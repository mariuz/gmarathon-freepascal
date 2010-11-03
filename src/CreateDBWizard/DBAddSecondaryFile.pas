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
// $Id: DBAddSecondaryFile.pas,v 1.2 2002/04/25 07:15:55 tmuetze Exp $

unit DBAddSecondaryFile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmDBSecondaryFile = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label1: TLabel;
    edFileName: TEdit;
    edPages: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

procedure TfrmDBSecondaryFile.btnOKClick(Sender: TObject);
begin
  if edFileName.Text = '' then
  begin
    MessageDlg('The secondary file must have a file name.', mtError, [mbOK], 0);
    Exit;
  end;
  if edPages.Text = '' then
  begin
    MessageDlg('The secondary file must have a page length.', mtError, [mbOK], 0);
    Exit;
  end;
  ModalResult := mrOK;
end;

end.

{
$Log: DBAddSecondaryFile.pas,v $
Revision 1.2  2002/04/25 07:15:55  tmuetze
New CVS powered comment block

}
