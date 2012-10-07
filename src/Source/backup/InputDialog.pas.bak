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
// $Id: InputDialog.pas,v 1.4 2005/04/13 16:04:29 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: InputDialog.pas,v $
Revision 1.4  2005/04/13 16:04:29  rjmills
*** empty log message ***

Revision 1.3  2002/08/28 14:56:56  tmuetze
Revised the Code Snippets functionality, only SaveSnippetAs.* needs revising

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit InputDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmInputDialog = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edItem: TEdit;
    lblPrompt: TLabel;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmInputDialog.btnOKClick(Sender: TObject);
begin
  if edItem.Text = '' then
  begin
    MessageDlg('You must enter a value!', mtError, [mbOK], 0);
    Exit;
  end;

  ModalResult := mrOK;
end;

end.


