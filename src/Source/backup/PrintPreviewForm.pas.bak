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

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, Printers, Dialogs, ExtCtrls, DBCtrls, Menus, ComCtrls,
	ToolWin, Buttons, ActnList,
	PagePrnt,
	BaseDocumentFOrm,
	GlobalPrintingRoutines;

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
		procedure MinMaxInfo(var Message : TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
		procedure UpdateStatus;
	public
		{ Public declarations }
		property PrintObject : TfrmGlobalPrintingRoutines read FPrintObject write FPrintObject;
	end;

implementation

uses
	Globals,
	HelpMap,
	//MarathonMain,
  MarathonIDE;

{$R *.DFM}

procedure TfrmPrintPreview.MinMaxInfo(var Message : TWMGetMinMaxInfo);
var
  wRect : TRect;
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
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight;
	Left := (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height Div 2) + MarathonIDEInstance.MainForm.FormHeight;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;
end;

procedure TfrmPrintPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FPrintObject) then
  begin
    FPrintObject.pnlBase.Parent := PrintObject;
    PrintObject.Free;
    PrintObject := nil;
  end;
  It.Free;
  Action := caFree;
  inherited;
end;

procedure TfrmPrintPreview.btnFullPageClick(Sender: TObject);
begin
  PrintObject.ppPrinter.ZoomToFit;
end;

procedure TfrmPrintPreview.btnPrintClick(Sender: TObject);
begin
  PrintObject.ppPrinter.Print;
end;

procedure TfrmPrintPreview.btnPageWidthClick(Sender: TObject);
begin
  PrintObject.ppPrinter.ZoomToWidth;
end;

procedure TfrmPrintPreview.actLastExecute(Sender: TObject);
begin
	PrintObject.ppPrinter.PageNumber := PrintObject.ppPrinter.PageCount;
  UpdateStatus;
end;

procedure TfrmPrintPreview.actPreviousExecute(Sender: TObject);
begin
  if PrintObject.ppPrinter.PageNumber - 1 > 0 then
    PrintObject.ppPrinter.PageNumber := PrintObject.ppPrinter.PageNumber - 1;
  UpdateStatus;
end;

procedure TfrmPrintPreview.actNextExecute(Sender: TObject);
begin
  if PrintObject.ppPrinter.PageNumber + 1 <= PrintObject.ppPrinter.PageCount then
    PrintObject.ppPrinter.PageNumber := PrintObject.ppPrinter.PageNumber + 1;
  UpdateStatus;
end;

procedure TfrmPrintPreview.actFirstExecute(Sender: TObject);
begin
  PrintObject.ppPrinter.PageNumber := 1;
  UpdateStatus;
end;

procedure TfrmPrintPreview.actFirstUpdate(Sender: TObject);
begin
  actFirst.Enabled := PrintObject.ppPrinter.PageNumber > 1;
end;

procedure TfrmPrintPreview.actPreviousUpdate(Sender: TObject);
begin
  actPrevious.Enabled := PrintObject.ppPrinter.PageNumber > 1;
end;

procedure TfrmPrintPreview.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := PrintObject.ppPrinter.PageNumber < PrintObject.ppPrinter.PageCount;
end;

procedure TfrmPrintPreview.actLastUpdate(Sender: TObject);
begin
  actLast.Enabled := PrintObject.ppPrinter.PageNumber < PrintObject.ppPrinter.PageCount;
end;

procedure TfrmPrintPreview.FormResize(Sender: TObject);
begin
  if Assigned(PrintObject) then
  begin
    PrintObject.ppPrinter.ZoomToFit;
    UpdateStatus;
  end;  
end;

procedure TfrmPrintPreview.FormShow(Sender: TObject);
begin
  UpdateStatus;
end;

procedure TfrmPrintPreview.UpdateStatus;
begin
  stsPreview.Panels[0].Text := 'Page ' + IntToStr(PrintObject.ppPrinter.PageNumber) +
                               ' of ' + IntToStr(PrintObject.ppPrinter.PageCount) + ' page(s)';
end;

procedure TfrmPrintPreview.actPrintExecute(Sender: TObject);
begin
  PrintObject.ppPrinter.Print;
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
