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
// $Id: ScriptOptions.pas,v 1.4 2002/06/12 11:43:34 tmuetze Exp $

unit ScriptOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Buttons, StdCtrls, ComCtrls, Registry;

type
	TfrmScriptOptions = class(TForm)
		pgOptions: TPageControl;
		btnOK: TButton;
		btnCancel: TButton;
		tsGeneral: TTabSheet;
		chkAbortOnError: TCheckBox;
		chkRollBack: TCheckBox;
		edScriptDir: TEdit;
		Label1: TLabel;
		btnChooseDir: TSpeedButton;
		procedure btnChooseDirClick(Sender: TObject);
		procedure chkAbortOnErrorClick(Sender: TObject);
		procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;


implementation

uses
	GSSRegistry,
	ChooseFolder, ScriptMain;

{$R *.DFM}

procedure TfrmScriptOptions.btnChooseDirClick(Sender: TObject);
var
	frmChooseFolder: TfrmChooseFolder;

begin
	frmChooseFolder := TfrmChooseFolder.Create(Self);
	try
		try
			frmChooseFolder.lstDir.Directory := edScriptDir.Text;
		except
			//eat it...
		end;
		if frmChooseFolder.ShowModal = mrOK then
		begin
			edScriptDir.Text := frmChooseFolder.lstDir.Directory;
		end;
	finally
		frmChooseFolder.Free;
	end;
end;

procedure TfrmScriptOptions.chkAbortOnErrorClick(Sender: TObject);
begin
	if chkAbortOnError.Checked then
	begin
		chkRollback.Enabled := True;
	end
	else
	begin
		chkRollback.Checked := False;
		chkRollback.Enabled := False;
	end;
end;

procedure TfrmScriptOptions.btnOKClick(Sender: TObject);
{var
	I : TRegistry;}

begin
   frmScript.AbortOnError    := chkAbortOnError.Checked;
   frmScript.RollbackOnAbort := chkRollback.Checked;
   frmScript.ScriptDir       := edScriptDir.Text;
{

	I := TRegistry.Create;
        I.RootKey:= HKEY_CURRENT_USER;     // hexplorador
	try
		if I.OpenKey(REG_SCREXEC, True) then
		begin
			I.WriteString('ScriptDir', edScriptDir.Text);
			I.WriteBool('AbortOnError', chkAbortOnError.Checked);
			I.WriteBool('RollbackOnAbort', chkRollback.Checked);
			I.CloseKey;
		end;
	finally
		I.Free;
	end;}
	ModalResult := mrOK;
end;

// Restore Configuration
procedure TfrmScriptOptions.FormCreate(Sender: TObject);
{var
   I : TRegistry;}
begin
{   I := TRegistry.Create;
   I.RootKey:=HKEY_CURRENT_USER;    // hexplorador
   try
     if I.OpenKey(REG_SCREXEC, True) then
   begin}
     chkAbortOnError.Checked := frmScript.AbortOnError; // I.ReadBool('AbortOnError');
     chkRollback.Checked     := frmScript.RollbackOnAbort; // I.ReadBool('RollbackOnAbort');
     edScriptDir.Text        := frmScript.ScriptDir;
{     I.CloseKey;
   end;
   finally
        I.Free;
   end;}

end;

end.

{ Old History
				11.04.2002      hexplorador
								* Fix the bug, when write or read the path in the register
}

{
$Log: ScriptOptions.pas,v $
Revision 1.4  2002/06/12 11:43:34  tmuetze
Patch from Arturo Castillo: Modifications to ScriptExec

Revision 1.3  2002/04/25 07:17:35  tmuetze
New CVS powered comment block

}
