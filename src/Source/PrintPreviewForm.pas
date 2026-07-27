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
// $Id: PrintPreviewForm.pas,v 1.4 2006/10/22 06:04:28 rjmills Exp $

unit PrintPreviewForm;

{$MODE Delphi}

interface

uses {$IFDEF FPC} {$IFDEF WINDOWS}Windows,{$ENDIF} LCLIntf, LCLType, LMessages, Messages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, Printers, Dialogs, ExtCtrls, DBCtrls, Menus, ComCtrls, ToolWin, Buttons, ActnList, BaseDocumentForm, GlobalPrintingRoutines, PrintDocument;

type

	TfrmPrintPreview = class(TfrmBaseDocumentForm)
    stsPreview: TStatusBar;
    PopupMenu1: TPopupMenu;
    First1: TMenuItem;
    Last1: TMenuItem;
    Next1: TMenuItem;
    Lst1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    PageWidth1: TMenuItem;
    FullPage1: TMenuItem;
    Panel1: TPanel;
    btnPrint: TSpeedButton;
    btnFullPage: TSpeedButton;
    btnPageWidth: TSpeedButton;
    btnFirst: TSpeedButton;
    btnNext: TSpeedButton;
    btnPrevious: TSpeedButton;
    btnLast: TSpeedButton;
    Bevel1: TBevel;
    ActionList1: TActionList;
    actPrint: TAction;
    actPrintPreview: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actCaptureSnippet: TAction;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actSelectAll: TAction;
    actFind: TAction;
		actCompile: TAction;
		actExecute: TAction;
    actDrop: TAction;
    actCommit: TAction;
    actRollback: TAction;
    actFirst: TAction;
    actPrevious: TAction;
		actNext: TAction;
    actLast: TAction;
    actQueryBuilder: TAction;
    actPrevStatement: TAction;
    actNextStatement: TAction;
    actStatementHistory: TAction;
    pnlParent: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WindowListClick(Sender: TObject);
    procedure btnFullPageClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnPageWidthClick(Sender: TObject);
    procedure actLastExecute(Sender: TObject);
    procedure actPreviousExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actFirstExecute(Sender: TObject);
    procedure actFirstUpdate(Sender: TObject);
    procedure actPreviousUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actLastUpdate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
  private
    It : TMenuItem;
		FPrintObject: TfrmGlobalPrintingRoutines;
		{ The laid-out document and where in it we are. Owned here: the preview is
		  what keeps it alive once the routine that built it has returned. }
		FDocument: TPrintedDocument;
		FPageIndex: Integer;
		FCharsPerLine: Integer;
		FFullPage: Boolean;
		{ Built in code rather than streamed from the .lfm, so an existing form
		  layout does not have to be reworked to gain a page in the middle of it. }
		FScroll: TScrollBox;
		FPaper: TPaintBox;
		procedure PaperPaint(Sender: TObject);
		procedure ShowPage(Index: Integer);
		procedure LayoutPaper;
		{$IFDEF WINDOWS}procedure MinMaxInfo(var Message : TWMGetMinMaxInfo); message WM_GETMINMAXINFO;{$ENDIF}
		procedure UpdateStatus;
	public
		{ Public declarations }
		property PrintObject : TfrmGlobalPrintingRoutines read FPrintObject write FPrintObject;
		{ Hands the preview the document to show. Taken over, not copied - the
		  caller must not free it.

		  Not called ShowDocument: the base form already has one of those, which
		  puts the form in a tab, and this form needs both. }
		procedure LoadDocument(ADocument: TPrintedDocument; CharsPerLine: Integer);
		{ How many pages there are and which one is on show. Read-only: the way to
		  move is through the navigation actions, which also update the status
		  bar. }
		function PageCount: Integer;
		function CurrentPage: TPrintPage;
		{ How wide the sheet is being drawn, which is what the two zoom buttons
		  change. Read-only, and only exposed so the harness can tell them
		  apart. }
		function PaperWidth: Integer;
		property PageIndex: Integer read FPageIndex;
	end;

implementation

uses Globals, HelpMap, MarathonIDE, PrintRenderer;

{$R *.lfm}

{$IFDEF WINDOWS}
procedure TfrmPrintPreview.MinMaxInfo(var Message : TWMGetMinMaxInfo);
var
  wMonitor : TMonitor;
  wMarathonMonitor : TMonitor;
begin
  inherited;
  wMarathonMonitor := MarathonScreen.GetMonitor;
  if self.Monitor.MonitorNum = wMarathonMonitor.MonitorNum then //same screen as the IDE main window
  begin
     wMonitor := screen.monitors[self.Monitor.MonitorNum];
     Message.MinMaxInfo.ptMaxSize.X := wMonitor.Width + (GetSystemMetrics(SM_CXSIZEFRAME) * 2);
     Message.MinMaxInfo.ptMaxSize.y := wMonitor.Height - (MarathonIDEInstance.MainForm.FormHeight + abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop));
     Message.MinMaxInfo.ptMaxPosition.Y := abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop) + MarathonIDEInstance.MainForm.FormHeight;
  end;
end;
{$ENDIF}

procedure TfrmPrintPreview.WindowListClick(Sender: TObject);
begin
  if WindowState = wsMinimized then
    WindowState := wsNormal
  else
    BringToFront;
end;

procedure TfrmPrintPreview.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Print_Preview;
	FCharsPerLine := 96;
	FFullPage := True;
	FScroll := TScrollBox.Create(Self);
	FScroll.Parent := Self;
	FScroll.Align := alClient;
	FScroll.Color := clAppWorkspace;
	FScroll.HorzScrollBar.Tracking := True;
	FScroll.VertScrollBar.Tracking := True;
	FPaper := TPaintBox.Create(Self);
	FPaper.Parent := FScroll;
	FPaper.OnPaint := PaperPaint;
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight;
	Left := (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height Div 2) + MarathonIDEInstance.MainForm.FormHeight;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;
end;

procedure TfrmPrintPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FPrintObject) then
  begin
    PrintObject.Free;
    PrintObject := nil;
  end;
  It.Free;
  FreeAndNil(FDocument);
  Action := caFree;
  inherited;
end;

procedure TfrmPrintPreview.btnFullPageClick(Sender: TObject);
begin
	FFullPage := True;
	LayoutPaper;
end;

procedure TfrmPrintPreview.btnPrintClick(Sender: TObject);
begin
	actPrintExecute(Sender);
end;

procedure TfrmPrintPreview.btnPageWidthClick(Sender: TObject);
begin
	FFullPage := False;
	LayoutPaper;
end;

procedure TfrmPrintPreview.actLastExecute(Sender: TObject);
begin
	if Assigned(FDocument) then
		ShowPage(FDocument.PageCount - 1);
  UpdateStatus;
end;

procedure TfrmPrintPreview.actPreviousExecute(Sender: TObject);
begin
	ShowPage(FPageIndex - 1);
  UpdateStatus;
end;

procedure TfrmPrintPreview.actNextExecute(Sender: TObject);
begin
	ShowPage(FPageIndex + 1);
  UpdateStatus;
end;

procedure TfrmPrintPreview.actFirstExecute(Sender: TObject);
begin
	ShowPage(0);
  UpdateStatus;
end;

procedure TfrmPrintPreview.actFirstUpdate(Sender: TObject);
begin
	actFirst.Enabled := Assigned(FDocument) and (FPageIndex > 0);
end;

procedure TfrmPrintPreview.actPreviousUpdate(Sender: TObject);
begin
	actPrevious.Enabled := Assigned(FDocument) and (FPageIndex > 0);
end;

procedure TfrmPrintPreview.actNextUpdate(Sender: TObject);
begin
	actNext.Enabled := Assigned(FDocument) and (FPageIndex < FDocument.PageCount - 1);
end;

procedure TfrmPrintPreview.actLastUpdate(Sender: TObject);
begin
	actLast.Enabled := Assigned(FDocument) and (FPageIndex < FDocument.PageCount - 1);
end;

procedure TfrmPrintPreview.FormResize(Sender: TObject);
begin
	LayoutPaper;
	UpdateStatus;
end;

procedure TfrmPrintPreview.FormShow(Sender: TObject);
begin
	LayoutPaper;
  UpdateStatus;
end;

procedure TfrmPrintPreview.UpdateStatus;
begin
	if not Assigned(FDocument) or (FDocument.PageCount = 0) then
		stsPreview.Panels[0].Text := 'Nothing to preview.'
	else
		stsPreview.Panels[0].Text := 'Page ' + IntToStr(FPageIndex + 1) +
			' of ' + IntToStr(FDocument.PageCount);
end;

procedure TfrmPrintPreview.LoadDocument(ADocument: TPrintedDocument;
	CharsPerLine: Integer);
begin
	FDocument.Free;
	FDocument := ADocument;
	FCharsPerLine := CharsPerLine;
	FPageIndex := 0;
	LayoutPaper;
	UpdateStatus;
end;

function TfrmPrintPreview.PageCount: Integer;
begin
	if Assigned(FDocument) then
		Result := FDocument.PageCount
	else
		Result := 0;
end;

function TfrmPrintPreview.PaperWidth: Integer;
begin
	if Assigned(FPaper) then
		Result := FPaper.Width
	else
		Result := 0;
end;

function TfrmPrintPreview.CurrentPage: TPrintPage;
begin
	Result := nil;
	if Assigned(FDocument) and (FPageIndex >= 0) and
	   (FPageIndex < FDocument.PageCount) then
		Result := FDocument[FPageIndex];
end;

procedure TfrmPrintPreview.ShowPage(Index: Integer);
begin
	if not Assigned(FDocument) or (FDocument.PageCount = 0) then
		Exit;
	if Index < 0 then
		Index := 0;
	if Index > FDocument.PageCount - 1 then
		Index := FDocument.PageCount - 1;
	FPageIndex := Index;
	if Assigned(FPaper) then
		FPaper.Invalidate;
	UpdateStatus;
end;

{ Sizes the sheet inside the scroll box. Page Width fills the window and lets
  the page run off the bottom; Full Page fits the whole sheet, which is what
  the two toolbar buttons have always offered and never done. }
procedure TfrmPrintPreview.LayoutPaper;
var
	Avail, W, H: Integer;
const
	{ A4's proportions. The preview draws a sheet, not the printer's exact page:
	  asking a possibly-absent printer for its geometry to decide how big to
	  draw a rectangle is a lot of failure for very little fidelity. }
	PageRatio = 1.414;
begin
	if not Assigned(FScroll) or not Assigned(FPaper) then
		Exit;
	Avail := FScroll.ClientWidth - 24;
	if Avail < 100 then
		Avail := 100;
	if FFullPage then
	begin
		H := FScroll.ClientHeight - 24;
		if H < 100 then
			H := 100;
		W := Round(H / PageRatio);
		if W > Avail then
		begin
			W := Avail;
			H := Round(W * PageRatio);
		end;
	end
	else
	begin
		W := Avail;
		H := Round(W * PageRatio);
	end;
	FPaper.SetBounds(12, 12, W, H);
	FPaper.Invalidate;
end;

procedure TfrmPrintPreview.PaperPaint(Sender: TObject);
var
	R: TRect;
	Margin: Integer;
begin
	{ The sheet itself, so the preview looks like paper rather than like a
	  window with text in it. }
	FPaper.Canvas.Brush.Color := clWhite;
	FPaper.Canvas.FillRect(0, 0, FPaper.Width, FPaper.Height);
	FPaper.Canvas.Pen.Color := clGray;
	FPaper.Canvas.Frame(0, 0, FPaper.Width, FPaper.Height);

	if not Assigned(FDocument) or (FDocument.PageCount = 0) then
		Exit;
	Margin := Round(FPaper.Width * 0.05);
	R := Rect(Margin, Margin, FPaper.Width - Margin, FPaper.Height - Margin);
	RenderPage(FPaper.Canvas, FDocument[FPageIndex], R, FCharsPerLine);
end;

procedure TfrmPrintPreview.actPrintExecute(Sender: TObject);
begin
	if not Assigned(FDocument) then
		Exit;
	if not PrintToPrinter(FDocument, Caption, FCharsPerLine) then
		MessageDlg('There is no printer configured to print to.', mtInformation,
			[mbOK], 0);
end;

end.

{
$Log: PrintPreviewForm.pas,v $
Revision 1.4  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.3  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
