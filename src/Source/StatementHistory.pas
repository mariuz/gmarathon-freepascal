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
// $Id: StatementHistory.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit StatementHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, Db, ImgList,
	rmCornerGrip,
	rmCollectionListBox;

type
  TfrmStatementHistory = class(TForm)
		btnOK: TButton;
		btnCancel: TButton;
		btnHelp: TButton;
		ImageList1: TImageList;
		rmCornerGrip1: TrmCornerGrip;
		lvHistory: TrmCollectionListBox;
		procedure btnOKClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure btnHelpClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure lvHistoryKeyPress(Sender: TObject; var Key: Char);
    procedure lvHistoryDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
	HelpMap,
	Globals;

{$R *.DFM}

procedure TfrmStatementHistory.btnOKClick(Sender: TObject);
begin
	if lvHistory.ItemIndex > -1 then
		ModalResult := mrOK
	else
		MessageDlg('Choose and item before clicking OK.', mtInformation, [mbOK], 0);
end;

procedure TfrmStatementHistory.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_SQL_Statement_History;
	LoadFormPosition(Self);
end;

procedure TfrmStatementHistory.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_SQL_Statement_History);
end;

procedure TfrmStatementHistory.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormPosition(Self);
end;

procedure TfrmStatementHistory.lvHistoryKeyPress(Sender: TObject;	var Key: Char);
begin
	if Key = #13 then
		btnOKClick(Self);
end;

procedure TfrmStatementHistory.lvHistoryDblClick(Sender: TObject);
begin
	btnOKClick(Self);
end;

end.

{
$Log: StatementHistory.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
