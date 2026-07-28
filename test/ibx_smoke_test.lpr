program ibx_smoke_test;

{ Standalone smoke test for the IBX (MWASoftware ibx4lazarus) database layer.
  Connects to a real Firebird server, creates a table, writes and reads a row,
  and verifies the round trip, then exercises DDLExtractor (Marathon's DDL
  scripting engine) against a table, a view, a stored procedure, and a
  trigger built on that table - each object type is its own code path in
  DDLExtractor.pas. Used by CI to prove the IBX conversion and DDL extraction
  actually work against Firebird, not just that the app compiles.

  Also round-trips the modern (Firebird 3+) column types through
  ConvertFieldType, gated on the connected server's engine version, since
  those types silently produced unusable DDL (the internal RDB$nn domain name
  in place of the type) before they were mapped. }

{$MODE Delphi}

uses
  { First, and before anything that starts a thread: IBX's SQL monitor runs a
    reader thread, and without a thread driver the program dies with "no thread
    support compiled in" the moment one is created. The application itself gets
    this from the LCL; a console harness has to say so. }
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, Classes, DB, BufDataset, IB, IBDatabase, IBQuery, IBSQL, DDLExtractor,
  MarathonProjectCacheTypes, ScriptAs, SingletonQuery, SQLStatementText, XlsxWriter,
  IBXServices, MaintenanceOps, IBPerformanceMonitor, ObjectCatalogue, CsvImport, ProfilerQueries, SafeDisconnect, SchemaCompare, CreateDatabase, SchemaObjects, ibxscript,
  TableDesign, TableDesignIO, QueryModel, MarathonSQLMonitor, SQLTraceFormat,
  SchemaDiagram, SchemaDiagramIO, RowEdits, StrUtils;

type
  { The trace's event is "of object", so it needs a method to hand it to - a
    nested procedure will not do. }
  TTraceCollector = class
  public
    Lines: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Collect(Sender: TObject; const NewString: String);
  end;

  { OnFilterRecord is "of object" as well. This is what the SQL editor's
    filter box does to its result set, minus the box. }
  TRowFilter = class
  public
    Needle: String;
    procedure Accept(DataSet: TDataSet; var Accepted: Boolean);
  end;

var
  DB: TIBDatabase;
  Tr: TIBTransaction;
  Q: TIBQuery;
  Extractor: TDDLExtractor;
  DatabaseName, UserName, Password: String;
  Value: String;
  DDL: String;
  EngineVersion: String;
  EngineMajor: Integer;
  Ctx: TScriptAsContext;
  PositionalCtx: TScriptAsContext;
  Script: String;
  Single: TBufDataset;
  ParamMeta: TIBSQL;
  Cols: TStringList;
  ProfileId: Int64;
  Prefix: String;
  FaultDB: TIBDatabase;
  FaultTr: TIBTransaction;
  FaultQ: TIBQuery;

{ The generators end their statements the way a user would type them; the API
  takes one statement without the terminator. }
function StripTrailingSemicolon(const SQLText: String): String;
begin
  Result := TrimRight(SQLText);
  while (Result <> '') and (Result[Length(Result)] = ';') do
    Result := TrimRight(Copy(Result, 1, Length(Result) - 1));
end;

{ The Script As generators run their own metadata queries and commit the
  transaction when they are done, so a caller cannot assume one is still open
  afterwards. }
procedure EnsureTransaction;
begin
  if not Tr.Active then
    Tr.StartTransaction;
end;

{ Compiles a statement without running it. Firebird still parses it and
  resolves every name, so a wrong verb or a bad identifier fails here - which
  is what we want for DROP, where actually executing would destroy the objects
  the rest of the run depends on. }
procedure PrepareOnly(const SQLText, What: String);
var
  S: TIBSQL;
begin
  S := TIBSQL.Create(nil);
  try
    EnsureTransaction;
    S.Database := DB;
    S.Transaction := Tr;
    S.SQL.Text := StripTrailingSemicolon(SQLText);
    try
      S.Prepare;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: generated ', What, ' did not compile: ', E.Message);
        WriteLn(SQLText);
        Halt(1);
      end;
    end;
  finally
    S.Free;
  end;
end;

{ Checks IsExplainRequest against one input, including what it hands back as
  the statement to actually prepare. }
procedure CheckExplain(const Input: String; ExpectIsExplain: Boolean; const ExpectInner: String);
var
  Inner: String;
  Got: Boolean;
begin
  Got := IsExplainRequest(Input, Inner);
  if Got <> ExpectIsExplain then
  begin
    WriteLn('FAIL: IsExplainRequest("', Input, '") returned ', Got, ', expected ', ExpectIsExplain);
    Halt(1);
  end;
  if Got and (Inner <> ExpectInner) then
  begin
    WriteLn('FAIL: IsExplainRequest("', Input, '") gave inner SQL "', Inner,
      '", expected "', ExpectInner, '"');
    Halt(1);
  end;
end;

{ Fails the test run unless Needle appears in the extracted DDL. }
procedure RequireInDDL(const DDLText, Needle, What: String);
begin
  if Pos(UpperCase(Needle), UpperCase(DDLText)) = 0 then
  begin
    WriteLn('FAIL: extracted DDL is missing ', What, ' (expected "', Needle, '"):');
    WriteLn(DDLText);
    Halt(1);
  end;
end;

{ 'localhost:' out of 'localhost:/tmp/db.fdb', so the databases this test makes
  are reached the same way as the one it was pointed at - a local path when the
  caller used one, and over the network when they did not. Matched on ':/'
  rather than ':' so a Windows drive letter is not mistaken for a host. }
function HostPrefixOf(const FullName: String): String;
var
  P: Integer;
begin
  P := Pos(':/', FullName);
  if P > 1 then
    Result := Copy(FullName, 1, P)
  else
    Result := '';
end;

{ Firebird names an unnamed constraint INTEG_nnn, and the number differs
  between databases holding identical schemas. Such a name is therefore only
  ever safe on a line the script does not run. }
procedure RequireGeneratedNamesOnlyCommented(const Script: String);
var
  Lines: TStringList;
  Idx: Integer;
  InComment: Boolean;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Script;
    InComment := False;
    for Idx := 0 to Lines.Count - 1 do
    begin
      { A line inside a /* */ block is no more run than one behind --, and the
        script uses those blocks to report what it could not migrate. Tracking
        them is what makes this check mean what it says rather than fire on any
        mention at all. }
      if not InComment then
        InComment := (Pos('/*', Lines[Idx]) > 0) and
                     (Pos('*/', Lines[Idx]) < Pos('/*', Lines[Idx]));
      if (not InComment) and (Pos('INTEG_', UpperCase(Lines[Idx])) > 0) and
         (Copy(TrimLeft(Lines[Idx]), 1, 2) <> '--') then
      begin
        WriteLn('FAIL: a generated constraint name appears on a line the script would run:');
        WriteLn(Lines[Idx]);
        Halt(1);
      end;
      if InComment and (Pos('*/', Lines[Idx]) > 0) then
        InComment := False;
    end;
  finally
    Lines.Free;
  end;
end;

{ Order matters as much as presence: a view over another view has to be created
  second, and the script is run top to bottom. }
procedure RequireOrderInDDL(const Script, First, Second, What: String);
var
  PosFirst, PosSecond: Integer;
begin
  PosFirst := Pos(UpperCase(First), UpperCase(Script));
  PosSecond := Pos(UpperCase(Second), UpperCase(Script));
  if (PosFirst = 0) or (PosSecond = 0) or (PosFirst > PosSecond) then
  begin
    WriteLn('FAIL: ', What, ' - expected "', First, '" before "', Second, '"');
    WriteLn(Script);
    Halt(1);
  end;
end;

procedure RequireNotInDDL(const DDLText, Needle, What: String);
begin
  if Pos(UpperCase(Needle), UpperCase(DDLText)) <> 0 then
  begin
    WriteLn('FAIL: ', What, ' should not appear ("', Needle, '"):');
    WriteLn(DDLText);
    Halt(1);
  end;
end;

{ The SQL trace, actually tracing.

  keyword_test says which IBX flags Marathon's categories map onto; only a
  running server can say whether the monitor then delivers anything. That is
  the question that matters here, because the component it replaced had every
  property right and no behaviour at all - so a check that only looked at the
  settings would have passed against the stub.

  IBX delivers through a reader thread that calls Synchronize, so a console
  program has to pump the synchronise queue itself; a GUI one gets it from the
  message loop. }
constructor TTraceCollector.Create;
begin
  inherited Create;
  Lines := TStringList.Create;
end;

destructor TTraceCollector.Destroy;
begin
  Lines.Free;
  inherited Destroy;
end;

procedure TTraceCollector.Collect(Sender: TObject; const NewString: String);
begin
  { On the main thread by the time Synchronize has delivered it. }
  Lines.Add(NewString);
end;

procedure TestSQLTraceLive;
var
  Monitor: TIB_Monitor;
  Collector: TTraceCollector;
  Waited: Integer;
begin
  WriteLn('SQL trace against a live server:');
  Collector := TTraceCollector.Create;
  Monitor := TIB_Monitor.Create(nil);
  try
    Monitor.OnMonitorOutputItem := Collector.Collect;
    Monitor.IncludeTimeStamp := True;
    Monitor.MonitorGroups := [mgStatement];
    Monitor.StatementGroups := [sgPrepare, sgExecute, sgFetch, sgError];
    Monitor.Enabled := True;
    { The publishing half: a connection sends nothing until it is told to. }
    Monitor.Watch(DB);

    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.Close;
    Q.SQL.Text := 'select 1 as TRACE_PROBE from rdb$database';
    Q.Open;
    Q.Close;
    if Tr.InTransaction then
      Tr.Commit;

    { The reader thread has its own pace, so this waits rather than assuming.
      Two seconds is generous; if nothing has arrived by then nothing is
      going to. }
    Waited := 0;
    while (Collector.Lines.Count = 0) and (Waited < 2000) do
    begin
      CheckSynchronize(50);
      Inc(Waited, 50);
    end;

    if Collector.Lines.Count = 0 then
    begin
      WriteLn('FAIL: the SQL trace received nothing at all - the monitor is ' +
        'still not connected to anything');
      Halt(1);
    end;
    WriteLn('  ok   the trace receives events (', Collector.Lines.Count, ' line(s))');

    { Not merely some traffic: the statement that was run. Anything else would
      pass while tracing a different connection's work. }
    if Pos('TRACE_PROBE', Collector.Lines.Text) = 0 then
    begin
      WriteLn('FAIL: the trace produced lines but not the statement that ran:');
      WriteLn(Copy(Collector.Lines.Text, 1, 500));
      Halt(1);
    end;
    WriteLn('  ok   and they contain the statement that was executed');

    { The timestamp the Options dialog has always offered and that has never
      done anything, because nothing was producing lines for it to affect. }
    if Pos(FormatDateTime('yyyy-mm-dd', Now), Collector.Lines.Text) = 0 then
    begin
      WriteLn('FAIL: IncludeTimeStamp produced no timestamp');
      Halt(1);
    end;
    WriteLn('  ok   with the timestamp the settings asked for');

    { Switching it off has to stop it, or the window would keep filling after
      the user turned tracing off. }
    Monitor.Enabled := False;
    Collector.Lines.Clear;
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.SQL.Text := 'select 2 as TRACE_SILENT from rdb$database';
    Q.Open;
    Q.Close;
    if Tr.InTransaction then
      Tr.Commit;
    CheckSynchronize(200);
    if Pos('TRACE_SILENT', Collector.Lines.Text) > 0 then
    begin
      WriteLn('FAIL: the trace kept reporting after being disabled');
      Halt(1);
    end;
    WriteLn('  ok   and stop when tracing is switched off');
  finally
    Monitor.Free;
    Collector.Free;
  end;
end;

{ The server's own keyword list.

  Firebird 5 added RDB$KEYWORDS, so the SQL editor can be told what this server
  reserves instead of a list being kept by hand in FirebirdKeywords. What only
  a server can answer is whether the table is there and what is in it. }
procedure TestServerKeywordList;
var
  Words: TStringList;
begin
  WriteLn('Server keyword list:');
  if not Tr.InTransaction then
    Tr.StartTransaction;
  Words := ReadServerKeywords(DB, Tr);
  try
    if EngineMajor < 5 then
    begin
      { No RDB$KEYWORDS before Firebird 5, and an empty list is the signal to
        fall back rather than a failure. }
      WriteLn('  ok   server is Firebird ', EngineMajor,
        ', so no keyword list and the built-in one is used');
      Exit;
    end;

    if Words.Count < 100 then
    begin
      WriteLn('FAIL: the server reported only ', Words.Count, ' keyword(s)');
      Halt(1);
    end;
    WriteLn('  ok   the server reports its keywords (', Words.Count, ')');

    { Words that must be in any Firebird's list, so this is checking the
      contents rather than merely the row count. }
    if (Words.IndexOf('SELECT') < 0) or (Words.IndexOf('FROM') < 0) then
    begin
      WriteLn('FAIL: the list is missing SELECT or FROM');
      Halt(1);
    end;
    WriteLn('  ok   including the ones every version has');

    { And the reason for asking at all: words newer than the list this program
      would otherwise carry. }
    if Words.IndexOf('BLOB_APPEND') < 0 then
    begin
      WriteLn('FAIL: the list is missing BLOB_APPEND, added in Firebird 5');
      Halt(1);
    end;
    WriteLn('  ok   and ones newer than this program''s own list');
  finally
    Words.Free;
  end;
  if Tr.InTransaction then
    Tr.Commit;
end;

{ One table's whole life, through the pieces that make it.

  Every other check here exercises one unit against the server. This walks a
  table from nothing to nothing through all of them in the order a user would:
  design it, read it back, put rows in, extract its DDL, query it, see it in
  the schema diagram, alter it, and drop it.

  It is worth having separately because the units agree with each other only if
  each hands the next something it can use, and nothing that tests them one at
  a time can show that. Each step below uses what the previous step produced
  rather than a value written here. }
procedure TestEndToEndTableLifecycle;
var
  Design, Reread, Target: TTableDesign;
  Col: TColumnDesign;
  Statements: TStringList;
  Extractor: TDDLExtractor;
  DDL: String;
  Model: TQueryModel;
  Diagram: TSchemaDiagram;
  Edits: TRowEditList;
  E: TRowEdit;
  Idx, Rows: Integer;
  Found: Boolean;

  { Its own, rather than the Col above: that one is declared further down the
    file, and a walk that depends on where a helper sits is a walk that breaks
    when the file is reordered. }
  function NewCol(const AName, AType: String;
    ANotNull: Boolean = False): TColumnDesign;
  begin
    Result.OriginalName := '';
    Result.Name := AName;
    Result.DataType := AType;
    Result.NotNull := ANotNull;
    Result.DefaultValue := '';
    Result.ComputedAs := '';
    Result.Collation := '';
  end;

  procedure Run(const SQLText, What: String);
  var
    S: TIBSQL;
  begin
    if not Tr.InTransaction then
      Tr.StartTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := StripTrailingSemicolon(SQLText);
      try
        S.ExecQuery;
      except
        on Ex: Exception do
        begin
          WriteLn('FAIL: end-to-end, ', What, ': ', Ex.Message);
          WriteLn(SQLText);
          if Tr.InTransaction then
            Tr.Rollback;
          Halt(1);
        end;
      end;
    finally
      S.Free;
    end;
    if Tr.InTransaction then
      Tr.Commit;
  end;

begin
  WriteLn('End to end - a table''s whole life:');

  if not Tr.InTransaction then
    Tr.StartTransaction;
  Q.SQL.Text := 'execute block as begin ' +
    'if (exists(select 1 from rdb$relations where rdb$relation_name = ''E2E_LINE'')) then ' +
    '  execute statement ''drop table E2E_LINE''; ' +
    'if (exists(select 1 from rdb$relations where rdb$relation_name = ''E2E_ITEM'')) then ' +
    '  execute statement ''drop table E2E_ITEM''; end';
  Q.ExecSQL;
  Tr.Commit;

  { 1. Designed, not written by hand - the designer's own model builds it. }
  Design := TTableDesign.Create('E2E_ITEM');
  try
    Design.AddColumn(NewCol('ID', 'integer', True));
    Design.AddColumn(NewCol('NAME', 'varchar(30)'));
    Design.PrimaryKey.Add('ID');
    Run(CreateTableScript(Design), 'creating the designed table');
    WriteLn('  ok   the designer''s script creates the table');
  finally
    Design.Free;
  end;

  { 2. Read back through the designer's reader. What it returns is what every
    later step works from - not a copy of what was written above. }
  if not Tr.InTransaction then
    Tr.StartTransaction;
  Design := ReadTableDesign(DB, Tr, 'E2E_ITEM');
  if not Assigned(Design) then
  begin
    WriteLn('FAIL: end-to-end, the table did not read back');
    Halt(1);
  end;
  if (Design.ColumnCount <> 2) or (Design.PrimaryKey.Count <> 1) then
  begin
    WriteLn('FAIL: end-to-end, read back ', Design.ColumnCount,
      ' column(s) and ', Design.PrimaryKey.Count, ' key column(s)');
    Halt(1);
  end;
  WriteLn('  ok   and the reader sees what the designer made');

  { 3. Rows, through the statements the data grid would produce. }
  Edits := TRowEditList.Create;
  try
    for Idx := 1 to 3 do
    begin
      E := Edits.Add(reInsert, 'E2E_ITEM');
      E.AddValue('ID', IntToStr(Idx), False, True);
      E.AddValue('NAME', 'row ' + IntToStr(Idx));
    end;
    if Edits.UnsafeCount > 0 then
    begin
      WriteLn('FAIL: end-to-end, the grid''s inserts were reported unsafe');
      Halt(1);
    end;
    for Idx := 0 to Edits.Count - 1 do
      Run(RowEditStatement(Edits[Idx]), 'running the grid''s insert');
  finally
    Edits.Free;
  end;
  WriteLn('  ok   the data grid''s statements put rows in it');

  { 4. Its DDL, from the extractor, naming the columns the reader found. }
  Extractor := TDDLExtractor.Create(nil);
  try
    Extractor.Database := DB;
    Extractor.Transaction := Tr;
    Extractor.SQLDialect := 3;
    Extractor.IsInterbase6 := True;
    EnsureTransaction;
    DDL := Extractor.Extract(ddlTable, ddlstNone, 'E2E_ITEM');
    if Tr.Active then
      Tr.Commit;
  finally
    Extractor.Free;
  end;
  for Idx := 0 to Design.ColumnCount - 1 do
    if Pos(AnsiUpperCase(Trim(Design.Column(Idx).Name)), AnsiUpperCase(DDL)) = 0 then
    begin
      WriteLn('FAIL: end-to-end, the extracted DDL is missing ',
        Design.Column(Idx).Name);
      Halt(1);
    end;
  WriteLn('  ok   the extractor names every column the reader found');

  { 5. A query built over it by the query builder, run as it generates it. }
  Model := TQueryModel.Create;
  try
    Model.AddTable('', 'E2E_ITEM');
    for Idx := 0 to Design.ColumnCount - 1 do
      Model.AddColumn(Model.Tables[0].Alias, Design.Column(Idx).Name);
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.Close;
    Q.SQL.Text := StripTrailingSemicolon(BuildSelectSQL(Model));
    try
      Q.Open;
      Rows := 0;
      while not Q.EOF do
      begin
        Inc(Rows);
        Q.Next;
      end;
      Q.Close;
    except
      on Ex: Exception do
      begin
        WriteLn('FAIL: end-to-end, the built query was rejected: ', Ex.Message);
        Halt(1);
      end;
    end;
    if Rows <> 3 then
    begin
      WriteLn('FAIL: end-to-end, the built query returned ', Rows,
        ' row(s), expected the 3 that were inserted');
      Halt(1);
    end;
    if Tr.InTransaction then
      Tr.Commit;
  finally
    Model.Free;
  end;
  WriteLn('  ok   a query built over it returns the rows that were put in');

  { 6. And it appears in the diagram, with the columns it was designed with. }
  if not Tr.InTransaction then
    Tr.StartTransaction;
  Diagram := ReadSchemaDiagram(DB, Tr);
  try
    if not Assigned(Diagram.FindTable('E2E_ITEM')) then
    begin
      WriteLn('FAIL: end-to-end, the table is not in the schema diagram');
      Halt(1);
    end;
    if Diagram.FindTable('E2E_ITEM').Columns.Count <> Design.ColumnCount then
    begin
      WriteLn('FAIL: end-to-end, the diagram shows ',
        Diagram.FindTable('E2E_ITEM').Columns.Count,
        ' column(s), the designer made ', Design.ColumnCount);
      Halt(1);
    end;
  finally
    Diagram.Free;
  end;
  WriteLn('  ok   and it appears in the schema diagram with those columns');

  { 7. Altered through the designer's diff, on rows that already exist. }
  Target := Design.Clone;
  try
    Col := Target.Column(1);
    Col.DataType := 'varchar(60)';
    Target.SetColumn(1, Col);
    Target.AddColumn(NewCol('QTY', 'integer'));
    Statements := TableDesignStatements(Design, Target);
    try
      if Statements.Count = 0 then
      begin
        WriteLn('FAIL: end-to-end, altering the design generated nothing');
        Halt(1);
      end;
      if not Tr.InTransaction then
        Tr.StartTransaction;
      try
        ApplyTableDesign(DB, Tr, Statements.ToStringArray);
        Tr.Commit;
      except
        on Ex: Exception do
        begin
          WriteLn('FAIL: end-to-end, the alter script was rejected: ', Ex.Message);
          Halt(1);
        end;
      end;
    finally
      Statements.Free;
    end;
  finally
    Target.Free;
  end;

  if not Tr.InTransaction then
    Tr.StartTransaction;
  Reread := ReadTableDesign(DB, Tr, 'E2E_ITEM');
  try
    Found := False;
    for Idx := 0 to Reread.ColumnCount - 1 do
      if SameText(Reread.Column(Idx).Name, 'QTY') then
        Found := True;
    if not Found or (Reread.ColumnCount <> 3) then
    begin
      WriteLn('FAIL: end-to-end, the alter did not land - ',
        Reread.ColumnCount, ' column(s), QTY found: ', Found);
      Halt(1);
    end;
  finally
    Reread.Free;
  end;
  { The rows put in at step 3 have to have survived being altered around. }
  Q.Close;
  Q.SQL.Text := 'select count(*) from E2E_ITEM';
  Q.Open;
  Rows := Q.Fields[0].AsInteger;
  Q.Close;
  if Tr.InTransaction then
    Tr.Commit;
  if Rows <> 3 then
  begin
    WriteLn('FAIL: end-to-end, ', Rows, ' row(s) survived the alter, expected 3');
    Halt(1);
  end;
  WriteLn('  ok   the designer alters it without losing the rows in it');

  { 8. A second table referencing the first, so the relationship path is
    walked too: the diagram has to see the key, and the query builder has to
    join across it in an order the server accepts. }
  Run('create table E2E_LINE (ID integer not null primary key, ' +
      'ITEM_ID integer references E2E_ITEM(ID), QTY integer)',
      'creating the referencing table');
  Run('insert into E2E_LINE (ID, ITEM_ID, QTY) values (1, 1, 5)',
      'putting a row in it');

  if not Tr.InTransaction then
    Tr.StartTransaction;
  Diagram := ReadSchemaDiagram(DB, Tr);
  try
    Found := False;
    for Idx := 0 to Diagram.LinkCount - 1 do
      if SameText(Diagram.Links[Idx].FromTable, 'E2E_LINE') and
         SameText(Diagram.Links[Idx].ToTable, 'E2E_ITEM') then
      begin
        Found := True;
        if not SameText(Trim(Diagram.Links[Idx].FromColumn), 'ITEM_ID') then
        begin
          WriteLn('FAIL: end-to-end, the diagram read the key as ',
            Diagram.Links[Idx].FromColumn);
          Halt(1);
        end;
      end;
    if not Found then
    begin
      WriteLn('FAIL: end-to-end, the diagram did not see the foreign key');
      Halt(1);
    end;
  finally
    Diagram.Free;
  end;
  WriteLn('  ok   the diagram sees the key between the two tables');

  { The builder is given the tables in the order that does *not* work as a
    FROM clause - the detail table first - so this exercises the ordering
    rather than happening to agree with it. }
  Model := TQueryModel.Create;
  try
    Model.AddTable('', 'E2E_LINE');
    Model.AddTable('', 'E2E_ITEM');
    Model.AddJoin(jkInner, 'EL', 'ITEM_ID', 'EI', 'ID');
    Model.AddColumn('EI', 'NAME');
    Model.AddColumn('EL', 'QTY');
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.Close;
    Q.SQL.Text := StripTrailingSemicolon(BuildSelectSQL(Model));
    try
      Q.Open;
      Rows := 0;
      while not Q.EOF do
      begin
        Inc(Rows);
        Q.Next;
      end;
      Q.Close;
    except
      on Ex: Exception do
      begin
        WriteLn('FAIL: end-to-end, the joined query was rejected: ', Ex.Message);
        WriteLn(BuildSelectSQL(Model));
        Halt(1);
      end;
    end;
    if Rows <> 1 then
    begin
      WriteLn('FAIL: end-to-end, the joined query returned ', Rows,
        ' row(s), expected 1');
      Halt(1);
    end;
    if Tr.InTransaction then
      Tr.Commit;
  finally
    Model.Free;
  end;
  WriteLn('  ok   and a query joining across it runs and returns the row');

  { 9. The key is what stops the parent going while a child points at it -
    the server's job, and worth knowing this walk has not disabled it. }
  if not Tr.InTransaction then
    Tr.StartTransaction;
  Q.Close;
  Q.SQL.Text := 'delete from E2E_ITEM';
  Found := False;
  try
    Q.ExecSQL;
  except
    on Ex: Exception do
      Found := True;
  end;
  if Tr.InTransaction then
    Tr.Rollback;
  if not Found then
  begin
    WriteLn('FAIL: end-to-end, the parent was deleted with a child still ' +
      'referencing it');
    Halt(1);
  end;
  WriteLn('  ok   and the key still refuses to orphan the child');

  Design.Free;
  Run('drop table E2E_LINE', 'dropping the referencing table');
  Run('drop table E2E_ITEM', 'dropping the table');
  WriteLn('  ok   and both drop cleanly at the end');
end;

{ The schema diagram's reader, against a real server.

  The layout is checked in keyword_test without a database. What only a server
  can answer is whether the catalogue queries are right: a foreign key lives in
  three tables at once - the constraint, the pair of constraints it joins, and
  the index segments giving the columns - and getting the join wrong yields
  either nothing or a cross product, both of which look like a plausible
  diagram until someone counts the lines. }
procedure TestSchemaDiagramReader;
var
  D: TSchemaDiagram;
  Found: Boolean;
  Idx: Integer;
  L: TDiagramLink;
begin
  WriteLn('Schema diagram reader:');

  if not Tr.InTransaction then
    Tr.StartTransaction;
  Q.SQL.Text := 'execute block as begin ' +
    'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''SD_PARENT'')) then ' +
    '  execute statement ''create table SD_PARENT (ID integer not null primary key, NAME varchar(20))''; ' +
    'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''SD_CHILD'')) then ' +
    '  execute statement ''create table SD_CHILD (ID integer not null primary key, ' +
    '    PARENT_ID integer references SD_PARENT(ID), NOTE varchar(20))''; ' +
    'end';
  Q.ExecSQL;
  Tr.Commit;

  if not Tr.InTransaction then
    Tr.StartTransaction;
  D := ReadSchemaDiagram(DB, Tr);
  try
    if D.TableCount = 0 then
    begin
      WriteLn('FAIL: the diagram reader found no tables at all');
      Halt(1);
    end;
    WriteLn('  ok   it reads the tables (', D.TableCount, ')');

    if not Assigned(D.FindTable('SD_PARENT')) or
       not Assigned(D.FindTable('SD_CHILD')) then
    begin
      WriteLn('FAIL: the reader did not find the two test tables');
      Halt(1);
    end;
    { Columns, in declaration order - the order they read in the diagram is the
      order they read in the table. }
    if (D.FindTable('SD_CHILD').Columns.Count <> 3) or
       (Trim(D.FindTable('SD_CHILD').Columns[0]) <> 'ID') then
    begin
      WriteLn('FAIL: SD_CHILD read back with ',
        D.FindTable('SD_CHILD').Columns.Count, ' column(s), first "',
        D.FindTable('SD_CHILD').Columns[0], '"');
      Halt(1);
    end;
    WriteLn('  ok   with their columns, in declaration order');

    { Views are not tables and must not be drawn as them. }
    if Assigned(D.FindTable('EDIT_VW')) then
    begin
      WriteLn('FAIL: a view was read as a table');
      Halt(1);
    end;
    WriteLn('  ok   and without the views');

    { The key itself, both ends and the right columns. }
    Found := False;
    for Idx := 0 to D.LinkCount - 1 do
    begin
      L := D.Links[Idx];
      if SameText(L.FromTable, 'SD_CHILD') and SameText(L.ToTable, 'SD_PARENT') then
      begin
        Found := True;
        if not SameText(Trim(L.FromColumn), 'PARENT_ID') or
           not SameText(Trim(L.ToColumn), 'ID') then
        begin
          WriteLn('FAIL: the key was read as ', L.FromColumn, ' -> ', L.ToColumn);
          Halt(1);
        end;
      end;
    end;
    if not Found then
    begin
      WriteLn('FAIL: the foreign key between the two tables was not read');
      Halt(1);
    end;
    WriteLn('  ok   and the foreign key, with the column at each end');

    { One line, not several. Joining the segments without matching their
      positions gives a row per pair and would draw the same key repeatedly. }
    Found := False;
    Idx := 0;
    for Idx := 0 to D.LinkCount - 1 do
      if SameText(D.Links[Idx].ConstraintName,
                  D.Links[0].ConstraintName) and (Idx > 0) and
         SameText(D.Links[Idx].FromTable, D.Links[0].FromTable) then
        Found := True;
    if Found then
    begin
      WriteLn('FAIL: a single-column key produced more than one link');
      Halt(1);
    end;
    WriteLn('  ok   once each, not once per pair of columns');
  finally
    D.Free;
  end;
  if Tr.InTransaction then
    Tr.Commit;
end;

{ The query builder's SQL, against a real server.

  keyword_test says what the builder should generate; only Firebird can say
  whether the result parses. Join order is the reason this matters: a query
  whose FROM clause names a table before the join that introduces it is
  perfectly well-formed text and is rejected, so a builder that gets it wrong
  looks right until someone runs it. }
procedure TestQueryBuilderSQL;
var
  M: TQueryModel;
  SQL: String;

  procedure RunGenerated(const What: String);
  begin
    SQL := BuildSelectSQL(M);
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.Close;
    { The generated statement ends in a semicolon for the editor's benefit; the
      engine takes one statement and does not want it. }
    Q.SQL.Text := StripTrailingSemicolon(SQL);
    try
      Q.Open;
      Q.Close;
      WriteLn('  ok   ', What);
    except
      on E: Exception do
      begin
        WriteLn('FAIL: the query builder generated SQL Firebird rejected (', What, '): ',
          E.Message);
        WriteLn(SQL);
        if Tr.InTransaction then
          Tr.Rollback;
        Halt(1);
      end;
    end;
    if Tr.InTransaction then
      Tr.Commit;
  end;

begin
  WriteLn('Query builder SQL:');

  { Prepared here rather than reusing another suite's tables, so this stands on
    its own and says what it depends on. }
  if not Tr.InTransaction then
    Tr.StartTransaction;
  Q.SQL.Text := 'execute block as begin ' +
    'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''QB_A'')) then ' +
    '  execute statement ''create table QB_A (ID integer not null primary key, NAME varchar(20))''; ' +
    'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''QB_B'')) then ' +
    '  execute statement ''create table QB_B (ID integer not null primary key, A_ID integer, NOTE varchar(20))''; ' +
    'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''QB_C'')) then ' +
    '  execute statement ''create table QB_C (ID integer not null primary key, B_ID integer, QTY integer)''; ' +
    'end';
  Q.ExecSQL;
  Tr.Commit;

  { One table. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_A');
    RunGenerated('one table, everything selected');
  finally
    M.Free;
  end;

  { Columns, a filter and a sort. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_A');
    M.AddColumn('QA', 'NAME').OutputName := 'CUSTOMER';
    with M.AddColumn('QA', 'ID') do
    begin
      Filter := '> 0';
      Sort := soDescending;
    end;
    M.Distinct := True;
    RunGenerated('columns with an alias, a filter, a sort and DISTINCT');
  finally
    M.Free;
  end;

  { Two tables joined. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_A');
    M.AddTable('', 'QB_B');
    M.AddJoin(jkLeft, 'QA', 'ID', 'QB', 'A_ID');
    M.AddColumn('QA', 'NAME');
    M.AddColumn('QB', 'NOTE');
    RunGenerated('two tables with a left join');
  finally
    M.Free;
  end;

  { Three tables added in an order that is not a valid FROM order.

    The chain is QB_A <- QB_B <- QB_C, but they are dropped C, A, B - which is
    what someone does who starts from the detail table and then adds what it
    looks up. Emitting them in the order they were added puts QB_A second,
    where the only join it has names QB_B, which is not in the query yet.

    An earlier version of this test added them A, B, C. That order is already
    valid, so it passed whether or not JoinOrder did anything at all. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_C');
    M.AddTable('', 'QB_A');
    M.AddTable('', 'QB_B');
    M.AddJoin(jkInner, 'QC', 'B_ID', 'QB', 'ID');
    M.AddJoin(jkInner, 'QB', 'A_ID', 'QA', 'ID');
    M.AddColumn('QA', 'NAME');
    M.AddColumn('QC', 'QTY');
    RunGenerated('three tables added in an order the FROM clause cannot use');
  finally
    M.Free;
  end;

  { A table joined to nothing still has to produce SQL that runs - it is a
    cross join, which is a legitimate if rarely intended query. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_A');
    M.AddTable('', 'QB_B');
    M.AddTable('', 'QB_C');
    M.AddJoin(jkInner, 'QB', 'A_ID', 'QA', 'ID');
    RunGenerated('an unjoined table becomes a cross join that still runs');
  finally
    M.Free;
  end;

  { A self-join, which is what two aliases for one table are for. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'QB_A');
    M.AddTable('', 'QB_A');
    M.AddJoin(jkInner, 'QA', 'ID', 'QA2', 'ID');
    M.AddColumn('QA', 'NAME');
    M.AddColumn('QA2', 'NAME');
    RunGenerated('a self-join through two aliases for one table');
  finally
    M.Free;
  end;

  { And with quoting on, which changes every identifier in the statement. }
  M := TQueryModel.Create;
  try
    M.QuoteIdentifiers := True;
    M.AddTable('', 'QB_A');
    M.AddTable('', 'QB_B');
    M.AddJoin(jkInner, 'QA', 'ID', 'QB', 'A_ID');
    M.AddColumn('QA', 'NAME');
    RunGenerated('quoted identifiers throughout');
  finally
    M.Free;
  end;
end;

{ A column, with only what a given check is about spelled out. An empty
  original name is what marks a column as one being added. }
function Col(const AOriginal, AName, AType: String; ANotNull: Boolean = False;
  const ADefault: String = ''): TColumnDesign;
begin
  Result.OriginalName := AOriginal;
  Result.Name := AName;
  Result.DataType := AType;
  Result.NotNull := ANotNull;
  Result.DefaultValue := ADefault;
  Result.ComputedAs := '';
  Result.Collation := '';
end;

{ The table designer's model against a real server.

  keyword_test already checks what a given edit should generate, without a
  database. What it cannot check is the half that matters most: that Firebird
  accepts those statements, and that a table read back out of the catalogue
  says the same thing as the design that made it. Those two are what make a
  preview worth trusting - a script nobody ran is a guess. }
procedure TestTableDesignRoundTrip;
var
  Original, Target, Reread: TTableDesign;
  Statements: TStringList;
  C: TColumnDesign;
  Changes: TTableDesignChangeArray;
  Idx: Integer;
  Names: String;

  procedure Fail(const What: String);
  begin
    WriteLn('FAIL: table design round trip: ', What);
    if Tr.InTransaction then
      Tr.Rollback;
    Halt(1);
  end;

  procedure RunDDL(const SQLText: String);
  begin
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.SQL.Text := SQLText;
    Q.ExecSQL;
    Tr.Commit;
  end;

  { The column of that name, or a failure - so a missing column is reported as
    itself rather than as a range-check error further down. }
  function ColumnNamed(Design: TTableDesign; const AName: String): TColumnDesign;
  var
    N: Integer;
  begin
    for N := 0 to Design.ColumnCount - 1 do
      if SameText(Design.Column(N).Name, AName) then
        Exit(Design.Column(N));
    Fail('no column called ' + AName + ' after the change');
  end;

begin
  WriteLn('Table designer round trip:');

  if not Tr.InTransaction then
    Tr.StartTransaction;
  Q.SQL.Text := 'execute block as begin ' +
    'if (exists(select 1 from rdb$relations where rdb$relation_name = ''DESIGN_T'')) then ' +
    '  execute statement ''drop table DESIGN_T''; end';
  Q.ExecSQL;
  Tr.Commit;

  Original := TTableDesign.Create('DESIGN_T');
  try
    Original.AddColumn(Col('', 'ID', 'integer', True));
    Original.AddColumn(Col('', 'NAME', 'varchar(30)'));
    Original.AddColumn(Col('', 'QTY', 'integer', False, '7'));
    Original.PrimaryKey.Add('ID');

    { Does the server accept what CreateTableScript generates? Nothing below
      means anything if it does not. }
    try
      RunDDL(CreateTableScript(Original));
    except
      on E: Exception do
        Fail('Firebird rejected the generated CREATE TABLE: ' + E.Message +
          ' - script was: ' + CreateTableScript(Original));
    end;
    WriteLn('  ok   the generated CREATE TABLE runs');
  finally
    Original.Free;
  end;

  if not Tr.InTransaction then
    Tr.StartTransaction;

  { What the designer would show when the table is opened. }
  Original := ReadTableDesign(DB, Tr, 'DESIGN_T');
  if not Assigned(Original) then
    Fail('the table just created did not read back');
  try
    if Original.ColumnCount <> 3 then
      Fail('read back ' + IntToStr(Original.ColumnCount) + ' columns, expected 3');
    if not SameText(Trim(ColumnNamed(Original, 'NAME').DataType), 'varchar(30)') then
      Fail('VARCHAR(30) read back as "' + ColumnNamed(Original, 'NAME').DataType + '"');
    if not ColumnNamed(Original, 'ID').NotNull then
      Fail('a NOT NULL column read back as nullable');
    if ColumnNamed(Original, 'NAME').NotNull then
      Fail('a nullable column read back as NOT NULL');
    if Trim(ColumnNamed(Original, 'QTY').DefaultValue) <> '7' then
      Fail('the default read back as "' + ColumnNamed(Original, 'QTY').DefaultValue +
        '", expected 7 - the DEFAULT keyword should have been stripped');
    if (Original.PrimaryKey.Count <> 1) or
       not SameText(Trim(Original.PrimaryKey[0]), 'ID') then
      Fail('the primary key did not read back');
    if Trim(ColumnNamed(Original, 'ID').OriginalName) = '' then
      Fail('a column read from the database has no original name, so every ' +
        'column would look like one being added');
    WriteLn('  ok   the table reads back as the design that made it');

    { The property that ties the two halves together: a design read from the
      database, compared with itself, must generate nothing. If the reader and
      the generator disagreed about how a type is spelled - "VARCHAR(30)"
      against "varchar(30) CHARACTER SET NONE", say - opening a table and
      pressing Apply without touching anything would rewrite columns. }
    Reread := ReadTableDesign(DB, Tr, 'DESIGN_T');
    try
      Changes := TableDesignChanges(Original, Reread);
      if Length(Changes) <> 0 then
      begin
        Names := '';
        for Idx := 0 to High(Changes) do
          Names := Names + #10 + '         ' + Changes[Idx].Statement;
        Fail('an untouched table generated ' + IntToStr(Length(Changes)) +
          ' statement(s), so the reader and the generator disagree:' + Names);
      end;
      WriteLn('  ok   reading a table twice generates no changes');
    finally
      Reread.Free;
    end;

    { Now every kind of change at once, which is also the case most likely to
      come out in an order the server rejects. }
    Target := Original.Clone;
    try
      C := Target.Column(1);
      C.Name := 'FULL_NAME';       { rename }
      C.DataType := 'varchar(60)'; { and widen, by the new name }
      C.NotNull := True;           { and make required }
      Target.SetColumn(1, C);

      C := Target.Column(2);
      C.DefaultValue := '0';       { change a default }
      Target.SetColumn(2, C);

      Target.AddColumn(Col('', 'EMAIL', 'varchar(100)'));  { add }

      Statements := TableDesignStatements(Original, Target);
      try
        if Statements.Count = 0 then
          Fail('five edits generated no statements at all');
        try
          ApplyTableDesign(DB, Tr, Statements.ToStringArray);
          Tr.Commit;
        except
          on E: Exception do
            Fail('Firebird rejected the generated script: ' + E.Message +
              ' - script was: ' + StringReplace(Statements.Text, #10, ' ', [rfReplaceAll]));
        end;
        WriteLn('  ok   the generated ALTER script runs (',
          Statements.Count, ' statements)');
      finally
        Statements.Free;
      end;
    finally
      Target.Free;
    end;

    { And the changes are actually there, rather than merely accepted. }
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Reread := ReadTableDesign(DB, Tr, 'DESIGN_T');
    if not Assigned(Reread) then
      Fail('the table did not read back after the changes');
    try
      if Reread.ColumnCount <> 4 then
        Fail('expected 4 columns after adding one, got ' + IntToStr(Reread.ColumnCount));
      if not SameText(Trim(ColumnNamed(Reread, 'FULL_NAME').DataType), 'varchar(60)') then
        Fail('the renamed column is "' + ColumnNamed(Reread, 'FULL_NAME').DataType +
          '", expected varchar(60) - the widen did not follow the rename');
      if not ColumnNamed(Reread, 'FULL_NAME').NotNull then
        Fail('the renamed column did not become NOT NULL');
      if Trim(ColumnNamed(Reread, 'QTY').DefaultValue) <> '0' then
        Fail('the changed default is "' + ColumnNamed(Reread, 'QTY').DefaultValue + '"');
      if not SameText(Trim(ColumnNamed(Reread, 'EMAIL').DataType), 'varchar(100)') then
        Fail('the added column is "' + ColumnNamed(Reread, 'EMAIL').DataType + '"');
      WriteLn('  ok   every change is in the table afterwards');
    finally
      Reread.Free;
    end;

    { Dropping, separately, because it is the destructive one and because it
      has to work on a table that has rows in it. }
    if not Tr.InTransaction then
      Tr.StartTransaction;
    Q.SQL.Text := 'insert into DESIGN_T (ID, FULL_NAME) values (1, ''x'')';
    Q.ExecSQL;
    Tr.Commit;

    if not Tr.InTransaction then
      Tr.StartTransaction;
    Reread := ReadTableDesign(DB, Tr, 'DESIGN_T');
    try
      Target := Reread.Clone;
      try
        for Idx := 0 to Target.ColumnCount - 1 do
          if SameText(Target.Column(Idx).Name, 'EMAIL') then
          begin
            Target.DropColumn(Idx);
            Break;
          end;
        Statements := TableDesignStatements(Reread, Target);
        try
          try
            ApplyTableDesign(DB, Tr, Statements.ToStringArray);
            Tr.Commit;
          except
            on E: Exception do
              Fail('Firebird rejected the generated DROP: ' + E.Message);
          end;
        finally
          Statements.Free;
        end;
      finally
        Target.Free;
      end;
    finally
      Reread.Free;
    end;

    if not Tr.InTransaction then
      Tr.StartTransaction;
    Reread := ReadTableDesign(DB, Tr, 'DESIGN_T');
    try
      if Reread.ColumnCount <> 3 then
        Fail('the dropped column is still there');
      WriteLn('  ok   a dropped column goes, on a table with rows in it');
    finally
      Reread.Free;
    end;

    { The name a key has to be dropped by, which cannot be guessed: Firebird
      calls an unnamed one INTEG_nnn and the number differs between databases. }
    if PrimaryKeyConstraintName(DB, Tr, 'DESIGN_T') = '' then
      Fail('the primary key constraint name did not read back, so a designer ' +
        'could not drop the key');
    WriteLn('  ok   the primary key constraint name reads back');

    if Tr.InTransaction then
      Tr.Commit;
  finally
    Original.Free;
  end;

  RunDDL('drop table DESIGN_T');
end;

{ File > Create Database, minus the dialog. The wizard it replaces was a
  Windows COM component that could not run here at all, so this is the first
  time the feature has worked on this platform - which makes checking that the
  options actually reach the database the whole point. }
procedure TestCreateDatabase(const HostPrefix: String);
var
  Opts: TCreateDatabaseOptions;
  Err: String;
  Made: TIBDatabase;
  MadeTr: TIBTransaction;
  MadeQ: TIBQuery;
  PageSize: Integer;
  CharSet: String;
const
  Path = '/tmp/marathon_create_probe.fdb';
begin
  Opts.ServerName := Copy(HostPrefix, 1, Length(HostPrefix) - 1);
  Opts.FileName := Path;
  Opts.UserName := UserName;
  Opts.Password := Password;
  Opts.CharacterSet := 'WIN1252';
  Opts.PageSize := 16384;
  Opts.Dialect := 3;

  if DatabaseConnectString(Opts) <> HostPrefix + Path then
  begin
    WriteLn('FAIL: connect string was "', DatabaseConnectString(Opts),
      '", expected "', HostPrefix + Path, '"');
    Halt(1);
  end;

  { Clear a leftover the same way the comparison test does - through the
    server, since the file belongs to the account Firebird runs as. }
  Made := TIBDatabase.Create(nil);
  try
    Made.DatabaseName := HostPrefix + Path;
    Made.Params.Values['user_name'] := UserName;
    Made.Params.Values['password'] := Password;
    Made.LoginPrompt := False;
    try
      Made.Connected := True;
      Made.DropDatabase;
    except
      on E: Exception do ;
    end;
  finally
    Made.Free;
  end;

  if not CreateFirebirdDatabase(Opts, Err) then
  begin
    WriteLn('FAIL: could not create a database: ', Err);
    Halt(1);
  end;

  { Refusing to overwrite is the one guard in this path that could otherwise
    cost somebody a database, so it is checked rather than assumed. }
  if CreateFirebirdDatabase(Opts, Err) then
  begin
    WriteLn('FAIL: creating over an existing database was allowed');
    Halt(1);
  end;

  Made := TIBDatabase.Create(nil);
  MadeTr := TIBTransaction.Create(nil);
  MadeQ := TIBQuery.Create(nil);
  try
    Made.DatabaseName := HostPrefix + Path;
    Made.Params.Values['user_name'] := UserName;
    Made.Params.Values['password'] := Password;
    Made.LoginPrompt := False;
    MadeTr.DefaultDatabase := Made;
    Made.DefaultTransaction := MadeTr;
    Made.Connected := True;
    MadeTr.StartTransaction;
    MadeQ.Database := Made;
    MadeQ.Transaction := MadeTr;
    MadeQ.SQL.Text := 'select mon$page_size, mon$sql_dialect from mon$database';
    MadeQ.Open;
    PageSize := MadeQ.Fields[0].AsInteger;
    MadeQ.Close;
    MadeQ.SQL.Text := 'select rdb$character_set_name from rdb$database';
    MadeQ.Open;
    CharSet := Trim(MadeQ.Fields[0].AsString);
    MadeQ.Close;
    if MadeTr.Active then
      MadeTr.Commit;
    Made.DropDatabase;
  finally
    MadeQ.Free;
    MadeTr.Free;
    Made.Free;
  end;

  { Page size is checked against what was asked for, not merely for being
    non-zero: Firebird silently clamps a size outside its range rather than
    refusing it, so a wrong value here would otherwise pass unnoticed. }
  if PageSize <> 16384 then
  begin
    WriteLn('FAIL: asked for a 16384-byte page, got ', PageSize);
    Halt(1);
  end;
  if CharSet <> 'WIN1252' then
  begin
    WriteLn('FAIL: asked for WIN1252, the database default is ', CharSet);
    Halt(1);
  end;
  WriteLn('Create Database OK (page size and character set as asked, ' +
    'existing file refused)');
end;

{ Schema DDL, round-tripped: extract it, drop the schema, run what was
  extracted, and require the schema back with the same attributes. Anything
  less only proves a string was produced. }
{ How many times Needle occurs in Haystack. }
function OccurrenceCount(const Haystack, Needle: String): Integer;
var
  At: Integer;
begin
  Result := 0;
  At := Pos(Needle, Haystack);
  while At > 0 do
  begin
    Inc(Result);
    At := PosEx(Needle, Haystack, At + Length(Needle));
  end;
end;

procedure TRowFilter.Accept(DataSet: TDataSet; var Accepted: Boolean);
begin
  Accepted := Pos(Needle, UpperCase(DataSet.Fields[0].AsString)) > 0;
end;

{ The result grid's filter, which is a client-side filter on the open dataset -
  the point of it is not to re-run the statement. Whether IBX honours
  Filtered/OnFilterRecord at all is a fact about the server-side dataset rather
  than about the window, so it is settled here; that the edit box is wired to
  it is checked in the GUI harness. }
{ Backup and restore through the Services API, end to end.

  The Maintenance dialog has offered both since Phase 5 and neither had ever
  been run by a test: the dialog's controls were checked, which says nothing
  about whether a backup can be taken or whether what comes back is a
  database. This takes one, restores it to a file of its own, connects to the
  result and looks for a table that was in the original.

  The service runs on the *server*, so both paths are the server's: the backup
  file is written beside the database rather than into the client's temp
  directory, which would be the wrong machine for a remote connection. }
procedure TestBackupAndRestore;
var
  SvcConn: TIBXServicesConnection;
  Backup: TIBXClientSideBackupService;
  Restore: TIBXClientSideRestoreService;
  Log: TStringList;
  Restored: TIBDatabase;
  RestoredTr: TIBTransaction;
  Probe: TIBQuery;
  BackupFile, TargetFile, Base, Prefix: String;
  BytesWritten, Tables: Integer;
begin
  { Refusals first - they need no server, and they are what stands between a
    stray click and an overwritten database. }
  if BackupRefusalReason('') = '' then
  begin
    WriteLn('FAIL: a backup with no file name should be refused');
    Halt(1);
  end;
  if BackupRefusalReason('/tmp/x.fbk') <> '' then
  begin
    WriteLn('FAIL: a backup with a file name should not be refused');
    Halt(1);
  end;
  if RestoreRefusalReason('', '/tmp/t.fdb', False) = '' then
  begin
    WriteLn('FAIL: a restore with no source should be refused');
    Halt(1);
  end;
  if RestoreRefusalReason('/tmp/s.fbk', '', False) = '' then
  begin
    WriteLn('FAIL: a restore with no target should be refused');
    Halt(1);
  end;
  { The one that matters: restore creates the database it writes. }
  if RestoreRefusalReason('/tmp/s.fbk', '/tmp/t.fdb', True) = '' then
  begin
    WriteLn('FAIL: a restore over an existing file should be refused');
    Halt(1);
  end;
  if RestoreRefusalReason('/tmp/s.fbk', '/tmp/t.fdb', False) <> '' then
  begin
    WriteLn('FAIL: a restore to a new file should not be refused');
    Halt(1);
  end;
  if (ParallelWorkersFor(0) <> 1) or (ParallelWorkersFor(-3) <> 1) or
     (ParallelWorkersFor(4) <> 4) then
  begin
    WriteLn('FAIL: parallel worker count is not clamped to something sensible');
    Halt(1);
  end;

  { Beside the database, because the service is the server's. }
  Prefix := HostPrefixOf(DatabaseName);
  Base := ChangeFileExt(Copy(DatabaseName, Length(Prefix) + 1, MaxInt), '');
  BackupFile := Base + '_svc_test.fbk';
  TargetFile := Base + '_svc_restored.fdb';
  { Only the backup file: the target is the server's to make and the server's
    to remove, and deleting it from here does nothing when the server runs as
    another user. }
  DeleteFile(BackupFile);

  SvcConn := TIBXServicesConnection.Create(nil);
  Backup := TIBXClientSideBackupService.Create(nil);
  Restore := TIBXClientSideRestoreService.Create(nil);
  Log := TStringList.Create;
  Restored := TIBDatabase.Create(nil);
  RestoredTr := TIBTransaction.Create(nil);
  Probe := TIBQuery.Create(nil);
  try
    SvcConn.LoginPrompt := False;
    SvcConn.SetDBParams(DB.Params);
    try
      SvcConn.ConnectUsing(DB);
    except
      on E: Exception do
      begin
        WriteLn('Backup/restore skipped (no services access: ', E.Message, ')');
        Exit;
      end;
    end;

    Backup.ServicesConnection := SvcConn;
    Backup.DatabaseName := DB.DatabaseName;
    Backup.Options := [];
    Backup.ParallelWorkers := ParallelWorkersFor(1);
    BytesWritten := 0;
    try
      Backup.BackupToFile(BackupFile, BytesWritten);
    except
      on E: Exception do
      begin
        WriteLn('FAIL: the backup service would not run: ', E.Message);
        Halt(1);
      end;
    end;
    { Bytes rather than "no exception": a backup that wrote nothing is not a
      backup, and the client side of this service streams it back itself. }
    if BytesWritten <= 0 then
    begin
      WriteLn('FAIL: the backup wrote ', BytesWritten, ' bytes');
      Halt(1);
    end;

    Restore.ServicesConnection := SvcConn;
    Restore.DatabaseFiles.Clear;
    Restore.DatabaseFiles.Add(TargetFile);
    Restore.Options := [CreateNewDB];
    try
      Restore.RestoreFromFile(BackupFile, Log);
    except
      on E: Exception do
      begin
        WriteLn('FAIL: the restore service would not run: ', E.Message);
        Halt(1);
      end;
    end;

    { And now the only question worth asking: is the thing it wrote a database
      holding what the original held. }
    Restored.DatabaseName := Prefix + TargetFile;
    Restored.Params.Assign(DB.Params);
    Restored.LoginPrompt := False;
    RestoredTr.DefaultDatabase := Restored;
    Restored.DefaultTransaction := RestoredTr;
    try
      Restored.Connected := True;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: the restored database will not open: ', E.Message);
        Halt(1);
      end;
    end;

    RestoredTr.StartTransaction;
    Probe.Database := Restored;
    Probe.Transaction := RestoredTr;
    Probe.SQL.Text := 'select count(*) from rdb$relations ' +
      'where coalesce(rdb$system_flag, 0) = 0 and rdb$view_source is null';
    Probe.Open;
    Tables := Probe.Fields[0].AsInteger;
    Probe.Close;

    if Tables <= 0 then
    begin
      WriteLn('FAIL: the restored database holds no user tables');
      Halt(1);
    end;

    { A table this suite is known to have made, by name - a count alone would
      pass on a database restored from the wrong backup. }
    Probe.SQL.Text := 'select count(*) from rdb$relations ' +
      'where rdb$relation_name = ''IBX_SMOKE_TEST''';
    Probe.Open;
    if Probe.Fields[0].AsInteger <> 1 then
    begin
      WriteLn('FAIL: the restored database does not hold IBX_SMOKE_TEST');
      Halt(1);
    end;
    Probe.Close;
    if RestoredTr.Active then
      RestoredTr.Commit;

    { Dropped rather than deleted: the server created this file and owns it, so
      a client-side DeleteFile silently fails and the next run trips over a
      database that already exists - which is how this was found. Dropping it
      asks the side that made it to remove it. }
    try
      Restored.DropDatabase;
    except
      on E: Exception do
        WriteLn('       (could not drop the restored database: ', E.Message, ')');
    end;
    if Restored.Connected then
      Restored.Connected := False;

    WriteLn('Backup and restore OK (', BytesWritten,
      ' bytes backed up, restored to a database holding ', Tables, ' table(s))');
  finally
    Probe.Free;
    RestoredTr.Free;
    Restored.Free;
    Log.Free;
    Restore.Free;
    Backup.Free;
    if SvcConn.Connected then
      SvcConn.Connected := False;
    SvcConn.Free;
    { The backup file is the client's - this service streams it here - so this
      one really is ours to delete. The database is not; see above. }
    DeleteFile(BackupFile);
  end;
end;

{ The per-statement performance counters, which come from the MON$ tables.

  This component was a stub for most of the port - it had every property and no
  behaviour, because the Delphi original read them through a raw
  isc_database_info call that IBX does not expose - and was rewritten against
  MON$IO_STATS and MON$RECORD_STATS. Nothing had driven it since: the SQL
  editor shows the numbers, and a component reporting zeroes looks exactly like
  a quiet database.

  So the test makes the database not quiet: it counts reads, does work that
  must produce some, and requires the numbers to have moved. }
procedure TestPerformanceMonitor;
var
  Perf: TIBPerformanceMonitor;
  PerfTr: TIBTransaction;
  Work: TIBQuery;
  Idx, Before, After_: Integer;
  Seen: Boolean;
begin
  Perf := TIBPerformanceMonitor.Create(nil);
  PerfTr := TIBTransaction.Create(nil);
  Work := TIBQuery.Create(nil);
  try
    PerfTr.DefaultDatabase := DB;
    Perf.IB_Connection := DB;
    Perf.Transaction := PerfTr;
    try
      Perf.Initialise;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: the performance monitor would not initialise: ', E.Message);
        Halt(1);
      end;
    end;
    if not Perf.Initialised then
    begin
      WriteLn('FAIL: the performance monitor reports itself uninitialised');
      Halt(1);
    end;

    { The counters are the monitored *transaction's*, not the attachment's -
      that is what the SQL editor wants, since its statements run in its own
      transaction - so the work has to happen there or nothing moves. Writing
      this test against another transaction is what showed that. }
    if not PerfTr.Active then
      PerfTr.StartTransaction;
    Perf.Refresh;
    Before := Perf.ReadFetchesCount.ThisRead;

    Work.Database := DB;
    Work.Transaction := PerfTr;
    Work.SQL.Text := 'select count(*) from IBX_SMOKE_TEST';
    Work.Open;
    Work.Close;

    Perf.Refresh;
    After_ := Perf.ReadFetchesCount.ThisRead;

    { Counters that never move are the failure this is written for - a stub
      returns zero and looks like an idle server. }
    if After_ <= 0 then
    begin
      WriteLn('FAIL: the fetch counter is still ', After_, ' after reading a table');
      Halt(1);
    end;
    if After_ < Before then
    begin
      WriteLn('FAIL: the fetch counter went backwards (', Before, ' -> ', After_, ')');
      Halt(1);
    end;

    { The page buffer count comes from MON$DATABASE and is a property of the
      database rather than of the session, so it is positive on any server. }
    if Perf.ReadNumBuffers <= 0 then
    begin
      WriteLn('FAIL: the page buffer count reads ', Perf.ReadNumBuffers);
      Halt(1);
    end;

    { And the per-table lists: the table just read has to be in one of them. }
    Seen := False;
    for Idx := 0 to Perf.ReadSeqCount.Count - 1 do
      if Perf.ReadSeqCount[Idx].Metric = 'IBX_SMOKE_TEST' then
        Seen := True;
    for Idx := 0 to Perf.ReadIdxCount.Count - 1 do
      if Perf.ReadIdxCount[Idx].Metric = 'IBX_SMOKE_TEST' then
        Seen := True;
    if not Seen then
    begin
      WriteLn('FAIL: the table just read is in neither the sequential nor the ' +
              'indexed read list');
      Halt(1);
    end;

    if PerfTr.Active then
      PerfTr.Commit;
    WriteLn('Performance counters OK (fetches ', Before, ' -> ', After_,
      ', ', Perf.ReadNumBuffers, ' page buffers)');
  finally
    Work.Free;
    Perf.Free;
    PerfTr.Free;
  end;
end;

{ Which catalogue holds which kind of object.

  Nine copies of the same twenty lines in Globals.DoesObjectExist became one
  mapping and one query, so the mapping is what there is to get wrong: a table
  looked up in the wrong catalogue answers "no such object" for something that
  is plainly there. Pure, so it needs no server. }
procedure TestObjectCatalogue;
var
  Table_, Column_: String;

  procedure Expect(AKind: TGSSCacheType; const ATable, AColumn, What: String);
  begin
    if not CatalogueTableFor(AKind, Table_, Column_) then
    begin
      WriteLn('FAIL: no catalogue for ', What);
      Halt(1);
    end;
    if (Table_ <> ATable) or (Column_ <> AColumn) then
    begin
      WriteLn('FAIL: ', What, ' looked up in ', Table_, '.', Column_,
              ', expected ', ATable, '.', AColumn);
      Halt(1);
    end;
  end;

begin
  Expect(ctTable, 'rdb$relations', 'rdb$relation_name', 'a table');
  { A view is a relation with a view source, so it is found the same way. }
  Expect(ctView, 'rdb$relations', 'rdb$relation_name', 'a view');
  Expect(ctTrigger, 'rdb$triggers', 'rdb$trigger_name', 'a trigger');
  Expect(ctSP, 'rdb$procedures', 'rdb$procedure_name', 'a procedure');
  Expect(ctGenerator, 'rdb$generators', 'rdb$generator_name', 'a generator');
  Expect(ctException, 'rdb$exceptions', 'rdb$exception_name', 'an exception');
  Expect(ctPackage, 'rdb$packages', 'rdb$package_name', 'a package');
  Expect(ctUDF, 'rdb$functions', 'rdb$function_name', 'a function');
  Expect(ctDomain, 'rdb$fields', 'rdb$field_name', 'a domain');

  { A header node names a branch of the tree, not an object, and is not
    looked up this way. Answering with some other catalogue would be worse
    than answering not at all. }
  if CatalogueTableFor(ctTableHeader, Table_, Column_) then
  begin
    WriteLn('FAIL: a tree header should have no catalogue of its own');
    Halt(1);
  end;

  { The query, including the schema clause the caller hands it. }
  if ObjectExistsSQL('rdb$relations', 'rdb$relation_name', 'CUSTOMERS', '') <>
     'select rdb$relation_name from rdb$relations ' +
     'where rdb$relation_name = ''CUSTOMERS''' then
  begin
    WriteLn('FAIL: the existence query is not what was expected: ',
      ObjectExistsSQL('rdb$relations', 'rdb$relation_name', 'CUSTOMERS', ''));
    Halt(1);
  end;
  if Pos('and X', ObjectExistsSQL('t', 'c', 'N', ' and X')) = 0 then
  begin
    WriteLn('FAIL: the schema clause is not appended');
    Halt(1);
  end;
  { A name with a quote in it must not end the literal - the same rule as
    everywhere else, and here it guards a query rather than a script. }
  if Pos('''O''''BRIEN''', ObjectExistsSQL('t', 'c', 'O''BRIEN', '')) = 0 then
  begin
    WriteLn('FAIL: a quote in the name is not escaped: ',
      ObjectExistsSQL('t', 'c', 'O''BRIEN', ''));
    Halt(1);
  end;

  WriteLn('Object catalogue mapping OK (nine kinds, and a tree header has none)');
end;

{ The CSV import, run into the database.

  What the import decides is checked without a server in keyword_test. What
  this adds is the only thing that suite cannot: that the DDL and the INSERTs
  it writes are ones Firebird accepts, and that what comes back out is what
  went in - the comma inside a quoted field, the apostrophe, the empty cell as
  a null rather than an empty string, and the numbers as numbers rather than
  as text that happens to look like them. }
procedure TestCsvImportLive;
var
  Lines: TStringList;
  Plan: TCsvImportPlan;
  Opts: TCsvOptions;
  Probe: TIBQuery;
  Idx: Integer;

  procedure Run(const SQLText, What: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := StripTrailingSemicolon(SQLText);
      try
        S.ExecQuery;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: ', What, ': ', E.Message);
          WriteLn(SQLText);
          Halt(1);
        end;
      end;
    finally
      S.Free;
    end;
  end;

  procedure Discard(const SQLText: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := SQLText;
      try
        S.ExecQuery;
        if Tr.Active then
          Tr.Commit;
      except
        if Tr.Active then
          Tr.Rollback;
      end;
    finally
      S.Free;
    end;
  end;

begin
  Discard('drop table CSV_IMPORTED');

  Opts := DefaultCsvOptions;
  Lines := TStringList.Create;
  Probe := TIBQuery.Create(nil);
  try
    Lines.Add('ID,NAME,PRICE,WHEN_');
    Lines.Add('1,"Smith, John",9.99,2026-07-28');
    Lines.Add('2,O''Brien,12.50,2026-07-29');
    { A gap in a numeric column: it must stay numeric, and arrive as null. }
    Lines.Add('3,Plain,,2026-07-30');

    Plan := PlanCsvImport(Lines, Opts);
    try
      Run(Plan.CreateTableSQL('CSV_IMPORTED'), 'the generated CREATE TABLE runs');
      for Idx := 0 to Plan.RowCount - 1 do
        Run(Plan.InsertSQL('CSV_IMPORTED', Idx),
          'the generated INSERT for row ' + IntToStr(Idx) + ' runs');

      EnsureTransaction;
      Probe.Database := DB;
      Probe.Transaction := Tr;
      Probe.SQL.Text :=
        'select count(*) as N, sum(PRICE) as TOTAL, ' +
        '  count(PRICE) as PRICED, min(WHEN_) as FIRST_DAY ' +
        'from CSV_IMPORTED';
      Probe.Open;
      if Probe.FieldByName('N').AsInteger <> 3 then
      begin
        WriteLn('FAIL: expected three imported rows, got ',
                Probe.FieldByName('N').AsInteger);
        Halt(1);
      end;
      { Summed on the server: proof the column is a number rather than text
        that looks like one. }
      if Abs(Probe.FieldByName('TOTAL').AsFloat - 22.49) > 0.001 then
      begin
        WriteLn('FAIL: the prices did not add up as numbers: ',
                Probe.FieldByName('TOTAL').AsFloat:0:4);
        Halt(1);
      end;
      { COUNT skips nulls: the empty cell has to be one. }
      if Probe.FieldByName('PRICED').AsInteger <> 2 then
      begin
        WriteLn('FAIL: the empty cell should be null, counted ',
                Probe.FieldByName('PRICED').AsInteger, ' prices');
        Halt(1);
      end;
      if FormatDateTime('yyyy-mm-dd', Probe.FieldByName('FIRST_DAY').AsDateTime) <>
         '2026-07-28' then
      begin
        WriteLn('FAIL: the dates did not arrive as dates: ',
                Probe.FieldByName('FIRST_DAY').AsString);
        Halt(1);
      end;
      Probe.Close;

      { And the two values that would have broken a naive importer. }
      Probe.SQL.Text := 'select NAME from CSV_IMPORTED order by ID';
      Probe.Open;
      if Trim(Probe.FieldByName('NAME').AsString) <> 'Smith, John' then
      begin
        WriteLn('FAIL: the quoted comma did not survive: "',
                Probe.FieldByName('NAME').AsString, '"');
        Halt(1);
      end;
      Probe.Next;
      if Trim(Probe.FieldByName('NAME').AsString) <> 'O''Brien' then
      begin
        WriteLn('FAIL: the apostrophe did not survive: "',
                Probe.FieldByName('NAME').AsString, '"');
        Halt(1);
      end;
      Probe.Close;
      if Tr.Active then
        Tr.Commit;

      WriteLn('CSV import OK (three rows, typed and quoted as written)');
    finally
      Plan.Free;
    end;
  finally
    Probe.Free;
    Lines.Free;
    Discard('drop table CSV_IMPORTED');
  end;
end;

{ An external table - one whose rows live in a file rather than in the
  database - surviving extraction.

  Without the clause such a table extracts as an ordinary one: the DDL
  compiles, a table appears, and everything written to it goes into the
  database instead of the file it was supposed to be a view of. The same class
  of silent wrongness as reading the byte length of a UTF8 column - what comes
  back looks like a table and is the wrong table.

  Only the metadata is exercised. Reading an external table's rows needs
  ExternalFileAccess in firebird.conf, which is None by default and is on the
  server rather than here; the DDL and the catalogue do not need it, and they
  are what this program gets wrong or right. }
procedure TestExternalTableDDL;
var
  Ex: TDDLExtractor;
  DDL: String;
  Probe: TIBQuery;
  Found: Boolean;

  procedure Run(const SQLText, What: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := StripTrailingSemicolon(SQLText);
      try
        S.ExecQuery;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: ', What, ': ', E.Message);
          WriteLn(SQLText);
          Halt(1);
        end;
      end;
    finally
      S.Free;
    end;
  end;

  procedure Discard(const SQLText: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := SQLText;
      try
        S.ExecQuery;
        if Tr.Active then
          Tr.Commit;
      except
        if Tr.Active then
          Tr.Rollback;
      end;
    finally
      S.Free;
    end;
  end;

begin
  Discard('drop table EXT_SMOKE');
  Discard('drop table EXT_SMOKE2');
  Run('create table EXT_SMOKE external file ''/tmp/marathon_ext_smoke.dat'' ' +
      '(ID char(10), NAME char(20))', 'creating an external table');

  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    DDL := Ex.Extract(ddlTable, ddlstNone, 'EXT_SMOKE');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;

  RequireInDDL(DDL, 'external file', 'the EXTERNAL FILE clause');
  RequireInDDL(DDL, 'marathon_ext_smoke.dat', 'the file the table is a view of');

  { And it runs: the clause has to be in the place Firebird takes it, which is
    after the column list. }
  DDL := StringReplace(DDL, 'EXT_SMOKE', 'EXT_SMOKE2', [rfReplaceAll]);
  DDL := StringReplace(DDL, 'marathon_ext_smoke.dat', 'marathon_ext_smoke2.dat',
    [rfReplaceAll]);
  Run(DDL, 'the extracted external-table DDL');

  EnsureTransaction;
  Probe := TIBQuery.Create(nil);
  try
    Probe.Database := DB;
    Probe.Transaction := Tr;
    Probe.SQL.Text := 'select rdb$external_file from rdb$relations ' +
      'where rdb$relation_name = ''EXT_SMOKE2''';
    Probe.Open;
    { The catalogue rather than the script: a CREATE TABLE that merely
      compiled would have made an ordinary table, and this is what tells them
      apart. }
    Found := (not Probe.EOF) and
      (Pos('marathon_ext_smoke2.dat', Probe.Fields[0].AsString) > 0);
    Probe.Close;
  finally
    Probe.Free;
  end;
  if Tr.Active then
    Tr.Commit;

  if not Found then
  begin
    WriteLn('FAIL: the recreated table is not external - the rows would go ' +
            'into the database rather than the file');
    Halt(1);
  end;

  Discard('drop table EXT_SMOKE2');
  Discard('drop table EXT_SMOKE');
  WriteLn('External table DDL OK (the file survives extraction and recreation)');
end;

procedure TestResultFilter;
var
  FQ: TIBQuery;
  Filter: TRowFilter;
  Rows: Integer;

  function CountRows: Integer;
  begin
    Result := 0;
    FQ.First;
    while not FQ.EOF do
    begin
      Inc(Result);
      FQ.Next;
    end;
  end;

begin
  FQ := TIBQuery.Create(nil);
  Filter := TRowFilter.Create;
  try
    EnsureTransaction;
    FQ.Database := DB;
    FQ.Transaction := Tr;
    FQ.SQL.Text :=
      'select ''ALPHA'' as W from rdb$database ' +
      'union all select ''BETA'' from rdb$database ' +
      'union all select ''ALPACA'' from rdb$database';
    Filter.Needle := 'ALP';
    FQ.OnFilterRecord := Filter.Accept;
    FQ.Open;
    Rows := CountRows;
    if Rows <> 3 then
    begin
      WriteLn('FAIL: the filter probe should return three rows, got ', Rows);
      Halt(1);
    end;

    FQ.Filtered := True;
    if not FQ.Filtered then
    begin
      WriteLn('FAIL: IBX did not accept Filtered on an open dataset - the ' +
              'result grid filter cannot work this way');
      Halt(1);
    end;
    Rows := CountRows;
    if Rows <> 2 then
    begin
      WriteLn('FAIL: filtering on ALP should leave ALPHA and ALPACA, got ',
              Rows, ' row(s)');
      Halt(1);
    end;

    { And off again, which is what clearing the box does. Without this a filter
      would be a one-way trip and the rest of the result unreachable. }
    FQ.Filtered := False;
    Rows := CountRows;
    if Rows <> 3 then
    begin
      WriteLn('FAIL: clearing the filter should bring all three rows back, got ',
              Rows);
      Halt(1);
    end;

    FQ.Close;
    if Tr.Active then
      Tr.Commit;
    WriteLn('Result filter OK (filters in the client, and can be switched off)');
  finally
    Filter.Free;
    FQ.Free;
  end;
end;

procedure TestSchemaDDL;
var
  Ex: TDDLExtractor;
  Names: TStringList;
  SchemaDDL: String;
  Probe: TIBQuery;
  Found: Boolean;

  procedure Run(const SQLText: String; const What: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := StripTrailingSemicolon(SQLText);
      try
        S.ExecQuery;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: ', What, ' raised: ', E.Message);
          WriteLn(SQLText);
          Halt(1);
        end;
      end;
    finally
      S.Free;
    end;
    if Tr.Active then
      Tr.Commit;
  end;

  { Runs a statement whose failure is not a test failure - clearing away what a
    halted earlier run may have left behind. A failed DDL statement leaves the
    transaction unusable, so it is rolled back rather than committed. }
  procedure Discard(const SQLText: String);
  var
    S: TIBSQL;
  begin
    EnsureTransaction;
    S := TIBSQL.Create(nil);
    try
      S.Database := DB;
      S.Transaction := Tr;
      S.SQL.Text := StripTrailingSemicolon(SQLText);
      try
        S.ExecQuery;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
          if Tr.Active then
            Tr.Rollback;
      end;
    finally
      S.Free;
    end;
  end;

begin
  { SQL schemas are Firebird 6. On anything older there is nothing to test and
    RDB$SCHEMAS does not exist to ask. }
  if EngineMajor < 6 then
  begin
    WriteLn('Schema DDL skipped (server is Firebird ', EngineMajor, ')');
    Exit;
  end;

  { Leftovers from a run that halted part-way. Failure here is the normal case
    on a clean database, so it is swallowed - unlike Run, which halts. }
  Discard('drop table SMOKE_OTHER.SMOKE_DUP');
  Discard('drop table SMOKE_DUP');
  Discard('drop schema SMOKE_OTHER');
  Discard('drop schema SMOKE_SCH');
  Discard('drop schema SMOKE_PLAIN');

  Run('create schema SMOKE_SCH default character set WIN1252', 'creating a schema');

  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    SchemaDDL := Ex.Extract(ddlSchema, ddlstNone, 'SMOKE_SCH');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;

  RequireInDDL(SchemaDDL, 'create schema', 'the CREATE SCHEMA verb');
  RequireInDDL(SchemaDDL, 'SMOKE_SCH', 'the schema name');
  RequireInDDL(SchemaDDL, 'WIN1252', 'the default character set');

  Run('drop schema SMOKE_SCH', 'dropping the schema before recreating it');
  Run(SchemaDDL, 'the extracted schema DDL');

  { Back, and with the character set it was declared with - which is the part
    a CREATE SCHEMA that merely compiles would not prove. }
  EnsureTransaction;
  Probe := TIBQuery.Create(nil);
  try
    Probe.Database := DB;
    Probe.Transaction := Tr;
    Probe.SQL.Text := 'select rdb$character_set_name from rdb$schemas ' +
      'where rdb$schema_name = ''SMOKE_SCH''';
    Probe.Open;
    Found := (not Probe.EOF) and
      (Trim(Probe.Fields[0].AsString) = 'WIN1252');
    Probe.Close;
  finally
    Probe.Free;
  end;
  if Tr.Active then
    Tr.Commit;
  if not Found then
  begin
    WriteLn('FAIL: the extracted schema DDL did not recreate the schema as declared');
    WriteLn(SchemaDDL);
    Halt(1);
  end;

  { ALTER SCHEMA, which is the last thing on this item that Firebird has.

    What it can change was probed against the server rather than read from the
    notes: SET DEFAULT CHARACTER SET and DROP DEFAULT CHARACTER SET work, and
    nothing else does - SQL SECURITY and OWNER TO are rejected outright in
    every position tried. So a schema's ALTER is its character set.

    Proved by running it rather than by reading it: the schema is moved to a
    different character set behind the extractor's back, then the statement it
    produced is run, and the catalogue has to hold what the statement said. }
  Run('alter schema SMOKE_SCH set default character set UTF8',
    'moving the schema to another character set');

  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    { Extracted while it is UTF8, so this is the statement that puts it back
      to UTF8 - and it is run below against a schema left on WIN1252. }
    SchemaDDL := Ex.Extract(ddlSchema, ddlstAlter, 'SMOKE_SCH');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;

  RequireInDDL(SchemaDDL, 'alter schema', 'the ALTER SCHEMA verb');
  RequireInDDL(SchemaDDL, 'set default character set', 'the SET form');
  RequireInDDL(SchemaDDL, 'UTF8', 'the character set it is on now');

  Run('alter schema SMOKE_SCH set default character set WIN1252',
    'moving it back so the extracted ALTER has something to do');
  Run(SchemaDDL, 'the extracted ALTER SCHEMA');

  EnsureTransaction;
  Probe := TIBQuery.Create(nil);
  try
    Probe.Database := DB;
    Probe.Transaction := Tr;
    Probe.SQL.Text := 'select rdb$character_set_name from rdb$schemas ' +
      'where rdb$schema_name = ''SMOKE_SCH''';
    Probe.Open;
    Found := (not Probe.EOF) and (Trim(Probe.Fields[0].AsString) = 'UTF8');
    Probe.Close;
  finally
    Probe.Free;
  end;
  if Tr.Active then
    Tr.Commit;
  if not Found then
  begin
    WriteLn('FAIL: the extracted ALTER SCHEMA did not change the character set');
    WriteLn(SchemaDDL);
    Halt(1);
  end;

  { A schema with no character set at all - PUBLIC is the case in point - has
    nothing to SET, so its ALTER is the DROP form. That is the state it is in,
    and unlike an omitted clause it is a statement that runs. }
  Run('create schema SMOKE_PLAIN', 'creating a schema with no character set');
  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    SchemaDDL := Ex.Extract(ddlSchema, ddlstAlter, 'SMOKE_PLAIN');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;
  RequireInDDL(SchemaDDL, 'drop default character set',
    'the DROP form for a schema that has no character set');
  { And it runs - which is the whole reason for emitting it rather than an
    ALTER with no clause on the end. }
  Run(SchemaDDL, 'the extracted ALTER for a schema with no character set');
  Run('drop schema SMOKE_PLAIN', 'cleaning up the plain schema');

  Run('drop schema SMOKE_SCH', 'cleaning up the schema');
  WriteLn('Schema DDL OK (round-trips with its default character set, ' +
    'and ALTER changes it)');

  { The same table name in two schemas. Object names are unique per schema, not
    per database, so a catalogue query filtering on the name alone matches both
    - and ExtractTable used to emit one table carrying both schemas' columns
    and a duplicated ID. What must come back is the current schema's table
    only. }
  Run('create schema SMOKE_OTHER', 'creating a second schema');
  Run('create table SMOKE_DUP (ID integer, IN_CURRENT_SCHEMA varchar(5))',
    'creating the table in the current schema');
  Run('create table SMOKE_OTHER.SMOKE_DUP (ID integer, IN_OTHER_SCHEMA varchar(5))',
    'creating the same-named table in the other schema');

  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    SchemaDDL := Ex.Extract(ddlTable, ddlstNone, 'SMOKE_DUP');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;

  RequireInDDL(SchemaDDL, 'IN_CURRENT_SCHEMA', 'the current schema''s column');
  RequireNotInDDL(SchemaDDL, 'IN_OTHER_SCHEMA',
    'a column belonging to the same-named table in another schema');

  { Extraction from a named schema. Until now the extractor could only reach
    what an unqualified name reaches, so an object in another schema could not
    be scripted at all; naming the schema both finds it and qualifies the DDL,
    which is what makes the result runnable. }
  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    Ex.Schema := 'SMOKE_OTHER';
    EnsureTransaction;
    SchemaDDL := Ex.Extract(ddlTable, ddlstNone, 'SMOKE_DUP');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;
  RequireInDDL(SchemaDDL, 'SMOKE_OTHER', 'the schema qualifying the table name');
  RequireInDDL(SchemaDDL, 'IN_OTHER_SCHEMA', 'the other schema''s own column');
  { The current schema has a table of the same name with a different column.
    Naming the schema has to reach past it, or the qualification would be
    decoration on the wrong object. }
  RequireNotInDDL(SchemaDDL, 'IN_CURRENT_SCHEMA',
    'a column from the same-named table in the current schema');
  WriteLn('Schema-qualified extraction OK (', Trim(Copy(SchemaDDL, 1, Pos('(', SchemaDDL) - 1)), ')');

  { A column whose domain lives in another schema.

    RDB$RELATION_FIELDS records the domain's name and, separately, the schema
    it is in. Matching on the name alone finds it in every schema - which
    duplicates the column once per schema that has one - while restricting the
    lookup to the table's own schema drops it entirely. Neither shows up
    without a domain that is genuinely somewhere else, which is what this
    makes. }
  Run('create domain SMOKE_OTHER.CROSS_DOM as varchar(23)',
    'creating a domain in the other schema');
  { The same name in this schema too, and a different width. Without both, a
    lookup that ignores the schema still finds exactly one row and the test
    proves nothing - which is what a first version of it did. The width is what
    says which of the two was used. }
  Run('create domain CROSS_DOM as varchar(7)',
    'creating a domain of the same name in this one');
  Run('create table CROSS_TAB (ID integer, TAG SMOKE_OTHER.CROSS_DOM)',
    'creating a table using a domain from another schema');

  Ex := TDDLExtractor.Create(nil);
  try
    Ex.Database := DB;
    Ex.Transaction := Tr;
    Ex.SQLDialect := 3;
    Ex.IsInterbase6 := True;
    EnsureTransaction;
    SchemaDDL := Ex.Extract(ddlTable, ddlstNone, 'CROSS_TAB');
    if Tr.Active then
      Tr.Commit;
  finally
    Ex.Free;
  end;

  { Both columns, once each. A duplicate would show as the column named twice;
    a dropped one as it missing altogether. }
  RequireInDDL(SchemaDDL, 'TAG', 'the column whose domain is in another schema');
  RequireInDDL(SchemaDDL, 'ID', 'and the ordinary one beside it');
  { The domain that was actually used, not the same-named one next door. }
  RequireInDDL(SchemaDDL, 'CROSS_DOM', 'named as the domain it was declared with');
  RequireNotInDDL(SchemaDDL, 'varchar(7)',
    'and not the width of the same-named domain in this schema');
  if OccurrenceCount(AnsiUpperCase(SchemaDDL), 'TAG') <> 1 then
  begin
    WriteLn('FAIL: the cross-schema column appears ',
      OccurrenceCount(AnsiUpperCase(SchemaDDL), 'TAG'), ' times, expected once');
    WriteLn(SchemaDDL);
    Halt(1);
  end;
  WriteLn('Cross-schema domain OK (the column is extracted once, not per schema)');

  Run('drop table CROSS_TAB', 'dropping the cross-schema table');
  Run('drop domain CROSS_DOM', 'dropping this schema''s domain');
  Run('drop domain SMOKE_OTHER.CROSS_DOM', 'dropping the other schema''s domain');

  { Listing what a *named* schema holds, which is what a tree needs to offer
    those objects at all. The current schema has a table of the same name, so
    a list that ignored the schema would look identical. }
  Names := ListSchemaObjects(DB, Tr, sokTable, 'SMOKE_OTHER', True);
  try
    if Names.IndexOf('SMOKE_DUP') < 0 then
    begin
      WriteLn('FAIL: the other schema''s table was not listed');
      Halt(1);
    end;
    { SMOKE_DUP is in both, so its presence proves nothing on its own. The
      current schema's *other* tables must be absent. }
    if Names.IndexOf('IBX_SMOKE_TEST') >= 0 then
    begin
      WriteLn('FAIL: a current-schema table appeared in another schema''s list');
      Halt(1);
    end;
    WriteLn('Schema object listing OK (', Names.Count,
      ' table(s) in SMOKE_OTHER)');
  finally
    Names.Free;
  end;

  { And the current schema still lists what it always did, so the tree's
    existing behaviour is unchanged when no schema is named. }
  Names := ListSchemaObjects(DB, Tr, sokTable, '', True);
  try
    if Names.IndexOf('IBX_SMOKE_TEST') < 0 then
    begin
      WriteLn('FAIL: naming no schema stopped listing the current one');
      Halt(1);
    end;
  finally
    Names.Free;
  end;

  { A server without schemas must not be sent RDB$SCHEMA_NAME at all - naming a
    column that is not there is a hard error, not an empty result. }
  if Pos('rdb$schema_name', SchemaObjectListSQL(sokTable, '', False)) > 0 then
  begin
    WriteLn('FAIL: the pre-schema statement still names RDB$SCHEMA_NAME');
    Halt(1);
  end;

  { The Script As generators reach the same schema, so what the tree offers on a
    schema's object is a statement that will run rather than one that names
    whatever the search path happens to hold. }
  SchemaDDL := ScriptAsCreate(
    ScriptAsContext(DB, Tr, True, 3, EngineMajor, 'SMOKE_OTHER'),
    'SMOKE_DUP', ctTable);
  RequireInDDL(SchemaDDL, 'SMOKE_OTHER', 'the schema in a scripted CREATE');
  RequireInDDL(SchemaDDL, 'IN_OTHER_SCHEMA', 'the other schema''s column');
  RequireNotInDDL(SchemaDDL, 'IN_CURRENT_SCHEMA',
    'a column from the same-named table in the current schema');

  SchemaDDL := ScriptAsDrop(
    ScriptAsContext(DB, Tr, True, 3, EngineMajor, 'SMOKE_OTHER'),
    'SMOKE_DUP', ctTable);
  RequireInDDL(SchemaDDL, 'SMOKE_OTHER', 'the schema in a scripted DROP');

  { And naming no schema still produces exactly what it always did. }
  SchemaDDL := ScriptAsDrop(
    ScriptAsContext(DB, Tr, True, 3, EngineMajor), 'SMOKE_DUP', ctTable);
  RequireNotInDDL(SchemaDDL, 'SMOKE_OTHER',
    'a schema in a statement that named none');
  WriteLn('Schema-qualified Script As OK');

  Run('drop table SMOKE_OTHER.SMOKE_DUP', 'dropping the other schema''s table');
  Run('drop table SMOKE_DUP', 'dropping the table');
  Run('drop schema SMOKE_OTHER', 'dropping the second schema');
  WriteLn('Schema-scoped extraction OK (a name shared across schemas is not merged)');
end;

{ Two throwaway databases with known differences, compared, and then the
  generated script run against the target to see whether it actually closes
  them. Anything less proves only that a script was produced. }
procedure TestSchemaCompare(const HostPrefix: String);
var
  SrcDB, TgtDB: TIBDatabase;
  SrcTr, TgtTr: TIBTransaction;
  SrcCtx, TgtCtx: TScriptAsContext;
  Diff, Diff2, Diff3: TSchemaDifferences;
  ScriptFile, ScriptError: String;
  MigrationScript: String;
  Runner: TIBXScript;
  Lines: TStringList;

  { A leftover from an aborted run has to go through the server: the file
    belongs to the account Firebird runs as, so deleting it from here fails and
    the CreateDatabase that follows then fails on "file already exists". }
  procedure DropIfExists(const Path: String);
  var
    Old: TIBDatabase;
  begin
    Old := TIBDatabase.Create(nil);
    try
      Old.DatabaseName := HostPrefix + Path;
      Old.Params.Values['user_name'] := UserName;
      Old.Params.Values['password'] := Password;
      Old.LoginPrompt := False;
      try
        Old.Connected := True;
        Old.DropDatabase;
      except
        { Not there, or not ours to drop - either way CreateDatabase is about
          to say so far more precisely than this could. }
        on E: Exception do ;
      end;
    finally
      Old.Free;
    end;
  end;

  procedure Build(var ADB: TIBDatabase; var ATr: TIBTransaction;
    const Path: String; Statements: array of String);
  var
    Idx: Integer;
    S: TIBSQL;
  begin
    DropIfExists(Path);
    ADB := TIBDatabase.Create(nil);
    ATr := TIBTransaction.Create(nil);
    ADB.DatabaseName := HostPrefix + Path;
    ADB.Params.Values['user_name'] := UserName;
    ADB.Params.Values['password'] := Password;
    ADB.Params.Values['lc_ctype'] := 'UTF8';
    ADB.LoginPrompt := False;
    ADB.SQLDialect := 3;
    ATr.DefaultDatabase := ADB;
    ADB.DefaultTransaction := ATr;
    ADB.CreateDatabase;
    for Idx := 0 to High(Statements) do
    begin
      if not ATr.Active then
        ATr.StartTransaction;
      S := TIBSQL.Create(nil);
      try
        S.Database := ADB;
        S.Transaction := ATr;
        S.SQL.Text := Statements[Idx];
        try
          S.ExecQuery;
        except
          on E: Exception do
          begin
            WriteLn('FAIL: could not build comparison database ', Path, ': ', E.Message);
            WriteLn(Statements[Idx]);
            Halt(1);
          end;
        end;
      finally
        S.Free;
      end;
      if ATr.Active then
        ATr.Commit;
    end;
  end;

begin
  { The source has objects of every compared kind. The target shares BOTH_TBL
    unchanged, redefines V_SHARED, is missing everything else, and has one
    table of its own to be offered for dropping. }
  Build(SrcDB, SrcTr, '/tmp/marathon_cmp_src.fdb', [
    'create domain D_CODE as varchar(10) not null',
    'create generator G_SEQ',
    'create exception E_BAD ''something went wrong''',
    'create table BOTH_TBL (ID integer not null primary key, NOTE varchar(10))',
    { The same unnamed CHECK on both sides. Firebird names it INTEG_nnn on each,
      and the numbers do not match, so anything comparing the name reports a
      difference that is not there. }
    'alter table BOTH_TBL add check (ID > 0)',
    'create table ONLY_SRC (ID integer not null primary key, CODE D_CODE)',
    'create view V_SHARED as select ID from BOTH_TBL',
    { A view over a view, named so that the dependent sorts first. Emitted in
      name order the script would try to create V_AAA before the V_ZZZ it
      selects from. }
    'create view V_ZZZ as select ID from BOTH_TBL',
    'create view V_AAA as select ID from V_ZZZ',
    'create procedure P_ONLY_SRC (A integer) returns (R integer) as ' +
      'begin R = A + 1; suspend; end',
    'create function F_ONLY_SRC (A integer) returns integer as begin return A * 2; end',
    'create trigger TR_BOTH for BOTH_TBL after insert as begin end',
    { BOTH_TBL is otherwise identical on the two sides, so an index only here
      is the case that used to be invisible: comparing tables by their column
      DDL alone said they matched. }
    'create index IDX_BOTH_ID on BOTH_TBL (ID)',
    { A constraint on a table both sides have, so it is compared by definition
      rather than by name - Firebird would call it INTEG_nnn on each side and
      those numbers do not match. }
    'alter table ONLY_SRC add constraint FK_SRC foreign key (ID) ' +
      'references BOTH_TBL (ID) on delete cascade',
    'alter table BOTH_TBL add constraint UQ_NOTE unique (NOTE)',
    { Identical columns, different primary key. A table can only have one, so
      this is the case that must be reported rather than migrated - adding it
      needs the existing one dropped first. }
    'create table PK_DIFF (A integer not null, B integer not null, primary key (A))']);

  Build(TgtDB, TgtTr, '/tmp/marathon_cmp_tgt.fdb', [
    { ONLY_TGT first, deliberately. Firebird numbers generated constraint names
      per database as it goes, so building the shared table after a different
      number of constraints is what makes the two sides' INTEG_ numbers
      disagree - which is the whole point of the check below. Built the other
      way round the numbers coincide and the test proves nothing. }
    'create table ONLY_TGT (ID integer not null primary key)',
    'create table BOTH_TBL (ID integer not null primary key, NOTE varchar(10))',
    'alter table BOTH_TBL add check (ID > 0)',
    { Same name, different body - the case a comparison exists to catch. }
    'create view V_SHARED as select ID + 0 as ID from BOTH_TBL',
    'create table PK_DIFF (A integer not null, B integer not null, primary key (B))']);

  try
    SrcCtx := ScriptAsContext(SrcDB, SrcTr, True, 3, EngineMajor);
    TgtCtx := ScriptAsContext(TgtDB, TgtTr, True, 3, EngineMajor);

    { These two databases are UTF8, so they also pin the character-length fix.
      D_CODE was declared varchar(10); the catalogue stores RDB$FIELD_LENGTH =
      40 and RDB$CHARACTER_LENGTH = 10, and reading the byte length rendered it
      as varchar(40) - which made a DDL round trip quadruple every string
      column, and stopped the comparison below from ever converging. }
    RequireInDDL(ScriptAsCreate(SrcCtx, 'D_CODE', ctDomain), 'varchar(10)',
      'the domain''s length in characters rather than bytes');
    RequireNotInDDL(ScriptAsCreate(SrcCtx, 'ONLY_SRC', ctTable), 'varchar(40)',
      'a column widened by reading the byte length');

    MigrationScript := CompareSchemas(SrcCtx, TgtCtx, Diff);

    { The implicit RDB$n domains must not be in here. Every table column makes
      one, so if they leaked in they would swamp the script - and each would be
      emitted as a CREATE DOMAIN that then fails on the reserved name. }
    RequireNotInDDL(MigrationScript, 'create domain RDB$', 'an implicit domain');

    RequireInDDL(MigrationScript, 'D_CODE', 'the missing domain');
    RequireInDDL(MigrationScript, 'G_SEQ', 'the missing generator');
    RequireInDDL(MigrationScript, 'E_BAD', 'the missing exception');
    RequireInDDL(MigrationScript, 'ONLY_SRC', 'the missing table');
    RequireInDDL(MigrationScript, 'P_ONLY_SRC', 'the missing procedure');
    RequireInDDL(MigrationScript, 'F_ONLY_SRC', 'the missing function');
    RequireInDDL(MigrationScript, 'TR_BOTH', 'the missing trigger');
    RequireInDDL(MigrationScript, '/* differs - redefining */', 'the changed view');
    RequireInDDL(MigrationScript, '-- drop table', 'the commented-out drop');
    RequireInDDL(MigrationScript, 'IDX_BOTH_ID',
      'an index missing from an otherwise identical table');
    RequireInDDL(MigrationScript, 'index missing from target',
      'the index difference is reported as such');
    RequireInDDL(MigrationScript, 'unique (NOTE)',
      'a constraint missing from an otherwise identical table');
    RequireInDDL(MigrationScript, 'constraint missing from target',
      'the constraint difference is reported as such');
    { Named by neither side in the generated text: comparing by definition is
      the whole point, so the statement must not carry a name that would differ
      between databases. }
    { A generated name may appear only on a commented-out DROP, which needs the
      real name to work. Anything the script would actually run must name no
      constraint at all, since those names differ between databases. }
    RequireGeneratedNamesOnlyCommented(MigrationScript);
    RequireOrderInDDL(MigrationScript, 'create view V_ZZZ', 'create view V_AAA',
      'a view is created before the view built on it');
    RequireInDDL(MigrationScript, 'has a different primary key',
      'a primary key that cannot be added without dropping the old one');
    if Diff.NeedingAttention <> 1 then
    begin
      WriteLn('FAIL: expected exactly one object needing attention, got ',
        Diff.NeedingAttention);
      Halt(1);
    end;

    { BOTH_TBL is identical on both sides, so it must not be recreated. Its
      name still appears - the view and trigger select from it - so the test is
      that no CREATE TABLE names it. }
    RequireNotInDDL(MigrationScript, 'create table BOTH_TBL', 'an unchanged table');
    { BOTH_TBL carries the same CHECK on both sides, but Firebird named it
      INTEG_3 in one database and INTEG_5 in the other. Reporting it as
      differing on that basis alone would bury the real differences. }
    RequireNotInDDL(MigrationScript, 'BOTH_TBL differs',
      'a table reported as differing only because a generated name differs');

    { Two: the table only the target has, and the target's own primary key on
      PK_DIFF - which is the other half of the report above, since adding the
      source's key means dropping this one first. }
    if Diff.ToDrop <> 2 then
    begin
      WriteLn('FAIL: expected exactly two objects to drop, got ', Diff.ToDrop);
      Halt(1);
    end;
    if Diff.Changed <> 1 then
    begin
      WriteLn('FAIL: expected exactly one redefinition, got ', Diff.Changed);
      Halt(1);
    end;
    WriteLn('Schema comparison OK (', Diff.ToCreate, ' to create, ',
      Diff.Changed, ' to redefine, ', Diff.ToDrop, ' to drop, ',
      Diff.NeedingAttention, ' needing attention)');

    { Now the part that matters: run it, and compare again. The drops stay
      commented out, so the one remaining difference afterwards should be
      exactly that - which is also what proves the drops really were inert. }
    Runner := TIBXScript.Create(nil);
    Lines := TStringList.Create;
    try
      Runner.Database := TgtDB;
      Runner.Transaction := TgtTr;
      Runner.Echo := False;
      Runner.StopOnFirstError := True;
      Lines.Text := MigrationScript;
      if not Runner.RunScript(Lines) then
      begin
        WriteLn('FAIL: the generated migration script did not run against the target:');
        WriteLn(MigrationScript);
        Halt(1);
      end;
    finally
      Lines.Free;
      Runner.Free;
    end;

    if TgtTr.Active then
      TgtTr.Commit;

    MigrationScript := CompareSchemas(SrcCtx, TgtCtx, Diff2);
    { Everything the script could do must be done. What it said it could not do
      is expected to be reported again, unchanged - that is the honest outcome,
      not a failure to converge. }
    if (Diff2.ToCreate <> 0) or (Diff2.Changed <> 0) or
       (Diff2.NeedingAttention <> Diff.NeedingAttention) then
    begin
      WriteLn('FAIL: the migration did not converge - still ', Diff2.ToCreate,
        ' to create, ', Diff2.Changed, ' to redefine, ', Diff2.NeedingAttention,
        ' needing attention (expected ', Diff.NeedingAttention, ')');
      WriteLn(MigrationScript);
      Halt(1);
    end;
    if Diff2.ToDrop <> Diff.ToDrop then
    begin
      WriteLn('FAIL: the commented-out drops were not inert - ', Diff2.ToDrop,
        ' objects to drop, expected the same ', Diff.ToDrop);
      Halt(1);
    end;
    { A DDL script as the reference instead of a live database. It is run into a
      scratch database and compared like any other source, so it gets the same
      treatment with no second implementation to keep in step. }
    ScriptFile := GetTempDir + 'marathon_reference.sql';
    with TStringList.Create do
      try
        Add('create table SCRIPT_TBL (ID integer not null primary key, NAME varchar(20));');
        Add('create index IDX_SCRIPT_NAME on SCRIPT_TBL (NAME);');
        SaveToFile(ScriptFile);
      finally
        Free;
      end;
    MigrationScript := CompareScriptWithDatabase(ScriptFile, TgtCtx,
      '/tmp/marathon_cmp_scratch.fdb',
      Copy(HostPrefix, 1, Length(HostPrefix) - 1), UserName, Password,
      Diff3, ScriptError);
    if ScriptError <> '' then
    begin
      WriteLn('FAIL: comparing against a script: ', ScriptError);
      Halt(1);
    end;
    RequireInDDL(MigrationScript, 'SCRIPT_TBL', 'the table the script defines');
    RequireInDDL(MigrationScript, 'IDX_SCRIPT_NAME', 'the index the script defines');
    { The target's own tables are not in the script, so they come back as drops -
      commented out, like every other drop. }
    RequireInDDL(MigrationScript, '-- drop table', 'the target-only tables');
    if Diff3.ToCreate < 2 then
    begin
      WriteLn('FAIL: expected the script''s table and index to be created, got ',
        Diff3.ToCreate);
      Halt(1);
    end;
    DeleteFile(ScriptFile);
    WriteLn('Script comparison OK (', Diff3.ToCreate, ' to create, ',
      Diff3.ToDrop, ' to drop)');

    { A script Firebird will not accept must be reported as that, not as a
      schema with no differences. }
    ScriptFile := GetTempDir + 'marathon_bad.sql';
    with TStringList.Create do
      try
        Add('create table BROKEN (this is not sql);');
        SaveToFile(ScriptFile);
      finally
        Free;
      end;
    MigrationScript := CompareScriptWithDatabase(ScriptFile, TgtCtx,
      '/tmp/marathon_cmp_scratch.fdb',
      Copy(HostPrefix, 1, Length(HostPrefix) - 1), UserName, Password,
      Diff3, ScriptError);
    if ScriptError = '' then
    begin
      WriteLn('FAIL: a script that does not compile was accepted as a reference');
      Halt(1);
    end;
    DeleteFile(ScriptFile);
    WriteLn('Script comparison rejects a script Firebird will not run');

    WriteLn('Migration script converges (', Diff2.ToDrop,
      ' commented-out drop(s) and ', Diff2.NeedingAttention,
      ' report(s) remain, as intended)');
  finally
    if SrcTr.Active then
      SrcTr.Rollback;
    if TgtTr.Active then
      TgtTr.Rollback;
    SrcDB.DropDatabase;
    TgtDB.DropDatabase;
    SrcTr.Free;
    SrcDB.Free;
    TgtTr.Free;
    TgtDB.Free;
  end;
end;

begin
  if ParamCount < 3 then
  begin
    WriteLn('Usage: ibx_smoke_test <database> <user> <password>');
    Halt(2);
  end;

  DatabaseName := ParamStr(1);
  UserName := ParamStr(2);
  Password := ParamStr(3);

  DB := TIBDatabase.Create(nil);
  Tr := TIBTransaction.Create(nil);
  Q := TIBQuery.Create(nil);
  try
    Tr.DefaultDatabase := DB;

    DB.DatabaseName := DatabaseName;
    DB.Params.Values['user_name'] := UserName;
    DB.Params.Values['password'] := Password;
    DB.LoginPrompt := False;
    DB.CreateIfNotExists := True;

    WriteLn('Connecting to ', DatabaseName, ' ...');
    DB.Connected := True;
    WriteLn('Connected. SQLDialect=', DB.SQLDialect);

    Q.Database := DB;
    Q.Transaction := Tr;

    { Drop objects left over from a previous run, in dependency order, before
      recreating the table - "recreate table" refuses to drop a table that
      other objects still depend on. Each drop is best-effort: ignore
      "doesn't exist" failures on a first-ever run. }
    Tr.StartTransaction;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_test_trig';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop procedure ibx_smoke_test_proc';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop view ibx_smoke_test_view';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_types';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop index ibx_smoke_ix_expr';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop index ibx_smoke_ix_part';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_ident';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop function ibx_smoke_fn';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_trg_multi';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_trg_conn';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop package ibx_smoke_pkg';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop package ibx_smoke_pkg_nobody';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop procedure ibx_smoke_out';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_tz';
      Q.ExecSQL;
    except
    end;
    Tr.Commit;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'recreate table ibx_smoke_test (id integer not null primary key, note varchar(50))';
      Q.ExecSQL;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not create table: ', E.Message);
        Halt(1);
      end;
    end;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (1, ''ibx works'')';
      Q.ExecSQL;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not insert row: ', E.Message);
        Halt(1);
      end;
    end;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'select note from ibx_smoke_test where id = 1';
      Q.Open;
      if Q.EOF then
      begin
        WriteLn('FAIL: no row returned');
        Halt(1);
      end;
      Value := Q.FieldByName('note').AsString;
      Q.Close;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not query row: ', E.Message);
        Halt(1);
      end;
    end;

    if Trim(Value) <> 'ibx works' then
    begin
      WriteLn('FAIL: expected ''ibx works'', got ''', Value, '''');
      Halt(1);
    end;

    Extractor := TDDLExtractor.Create(nil);
    try
      Extractor.Database := DB;
      Extractor.Transaction := Tr;
      Extractor.SQLDialect := DB.SQLDialect;
      Extractor.IsInterbase6 := True;

      { Deliberately with no transaction open. The extractor's transaction is
        shared with everything else on the connection and is committed
        constantly - by the object tree's queries, by saving an editor - so
        being asked to extract without one is the normal case, not an edge
        case. It used to raise "Transaction is not active", which is what the
        table editor's DDL tab did. }
      if Tr.Active then
        Tr.Commit;
      try
        DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_TEST');
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;

      if (Pos('CREATE TABLE', UpperCase(DDL)) = 0) or (Pos('NOTE', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (table):');
      WriteLn(DDL);

      { Round-trip DDLExtractor against a view, a stored procedure, and a
        trigger too, not just a plain table - each code path in
        DDLExtractor.pas has its own metadata queries and is worth its own
        regression coverage. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter view ibx_smoke_test_view as select id, note from ibx_smoke_test';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create view: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        Q.SQL.Text :=
          'create or alter procedure ibx_smoke_test_proc (a_id integer) ' +
          'returns (a_note varchar(50)) ' +
          'as ' +
          'begin ' +
          '  select note from ibx_smoke_test where id = :a_id into :a_note; ' +
          '  suspend; ' +
          'end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create procedure: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        Q.SQL.Text :=
          'create or alter trigger ibx_smoke_test_trig for ibx_smoke_test ' +
          'active before insert position 0 ' +
          'as ' +
          'begin ' +
          'end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlView, ddlstNone, 'IBX_SMOKE_TEST_VIEW');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: view DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if (Pos('CREATE VIEW', UpperCase(DDL)) = 0) or (Pos('IBX_SMOKE_TEST_VIEW', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted view DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (view):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlStoredProc, ddlstNone, 'IBX_SMOKE_TEST_PROC');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: procedure DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      { ExtractStoredProcedure (ddlstNone) always emits the "alter procedure"
        body form - it's meant to follow a separate ddlstHeader "create
        procedure" stub for round-tripping procedures with forward
        references, matching how Phase 2's "Script as CREATE" already uses
        this extractor. }
      if (Pos('PROCEDURE', UpperCase(DDL)) = 0) or (Pos('A_NOTE', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted procedure DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (procedure):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TEST_TRIG');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if (Pos('CREATE', UpperCase(DDL)) = 0) or (Pos('TRIGGER', UpperCase(DDL)) = 0) or
         (Pos('IBX_SMOKE_TEST', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted trigger DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (trigger):');
      WriteLn(DDL);

      { Modern column types. Which ones exist depends on the server: BOOLEAN
        arrived in Firebird 3, and DECFLOAT / INT128 / WITH TIME ZONE in
        Firebird 4 - so ask the engine rather than assuming. CI currently runs
        Firebird 3.0, which exercises the BOOLEAN path only. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'select rdb$get_context(''SYSTEM'', ''ENGINE_VERSION'') from rdb$database';
        Q.Open;
        EngineVersion := Trim(Q.Fields[0].AsString);
        Q.Close;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not read ENGINE_VERSION: ', E.Message);
          Halt(1);
        end;
      end;
      EngineMajor := StrToIntDef(Copy(EngineVersion, 1, Pos('.', EngineVersion + '.') - 1), 0);
      WriteLn('Server ENGINE_VERSION=', EngineVersion, ' (major ', EngineMajor, ')');

      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          if EngineMajor >= 4 then
            Q.SQL.Text := 'recreate table ibx_smoke_types (' +
              'c_bool boolean, c_dec16 decfloat(16), c_dec34 decfloat(34), ' +
              'c_int128 int128, c_num38 numeric(38,4), ' +
              'c_timetz time with time zone, c_tstz timestamp with time zone, ' +
              'c_bigint bigint)'
          else
            Q.SQL.Text := 'recreate table ibx_smoke_types (c_bool boolean, c_bigint bigint)';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create modern-types table: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_TYPES');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: modern-types DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;

        { An unmapped type leaves ConvertFieldType's Result empty and the
          caller falls back to the internal domain name, so guard against
          that explicitly as well as checking each expected type name. }
        if Pos('RDB$', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: extracted DDL contains an internal RDB$ domain name, ');
          WriteLn('      which means a column type is not mapped by ConvertFieldType:');
          WriteLn(DDL);
          Halt(1);
        end;
        RequireInDDL(DDL, 'boolean', 'BOOLEAN (Firebird 3)');
        RequireInDDL(DDL, 'bigint', 'BIGINT');
        if EngineMajor >= 4 then
        begin
          RequireInDDL(DDL, 'decfloat(16)', 'DECFLOAT(16) (Firebird 4)');
          RequireInDDL(DDL, 'decfloat(34)', 'DECFLOAT(34) (Firebird 4)');
          RequireInDDL(DDL, 'int128', 'INT128 (Firebird 4)');
          RequireInDDL(DDL, 'numeric(38, 4)', 'NUMERIC(38,4) (Firebird 4)');
          RequireInDDL(DDL, 'time with time zone', 'TIME WITH TIME ZONE (Firebird 4)');
          RequireInDDL(DDL, 'timestamp with time zone', 'TIMESTAMP WITH TIME ZONE (Firebird 4)');
        end;
        WriteLn('DDL extraction OK (modern types):');
        WriteLn(DDL);
      end;

      { Identity columns (Firebird 3) and SQL SECURITY (Firebird 4). Losing an
        identity on extraction is not cosmetic - the restored column silently
        stops auto-generating - so assert on the generated clause directly. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          if EngineMajor >= 4 then
            Q.SQL.Text := 'recreate table ibx_smoke_ident (' +
              'a integer generated always as identity (start with 100 increment by 5), ' +
              'b bigint generated by default as identity)'
          else
            Q.SQL.Text := 'recreate table ibx_smoke_ident (' +
              'a integer generated by default as identity, b bigint)';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create identity table: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_IDENT');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: identity DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'as identity', 'identity clause (Firebird 3)');
        if EngineMajor >= 4 then
        begin
          RequireInDDL(DDL, 'generated always as identity', 'GENERATED ALWAYS');
          RequireInDDL(DDL, 'generated by default as identity', 'GENERATED BY DEFAULT');
          RequireInDDL(DDL, 'start with 100 increment by 5', 'START WITH / INCREMENT BY');
        end;
        WriteLn('DDL extraction OK (identity columns):');
        WriteLn(DDL);
      end;

      { Packages (Firebird 3). Header and body are separate objects and a
        package may legitimately have a header and no body. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter package ibx_smoke_pkg as begin ' +
                        'function pf(a integer) returns integer; end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create package header: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          Q.SQL.Text := 'recreate package body ibx_smoke_pkg as begin ' +
                        'function pf(a integer) returns integer as begin return a + 1; end end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create package body: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPackage, ddlstHeader, 'IBX_SMOKE_PKG');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: package header DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'create or alter package', 'package header statement');
        RequireInDDL(DDL, 'returns integer', 'declared routine in the header');
        WriteLn('DDL extraction OK (package header):');
        WriteLn(DDL);

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPackage, ddlstProc, 'IBX_SMOKE_PKG');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: package body DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'package body', 'package body statement');
        RequireInDDL(DDL, 'return a + 1', 'package body source');
        WriteLn('DDL extraction OK (package body):');
        WriteLn(DDL);

        { The query the package viewer loads from. A package may legitimately
          be declared and left unimplemented, and the viewer reports that
          rather than treating it as an error - so the body of such a package
          has to come back NULL, not empty-and-indistinguishable. }
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter package ibx_smoke_pkg_nobody as begin ' +
                        'procedure declared_only(a integer); end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create a header-only package: ', E.Message);
            Halt(1);
          end;
        end;

        EnsureTransaction;
        Q.SQL.Text := 'select rdb$package_header_source, rdb$package_body_source ' +
                      'from rdb$packages where rdb$package_name = ''IBX_SMOKE_PKG_NOBODY''';
        Q.Open;
        if Q.EOF then
        begin
          WriteLn('FAIL: the header-only package was not found');
          Halt(1);
        end;
        if Trim(Q.FieldByName('rdb$package_header_source').AsString) = '' then
        begin
          WriteLn('FAIL: the header source came back empty');
          Halt(1);
        end;
        if not Q.FieldByName('rdb$package_body_source').IsNull then
        begin
          WriteLn('FAIL: a package with no body did not report a NULL body');
          Halt(1);
        end;
        Q.Close;

        { And one that does have a body reports both. }
        EnsureTransaction;
        Q.SQL.Text := 'select rdb$package_header_source, rdb$package_body_source ' +
                      'from rdb$packages where rdb$package_name = ''IBX_SMOKE_PKG''';
        Q.Open;
        if Q.EOF or Q.FieldByName('rdb$package_body_source').IsNull then
        begin
          WriteLn('FAIL: a package with a body reported no body');
          Halt(1);
        end;
        Q.Close;
        if Tr.Active then
          Tr.Commit;
        WriteLn('Package viewer query OK (header-only reports a NULL body)');
      end;

      { Replication publications (Firebird 4). Every FB4+ database owns exactly
        one, the built-in RDB$DEFAULT, and its whole DDL surface is spelled
        ALTER DATABASE. Including a table does not switch replication on
        (RDB$ACTIVE_FLAG stays 0), so this leaves the database inert - and the
        table is excluded again afterwards to leave it as found. }
      if EngineMajor >= 4 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'alter database include table ibx_smoke_test to publication';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not include a table in the publication: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPublication, ddlstNone, DefaultPublicationName);
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: publication DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'publication', 'publication statement');
        RequireInDDL(DDL, 'include table', 'explicit publication member list');
        RequireInDDL(DDL, 'ibx_smoke_test', 'the included table');
        WriteLn('DDL extraction OK (publication):');
        WriteLn(DDL);

        Tr.StartTransaction;
        try
          Q.SQL.Text := 'alter database exclude table ibx_smoke_test from publication';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not exclude the table from the publication: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { Trigger forms beyond the six single-action table triggers. A multi-action
        trigger ("before insert or update") emitted no event clause at all, and
        a database-level trigger emitted "for " with an empty relation name -
        both invalid SQL. RDB$TRIGGER_TYPE is odd for BEFORE / even for AFTER,
        and decodes in base 4 as up to three action slots. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter trigger ibx_smoke_trg_multi for ibx_smoke_test ' +
                      'active before insert or update or delete position 0 as begin end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create multi-action trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TRG_MULTI');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: multi-action trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      RequireInDDL(DDL, 'before insert or update or delete', 'multi-action trigger event clause');
      WriteLn('DDL extraction OK (multi-action trigger):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter trigger ibx_smoke_trg_conn active on connect ' +
                      'position 0 as begin end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create database-level trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TRG_CONN');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: database-level trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      RequireInDDL(DDL, 'on connect', 'ON CONNECT event clause');
      if Pos(' FOR ', UpperCase(DDL)) > 0 then
      begin
        WriteLn('FAIL: database-level trigger emitted a FOR <relation> clause:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (database-level trigger):');
      WriteLn(DDL);

      { PSQL functions (Firebird 3). These share RDB$FUNCTIONS with legacy
        external UDFs but are a different object entirely, and running one
        through the DECLARE EXTERNAL FUNCTION path produced nonsense - the
        arguments are typed via RDB$FIELD_SOURCE, not RDB$FIELD_TYPE, so
        ConvertFieldType saw a NULL type and (before it initialised its result)
        returned arbitrary memory. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter function ibx_smoke_fn(x integer) returns integer ' +
                        'as begin return x * 2; end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create PSQL function: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlUDF, ddlstNone, 'IBX_SMOKE_FN');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: PSQL function DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        if Pos('DECLARE EXTERNAL FUNCTION', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: PSQL function extracted as an external UDF:');
          WriteLn(DDL);
          Halt(1);
        end;
        if Pos('SELECT ', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: a SQL query leaked into the generated DDL:');
          WriteLn(DDL);
          Halt(1);
        end;
        RequireInDDL(DDL, 'function', 'CREATE FUNCTION');
        RequireInDDL(DDL, 'returns integer', 'return type');
        RequireInDDL(DDL, 'return x * 2', 'function body');
        WriteLn('DDL extraction OK (PSQL function):');
        WriteLn(DDL);
      end;

      { Index DDL. An expression index has no RDB$INDEX_SEGMENTS rows, so it
        used to emit an empty column list ("on TBL()") - invalid SQL. Partial
        indexes (Firebird 5) additionally carry a WHERE condition that, if
        dropped, silently yields a full index instead of a partial one. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create index ibx_smoke_ix_expr on ibx_smoke_test computed by (upper(note))';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create expression index: ', E.Message);
          Halt(1);
        end;
      end;

      if EngineMajor >= 5 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create index ibx_smoke_ix_part on ibx_smoke_test (note) where note is not null';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create partial index: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTable, ddlstIndex, 'IBX_SMOKE_TEST');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: index DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if Pos('()', DDL) > 0 then
      begin
        WriteLn('FAIL: index DDL has an empty column list (expression index not handled):');
        WriteLn(DDL);
        Halt(1);
      end;
      RequireInDDL(DDL, 'computed by', 'COMPUTED BY for the expression index');
      if EngineMajor >= 5 then
        RequireInDDL(DDL, 'where note is not null', 'WHERE clause for the partial index (Firebird 5)');
      WriteLn('DDL extraction OK (indexes):');
      WriteLn(DDL);

      { The object tree's "Script As" generators. They live in ScriptAs.pas
        rather than MarathonIDE.pas precisely so they can be reached from here:
        MarathonProjectCache pulls in the LCL, which a console test cannot
        initialise. Each generated statement is either executed or prepared,
        so this checks the SQL is real rather than merely that the text looks
        plausible. }
      { IsIB6 is True for every Firebird a connection can be made to - see
        TMarathonCacheConnection.IsIB6 - so pass True here as well, or these
        tests exercise a configuration the application never uses. It decides
        identifier quoting and whether dialect-3 types are formatted at all:
        with False, ConvertFieldType returns an empty string for NUMERIC. }
      Ctx := ScriptAsContext(DB, Tr, True, DB.SQLDialect, EngineMajor);

      try
        { SELECT/INSERT/UPDATE/DELETE all have to parse. The SELECT is the only
          one safe to run as-is; the rest are prepared, which still makes
          Firebird compile them and resolve every name. }
        Script := ScriptAsSelect(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'select first 100', 'SELECT template');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.Open;
        Q.Close;

        Script := ScriptAsInsert(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'insert into', 'INSERT template');
        RequireInDDL(Script, ':ID', 'INSERT parameter');
        PrepareOnly(Script, 'INSERT template');

        Script := ScriptAsUpdate(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'update ', 'UPDATE template');
        PrepareOnly(Script, 'UPDATE template');

        Script := ScriptAsDelete(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'delete from', 'DELETE template');
        PrepareOnly(Script, 'DELETE template');

        Script := ScriptAsExecute(Ctx, 'IBX_SMOKE_TEST_PROC');
        RequireInDDL(Script, 'ibx_smoke_test_proc', 'EXECUTE template');
        PrepareOnly(Script, 'EXECUTE template');

        { Named arguments where the engine takes them - clearer for a routine
          with several parameters, and unaffected by a later reordering. The
          context carries the engine version so an older server still gets a
          positional call, which is the only form it will parse. }
        if EngineMajor >= 6 then
        begin
          RequireInDDL(Script, '=>', 'named arguments on Firebird 6');
          { Both forms have to compile, so build the positional one explicitly
            and prepare that too rather than assuming it still works. }
          PositionalCtx := ScriptAsContext(DB, Tr, True, DB.SQLDialect, 5);
          Script := ScriptAsExecute(PositionalCtx, 'IBX_SMOKE_TEST_PROC');
          if Pos('=>', Script) > 0 then
          begin
            WriteLn('FAIL: a pre-6 engine was given named arguments:');
            WriteLn(Script);
            Halt(1);
          end;
          PrepareOnly(Script, 'positional EXECUTE template');
        end
        else
          if Pos('=>', Script) > 0 then
          begin
            WriteLn('FAIL: named arguments generated for engine major ', EngineMajor);
            Halt(1);
          end;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a Script As DML template did not compile: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (SELECT/INSERT/UPDATE/DELETE/EXECUTE)');

      { Routine signatures, shown in the explorer's status bar so a routine's
        parameters can be read without opening it. Both catalogues type their
        arguments through the domain rather than carrying the type directly,
        which is the part worth checking. }
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_TEST_PROC', False);
      RequireInDDL(Script, 'IBX_SMOKE_TEST_PROC(', 'the routine name and an argument list');
      RequireInDDL(Script, 'A_ID integer', 'the parameter with its declared type');
      WriteLn('Signature OK (procedure): ', Script);

      if EngineMajor >= 3 then
      begin
        { A PSQL function's return type lives at argument position 0, not in a
          separate column - a detail easy to get wrong, and the reason the
          function path is checked separately. }
        Script := RoutineSignature(Ctx, 'IBX_SMOKE_FN', True);
        RequireInDDL(Script, 'IBX_SMOKE_FN(', 'the function name');
        RequireInDDL(Script, 'X integer', 'the function argument');
        RequireInDDL(Script, 'RETURNS', 'the function return type');
        WriteLn('Signature OK (function): ', Script);
      end;

      { A procedure with no parameters at all must still read sensibly. }
      EnsureTransaction;
      Q.SQL.Text := 'create or alter procedure ibx_smoke_noargs as begin end';
      Q.ExecSQL;
      if Tr.Active then
        Tr.Commit;
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_NOARGS', False);
      if Script <> 'IBX_SMOKE_NOARGS()' then
      begin
        WriteLn('FAIL: a parameterless procedure reads as "', Script, '"');
        Halt(1);
      end;
      EnsureTransaction;
      Q.SQL.Text := 'drop procedure ibx_smoke_noargs';
      Q.ExecSQL;
      if Tr.Active then
        Tr.Commit;

      { A name that is not a routine has to answer with nothing. The editor's
        hover tooltip leans on this: it asks for a signature for whatever word
        is under the pointer rather than first asking the catalogue what kind
        of object it is, so a table name must simply produce no hint. }
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_TEST', False);
      if Script <> '' then
      begin
        WriteLn('FAIL: a table name produced a routine signature: "', Script, '"');
        Halt(1);
      end;
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_TEST', True);
      if Script <> '' then
      begin
        WriteLn('FAIL: a table name produced a function signature: "', Script, '"');
        Halt(1);
      end;
      Script := RoutineSignature(Ctx, 'NO_SUCH_OBJECT_AT_ALL', False);
      if Script <> '' then
      begin
        WriteLn('FAIL: an unknown name produced a signature: "', Script, '"');
        Halt(1);
      end;
      WriteLn('Routine signature OK (nothing for a table or an unknown name)');

      { MERGE. The join condition has to come from the real primary key - an ON
        clause that never matches would turn every MERGE into an INSERT - and
        the key columns must not appear in the UPDATE SET list, since they are
        what the rows were matched on. }
      Script := ScriptAsMerge(Ctx, 'IBX_SMOKE_TEST');
      RequireInDDL(Script, 'merge into', 'MERGE statement');
      RequireInDDL(Script, 't.ID = s.ID', 'MERGE join on the primary key');
      RequireInDDL(Script, 't.NOTE = s.NOTE', 'MERGE update of a non-key column');
      if Pos('T.ID = S.ID', UpperCase(Copy(Script, Pos('UPDATE SET', UpperCase(Script)), MaxInt))) > 0 then
      begin
        WriteLn('FAIL: MERGE updates the key columns it matched on:');
        WriteLn(Script);
        Halt(1);
      end;
      { The source table is a TODO placeholder by design; falling back to the
        keyless ON clause on a table that has a primary key would not be. }
      if Pos('NO PRIMARY KEY', UpperCase(Script)) > 0 then
      begin
        WriteLn('FAIL: MERGE fell back to the no-primary-key template on a keyed table:');
        WriteLn(Script);
        Halt(1);
      end;
      WriteLn('Script As OK (MERGE):');
      WriteLn(Script);

      { DROP, for every object type the tree offers it on. Prepared rather than
        executed, which still resolves the object name - a wrong verb or a name
        that does not exist fails here. }
      try
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_VIEW', ctView), 'DROP VIEW');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_PROC', ctSP), 'DROP PROCEDURE');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_TRIG', ctTrigger), 'DROP TRIGGER');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST', ctTable), 'DROP TABLE');
        if EngineMajor >= 3 then
          PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_FN', ctUDF), 'DROP FUNCTION');
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a generated DROP statement did not compile: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (DROP: ', ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST', ctTable), ')');

      { DROP PACKAGE takes the body with it, so one statement covers a package
        whether or not it has one - prepared against both to prove it. }
      if EngineMajor >= 3 then
      begin
        Script := ScriptAsDrop(Ctx, 'IBX_SMOKE_PKG', ctPackage);
        if Pos('PACKAGE BODY', UpperCase(Script)) > 0 then
        begin
          WriteLn('FAIL: the package DROP names the body separately:');
          WriteLn(Script);
          Halt(1);
        end;
        PrepareOnly(Script, 'DROP PACKAGE (with a body)');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_PKG_NOBODY', ctPackage),
          'DROP PACKAGE (header only)');
        WriteLn('Script As OK (DROP PACKAGE: ', Trim(Script), ')');
      end;

      { ALTER. These are executed, not just prepared: restating an object
        exactly as it already is is harmless, and it is the only way to prove
        the ALTER forms are right. The trigger is the one that matters - ALTER
        TRIGGER rejects the "for <table>" clause that CREATE TRIGGER requires,
        so an extractor that simply swapped the verb would emit invalid SQL. }
      try
        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_VIEW', ctView);
        RequireInDDL(Script, 'alter view', 'ALTER VIEW form');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;

        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_TRIG', ctTrigger);
        RequireInDDL(Script, 'alter trigger', 'ALTER TRIGGER form');
        if Pos(' FOR ', UpperCase(Copy(Script, 1, Pos(#10, Script + #10)))) > 0 then
        begin
          WriteLn('FAIL: ALTER TRIGGER kept the FOR clause, which Firebird rejects:');
          WriteLn(Script);
          Halt(1);
        end;
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;

        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_PROC', ctSP);
        RequireInDDL(Script, 'alter procedure', 'ALTER PROCEDURE form');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a generated ALTER statement did not run: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (ALTER: view, trigger, procedure)');

      { A table has no whole-table ALTER, so that path emits a template rather
        than executable DDL - check it is the template and not silently empty. }
      Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST', ctTable);
      RequireInDDL(Script, 'alter table', 'ALTER TABLE template');
      RequireInDDL(Script, 'Current columns', 'the template''s column inventory');

      { Statements Firebird executes "with output" rather than through a
        cursor. TIBQuery.Open returns nothing for these, so the SQL editor used
        to execute them and silently drop what they returned. }
      EnsureTransaction;
      try
        { Singleton INSERT ... RETURNING. }
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4242';
        Q.ExecSQL;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4242, ''returned'') returning id, note', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: singleton INSERT ... RETURNING produced no output row');
          Halt(1);
        end;
        try
          if Single.FieldByName('ID').AsString <> '4242' then
          begin
            WriteLn('FAIL: RETURNING gave ID=', Single.FieldByName('ID').AsString, ', expected 4242');
            Halt(1);
          end;
          if Trim(Single.FieldByName('NOTE').AsString) <> 'returned' then
          begin
            WriteLn('FAIL: RETURNING gave NOTE=', Single.FieldByName('NOTE').AsString);
            Halt(1);
          end;
          WriteLn('Singleton output OK (INSERT ... RETURNING): ID=',
            Single.FieldByName('ID').AsString, ' NOTE=', Trim(Single.FieldByName('NOTE').AsString));
        finally
          Single.Free;
        end;

        { A statement with no output columns must come back nil, and - the part
          that matters - must not have been executed, or the caller running it
          itself would run it twice. }
        EnsureTransaction;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4243, ''must not run'')', nil);
        if Assigned(Single) then
        begin
          WriteLn('FAIL: a statement with no output columns returned a dataset');
          Single.Free;
          Halt(1);
        end;
        EnsureTransaction;
        Q.SQL.Text := 'select count(*) from ibx_smoke_test where id = 4243';
        Q.Open;
        if Q.Fields[0].AsInteger <> 0 then
        begin
          WriteLn('FAIL: ExecuteSingletonOutput executed a statement it reported as having no output');
          Halt(1);
        end;
        Q.Close;
        WriteLn('Singleton output OK (no output columns: nil, and not executed)');

        { EXECUTE PROCEDURE with output parameters takes the same path. }
        EnsureTransaction;
        Q.SQL.Text := 'create or alter procedure ibx_smoke_out (a integer) ' +
                      'returns (b integer, c varchar(10)) as begin b = a * 2; c = ''ok''; end';
        Q.ExecSQL;
        Tr.Commit;
        EnsureTransaction;
        Single := ExecuteSingletonOutput(DB, Tr, 'execute procedure ibx_smoke_out(21)', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: EXECUTE PROCEDURE with output parameters produced no row');
          Halt(1);
        end;
        try
          if (Single.FieldByName('B').AsString <> '42') or
             (Trim(Single.FieldByName('C').AsString) <> 'ok') then
          begin
            WriteLn('FAIL: EXECUTE PROCEDURE returned B=', Single.FieldByName('B').AsString,
              ' C=', Single.FieldByName('C').AsString);
            Halt(1);
          end;
          WriteLn('Singleton output OK (EXECUTE PROCEDURE): B=', Single.FieldByName('B').AsString,
            ' C=', Trim(Single.FieldByName('C').AsString));
        finally
          Single.Free;
        end;

        { NULLs must stay NULL rather than becoming empty strings. }
        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4244';
        Q.ExecSQL;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4244, null) returning id, note', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: RETURNING with a NULL column produced no row');
          Halt(1);
        end;
        try
          if not Single.FieldByName('NOTE').IsNull then
          begin
            WriteLn('FAIL: a NULL RETURNING column came back as non-NULL: "',
              Single.FieldByName('NOTE').AsString, '"');
            Halt(1);
          end;
        finally
          Single.Free;
        end;
        WriteLn('Singleton output OK (NULL stays NULL)');

        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (4242, 4244)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: singleton-output handling raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Parameter binding. The SQL editor prompts for a value per parameter and
        binds every one of them as text, leaving Firebird to convert - that is
        what lets one dialog serve every parameter type. Worth proving, since
        the alternative (an unbound parameter) is silently NULL rather than an
        error, which is the bug that prompted the dialog. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'execute procedure ibx_smoke_out(:A)';
        Q.Prepare;
        if Q.ParamCount <> 1 then
        begin
          WriteLn('FAIL: expected 1 parameter, got ', Q.ParamCount);
          Halt(1);
        end;
        if Q.Params[0].Name <> 'A' then
        begin
          WriteLn('FAIL: parameter came back named "', Q.Params[0].Name, '"');
          Halt(1);
        end;

        { An integer parameter fed a string, which is what the dialog does. }
        Q.Params[0].AsString := '21';
        Single := ExecuteSingletonOutput(DB, Tr, 'execute procedure ibx_smoke_out(21)', nil);
        if Assigned(Single) then
        try
          if Single.FieldByName('B').AsString <> '42' then
          begin
            WriteLn('FAIL: procedure did not double its argument');
            Halt(1);
          end;
        finally
          Single.Free;
        end;

        { And the case the dialog exists to prevent: left unbound, the
          parameter is NULL and the statement runs anyway. }
        EnsureTransaction;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (:ID, :NOTE)';
        Q.Prepare;
        Q.Params[0].AsString := '4321';
        Q.Params[1].AsString := 'bound as text';
        Q.ExecSQL;
        EnsureTransaction;
        Q.SQL.Text := 'select note from ibx_smoke_test where id = 4321';
        Q.Open;
        if Q.EOF or (Trim(Q.Fields[0].AsString) <> 'bound as text') then
        begin
          WriteLn('FAIL: a text-bound parameter did not reach the database intact');
          Halt(1);
        end;
        Q.Close;
        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4321';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        WriteLn('Parameter binding OK (bound as text, converted by Firebird)');

        { The declared types of a statement's parameters, which the SQL editor
          reads to decide what to validate. They are NOT available from
          TIBQuery - its TParams come back ftUnknown - so it prepares a TIBSQL
          alongside; this checks that route still yields real types, and pins
          the codes SQLParamTypes.pas maps. The one that matters is
          NUMERIC(10,2): it arrives as SQL_INT64 with a negative scale, so
          scale is what separates a whole number from a decimal. }
        EnsureTransaction;
        ParamMeta := TIBSQL.Create(nil);
        try
          ParamMeta.Database := DB;
          ParamMeta.Transaction := Tr;
          ParamMeta.SQL.Text := 'select * from ibx_smoke_test where id = :P_INT ' +
                                'and note = :P_TEXT';
          ParamMeta.Prepare;
          if ParamMeta.Params.GetCount <> 2 then
          begin
            WriteLn('FAIL: expected 2 typed parameters, got ', ParamMeta.Params.GetCount);
            Halt(1);
          end;
          if ParamMeta.Params[0].SQLType <> SQL_LONG then
          begin
            WriteLn('FAIL: an integer parameter came back as SQLType ',
              ParamMeta.Params[0].SQLType, ', expected SQL_LONG');
            Halt(1);
          end;
          if ParamMeta.Params[0].getScale <> 0 then
          begin
            WriteLn('FAIL: an integer parameter has scale ', ParamMeta.Params[0].getScale);
            Halt(1);
          end;
          if ParamMeta.Params[1].SQLType <> SQL_VARYING then
          begin
            WriteLn('FAIL: a varchar parameter came back as SQLType ',
              ParamMeta.Params[1].SQLType, ', expected SQL_VARYING');
            Halt(1);
          end;
          WriteLn('Parameter metadata OK (typed via TIBSQL: SQL_LONG scale 0, SQL_VARYING)');
        finally
          ParamMeta.Free;
        end;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: parameter binding raised: ', E.Message);
          Halt(1);
        end;
      end;

      { XLSX export. The file is a zip of XML parts, so the only way to know
        it is right is to write one and take it apart again - which the test
        harness does after this run. Here we write it from a real result set
        containing the things most likely to break the writer: a NULL, a
        number, and text needing XML escaping. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (9001, 9002)';
        Q.ExecSQL;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values ' +
                      '(9001, ''a & b <c> "d"'')';
        Q.ExecSQL;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (9002, null)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        EnsureTransaction;
        Q.SQL.Text := 'select id, note from ibx_smoke_test where id in (9001, 9002) order by id';
        Q.Open;
        Cols := TStringList.Create;
        try
          Cols.Add('ID');
          Cols.Add('NOTE');
          WriteXlsx(Q, Cols, 'Results', GetTempDir + 'ibx_smoke_export.xlsx');
        finally
          Cols.Free;
        end;
        Q.Close;

        if not FileExists(GetTempDir + 'ibx_smoke_export.xlsx') then
        begin
          WriteLn('FAIL: no workbook was written');
          Halt(1);
        end;

        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (9001, 9002)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        WriteLn('XLSX export OK (written to ', GetTempDir, 'ibx_smoke_export.xlsx)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: XLSX export raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Cell references are base-26 with no zero digit, which is the part of
        the format most easily got wrong past column Z. }
      if XlsxCellRef(0, 0) <> 'A1' then
      begin
        WriteLn('FAIL: cell (0,0) is ', XlsxCellRef(0, 0), ', expected A1');
        Halt(1);
      end;
      if XlsxCellRef(25, 0) <> 'Z1' then
      begin
        WriteLn('FAIL: cell (25,0) is ', XlsxCellRef(25, 0), ', expected Z1');
        Halt(1);
      end;
      if XlsxCellRef(26, 1) <> 'AA2' then
      begin
        WriteLn('FAIL: cell (26,1) is ', XlsxCellRef(26, 1), ', expected AA2');
        Halt(1);
      end;
      if XlsxCellRef(701, 0) <> 'ZZ1' then
      begin
        WriteLn('FAIL: cell (701,0) is ', XlsxCellRef(701, 0), ', expected ZZ1');
        Halt(1);
      end;
      if XlsxCellRef(702, 0) <> 'AAA1' then
      begin
        WriteLn('FAIL: cell (702,0) is ', XlsxCellRef(702, 0), ', expected AAA1');
        Halt(1);
      end;
      if XlsxEscape('a & b <c>') <> 'a &amp; b &lt;c&gt;' then
      begin
        WriteLn('FAIL: XML escaping is wrong: ', XlsxEscape('a & b <c>'));
        Halt(1);
      end;
      WriteLn('XLSX cell references and escaping OK');

      { Disconnect hardening. A user's own query in the SQL editor can still
        select a WITH TIME ZONE column - Marathon casts its own, but cannot
        rewrite the user's - and this IBX version then faults while closing the
        attachment. DisconnectQuietly turns that into a message so the caller's
        cleanup still runs instead of the application going down.

        Driven on a throwaway connection so the fault is real rather than
        simulated: if IBX is ever fixed, TookFault goes false and this test
        says so rather than silently passing. }
      if EngineMajor >= 4 then
      begin
        EnsureTransaction;
        Q.SQL.Text := 'recreate table ibx_smoke_tz2 (id integer, ts timestamp with time zone)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        EnsureTransaction;
        Q.SQL.Text := 'insert into ibx_smoke_tz2 values (1, current_timestamp)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        FaultDB := TIBDatabase.Create(nil);
        FaultTr := TIBTransaction.Create(nil);
        FaultQ := TIBQuery.Create(nil);
        try
          FaultDB.DatabaseName := DatabaseName;
          FaultDB.Params.Values['user_name'] := UserName;
          FaultDB.Params.Values['password'] := Password;
          FaultDB.LoginPrompt := False;
          FaultTr.DefaultDatabase := FaultDB;
          FaultDB.DefaultTransaction := FaultTr;
          FaultDB.Connected := True;
          FaultTr.StartTransaction;
          FaultQ.Database := FaultDB;
          FaultQ.Transaction := FaultTr;
          { Read the column raw - exactly what a user's own query does. }
          FaultQ.SQL.Text := 'select ts from ibx_smoke_tz2';
          FaultQ.Open;
          FaultQ.Close;
          if FaultTr.Active then
            FaultTr.Commit;

          { Must return rather than raise, whichever way it goes. }
          Value := DisconnectQuietly(FaultDB);
          if Value <> '' then
            WriteLn('Disconnect hardening OK (contained: ', Value, ')')
          else
            { Both workarounds stay regardless. The casts are not only a
              workaround - they are how the IANA zone name reaches the grid at
              all - and the guard still earns its place for anyone running an
              unpatched fbintf. }
            WriteLn('Disconnect hardening OK (clean - this fbintf has the fix from ' +
                    'MWASoftware/fbintf#7 or equivalent)');
        finally
          FaultQ.Free;
          FaultTr.Free;
          FaultDB.Free;
        end;

        EnsureTransaction;
        Q.SQL.Text := 'drop table ibx_smoke_tz2';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      end;

      { Firebird 4 WITH TIME ZONE columns. Two things are wrong with reading one
        directly through IBX, and one cast fixes both: IBX surfaces the column
        as a plain ftDateTime and reduces the zone to a numeric offset, losing
        the IANA name; and doing so leaves the attachment unable to disconnect
        afterwards (see test/timezone_disconnect_repro.lpr). Marathon's MON$
        queries therefore cast on the server, and this pins that the cast
        really does carry the zone name. }
      if EngineMajor >= 4 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text := 'recreate table ibx_smoke_tz (id integer, ts timestamp with time zone)';
          Q.ExecSQL;
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := 'insert into ibx_smoke_tz values ' +
                        '(1, timestamp ''2026-07-26 14:30:00 Europe/Berlin'')';
          Q.ExecSQL;
          if Tr.Active then
            Tr.Commit;

          EnsureTransaction;
          Q.SQL.Text := 'select cast(ts as varchar(64)) as TS_TEXT from ibx_smoke_tz';
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: no time zone row came back');
            Halt(1);
          end;
          if Pos('Europe/Berlin', Q.Fields[0].AsString) = 0 then
          begin
            WriteLn('FAIL: the cast lost the zone name: "', Q.Fields[0].AsString, '"');
            Halt(1);
          end;
          WriteLn('Time zone OK (cast keeps the name: ', Trim(Q.Fields[0].AsString), ')');
          Q.Close;
          Q.Prepared := False;

          { And the cast is wide enough for the longest names Firebird ships. }
          EnsureTransaction;
          Q.SQL.Text := 'select max(char_length(trim(rdb$time_zone_name))) from rdb$time_zones';
          Q.Open;
          if not Q.EOF then
            if Q.Fields[0].AsInteger + 25 > 64 then
            begin
              WriteLn('FAIL: varchar(64) is too narrow for the longest zone name (',
                Q.Fields[0].AsInteger, ' chars)');
              Halt(1);
            end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: time zone handling raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { The object-list queries behind the tree and the New Trigger dialog. Two
        gaps were found by running them against a live server rather than
        reading them: the table and view lists had no system-object filter, so
        they returned every MON$ and SEC$ relation - they are ordinary
        relations that happen to be flagged system, which the RDB$ name check
        does not catch - and the procedure list did not exclude packaged
        procedures, though the function list already excluded packaged
        functions. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'select count(*) from rdb$relations ' +
          'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
          'and rdb$view_source is null ' +
          'and rdb$relation_name starting with ''MON$''';
        Q.Open;
        if Q.Fields[0].AsInteger <> 0 then
        begin
          WriteLn('FAIL: the table list filter still admits MON$ relations');
          Halt(1);
        end;
        Q.Close;
        Q.Prepared := False;

        { And the filter must not throw the baby out - the smoke test's own
          table has to survive it. }
        EnsureTransaction;
        Q.SQL.Text := 'select count(*) from rdb$relations ' +
          'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
          'and rdb$view_source is null ' +
          'and rdb$relation_name = ''IBX_SMOKE_TEST''';
        Q.Open;
        if Q.Fields[0].AsInteger <> 1 then
        begin
          WriteLn('FAIL: the table list filter excludes an ordinary user table');
          Halt(1);
        end;
        Q.Close;
        Q.Prepared := False;

        if EngineMajor >= 3 then
        begin
          { A packaged procedure must not appear at top level, and a standalone
            one must. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$procedures ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and rdb$package_name is null ' +
            'and rdb$procedure_name = ''IBX_SMOKE_TEST_PROC''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 1 then
          begin
            WriteLn('FAIL: a standalone procedure is missing from the procedure list');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$procedures ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and rdb$package_name is null ' +
            'and rdb$package_name is distinct from null';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: the procedure filter is self-contradictory');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
        end;
        if Tr.Active then
          Tr.Commit;
        { Firebird 6 schemas. A database can hold objects the user never made -
          the profiler plugin puts its tables in a PLG$PROFILER schema of its
          own, and they are not flagged system, so no system filter excludes
          them. Marathon generates unqualified DDL, so the object lists show
          only what an unqualified name reaches. }
        if EngineMajor >= 6 then
        begin
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$relations ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and (rdb$schema_name = current_schema or current_schema is null) ' +
            'and rdb$relation_name starting with ''PLG$''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: the schema filter still admits another schema''s tables');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { And it must not hide the user's own. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$relations ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and (rdb$schema_name = current_schema or current_schema is null) ' +
            'and rdb$relation_name = ''IBX_SMOKE_TEST''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 1 then
          begin
            WriteLn('FAIL: the schema filter hides the user''s own table');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Schema filter OK (other schemas excluded, own schema kept)');
        end;

        WriteLn('Object list filters OK (no MON$ relations, no packaged procedures)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: object list filter check raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Encryption status. The obvious route - the raw fb_info_crypt_state
        information item - reaches the server and the item comes back, but this
        fbintf's parser does not classify that item code, so every accessor
        including getAsBytes refuses it. MON$DATABASE carries the same state,
        needs nothing outside this codebase, and its meanings are published in
        RDB$TYPES rather than having to be hard-coded. }
      if EngineMajor >= 3 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text :=
            'select coalesce(replace(trim(t.rdb$type_name), ''_'', '' ''), ' +
            'cast(d.mon$crypt_state as varchar(11))) as CRYPT_STATE ' +
            'from mon$database d ' +
            'left join rdb$types t on t.rdb$field_name = ''MON$CRYPT_STATE'' ' +
            'and t.rdb$type = d.mon$crypt_state';
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: MON$DATABASE returned no row');
            Halt(1);
          end;
          Value := Trim(Q.Fields[0].AsString);
          { The smoke-test database is not encrypted, so this is the state it
            has to report - and it must be the decoded name, not a bare code. }
          if Value <> 'NOT ENCRYPTED' then
          begin
            WriteLn('FAIL: crypt state came back "', Value, '", expected NOT ENCRYPTED');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { All four states are published, so a future one shows its own name. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$types where rdb$field_name = ''MON$CRYPT_STATE''';
          Q.Open;
          if Q.Fields[0].AsInteger < 4 then
          begin
            WriteLn('FAIL: expected at least 4 documented crypt states, got ',
              Q.Fields[0].AsInteger);
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Encryption status OK (', Value, ')');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: encryption status raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { The built-in profiler (Firebird 5). Driven end to end here because the
        interesting part is not the SQL but where the PLG$PROF_* tables live:
        Firebird 6 puts them in a schema of their own, earlier versions did
        not, and ProfilerQueries resolves that from the catalogue rather than
        from a version test. }
      if ProfilerAvailable(DB, Tr) then
      begin
        EnsureTransaction;
        try
          ProfileId := StartProfilerSession(DB, Tr, 'ibx smoke test');
          if ProfileId < 0 then
          begin
            WriteLn('FAIL: START_SESSION returned no session id');
            Halt(1);
          end;

          { Something for it to record. }
          Q.SQL.Text := 'select count(*) from ibx_smoke_test';
          Q.Open;
          Q.Close;

          FinishProfilerSession(DB, Tr);
          if Tr.Active then
            Tr.Commit;

          { Where the PLG$PROF_* tables live is the part that varies: Firebird 6
            puts them in a schema of their own, earlier versions did not. This
            reads RDB$RELATIONS, not the profiler tables, so it is safe - see
            the note below about what is not. }
          EnsureTransaction;
          Prefix := ProfilerSchemaPrefix(DB, Tr);
          if EngineMajor >= 6 then
          begin
            if Prefix = '' then
            begin
              WriteLn('FAIL: no schema prefix resolved on a server that uses schemas');
              Halt(1);
            end;
          end;
          if (Prefix <> '') and (Copy(Prefix, Length(Prefix), 1) <> '.') then
          begin
            WriteLn('FAIL: the prefix is not dot-terminated: "', Prefix, '"');
            Halt(1);
          end;
          if Pos(Prefix + 'plg$prof_sessions', ProfilerSessionsSQL(Prefix)) = 0 then
          begin
            WriteLn('FAIL: the sessions query does not use the resolved prefix');
            Halt(1);
          end;
          { Reading these was what faulted before the cause was understood: the
            sessions view has TIMESTAMP WITH TIME ZONE columns, and handing one
            to this IBX version breaks the later disconnect. ProfilerSessionsSQL
            casts them, so the whole set is readable again - and if that
            regresses, this run ends with the fault rather than a pass. }
          Q.SQL.Text := ProfilerSessionsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: no profiler session was recorded');
            Halt(1);
          end;
          if Q.FieldByName('description').AsString <> 'ibx smoke test' then
          begin
            WriteLn('FAIL: session description came back "',
              Q.FieldByName('description').AsString, '"');
            Halt(1);
          end;
          { The cast keeps the zone name here too. }
          if Pos('/', Q.FieldByName('start_timestamp').AsString) = 0 then
          begin
            WriteLn('FAIL: the session start time lost its zone name: "',
              Q.FieldByName('start_timestamp').AsString, '"');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := ProfilerStatementStatsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: the profiler recorded no statement statistics');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := ProfilerRecordSourceStatsSQL(Prefix);
          Q.Open;
          Q.Close;
          Q.Prepared := False;

          { DISCARD does not remove anything already flushed, despite the name,
            so a session survives it - a "clear" button wired to DISCARD would
            look broken. }
          EnsureTransaction;
          DiscardProfilerData(DB, Tr);
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := ProfilerSessionsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: DISCARD removed flushed sessions - it is not supposed to');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { Deleting the session is what clears it, and the dependent rows go
            with it. }
          EnsureTransaction;
          ClearProfilerData(DB, Tr, Prefix);
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from ' + Prefix + 'plg$prof_statements';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: clearing the sessions left statement rows behind');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Profiler OK (session ', ProfileId, ' recorded; prefix "', Prefix,
            '"; stats readable; clearing cascades)');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: profiler raised: ', E.Message);
            Halt(1);
          end;
        end;
      end
      else
        WriteLn('Profiler not available on this server - skipped');

      { EXPLAIN. It is a client-side command that isql implements itself, not
        server DSQL - preparing "explain select ..." through IBX fails with
        "Token unknown - explain" - so the editor recognises it, strips it and
        prepares what is left. Two things have to hold for that to work. }
      CheckExplain('explain select 1 from rdb$database', True, 'select 1 from rdb$database');
      CheckExplain('   EXPLAIN   select 1 from rdb$database  ', True, 'select 1 from rdb$database');
      CheckExplain('explain' + #13#10 + 'select 1 from rdb$database', True, 'select 1 from rdb$database');
      { Not a request to explain: the keyword has to be a whole word, and there
        has to be something after it. }
      CheckExplain('select * from EXPLAINED', False, '');
      CheckExplain('explainer select 1', False, '');
      CheckExplain('explain', False, '');
      CheckExplain('   ', False, '');
      WriteLn('EXPLAIN parsing OK');

      { First: a prepared statement carries its explained plan, so no execution
        is needed to get one. Second - the point of the whole feature - the
        statement really is not executed, which is what makes explaining a
        DELETE safe. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'delete from ibx_smoke_test';
        Q.Prepare;
        Script := Q.GetPlan;
        if Trim(Script) = '' then
        begin
          WriteLn('FAIL: GetPlan after Prepare returned nothing - EXPLAIN would show an empty plan');
          Halt(1);
        end;
        Q.SQL.Text := 'select count(*) from ibx_smoke_test';
        Q.Open;
        if Q.Fields[0].AsInteger = 0 then
        begin
          WriteLn('FAIL: preparing a DELETE executed it - EXPLAIN would destroy data');
          Halt(1);
        end;
        Q.Close;
        if Tr.Active then
          Tr.Commit;
        WriteLn('EXPLAIN OK (plan available from Prepare alone, nothing executed)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: EXPLAIN plan check raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Multi-row RETURNING is the case the roadmap asked about, and it needs
        no special handling: Firebird gives it a real cursor and reports it as
        SQLSelect, so the editor's ordinary Open path shows every row. Assert
        that, so a future IBX bump that changes it is caught here. }
      if EngineMajor >= 5 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text := 'update ibx_smoke_test set note = note returning id, note';
          Q.Prepare;
          if Q.StatementType <> SQLSelect then
          begin
            WriteLn('FAIL: multi-row RETURNING no longer reports SQLSelect - the SQL ' +
                    'editor would stop showing its rows');
            Halt(1);
          end;
          Q.Open;
          Q.Close;
          { Unprepared before the commit, not after: a prepared statement holds
            a transaction interface, and touching it once that transaction has
            ended dereferences nil. }
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Multi-row RETURNING OK (reports SQLSelect, opens as a cursor)');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: multi-row RETURNING raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;
    finally
      Extractor.Free;
    end;

    if Tr.Active then
      Tr.Commit;

    { A domain, a generator and an exception, left behind deliberately. The GUI
      harness opens an editor on each kind the database holds, and without one
      of these it skips those three editors - which is honest but covers
      nothing. Created here because this suite already owns the test database.
      RECREATE/EXECUTE BLOCK so a re-run is not an error. }
    EnsureTransaction;
    try
      Q.SQL.Text := 'execute block as begin ' +
        'if (not exists(select 1 from rdb$fields where rdb$field_name = ''SMOKE_DOM'')) then ' +
        '  execute statement ''create domain SMOKE_DOM as varchar(12) character set WIN1252''; ' +
        'if (not exists(select 1 from rdb$generators where rdb$generator_name = ''SMOKE_GEN'')) then ' +
        '  execute statement ''create generator SMOKE_GEN''; ' +
        'if (not exists(select 1 from rdb$exceptions where rdb$exception_name = ''SMOKE_EXC'')) then ' +
        '  execute statement ''create exception SMOKE_EXC ''''a smoke test exception''''''; ' +
        'end';
      Q.ExecSQL;
      if Tr.Active then
        Tr.Commit;
      WriteLn('Editor fixtures OK (domain, generator and exception present)');

      { The same table name in two schemas, left behind for the GUI harness.
        The object editors filter their metadata on name alone, which on
        Firebird 6 matches every schema at once - so an editor opened on one of
        these used to show a table built from both. Nothing but a real pair of
        same-named tables can catch that, and only the GUI harness can open an
        editor, so the pair is made here and left. }
      if EngineMajor >= 6 then
      begin
        EnsureTransaction;
        Q.SQL.Text := 'execute block as begin ' +
          'if (not exists(select 1 from rdb$schemas where rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create schema EDIT_SCH''; end';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        EnsureTransaction;
        Q.SQL.Text := 'execute block as begin ' +
          'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_DUP'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create table EDIT_DUP (ID integer, HERE_A varchar(5), HERE_B varchar(5))''; ' +
          'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_DUP'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create table EDIT_SCH.EDIT_DUP (OVER_THERE integer)''; ' +
          'end';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        EnsureTransaction;
        Q.SQL.Text := 'execute block as begin ' +
          'if (exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_VW'' and rdb$schema_name = current_schema)) then execute statement ''drop view EDIT_VW''; ' +
          'if (exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_VW'' and rdb$schema_name = ''EDIT_SCH'')) then execute statement ''drop view EDIT_SCH.EDIT_VW''; ' +
          'if (exists(select 1 from rdb$procedures where rdb$procedure_name = ''EDIT_SP'' and rdb$schema_name = current_schema)) then execute statement ''drop procedure EDIT_SP''; ' +
          'if (exists(select 1 from rdb$procedures where rdb$procedure_name = ''EDIT_SP'' and rdb$schema_name = ''EDIT_SCH'')) then execute statement ''drop procedure EDIT_SCH.EDIT_SP''; ' +
          'if (exists(select 1 from rdb$exceptions where rdb$exception_name = ''EDIT_EXC'' and rdb$schema_name = current_schema)) then execute statement ''drop exception EDIT_EXC''; ' +
          'if (exists(select 1 from rdb$exceptions where rdb$exception_name = ''EDIT_EXC'' and rdb$schema_name = ''EDIT_SCH'')) then execute statement ''drop exception EDIT_SCH.EDIT_EXC''; ' +
          'end';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        { One object of every editable kind, in both schemas, each with a marker
          saying which schema it came from. The markers are deliberately not
          substrings of one another - an earlier pair, HERE_V and THERE_V, made
          a correct editor look wrong. One kind at a time
          because a failed statement in an EXECUTE BLOCK abandons the rest. }
        EnsureTransaction;
        Q.SQL.Text := 'execute block as begin ' +
          'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_VW'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create view EDIT_VW (VCUR) as select HERE_A from EDIT_DUP''; ' +
          'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''EDIT_VW'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create view EDIT_SCH.EDIT_VW (VOTH) as select OVER_THERE from EDIT_SCH.EDIT_DUP''; ' +
          'if (not exists(select 1 from rdb$procedures where rdb$procedure_name = ''EDIT_SP'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create procedure EDIT_SP returns (PCUR integer) as begin PCUR = 1; suspend; end''; ' +
          'if (not exists(select 1 from rdb$procedures where rdb$procedure_name = ''EDIT_SP'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create procedure EDIT_SCH.EDIT_SP returns (POTH integer) as begin POTH = 2; suspend; end''; ' +
          'if (not exists(select 1 from rdb$exceptions where rdb$exception_name = ''EDIT_EXC'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create exception EDIT_EXC ''''excur''''''; ' +
          'if (not exists(select 1 from rdb$exceptions where rdb$exception_name = ''EDIT_EXC'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create exception EDIT_SCH.EDIT_EXC ''''exoth''''''; ' +
          'if (not exists(select 1 from rdb$generators where rdb$generator_name = ''EDIT_GEN'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create generator EDIT_GEN''; ' +
          'if (not exists(select 1 from rdb$generators where rdb$generator_name = ''EDIT_GEN'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create generator EDIT_SCH.EDIT_GEN''; ' +
          'if (not exists(select 1 from rdb$fields where rdb$field_name = ''EDIT_DOM'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create domain EDIT_DOM as varchar(7)''; ' +
          { A table using that domain, left behind so the GUI harness can
            extract it and check the domain survives into a rebuilt
            database. The same name exists in EDIT_SCH with a different
            width, so the width says which one the extractor picked. }
          'if (not exists(select 1 from rdb$relations where rdb$relation_name = ''DOM_USER'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create table DOM_USER (ID integer, TAG EDIT_DOM)''; ' +
          'if (not exists(select 1 from rdb$fields where rdb$field_name = ''EDIT_DOM'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create domain EDIT_SCH.EDIT_DOM as varchar(19)''; ' +
          { The same trap on a procedure's parameters. They reach their type
            through RDB$PROCEDURE_PARAMETERS.RDB$FIELD_SOURCE exactly as a
            column does, so a domain matched by name alone types the parameter
            from whichever schema answered first - and the procedure name
            itself is only unique per schema, so an unqualified parameter query
            returns both procedures' parameters as if they were one list.
            DOM_PROC exists in both schemas with different parameters. }
          'if (not exists(select 1 from rdb$procedures where rdb$procedure_name = ''DOM_PROC'' ' +
          '   and rdb$schema_name = current_schema)) then ' +
          '  execute statement ''create procedure DOM_PROC (P EDIT_DOM) ' +
          'returns (R integer) as begin R = 1; suspend; end''; ' +
          'if (not exists(select 1 from rdb$procedures where rdb$procedure_name = ''DOM_PROC'' ' +
          '   and rdb$schema_name = ''EDIT_SCH'')) then ' +
          '  execute statement ''create procedure EDIT_SCH.DOM_PROC ' +
          '(Q integer, Q2 integer, Q3 integer) returns (R integer) ' +
          'as begin R = 2; suspend; end''; ' +
          'end';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        { A different description on each of the same-named tables. The editors'
          Description tab is a frame running its own query, so this is what
          shows whether it reads the object the editor was opened on. }
        EnsureTransaction;
        { COMMENT ON rather than an UPDATE of RDB$RELATIONS: Firebird 6 refuses
          to let anything write the system tables directly. }
        Q.SQL.Text := 'comment on table EDIT_DUP is ''desc here''';
        Q.ExecSQL;
        Q.SQL.Text := 'comment on table EDIT_SCH.EDIT_DUP is ''desc yonder''';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        WriteLn('Schema editor fixture OK (table, view, procedure, exception, ' +
          'generator and domain in the current schema and in EDIT_SCH)');
      end;
    except
      on E: Exception do
      begin
        if Tr.Active then
          Tr.Rollback;
        WriteLn('FAIL: could not create the editor fixtures: ', E.Message);
        Halt(1);
      end;
    end;

    { Left until last: it makes and drops databases of its own, so a failure
      earlier in the run is not hidden behind it. }
    TestTableDesignRoundTrip;
    TestQueryBuilderSQL;
    TestSchemaDiagramReader;
    TestEndToEndTableLifecycle;
    TestServerKeywordList;
    TestSQLTraceLive;
    TestCreateDatabase(HostPrefixOf(DatabaseName));
    TestObjectCatalogue;
    TestCsvImportLive;
    TestExternalTableDDL;
    TestResultFilter;
    TestBackupAndRestore;
    TestPerformanceMonitor;
    TestSchemaDDL;
    TestSchemaCompare(HostPrefixOf(DatabaseName));

    DB.Connected := False;
    WriteLn('PASS: IBX round-trip against a live Firebird server succeeded.');
  finally
    Q.Free;
    Tr.Free;
    DB.Free;
  end;
end.
