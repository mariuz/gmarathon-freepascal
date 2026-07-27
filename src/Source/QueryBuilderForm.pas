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

unit QueryBuilderForm;

{$MODE Delphi}

{ The visual query builder.

  This replaces QBuilder.pas, which was 2819 lines of Delphi drawing its own
  table boxes with raw Polygon calls, handling WM_ messages by hand and calling
  ClipCursor to trap the mouse while dragging. None of that survives a move to
  the LCL, so it was dropped from the program - the unit stayed in the tree but
  not in marathon.lpr, and the four menu items that opened it were commented
  out.

  What is here is smaller because almost none of it is here. Deciding what SQL
  a set of tables, joins and columns amounts to is QueryModel's job, and it is
  tested without a widgetset; this draws boxes, works out what was clicked, and
  shows the result.

  Everything is drawn on one paint box rather than made of child controls, as
  the original did. Boxes that are drawn can be dragged, hit-tested and joined
  with arithmetic; boxes made of controls need the parent to arbitrate every
  mouse event between them, which is where the original's WM_ handling and its
  cursor clipping came from. }

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Grids, Menus, IBDatabase, QueryModel;

type
  { Where a table's box sits on the canvas and which of its columns are ticked.
    Kept alongside the model rather than in it, because a position is a fact
    about the picture and the model has to stay free of the LCL. }
  TTableBox = class
  public
    Alias: String;
    Left, Top, Width, Height: Integer;
    Columns: TStringList;
    destructor Destroy; override;
  end;

  TfrmQueryBuilder = class(TForm)
    pnlLeft: TPanel;
    lblTables: TLabel;
    lstTables: TListBox;
    btnAdd: TButton;
    splLeft: TSplitter;
    pnlCanvas: TPanel;
    pbCanvas: TPaintBox;
    splBottom: TSplitter;
    pnlBottom: TPanel;
    pgBottom: TPageControl;
    tsColumns: TTabSheet;
    grdColumns: TStringGrid;
    tsSQL: TTabSheet;
    memSQL: TMemo;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    chkDistinct: TCheckBox;
    lblWarning: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure lstTablesDblClick(Sender: TObject);
    procedure pbCanvasPaint(Sender: TObject);
    procedure pbCanvasMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure pbCanvasMouseMove(Shift: TShiftState; X, Y: Integer);
    procedure pbCanvasMouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure grdColumnsEditingDone(Sender: TObject);
    procedure chkDistinctClick(Sender: TObject);
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FModel: TQueryModel;
    FBoxes: TList;
    { What the mouse is doing. Dragging a box moves it; dragging from a column
      draws a join line to wherever the mouse is and makes a join if it lands
      on another table's column. }
    FDragBox: TTableBox;
    FDragDX, FDragDY: Integer;
    FJoinFrom: TTableBox;
    FJoinFromColumn: Integer;
    FJoinToX, FJoinToY: Integer;
    function BoxAt(X, Y: Integer): TTableBox;
    function BoxOf(const AAlias: String): TTableBox;
    { Which column row of the box that Y falls on, or -1 for its caption. }
    function ColumnAt(Box: TTableBox; Y: Integer): Integer;
    function ColumnY(Box: TTableBox; Index: Integer): Integer;
    procedure AddTableToCanvas(const ATableName: String);
    procedure LoadColumnsOf(const ATableName: String; Into: TStringList);
    procedure RefreshGrid;
    procedure RefreshSQL;
    procedure Refresh_;
  public
    { The connection to read table and column names from. }
    procedure LoadFrom(ADatabase: TIBDatabase; ATransaction: TIBTransaction);
    { What the user built, once the dialog has been accepted. }
    function SQL: String;
    property Model: TQueryModel read FModel;
  end;

{ Opens the builder and returns the SQL, or '' if it was cancelled. }
function BuildQuery(ADatabase: TIBDatabase; ATransaction: TIBTransaction): String;

implementation

{$R *.lfm}

uses IBQuery, SchemaObjects;

const
  BoxWidth = 150;
  RowHeight = 16;
  CaptionHeight = 20;
  { How many column rows a box shows before it stops growing. A table of 200
    columns would otherwise be taller than the screen and impossible to join
    to anything. }
  MaxVisibleRows = 12;

destructor TTableBox.Destroy;
begin
  Columns.Free;
  inherited Destroy;
end;

function BuildQuery(ADatabase: TIBDatabase; ATransaction: TIBTransaction): String;
var
  F: TfrmQueryBuilder;
begin
  Result := '';
  F := TfrmQueryBuilder.Create(nil);
  try
    F.LoadFrom(ADatabase, ATransaction);
    if F.ShowModal = mrOK then
      Result := F.SQL;
  finally
    F.Free;
  end;
end;

procedure TfrmQueryBuilder.FormCreate(Sender: TObject);
begin
  FModel := TQueryModel.Create;
  FBoxes := TList.Create;
  grdColumns.RowCount := 1;
  grdColumns.Cells[0, 0] := 'Column';
  grdColumns.Cells[1, 0] := 'Output name';
  grdColumns.Cells[2, 0] := 'Sort';
  grdColumns.Cells[3, 0] := 'Condition';
end;

procedure TfrmQueryBuilder.FormDestroy(Sender: TObject);
var
  Idx: Integer;
begin
  for Idx := 0 to FBoxes.Count - 1 do
    TTableBox(FBoxes[Idx]).Free;
  FBoxes.Free;
  FModel.Free;
end;

procedure TfrmQueryBuilder.LoadFrom(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction);
var
  Names: TStringList;
begin
  FDatabase := ADatabase;
  FTransaction := ATransaction;
  lstTables.Items.Clear;
  if not Assigned(FDatabase) or not FDatabase.Connected then
    Exit;
  { The same listing the object tree uses, so the builder offers what the tree
    shows. }
  Names := ListSchemaObjects(FDatabase, FTransaction, sokTable, '', False);
  try
    lstTables.Items.Assign(Names);
  finally
    Names.Free;
  end;
end;

procedure TfrmQueryBuilder.LoadColumnsOf(const ATableName: String;
  Into: TStringList);
var
  Q: TIBQuery;
begin
  Into.Clear;
  if not Assigned(FDatabase) or not FDatabase.Connected then
    Exit;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    { The shared metadata transaction is committed constantly by the object
      tree, so this may well arrive on a closed one. }
    Q.AllowAutoActivateTransaction := True;
    Q.SQL.Text := 'select rdb$field_name from rdb$relation_fields ' +
      'where rdb$relation_name = :name order by rdb$field_position';
    Q.ParamByName('name').AsString := ATableName;
    try
      Q.Open;
      while not Q.EOF do
      begin
        Into.Add(Trim(Q.Fields[0].AsString));
        Q.Next;
      end;
    except
      { A table whose columns cannot be read still gets a box, so the user can
        see it arrived and remove it. }
      on E: Exception do
        Into.Clear;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmQueryBuilder.AddTableToCanvas(const ATableName: String);
var
  Table: TQueryTable;
  Box: TTableBox;
  Rows: Integer;
begin
  if Trim(ATableName) = '' then
    Exit;
  Table := FModel.AddTable('', Trim(ATableName));
  Box := TTableBox.Create;
  Box.Alias := Table.Alias;
  Box.Columns := TStringList.Create;
  LoadColumnsOf(Trim(ATableName), Box.Columns);

  Rows := Box.Columns.Count;
  if Rows > MaxVisibleRows then
    Rows := MaxVisibleRows;
  Box.Width := BoxWidth;
  Box.Height := CaptionHeight + Rows * RowHeight + 4;
  { Laid out left to right in the order they are added, wrapping when the row
    is full - so dropping six tables does not stack them all on one spot. }
  Box.Left := 12 + (FBoxes.Count mod 4) * (BoxWidth + 24);
  Box.Top := 12 + (FBoxes.Count div 4) * 140;
  FBoxes.Add(Box);
  Refresh_;
end;

procedure TfrmQueryBuilder.btnAddClick(Sender: TObject);
begin
  if lstTables.ItemIndex >= 0 then
    AddTableToCanvas(lstTables.Items[lstTables.ItemIndex]);
end;

procedure TfrmQueryBuilder.lstTablesDblClick(Sender: TObject);
begin
  btnAddClick(Sender);
end;

function TfrmQueryBuilder.BoxOf(const AAlias: String): TTableBox;
var
  Idx: Integer;
begin
  Result := nil;
  for Idx := 0 to FBoxes.Count - 1 do
    if SameText(TTableBox(FBoxes[Idx]).Alias, AAlias) then
      Exit(TTableBox(FBoxes[Idx]));
end;

function TfrmQueryBuilder.BoxAt(X, Y: Integer): TTableBox;
var
  Idx: Integer;
  Box: TTableBox;
begin
  Result := nil;
  { Backwards, so the box drawn last - the one on top - is the one hit. }
  for Idx := FBoxes.Count - 1 downto 0 do
  begin
    Box := TTableBox(FBoxes[Idx]);
    if (X >= Box.Left) and (X < Box.Left + Box.Width) and
       (Y >= Box.Top) and (Y < Box.Top + Box.Height) then
      Exit(Box);
  end;
end;

function TfrmQueryBuilder.ColumnAt(Box: TTableBox; Y: Integer): Integer;
begin
  Result := (Y - Box.Top - CaptionHeight) div RowHeight;
  if (Result < 0) or (Result >= Box.Columns.Count) or
     (Result >= MaxVisibleRows) then
    Result := -1;
end;

function TfrmQueryBuilder.ColumnY(Box: TTableBox; Index: Integer): Integer;
begin
  Result := Box.Top + CaptionHeight + Index * RowHeight + RowHeight div 2;
end;

procedure TfrmQueryBuilder.pbCanvasPaint(Sender: TObject);
var
  Idx, J, Row, Y: Integer;
  Box, Other: TTableBox;
  C: TCanvas;
  Join: TQueryJoin;
  X1, Y1, X2, Y2: Integer;
  Ticked: Boolean;
begin
  C := pbCanvas.Canvas;
  C.Brush.Color := clWindow;
  C.FillRect(0, 0, pbCanvas.Width, pbCanvas.Height);

  { Join lines first, so a box drawn over one hides the end of it rather than
    the line crossing the box. }
  C.Pen.Color := clNavy;
  C.Pen.Width := 2;
  for J := 0 to FModel.JoinCount - 1 do
  begin
    Join := FModel.Joins[J];
    Box := BoxOf(Join.LeftAlias);
    Other := BoxOf(Join.RightAlias);
    if not Assigned(Box) or not Assigned(Other) then
      Continue;
    X1 := Box.Left + Box.Width;
    Y1 := ColumnY(Box, Box.Columns.IndexOf(Join.LeftColumn));
    X2 := Other.Left;
    Y2 := ColumnY(Other, Other.Columns.IndexOf(Join.RightColumn));
    C.Line(X1, Y1, X2, Y2);
  end;
  C.Pen.Width := 1;

  { The line being dragged, so there is something to aim with. }
  if Assigned(FJoinFrom) and (FJoinFromColumn >= 0) then
  begin
    C.Pen.Color := clGray;
    C.Line(FJoinFrom.Left + FJoinFrom.Width,
      ColumnY(FJoinFrom, FJoinFromColumn), FJoinToX, FJoinToY);
  end;

  for Idx := 0 to FBoxes.Count - 1 do
  begin
    Box := TTableBox(FBoxes[Idx]);
    C.Brush.Color := clBtnFace;
    C.Pen.Color := clBlack;
    C.Rectangle(Box.Left, Box.Top, Box.Left + Box.Width, Box.Top + Box.Height);

    C.Brush.Color := clHighlight;
    C.Font.Color := clHighlightText;
    C.FillRect(Box.Left + 1, Box.Top + 1, Box.Left + Box.Width - 1,
      Box.Top + CaptionHeight);
    C.TextOut(Box.Left + 4, Box.Top + 3,
      FModel.TableByAlias(Box.Alias).Name + ' (' + Box.Alias + ')');

    C.Brush.Color := clBtnFace;
    C.Font.Color := clWindowText;
    for Row := 0 to Box.Columns.Count - 1 do
    begin
      if Row >= MaxVisibleRows then
      begin
        C.TextOut(Box.Left + 4, Box.Top + CaptionHeight + Row * RowHeight,
          '...');
        Break;
      end;
      Y := Box.Top + CaptionHeight + Row * RowHeight;
      { A tick box, drawn rather than made of controls - see the unit note. }
      Ticked := False;
      for J := 0 to FModel.ColumnCount - 1 do
        if SameText(FModel.Columns[J].TableAlias, Box.Alias) and
           SameText(FModel.Columns[J].Name, Box.Columns[Row]) then
          Ticked := True;
      C.Brush.Color := clWindow;
      C.Rectangle(Box.Left + 4, Y + 2, Box.Left + 14, Y + 12);
      if Ticked then
      begin
        C.Pen.Color := clBlack;
        C.Line(Box.Left + 6, Y + 7, Box.Left + 8, Y + 10);
        C.Line(Box.Left + 8, Y + 10, Box.Left + 12, Y + 4);
      end;
      C.Brush.Color := clBtnFace;
      C.TextOut(Box.Left + 18, Y, Box.Columns[Row]);
    end;
  end;
end;

procedure TfrmQueryBuilder.pbCanvasMouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Box: TTableBox;
  Row, Idx: Integer;
  Found: Boolean;
begin
  Box := BoxAt(X, Y);
  if not Assigned(Box) then
    Exit;

  Row := ColumnAt(Box, Y);
  if Row < 0 then
  begin
    { The caption bar: drag the box. }
    FDragBox := Box;
    FDragDX := X - Box.Left;
    FDragDY := Y - Box.Top;
    Exit;
  end;

  if X < Box.Left + 16 then
  begin
    { The tick box: choose or unchoose the column. }
    Found := False;
    for Idx := FModel.ColumnCount - 1 downto 0 do
      if SameText(FModel.Columns[Idx].TableAlias, Box.Alias) and
         SameText(FModel.Columns[Idx].Name, Box.Columns[Row]) then
      begin
        Found := True;
        Break;
      end;
    if Found then
      { Unticking is removing it from the select list. There is no Remove on
        the model for one column, so the grid is the place that owns this - but
        a builder must be able to untick, so it is done by rebuilding. }
      FModel.Columns[Idx].Name := ''
    else
      FModel.AddColumn(Box.Alias, Box.Columns[Row]);
    Refresh_;
    Exit;
  end;

  { The column name: start dragging a join from it. }
  FJoinFrom := Box;
  FJoinFromColumn := Row;
  FJoinToX := X;
  FJoinToY := Y;
end;

procedure TfrmQueryBuilder.pbCanvasMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FDragBox) then
  begin
    FDragBox.Left := X - FDragDX;
    FDragBox.Top := Y - FDragDY;
    { Not off the top or left, where it could never be reached again. }
    if FDragBox.Left < 0 then
      FDragBox.Left := 0;
    if FDragBox.Top < 0 then
      FDragBox.Top := 0;
    pbCanvas.Invalidate;
  end
  else if Assigned(FJoinFrom) then
  begin
    FJoinToX := X;
    FJoinToY := Y;
    pbCanvas.Invalidate;
  end;
end;

procedure TfrmQueryBuilder.pbCanvasMouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Target: TTableBox;
  Row: Integer;
begin
  if Assigned(FJoinFrom) then
  begin
    Target := BoxAt(X, Y);
    if Assigned(Target) and (Target <> FJoinFrom) then
    begin
      Row := ColumnAt(Target, Y);
      if Row >= 0 then
      begin
        FModel.AddJoin(jkInner, FJoinFrom.Alias,
          FJoinFrom.Columns[FJoinFromColumn], Target.Alias, Target.Columns[Row]);
        Refresh_;
      end;
    end;
  end;
  FJoinFrom := nil;
  FJoinFromColumn := -1;
  FDragBox := nil;
  pbCanvas.Invalidate;
end;

procedure TfrmQueryBuilder.RefreshGrid;
var
  Idx, Row: Integer;
  Col: TQueryColumn;
begin
  grdColumns.RowCount := 1;
  for Idx := 0 to FModel.ColumnCount - 1 do
  begin
    Col := FModel.Columns[Idx];
    if Trim(Col.Name) = '' then
      Continue;
    Row := grdColumns.RowCount;
    grdColumns.RowCount := Row + 1;
    grdColumns.Cells[0, Row] := Col.TableAlias + '.' + Col.Name;
    grdColumns.Cells[1, Row] := Col.OutputName;
    case Col.Sort of
      soAscending:  grdColumns.Cells[2, Row] := 'asc';
      soDescending: grdColumns.Cells[2, Row] := 'desc';
    else
      grdColumns.Cells[2, Row] := '';
    end;
    grdColumns.Cells[3, Row] := Col.Filter;
    { So a row edited in the grid can be put back on the right column even
      after unticked ones have been skipped. }
    grdColumns.Objects[0, Row] := TObject(PtrInt(Idx));
  end;
end;

procedure TfrmQueryBuilder.grdColumnsEditingDone(Sender: TObject);
var
  Row, Idx: Integer;
  Sort: String;
begin
  for Row := 1 to grdColumns.RowCount - 1 do
  begin
    Idx := PtrInt(grdColumns.Objects[0, Row]);
    if (Idx < 0) or (Idx >= FModel.ColumnCount) then
      Continue;
    FModel.Columns[Idx].OutputName := Trim(grdColumns.Cells[1, Row]);
    FModel.Columns[Idx].Filter := Trim(grdColumns.Cells[3, Row]);
    Sort := AnsiLowerCase(Trim(grdColumns.Cells[2, Row]));
    if Copy(Sort, 1, 1) = 'a' then
      FModel.Columns[Idx].Sort := soAscending
    else if Copy(Sort, 1, 1) = 'd' then
      FModel.Columns[Idx].Sort := soDescending
    else
      FModel.Columns[Idx].Sort := soNone;
  end;
  RefreshSQL;
end;

procedure TfrmQueryBuilder.chkDistinctClick(Sender: TObject);
begin
  FModel.Distinct := chkDistinct.Checked;
  RefreshSQL;
end;

procedure TfrmQueryBuilder.RefreshSQL;
begin
  memSQL.Lines.Text := SQL;
  { An unjoined table multiplies the row count by its whole length, which looks
    like a hung query rather than a mistake - so it is said out loud. }
  if (FModel.TableCount > 1) and not IsFullyJoined(FModel) then
    lblWarning.Caption :=
      'A table is not joined to the others: every row will be paired with every row.'
  else
    lblWarning.Caption := '';
end;

procedure TfrmQueryBuilder.Refresh_;
begin
  pbCanvas.Invalidate;
  RefreshGrid;
  RefreshSQL;
end;

function TfrmQueryBuilder.SQL: String;
var
  Idx: Integer;
  Clean: TQueryModel;
  Col: TQueryColumn;
  Table: TQueryTable;
  New_: TQueryColumn;
begin
  { Unticked columns are left in the model with an empty name rather than
    removed, so the grid rows keep their indices while it is being edited.
    They must not reach the SQL, so the statement is built from a copy without
    them. }
  Clean := TQueryModel.Create;
  try
    Clean.Distinct := FModel.Distinct;
    Clean.QuoteIdentifiers := FModel.QuoteIdentifiers;
    for Idx := 0 to FModel.TableCount - 1 do
    begin
      Table := Clean.AddTable(FModel.Tables[Idx].Schema, FModel.Tables[Idx].Name);
      { The alias has to be the one the joins and columns already name, not a
        fresh one worked out from the table name again. }
      Table.Alias := FModel.Tables[Idx].Alias;
    end;
    for Idx := 0 to FModel.JoinCount - 1 do
      Clean.AddJoin(FModel.Joins[Idx].Kind, FModel.Joins[Idx].LeftAlias,
        FModel.Joins[Idx].LeftColumn, FModel.Joins[Idx].RightAlias,
        FModel.Joins[Idx].RightColumn);
    for Idx := 0 to FModel.ColumnCount - 1 do
    begin
      Col := FModel.Columns[Idx];
      if Trim(Col.Name) = '' then
        Continue;
      New_ := Clean.AddColumn(Col.TableAlias, Col.Name);
      New_.OutputName := Col.OutputName;
      New_.Sort := Col.Sort;
      New_.Filter := Col.Filter;
    end;
    Result := BuildSelectSQL(Clean);
  finally
    Clean.Free;
  end;
end;

end.
