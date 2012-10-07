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
// $Id: MarathonToolsAPIDocForm.pas,v 1.3 2005/05/20 19:24:09 rjmills Exp $

unit MarathonToolsAPIDocForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  BaseDocumentForm, GimbalToolsAPI, GimbalToolsAPIImpl, Menus;

type
  TfrmMarathonToolsDocForm = class(TfrmBaseDocumentForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    IT : TMenuItem;
    FForm: TGimbalIDEMarathonForm;
    procedure WindowListClick(Sender: TObject);
  public
    { Public declarations }
    procedure MinMaxInfo(var Message : TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    destructor Destroy; override;
    property FormInterface : TGimbalIDEMarathonForm read FForm write FForm;
  end;

var
  frmMarathonToolsDocForm: TfrmMarathonToolsDocForm;

implementation

{$R *.DFM}

uses
  MarathonIDE, 
  Globals;

{ TForm1 }

procedure TfrmMarathonToolsDocForm.MinMaxInfo(var Message: TWMGetMinMaxInfo);
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

procedure TfrmMarathonToolsDocForm.FormCreate(Sender: TObject);
begin
  inherited;
  It := TMenuItem.Create(Self);
  It.Caption := '&1 Doc';
  It.OnClick := WindowListClick;
  MarathonIDEInstance.AddMenuToMainForm(IT);

  Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
  Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
  Height := (MarathonScreen.Height Div 2) + MarathonIDEInstance.MainForm.FormHeight;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;
end;

procedure TfrmMarathonToolsDocForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FForm) then
    if Assigned(FForm.DocInterface) then
      FForm.DocInterface.IDEOnClose;
  IT.Free;
  FForm := nil;
  Action := caFree;
  inherited;
end;

procedure TfrmMarathonToolsDocForm.WindowListClick(Sender: TObject);
begin
  if WindowState = wsMinimized then
    WindowState := wsNormal
  else
    BringToFront;
end;

procedure TfrmMarathonToolsDocForm.FormResize(Sender: TObject);
begin
  inherited;
  if Assigned(FForm) then
    if Assigned(FForm.DocInterface) then
      FForm.DocInterface.IDEOnResize;
end;

destructor TfrmMarathonToolsDocForm.Destroy;
begin
  inherited;
end;

end.

{
$Log: MarathonToolsAPIDocForm.pas,v $
Revision 1.3  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
