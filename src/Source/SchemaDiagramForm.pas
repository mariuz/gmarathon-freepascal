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

unit SchemaDiagramForm;

{$MODE Delphi}

{ The schema designer: the tables of a database and the keys between them.

  The VS Code MSSQL extension calls this a Schema Designer and it was the one
  substantial thing on its list Marathon had no answer to. Reading the
  catalogue is SchemaDiagramIO's job and where the boxes go is SchemaDiagram's;
  both are checked without a canvas. This draws them.

  Everything is drawn on one paint box rather than made of child controls, for
  the reason the query builder gives: boxes that are drawn can be dragged and
  hit-tested with arithmetic, where boxes made of controls need the parent to
  arbitrate every mouse event between them. }

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, IBDatabase, BaseDocumentForm, SchemaDiagram;

type
  TfrmSchemaDiagram = class(TfrmBaseDocumentForm)
    pnlTop: TPanel;
    lblInfo: TLabel;
    btnRelayout: TButton;
    scrDiagram: TScrollBox;
    pbDiagram: TPaintBox;
    stbStatus: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRelayoutClick(Sender: TObject);
    procedure pbDiagramPaint(Sender: TObject);
    procedure pbDiagramMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure pbDiagramMouseMove(Shift: TShiftState; X, Y: Integer);
    procedure pbDiagramMouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
  private
    FDiagram: TSchemaDiagram;
    FConnectionName: String;
    FDragTable: TDiagramTable;
    FDragDX, FDragDY: Integer;
    procedure Relayout;
    procedure SizeCanvas;
  public
    { Reads the database and lays the diagram out. }
    procedure LoadFrom(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
      const AConnectionName, ASchema: String; ASupportsSchemas: Boolean);
    property Diagram: TSchemaDiagram read FDiagram;
    function GetActiveConnectionName: String; override;
  end;

implementation

{$R *.lfm}

uses SchemaDiagramIO;

const
  BoxWidth = 168;
  RowHeight = 14;
  HeaderHeight = 20;
  { How many columns a box shows before it stops growing. A table of two
    hundred columns would otherwise be taller than any window and push
    everything else off the diagram. }
  MaxRows = 10;

procedure TfrmSchemaDiagram.FormCreate(Sender: TObject);
begin
  FDiagram := TSchemaDiagram.Create;
end;

procedure TfrmSchemaDiagram.FormDestroy(Sender: TObject);
begin
  FDiagram.Free;
end;

function TfrmSchemaDiagram.GetActiveConnectionName: String;
begin
  Result := FConnectionName;
end;

procedure TfrmSchemaDiagram.LoadFrom(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction; const AConnectionName, ASchema: String;
  ASupportsSchemas: Boolean);
begin
  FConnectionName := AConnectionName;
  FDiagram.Free;
  FDiagram := ReadSchemaDiagram(ADatabase, ATransaction, ASchema,
    ASupportsSchemas);
  Caption := 'Schema: ' + AConnectionName;
  Relayout;
end;

procedure TfrmSchemaDiagram.Relayout;
begin
  if not Assigned(FDiagram) then
    Exit;
  { Laid out to the width of the visible area, so a diagram opens readable and
    only scrolls downwards. }
  LayoutDiagram(FDiagram, scrDiagram.ClientWidth, BoxWidth, RowHeight,
    HeaderHeight);
  SizeCanvas;
  stbStatus.SimpleText := IntToStr(FDiagram.TableCount) + ' table(s), ' +
    IntToStr(FDiagram.LinkCount) + ' foreign key(s), ' +
    IntToStr(FDiagram.IsolatedCount) + ' in no relationship';
  pbDiagram.Invalidate;
end;

procedure TfrmSchemaDiagram.SizeCanvas;
var
  W, H: Integer;
begin
  DiagramExtent(FDiagram, W, H);
  { A margin past the furthest box, so a table dragged to the edge can still be
    dropped somewhere. }
  pbDiagram.SetBounds(0, 0, W + 40, H + 40);
end;

procedure TfrmSchemaDiagram.btnRelayoutClick(Sender: TObject);
begin
  Relayout;
end;

procedure TfrmSchemaDiagram.pbDiagramPaint(Sender: TObject);
var
  Idx, Row, Y, Rows: Integer;
  T, Other: TDiagramTable;
  L: TDiagramLink;
  C: TCanvas;
  X1, Y1, X2, Y2: Integer;
begin
  C := pbDiagram.Canvas;
  C.Brush.Color := clWindow;
  C.FillRect(0, 0, pbDiagram.Width, pbDiagram.Height);
  if not Assigned(FDiagram) then
    Exit;

  { The keys first, so a box drawn over a line hides its end rather than the
    line crossing the box. }
  C.Pen.Color := clGray;
  for Idx := 0 to FDiagram.LinkCount - 1 do
  begin
    L := FDiagram.Links[Idx];
    T := FDiagram.FindTable(L.FromTable);
    Other := FDiagram.FindTable(L.ToTable);
    if not Assigned(T) or not Assigned(Other) or (T = Other) then
      Continue;
    X1 := T.Left + T.Width div 2;
    Y1 := T.Top + T.Height div 2;
    X2 := Other.Left + Other.Width div 2;
    Y2 := Other.Top + Other.Height div 2;
    C.Line(X1, Y1, X2, Y2);
  end;

  for Idx := 0 to FDiagram.TableCount - 1 do
  begin
    T := FDiagram.Tables[Idx];
    C.Brush.Color := clBtnFace;
    C.Pen.Color := clBlack;
    C.Rectangle(T.Left, T.Top, T.Left + T.Width, T.Top + T.Height);

    C.Brush.Color := clHighlight;
    C.Font.Color := clHighlightText;
    C.FillRect(T.Left + 1, T.Top + 1, T.Left + T.Width - 1,
      T.Top + HeaderHeight);
    C.TextOut(T.Left + 4, T.Top + 3, T.Name);

    C.Brush.Color := clBtnFace;
    C.Font.Color := clWindowText;
    Rows := T.Columns.Count;
    if Rows > MaxRows then
      Rows := MaxRows;
    for Row := 0 to Rows - 1 do
    begin
      Y := T.Top + HeaderHeight + Row * RowHeight;
      C.TextOut(T.Left + 6, Y, T.Columns[Row]);
    end;
    if T.Columns.Count > MaxRows then
      C.TextOut(T.Left + 6, T.Top + HeaderHeight + Rows * RowHeight,
        '... ' + IntToStr(T.Columns.Count - MaxRows) + ' more');
  end;
end;

procedure TfrmSchemaDiagram.pbDiagramMouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragTable := TableAt(FDiagram, X, Y);
  if Assigned(FDragTable) then
  begin
    FDragDX := X - FDragTable.Left;
    FDragDY := Y - FDragTable.Top;
    stbStatus.SimpleText := FDragTable.Name + ' - ' +
      IntToStr(FDragTable.Columns.Count) + ' column(s)';
  end;
end;

procedure TfrmSchemaDiagram.pbDiagramMouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  if not Assigned(FDragTable) then
    Exit;
  FDragTable.Left := X - FDragDX;
  FDragTable.Top := Y - FDragDY;
  { Not off the top or left, where it could never be reached again. }
  if FDragTable.Left < 0 then
    FDragTable.Left := 0;
  if FDragTable.Top < 0 then
    FDragTable.Top := 0;
  pbDiagram.Invalidate;
end;

procedure TfrmSchemaDiagram.pbDiagramMouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FDragTable) then
    { The canvas may need to grow: a table dragged past the old extent would
      otherwise be drawn outside it and unreachable. }
    SizeCanvas;
  FDragTable := nil;
  pbDiagram.Invalidate;
end;

end.
