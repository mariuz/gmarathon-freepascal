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
// $Id: SQLForm.pas,v 1.18 2007/02/10 22:01:14 rjmills Exp $

{
$Log: SQLForm.pas,v $
Revision 1.18  2007/02/10 22:01:14  rjmills
Fixes for Component Library updates

Revision 1.17  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.16  2006/10/19 03:54:59  rjmills
Numerous bug fixes and current work in progress

Revision 1.15  2005/11/16 06:50:18  rjmills
General updates Synedit Search and comment updates

Revision 1.14  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.13  2005/04/13 16:04:31  rjmills
*** empty log message ***

Revision 1.12  2003/11/05 05:53:00  figmentsoft
Quick hack for empty selection returns.

Revision 1.11  2002/09/25 12:11:40  tmuetze
Revisited the 'Load from' and 'Save as' capabilities of the editors

Revision 1.10  2002/09/23 10:32:51  tmuetze
Added the possibility to load files into the SQL Editor

Revision 1.9  2002/08/28 14:52:29  tmuetze
Fixed a typo

Revision 1.8  2002/06/14 09:57:37  tmuetze
Reenabled context sensitive keyword help via SQLRef.hlp

Revision 1.7  2002/05/30 15:40:34  tmuetze
Added a patch from Pavel Odstrcil: Added posibility to create insert statement with column names optionally surrounded by quotes, data values now enclosed in single quotes, added largeint type

Revision 1.6  2002/05/21 09:59:52  tmuetze
TIBOQuery.FetchAll instead of TIBOQuery.Last, this should also display the fetch dialog

Revision 1.5  2002/05/15 08:54:09  tmuetze
Fixed some IBPerformanceMonitor and SQLForm statistic related issues

Revision 1.4  2002/05/14 07:14:56  tmuetze
Readded the PrepareTime, FetchTime performance values, but some more testing is needed

Revision 1.3  2002/05/06 14:27:49  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit SQLForm;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls,ExtCtrls, DB, Menus, Grids, DBGrids,	Buttons, Registry,
	ClipBrd, ToolWin, Printers, Tabs, DBCtrls, Series, TeeProcs, TeEngine,
	Chart, ActnList, ImgList,
	rmPanel,
	rmCollectionListBox,
	rmTabs3x,
	rmMemoryDataSet,
	IB_Process,
	IB_Session,
	IB_Components,
	IBODataset,
	SynEdit,
  SynEditTypes,
	SyntaxMemoWithStuff2,
	adbpedit,
	BaseDocumentForm,
	BaseDocumentDataAwareForm,
	MarathonInternalInterfaces,
	GimbalToolsAPI,
	SQLYacc,
	IBPerformanceMonitor,
	DiagramTree, rmNotebook2;

type
	TExecuteMode = (exStatement, exScript);

	TfrmSQLForm = class(TfrmBaseDocumentDataAwareForm, IMarathonSQLForm, IGimbalIDESQLTextEditor)
		stsSQLStatement: TStatusBar;
		dsSQLStatement: TDataSource;
		dlgSave: TSaveDialog;
    qrySQLStatement: TIBOQuery;
    qryUtil: TIBOQuery;
    pnlBase: TPanel;
    pgSQLStatement: TPageControl;
    tsSQLStatement: TTabSheet;
    edSQLStatement: TSyntaxMemoWithStuff2;
    tsResultsView: TTabSheet;
    nbResults: TrmNoteBookControl;
    tabResults: TrmTabSet;
    grdSQLStatement: TDBGrid;
    pnlResForm: TDBPanelEdit;
    transSQLStatement: TIB_Transaction;
    pnlNavigator: TPanel;
    navResults: TDBNavigator;
    pnlPerformance: TPanel;
    DBNavigator1: TDBNavigator;
    dtaPerform: TrmMemoryDataSet;
    dsPerform: TDataSource;
    perfSQL: TIBPerformanceMonitor;
    tsPerformance: TTabSheet;
    pnlBasePerformance: TPanel;
    pnlNoPerform: TPanel;
		lblPerform: TLabel;
		Panel3: TPanel;
		tsPlan: TTabSheet;
		edPlan: TMemo;
		btnRefresh: TSpeedButton;
		SpeedButton1: TSpeedButton;
		imgSuccess: TImage;
		cmbMode: TComboBox;
		qryScript: TIB_DSQL;
		rmTabSet1: TrmTabSet;
    nbPerform: TrmNoteBookControl;
		grdPerform: TDBGrid;
		Panel2: TPanel;
		chtPerform: TChart;
		Series1: THorizBarSeries;
		Panel1: TPanel;
		Shape1: TShape;
		Label1: TLabel;
		Label2: TLabel;
		Shape2: TShape;
		dtPlan: TDiagramTree;
		ImageList1: TImageList;
  nbpDatasheet : TrmNotebookPage;
  nbpForm : TrmNotebookPage;
  nbpStats : TrmNotebookPage;
  nbpChart : TrmNotebookPage;
  dlgOpen: TOpenDialog;
  pnlMessages: TrmPanel;
  lstResults: TrmCollectionListBox;
		procedure edSQLStatementChange(Sender: TObject);
		procedure lstResultsClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure WindowListClick(Sender: TObject);
		procedure edSQLStateMentKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure edSQLStatementDragOver(Sender, Source: TObject; X, Y: Integer;
			State: TDragState; var Accept: Boolean);
		procedure edSQLStatementDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure grdSQLStatementDblClick(Sender: TObject);
		function FormHelp(Command: Word; Data: Integer;	var CallHelp: Boolean): Boolean;
		procedure tabResultsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure edSQLStatementGetHintText(Sender: TObject; Token: String;
			var HintText: String; HintType: THintType);
		procedure edSQLStatementNavigateHyperLinkClick(Sender: TObject; Token: String);
		procedure pgSQLStatementChange(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure qrySQLStatementAfterOpen(DataSet: TDataSet);
		procedure actQueryBuilderExecute(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure pnlMessagesResize(Sender: TObject);
		procedure cmbModeChange(Sender: TObject);
		procedure edSQLStatementStatusChange(Sender: TObject; Changes: TSynStatusChanges);
		procedure rmTabSet1Change(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure qrySQLStatementAfterPrepare(Sender: TObject);
		procedure qrySQLStatementBeforePrepare(Sender: TObject);
    procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		LinePos: LongInt;
		It: TMenuItem;
		// Context sensitive keyword help
		DoKeySearch: Boolean;

		// Performance measurement
		FPrepareTime, FPrepareTimeStart: Cardinal;
		FStmtIndex: Integer;
		FShowPlan: Boolean;
		FShowPerformData: Boolean;
		FExecuteMode: TExecuteMode;
		FStartMemory: Integer;
		FCurrentMemory: Integer;
		FCloseQueried: Boolean;

		FFileName: String;
		FNew: Boolean;
		procedure WMMove(var message: TMessage); message WM_MOVE;
		procedure WMNCLButtonDown(var message: TMessage); message WM_NCLBUTTONDOWN;
		procedure WMNCRButtonDown(var message: TMessage); message WM_NCRBUTTONDOWN;
		procedure AddError(Info: String);
		procedure UpdateEncoding;
		procedure OpenError;
		procedure LineUpdateHandler(Sender: TObject; LineNumber: Integer);
		procedure ReportErrorHandler(Sender: TObject; LineNumber: Integer; ErrorText: String);
	public
		{ Public declarations }
		Modified: Boolean;
		procedure NewFile;
		function InternalCloseQuery: Boolean; override;
		procedure OpenFile(FileName: String);

		procedure SetConnectionName(Value: String);
		procedure SetDatabaseName(const Value: String); override;

		function CanInternalClose: Boolean; override;
		procedure DoInternalClose; override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

		function CanRefresh: Boolean; override;
		procedure DoRefresh; override;

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
		procedure DoSelectAll;  override;

		function CanViewPrevStatement: Boolean; override;
		procedure DoViewPrevStatement; override;

		function CanViewNextStatement: Boolean; override;
		procedure DoViewNextStatement; override;

		function CanStatementHistory: Boolean; override;
		procedure DoStatementHistory; override;

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

		function CanLoad: Boolean; override;
		procedure DoLoad; override;

		function CanLoadFrom: Boolean; override;
		procedure DoLoadFrom; override;

		function CanSave: Boolean; override;
		procedure DoSave; override;

		function CanSaveAs: Boolean; override;
		procedure DoSaveAs; override;

		function CanViewMessages: Boolean; override;
		function AreMessagesVisible : Boolean; override;
		procedure DoViewMessages; override;

		function CanChangeEncoding: Boolean; override;
		procedure DoChangeEncoding(Index: Integer); override;
		function IsEncoding(Index: Integer): Boolean; override;

		function CanClearBuffer: Boolean; override;
		procedure DoClearBuffer; override;

		function CanToggleBookmark(Index: Integer): Boolean; override;
		procedure DoToggleBookmark(Index: Integer); override;
		function IsBookmarkSet(Index: Integer): Boolean; override;

		function CanGotoBookmark(Index: Integer): Boolean; override;
		procedure DoGotoBookmark(Index: Integer); override;

		function CanShowQueryPlan: Boolean; override;
		function IsShowingQueryPlan: Boolean; override;
		procedure DoShowQueryPlan; override;

		function CanExecuteAsScript: Boolean; override;
		function IsExecuteAsScript: Boolean; override;
		procedure DoExecuteAsScript; override;

		function CanShowPerformanceData: Boolean; override;
		function IsShowingPerformanceData: Boolean; override;
		procedure DoShowPerformanceData; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;

		function CurrentConnection: String;

		property New : Boolean read FNew;
		property FileName: String read FFileName;

		//ToolsAPI
		procedure IDESetLines(Value: IGimbalIDELines); safecall;
		function IDEGetLines: IGimbalIDELines; safecall;

	end;

implementation

uses
	Globals,
	HelpMap,
	GSSRegistry,
	MarathonIDE,
	StatementHistory,
	ScriptExecutive,
	SaveFileFormat,
	BlobViewer,
	QBuilder;

{$R *.DFM}

procedure TfrmSQLForm.edSQLStatementChange(Sender: TObject);
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
	begin
		Modified := UpdateEditorStatusBar(stsSQLStatement, edSQLStatement);
		stsSQLStatement.Panels[3].Text := '      Editing Statement';
		imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_MOD');
	end
	else
	begin
		stsSQLStatement.Panels[0].Text := '';
    stsSQLStatement.Panels[1].Text := '';
		stsSQLStatement.Panels[2].Text := '';
  end;
end;

procedure TfrmSQLForm.lstResultsClick(Sender: TObject);
var
	Line: String;
	CharPos: Integer;
	FoundLine, FoundChar: Boolean;
	Parser: TTextParser;
	Tok: TToken;

begin
	if lstResults.ItemIndex <> -1 then
	begin
		edSQLStatement.ErrorLine := -1;

		CharPos := 0;

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
				begin
					try
						CharPos := StrToInt(Tok.TokenText);
						FoundChar := True;
					except

					end;
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
			edSQLStatement.ErrorLine := LinePos;
      edSQLStatement.CaretXY := BufferCoord(CharPos, LinePos);
      if pgSQLStatement.ActivePage.PageIndex = 0 then
        edSQLStatement.SetFocus;
    end;
	end;
end;

procedure TfrmSQLForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	It.Free;

	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_BASE, True) then
			begin
				WriteBool('ShowQueryPlan', FShowPlan);
				WriteBool('ShowPerformData', FShowPerformData);
				CloseKey;
			end;
		finally
			Free;
		end;

	Action := caFree;
	inherited;
end;

procedure TfrmSQLForm.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmSQLForm.FormCreate(Sender: TObject);
begin
	inherited;
	HelpContext := IDH_SQL_Editor;
//	qrySQLStatement.TrimStrings := False;

	FExecuteMode := exStatement;
	cmbMode.ItemIndex := 0;

	imgSuccess.Parent := stsSQLStatement;
	imgSuccess.Top := 5;
	imgSuccess.Left := 207;

	pgSQLStatement.ActivePage := tsSQLStatement;
	nbResults.ActivePage := nbpDatasheet;

	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_BASE, True) then
			begin
				if not ValueExists('ShowQueryPlan') then
					FShowPlan := False
				else
					FShowPlan := ReadBool('ShowQueryPlan');

				if not ValueExists('ShowPerformData') then
					FShowPerformData := False
				else
					FShowPerformData := ReadBool('ShowPerformData');
				CloseKey;
			end;
		finally
			Free;
		end;

	pnlBasePerformance.Visible := FShowPerformData;
	pnlNoPerform.Visible := not FShowPerformData;
	lblPerform.Caption := 'There is no performance data being collected. To collect and display data, check "Tools" - "Show Performance Query Data" in the Object Menu.';

	tsPlan.TabVisible := FShowPlan;

	edSQLStatement.Clear;

	It := TMenuItem.Create(Self);
	It.Caption := '&1 SQL Editor';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);

	FStmtIndex := 0;
	pnlMessages.Visible := False;
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;

  SetupSyntaxEditor(edSQLStatement);
  
  FCharSet := SetUpEncodingControl(edSQLStatement);
  FCharSet := SetUpEncodingControl(grdSQLStatement);
	FCharSet := SetUpEncodingControl(pnlResForm);

	FStmtIndex := MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1;
end;

procedure TfrmSQLForm.edSQLStateMentKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	edSQLStatement.ErrorLine := -1;

	if Key = VK_F1 then
		if edSQLStatement.Highlighter.IsKeyword(edSQLStatement.SelText) then
		begin
			DoKeySearch := True;
			Key := 0;
		end
		else
			DoKeySearch := False;

	// Handle notifier chain
	MarathonIDEInstance.ProcessKeyPressNotifierChain(Key, Shift);
end;

procedure TfrmSQLForm.FormCloseQuery(Sender: TObject;	var CanClose: Boolean);
begin
	if not FByPassClose then
		CanClose := InternalCloseQuery
	else
		CanCLose := True;
end;

procedure TfrmSQLForm.edSQLStatementDragOver(Sender, Source: TObject; X, Y: Integer;
	State: TDragState; var Accept: Boolean);
begin
	SetFocus;
	UpdateEditorStatusBar(stsSQLStatement, edSQLStatement);
	edSQLStatement.CaretXY := TBufferCoord(edSQLStatement.PixelsToRowColumn(X, Y));
	Accept := True;
end;

procedure TfrmSQLForm.edSQLStatementDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
	edSQLStatement.CaretXY := TBufferCoord(edSQLStatement.PixelsToRowColumn(X, Y));

	if Source is TDragQueen then
		edSQLStatement.SelText := TDragQueen(Source).DragText;
end;

procedure TfrmSQLForm.grdSQLStatementDblClick(Sender: TObject);
begin
	EditBlobColumn(grdSQLStatement.SelectedField);
end;

function TfrmSQLForm.FormHelp(Command: Word; Data: Integer;	var CallHelp: Boolean): Boolean;
begin
	Result := True;
	if DoKeySearch then
	begin
		if edSQLStatement.Highlighter.IsKeyword(edSQLStatement.SelText) then
		begin
			WinHelp(Handle, PChar(ExtractFilePath(Application.ExeName) + 'Help\SQLRef.hlp'), HELP_PARTIALKEY, Integer(PChar(edSQLStatement.SelText)));
			CallHelp := False;
		end
		else
			CallHelp := True;
	end
	else
		CallHelp := True;
end;

procedure TfrmSQLForm.tabResultsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
	nbResults.ActivePageIndex := NewTab;
end;

procedure TfrmSQLForm.AddError(Info: String);
begin
	OpenError;
  lstResults.Add(Info, 0, nil);
end;

procedure TfrmSQLForm.edSQLStatementGetHintText(Sender: TObject; Token: String; var HintText: String; HintType: THintType);
begin
  HintText := MarathonIDEInstance.GetHintTextForToken(Token, ConnectionName);
end;

procedure TfrmSQLForm.edSQLStatementNavigateHyperLinkClick(Sender: TObject;	Token: String);
begin
	MarathonIDEInstance.NavigateToLink(Token, ConnectionName);
end;

procedure TfrmSQLForm.OpenError;
begin
	pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
	pnlMessages.Visible := True;
	Refresh;
	stsSQLStatement.Top := Height;
end;

procedure TfrmSQLForm.UpdateEncoding;
begin
	edSQLStatement.Font.Charset := FCharSet;
	grdSQLStatement.Font.CharSet := FCharSet;
	pnlResForm.ControlFont.CharSet := FCharSet;
end;

procedure TfrmSQLForm.pgSQLStatementChange(Sender: TObject);
begin
  if pgSQLStatement.ActivePage = tsSQLStatement then
  begin
    edSQLStatementChange(edSQLStatement);
    edSQLStatement.SetFocus;
  end;

  if pgSQLStatement.ActivePage = tsResultsView then
  begin
    stsSQLStatement.Panels[0].Text := '';
    stsSQLStatement.Panels[1].Text := '';
    if qrySQLStatement.Active then
    begin
      if qrySQLStatement.CanModify then
        stsSQLStatement.Panels[2].Text := 'Live'
      else
        stsSQLStatement.Panels[2].Text := 'Read-Only';
    end
    else
      stsSQLStatement.Panels[2].Text := '';
    case gDefaultView of
			0:
				begin
				 nbResults.ActivePage := nbpDatasheet;
				 tabResults.TabIndex := gDefaultView;
				end;

			1:
				begin
					nbResults.ActivePage := nbpForm;
					tabResults.TabIndex := gDefaultView;
				end;
		end;
	end;

	if pgSQLStatement.ActivePage = tsPerformance then
	begin
		stsSQLStatement.Panels[0].Text := '';
		stsSQLStatement.Panels[1].Text := '';
		stsSQLStatement.Panels[2].Text := '';
	end;

	if pgSQLStatement.ActivePage = tsPlan then
	begin
		stsSQLStatement.Panels[0].Text := '';
		stsSQLStatement.Panels[1].Text := '';
		stsSQLStatement.Panels[2].Text := '';
	end;
end;

procedure TfrmSQLForm.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	cmbMode.Left := Self.ClientWidth - cmbMode.Width;
end;

procedure TfrmSQLForm.WMMove(var message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmSQLForm.WMNCLButtonDown(var message: TMessage);
begin
	inherited;
	edSQLStatement.CloseUpLists;
end;

procedure TfrmSQLForm.WMNCRButtonDown(var message: TMessage);
begin
  inherited;
  edSQLStatement.CloseUpLists;
end;

procedure TfrmSQLForm.qrySQLStatementAfterOpen(DataSet: TDataSet);
begin
	GlobalFormatFields(DataSet);
end;

procedure TfrmSQLForm.qrySQLStatementAfterPrepare(Sender: TObject);
begin
	inherited;
	FPrepareTime := GetTickCount - FPrepareTimeStart;
end;

procedure TfrmSQLForm.qrySQLStatementBeforePrepare(Sender: TObject);
begin
	inherited;
	FPrepareTime := 0;
	FPrepareTimeStart := GetTickCount;
end;

procedure TfrmSQLForm.actQueryBuilderExecute(Sender: TObject);
var
	B: TQBuilderDialog;

begin
	B := TQBuilderDialog.Create(Self);
	try
		B.OnGetTableColumns := MarathonIDEInstance.GetTableColumnsEvent;
		B.OnGetTables := MarathonIDEInstance.GetTablesEvent;
		B.SystemTables := False;
		if B.Execute then
			edSQLStatement.SelText := B.SQL.Text;
		B.OnGetTableColumns := nil;
		B.OnGetTables := nil;
	finally
		B.Free;
	end;
end;

procedure TfrmSQLForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgSQLStatement)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgSQLStatement);
end;

function TfrmSQLForm.CanInternalClose: Boolean;
begin
	Result := True;
end;

function TfrmSQLForm.CanPrint: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;

	if pgSQLStatement.ActivePage = tsResultsView then
		Result := not (qrySQLStatement.EOF and qrySQLStatement.BOF);

	if pgSQLStatement.ActivePage = tsPerformance then
		Result := FShowPerformData;

	if pgSQLStatement.ActivePage = tsPlan then
		Result := FShowPlan;
end;

function TfrmSQLForm.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

procedure TfrmSQLForm.DoInternalClose;
begin
	inherited;
	Close;
end;

procedure TfrmSQLForm.DoPrint;
var
	M: TMetafileCanvas;
	MF: TMetafile;

begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		MarathonIDEInstance.PrintSyntaxMemo(edSQLStatement, False, FFileName);

	if pgSQLStatement.ActivePage = tsResultsView then
		MarathonIDEInstance.PrintDataSet(qrySQLStatement, False, FFileName);

	if pgSQLStatement.ActivePage = tsPerformance then
		MarathonIDEInstance.PrintPerformanceAnalysis(False, edSQLStatement.Lines, dtaPerform, chtPerform);

	if pgSQLStatement.ActivePage = tsPlan then
	begin
		MF := TMetafile.Create;
		try
			M := TMetafileCanvas.Create(MF, dtPlan.DVCanvas.Canvas.Handle);
			try
				dtPlan.PaintToCanvas(M);
			finally
				M.Free;
			end;
			MarathonIDEInstance.PrintQueryPlan(False, edSQLStatement.Lines, edPlan.Text, MF);
		finally
			MF.Free;
		end;
	end;
end;

procedure TfrmSQLForm.DoPrintPreview;
var
	M: TMetafileCanvas;
	MF: TMetafile;

begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		MarathonIDEInstance.PrintSyntaxMemo(edSQLStatement, True, FFileName);

	if pgSQLStatement.ActivePage = tsResultsView then
		MarathonIDEInstance.PrintDataSet(qrySQLStatement, True, FFileName);

	if pgSQLStatement.ActivePage = tsPerformance then
		MarathonIDEInstance.PrintPerformanceAnalysis(True, edSQLStatement.Lines, dtaPerform, chtPerform);

	if pgSQLStatement.ActivePage = tsPlan then
	begin
		MF := TMetafile.Create;
		try
			M := TMetafileCanvas.Create(MF, dtPlan.DVCanvas.Canvas.Handle);
			try
				dtPlan.PaintToCanvas(M);
			finally
				M.Free;
			end;
			MarathonIDEInstance.PrintQueryPlan(True, edSQLStatement.Lines, edPlan.Text, MF);
		finally
			MF.Free;
		end;
	end;
end;

procedure TfrmSQLForm.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		cmbMode.Enabled := False;
		transSQLStatement.IB_Connection := nil;
		qryScript.IB_Connection := nil;
		qrySQLStatement.IB_Connection := nil;
		qryUtil.IB_Connection := nil;
		perfSQL.IB_Connection := nil;
		IsInterbase6 := False;
		SQLDialect := 0;
		stsSQLStatement.Panels[4].Text := 'No Connection';
	end
	else
	begin
		cmbMode.Enabled := True;
		transSQLStatement.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qrySQLStatement.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		perfSQL.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qrySQLStatement.IB_Transaction := transSQLStatement;
		qryScript.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryScript.IB_Transaction := transSQLStatement;
		qryUtil.IB_Transaction := transSQLStatement;
		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qrySQLStatement.IB_Connection.SQLDialect;
		stsSQLStatement.Panels[4].Text := Value;
	end;
end;

function TfrmSQLForm.CanCaptureSnippet: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := Length(edSQLStatement.SelText) > 0;
end;

function TfrmSQLForm.CanChangeEncoding: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := True;

	if pgSQLStatement.ActivePage = tsResultsView then
		Result := True;
end;

function TfrmSQLForm.CanClearBuffer: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

function TfrmSQLForm.CanCopy: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		if lstResults.Focused then
			Result := lstResults.ItemIndex > -1
		else
			Result := Length(edSQLStatement.SelText) > 0;

	if pgSQLStatement.ActivePage = tsPlan then
		Result := edPlan.SelLength > 0;
end;

function TfrmSQLForm.CanCut: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := Length(edSQLStatement.SelText) > 0;
end;

function TfrmSQLForm.CanExecute: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := (edSQLStatement.Lines.Count > 0) and (ConnectionName <> '');
end;

function TfrmSQLForm.CanFind: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

function TfrmSQLForm.CanFindNext: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

function TfrmSQLForm.CanGotoBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := IsBookmarkSet(Index);
end;

function TfrmSQLForm.CanPaste: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := Clipboard.HasFormat(CF_TEXT);
end;

function TfrmSQLForm.CanRedo: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.CanUndo;
end;

function TfrmSQLForm.CanRefresh: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsResultsView then
		Result := True;
end;

function TfrmSQLForm.CanSave: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := Modified;
end;

function TfrmSQLForm.CanSaveAs: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := True;
end;

function TfrmSQLForm.CanLoadFrom: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := True;
end;

function TfrmSQLForm.CanSelectAll: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

function TfrmSQLForm.CanStatementHistory: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := MarathonIDEInstance.CurrentProject.SQLHistory.Count > 0;
end;

function TfrmSQLForm.CanToggleBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

function TfrmSQLForm.CanTransactionCommit: Boolean;
begin
	Result := qrySQLStatement.IB_Transaction.Started;
end;

function TfrmSQLForm.CanTransactionRollback: Boolean;
begin
	Result := qrySQLStatement.IB_Transaction.Started;
end;

function TfrmSQLForm.CanUndo: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.CanUndo;
end;

function TfrmSQLForm.CanViewMessages: Boolean;
begin
	Result := True;
end;

function TfrmSQLForm.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmSQLForm.CanViewNextStatement: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := FStmtIndex < MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1;
end;

function TfrmSQLForm.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

function TfrmSQLForm.CanViewPrevStatement: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := FStmtIndex > 0;
end;

procedure TfrmSQLForm.DoCaptureSnippet;
begin
	CaptureCodeSnippet(edSQLStatement);
end;

procedure TfrmSQLForm.DoChangeEncoding(Index: Integer);
begin
	FCharSet := GetCharSetByIndex(Index);
	UpdateEncoding;
end;

procedure TfrmSQLForm.DoClearBuffer;
begin
	edSQLStatement.Clear;
	edSQLStatement.OnChange(edSQLStatement);
end;

procedure TfrmSQLForm.DoCopy;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		if lstResults.Focused then
			Clipboard.AsText := lstResults.Collection[lstResults.ItemIndex].TextData.Text
		else
			edSQLStatement.CopyToClipboard;

	if pgSQLStatement.ActivePage = tsPlan then
		edPlan.CopyToClipboard;
end;

procedure TfrmSQLForm.DoCut;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.CutToClipboard;
end;

procedure TfrmSQLForm.LineUpdateHandler(Sender : TObject; LineNumber : Integer);
begin
	edSQLStatement.ErrorLine := LineNumber;
	edSQLStatement.CaretXY := BufferCoord(1, LineNumber);
	Refresh;
end;

procedure TfrmSQLForm.ReportErrorHandler(Sender : TObject; LineNumber : Integer; ErrorText : String);
begin
	AddError(ErrorText);
end;

procedure TfrmSQLForm.DoExecute;
var
	Items: TPerformItems;
	Idx, DelCount: Integer;
	Found: Boolean;
	ISQLObj: TIBSQLObj;
	PlanParser: TSQLParser;
  nRecords: Integer;

begin
	try
		if FExecuteMode = exScript then
		begin
			pnlMessages.Visible := False;
			Refresh;
			lstResults.Collection.Clear;

			ISQLObj := TIBSqlObj.Create (Self);
			try
				try
					with ISQLObj do
					begin
						SkipCreateConnect := True;
						AutoDDL := True;
						Query := edSQLStatement.Lines;
						Database := qryScript.IB_COnnection;
						Transaction := transSQLStatement;
						SQLQuery := qryScript;
						OnLineUpdate := LineUpdateHandler;
						OnReportError := ReportErrorHandler;
						Cursor := crSQLWait;
						DoIsql;
						Cursor := crDefault;
					end;
				except
					on E : Exception do
					begin
						Cursor := crDefault;
						AddError(E.message);
					end;
				end;
			finally
				ISQLObj.Free;
			end;

		end
		else
		begin
			if FShowPerformData then
			begin
				pnlBasePerformance.Visible := True;
				pnlNoPerform.Visible := False;
				if not perfSQL.Initialised then
				begin
					stsSQLStatement.Panels[2].Text := 'Initialising Performance Monitor - Please wait...';
					perfSQL.ShowSystemTables := gShowSystemInPerformance;
					perfSQL.Initialise;
				end;
			end
			else
			begin
				pnlBasePerformance.Visible := False;
				pnlNoPerform.Visible := True;
				lblPerform.Caption := 'There is no performace data being collected. To collect and display data, check "Tools" - "Show Performance Query Data" in the Object Menu.';
			end;

			edSQLStatement.ErrorLine := -1;
			edPlan.Text := '';
			qrySQLStatement.BeginBusy(False);
			Screen.Cursor := crDefault;
			stsSQLStatement.Panels[2].Text := 'Executing Statement - Please wait...';
			Refresh;
			pgSQLStatement.ActivePage := tsSQLStatement;
			Refresh;
			pnlMessages.Visible := False;
			Refresh;
			lstResults.Collection.Clear;
			try
				if FShowPerformData then
					FStartMemory := perfSQL.ReadCurrentMemory;

				qrySQLStatement.Close;
				qrySQLStatement.SQL.Clear;
				if edSQLStatement.SelText <> '' then
					qrySQLStatement.SQL.Text := edSQLStatement.SelText
				else
					qrySQLStatement.SQL.Text := edSQLStatement.Text;

				try
					qrySQLStatement.Prepare;
				except
					on E : Exception do
					begin
						// nothing...
					end;
				end;

				case qrySQLStatement.StatementType of
					stSelect, stSelectForUpdate:
						begin
							qrySQLStatement.RequestLive := True;
							qrySQLStatement.Open;
							pgSQLStatement.ActivePage := tsResultsView;
							pgSQLStatementChange(pgSQLStatement);
							stsSQLStatement.Panels[3].Text := '      Statement Execution Successful';
							imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_OK');
						end;
				else
					begin
						qrySQLStatement.RequestLive := False;
						qrySQLStatement.ExecSQL;
						MarathonIDEInstance.RecordToScript(qrySQLStatement.SQL.Text, GetActiveConnectionName);
						stsSQLStatement.Panels[3].Text := '      Statement Execution Successful';
						imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_OK');
					end;
				end;

				if FShowPerformData then
				begin
					// Do a fetch all
					if qrySQLStatement.Active then
					begin
						qrySQLStatement.DisableControls;
						try
							qrySQLStatement.FetchAll;
							if not qrySQLStatement.InternalDataset.FetchingAborted then
								qrySQLStatement.First;
						finally
							qrySQLStatement.EnableControls;
						end;
					end;

					if not qrySQLStatement.InternalDataset.FetchingAborted then
					begin
						Series1.Clear;

						// Index reads
						Items := perfSQL.ReadIdxCount;
						for Idx := 0 to Items.Count - 1 do
							if Items.Items[Idx].Value.Data <> 0 then
								with Series1 do
									Add(Items.Items[Idx].Value.Data, Items.Items[Idx].Metric, clGreen);

						// Sequential reads
						Items := perfSQL.ReadSeqCount;
						for Idx := 0 to Items.Count - 1 do
							if Items.Items[Idx].Value.Data <> 0 then
								with Series1 do
									Add(Items.Items[Idx].Value.Data, Items.Items[Idx].Metric , clRed);

						// Fill the memory dataset
						dtaPerform.Close;
						dtaPerform.Open;
						case qrySQLStatement.StatementType of
							stSelect, stSelectForUpdate:
								begin
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Prepare Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(FPrepareTime) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Fetch Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(GetTickCount - qrySQLStatement.CallbackInitTick) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Avg Fetch Time';
                  nRecords := qrySQLStatement.RecordCount;  //AC:
                  if nRecords = 0 then nRecords := 1; //AC:
									dtaPerform.FieldByName('value').AsString := FormatFloat('####0.00', (GetTickCount - qrySQLStatement.CallbackInitTick) / nRecords) + ' ms';  //AC:
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Rows Processed';
									dtaPerform.FieldByName('value').AsString := IntToStr(qrySQLStatement.RecordCount);
									dtaPerform.Post;
								end;
							stUpdate, stDelete:
								begin
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Prepare Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(FPrepareTime) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Fetch Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(GetTickCount - qrySQLStatement.CallbackInitTick) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Rows Processed';
									dtaPerform.FieldByName('value').AsString := IntToStr(qrySQLStatement.RowsAffected);
									dtaPerform.Post;
								end;
						end;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Start Memory';
						dtaPerform.FieldByName('value').AsString := IntToStr(FStartMemory) + ' bytes';
						dtaPerform.Post;
						FCurrentMemory := perfSQL.ReadCurrentMemory;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Current Memory';
						dtaPerform.FieldByName('value').AsString := IntToStr(FCurrentMemory) + ' bytes';
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Delta Memory';
						dtaPerform.FieldByName('value').AsString := IntToStr(FCurrentMemory - FStartMemory) + ' bytes';
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Buffers';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadNumBuffers) + ' buffers';
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Reads';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadReadCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Writes';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadWriteCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Marks';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadMarksCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Fetches';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadFetchesCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Inserts';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadInsertCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Deletes';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadDeleteCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Updates';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadUpdateCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Backouts';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadBackoutCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Purges';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadPurgeCount.Data);
						dtaPerform.Post;
						dtaPerform.Append;
						dtaPerform.FieldByName('item').AsString := 'Expunges';
						dtaPerform.FieldByName('value').AsString := IntToStr(perfSQL.ReadExpungeCount.Data);
						dtaPerform.Post;
					end
					else
					begin
						pnlBasePerformance.Visible := False;
						pnlNoPerform.Visible := True;
						lblPerform.Caption := 'There is no performace data being displayed because the query fetching was cancelled.';
					end;
				end;

				Found := False;
				for Idx := 0 to MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1 do
				begin
					if edSQLStatement.SelText <> '' then
					begin
						if MarathonIDEInstance.CurrentProject.SQLHistory.Items[Idx].SQLText.Text = edSQLStatement.SelText then
						begin
							Found := True;
							FStmtIndex := Idx;
							Break;
						end;
					end
					else
						if MarathonIDEInstance.CurrentProject.SQLHistory.Items[Idx].SQLText.Text = edSQLStatement.Text then
						begin
							Found := True;
							FStmtIndex := Idx;
							Break;
						end;
				end;
				if not Found then
				begin
					if MarathonIDEInstance.CurrentProject.SQLHistory.Count > MarathonIDEInstance.CurrentProject.NumHistory then
					begin
						DelCount := MarathonIDEInstance.CurrentProject.SQLHistory.Count - MarathonIDEInstance.CurrentProject.NumHistory;
						for Idx := 1 to DelCount + 1 do
							MarathonIDEInstance.CurrentProject.SQLHistory.Items[0].Free;
					end;
					if edSQLStatement.SelText <> '' then
					begin
						with MarathonIDEInstance.CurrentProject.SQLHistory.Add do
							SQLText.Text := edSQLStatement.SelText;
					end
					else
						with MarathonIDEInstance.CurrentProject.SQLHistory.Add do
							SQLText.Text := edSQLStatement.Text;

					FStmtIndex := MarathonIDEInstance.CurrentProject.SQLHistory.Count;
				end;

				if qrySQLStatement.CanModify then
				begin
					stsSQLStatement.Panels[2].Text := 'Live';
					Refresh;
				end
				else
				begin
					stsSQLStatement.Panels[2].Text := 'Read-Only';
					Refresh;
				end;

				if FShowPlan and (qrySQLStatement.StatementType in [stSelect, stSelectForUpdate, stUpdate, stDelete]) and (qrySQLStatement.Plan <> '') then
				begin
					edPlan.Text := qrySQLStatement.Plan;
					PlanParser := TSQLParser.Create(Self);
					try
						PlanParser.ParserType := ptPlan;
						PlanParser.Lexer.yyinput.Text := edPlan.Text;
						PlanParser.Lexer.IsInterbase6 := FIsInterbase6;
						PlanParser.Lexer.SQLDialect := FSQLDialect;
						if PlanParser.yyparse = 0 then
						begin
							PlanParser.PlanObject.FillTree(dtPlan);
						end;
					finally
						PlanParser.Free;
					end;
				end
				else
					dtPlan.Clear;

			except
				On E : Exception do
				begin
					stsSQLStatement.Panels[3].Text := '      Statement Execution Failed';
					imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_FAIL');
					pnlMessages.Visible := True;
					Refresh;
					stsSQLStatement.Top := Height;
					if E is EIB_ISCError then
						AddError(EIB_ISCError(E).message)
					else
						AddError(E.message);
					lstResultsClick(lstResults);
				end;
			end;
		end;
	finally
		Screen.Cursor := crDefault;
		qrySQLStatement.EndBusy;
	end;
end;

procedure TfrmSQLForm.DoFind;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.WSFind;
end;

procedure TfrmSQLForm.DoFindNext;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.WSFindNext;
end;

procedure TfrmSQLForm.DoGotoBookmark(Index: Integer);
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.GotoBookmark(Index);
end;

procedure TfrmSQLForm.DoPaste;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.PasteFromClipboard;
end;

procedure TfrmSQLForm.DoRedo;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.Redo;
end;

procedure TfrmSQLForm.DoRefresh;
begin
	if pgSQLStatement.ActivePage = tsResultsView then
	begin
		qrySQLStatement.Close;
		qrySQLStatement.Open;
	end;
end;

function TfrmSQLForm.CanLoad: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := True;
end;

procedure TfrmSQLForm.DoLoad;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		if FNew then
			DoLoadFrom
		else
		begin
			if LoadEditorContent(edSQLStatement, FFileName) then
			begin
				Modified := False;
				InternalCaption := 'SQL Editor - [' + ExtractFileName(FFileName) + ']';
				IT.Caption := Caption;
				FNew := False;
				edSQLStatement.Modified := False;
				edSQLStatementChange(nil);
			end;
		end;
end;

procedure TfrmSQLForm.DoLoadFrom;
begin
	if dlgOpen.Execute then
	begin
		FFileName := dlgOpen.FileName;
		FNew := False;
		DoLoad;
	end;
end;

procedure TfrmSQLForm.DoSave;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		if FNew then
			DoSaveAs
		else
		begin
			if SaveEditorContent(edSQLStatement, FFileName) then
			begin
				Modified := False;
				InternalCaption := 'SQL Editor - [' + ExtractFileName(FFileName) + ']';
				IT.Caption := Caption;
				FNew := False;
				edSQLStatement.Modified := False;
				edSQLStatementChange(nil);
			end;
		end;
end;

procedure TfrmSQLForm.DoSaveAs;
begin
	if dlgSave.Execute then
	begin
		FFileName := dlgSave.FileName;
		FNew := False;
		DoSave;
	end;
end;

procedure TfrmSQLForm.DoSelectAll;
begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.SelectAll;
end;

procedure TfrmSQLForm.DoStatementHistory;
var
	Idx: Integer;
	F: TfrmStatementHistory;

begin
	F := TfrmStatementHistory.Create(Self);
	try
		for Idx := 0 to MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1 do
			F.lvHistory.Add(ConvertTabs(MarathonIDEInstance.CurrentProject.SQLHistory.Items[Idx].SQLText.Text, edSQLStatement), 0, nil);
		if F.ShowModal = mrOK then
		begin
			FStmtIndex := F.lvHistory.ItemIndex;
			edSQLStatement.Text := F.lvHistory.Collection.Items[F.lvHistory.ItemIndex].TextData.Text;
			edSQLStatement.SetFocus;
		end;
	finally
		F.Free;
	end;
end;

procedure TfrmSQLForm.DoToggleBookmark(Index: Integer);
begin
	GlobalSetBookmark(edSQLStatement, Index);
end;

procedure TfrmSQLForm.DOTransactionCommit;
begin
	case pgSQLStatement.ActivePage.PageIndex of
		0:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						if qrySQLStatement.State in [dsEdit, dsInsert] then
							qrySQLStatement.Post;

						qrySQLStatement.Close;
						transSQLStatement.Commit;
					end;
				end
				else
				begin
					if qrySQLStatement.State in [dsEdit, dsInsert] then
						qrySQLStatement.Post;

					qrySQLStatement.Close;
					transSQLStatement.Commit;
				end;
			end;
		1:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Commit Work - (Note: Committing will also close the result set)?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						if qrySQLStatement.State in [dsEdit, dsInsert] then
							qrySQLStatement.Post;

						qrySQLStatement.Close;
						transSQLStatement.Commit;
						pgSQLStatement.ActivePage := tsSQLStatement;
					end;
				end
				else
				begin
					if qrySQLStatement.State in [dsEdit, dsInsert] then
						qrySQLStatement.Post;

					qrySQLStatement.Close;
					transSQLStatement.Commit;
					pgSQLStatement.ActivePage := tsSQLStatement;
				end;
			end;
		2:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						if qrySQLStatement.State in [dsEdit, dsInsert] then
							qrySQLStatement.Post;

						qrySQLStatement.Close;
						transSQLStatement.Commit;
					end;
				end
				else
				begin
					if qrySQLStatement.State in [dsEdit, dsInsert] then
						qrySQLStatement.Post;

					qrySQLStatement.Close;
					transSQLStatement.Commit;
				end;
			end;
		3:
			begin
				if gPromptTrans then
				begin
					if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
					begin
						if qrySQLStatement.State in [dsEdit, dsInsert] then
							qrySQLStatement.Post;

						qrySQLStatement.Close;
						transSQLStatement.Commit;
					end;
				end
				else
				begin
					if qrySQLStatement.State in [dsEdit, dsInsert] then
						qrySQLStatement.Post;

					qrySQLStatement.Close;
					transSQLStatement.Commit;
				end;
			end;
  end;
end;

procedure TfrmSQLForm.DoTransactionRollback;
begin
  case pgSQLStatement.ActivePage.PageIndex of
    0:
			begin
        if gPromptTrans then
        begin
          if MessageDlg('Rollback Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            if qrySQLStatement.State in [dsEdit, dsInsert] then
              qrySQLStatement.Cancel;

            qrySQLStatement.Close;
            transSQLStatement.Rollback;
          end;
        end
        else
        begin
          if qrySQLStatement.State in [dsEdit, dsInsert] then
            qrySQLStatement.Cancel;

					qrySQLStatement.Close;
          transSQLStatement.Rollback;
        end;
      end;
    1:
      begin
        if gPromptTrans then
        begin
          if MessageDlg('Rollback Work - (Note: Rolling Back will also close the result set)?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            if qrySQLStatement.State in [dsEdit, dsInsert] then
              qrySQLStatement.Cancel;

            qrySQLStatement.Close;
						transSQLStatement.Rollback;
            pgSQLStatement.ActivePage := tsSQLStatement;
          end;
        end
        else
        begin
          if qrySQLStatement.State in [dsEdit, dsInsert] then
            qrySQLStatement.Cancel;

          qrySQLStatement.Close;
          transSQLStatement.Rollback;
          pgSQLStatement.ActivePage := tsSQLStatement;
        end;
      end;
    2:
      begin
        if gPromptTrans then
        begin
          if MessageDlg('Rollback Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            if qrySQLStatement.State in [dsEdit, dsInsert] then
              qrySQLStatement.Cancel;

            qrySQLStatement.Close;
            transSQLStatement.Rollback;
					end;
        end
        else
        begin
          if qrySQLStatement.State in [dsEdit, dsInsert] then
            qrySQLStatement.Cancel;

          qrySQLStatement.Close;
          transSQLStatement.Rollback;
        end;
      end;
    3:
      begin
        if gPromptTrans then
				begin
          if MessageDlg('Rollback Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            if qrySQLStatement.State in [dsEdit, dsInsert] then
              qrySQLStatement.Cancel;

            qrySQLStatement.Close;
            transSQLStatement.Rollback;
					end;
        end
        else
        begin
          if qrySQLStatement.State in [dsEdit, dsInsert] then
            qrySQLStatement.Cancel;

          qrySQLStatement.Close;
          transSQLStatement.Rollback;
        end;
      end;
  end;
end;

procedure TfrmSQLForm.DoUndo;
begin
  if pgSQLStatement.ActivePage = tsSQLStatement then
		edSQLStatement.Undo;
end;

procedure TfrmSQLForm.DoViewMessages;
begin
	pnlMessages.Visible := not pnlMessages.Visible;
	if pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		stsSQLStatement.Top := Height;
	end;
end;

procedure TfrmSQLForm.DoViewNextPage;
begin
	pgSQLStatement.SelectNextPage(True);
end;

procedure TfrmSQLForm.DoViewNextStatement;
begin
	if MarathonIDEInstance.CurrentProject.SQLHistory.Count > 0 then
	begin
		FStmtIndex := FStmtIndex + 1;
		if FStmtIndex > MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1 then
			FStmtIndex := MarathonIDEInstance.CurrentProject.SQLHistory.Count - 1;
		edSQLStatement.Text := MarathonIDEInstance.CurrentProject.SQLHistory.Items[FStmtIndex].SQLText.Text;
	end;
end;

procedure TfrmSQLForm.DoViewPrevPage;
begin
	pgSQLStatement.SelectNextPage(False);
end;

procedure TfrmSQLForm.DoViewPrevStatement;
begin
	if MarathonIDEInstance.CurrentProject.SQLHistory.Count > 0 then
	begin
		FStmtIndex := FStmtIndex - 1;
		if FStmtIndex < 0 then
			FStmtIndex := 0;
		edSQLStatement.Text := MarathonIDEInstance.CurrentProject.SQLHistory.Items[FStmtIndex].SQLText.Text;
	end;
end;

procedure TfrmSQLForm.EnvironmentOptionsRefresh;
begin
	SetupSyntaxEditor(edSQLStatement);
	SetUpEncodingControl(grdSQLStatement);
	SetUpEncodingControl(pnlResForm);
	GlobalFormatFields(qrySQLStatement);
end;

function TfrmSQLForm.IsBookmarkSet(Index: Integer): Boolean;
begin
	Result := IsABookmarkSet(edSQLStatement, Index);
end;

function TfrmSQLForm.IsEncoding(Index: Integer): Boolean;
begin
	Result := FCharSet = GetCharSetByIndex(Index);
end;

procedure TfrmSQLForm.ProjectOptionsRefresh;
begin
  inherited;

end;

function TfrmSQLForm.CanShowPerformanceData: Boolean;
begin
  Result := True;
end;

function TfrmSQLForm.CanShowQueryPlan: Boolean;
begin
  Result := True;
end;

procedure TfrmSQLForm.DoShowPerformanceData;
begin
	FShowPerformData := not FShowPerformData;
end;

procedure TfrmSQLForm.DoShowQueryPlan;
begin
	FShowPlan := not FShowPlan;
	edPlan.Text := '';
	tsPlan.TabVisible := FShowPlan;
end;

function TfrmSQLForm.IsShowingPerformanceData: Boolean;
begin
	Result := FSHowPerformData;
end;

function TfrmSQLForm.IsShowingQueryPlan: Boolean;
begin
  Result := FShowPlan;
end;

function TfrmSQLForm.CurrentConnection: String;
begin
  Result := ConnectionName;
end;

procedure TfrmSQLForm.SetConnectionName(Value: String);
begin
	ConnectionName := Value;
end;

procedure TfrmSQLForm.NewFile;
begin
	FFileName := MarathonIDEInstance.GetNewFileName;
	FNew := True;
	InternalCaption := 'SQL Editor - [' + ExtractFileName(FFileName) + ']';
	IT.Caption := Caption;
end;

function TfrmSQLForm.InternalCloseQuery: Boolean;
begin
	Result := True;
	if not FCLoseQueried then
	begin
		if transSQLStatement.Started then
		begin
			if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
			begin
				if qrySQLStatement.State in [dsEdit, dsInsert] then
					qrySQLStatement.Post;

				qrySQLStatement.Close;
				transSQLStatement.Commit;
			end
			else
			begin
				if qrySQLStatement.State in [dsEdit, dsInsert] then
					qrySQLStatement.Cancel;

				qrySQLStatement.Close;
				transSQLStatement.Rollback;
			end;
		end;

		if FNew then
		begin
			if gSQLSave then
			begin
				case MessageDlg('"' + FFileName + '" has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
					mrCancel :
						begin
							Result := False;
						end;
					mrYes :
						begin
							if dlgSave.Execute then
							begin
								Result := SaveEditorContent(edSQLStatement, dlgSave.FileName);
								Modified := False;
								FNew := False;
							end
							else
								Result := True;
						end;
					mrNo :
						begin
							Result := True;
							Modified := False;
						end;
				end;
			end
			else
			begin
				Result := True;
				Modified := False;
			end;
			FCloseQueried := True;
		end
		else
		begin
			if Modified then
			begin
				case MessageDlg('"' + FFileName + '" has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
					mrCancel :
						begin
							Result := False;
						end;
					mrYes :
						begin
							if dlgSave.Execute then
							begin
								Result := SaveEditorContent(edSQLStatement, dlgSave.FileName);
								Modified := False;
								FNew := False;
							end
							else
								Result := True;
						end;
					mrNo :
						begin
							Result := True;
							Modified := False;
						end;
				end;
				FCloseQueried := True;
			end
      else
        Result := True;
    end;
  end
  else
    Result := True;
end;

procedure TfrmSQLForm.OpenFile(FileName: String);
begin
	edSQLStatement.Lines.LoadFromFile(FileName);
	FFIleName := FileName;
	Modified := False;
	InternalCaption := 'SQL Editor - [' + ExtractFileName(FFileName) + ']';
	IT.Caption := Caption;
	FNew := False;
	edSQLStatement.Modified := False;
end;

function TfrmSQLForm.CanExport: Boolean;
begin
	Result := (pgSQLStatement.ActivePage = tsResultsView) and (not (qrySQLStatement.EOF and qrySQLStatement.BOF));
end;

procedure TfrmSQLForm.DoExport;
var
	Idx: Integer;
	FName, TableName: String;
	F: TfrmSaveFileFormat;
	FList: TStringList;
	Ex: TExportType;

begin
	inherited;
	F := TfrmSaveFileFormat.Create(Self);
	try
			for idx := 0 to qrySQLStatement.Fields.Count - 1 do
				  f.chklistColumns.Items.Add(qrySQLStatement.Fields[idx].FieldName);

			// Default all to true
			for Idx := 0 to f.chkListColumns.Items.Count - 1 do
				  f.chkListColumns.Checked[Idx] := True;

			if f.ShowModal = mrOK then
			begin
				Ex.ExType := f.cmbFormat.ItemIndex;
				Ex.FirstRowNames := f.chkFirstRow.Checked;
				Ex.InsertColumnNames := f.chkInsColNames.Checked;
				Ex.InsertColumnNamesSep := f.chkInsColNamesSep.Checked;
				TableName := f.edTable.Text;
				case f.cmbSep.ItemIndex of
					0:
						Ex.SepChar := ',';
					1:
						Ex.SepChar := #9;
					2:
						Ex.SepChar := '^';
					3:
						Ex.SepChar := '~';
				end;

				case f.cmbQual.ItemIndex of
					0:
						Ex.QualChar := '"';
					1:
						Ex.QualChar := '''';
					2:
						Ex.QualChar := '';
				end;

				FList := TStringList.Create;
				try
					for Idx := 0 to f.chkListColumns.Items.Count - 1 do
						if f.chkListColumns.Checked[Idx] then
							FList.Add(f.chkListColumns.Items[Idx]);
					f.chkListColumns.ItemIndex := 0;

					FName := F.edFileName.Text;

					ExportGrid(Ex, qrySQLStatement, FList, TableName, FName);
				finally
					FList.Free;
				end;
			end;
	finally
		F.Free;
	end;
end;

function TfrmSQLForm.AreMessagesVisible: Boolean;
begin
	Result := pnlMessages.Visible;
end;

procedure TfrmSQLForm.pnlMessagesResize(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.CurrentProject.ResultsPanelHeight := pnlMessages.Height;
	stsSQLStatement.Top := Height;
end;

function TfrmSQLForm.CanReplace: Boolean;
begin
	Result := False;
	if pgSQLStatement.ActivePage = tsSQLStatement then
		Result := edSQLStatement.Lines.Count > 0;
end;

procedure TfrmSQLForm.DoReplace;
begin
	inherited;
	edSQLStatement.WSReplace;
end;

procedure TfrmSQLForm.cmbModeChange(Sender: TObject);
begin
	inherited;
	case cmbMode.ItemIndex of
		0:
			FExecuteMode := exStatement;
		1:
			FExecuteMode := exScript;
	end;
end;

function TfrmSQLForm.CanExecuteAsScript: Boolean;
begin
	Result := (pgSQLStatement.ActivePage = tsSQLStatement) and (FDatabaseName <> '');
end;

procedure TfrmSQLForm.DoExecuteAsScript;
begin
	if FExecuteMode = exStatement then
	begin
		FExecuteMode := exScript;
		cmbMode.ItemIndex := 1;
	end
	else
	begin
		FExecuteMode := exStatement;
		cmbMode.ItemIndex := 0;
	end;
end;

function TfrmSQLForm.IsExecuteAsScript: Boolean;
begin
	Result := FExecuteMode = exScript;
end;

procedure TfrmSQLForm.edSQLStatementStatusChange(Sender: TObject;	Changes: TSynStatusChanges);
begin
	inherited;
	edSQLStatementChange(Sender);
end;

procedure TfrmSQLForm.rmTabSet1Change(Sender: TObject; NewTab: Integer;	var AllowChange: Boolean);
begin
	inherited;
	nbPerform.ActivePageIndex := NewTab;
end;

function TfrmSQLForm.IDEGetLines: IGimbalIDELines;
begin
	Result := nil;
end;

procedure TfrmSQLForm.IDESetLines(Value: IGimbalIDELines);
begin

end;

procedure TfrmSQLForm.FormShow(Sender: TObject);
begin
  inherited;
  ActiveControl := edSQLStatement;
end;

end.


