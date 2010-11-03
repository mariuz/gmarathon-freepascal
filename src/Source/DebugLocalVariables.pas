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
// $Id: DebugLocalVariables.pas,v 1.6 2005/06/29 22:29:51 hippoman Exp $

unit DebugLocalVariables;

interface

{$I compilerdefines.inc}

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, Menus,
	{$IFDEF D6_OR_HIGHER}
	Variants,
	{$ENDIF}
	ActnList;

type
	TfrmDebugLocals = class(TForm)
		lvVars: TListView;
		actCallStack: TActionList;
		actStayOnTop: TAction;
		PopupMenu1: TPopupMenu;
		StayOnTop1: TMenuItem;
		procedure FormShow(Sender: TObject);
		procedure actStayOnTopExecute(Sender: TObject);
		procedure actStayOnTopUpdate(Sender: TObject);
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

procedure TfrmDebugLocals.UpdateInfo;
var
	CS : TCallStackItem;
	Idx : Integer;

begin
	lvVars.Items.BeginUpdate;
	try
		lvVars.Items.Clear;
    if MarathonIDEInstance.DebuggerVM.Enabled then
    begin
      if MarathonIDEInstance.DebuggerVM.Executing then
      begin
        CS := MarathonIDEInstance.DebuggerVM.CallStack[0];
        for Idx := 0 to CS.SymbolTable.Count - 1 do
        begin
          if CS.SymbolTable.Items[Idx].SymbolType = stLocal then
          begin
            with lvVars.Items.Add do
            begin
              Caption := CS.SymbolTable.Items[Idx].Name;
              if VarIsNull(CS.SymbolTable.Items[Idx].Value) then
                SubItems.Add('NULL')
              else
                SubItems.Add(CS.SymbolTable.Items[Idx].Value);
            end;
          end;
        end;
      end;
    end;
  finally
    lvVars.Items.EndUpdate;
  end;
end;

procedure TfrmDebugLocals.FormShow(Sender: TObject);
begin
  UpdateInfo;
end;

procedure TfrmDebugLocals.actStayOnTopExecute(Sender: TObject);
begin
	if FormStyle = fsStayOnTop then
		FormStyle := fsNormal
	else
		FormStyle := fsStayOnTop;
end;

procedure TfrmDebugLocals.actStayOnTopUpdate(Sender: TObject);
begin
	(Sender As TAction).Checked := FormStyle = fsStayOnTop;
end;

procedure TfrmDebugLocals.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

{
$Log: DebugLocalVariables.pas,v $
Revision 1.6  2005/06/29 22:29:51  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.5  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.3  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
