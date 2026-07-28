program keyword_test;

{ Checks that the Firebird 5/6 keywords Lazarus's SynHighlighterSQL does not
  know about are actually highlighted once FirebirdKeywords.ApplyFirebirdKeywords
  has run - see that unit for why they have to be injected through TableNames.

  Needs no database. It does need the LCL linked (SynEdit's attributes are
  built on Graphics), but not a display: build it with the nogui widgetset,
    lazbuild --ws=nogui test/keyword_test.lpi
  and it runs headlessly, which is how CI runs it.

  The limit of that trick, so nobody spends an afternoon rediscovering it:
  nogui only supports LCL classes that draw nothing. TSynSQLSyn qualifies -
  it is a non-visual component. Forms do not. Under nogui even a bare
  TForm.Create(nil) raises an access violation, as does TDBGrid, so .lfm
  loading and form construction cannot be tested this way; that needs a real
  widgetset and a display (Xvfb, say). }

{$MODE Delphi}

uses
  Interfaces, SysUtils, Classes, SynHighlighterSQL, FirebirdKeywords, SQLCompletion, TreeFilter, CommandPalette, TableDesign, SchemaNames, PrintDocument, QueryModel, SQLTraceFormat, KeyBindings, Menus, CodeTemplates, IconScaling, SchemaDiagram, PlanParser, RowEdits, SessionAdmin, CompileScript, BlobText, MemoryUsage, SystemPrivileges, CsvImport, ServerMetrics, GridLayout, DB, BufDataset;

var
  Highlighter: TSynSQLSyn;
  Failures: Integer = 0;

{ The token kind SynHighlighterSQL assigns to Word on a line of its own. }
function KindOf(const Word: String): Integer;
begin
  Result := -1;
  Highlighter.SetLine(Word, 0);
  while not Highlighter.GetEol do
  begin
    if Trim(Highlighter.GetToken) <> '' then
    begin
      Result := Highlighter.GetTokenKind;
      Exit;
    end;
    Highlighter.Next;
  end;
end;

function AttrOf(const Word: String): String;
begin
  Result := '';
  Highlighter.SetLine(Word, 0);
  while not Highlighter.GetEol do
  begin
    if Trim(Highlighter.GetToken) <> '' then
    begin
      Result := Highlighter.GetTokenAttribute.Name;
      Exit;
    end;
    Highlighter.Next;
  end;
end;

procedure Check(Condition: Boolean; const What: String);
begin
  if Condition then
    WriteLn('  ok   ', What)
  else
  begin
    WriteLn('  FAIL ', What);
    Inc(Failures);
  end;
end;

var
  Idx: Integer;
  IdentifierKind: Integer;
  Word: String;

procedure CheckContext(const Line: String; CaretX: Integer;
  ExpectKind: TCompletionKind; const ExpectPartial, ExpectQualifier, What: String);
var
  Ctx: TCompletionContext;
begin
  Ctx := CompletionContextAt(Line, CaretX);
  Check((Ctx.Kind = ExpectKind) and (Ctx.Partial = ExpectPartial) and
        (Ctx.Qualifier = ExpectQualifier), What);
end;

procedure CheckCommand(const Query, Caption, Category: String;
  Expect: Boolean; const What: String);
begin
  Check(CommandMatches(Query, Caption, Category) = Expect, What);
end;

procedure CheckFilter(const FilterText, ObjectName, KindCaption: String;
  Expect: Boolean; const What: String);
var
  F: TTreeFilter;
begin
  F := ParseTreeFilter(FilterText);
  Check(TreeFilterMatches(F, ObjectName, KindCaption) = Expect, What);
end;

procedure CheckAlias(const SQLText, Alias, Expect, What: String);
begin
  Check(ResolveAlias(SQLText, Alias) = Expect, What +
    ' (got "' + ResolveAlias(SQLText, Alias) + '")');
end;

{ A column, with only what a given check is about spelled out. }
function Col(const AOriginal, AName, AType: String; ANotNull: Boolean = False;
  const ADefault: String = ''; const AComputed: String = ''): TColumnDesign;
begin
  Result.OriginalName := AOriginal;
  Result.Name := AName;
  Result.DataType := AType;
  Result.NotNull := ANotNull;
  Result.DefaultValue := ADefault;
  Result.ComputedAs := AComputed;
  Result.Collation := '';
end;

{ True when the generated script contains that text, ignoring case and the
  runs of whitespace that only reflect how the script is laid out. }
function ScriptHas(const Script, Fragment: String): Boolean;
begin
  Result := Pos(AnsiUpperCase(Fragment), AnsiUpperCase(Script)) > 0;
end;

procedure CheckScript(Original, Target: TTableDesign;
  const Fragment: String; Expect: Boolean; const What: String);
var
  S: String;
begin
  S := TableDesignScript(Original, Target);
  Check(ScriptHas(S, Fragment) = Expect, What);
  if ScriptHas(S, Fragment) <> Expect then
    WriteLn('       script was: ', StringReplace(Trim(S), #10, ' | ', [rfReplaceAll]));
end;

{ How many statements the change list holds, and how many of them are marked
  as able to lose data. }
procedure CountChanges(Original, Target: TTableDesign;
  out Total, Destructive: Integer);
var
  Changes: TTableDesignChangeArray;
  Idx: Integer;
begin
  Destructive := 0;
  Changes := TableDesignChanges(Original, Target);
  Total := Length(Changes);
  for Idx := 0 to High(Changes) do
    if Changes[Idx].Destructive then
      Inc(Destructive);
end;

{ The position of the first statement of that kind, or -1. Used to check the
  order the changes come out in, which is what makes the script runnable. }
function IndexOfKind(Original, Target: TTableDesign;
  Kind: TTableDesignChangeKind): Integer;
var
  Changes: TTableDesignChangeArray;
  Idx: Integer;
begin
  Result := -1;
  Changes := TableDesignChanges(Original, Target);
  for Idx := 0 to High(Changes) do
    if Changes[Idx].Kind = Kind then
      Exit(Idx);
end;

{ A CUSTOMERS table as it stands in the database: what every check below
  starts from. Columns carry their own name as OriginalName, because that is
  what "already in the database" means. }
function ExistingTable: TTableDesign;
begin
  Result := TTableDesign.Create('CUSTOMERS');
  Result.AddColumn(Col('CUST_ID', 'CUST_ID', 'integer', True));
  Result.AddColumn(Col('NAME', 'NAME', 'varchar(30)'));
  Result.AddColumn(Col('BALANCE', 'BALANCE', 'numeric(18,2)', False, '0'));
  Result.PrimaryKey.Add('CUST_ID');
end;

{ Every line of every page, as one string, so a check can ask what is on paper
  rather than what the layout intended. }
function AllPages(Doc: TPrintedDocument): String;
var
  P, L: Integer;
begin
  Result := '';
  for P := 0 to Doc.PageCount - 1 do
    for L := 0 to Doc[P].Lines.Count - 1 do
      Result := Result + Doc[P].Lines[L] + #10;
end;

function PageText(Doc: TPrintedDocument; Page: Integer): String;
var
  L: Integer;
begin
  Result := '';
  for L := 0 to Doc[Page].Lines.Count - 1 do
    Result := Result + Doc[Page].Lines[L] + #10;
end;

{ The longest line anywhere, which is what running off the paper looks like. }
function WidestLine(Doc: TPrintedDocument): Integer;
var
  P, L: Integer;
begin
  Result := 0;
  for P := 0 to Doc.PageCount - 1 do
    for L := 0 to Doc[P].Lines.Count - 1 do
      if Length(Doc[P].Lines[L]) > Result then
        Result := Length(Doc[P].Lines[L]);
end;

procedure TestServerKeywords;
var
  Server, Chosen: TStringList;
begin
  Server := TStringList.Create;
  Chosen := TStringList.Create;
  try
    { Words the highlighter already handles are left alone: injecting one
      replaces its own handling with the TableName attribute, which renders
      worse than what it already does.

      Invented words are used for the other side rather than real Firebird
      ones, because by this point ApplyFirebirdKeywords has already injected
      every word in the built-in list - so a real one would correctly report
      as known and prove nothing. }
    Server.Add('SELECT');
    Server.Add('FROM');
    Server.Add('ZZ_UNKNOWN_ONE');
    Server.Add('ZZ_UNKNOWN_TWO');
    SelectUnknownKeywords(Highlighter, Server, Chosen);
    Check(Chosen.IndexOf('SELECT') < 0, 'a word the highlighter knows is not injected');
    Check(Chosen.IndexOf('FROM') < 0, 'nor another one');
    Check(Chosen.IndexOf('ZZ_UNKNOWN_ONE') >= 0, 'one it does not know is');
    Check(Chosen.IndexOf('ZZ_UNKNOWN_TWO') >= 0, 'and so is the next');

    { Duplicates and blanks come out of a catalogue query as readily as
      anything else. }
    Server.Clear;
    Server.Add('ZZ_UNKNOWN_ONE');
    Server.Add('ZZ_UNKNOWN_ONE');
    Server.Add('');
    Server.Add('   ');
    SelectUnknownKeywords(Highlighter, Server, Chosen);
    Check(Chosen.Count = 1, 'duplicates and blanks are dropped');

    { A word the server reported is painted. }
    Server.Clear;
    Server.Add('ZZ_UNKNOWN_ONE');
    ApplyServerKeywords(Highlighter, Server);
    Check(KindOf('ZZ_UNKNOWN_ONE') <> IdentifierKind,
      'a word the server reported is highlighted');
    { Which is the point of asking the server at all: this program has never
      heard of it. }
    Check(KindOf('ZZ_UNKNOWN_TWO') = IdentifierKind,
      'and one it did not report is not');

    { Nothing from the server - a Firebird older than 5, which has no
      RDB$KEYWORDS - falls back to the built-in list rather than leaving the
      highlighter with nothing. }
    Server.Clear;
    ApplyServerKeywords(Highlighter, Server);
    Check(KindOf('LOCKED') <> IdentifierKind,
      'an empty server list falls back to the built-in keywords');
  finally
    Server.Free;
    Chosen.Free;
  end;
end;

{ What a value looks like written into a statement.

  This is what the grid's "export as INSERT" produces, and until it was given
  this function it produced scripts that would not run: there was no null test
  at all, so a null column emitted nothing and left "values (1, , 'x')", and
  text was wrapped in quotes without doubling the ones inside it, so a single
  apostrophe ended the literal. Both are checked here rather than only through
  the export, because the rules are the interesting part and they need no
  database and no window - a TBufDataset is enough to hold a field of each
  type. }
{ The Session Monitor's two admin actions, as statements.

  Firebird has no CANCEL or KILL verb - both are done by deleting a row from a
  monitoring table, which is the one place the engine reads a DELETE as a
  command. Worth pinning: a typo in either statement would look like a working
  button that quietly does nothing to the wrong table.

  The window itself cannot be driven here - both handlers ask for confirmation
  first, and a modal dialog under Xvfb is a hang rather than a failure - so
  what the buttons decide is checked here and what the statements do to a real
  server is checked by the GUI harness. }
{ Rewriting the verb of a compile script.

  An editor writes CREATE and only finds out afterwards whether the object is
  already there, so the text is edited in place before it is run. The edit was
  three inline lines that indexed into a string at a position a parser handed
  them, with nothing checking the position was on the line - so a parse that
  surprised it wrote into the wrong place, or raised out of a compile that had
  nothing wrong with it. }
procedure TestCompileScript;
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    { The ordinary case: the lexer stops one past the token it read. }
    L.Text := 'create procedure P returns (R integer)' + LineEnding +
              'as begin R = 1; suspend; end';
    Check(ReplaceVerbAt(L, 1, 7, 6, 'alter'), 'the verb is replaced');
    Check(Copy(L[0], 1, 16) = 'alter procedure ',
      'and the line now says alter: ' + Copy(L[0], 1, 16));
    Check(Pos('returns (R integer)', L[0]) > 0, 'with the rest of the line intact');
    Check(Pos('R = 1', L[1]) > 0, 'and the other lines untouched');

    { Indented, and not on the first line - both of which a real script does. }
    L.Text := '/* a comment */' + LineEnding + '   create trigger T for X';
    Check(ReplaceVerbAt(L, 2, 10, 6, 'alter'), 'a verb further in is replaced');
    Check(L[1] = '   alter trigger T for X',
      'at the right place (' + L[1] + ')');
    Check(L[0] = '/* a comment */', 'leaving the line above alone');

    { The replacement need not be the same length as what it replaces. }
    L.Text := 'alter procedure P';
    Check(ReplaceVerbAt(L, 1, 6, 5, 'recreate'), 'a longer verb fits');
    Check(L[0] = 'recreate procedure P', 'and the rest follows it: ' + L[0]);

    { Positions that are not in the text change nothing. Before, each of these
      either raised or wrote somewhere else. }
    L.Text := 'create procedure P';
    Check(not ReplaceVerbAt(L, 2, 7, 6, 'alter'), 'a line past the end is refused');
    Check(not ReplaceVerbAt(L, 0, 7, 6, 'alter'), 'and so is line zero');
    Check(not ReplaceVerbAt(L, 1, 400, 6, 'alter'),
      'a column past the end of the line is refused');
    Check(not ReplaceVerbAt(L, 1, 3, 6, 'alter'),
      'and a token reaching back past the start');
    Check(not ReplaceVerbAt(L, 1, 7, 0, 'alter'), 'an empty token is refused');
    Check(not ReplaceVerbAt(nil, 1, 7, 6, 'alter'), 'and no text at all');
    Check(L[0] = 'create procedure P',
      'none of which changed the text (' + L[0] + ')');
  finally
    L.Free;
  end;
end;

{ Showing a blob.

  The viewer had a tab labelled Hex that held no hex - it loaded the blob into
  a second memo as text - and it wrote whichever memo was in front back into
  the blob when the tab was switched or OK was pressed. For a binary blob that
  is not a viewer but a shredder: a memo normalises line endings and loses what
  it cannot render, so opening an image and pressing OK replaced it with a
  transcription of itself. Both halves of the fix are decisions about bytes. }
procedure TestBlobText;
var
  Data: TBytes;
  Dump: String;
  Byte_: Integer;
  L: TStringList;

  procedure SetBytes(const S: String);
  var
    Idx: Integer;
  begin
    SetLength(Data, Length(S));
    for Idx := 1 to Length(S) do
      Data[Idx - 1] := Ord(S[Idx]);
  end;

begin
  { Text is text. }
  SetBytes('select * from CUSTOMERS' + #13#10 + 'where ID = 1');
  Check(not IsBinaryData(Data), 'a SQL script is not binary');
  SetBytes('');
  Check(not IsBinaryData(Data), 'and nothing at all is not binary either');
  SetBytes('tabs' + #9 + 'and' + #10 + 'newlines' + #13);
  Check(not IsBinaryData(Data), 'tabs and line endings are text');

  { A NUL settles it on its own - no text blob has one and every binary format
    does. }
  SetLength(Data, 4);
  Data[0] := Ord('a'); Data[1] := 0; Data[2] := Ord('b'); Data[3] := Ord('c');
  Check(IsBinaryData(Data), 'a NUL makes it binary whatever else is there');

  { A PNG header: no NUL in the first bytes, but plainly not text. }
  SetLength(Data, 8);
  Data[0] := $89; Data[1] := $50; Data[2] := $4E; Data[3] := $47;
  Data[4] := $0D; Data[5] := $0A; Data[6] := $1A; Data[7] := $0A;
  Check(IsBinaryData(Data), 'and so does a run of control bytes');

  { One stray control byte in a page of text is not a reason to refuse to
    edit it. }
  SetBytes(StringOfChar('x', 100) + #1);
  Check(not IsBinaryData(Data), 'but one odd byte among a hundred is not');

  { The dump: offset, hex, and the printable bytes again. }
  SetBytes('Hello');
  Dump := HexDump(Data);
  L := TStringList.Create;
  try
    L.Text := Dump;
    Check(L.Count = 1, 'five bytes make one dump line (' + IntToStr(L.Count) + ')');
    Check(Pos('00000000', L[0]) = 1, 'which starts with its offset: ' + L[0]);
    Check(Pos('48 65 6C 6C 6F', L[0]) > 0, 'holds the bytes in hex');
    Check(Pos('Hello', L[0]) > 0, 'and the printable ones in the gutter');

    { Sixteen to a line, and the gutter shows a dot for what it cannot draw. }
    SetLength(Data, 17);
    for Byte_ := 0 to 16 do
      Data[Byte_] := Byte_;
    L.Text := HexDump(Data);
    Check(L.Count = 2, 'seventeen bytes make two lines (' + IntToStr(L.Count) + ')');
    Check(Pos('00000010', L[1]) = 1, 'the second starting at offset 16: ' + L[1]);
    Check(Pos('.', L[0]) > 0, 'and an unprintable byte is a dot in the gutter');

    { A blob can be megabytes; the dump says when it stopped rather than
      looking like a blob that ends there. }
    SetLength(Data, 100);
    FillChar(Data[0], 100, Ord('z'));
    L.Text := HexDump(Data, 32);
    Check(Pos('68 more byte', L[L.Count - 1]) > 0,
      'a limited dump says how much it left out: ' + L[L.Count - 1]);
    Check(Pos('more byte', HexDump(Data)) = 0,
      'and an unlimited one has nothing to say about it');
  finally
    L.Free;
  end;
end;

{ Reading MON$MEMORY_USAGE.

  The table is a stat id, a group number and four byte counts; the group
  numbers are the engine's and nothing in the catalogue explains them, which is
  why they are in one named place. }
procedure TestMemoryUsage;
begin
  Check(StatGroupName(StatGroupDatabase) = 'Database', 'group 0 is the database');
  Check(StatGroupName(StatGroupAttachment) = 'Attachment', 'group 1 is an attachment');
  Check(StatGroupName(StatGroupTransaction) = 'Transaction', 'group 2 is a transaction');
  Check(StatGroupName(StatGroupStatement) = 'Statement', 'group 3 is a statement');
  Check(StatGroupName(StatGroupCall) = 'Call', 'group 4 is a call');
  { A later Firebird adding a group should read as itself rather than as one of
    the ones that exist. }
  Check(StatGroupName(9) = 'Group 9', 'and an unknown group is shown as its number');

  Check(FormatBytes(512) = '512 B', 'small pools are bytes');
  Check(FormatBytes(2048) = '2.0 KB', 'and larger ones scale (' + FormatBytes(2048) + ')');
  Check(FormatBytes(3 * 1024 * 1024) = '3.0 MB', 'up to megabytes');
  Check(Pos('GB', FormatBytes(Int64(5) * 1024 * 1024 * 1024)) > 0, 'and gigabytes');
  Check(FormatBytes(-1) = '', 'a null count reads as nothing rather than as -1 B');

  { Left-joined, because the database's own pool has no attachment and is
    usually the largest row - an inner join would drop it. }
  Check(Pos('left join mon$attachments', MemoryUsageSQL) > 0,
    'the query keeps pools that belong to no attachment');
  Check(Pos('order by m.mon$memory_allocated desc', MemoryUsageSQL) > 0,
    'and puts the largest first, which is the question being asked');
end;

{ Decoding RDB$ROLES.RDB$SYSTEM_PRIVILEGES.

  Firebird 4 grants the right to run gbak, trace another attachment or create a
  database to roles, as a bitmask that nothing in the catalogue explains. The
  layout below was measured against the 6.0.0 server rather than assumed: a
  role granted USER_MANAGEMENT (type 1) reads 0200000000000000, READ_RAW_PAGES
  (2) reads 0400..., CREATE_DATABASE (9) reads 0002..., and all of 1, 9 and 27
  together read 0202000800000000. So bit n is privilege n, low byte first. }
{ The JSON view of a blob.

  Firebird has no JSON type - a document lives in a BLOB SUB_TYPE TEXT, and
  6.0.0 has none of the SQL/JSON functions either - so nothing on the server
  will say that what was stored is malformed, or show it with the nesting
  visible. Both are decisions about text. }
procedure TestBlobJSON;
var
  Formatted, Error_: String;
begin
  { Whether to offer the view at all: the first thing that is not white space
    begins an object or an array. }
  Check(LooksLikeJSON('{"a":1}'), 'an object looks like JSON');
  Check(LooksLikeJSON('   ' + LineEnding + ' [1,2]'), 'and so does an array after white space');
  Check(not LooksLikeJSON('select * from T'), 'a SQL script does not');
  Check(not LooksLikeJSON(''), 'and neither does nothing at all');
  { A document that begins like JSON and then goes wrong still offers the view
    - that is the case where someone wants to see where it went wrong. }
  Check(LooksLikeJSON('{"broken":'), 'a broken object still looks like one');

  Formatted := FormatJSON('{"b":2,"a":[1,2]}', Error_);
  Check(Error_ = '', 'valid JSON formats without complaint');
  Check(Pos(LineEnding, Formatted) > 0, 'and comes back on more than one line');
  Check(Pos('"b"', Formatted) > 0, 'keeping its keys');
  { Two spaces per level, which is what everything else that prints JSON does. }
  Check(Pos('  "b"', Formatted) > 0, 'indented by two spaces: ' +
    StringReplace(Copy(Formatted, 1, 20), LineEnding, '|', [rfReplaceAll]));

  Formatted := FormatJSON('{"broken":', Error_);
  Check(Formatted = '', 'invalid JSON formats to nothing');
  Check(Error_ <> '', 'and says so');
  { The parser reports where it stopped, which is the useful half. }
  Check(Pos('Pos', Error_) > 0, 'naming the position: ' + Error_);

  Formatted := FormatJSON('   ', Error_);
  Check((Formatted = '') and (Error_ <> ''), 'and empty text is not valid JSON either');
end;

{ Reading a flat file into a table.

  Both VS Code database extensions ship a CSV-to-table wizard and it was the
  one thing they had that this did not. What the import decides - how a line
  splits, what type a column of text should be, and what DDL and DML that comes
  to - needs no window and no database, so it is all checked here. }
procedure TestCsvImport;
var
  Opts: TCsvOptions;
  Fields: TStringList;
  Lines: TStringList;
  Plan: TCsvImportPlan;
  DDL: String;
begin
  Opts := DefaultCsvOptions;

  { Splitting, which is where a naive importer ruins the data. }
  Fields := ParseCsvLine('a,b,c', Opts);
  try
    Check(Fields.Count = 3, 'three fields split into three');
    Check(Fields[1] = 'b', 'in order');
  finally
    Fields.Free;
  end;

  Fields := ParseCsvLine('"Smith, John",42', Opts);
  try
    Check(Fields.Count = 2, 'a comma inside quotes does not split the row');
    Check(Fields[0] = 'Smith, John', 'and the quotes come off: ' + Fields[0]);
  finally
    Fields.Free;
  end;

  { A quote inside a quoted field is written twice. A splitter that does not
    know that turns one row into several. }
  Fields := ParseCsvLine('"He said ""no""",1', Opts);
  try
    Check(Fields[0] = 'He said "no"', 'a doubled quote is one quote: ' + Fields[0]);
    Check(Fields.Count = 2, 'and does not end the field early');
  finally
    Fields.Free;
  end;

  Fields := ParseCsvLine('a,,c', Opts);
  try
    Check((Fields.Count = 3) and (Fields[1] = ''), 'an empty field is still a field');
  finally
    Fields.Free;
  end;

  { Types. A column is only a number if every value in it is. }
  Lines := TStringList.Create;
  try
    Lines.Add('ID,NAME,PRICE,WHEN_,NOTE');
    Lines.Add('1,Widget,9.99,2026-07-28,ok');
    Lines.Add('2,"Gadget, large",12.50,2026-07-29,');
    Lines.Add('3,Thing,,2026-07-30,fine');
    Plan := PlanCsvImport(Lines, Opts);
    try
      Check(Plan.ColumnCount = 5, 'five columns (' + IntToStr(Plan.ColumnCount) + ')');
      Check(Plan.RowCount = 3, 'and three rows (' + IntToStr(Plan.RowCount) + ')');
      Check(Plan.Columns[0].Name = 'ID', 'the header names the columns');
      Check(Plan.Columns[0].Kind = ckInteger, 'a column of whole numbers is integer');
      Check(Plan.Columns[2].Kind = ckDouble,
        'one with a decimal point is double precision');
      Check(Plan.Columns[3].Kind = ckDate, 'an ISO date is a date');
      Check(Plan.Columns[1].Kind = ckText, 'and words are text');
      { The gap in PRICE must not make it text. }
      Check(ColumnTypeSQL(Plan.Columns[2]) = 'double precision',
        'a missing value does not change the type');
      Check(Plan.Columns[1].Width = Length('Gadget, large'),
        'the width is the longest value (' + IntToStr(Plan.Columns[1].Width) + ')');

      DDL := Plan.CreateTableSQL('IMPORTED');
      Check(Pos('create table IMPORTED', DDL) > 0, 'the DDL names the table');
      Check(Pos('ID integer', DDL) > 0, 'with the types it worked out');
      Check(Pos('varchar(13)', DDL) > 0, 'and a width that fits the widest value');

      { An empty cell is a missing value, not an empty string. }
      Check(Pos('null', Plan.InsertSQL('IMPORTED', 2)) > 0,
        'an empty cell inserts as null');
      Check(Pos('''Gadget, large''', Plan.InsertSQL('IMPORTED', 1)) > 0,
        'a quoted value keeps its comma');
      Check(Pos('9.99', Plan.InsertSQL('IMPORTED', 0)) > 0,
        'and a number is written unquoted');
    finally
      Plan.Free;
    end;
  finally
    Lines.Free;
  end;

  { Without a header row the columns are named rather than taken from data. }
  Lines := TStringList.Create;
  try
    Lines.Add('1,two');
    Lines.Add('3,four');
    Opts.FirstRowIsNames := False;
    Plan := PlanCsvImport(Lines, Opts);
    try
      Check(Plan.RowCount = 2, 'the first line is data when it is not a header');
      Check(Plan.Columns[0].Name = 'COLUMN1', 'and the columns are named for us');
    finally
      Plan.Free;
    end;
  finally
    Lines.Free;
  end;

  { A header a spreadsheet wrote is not always a name Firebird takes. }
  Lines := TStringList.Create;
  try
    Lines.Add('Order #,2026 Total,');
    Lines.Add('1,2,3');
    Opts.FirstRowIsNames := True;
    Plan := PlanCsvImport(Lines, Opts);
    try
      Check(Plan.Columns[0].Name = 'ORDER__', 'a space and a hash become underscores: ' +
        Plan.Columns[0].Name);
      Check(Copy(Plan.Columns[1].Name, 1, 7) = 'COLUMN2',
        'a name starting with a digit is prefixed: ' + Plan.Columns[1].Name);
      Check(Plan.Columns[2].Name = 'COLUMN3', 'and an empty one is named outright');
    finally
      Plan.Free;
    end;
  finally
    Lines.Free;
  end;

  { An apostrophe in a spreadsheet must not end the literal. }
  Lines := TStringList.Create;
  try
    Lines.Add('NAME');
    Lines.Add('O''Brien');
    Plan := PlanCsvImport(Lines, Opts);
    try
      Check(Pos('''O''''Brien''', Plan.InsertSQL('T', 0)) > 0,
        'a quote in the data is doubled: ' + Plan.InsertSQL('T', 0));
    finally
      Plan.Free;
    end;
  finally
    Lines.Free;
  end;
end;

{ How busy the database is, over time.

  Firebird's counters are cumulative, so a snapshot says almost nothing: what
  is worth watching is the rate between two of them. Three things that rate has
  to survive, all of which produce nonsense if ignored - two samples in the
  same instant, a counter that went backwards, and the first sample, which has
  nothing to compare against. }
procedure TestServerMetrics;
var
  A, B: TMetricSample;
  H: TMetricHistory;
  Idx: Integer;

  function SampleAt(ASeconds: Double; AFetches: Int64): TMetricSample;
  var
    K: TMetricKind;
  begin
    Result.Taken := ASeconds / SecsPerDay;
    for K := Low(TMetricKind) to High(TMetricKind) do
      Result.Counts[K] := 0;
    Result.Counts[mkPageFetches] := AFetches;
    Result.Valid := True;
  end;

begin
  { Ten seconds apart, a thousand fetches on: a hundred a second. }
  A := SampleAt(0, 1000);
  B := SampleAt(10, 2000);
  Check(Abs(MetricRate(A, B, mkPageFetches) - 100) < 0.001,
    'a thousand fetches over ten seconds is a hundred a second (' +
    FormatFloat('0.0', MetricRate(A, B, mkPageFetches)) + ')');
  Check(MetricRate(A, B, mkPageReads) = 0, 'a counter that did not move has no rate');

  { The same instant twice. Dividing by that is how a dashboard shows
    infinity. }
  Check(MetricRate(A, SampleAt(0, 5000), mkPageFetches) = 0,
    'two samples in the same instant have no rate between them');

  { A counter lower than it was means the server started counting again, not
    that work was undone. }
  Check(MetricRate(B, SampleAt(20, 5), mkPageFetches) = 0,
    'a counter that went backwards reads as nothing, not as a negative spike');

  { A sample that could not be read is not a zero reading. }
  A.Valid := False;
  Check(MetricRate(A, B, mkPageFetches) = 0, 'an unread sample has no rate');

  Check(MetricName(mkPageFetches) = 'Page fetches', 'the counters have names');
  Check(Pos('mon$database', DatabaseMetricsSQL) > 0,
    'and the query reads the database rather than one attachment');
  Check(Pos('left join', DatabaseMetricsSQL) > 0,
    'left-joined, so a missing stats row is zeroes rather than no row');

  { The history: oldest first, capped, and no rate until there are two. }
  H := TMetricHistory.Create(3);
  try
    Check(H.LatestRate(mkPageFetches) = 0, 'an empty history has no rate');
    H.Add(SampleAt(0, 100));
    Check(H.LatestRate(mkPageFetches) = 0, 'and neither has one sample');
    H.Add(SampleAt(1, 200));
    Check(Abs(H.LatestRate(mkPageFetches) - 100) < 0.001,
      'two samples give the rate between them');

    H.Add(SampleAt(2, 300));
    H.Add(SampleAt(3, 400));
    Check(H.Count = 3, 'the history is capped (' + IntToStr(H.Count) + ')');
    { Oldest dropped, order kept - a plot reads left to right. }
    Check(Abs(H[0].Counts[mkPageFetches] - 200) < 0.001,
      'dropping the oldest rather than the newest');
    Check(H[H.Count - 1].Counts[mkPageFetches] = 400, 'and keeping the order');

    for Idx := 1 to 10 do
      H.Add(SampleAt(3 + Idx, 400 + Idx * 10));
    Check(H.Count = 3, 'however long it is left running');
  finally
    H.Free;
  end;
end;

{ Which columns a result grid shows, and how many stay put.

  A select over a wide table returns thirty columns and the one being compared
  is off the right-hand edge. Each of these rules has a way of going wrong that
  leaves a grid nobody can use, which is why they are decided here rather than
  in the dialog. }
procedure TestGridLayout;
var
  L: TGridLayout;
  Cols: TStringList;
  Vis: TStringList;
begin
  L := TGridLayout.Create;
  Cols := TStringList.Create;
  try
    Cols.Add('ID');
    Cols.Add('NAME');
    Cols.Add('PRICE');
    Cols.Add('NOTE');
    L.SetColumns(Cols);
    Check(L.Count = 4, 'the layout takes the columns it is given');
    Check(L.VisibleCount = 4, 'and shows them all to begin with');

    Check(L.Hide('NOTE'), 'a column hides');
    Check(not L.IsVisible('NOTE'), 'and stops being visible');
    Check(L.VisibleCount = 3, 'leaving the rest (' + IntToStr(L.VisibleCount) + ')');
    Vis := L.VisibleNames;
    try
      Check(Vis.Count = 3, 'the visible list is the visible ones');
      Check(Vis.IndexOf('NOTE') < 0, 'without the hidden one');
      Check(Vis[0] = 'ID', 'in the order the columns came');
    finally
      Vis.Free;
    end;

    L.Show('NOTE');
    Check(L.IsVisible('NOTE'), 'and shows again');

    { A name that is not there is not a column. }
    Check(not L.Hide('NOT_A_COLUMN'), 'an unknown column cannot be hidden');
    Check(not L.IsVisible('NOT_A_COLUMN'), 'and is not visible either');

    { Freezing: at least one column has to be left to scroll. }
    L.FrozenCount := 2;
    Check(L.FrozenCount = 2, 'two columns can be frozen');
    L.FrozenCount := 99;
    Check(L.FrozenCount = 3,
      'freezing more than there are leaves one to scroll (' +
      IntToStr(L.FrozenCount) + ' of 4)');
    L.FrozenCount := -5;
    Check(L.FrozenCount = 0, 'and a negative freeze is none');

    { Hiding a frozen column must take its place in the freeze with it, or the
      grid keeps a column fixed that is no longer there. }
    L.FrozenCount := 3;
    L.Hide('NOTE');
    Check(L.FrozenCount = 2,
      'hiding a column reduces the freeze to fit (' + IntToStr(L.FrozenCount) + ')');

    { The last column stays: a grid with nothing in it looks broken rather
      than empty. }
    L.ShowAll;
    Check(L.Hide('ID') and L.Hide('NAME') and L.Hide('PRICE'),
      'three of four hide');
    Check(L.VisibleCount = 1, 'leaving one');
    Check(not L.Hide('NOTE'), 'and the last one refuses to hide');
    Check(L.VisibleCount = 1, 'so something is always shown');

    { A new result set is a new set of columns - a hidden name must not carry
      over and hide a column of the same name in an unrelated query. }
    Cols.Clear;
    Cols.Add('NOTE');
    Cols.Add('OTHER');
    L.SetColumns(Cols);
    Check(L.IsVisible('NOTE'), 'a new result set starts with everything shown');
    Check(L.FrozenCount = 0, 'and nothing frozen');
  finally
    Cols.Free;
    L.Free;
  end;
end;

procedure TestSystemPrivileges;
const
  UserManagement = 1;
  ReadRawPages   = 2;
  CreateDatabase = 9;
  ProfileAnyAtt  = 27;
  { What the server actually returned for a role granted only that one. }
  OnlyUserMgmt = '0200000000000000';
  OnlyRawPages = '0400000000000000';
  OnlyCreateDB = '0002000000000000';
  ThreeOfThem  = '0202000800000000';
  Everything   = 'FFFFFFFFFFFFFFFF';
  Nothing      = '0000000000000000';
begin
  Check(HasSystemPrivilege(OnlyUserMgmt, UserManagement),
    'the first bit of the first byte is USER_MANAGEMENT');
  Check(not HasSystemPrivilege(OnlyUserMgmt, ReadRawPages),
    'and its neighbour is not granted by it');
  Check(HasSystemPrivilege(OnlyRawPages, ReadRawPages), 'READ_RAW_PAGES is bit 2');
  Check(HasSystemPrivilege(OnlyCreateDB, CreateDatabase),
    'CREATE_DATABASE is bit 9, which is the second byte');
  Check(not HasSystemPrivilege(OnlyCreateDB, UserManagement),
    'and the second byte does not grant the first byte''s privileges');

  { The three-privilege mask: exactly those three and nothing else. }
  Check(HasSystemPrivilege(ThreeOfThem, UserManagement) and
        HasSystemPrivilege(ThreeOfThem, CreateDatabase) and
        HasSystemPrivilege(ThreeOfThem, ProfileAnyAtt),
    'a mask with three privileges grants all three');
  Check(not HasSystemPrivilege(ThreeOfThem, ReadRawPages),
    'and grants nothing it was not given');
  Check(SystemPrivilegeCount(ThreeOfThem, 27) = 3,
    'which counts as three (' + IntToStr(SystemPrivilegeCount(ThreeOfThem, 27)) + ')');

  { RDB$ADMIN, which every database has. }
  Check(HasSystemPrivilege(Everything, ProfileAnyAtt),
    'an all-ones mask grants the highest privilege');
  Check(SystemPrivilegeCount(Everything, 27) = 28,
    'and counts every one of them including type 0');
  Check(SystemPrivilegeCount(Nothing, 27) = 0, 'an empty mask grants none');

  { What a server sends is not always what a decoder expects, and a window
    that will not open is worse than one showing a role with no privileges. }
  Check(not HasSystemPrivilege('', UserManagement), 'no mask grants nothing');
  Check(not HasSystemPrivilege('020', UserManagement),
    'and neither does half a byte');
  Check(not HasSystemPrivilege('ZZ00000000000000', UserManagement),
    'nor one that is not hex');
  Check(not HasSystemPrivilege(OnlyUserMgmt, 999),
    'a privilege past the end of the mask is not granted');
  Check(not HasSystemPrivilege(OnlyUserMgmt, -1), 'and neither is a negative one');

  { Lower case hex is as valid as upper. }
  Check(HasSystemPrivilege('ffffffffffffffff', CreateDatabase),
    'lower-case hex decodes the same');

  { The queries read the names from the catalogue rather than a list here, so
    a privilege a later Firebird adds appears by itself. }
  Check(Pos('rdb$types', SystemPrivilegeNamesSQL) > 0,
    'the names come from RDB$TYPES rather than from a hard-coded list');
  Check(Pos('hex_encode', RoleSystemPrivilegesSQL) > 0,
    'and the mask arrives as hex rather than as raw bytes');
end;

procedure TestSessionAdmin;
begin
  Check(DisconnectAttachmentSQL(17) =
    'delete from mon$attachments where mon$attachment_id = 17',
    'disconnecting an attachment deletes its MON$ATTACHMENTS row');
  Check(CancelStatementSQL(9) =
    'delete from mon$statements where mon$statement_id = 9',
    'cancelling a statement deletes its MON$STATEMENTS row, not the attachment');
  Check(Pos('current_connection', CurrentAttachmentSQL) > 0,
    'and this window finds its own attachment through CURRENT_CONNECTION');

  { The guard that stops the monitor disconnecting itself. Its own attachment
    is normally in the list, and often the first row. }
  Check(IsOwnAttachment(12, 12), 'an attachment matching this one is its own');
  Check(not IsOwnAttachment(12, 13), 'and a different one is not');
  { An id that could not be read must not match everything, or the button
    would refuse every disconnect rather than just this window's. }
  Check(not IsOwnAttachment(-1, 13), 'an unreadable id is not a match');
  Check(not IsOwnAttachment(12, -1), 'and neither is an unreadable current id');
end;

procedure TestFieldLiterals;
var
  DS: TBufDataset;
begin
  DS := TBufDataset.Create(nil);
  try
    DS.FieldDefs.Add('N', ftInteger);
    DS.FieldDefs.Add('T', ftString, 40);
    DS.FieldDefs.Add('B', ftBoolean);
    DS.FieldDefs.Add('D', ftDate);
    DS.FieldDefs.Add('TS', ftDateTime);
    DS.FieldDefs.Add('BL', ftMemo);
    DS.CreateDataset;
    DS.Open;

    { Every column left unset - which is what a null column is. }
    DS.Append;
    DS.Post;
    DS.First;
    Check(SQLFieldLiteral(DS.FieldByName('N')) = 'null',
      'a null number is the word null, not nothing at all');
    Check(SQLFieldLiteral(DS.FieldByName('T')) = 'null',
      'and a null string is not an empty pair of quotes');
    Check(SQLFieldLiteral(nil) = 'null', 'and no field at all is null too');

    DS.Edit;
    DS.FieldByName('N').AsInteger := 42;
    DS.FieldByName('T').AsString := 'O' + '''' + 'Brien';
    DS.FieldByName('B').AsBoolean := True;
    DS.FieldByName('D').AsDateTime := EncodeDate(2026, 7, 28);
    DS.FieldByName('TS').AsDateTime :=
      EncodeDate(2026, 7, 28) + EncodeTime(13, 45, 6, 0);
    DS.Post;

    Check(SQLFieldLiteral(DS.FieldByName('N')) = '42',
      'a number is written unquoted');
    { The one that made a generated script fail to parse. }
    Check(SQLFieldLiteral(DS.FieldByName('T')) =
      '''' + 'O' + '''' + '''' + 'Brien' + '''',
      'a quote inside text is doubled: ' + SQLFieldLiteral(DS.FieldByName('T')));
    Check(SQLFieldLiteral(DS.FieldByName('B')) = 'true',
      'a boolean is a boolean literal, not the quoted word True');
    { Written in the order Firebird reads rather than the machine's locale -
      a script exported here has to run somewhere else. }
    Check(SQLFieldLiteral(DS.FieldByName('D')) = '''' + '2026-07-28' + '''',
      'a date is written year first: ' + SQLFieldLiteral(DS.FieldByName('D')));
    Check(Pos('2026-07-28 13:45:06', SQLFieldLiteral(DS.FieldByName('TS'))) > 0,
      'and a timestamp carries its time: ' + SQLFieldLiteral(DS.FieldByName('TS')));
    { Not in the grid to write out. }
    Check(SQLFieldLiteral(DS.FieldByName('BL')) = 'null',
      'a blob exports as null rather than as its handle');

    DS.Close;
  finally
    DS.Free;
  end;
end;

procedure TestRowEdits;
var
  L: TRowEditList;
  E: TRowEdit;
  S: String;
begin
  { An insert makes the row rather than finding it, so it needs no key. }
  L := TRowEditList.Create;
  try
    E := L.Add(reInsert, 'CUSTOMERS');
    E.AddValue('ID', '7', False, True);
    E.AddValue('NAME', 'Smith');
    S := RowEditStatement(E);
    Check(Pos('insert into CUSTOMERS', S) > 0, 'an insert names the table');
    Check(Pos('(ID, NAME)', S) > 0, 'and its columns');
    Check(Pos('7', S) > 0, 'a numeric value is written unquoted');
    Check(Pos('''Smith''', S) > 0, 'and a text value quoted');
  finally
    L.Free;
  end;

  { An update must find exactly one row, and that is what the key is for. }
  L := TRowEditList.Create;
  try
    E := L.Add(reUpdate, 'CUSTOMERS');
    E.AddValue('NAME', 'Jones');
    E.AddKey('ID', '7', False, True);
    S := RowEditStatement(E);
    Check(Pos('update CUSTOMERS', S) > 0, 'an update names the table');
    Check(Pos('set NAME = ''Jones''', S) > 0, 'and what it sets');
    Check(Pos('where ID = 7', S) > 0, 'and finds the row by its key');
  finally
    L.Free;
  end;

  { The corner this unit exists for: no key means no safe statement. }
  L := TRowEditList.Create;
  try
    E := L.Add(reUpdate, 'NOKEY_TAB');
    E.AddValue('NAME', 'Jones');
    Check(RowEditStatement(E) = '',
      'an update with nothing to identify the row writes no statement');
    E := L.Add(reDelete, 'NOKEY_TAB');
    Check(RowEditStatement(E) = '', 'and neither does a delete');
    Check(L.UnsafeCount = 2, 'both are counted as unsafe');
    S := RowEditScript(L);
    { Said out loud rather than dropped - a preview that quietly omits an edit
      is worse than one that explains it. }
    Check(Pos('no primary key', S) > 0, 'and the script says why');
    Check(Pos('update', AnsiLowerCase(S)) = 0, 'without emitting the statement');
  finally
    L.Free;
  end;

  { Deletes. }
  L := TRowEditList.Create;
  try
    E := L.Add(reDelete, 'CUSTOMERS');
    E.AddKey('ID', '7', False, True);
    S := RowEditStatement(E);
    Check(Pos('delete from CUSTOMERS', S) > 0, 'a delete names the table');
    Check(Pos('where ID = 7', S) > 0, 'and the row');
  finally
    L.Free;
  end;

  { A compound key needs every part, or it identifies a group rather than a
    row. }
  L := TRowEditList.Create;
  try
    E := L.Add(reDelete, 'ORDER_LINE');
    E.AddKey('ORDER_ID', '3', False, True);
    E.AddKey('LINE_NO', '2', False, True);
    S := RowEditStatement(E);
    Check(Pos('ORDER_ID = 3', S) > 0, 'a compound key uses its first column');
    Check(Pos('LINE_NO = 2', S) > 0, 'and its second');
    Check(Pos(' and ', S) > 0, 'joined, so it picks one row');
  finally
    L.Free;
  end;

  { Nulls. = null is never true, so a null key has to be compared with IS
    NULL or the statement matches nothing at all. }
  L := TRowEditList.Create;
  try
    E := L.Add(reUpdate, 'T');
    E.AddValue('NOTE', '', True);
    E.AddKey('CODE', '', True);
    S := RowEditStatement(E);
    Check(Pos('set NOTE = null', S) > 0, 'a null value is set to null');
    Check(Pos('CODE is null', S) > 0, 'and a null key is matched with IS NULL');
    Check(Pos('CODE = null', S) = 0, 'never with equals, which is never true');
  finally
    L.Free;
  end;

  { Quoting, which is the whole of escaping a literal. }
  L := TRowEditList.Create;
  try
    E := L.Add(reInsert, 'T');
    E.AddValue('NAME', 'O''Brien');
    S := RowEditStatement(E);
    Check(Pos('''O''''Brien''', S) > 0, 'a quote in a value is doubled');
  finally
    L.Free;
  end;

  { An empty numeric is null, not an empty expression that would not parse. }
  L := TRowEditList.Create;
  try
    E := L.Add(reInsert, 'T');
    E.AddValue('QTY', '', False, True);
    Check(Pos('null', RowEditStatement(E)) > 0,
      'an empty numeric value is written as null');
  finally
    L.Free;
  end;

  { A schema, since the editors carry one. }
  L := TRowEditList.Create;
  try
    E := L.Add(reInsert, 'CUSTOMERS', 'S_ALPHA');
    E.AddValue('ID', '1', False, True);
    Check(Pos('S_ALPHA.CUSTOMERS', RowEditStatement(E)) > 0,
      'a table in a schema is named with it');
  finally
    L.Free;
  end;

  { The script keeps the order the edits were made in: a row inserted and then
    updated has to be inserted first. }
  L := TRowEditList.Create;
  try
    E := L.Add(reInsert, 'T');
    E.AddValue('ID', '1', False, True);
    E := L.Add(reDelete, 'T');
    E.AddKey('ID', '1', False, True);
    S := RowEditScript(L);
    Check(Pos('insert', S) < Pos('delete', S),
      'the script keeps the order the edits were made in');
    Check(L.UnsafeCount = 0, 'and neither of them is unsafe');
  finally
    L.Free;
  end;

  { Nothing at all. }
  L := TRowEditList.Create;
  try
    Check(Trim(RowEditScript(L)) = '', 'no edits make no script');
  finally
    L.Free;
  end;
end;

procedure TestPlanParser;
var
  P: TPlanNode;

  { The whole tree flattened, so a check can ask what is in it without
    walking. }
  function Flatten(N: TPlanNode; Depth: Integer): String;
  var
    Idx: Integer;
  begin
    Result := StringOfChar(' ', Depth * 2) + N.Caption;
    if N.Access <> '' then
      Result := Result + ' [' + N.Access + ']';
    Result := Result + #10;
    for Idx := 0 to N.ChildCount - 1 do
      Result := Result + Flatten(N.Children[Idx], Depth + 1);
  end;

begin
  { Nothing in, a root and nothing else out - never nil, so no caller has to
    guard. }
  P := ParsePlan('');
  try
    Check(Assigned(P), 'an empty plan still gives a tree');
    Check(P.ChildCount = 0, 'with nothing under it');
  finally
    P.Free;
  end;

  { The simplest real plan. }
  P := ParsePlan('PLAN (CUSTOMERS NATURAL)');
  try
    Check(P.ChildCount = 1, 'one table gives one node');
    Check(P.Children[0].Caption = 'CUSTOMERS', 'named after the table');
    Check(Pos('NATURAL', P.Children[0].Access) > 0, 'carrying how it is read');
    { A bare bracketed list groups without naming an operation, so it must not
      add a box of its own - one saying "(" would be noise. }
    Check(P.TotalNodes = 2, 'and the brackets add no node of their own');
    Check(IsNaturalScan(P.Children[0]), 'a table read without an index is a scan');
  finally
    P.Free;
  end;

  P := ParsePlan('PLAN (ORDERS INDEX (FK_ORD_CUST))');
  try
    Check(Pos('INDEX', P.Children[0].Access) > 0, 'an indexed read says so');
    Check(Pos('FK_ORD_CUST', P.Children[0].Access) > 0, 'and names the index');
    Check(not IsNaturalScan(P.Children[0]), 'and is not a scan');
  finally
    P.Free;
  end;

  { A join - the case the old reader turned into a single box. }
  P := ParsePlan('PLAN JOIN (CUSTOMERS NATURAL, ORDERS INDEX (FK_ORD_CUST))');
  try
    Check(P.ChildCount = 1, 'a join is one node under the root');
    Check(P.Children[0].Kind = pnJoin, 'and is recognised as a join');
    Check(P.Children[0].ChildCount = 2, 'with a child per table');
    Check(P.Children[0].Children[0].Caption = 'CUSTOMERS', 'in order');
    Check(P.Children[0].Children[1].Caption = 'ORDERS', 'both of them');
    { Two index names inside one INDEX(...) must not be read as the end of the
      item and the start of another. }
    Check(P.TotalNodes = 4, 'the whole plan is four nodes');
  finally
    P.Free;
  end;

  { Nesting, which is what makes it a tree at all. }
  P := ParsePlan('PLAN SORT (JOIN (A_TAB NATURAL, B_TAB INDEX (I1, I2)))');
  try
    Check(P.Children[0].Kind = pnSort, 'a sort is recognised');
    Check(P.Children[0].ChildCount = 1, 'wrapping one thing');
    Check(P.Children[0].Children[0].Kind = pnJoin, 'which is the join');
    Check(P.Children[0].Children[0].ChildCount = 2, 'with its two tables');
    { Two indexes in one list: a comma inside the brackets is not an item
      separator, and counting brackets is what tells them apart. }
    Check(Pos('I1', P.Children[0].Children[0].Children[1].Access) > 0,
      'an index list keeps its first index');
    Check(Pos('I2', P.Children[0].Children[0].Children[1].Access) > 0,
      'and its second, rather than splitting the item there');
  finally
    P.Free;
  end;

  P := ParsePlan('PLAN MERGE (SORT (A_TAB NATURAL), SORT (B_TAB NATURAL))');
  try
    Check(P.Children[0].Kind = pnMerge, 'a merge is recognised');
    Check(P.Children[0].ChildCount = 2, 'with both sides under it');
    Check(P.Children[0].Children[0].Kind = pnSort, 'each of which is a sort');
  finally
    P.Free;
  end;

  P := ParsePlan('PLAN HASH (A_TAB NATURAL, B_TAB NATURAL)');
  try
    Check(P.Children[0].Kind = pnHash, 'a hash join is recognised');
  finally
    P.Free;
  end;

  { ORDER, which names an index without the INDEX keyword. }
  P := ParsePlan('PLAN (CUSTOMERS ORDER PK_CUSTOMERS)');
  try
    Check(Pos('ORDER', P.Children[0].Access) > 0, 'an ordered read says so');
    Check(Pos('PK_CUSTOMERS', P.Children[0].Access) > 0, 'and names the index');
  finally
    P.Free;
  end;

  { Quoted names, which is how a mixed-case table appears. }
  P := ParsePlan('PLAN ("My Table" NATURAL)');
  try
    Check(Pos('My Table', P.Children[0].Caption) > 0,
      'a quoted name keeps its spaces');
  finally
    P.Free;
  end;

  { Several PLAN clauses, one per subquery, which Firebird runs together. }
  P := ParsePlan('PLAN (A_TAB NATURAL) PLAN (B_TAB NATURAL)');
  try
    Check(P.ChildCount = 2, 'two plan clauses give two subtrees');
  finally
    P.Free;
  end;

  { Nothing here may raise or hang, whatever arrives - a plan comes from the
    server, so anything odd in it is not the user's mistake. }
  P := ParsePlan('PLAN JOIN (A_TAB NATURAL');
  try
    Check(P.TotalNodes >= 2, 'an unclosed bracket still gives a tree');
  finally
    P.Free;
  end;
  P := ParsePlan('))))');
  try
    Check(Assigned(P), 'and so does nonsense');
  finally
    P.Free;
  end;

  { Telling the two plan formats apart, since they need different readers. }
  Check(not IsExplainedPlan('PLAN JOIN (A NATURAL, B NATURAL)'),
    'a parenthesised plan is not the explained kind');
  Check(IsExplainedPlan('Select Expression'#10'    -> Table "A" Full Scan'),
    'and an indented one is');
end;

procedure TestSchemaDiagram;
var
  D: TSchemaDiagram;
  T: TDiagramTable;
  Idx, W, H, Overlaps, A, B: Integer;
  P, Q: TDiagramTable;

  function Overlapping(X, Y: TDiagramTable): Boolean;
  begin
    Result := (X.Left < Y.Left + Y.Width) and (Y.Left < X.Left + X.Width) and
              (X.Top < Y.Top + Y.Height) and (Y.Top < X.Top + X.Height);
  end;

begin
  { An empty diagram lays out without complaint. }
  D := TSchemaDiagram.Create;
  try
    LayoutDiagram(D, 800, 160, 14, 20);
    DiagramExtent(D, W, H);
    Check((W = 0) and (H = 0), 'an empty diagram has no extent');
    Check(TableAt(D, 10, 10) = nil, 'and nothing is at any point in it');
  finally
    D.Free;
  end;

  D := TSchemaDiagram.Create;
  try
    T := D.AddTable('CUSTOMERS');
    T.Columns.Add('ID');
    T.Columns.Add('NAME');
    T := D.AddTable('ORDERS');
    T.Columns.Add('ID');
    T.Columns.Add('CUST_ID');
    T := D.AddTable('LINES');
    T.Columns.Add('ORDER_ID');
    D.AddTable('LOOKUP');   { in no relationship at all }

    { Reading a table twice is a caller reading twice, not two tables. }
    D.AddTable('CUSTOMERS');
    Check(D.TableCount = 4, 'the same table added twice is one table');

    D.AddLink('ORDERS', 'CUST_ID', 'CUSTOMERS', 'ID', 'FK_ORD_CUST');
    D.AddLink('LINES', 'ORDER_ID', 'ORDERS', 'ID', 'FK_LIN_ORD');
    Check(D.LinkCount = 2, 'links are recorded');

    { Degree counts both ends, which is what "most connected" means. }
    Check(D.DegreeOf('ORDERS') = 2, 'a table in two keys has degree two');
    Check(D.DegreeOf('CUSTOMERS') = 1, 'and one in one has degree one');
    Check(D.DegreeOf('LOOKUP') = 0, 'a table in none has degree zero');
    Check(D.DegreeOf('NOSUCHTABLE') = 0, 'and an unknown name has none either');
    Check(D.IsolatedCount = 1, 'the unrelated table is counted as isolated');

    LayoutDiagram(D, 800, 160, 14, 20);

    { Every box got a size from its columns, not a default. }
    for Idx := 0 to D.TableCount - 1 do
      if D.Tables[Idx].Width <= 0 then
      begin
        Check(False, 'every box has a width');
        Break;
      end;
    Check(D.FindTable('CUSTOMERS').Height > D.FindTable('LOOKUP').Height,
      'a box with columns is taller than one without');

    { Nothing overlaps: two boxes on top of each other is the one thing a
      layout must never do. }
    Overlaps := 0;
    for A := 0 to D.TableCount - 1 do
      for B := A + 1 to D.TableCount - 1 do
        if Overlapping(D.Tables[A], D.Tables[B]) then
          Inc(Overlaps);
    Check(Overlaps = 0, 'no two boxes overlap');

    { The most-connected table leads, so a reader finds it first. }
    P := D.FindTable('ORDERS');
    Check((P.Left <= D.FindTable('CUSTOMERS').Left) and (P.Top <= D.FindTable('CUSTOMERS').Top),
      'the most connected table is placed first');

    { And a table in no relationship goes after every table that is in one -
      mixed in, it would push related tables apart for nothing. }
    Q := D.FindTable('LOOKUP');
    Check((Q.Top > P.Top) or (Q.Left > P.Left),
      'an unrelated table is placed after the connected ones');

    DiagramExtent(D, W, H);
    Check((W > 0) and (H > 0), 'the diagram has an extent to scroll over');
    Check(W >= D.FindTable('ORDERS').Left + D.FindTable('ORDERS').Width,
      'which reaches the far edge of the furthest box');

    { Hit testing, which is how a box is picked up. }
    P := D.FindTable('ORDERS');
    Check(TableAt(D, P.Left + 5, P.Top + 5) = P, 'a point inside a box finds it');
    Check(TableAt(D, P.Left - 5, P.Top - 5) <> P, 'and a point outside does not');
    Check(TableAt(D, -100, -100) = nil, 'a point off the diagram finds nothing');
  finally
    D.Free;
  end;

  { A cycle, which real schemas have and a naive walk would spin on. }
  D := TSchemaDiagram.Create;
  try
    D.AddTable('A_TAB');
    D.AddTable('B_TAB');
    D.AddLink('A_TAB', 'B_ID', 'B_TAB', 'ID', 'FK1');
    D.AddLink('B_TAB', 'A_ID', 'A_TAB', 'ID', 'FK2');
    LayoutDiagram(D, 800, 160, 14, 20);
    Check(D.Tables[0].Width > 0, 'a cycle between two tables lays out and terminates');
  finally
    D.Free;
  end;

  { A table referencing itself - an employee's manager, say. }
  D := TSchemaDiagram.Create;
  try
    D.AddTable('STAFF');
    D.AddLink('STAFF', 'MANAGER_ID', 'STAFF', 'ID', 'FK_SELF');
    Check(D.DegreeOf('STAFF') = 2, 'a self-reference counts at both ends');
    LayoutDiagram(D, 800, 160, 14, 20);
    Check(D.FindTable('STAFF').Width > 0, 'and lays out without spinning');
  finally
    D.Free;
  end;

  { Enough tables to wrap, which is where a row-height mistake shows up as
    boxes sitting on each other. }
  D := TSchemaDiagram.Create;
  try
    for Idx := 1 to 24 do
    begin
      T := D.AddTable('T' + IntToStr(Idx));
      { Deliberately uneven heights: a row as tall as its tallest box is the
        only way the next row clears it. }
      if Idx mod 3 = 0 then
      begin
        T.Columns.Add('A'); T.Columns.Add('B'); T.Columns.Add('C');
        T.Columns.Add('D'); T.Columns.Add('E');
      end;
      if Idx > 1 then
        D.AddLink('T' + IntToStr(Idx), 'P', 'T' + IntToStr(Idx - 1), 'ID',
          'FK' + IntToStr(Idx));
    end;
    LayoutDiagram(D, 700, 160, 14, 20);
    Overlaps := 0;
    for A := 0 to D.TableCount - 1 do
      for B := A + 1 to D.TableCount - 1 do
        if Overlapping(D.Tables[A], D.Tables[B]) then
          Inc(Overlaps);
    Check(Overlaps = 0, 'twenty-four tables of uneven height still do not overlap');
    { Wrapped rather than run off the side. }
    DiagramExtent(D, W, H);
    Check(W <= 700, 'and the diagram stays within the width it was given');
    Check(H > 200, 'wrapping onto further rows');
  finally
    D.Free;
  end;
end;

procedure TestIconScaling;
begin
  { The sizes the build script renders. Anything asking for one it does not
    make would load a resource that is not there. }
  Check(IconSizeForDPI(96) = 16, 'a normal display gets the 16-pixel icons');
  Check(IconSizeForDPI(120) = 24, '125% gets 24');
  Check(IconSizeForDPI(144) = 24, '150% gets 24');
  Check(IconSizeForDPI(192) = 32, '200% gets 32');
  Check(IconSizeForDPI(288) = 32, 'and anything larger gets 32, the largest made');

  { Slightly-too-large is easier to read than slightly-too-small, so 175%
    rounds up rather than down. }
  Check(IconSizeForDPI(168) = 32, '175% rounds up rather than down');

  { A display that reports nothing useful is commoner than it should be, and
    guessing large from a bad number makes every icon wrong. }
  Check(IconSizeForDPI(0) = 16, 'a display reporting nothing gets the base size');
  Check(IconSizeForDPI(-1) = 16, 'and so does one reporting nonsense');

  { Every size the chooser can return must be one the script renders, or the
    resource lookup fails at runtime. }
  Check((IconSizeForDPI(96) = IconSizes[0]) and
        (IconSizeForDPI(144) = IconSizes[1]) and
        (IconSizeForDPI(192) = IconSizes[2]),
    'every size it can choose is one the build script renders');

  { The base keeps its old resource name: renaming it would break every strip
    loaded by a resource file an older build produced. }
  Check(IconResourceSuffix(16) = '', 'the base size has no suffix');
  Check(IconResourceSuffix(24) = '_24', 'and the others are named by size');
  Check(IconResourceSuffix(32) = '_32', 'both of them');
end;

procedure TestCodeTemplates;
var
  List: TCodeTemplateList;
  T: TCodeTemplate;
  Text_, Saved: String;
  CaretLine, CaretCol: Integer;
begin
  { Which word the user meant. }
  Check(TemplateWordBefore('sel', 4) = 'sel', 'the word before the caret is found');
  Check(TemplateWordBefore('select * from sel', 18) = 'sel',
    'from the end of a line of text');
  Check(TemplateWordBefore('  sel', 6) = 'sel', 'past leading whitespace');
  Check(TemplateWordBefore('sel ', 5) = '',
    'a caret after a space is not at the end of a word');
  Check(TemplateWordBefore('sel', 1) = '', 'and neither is one at the start');
  { Underscores and digits are part of an identifier, so part of a name. }
  Check(TemplateWordBefore('my_t2', 6) = 'my_t2',
    'underscores and digits belong to the word');

  Check(IndentOf('    select') = '    ', 'the indent of a line is its leading spaces');
  Check(IndentOf(#9'  x') = #9'  ', 'tabs count too');
  Check(IndentOf('select') = '', 'and a line at the margin has none');

  List := TCodeTemplateList.Create;
  try
    T := List.Add('sel', 'Select all rows');
    T.Body.Add('select *');
    T.Body.Add('from |');

    Check(List.Count = 1, 'a template can be added');
    Check(Assigned(List.FindByName('sel')), 'and found by name');
    { Nobody remembers whether they called it sel or SEL. }
    Check(Assigned(List.FindByName('SEL')), 'without regard to case');
    Check(List.FindByName('nope') = nil, 'and an unknown name finds nothing');

    { Expansion at the margin. }
    Text_ := ExpandTemplate(T, '', CaretLine, CaretCol);
    Check(Pos('select *', Text_) > 0, 'the body is expanded');
    Check(Pos('|', Text_) = 0, 'with the caret marker taken out');
    Check(CaretLine = 1, 'and the caret lands on the marked line');
    Check(CaretCol = 6, 'at the marked column');
    { A template goes into a line that already exists, so a trailing break
      would push whatever followed onto a line of its own. }
    Check((Length(Text_) > 0) and not (Text_[Length(Text_)] in [#13, #10]),
      'and the text does not end in a line break');

    { Expansion inside a block. Every line after the first lines up with where
      the template was typed; the first does not, because the caret is already
      there. }
    Text_ := ExpandTemplate(T, '    ', CaretLine, CaretCol);
    Check(Pos('    from', Text_) > 0, 'later lines are indented to match');
    Check(Copy(Text_, 1, 6) = 'select', 'while the first line is not, being typed in place');

    { A template with no marker. }
    T := List.Add('plain', 'No caret marker');
    T.Body.Add('commit');
    Text_ := ExpandTemplate(T, '', CaretLine, CaretCol);
    Check(Text_ = 'commit', 'a template without a marker expands whole');
    Check((CaretLine = 0) and (CaretCol = 7),
      'and the caret goes to the end, where typing would carry on');

    { The marker is the concatenation operator, so a template wanting a literal
      one doubles it. }
    T := List.Add('cat', 'Concatenate');
    T.Body.Add('a || b');
    Text_ := ExpandTemplate(T, '', CaretLine, CaretCol);
    Check(Text_ = 'a | b', 'a doubled marker becomes one literal bar');
    Check(CaretCol = 6, 'and is not mistaken for the caret position');

    { The file form. }
    Saved := List.SaveToText;
    Check(Pos('[sel | Select all rows]', Saved) > 0, 'a template saves with its header');
    Check(Pos('select *', Saved) > 0, 'and its body');
  finally
    List.Free;
  end;

  { Round trip, which is what has to hold for a saved file. }
  List := TCodeTemplateList.Create;
  try
    List.LoadFromText('[sel | Select all]'#10'select *'#10'from |'#10 +
                      '[ins | Insert]'#10'insert into |'#10);
    Check(List.Count = 2, 'two templates read back');
    Check(List[0].Name = 'sel', 'with their names');
    Check(Trim(List[0].Description) = 'Select all', 'and descriptions');
    Check(List[0].Body.Count = 2, 'and the right number of body lines');
    Check(List[1].Body[0] = 'insert into |', 'the second body is its own');
    { A body line may perfectly well contain brackets, so only a line that is
      wholly bracketed starts a new template. }
    List.LoadFromText('[t | T]'#10'select cast(x as varchar(10)) from y'#10);
    Check(List.Count = 1, 'brackets inside a body do not start a template');
    Check(List[0].Body.Count = 1, 'and the line stays in the body');
    { Anything before the first header belongs to no template. }
    List.LoadFromText('stray line'#10'[t | T]'#10'body'#10);
    Check((List.Count = 1) and (List[0].Body.Count = 1),
      'a stray line before the first header is dropped');
    { A header with no description is still a template. }
    List.LoadFromText('[bare]'#10'body'#10);
    Check((List.Count = 1) and (List[0].Name = 'bare'),
      'a header with no description still names a template');
  finally
    List.Free;
  end;

  List := TCodeTemplateList.Create;
  try
    List.AddDefaults;
    Check(List.Count > 3, 'there is a starter set for a machine that has none');
    Check(Assigned(List.FindByName('sel')), 'including a select');
    { The starter set has to survive its own file format, or the first save
      would corrupt what shipped. }
    Saved := List.SaveToText;
    List.LoadFromText(Saved);
    Check(Assigned(List.FindByName('blk')),
      'and the whole set survives a save and load');
    Check(List.FindByName('blk').Body.Count = 4,
      'with its body intact');
  finally
    List.Free;
  end;
end;

procedure TestKeyBindings;
var
  Map: TKeyMap;
  Conflicts: TStringList;
  Saved: String;
begin
  { The bits have to be the LCL's, because a value from this unit is assigned
    straight to TAction.ShortCut. They are repeated rather than imported to
    keep the unit free of the LCL, so something has to check they still
    agree - scShift, scCtrl and scAlt from LCL's Menus. }
  Check(kbShift = scShift, 'the Shift bit matches the LCL''s');
  Check(kbCtrl = scCtrl, 'and the Ctrl bit');
  Check(kbAlt = scAlt, 'and the Alt bit');

  { Text form. Written here rather than taken from ShortCutToText because that
    one is translated - on a German build Ctrl comes back as Strg - so a file
    written on one machine would not load on another. }
  Check(ShortCutToStorageText(kbNone) = '', 'no shortcut writes as nothing');
  Check(ShortCutToStorageText(Ord('S') or kbCtrl) = 'Ctrl+S', 'Ctrl+S writes plainly');
  Check(ShortCutToStorageText(Ord('P') or kbCtrl or kbShift) = 'Ctrl+Shift+P',
    'and modifiers come in a fixed order');
  Check(ShortCutToStorageText($70) = 'F1', 'a function key writes by name');
  Check(ShortCutToStorageText($2E or kbShift) = 'Shift+Del', 'and so does Delete');
  { A modifier with no key runs nothing, so it is not a shortcut. }
  Check(ShortCutToStorageText(kbCtrl) = '',
    'modifiers with no key are not a shortcut');

  { And back. }
  Check(StorageTextToShortCut('Ctrl+S') = (Ord('S') or kbCtrl), 'Ctrl+S reads back');
  Check(StorageTextToShortCut('ctrl+s') = (Ord('S') or kbCtrl), 'case does not matter');
  Check(StorageTextToShortCut('Ctrl+Shift+P') = (Ord('P') or kbCtrl or kbShift),
    'two modifiers read back');
  { Order in the file must not matter, so a hand-edited line still works. }
  Check(StorageTextToShortCut('Shift+Ctrl+P') = (Ord('P') or kbCtrl or kbShift),
    'and in either order');
  Check(StorageTextToShortCut('F5') = $74, 'a function key reads back');
  Check(StorageTextToShortCut('') = kbNone, 'an empty line is no shortcut');
  { A corrupt line must clear that binding rather than make one that can never
    be pressed. }
  Check(StorageTextToShortCut('Ctrl+') = kbNone, 'a modifier with no key is nothing');
  Check(StorageTextToShortCut('Ctrl+Nonsense') = kbNone,
    'and so is a key name nothing recognises');

  { Round trip, which is what actually has to hold for a saved file. }
  Check(StorageTextToShortCut(ShortCutToStorageText(Ord('X') or kbCtrl or kbAlt)) =
    (Ord('X') or kbCtrl or kbAlt), 'a shortcut survives being written and read');

  Map := TKeyMap.Create;
  try
    Map.Add('FileOpen', '&Open...', 'File', Ord('O') or kbCtrl);
    Map.Add('FileSave', '&Save', 'File', Ord('S') or kbCtrl);
    Map.Add('EditCopy', '&Copy', 'Edit', Ord('C') or kbCtrl);
    Map.Add('NoKey', 'No Shortcut', 'Tools', kbNone);
    Check(Map.Count = 4, 'a map holds the commands it was given');
    Check(Map.ShortCutOf('FileSave') = (Ord('S') or kbCtrl),
      'and the shortcut each came with');
    Check(Map.ShortCutOf('NotAThing') = kbNone,
      'an unknown command has no shortcut rather than raising');

    { Nothing changed yet. }
    Check(Map.ChangedCount = 0, 'a fresh map has nothing changed');
    Check(not Map.IsChanged('FileSave'), 'and no command reports otherwise');

    Map.Assign_('FileSave', Ord('W') or kbCtrl);
    Check(Map.ShortCutOf('FileSave') = (Ord('W') or kbCtrl), 'a command can be rebound');
    Check(Map.IsChanged('FileSave'), 'and says it has changed');
    Check(Map.ChangedCount = 1, 'and only that one has');

    { Conflicts. A shortcut runs one command, so two holding it means one of
      them silently never fires - and an editor has to say which. }
    Conflicts := Map.ConflictsFor('FileOpen', Ord('C') or kbCtrl);
    try
      Check(Conflicts.Count = 1, 'a shortcut already in use is reported');
      Check(Conflicts[0] = 'EditCopy', 'by name, so the editor can say which');
    finally
      Conflicts.Free;
    end;

    Conflicts := Map.ConflictsFor('FileOpen', Ord('Q') or kbCtrl);
    try
      Check(Conflicts.Count = 0, 'an unused shortcut conflicts with nothing');
    finally
      Conflicts.Free;
    end;

    { A command does not conflict with itself - otherwise re-confirming a
      binding would look like a clash. }
    Conflicts := Map.ConflictsFor('EditCopy', Ord('C') or kbCtrl);
    try
      Check(Conflicts.Count = 0, 'a command does not conflict with itself');
    finally
      Conflicts.Free;
    end;

    { Any number of commands may have no shortcut at all. }
    Map.Assign_('FileOpen', kbNone);
    Conflicts := Map.ConflictsFor('EditCopy', kbNone);
    try
      Check(Conflicts.Count = 0, 'having no shortcut conflicts with nothing');
    finally
      Conflicts.Free;
    end;

    { Saving only the differences, so a command whose built-in shortcut changes
      in a later build picks the new one up instead of being pinned by a file
      that recorded the old one. }
    Saved := Map.SaveToText;
    Check(Pos('FileSave=Ctrl+W', Saved) > 0, 'a changed binding is saved');
    Check(Pos('EditCopy', Saved) = 0, 'an unchanged one is not');
    { A cleared shortcut is a change, and different from never having touched
      it - so it has to be recorded, with an empty value. }
    Check(Pos('FileOpen=', Saved) > 0, 'and a deliberately cleared one is');

    Map.ResetAll;
    Check(Map.ChangedCount = 0, 'reset puts everything back');
    Check(Map.ShortCutOf('FileSave') = (Ord('S') or kbCtrl),
      'to the shortcut it was built with');

    Map.LoadFromText(Saved);
    Check(Map.ShortCutOf('FileSave') = (Ord('W') or kbCtrl), 'and a saved file reloads');
    Check(Map.ShortCutOf('FileOpen') = kbNone, 'including a cleared shortcut');
    Check(Map.ShortCutOf('EditCopy') = (Ord('C') or kbCtrl),
      'while one that was never changed keeps its default');

    { A file naming a command that no longer exists is stale, not a reason to
      reject everything in it. }
    Map.LoadFromText('GoneAway=Ctrl+G'#10'EditCopy=Ctrl+E');
    Check(Map.ShortCutOf('EditCopy') = (Ord('E') or kbCtrl),
      'an unknown command in the file does not stop the rest loading');
  finally
    Map.Free;
  end;
end;

procedure TestSQLTrace;
var
  Cats: TTraceCategories;
  Line: String;
  When_: TDateTime;
begin
  { Nothing asked for, nothing watched. The component leaves the monitor
    disabled on an empty set, so this is what stops a trace window that has
    been opened and configured to watch nothing from starting a reader
    thread. }
  Check(TraceCategoriesFor([], []) = [], 'watching nothing selects no categories');

  { The plain groups map one for one. }
  Check(tcConnect in TraceCategoriesFor([mgConnection], []), 'connections map to connect');
  Check(tcTransact in TraceCategoriesFor([mgTransaction], []), 'transactions to transact');
  Check(tcBlob in TraceCategoriesFor([mgBlob], []), 'blobs to blob');
  { A row is a fetch - IBX has no separate notion of one. }
  Check(tcFetch in TraceCategoriesFor([mgRow], []), 'rows map to fetch');
  { Arrays have no flag of their own and arrive among the miscellany. }
  Check(tcMisc in TraceCategoriesFor([mgArray], []), 'arrays map to the miscellany');

  { A group not asked for must not be switched on by another. }
  Cats := TraceCategoriesFor([mgConnection], []);
  Check(not (tcTransact in Cats), 'asking for one group does not enable another');

  { The statement groups are only meaningful when statements are watched at
    all. Turning Prepare on while Statements is off would trace exactly what
    the user had just switched off. }
  Cats := TraceCategoriesFor([], [sgPrepare, sgExecute, sgFetch, sgError]);
  Check(Cats = [], 'statement detail is ignored when statements are not watched');

  Cats := TraceCategoriesFor([mgStatement], []);
  Check(tcStatement in Cats, 'watching statements watches statements');

  Cats := TraceCategoriesFor([mgStatement], [sgPrepare]);
  Check(tcPrepare in Cats, 'prepare maps through');
  Check(not (tcExecute in Cats), 'and does not drag execute in with it');

  Cats := TraceCategoriesFor([mgStatement], [sgExecute]);
  Check(tcExecute in Cats, 'execute maps through');
  { Two of Marathon's groups mean the same IBX flag; either one has to reach
    it, and neither may need the other. }
  Cats := TraceCategoriesFor([mgStatement], [sgExecuteImmediate]);
  Check(tcExecute in Cats, 'and so does execute-immediate on its own');

  Cats := TraceCategoriesFor([mgStatement], [sgError]);
  Check(tcError in Cats, 'errors map through');

  { The six statement groups IBX has no flag for must still turn something on,
    or ticking one of them in the Options dialog would do nothing at all. }
  Cats := TraceCategoriesFor([mgStatement], [sgDescribe]);
  Check(tcMisc in Cats, 'a statement group IBX has no flag for asks for the miscellany');
  Cats := TraceCategoriesFor([mgStatement], [sgField]);
  Check(tcMisc in Cats, 'and so does another of them');
  Cats := TraceCategoriesFor([mgStatement], [sgPrepare]);
  Check(not (tcMisc in Cats),
    'while one that does have a flag does not ask for it as well');

  { Formatting. }
  When_ := EncodeDate(2026, 7, 27) + EncodeTime(14, 5, 9, 250);
  Line := FormatTraceLine('select 1 from rdb$database', When_, False, '');
  Check(Line = 'select 1 from rdb$database', 'without a timestamp the text is the line');

  Line := FormatTraceLine('select 1', When_, True, '');
  Check(Pos('2026-07-27', Line) > 0, 'a timestamp carries the date');
  Check(Pos('14:05:09', Line) > 0, 'and the time');
  { Two statements in the same second is the ordinary case, so a timestamp
    that cannot tell them apart is decoration. }
  Check(Pos('.250', Line) > 0, 'to the millisecond');
  Check(Pos('select 1', Line) > 0, 'and still has the statement in it');

  Line := FormatTraceLine('select 1', When_, False, ';;');
  Check(Copy(Line, Length(Line) - 1, 2) = ';;', 'an item terminator is appended');

  { MinTicks is what makes a trace usable on a busy connection. }
  Check(PassesMinTicks(0, 0), 'with no threshold everything passes');
  Check(PassesMinTicks(5, 0), 'including something that took time');
  Check(not PassesMinTicks(5, 10), 'below the threshold is dropped');
  Check(PassesMinTicks(10, 10), 'and the threshold itself passes');
end;

procedure TestQueryModel;
var
  M: TQueryModel;
  C: TQueryColumn;
  Order: TStringList;
  SQL: String;
  A, B: Integer;
begin
  { An empty builder produces nothing rather than a broken statement. }
  M := TQueryModel.Create;
  try
    Check(BuildSelectSQL(M) = '', 'an empty query builds no SQL');
  finally
    M.Free;
  end;

  { Aliases. The same table dropped twice is a self-join, not a mistake. }
  M := TQueryModel.Create;
  try
    Check(M.AddTable('', 'CUSTOMERS').Alias = 'C', 'an alias comes from the initials');
    Check(M.AddTable('', 'ORDER_LINE_ITEM').Alias = 'OLI',
      'and from the initial of each word');
    Check(M.AddTable('', 'CUSTOMERS').Alias <> 'C',
      'the same table twice gets a second alias, so a self-join works');
  finally
    M.Free;
  end;

  { One table, nothing ticked. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'CUSTOMERS');
    SQL := BuildSelectSQL(M);
    Check(Pos('select *', SQL) > 0, 'no columns chosen selects everything');
    Check(Pos('from CUSTOMERS C', SQL) > 0, 'and the table is aliased in FROM');
  finally
    M.Free;
  end;

  { Columns, output names, filters and sorts. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'CUSTOMERS');
    C := M.AddColumn('C', 'NAME');
    C.OutputName := 'Customer';
    C := M.AddColumn('C', 'BALANCE');
    C.Filter := '> 100';
    C.Sort := soDescending;
    SQL := BuildSelectSQL(M);
    Check(Pos('C.NAME as Customer', SQL) > 0, 'an output name becomes AS');
    Check(Pos('where C.BALANCE > 100', SQL) > 0, 'a filter becomes WHERE');
    Check(Pos('order by C.BALANCE desc', SQL) > 0, 'and a sort becomes ORDER BY');
    { Both columns, not just the last one to be added. }
    Check((Pos('C.NAME', SQL) > 0) and (Pos('C.BALANCE', SQL) > 0),
      'every chosen column is selected');
  finally
    M.Free;
  end;

  { Distinct. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'T');
    M.Distinct := True;
    Check(Pos('select distinct', BuildSelectSQL(M)) > 0, 'DISTINCT is emitted');
  finally
    M.Free;
  end;

  { Two tables and a join. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'CUSTOMERS');
    M.AddTable('', 'ORDERS');
    M.AddJoin(jkInner, 'C', 'ID', 'O', 'CUST_ID');
    SQL := BuildSelectSQL(M);
    Check(Pos('inner join ORDERS O on', SQL) > 0, 'a join becomes a JOIN clause');
    Check(Pos('C.ID = O.CUST_ID', SQL) > 0, 'with its condition');
    Check(IsFullyJoined(M), 'and the query is fully joined');
  finally
    M.Free;
  end;

  { Join kinds. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'A_TAB');
    M.AddTable('', 'B_TAB');
    M.AddJoin(jkLeft, 'AT', 'ID', 'BT', 'AID');
    Check(Pos('left join', BuildSelectSQL(M)) > 0, 'a left join says so');
  finally
    M.Free;
  end;

  { Join order - the part that produces SQL the server rejects if it is wrong.
    The joins are made in an order that does not match the table order, which
    is exactly what a user dragging lines around produces. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'AAA');
    M.AddTable('', 'BBB');
    M.AddTable('', 'CCC');
    { CCC joins to BBB, and BBB joins to AAA - but the CCC join is made
      first. Emitting the joins in the order they were made would name BBB
      before BBB is in the query. }
    M.AddJoin(jkInner, 'C', 'BID', 'B', 'ID');
    M.AddJoin(jkInner, 'B', 'AID', 'A', 'ID');
    Order := JoinOrder(M);
    try
      Check(Order.IndexOf('A') = 0, 'the first table added leads the FROM clause');
      Check(Order.IndexOf('B') < Order.IndexOf('C'),
        'and a table is ordered after the one it joins to');
    finally
      Order.Free;
    end;
    SQL := BuildSelectSQL(M);
    { Every alias must be introduced before it is used in an ON clause. }
    A := Pos('BBB B', SQL);
    B := Pos('B.AID', SQL);
    Check((A > 0) and (B > 0) and (A < B),
      'an alias is declared before any ON clause names it');
    Check(IsFullyJoined(M), 'three tables joined in a chain are fully joined');
  finally
    M.Free;
  end;

  { A table nobody joined. It still belongs in the query - the user put it
    there - but the SQL must say so rather than invent a condition. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'AAA');
    M.AddTable('', 'BBB');
    M.AddTable('', 'ZZZ');
    M.AddJoin(jkInner, 'A', 'ID', 'B', 'AID');
    Check(not IsFullyJoined(M), 'an unjoined table is reported, not hidden');
    SQL := BuildSelectSQL(M);
    Check(Pos('ZZZ Z', SQL) > 0, 'and still appears in the query');
    Check(Pos('on Z.', SQL) = 0, 'without a condition being made up for it');
  finally
    M.Free;
  end;

  { A table joined to two others: the second connection is a condition on the
    first join, not a second JOIN clause naming the same table twice. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'AAA');
    M.AddTable('', 'BBB');
    M.AddJoin(jkInner, 'A', 'ID1', 'B', 'ID1');
    M.AddJoin(jkInner, 'A', 'ID2', 'B', 'ID2');
    SQL := BuildSelectSQL(M);
    Check(Pos('and A.ID2 = B.ID2', SQL) > 0,
      'a second join between the same tables becomes an extra condition');
    A := 0;
    for B := 1 to Length(SQL) - 4 do
      if Copy(SQL, B, 4) = 'BBB ' then
        Inc(A);
    Check(A = 1, 'and the table is named once, not joined twice');
  finally
    M.Free;
  end;

  { Removing a table takes its columns and joins with it - a column naming an
    alias the FROM clause no longer declares is rejected by the server. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'AAA');
    M.AddTable('', 'BBB');
    M.AddColumn('A', 'X');
    M.AddColumn('B', 'Y');
    M.AddJoin(jkInner, 'A', 'ID', 'B', 'AID');
    M.RemoveTable('B');
    Check(M.TableCount = 1, 'removing a table removes it');
    Check(M.ColumnCount = 1, 'and the columns that named it');
    Check(M.JoinCount = 0, 'and the joins that named it');
    Check(Pos('B.', BuildSelectSQL(M)) = 0, 'so nothing refers to it any more');
  finally
    M.Free;
  end;

  { Schemas, reusing what the editors already know about them. }
  M := TQueryModel.Create;
  try
    M.AddTable('S_ALPHA', 'CUSTOMERS');
    Check(Pos('S_ALPHA.CUSTOMERS', BuildSelectSQL(M)) > 0,
      'a table in a schema is named with it');
  finally
    M.Free;
  end;

  { Quoting is off by default: Firebird folds unquoted names to upper case, and
    quoting everything makes a generated query case-sensitive unasked. }
  M := TQueryModel.Create;
  try
    M.AddTable('', 'CUSTOMERS');
    Check(Pos('"', BuildSelectSQL(M)) = 0, 'identifiers are unquoted by default');
    M.QuoteIdentifiers := True;
    M.AddColumn('C', 'Mixed Case');
    Check(Pos('"Mixed Case"', BuildSelectSQL(M)) > 0,
      'and quoted when asked, for a name that needs it');
  finally
    M.Free;
  end;
end;

procedure TestPrintDocument;
var
  Doc: TPrintDocument;
  Out_: TPrintedDocument;
  W: TStringList;
  Idx, HeaderPages: Integer;
begin
  { Wrapping. }
  W := WrapLine('the quick brown fox jumps over the lazy dog', 12);
  try
    Check(W.Count > 1, 'a long line wraps');
    for Idx := 0 to W.Count - 1 do
      if Length(W[Idx]) > 12 then
        Check(False, 'no wrapped line is wider than asked for');
    Check(W[0] = 'the quick', 'and breaks at a space rather than mid-word');
  finally
    W.Free;
  end;

  W := WrapLine('', 20);
  try
    { A blank between paragraphs has to survive, or the report closes up. }
    Check(W.Count = 1, 'an empty line stays one line');
  finally
    W.Free;
  end;

  W := WrapLine('SUPERCALIFRAGILISTICEXPIALIDOCIOUS', 10);
  try
    Check(W.Count > 1, 'a word longer than the line is cut rather than dropped');
    { Cutting it necessarily splits it, so the check is that the pieces put
      back together are the word - not that any one piece contains its end. }
    Check(StringReplace(W.Text, #10, '', [rfReplaceAll]) =
      'SUPERCALIFRAGILISTICEXPIALIDOCIOUS',
      'and every character of it survives across the cuts');
  finally
    W.Free;
  end;

  { Columns. }
  Check(FormatRow(['A', 'B'], [3, 3]) = 'A    B',
    'cells are padded into columns with a gap between');
  Check(FormatRow(['TOOLONG', 'B'], [3, 3]) = 'TOO  B',
    'a cell wider than its column is clipped, not allowed to shove the rest');

  { A report that fits on one page. }
  Doc := TPrintDocument.Create('Marathon Report');
  try
    Doc.AddTitle('CUSTOMERS');
    Doc.AddText('A short line.');
    Out_ := PaginateDocument(Doc, 30, 60);
    try
      Check(Out_.PageCount = 1, 'a short report is one page');
      Check(Pos('Marathon Report', PageText(Out_, 0)) > 0,
        'the running header carries the report title');
      Check(Pos('Page 1 of 1', PageText(Out_, 0)) > 0, 'and the footer numbers it');
      Check(Out_[0].Lines.Count = 30, 'the page is padded to its full height, ' +
        'so the footer sits at the bottom rather than under the text');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;

  { Enough text to need several pages. }
  Doc := TPrintDocument.Create('Long Report');
  try
    for Idx := 1 to 60 do
      Doc.AddText('line ' + IntToStr(Idx));
    Out_ := PaginateDocument(Doc, 20, 60);
    try
      Check(Out_.PageCount > 1, 'a long report runs to several pages');
      { The count in the footer is only knowable once the layout is done, which
        is why footers are added last. }
      Check(Pos('Page 1 of ' + IntToStr(Out_.PageCount), PageText(Out_, 0)) > 0,
        'every footer counts up to the real total');
      Check(Pos('Page ' + IntToStr(Out_.PageCount) + ' of ' + IntToStr(Out_.PageCount),
        PageText(Out_, Out_.PageCount - 1)) > 0, 'including the last');
      { Nothing may be lost at a page boundary - the failure a reader notices
        last and trusts least. }
      Check(Pos('line 1'#10, AllPages(Out_)) > 0, 'the first line is on paper');
      Check(Pos('line 60', AllPages(Out_)) > 0, 'and so is the last');
      for Idx := 1 to 60 do
        if Pos('line ' + IntToStr(Idx) + #10, AllPages(Out_)) = 0 then
        begin
          Check(False, 'line ' + IntToStr(Idx) + ' fell down a page break');
          Break;
        end;
      Check(Out_[0].Lines.Count = 20, 'each page is the height asked for');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;

  { A table crossing a page boundary. }
  Doc := TPrintDocument.Create('Table Report');
  try
    Doc.AddTableHeader(['COLUMN', 'TYPE']);
    for Idx := 1 to 40 do
      Doc.AddTableRow(['FIELD_' + IntToStr(Idx), 'varchar(10)']);
    Out_ := PaginateDocument(Doc, 20, 60);
    try
      Check(Out_.PageCount > 1, 'a long table runs to several pages');
      HeaderPages := 0;
      for Idx := 0 to Out_.PageCount - 1 do
        if Pos('COLUMN', PageText(Out_, Idx)) > 0 then
          Inc(HeaderPages);
      { The reason tables are a block kind rather than pre-formatted text:
        page four has to say which column is which. }
      Check(HeaderPages = Out_.PageCount,
        'the column header repeats on every page the table runs onto');
      for Idx := 1 to 40 do
        if Pos('FIELD_' + IntToStr(Idx), AllPages(Out_)) = 0 then
        begin
          Check(False, 'table row ' + IntToStr(Idx) + ' was lost');
          Break;
        end;
      Check(Pos('FIELD_1 ', PageText(Out_, 0)) > 0,
        'and the columns line up under it');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;

  { A table wider than the paper. Something has to give, and it must not be
    the page width - a line that overruns is simply lost off the edge. }
  Doc := TPrintDocument.Create('Wide');
  try
    Doc.AddTableHeader(['NAME', 'DESCRIPTION']);
    Doc.AddTableRow(['SHORT', StringOfChar('x', 200)]);
    Out_ := PaginateDocument(Doc, 30, 40);
    try
      Check(WidestLine(Out_) <= 40, 'a too-wide table is narrowed to the page');
      { Narrowed by taking it off the widest column, so the short one survives
        intact rather than every column being mangled equally. }
      Check(Pos('SHORT', AllPages(Out_)) > 0,
        'and the narrow column keeps its content');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;

  { A heading that would land at the very foot of a page goes with its
    content instead. }
  Doc := TPrintDocument.Create('Widow');
  try
    for Idx := 1 to 15 do
      Doc.AddText('filler ' + IntToStr(Idx));
    Doc.AddHeading('Indices');
    Doc.AddText('the index');
    Out_ := PaginateDocument(Doc, 20, 60);
    try
      for Idx := 0 to Out_.PageCount - 1 do
        if Pos('Indices', PageText(Out_, Idx)) > 0 then
          Check(Pos('the index', PageText(Out_, Idx)) > 0,
            'a heading is never left alone at the foot of a page');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;

  { Long text still fits the paper. }
  Doc := TPrintDocument.Create('Wrap');
  try
    Doc.AddText(StringOfChar('y', 300));
    Out_ := PaginateDocument(Doc, 30, 50);
    try
      Check(WidestLine(Out_) <= 50, 'no line is ever wider than the page');
    finally
      Out_.Free;
    end;
  finally
    Doc.Free;
  end;
end;

procedure TestSchemaNames;
var
  Schema, Name: String;
begin
  { A server without schemas must get no fragment at all. Naming
    RDB$SCHEMA_NAME on Firebird 5 is a hard error rather than a null, so an
    "always true" fragment would not do - it has to disappear. }
  Check(SchemaPredicate('', '', False) = '',
    'a server without schemas gets no predicate');
  Check(SchemaPredicate('a.', 'S_ALPHA', False) = '',
    'and none even when a schema is named');

  { With schemas but none named, an unqualified name means whatever the search
    path reaches. }
  Check(Pos('current_schema', SchemaPredicate('', '', True)) > 0,
    'no named schema falls back to CURRENT_SCHEMA');
  { The guard that stops an empty search path returning nothing at all rather
    than everything. }
  Check(Pos('current_schema is null', SchemaPredicate('', '', True)) > 0,
    'and guards against a null CURRENT_SCHEMA');

  { A named schema is asked for exactly - the whole point of naming one is to
    reach objects the search path does not. }
  Check(Pos('''S_ALPHA''', SchemaPredicate('', 'S_ALPHA', True)) > 0,
    'a named schema is matched exactly');
  Check(Pos('current_schema', SchemaPredicate('', 'S_ALPHA', True)) = 0,
    'and does not fall back to the search path');
  Check(Pos(' and (', SchemaPredicate('', 'S_ALPHA', True)) = 1,
    'the fragment appends to an existing WHERE');

  Check(Pos('a.rdb$schema_name', SchemaPredicate('a.', 'S_ALPHA', True)) > 0,
    'an alias is carried through');
  { Not every catalogue table calls it RDB$SCHEMA_NAME, and filtering on the
    wrong column quietly returns nothing. }
  Check(Pos('rdb$relation_schema_name', SchemaPredicate('',
    'rdb$relation_schema_name', 'S_ALPHA', True)) > 0,
    'and so is a column that is not the usual one');

  { Identifiers, as generated DDL spells them. }
  Check(QualifiedIdent('', 'CUSTOMERS', True, 3) = 'CUSTOMERS',
    'no schema leaves the name bare');
  Check(QualifiedIdent('S_ALPHA', 'CUSTOMERS', True, 3) = 'S_ALPHA.CUSTOMERS',
    'a schema qualifies it');
  { A name needing quotes must still get them once qualified, on both halves
    independently. }
  Check(QualifiedIdent('S_ALPHA', 'Mixed Case', True, 3) =
    'S_ALPHA."Mixed Case"', 'a name needing quotes still gets them');

  { Splitting what a user or a tree node hands over. }
  Check(not SplitSchemaName('CUSTOMERS', Schema, Name),
    'a bare name names no schema');
  Check((Schema = '') and (Name = 'CUSTOMERS'),
    'and comes back whole');
  Check(SplitSchemaName('S_ALPHA.CUSTOMERS', Schema, Name),
    'a qualified name splits');
  Check((Schema = 'S_ALPHA') and (Name = 'CUSTOMERS'), 'into its two parts');
  Check(SplitSchemaName('"My Schema"."My Table"', Schema, Name) and
    (Schema = 'My Schema') and (Name = 'My Table'),
    'quoted parts are unquoted');
  { The reason the scan skips quotes rather than taking the first dot. }
  Check(SplitSchemaName('"A.B"."C"', Schema, Name) and (Schema = 'A.B') and
    (Name = 'C'), 'a dot inside quotes is part of the name, not a separator');
  Check(not SplitSchemaName('.CUSTOMERS', Schema, Name),
    'a leading dot names no schema');

  Check(DisplaySchemaName('', 'CUSTOMERS') = 'CUSTOMERS',
    'an unqualified object is shown plainly');
  Check(DisplaySchemaName('S_ALPHA', 'CUSTOMERS') = 'S_ALPHA.CUSTOMERS',
    'and a schema one is shown qualified');
end;

procedure TestTableDesign;
var
  Was, Now_: TTableDesign;
  C: TColumnDesign;
  Total, Destructive: Integer;
  Script: String;
begin
  { Creating from nothing. }
  Now_ := ExistingTable;
  try
    Script := CreateTableScript(Now_);
    Check(ScriptHas(Script, 'create table CUSTOMERS'), 'a design becomes a CREATE TABLE');
    Check(ScriptHas(Script, 'CUST_ID integer not null'),
      'a not-null column carries its constraint');
    Check(ScriptHas(Script, 'BALANCE numeric(18,2) default 0'),
      'and a default comes before NOT NULL, as the syntax requires');
    Check(ScriptHas(Script, 'primary key (CUST_ID)'), 'the key is part of the statement');
  finally
    Now_.Free;
  end;

  { Nothing edited means nothing to run. That is the whole point of holding a
    design rather than applying as you go: an untouched table produces no
    script at all. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    CountChanges(Was, Now_, Total, Destructive);
    Check(Total = 0, 'an unedited design generates no statements');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Adding. A new column has no original name, which is what distinguishes it
    from one being renamed. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    Now_.AddColumn(Col('', 'EMAIL', 'varchar(100)'));
    CheckScript(Was, Now_, 'alter table CUSTOMERS add EMAIL varchar(100);', True,
      'a column with no original name is added');
    CountChanges(Was, Now_, Total, Destructive);
    Check((Total = 1) and (Destructive = 0), 'adding is one statement and loses nothing');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Dropping, and the reason the flag exists. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    Now_.DropColumn(1);
    CheckScript(Was, Now_, 'alter table CUSTOMERS drop NAME;', True, 'a removed column is dropped');
    CountChanges(Was, Now_, Total, Destructive);
    Check(Destructive = 1, 'and dropping is marked as losing data');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Renaming. The distinction OriginalName exists for: this must be one ALTER
    ... TO, not a drop and an add, because those differ by the data in the
    column. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(1);
    C.Name := 'FULL_NAME';
    Now_.SetColumn(1, C);
    CheckScript(Was, Now_, 'alter column NAME to FULL_NAME', True, 'a renamed column is renamed');
    CheckScript(Was, Now_, 'drop NAME', False, 'and is not dropped and re-added');
    CountChanges(Was, Now_, Total, Destructive);
    Check((Total = 1) and (Destructive = 0),
      'renaming is one statement and loses nothing');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Retyping, nullability and defaults, each on its own. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(1);
    C.DataType := 'varchar(60)';
    Now_.SetColumn(1, C);
    CheckScript(Was, Now_, 'alter column NAME type varchar(60)', True, 'a changed type is altered');
    CountChanges(Was, Now_, Total, Destructive);
    Check(Destructive = 1,
      'and retyping is flagged, since narrowing can truncate or fail');
  finally
    Was.Free;
    Now_.Free;
  end;

  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(1);
    C.NotNull := True;
    Now_.SetColumn(1, C);
    CheckScript(Was, Now_, 'alter column NAME set not null', True, 'nullability turned on');
    C := Now_.Column(0);
    C.NotNull := False;
    Now_.SetColumn(0, C);
    CheckScript(Was, Now_, 'alter column CUST_ID drop not null', True, 'and turned off');
  finally
    Was.Free;
    Now_.Free;
  end;

  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(2);
    C.DefaultValue := '';
    Now_.SetColumn(2, C);
    CheckScript(Was, Now_, 'alter column BALANCE drop default', True,
      'clearing a default drops it rather than setting it to nothing');
    C.DefaultValue := '100';
    Now_.SetColumn(2, C);
    CheckScript(Was, Now_, 'alter column BALANCE set default 100', True,
      'and changing it sets it');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Order. A rename has to precede everything that names the column, or the
    later statements address a name that no longer exists - the script would
    parse and then fail halfway, which is the failure mode a preview is meant
    to prevent. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(1);
    C.Name := 'FULL_NAME';
    C.DataType := 'varchar(60)';
    C.NotNull := True;
    Now_.SetColumn(1, C);
    Check(IndexOfKind(Was, Now_, tdRename) < IndexOfKind(Was, Now_, tdRetype),
      'a rename comes before the retype of the same column');
    Check(IndexOfKind(Was, Now_, tdRename) < IndexOfKind(Was, Now_, tdNullability),
      'and before its nullability change');
    CheckScript(Was, Now_, 'alter column FULL_NAME type varchar(60)', True,
      'and those later statements use the new name');
  finally
    Was.Free;
    Now_.Free;
  end;

  { The key is rebuilt last, because it names columns that earlier statements
    create or rename. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    Now_.AddColumn(Col('', 'REGION', 'char(2)', True));
    Now_.PrimaryKey.Add('REGION');
    Check(IndexOfKind(Was, Now_, tdAdd) < IndexOfKind(Was, Now_, tdPrimaryKey),
      'a column is added before the key that names it');
    CheckScript(Was, Now_, 'add primary key (CUST_ID, REGION)', True,
      'and the new key lists both columns in order');
  finally
    Was.Free;
    Now_.Free;
  end;

  { Column order is part of a compound key, so reordering one is a change even
    though the same columns are in it. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    Was.PrimaryKey.Clear;
    Was.PrimaryKey.Add('CUST_ID');
    Was.PrimaryKey.Add('NAME');
    Now_.PrimaryKey.Clear;
    Now_.PrimaryKey.Add('NAME');
    Now_.PrimaryKey.Add('CUST_ID');
    CountChanges(Was, Now_, Total, Destructive);
    Check(Total > 0, 'reordering the columns of a key is a change');
  finally
    Was.Free;
    Now_.Free;
  end;

  { A computed column defines itself with an expression and takes none of the
    other clauses - emitting "not null" after "computed by" is a syntax error. }
  Now_ := TTableDesign.Create('T');
  try
    Now_.AddColumn(Col('', 'A', 'integer'));
    Now_.AddColumn(Col('', 'B', 'integer'));
    Now_.AddColumn(Col('', 'TOTAL', 'integer', True, '0', 'A + B'));
    Script := CreateTableScript(Now_);
    Check(ScriptHas(Script, 'TOTAL computed by (A + B)'), 'a computed column uses its expression');
    Check(not ScriptHas(Script, 'TOTAL computed by (A + B) default'),
      'and carries no default or NOT NULL, which would not parse');
  finally
    Now_.Free;
  end;

  { Cloning has to copy, not alias: a designer holds the original next to what
    is being edited, and editing one must not change the other. }
  Was := ExistingTable;
  Now_ := Was.Clone;
  try
    C := Now_.Column(0);
    C.Name := 'CHANGED';
    Now_.SetColumn(0, C);
    Now_.PrimaryKey.Add('NAME');
    Check(Was.Column(0).Name = 'CUST_ID', 'editing a clone leaves the original alone');
    Check(Was.PrimaryKey.Count = 1, 'including its primary key');
  finally
    Was.Free;
    Now_.Free;
  end;
end;

begin
  Highlighter := TSynSQLSyn.Create(nil);
  try
    Highlighter.SQLDialect := sqlFirebird40;

    { Whatever kind a word nobody has ever heard of gets - that is what the
      injected keywords must NOT be. Read it rather than hard-coding the enum
      ordinal, which is SynEdit's business and could be renumbered. }
    IdentifierKind := KindOf('ZZ_NOT_A_KEYWORD_ZZ');
    WriteLn('Identifier token kind = ', IdentifierKind, ' (', AttrOf('ZZ_NOT_A_KEYWORD_ZZ'), ')');

    WriteLn('Before ApplyFirebirdKeywords:');
    for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
    begin
      Word := ExtraFirebirdKeywords[Idx];
      { If one of these ever starts arriving already-highlighted, Lazarus has
        gained an FB5/FB6 keyword set and this unit can start shrinking. }
      Check(KindOf(Word) = IdentifierKind,
        Word + ' is an unhighlighted identifier until injected');
    end;

    ApplyFirebirdKeywords(Highlighter);

    WriteLn('After ApplyFirebirdKeywords:');
    for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
    begin
      Word := ExtraFirebirdKeywords[Idx];
      Check(KindOf(Word) <> IdentifierKind,
        Word + ' is highlighted (' + AttrOf(Word) + ')');
    end;

    { Injection must not turn every identifier into a keyword, and must leave
      the words the dialect list already covers alone. }
    Check(KindOf('ZZ_NOT_A_KEYWORD_ZZ') = IdentifierKind,
      'an ordinary identifier is still an identifier');
    Check(AttrOf('SELECT') = 'Reserved word', 'SELECT is still a reserved word');
    Check(AttrOf('SKIP') = 'Reserved word', 'SKIP is still a reserved word');

    { The whole point of copying the styling across: these render the same as
      the reserved words they are, despite riding in on the table-name kind. }
    Check(Highlighter.TableNameAttri.Foreground = Highlighter.KeyAttri.Foreground,
      'injected keywords use the reserved-word foreground');
    Check(Highlighter.TableNameAttri.Style = Highlighter.KeyAttri.Style,
      'injected keywords use the reserved-word style');

    { Calling twice must be harmless - LoadOptions runs on every settings
      reload. }
    ApplyFirebirdKeywords(Highlighter);
    Check(KindOf('LOCKED') <> IdentifierKind, 'still highlighted after a second call');

    { The server's own list, which is what this now prefers. Inside this block
      because it needs the same live highlighter. }
    WriteLn('Keywords from the server:');
    TestServerKeywords;
  finally
    Highlighter.Free;
  end;

  { --- What a completion list should offer at a given point --- }
  WriteLn('Completion context:');

  CheckContext('select ', 8, ckAny, '', '', 'whitespace offers everything');
  CheckContext('select cus', 11, ckAny, 'cus', '',
    'a partly typed word is the filter');
  CheckContext('select c.', 10, ckQualified, '', 'c',
    'just past a dot asks for that object''s columns');
  CheckContext('select c.na', 12, ckQualified, 'na', 'c',
    'and filters them by what follows the dot');
  { A dot with nothing in front of it qualifies nothing - looking up the
    columns of '' would offer an empty list where keywords were wanted. }
  CheckContext('select .', 9, ckAny, '', '', 'a leading dot qualifies nothing');
  CheckContext('select RDB$DB', 14, ckAny, 'RDB$DB', '',
    'a Firebird name keeps its $ and is not cut short');
  { The caret can sit before the end of the line: only what is behind it
    counts, or typing in the middle of a word would offer the wrong list. }
  CheckContext('select abc from t', 11, ckAny, 'abc', '',
    'only the text behind the caret is read');

  WriteLn('Alias resolution:');
  CheckAlias('select * from CUSTOMERS c', 'c', 'CUSTOMERS', 'a FROM alias');
  CheckAlias('select * from CUSTOMERS as c', 'c', 'CUSTOMERS', 'an AS alias');
  CheckAlias('select * from CUSTOMERS c join ORDERS o on o.ID = c.ID', 'o',
    'ORDERS', 'a JOIN alias');
  CheckAlias('select * from CUSTOMERS c,ORDERS o', 'o', 'ORDERS',
    'an alias with no space after the comma');
  { An unaliased table typed in full has to resolve to itself, or qualifying a
    column with the table name would offer nothing. }
  CheckAlias('select * from CUSTOMERS', 'CUSTOMERS', 'CUSTOMERS',
    'a table named in full');
  CheckAlias('select * from CUSTOMERS c', 'zz', 'zz',
    'an unknown alias is left alone');

  { --- What an object tree filter shows --- }
  WriteLn('Tree filter:');

  CheckFilter('', 'CUSTOMERS', 'Tables', True, 'an empty filter shows everything');
  CheckFilter('   ', 'CUSTOMERS', 'Tables', True, 'and so does whitespace');
  CheckFilter('cust', 'CUSTOMERS', 'Tables', True, 'a fragment matches by name');
  CheckFilter('cust', 'ORDERS', 'Tables', False, 'and excludes what it does not match');
  { Firebird folds unquoted names to upper case and nobody types them that way. }
  CheckFilter('CUST', 'customers', 'Tables', True, 'matching ignores case');

  CheckFilter('table:cust', 'CUSTOMERS', 'Tables', True, 'a type and a fragment');
  CheckFilter('table:cust', 'CUSTOMERS', 'Views', False,
    'the type has to match too');
  CheckFilter('table:', 'ANYTHING', 'Tables', True, 'a type on its own shows that type');
  CheckFilter('table:', 'ANYTHING', 'Views', False, 'and hides the others');

  { The group captions are Marathon's, and the user should not have to know
    their exact wording. }
  CheckFilter('procedure:x', 'XYZ', 'Stored Procedures', True,
    'a singular type finds a plural group');
  CheckFilter('proc:x', 'XYZ', 'Stored Procedures', True, 'an abbreviation does too');
  CheckFilter('sp:x', 'XYZ', 'Stored Procedures', True,
    'and one that shares no letters with the caption');

  CheckFilter('"CUSTOMERS"', 'CUSTOMERS', 'Tables', True, 'a quoted name matches exactly');
  CheckFilter('"CUST"', 'CUSTOMERS', 'Tables', False,
    'and a quoted fragment does not match a longer name');
  CheckFilter('table:"CUSTOMERS"', 'CUSTOMERS', 'Tables', True,
    'a type and a quoted name together');

  { A colon inside a quoted name is part of the name, not a type prefix. }
  CheckFilter('"A:B"', 'A:B', 'Tables', True, 'a colon inside quotes is not a type');

  { --- Finding a command by typing part of its name --- }
  WriteLn('Command palette:');

  Check(CommandDisplayName('&New Connection...') = 'New Connection',
    'accelerators and trailing dots are not part of the name');
  Check(CommandDisplayName('E&xtract') = 'Extract',
    'an ampersand inside a word goes too');

  CheckCommand('', 'New Connection', 'Project', True, 'an empty query lists everything');
  CheckCommand('new', 'New Connection', 'Project', True, 'one word matches');
  CheckCommand('conn', '&New Connection...', 'Project', True,
    'and matches through the accelerator markers');
  CheckCommand('new conn', 'New Connection', 'Project', True, 'two words in order');
  { Nobody recalls the exact wording, so word order must not matter. }
  CheckCommand('conn new', 'New Connection', 'Project', True, 'or out of order');
  CheckCommand('new xyz', 'New Connection', 'Project', False,
    'every word has to appear');
  CheckCommand('NEW', 'new connection', 'Project', True, 'matching ignores case');
  { The category is searchable too, so a half-remembered menu name finds it. }
  CheckCommand('tools extract', 'Metadata Extract', 'Tools', True,
    'a word may come from the category');
  CheckCommand('script', 'Metadata Extract', 'Tools', False,
    'and an unrelated word still excludes it');

  { Ordering: what was typed at the start of a name is almost certainly meant. }
  Check(CommandRank('new', 'New Connection', 'Project') >
        CommandRank('new', 'Add New Server', 'Project'),
    'a name starting with the query outranks one merely containing it');
  Check(CommandRank('new', 'Add New Server', 'Project') >
        CommandRank('tools new', 'Something Else', 'Tools New'),
    'and containing it outranks matching only through the category');
  Check(CommandRank('zzz', 'New Connection', 'Project') = 0,
    'no match ranks zero');

  WriteLn('Table design:');
  TestTableDesign;

  WriteLn('Schema-qualified names:');
  TestSchemaNames;

  WriteLn('Print pagination:');
  TestPrintDocument;

  WriteLn('Query builder:');
  TestQueryModel;

  WriteLn('SQL trace:');
  TestSQLTrace;

  WriteLn('Key bindings:');
  TestKeyBindings;

  WriteLn('Code templates:');
  TestCodeTemplates;

  WriteLn('Icon scaling:');
  TestIconScaling;

  WriteLn('Schema diagram:');
  TestSchemaDiagram;

  WriteLn('Query plan:');
  TestPlanParser;

  WriteLn('Data grid edits:');
  TestRowEdits;

  WriteLn('Values written into statements:');
  TestFieldLiterals;

  WriteLn('Session admin actions:');
  TestSessionAdmin;

  WriteLn('Compile script rewriting:');
  TestCompileScript;

  WriteLn('Blob viewing:');
  TestBlobText;

  WriteLn('Blob JSON view:');
  TestBlobJSON;

  WriteLn('Memory usage:');
  TestMemoryUsage;

  WriteLn('System privileges:');
  TestSystemPrivileges;

  WriteLn('CSV import:');
  TestCsvImport;

  WriteLn('Server metrics:');
  TestServerMetrics;

  WriteLn('Result grid columns:');
  TestGridLayout;

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: Firebird 5/6 keyword highlighting works.');
end.
