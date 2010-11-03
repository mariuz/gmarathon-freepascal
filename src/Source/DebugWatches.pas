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
// $Id: DebugWatches.pas,v 1.2 2002/04/25 07:21:29 tmuetze Exp $

unit DebugWatches;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ActnList;

type
  TfrmWatches = class(TForm)
    lvWatches: TListView;
    actCallStack: TActionList;
    actStayOnTop: TAction;
    PopupMenu1: TPopupMenu;
    ViewSource1: TMenuItem;
    N1: TMenuItem;
    StayOnTop1: TMenuItem;
    actEditWatch: TAction;
    actAddWatch: TAction;
    actEnableWatch: TAction;
    actDisableWatch: TAction;
    actDeleteWatch: TAction;
    actEnableAllWatches: TAction;
    actDisableAllWatches: TAction;
    actDeleteAllWatches: TAction;
    actEditWatch1: TMenuItem;
    actEnableWatch1: TMenuItem;
    actDisableWatch1: TMenuItem;
    actDeleteWatch1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    actEnableAllWatches1: TMenuItem;
    actDisableAllWatches1: TMenuItem;
    actDeleteAllWatches1: TMenuItem;
    procedure actStayOnTopExecute(Sender: TObject);
    procedure actStayOnTopUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actEditWatchUpdate(Sender: TObject);
    procedure actAddWatchUpdate(Sender: TObject);
    procedure actEnableWatchUpdate(Sender: TObject);
    procedure actDisableWatchUpdate(Sender: TObject);
    procedure actDeleteWatchExecute(Sender: TObject);
    procedure actEnableAllWatchesExecute(Sender: TObject);
    procedure actDisableAllWatchesUpdate(Sender: TObject);
    procedure actDeleteAllWatchesUpdate(Sender: TObject);
    procedure actAddWatchExecute(Sender: TObject);
    procedure actEnableWatchExecute(Sender: TObject);
    procedure actDisableWatchExecute(Sender: TObject);
    procedure actDeleteWatchUpdate(Sender: TObject);
    procedure actEnableAllWatchesUpdate(Sender: TObject);
    procedure actDisableAllWatchesExecute(Sender: TObject);
    procedure actDeleteAllWatchesExecute(Sender: TObject);
    procedure actEditWatchExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateInfo;
  end;


implementation

{$R *.DFM}

uses
  AddWatch,
  MarathonIDE,
  MarathonInternalInterfaces,
  IBDebuggerVM;

procedure TfrmWatches.UpdateInfo;
var
  Idx : Integer;

begin
  lvWatches.Items.BeginUpdate;
  try
    lvWatches.Items.Clear;
    for Idx := 0 to MarathonIDEInstance.DebuggerVM.WatchList.COunt - 1 do
    begin
      with lvWatches.Items.Add do
      begin
        Caption := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]).Expression;
        SubItems.Add(TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]).Value);
      end;
    end;
  finally
    lvWatches.Items.EndUpdate;
  end;
end;

procedure TfrmWatches.actStayOnTopExecute(Sender: TObject);
begin
  if FormStyle = fsStayOnTop then
    FormStyle := fsNormal
  else
    FormStyle := fsStayOnTop;
end;

procedure TfrmWatches.actStayOnTopUpdate(Sender: TObject);
begin
  (Sender As TAction).Checked := FormStyle = fsStayOnTop;
end;

procedure TfrmWatches.FormShow(Sender: TObject);
begin
  UpdateInfo;
end;

procedure TfrmWatches.actEditWatchUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Selected <> nil);
end;

procedure TfrmWatches.actAddWatchUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled;
end;

procedure TfrmWatches.actEnableWatchUpdate(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  if MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Selected <> nil) then
  begin
    Idx := lvWatches.Selected.Index;
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    (Sender As TAction).Enabled := not W.Enabled;
  end
  else
    (Sender As TAction).Enabled := False;
end;

procedure TfrmWatches.actDisableWatchUpdate(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  if MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Selected <> nil) then
  begin
    Idx := lvWatches.Selected.Index;
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    (Sender As TAction).Enabled := W.Enabled;
  end
  else
    (Sender As TAction).Enabled := False;
end;

procedure TfrmWatches.actDeleteWatchUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Selected <> nil);
end;

procedure TfrmWatches.actEnableAllWatchesUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Items.Count > 0);
end;

procedure TfrmWatches.actDisableAllWatchesUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Items.Count > 0);
end;

procedure TfrmWatches.actDeleteAllWatchesUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled and (lvWatches.Items.Count > 0);
end;

procedure TfrmWatches.actDeleteWatchExecute(Sender: TObject);
var
  Idx : Integer;
begin
  Idx := lvWatches.Selected.Index;
  TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]).Free;
  MarathonIDEInstance.DebuggerVM.WatchList.Delete(Idx);
  UpdateInfo;
end;

procedure TfrmWatches.actEnableAllWatchesExecute(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  for Idx := 0 to MarathonIDEInstance.DebuggerVM.WatchList.Count - 1 do
  begin
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    W.Enabled := True;
  end;
  UpdateInfo;
end;

procedure TfrmWatches.actAddWatchExecute(Sender: TObject);
begin
  MarathonIDEInstance.DebuggerVM.AddWatchDialog;
end;

procedure TfrmWatches.actEnableWatchExecute(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  Idx := lvWatches.Selected.Index;
  W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
  W.Enabled := True;
  UpdateInfo;
end;

procedure TfrmWatches.actDisableWatchExecute(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  Idx := lvWatches.Selected.Index;
  W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
  W.Enabled := False;
  UpdateInfo;
end;

procedure TfrmWatches.actDisableAllWatchesExecute(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  for Idx := 0 to MarathonIDEInstance.DebuggerVM.WatchList.Count - 1 do
  begin
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    W.Enabled := False;
  end;
  UpdateInfo;
end;

procedure TfrmWatches.actDeleteAllWatchesExecute(Sender: TObject);
var
  Idx : Integer;
  W : TWatch;

begin
  for Idx := 0 to MarathonIDEInstance.DebuggerVM.WatchList.Count - 1 do
  begin
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    W.Free;
  end;
  MarathonIDEInstance.DebuggerVM.WatchList.Clear;
  UpdateInfo;
end;

procedure TfrmWatches.actEditWatchExecute(Sender: TObject);
var
  FA : TfrmAddWatch;
  Idx : Integer;
  W : TWatch;

begin
  FA := TfrmAddWatch.Create(nil);
  try
    Idx := lvWatches.Selected.Index;
    W := TWatch(MarathonIDEInstance.DebuggerVM.WatchList[Idx]);
    FA.cmbVariable.Text := W.Expression;
    FA.chkEnabled.Checked := W.Enabled;
    if FA.ShowModal = mrOK then
    begin
      W.Expression := FA.cmbVariable.Text;
      W.Enabled := FA.chkEnabled.Checked;
      UpdateInfo;
    end;
  finally
    FA.Free;
  end;
end;

procedure TfrmWatches.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

{
$Log: DebugWatches.pas,v $
Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
