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

unit SQLParamsDialog;

{$MODE Delphi}

{ Collects values for the parameters of a statement about to be run.

  Without this, a statement containing parameters executes with every one of
  them unbound, which Firebird takes as NULL - silently. That matters because
  the "Script as ..." generators deliberately emit parameter placeholders
  (insert ... values (:ID), execute procedure P(:A)), so the common path from
  the object tree produced a statement that appeared to run and did nothing
  useful.

  Deliberately knows nothing about IBX: it works in parameter *names* and
  string values, and the caller does the binding. That keeps it testable
  without a database. }

interface

uses
  {$IFDEF FPC} LCLIntf, LCLType, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Controls, Forms, StdCtrls, Grids, Dialogs;

type
  { What a parameter will accept. The caller derives this from the prepared
    statement; the dialog only needs to know how to check a typed-in value, so
    it stays free of any IBX type. }
  TSQLParamKind = (pkText, pkInteger, pkDecimal, pkDate, pkTime, pkDateTime,
    pkBoolean);

  TfrmSQLParams = class(TForm)
    grdParams: TStringGrid;
    btnOK: TButton;
    btnCancel: TButton;
    lblPrompt: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FKinds: array of TSQLParamKind;
    function RowOf(Index: Integer): Integer;
    function ValueIsValid(Index: Integer; out Complaint: String): Boolean;
  public
    { True when every row would pass the check OK applies. Exposed so the rule
      can be exercised without driving the button. }
    function AcceptsValues: Boolean;
    { Builds a row per parameter. Values start empty and non-NULL, so a user
      who just presses OK gets empty strings rather than silent NULLs. }
    { Names, and optionally what each will accept plus a type name to show.
      Kinds and TypeNames may be shorter than Names, in which case the rest are
      treated as free text. }
    procedure SetParameters(Names: TStrings); overload;
    procedure SetParameters(Names: TStrings; const Kinds: array of TSQLParamKind;
      TypeNames: TStrings); overload;
    function KindOf(Index: Integer): TSQLParamKind;
    function ParameterCount: Integer;
    function ValueOf(Index: Integer): String;
    function IsNullAt(Index: Integer): Boolean;
    { For callers that want to pre-fill, and for tests. }
    procedure SetValue(Index: Integer; const Value: String; Null: Boolean);
  end;

const
  { Grid columns. Column 0 is the fixed row header the grid draws itself. }
  colParamName = 1;
  colParamType = 2;
  colParamValue = 3;
  colParamNull = 4;

implementation

{$R *.lfm}

procedure TfrmSQLParams.FormCreate(Sender: TObject);
begin
  grdParams.ColCount := 5;
  grdParams.FixedCols := 1;
  grdParams.FixedRows := 1;
  grdParams.RowCount := 1;
  grdParams.Cells[colParamName, 0] := 'Parameter';
  grdParams.Cells[colParamType, 0] := 'Type';
  grdParams.Cells[colParamValue, 0] := 'Value';
  grdParams.Cells[colParamNull, 0] := 'NULL';
  grdParams.ColWidths[0] := 24;
  grdParams.ColWidths[colParamName] := 120;
  grdParams.ColWidths[colParamType] := 90;
  grdParams.ColWidths[colParamValue] := 190;
  grdParams.ColWidths[colParamNull] := 45;
  grdParams.Options := grdParams.Options + [goEditing, goColSizing, goRowSelect] -
    [goRowSelect];
end;

function TfrmSQLParams.RowOf(Index: Integer): Integer;
begin
  Result := Index + 1;
end;

procedure TfrmSQLParams.SetParameters(Names: TStrings);
begin
  SetParameters(Names, [], nil);
end;

procedure TfrmSQLParams.SetParameters(Names: TStrings;
  const Kinds: array of TSQLParamKind; TypeNames: TStrings);
var
  Idx: Integer;
begin
  grdParams.RowCount := Names.Count + 1;
  SetLength(FKinds, Names.Count);
  for Idx := 0 to Names.Count - 1 do
  begin
    grdParams.Cells[colParamName, RowOf(Idx)] := Names[Idx];
    grdParams.Cells[colParamValue, RowOf(Idx)] := '';
    grdParams.Cells[colParamNull, RowOf(Idx)] := '';
    if Idx <= High(Kinds) then
      FKinds[Idx] := Kinds[Idx]
    else
      FKinds[Idx] := pkText;
    if Assigned(TypeNames) and (Idx < TypeNames.Count) then
      grdParams.Cells[colParamType, RowOf(Idx)] := TypeNames[Idx]
    else
      grdParams.Cells[colParamType, RowOf(Idx)] := '';
  end;
end;

function TfrmSQLParams.KindOf(Index: Integer): TSQLParamKind;
begin
  if (Index >= 0) and (Index <= High(FKinds)) then
    Result := FKinds[Index]
  else
    Result := pkText;
end;

{ Rejects a value the database is certain to refuse, so the user finds out here
  rather than through a conversion error after the statement has been sent.
  Deliberately permissive: anything it cannot judge is let through, because a
  dialog that blocks a legal value is worse than one that misses an illegal
  one. }
function TfrmSQLParams.ValueIsValid(Index: Integer; out Complaint: String): Boolean;
var
  Text: String;
  I: Int64;
  D: Double;
  T: TDateTime;
begin
  Result := True;
  Complaint := '';
  if IsNullAt(Index) then
    Exit;
  Text := Trim(ValueOf(Index));
  { An empty value is a legal empty string for text, and for anything else it
    is the user not having filled it in yet - which the database will complain
    about more precisely than this dialog can. }
  if Text = '' then
    Exit;

  case KindOf(Index) of
    pkInteger:
      if not TryStrToInt64(Text, I) then
        Complaint := 'a whole number';
    pkDecimal:
      if not TryStrToFloat(Text, D) then
        Complaint := 'a number';
    pkDate:
      if not TryStrToDate(Text, T) then
        Complaint := 'a date';
    pkTime:
      if not TryStrToTime(Text, T) then
        Complaint := 'a time';
    pkDateTime:
      if not TryStrToDateTime(Text, T) then
        Complaint := 'a date and time';
    pkBoolean:
      if not (SameText(Text, 'true') or SameText(Text, 'false') or
              (Text = '1') or (Text = '0')) then
        Complaint := 'true or false';
  end;
  Result := Complaint = '';
end;

function TfrmSQLParams.AcceptsValues: Boolean;
var
  Idx: Integer;
  Complaint: String;
begin
  Result := True;
  for Idx := 0 to ParameterCount - 1 do
    if not ValueIsValid(Idx, Complaint) then
    begin
      Result := False;
      Exit;
    end;
end;

procedure TfrmSQLParams.btnOKClick(Sender: TObject);
var
  Idx: Integer;
  Complaint: String;
begin
  for Idx := 0 to ParameterCount - 1 do
    if not ValueIsValid(Idx, Complaint) then
    begin
      MessageDlg(grdParams.Cells[colParamName, RowOf(Idx)] + ' needs ' + Complaint +
        ', or tick NULL.', mtWarning, [mbOK], 0);
      grdParams.Row := RowOf(Idx);
      grdParams.Col := colParamValue;
      { Leaves the dialog open. }
      ModalResult := mrNone;
      Exit;
    end;
  ModalResult := mrOK;
end;

function TfrmSQLParams.ParameterCount: Integer;
begin
  Result := grdParams.RowCount - 1;
end;

function TfrmSQLParams.ValueOf(Index: Integer): String;
begin
  Result := grdParams.Cells[colParamValue, RowOf(Index)];
end;

{ Anything other than an empty cell in the NULL column means NULL - the column
  is a checkbox, and a checked LCL checkbox cell reads back as '1'. }
function TfrmSQLParams.IsNullAt(Index: Integer): Boolean;
begin
  Result := Trim(grdParams.Cells[colParamNull, RowOf(Index)]) <> '';
end;

procedure TfrmSQLParams.SetValue(Index: Integer; const Value: String; Null: Boolean);
begin
  grdParams.Cells[colParamValue, RowOf(Index)] := Value;
  if Null then
    grdParams.Cells[colParamNull, RowOf(Index)] := '1'
  else
    grdParams.Cells[colParamNull, RowOf(Index)] := '';
end;

end.
