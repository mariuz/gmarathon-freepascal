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
// $Id: DebugCallStack.pas,v 1.3 2003/11/05 05:29:44 figmentsoft Exp $

unit DebugCallStack;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ActnList;

type
  TCallStackHolder = class(TObject)
  private
    FLine: Integer;
    FModule: String;
  public
    property ModuleName : String read FModule write FModule;
    property Line : Integer read FLine write FLine;
  end;

  TfrmDebugCallStack = class(TForm)
    lvCallStack: TListView;
    actCallStack: TActionList;
    actViewSource: TAction;
    actStayOnTop: TAction;
    PopupMenu1: TPopupMenu;
    StayOnTop1: TMenuItem;
    ViewSource1: TMenuItem;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure actStayOnTopUpdate(Sender: TObject);
    procedure actStayOnTopExecute(Sender: TObject);
    procedure lvCallStackDblClick(Sender: TObject);
    procedure actViewSourceUpdate(Sender: TObject);
    procedure lvCallStackDeletion(Sender: TObject; Item: TListItem);
    procedure actViewSourceExecute(Sender: TObject);
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
  MarathonIDE,
  MarathonInternalInterfaces,
  IBDebuggerVM;

procedure TfrmDebugCallStack.FormShow(Sender: TObject);
begin
  UpdateInfo;
end;

procedure TfrmDebugCallStack.UpdateInfo;
var
  CSString : String;
  CS : TCallStackItem;
  Module : TProcModule;
  Idx : Integer;
  H : TCallStackHolder;

begin
  lvCallStack.Items.BeginUpdate;
  try
    lvCallStack.Items.Clear;
    if MarathonIDEInstance.DebuggerVM.Enabled then
    begin
      if MarathonIDEInstance.DebuggerVM.Executing then
      begin
        for Idx := 0 to MarathonIDEInstance.DebuggerVM.CallStack.Count - 1 do
        begin
          CS := MarathonIDEInstance.DebuggerVM.CallStack[Idx];
          Module := MarathonIDEInstance.DebuggerVM.ModuleByName[CS.ModuleName];
          CSString := CS.ModuleName + ' (' + IntToStr(Module.CurrentStatement.Line) + ')';
          H := TCallStackHolder.Create;
					H.ModuleName := CS.ModuleName;
					H.Line := Module.CurrentStatement.Line;
          with lvCallStack.Items.Add do
          begin
            Caption := CSString;
            Data := H;
          end;
        end;
      end
      else
      begin
        with lvCallStack.Items.Add do
          Caption := 'Process is not accessable';
      end;
    end
    else
    begin
      with lvCallStack.Items.Add do
        Caption := 'Process is not accessable';
		end;
	finally
		lvCallStack.Items.EndUpdate;
	end;
end;

procedure TfrmDebugCallStack.actStayOnTopUpdate(Sender: TObject);
begin
	(Sender As TAction).Checked := FormStyle = fsStayOnTop;
end;

procedure TfrmDebugCallStack.actStayOnTopExecute(Sender: TObject);
begin
	if FormStyle = fsStayOnTop then
		FormStyle := fsNormal
	else
		FormStyle := fsStayOnTop;
end;

procedure TfrmDebugCallStack.lvCallStackDblClick(Sender: TObject);
begin
	if actViewSource.Enabled then
		actViewSource.Execute;
end;

procedure TfrmDebugCallStack.actViewSourceUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := (lvCallStack.Selected <> nil) and (lvCallStack.Selected.Data <> nil);
end;

procedure TfrmDebugCallStack.lvCallStackDeletion(Sender: TObject;	Item: TListItem);
begin
	if Assigned(Item.Data) then
  begin
		TObject(Item.Data).Free;
    Item.Data := nil; //AC:
  end;
end;

procedure TfrmDebugCallStack.actViewSourceExecute(Sender: TObject);
var
	H : TCallStackHolder;
	F : IMarathonStoredProcEditor;
	Module : TProcModule;

begin
	if lvCallStack.Selected <> nil then
	begin
		if lvCallStack.Selected.Data <> nil then
		begin
			 H := TCallStackHolder(lvCallStack.Selected.Data);
			 Module := MarathonIDEInstance.DebuggerVM.ModuleByName[H.ModuleName];
			 F := MarathonIDEInstance.DebugOpenProcedure(Module.ProcName, MarathonIDEInstance.DebuggerVM.DatabaseName, True, True);
			 if Assigned(F) then
			 begin
				 F.DebugSetExecutionPoint(Module.CurrentLine);
			 end;
		end;
	end;
end;

procedure TfrmDebugCallStack.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

{
$Log: DebugCallStack.pas,v $
Revision 1.3  2003/11/05 05:29:44  figmentsoft
Code cleanup.
Before I found what I feel was the reason why Marathon AVed, I tied up the loose ends by setting freed items to nil.  lvCallStackDeletion() deallocates the Item.Data without setting Data to nil.  I set it to nil for safety.  I think I have seen it evaluated for nil elsewhere.  But then again, I don't really remember cause it's been a while since I have fixed the AV issue.  Or so I think.

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
