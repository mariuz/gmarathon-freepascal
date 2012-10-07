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
// $Id: GlobalPrintDialog.pas,v 1.3 2002/06/06 07:36:43 tmuetze Exp $

unit GlobalPrintDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls,
	rmSpin,
	rmBaseEdit, ExtCtrls;

type
  TfrmGlobalPrintDialogOption = (
    opDatabase,
    opDatabaseNewPage,
    opTable,
      opTableStructure, opTableConstraints, opTableIndexes,
      opTableDependencies, opTableTriggerSummary, opTableTriggerDetail,
      opTableDocumentation,
    opView,
      opViewDocumentation, opViewStructure, opViewDependencies,
      opViewTriggerSummary, opViewTriggerDetail, opViewSource,
    opSP,
      opSPDocumentation, opSPCode,
    opUDF,
      opUDFDocumentation, opUDFUDF,
    opTrigger,
      opTriggerDocumentation, opTriggerCode,
    opException,
      opExceptionDocumentation, opExceptionException,
    opGenerator,
      opGeneratorDetail,
    opDomain,
      opDomainDetail,
    opDependencies
  );

  TfrmGlobalPrintDialogOptions = set of TfrmGlobalPrintDialogOption;

  TfrmGlobalPrintDialog = class(TForm)
    Panel1: TPanel;
    btnOptions: TButton;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Panel3: TPanel;
    gbOptions: TGroupBox;
    Label5: TLabel;
    chkWrap: TCheckBox;
    edNumCopies: TrmSpinEdit;
    pnObjects: TPanel;
    pgPrintDialog: TPageControl;
    tsTable: TTabSheet;
    chkTabStruct: TCheckBox;
    chkTabConstraints: TCheckBox;
    chkTabIndexes: TCheckBox;
    chkTabDepend: TCheckBox;
    chkTabTriggerSummary: TCheckBox;
    chkTabDoco: TCheckBox;
    tsView: TTabSheet;
    chkViewStruct: TCheckBox;
    chkViewDepend: TCheckBox;
    chkViewTriggerSummary: TCheckBox;
    chkViewDoco: TCheckBox;
    tsSP: TTabSheet;
    chkSPCode: TCheckBox;
    chkSPDoco: TCheckBox;
    tsTrigger: TTabSheet;
    chkTrigCode: TCheckBox;
    chkTrigDoco: TCheckBox;
    tsExcept: TTabSheet;
    chkExCode: TCheckBox;
    chkExDoco: TCheckBox;
    tsUDF: TTabSheet;
    chkUDFCOde: TCheckBox;
    chkUDFDoco: TCheckBox;
    dlgFont: TFontDialog;
    pnFonts: TPanel;
    pnPageHeaderFont: TPanel;
    pnDataHeaderFont: TPanel;
    pnTailFont: TPanel;
    pnPageFooterFont: TPanel;
    pnDataFont: TPanel;
    pnTitleFont: TPanel;
    Label1: TLabel;
    chkViewSource: TCheckBox;
    chkViewTriggerDetail: TCheckBox;
    chkTabTriggerDetail: TCheckBox;
    tsDatabase: TTabSheet;
    chkDbNewPage: TCheckBox;
    chkDbTables: TCheckBox;
    chkDbViews: TCheckBox;
    chkDbSp: TCheckBox;
    chkDbTriggers: TCheckBox;
    chkDbDomains: TCheckBox;
    chkDbGenerators: TCheckBox;
    chkDbExceptions: TCheckBox;
    chkDbUDFs: TCheckBox;
    tsDomain: TTabSheet;
    tsGenerator: TTabSheet;
    chkDomainDet: TCheckBox;
    chkGeneratorDet: TCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnTitleFontClick(Sender: TObject);
  private
		{ Private declarations }
    Res : TfrmGlobalPrintDialogOptions;
	public
		{ Public declarations }
    procedure SetDlgType(ADlgType : string; Preview : boolean);
    function  GetOptions: TfrmGlobalPrintDialogOptions;
	end;

implementation

uses
	MarathonIDE,
	GlobalPrintingRoutines;

{$R *.DFM}

procedure TfrmGlobalPrintDialog.btnOKClick(Sender: TObject);
begin
	//do some stuff in here...
  gpNumCopies := edNumCopies.Value;
  gpWrap := chkWrap.Checked;

  WritePrintSettings;

  ModalResult := mrOK;
end;

procedure TfrmGlobalPrintDialog.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmGlobalPrintDialog.FormCreate(Sender: TObject);
begin
  edNumCopies.Value := gpNumCopies;
  chkWrap.Checked := gpWrap;
end;

procedure TfrmGlobalPrintDialog.btnOptionsClick(Sender: TObject);
begin
  MarathonIDEInstance.FilePrintSetup;
end;

procedure TfrmGlobalPrintDialog.FormShow(Sender: TObject);
begin
  // resize
  if not pgPrintDialog.Visible then
  begin
    Height := Height-pnObjects.Height;
  end;
end;

procedure TfrmGlobalPrintDialog.pnTitleFontClick(Sender: TObject);
begin
  if Sender is TPanel then
  begin
    dlgFont.Font.Assign(TPanel(Sender).Font);
    if dlgFont.Execute then
    begin
      TPanel(Sender).Font.Assign(dlgFont.Font);
    end;
  end;
end;

procedure TfrmGlobalPrintDialog.SetDlgType(ADlgType : string; Preview : boolean);
var
  i: integer;
  ts: TTabSheet;
begin
  ts := nil;
  Res := [];
  pnFonts.Visible := false;
  if ADlgType = 'TABLE' then
  begin
    Res := Res+[opTable];
    ts := tsTable;
  end
  else if ADlgType = 'TABLE_CONSTRAINTS' then
  begin
    Res := Res+[opTable, opTableConstraints];
  end
  else if ADlgType = 'TABLE_INDEXES' then
  begin
    Res := Res+[opTable, opTableIndexes];
  end
  else if ADlgType = 'TABLE_TRIGGERS' then
  begin
    Res := Res+[opTable, opTableTriggerSummary];
  end
  else if ADlgType = 'VIEW' then
  begin
    Res := Res + [opView];
    ts := tsView;
  end
  else if ADlgType = 'VIEW_STRUCT' then
  begin
    Res := Res + [opViewStructure];
  end
  else if ADlgType = 'VIEW_TRIGGERS' then
  begin
    Res := Res + [opViewTriggerSummary];
  end
  else if ADlgType = 'VIEW_SOURCE' then
  begin
    Res := Res + [opViewSource];
  end
  else if ADlgType = 'SP' then
  begin
    Res := Res + [opSP];
    ts := tsSP;
  end
  else if ADlgType = 'UDF' then
  begin
    Res := Res + [opUDF];
    ts := tsUDF;
  end
  else if ADlgType = 'TRIGGER' then
  begin
    Res := Res + [opTrigger];
    ts := tsTrigger;
  end
  else if ADlgType = 'EXCEPTION' then
  begin
    Res := Res + [opException];
    ts := tsExcept;
  end
  else if ADlgType = 'GENERATOR' then
  begin
    Res := Res + [opGenerator];
    ts := tsGenerator;
  end
  else if ADlgType = 'DOMAIN' then
  begin
    Res := Res + [opDomain];
    ts := tsDomain;
  end
  else if ADlgType = 'DEPENDENCIES' then
  begin
    Res := Res + [opDomain];
  end
  else if ADlgType = 'DATABASE' then
  begin
    pgPrintDialog.Visible := true;
    for i := 0 to pgPrintDialog.PageCount-1 do begin
      pgPrintDialog.Pages[i].TabVisible := true;
    end;
    pgPrintDialog.ActivePageIndex := 0;
    Res := Res + [opDatabase];
  end;
  if ts <> nil then
  begin
    pgPrintDialog.Visible := true;
    for i := 0 to pgPrintDialog.PageCount-1 do begin
      pgPrintDialog.Pages[i].TabVisible := false;
    end;
    ts.TabVisible := true;
    pgPrintDialog.ActivePage := ts;
  end;
	if Preview then
  begin
		edNumCopies.Enabled := False;
    ActiveControl := btnOK;
  end;
end;

function  TfrmGlobalPrintDialog.GetOptions: TfrmGlobalPrintDialogOptions;
begin

  if opDatabase in Res then
  begin
    if chkDbNewPage.Checked then Res := Res+[opDatabaseNewPage];
    if chkDbDomains.Checked then Res := Res+[opDomain];
    if chkDbTables.Checked then Res := Res+[opTable];
    if chkDbViews.Checked then Res := Res+[opView];
    if chkDbSp.Checked then Res := Res+[opSP];
    if chkDbTriggers.Checked then Res := Res+[opTrigger];
    if chkDbGenerators.Checked then Res := Res+[opGenerator];
    if chkDbExceptions.Checked then Res := Res+[opException];
    if chkDbUDFs.Checked then Res := Res+[opUDF];
  end;

  if chkDomainDet.Checked then Res := Res+[opDomainDetail];

  if chkTabStruct.Checked then Res := Res+[opTableStructure];
  if chkTabConstraints.Checked then Res := Res+[opTableConstraints];
  if chkTabIndexes.Checked then Res := Res+[opTableIndexes];
  if chkTabDepend.Checked then Res := Res+[opTableDependencies];
  if chkTabTriggerSummary.Checked then Res := Res+[opTableTriggerSummary];
  if chkTabTriggerDetail.Checked then Res := Res+[opTableTriggerDetail];
  if chkTabDoco.Checked then Res := Res+[opTableDocumentation];

  if chkViewDoco.Checked then Res := Res+[opViewDocumentation];
  if chkViewStruct.Checked then Res := Res+[opViewStructure];
  if chkViewDepend.Checked then Res := Res+[opViewDependencies];
  if chkViewTriggerSummary.Checked then Res := Res+[opViewTriggerSummary];
  if chkViewTriggerDetail.Checked then Res := Res+[opViewTriggerDetail];
  if chkViewSource.Checked then Res := Res+[opViewSource];

  if chkSPDoco.Checked then Res := Res+[opSPDocumentation];
  if chkSPCode.Checked then Res := Res+[opSPCode];

  if chkTrigDoco.Checked then Res := Res+[opTriggerDocumentation];
  if chkTrigCode.Checked then Res := Res+[opTriggerCode];

  if chkGeneratorDet.Checked then Res := Res+[opGeneratorDetail];

  if chkExDoco.Checked then Res := Res+[opExceptionDocumentation];
  if chkExCode.Checked then Res := Res+[opExceptionException];

  if chkUDFDoco.Checked then Res := Res+[opUDFDocumentation];
  if chkUDFCOde.Checked then Res := Res+[opUDFUDF];

  Result := Res;
end;

end.

{
$Log: GlobalPrintDialog.pas,v $
Revision 1.3  2002/06/06 07:36:43  tmuetze
Added a patch from Pavel Odstrcil: Now most basic print functions (right click in db navigator, print) work.

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
