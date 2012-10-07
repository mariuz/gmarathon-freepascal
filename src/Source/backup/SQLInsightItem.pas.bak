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
// $Id: SQLInsightItem.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit SQLInsightItem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmSQLInsight = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edShortCut: TEdit;
    edDescription: TEdit;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmSQLInsight.btnOKClick(Sender: TObject);
begin
  if edShortCut.Text = '' then
  begin
    MessageDlg('You must enter a shortcut to the code template.', mtError, [mbOK], 0);
    Exit;
  end;
  if edDescription.Text = '' then
  begin
    MessageDlg('You must enter a description for the code template.', mtError, [mbOK], 0);
    Exit;
  end;
  ModalResult := mrOK;
end;

end.

{
$Log: SQLInsightItem.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
