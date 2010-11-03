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
// $Id: ArrayDialog.pas,v 1.2 2002/04/25 07:21:29 tmuetze Exp $

unit ArrayDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  TfrmArrayDialog = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edLBound: TEdit;
    edUBound: TEdit;
    udLBound: TUpDown;
    udUBound: TUpDown;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmArrayDialog.btnOKClick(Sender: TObject);
begin
  if udUBound.Position <= udLBound.Position then
  begin
    MessageDlg('Array Upper Bound must be greater than Array Lower Bound.', mtError, [mbOK], 0);
		Exit;
	end
	else
		ModalResult := mrOK;
end;

end.

{
$Log: ArrayDialog.pas,v $
Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
