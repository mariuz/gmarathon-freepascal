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

unit TableDesign;

{$MODE Delphi}

{ A table as it is being designed, and the script that would make it so.

  Marathon alters a table as you go: each column dialog runs its own ALTER
  TABLE when you press OK. That is why there is nothing to show before applying
  and no way to abandon a half-made change - the first three columns are
  already in the database while you are still deciding on the fourth.

  This is the other model, the one a table designer needs: a design is held,
  compared with what the table is now, and turned into a script that is shown
  before it is run. Nothing here talks to a database or to the LCL, so the
  script for any given change can be checked without either.

  What a column knows about itself matters more than it looks. OriginalName is
  what the column is called *in the database*, empty for one being added. That
  is what makes a rename an instruction rather than a guess: without it, a
  column called ID becoming CUSTOMER_ID is indistinguishable from ID being
  dropped and CUSTOMER_ID added, and those differ by the data in it. }

interface

uses SysUtils, Classes;

type
  TColumnDesign = record
    { What the column is called in the database. Empty for a new column, which
      is how adding is told from renaming. }
    OriginalName: String;
    Name: String;
    { The type as SQL spells it: 'integer', 'varchar(30)', 'numeric(18,2)'. Held
      as text because that is what the user types and what Firebird parses; a
      structured type would have to be lowered back to this anyway. }
    DataType: String;
    NotNull: Boolean;
    DefaultValue: String;
    { Set for a computed column, in which case DataType is optional and the
      expression is what defines it. }
    ComputedAs: String;
    Collation: String;
  end;

  TTableDesignChangeKind = (tdAdd, tdDrop, tdRename, tdRetype, tdNullability,
    tdDefault, tdPrimaryKey);

  TTableDesignChange = record
    Kind: TTableDesignChangeKind;
    Column: String;
    Statement: String;
    { True when running this can lose data - dropping a column, or narrowing a
      type. A designer should say so before applying rather than after. }
    Destructive: Boolean;
  end;

  TTableDesignChangeArray = array of TTableDesignChange;

  TTableDesign = class
  private
    FTableName: String;
    FColumns: array of TColumnDesign;
    FPrimaryKey: TStringList;
    function IndexOfOriginal(const AName: String): Integer;
  public
    constructor Create(const ATableName: String);
    destructor Destroy; override;
    procedure AddColumn(const AColumn: TColumnDesign);
    function ColumnCount: Integer;
    function Column(Index: Integer): TColumnDesign;
    procedure SetColumn(Index: Integer; const AColumn: TColumnDesign);
    procedure DropColumn(Index: Integer);
    property TableName: String read FTableName write FTableName;
    property PrimaryKey: TStringList read FPrimaryKey;
    { A copy, so a designer can hold the original alongside what is being
      edited and compare the two. }
    function Clone: TTableDesign;
  end;

{ The statement that would create this table from nothing. }
function CreateTableScript(Design: TTableDesign): String;

{ What has to run to turn Original into Target, one entry per change so a
  designer can list them, mark the destructive ones and let them be reviewed
  before any of it runs.

  Order matters and is not the order they were edited: renames come before
  anything that names a column, so later statements can use the new name, and
  the primary key is rebuilt last because it depends on the columns. }
function TableDesignChanges(Original, Target: TTableDesign): TTableDesignChangeArray;

{ The changes as one script, in order, with the destructive ones marked. }
function TableDesignScript(Original, Target: TTableDesign): String;

{ The name the server will store for an identifier the user typed.

  Firebird folds an unquoted identifier to upper case and keeps a quoted one
  verbatim, so a table created from what someone typed cannot be read back by
  that same text. Anything that creates an object and then looks it up again
  has to ask for the stored form, not the typed one. }
function StoredIdentifier(const ATyped: String): String;

implementation

constructor TTableDesign.Create(const ATableName: String);
begin
  inherited Create;
  FTableName := ATableName;
  FPrimaryKey := TStringList.Create;
end;

destructor TTableDesign.Destroy;
begin
  FPrimaryKey.Free;
  inherited Destroy;
end;

procedure TTableDesign.AddColumn(const AColumn: TColumnDesign);
begin
  SetLength(FColumns, Length(FColumns) + 1);
  FColumns[High(FColumns)] := AColumn;
end;

function TTableDesign.ColumnCount: Integer;
begin
  Result := Length(FColumns);
end;

function TTableDesign.Column(Index: Integer): TColumnDesign;
begin
  Result := FColumns[Index];
end;

procedure TTableDesign.SetColumn(Index: Integer; const AColumn: TColumnDesign);
begin
  FColumns[Index] := AColumn;
end;

procedure TTableDesign.DropColumn(Index: Integer);
var
  Idx: Integer;
begin
  for Idx := Index to High(FColumns) - 1 do
    FColumns[Idx] := FColumns[Idx + 1];
  SetLength(FColumns, Length(FColumns) - 1);
end;

function TTableDesign.IndexOfOriginal(const AName: String): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  if Trim(AName) = '' then
    Exit;
  for Idx := 0 to High(FColumns) do
    if SameText(FColumns[Idx].OriginalName, AName) then
      Exit(Idx);
end;

function TTableDesign.Clone: TTableDesign;
var
  Idx: Integer;
begin
  Result := TTableDesign.Create(FTableName);
  for Idx := 0 to High(FColumns) do
    Result.AddColumn(FColumns[Idx]);
  Result.PrimaryKey.Assign(FPrimaryKey);
end;

function ColumnDefinition(const C: TColumnDesign): String;
begin
  if Trim(C.ComputedAs) <> '' then
  begin
    { A computed column takes no default, no NOT NULL and no collation - the
      expression is the whole definition. }
    Result := Trim(C.Name) + ' computed by (' + Trim(C.ComputedAs) + ')';
    Exit;
  end;

  Result := Trim(C.Name) + ' ' + Trim(C.DataType);
  if Trim(C.DefaultValue) <> '' then
    Result := Result + ' default ' + Trim(C.DefaultValue);
  if C.NotNull then
    Result := Result + ' not null';
  if Trim(C.Collation) <> '' then
    Result := Result + ' collate ' + Trim(C.Collation);
end;

function ColumnList(AList: TStrings): String;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := 0 to AList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + Trim(AList[Idx]);
  end;
end;

function CreateTableScript(Design: TTableDesign): String;
var
  Idx: Integer;
  Body: String;
begin
  Body := '';
  for Idx := 0 to Design.ColumnCount - 1 do
  begin
    if Body <> '' then
      Body := Body + ',' + #13#10;
    Body := Body + '  ' + ColumnDefinition(Design.Column(Idx));
  end;
  if Design.PrimaryKey.Count > 0 then
    Body := Body + ',' + #13#10 + '  primary key (' +
      ColumnList(Design.PrimaryKey) + ')';
  Result := 'create table ' + Trim(Design.TableName) + ' (' + #13#10 +
    Body + #13#10 + ');';
end;

procedure AddChange(var AList: TTableDesignChangeArray;
  AKind: TTableDesignChangeKind; const AColumn, AStatement: String;
  ADestructive: Boolean);
var
  At: Integer;
begin
  At := Length(AList);
  SetLength(AList, At + 1);
  AList[At].Kind := AKind;
  AList[At].Column := AColumn;
  AList[At].Statement := AStatement;
  AList[At].Destructive := ADestructive;
end;

{ True when the two designs describe the same primary key, in the same order.
  Order is part of a key, not a detail: (A, B) and (B, A) index differently. }
function SameKey(A, B: TStrings): Boolean;
var
  Idx: Integer;
begin
  Result := A.Count = B.Count;
  if not Result then
    Exit;
  for Idx := 0 to A.Count - 1 do
    if not SameText(Trim(A[Idx]), Trim(B[Idx])) then
      Exit(False);
end;

function StoredIdentifier(const ATyped: String): String;
begin
  Result := Trim(ATyped);
  if (Length(Result) >= 2) and (Result[1] = '"') and
     (Result[Length(Result)] = '"') then
    { Quoted: the server stores exactly what is between the quotes, case and
      all. }
    Result := Copy(Result, 2, Length(Result) - 2)
  else
    Result := AnsiUpperCase(Result);
end;

function TableDesignChanges(Original, Target: TTableDesign): TTableDesignChangeArray;
var
  Idx, Other: Integer;
  Was, Now_: TColumnDesign;
  Matched, Found: Boolean;
  TableName: String;
begin
  Result := nil;
  { No original means there is nothing to compare against, and the difference
    between "this table has no columns" and "this table could not be read" is
    the difference between a correct script and a destructive one - the first
    loop below would read every existing column as dropped. Answer no changes
    and let the caller say so; a designer that cannot read the table has
    nothing to apply. }
  if not Assigned(Original) or not Assigned(Target) then
    Exit;
  TableName := Trim(Target.TableName);

  { Renames first: everything after this names columns by their new name, so
    doing them last would leave the earlier statements pointing at names that
    no longer exist. }
  for Idx := 0 to Target.ColumnCount - 1 do
  begin
    Now_ := Target.Column(Idx);
    if (Trim(Now_.OriginalName) = '') or SameText(Now_.OriginalName, Now_.Name) then
      Continue;
    AddChange(Result, tdRename, Now_.Name,
      'alter table ' + TableName + ' alter column ' + Trim(Now_.OriginalName) +
      ' to ' + Trim(Now_.Name) + ';', False);
  end;

  { Columns that have gone. Always destructive: the data in them goes too. }
  for Idx := 0 to Original.ColumnCount - 1 do
  begin
    Was := Original.Column(Idx);
    Found := False;
    for Other := 0 to Target.ColumnCount - 1 do
      if SameText(Target.Column(Other).OriginalName, Was.Name) then
      begin
        Found := True;
        Break;
      end;
    if not Found then
      AddChange(Result, tdDrop, Was.Name,
        'alter table ' + TableName + ' drop ' + Trim(Was.Name) + ';', True);
  end;

  for Idx := 0 to Target.ColumnCount - 1 do
  begin
    Now_ := Target.Column(Idx);

    { A column with no original name is one being added. }
    if Trim(Now_.OriginalName) = '' then
    begin
      AddChange(Result, tdAdd, Now_.Name,
        'alter table ' + TableName + ' add ' + ColumnDefinition(Now_) + ';', False);
      Continue;
    end;

    Matched := False;
    for Other := 0 to Original.ColumnCount - 1 do
      if SameText(Original.Column(Other).Name, Now_.OriginalName) then
      begin
        Was := Original.Column(Other);
        Matched := True;
        Break;
      end;
    if not Matched then
      Continue;

    if not SameText(Trim(Was.DataType), Trim(Now_.DataType)) then
      { Narrowing a type can fail or truncate, and which it does depends on the
        data, so this is flagged rather than judged. }
      AddChange(Result, tdRetype, Now_.Name,
        'alter table ' + TableName + ' alter column ' + Trim(Now_.Name) +
        ' type ' + Trim(Now_.DataType) + ';', True);

    if Was.NotNull <> Now_.NotNull then
    begin
      if Now_.NotNull then
        { Fails if any row is already null there, which is the database's
          business to report rather than this to predict. }
        AddChange(Result, tdNullability, Now_.Name,
          'alter table ' + TableName + ' alter column ' + Trim(Now_.Name) +
          ' set not null;', False)
      else
        AddChange(Result, tdNullability, Now_.Name,
          'alter table ' + TableName + ' alter column ' + Trim(Now_.Name) +
          ' drop not null;', False);
    end;

    if Trim(Was.DefaultValue) <> Trim(Now_.DefaultValue) then
    begin
      if Trim(Now_.DefaultValue) = '' then
        AddChange(Result, tdDefault, Now_.Name,
          'alter table ' + TableName + ' alter column ' + Trim(Now_.Name) +
          ' drop default;', False)
      else
        AddChange(Result, tdDefault, Now_.Name,
          'alter table ' + TableName + ' alter column ' + Trim(Now_.Name) +
          ' set default ' + Trim(Now_.DefaultValue) + ';', False);
    end;
  end;

  { The key last: it names columns, so it has to follow their renames, additions
    and retypes. }
  if not SameKey(Original.PrimaryKey, Target.PrimaryKey) then
  begin
    if Original.PrimaryKey.Count > 0 then
      { Firebird names an unnamed primary key itself, so the constraint has to
        be found by what it is rather than by a name this could guess. The
        designer supplies the name it read from the catalogue; with none, this
        says what has to happen rather than pretending it can. }
      AddChange(Result, tdPrimaryKey, '',
        '/* the existing primary key must be dropped first: ' +
        'alter table ' + TableName + ' drop constraint <name> */', True);
    if Target.PrimaryKey.Count > 0 then
      AddChange(Result, tdPrimaryKey, '',
        'alter table ' + TableName + ' add primary key (' +
        ColumnList(Target.PrimaryKey) + ');', False);
  end;
end;

function TableDesignScript(Original, Target: TTableDesign): String;
var
  Changes: TTableDesignChangeArray;
  Idx: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Changes := TableDesignChanges(Original, Target);
    for Idx := 0 to High(Changes) do
    begin
      if Changes[Idx].Destructive then
        Lines.Add('/* this one can lose data */');
      Lines.Add(Changes[Idx].Statement);
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.
