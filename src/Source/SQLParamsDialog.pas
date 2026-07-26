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
  SysUtils, Classes, Controls, Forms, StdCtrls, Grids;

type
  TfrmSQLParams = class(TForm)
    grdParams: TStringGrid;
    btnOK: TButton;
    btnCancel: TButton;
    lblPrompt: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    function RowOf(Index: Integer): Integer;
  public
    { Builds a row per parameter. Values start empty and non-NULL, so a user
      who just presses OK gets empty strings rather than silent NULLs. }
    procedure SetParameters(Names: TStrings);
    function ParameterCount: Integer;
    function ValueOf(Index: Integer): String;
    function IsNullAt(Index: Integer): Boolean;
    { For callers that want to pre-fill, and for tests. }
    procedure SetValue(Index: Integer; const Value: String; Null: Boolean);
  end;

const
  { Grid columns. Column 0 is the fixed row header the grid draws itself. }
  colParamName = 1;
  colParamValue = 2;
  colParamNull = 3;

implementation

{$R *.lfm}

procedure TfrmSQLParams.FormCreate(Sender: TObject);
begin
  grdParams.ColCount := 4;
  grdParams.FixedCols := 1;
  grdParams.FixedRows := 1;
  grdParams.RowCount := 1;
  grdParams.Cells[colParamName, 0] := 'Parameter';
  grdParams.Cells[colParamValue, 0] := 'Value';
  grdParams.Cells[colParamNull, 0] := 'NULL';
  grdParams.ColWidths[0] := 24;
  grdParams.ColWidths[colParamName] := 150;
  grdParams.ColWidths[colParamValue] := 230;
  grdParams.ColWidths[colParamNull] := 50;
  grdParams.Options := grdParams.Options + [goEditing, goColSizing, goRowSelect] -
    [goRowSelect];
end;

function TfrmSQLParams.RowOf(Index: Integer): Integer;
begin
  Result := Index + 1;
end;

procedure TfrmSQLParams.SetParameters(Names: TStrings);
var
  Idx: Integer;
begin
  grdParams.RowCount := Names.Count + 1;
  for Idx := 0 to Names.Count - 1 do
  begin
    grdParams.Cells[colParamName, RowOf(Idx)] := Names[Idx];
    grdParams.Cells[colParamValue, RowOf(Idx)] := '';
    grdParams.Cells[colParamNull, RowOf(Idx)] := '';
  end;
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
