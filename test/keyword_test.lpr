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
  Interfaces, SysUtils, Classes, SynHighlighterSQL, FirebirdKeywords, SQLCompletion, TreeFilter, CommandPalette, TableDesign, SchemaNames, PrintDocument, QueryModel, SQLTraceFormat, KeyBindings, Menus, CodeTemplates, IconScaling, SchemaDiagram, PlanParser, RowEdits;

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

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: Firebird 5/6 keyword highlighting works.');
end.
