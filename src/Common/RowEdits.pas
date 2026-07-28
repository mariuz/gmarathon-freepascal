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

unit RowEdits;

{$MODE Delphi}

{ Edits made in the data grid, as the SQL they would run.

  The table designer was converted from apply-as-you-go to design-then-apply
  earlier: a batch of intended changes, a script built from them, and one
  Apply. The data grid still worked the old way - every row posted itself as it
  was left, so there was nothing to review and no way to change your mind.
  This is the same pattern for rows.

  Turning a grid edit into SQL has one genuinely dangerous corner, and it is
  the reason this is a unit of its own with tests rather than a few lines
  beside the grid: an UPDATE or DELETE is only safe if its WHERE clause picks
  out exactly one row. A table with no primary key gives nothing to write
  there, and a statement without one changes every row that looks alike. So a
  change with no key columns refuses to produce a statement at all, and says
  why. }

interface

uses SysUtils, Classes, DB;

type
  TRowEditKind = (reInsert, reUpdate, reDelete);

  { One column's value in a statement. Held as text with a flag for how it
    should be written, because that is what a dataset hands over and because
    deciding it later would mean deciding it twice. }
  TRowValue = record
    Name: String;
    Value: String;
    IsNull: Boolean;
    { True for anything written without quotes - the numeric types. Everything
      else is quoted, which is right for text and for the date and time
      literals Firebird accepts in quotes. }
    Unquoted: Boolean;
  end;

  TRowEdit = class
  private
    FValues: array of TRowValue;
    FKeys: array of TRowValue;
  public
    Kind: TRowEditKind;
    TableName: String;
    Schema: String;
    { What the column was set to. Empty for a delete. }
    procedure AddValue(const AName, AValue: String; AIsNull: Boolean = False;
      AUnquoted: Boolean = False);
    { What identifies the row. Empty when the table has no key, which is what
      makes the change unsafe. }
    procedure AddKey(const AName, AValue: String; AIsNull: Boolean = False;
      AUnquoted: Boolean = False);
    function ValueCount: Integer;
    function KeyCount: Integer;
    function Value(Index: Integer): TRowValue;
    function Key(Index: Integer): TRowValue;
  end;

  TRowEditList = class
  private
    FItems: TList;
    function GetItem(Index: Integer): TRowEdit;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AKind: TRowEditKind; const ATable: String;
      const ASchema: String = ''): TRowEdit;
    procedure Clear;
    function Count: Integer;
    property Items[Index: Integer]: TRowEdit read GetItem; default;
    { How many changes cannot be written safely, because the row cannot be
      identified. A caller shows this before offering to apply anything. }
    function UnsafeCount: Integer;
  end;

{ A value as SQL spells it. Strings are quoted with their own quotes doubled,
  which is the whole of SQL escaping for a literal. }
function SQLLiteral(const AValue: TRowValue): String;

{ The same question asked of a field in an open dataset: what would this value
  look like written into a statement.

  Here rather than beside the grid export that needed it, because it is the
  same decision this unit already makes for a row edit and because a dataset is
  all it needs - no LCL, so the rules can be checked without a window.

  The rules are the ones that make a generated INSERT run rather than merely
  look right: a null is the word null and not an empty pair of quotes or, worse,
  nothing at all; a quote inside text is doubled; numbers, and booleans, are
  written unquoted, so a boolean column takes them; and a date is written in the
  order Firebird reads regardless of what the machine's locale would print.
  Blobs are written as null, which is what the export has always done - the
  value is not in the grid to write. }
function SQLFieldLiteral(AField: TField): String;

{ The statement for one change, or '' when it cannot be written safely -
  an update or delete with nothing to identify the row by. }
function RowEditStatement(AEdit: TRowEdit): String;

{ Every change as one script, in the order they were made. Changes that cannot
  be written safely appear as a comment saying so rather than being dropped
  silently: a preview that quietly omits an edit is worse than one that
  explains it. }
function RowEditScript(AList: TRowEditList): String;

implementation

uses SchemaNames;

procedure TRowEdit.AddValue(const AName, AValue: String; AIsNull, AUnquoted: Boolean);
var
  At: Integer;
begin
  At := Length(FValues);
  SetLength(FValues, At + 1);
  FValues[At].Name := Trim(AName);
  FValues[At].Value := AValue;
  FValues[At].IsNull := AIsNull;
  FValues[At].Unquoted := AUnquoted;
end;

procedure TRowEdit.AddKey(const AName, AValue: String; AIsNull, AUnquoted: Boolean);
var
  At: Integer;
begin
  At := Length(FKeys);
  SetLength(FKeys, At + 1);
  FKeys[At].Name := Trim(AName);
  FKeys[At].Value := AValue;
  FKeys[At].IsNull := AIsNull;
  FKeys[At].Unquoted := AUnquoted;
end;

function TRowEdit.ValueCount: Integer;
begin
  Result := Length(FValues);
end;

function TRowEdit.KeyCount: Integer;
begin
  Result := Length(FKeys);
end;

function TRowEdit.Value(Index: Integer): TRowValue;
begin
  Result := FValues[Index];
end;

function TRowEdit.Key(Index: Integer): TRowValue;
begin
  Result := FKeys[Index];
end;

constructor TRowEditList.Create;
begin
  inherited Create;
  FItems := TList.Create;
end;

destructor TRowEditList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

function TRowEditList.GetItem(Index: Integer): TRowEdit;
begin
  Result := TRowEdit(FItems[Index]);
end;

function TRowEditList.Count: Integer;
begin
  Result := FItems.Count;
end;

function TRowEditList.Add(AKind: TRowEditKind;
  const ATable, ASchema: String): TRowEdit;
begin
  Result := TRowEdit.Create;
  Result.Kind := AKind;
  Result.TableName := Trim(ATable);
  Result.Schema := Trim(ASchema);
  FItems.Add(Result);
end;

procedure TRowEditList.Clear;
var
  Idx: Integer;
begin
  for Idx := 0 to FItems.Count - 1 do
    TRowEdit(FItems[Idx]).Free;
  FItems.Clear;
end;

function TRowEditList.UnsafeCount: Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to FItems.Count - 1 do
    if RowEditStatement(GetItem(Idx)) = '' then
      Inc(Result);
end;

function SQLLiteral(const AValue: TRowValue): String;
begin
  if AValue.IsNull then
    Exit('null');
  if AValue.Unquoted then
  begin
    { A numeric column with nothing in it is null, not an empty expression
      that would not parse. }
    if Trim(AValue.Value) = '' then
      Exit('null');
    Exit(Trim(AValue.Value));
  end;
  { Doubling the quotes is the whole of escaping a SQL literal. }
  Result := '''' + StringReplace(AValue.Value, '''', '''''', [rfReplaceAll]) + '''';
end;

{ The WHERE clause identifying one row. Null keys are compared with IS NULL,
  since = null is never true and would match nothing. }
function KeyClause(AEdit: TRowEdit): String;
var
  Idx: Integer;
  K: TRowValue;
begin
  Result := '';
  for Idx := 0 to AEdit.KeyCount - 1 do
  begin
    K := AEdit.Key(Idx);
    if Result <> '' then
      Result := Result + ' and ';
    if K.IsNull then
      Result := Result + K.Name + ' is null'
    else
      Result := Result + K.Name + ' = ' + SQLLiteral(K);
  end;
end;

function SQLFieldLiteral(AField: TField): String;
begin
  if not Assigned(AField) or AField.IsNull then
    Exit('null');
  case AField.DataType of
    ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc:
      Result := Trim(AField.AsString);
    { DECFLOAT, INT128 and NUMERIC all arrive as BCD. Their text form is the
      exact one; AsFloat would round away the precision they exist for. The
      decimal separator is the machine's, and SQL wants a point. }
    ftBCD, ftFMTBcd:
      Result := StringReplace(Trim(AField.AsString), ',', '.', [rfReplaceAll]);
    ftFloat, ftCurrency:
      Result := StringReplace(FloatToStr(AField.AsFloat), ',', '.', [rfReplaceAll]);
    ftBoolean:
      if AField.AsBoolean then
        Result := 'true'
      else
        Result := 'false';
    { Written the way Firebird reads it whatever the machine prints, which
      DateTimeToStr does not promise - a script exported on one machine has to
      run on another. }
    ftDate:
      Result := '''' + FormatDateTime('yyyy-mm-dd', AField.AsDateTime) + '''';
    ftTime:
      Result := '''' + FormatDateTime('hh:nn:ss', AField.AsDateTime) + '''';
    ftDateTime, ftTimeStamp:
      Result := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', AField.AsDateTime) + '''';
    { Not in the grid to write out. }
    ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftTypedBinary:
      Result := 'null';
  else
    Result := '''' +
      StringReplace(AField.AsString, '''', '''''', [rfReplaceAll]) + '''';
  end;
end;

function RowEditStatement(AEdit: TRowEdit): String;
var
  Idx: Integer;
  Cols, Vals, Sets_, Table: String;
  V: TRowValue;
begin
  Result := '';
  if not Assigned(AEdit) or (Trim(AEdit.TableName) = '') then
    Exit;
  Table := DisplaySchemaName(AEdit.Schema, AEdit.TableName);

  case AEdit.Kind of
    reInsert:
      begin
        { An insert needs no key: it makes the row rather than finding it. }
        Cols := '';
        Vals := '';
        for Idx := 0 to AEdit.ValueCount - 1 do
        begin
          V := AEdit.Value(Idx);
          if Cols <> '' then
          begin
            Cols := Cols + ', ';
            Vals := Vals + ', ';
          end;
          Cols := Cols + V.Name;
          Vals := Vals + SQLLiteral(V);
        end;
        if Cols = '' then
          Exit;
        Result := 'insert into ' + Table + ' (' + Cols + ')' + #13#10 +
          '  values (' + Vals + ');';
      end;

    reUpdate:
      begin
        { Without a key this would change every row that looks alike. }
        if AEdit.KeyCount = 0 then
          Exit;
        Sets_ := '';
        for Idx := 0 to AEdit.ValueCount - 1 do
        begin
          V := AEdit.Value(Idx);
          if Sets_ <> '' then
            Sets_ := Sets_ + ',' + #13#10 + '      ';
          Sets_ := Sets_ + V.Name + ' = ' + SQLLiteral(V);
        end;
        { Nothing changed is not a statement. }
        if Sets_ = '' then
          Exit;
        Result := 'update ' + Table + #13#10 + '  set ' + Sets_ + #13#10 +
          '  where ' + KeyClause(AEdit) + ';';
      end;

    reDelete:
      begin
        if AEdit.KeyCount = 0 then
          Exit;
        Result := 'delete from ' + Table + #13#10 +
          '  where ' + KeyClause(AEdit) + ';';
      end;
  end;
end;

function RowEditScript(AList: TRowEditList): String;
var
  Idx: Integer;
  Lines: TStringList;
  Statement: String;
  E: TRowEdit;
begin
  Result := '';
  if not Assigned(AList) then
    Exit;
  Lines := TStringList.Create;
  try
    for Idx := 0 to AList.Count - 1 do
    begin
      E := AList[Idx];
      Statement := RowEditStatement(E);
      if Statement <> '' then
        Lines.Add(Statement)
      else if E.Kind = reInsert then
        Lines.Add('/* a new row with nothing in it, skipped */')
      else
        { Said out loud rather than dropped: a preview that quietly omits an
          edit is worse than one that explains it. }
        Lines.Add('/* ' + DisplaySchemaName(E.Schema, E.TableName) +
          ' has no primary key, so this change cannot be written safely - ' +
          'it would match every row that looks alike */');
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.
