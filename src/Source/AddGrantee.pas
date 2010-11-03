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
// $Id: AddGrantee.pas,v 1.4 2006/10/22 06:04:28 rjmills Exp $

unit AddGrantee;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls,
	rmCornerGrip;

type
	TfrmGranteeAdd = class(TForm)
		btnCancel: TButton;
		btnOK: TButton;
		pgGrantee: TPageControl;
		tsUser: TTabSheet;
		tsObject: TTabSheet;
		cmbObject: TComboBox;
		Label1: TLabel;
		lvObject: TListView;
		Label2: TLabel;
		edUser: TEdit;
		btnHelp: TButton;
		rmCornerGrip1: TrmCornerGrip;
		procedure btnOKClick(Sender: TObject);
		procedure cmbObjectChange(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure btnHelpClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses
	Globals,
	HelpMap;

procedure TfrmGranteeAdd.btnOKClick(Sender: TObject);
begin
	case pgGrantee.ActivePage.PageIndex of
    0 :
      begin
				if edUser.Text = '' then
				begin
					MessageDlg('You must enter a user name or role for the grantee.', mtError, [mbOK], 0);
					Exit;
				end;
			end;
		1 :
			begin
				if lvObject.SelCount < 1 then
				begin
					MessageDlg('You must select object name(s) for grantee(s).', mtError, [mbOK], 0);
					Exit;
				end;
			end;
	end;
	ModalResult := mrOK;
end;

procedure TfrmGranteeAdd.cmbObjectChange(Sender: TObject);
{var
	Idx : Integer;}
begin
{  lvObject.Items.BeginUpdate;
	try
		case cmbObject.ItemIndex of
			0 :
				begin
					lvObject.Items.Clear;
					for Idx := 0 to frmMarathonMain.MSPList.Count - 1 do
					begin
						with lvObject.Items.Add do
						begin
							Caption := frmMarathonMain.MSPList[Idx];
						end;
					end;
				end;
			1 :
				begin
					lvObject.Items.Clear;
					for Idx := 0 to frmMarathonMain.MTriggerList.Count - 1 do
					begin
						with lvObject.Items.Add do
						begin
							Caption := frmMarathonMain.MTriggerList[Idx];
						end;
					end;
				end;
			2 :
				begin
					lvObject.Items.Clear;
					for Idx := 0 to frmMarathonMain.MViewList.Count - 1 do
					begin
						with lvObject.Items.Add do
						begin
							Caption := frmMarathonMain.MViewList[Idx];
						end;
					end;
				end;
		end;
	finally
		lvObject.Items.EndUpdate;
	end;}
end;

procedure TfrmGranteeAdd.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Add_Grantee;
	pgGrantee.ActivePage := tsUser;
	ActiveControl := edUser;
	cmbObject.ItemIndex := 0;
	cmbObjectChange(cmbObject);
	LoadFormPosition(Self);
end;

procedure TfrmGranteeAdd.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgGrantee)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgGrantee);
end;

procedure TfrmGranteeAdd.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_Add_Grantee);
end;

procedure TfrmGranteeAdd.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
	SaveFormPosition(Self);
end;

end.

{
$Log: AddGrantee.pas,v $
Revision 1.4  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.3  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
