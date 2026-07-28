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

unit CsvImport;

{$MODE Delphi}

{ Reading a flat file into a table.

  Both VS Code database extensions ship a CSV-to-table wizard and it is the one
  thing they have that this did not: getting a spreadsheet into Firebird meant
  writing the INSERTs by hand or reaching for another tool.

  Everything here is decidable without a window - how a line splits, what type
  a column of text should be, and what DDL and DML that comes to - so it is all
  here and checked without one. The dialog picks the file and shows the
  preview; it decides nothing.

  Two things this is careful about, because they are where a naive importer
  quietly ruins the data. **Quoting**: a field may hold the delimiter, a line
  ending or a quote of its own, and the last is written doubled - a splitter
  that does not know that turns one row into several. **Types**: a column is
  only a number if *every* value in it is, and a value that is empty says
  nothing either way, so a column of numbers with a gap in it is still
  numbers. Where the values disagree the column is text, because text holds
  everything and a wrong guess costs a failed import or, worse, a silent
  truncation. }

interface

uses SysUtils, Classes;

type
  TCsvOptions = record
    Delimiter: Char;
    Quote: Char;
    { The first line names the columns rather than holding data. }
    FirstRowIsNames: Boolean;
  end;

  { What a column of text can be stored as. In widening order: a column is
    given the narrowest kind every one of its values fits. }
  TCsvColumnKind = (ckInteger, ckBigInt, ckDouble, ckDate, ckTimestamp, ckText);

  TCsvColumn = record
    Name: String;
    Kind: TCsvColumnKind;
    { Longest value seen, for the VARCHAR width. }
    Width: Integer;
  end;

  { A file, read and understood: the columns it has, the rows it holds, and the
    statements that would put them in a table. }
  TCsvImportPlan = class
  private
    FColumns: array of TCsvColumn;
    FRows: TList;
    FOptions: TCsvOptions;
    function GetColumn(Index: Integer): TCsvColumn;
    function GetRow(Index: Integer): TStringList;
    function GetColumnCount: Integer;
    function GetRowCount: Integer;
  public
    constructor Create(const AOptions: TCsvOptions);
    destructor Destroy; override;
    property ColumnCount: Integer read GetColumnCount;
    property Columns[Index: Integer]: TCsvColumn read GetColumn;
    property RowCount: Integer read GetRowCount;
    property Rows[Index: Integer]: TStringList read GetRow;

    { CREATE TABLE for the columns as they were understood. }
    function CreateTableSQL(const ATableName: String): String;
    { One INSERT for one row. Values are quoted or not according to the
      column's kind, and an empty value is null rather than an empty string -
      a blank cell in a spreadsheet is a missing value, not a present empty
      one. }
    function InsertSQL(const ATableName: String; ARow: Integer): String;
  end;

{ Comma, double quote, first row names - what a file exported by a spreadsheet
  looks like. }
function DefaultCsvOptions: TCsvOptions;

{ Splits one line into its fields, honouring quotes and doubled quotes inside
  them. }
function ParseCsvLine(const ALine: String; const AOptions: TCsvOptions): TStringList;

{ Reads the lines into a plan: names the columns, works out what each one holds
  and keeps the rows. The caller owns the result. }
function PlanCsvImport(ALines: TStrings; const AOptions: TCsvOptions): TCsvImportPlan;

{ The Firebird type for a column, as DDL spells it. }
function ColumnTypeSQL(const AColumn: TCsvColumn): String;

implementation

uses SQLIdentifiers;

function DefaultCsvOptions: TCsvOptions;
begin
  Result.Delimiter := ',';
  Result.Quote := '"';
  Result.FirstRowIsNames := True;
end;

function ParseCsvLine(const ALine: String; const AOptions: TCsvOptions): TStringList;
var
  Idx: Integer;
  Current: String;
  InQuotes: Boolean;
begin
  Result := TStringList.Create;
  Current := '';
  InQuotes := False;
  Idx := 1;
  while Idx <= Length(ALine) do
  begin
    if InQuotes then
    begin
      if ALine[Idx] = AOptions.Quote then
      begin
        { A quote inside a quoted field is written twice. One of them is the
          end of the field; two of them are one quote in the value. }
        if (Idx < Length(ALine)) and (ALine[Idx + 1] = AOptions.Quote) then
        begin
          Current := Current + AOptions.Quote;
          Inc(Idx);
        end
        else
          InQuotes := False;
      end
      else
        Current := Current + ALine[Idx];
    end
    else if ALine[Idx] = AOptions.Quote then
      InQuotes := True
    else if ALine[Idx] = AOptions.Delimiter then
    begin
      Result.Add(Current);
      Current := '';
    end
    else
      Current := Current + ALine[Idx];
    Inc(Idx);
  end;
  Result.Add(Current);
end;

{ What one value could be stored as, on its own. }
function KindOfValue(const AValue: String): TCsvColumnKind;
var
  I64: Int64;
  Dbl: Double;
  Dt: TDateTime;
  Fmt: TFormatSettings;
begin
  { A number that fits an integer, then one that fits a bigint. }
  if TryStrToInt64(AValue, I64) then
  begin
    if (I64 >= -2147483648) and (I64 <= 2147483647) then
      Result := ckInteger
    else
      Result := ckBigInt;
    Exit;
  end;

  { The decimal point is a point, not the machine's separator: this is reading
    a file that came from somewhere else. }
  Fmt := DefaultFormatSettings;
  Fmt.DecimalSeparator := '.';
  if TryStrToFloat(AValue, Dbl, Fmt) then
    Exit(ckDouble);

  { ISO dates and timestamps only. A file written as 03/04/2026 is ambiguous
    in a way no importer can settle, so it stays text rather than being read
    as one of the two possible days. }
  Fmt.DateSeparator := '-';
  Fmt.ShortDateFormat := 'yyyy-mm-dd';
  Fmt.TimeSeparator := ':';
  if (Length(AValue) = 10) and TryStrToDate(AValue, Dt, Fmt) then
    Exit(ckDate);
  if (Length(AValue) >= 19) and (Length(AValue) <= 23) and
     TryStrToDateTime(AValue, Dt, Fmt) then
    Exit(ckTimestamp);

  Result := ckText;
end;

{ The kind that holds both. Anything mixed with text is text, and a date mixed
  with a number is text too - they have nothing in common that keeps both. }
function WidenKind(A, B: TCsvColumnKind): TCsvColumnKind;
begin
  if A = B then
    Exit(A);
  if (A in [ckInteger, ckBigInt]) and (B in [ckInteger, ckBigInt]) then
    Exit(ckBigInt);
  if (A in [ckInteger, ckBigInt, ckDouble]) and
     (B in [ckInteger, ckBigInt, ckDouble]) then
    Exit(ckDouble);
  if (A in [ckDate, ckTimestamp]) and (B in [ckDate, ckTimestamp]) then
    Exit(ckTimestamp);
  Result := ckText;
end;

function ColumnTypeSQL(const AColumn: TCsvColumn): String;
begin
  case AColumn.Kind of
    ckInteger:   Result := 'integer';
    ckBigInt:    Result := 'bigint';
    ckDouble:    Result := 'double precision';
    ckDate:      Result := 'date';
    ckTimestamp: Result := 'timestamp';
  else
    { At least one character, and never narrower than the widest value seen.
      Firebird's limit for a VARCHAR in a single-byte character set is 32765;
      anything longer than that has to be a blob, and an import that silently
      truncated would be worse than one that refuses. }
    if AColumn.Width <= 0 then
      Result := 'varchar(1)'
    else if AColumn.Width > 32765 then
      Result := 'blob sub_type text'
    else
      Result := 'varchar(' + IntToStr(AColumn.Width) + ')';
  end;
end;

constructor TCsvImportPlan.Create(const AOptions: TCsvOptions);
begin
  inherited Create;
  FOptions := AOptions;
  FRows := TList.Create;
end;

destructor TCsvImportPlan.Destroy;
var
  Idx: Integer;
begin
  for Idx := 0 to FRows.Count - 1 do
    TStringList(FRows[Idx]).Free;
  FRows.Free;
  inherited Destroy;
end;

function TCsvImportPlan.GetColumn(Index: Integer): TCsvColumn;
begin
  Result := FColumns[Index];
end;

function TCsvImportPlan.GetColumnCount: Integer;
begin
  Result := Length(FColumns);
end;

function TCsvImportPlan.GetRow(Index: Integer): TStringList;
begin
  Result := TStringList(FRows[Index]);
end;

function TCsvImportPlan.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function TCsvImportPlan.CreateTableSQL(const ATableName: String): String;
var
  Idx: Integer;
begin
  Result := 'create table ' + MakeQuotedIdent(ATableName, True, 3) + ' (' + #13#10;
  for Idx := 0 to High(FColumns) do
  begin
    Result := Result + '  ' + MakeQuotedIdent(FColumns[Idx].Name, True, 3) +
      ' ' + ColumnTypeSQL(FColumns[Idx]);
    if Idx < High(FColumns) then
      Result := Result + ',';
    Result := Result + #13#10;
  end;
  Result := Result + ');';
end;

function TCsvImportPlan.InsertSQL(const ATableName: String; ARow: Integer): String;
var
  Idx: Integer;
  Cols, Vals, Value_: String;
  Row: TStringList;
begin
  Result := '';
  if (ARow < 0) or (ARow >= FRows.Count) then
    Exit;
  Row := TStringList(FRows[ARow]);
  Cols := '';
  Vals := '';
  for Idx := 0 to High(FColumns) do
  begin
    if Cols <> '' then
    begin
      Cols := Cols + ', ';
      Vals := Vals + ', ';
    end;
    Cols := Cols + MakeQuotedIdent(FColumns[Idx].Name, True, 3);

    if Idx < Row.Count then
      Value_ := Row[Idx]
    else
      { A short row is missing values, not holding empty ones. }
      Value_ := '';

    if Trim(Value_) = '' then
      Vals := Vals + 'null'
    else if FColumns[Idx].Kind in [ckInteger, ckBigInt, ckDouble] then
      Vals := Vals + Trim(Value_)
    else
      { Quoted, with the quotes inside it doubled - the same rule as
        everywhere else, and here it stands between a stray apostrophe in a
        spreadsheet and a script that will not run. }
      Vals := Vals + '''' +
        StringReplace(Value_, '''', '''''', [rfReplaceAll]) + '''';
  end;
  Result := 'insert into ' + MakeQuotedIdent(ATableName, True, 3) +
    ' (' + Cols + ') values (' + Vals + ');';
end;

{ A column name a spreadsheet would produce is not always one Firebird will
  take. What is kept is what an identifier may hold; everything else becomes an
  underscore, and a name that starts with a digit or ends up empty is given a
  prefix rather than being refused. }
function SafeColumnName(const AName: String; AIndex: Integer): String;
var
  Idx: Integer;
  Ch: Char;
begin
  Result := '';
  for Idx := 1 to Length(AName) do
  begin
    Ch := AName[Idx];
    if (Ch in ['A'..'Z', 'a'..'z', '0'..'9', '_', '$']) then
      Result := Result + Ch
    else
      Result := Result + '_';
  end;
  Result := Trim(Result);
  if (Result = '') or (Result[1] in ['0'..'9']) then
    Result := 'COLUMN' + IntToStr(AIndex + 1) + Result;
  { Firebird 4 and later allow 63; before that 31. The shorter limit is the
    safe one to cut at, since a name that fits everywhere fits. }
  if Length(Result) > 31 then
    Result := Copy(Result, 1, 31);
  Result := UpperCase(Result);
end;

function PlanCsvImport(ALines: TStrings; const AOptions: TCsvOptions): TCsvImportPlan;
var
  LineIdx, ColIdx, FirstDataLine, Widest: Integer;
  Fields: TStringList;
  Names: TStringList;
  Kind: TCsvColumnKind;
  Seen: array of Boolean;
begin
  Result := TCsvImportPlan.Create(AOptions);
  if not Assigned(ALines) or (ALines.Count = 0) then
    Exit;

  { The names first, from the first line or made up. }
  Names := ParseCsvLine(ALines[0], AOptions);
  try
    SetLength(Result.FColumns, Names.Count);
    SetLength(Seen, Names.Count);
    for ColIdx := 0 to Names.Count - 1 do
    begin
      if AOptions.FirstRowIsNames then
        Result.FColumns[ColIdx].Name := SafeColumnName(Names[ColIdx], ColIdx)
      else
        Result.FColumns[ColIdx].Name := 'COLUMN' + IntToStr(ColIdx + 1);
      Result.FColumns[ColIdx].Kind := ckInteger;
      Result.FColumns[ColIdx].Width := 0;
      Seen[ColIdx] := False;
    end;
  finally
    Names.Free;
  end;

  if AOptions.FirstRowIsNames then
    FirstDataLine := 1
  else
    FirstDataLine := 0;

  for LineIdx := FirstDataLine to ALines.Count - 1 do
  begin
    { A trailing newline leaves an empty last line, which is not a row of
      empty values. }
    if Trim(ALines[LineIdx]) = '' then
      Continue;
    Fields := ParseCsvLine(ALines[LineIdx], AOptions);
    Result.FRows.Add(Fields);

    for ColIdx := 0 to Fields.Count - 1 do
    begin
      { A file may have a row with more fields than the header. Those columns
        have no name and nowhere to go, so they are left out rather than
        silently renaming everything after them. }
      if ColIdx > High(Result.FColumns) then
        Break;
      Widest := Length(Fields[ColIdx]);
      if Widest > Result.FColumns[ColIdx].Width then
        Result.FColumns[ColIdx].Width := Widest;
      { An empty value says nothing about the type - a column of numbers with
        a gap in it is still a column of numbers. }
      if Trim(Fields[ColIdx]) = '' then
        Continue;
      Kind := KindOfValue(Trim(Fields[ColIdx]));
      if not Seen[ColIdx] then
      begin
        Result.FColumns[ColIdx].Kind := Kind;
        Seen[ColIdx] := True;
      end
      else
        Result.FColumns[ColIdx].Kind :=
          WidenKind(Result.FColumns[ColIdx].Kind, Kind);
    end;
  end;

  { A column that was never given a value at all is text: there is nothing to
    say it is a number, and text takes whatever arrives later. }
  for ColIdx := 0 to High(Result.FColumns) do
    if not Seen[ColIdx] then
      Result.FColumns[ColIdx].Kind := ckText;
end;

end.
