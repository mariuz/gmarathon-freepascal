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
// $Id: NewObjectDialog.pas,v 1.4 2005/04/13 16:04:30 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: NewObjectDialog.pas,v $
Revision 1.4  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit NewObjectDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ImgList,
	MarathonProjectCacheTypes;

type
  TfrmNewObject = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    ilImages: TImageList;
    pgNewObject: TPageControl;
    tsAllObjects: TTabSheet;
    tsStoredProcTemplates: TTabSheet;
    lvObjects: TListView;
    lvSPTempls: TListView;
    Label1: TLabel;
    cmbConnection: TComboBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvObjectsKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
		procedure btnHelpClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
	private
		FRtnType: TGSSCacheType;
		FRtnName: String;
		FConnectionName: String;
		{ Private declarations }
	public
		{ Public declarations }
		property RtnType : TGSSCacheType read FRtnType write FRtnType;
		property RtnName : String read FRtnName write FRtnName;
		property ConnectionName : String read FConnectionName write FConnectionName;
	end;

const
	NNT_DOMAIN = 'Domain';
	NNT_TABLE = 'Table';
	NNT_VIEW = 'View';
	NNT_STORED_PROC = 'Stored Procedure';
	NNT_TRIGGER = 'Trigger';
	NNT_GENERATOR = 'Generator';
	NNT_EXCEPTION = 'Exception';
	NNT_UDF = 'User Defined Funtion';

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE;

{$R *.DFM}

const
  ALL_OBJECTS = 0;
  SP_TEMPLS   = 1;

procedure TfrmNewObject.btnOKClick(Sender: TObject);
begin
  case pgNewObject.ActivePage.PageIndex of
    ALL_OBJECTS:
      begin
        if lvObjects.Selected <> nil then
        begin
          if lvObjects.Selected.Caption = NNT_STORED_PROC then
          begin
            RtnType := ctSP;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_TABLE then
          begin
            RtnType := ctTable;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_VIEW then
          begin
            RtnType := ctView;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_DOMAIN then
          begin
            RtnType := ctDomain;
						ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_EXCEPTION then
          begin
            RtnType := ctException;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_TRIGGER then
          begin
            RtnType := ctTrigger;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_UDF then
          begin
            RtnType := ctUDF;
            ModalResult := mrOK;
          end;

          if lvObjects.Selected.Caption = NNT_GENERATOR then
          begin
            RtnType := ctGenerator;
            ModalResult := mrOK;
          end;

        end
        else
          MessageDlg('You must first choose an object', mtError, [mbOK], 0);
      end;

    SP_TEMPLS:
      begin
        if lvSPTempls.Selected <> nil then
        begin
          RtnType := ctSPTemplate;
          RtnName := lvSPTempls.Selected.Caption;
          ModalResult := mrOK;
				end
        else
          MessageDlg('You must first choose an object', mtError, [mbOK], 0);
      end;
  end;
  FConnectionName := cmbConnection.Text;
end;

procedure TfrmNewObject.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmNewObject.lvObjectsKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    btnOKClick(btnOK);
  end;
end;

procedure TfrmNewObject.FormCreate(Sender: TObject);
var
  R : TSearchRec;
  Res : Integer;
  Idx : Integer;

begin
  HelpContext := IDH_New_Object_Dialog;

	//Load stored procedure templates
	Res := FindFirst(ExtractFilePath(Application.ExeName) + 'Templates\*.spt', faAnyFile, R);
	While Res = 0 do
	begin
		with lvSPTempls.Items.Add do
		begin
			Caption := Copy(R.Name, 1, Length(R.Name) - 4);;
			ImageIndex := 3;
    end;
    Res := FindNext(R);
  end;
  FindClose(R);

  //load the connections...
  for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
  begin
    cmbConnection.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
  end;
  if MarathonIDEInstance.CurrentProject.Cache.ActiveConnection <> '' then
    cmbConnection.ItemIndex := cmbConnection.Items.IndexOf(MarathonIDEInstance.CurrentProject.Cache.ActiveConnection)
  else
    cmbConnection.ItemIndex := 0;  
end;

procedure TfrmNewObject.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_New_Object_Dialog);
end;

procedure TfrmNewObject.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgNewObject)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgNewObject);
end;

end.


