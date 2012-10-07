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
// $Id: EditorUDF.pas,v 1.6 2005/05/20 19:24:09 rjmills Exp $

unit EditorUDF;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, Grids, DBGrids, DBCtrls, StdCtrls,	Printers, ExtCtrls,
	ActnList, ClipBrd,
	IBODataset,
	MarathonIDE,
	BaseDocumentDataAwareForm,
	MarathonProjectCacheTypes,
	MarathonInternalInterfaces,
	FrameDescription,
	FrameMetadata;

type
  TfrmUDFEditor = class(TfrmBaseDocumentDataAwareForm, IMarathonUDFEditor)
    pgObjectEditor: TPageControl;
    tsObject: TTabSheet;
		tsDocoView: TTabSheet;
    qryUtil: TIBOQuery;
    tsDDL: TTabSheet;
    framDoco: TframeDesc;
		stsEditor: TStatusBar;
		framDDL: TframDisplayDDL;
		Panel2: TPanel;
		lvUDFParams: TListView;
		Panel1: TPanel;
		Label5: TLabel;
		Label4: TLabel;
		Label3: TLabel;
		Label2: TLabel;
		Label1: TLabel;
		Label6: TLabel;
		cmbRtnType: TComboBox;
		edLibraryName: TEdit;
		edEntryPoint: TEdit;
		edUDFName: TEdit;
		edRtnParam: TEdit;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure pgObjectEditorChanging(Sender: TObject;	var AllowChange: Boolean);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure lvUDFParamsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure edUDFNameChange(Sender: TObject);
	private
		{ Private declarations }
		FErrors: Boolean;
		It : TMenuItem;
		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var Message: TMessage); message WM_MOVE;

		//Implementing IMarathonUDFEditor
		function IsInterbaseSix: Boolean;
		function GetCurrentName: String;
		function UDFParamCount: Integer;
		function ParamText(Index: Integer): String;
		function ReturnType: String;
		function EntryPoint: String;
		function LibraryName: String;

	public
		{ Public declarations }
		procedure LoadUDF(UDFName: String);
		procedure NewUDF;
		function InternalCloseQuery: Boolean; override;
		procedure SetObjectName(Value: String); override;
		procedure SetObjectModified(Value: Boolean); override;
		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar: TStatusBar; override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

    function CanViewNextPage: Boolean; override;
    procedure DOViewNextPage; override;

    function CanViewPrevPage: Boolean; override;
		procedure DOViewPrevPage; override;

    function CanObjectDrop: Boolean; override;
    procedure DoObjectDrop; override;

    function CanCompile: Boolean; override;
    procedure DoCompile; override;

		function CanSaveDoco: Boolean; override;
    procedure DoSaveDoco; override;

    function CanUndo: Boolean; override;
    procedure DoUndo; override;

    function CanRedo: Boolean; override;
    procedure DoRedo; override;

    function CanCaptureSnippet: Boolean; override;
    procedure DoCaptureSnippet; override;

    function CanCut: Boolean; override;
    procedure DoCut; override;

    function CanCopy: Boolean; override;
    procedure DoCopy; override;

    function CanPaste: Boolean; override;
		procedure DoPaste; override;

    function CanFind: Boolean; override;
    procedure DoFind; override;

    function CanFindNext: Boolean; override;
    procedure DoFindNext; override;

    function CanReplace: Boolean; override;
    procedure DoReplace; override;

    function CanSelectAll: Boolean; override;
		procedure DoSelectAll;  override;

    function CanObjectNewInputParam: Boolean; override;
    procedure DoObjectNewInputParam; override;

    function CanObjectDropInputParam: Boolean; override;
    procedure DoObjectDropInputParam; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;

	end;

implementation

uses
	Globals,
	HelpMap,
	CompileDBObject,
	DropObject,
	UDFInputParam;

{$R *.DFM}

const
	PG_UDF = 0;
	PG_DOCO = 1;
	PG_DDL = 2;

procedure TfrmUDFEditor.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmUDFEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;
	IT.Free;
	Action := caFree;
end;

procedure TfrmUDFEditor.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	inherited;
	FObjectType := ctUDF;

	HelpContext := IDH_Exceptions_Editor;

	pgObjectEditor.ActivePage := tsObject;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

	It := TMenuItem.Create(Self);
	It.Caption := '&1 UDF - [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);

	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framDDL.Init(TmpIntf);
end;

procedure TfrmUDFEditor.FormCloseQuery(Sender: TObject;	var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

procedure TfrmUDFEditor.pgObjectEditorChanging(Sender: TObject;	var AllowChange: Boolean);
begin
	if FNewObject then
	begin
		MessageDlg('You cannot change to Documentation View until the object has been compiled.', mtWarning, [mbOK], 0);
		AllowChange := False;
	end
	else
		case pgObjectEditor.ActivePage.PageIndex of
			PG_DOCO:
				if framDoco.Modified then
					if MessageDlg('Save changes to documentation?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
						framDoco.SaveDoco;
		end;
end;

procedure TfrmUDFEditor.pgObjectEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
				edUDFName.SetFocus;
			end;

		PG_DOCO:
			framDoco.SetActive;

		PG_DDL:
			begin
				framDDL.SetActive;
				if not FNewObject then
					framDDL.GetDDL;
			end;
	end;
end;

procedure TfrmUDFEditor.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmUDFEditor.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmUDFEditor.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

function TfrmUDFEditor.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if FObjectModified then
		begin
			case MessageDlg('The UDF ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
				mrYes:
					begin
						DoCompile;
						if FErrors then
							Result := False
						else
							Result := True;
					end;

				mrCancel:
					Result := False;

				mrNo:
					begin
						Result := True;
						FObjectModified := False;
					end;
			end;
		end;
		if framDoco.Modified then
		begin
			case MessageDlg('The documentation for UDF ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
				mrYes:
					framDoco.SaveDoco;

				mrCancel:
					Result := False;

				mrNo:
					begin
						Result := True;
						framDoco.Modified := False;
					end;
			end;
		end;
	end
  else
    Result := True;
end;

function TfrmUDFEditor.GetActiveStatusBar: TStatusBar;
begin
  Result := stsEditor;
end;

procedure TfrmUDFEditor.SetDatabaseName(const Value: String);
begin
  inherited;
  if Value = '' then
	begin
		qryUtil.IB_Connection := nil;
    framDoco.qryDoco.IB_Connection := nil;
    framDoco.qryDoco.IB_Transaction := nil;
    IsInterbase6 := False;
    SQLDialect := 0;
    stsEditor.Panels[3].Text := 'No Connection';
  end
  else
  begin
    qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
    qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

    framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
    framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

    IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
    SQLDialect := qryUtil.IB_Connection.SQLDialect;
    stsEditor.Panels[3].Text := Value;
  end;
end;

procedure TfrmUDFEditor.SetObjectModified(Value: Boolean);
begin
  inherited;
  FObjectModified := True;
end;

procedure TfrmUDFEditor.SetObjectName(Value: String);
begin
  inherited;
  FObjectName := Value;
  InternalCaption := 'UDF - [' + FObjectName + ']';
  IT.Caption := InternalCaption;
end;

procedure TfrmUDFEditor.LoadUDF(UDFName: String);
var
	RtnPosition: Integer;
	L: TListItem;

begin
	try
		FObjectName := UDFName;
		qryUtil.BeginBusy(False);
		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select * from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
		qryUtil.Open;

		// Now fill the controls
		edUDFName.Text := qryUtil.FieldByName('rdb$function_name').AsString;
		edEntryPoint.Text := qryUtil.FieldByName('rdb$entrypoint').AsString;
		edLibraryName.Text := qryUtil.FieldByName('rdb$module_name').AsString;
		RtnPosition := qryUtil.FieldByName('rdb$return_argument').AsInteger;

		qryUtil.Close;
		qryUtil.IB_Transaction.Commit;

		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select * from rdb$function_arguments where rdb$function_name = ' + AnsiQuotedStr(FObjectName, '''') + ' order by rdb$argument_position asc;');
		qryUtil.Open;

		while not qryUtil.EOF do
		begin
			if qryUtil.FieldByName('rdb$argument_position').AsInteger = RtnPosition then
			begin
				if FIsInterbase6 then
					edRtnParam.Text := ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
						qryUtil.FieldByName('rdb$field_length').AsInteger,
						qryUtil.FieldByName('rdb$field_scale').AsInteger,
						qryUtil.FieldByName('rdb$field_sub_type').AsInteger,
						qryUtil.FieldByName('rdb$field_precision').AsInteger,
						True, FSQLDialect)
				else
					edRtnParam.Text := ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
						qryUtil.FieldByName('rdb$field_length').AsInteger,
						qryUtil.FieldByName('rdb$field_scale').AsInteger,
						-1, -1, False, FSQLDialect);
				cmbRtnType.ItemIndex := qryUtil.FieldByName('rdb$mechanism').AsInteger;
			end
			else
			begin
				L := lvUDFParams.Items.Add;

				if FIsInterbase6 then
					L.Caption := ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
						qryUtil.FieldByName('rdb$field_length').AsInteger,
						qryUtil.FieldByName('rdb$field_scale').AsInteger,
						qryUtil.FieldByName('rdb$field_sub_type').AsInteger,
						qryUtil.FieldByName('rdb$field_precision').AsInteger,
						True, FSQLDialect)
				else
					L.Caption := ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
						qryUtil.FieldByName('rdb$field_length').AsInteger,
						qryUtil.FieldByName('rdb$field_scale').AsInteger,
						-1, -1, False, FSQLDialect);

				case qryUtil.FieldByName('rdb$mechanism').AsInteger of
					0:
						L.SubItems.Add('By Value');

					1:
						L.SubItems.Add('By Reference');
        end;
			end;
      qryUtil.Next;
    end;
    qryUtil.Close;
    qryUtil.IB_Transaction.Commit;

    InternalCaption := 'UDF - [' + FObjectName + ']';
    It.Caption := '&1 UDF - [' + FObjectName + ']';

    FObjectModified := False;
    FNewObject := False;

    framDoco.LoadDoco;
  finally
    qryUtil.EndBusy;
  end;
end;

procedure TfrmUDFEditor.NewUDF;
begin
  FObjectName := 'new_udf';
  InternalCaption := 'UDF - [' + FObjectName + ']';
  edUDFName.Text := FObjectName;
  ActiveControl := edUDFName;
	FObjectModified := True;
  FNewObject := True;
end;

function TfrmUDFEditor.CanObjectDrop: Boolean;
begin
  Result := False;
  if pgObjectEditor.ActivePage = tsObject then
		Result := not FNewObject;
end;

procedure TfrmUDFEditor.DoObjectDrop;
var
	DoClose: Boolean;
	frmDropObject: TfrmDropObject;

begin
	if MessageDlg('Are you sure that you wish to drop the UDF "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctUDF, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

function TfrmUDFEditor.CanCompile: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edUDFName.Text <> '';
end;

function TfrmUDFEditor.CanSaveDoco: Boolean;
begin
	Result := framDoco.Modified;
end;

procedure TfrmUDFEditor.DoCompile;
var
	Doco, CompileText: String;
	TmpIntf : IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	Doco := framDoco.Doco;

	Refresh;
	if edUDFName.Text = '' then
	begin
		MessageDlg('The UDF must have a name.', mtError, [mbOK], 0);
		edUDFName.SetFocus;
		Exit;
	end;

	if edEntryPoint.Text = '' then
	begin
		MessageDlg('The UDF must have an Entry Point.', mtError, [mbOK], 0);
		edEntryPoint.SetFocus;
		Exit;
	end;

	if edLibraryName.Text = '' then
	begin
		MessageDlg('The UDF must have a Library Name.', mtError, [mbOK], 0);
		edLibraryName.SetFocus;
		Exit;
	end;

	if edRtnParam.Text = '' then
	begin
		MessageDlg('The UDF must have a Return Parameter.', mtError, [mbOK], 0);
		edRtnParam.SetFocus;
		Exit;
	end;

	CompileText := '';

	TmpIntf := Self;
	FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctUDF, CompileText);
	FErrors := FCompile.CompileErrors;
	FCompile.Free;

	if FErrors then
		Exit;

	if FNewObject then
		// Update the tree cache
		MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctUDF);

	FNewObject := False;
	FObjectModified := False;

	framDoco.Doco := Doco;
	framDoco.SaveDoco;
end;

procedure TfrmUDFEditor.DoSaveDoco;
begin
	framDoco.SaveDoco;
end;

function TfrmUDFEditor.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmUDFEditor.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

procedure TfrmUDFEditor.DOViewNextPage;
begin
	pgObjectEditor.SelectNextPage(True);
end;

procedure TfrmUDFEditor.DOViewPrevPage;
begin
  pgObjectEditor.SelectNextPage(False);
end;

function TfrmUDFEditor.CanCaptureSnippet: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCaptureSnippet;

		PG_DDL:
			Result := framDDL.CanCaptureSnippet;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanCopy: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCopy;

		PG_DDL:
			Result := framDDL.CanCopy;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanCut: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCut;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanFind: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanFind;

		PG_DDL:
			Result := framDDL.CanFind;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanFindNext: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanFindNext;

		PG_DDL:
			Result := framDDL.CanFindNext;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanPaste: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanPaste;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanRedo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanRedo;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanReplace: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanReplace;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanSelectAll: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanSelectAll;

		PG_DDL:
			Result := framDDL.CanSelectAll;
	else
		Result := False;
	end;
end;

function TfrmUDFEditor.CanUndo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanUndo;

		PG_DDL:
			Result := False;
	else
    Result := False;
  end;
end;

procedure TfrmUDFEditor.DoCaptureSnippet;
begin
  case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.CaptureSnippet;

		PG_DDL:
			framDDL.CaptureSnippet;
	end;
end;

procedure TfrmUDFEditor.DoCopy;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.CopyToClipboard;

		PG_DDL:
			framDDL.CopyToClipboard;
	end;
end;

procedure TfrmUDFEditor.DoCut;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.CutToClipBoard;
	end;
end;

procedure TfrmUDFEditor.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSFind;

		PG_DDL:
			framDDL.WSFind;
	end;
end;

procedure TfrmUDFEditor.DoFindNext;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSFindNext;

		PG_DDL:
			framDDL.WSFindNext;
	end;
end;

procedure TfrmUDFEditor.DoPaste;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.PasteFromClipboard;
	end;
end;

procedure TfrmUDFEditor.DoRedo;
begin
  case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.Redo;
	end;
end;

procedure TfrmUDFEditor.DoReplace;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSReplace;
	end;
end;

procedure TfrmUDFEditor.DoSelectAll;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.SelectAll;

		PG_DDL:
			framDDL.SelectAll;
	end;
end;

procedure TfrmUDFEditor.DoUndo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.Undo;
	end;
end;

function TfrmUDFEditor.EntryPoint: String;
begin
	Result := edEntryPoint.Text;
end;

function TfrmUDFEditor.GetCurrentName: String;
begin
	Result := edUDFName.Text;
end;

function TfrmUDFEditor.IsInterbaseSix: Boolean;
begin
	Result := FIsInterbase6;
end;

function TfrmUDFEditor.LibraryName: String;
begin
	Result := edLibraryName.Text;
end;

function TfrmUDFEditor.ParamText(Index: Integer): String;
begin
	Result := lvUDFParams.Items.Item[Index].Caption;
	if lvUDFParams.Items.Item[Index].SubItems[0] = 'By Value' then
		Result := Result + ' by value';
end;

function TfrmUDFEditor.ReturnType: String;
begin
  Result := edRtnParam.Text;
  if cmbRtnType.Text = 'value' then
    Result := Result + ' by value';
end;

function TfrmUDFEditor.UDFParamCount: Integer;
begin
  Result := lvUDFParams.Items.Count;
end;

function TfrmUDFEditor.CanObjectNewInputParam: Boolean;
begin
  Result := pgObjectEditor.ActivePage = tsObject;
end;

procedure TfrmUDFEditor.DoObjectNewInputParam;
var
  frmUDFAddInput: TfrmUDFAddInput;
  I : TListItem;

begin
  frmUDFAddInput := TfrmUDFAddInput.Create(Self);
	try
		with frmUDFAddInput do
		begin
			if ShowModal = mrOK then
			begin
				I := lvUDFParams.Items.Add;
				I.Caption := LowerCase(edParameter.Text);
				case cmbRtnType.ItemIndex of
					0:
						I.SubItems.Add('By Value');

					1:
						I.SubItems.Add('By Reference');
				end;
			end;
		end;
	finally
		frmUDFAddInput.Free;
	end;
end;

function TfrmUDFEditor.CanObjectDropInputParam: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsObject) and
		(lvUDFParams.Selected <> nil);
end;

procedure TfrmUDFEditor.DoObjectDropInputParam;
begin
	if MessageDlg('Are you sure you want to delete this Parameter?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		lvUDFParams.Selected.Delete;
end;

procedure TfrmUDFEditor.lvUDFParamsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			if CanObjectNewInputParam then
				DoObjectNewInputParam;

		VK_DELETE:
			if CanObjectDropInputParam then
				DoObjectDropInputParam;
	end;
end;

procedure TfrmUDFEditor.EnvironmentOptionsRefresh;
begin
	inherited;
end;

procedure TfrmUDFEditor.ProjectOptionsRefresh;
begin
	inherited;
end;

procedure TfrmUDFEditor.edUDFNameChange(Sender: TObject);
begin
	inherited;
	CheckNameLength(edUDFName.Text);
end;

function TfrmUDFEditor.CanPrint: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			Result := (not FNewObject);

		PG_DOCO:
			Result := (not FNewObject) and framDoco.CanPrint;

		PG_DDL:
			Result := (not FNewObject) and framDDL.CanPrint;
	end;
end;

function TfrmUDFEditor.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

procedure TfrmUDFEditor.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			MarathonIDEInstance.PrintUDF(False, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrint;

		PG_DDL:
			framDDL.DoPrint;
	end;
end;

procedure TfrmUDFEditor.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_UDF:
			MarathonIDEInstance.PrintUDF(True, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrintPreview;

		PG_DDL:
			framDDL.DoPrintPreview;
	end;
end;

end.

{
$Log: EditorUDF.pas,v $
Revision 1.6  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.5  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.4  2002/04/29 10:45:38  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/29 10:30:28  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
