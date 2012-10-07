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
// $Id: Login.pas,v 1.3 2005/04/13 16:04:29 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: Login.pas,v $
Revision 1.3  2005/04/13 16:04:29  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit Login;

{$I compilerdefines.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, FileCtrl, ExtCtrls, Registry, Buttons;

type
  TfrmConnect = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edUserName: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblPrompt: TLabel;
    Label3: TLabel;
    chkRememberPassword: TCheckBox;
    Label5: TLabel;
    edRole: TEdit;
    Label4: TLabel;
    cmbDialect: TComboBox;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
	Globals;
	
{$R *.DFM}

procedure TfrmConnect.btnOKClick(Sender: TObject);
begin
	ModalResult := mrOK;
end;

end.


