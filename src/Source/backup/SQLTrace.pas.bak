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
// $Id: SQLTrace.pas,v 1.6 2005/05/20 19:24:09 rjmills Exp $

unit SQLTrace;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Menus, ComCtrls, Registry, ClipBrd, ExtCtrls, Buttons,
	IB_Components,
	IB_Monitor,
	SynEdit,
  SynEditTypes,
	SyntaxMemoWithStuff2,
	BaseDocumentForm;

type
	TfrmSQLTrace = class(TfrmBaseDocumentForm)
		pgMacro: TPageControl;
		stsScript: TStatusBar;
		tsEdit: TTabSheet;
		edTrace: TSyntaxMemoWithStuff2;
		dlgSave: TSaveDialog;
		trcSQL: TIB_Monitor;
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure edTraceChange(Sender: TObject);
		procedure trcSQLMonitorOutputItem(Sender: TObject; const NewString: String);
	private
		{ Private declarations }
		It: TMenuItem;
		procedure WindowListClick(Sender: TObject);
		procedure MinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
	public
		{ Public declarations }
		FFileName: String;

		function CanClearBuffer: Boolean; override;
		procedure DoClearBuffer; override;

		function CanCopy: Boolean; override;
		procedure DoCopy; override;

		function CanFind: Boolean; override;
		procedure DoFind; override;

		function CanFindNext: Boolean; override;
		procedure DoFindNext; override;

		function CanSelectAll: Boolean; override;
		procedure DoSelectAll;  override;

		function CanSaveAs: Boolean; override;
		procedure DoSaveAs; override;
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE;

{$R *.DFM}

function TfrmSQLTrace.CanClearBuffer: Boolean;
begin
	Result := edTrace.Lines.Count > 0;
end;

procedure TfrmSQLTrace.DoClearBuffer;
begin
	edTrace.Clear;
end;

function TfrmSQLTrace.CanCopy: Boolean;
begin
	Result := Length(edTrace.SelText) > 0;
end;

procedure TfrmSQLTrace.DoCopy;
begin
	edTrace.CopyToClipboard;
end;

function TfrmSQLTrace.CanFind: Boolean;
begin
	Result := edTrace.Lines.Count > 0;
end;

procedure TfrmSQLTrace.DoFind;
begin
	edTrace.WSFind;
end;

function TfrmSQLTrace.CanFindNext: Boolean;
begin
	Result := edTrace.Lines.Count > 0;
end;

procedure TfrmSQLTrace.DoFindNext;
begin
	edTrace.WSFindNext;
end;

function TfrmSQLTrace.CanSelectAll: Boolean;
begin
	Result := edTrace.Lines.Count > 0;
end;

procedure TfrmSQLTrace.DoSelectAll;
begin
	edTrace.SelectAll;
end;

function TfrmSQLTrace.CanSaveAs: Boolean;
begin
	Result := edTrace.Lines.Count > 0;
end;

procedure TfrmSQLTrace.DoSaveAs;
begin
	if dlgSave.Execute then
	begin
		FFileName := dlgSave.FileName;
		DoSave;
	end;
end;

procedure TfrmSQLTrace.MinMaxInfo(var Message: TWMGetMinMaxInfo);
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

procedure TfrmSQLTrace.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
	inherited;
	Action := caFree;
end;

procedure TfrmSQLTrace.FormCreate(Sender: TObject);
var
	R: TRect;

begin
	HelpContext := IDH_SQL_Trace;

	edTrace.Clear;

	Top := MarathonScreen.Top + Trunc((MarathonScreen.Height div 3) * 2);
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;

	if SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0) then
		Height := R.Bottom - Top;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

	SetupNonSyntaxEditor(edTrace);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 SQL Trace';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);

	// Set the SQL Trace monitor groups
	if gTraceConnection then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgConnection]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgConnection];
	if gTraceStatement then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgTransaction]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgTransaction];
	if gTraceStatement then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgStatement]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgStatement];
	if gTraceRow then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgRow]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgRow];
	if gTraceBlob then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgBlob]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgBlob];
	if gTraceArray then
		trcSQL.MonitorGroups := trcSQL.MonitorGroups + [mgArray]
	else
		trcSQL.MonitorGroups := trcSQL.MonitorGroups - [mgArray];

	// Set the SQL Trace statement groups
	if gTraceAllocate then
		trcSQL.StatementGroups := trcSQL.StatementGroups + [sgAllocate]
	else
		trcSQL.StatementGroups := trcSQL.StatementGroups - [sgAllocate];
	if gTracePrepare then
		trcSQL.StatementGroups := trcSQL.StatementGroups + [sgPrepare]
	else
		trcSQL.StatementGroups := trcSQL.StatementGroups - [sgPrepare];
	if gTraceExecute then
		trcSQL.StatementGroups := trcSQL.StatementGroups + [sgExecute]
	else
		trcSQL.StatementGroups := trcSQL.StatementGroups - [sgExecute];
	if gTraceExecuteImmediate then
		trcSQL.StatementGroups := trcSQL.StatementGroups + [sgExecuteImmediate]
	else
		trcSQL.StatementGroups := trcSQL.StatementGroups - [sgExecuteImmediate];
end;

procedure TfrmSQLTrace.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmSQLTrace.edTraceChange(Sender: TObject);
begin
	UpdateEditorStatusBar(stsScript, edTrace);
end;

procedure TfrmSQLTrace.trcSQLMonitorOutputItem(Sender: TObject;	const NewString: String);
var
	Idx: Integer;
	Tmp: TStringList;

begin
	Tmp := TStringList.Create;
	try
		Tmp.Text := NewString;
		edTrace.Text := edTrace.Text + #13#10;
		for Idx := 0 to Tmp.Count - 1 do
			if not (Pos('----------', Tmp[Idx]) > 0) then
				edTrace.Text := edTrace.Text + '    ' + Tmp[Idx];
		edTrace.BlockBegin := BufferCoord(Length(edTrace.Lines[edTrace.Lines.Count - 1]), edTrace.Lines.Count - 1);
	finally
		Tmp.Free;
	end;
end;

end.

{
$Log: SQLTrace.pas,v $
Revision 1.6  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.5  2005/04/13 16:04:31  rjmills
*** empty log message ***

Revision 1.4  2002/09/25 12:11:40  tmuetze
Revisited the 'Load from' and 'Save as' capabilities of the editors

Revision 1.3  2002/09/23 10:34:11  tmuetze
Revised the SQL Trace functionality, e.g. TIB_Monitor options can now be customized via the Option dialog

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
