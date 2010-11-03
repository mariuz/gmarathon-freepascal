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
// $Id: UDFInputParam.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit UDFInputParam;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls;

type
	TfrmUDFAddInput = class(TForm)
		btnOK: TButton;
		btnCancel: TButton;
		btnHelp: TButton;
		edParameter: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		cmbRtnType: TComboBox;
		procedure btnOKClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure btnHelpClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

implementation

{$R *.DFM}

uses
	HelpMap;

procedure TfrmUDFAddInput.btnOKClick(Sender: TObject);
begin
	if edParameter.Text = '' then
	begin
		MessageDlg('You must enter a Parameter.', mtError, [mbOK], 0);
    Exit;
  end;

  ModalResult := mrOK;
end;

procedure TfrmUDFAddInput.FormCreate(Sender: TObject);
begin
  HelpContext := IDH_UDF_Input_Parameters_Dialog;
  cmbRtnType.ItemIndex := 1;
end;

procedure TfrmUDFAddInput.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_UDF_Input_Parameters_Dialog);
end;

end.

{
$Log: UDFInputParam.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
