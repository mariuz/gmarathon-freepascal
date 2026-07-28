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

unit GridColumnsDialog;

{$MODE Delphi}

{ Which columns the result grid shows, and how many stay put.

  GridLayout decides all of it - what may be hidden, what the freeze clamps to,
  and that something is always shown - and is checked without a window. This
  ticks the boxes and applies the answer to a grid.

  ApplyLayout is the only part that touches the LCL, and it is the reason this
  is not a purely cosmetic feature: a TDBGrid with no explicit Columns builds
  one per field and there is nothing to hide, so the columns have to be made
  before any of this means anything. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  CheckLst, Spin, DB, DBGrids, GridLayout;

type
  TfrmGridColumns = class(TForm)
    lblColumns: TLabel;
    lstColumns: TCheckListBox;
    lblFrozen: TLabel;
    edFrozen: TSpinEdit;
    btnAll: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FLayout: TGridLayout;
    procedure FillList;
  public
    { The layout being edited. Not owned - the grid's owner keeps it, so the
      choice survives the dialog closing. }
    procedure Edit(ALayout: TGridLayout);
  end;

{ Reads a dataset's fields into a layout, keeping what was already chosen when
  the columns are the same ones. }
procedure LayoutFromDataSet(ALayout: TGridLayout; ADataSet: TDataSet);

{ Builds the grid's columns from the layout: the visible ones in order, with
  the first few fixed.

  A TDBGrid with an empty Columns collection makes one column per field and
  offers no way to hide any of them, so this is where hiding becomes possible
  at all rather than a decoration on top of it. }
procedure ApplyLayout(AGrid: TDBGrid; ALayout: TGridLayout);

implementation

{$R *.lfm}

procedure LayoutFromDataSet(ALayout: TGridLayout; ADataSet: TDataSet);
var
  Names: TStringList;
  Idx: Integer;
  Same: Boolean;
begin
  if not Assigned(ALayout) or not Assigned(ADataSet) then
    Exit;
  Names := TStringList.Create;
  try
    for Idx := 0 to ADataSet.FieldCount - 1 do
      Names.Add(ADataSet.Fields[Idx].FieldName);

    { The same columns as last time means the same result set being looked at
      again - re-reading them would throw away a choice the user just made. }
    Same := Names.Count = ALayout.Count;
    if Same then
      for Idx := 0 to Names.Count - 1 do
        if Names[Idx] <> ALayout.Names[Idx] then
        begin
          Same := False;
          Break;
        end;
    if not Same then
      ALayout.SetColumns(Names);
  finally
    Names.Free;
  end;
end;

procedure ApplyLayout(AGrid: TDBGrid; ALayout: TGridLayout);
var
  Vis: TStringList;
  Idx: Integer;
  Col: TColumn;
begin
  if not Assigned(AGrid) or not Assigned(ALayout) then
    Exit;
  Vis := ALayout.VisibleNames;
  try
    AGrid.BeginUpdate;
    try
      { Down first. Clearing the columns takes the count to nothing while
        FixedCols still holds the last layout's freeze, and LCL raises
        "FixedCols can't be > ColCount" on the way through - which is a rebuild
        that worked once and threw the second time. }
      AGrid.FixedCols := 1;
      AGrid.Columns.Clear;
      for Idx := 0 to Vis.Count - 1 do
      begin
        Col := AGrid.Columns.Add;
        Col.FieldName := Vis[Idx];
        Col.Title.Caption := Vis[Idx];
      end;
      { LCL counts the row indicator as a fixed column, so the frozen columns
        are the ones after it. Setting this with no columns at all raises, and
        the layout guarantees there is at least one. }
      if Vis.Count > 0 then
        AGrid.FixedCols := ALayout.FrozenCount + 1;
    finally
      AGrid.EndUpdate;
    end;
  finally
    Vis.Free;
  end;
end;

procedure TfrmGridColumns.FillList;
var
  Idx: Integer;
begin
  lstColumns.Items.BeginUpdate;
  try
    lstColumns.Items.Clear;
    for Idx := 0 to FLayout.Count - 1 do
    begin
      lstColumns.Items.Add(FLayout.Names[Idx]);
      lstColumns.Checked[Idx] := FLayout.Visible[Idx];
    end;
  finally
    lstColumns.Items.EndUpdate;
  end;
  edFrozen.MaxValue := FLayout.Count;
  edFrozen.Value := FLayout.FrozenCount;
end;

procedure TfrmGridColumns.Edit(ALayout: TGridLayout);
begin
  FLayout := ALayout;
  FillList;
end;

procedure TfrmGridColumns.btnAllClick(Sender: TObject);
var
  Idx: Integer;
begin
  for Idx := 0 to lstColumns.Items.Count - 1 do
    lstColumns.Checked[Idx] := True;
end;

procedure TfrmGridColumns.btnOKClick(Sender: TObject);
var
  Idx: Integer;
begin
  { Show first, hide second: hiding refuses to take the last visible column,
    so doing it the other way round could refuse a hide that the shows which
    follow would have made legal. }
  for Idx := 0 to lstColumns.Items.Count - 1 do
    if lstColumns.Checked[Idx] then
      FLayout.Show(lstColumns.Items[Idx]);
  for Idx := 0 to lstColumns.Items.Count - 1 do
    if not lstColumns.Checked[Idx] then
      FLayout.Hide(lstColumns.Items[Idx]);
  { Set last, so it clamps against what is actually visible now. }
  FLayout.FrozenCount := edFrozen.Value;
  ModalResult := mrOK;
end;

end.
