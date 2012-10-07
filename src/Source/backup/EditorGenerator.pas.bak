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
// $Id: EditorGenerator.pas,v 1.5 2005/05/20 19:24:08 rjmills Exp $

unit EditorGenerator;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, DBCtrls, StdCtrls, ExtCtrls, ClipBrd, Spin, ActnList,
	IBODataset,
	BaseDocumentDataAwareForm,
	MarathonProjectCacheTypes,
	MarathonInternalInterfaces,
	FrameMetadata;

type
  TfrmGenerators = class(TfrmBaseDocumentDataAwareForm)
    pgObjectEditor: TPageControl;
    tsGeneratorView: TTabSheet;
    Label1: TLabel;
    edGeneratorName: TEdit;
    Label2: TLabel;
    udGenerator: TSpinEdit;
    qryGenerator: TIBOQuery;
    tsDDLView: TTabSheet;
    Button1: TButton;
    btnSave: TButton;
		stsEditor: TStatusBar;
    ActionList1: TActionList;
    actReset: TAction;
    actSave: TAction;
    framDDL: TframDisplayDDL;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure udGeneratorChange(Sender: TObject);
		procedure pgObjectEditorChanging(Sender: TObject;	var AllowChange: Boolean);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure actSaveExecute(Sender: TObject);
		procedure actSaveUpdate(Sender: TObject);
		procedure actResetExecute(Sender: TObject);
		procedure actResetUpdate(Sender: TObject);
		procedure edGeneratorNameChange(Sender: TObject);
	private
		{ Private declarations }
		It : TMenuItem;
		FErrors : Boolean;
		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var Message : TMessage); message WM_MOVE;
	public
		procedure LoadGenerator(GeneratorName : String);
		procedure NewGenerator;
		function InternalCloseQuery : Boolean; override;
		procedure SetObjectName(Value : String); override;
		procedure SetObjectModified(Value : Boolean); override;
		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar : TStatusBar; override;

		function CanPrint : Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview : Boolean; override;
		procedure DoPrintPreview; override;

		function CanViewNextPage : Boolean; override;
		procedure DOViewNextPage; override;

		function CanViewPrevPage : Boolean; override;
		procedure DOViewPrevPage; override;

    function CanObjectDrop : Boolean; override;
    procedure DoObjectDrop; override;

    function CanCompile : Boolean; override;
    procedure DoCompile; override;

    function CanCopy : Boolean; override;
    procedure DoCopy; override;

    function CanFind : Boolean; override;
    procedure DoFind; override;

    function CanFindNext : Boolean; override;
    procedure DoFindNext; override;

    function CanSelectAll : Boolean; override;
    procedure DoSelectAll;  override;

		function CanResetValue : Boolean; override;
    procedure DoResetValue; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;
	end;

const
	PG_GENERATOR    = 0;
	PG_DDL          = 1;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE,
	DropObject,
	CompileDBObject;

{$R *.DFM}

procedure TfrmGenerators.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmGenerators.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;
	IT.Free;
	Action := caFree;
end;

procedure TfrmGenerators.FormCreate(Sender: TObject);
var
	TmpIntf : IMarathonForm;

begin
	FObjectType := ctGenerator;
	pgObjectEditor.ActivePage := tsGeneratorView;
	HelpContext := IDH_Generator_Editor;
	ActiveControl := edGeneratorName;
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height Div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

	TmpIntf := Self;
	framDDL.Init(TmpIntf);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 Generator - [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);
end;

procedure TfrmGenerators.udGeneratorChange(Sender: TObject);
begin
	FObjectModified := True;
end;

procedure TfrmGenerators.pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
begin
	if FNewObject and (pgObjectEditor.ActivePage = tsGeneratorView) then
	begin
		MessageDlg('You cannot view the DDL until the object has been compiled.', mtInformation, [mbOK], 0);
		AllowChange := False;
	end;
end;

procedure TfrmGenerators.pgObjectEditorChange(Sender: TObject);
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin
        //blank the panels...
        stsEditor.Panels[0].Text := '';
        stsEditor.Panels[1].Text := '';
        stsEditor.Panels[2].Text := '';
      end;

    PG_DDL:
      begin
        framDDL.SetActive;
        if not FNewObject then
          framDDL.GetDDL;
      end;
  end;
end;

procedure TfrmGenerators.FormResize(Sender: TObject);
begin
  MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmGenerators.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmGenerators.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

function TfrmGenerators.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

function TfrmGenerators.InternalCloseQuery: Boolean;
begin
  if Not FDropClose then
  begin
    Result := True;
    if FObjectModified then
    begin
      case MessageDlg('The generator ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            if FNewObject then
              DoCompile
            else
              DoResetValue;
            if FErrors then
              Result := False
            else
              Result := True;
          end;
        mrCancel :
          Result := False;
        mrNo :
          Result := True;
      end;
    end;
  end
  else
    Result := True;
end;

procedure TfrmGenerators.LoadGenerator(GeneratorName: String);
begin
  qryGenerator.BeginBusy(False);
  try
    qryGenerator.SQL.Clear;
    qryGenerator.SQL.Add('select rdb$generator_name from rdb$generators where rdb$generator_name = ''' + GeneratorName + ''';');
    qryGenerator.Open;
    edGeneratorName.Text := qryGenerator.FieldByName('rdb$generator_name').AsString;
    qryGenerator.Close;
    qryGenerator.IB_Transaction.Commit;

    //get current value....
    qryGenerator.SQL.Clear;
    qryGenerator.SQL.Add('select distinct gen_id(' + GeneratorName + ', 0) from rdb$database');
    qryGenerator.Open;
    udGenerator.Value := qryGenerator.Fields[0].AsInteger;
    qryGenerator.Close;
    qryGenerator.IB_Transaction.Commit;

    FObjectName := GeneratorName;
    InternalCaption := 'Generator - [' + FObjectName + ']';
    FNewObject := False;
    FObjectModified := False;
    edGeneratorName.ReadOnly := True;
  finally
    qryGenerator.EndBusy;
  end;
end;

procedure TfrmGenerators.NewGenerator;
begin
  FObjectName := 'new_generator';
  InternalCaption := 'Generator - [' + FObjectName + ']';
  edGeneratorName.Text := FObjectName;
  udGenerator.Enabled := False;
  FNewObject := True;
  FObjectModified := True;
end;

procedure TfrmGenerators.SetDatabaseName(const Value: String);
begin
  inherited;
  if Value = '' then
  begin
    qryGenerator.IB_Connection := nil;
    IsInterbase6 := False;
    SQLDialect := 0;
    stsEditor.Panels[3].Text := 'No Connection';
  end
  else
  begin
    qryGenerator.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
    qryGenerator.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

    IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
    SQLDialect := qryGenerator.IB_Connection.SQLDialect;
    stsEditor.Panels[3].Text := Value;
  end;
end;

procedure TfrmGenerators.SetObjectModified(Value: Boolean);
begin
  inherited;
  FObjectModified := True;
end;

procedure TfrmGenerators.SetObjectName(Value: String);
begin
  inherited;
  FObjectName := Value;
  InternalCaption := 'Generator - [' + FObjectName + ']';
  IT.Caption := Caption;
end;

procedure TfrmGenerators.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
    CanClose := True
  else
    CanClose := InternalCloseQuery;
end;

function TfrmGenerators.CanCompile: Boolean;
begin
  Result := FNewObject;
end;

function TfrmGenerators.CanObjectDrop: Boolean;
begin
  Result := not FNewObject;
end;

procedure TfrmGenerators.DoCompile;
var
  FCompile : TfrmCompileDBObject;
  TmpIntf : IMarathonForm;

begin
  //compile the generator....
  if edGeneratorName.Text = '' then
  begin
    MessageDlg('Generator must have a name.', mtError, [mbOK], 0);
    edGeneratorName.SetFocus;
    Exit;
  end;
  TmpIntf := Self;
  FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryGenerator.IB_Connection, qryGenerator.IB_Transaction, ctGenerator, edGeneratorName.Text);
  FCompile.Free;

  if FNewObject then
  begin
    //update the tree cache...
    MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctGenerator);
  end;
  FNewObject := False;
	FObjectModified := False;
end;

procedure TfrmGenerators.DoObjectDrop;
var
  frmDropObject : TfrmDropObject;
  DoClose : Boolean;

begin
  If MessageDlg('Are you sure that you wish to drop the generator "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctGenerator, FObjectName);
    DoClose := frmDropObject.ModalResult = mrOK;
    frmDropObject.Free;
    if DoClose then
      DropClose;
  end;
end;

function TfrmGenerators.CanResetValue: Boolean;
begin
  Result := not(FNewObject) and (pgObjectEditor.ActivePage = tsGeneratorView);
end;

procedure TfrmGenerators.DoResetValue;
begin
  //reset value to the spin edit control value...
  If MessageDlg('Are you sure that you wish set the Generator "' + FObjectName + '" to the value ' + IntToStr(udGenerator.Value) + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    qryGenerator.Close;
    qryGenerator.SQL.Clear;
    qryGenerator.SQL.Add('set generator ' + FObjectName + ' to ' + IntToStr(udGenerator.Value) + ';');
    try
      qryGenerator.ExecSQL;
      qryGenerator.IB_Transaction.Commit;
      //write to script system
      MarathonIDEInstance.RecordToScript(qryGenerator.SQL.Text, GetActiveConnectionName);
      FObjectModified := False;
    except
			On E : Exception do
      begin
        qryGenerator.IB_Transaction.Rollback;
        MessageDlg(E.Message, mtError, [mbOK], 0);
      end;
    end;
  end;
end;

procedure TfrmGenerators.actSaveExecute(Sender: TObject);
begin
  inherited;
  DoCompile;
end;

procedure TfrmGenerators.actSaveUpdate(Sender: TObject);
begin
  inherited;
  (Sender As TAction).Enabled := CanCOmpile;
end;

procedure TfrmGenerators.actResetExecute(Sender: TObject);
begin
  inherited;
  DoResetValue;
end;

procedure TfrmGenerators.actResetUpdate(Sender: TObject);
begin
  inherited;
  (Sender As TAction).Enabled := CanResetValue;
end;

function TfrmGenerators.CanCopy: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin
        Result := False;
			end;
		PG_DDL:
			begin
				Result := framDDL.CanCopy;
			end;
	else
		Result := False;
	end;
end;

function TfrmGenerators.CanFind: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin
        Result := False;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanFind;
      end;
  else
    Result := False;
  end;
end;

function TfrmGenerators.CanFindNext: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin
        Result := False;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanFindNext;
      end;
  else
    Result := False;
  end;
end;

function TfrmGenerators.CanSelectAll: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin
        Result := False;
			end;
    PG_DDL:
      begin
        Result := framDDL.CanSelectAll;
      end;
  else
    Result := False;
  end;
end;

procedure TfrmGenerators.DoCopy;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin

      end;
		PG_DDL:
			begin
				framDDL.CopyToClipboard;
			end;
	end;
end;

procedure TfrmGenerators.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_GENERATOR:
			begin

			end;
		PG_DDL:
			begin
				framDDL.WSFind;
			end;
	end;
end;

procedure TfrmGenerators.DoFindNext;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
      begin

      end;
    PG_DDL:
      begin
        framDDL.WSFindNext;
      end;
  end;
end;

procedure TfrmGenerators.DoSelectAll;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_GENERATOR:
			begin

      end;
    PG_DDL:
      begin
        framDDL.SelectAll;
      end;
  end;
end;

function TfrmGenerators.CanViewNextPage: Boolean;
begin
  Result := True;
end;

procedure TfrmGenerators.DOViewNextPage;
begin
  pgObjectEditor.SelectNextPage(True);
end;

function TfrmGenerators.CanViewPrevPage: Boolean;
begin
  Result := True;
end;

procedure TfrmGenerators.DOViewPrevPage;
begin
  pgObjectEditor.SelectNextPage(False);
end;

procedure TfrmGenerators.EnvironmentOptionsRefresh;
begin
  inherited;

end;

procedure TfrmGenerators.ProjectOptionsRefresh;
begin
  inherited;

end;

procedure TfrmGenerators.edGeneratorNameChange(Sender: TObject);
begin
  inherited;
  FObjectModified := True;
  CheckNameLength(edGeneratorName.Text);
end;

function TfrmGenerators.CanPrint: Boolean;
begin
  Result := True;
	case pgObjectEditor.ActivePage.PageIndex of
		0 :
			begin
				Result := (not FNewObject);
			end;
		1 :
			begin
				Result := (not FNewObject) and framDDL.CanPrint;
			end;
	end;
end;

function TfrmGenerators.CanPrintPreview: Boolean;
begin
  Result := CanPrint;
end;

procedure TfrmGenerators.DoPrint;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    0 :
      begin
        MarathonIDEInstance.PrintGenerator(False, FObjectName, FDatabaseName);
      end;
    1 :
      begin
        framDDL.DoPrint;
			end;
  end;
end;

procedure TfrmGenerators.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
    0 :
      begin
        MarathonIDEInstance.PrintGenerator(True, FObjectName, FDatabaseName);
      end;
    1 :
      begin
        framDDL.DoPrintPreview;
      end;
  end;
end;

end.

{
$Log: EditorGenerator.pas,v $
Revision 1.5  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.4  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.3  2002/04/29 11:43:41  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
