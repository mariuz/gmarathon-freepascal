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
  Interfaces, SysUtils, Classes, SynHighlighterSQL, FirebirdKeywords, SQLCompletion, TreeFilter, CommandPalette, TableDesign, SchemaNames;

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

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: Firebird 5/6 keyword highlighting works.');
end.
