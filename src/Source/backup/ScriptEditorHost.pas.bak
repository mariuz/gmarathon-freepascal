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
// $Id: ScriptEditorHost.pas,v 1.3 2005/05/20 19:24:09 rjmills Exp $

unit ScriptEditorHost;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Menus, ComCtrls, Registry, ClipBrd, ExtCtrls,	Buttons, ActnList,
	BaseDocumentForm,
	MarathonInternalInterfaces;

type
  TScriptHostTabSheet = class(TTabSheet)
  private
    FScriptRecorder: IMarathonScriptRecorder;
  public
    property ScriptRecorder : IMarathonScriptRecorder read FScriptRecorder write FScriptRecorder;
  end;

  TfrmScriptEditorHost = class(TfrmBaseDocumentForm, IMarathonRecScriptHost)
    pgMacro: TPageControl;
    stsScript: TStatusBar;
    tmrRecord: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pgMacroChange(Sender: TObject);
  private
    { Private declarations }
    It : TMenuItem;
    procedure WindowListClick(Sender: TObject);
    procedure MinMaxInfo(var Message : TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    function GetStatusBar : TObject;
  public
    { Public declarations }
    function InternalCloseQuery : Boolean; override;
    procedure UpdateConnections;

    function CanInternalClose : Boolean; override;
    procedure DoInternalClose; override;

    function CanSave : Boolean; override;
    procedure DoSave; override;

    function CanSaveAs : Boolean; override;
    procedure DoSaveAs; override;

    function CanStopScriptRecord : Boolean; override;
    procedure DoStopScriptRecord; override;

		function CanStartScriptRecord : Boolean; override;
		procedure DoStartScriptRecord; override;

		function CanNewScriptRecord : Boolean; override;
		procedure DoNewScriptRecord; override;

		function CanAppendExistingScript : Boolean; override;
		procedure DoAppendExistingScript; override;
	end;

implementation

{$R *.DFM}

uses
	Globals,
	HelpMap,
	MarathonIDE,
	MarathonProjectCache;

procedure TfrmScriptEditorHost.MinMaxInfo(var Message : TWMGetMinMaxInfo);
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


procedure TfrmScriptEditorHost.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
  else
    BringToFront;
end;

procedure TfrmScriptEditorHost.FormCreate(Sender: TObject);
var
  R : TRect;
  Idx : Integer;
  T : TScriptHostTabSheet;

begin
  inherited;
  HelpContext := IDH_SQL_Script_Recording;

  Top := MarathonScreen.Top + Trunc((MarathonScreen.Height Div 3) * 2);
  Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;

  if SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0) then
    Height := R.Bottom - Top;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;

  It := TMenuItem.Create(Self);
  It.Caption := '&1 Script Recorder';
  It.OnClick := WindowListClick;
  MarathonIDEInstance.AddMenuToMainForm(IT);


  //load all of the script windows...
  for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
  begin
    T := TScriptHostTabSheet.Create(Self);
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.pnlBase.Parent := T;
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.Clear;
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.HostEditor := Self;
    T.ScriptRecorder := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder;
    T.PageControl := pgMacro;
    T.Caption := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption;
  end;
	if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.UpdateStatus;
end;

procedure TfrmScriptEditorHost.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  Idx : Integer;
begin
  for Idx := 0 to pgMacro.PageCount - 1 do
  begin
    TScriptHostTabSheet(pgMacro.Pages[Idx]).ScriptRecorder := nil;
  end;
  //put all of the script windows back
  for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
  begin
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.DoStopScriptRecord;
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.ClearFileName;
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.HostEditor := nil;
    MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.pnlBase.Parent := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder;
  end;
  Action := caFree;
  inherited;
end;

procedure TfrmScriptEditorHost.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if not FByPassClose then
		CanClose := InternalCloseQuery
	else
		CanCLose := True;
end;

function TfrmScriptEditorHost.InternalCloseQuery: Boolean;
begin
	Result := True;
end;

procedure TfrmScriptEditorHost.UpdateConnections;
var
	Idx : Integer;
	Current : String;
	T : TScriptHostTabSheet;
begin
	for Idx := 0 to pgMacro.PageCount - 1 do
	begin
		TScriptHostTabSheet(pgMacro.Pages[Idx]).ScriptRecorder := nil;
	end;
	Current := pgMacro.ActivePage.Caption;
	//put all of the script windows back
	for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
	begin
		MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.pnlBase.Parent := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder;
	end;

	//clear the page control...
	for Idx := 0 to pgMacro.PageCount - 1 do
	begin
		pgMacro.Pages[Idx].Free;
	end;
	//load all of the script windows...
	for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
	begin
		T := TScriptHostTabSheet.Create(Self);
		MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.pnlBase.Parent := T;
		MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.Clear;
		MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder.HostEditor := Self;
		T.ScriptRecorder := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].ScriptRecorder;
		T.PageControl := pgMacro;
		T.Caption := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption;
	end;

  for Idx := 0 to pgMacro.PageCount - 1 do
  begin
    if pgMacro.Pages[Idx].Caption = Current then
    begin
      pgMacro.ActivePage := pgMacro.Pages[Idx];
    end;
  end;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.UpdateStatus;
end;

function TfrmScriptEditorHost.CanAppendExistingScript: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanAppendExistingScript
  else
    Result := False;
end;

function TfrmScriptEditorHost.CanInternalClose: Boolean;
begin
  Result := True;
end;

function TfrmScriptEditorHost.CanNewScriptRecord: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanNewScriptRecord
  else
    Result := False;
end;

function TfrmScriptEditorHost.CanSave: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanSave
  else
    Result := False;
end;

function TfrmScriptEditorHost.CanSaveAs: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanSaveAs
  else
    Result := False;
end;

function TfrmScriptEditorHost.CanStartScriptRecord: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanStartScriptRecord
  else
    Result := False;
end;

function TfrmScriptEditorHost.CanStopScriptRecord: Boolean;
begin
  if Assigned(pgMacro.ActivePage) then
    Result := TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.CanStopScriptRecord
  else
    Result := False;
end;

procedure TfrmScriptEditorHost.DoAppendExistingScript;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoAppendExistingScript;
end;

procedure TfrmScriptEditorHost.DoInternalClose;
begin
  inherited;
  Close;
end;

procedure TfrmScriptEditorHost.DoNewScriptRecord;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoNewScriptRecord;
end;

procedure TfrmScriptEditorHost.DoSave;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoSave;
end;

procedure TfrmScriptEditorHost.DoSaveAs;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoSaveAs;
end;

procedure TfrmScriptEditorHost.DoStartScriptRecord;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoStartScriptRecord;
end;

procedure TfrmScriptEditorHost.DoStopScriptRecord;
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.DoStopScriptRecord;
end;

function TfrmScriptEditorHost.GetStatusBar: TObject;
begin
  Result := stsScript;
end;

procedure TfrmScriptEditorHost.pgMacroChange(Sender: TObject);
begin
  inherited;
  if Assigned(pgMacro.ActivePage) then
    TScriptHostTabSheet(pgMacro.ActivePage).ScriptRecorder.UpdateStatus;
end;

end.

{
$Log: ScriptEditorHost.pas,v $
Revision 1.3  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
