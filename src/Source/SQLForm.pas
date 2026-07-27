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
TIBQuery.FetchAll instead of TIBQuery.Last, this should also display the fetch dialog

Revision 1.5  2002/05/15 08:54:09  tmuetze
Fixed some IBPerformanceMonitor and SQLForm statistic related issues

Revision 1.4  2002/05/14 07:14:56  tmuetze
Readded the PrepareTime, FetchTime performance values, but some more testing is needed

Revision 1.3  2002/05/06 14:27:49  tmuetze
Converted from TIBGSSDataset to TIBQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit SQLForm;

{$MODE Delphi}

interface

uses {$IFDEF FPC} {$IFDEF WINDOWS}Windows,{$ENDIF} LCLIntf, LCLType, LMessages, Messages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, ExtCtrls, DB, Menus, Grids, DBGrids, Buttons, Registry, ClipBrd, ToolWin, Printers, DBCtrls, TASeries, TAGraph, ActnList, ImgList, BufDataset, IBDatabase, IBQuery, IB, SingletonQuery, SQLStatementText, SynEdit, SynEditTypes, SyntaxMemoWithStuff2, adbpedit, BaseDocumentForm, BaseDocumentDataAwareForm, MarathonInternalInterfaces, GimbalToolsAPI, PlanUnit, IBPerformanceMonitor, DiagramTree, rmCompatControls, SynCompletion, SQLCompletion, FirebirdKeywords;

type
	TExecuteMode = (exStatement, exScript);

	TfrmSQLForm = class(TfrmBaseDocumentDataAwareForm, IMarathonSQLForm, IGimbalIDESQLTextEditor)
		stsSQLStatement: TStatusBar;
		dsSQLStatement: TDataSource;
		pnlEnvironment: TPanel;
		lblConnectionCaption: TLabel;
		lblEnvironmentName: TLabel;
		cmbConnection: TComboBox;
		dlgSave: TSaveDialog;
    qrySQLStatement: TIBQuery;
    qryUtil: TIBQuery;
    pnlBase: TPanel;
    pgSQLStatement: TPageControl;
    tsSQLStatement: TTabSheet;
    edSQLStatement: TSyntaxMemoWithStuff2;
    tsResultsView: TTabSheet;
    nbResults: TrmNoteBookControl;
    tabResults: TrmTabSet;
    grdSQLStatement: TDBGrid;
    pnlResForm: TDBPanelEdit;
    transSQLStatement: TIBTransaction;
    pnlNavigator: TPanel;
    navResults: TDBNavigator;
    lblFilter: TLabel;
    edFilter: TEdit;
    pnlPerformance: TPanel;
    DBNavigator1: TDBNavigator;
    dtaPerform: TBufDataset;
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
		qryScript: TIBQuery;
		rmTabSet1: TrmTabSet;
    nbPerform: TrmNoteBookControl;
		grdPerform: TDBGrid;
		Panel2: TPanel;
		chtPerform: TChart;
		Series1: TBarSeries;
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
  pnlMessages: TPanel;
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
    procedure edFilterChange(Sender: TObject);
    procedure cmbConnectionChange(Sender: TObject);
    procedure cmbConnectionDropDown(Sender: TObject);
    procedure qrySQLStatementFilterRecord(DataSet: TDataSet; var Accept: Boolean);
	private
		FCompletion: TSynCompletion;
		{ Private declarations }
		{ Holds the single output row of a statement Firebird executes with
		  output rather than through a cursor - see ExecuteSingletonOutput. }
		FSingletonResult: TBufDataset;
		{ Set while the connection combo is being repopulated, so that doing so
		  does not look like the user picking a different connection. }
		FLoadingConnections: Boolean;
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
		{$IFDEF WINDOWS}procedure WMMove(var message: TMessage); message WM_MOVE;{$ENDIF}
		{$IFDEF WINDOWS}procedure WMNCLButtonDown(var message: TMessage); message WM_NCLBUTTONDOWN;{$ENDIF}
		{$IFDEF WINDOWS}procedure WMNCRButtonDown(var message: TMessage); message WM_NCRBUTTONDOWN;{$ENDIF}
		procedure UpdateEnvironmentBand;
		procedure FillConnectionList;
		function BindStatementParameters: Boolean;
		function ExecuteSingletonOutput(const SQLText: String): Boolean;
		procedure ResetResultSet;
		function ActiveResultSet: TDataSet;
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
		{ Ctrl+Space completion. SynEdit supplies the popup; what this adds is
		  deciding what to put in it - keywords and the connection's objects
		  normally, and that object's columns after a dot. }
		procedure SetUpCompletion;
		procedure CompletionExecute(Sender: TObject);
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

uses Globals, HelpMap, GSSRegistry, MarathonIDE, StatementHistory, ScriptExecutive, SaveFileFormat, BlobViewer, MarathonProjectCache, MarathonProjectCacheTypes, SQLParamsDialog, SQLParamTypes, IBSQL, ScriptAs;

{$R *.lfm}

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
      edSQLStatement.CaretXY := Point(CharPos, LinePos);
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
	SetUpCompletion;

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
	edSQLStatement.CaretXY := edSQLStatement.PixelsToRowColumn(Point(X, Y));
	Accept := True;
end;

procedure TfrmSQLForm.edSQLStatementDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
	edSQLStatement.CaretXY := edSQLStatement.PixelsToRowColumn(Point(X, Y));

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
			{$IFNDEF FPC}WinHelp(Handle, PChar(ExtractFilePath(Application.ExeName) + 'Help\SQLRef.hlp'), HELP_PARTIALKEY, Integer(PChar(edSQLStatement.SelText)));{$ENDIF}
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
	pnlResForm.Font.CharSet := FCharSet;
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

{$IFDEF WINDOWS}
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
{$ENDIF}

{ Whatever the results grid is currently showing. Normally qrySQLStatement,
  but a statement executed with output (below) is displayed from an in-memory
  dataset instead, and export and the "can I export?" test have to follow. }
function TfrmSQLForm.ActiveResultSet: TDataSet;
begin
	Result := dsSQLStatement.DataSet;
	if not Assigned(Result) then
		Result := qrySQLStatement;
end;

procedure TfrmSQLForm.ResetResultSet;
begin
	dsSQLStatement.DataSet := qrySQLStatement;
	FreeAndNil(FSingletonResult);
end;

{ Delegates to SingletonQuery.pas, which is kept LCL-free so the smoke test
  can cover it; see the explanation of the SQLExecProcedure case there. }
function TfrmSQLForm.ExecuteSingletonOutput(const SQLText: String): Boolean;
begin
	FreeAndNil(FSingletonResult);
	FSingletonResult := SingletonQuery.ExecuteSingletonOutput(
		qrySQLStatement.Database, qrySQLStatement.Transaction, SQLText, Self);
	Result := Assigned(FSingletonResult);
	if Result then
		dsSQLStatement.DataSet := FSingletonResult;
end;

procedure TfrmSQLForm.qrySQLStatementAfterOpen(DataSet: TDataSet);
begin
	GlobalFormatFields(DataSet);
	edFilter.Text := '';
	qrySQLStatement.Filtered := False;
end;

procedure TfrmSQLForm.edFilterChange(Sender: TObject);
begin
	{ The filter is qrySQLStatement's own OnFilterRecord; it does not apply to
	  the in-memory singleton result the grid may be showing instead. }
	if not qrySQLStatement.Active then
		Exit;
	qrySQLStatement.Filtered := (Trim(edFilter.Text) <> '');
	qrySQLStatement.First;
end;

procedure TfrmSQLForm.qrySQLStatementFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
	Idx: Integer;
	Needle: String;
begin
	Needle := UpperCase(Trim(edFilter.Text));
	if Needle = '' then
	begin
		Accept := True;
		Exit;
	end;

	Accept := False;
	for Idx := 0 to DataSet.Fields.Count - 1 do
	begin
		if DataSet.Fields[Idx].DataType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftTypedBinary] then
			Continue;
		if Pos(Needle, UpperCase(DataSet.Fields[Idx].AsString)) > 0 then
		begin
			Accept := True;
			Break;
		end;
	end;
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
begin
	// FPC: Query Builder (QBuilder.pas) relies on deep Win32 GDI/grid APIs not ported to LCL; disabled on this port.
	MessageDlg('The Query Builder is not available in this build.', mtInformation, [mbOK], 0);
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
{$IFNDEF FPC}
var
	M: TMetafileCanvas;
	MF: TMetafile;
{$ENDIF}

begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		MarathonIDEInstance.PrintSyntaxMemo(edSQLStatement, False, FFileName);

	if pgSQLStatement.ActivePage = tsResultsView then
		MarathonIDEInstance.PrintDataSet(qrySQLStatement, False, FFileName);

	if pgSQLStatement.ActivePage = tsPerformance then
		MarathonIDEInstance.PrintPerformanceAnalysis(False, edSQLStatement.Lines, dtaPerform, chtPerform);

	{$IFNDEF FPC}
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
	{$ENDIF}
end;

procedure TfrmSQLForm.DoPrintPreview;
{$IFNDEF FPC}
var
	M: TMetafileCanvas;
	MF: TMetafile;
{$ENDIF}

begin
	if pgSQLStatement.ActivePage = tsSQLStatement then
		MarathonIDEInstance.PrintSyntaxMemo(edSQLStatement, True, FFileName);

	if pgSQLStatement.ActivePage = tsResultsView then
		MarathonIDEInstance.PrintDataSet(qrySQLStatement, True, FFileName);

	if pgSQLStatement.ActivePage = tsPerformance then
		MarathonIDEInstance.PrintPerformanceAnalysis(True, edSQLStatement.Lines, dtaPerform, chtPerform);

	{$IFNDEF FPC}
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
	{$ENDIF}
end;

procedure TfrmSQLForm.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		cmbMode.Enabled := False;
		transSQLStatement.DefaultDatabase := nil;
		qryScript.Database := nil;
		qrySQLStatement.Database := nil;
		qryUtil.Database := nil;
		perfSQL.IB_Connection := nil;
		IsInterbase6 := False;
		SQLDialect := 0;
		stsSQLStatement.Panels[4].Text := 'No Connection';
	end
	else
	begin
		cmbMode.Enabled := True;
		transSQLStatement.DefaultDatabase := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qrySQLStatement.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryUtil.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		perfSQL.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		perfSQL.Transaction := transSQLStatement;
		qrySQLStatement.Transaction := transSQLStatement;
		qryScript.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryScript.Transaction := transSQLStatement;
		qryUtil.Transaction := transSQLStatement;
		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := TIBDatabase(qrySQLStatement.Database).SQLDialect;
		stsSQLStatement.Panels[4].Text := Value;
	end;
	{ Driven from the setter rather than from any one caller, so that every path
	  that repoints this editor refreshes the strip. }
	UpdateEnvironmentBand;
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
	Result := transSQLStatement.Active;
end;

function TfrmSQLForm.CanTransactionRollback: Boolean;
begin
	Result := transSQLStatement.Active;
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
	edSQLStatement.CaretXY := Point(1, LineNumber);
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
  nRecords: Integer;
	StatementText, InnerSQL: String;
	IsExplain: Boolean;

begin
	IsExplain := False;
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
						Database := TIBDatabase(qryScript.Database);
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
			{$IFNDEF FPC}qrySQLStatement.BeginBusy(False);{$ENDIF}
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
				begin
					perfSQL.ResetCounters;
					FStartMemory := perfSQL.ReadCurrentMemory;
				end;

				qrySQLStatement.Close;
				ResetResultSet;
				qrySQLStatement.SQL.Clear;
				if edSQLStatement.SelText <> '' then
					StatementText := edSQLStatement.SelText
				else
					StatementText := edSQLStatement.Text;

				{ EXPLAIN is a client-side command, not something Firebird will
				  prepare, so strip it and prepare the statement underneath. A
				  prepared statement already carries its explained plan and
				  preparing executes nothing - which is exactly what makes
				  explaining a DELETE useful. }
				IsExplain := IsExplainRequest(StatementText, InnerSQL);
				if IsExplain then
					qrySQLStatement.SQL.Text := InnerSQL
				else
					qrySQLStatement.SQL.Text := StatementText;

				try
					qrySQLStatement.Prepare;
				except
					on E : Exception do
					begin
						// nothing...
					end;
				end;

				{ A statement with parameters would otherwise execute with every
				  one of them unbound, which Firebird takes as NULL without
				  complaint - so the generated "insert ... values (:ID)" and
				  "execute procedure P(:A)" scripts appeared to run and did
				  nothing useful. }
				if not IsExplain then
					if not BindStatementParameters then
					begin
						stsSQLStatement.Panels[3].Text := '      Statement Cancelled';
						Exit;
					end;

				if IsExplain then
				begin
					edPlan.Text := qrySQLStatement.GetPlan;
					FillTreeFromExplainedPlan(edPlan.Text, dtPlan);
					{ The user asked for the plan explicitly, so show it even when
					  the Plan tab is otherwise switched off. }
					tsPlan.TabVisible := True;
					pgSQLStatement.ActivePage := tsPlan;
					stsSQLStatement.Panels[3].Text := '      Statement Explained';
					imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_OK');
				end
				else

				case qrySQLStatement.StatementType of
					SQLSelect, SQLSelectForUpdate:
						begin
							qrySQLStatement.Open;
							pgSQLStatement.ActivePage := tsResultsView;
							pgSQLStatementChange(pgSQLStatement);
							stsSQLStatement.Panels[3].Text := '      Statement Execution Successful';
							imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_OK');
						end;

					SQLExecProcedure:
						begin
							{ Only when the statement actually has output columns -
							  an EXECUTE PROCEDURE on a procedure with no output
							  parameters is an ordinary execute. ExecuteSingletonOutput
							  runs the statement itself, so it must not also be run
							  below or an INSERT would happen twice. }
							if ExecuteSingletonOutput(qrySQLStatement.SQL.Text) then
							begin
								MarathonIDEInstance.RecordToScript(qrySQLStatement.SQL.Text, GetActiveConnectionName);
								pgSQLStatement.ActivePage := tsResultsView;
								pgSQLStatementChange(pgSQLStatement);
							end
							else
							begin
								qrySQLStatement.ExecSQL;
								MarathonIDEInstance.RecordToScript(qrySQLStatement.SQL.Text, GetActiveConnectionName);
							end;
							stsSQLStatement.Panels[3].Text := '      Statement Execution Successful';
							imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_OK');
						end;
				else
					begin
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
							{$IFNDEF FPC}
							qrySQLStatement.FetchAll;
							if not qrySQLStatement.InternalDataset.FetchingAborted then
							{$ENDIF}
								qrySQLStatement.First;
						finally
							qrySQLStatement.EnableControls;
						end;
					end;

					if True then { FPC: InternalDataset.FetchingAborted not available }
					begin
						perfSQL.Refresh;
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
							SQLSelect, SQLSelectForUpdate:
								begin
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Prepare Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(FPrepareTime) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Fetch Time';
									dtaPerform.FieldByName('value').AsString := '0 ms'; { FPC: CallbackInitTick not available }
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Avg Fetch Time';
                  nRecords := qrySQLStatement.RecordCount;  //AC:
                  if nRecords = 0 then nRecords := 1; //AC:
									dtaPerform.FieldByName('value').AsString := '0 ms'; { FPC: CallbackInitTick not available }
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Rows Processed';
									dtaPerform.FieldByName('value').AsString := IntToStr(qrySQLStatement.RecordCount);
									dtaPerform.Post;
								end;
							SQLUpdate, SQLDelete:
								begin
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Prepare Time';
									dtaPerform.FieldByName('value').AsString := IntToStr(FPrepareTime) + ' ms';
									dtaPerform.Post;
									dtaPerform.Append;
									dtaPerform.FieldByName('item').AsString := 'Fetch Time';
									dtaPerform.FieldByName('value').AsString := '0 ms'; { FPC: CallbackInitTick not available }
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

				{ An EXPLAIN already filled the plan in above, and executed
				  nothing there is a plan to report for. }
				if not IsExplain then
				begin
					if FShowPlan and (qrySQLStatement.StatementType in [SQLSelect, SQLSelectForUpdate, SQLUpdate, SQLDelete]) then
					begin
						edPlan.Text := qrySQLStatement.GetPlan;
						FillTreeFromExplainedPlan(edPlan.Text, dtPlan);
					end
					else
						dtPlan.Clear;
				end;

			except
				On E : Exception do
				begin
					stsSQLStatement.Panels[3].Text := '      Statement Execution Failed';
					imgSuccess.Picture.Bitmap.LoadFromResourceName(HInstance, 'SQL_ED_FAIL');
					pnlMessages.Visible := True;
					Refresh;
					stsSQLStatement.Top := Height;
					AddError(E.message);
					lstResultsClick(lstResults);
				end;
			end;
		end;
	finally
		Screen.Cursor := crDefault;
		{$IFNDEF FPC}qrySQLStatement.EndBusy;{$ENDIF}
	end;
end;

procedure TfrmSQLForm.SetUpCompletion;
begin
	FCompletion := TSynCompletion.Create(Self);
	FCompletion.Editor := edSQLStatement;
	{ Ctrl+Space, which is what every other SQL tool uses. SynEdit's default is
	  the same shortcut, but it is set explicitly so a change of default does
	  not silently move it. }
	FCompletion.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl]);
	{ A dot has to end a token, or typing 'c.' would look like one word and the
	  list would never see the qualifier. }
	FCompletion.EndOfTokenChr := '()[]. ,;:-+*/=<>''"';
	FCompletion.OnExecute := CompletionExecute;
end;

procedure TfrmSQLForm.CompletionExecute(Sender: TObject);
var
	Ctx: TCompletionContext;
	Conn: TMarathonCacheConnection;
	Cols: TStringList;
	Idx: Integer;
	Line, TableName: String;
begin
	FCompletion.ItemList.BeginUpdate;
	try
		FCompletion.ItemList.Clear;
		Line := edSQLStatement.LineText;
		Ctx := CompletionContextAt(Line, edSQLStatement.CaretX);

		Conn := nil;
		if ConnectionName <> '' then
			Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];

		if Ctx.Kind = ckQualified then
		begin
			{ After a dot only that object's columns make sense - a keyword there
			  never does. Nothing is offered when the connection is closed or the
			  name resolves to nothing, which is better than offering a list that
			  does not belong to it. }
			if Assigned(Conn) and Conn.Connected then
			begin
				TableName := ResolveAlias(edSQLStatement.Text, Ctx.Qualifier);
				try
					Cols := ScriptAsColumnNames(
						ScriptAsContext(Conn.Connection, Conn.Transaction, Conn.IsIB6,
							Conn.SQLDialect, Conn.ServerMajorVersion),
						AnsiUpperCase(TableName));
					try
						for Idx := 0 to Cols.Count - 1 do
							FCompletion.ItemList.Add(Trim(Cols[Idx]));
					finally
						Cols.Free;
					end;
				except
					{ An unknown name is the normal case while typing, not an error
					  to report - it just has no columns to offer. }
					on E: Exception do ;
				end;
			end;
			Exit;
		end;

		{ Otherwise: the objects on this connection, then the keywords. Objects
		  first because they are what the reader cannot remember; keywords are
		  already highlighted as they type. }
		if Assigned(Conn) and Conn.Connected then
		begin
			FCompletion.ItemList.AddStrings(Conn.TableList);
			FCompletion.ItemList.AddStrings(Conn.ViewList);
		end;
		AddFirebirdKeywords(FCompletion.ItemList);
	finally
		FCompletion.ItemList.EndUpdate;
	end;
end;

procedure TfrmSQLForm.DoFind;
begin
	edSQLStatement.WSFind;
end;

procedure TfrmSQLForm.DoFindNext;
begin
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

{ Repopulates the connection dropdown from the project. Done on drop-down
  rather than once at create time, because connections can be added, renamed or
  removed while an editor is open. }
procedure TfrmSQLForm.FillConnectionList;
var
	Idx: Integer;
begin
	FLoadingConnections := True;
	try
		cmbConnection.Items.BeginUpdate;
		try
			cmbConnection.Items.Clear;
			if Assigned(MarathonIDEInstance.CurrentProject) then
				for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
					cmbConnection.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
		finally
			cmbConnection.Items.EndUpdate;
		end;
		cmbConnection.ItemIndex := cmbConnection.Items.IndexOf(ConnectionName);
	finally
		FLoadingConnections := False;
	end;
end;

{ Asks for a value for each parameter the prepared statement has, and binds
  what comes back. True to go ahead, False if the user cancelled. A statement
  with no parameters never prompts. }
function TfrmSQLForm.BindStatementParameters: Boolean;
var
	Dlg: TfrmSQLParams;
	Names, TypeNames: TStringList;
	Kinds: array of TSQLParamKind;
	Meta: TIBSQL;
	Idx: Integer;
begin
	Result := True;
	if qrySQLStatement.ParamCount = 0 then
		Exit;

	Names := TStringList.Create;
	TypeNames := TStringList.Create;
	try
		for Idx := 0 to qrySQLStatement.ParamCount - 1 do
			Names.Add(qrySQLStatement.Params[Idx].Name);
		SetLength(Kinds, Names.Count);

		{ TIBQuery keeps its parameters as FCL TParams, whose DataType comes back
		  ftUnknown - the declared types live on the statement itself, which only
		  TIBSQL exposes. Preparing a second time to read them is cheap and needs
		  no extra round trip once the statement is in the cache. }
		Meta := TIBSQL.Create(nil);
		try
			try
				Meta.Database := qrySQLStatement.Database;
				Meta.Transaction := qrySQLStatement.Transaction;
				Meta.SQL.Text := qrySQLStatement.SQL.Text;
				Meta.Prepare;
				for Idx := 0 to Names.Count - 1 do
					if Idx < Meta.Params.GetCount then
					begin
						Kinds[Idx] := SQLParamKindOf(Meta.Params[Idx].SQLType,
							Meta.Params[Idx].getScale);
						TypeNames.Add(Meta.Params[Idx].GetSQLTypeName);
					end;
			except
				{ Types are a convenience; without them every parameter is free
				  text, which still works. }
				on E: Exception do
					TypeNames.Clear;
			end;
		finally
			Meta.Free;
		end;

		Dlg := TfrmSQLParams.Create(Self);
		try
			Dlg.SetParameters(Names, Kinds, TypeNames);
			if Dlg.ShowModal <> mrOK then
			begin
				Result := False;
				Exit;
			end;
			for Idx := 0 to qrySQLStatement.ParamCount - 1 do
				if Dlg.IsNullAt(Idx) then
					qrySQLStatement.Params[Idx].Clear
				else
					{ Bound as text and left to Firebird to convert, which is what
					  makes one dialog work for every parameter type. }
					qrySQLStatement.Params[Idx].AsString := Dlg.ValueOf(Idx);
		finally
			Dlg.Free;
		end;
	finally
		TypeNames.Free;
		Names.Free;
	end;
end;

procedure TfrmSQLForm.cmbConnectionDropDown(Sender: TObject);
begin
	FillConnectionList;
end;

{ Repoints this editor at another connection without closing it. The script
  itself is untouched - only what it will run against changes. }
procedure TfrmSQLForm.cmbConnectionChange(Sender: TObject);
var
	NewName: String;
begin
	if FLoadingConnections then
		Exit;
	if cmbConnection.ItemIndex < 0 then
		Exit;
	NewName := cmbConnection.Items[cmbConnection.ItemIndex];
	if NewName = ConnectionName then
		Exit;

	{ Work in flight belongs to the connection being left, so it has to be
	  settled before the datasets are repointed - the same question closing the
	  editor asks. }
	if transSQLStatement.Active then
	begin
		case MessageDlg('This editor has uncommitted work on ' + ConnectionName + '.' +
			#13#10#13#10 + 'Commit it before switching to ' + NewName + '?',
			mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
			mrYes:
				transSQLStatement.Commit;
			mrNo:
				transSQLStatement.Rollback;
		else
			{ Put the combo back where it was and leave everything alone. }
			FillConnectionList;
			Exit;
		end;
	end;

	qrySQLStatement.Close;
	ResetResultSet;
	edPlan.Text := '';
	dtPlan.Clear;

	ConnectionName := NewName;
end;

{ Shows which connection this editor is pointed at and, when that connection
  has been tagged, which environment - in the environment's colour. The point
  is that a window about to run DDL against production should not look like one
  pointed at a scratch database. }
procedure TfrmSQLForm.UpdateEnvironmentBand;
var
	Conn: TMarathonCacheConnection;
	Env: TConnectionEnvironment;
begin
	{ SetDatabaseName can run before the strip's controls have streamed. }
	if not Assigned(cmbConnection) then
		Exit;
	Env := envUnset;
	if (ConnectionName <> '') and Assigned(MarathonIDEInstance.CurrentProject) then
	begin
		Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
		if Assigned(Conn) then
			Env := Conn.Environment;
	end;

	FillConnectionList;
	lblEnvironmentName.Caption := UpperCase(EnvironmentDisplayName(Env));

	pnlEnvironment.Color := EnvironmentColor(Env);
	pnlEnvironment.Font.Color := EnvironmentTextColor(Env);
	lblConnectionCaption.Font.Color := EnvironmentTextColor(Env);
	lblEnvironmentName.Font.Color := EnvironmentTextColor(Env);
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
		if transSQLStatement.Active then
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
	Result := (pgSQLStatement.ActivePage = tsResultsView) and
		(not (ActiveResultSet.EOF and ActiveResultSet.BOF));
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
			for idx := 0 to ActiveResultSet.Fields.Count - 1 do
				  f.chklistColumns.Items.Add(ActiveResultSet.Fields[idx].FieldName);

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

					ExportGrid(Ex, ActiveResultSet, FList, TableName, FName);
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


