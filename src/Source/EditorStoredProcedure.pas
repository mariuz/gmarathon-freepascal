{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************}
// $Id: EditorStoredProcedure.pas,v 1.16 2007/06/15 21:31:32 rjmills Exp $

unit EditorStoredProcedure;

{$I compilerdefines.inc}

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls, DB, Menus, Grids, DBGrids, Buttons, Registry,
	Clipbrd, FileCtrl, Tabs, DBCtrls, ActnList, ImgList,
	{$IFDEF d6_or_higher}
	Variants,
	{$ENDIF}
	rmTabs3x,
	rmPanel,
	rmCollectionListBox,
	rmMemoryDataSet,
	IB_Components,
	IB_Header,
	IBODataset,
	SynEdit,
  SynEditTypes,
	SyntaxMemoWithStuff2,
	adbpedit,
	BaseDocumentDataAwareForm,
	FrameDescription,
	FrameDependencies,
	FrameDRUIMatrix,
	FramePermissions,
	FrameMetadata,
	MarathonProjectCacheTypes,
	MarathonInternalInterfaces,
	GimbalToolsAPI, rmNotebook2;

type
	TfrmStoredProcedure = class(TfrmBaseDocumentDataAwareForm, IMarathonStoredProcEditor, IGimbalIDESQLTextEditor)
		stsEditor: TStatusBar;
		dsResults: TDataSource;
		dlgOpen: TOpenDialog;
		pgObjectEditor: TPageControl;
		tsStoredProc: TTabSheet;
		tsDocoView: TTabSheet;
		tsExecute: TTabSheet;
    qryStoredProc: TIBOQuery;
    qryResults: TIBOQuery;
    qryUtil: TIBOQuery;
		edEditor: TSyntaxMemoWithStuff2;
		tsDependencies: TTabSheet;
    nbResults: TrmNoteBookControl;
		grdResults: TDBGrid;
		pnledResults: TDBPanelEdit;
		pnlDataView: TPanel;
		navDataView: TDBNavigator;
    nbpForm : TrmNotebookPage;
    nbpDataSheet : TrmNotebookPage;
		tabResults: TrmTabSet;
		tranResults: TIB_Transaction;
		tsDRUI: TTabSheet;
		tsGrants: TTabSheet;
		tsDebuggerOutput: TTabSheet;
		txtParameters: TrmMemoryDataSet;
		txtParametersparam_name: TStringField;
		txtParametersparam_type: TStringField;
		txtParametersparam_value: TStringField;
		txtParametersfield_type: TStringField;
		txtParametersfield_length: TStringField;
		txtParametersfield_scale: TStringField;
		txtParametersmatch: TStringField;
		txtParametersnull: TStringField;
		edErrors: TSyntaxMemoWithStuff2;
		qryWarnings: TIB_DSQL;
		framDepend: TframeDepend;
		frameDRUI: TframeDRUI;
		framePerms: TframePerms;
		tsDebugger: TTabSheet;
		edDebugInfo: TMemo;
		framDoco: TframeDesc;
    dlgSave: TSaveDialog;
    pnlMessages: TrmPanel;
    lstResults: TrmCollectionListBox;
		procedure lstResultsClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure WindowListClick(Sender: TObject);
		procedure edEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure edEditorDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
		procedure edEditorDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure pgObjectEditorChanging(Sender: TObject;	var AllowChange: Boolean);
		function FormHelp(Command: Word; Data: Integer;	var CallHelp: Boolean): Boolean;
		procedure txtParametersNewRecord(DataSet: TDataSet);
		procedure grdResultsDblClick(Sender: TObject);
		procedure edEditorChange(Sender: TObject);
		procedure tabResultsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure edEditorGetHintText(Sender: TObject; Token: String;	var HintText: String; HintType: THintType);
		procedure edEditorNavigateHyperLinkClick(Sender: TObject;	Token: String);
		procedure txtParametersnullValidate(Sender: TField);
		procedure txtParametersnullChange(Sender: TField);
		procedure txtParametersparam_valueChange(Sender: TField);
		procedure FormResize(Sender: TObject);
		procedure qryResultsAfterOpen(DataSet: TDataSet);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure pnlMessagesResize(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure edEditorStatusChange(Sender: TObject;	Changes: TSynStatusChanges);
	private
		{ Private declarations }
		// Context sensitive keyword help
		DoKeySearch: Boolean;

		FFileName: String;

		FErrors, FAppendFlag, FHasParameters, FNeedParameters, FDontChange: Boolean;
		FParameterList: TStringList;
		LinePos: LongInt;
		It: TMenuItem;
		procedure WMMove(var Message: TMessage); message WM_MOVE;
		procedure WMNCLButtonDown(var Message: TMessage); message WM_NCLBUTTONDOWN;
		procedure WMNCRButtonDown(var Message: TMessage); message WM_NCRBUTTONDOWN;
		function GetParameters(Force: Boolean; var Params: String): Boolean;
		function NeedParameters: Boolean;
		function HasParameters: Boolean;
		procedure LoadProcSource;
		procedure UpdateEncoding;
		function CheckInputParamsImpact: Boolean;
		procedure WarningsHandler(Sender: TObject; Line: Integer; Column: Integer; Statement: String);
		function GetDebugParameters(Force: Boolean): Boolean;
	public
		{ Public declarations }
		procedure AddInfo(Info: String);
		procedure AddError(Info: String);
		procedure GotoFindPosition(C: TPoint; Len: Integer);
		// Debugger stuff
		procedure DebugSetExecutionPoint(Line: Integer);
		procedure DebugSetExceptionLine(Line: Integer; Message: String);
		procedure DebugSetBreakPointLine(Active: Boolean; Line: Integer);
		procedure DebugRefreshDots;

		procedure LoadProcedure(ProcedureName: String);
		procedure NewProcedure;
		function InternalCloseQuery: Boolean; override;
		procedure OpenMessages; override;
		procedure AddCompileError(ErrorText: String); override;
		procedure ClearErrors; override;
		procedure ForceRefresh; override;
		procedure SetObjectName(Value: String); override;
		procedure SetObjectModified(Value: Boolean); override;

		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar: TStatusBar; override;

		function CanInternalClose: Boolean; override;
		procedure DoInternalClose; override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

		function CanExecute: Boolean; override;
		procedure DoExecute; override;

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

		function CanReplace: Boolean; override;
		procedure DoReplace; override;

		function CanFindNext: Boolean; override;
		procedure DoFindNext; override;

		function CanSelectAll: Boolean; override;
		procedure DoSelectAll;	override;

		function CanViewNextPage: Boolean; override;
		procedure DoViewNextPage; override;

		function CanViewPrevPage: Boolean; override;
		procedure DoViewPrevPage; override;

		function CanTransactionCommit: Boolean; override;
		procedure DoTransactionCommit; override;

		function CanTransactionRollback: Boolean; override;
		procedure DoTransactionRollback; override;

		function CanExport: Boolean; override;
		procedure DoExport; override;

		function CanLoadFrom: Boolean; override;
		procedure DoLoadFrom; override;

		function CanSaveAs: Boolean; override;
		procedure DoSaveAs; override;

		function CanClearBuffer: Boolean; override;
		procedure DoClearBuffer; override;

		function CanViewMessages: Boolean; override;
		function AreMessagesVisible: Boolean; override;
		procedure DoViewMessages; override;

		function CanCompile: Boolean; override;
		procedure DoCompile; override;

		function CanObjectParameters: Boolean; override;
		procedure DoObjectParameters; override;

		function CanSaveDoco: Boolean; override;
		procedure DoSaveDoco; override;

		function CanSaveAsTemplate: Boolean; override;
		procedure DoSaveAsTemplate; override;

		function CanObjectDrop: Boolean; override;
		procedure DoObjectDrop; override;

		function CanGrant: Boolean;	override;
		procedure DoGrant;	override;

		function CanRevoke: Boolean;  override;
		procedure DoRevoke;  override;

		function CanQueryBuilder: Boolean; override;
		procedure DoQueryBuilder; override;

		function CanChangeEncoding: Boolean; override;
		procedure DoChangeEncoding(Index: Integer); override;
		function IsEncoding(Index: Integer): Boolean; override;

		function CanToggleBookmark(Index: Integer): Boolean; override;
		procedure DoToggleBookmark(Index: Integer); override;
		function IsBookmarkSet(Index: Integer): Boolean; override;

		function CanGotoBookmark(Index: Integer): Boolean; override;
		procedure DoGotoBookmark(Index: Integer); override;

		function CanObjectAddToProject: Boolean; override;
		procedure DoObjectAddToProject; override;

		function CanStepInto: Boolean; override;
		procedure DoStepInto; override;

		function CanAddBreakPoint: Boolean; override;
		procedure DoAddBreakPoint; override;

		function CanAddWatchAtCursor: Boolean; override;
		procedure DoAddWatchAtCursor; override;

		function CanToggleBreakPoint: Boolean; override;
		procedure DoToggleBreakPoint; override;

		function CanEvalModify: Boolean; override;
		procedure DoEvalModify; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;

		// ToolsAPI
		procedure IDESetLines(Value: IGimbalIDELines); safecall;
		function IDEGetLines: IGimbalIDELines; safecall;
	end;

implementation

uses
	Globals,
	HelpMap,
	SQLYacc,
	CompileDBObject,
	DropObject,
	StoredProcedureParams,
	SaveFileFormat,
	MarathonIDE,
	MarathonOptions,
	BlobViewer,
	InputDialog,
	QBuilder,
	EditorGrant,
	StoredProcParamWarn,
	IBDebuggerVM;

{$R *.DFM}

const
	PG_EDIT = 0;
	PG_DOCO = 1;
	PG_RESULTS = 2;
	PG_DEPEND = 3;
	PG_DRUI = 4;
	PG_GRANTS = 5;

procedure TfrmStoredProcedure.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmStoredProcedure.LoadProcSource;
var
	tmp, tmp1, CharSet: String;
	P: TStringList;

begin
	InternalCaption := 'Stored Procedure - [' + FObjectName + ']';
	IT.Caption := Caption;

	qryStoredProc.Close;
	qryStoredProc.SQL.Clear;
	if ShouldBeQuoted(FObjectName) then
		tmp := 'create procedure ' + MakeQuotedIdent(FObjectName, FIsInterbase6, FSQLDialect) + ' '
	else
		tmp := 'create procedure ' + FObjectName + ' ';
	if FIsinterbase6 {and (FSQLDialect = 3)} then
		qryStoredProc.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$FIELD_SUB_TYPE, B.RDB$FIELD_PRECISION, B.RDB$CHARACTER_SET_ID from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
			'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;')
	else
		qryStoredProc.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$CHARACTER_SET_ID from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
			'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;');
	qryStoredProc.Open;
	if not (qryStoredProc.EOF and qryStoredProc.BOF) Then
	begin
		tmp := tmp + '(' + #13#10;
		if FIsInterbase6 {and (FSQLDialect = 3)} then
			tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
				+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_PRECISION').AsInteger, True, FSQLDialect)
		else
			tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
				+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger, -1, -1, False, FSQLDialect);

		CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryStoredProc.FieldByName('RDB$CHARACTER_SET_ID').AsInteger);
		if CharSet <> '' then
			Tmp := Tmp + ' character set ' + CharSet;
		qryStoredProc.Next;

		while not qryStoredProc.EOF do
		begin
			tmp := tmp + ',' + #13#10;
			if FIsInterbase6 {and (FSQLDialect = 3)} then
				tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
					+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_PRECISION').AsInteger, True, FSQLDialect)
			else
				tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
					+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
					qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger, -1, -1, False, FSQLDialect);
			CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryStoredProc.FieldByName('rdb$character_set_id').AsInteger);
			if CharSet <> '' then
				Tmp := Tmp + ' character set ' + CharSet;
			qryStoredProc.Next;
		end;
		tmp := tmp + ')';
	end;
	qryStoredProc.Close;
	if qryStoredProc.IB_Transaction.Started then
		qryStoredProc.IB_Transaction.Commit;
	qryStoredProc.SQL.Clear;
	if FIsInterbase6 {and (FSQLDialect = 3)} then
		qryStoredProc.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$FIELD_SUB_TYPE, B.RDB$FIELD_PRECISION, B.RDB$CHARACTER_SET_ID from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
			'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 1 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;')
	else
		qryStoredProc.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$CHARACTER_SET_ID from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
			'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 1 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;');
	qryStoredProc.Open;
	if not (qryStoredProc.EOF and qryStoredProc.BOF) Then
	begin
		tmp := tmp + #13#10;
		tmp := tmp + 'returns (' + #13#10;
		if FIsInterbase6 {and (FSQLDialect = 3)} then
		begin
			tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
			+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_PRECISION').AsInteger,	True, FSQLDialect);
		end
		else
		begin
			tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
			+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
			qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger,
			-1, -1, False, FSQLDialect);
		end;
		CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryStoredProc.FieldByName('rdb$character_set_id').AsInteger);
		if CharSet <> '' then
			Tmp := Tmp + ' character set ' + CharSet;

		qryStoredProc.Next;
		while not qryStoredProc.EOF do
		begin
			tmp := tmp + ',' + #13#10;
			if FIsInterbase6 {and (FSQLDialect = 3)} then
				tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
				+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_PRECISION').AsInteger, True, FSQLDialect)
			else
				tmp := tmp + '		' + qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString + ' '
				+ ConvertFieldType(qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger,
				qryStoredProc.FieldByName('RDB$FIELD_SCALE').AsInteger, -1, -1, False, FSQLDialect);
			CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryStoredProc.FieldByName('rdb$character_set_id').AsInteger);
			if CharSet <> '' then
				Tmp := Tmp + ' character set ' + CharSet;
			qryStoredProc.Next;
		end;
		tmp := tmp + ')';
	end;

	qryStoredProc.Close;
	if qryStoredProc.IB_Transaction.Started then
		qryStoredProc.IB_Transaction.Commit;

	P := TStringList.Create;
	try
		qryStoredProc.SQL.Clear;
		qryStoredProc.SQL.Add('select RDB$PROCEDURE_SOURCE from RDB$PROCEDURES where RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ';');
		qryStoredProc.Open;
		if not (qryStoredProc.EOF and qryStoredProc.BOF) Then
		begin
			tmp := tmp + #13#10;
			tmp := tmp + 'as' + #13#10;
			Tmp1 := Trim(ConvertTabs(AdjustLineBreaks(qryStoredProc.FieldByName('RDB$PROCEDURE_SOURCE').AsString), edEditor));
			P.Text := Tmp1;
		end;
		qryStoredProc.Close;
		if qryStoredProc.IB_Transaction.Started then
			qryStoredProc.IB_Transaction.Commit;
		qryStoredProc.SQL.Clear;
		Tmp := tmp + P.Text;

		edEditor.Text := Tmp;
		FObjectModified := False;
		edEditor.Modified := False;
		FNewObject := False;
	finally
		P.Free;
	end;
end;

procedure TfrmStoredProcedure.lstResultsClick(Sender: TObject);
var
	Line: String;
	CharPos: Integer;
	FoundLine, FoundChar: Boolean;
	Parser: TTextParser;
	Tok: TToken;

begin
	if lstResults.ItemIndex <> -1 then
	begin
		CharPos := 0;

		edEditor.ErrorLine := -1;

		Line := lstResults.Collection[lstResults.ItemIndex].TextData.Text;

		FoundLine := False;
		FoundChar := False;

		Parser := TTextParser.Create;
		Parser.Input := Line;
		Tok := Parser.NextToken;
		while Tok.TokenType <> tkNone do
		begin
			if AnsiUpperCase(Tok.TokenText)  = 'LINE' then
			begin
				Tok := Parser.NextToken;
				while (Tok.TokenType <> tkNumber) do
				begin
					Tok := Parser.NextToken;
					if Tok.TokenType = tkNone then
						Break;
				end;
				if Tok.TokenType = tkNumber then
				begin
					try
						LinePos := StrToInt(Tok.TokenText);
						FoundLine := True;
					except

					end;
				end;
			end;
			if AnsiUpperCase(Tok.TokenText)  = 'CHAR' then
			begin
				Tok := Parser.NextToken;
				while (Tok.TokenType <> tkNumber) do
				begin
					Tok := Parser.NextToken;
					if Tok.TokenType = tkNone then
						Break;
				end;
				if Tok.TokenType = tkNumber then
					try
						CharPos := StrToInt(Tok.TokenText);
						FoundChar := True;
					except

					end;
			end;
			Tok := Parser.NextToken;
		end;
		if FoundChar then
			CharPos := Abs(CharPos)
		else
			CharPos := 1;
		if FoundLine then
			LinePos := Abs(LinePos)
		else
			LinePos := 1;

		if not ((LinePos = 0) and (CharPos = 0)) then
		begin
			edEditor.CaretXY := buffercoord(CharPos, LinePos);
			edEditor.ErrorLine := LinePos;
			if pgObjectEditor.ActivePage.PageIndex = 0 then
				edEditor.SetFocus;
		end;
	end;
end;

procedure TfrmStoredProcedure.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;
	framDepend.SaveColWidths;
	Action := caFree;
end;

procedure TfrmStoredProcedure.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	FObjectType := ctSP;

	FParameterList := TStringList.Create;

	pgObjectEditor.ActivePage := tsStoredProc;
	pnlMessages.Visible := False;

	HelpContext := IDH_Stored_Procedure_Editor;

	edEditor.Clear;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

	SetupSyntaxEditor(edEditor);
	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framDepend.Init(TmpIntf);
	framePerms.Init(TmpIntf);
	frameDRUI.Init(TmpIntf);

	FCharSet := SetupEncodingControl(edEditor);
	FCharSet := SetupEncodingControl(grdResults);
	FCharSet := SetupEncodingControl(pnledResults);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 Stored Procedure [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);
end;

function TfrmStoredProcedure.GetParameters(Force: Boolean; var Params: String): Boolean;
var
	Idx: Integer;
	Found: Boolean;
	OldDecimalSeparator: Char;
	frmStoredProcParameters: TfrmStoredProcParameters;

begin
	try
		qryUtil.BeginBusy(False);
		Result := False;
		txtParameters.Close;
		txtParameters.Open;
		qryUtil.Close;
		qryUtil.SQL.Clear;
		if FIsInterbase6 then
			qryUtil.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$FIELD_SUB_TYPE, B.RDB$FIELD_PRECISION from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
				'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;')
		else
			qryUtil.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE FROM RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
				'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ' order by RDB$PARAMETER_NUMBER asc;');
		qryUtil.Open;
		FAppendFlag := True;
		while not qryUtil.EOF do
		begin
			txtParameters.Append;
			txtParameters.FieldByName('PARAM_NAME').AsString := qryUtil.FieldByName('RDB$PARAMETER_NAME').AsString;

			if FIsInterbase6 then
				txtParameters.FieldByName('PARAM_TYPE').AsString := ConvertFieldType(qryUtil.FieldByName('RDB$FIELD_TYPE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_LENGTH').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_SCALE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_PRECISION').AsInteger, True, FSQLDialect)
			else
				txtParameters.FieldByName('PARAM_TYPE').AsString := ConvertFieldType(qryUtil.FieldByName('RDB$FIELD_TYPE').AsInteger,
				qryUtil.FieldByName('RDB$FIELD_LENGTH').AsInteger,
				qryUtil.FieldByName('RDB$FIELD_SCALE').AsInteger, -1, -1, False, FSQLDialect);

			txtParameters.FieldByName('PARAM_VALUE').AsString := '';
			txtParameters.FieldByName('FIELD_TYPE').AsString := qryUtil.FieldByName('RDB$FIELD_TYPE').AsString;
			txtParameters.FieldByName('FIELD_LENGTH').AsString := qryUtil.FieldByName('RDB$FIELD_LENGTH').AsString;
			txtParameters.FieldByName('FIELD_SCALE').AsString := qryUtil.FieldByName('RDB$FIELD_SCALE').AsString;
			txtParameters.FieldByName('MATCH').AsString := 'F';

			txtParameters.Post;
			qryUtil.Next;
		end;
		qryUtil.Close;
		if qryUtil.IB_Transaction.Started then
			 qryUtil.IB_Transaction.Commit;
		FAppendFlag := False;

		// Ok we now have our input paramters check to see if we have any matching
		// and fill the values in
		txtParameters.First;
		while not txtParameters.EOF do
		begin
			for Idx := 0 to FParameterList.Count - 1 do
				if AnsiUpperCase(ParseSection(FParameterList[Idx], 1, #9)) = AnsiUpperCase(txtParameters.FieldByName('PARAM_NAME').AsString) then
				begin
					txtParameters.Edit;
					if ParseSection(FParameterList[Idx], 2, #9) = 'NULL' then
						txtParameters.FieldByName('NULL').AsString := 'NULL'
					else
						txtParameters.FieldByName('PARAM_VALUE').AsString := ParseSection(FParameterList[Idx], 2, #9);
					txtParameters.FieldByName('MATCH').AsString := 'T';
					txtParameters.Post;
				end;
			txtParameters.Next;
		end;

		// Do we have any non matching
		Found := False;
		txtParameters.First;
		while not txtParameters.EOF do
		begin
			if txtParameters.FieldByName('MATCH').AsString = 'F' then
			begin
				Found := True;
				Break;
			end;
			txtParameters.Next;
		end;

		if Found or Force or gAlwaysSPParams then
		begin
			frmStoredProcParameters := TfrmStoredProcParameters.Create(Self);
			try
				with frmStoredProcParameters do
				begin
					frmStoredProcParameters.dsParameters.DataSet := txtParameters;
					if not (ShowModal = mrOK) then
					begin
						Result := False;
						Exit;
					end;
				end;
			finally
				frmStoredProcParameters.Free;
			end;
		end;

		// Now do some validation
		with txtParameters do
		begin
			First;
			while not EOF do
			begin
				if FieldByName('NULL').AsString <> 'NULL' then
				begin
					case FieldByName('FIELD_TYPE').AsInteger	of
						blr_short:
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(4, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
									try
										StrToInt(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid integer value.', mtError, [mbOK], 0);
										Exit;
									end;
							end;

						blr_long: // Integer
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(9, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
									try
										StrToInt(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid integer point value.', mtError, [mbOK], 0);
										Exit;
									end
							end;

						blr_float: // Float
							begin
								OldDecimalSeparator := DecimalSeparator;
								try
									DecimalSeparator := '.';
									try
										StrToFloat(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid floating point value.', mtError, [mbOK], 0);
										Exit;
									end
								finally
									DecimalSeparator := OldDecimalSeparator;
								end;
							end;

						blr_text: // Char
							begin
								if Length(FieldByName('PARAM_VALUE').AsString) > FieldByName('FIELD_LENGTH').AsInteger then
								begin
									MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is to long to fit in a parameter of type char(' +
									FieldByName('PARAM_LENGTH').AsString + ').', mtError, [mbOK], 0);
									Exit;
								end;
							end;

						blr_double: // Double
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(15, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid double value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end;
							end;

						blr_timestamp: // Date
							begin
							end;

						blr_varying: // Varchar
							if Length(FieldByName('PARAM_VALUE').AsString) > FieldByName('FIELD_LENGTH').AsInteger then
							begin
								MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is to long to fit in a parameter of type varchar(' +
								FieldByName('FIELD_LENGTH').AsString + ').', mtError, [mbOK], 0);
								Exit;
							end;
					else
						raise Exception.Create('unknown data type');
					end;
				end;
				Next;
			end;
		end;

		// Now build the parameters
		Params := '';
		with txtParameters do
		begin
			First;
			FParameterList.Clear;
			while not EOF do
			begin
				if FieldByName('NULL').AsString = 'NULL' then
				begin
					FParameterList.Add(FieldByName('PARAM_NAME').AsString + #9 + FieldByName('NULL').AsString);
					Params := Params + 'NULL' + ', ';
				end
				else
				begin
					FParameterList.Add(FieldByName('PARAM_NAME').AsString + #9 + FieldByName('PARAM_VALUE').AsString);
					case FieldByName('FIELD_TYPE').AsInteger	of
						blr_short:
							Params := Params + FieldByName('PARAM_VALUE').AsString + ', ';

						blr_long: // Integer
							Params := Params + FieldByName('PARAM_VALUE').AsString + ', ';

						blr_float: // Float
							begin
								OldDecimalSeparator := DecimalSeparator;
								try
									DecimalSeparator := '.';
									Params := Params + FieldByName('PARAM_VALUE').AsString + ', ';
								finally
									DecimalSeparator := OldDecimalSeparator;
								end;
							end;

						blr_text: // Char
							Params := Params + '''' + FieldByName('PARAM_VALUE').AsString + ''', ';

						blr_double: // Double
							begin
								OldDecimalSeparator := DecimalSeparator;
								try
									DecimalSeparator := '.';
									Params := Params + FieldByName('PARAM_VALUE').AsString + ', ';
								finally
									DecimalSeparator := OldDecimalSeparator;
								end;
							end;

						blr_timestamp: // Date
							Params := Params + '''' + FieldByName('PARAM_VALUE').AsString + ''', ';

						blr_varying: // Varchar
							Params := Params + '''' + FieldByName('PARAM_VALUE').AsString + ''', ';
					else
						raise Exception.Create('unknown data type');
					end;
				end;
				Next;
			end;
		end;
		Params := Trim(Params);
		if Params[Length(Params)] = ',' then
			Params := Copy(Params, 1, Length(Params) - 1);
		Result := True;
	finally
		qryUtil.EndBusy;
	end;
end;

function TfrmStoredProcedure.GetDebugParameters(Force: Boolean): Boolean;
var
	Idx: Integer;
	Found: Boolean;
	OldDecimalSeparator: Char;
	frmStoredProcParameters: TfrmStoredProcParameters;

begin
	try
		qryUtil.BeginBusy(False);
		Result := False;
		txtParameters.Close;
		txtParameters.Open;
		qryUtil.Close;
		qryUtil.SQL.Clear;
		if FIsInterbase6 then
			qryUtil.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$FIELD_SUB_TYPE, B.RDB$FIELD_PRECISION from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
				'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ''' + FObjectName + ''' order by RDB$PARAMETER_NUMBER asc;')
		else
			qryUtil.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE FROM RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
				'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ''' + FObjectName + ''' order by RDB$PARAMETER_NUMBER asc;');
		qryUtil.Open;
		FAppendFlag := True;
		while not qryUtil.EOF do
		begin
			txtParameters.Append;
			txtParameters.FieldByName('PARAM_NAME').AsString := qryUtil.FieldByName('RDB$PARAMETER_NAME').AsString;
			if FIsInterbase6 then
				txtParameters.FieldByName('PARAM_TYPE').AsString := ConvertFieldType(qryUtil.FieldByName('RDB$FIELD_TYPE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_LENGTH').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_SCALE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_PRECISION').AsInteger, True, FSQLDialect)
			else
				txtParameters.FieldByName('PARAM_TYPE').AsString := ConvertFieldType(qryUtil.FieldByName('RDB$FIELD_TYPE').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_LENGTH').AsInteger,
					qryUtil.FieldByName('RDB$FIELD_SCALE').AsInteger, -1, -1, False, FSQLDialect);

			txtParameters.FieldByName('PARAM_VALUE').AsString := '';
			txtParameters.FieldByName('FIELD_TYPE').AsString := qryUtil.FieldByName('RDB$FIELD_TYPE').AsString;
			txtParameters.FieldByName('FIELD_LENGTH').AsString := qryUtil.FieldByName('RDB$FIELD_LENGTH').AsString;
			txtParameters.FieldByName('FIELD_SCALE').AsString := qryUtil.FieldByName('RDB$FIELD_SCALE').AsString;
			txtParameters.FieldByName('MATCH').AsString := 'F';

			txtParameters.Post;
			qryUtil.Next;
		end;
		qryUtil.Close;
		if qryUtil.IB_Transaction.Started then
			 qryUtil.IB_Transaction.Commit;
		FAppendFlag := False;

		// Ok we now have our input paramters check to see if we have any matching
		// and fill the values in
		txtParameters.First;
		while not txtParameters.EOF do
		begin
			for Idx := 0 to FParameterList.Count - 1 do
				if AnsiUpperCase(ParseSection(FParameterList[Idx], 1, #9)) = AnsiUpperCase(txtParameters.FieldByName('PARAM_NAME').AsString) then
				begin
					txtParameters.Edit;
					txtParameters.FieldByName('PARAM_VALUE').AsString := ParseSection(FParameterList[Idx], 2, #9);
					txtParameters.FieldByName('MATCH').AsString := 'T';
					txtParameters.Post;
				end;
			txtParameters.Next;
		end;

		// Do we have any non matching
		Found := False;
		txtParameters.First;
		while not txtParameters.EOF do
		begin
			if txtParameters.FieldByName('MATCH').AsString = 'F' then
			begin
				Found := True;
				Break;
			end;
			txtParameters.Next;
		end;

		if Found or Force then
		begin
			frmStoredProcParameters := TfrmStoredProcParameters.Create(Self);
			try
				with frmStoredProcParameters do
				begin
					frmStoredProcParameters.dsParameters.DataSet := txtParameters;
					if not (ShowModal = mrOK) then
					begin
						Result := False;
						Exit;
					end;
				end;
			finally
				frmStoredProcParameters.Free;
			end;
		end;

		// Now do some validation
		with txtParameters do
		begin
			First;
			while not EOF do
			begin
				if FieldByName('NULL').AsString <> 'NULL' then
				begin
					case FieldByName('FIELD_TYPE').AsInteger	of
						blr_short:
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(4, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
									try
										StrToInt(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid integer value.', mtError, [mbOK], 0);
										Exit;
									end;
							end;

						blr_long: // Integer
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(9, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
									try
										StrToInt(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid integer point value.', mtError, [mbOK], 0);
										Exit;
									end
							end;

						blr_float: // Float
							begin
								OldDecimalSeparator := DecimalSeparator;
								try
									DecimalSeparator := '.';
									try
										StrToFloat(FieldByName('PARAM_VALUE').AsString);
									except
										MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid floating point value.', mtError, [mbOK], 0);
										Exit;
									end
								finally
									DecimalSeparator := OldDecimalSeparator;
								end;
							end;

						blr_text: // Char
							if Length(FieldByName('PARAM_VALUE').AsString) > FieldByName('FIELD_LENGTH').AsInteger then
							begin
								MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is to long to fit in a parameter of type char(' +
								FieldByName('param_length').AsString + ').', mtError, [mbOK], 0);
								Exit;
							end;

						blr_double: // Double
							begin
								if FieldByName('FIELD_SCALE').AsInteger <> 0 then
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid numeric(15, ' +
											FieldByName('FIELD_SCALE').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end
								else
								begin
									OldDecimalSeparator := DecimalSeparator;
									try
										DecimalSeparator := '.';
										try
											StrToFloat(FieldByName('PARAM_VALUE').AsString);
										except
											MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is not a valid double value.', mtError, [mbOK], 0);
											Exit;
										end
									finally
										DecimalSeparator := OldDecimalSeparator;
									end;
								end;
							end;

						blr_timestamp: // Date
							begin
							end;

						blr_varying: // Varchar
							if Length(FieldByName('PARAM_VALUE').AsString) > FieldByName('FIELD_LENGTH').AsInteger then
							begin
								MessageDlg(FieldByName('PARAM_VALUE').AsString	+ ' is to long to fit in a parameter of type varchar(' +
								FieldByName('FIELD_LENGTH').AsString + ').', mtError, [mbOK], 0);
								Exit;
							end;
					else
						raise Exception.Create('unknown data type');
					end;
				end;
				Next;
			end;
		end;

		// Now build the parameters
		with txtParameters do
		begin
			First;
			FParameterList.Clear;
			while not EOF do
			begin
				if FieldByName('NULL').AsString = 'NULL' then
				begin
					FParameterList.Add(FieldByName('PARAM_NAME').AsString + #9 + FieldByName('NULL').AsString);
					MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, NULL);
				end
				else
				begin
					FParameterList.Add(FieldByName('PARAM_NAME').AsString + #9 + FieldByName('PARAM_VALUE').AsString);
					case FieldByName('FIELD_TYPE').AsInteger	of
						blr_short:
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsInteger);

						blr_long: // Integer
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsInteger);

						blr_float: // Float
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsFloat);

						blr_text: // Char
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsString);

						blr_double: // Double
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsFloat);

						blr_timestamp: // Date
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsDateTime);

						blr_varying: // Varchar
							MarathonIDEInstance.DebuggerVM.Modules[0].GetSymbolTable.UpdateSym(FieldByName('PARAM_NAME').AsString, FieldByName('PARAM_VALUE').AsString);
					else
						raise Exception.Create('unknown data type');
					end;
				end;
				Next;
			end;
		end;
		Result := True;
	finally
		qryUtil.EndBusy;
	end;
end;

function TfrmStoredProcedure.NeedParameters: Boolean;
begin
	try
		qryUtil.BeginBusy(False);

		qryUtil.Close;
		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select count(*) from RDB$PROCEDURE_PARAMETERS where RDB$PARAMETER_TYPE = 0 ' +
			'and RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, ''''));
		qryUtil.Open;
		if qryUtil.FieldByName('COUNT').AsInteger > 0 then
			Result := True
		else
			Result := False;
		qryUtil.Close;
		if qryUtil.IB_Transaction.Started then
			qryUtil.IB_Transaction.Commit;
	finally
		qryUtil.EndBusy;
	end;
end;

function TfrmStoredProcedure.HasParameters: Boolean;
begin
	try
		if qryUtil.IB_Transaction.Started then
			qryUtil.IB_Transaction.Commit;
		qryUtil.BeginBusy(False);
		qryUtil.Close;
		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select count(*) from RDB$PROCEDURE_PARAMETERS where RDB$PARAMETER_TYPE = 1 ' +
			'and RDB$PROCEDURE_NAME = ' + AnsiQuotedStr(FObjectName, ''''));
		qryUtil.Open;
		if qryUtil.FieldByName('COUNT').AsInteger > 0 then
			Result := True
		else
			Result := False;
		qryUtil.Close;
		if qryUtil.IB_Transaction.Started then
			qryUtil.IB_Transaction.Commit;
	finally
		qryUtil.EndBusy;
	end;
end;

procedure TfrmStoredProcedure.edEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	edEditor.ErrorLine := -1;

	if Key = VK_F1 then
		if edEditor.Highlighter.IsKeyword(edEditor.SelText) then
		begin
			DoKeySearch := True;
			Key := 0;
		end
		else
			DoKeySearch := False;

	// Handle notifier chain
	MarathonIDEInstance.ProcessKeyPressNotifierChain(Key, Shift);
end;

procedure TfrmStoredProcedure.pgObjectEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			begin
				if qryResults.Active then
					qryResults.Close;
				edEditorChange(Self);
				edEditor.SetFocus;
			end;

		PG_DOCO:
			begin
				if qryResults.Active then
					qryResults.Close;
				edEditorChange(Self);
				framDoco.SetActive;
			end;

		PG_DEPEND:
			begin
				if qryResults.Active then
					qryResults.Close;

				framDepend.LoadDependencies;
				framDepend.SetActive;

				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_RESULTS:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
				case gDefaultView of
					0:
						begin
							nbResults.ActivePage := nbpDataSheet;
							tabResults.TabIndex := gDefaultView;
						end;

					1:
						begin
							nbResults.ActivePage := nbpForm;
							tabResults.TabIndex := gDefaultView;
						end;
				end;
			end;

		PG_DRUI:
			begin
				frameDRUI.CalcMatrix(edEditor.Text);
				frameDRUI.SetActive;
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_GRANTS:
			begin
				framePerms.OpenGrants;
				framePerms.SetActive;
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;
	end;
end;

procedure TfrmStoredProcedure.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if FDropClose or FByPassClose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

procedure TfrmStoredProcedure.edEditorDragOver(Sender, Source: TObject;	X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
	SetFocus;
	if edEditor.InsertMode then
		stsEditor.Panels[2].Text := 'Insert'
	else
		stsEditor.Panels[2].Text := 'Overwrite';
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	Accept := True;
end;

procedure TfrmStoredProcedure.edEditorDragDrop(Sender, Source: TObject; X, Y: Integer);
var
	Tmp: String;

begin
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	if Source is TDragQueen then
		Tmp := TDragQueen(Source).DragText;

	edEditor.SelText := Tmp;
end;

procedure TfrmStoredProcedure.pgObjectEditorChanging(Sender: TObject;	var AllowChange: Boolean);
begin
	if FNewObject then
	begin
		MessageDlg('You cannot change from Edit View until the object has been compiled.', mtWarning, [mbOK], 0);
		AllowChange := False;
	end
	else
		case pgObjectEditor.ActivePage.PageIndex of
			PG_DOCO:
				if framDoco.Modified then
					if MessageDlg('Save changes to documentation?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
						framDoco.SaveDoco;

			PG_RESULTS:
				if tranResults.Started then
				begin
					MessageDlg('There is an open transaction for the results - Commit or Rollback before changing View.', mtWarning, [mbOK], 0);
					AllowChange := False;
				end;
		end;
end;

procedure TfrmStoredProcedure.GotoFindPosition(C: TPoint; Len: Integer);
begin
//	edEditor.SetSelection(C.Y + FLineOffset + 1, C.X, C.Y + FLineOffset + 1, C.X + Len, False);
end;

function TfrmStoredProcedure.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
	Result := True;
	if DoKeySearch then
	begin
		if edEditor.Highlighter.IsKeyword(edEditor.SelText) then
		begin
			WinHelp(Handle, PChar(ExtractFilePath(Application.ExeName) + 'Help\SQLRef.hlp'), HELP_PARTIALKEY, Integer(PChar(edEditor.SelText)));
			CallHelp := False;
		end
		else
			CallHelp := True;
	end
	else
		CallHelp := True;
end;

procedure TfrmStoredProcedure.txtParametersNewRecord(DataSet: TDataSet);
begin
	if not FAppendFlag then
		Abort;
end;

procedure TfrmStoredProcedure.grdResultsDblClick(Sender: TObject);
begin
	EditBlobColumn(grdResults.SelectedField);
end;

procedure TfrmStoredProcedure.edEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			FObjectModified := UpdateEditorStatusBar(stsEditor, edEditor);

		PG_RESULTS:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_DEPEND:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_DRUI:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;
	end;
end;

procedure TfrmStoredProcedure.tabResultsChange(Sender: TObject;	NewTab: Integer; var AllowChange: Boolean);
begin
	nbResults.ActivePageIndex := NewTab;
end;

procedure TfrmStoredProcedure.AddInfo(Info: String);
begin
	if not pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		pnlMessages.Visible := True;
		stsEditor.Top := Height;
	end;
	lstResults.Add('INFO: ' + Info, 1, nil);
end;

procedure TfrmStoredProcedure.AddError(Info: String);
begin
	if not pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		pnlMessages.Visible := True;
		stsEditor.Top := Height;
	end;
	lstResults.Add(Info, 0, nil);
end;


procedure TfrmStoredProcedure.edEditorGetHintText(Sender: TObject; Token: String; var HintText: String; HintType: THintType);
var
	Tmp: String;
	V: Variant;
	Sym: TSymbolTable;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled and MarathonIDEInstance.DebuggerVM.Executing then
	begin
		Sym := MarathonIDEInstance.DebuggerVM.GetTopSymbolTable;
		if Sym.IsSymbol(Token) then
		begin
			V := Sym.GetSymValue(Token);
			if VarIsNull(V) then
				HintText := Token + ': NULL'
			else
			begin
				case VarType(V) of
					varSmallint,
					varInteger:
						Tmp := IntToStr(V);

					varSingle,
					varDouble,
					varCurrency:
						Tmp := FloatToStr(V);

					varDate:
						Tmp := DateTimeToStr(V);

					varString:
						Tmp := V;
				end;

				HintText := Token + ': ' + Tmp;
			end;
		end;
	end
	else
		HintText := MarathonIDEInstance.GetHintTextForToken(Token, ConnectionName);
end;

procedure TfrmStoredProcedure.edEditorNavigateHyperLinkClick(Sender: TObject; Token: String);
begin
	MarathonIDEInstance.NavigateToLink(Token, ConnectionName);
end;

procedure TfrmStoredProcedure.WarningsHandler(Sender: TObject; Line: Integer; Column: Integer; Statement: String);
var
	Plan: String;

begin
	qryWarnings.SQL.Text := Statement;
	try
		qryWarnings.Prepare;
	except
		on E: Exception do
		begin
			// Do nothing
		end;
	end;
	Plan := qryWarnings.StatementPlan;
	if Pos('NATURAL', AnsiUpperCase(Plan)) > 0 then
		AddInfo('Warning: SubOptimal Query Line ' + IntToStr(Line) + ' Column ' + IntToStr(Column) + ' -  May not use Index (' + Plan + ')');
end;

procedure TfrmStoredProcedure.UpdateEncoding;
begin
	edEditor.Font.Charset := FCharSet;
	grdResults.Font.CharSet := FCharSet;
	pnledResults.ControlFont.CharSet := FCharSet;
end;

procedure TfrmStoredProcedure.txtParametersnullValidate(Sender: TField);
begin
	if not ((AnsiUpperCase(Sender.AsString) = 'NULL') or (Sender.AsString = '')) then
		raise Exception.Create('Null must be "NULL" or empty');
end;

procedure TfrmStoredProcedure.txtParametersnullChange(Sender: TField);
begin
	if AnsiUpperCase(Sender.AsString) = 'NULL' then
	begin
		FDontChange := True;
		txtParameters.FieldByName('PARAM_VALUE').AsString := '';
		FDontChange := False;
	end;
end;

procedure TfrmStoredProcedure.txtParametersparam_valueChange(Sender: TField);
begin
	if not FDontChange then
		txtParameters.FieldByName('NULL').AsString := '';
end;

procedure TfrmStoredProcedure.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmStoredProcedure.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

function TfrmStoredProcedure.CheckInputParamsImpact: Boolean;
var
	M: TSQLParser;
	ParseList: TVariablesList;
	ProcList: TVariablesList;
	DifferentList: TStringList;
	frmParameterChange: TfrmParameterChange;

begin
	if not FNewObject then
	begin
		DifferentList := TStringList.Create;
		frmParameterChange := TfrmParameterChange.Create(Self);
		try
			// Does this proc have any dependents
			qryStoredProc.SQL.Clear;
			qryStoredProc.SQL.Add('select RDB$DEPENDENT_NAME, RDB$DEPENDENT_TYPE, RDB$FIELD_NAME from RDB$DEPENDENCIES where RDB$DEPENDED_ON_NAME = ' +
				AnsiQuotedStr(FObjectName, '''') + ' and (RDB$DEPENDENT_TYPE in (5, 2)) order by RDB$DEPENDENT_NAME, RDB$FIELD_NAME;');
			qryStoredProc.Open;
			try
				if not (qryStoredProc.EOF and qryStoredProc.BOF) Then
				begin
					while not qryStoredProc.EOF do
					begin
						if DifferentList.IndexOf(qryStoredProc.FieldByName('RDB$DEPENDENT_NAME').AsString) = -1 then
						begin
							DifferentList.Add(qryStoredProc.FieldByName('RDB$DEPENDENT_NAME').AsString);
							with frmParameterChange.lvProcs.Items.Add do
							begin
								Caption := qryStoredProc.FieldByName('RDB$DEPENDENT_NAME').AsString;
								if qryStoredProc.FieldByName('RDB$DEPENDENT_TYPE').AsInteger = 5 then
									ImageIndex := 3
								else
									ImageIndex := 4;
							end;
						end;
						qryStoredProc.Next;
					end
				end
				else
				begin
					Result := True;
					Exit;
				end;
			finally
				qryStoredProc.Close;
				if qryStoredProc.IB_Transaction.Started then
					qryStoredProc.IB_Transaction.Commit;
			end;

			// Assume there is a difference
			ParseList := TVariablesList.Create(TVariablesCollectionItem);
			ProcList := TVariablesList.Create(TVariablesCollectionItem);
			try
				// Parse source to get list from source
				M := TSQLParser.Create(Self);
				try
					M.ParserType := ptCheckInputParms;
					M.Lexer.IsInterbase6 := FIsInterbase6;
					M.Lexer.SQLDialect := FSQLDialect;

					M.Lexer.yyinput.Text := edEditor.Text;
					if M.yyparse = 0 then
						ParseList.Assign(M.DeclaredVariables)
					else
					begin
						// We got a parser error so we bail out and return true
						Result := True;
						Exit;
					end;
				finally
					M.Free;
				end;

				// Get a list from the database
				qryStoredProc.SQL.Clear;
				qryStoredProc.SQL.Add('select A.RDB$PARAMETER_NAME, B.RDB$FIELD_TYPE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, B.RDB$CHARACTER_SET_ID from RDB$PROCEDURE_PARAMETERS A, RDB$FIELDS B where ' +
					'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$PARAMETER_TYPE = 0 and A.RDB$PROCEDURE_NAME = ''' + FObjectName + ''' order by RDB$PARAMETER_NUMBER asc;');
				qryStoredProc.Open;
				if not (qryStoredProc.EOF and qryStoredProc.BOF) Then
					while not qryStoredProc.EOF do
					begin
						with ProcList.Add do
						begin
							VarName := qryStoredProc.FieldByName('RDB$PARAMETER_NAME').AsString;
							VarType := qryStoredProc.FieldByName('RDB$FIELD_TYPE').AsInteger;
							VarLen := qryStoredProc.FieldByName('RDB$FIELD_LENGTH').AsInteger;
							// May need to compare using these later
							//VarCharSet := qryStoredProc.FieldByName('
							//VarPrecision := qryStoredProc.FieldByName('
							//VarScale := qryStoredProc.FieldByName('
						end;
						qryStoredProc.Next;
					end;

				qryStoredProc.Close;
				if qryStoredProc.IB_Transaction.Started then
					qryStoredProc.IB_Transaction.Commit;

				if not ((ParseList.Count = 0) and (ProcList.Count = 0)) then
				begin
					if ParseList.Count < ProcList.Count then
					begin
						// We have removed one or more parameters
						if frmParameterChange.ShowModal = mrYes then
						begin
							Result := True;
							Exit;
						end
						else
							Result := False;
					end
					else
					begin
						if ParseList.Count > ProcList.Count then
						begin
							// We have added one or more parameters
							if frmParameterChange.ShowModal = mrYes then
							begin
								Result := True;
								Exit;
							end
							else
								Result := False;
						end
						else
						begin
							if ParseList.Count = ProcList.Count then
							begin
								// The number of parameters is the same
								Result := True;
								Exit;
							end
							else
							begin
								Result := True;
								Exit;
							end;
						end;
					end;
				end
				else
				begin
					// No params at all
					Result := True;
					Exit;
				end;
			finally
				ParseList.Free;
				ProcList.Free;
			end;
		finally
			DifferentList.Free;
			frmParameterChange.Free;
		end;
	end
	else
		Result := True;
end;

procedure TfrmStoredProcedure.WMNCLButtonDown(var Message: TMessage);
begin
	inherited;
	edEditor.CLoseUpLists;
end;

procedure TfrmStoredProcedure.WMNCRButtonDown(var Message: TMessage);
begin
	inherited;
	edEditor.CloseUpLists;
end;

procedure TfrmStoredProcedure.qryResultsAfterOpen(DataSet: TDataSet);
begin
	GlobalFormatFields(DataSet);
end;

procedure TfrmStoredProcedure.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

function TfrmStoredProcedure.CanCaptureSnippet: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := Length(edEditor.SelText) > 0;
end;

function TfrmStoredProcedure.CanChangeEncoding: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := True;

		PG_DOCO:
			Result := True;

		PG_RESULTS:
			Result := True;
	end;
end;

function TfrmStoredProcedure.CanCopy: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			if lstResults.Focused then
				Result := lstResults.ItemIndex > -1
			else
				Result := Length(edEditor.SelText) > 0;

		PG_DOCO:
			Result := framDoco.CanCopy;
	end;
end;

function TfrmStoredProcedure.CanCut: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := Length(edEditor.SelText) > 0;

		PG_DOCO:
			Result := framDoco.CanCut;
	end;
end;

function TfrmStoredProcedure.CanExecute: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := not (FNewObject);
end;

function TfrmStoredProcedure.CanExport: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsExecute then
		Result := not (qryResults.BOF and qryResults.EOF)
end;

function TfrmStoredProcedure.CanFind: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanFind;
	end;
end;

function TfrmStoredProcedure.CanFindNext: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanFindNext;
	end;
end;

function TfrmStoredProcedure.CanGotoBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := IsBookmarkSet(Index);
end;

function TfrmStoredProcedure.CanInternalClose: Boolean;
begin
	Result := True;
end;

function TfrmStoredProcedure.CanPaste: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := Clipboard.HasFormat(CF_TEXT);

		PG_DOCO:
			Result := framDoco.CanPaste;
	end;
end;

function TfrmStoredProcedure.CanPrint: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			Result := True;

		PG_DOCO:
			Result := (not FNewObject) and framDoco.CanPrint;

		PG_RESULTS:
			Result := not (qryResults.EOF and qryResults.BOF);

		PG_DEPEND:
			Result := (not FNewObject) and framDepend.CanPrint;

		PG_DRUI:
			Result := (not FNewObject) and frameDRUI.CanPrint;

		PG_GRANTS:
			Result := (not FNewObject) and framePerms.CanPrint;
	else
		Result := False;		
	end;
end;

function TfrmStoredProcedure.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

function TfrmStoredProcedure.CanRedo: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.CanRedo;

		PG_DOCO:
			Result := framDoco.CanRedo;
	end;
end;

function TfrmStoredProcedure.CanSelectAll: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanSelectAll;
	end;
end;

function TfrmStoredProcedure.CanToggleBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := edEditor.Lines.Count > 0;
end;

function TfrmStoredProcedure.CanTransactionCommit: Boolean;
begin
	Result := tranResults.Started;
end;

function TfrmStoredProcedure.CanTransactionRollback: Boolean;
begin
	Result := tranResults.Started;
end;

function TfrmStoredProcedure.CanUndo: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.CanUndo;

		PG_DOCO:
			Result := framDoco.CanUndo;
	end;
end;

function TfrmStoredProcedure.CanViewMessages: Boolean;
begin
	Result := True;
end;

function TfrmStoredProcedure.AreMessagesVisible: Boolean;
begin
	Result := pnlMessages.Visible;
end;

function TfrmStoredProcedure.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmStoredProcedure.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

function TfrmStoredProcedure.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if edEditor.Modified then
		begin
			case MessageDlg('The stored procedure ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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
					Result := True;
			end;
		end;
		if framDoco.Modified then
		begin
			case MessageDlg('The documentation for stored procedure ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
				mrYes:
					framDoco.SaveDoco;

				mrCancel:
					Result := False;

				mrNo:
					Result := True;
			end;
		end;
	end
	else
		Result := True;
end;

procedure TfrmStoredProcedure.DoCaptureSnippet;
begin
	CaptureCodeSnippet(edEditor);
end;

procedure TfrmStoredProcedure.DoChangeEncoding(Index: Integer);
begin
	inherited;
	FCharSet := GetCharSetByIndex(Index);
	UpdateEncoding;
end;

procedure TfrmStoredProcedure.DoCopy;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			if lstResults.Focused then
				Clipboard.AsText := lstResults.Collection[lstResults.ItemIndex].TextData.Text
			else
				edEditor.CopyToClipboard;

		PG_DOCO:
			framDoco.CopyToClipboard;
	end;
end;

procedure TfrmStoredProcedure.DoCut;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.CutToClipBoard;

		PG_DOCO:
			framDoco.CutToClipBoard;
	end;
end;

procedure TfrmStoredProcedure.DoExecute;
var
	Params: String;

begin
	// Compile first
	if edEditor.Modified then
	begin
		if MarathonIDEInstance.DebuggerVM.Executing then
		begin
			if MessageDlg('Stored Procedure source has changed. Recompile?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
			begin
				MarathonIDEInstance.DebuggerVM.Reset;
				DoCompile;
			end;
		end
		else
			DoCompile;
	end;

	if FErrors then
		Exit;

	try
		qryResults.BeginBusy(False);
		Screen.Cursor := crHourGlass;
		stsEditor.Panels[2].Text := 'Executing Stored Procedure...';
		stsEditor.Refresh;

		if MarathonIDEInstance.DebuggerVM.Enabled then
		begin
			if MarathonIDEInstance.DebuggerVM.ModuleCount = 0 then
				DoCompile;

			if FErrors then
				Exit;

			if NeedParameters then
				if not GetDebugParameters(False) then
					Exit;

			InternalCaption := 'Stored Procedure - [' + FObjectName + '] - Running';
			IT.Caption := Caption;
			edEditor.ErrorLine := -1;
			ClearErrors;
			dsResults.DataSet := MarathonIDEInstance.DebuggerVM.ModuleByName[FObjectName].ExecutionResults;
			MarathonIDEInstance.DebuggerVM.Execute(False);
		end
		else
		begin
			dsResults.DataSet := qryResults;
			qryResults.SQL.Clear;
			if NeedParameters then
			begin
				if HasParameters then
				begin
					if GetParameters(False, Params) then
						qryResults.SQL.Add('select * from ' + FObjectName + '(' + Params + ');')
					else
						Exit;
				end
				else
				begin
					if GetParameters(False, Params) then
						qryResults.SQL.Add('execute procedure ' + FObjectName + '(' + Params + ');')
					else
						Exit;
				end;
			end
			else
			begin
				if HasParameters then
					qryResults.SQL.Add('select * from ' + FObjectName + ';')
				else
					qryResults.SQL.Add('execute procedure ' + FObjectName + ';')
			end;

			try
				if HasParameters then
				begin
					qryResults.Open;
					pgObjectEditor.ActivePage := tsExecute;
					pgObjectEditorChange(Self);
				end
				else
					qryResults.ExecSQL;
			except
				on E: Exception do
				begin
					if tranResults.InTransaction then
						tranResults.Rollback;
					pgObjectEditor.ActivePage := tsStoredProc;
					if not pnlMessages.Visible then
					begin
						pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
						pnlMessages.Visible := True;
						stsEditor.Top := Height;
					end;
					Refresh;
					AddError(E.Message);
					// Go to the error
					lstResultsClick(lstResults);
				end;
			end;
		end;
	finally
		qryResults.EndBusy;
		Screen.Cursor := crDefault;
		stsEditor.Panels[2].Text := '';
		stsEditor.Refresh;
	end;
end;

procedure TfrmStoredProcedure.DoExport;
var
	Idx: Integer;
	FName, TableName: String;
	F: TfrmSaveFileFormat;
	FList: TStringList;
	Ex: TExportType;

begin
	F := TfrmSaveFileFormat.Create(Self);
	try
		with F do
		begin
			for idx := 0 to qryResults.Fields.Count - 1 do
				chklistColumns.Items.Add(qryResults.Fields[idx].FieldName);

			// Default all to true
			for Idx := 0 to chkListColumns.Items.Count - 1 do
				chkListColumns.Checked[Idx] := True;

			if ShowModal = mrOK then
			begin
				Ex.ExType := cmbFormat.ItemIndex;
				Ex.FirstRowNames := chkFirstRow.Checked;
				TableName := edTable.Text;
				case cmbSep.ItemIndex of
					0:
						Ex.SepChar := ',';

					1:
						Ex.SepChar := #9;

					2:
						Ex.SepChar := '^';

					3:
						Ex.SepChar := '~';
				end;

				case cmbQual.ItemIndex of
					0:
						Ex.QualChar := '"';

					1:
						Ex.QualChar := '''';

					2:
						Ex.QualChar := '';
				end;

				FList := TStringList.Create;
				try
					for idx := 0 to chkListColumns.Items.Count - 1 do
						if chkListColumns.Checked[idx] then
							FList.Add(chkListColumns.Items[idx]);
					chkListColumns.ItemIndex := 0;

					FName := F.edFileName.Text;

					ExportGrid(Ex, qryResults, FList, TableName, FName);
				finally
					FList.Free;
				end;
			end;
		end;
	finally
		F.Free;
	end;
end;

function TfrmStoredProcedure.CanLoadFrom: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := True;
end;

procedure TfrmStoredProcedure.DoLoadFrom;
begin
	if dlgOpen.Execute then
	begin
		FFileName := dlgOpen.FileName;
		if LoadEditorContent(edEditor, FFileName) then
		begin
			ObjectModified := False;
			edEditor.Modified := False;
			edEditor.OnChange(nil);
		end;
	end;
end;

function TfrmStoredProcedure.CanSaveAs: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := True;
end;

procedure TfrmStoredProcedure.DoSaveAs;
begin
	dlgSave.FileName := FObjectName;
	if dlgSave.Execute then
	begin
		FFileName := dlgSave.FileName;
		if SaveEditorContent(edEditor, FFileName) then
		begin
			ObjectModified := False;
			edEditor.Modified := False;
			edEditor.OnChange(nil);
		end;
	end;
end;

function TfrmStoredProcedure.CanClearBuffer: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := edEditor.Lines.Count > 0;
end;

procedure TfrmStoredProcedure.DoClearBuffer;
begin
	edEditor.Clear;
	edEditor.OnChange(edEditor);
end;

procedure TfrmStoredProcedure.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.WSFind;

		PG_DOCO:
			framDoco.WSFind;
	end;
end;

procedure TfrmStoredProcedure.DoFindNext;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.WSFindNext;

		PG_DOCO:
			framDoco.WSFindNext;
	end;
end;

procedure TfrmStoredProcedure.DoGotoBookmark(Index: Integer);
begin
	if pgObjectEditor.ActivePage = tsStoredProc then
		edEditor.GotoBookmark(Index);
end;

procedure TfrmStoredProcedure.DoInternalClose;
begin
	Close;
end;

procedure TfrmStoredProcedure.DoPaste;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			if ClipBoard.HasFormat(CF_TEXT) then
				edEditor.PasteFromClipboard;

		PG_DOCO:
			if ClipBoard.HasFormat(CF_TEXT) then
				framDoco.PasteFromClipboard;
	end;
end;

procedure TfrmStoredProcedure.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			MarathonIDEInstance.PrintSP(False, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrint;

		PG_RESULTS:
			MarathonIDEInstance.PrintDataSet(qryResults, False, FObjectName);

		PG_DEPEND:
			framDepend.DoPrint;

		PG_DRUI:
			frameDRUI.DoPrint;

		PG_GRANTS:
			framePerms.DoPrint;
	end;
end;

procedure TfrmStoredProcedure.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			MarathonIDEInstance.PrintSP(True, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrintPreview;

		PG_RESULTS:
			MarathonIDEInstance.PrintDataSet(qryResults, False, FObjectName);

		PG_DEPEND:
			framDepend.DoPrintPreview;

		PG_DRUI:
			frameDRUI.DoPrintPreview;

		PG_GRANTS:
			framePerms.DoPrintPreview;
	end;
end;

procedure TfrmStoredProcedure.DoRedo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.Redo;

		PG_DOCO:
			framDoco.Redo;
	end;
end;

procedure TfrmStoredProcedure.DoSelectAll;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.SelectAll;

		PG_DOCO:
			framDoco.SelectAll;
	end;
end;

procedure TfrmStoredProcedure.DoToggleBookmark(Index: Integer);
begin
	GlobalSetBookmark(edEditor, Index);
end;

procedure TfrmStoredProcedure.DoTransactionCommit;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_RESULTS:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Commit Work - (Note: Committing will also close the result set)?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						qryResults.Close;
						tranResults.Commit;
						pgObjectEditor.ActivePage := tsStoredProc;
					end;
				end
				else
				begin
					qryResults.Close;
					tranResults.Commit;
					pgObjectEditor.ActivePage := tsStoredProc;
				end;
			end;
	else
		begin
			if gPromptTrans then
			begin
				if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
				begin
					qryResults.Close;
					tranResults.Commit;
				end;
			end
			else
			begin
				qryResults.Close;
				tranResults.Commit;
			end;
		end;
	end;
end;

procedure TfrmStoredProcedure.DoTransactionRollback;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_RESULTS:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Rollback Work - (Note: Rolling Back will also close the result set)?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						qryResults.Close;
						tranResults.Rollback;
						pgObjectEditor.ActivePage := tsStoredProc;
					end;
				end
				else
				begin
					qryResults.Close;
					tranResults.Rollback;
					pgObjectEditor.ActivePage := tsStoredProc;
				end;
			end;
	else
		begin
			if gPromptTrans then
			begin
				if MessageDlg('Rollback Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
				begin
					qryResults.Close;
					tranResults.Rollback;
				end;
			end
			else
			begin
				qryResults.Close;
				tranResults.Rollback;
			end;
		end;
	end;
end;

procedure TfrmStoredProcedure.DoUndo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.Undo;

		PG_DOCO:
			framDoco.Undo;
	end;
end;

procedure TfrmStoredProcedure.DoViewMessages;
begin
	inherited;
	pnlMessages.Visible := not pnlMessages.Visible;
	if pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		stsEditor.Top := Height;
	end;
end;

procedure TfrmStoredProcedure.DoViewNextPage;
begin
	inherited;
end;

procedure TfrmStoredProcedure.DoViewPrevPage;
begin
	inherited;
end;

procedure TfrmStoredProcedure.EnvironmentOptionsRefresh;
begin
	inherited;
end;

function TfrmStoredProcedure.IsBookmarkSet(Index: Integer): Boolean;
begin
	Result := IsABookmarkSet(edEditor, Index);
end;

function TfrmStoredProcedure.IsEncoding(Index: Integer): Boolean;
begin
	Result := FCharSet = GetCharSetByIndex(Index);
end;

procedure TfrmStoredProcedure.LoadProcedure(ProcedureName: String);
begin
	FObjectName := ProcedureName;
	qryStoredProc.BeginBusy(False);
	try
		LoadProcSource;
	finally
		qryStoredProc.EndBusy;
	end;

	Refresh;
	Show;
	// Load the documentation from the SP
	framDoco.LoadDoco;

	FHasParameters := HasParameters;
	FNeedParameters := NeedParameters;
end;

procedure TfrmStoredProcedure.ProjectOptionsRefresh;
begin
	inherited;
end;

procedure TfrmStoredProcedure.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		tranResults.IB_Connection := nil;
		qryWarnings.IB_Connection := nil;
		qryResults.IB_Connection := nil;
		qryUtil.IB_Connection := nil;
		qryStoredProc.IB_Connection := nil;
		framDoco.qryDoco.IB_Connection := nil;
		framDoco.qryDoco.IB_Transaction := nil;
		IsInterbase6 := False;
		SQLDialect := 0;
		stsEditor.Panels[3].Text := 'No Connection';
	end
	else
	begin
		tranResults.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryResults.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryResults.IB_Transaction := tranResults;

		qryWarnings.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryWarnings.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryStoredProc.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryStoredProc.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qryUtil.IB_Connection.SQLDialect;
		stsEditor.Panels[3].Text := Value;
	end;
end;


procedure TfrmStoredProcedure.NewProcedure;
var
	Tmp: String;

begin
	FObjectName := 'new_procedure';
	InternalCaption := 'Stored Procedure - [' + FObjectName + ']';
	IT.Caption := Caption;
	tmp := 'create procedure NEW_PROCEDURE' + #13#10;
	tmp := Tmp + 'as' + #13#10;
	tmp := Tmp + 'begin' + #13#10;
	tmp := Tmp + '	suspend;' + #13#10;
	tmp := Tmp + 'end' + #13#10;

	edEditor.Text := AdjustLineBreaks(tmp);
	FObjectModified := True;
	FNewObject := True;

	stsEditor.Panels[1].Text := '';
end;

function TfrmStoredProcedure.CanCompile: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := edEditor.Lines.Count > 0
end;

procedure TfrmStoredProcedure.DoCompile;
var
	Idx: Integer;
	Doco, CompileText: String;
	M: TSQLParser;
	TmpIntf: IMarathonForm;
	Module: TProcModule;
	FCompile: TfrmCompileDBObject;

begin
	try
		if tranResults.Started then
		begin
			MessageDlg('There is an open transaction from the last execution - Commit or Rollback before compiling.', mtWarning, [mbOK], 0);
			FErrors := True;
			Exit;
		end;

		for Idx := 0 to edEditor.Lines.Count - 1 do
			edEditor.RemoveQuestGlyph(ilExecutedOK, Idx + 1);

		// Check the impact of changing input params
		if not CheckInputParamsImpact then
			Exit;

		Doco := framDoco.Doco;

		edEditor.ErrorLine := -1;

		Refresh;

		if FNewObject then
			CompileText := edEditor.Text
		else
		begin
			CompileText := edEditor.Text;
			Delete(CompileText, Pos('create', CompileText), 6);
			Insert('alter', CompileText, 1);
		end;

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryStoredProc.IB_Connection, qryStoredProc.IB_Transaction, ctSP, CompileText);

		FErrors := FCompile.CompileErrors;
		FCompile.Free;

		if FErrors then
			Exit;

		pnlMessages.Visible := False;

		// Update the tree cache
		if FNewObject then
			MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctSP);

		FNewObject := False;

		// Now check for warnings
		M := TSQLParser.Create(Self);
		try
			M.ParserType := ptWarnings;
			M.OnStatementFound := WarningsHandler;
			M.Lexer.IsInterbase6 := FIsInterbase6;
			M.Lexer.SQLDialect := FSQLDialect;

			M.Lexer.yyinput.Text := edEditor.Text;
			if M.yyparse = 0 then
			begin

			end;
		finally
			M.Free;
		end;

		edEditor.Modified := False;
		edEditorChange(edEditor);

		framDoco.Doco := Doco;
		framDoco.SaveDoco;
		FHasParameters := HasParameters;
		FNeedParameters := NeedParameters;

		if MarathonIDEInstance.IsDebuggerEnabled and MarathonIDEInstance.CanDebuggerEnabled then
		begin
			MarathonIDEInstance.DebuggerVM.DatabaseName := FDatabaseName;
			MarathonIDEInstance.DebuggerVM.Database := qryResults.IB_Connection;
			if not MarathonIDEInstance.DebuggerVM.Compile(FObjectName, edEditor.Text) then
			begin
				MessageDlg('Marathon was unable to compile the source in the editor.', mtError, [mbOK], 0);
				edDebugInfo.Text := MarathonIDEInstance.DebuggerVM.Errors;
				edDebugInfo.Text := edDebugInfo.Text + #13#10 + MarathonIDEInstance.DebuggerVM.OutPut;
			end
			else
			begin
				edDebugInfo.Text := MarathonIDEInstance.DebuggerVM.Dump;

				// Draw the blue dots
				Module := MarathonIDEInstance.DebuggerVM.ModuleByName[FObjectName];
				if Assigned(Module) then
					for Idx := 0 to Module.AllowBreakList.Count - 1 do
						edEditor.AddQuestGlyph(ilExecutedOK, StrToInt(Module.AllowBreakList[Idx]));
			end;
		end;

	finally
		edEditor.SetFocus;
	end;
end;

function TfrmStoredProcedure.CanObjectDrop: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := not FNewObject;
end;

procedure TfrmStoredProcedure.DoObjectDrop;
var
	DoClose: Boolean;
	frmDropObject: TfrmDropObject;

begin
	if MessageDlg('Are you sure that you wish to drop the stored procedure "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctSP, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

function TfrmStoredProcedure.CanObjectParameters: Boolean;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
		Result := (MarathonIDEInstance.DebuggerVM.ModuleCount > 0) and FHasParameters
	else
		Result := True;
end;

function TfrmStoredProcedure.CanSaveDoco: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanSaveDoco;
end;

procedure TfrmStoredProcedure.DoObjectParameters;
var
	Dummy: String;

begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
	begin
		if NeedParameters then
			GetDebugParameters(True);
	end
	else
		if NeedParameters then
			GetParameters(True, Dummy);
end;

procedure TfrmStoredProcedure.DoSaveDoco;
begin
	framDoco.SaveDoco;
end;

function TfrmStoredProcedure.CanReplace: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanReplace;
	end;
end;

procedure TfrmStoredProcedure.DoReplace;
begin
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			edEditor.WSReplace;

		PG_DOCO:
			framDoco.WSReplace;
	end;
end;

function TfrmStoredProcedure.CanSaveAsTemplate: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsStoredProc then
		Result := edEditor.Lines.Count > 0
end;

procedure TfrmStoredProcedure.DoSaveAsTemplate;
var
	frmInputDialog: TfrmInputDialog;

begin
	frmInputDialog := TfrmInputDialog.Create(Self);
	try
		frmInputDialog.Caption := 'Save Stored Procedure Template';
		frmInputDialog.lblPrompt.Caption := 'Template Name:';
		if frmInputDialog.ShowModal = mrOK then
		begin
			ForceDirectories(ExtractFilePath(Application.ExeName) + 'Templates\');
			edEditor.Lines.SaveToFile(ExtractFilePath(Application.ExeName) + 'Templates\' + frmInputDialog.edItem.Text + '.spt');
		end;
	finally
		frmInputDialog.Free;
	end;
end;

function TfrmStoredProcedure.CanGrant: Boolean;
begin
	Result := True;
end;

function TfrmStoredProcedure.CanRevoke: Boolean;
begin
	Result := True;
end;

procedure TfrmStoredProcedure.DoGrant;
begin
	with TfrmEditorGrant.Create(Self, FDatabaseName, FObjectName, otProcedure) do
		try
			if ShowModal = mrOK then
				if pgObjectEditor.ActivePage = tsGrants then
					pgObjectEditor.OnChange(pgObjectEditor);
		finally
			Free;
		end;
end;

procedure TfrmStoredProcedure.DoRevoke;
begin
	DoGrant;
end;

function TfrmStoredProcedure.CanQueryBuilder: Boolean;
begin
	Result := False;
end;

procedure TfrmStoredProcedure.DoQueryBuilder;
var
	B: TQBuilderDialog;

begin
	B := TQBuilderDialog.Create(Self);
	try
		B.OnGetTableColumns := MarathonIDEInstance.GetTableColumnsEvent;
		B.OnGetTables := MarathonIDEInstance.GetTablesEvent;
		B.SystemTables := False;
		if B.Execute then
			edEditor.SelText := B.SQL.Text;
		B.OnGetTableColumns := nil;
		B.OnGetTables := nil;
	finally
		B.Free;
	end;
end;

procedure TfrmStoredProcedure.OpenMessages;
begin
	pnlMessages.Visible := True;
	pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
	stsEditor.Top := Height;
end;

procedure TfrmStoredProcedure.AddCompileError(ErrorText: String);
begin
	inherited;
	OpenMessages;
	AddError(ErrorText);
end;

procedure TfrmStoredProcedure.ClearErrors;
begin
	inherited;
	lstResults.Collection.Clear;
end;

procedure TfrmStoredProcedure.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

procedure TfrmStoredProcedure.SetObjectModified(Value: Boolean);
begin
	inherited;
	FObjectModified := False;
end;

procedure TfrmStoredProcedure.SetObjectName(Value: String);
begin
	inherited;
	FObjectName := Value;
	InternalCaption := 'Stored Procedure - [' + FObjectName + ']';
	IT.Caption := Caption;
end;

procedure TfrmStoredProcedure.pnlMessagesResize(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.CurrentProject.ResultsPanelHeight := pnlMessages.Height;
	stsEditor.Top := Height;
end;

function TfrmStoredProcedure.CanObjectAddToProject: Boolean;
begin
	Result := False;
end;

procedure TfrmStoredProcedure.DoObjectAddToProject;
begin
	inherited;

end;

function TfrmStoredProcedure.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

procedure TfrmStoredProcedure.FormDestroy(Sender: TObject);
var
	Idx: Integer;

begin
	inherited;
	It.Free;
	for Idx := 0 to FParameterList.Count - 1 do
		FParameterList.Objects[Idx].Free;
	FParameterList.Free;
end;

function TfrmStoredProcedure.CanStepInto: Boolean;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
		Result := True
	else
		Result := False;
end;

procedure TfrmStoredProcedure.DoStepInto;
begin
	// Compile first
	if edEditor.Modified then
	begin
		if MarathonIDEInstance.DebuggerVM.Executing then
		begin
			if MessageDlg('Stored Procedure source has changed. Recompile?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
			begin
				MarathonIDEInstance.DebuggerVM.Reset;
				DoCompile;
			end;
		end
		else
			DoCompile;
	end;

	if FErrors then
		Exit;

	if not MarathonIDEInstance.DebuggerVM.Executing then
	begin
		if MarathonIDEInstance.DebuggerVM.ModuleCount = 0 then
			DoCompile;

		if FErrors then
			Exit;

		if NeedParameters then
			if not GetDebugParameters(False) then
				Exit;
	end;
	InternalCaption := 'Stored Procedure - [' + FObjectName + '] - Running';
	IT.Caption := Caption;
	ClearErrors;
	edEditor.ErrorLine := -1;
	dsResults.DataSet := MarathonIDEInstance.DebuggerVM.ModuleByName[FObjectName].ExecutionResults;
	MarathonIDEInstance.DebuggerVM.Execute(True);
end;

procedure TfrmStoredProcedure.DebugSetExecutionPoint(Line: Integer);
begin
	if (Line = -1) or (Line = -2) then
	begin
		edEditor.SetExecutionHighlighting(-1, -1);
		if Line = -2 then
			InternalCaption := 'Stored Procedure - [' + FObjectName + '] - Paused'
		else
			InternalCaption := 'Stored Procedure - [' + FObjectName + ']';
		IT.Caption := Caption;
	end
	else
	begin
		edEditor.SetExecutionHighlighting(Line, Line);
		InternalCaption := 'Stored Procedure - [' + FObjectName + '] - Paused';
		IT.Caption := Caption;
	end;
end;

function TfrmStoredProcedure.CanAddBreakPoint: Boolean;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
		Result := True
	else
		Result := False;
end;

procedure TfrmStoredProcedure.DoAddBreakPoint;
begin
	MarathonIDEInstance.DebuggerVM.AddBreakPoint(FDatabaseName, FObjectName, edEditor.CaretY);
end;

procedure TfrmStoredProcedure.DebugSetBreakPointLine(Active: Boolean; Line: Integer);
//var
//	BP: TSM_BreakPointData;
begin
	{ TODO: Fixit }
	if Active then
	begin
//		BP := TSM_BreakPointData.Create(Line - 1, True, '', 0);
//		edEditor.TextData.Breakpoints.AddBreakpoint(BP);
	end
	else
	begin
//		edEditor.TextData.Breakpoints.RemoveBreakpointAtLine(Line - 1);
	end;
end;

function TfrmStoredProcedure.CanToggleBreakPoint: Boolean;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
		Result := True
	else
		Result := False;
end;

procedure TfrmStoredProcedure.DoToggleBreakPoint;
begin
	MarathonIDEInstance.DebuggerVM.ToggleBreakPoint(FDatabaseName, FObjectName, edEditor.CaretY);
end;

function TfrmStoredProcedure.CanEvalModify: Boolean;
begin
	if MarathonIDEInstance.DebuggerVM.Enabled then
		Result := MarathonIDEInstance.DebuggerVM.Executing
	else
		Result := False;
end;

procedure TfrmStoredProcedure.DoEvalModify;
begin
	MarathonIDEInstance.DebuggerVM.EvalModify;
end;

procedure TfrmStoredProcedure.edEditorStatusChange(Sender: TObject;	Changes: TSynStatusChanges);
begin
	edEditorChange(Sender);
end;

function TfrmStoredProcedure.IDEGetLines: IGimbalIDELines;
begin
	Result := nil;
end;

procedure TfrmStoredProcedure.IDESetLines(Value: IGimbalIDELines);
begin

end;

function TfrmStoredProcedure.CanAddWatchAtCursor: Boolean;
begin
	Result := MarathonIDEInstance.DebuggerVM.Enabled;
end;

procedure TfrmStoredProcedure.DoAddWatchAtCursor;
var
	Symbol: String;

begin
	Symbol := edEditor.GetWordAtRowCol(edEditor.CaretXY);
	MarathonIDEInstance.DebuggerVM.AddWatchAtCursor(Symbol);
end;

procedure TfrmStoredProcedure.DebugSetExceptionLine(Line: Integer; Message: String);
begin
	MessageDlg('The stored procedure ' + FObjectName + ' raised exception "' + Message + '". Process stopped. Use Step or Run to continue.', mtError, [mbOK], 0);
	edEditor.ErrorLine := Line;
	AddError(Message);
end;

procedure TfrmStoredProcedure.DebugRefreshDots;
var
	Idx: Integer;
	Module: TProcModule;

begin
	// Draw the blue dots
	Module := MarathonIDEInstance.DebuggerVM.ModuleByName[FObjectName];
	if Assigned(Module) then
		for Idx := 0 to Module.AllowBreakList.Count - 1 do
			edEditor.AddQuestGlyph(ilExecutedOK, StrToInt(Module.AllowBreakList[Idx]));
end;

end.

{ Old History
	10.04.2002	tmuetze
		* TfrmStoredProcedure.DoGrant, TfrmStoredProcedure.DoRevoke rewritten for new
			and revised EditorGrant
}

{
$Log: EditorStoredProcedure.pas,v $
Revision 1.16  2007/06/15 21:31:32  rjmills
Numerous bug fixes and current work in progress

Revision 1.15  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.14  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.13  2005/06/29 22:29:51  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.12  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.11  2005/04/13 16:04:27  rjmills
*** empty log message ***

Revision 1.9  2002/09/25 12:11:40  tmuetze
Revisited the 'Load from' and 'Save as' capabilities of the editors

Revision 1.8  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.7  2002/06/14 09:57:37  tmuetze
Reenabled context sensitive keyword help via SQLRef.hlp

Revision 1.6  2002/05/27 07:10:28  tmuetze
Fixed another compile bug and tightened the sourcecode a bit

Revision 1.5  2002/05/25 10:24:21  tmuetze
Fixed SP update bug #556457

Revision 1.4  2002/05/06 06:23:32  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
