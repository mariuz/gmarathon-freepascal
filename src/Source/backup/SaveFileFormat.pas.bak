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
// $Id: SaveFileFormat.pas,v 1.6 2005/11/16 06:50:18 rjmills Exp $

{
$Log: SaveFileFormat.pas,v $
Revision 1.6  2005/11/16 06:50:18  rjmills
General updates Synedit Search and comment updates

Revision 1.5  2005/05/20 19:18:26  rjmills
Fix for unnamed TrmNotebookPages.

Revision 1.4  2005/04/13 16:04:31  rjmills
*** empty log message ***

Revision 1.3  2002/05/29 11:14:01  tmuetze
Added a patch from Pavel Odstrcil: Added posibility to create insert statement with column names optionally surrounded by quotes, data values now enclosed in single quotes, added largeint type

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit SaveFileFormat;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ExtCtrls, CheckLst, ComCtrls,
	rmBtnEdit,
	rmCornerGrip,
  rmBaseEdit, rmNotebook2;

type
  TfrmSaveFileFormat = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgFileExport: TPageControl;
    tsDetails: TTabSheet;
    tsColumns: TTabSheet;
    chkListColumns: TCheckListBox;
    nbFormat: TrmNoteBookControl;
    Label2: TLabel;
    Label3: TLabel;
    cmbSep: TComboBox;
    cmbQual: TComboBox;
    chkFirstRow: TCheckBox;
    cmbFormat: TComboBox;
    Label1: TLabel;
    Label4: TLabel;
    edFileName: TrmBtnEdit;
    dlgSave: TSaveDialog;
    Label5: TLabel;
    edTable: TEdit;
    rmCornerGrip1: TrmCornerGrip;
    chkInsColNames: TCheckBox;
    Panel1: TPanel;
    chkInsColNamesSep: TCheckBox;
    btnSelectAll: TButton;
    btnSelectNone: TButton;
    nbpSV: TrmNotebookPage;
    nbpInsert: TrmNotebookPage;
    procedure cmbFormatChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edFileNameBtn1Click(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
	end;

implementation

uses
	Globals,
	HelpMap;

{$R *.DFM}

procedure TfrmSaveFileFormat.cmbFormatChange(Sender: TObject);
begin
  nbFormat.ActivePageIndex := TComboBox(Sender).ItemIndex;
end;

procedure TfrmSaveFileFormat.FormCreate(Sender: TObject);
begin
  HelpContext := IDH_File_Format_Dialog;
  cmbFormat.ItemIndex := 0;
  cmbSep.ItemIndex := 0;
  cmbQual.ItemIndex := 0;
  chkFirstRow.Checked := True;
  nbformat.ActivePage := nbpSV;
end;

procedure TfrmSaveFileFormat.btnOKClick(Sender: TObject);
begin
  if edFileName.Text = '' then
  begin
    MessageDlg('You must enter a file name.', mtError, [mbOK], 0);
    pgFileExport.ActivePage := tsDetails;
    edFileName.SetFocus;
    Exit;
  end;
  if cmbFormat.ItemIndex = 1 then
  begin
    if edTable.Text = '' then
    begin
      MessageDlg('You must enter a table name.', mtError, [mbOK], 0);
      pgFileExport.ActivePage := tsDetails;
      edTable.SetFocus;
      Exit;
    end;
  end;
  ModalResult := mrOK;
end;

procedure TfrmSaveFileFormat.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_File_Format_Dialog);
end;

procedure TfrmSaveFileFormat.FormShow(Sender: TObject);
begin
  LoadFormPosition(Self);
end;

procedure TfrmSaveFileFormat.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //save size...
  SaveFormPosition(Self);
end;

procedure TfrmSaveFileFormat.edFileNameBtn1Click(Sender: TObject);
begin
  if dlgSave.Execute then
    edFileName.Text := dlgSave.FileName;
end;

procedure TfrmSaveFileFormat.btnSelectAllClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to chkListColumns.Items.Count-1 do chkListColumns.Checked[i] := true;
end;

procedure TfrmSaveFileFormat.btnSelectNoneClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to chkListColumns.Items.Count-1 do chkListColumns.Checked[i] := false;
end;

end.


