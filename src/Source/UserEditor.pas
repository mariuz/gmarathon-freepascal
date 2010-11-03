{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************} 
// $Id: UserEditor.pas,v 1.6 2006/10/22 06:04:28 rjmills Exp $

unit UserEditor;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, Grids, DBGrids, DBCtrls, StdCtrls,	ExtCtrls, ClipBrd,
	Spin, ActnList, Tabs,
	rmTabs3x,
	IB_Components,
	IBODataset;

type
	TfrmUsers = class(TForm)
		stsUsers: TStatusBar;
		pgUsers: TPageControl;
		tsUserView: TTabSheet;
    qryUser: TIBOQuery;
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
		actFindNext: TAction;
		actReplace: TAction;
		actClose: TAction;
		actSaveToFile: TAction;
		actOpenFromFile: TAction;
		dbSecurity: TIB_Connection;
		tranSecurity: TIB_Transaction;
    qrySecurity: TIBOQuery;
		Splitter1: TSplitter;
		Panel1: TPanel;
		tabGrants: TrmTabSet;
		ListView1: TListView;
		actQueryBuilder: TAction;
		actPrevStatement: TAction;
		actNextStatement: TAction;
		actStatementHistory: TAction;
    actWindowUserEditor: TAction;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure actCloseExecute(Sender: TObject);
		procedure pgUsersChange(Sender: TObject);
		procedure WindowListClick(Sender: TObject);
	private
		{ Private declarations }
		FByPass: Boolean;
		FModified: Boolean;
		procedure MinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
	public
		It: TMenuItem;
		procedure DropClose;
	end;

const
	PG_GENERATOR		= 0;
	PG_DDL					= 1;

implementation

uses
	Globals,
	HelpMap,
	//MarathonMain,
  MarathonIDE,
	SecureDBLogin;

{$R *.DFM}

procedure TfrmUsers.MinMaxInfo(var Message: TWMGetMinMaxInfo);
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

procedure TfrmUsers.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmUsers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
end;

procedure TfrmUsers.FormCreate(Sender: TObject);
var
	F: TfrmSecureConnect;

begin
	pgUsers.ActivePage := tsUserView;
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

//	It := TMenuItem.Create(Self);
//	It.Caption := '&1 User Editor';
//	It.OnClick := WindowListClick;
	MarathonIDEInstance.MainForm.AddMenuItem(actWindowUserEditor);
  // Window1_old.Add(It); //rjm - tbmenufix

	Show;
	Refresh;
	// Try to connect to the security database
	while True do
	begin
		F := TfrmSecureConnect.Create(Self);
		try
			if F.ShowModal = mrOK then
			begin
				dbSecurity.DatabaseName := F.edDBName.Text;
				dbSecurity.UserName := F.edUserName.Text;
				dbSecurity.Password := F.edPassword.Text;
			end
			else
				Break;
		finally
			F.Free;
		end;

		try
			dbSecurity.Connect;
			Break;
		except
			on E: Exception do
			begin
				if MessageDlg('Could not connect to Security Database: ' + E.Message + #13#10#13#10 +
					'Would you like to try again?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
					Break;
			end;
		end;
	end;
	try
		if dbSecurity.Connected then
		begin
			// Get a list of the users from the security database
			qrySecurity.SQL.Text := '';
			qrySecurity.Open;

			if not (qrySecurity.Eof and qrySecurity.Bof) then
				while not qrySecurity.EOF do
					qrySecurity.Next;
		end;
	except
		on E: Exception do
			MessageDlg(E.Message, mtError, [mbOK], 0);
	end;
end;

procedure TfrmUsers.FormCloseQuery(Sender: TObject;	var CanClose: Boolean);
begin
	if not FByPass Then
		if FModified then
			if MessageDlg('Exit without saving changes?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
			begin
				CanClose := False;
				Exit;
			end;
end;

procedure TfrmUsers.DropClose;
begin
	FByPass := True;
	Close;
end;

procedure TfrmUsers.actCloseExecute(Sender: TObject);
begin
	Close;
end;

procedure TfrmUsers.pgUsersChange(Sender: TObject);
begin
	case pgUsers.ActivePage.PageIndex of
		PG_GENERATOR:
			begin
				// Blank the panels
				stsUsers.Panels[0].Text := '';
				stsUsers.Panels[1].Text := '';
				stsUsers.Panels[2].Text := '';
			end;

		PG_DDL:
			begin
				// Blank the panels
				stsUsers.Panels[0].Text := '';
				stsUsers.Panels[1].Text := '';
				stsUsers.Panels[2].Text := '';
			end;
	end;
end;

end.

{
$Log: UserEditor.pas,v $
Revision 1.6  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.5  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.4  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.3  2002/04/29 14:25:40  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
