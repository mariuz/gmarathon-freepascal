{******************************************************************}
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}

unit SchemaCompare;

{$MODE Delphi}

{ Compares the metadata of two databases and writes a script that moves the
  target towards the source.

  What it does, and what it deliberately does not:

  - Objects in the source and not the target are emitted as CREATE, in an order
    that respects the obvious dependencies (domains and generators before the
    tables that use them, tables before the views and routines over them).
  - Objects in the target and not the source are emitted as DROP, but **always
    commented out**. Dropping is the one direction that destroys data, and a
    generated script should not be able to do that by being run without being
    read.
  - Objects in both whose DDL differs are reported. Where Firebird has a form
    that redefines the whole object - a view, trigger, procedure, PSQL function
    or package - the replacement is emitted and is safe to run. A table that
    differs is reported as a comment only: the difference could be a column
    added, dropped, retyped or renamed, and guessing wrong writes a migration
    that silently loses a column.

  The comparison is by extracted DDL text, so it sees anything DDLExtractor
  renders and nothing it does not. That is a real limit worth knowing: two
  objects that differ only in something the extractor omits will compare equal.

  LCL-free so test/ibx_smoke_test.lpr can run a comparison between two real
  databases. }

interface

uses SysUtils, Classes, ScriptAs, MarathonProjectCacheTypes;

type
  { What a comparison found, so a caller can report a summary without parsing
    the script back. }
  TSchemaDifferences = record
    ToCreate: Integer;
    ToDrop: Integer;
    Changed: Integer;
    { Objects that differ but cannot be migrated automatically - tables, in
      practice - which the script reports rather than rewrites. }
    NeedingAttention: Integer;
  end;

{ Writes a migration script taking Target towards Source. Differences, if
  passed, receives the counts. }
function CompareSchemas(const Source, Target: TScriptAsContext;
  out Differences: TSchemaDifferences): String;

implementation

uses IBDatabase, IBQuery, DDLExtractor;

type
  TComparedKind = record
    Caption: String;
    CacheType: TGSSCacheType;
    ListSQL: String;
    { True when Firebird can redefine the object wholesale, so a difference can
      be migrated by emitting the replacement. }
    Replaceable: Boolean;
  end;

  TComparedKinds = array of TComparedKind;

{ The kinds to compare, ordered so that a script run top to bottom creates
  things before whatever depends on them.

  HasPackages says whether this server has RDB$PACKAGE_NAME - Firebird 3 and
  later. Where it does, a routine that belongs to a package is skipped: it is
  created by its package's DDL, and listing it here would emit it twice.

  The system-flag test is enough to keep the catalogue's own objects out, and
  it also covers the triggers Firebird writes for CHECK constraints: those
  carry RDB$SYSTEM_FLAG = 4 (verified on Firebird 6), so no separate
  RDB$CHECK_CONSTRAINTS exclusion is needed. Domains are the exception - the
  implicit per-column ones are flagged 0, like a user's, and are told apart
  only by their RDB$ name. }
function ComparedKinds(HasPackages: Boolean): TComparedKinds;
const
  NotSystem = '((rdb$system_flag = 0) or (rdb$system_flag is null))';
var
  NotPackaged: String;
begin
  if HasPackages then
    NotPackaged := ' and rdb$package_name is null'
  else
    NotPackaged := '';

  SetLength(Result, 8);

  Result[0].Caption := 'Domains';
  Result[0].CacheType := ctDomain;
  Result[0].ListSQL := 'select rdb$field_name from rdb$fields where ' +
    NotSystem + ' and (rdb$field_name not starting with ''RDB$'') order by 1';
  Result[0].Replaceable := False;

  Result[1].Caption := 'Generators';
  Result[1].CacheType := ctGenerator;
  Result[1].ListSQL := 'select rdb$generator_name from rdb$generators where ' +
    NotSystem + ' order by 1';
  Result[1].Replaceable := False;

  Result[2].Caption := 'Exceptions';
  Result[2].CacheType := ctException;
  Result[2].ListSQL := 'select rdb$exception_name from rdb$exceptions where ' +
    NotSystem + ' order by 1';
  Result[2].Replaceable := False;

  Result[3].Caption := 'Tables';
  Result[3].CacheType := ctTable;
  Result[3].ListSQL := 'select rdb$relation_name from rdb$relations where ' +
    NotSystem + ' and rdb$view_source is null order by 1';
  Result[3].Replaceable := False;

  Result[4].Caption := 'Views';
  Result[4].CacheType := ctView;
  Result[4].ListSQL := 'select rdb$relation_name from rdb$relations where ' +
    NotSystem + ' and rdb$view_source is not null order by 1';
  Result[4].Replaceable := True;

  Result[5].Caption := 'Stored procedures';
  Result[5].CacheType := ctSP;
  Result[5].ListSQL := 'select rdb$procedure_name from rdb$procedures where ' +
    NotSystem + NotPackaged + ' order by 1';
  Result[5].Replaceable := True;

  Result[6].Caption := 'Functions';
  Result[6].CacheType := ctUDF;
  Result[6].ListSQL := 'select rdb$function_name from rdb$functions where ' +
    NotSystem + NotPackaged + ' order by 1';
  Result[6].Replaceable := True;

  Result[7].Caption := 'Triggers';
  Result[7].CacheType := ctTrigger;
  Result[7].ListSQL := 'select rdb$trigger_name from rdb$triggers where ' +
    NotSystem + ' and rdb$trigger_source is not null order by 1';
  Result[7].Replaceable := True;
end;

function ObjectNames(const Ctx: TScriptAsContext; const SQL: String): TStringList;
var
  Q: TIBQuery;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := Ctx.Database;
    Q.Transaction := Ctx.Transaction;
    if Assigned(Q.Transaction) and not Q.Transaction.Active then
      Q.Transaction.StartTransaction;
    Q.SQL.Text := SQL;
    Q.Open;
    while not Q.EOF do
    begin
      Result.Add(Trim(Q.Fields[0].AsString));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

{ Reorders Names so that anything depending on another entry comes after it.

  Alphabetical order is no guide: a view V_AAA selecting from V_ZZZ sorts first,
  and the script then fails with "Table unknown". RDB$DEPENDENCIES is consulted
  only for entries within this list - anything depended on that is not in it
  belongs to an earlier kind and already exists by the time this section runs.

  A cycle leaves the entries it involves in the order they arrived, which is no
  worse than not ordering at all. Firebird permits mutually recursive procedures,
  so this is reachable rather than theoretical. }
procedure OrderByDependency(const Ctx: TScriptAsContext; Names: TStringList);
var
  Q: TIBQuery;
  Pending, Ordered, Depends: TStringList;
  InList, Dependent, DependedOn: String;
  Idx, Pick, D: Integer;
  Blocked: Boolean;
begin
  if Names.Count < 2 then
    Exit;

  InList := '';
  for Idx := 0 to Names.Count - 1 do
  begin
    if InList <> '' then
      InList := InList + ', ';
    InList := InList + AnsiQuotedStr(Names[Idx], '''');
  end;

  Depends := TStringList.Create;
  Pending := TStringList.Create;
  Ordered := TStringList.Create;
  try
    Q := TIBQuery.Create(nil);
    try
      Q.Database := Ctx.Database;
      Q.Transaction := Ctx.Transaction;
      if Assigned(Q.Transaction) and not Q.Transaction.Active then
        Q.Transaction.StartTransaction;
      Q.SQL.Text :=
        'select distinct rdb$dependent_name, rdb$depended_on_name ' +
        'from rdb$dependencies where rdb$dependent_name in (' + InList + ') ' +
        'and rdb$depended_on_name in (' + InList + ')';
      Q.Open;
      while not Q.EOF do
      begin
        Dependent := Trim(Q.Fields[0].AsString);
        DependedOn := Trim(Q.Fields[1].AsString);
        { An object listing itself is not an ordering constraint - a recursive
          view or procedure would otherwise never become pickable. }
        if not SameText(Dependent, DependedOn) then
          Depends.Add(Dependent + #1 + DependedOn);
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;

    if Depends.Count = 0 then
      Exit;

    Pending.Assign(Names);
    while Pending.Count > 0 do
    begin
      Pick := -1;
      for Idx := 0 to Pending.Count - 1 do
      begin
        Blocked := False;
        for D := 0 to Depends.Count - 1 do
          if SameText(Copy(Depends[D], 1, Pos(#1, Depends[D]) - 1), Pending[Idx]) and
             (Pending.IndexOf(Copy(Depends[D], Pos(#1, Depends[D]) + 1, MaxInt)) >= 0) then
          begin
            Blocked := True;
            Break;
          end;
        if not Blocked then
        begin
          Pick := Idx;
          Break;
        end;
      end;
      if Pick < 0 then
      begin
        { A cycle: take the rest as they are rather than looping forever. }
        for Idx := 0 to Pending.Count - 1 do
          Ordered.Add(Pending[Idx]);
        Break;
      end;
      Ordered.Add(Pending[Pick]);
      Pending.Delete(Pick);
    end;
    Names.Assign(Ordered);
  finally
    Ordered.Free;
    Pending.Free;
    Depends.Free;
  end;
end;

{ Removes the name from a constraint Firebird named for itself.

  A table's extracted DDL carries its CHECK constraints in full, including the
  name - and an unnamed CHECK is INTEG_3 in one database and INTEG_5 in another
  holding the identical schema, because the engine numbers them per database as
  it goes. Comparing that text reported every such table as differing. Dropping
  the name leaves 'add check (...)', which is both what the two schemas actually
  have in common and a statement Firebird accepts, naming it itself. }
function WithoutGeneratedConstraintNames(const DDL: String): String;
var
  Idx, Stop: Integer;
  Upper: String;
begin
  Result := DDL;
  repeat
    Upper := UpperCase(Result);
    Idx := Pos('CONSTRAINT INTEG_', Upper);
    if Idx = 0 then
      Break;
    { Past the digits, and past the space that follows them. }
    Stop := Idx + Length('CONSTRAINT INTEG_');
    while (Stop <= Length(Result)) and (Result[Stop] >= '0') and (Result[Stop] <= '9') do
      Inc(Stop);
    while (Stop <= Length(Result)) and (Result[Stop] = ' ') do
      Inc(Stop);
    Delete(Result, Idx, Stop - Idx);
  until False;
end;

{ The whole DDL for one object, which is what the comparison is made on. }
function ObjectDDL(const Ctx: TScriptAsContext; const Name: String;
  CacheType: TGSSCacheType): String;
begin
  Result := WithoutGeneratedConstraintNames(ScriptAsCreate(Ctx, Name, CacheType));
end;

{ The index name out of a CREATE INDEX statement, for writing the DROP that
  removes it. Returns an empty string for anything that is not one, so an
  unrecognised statement is skipped rather than turned into a wrong DROP. }
function IndexNameOf(const Statement: String): String;
var
  Words: TStringList;
  Idx: Integer;
begin
  Result := '';
  Words := TStringList.Create;
  try
    Words.Delimiter := ' ';
    Words.DelimitedText := StringReplace(Trim(Statement), #9, ' ', [rfReplaceAll]);
    for Idx := 0 to Words.Count - 2 do
      if SameText(Words[Idx], 'index') then
      begin
        Result := Words[Idx + 1];
        Break;
      end;
  finally
    Words.Free;
  end;
end;

{ The index statements of one table, one per entry, as the extractor renders
  them. Splitting the block up is what makes a useful comparison possible: both
  databases are rendered by the same code, so a statement present in one list
  and not the other is exactly one index's worth of difference, and only those
  need be emitted - re-running the whole block would fail on the indexes that
  are already there. }
function TableIndexStatements(const Ctx: TScriptAsContext; const TableName: String): TStringList;
var
  Extractor: TDDLExtractor;
  Block, Statement: String;
  Parts, ConstraintIndexes: TStringList;
  Q: TIBQuery;
  Idx: Integer;
begin
  Result := TStringList.Create;
  Extractor := TDDLExtractor.Create(nil);
  Parts := TStringList.Create;
  ConstraintIndexes := TStringList.Create;
  try
    { The indexes a constraint owns are compared as constraints, not here.
      ExtractTableIDX already leaves out those behind PRIMARY KEY and FOREIGN
      KEY but not the ones behind UNIQUE, and their names are generated - so
      the same unique constraint appears as UQ_NOTE in one database and
      INTEG_512 in the other, and comparing the index text reported a
      difference where there was none. }
    Q := TIBQuery.Create(nil);
    try
      Q.Database := Ctx.Database;
      Q.Transaction := Ctx.Transaction;
      if Assigned(Q.Transaction) and not Q.Transaction.Active then
        Q.Transaction.StartTransaction;
      Q.SQL.Text := 'select rdb$index_name from rdb$relation_constraints ' +
        'where rdb$relation_name = ' + AnsiQuotedStr(TableName, '''') +
        ' and rdb$index_name is not null';
      Q.Open;
      while not Q.EOF do
      begin
        ConstraintIndexes.Add(UpperCase(Trim(Q.Fields[0].AsString)));
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;

    Extractor.Database := Ctx.Database;
    Extractor.Transaction := Ctx.Transaction;
    Extractor.SQLDialect := Ctx.Dialect;
    Extractor.IsInterbase6 := Ctx.IsIB6;
    Block := Extractor.Extract(ddlTable, ddlstIndex, TableName);
    Parts.Text := StringReplace(Block, ';', ';' + #13#10, [rfReplaceAll]);
    for Idx := 0 to Parts.Count - 1 do
    begin
      Statement := Trim(Parts[Idx]);
      if (Statement <> '') and
         (ConstraintIndexes.IndexOf(UpperCase(IndexNameOf(Statement))) < 0) then
        Result.Add(Statement);
    end;
  finally
    ConstraintIndexes.Free;
    Parts.Free;
    Extractor.Free;
  end;
end;

{ The columns of an index, in key order, as a bracketed list.  }
function IndexColumnList(const Ctx: TScriptAsContext; const IndexName: String): String;
var
  Q: TIBQuery;
begin
  Result := '';
  Q := TIBQuery.Create(nil);
  try
    Q.Database := Ctx.Database;
    Q.Transaction := Ctx.Transaction;
    if Assigned(Q.Transaction) and not Q.Transaction.Active then
      Q.Transaction.StartTransaction;
    Q.SQL.Text := 'select rdb$field_name from rdb$index_segments ' +
      'where rdb$index_name = ' + AnsiQuotedStr(IndexName, '''') +
      ' order by rdb$field_position';
    Q.Open;
    while not Q.EOF do
    begin
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + Trim(Q.Fields[0].AsString);
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
  Result := '(' + Result + ')';
end;

{ True for a name Firebird made up because the user did not supply one. Those
  differ between databases holding identical schemas - a primary key is
  INTEG_249 in one and INTEG_512 in another - which is precisely why
  constraints cannot be compared by name. }
function IsGeneratedConstraintName(const Name: String): Boolean;
begin
  Result := Copy(UpperCase(Trim(Name)), 1, 6) = 'INTEG_';
end;

{ The key constraints of one table, rendered without their names so that two
  databases describing the same constraint produce the same text. Statements
  and Names are filled in step: Statements[i] is what would add it, Names[i] is
  what it is actually called, which is what a DROP needs.

  CHECK constraints are left out. Their text lives in the trigger the engine
  writes for them rather than in the constraint, and comparing that is a
  different problem from comparing a key. }
procedure TableConstraints(const Ctx: TScriptAsContext; const TableName: String;
  Statements, Names, Kinds: TStringList);
var
  Q: TIBQuery;
  Ident, Kind, Clause, Rule: String;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := Ctx.Database;
    Q.Transaction := Ctx.Transaction;
    if Assigned(Q.Transaction) and not Q.Transaction.Active then
      Q.Transaction.StartTransaction;
    Q.SQL.Text :=
      'select rc.rdb$constraint_name, rc.rdb$constraint_type, rc.rdb$index_name, ' +
      'ref.rdb$update_rule, ref.rdb$delete_rule, ' +
      'uq.rdb$relation_name as uq_relation, uq.rdb$index_name as uq_index ' +
      'from rdb$relation_constraints rc ' +
      'left join rdb$ref_constraints ref on ref.rdb$constraint_name = rc.rdb$constraint_name ' +
      'left join rdb$relation_constraints uq on uq.rdb$constraint_name = ref.rdb$const_name_uq ' +
      'where rc.rdb$relation_name = ' + AnsiQuotedStr(TableName, '''') + ' ' +
      'and rc.rdb$constraint_type in (''PRIMARY KEY'', ''UNIQUE'', ''FOREIGN KEY'') ' +
      'order by rc.rdb$constraint_type, rc.rdb$constraint_name';
    Q.Open;
    while not Q.EOF do
    begin
      Kind := Trim(Q.FieldByName('rdb$constraint_type').AsString);
      Ident := Trim(Q.FieldByName('rdb$index_name').AsString);
      Clause := '';
      if Kind = 'PRIMARY KEY' then
        Clause := 'primary key ' + IndexColumnList(Ctx, Ident)
      else if Kind = 'UNIQUE' then
        Clause := 'unique ' + IndexColumnList(Ctx, Ident)
      else if Kind = 'FOREIGN KEY' then
      begin
        Clause := 'foreign key ' + IndexColumnList(Ctx, Ident) +
          ' references ' + Trim(Q.FieldByName('uq_relation').AsString) + ' ' +
          IndexColumnList(Ctx, Trim(Q.FieldByName('uq_index').AsString));
        { RESTRICT is what Firebird stores when the user wrote no rule at all,
          so writing it out would make a schema differ from itself depending on
          how it was typed. }
        Rule := Trim(Q.FieldByName('rdb$update_rule').AsString);
        if (Rule <> '') and (Rule <> 'RESTRICT') then
          Clause := Clause + ' on update ' + LowerCase(Rule);
        Rule := Trim(Q.FieldByName('rdb$delete_rule').AsString);
        if (Rule <> '') and (Rule <> 'RESTRICT') then
          Clause := Clause + ' on delete ' + LowerCase(Rule);
      end;
      if Clause <> '' then
      begin
        Statements.Add('alter table ' + Trim(TableName) + ' add ' + Clause + ';');
        Names.Add(Trim(Q.FieldByName('rdb$constraint_name').AsString));
        Kinds.Add(Kind);
      end;
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function CompareSchemas(const Source, Target: TScriptAsContext;
  out Differences: TSchemaDifferences): String;
var
  Script: TStringList;
  SourceKinds, TargetKinds: TComparedKinds;
  K, Idx: Integer;
  InSource, InTarget: TStringList;
  SourceDDL, TargetDDL, IndexName: String;
  SourceIdx, TargetIdx: TStringList;
  SrcCon, SrcName, SrcKind, TgtCon, TgtName, TgtKind: TStringList;
  I2: Integer;
  Header, TableHeader: Boolean;
  AllTables, ToCreate: TStringList;

  procedure Section(const Caption: String; var Emitted: Boolean);
  begin
    if not Emitted then
    begin
      Script.Add('');
      Script.Add('/* ---- ' + Caption + ' ---- */');
      Emitted := True;
    end;
  end;

begin
  Differences.ToCreate := 0;
  Differences.ToDrop := 0;
  Differences.Changed := 0;
  Differences.NeedingAttention := 0;

  Script := TStringList.Create;
  try
    Script.Add('/* Migration script generated by comparing two databases.');
    Script.Add('');
    Script.Add('   Read it before running it. DROP statements are commented out');
    Script.Add('   deliberately - dropping is the only direction that destroys');
    Script.Add('   data, and a generated script should not be able to do that by');
    Script.Add('   being run without being read. Tables that differ are reported');
    Script.Add('   rather than altered, because the difference could be a column');
    Script.Add('   added, dropped, retyped or renamed and guessing wrong loses');
    Script.Add('   data. */');

    { Listed with each side's own capabilities: the two databases can be on
      different servers, and asking an older one for RDB$PACKAGE_NAME is an
      error rather than a null. }
    SourceKinds := ComparedKinds(Source.EngineMajor >= 3);
    TargetKinds := ComparedKinds(Target.EngineMajor >= 3);
    for K := 0 to High(SourceKinds) do
    begin
      Header := False;
      InSource := ObjectNames(Source, SourceKinds[K].ListSQL);
      InTarget := ObjectNames(Target, TargetKinds[K].ListSQL);
      try
        { Present in the source only - create it. Gathered first and then
          ordered by dependency, because these are the ones being created from
          nothing: a view over another view, or a procedure calling one, has to
          come second, and the alphabetical order the list arrives in is no
          guide. Objects already in the target need no such ordering. }
        ToCreate := TStringList.Create;
        try
          for Idx := 0 to InSource.Count - 1 do
            if InTarget.IndexOf(InSource[Idx]) < 0 then
              ToCreate.Add(InSource[Idx]);
          OrderByDependency(Source, ToCreate);
          for Idx := 0 to ToCreate.Count - 1 do
          begin
            Section(SourceKinds[K].Caption, Header);
            Script.Add('');
            Script.Add('/* missing from target */');
            Script.Add(Trim(ObjectDDL(Source, ToCreate[Idx], SourceKinds[K].CacheType)));
            Inc(Differences.ToCreate);
          end;
        finally
          ToCreate.Free;
        end;

        { Present in both - compare, and replace where that is safe. }
        for Idx := 0 to InSource.Count - 1 do
          if InTarget.IndexOf(InSource[Idx]) >= 0 then
          begin
            SourceDDL := Trim(ObjectDDL(Source, InSource[Idx], SourceKinds[K].CacheType));
            TargetDDL := Trim(ObjectDDL(Target, InSource[Idx], SourceKinds[K].CacheType));
            if SourceDDL <> TargetDDL then
            begin
              Section(SourceKinds[K].Caption, Header);
              Script.Add('');
              if SourceKinds[K].Replaceable then
              begin
                { Compared on the CREATE form, but emitted as the ALTER one.
                  The object already exists in the target, so a CREATE would
                  fail on the name; ScriptAsAlter renders each replaceable kind
                  in the form Firebird accepts against an existing object -
                  ALTER VIEW, ALTER TRIGGER, ALTER PROCEDURE, CREATE OR ALTER
                  for a PSQL function or package. }
                Script.Add('/* differs - redefining */');
                Script.Add(Trim(ScriptAsAlter(Source, InSource[Idx],
                  SourceKinds[K].CacheType)));
                Inc(Differences.Changed);
              end
              else
              begin
                Script.Add('/* ' + InSource[Idx] + ' differs and cannot be migrated');
                Script.Add('   automatically. Source definition, for reference:');
                Script.Add('');
                Script.Add(SourceDDL);
                Script.Add('*/');
                Inc(Differences.NeedingAttention);
              end;
            end;

          end;

        { Present in the target only - drop it, commented out. }
        for Idx := 0 to InTarget.Count - 1 do
          if InSource.IndexOf(InTarget[Idx]) < 0 then
          begin
            Section(SourceKinds[K].Caption, Header);
            Script.Add('');
            Script.Add('/* only in target - uncomment to remove */');
            Script.Add('-- ' + Trim(ScriptAsDrop(Target, InTarget[Idx], SourceKinds[K].CacheType)));
            Inc(Differences.ToDrop);
          end;
      finally
        InTarget.Free;
        InSource.Free;
      end;
    end;

    { Keys and indexes, in a pass of their own once every table exists.

      They cannot go with the tables: a table missing from the target is
      created from its column DDL alone, so it arrives without them, and a
      foreign key may point at a table that is created later in the script.
      Running the whole pass at the end settles both - by then every table is
      there, whether it was just created or was already present. }
    TableHeader := False;
    AllTables := ObjectNames(Source, SourceKinds[3].ListSQL);
    try
      for Idx := 0 to AllTables.Count - 1 do
      begin
        SourceIdx := TableIndexStatements(Source, AllTables[Idx]);
        TargetIdx := TableIndexStatements(Target, AllTables[Idx]);
        SrcCon := TStringList.Create;
        SrcName := TStringList.Create;
        SrcKind := TStringList.Create;
        TgtCon := TStringList.Create;
        TgtName := TStringList.Create;
        TgtKind := TStringList.Create;
        try
          TableConstraints(Source, AllTables[Idx], SrcCon, SrcName, SrcKind);
          TableConstraints(Target, AllTables[Idx], TgtCon, TgtName, TgtKind);

          for I2 := 0 to SrcCon.Count - 1 do
            if TgtCon.IndexOf(SrcCon[I2]) < 0 then
            begin
              Section('Table keys and indexes', TableHeader);
              Script.Add('');
              { A table can have only one primary key, so where the target
                already has a different one this cannot simply be added - the
                old one has to go first, and which of the two is right is not
                something to decide here. }
              if (SrcKind[I2] = 'PRIMARY KEY') and (TgtKind.IndexOf('PRIMARY KEY') >= 0) then
              begin
                Script.Add('/* ' + AllTables[Idx] + ' has a different primary key.');
                Script.Add('   Adding this one needs the existing one dropped first:');
                Script.Add('   ' + SrcCon[I2]);
                Script.Add('*/');
                Inc(Differences.NeedingAttention);
              end
              else
              begin
                Script.Add('/* constraint missing from target */');
                Script.Add(SrcCon[I2]);
                Inc(Differences.ToCreate);
              end;
            end;

          for I2 := 0 to TgtCon.Count - 1 do
            if SrcCon.IndexOf(TgtCon[I2]) < 0 then
            begin
              Section('Table keys and indexes', TableHeader);
              Script.Add('');
              Script.Add('/* constraint only in target - uncomment to remove */');
              Script.Add('-- alter table ' + Trim(AllTables[Idx]) +
                ' drop constraint ' + TgtName[I2] + ';');
              Inc(Differences.ToDrop);
            end;

          for I2 := 0 to SourceIdx.Count - 1 do
            if TargetIdx.IndexOf(SourceIdx[I2]) < 0 then
            begin
              Section('Table keys and indexes', TableHeader);
              Script.Add('');
              Script.Add('/* index missing from target */');
              Script.Add(SourceIdx[I2]);
              Inc(Differences.ToCreate);
            end;

          for I2 := 0 to TargetIdx.Count - 1 do
            if SourceIdx.IndexOf(TargetIdx[I2]) < 0 then
            begin
              IndexName := IndexNameOf(TargetIdx[I2]);
              if IndexName <> '' then
              begin
                Section('Table keys and indexes', TableHeader);
                Script.Add('');
                Script.Add('/* index only in target - uncomment to remove */');
                Script.Add('-- drop index ' + IndexName + ';');
                Inc(Differences.ToDrop);
              end;
            end;
        finally
          TgtKind.Free;
          TgtName.Free;
          TgtCon.Free;
          SrcKind.Free;
          SrcName.Free;
          SrcCon.Free;
          TargetIdx.Free;
          SourceIdx.Free;
        end;
      end;
    finally
      AllTables.Free;
    end;

    if (Differences.ToCreate = 0) and (Differences.ToDrop = 0) and
       (Differences.Changed = 0) and (Differences.NeedingAttention = 0) then
    begin
      Script.Add('');
      Script.Add('/* No differences found. */');
    end;

    Result := Script.Text;
  finally
    Script.Free;
  end;
end;

end.
