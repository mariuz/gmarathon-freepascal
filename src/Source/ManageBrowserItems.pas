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
// $Id: ManageBrowserItems.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit ManageBrowserItems;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ActnList;

type
  TfrmManageBrowserItems = class(TForm)
    lvRecent: TListView;
    btnClose: TButton;
    btnRemove: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    actList: TActionList;
    actRemove: TAction;
    actMoveUp: TAction;
    actMoveDOwn: TAction;
    btnCancel: TButton;
    procedure actRemoveExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDOwnExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure actMoveUpUpdate(Sender: TObject);
    procedure actMoveDOwnUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmManageBrowserItems.actRemoveExecute(Sender: TObject);
begin
	if MessageDlg('Are you sure you wish to remove the selected item?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		lvRecent.Selected.Delete;
end;

procedure TfrmManageBrowserItems.actMoveUpExecute(Sender: TObject);
var
	CUrIdx : Integer;
	Temp : String;

begin
	CurIDX := lvRecent.Selected.Index;
	CurIDX := CurIDX - 1;
	Temp := lvRecent.Selected.Caption;
	lvRecent.Selected.Delete;
	with lvRecent.Items.Insert(CurIdx) do
	begin
		Caption := Temp;
		Selected := True;
		Focused := True;
	end;
end;

procedure TfrmManageBrowserItems.actMoveDOwnExecute(Sender: TObject);
var
  CUrIdx : Integer;
  Temp : String;

begin
  CurIDX := lvRecent.Selected.Index;
  CurIDX := CurIDX + 1;
  Temp := lvRecent.Selected.Caption;
  lvRecent.Selected.Delete;
  with lvRecent.Items.Insert(CurIdx) do
  begin
    Caption := Temp;
    Selected := True;
    Focused := True;
  end;
end;

procedure TfrmManageBrowserItems.actRemoveUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvRecent.Selected <> nil;
end;

procedure TfrmManageBrowserItems.actMoveUpUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lvRecent.Selected <> nil) and (lvRecent.Items.Count > 1) and
    (lvRecent.Selected.Index > 0);
end;

procedure TfrmManageBrowserItems.actMoveDOwnUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lvRecent.Selected <> nil) and (lvRecent.Items.Count > 1) and
    (lvRecent.Selected.Index < lvRecent.Items.Count - 1);
end;

end.

{
$Log: ManageBrowserItems.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
