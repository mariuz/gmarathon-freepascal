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

unit TableDesignIO;

{$MODE Delphi}

{ Reading a table out of the catalogue as a design, and running a design's
  script against the database.

  Kept apart from TableDesign so that unit needs no database to be tested: what
  a change should generate is decided there and checked without a server, and
  only the two ends - where the design comes from and where the script goes -
  are here.

  ConvertFieldType and DeclaredFieldLength come from the metadata extractor
  rather than being written again, so a column reads back the way the DDL tab
  spells it. That matters more than saving the code: if the two disagreed, the
  designer would generate an ALTER for a type that had not actually changed. }

interface

uses SysUtils, Classes, DB, IBDatabase, IBQuery, IBSQL, TableDesign;

{ The table as it is now. Returns nil when there is no such table.

  Every column comes back with OriginalName set to its own name, which is what
  marks it as already existing; a column the designer adds afterwards leaves
  that empty and is told apart by it. }
function ReadTableDesign(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ATableName: String): TTableDesign;

{ The name Firebird gave the table's primary key constraint, or '' if it has
  none. Needed because dropping a key needs its name, and an unnamed one is
  called INTEG_nnn - a number that cannot be guessed and differs between two
  databases built from the same script. }
function PrimaryKeyConstraintName(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction; const ATableName: String): String;

{ Runs the statements one at a time in the caller's transaction. Stops at the
  first failure and re-raises, leaving the transaction for the caller to roll
  back - a half-applied design is the caller's decision to keep or discard, not
  this function's. }
procedure ApplyTableDesign(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const AStatements: array of String);

{ The design's changes as statements, with the comment lines a preview shows
  stripped out - what ApplyTableDesign should actually be given. }
function TableDesignStatements(Original, Target: TTableDesign): TStringList;

implementation

uses MetaExtractGlobals;

function ScalarSQL(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ASQL: String; const AParam: String): String;
var
  Q: TIBQuery;
begin
  Result := '';
  Q := TIBQuery.Create(nil);
  try
    Q.Database := ADatabase;
    Q.Transaction := ATransaction;
    { IBX will not open a dataset on a transaction that is not running unless
      it is told it may. The editors grant this to every dataset they own, but
      these are owned by nobody, so each says it for itself - otherwise reading
      a table fails whenever something else has just committed the shared
      metadata transaction, which the object tree does constantly. }
    Q.AllowAutoActivateTransaction := True;
    Q.SQL.Text := ASQL;
    Q.ParamByName('name').AsString := AParam;
    Q.Open;
    if not Q.EOF then
      Result := Trim(Q.Fields[0].AsString);
  finally
    Q.Free;
  end;
end;

function PrimaryKeyConstraintName(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction; const ATableName: String): String;
begin
  Result := ScalarSQL(ADatabase, ATransaction,
    'select rdb$constraint_name from rdb$relation_constraints ' +
    'where rdb$relation_name = :name ' +
    '  and rdb$constraint_type = ''PRIMARY KEY''',
    ATableName);
end;

{ The key's columns in key order, which is RDB$FIELD_POSITION on the index
  segment - not the order they appear in the table. }
procedure ReadPrimaryKey(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ATableName: String; ADesign: TTableDesign);
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := ADatabase;
    Q.Transaction := ATransaction;
    { IBX will not open a dataset on a transaction that is not running unless
      it is told it may. The editors grant this to every dataset they own, but
      these are owned by nobody, so each says it for itself - otherwise reading
      a table fails whenever something else has just committed the shared
      metadata transaction, which the object tree does constantly. }
    Q.AllowAutoActivateTransaction := True;
    Q.SQL.Text :=
      'select s.rdb$field_name from rdb$relation_constraints rc ' +
      '  join rdb$index_segments s on s.rdb$index_name = rc.rdb$index_name ' +
      'where rc.rdb$relation_name = :name ' +
      '  and rc.rdb$constraint_type = ''PRIMARY KEY'' ' +
      'order by s.rdb$field_position';
    Q.ParamByName('name').AsString := ATableName;
    Q.Open;
    while not Q.EOF do
    begin
      ADesign.PrimaryKey.Add(Trim(Q.Fields[0].AsString));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function ReadTableDesign(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ATableName: String): TTableDesign;
var
  Q: TIBQuery;
  C: TColumnDesign;
  Name: String;
  Found: Boolean;
begin
  Result := nil;
  Name := Trim(ATableName);
  if (Name = '') or not Assigned(ADatabase) or not Assigned(ATransaction) then
    Exit;

  Q := TIBQuery.Create(nil);
  try
    Q.Database := ADatabase;
    Q.Transaction := ATransaction;
    { IBX will not open a dataset on a transaction that is not running unless
      it is told it may. The editors grant this to every dataset they own, but
      these are owned by nobody, so each says it for itself - otherwise reading
      a table fails whenever something else has just committed the shared
      metadata transaction, which the object tree does constantly. }
    Q.AllowAutoActivateTransaction := True;
    { RDB$RELATION_FIELDS carries the column, RDB$FIELDS the type behind it.
      The default can sit on either: a column declared with its own DEFAULT has
      it on the relation field, one inheriting from a domain has it on the
      field, so both are read and the column's own wins. }
    Q.SQL.Text :=
      'select rf.rdb$field_name, rf.rdb$null_flag, rf.rdb$default_source, ' +
      '       rf.rdb$field_source, ' +
      '       f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, ' +
      '       f.rdb$field_scale, f.rdb$field_sub_type, f.rdb$field_precision, ' +
      '       f.rdb$null_flag as domain_null_flag, ' +
      '       f.rdb$default_source as domain_default, ' +
      '       f.rdb$computed_source ' +
      'from rdb$relation_fields rf ' +
      '  join rdb$fields f on f.rdb$field_name = rf.rdb$field_source ' +
      'where rf.rdb$relation_name = :name ' +
      'order by rf.rdb$field_position';
    Q.ParamByName('name').AsString := Name;
    Q.Open;

    Found := False;
    while not Q.EOF do
    begin
      if not Found then
      begin
        Result := TTableDesign.Create(Name);
        Found := True;
      end;

      C.Name := Trim(Q.FieldByName('rdb$field_name').AsString);
      { What it is called in the database, which is what makes a later rename
        an instruction rather than something to be inferred. }
      C.OriginalName := C.Name;
      C.DataType := ConvertFieldType(
        Q.FieldByName('rdb$field_type').AsInteger,
        DeclaredFieldLength(Q),
        Q.FieldByName('rdb$field_scale').AsInteger,
        Q.FieldByName('rdb$field_sub_type').AsInteger,
        Q.FieldByName('rdb$field_precision').AsInteger,
        True);
      { NOT NULL can come from the column or from its domain; either one makes
        the column not nullable. }
      C.NotNull := (not Q.FieldByName('rdb$null_flag').IsNull) and
                   (Q.FieldByName('rdb$null_flag').AsInteger <> 0);
      if not C.NotNull then
        C.NotNull := (not Q.FieldByName('domain_null_flag').IsNull) and
                     (Q.FieldByName('domain_null_flag').AsInteger <> 0);

      C.DefaultValue := Trim(Q.FieldByName('rdb$default_source').AsString);
      if C.DefaultValue = '' then
        C.DefaultValue := Trim(Q.FieldByName('domain_default').AsString);
      { Stored with the keyword; the design holds only the value, since it puts
        the keyword back itself. }
      if AnsiUpperCase(Copy(C.DefaultValue, 1, 8)) = 'DEFAULT ' then
        C.DefaultValue := Trim(Copy(C.DefaultValue, 9, MaxInt));

      C.ComputedAs := Trim(Q.FieldByName('rdb$computed_source').AsString);
      { Stored parenthesised, and the design adds its own brackets. }
      if (Length(C.ComputedAs) >= 2) and (C.ComputedAs[1] = '(') and
         (C.ComputedAs[Length(C.ComputedAs)] = ')') then
        C.ComputedAs := Trim(Copy(C.ComputedAs, 2, Length(C.ComputedAs) - 2));

      C.Collation := '';
      Result.AddColumn(C);
      Q.Next;
    end;
  finally
    Q.Free;
  end;

  if Assigned(Result) then
    ReadPrimaryKey(ADatabase, ATransaction, Name, Result);
end;

function TableDesignStatements(Original, Target: TTableDesign): TStringList;
var
  Changes: TTableDesignChangeArray;
  Idx: Integer;
begin
  Result := TStringList.Create;
  Changes := TableDesignChanges(Original, Target);
  for Idx := 0 to High(Changes) do
    { A change the generator could not express comes back as a comment rather
      than as SQL - dropping a key whose name was never supplied, say. Running
      it would fail, so it is shown in the preview and left out of the run. }
    if Copy(Trim(Changes[Idx].Statement), 1, 2) <> '/*' then
      Result.Add(Changes[Idx].Statement);
end;

procedure ApplyTableDesign(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const AStatements: array of String);
var
  Idx: Integer;
  Q: TIBSQL;
  Text: String;
begin
  if not ATransaction.InTransaction then
    ATransaction.StartTransaction;
  for Idx := Low(AStatements) to High(AStatements) do
  begin
    Text := Trim(AStatements[Idx]);
    if (Text = '') or (Copy(Text, 1, 2) = '/*') then
      Continue;
    { The trailing semicolon is for the preview; the engine takes one statement
      and does not want it. }
    while (Length(Text) > 0) and (Text[Length(Text)] = ';') do
      Text := TrimRight(Copy(Text, 1, Length(Text) - 1));
    Q := TIBSQL.Create(nil);
    try
      Q.Database := ADatabase;
      Q.Transaction := ATransaction;
      Q.SQL.Text := Text;
      Q.ExecQuery;
    finally
      Q.Free;
    end;
  end;
end;

end.
