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
// $Id: SecureDBLogin.pas,v 1.4 2006/10/22 06:04:28 rjmills Exp $

unit SecureDBLogin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, FileCtrl, ExtCtrls, Registry;

type
  TfrmSecureConnect = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edUserName: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edDBName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
	end;

implementation

uses
	Globals,
	MarathonIDE{,
	MarathonMain};

{$R *.DFM}

procedure TfrmSecureConnect.FormCreate(Sender: TObject);
begin
{	if MarathonIDEInstance.CurrentProject. SecureDB <> '' then
	begin
		edDBName.Text := MarathonIDEInstance.CurrentProject.SecureDB;
		ActiveControl := edUserName;
	end
	else
	begin
		ActiveControl := edDBName;
		Exit;
	end;

	if MarathonIDEInstance.CurrentProject.SecureDBUserName <> '' then
	begin
		edUserName.Text := MarathonIDEInstance.CurrentProject.SecureDBUserName;
		ActiveControl := edPassword;
	end
	else
		ActiveControl := edUserName;

	if MarathonIDEInstance.CurrentProject.SecureDBPassword <> '' then
		edPassword.Text := MarathonIDEInstance.CurrentProject.SecureDBPassword;}
end;

procedure TfrmSecureConnect.btnOKClick(Sender: TObject);
begin
{	MarathonIDEInstance.CurrentProject.SecureDB := edDBName.Text;
	MarathonIDEInstance.CurrentProject.SecureDBUserName := edUserName.Text;
	MarathonIDEInstance.CurrentProject.SecureDBPassword := edPassword.Text;}
	ModalResult := mrOK;
end;

end.

{
$Log: SecureDBLogin.pas,v $
Revision 1.4  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.3  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
