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
// $Id: EditorDomain.pas,v 1.6 2005/05/20 19:24:08 rjmills Exp $

unit EditorDomain;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, ExtCtrls, DB,	Printers, Menus,	ClipBrd,
	IB_Header,
	IBODataset,
	rmCollectionListBox,
	rmPanel,
	SynEdit,
	SyntaxMemoWithStuff2,
	BaseDocumentDataAwareForm,
	MarathonInternalInterfaces,
	FrameMetadata,
	FrameDescription, rmNotebook2;

type
	TfrmDomains = class(TfrmBaseDocumentDataAwareForm, IMarathonDomainEditor)
    pgObjectEditor: TPageControl;
		tsMain: TTabSheet;
    edColumn: TEdit;
    Label1: TLabel;
		tsDefault: TTabSheet;
		tsConstraint: TTabSheet;
    Bevel1: TBevel;
    qryDomain: TIBOQuery;
    tsDDL: TTabSheet;
    Label3: TLabel;
    cmbDataType: TComboBox;
    nbType: TrmNoteBookControl;
    Label4: TLabel;
    Label9: TLabel;
    nbpBlank : TrmNotebookPage;
    nbpBlob : TrmNotebookPage;
    nbpNumeric : TrmNotebookPage;
    nbpChar : TrmNotebookPage;
    edLength: TEdit;
    udLen: TUpDown;
    cmbCharCharSet: TComboBox;
    Label14: TLabel;
    Label15: TLabel;
    edPrecision: TEdit;
    edScale: TEdit;
    upPrec: TUpDown;
    upScale: TUpDown;
    Label18: TLabel;
    Label6: TLabel;
    Label11: TLabel;
    edSubType: TEdit;
    cmbBlobCharSet: TComboBox;
    edSegSize: TEdit;
    udSegLength: TUpDown;
    chkColNotNull: TCheckBox;
    tsDescription: TTabSheet;
    framDoco: TframeDesc;
    pnlArray: TPanel;
    Label10: TLabel;
    lvArray: TListView;
    btnAddDimension: TButton;
		btnDeleteDimension: TButton;
    btnEditDimension: TButton;
    framDDL: TframDisplayDDL;
		stsEditor: TStatusBar;
    pnlMessages: TPanel;
    lstResults: TrmCollectionListBox;
		edDefault: TSyntaxMemoWithStuff2;
		edConstraint: TSyntaxMemoWithStuff2;
		Label2: TLabel;
		cmbCollate: TComboBox;
		Label5: TLabel;
		cmbBlobCollate: TComboBox;
		procedure cmbDataTypeChange(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure edColDefaultChange(Sender: TObject);
		procedure edColCheckChange(Sender: TObject);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure btnAddDimensionClick(Sender: TObject);
		procedure btnDeleteDimensionClick(Sender: TObject);
		procedure btnEditDimensionClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure edColumnChange(Sender: TObject);
		procedure edLengthChange(Sender: TObject);
	private
		{ Private declarations }
		It : TMenuItem;
		FErrors: Boolean;

		FChangeDefault: Boolean;
		FChangeCheck: Boolean;
		FChangeName: Boolean;
		FChangeDataType: Boolean;

		function GetDataType: String;
		function GetDefault: String;
		function GetNotNull: String;
		function GetCheck: String;

		function GetSaveFieldType: Integer;
		function GetSaveFieldLength: Integer;
		function GetSaveFieldScale: Integer;

		procedure SaveDomain;
		function GetCollate: String;

		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var Message: TMessage); message WM_MOVE;
		procedure AddError(Info: String);
	public
		{ Public declarations }
		procedure NewDomain;
		procedure LoadDomain(DomainName: String);
		function InternalCloseQuery: Boolean; override;
		procedure SetObjectName(Value: String); override;
		procedure SetObjectModified(Value: Boolean); override;
		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar: TStatusBar; override;
		procedure AddCompileError(ErrorText: String); override;
		procedure ClearErrors; override;
		procedure ForceRefresh; override;
		procedure OpenMessages; override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

		function CanInternalClose: Boolean; override;
		procedure DoInternalClose; override;

		function CanViewNextPage: Boolean; override;
		procedure DoViewNextPage; override;

		function CanViewPrevPage: Boolean; override;
		procedure DoViewPrevPage; override;

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

    function CanViewMessages: Boolean; override;
		function AreMessagesVisible: Boolean; override;
		procedure DoViewMessages; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE,
	MarathonProjectCacheTypes,
	CompileDBObject,
	DropObject,
	ArrayDialog;

const
	TY_NONE = -1;
	TY_SMALLINT = 0;
	TY_INTEGER = 1;
	TY_FLOAT = 2;
	TY_DOUBLE_PRECISION = 3;
	TY_DECIMAL = 4;
	TY_NUMERIC = 5;
	TY_DATE = 6;
	TY_TIME = 7;
	TY_TIMESTAMP = 8;
	TY_CHAR = 9;
	TY_VARCHAR = 10;
	TY_BLOB = 11;

	PG_DOMAIN = 0;
	PG_DEFAULT = 1;
	PG_CONSTRAINT = 2;
	PG_DESC = 3;
	PG_DDL = 4;

{$R *.DFM}

procedure TfrmDomains.cmbDataTypeChange(Sender: TObject);
begin
  FChangeDataType := True;
  if cmbDataType.ItemIndex = -1 then
  begin
    nbType.ActivePage := nbpBlank;
    pnlArray.Visible := True;
  end
	else
	begin
		case cmbDataType.ItemIndex of
			TY_DECIMAL:
				begin
					nbType.ActivePage := nbpNumeric;
					pnlArray.Visible := True;
				end;

			TY_NUMERIC:
				begin
					nbType.ActivePage := nbpNumeric;
					pnlArray.Visible := True;
				end;

			TY_CHAR:
				begin
					nbType.ActivePage := nbpChar;
					pnlArray.Visible := True;
				end;

			TY_VARCHAR:
				begin
					nbType.ActivePage := nbpChar;
					pnlArray.Visible := True;
				end;

			TY_BLOB:
				begin
					nbType.ActivePage := nbpBlob;
					pnlArray.Visible := False;
				end;
		else
			nbType.ActivePage := nbpBlank;
			pnlArray.Visible := True;
		end;
	end;
end;

function TfrmDomains.GetDataType: String;
var
	Idx: Integer;

begin
	Result := cmbDataType.Text;

	case cmbDataType.ItemIndex of
		TY_NUMERIC, TY_DECIMAL:
			begin
				Result := Result + '(' + edPrecision.Text + ', ' + edScale.Text + ')';
				if lvArray.Items.Count > 0 then
				begin
					Result := Result + ' [';
					for Idx := 0 to lvArray.Items.Count - 1 do
						Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
					Result := Trim(Result);
					if Result[Length(Result)] = ',' then
						Result := Copy(Result, 1, Length(Result) - 1);
					Result := Result + ']';
				end;
			end;

		TY_CHAR, TY_VARCHAR:
			begin
				Result := Result + '(' + edLength.Text + ')';
				if lvArray.Items.Count > 0 then
				begin
					Result := Result + ' [';
					for Idx := 0 to lvArray.Items.Count - 1 do
						Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
					Result := Trim(Result);
					if Result[Length(Result)] = ',' then
						Result := Copy(Result, 1, Length(Result) - 1);
					Result := Result + ']';
				end;
				if not ((cmbCharCharSet.Text = '') or (cmbCharCharSet.Text = 'NONE')) then
					Result := Result + ' character set ' + cmbCharCharSet.Text;
			end;

		TY_BLOB:
			begin
				Result := Result + ' sub_type ' + edSubType.Text;
				Result := Result + ' segment size ' + IntToStr(udSegLength.Position);
				if not ((cmbBlobCharSet.Text = '') or (cmbBlobCharSet.Text = 'NONE')) then
					Result := Result + ' character set ' + cmbBlobCharSet.Text;
			end;
	else
		begin
			if lvArray.Items.Count > 0 then
			begin
				Result := Result + ' [';
				for Idx := 0 to lvArray.Items.Count - 1 do
					Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
				Result := Trim(Result);
				if Result[Length(Result)] = ',' then
					Result := Copy(Result, 1, Length(Result) - 1);
				Result := Result + ']';
			end;
		end;
	end;
end;

function TfrmDomains.GetDefault: String;
var
	Temp: String;
begin
	Temp := Trim(edDefault.Text);
	if Temp <> '' then
	begin
		if Pos('default', AnsiLowerCase(Temp)) = 0 then
			Temp := 'default ' + Temp;
		Result := ' ' + Temp
	end
	else
		Result := ' ';
end;

function TfrmDomains.GetNotNull: String;
begin
	if chkColNotNull.Checked then
		Result := ' not null'
	else
		Result := ' ';
end;

function TfrmDomains.GetCheck: String;
var
	Temp: String;
begin
	Temp := Trim(edConstraint.Text);
	if Temp <> '' then
	begin
		if Pos('check', AnsiLowerCase(Temp)) = 0 then
		 Temp := 'check ' + Temp;
		Result := ' ' + Temp;
	end
	else
		Result := ' ';
end;

function TfrmDomains.GetCollate: String;
begin
	if (cmbCollate.Text <> '') then
		Result := ' collate ' + cmbCollate.Text
	else
		Result := ' ';
end;

function TfrmDomains.GetSaveFieldType: Integer;
begin
	case cmbDataType.ItemIndex of
		TY_SMALLINT:
			Result := blr_short;

		TY_INTEGER:
			Result := blr_long;

		TY_FLOAT:
			Result := blr_float;

		TY_DOUBLE_PRECISION:
			Result := blr_double;

		TY_DECIMAL, TY_NUMERIC:
			begin
				case upPrec.Position of
					1..9:
						Result := blr_long;
				else
					Result := blr_double;
				end;
			end;

		TY_DATE:
			Result := blr_timestamp;

		TY_TIME:
			raise Exception.Create('TIME datatype not supported in this version of Firebird/InterBase.');

		TY_TIMESTAMP:
			raise Exception.Create('TIMESTAMP datatype Not supported in this version of Firebird/InterBase.');

		TY_CHAR:
			Result := blr_text;

		TY_VARCHAR:
			Result := blr_varying;

		TY_BLOB:
			Result := blr_blob;
	else
		Result := -1;
	end;
end;

function TfrmDomains.GetSaveFieldLength: Integer;
begin
	case cmbDataType.ItemIndex of
		TY_SMALLINT:
			Result := 2;

		TY_INTEGER:
			Result := 4;

		TY_FLOAT:
			Result := 4;

		TY_DOUBLE_PRECISION:
			Result := 8;

		TY_DECIMAL,
		TY_NUMERIC:
			begin
				case upPrec.Position of
					1..9:
						Result := 4;
				else
					Result := 8;
				end;
			end;

		TY_DATE,
		TY_TIME,
		TY_TIMESTAMP:
			Result := 8;

		TY_CHAR:
			Result := udLen.Position;

		TY_VARCHAR:
			Result := udLen.Position;

		TY_BLOB:
			Result := 8;
	else
		Result := -1;
	end;
end;

function TfrmDomains.GetSaveFieldScale: Integer;
begin
	case cmbDataType.ItemIndex of
		TY_SMALLINT:
			Result := 0;

		TY_INTEGER:
			Result := 0;

		TY_FLOAT:
			Result := 0;

		TY_DOUBLE_PRECISION:
			Result := 0;

		TY_DECIMAL,
		TY_NUMERIC:
			begin
				case upPrec.Position of
					1..9:
						Result := -(upScale.Position);
				else
					Result := -(upScale.Position);
				end;
			end;

		TY_DATE,
		TY_TIME,
		TY_TIMESTAMP:
			Result := 0;

		TY_CHAR:
			Result := udLen.Position;

		TY_VARCHAR:
			Result := udLen.Position;

		TY_BLOB:
			Result := 0;
	else
		Result := -1;
	end;
end;

procedure TfrmDomains.SaveDomain;
var
	Rec: String;

begin
	if IsInterbase6 then
  begin
    qryDomain.Close;
    qryDomain.SQL.Clear;
    qryDomain.RequestLive := True;
		qryDomain.SQL.Add('select rdb$field_name, rdb$field_type, rdb$null_flag, rdb$field_length, rdb$field_scale, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
    qryDomain.Open;
    try
      try
        qryDomain.Edit;
				// Not Null constraint
				if chkColNotNull.Checked then
				begin
					qryDomain.FieldByName('rdb$null_flag').AsInteger := 1;
					Rec := 'update rdb$fields set rdb$null_flag = 1 where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';';
					MarathonIDEInstance.RecordToScript(Rec, FDatabaseName);
				end
				else
				begin
					qryDomain.FieldByName('rdb$null_flag').Clear;
					Rec := 'update rdb$fields set rdb$null_flag = NULL where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';';
					MarathonIDEInstance.RecordToScript(Rec, FDatabaseName);
				end;

				qryDomain.Post;
				qryDomain.Close;

				if FChangeDataType then
				begin
					qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' type ' + GetDataType;
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
				end;

				if FChangeName then
				begin
					qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' to ' + edColumn.Text;
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
				end;

				if FChangeDefault then
				begin
					qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect)  + ' drop default';
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);

					if edDefault.Text <> '' then
					begin
						qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' set' + GetDefault;
						qryDomain.ExecSQL;
						MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
					end;
				end;

				if FChangeCheck then
				begin
					qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' drop constraint';
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);

					if edConstraint.Text <> '' then
					begin
						qryDomain.SQL.Text := 'alter domain ' + MakeQuotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' add' + GetCheck;
						qryDomain.ExecSQL;
						MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
					end;
				end;

				qryDomain.IB_Transaction.Commit;
				SetObjectName(edColumn.Text);
			except
				on E : Exception do
				begin
					qryDomain.IB_Transaction.Rollback;
					raise;
				end;
			end;
		finally
			qryDomain.Close;
		end;
	end
	else
	begin
		qryDomain.Close;
		qryDomain.SQL.Clear;
		qryDomain.RequestLive := True;
		qryDomain.SQL.Add('select rdb$field_name, rdb$field_type, rdb$null_flag, rdb$field_length, rdb$field_scale, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
		qryDomain.Open;
		try
			// Check to see if we are changing from or to a blob
			if qryDomain.FieldByName('rdb$field_type').AsInteger <> GetSaveFieldType then
			begin
				if ((qryDomain.FieldByName('rdb$field_type').AsInteger = blr_blob) or (GetSaveFieldType = blr_blob)) then
				begin
					raise Exception.Create('Firebird/InterBase does not allow data types to be changed to or from a blob.');
				end;
			end;

			try
				qryDomain.Edit;
				// Not Null constraint
				if chkColNotNull.Checked then
				begin
					qryDomain.FieldByName('rdb$null_flag').AsInteger := 1;
					qryDomain.FieldByName('rdb$field_type').AsInteger := GetSaveFieldType;
					qryDomain.FieldByName('rdb$field_length').AsInteger := GetSaveFieldLength;
					qryDomain.FieldByName('rdb$field_scale').AsInteger := GetSaveFieldScale;
					Rec := 'update rdb$fields set rdb$null_flag = 1, rdb$field_type = ' + IntToStr(GetSaveFieldType) +
						'rdb$field_length = ' + IntToStr(GetSaveFieldLength) +
						'rdb$field_scale = ' + IntToStr(GetSaveFieldScale) +
						'where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';';
					MarathonIDEInstance.RecordToScript(Rec, FDatabaseName);
				end
				else
				begin
					qryDomain.FieldByName('rdb$null_flag').Clear;
					qryDomain.FieldByName('rdb$field_type').AsInteger := GetSaveFieldType;
					qryDomain.FieldByName('rdb$field_length').AsInteger := GetSaveFieldLength;
					qryDomain.FieldByName('rdb$field_scale').AsInteger := GetSaveFieldScale;
					Rec := 'update rdb$fields set rdb$null_flag = NULL, rdb$field_type = ' + IntToStr(GetSaveFieldType) +
						'rdb$field_length = ' + IntToStr(GetSaveFieldLength) +
						'rdb$field_scale = ' + IntToStr(GetSaveFieldScale) +
						'where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';';
					MarathonIDEInstance.RecordToScript(Rec, FDatabaseName);
				end;

				qryDomain.Post;
				qryDomain.Close;


				if FChangeDefault then
				begin
					qryDomain.SQL.Text := 'alter domain ' + FObjectName + ' drop default';
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);

					if edDefault.Text <> '' then
					begin
						qryDomain.SQL.Text := 'alter domain ' + FObjectName + ' set' + GetDefault;
						qryDomain.ExecSQL;
						MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
					end;
				end;

				if FChangeCheck then
				begin
					qryDomain.SQL.Text := 'alter domain ' + FObjectName + ' drop constraint';
					qryDomain.ExecSQL;
					MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);

					if edConstraint.Text <> '' then
					begin
						qryDomain.SQL.Text := 'alter domain ' + FObjectName + ' add' + GetCheck;
						qryDomain.ExecSQL;
						MarathonIDEInstance.RecordToScript(qryDomain.SQL.Text, FDatabaseName);
					end;
				end;

				qryDomain.IB_Transaction.Commit;
			except
				on E : Exception do
				begin
					qryDomain.IB_Transaction.Rollback;
					raise;
        end;
      end;
		finally
      qryDomain.Close;
    end;
  end;
end;


procedure TfrmDomains.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  IT.Free;
  inherited;
end;

procedure TfrmDomains.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	FObjectType := ctDomain;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

  It := TMenuItem.Create(Self);
  It.Caption := '&1 Domain - [' + FObjectName + ']';
  It.OnClick := WindowListClick;
  MarathonIDEInstance.AddMenuToMainForm(IT);

  TmpIntf := Self;
  framDoco.Init(TmpIntf);
  framDDL.Init(TmpIntf);
  SetupSyntaxEditor(edDefault);
  SetupSyntaxEditor(edConstraint);
  HelpContext := IDH_Domain_Editor;
  pgObjectEditor.ActivePage := tsMain;
end;

procedure TfrmDomains.edColDefaultChange(Sender: TObject);
begin
	FChangeDefault := True;
end;

procedure TfrmDomains.edColCheckChange(Sender: TObject);
begin
  FChangeCheck := True;
end;

procedure TfrmDomains.pgObjectEditorChange(Sender: TObject);
begin
  if pgObjectEditor.ActivePage = tsDDL then
	begin
		Self.Refresh;
		if not FNewObject then
			framDDL.GetDDL;
	end;
end;

procedure TfrmDomains.btnAddDimensionClick(Sender: TObject);
var
	frmArrayDialog: TfrmArrayDialog;

begin
	frmArrayDialog := TfrmArrayDialog.Create(Self);
	try
		if frmArrayDialog.ShowModal = mrOK then
		begin
			with lvArray.Items.Add do
			begin
				Caption := frmArrayDialog.edLBound.Text;
				SubItems.Add(frmArrayDialog.edUBound.Text);
			end;
			FChangeDataType := True;
		end;
	finally
		frmArrayDialog.Free;
	end;
end;

procedure TfrmDomains.btnDeleteDimensionClick(Sender: TObject);
begin
	if lvArray.Selected <> nil then
	begin
		if MessageDlg('Are you sure you wish to delete this dimension?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			lvArray.Selected.Delete;
			FChangeDataType := True;
		end;
	end;
end;

procedure TfrmDomains.btnEditDimensionClick(Sender: TObject);
var
	frmArrayDialog: TfrmArrayDialog;

begin
	if lvArray.Selected <> nil then
	begin
		frmArrayDialog := TfrmArrayDialog.Create(Self);
		try
			frmArrayDialog.udLBound.Position := StrToInt(lvArray.Selected.Caption);
			frmArrayDialog.udUBound.Position := StrToInt(lvArray.Selected.SubItems[0]);
			if frmArrayDialog.ShowModal = mrOK then
			begin
				with lvArray.Items.Add do
				begin
					lvArray.Selected.Caption := frmArrayDialog.edLBound.Text;
					lvArray.Selected.SubItems[0] := frmArrayDialog.edUBound.Text;
				end;
				FChangeDataType := True;
			end;
		finally
			frmArrayDialog.Free;
		end;
	end;
end;

procedure TfrmDomains.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

procedure TfrmDomains.LoadDomain(DomainName: String);
var
	Idx: Integer;
	Dimensions: Integer;

begin
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbBlobCharSet.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbCharCharSet.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbBlobCollate.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbCollate.Items);
	// Edit an existing domain
	FObjectName := DomainName;
	FNewObject := False;
	InternalCaption := 'Domain [' + FObjectName + ']';
	It.Caption := '&1 Domain - [' + FObjectName + ']';

	qryDomain.SQL.Add('select * from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
	qryDomain.Open;

	edColumn.Text := FObjectName;

	// Field type
	case qryDomain.FieldByName('rdb$field_type').AsInteger of
		blr_short:
			begin
				if IsInterbase6 then
				begin
					if qryDomain.FieldByName('rdb$field_sub_type').IsNull then
						cmbDataType.ItemIndex := TY_SMALLINT
					else
					begin
						case qryDomain.FieldByName('rdb$field_sub_type').AsInteger of
							0:
								cmbDataType.ItemIndex := TY_SMALLINT;

							1:
								begin
									cmbDataType.ItemIndex := TY_NUMERIC;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 4;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;

							2:
								begin
									cmbDataType.ItemIndex := TY_DECIMAL;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 4;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;
						end;
					end;
				end
				else
				begin
					if qryDomain.FieldByName('rdb$field_scale').AsInteger <> 0 then
					begin
						cmbDataType.ItemIndex := TY_DECIMAL;
						upPrec.Position := 4;
						upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
					end
					else
						cmbDataType.ItemIndex := TY_SMALLINT;
				end;
			end;

		blr_long:
			begin
				if IsInterbase6 then
				begin
					if qryDomain.FieldByName('rdb$field_sub_type').IsNull then
					begin
						cmbDataType.ItemIndex := TY_INTEGER;
					end
					else
					begin
						case qryDomain.FieldByName('rdb$field_sub_type').AsInteger of
							0:
								cmbDataType.ItemIndex := TY_INTEGER;

							1:
								begin
									cmbDataType.ItemIndex := TY_NUMERIC;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 9;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;

							2:
								begin
									cmbDataType.ItemIndex := TY_DECIMAL;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 9;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;
						end;
					end;
				end
				else
				begin
					if qryDomain.FieldByName('rdb$field_scale').AsInteger <> 0 then
					begin
						cmbDataType.ItemIndex := TY_DECIMAL;
						upPrec.Position := 9;
						upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
					end
					else
						cmbDataType.ItemIndex := TY_INTEGER;
				end;
			end;

		blr_int64:
			begin
				if IsInterbase6 then
				begin
					if qryDomain.FieldByName('rdb$field_sub_type').IsNull then
					begin
						cmbDataType.ItemIndex := TY_DECIMAL;
						upPrec.Position := 18;
						upScale.Position := 0;
					end
					else
					begin
						case qryDomain.FieldByName('rdb$field_sub_type').AsInteger of
							0:
								begin
									cmbDataType.ItemIndex := TY_DECIMAL;
									upPrec.Position := 18;
									upScale.Position := 0;
								end;

							1:
								begin
									cmbDataType.ItemIndex := TY_NUMERIC;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 18;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;

							2:
								begin
									cmbDataType.ItemIndex := TY_DECIMAL;
									if FSQLDialect = 3 then
										upPrec.Position := qryDomain.FieldByName('rdb$field_precision').AsInteger
									else
										upPrec.Position := 18;
									upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
								end;
						end;
					end;
				end;
			end;

		blr_float:
			cmbDataType.ItemIndex := TY_FLOAT;

		blr_text:
			begin
				cmbDataType.ItemIndex := TY_CHAR;
				udLen.Position := qryDomain.FieldByName('rdb$field_length').AsInteger;
				cmbCharCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryDomain.FieldByName('rdb$character_set_id').AsInteger));
				cmbCollate.ItemIndex := cmbCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryDomain.FieldByName('rdb$collation_id').AsInteger, qryDomain.FieldByName('rdb$character_set_id').AsInteger));
			end;

		blr_double:
			begin
				if qryDomain.FieldByName('rdb$field_scale').AsInteger <> 0 then
				begin
					cmbDataType.ItemIndex := TY_DECIMAL;
					upPrec.Position := 15;
					upScale.Position := Abs(qryDomain.FieldByName('rdb$field_scale').AsInteger);
				end
				else
					cmbDataType.ItemIndex := TY_DOUBLE_PRECISION;
			end;

		blr_timestamp:
			if IsInterbase6 then
				cmbDataType.ItemIndex := TY_TIMESTAMP
			else
				cmbDataType.ItemIndex := TY_DATE;

		blr_sql_time:
			cmbDataType.ItemIndex := TY_TIME;

		blr_sql_date:
			cmbDataType.ItemIndex := TY_DATE;

		blr_varying:
			begin
				cmbDataType.ItemIndex := TY_VARCHAR;
				udLen.Position := qryDomain.FieldByName('rdb$field_length').AsInteger;
				cmbCharCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryDomain.FieldByName('rdb$character_set_id').AsInteger));
				cmbCollate.ItemIndex := cmbCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryDomain.FieldByName('rdb$collation_id').AsInteger, qryDomain.FieldByName('rdb$character_set_id').AsInteger));
			end;

		blr_blob:
			begin
				cmbDataType.ItemIndex := TY_BLOB;
				edSubType.Text := qryDomain.FieldByName('rdb$field_sub_type').AsString;
				udSegLength.Position := qryDomain.FieldByName('rdb$segment_length').AsInteger;
				cmbBlobCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryDomain.FieldByName('rdb$character_set_id').AsInteger));
				cmbBlobCollate.ItemIndex := cmbBlobCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryDomain.FieldByName('rdb$collation_id').AsInteger, qryDomain.FieldByName('rdb$character_set_id').AsInteger));
			end;
	else
		cmbDataType.ItemIndex := TY_NONE;
	end;
	cmbDataTypeChange(cmbDataType);

	// Defaults
	edDefault.Text := qryDomain.FieldByName('rdb$default_source').AsString;

	// Check Constraint
	edConstraint.Text := qryDomain.FieldByName('rdb$validation_source').AsString;

	if qryDomain.FieldByName('rdb$null_flag').IsNull then
		chkColNotNull.Checked := False
	else
		chkColNotNull.Checked := True;

	if qryDomain.FieldByName('rdb$dimensions').AsInteger > 0 then
	begin
		Dimensions := qryDomain.FieldByName('rdb$dimensions').AsInteger;
		for Idx := 0 to Dimensions do
		begin
			qryDomain.Close;
			qryDomain.SQL.Clear;
			qryDomain.SQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
										'rdb$dimension = ' + IntToStr(Idx)  + 'and rdb$field_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
			qryDomain.Open;
			if not (qryDomain.EOF and qryDomain.BOF) then
				with lvArray.Items.Add do
				begin
					Caption := qryDomain.FieldByName('rdb$lower_bound').AsString;
					SubItems.Add(qryDomain.FieldByName('rdb$upper_bound').AsString);
				end;
		end;
	end;

	if not IsInterbase6 then
	begin
		btnAddDimension.Enabled := False;
		btnDeleteDimension.Enabled := False;
		btnEditDimension.Enabled := False;

		cmbCollate.Enabled := False;
		cmbCharCharSet.Enabled := False;
		cmbBlobCollate.Enabled := False;
		cmbBlobCharSet.Enabled := False;
	end;

	framDoco.LoadDoco;

	if not IsInterbase6 then
		edColumn.ReadOnly := True;
	qryDomain.Close;
	qryDomain.IB_Transaction.Commit;
	FChangeDefault := False;
	FChangeCheck := False;
	FChangeName := False;
	FChangeDataType := False;
end;

procedure TfrmDomains.NewDomain;
begin
	// We want to create a new domain
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbBlobCharSet.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbCharCharSet.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbBlobCollate.Items);
	MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbCollate.Items);

	FNewObject := True;
	InternalCaption := 'Domain [new_domain]';
	FObjectName := 'new_domain';
	edColumn.Text := 'new_domain';
	ActiveControl := edColumn;
end;

procedure TfrmDomains.SetDatabaseName(const Value: String);
begin
	inherited;
	qryDomain.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
	qryDomain.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;
	IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
	SQLDialect := qryDomain.IB_Connection.SQLDialect;
	stsEditor.Panels[3].Text := Value;
end;

function TfrmDomains.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

function TfrmDomains.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if FObjectModified then
		begin
			case MessageDlg('The domain ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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
			case MessageDlg('The documentation for domain ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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

procedure TfrmDomains.SetObjectModified(Value: Boolean);
begin
	inherited;
	FObjectModified := True;
end;

procedure TfrmDomains.SetObjectName(Value: String);
begin
	FObjectName := Value;
	InternalCaption := 'Domain - [' + FObjectName + ']';
	It.Caption := '&1 Domain - [' + FObjectName + ']';
end;

procedure TfrmDomains.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmDomains.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

function TfrmDomains.CanCaptureSnippet: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := Length(edDefault.SelText) > 1;

		PG_CONSTRAINT:
			Result := Length(edConstraint.SelText) > 1;

		PG_DESC:
			Result := framDoco.CanCaptureSnippet;

		PG_DDL:
			Result := framDDL.CanCaptureSnippet;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanCompile: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := True;

		PG_DEFAULT:
			Result := True;

		PG_CONSTRAINT:
			Result := True;

		PG_DESC:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanCopy: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := Length(edDefault.SelText) > 1;

		PG_CONSTRAINT:
			Result := Length(edConstraint.SelText) > 1;

		PG_DESC:
			Result := framDoco.CanCopy;

		PG_DDL:
			Result := framDDL.CanCopy;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanCut: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := Length(edDefault.SelText) > 1;

		PG_CONSTRAINT:
			Result := Length(edConstraint.SelText) > 1;

		PG_DESC:
			Result := framDoco.CanCut;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanFind: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.Lines.Count > 0;

		PG_CONSTRAINT:
			Result := edConstraint.Lines.Count > 0;

		PG_DESC:
			Result := framDoco.CanFind;

		PG_DDL:
			Result := framDDL.CanFind;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanFindNext: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.Lines.Count > 0;

		PG_CONSTRAINT:
			Result := edConstraint.Lines.Count > 0;

		PG_DESC:
			Result := framDoco.CanFindNext;

		PG_DDL:
			Result := framDDL.CanFindNext;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanObjectDrop: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := not FNewObject;

		PG_DEFAULT:
			Result := False;

		PG_CONSTRAINT:
			Result := False;

		PG_DESC:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanPaste: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := Clipboard.HasFormat(CF_TEXT);

		PG_CONSTRAINT:
			Result := Clipboard.HasFormat(CF_TEXT);

		PG_DESC:
			Result := framDoco.CanPaste;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanRedo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.CanRedo;

		PG_CONSTRAINT:
			Result := edConstraint.CanRedo;

		PG_DESC:
			Result := framDoco.CanRedo;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanReplace: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.Lines.Count > 0;

		PG_CONSTRAINT:
			Result := edConstraint.Lines.Count > 0;

		PG_DESC:
			Result := framDoco.CanReplace;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanSaveDoco: Boolean;
begin
	Result := framDoco.Modified;
end;

function TfrmDomains.CanSelectAll: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.Lines.Count > 0;

		PG_CONSTRAINT:
			Result := edConstraint.Lines.Count > 0;

		PG_DESC:
			Result := framDoco.CanSelectAll;

		PG_DDL:
			Result := framDDL.CanSelectAll;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanUndo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOMAIN:
			Result := False;

		PG_DEFAULT:
			Result := edDefault.CanUndo;

		PG_CONSTRAINT:
			Result := edConstraint.CanUndo;

		PG_DESC:
			Result := framDoco.CanUndo;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmDomains.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmDomains.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

procedure TfrmDomains.DoCaptureSnippet;
begin
	inherited;
end;

procedure TfrmDomains.DoCompile;
var
	Doco, FCompileText: String;
	TmpIntf : IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	Doco := framDoco.Doco;

	Refresh;
	// Do validation
	if FNewObject then
	begin
		if edColumn.Text = '' then
		begin
			MessageDlg('The new domain must have a name.', mtError, [mbOK], 0);
			edColumn.SetFocus;
			Exit;
		end;

		FCompileText := 'create domain ' + edColumn.Text + ' as ' + GetDataType + GetDefault + GetNotNull + GetCheck + GetCollate;
		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryDomain.IB_Connection, qryDomain.IB_Transaction, ctDomain, FCompileText);
		FErrors := FCompile.CompileErrors;
		FCompile.Free;

		if not IsInterbase6 then
			edColumn.ReadOnly := True;
	end
	else
	begin
		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateCompileCallBack(Self, TmpIntf);
		FErrors := FCompile.CompileErrors;
		FCompile.Free;
	end;

	if FErrors then
		Exit;

	// Update the tree cache
	if FNewObject then
		MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctDomain);

	FNewObject := False;
	FObjectModified := False;
	FChangeDefault := False;
	FChangeCheck := False;
	FChangeName := False;
	FChangeDataType := False;

	framDoco.Doco := Doco;
	framDoco.SaveDoco;
end;

procedure TfrmDomains.DoCopy;
begin
	inherited;
end;

procedure TfrmDomains.DoCut;
begin
	inherited;
end;

procedure TfrmDomains.DoFind;
begin
	inherited;
end;

procedure TfrmDomains.DoFindNext;
begin
	inherited;
end;

procedure TfrmDomains.DoObjectDrop;
var
	DoClose: Boolean;
	frmDropObject: TfrmDropObject;

begin
	if MessageDlg('Are you sure that you wish to drop the domain "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctDomain, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

procedure TfrmDomains.DoPaste;
begin
	inherited;
end;

procedure TfrmDomains.DoRedo;
begin
	inherited;
end;

procedure TfrmDomains.DoReplace;
begin
	inherited;
end;

procedure TfrmDomains.DoSaveDoco;
begin
	framDoco.SaveDoco;
end;

procedure TfrmDomains.DoSelectAll;
begin
	inherited;
end;

procedure TfrmDomains.DoUndo;
begin
	inherited;
end;

procedure TfrmDomains.DOViewNextPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(True);
end;

procedure TfrmDomains.DoViewPrevPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(False);
end;

procedure TfrmDomains.FormCloseQuery(Sender: TObject;	var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

procedure TfrmDomains.AddError(Info: String);
begin
	if not pnlMessages.Visible then
	begin
		pnlMessages.Visible := True;
		stsEditor.Top := Height;
	end;
	lstResults.Add(Info, 0, nil);
end;

procedure TfrmDomains.AddCompileError(ErrorText: String);
begin
	inherited;
	OpenMessages;
	AddError(ErrorText);
end;

procedure TfrmDomains.ClearErrors;
begin
	inherited;
	lstResults.Collection.Clear;
	pnlMessages.Visible := False;
end;

procedure TfrmDomains.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

procedure TfrmDomains.OpenMessages;
begin
	pnlMessages.Visible := True;
	stsEditor.Top := Height;
end;

function TfrmDomains.AreMessagesVisible: Boolean;
begin
	Result := pnlMessages.Visible;
end;

function TfrmDomains.CanViewMessages: Boolean;
begin
	Result := True;
end;

procedure TfrmDomains.DoViewMessages;
begin
	inherited;
	pnlMessages.Visible := not pnlMessages.Visible;
	if pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		stsEditor.Top := Height;
  end;
end;

procedure TfrmDomains.edColumnChange(Sender: TObject);
begin
  inherited;
  FChangeName := True;
  CheckNameLength(edColumn.Text);
end;

function TfrmDomains.CanInternalClose: Boolean;
begin
  Result := True;
end;

procedure TfrmDomains.DoInternalClose;
begin
	inherited;
	Close;
end;

procedure TfrmDomains.EnvironmentOptionsRefresh;
var
	TmpIntf: IMarathonForm;

begin
	inherited;
	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framDDL.Init(TmpIntf);
	SetupSyntaxEditor(edDefault);
	SetupSyntaxEditor(edConstraint);
end;

procedure TfrmDomains.ProjectOptionsRefresh;
begin
	inherited;
end;

function TfrmDomains.CanPrint: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		0, 1, 2:
			Result := not FNewObject;

		3:
			Result := (not FNewObject) and framDoco.CanPrint;

		4:
			Result := (not FNewObject) and framDDL.CanPrint;
	end;
end;

function TfrmDomains.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

procedure TfrmDomains.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		0, 1, 2:
			MarathonIDEInstance.PrintDomain(False, FObjectName, FDatabaseName);

		3:
			framDoco.DoPrint;

		4:
			framDDL.DoPrint;
	end;
end;

procedure TfrmDomains.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		0, 1, 2:
			MarathonIDEInstance.PrintDomain(True, FObjectName, FDatabaseName);

		3:
			framDoco.DoPrintPreview;

		4:
			framDDL.DoPrintPreview;
	end;
end;

procedure TfrmDomains.edLengthChange(Sender: TObject);
begin
	inherited;
	FChangeDataType := True;
end;

end.

{
$Log: EditorDomain.pas,v $
Revision 1.6  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.5  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.4  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.3  2002/04/29 14:52:40  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
