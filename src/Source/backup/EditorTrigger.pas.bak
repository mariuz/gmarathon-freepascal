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
// $Id: EditorTrigger.pas,v 1.11 2006/10/22 06:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: EditorTrigger.pas,v $
Revision 1.11  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.10  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.9  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.8  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.7  2002/09/25 12:11:40  tmuetze
Revisited the 'Load from' and 'Save as' capabilities of the editors

Revision 1.6  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.5  2002/06/14 09:57:37  tmuetze
Reenabled context sensitive keyword help via SQLRef.hlp

Revision 1.4  2002/05/27 07:10:28  tmuetze
Fixed another compile bug and tightened the sourcecode a bit

Revision 1.3  2002/04/29 15:05:58  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit EditorTrigger;

{$I compilerdefines.inc}

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls, DB, Menus, Grids, DBGrids, Buttons, Clipbrd,
	Tabs, FileCtrl, ActnList, ImgList,
	rmPanel,
	rmCollectionListBox,
	IB_Components,
	IB_Header,
	IBODataset,
	SynEdit,
  SynEditTypes,
	SyntaxMemoWithStuff2,
	BaseDocumentDataAwareForm,
	FrameDescription,
	FrameDependencies,
	FrameDRUIMatrix,
	FramePermissions,
	MarathonProjectCacheTypes,
	MarathonInternalInterfaces,
	NewTrigger;

type
	TTriggerHeader = class(TObject)
	public
		TriggerName: String;
		Active: String;
		Position: String;
		Table: String;
		FireOrder: String;
		function GetAlterText: String;
		function GetCreateText: String;
	end;

	TfrmTriggerEditor = class(TfrmBaseDocumentDataAwareForm, IMarathonTriggerEditor)
		stsEditor: TStatusBar;
		dlgOpen: TOpenDialog;
		pgObjectEditor: TPageControl;
		tsObject: TTabSheet;
		tsDocoView: TTabSheet;
    qryTrigger: TIBOQuery;
    qryUtil: TIBOQuery;
		edEditor: TSyntaxMemoWithStuff2;
		tsDependencies: TTabSheet;
		tsDRUI: TTabSheet;
		tsDebuggerOutput: TTabSheet;
		edErrors: TSyntaxMemoWithStuff2;
		qryWarnings: TIB_DSQL;
		framDoco: TframeDesc;
		framDepend: TframeDepend;
		frameDRUI: TframeDRUI;
		edTriggerHeader: TSyntaxMemoWithStuff2;
		Splitter1: TSplitter;
    dlgSave: TSaveDialog;
    pnlMessages: TrmPanel;
    lstResults: TrmCollectionListBox;
		procedure lstResultsClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure WindowListClick(Sender: TObject);
		procedure edEditorKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure edEditorDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
		procedure edEditorDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
		function FormHelp(Command: Word; Data: Integer;	var CallHelp: Boolean): Boolean;
		procedure edEditorChange(Sender: TObject);
		procedure edEditorGetHintText(Sender: TObject; Token: String;	var HintText: String; HintType: THintType);
		procedure edEditorNavigateHyperLinkClick(Sender: TObject;	Token: String);
		procedure FormResize(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure pnlMessagesResize(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure edEditorStatusChange(Sender: TObject;	Changes: TSynStatusChanges);
    procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		FErrors: Boolean;
		LinePos: LongInt;
		// Context sensitive keyword help
		DoKeySearch: Boolean;

		FFileName: String;

		It: TMenuItem;
		FNewTriggerProperties: TfrmNewTrigger;
		FTableName: String;
		FHeader: TTriggerHeader;
		procedure WMMove(var message: TMessage); message WM_MOVE;
		procedure WMNCLButtonDown(var message: TMessage); message WM_NCLBUTTONDOWN;
		procedure WMNCRButtonDown(var message: TMessage); message WM_NCRBUTTONDOWN;
		procedure LoadTriggerSource;
		procedure UpdateEncoding;
		procedure WarningsHandler(Sender: TObject; Line: Integer; Column: Integer; Statement: String);
		function GetTableName: String;
	public
		{ Public declarations }
		property TriggerProperties: TfrmNewTrigger read FNewTriggerProperties write FNewTriggerProperties;
		procedure AddInfo(Info: String);
		procedure AddError(Info: String);
		procedure GotoFindPosition(C: TPoint; Len: Integer);

		procedure LoadTrigger(TriggerName: String);
		procedure NewTrigger(TriggerType: String; Table: String);
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

		function CanLoadFrom: Boolean; override;
		procedure DoLoadFrom; override;

		function CanSaveAs: Boolean; override;
		procedure DoSaveAs; override;

		function CanClearBuffer: Boolean; override;
		procedure DoClearBuffer; override;

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

		function CanViewMessages: Boolean; override;
		function AreMessagesVisible: Boolean; override;
		procedure DoViewMessages; override;

		function CanCompile: Boolean; override;
		procedure DoCompile; override;

		function CanSaveDoco: Boolean; override;
		procedure DoSaveDoco; override;

		function CanSaveAsTemplate: Boolean; override;
		procedure DoSaveAsTemplate; override;

		function CanObjectDrop: Boolean; override;
		procedure DoObjectDrop; override;

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

		function CanObjectProperties: Boolean; override;
		procedure DoObjectProperties; override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;
	end;

implementation

uses
	Globals,
	HelpMap,
	SQLYacc,
	CompileDBObject,
	DropObject,
	SaveFileFormat,
	MarathonIDE,
	MarathonOptions,
	InputDialog,
	QBuilder;

{$R *.DFM}

const
	PG_EDIT = 0;
	PG_DOCO = 1;
	PG_DEPEND = 2;
	PG_DRUI = 3;

function TTriggerHeader.GetAlterText: String;
begin
	Result := 'alter trigger ' + TriggerName + ' ' + Active + ' ' + Position + ' position ' + FireOrder;
end;

function TTriggerHeader.GetCreateText: String;
begin
	Result := 'create trigger ' + TriggerName + ' for ' + Table + ' ' + Active + ' ' + Position + ' position ' + FireOrder;
end;

procedure TfrmTriggerEditor.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmTriggerEditor.LoadTriggerSource;
var
	Temp: String;
	Idx: Integer;

begin
	InternalCaption := 'Trigger - [' + FObjectName + ']';
	IT.Caption := Caption;

	qryTrigger.BeginBusy(False);
	try
		FNewObject := False;
		if ShouldbeQuoted(FObjectName) then
			FHeader.TriggerName := MakeQuotedIdent(FObjectName, FIsInterbase6, FSQLDialect)
		else
			FHeader.TriggerName := FObjectName;

		qryTrigger.SQL.Add('select * from RDB$TRIGGERS where RDB$TRIGGER_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ';');
		qryTrigger.Open;
		if not (qryTrigger.EOF and qryTrigger.BOF) then
		begin
			if ShouldBeQuoted(qryTrigger.FieldByName('RDB$RELATION_NAME').AsString) then
				FHeader.Table := MakeQuotedIdent(qryTrigger.FieldByName('RDB$RELATION_NAME').AsString, FIsInterbase6, FSQLDialect)
			else
				FHeader.Table := qryTrigger.FieldByName('RDB$RELATION_NAME').AsString;
			FTableName := qryTrigger.FieldByName('RDB$RELATION_NAME').AsString;
			case qryTrigger.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger of
				0:
					FHeader.Active := 'active';

				1:
					FHeader.Active := 'inactive';
			end;
			case qryTrigger.FieldByName('RDB$TRIGGER_TYPE').AsInteger of
				1:
					FHeader.Position := 'before insert';

				2:
					FHeader.Position := 'after insert';

				3:
					FHeader.Position := 'before update';

				4:
					FHeader.Position := 'after update';

				5:
					FHeader.Position := 'before delete';

				6:
					FHeader.Position := 'after delete';
			end;
			FHeader.FireOrder := qryTrigger.FieldByName('RDB$TRIGGER_SEQUENCE').AsString;

			Temp := ConvertTabs(qryTrigger.FieldByName('RDB$TRIGGER_SOURCE').AsString, edEditor);
			Idx := Pos(' ' + #10, Temp);
			while Idx > 0 do
			begin
				Delete(Temp, Idx, 2);
				Idx := Pos(' ' + #10, Temp);
			end;
		end;
		edTriggerHeader.Text := FHeader.GetCreateText;
		edEditor.Text := Temp;
		qryTrigger.Close;
		qryTrigger.IB_Transaction.Commit;
	finally
		qryTrigger.EndBusy;
	end;
end;

procedure TfrmTriggerEditor.lstResultsClick(Sender: TObject);
var
	Line: String;
	CharPos: Integer;
	Parser: TTextParser;
	Tok: TToken;
	FoundLine, FoundChar: Boolean;

begin
	if lstResults.ItemIndex <> -1 then
	begin

		edEditor.ErrorLine := -1;

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
			edEditor.ErrorLine := LinePos;
			edEditor.CaretXY := BufferCoord(CharPos, LinePos);
			if pgObjectEditor.ActivePage.PageIndex = 0 then
				edEditor.SetFocus;
		end;
	end;
end;

procedure TfrmTriggerEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;

	framDepend.SaveColWidths;
	FHeader.Free;
	Action := caFree;
end;

procedure TfrmTriggerEditor.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	FObjectType := ctTrigger;
	FHeader := TTriggerHeader.Create;

	FNewTriggerProperties := TfrmNewTrigger.Create(Self);

	pgObjectEditor.ActivePage := tsObject;
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
	frameDRUI.Init(TmpIntf);

	FCharSet := SetupEncodingControl(edEditor);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 Trigger [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);
end;


procedure TfrmTriggerEditor.edEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TfrmTriggerEditor.pgObjectEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			begin
				edEditorChange(Self);
				edEditor.SetFocus;
			end;

		PG_DOCO:
			begin
				edEditorChange(Self);
				framDoco.SetActive;
			end;

		PG_DEPEND:
			begin
				framDepend.LoadDependencies;
				framDepend.SetActive;

				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_DRUI:
			begin
				frameDRUI.CalcMatrix(FHeader.GetCreateText + #13#10 + edEditor.Text);
				frameDRUI.SetActive;
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

	end;
end;

procedure TfrmTriggerEditor.FormCloseQuery(Sender: TObject;	var CanClose: Boolean);
begin
	if FDropClose or FByPassClose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

procedure TfrmTriggerEditor.edEditorDragOver(Sender, Source: TObject;	X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
	SetFocus;
	if edEditor.InsertMode then
		stsEditor.Panels[2].Text := 'Insert'
	else
		stsEditor.Panels[2].Text := 'Overwrite';
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	Accept := True;
end;

procedure TfrmTriggerEditor.edEditorDragDrop(Sender, Source: TObject; X, Y: Integer);
var
	Tmp: String;

begin
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	if Source is TDragQueen then
		Tmp := TDragQueen(Source).DragText;

	edEditor.SelText := Tmp;
end;

procedure TfrmTriggerEditor.pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
begin
	if FNewObject then
	begin
		MessageDlg('You cannot change from Edit View until the object has been compiled.', mtWarning, [mbOK], 0);
		AllowChange := False;
	end
	else
	begin
		case pgObjectEditor.ActivePage.PageIndex of
			PG_DOCO:
				if framDoco.Modified then
					if MessageDlg('Save changes to documentation?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
						framDoco.SaveDoco;
		end;
	end;
end;

procedure TfrmTriggerEditor.GotoFindPosition(C: TPoint; Len: Integer);
begin
//	edEditor.SetSelection(C.Y + FLineOffset + 1, C.X, C.Y + FLineOffset + 1, C.X + Len, False);
end;

function TfrmTriggerEditor.FormHelp(Command: Word; Data: Integer;	var CallHelp: Boolean): Boolean;
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

procedure TfrmTriggerEditor.edEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			FObjectModified := UpdateEditorStatusBar(stsEditor, edEditor);

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

procedure TfrmTriggerEditor.AddInfo(Info: String);
begin
	if not pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		pnlMessages.Visible := True;
		stsEditor.Top := Height;
	end;

	lstResults.Add('INFO: ' + Info, 1, nil);
end;

procedure TfrmTriggerEditor.AddError(Info: String);
begin
	if not pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		pnlMessages.Visible := True;
		stsEditor.Top := Height;
	end;
	lstResults.Add(Info, 0, nil);
end;

procedure TfrmTriggerEditor.edEditorGetHintText(Sender: TObject; Token: String; var HintText: String; HintType: THintType);
begin
	HintText := MarathonIDEInstance.GetHintTextForToken(Token, ConnectionName);
end;

procedure TfrmTriggerEditor.edEditorNavigateHyperLinkClick(Sender: TObject; Token: String);
begin
	MarathonIDEInstance.NavigateToLink(Token, ConnectionName);
end;

procedure TfrmTriggerEditor.WarningsHandler(Sender: TObject; Line: Integer; Column: Integer; Statement: String);
var
	Plan: String;

begin
	qryWarnings.SQL.Text := Statement;
	try
		qryWarnings.Prepare;
	except
		on E: Exception do
	end;
	Plan := qryWarnings.StatementPlan;
	if Pos('NATURAL', AnsiUpperCase(Plan)) > 0 then
		AddInfo('Warning: SubOptimal Query Line ' + IntToStr(Line) + ' Column ' + IntToStr(Column) + ' -  May not use Index (' + Plan + ')');
end;

procedure TfrmTriggerEditor.UpdateEncoding;
begin
	edEditor.Font.Charset := FCharSet;
end;

procedure TfrmTriggerEditor.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmTriggerEditor.WMMove(var message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmTriggerEditor.WMNCLButtonDown(var message: TMessage);
begin
	inherited;
	edEditor.CLoseUpLists;
end;

procedure TfrmTriggerEditor.WMNCRButtonDown(var message: TMessage);
begin
	inherited;
	edEditor.CloseUpLists;
end;

procedure TfrmTriggerEditor.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

function TfrmTriggerEditor.CanCaptureSnippet: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := Length(edEditor.SelText) > 0;
end;

function TfrmTriggerEditor.CanChangeEncoding: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := True;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := True;
end;

function TfrmTriggerEditor.CanCopy: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		if lstResults.Focused then
			Result := lstResults.ItemIndex > -1
		else
			Result := Length(edEditor.SelText) > 0;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanCopy;
end;

function TfrmTriggerEditor.CanCut: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := Length(edEditor.SelText) > 0;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanCut;
end;

function TfrmTriggerEditor.CanFind: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanFind;
end;

function TfrmTriggerEditor.CanFindNext: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanFindNext;
end;

function TfrmTriggerEditor.CanGotoBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := IsBookmarkSet(Index);
end;

function TfrmTriggerEditor.CanInternalClose: Boolean;
begin
	Result := True;
end;

function TfrmTriggerEditor.CanPaste: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := Clipboard.HasFormat(CF_TEXT);

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanPaste;
end;

function TfrmTriggerEditor.CanPrint: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			Result := (not FNewObject);

		PG_DOCO:
			Result := (not FNewObject) and framDoco.CanPrint;

		PG_DEPEND:
			Result := (not FNewObject) and framDepend.CanPrint;

		PG_DRUI:
			Result := (not FNewObject) and frameDRUI.CanPrint;
	end;
end;

function TfrmTriggerEditor.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

function TfrmTriggerEditor.CanRedo: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.CanRedo;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanRedo;
end;

function TfrmTriggerEditor.CanSelectAll: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanSelectAll;
	end;
end;

function TfrmTriggerEditor.CanToggleBookmark(Index: Integer): Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0;
end;

function TfrmTriggerEditor.CanUndo: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.CanUndo;

	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanUndo;
end;

function TfrmTriggerEditor.CanViewMessages: Boolean;
begin
	Result := True;
end;

function TfrmTriggerEditor.AreMessagesVisible: Boolean;
begin
	Result := pnlMessages.Visible;
end;

function TfrmTriggerEditor.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmTriggerEditor.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

function TfrmTriggerEditor.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if edEditor.Modified then
		begin
			case MessageDlg('The trigger ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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
			case MessageDlg('The documentation for trigger ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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

procedure TfrmTriggerEditor.DoCaptureSnippet;
begin
	CaptureCodeSnippet(edEditor);
end;

procedure TfrmTriggerEditor.DoChangeEncoding(Index: Integer);
begin
	inherited;
	FCharSet := GetCharSetByIndex(Index);
	UpdateEncoding;
end;

procedure TfrmTriggerEditor.DoCopy;
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

procedure TfrmTriggerEditor.DoCut;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.CutToClipBoard;

		PG_DOCO:
			framDoco.CutToClipBoard;
	end;
end;

procedure TfrmTriggerEditor.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.WSFind;

		PG_DOCO:
			framDoco.WSFind;
	end;
end;

procedure TfrmTriggerEditor.DoFindNext;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.WSFindNext;

		PG_DOCO:
			framDoco.WSFindNext;
	end;
end;

procedure TfrmTriggerEditor.DoGotoBookmark(Index: Integer);
begin
	if pgObjectEditor.ActivePage = tsObject then
		edEditor.GotoBookmark(Index);
end;

procedure TfrmTriggerEditor.DoInternalClose;
begin
	Close;
end;

procedure TfrmTriggerEditor.DoPaste;
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

function TfrmTriggerEditor.CanLoadFrom: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := True;
end;

procedure TfrmTriggerEditor.DoLoadFrom;
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

function TfrmTriggerEditor.CanSaveAs: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := True;
end;

procedure TfrmTriggerEditor.DoSaveAs;
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

function TfrmTriggerEditor.CanClearBuffer: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0;
end;

procedure TfrmTriggerEditor.DoClearBuffer;
begin
	edEditor.Clear;
	edEditor.OnChange(edEditor);
end;

procedure TfrmTriggerEditor.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			MarathonIDEInstance.PrintTrigger(False, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrint;

		PG_DEPEND:
			framDepend.DoPrint;

		PG_DRUI:
			frameDRUI.DoPrint;
	end;
end;

procedure TfrmTriggerEditor.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			MarathonIDEInstance.PrintTrigger(True, FObjectName, FDatabaseName);

		PG_DOCO:
			framDoco.DoPrintPreview;

		PG_DEPEND:
			framDepend.DoPrintPreview;

		PG_DRUI:
			frameDRUI.DoPrintPreview;
	end;
end;

procedure TfrmTriggerEditor.DoRedo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.Redo;

		PG_DOCO:
			framDoco.Redo;
	end;
end;

procedure TfrmTriggerEditor.DoSelectAll;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.SelectAll;

		PG_DOCO:
			framDoco.SelectAll;
	end;
end;

procedure TfrmTriggerEditor.DoToggleBookmark(Index: Integer);
begin
	GlobalSetBookmark(edEditor, Index);
end;

procedure TfrmTriggerEditor.DoUndo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EDIT:
			edEditor.Undo;

		PG_DOCO:
			framDoco.Undo;
	end;
end;

procedure TfrmTriggerEditor.DoViewMessages;
begin
	inherited;
	pnlMessages.Visible := not pnlMessages.Visible;
	if pnlMessages.Visible then
	begin
		pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
		stsEditor.Top := Height;
	end;
end;

procedure TfrmTriggerEditor.DoViewNextPage;
begin
	inherited;
end;

procedure TfrmTriggerEditor.DoViewPrevPage;
begin
	inherited;
end;

procedure TfrmTriggerEditor.EnvironmentOptionsRefresh;
begin
	inherited;
end;

function TfrmTriggerEditor.IsBookmarkSet(Index: Integer): Boolean;
begin
	Result := IsABookmarkSet(edEditor, Index);
end;

function TfrmTriggerEditor.IsEncoding(Index: Integer): Boolean;
begin
	Result := FCharSet = GetCharSetByIndex(Index);
end;

procedure TfrmTriggerEditor.LoadTrigger(TriggerName: String);
begin
	FObjectName := TriggerName;
	qryTrigger.BeginBusy(False);
	try
		LoadTriggerSource;
	finally
		qryTrigger.EndBusy;
	end;

	Refresh;
	Show;

	// Load the documentation from the SP
	framDoco.LoadDoco;
end;

procedure TfrmTriggerEditor.ProjectOptionsRefresh;
begin
	inherited;
end;

procedure TfrmTriggerEditor.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		qryWarnings.IB_Connection := nil;
		qryUtil.IB_Connection := nil;
		qryTrigger.IB_Connection := nil;
		framDoco.qryDoco.IB_Connection := nil;
		framDoco.qryDoco.IB_Transaction := nil;
		IsInterbase6 := False;
		SQLDialect := 0;
		stsEditor.Panels[3].Text := 'No Connection';
	end
	else
	begin
		qryWarnings.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryWarnings.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryTrigger.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryTrigger.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qryUtil.IB_Connection.SQLDialect;
		stsEditor.Panels[3].Text := Value;
	end;
end;

procedure TfrmTriggerEditor.NewTrigger(TriggerType: String; Table: String);
var
	Idx: Integer;

begin
	FObjectName := 'NEW_TRIGGER';
	InternalCaption := 'Trigger - [' + FObjectName + ']';
	IT.Caption := Caption;

	FNewTriggerProperties.edTriggerName.Text := FObjectName;
	FNewTriggerProperties.cmbActive.ItemIndex := 0;
	FNewTriggerProperties.cmbTables.Items := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].TableList;
	for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].ViewList.Count - 1 do
		FNewTriggerProperties.cmbTables.Items.Add(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].ViewList[Idx]);

	for Idx := 0 to FNewTriggerProperties.cmbTables.Items.Count - 1 do
		if Table = FNewTriggerProperties.cmbTables.Items[Idx] then
		begin
			FNewTriggerProperties.cmbTables.ItemIndex := Idx;
			Break;
		end;

	if TriggerType = 'before insert' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 0;

	if TriggerType = 'after insert' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 1;

	if TriggerType = 'before update' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 2;

	if TriggerType = 'after update' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 3;

	if TriggerType = 'before update' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 4;

	if TriggerType = 'after delete' then
		FNewTriggerProperties.cmbTrigPos.ItemIndex := 5;


	if FNewTriggerProperties.ShowModal = mrOK then
	begin
		FObjectName := MakeQuotedIdent(FNewTriggerProperties.edTriggerName.Text, IsInterbase6, SQLDialect);

		InternalCaption := 'Trigger - [' + FObjectName + ']';
		FHeader.TriggerName := FObjectName;
		if ShouldBeQuoted(FNewTriggerProperties.cmbTables.Text) then
			FHeader.Table := MakeQuotedIdent(FNewTriggerProperties.cmbTables.Text, FIsInterbase6, FSQLDialect)
		else
			FHeader.Table := FNewTriggerProperties.cmbTables.Text;

		FTableName := FNewTriggerProperties.cmbTables.Text;
		FHeader.Active := FNewTriggerProperties.cmbActive.Text;
		FHeader.Position := FNewTriggerProperties.cmbTrigPos.Text;
		FHeader.FireOrder := FNewTriggerProperties.edPosition.Text;
		edTriggerHeader.Text := FHeader.GetCreateText;

		edEditor.Text := 'as' + #13#10 + 'begin' + #13#10#13#10 + 'end';
		edTriggerHeader.ReadOnly := False;
	end
	else
		raise Exception.Create('Creation of new Trigger cancelled.');

	FObjectModified := True;
	FNewObject := True;
	stsEditor.Panels[1].Text := '';
end;

function TfrmTriggerEditor.CanCompile: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0
end;

procedure TfrmTriggerEditor.DoCompile;
var
	Doco, CompileText: String;
	M: TSQLParser;
	TmpIntf: IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	try
		pnlMessages.Visible := False;

		Doco := framDoco.Doco;

		edEditor.ErrorLine := -1;

		Refresh;
		if FNewObject then
			CompileText := FHeader.GetCreateText + #13#10 + edEditor.Text
		else
			CompileText := FHeader.GetAlterText + #13#10 + edEditor.Text;

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryTrigger.IB_Connection, qryTrigger.IB_Transaction, ctTrigger, CompileText);
		FErrors := FCompile.CompileErrors;
		FCompile.Free;

		if FErrors then
			Exit;

		// Update the tree cache
		if FNewObject then
		begin
			MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctTrigger);
			edTriggerHeader.ReadOnly := True;
		end;

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
	finally
		edEditor.SetFocus;
	end;
end;

function TfrmTriggerEditor.CanObjectDrop: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := not FNewObject;
end;

procedure TfrmTriggerEditor.DoObjectDrop;
var
	frmDropObject: TfrmDropObject;
	DoClose: Boolean;

begin
	if MessageDlg('Are you sure that you wish to drop the trigger "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctTrigger, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

function TfrmTriggerEditor.CanSaveDoco: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsDocoView then
		Result := framDoco.CanSaveDoco;
end;

procedure TfrmTriggerEditor.DoObjectProperties;
var
	Idx: Integer;
	Active, NowActive: Boolean;
	F: TfrmNewTrigger;

begin
	F := TfrmNewTrigger.Create(Self);
	try
		qryTrigger.BeginBusy(False);
		F.Caption := 'Properties for ' + FObjectName;

		qryTrigger.Close;
		qryTrigger.SQL.Clear;
		if ShouldBeQuoted(FObjectName) then
			qryTrigger.SQL.Add('select * from RDB$TRIGGERS where RDB$TRIGGER_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ';')
		else
			qryTrigger.SQL.Add('select * from RDB$TRIGGERS where RDB$TRIGGER_NAME = ' + AnsiQuotedStr(AnsiUpperCase(FObjectName), '''') + ';');
		qryTrigger.Open;
		if (qryTrigger.EOF and qryTrigger.BOF) Then
			Exit;

		F.edTriggerName.Text := FObjectName;
		F.edTriggerName.Enabled := False;

		F.cmbTables.Items := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].TableList;
		for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].ViewList.Count - 1 do
			F.cmbTables.Items.Add(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].ViewList[Idx]);

		for Idx := 0 to F.cmbTables.Items.Count - 1 do
			if F.cmbTables.Items[Idx] = qryTrigger.FieldByName('RDB$RELATION_NAME').AsString then
			begin
				F.cmbTables.ItemIndex := Idx;
				Break;
			end;
		F.cmbTables.Enabled := False;

		F.cmbActive.ItemIndex := qryTrigger.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger;
		if qryTrigger.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger = 0 then
			Active := True
		else
			Active := False;

		F.cmbTrigPos.ItemIndex := qryTrigger.FieldByName('RDB$TRIGGER_TYPE').AsInteger - 1;
		F.cmbTrigPos.Enabled := False;

		F.UpDown1.Position := qryTrigger.FieldByName('RDB$TRIGGER_SEQUENCE').AsInteger;
		F.UpDown1.Enabled := False;
		qryTrigger.Close;
		qryTrigger.IB_Transaction.Commit;

		if F.ShowModal = mrOK then
		begin
			case F.cmbActive.ItemIndex of
				0:
					NowActive := True;
				1:
					NowActive := False;
				else
					NowActive := False;
			end;

			if Active and not(NowActive) then
			begin
				if MessageDlg('Deactivate Trigger?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
				begin
					try
						qryTrigger.SQL.Clear;
						if ShouldBeQuoted(FObjectName) then
							qryTrigger.SQL.Add('alter trigger ' + MakeQuotedIdent(FObjectName, ISInterbase6, SQLDialect) + ' inactive')
						else
							qryTrigger.SQL.Add('alter trigger ' + FObjectName + ' inactive');
						qryTrigger.ExecSQL;
						qryTrigger.IB_Transaction.Commit;

						if ShouldBeQuoted(F.cmbTables.Text) then
							FHeader.Table := MakeQUotedIdent(F.cmbTables.Text, FIsInterbase6, FSQLDialect)
						else
							FHeader.Table := F.cmbTables.Text;

						FTableName := F.cmbTables.Text;
						FHeader.Active := F.cmbActive.Text;
						FHeader.Position := F.cmbTrigPos.Text;
						FHeader.FireOrder := F.edPosition.Text;
						edTriggerHeader.Text := FHeader.GetCreateText;

					except
						on E: Exception do
							AddError(E.message);
					end;
				end;
			end;

			if not(Active) and NowActive then
			begin
				if MessageDlg('Activate Trigger?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
				begin
					try
						qryTrigger.SQL.Clear;
						if ShouldBeQuoted(FObjectName) then
							qryTrigger.SQL.Add('alter trigger ' + MakeQuotedIdent(FObjectName, ISInterbase6, SQLDialect) + ' active')
						else
							qryTrigger.SQL.Add('alter trigger ' + FObjectName + ' active');
						qryTrigger.ExecSQL;
						qryTrigger.IB_Transaction.Commit;

						if ShouldBeQuoted(F.cmbTables.Text) then
							FHeader.Table := MakeQuotedIdent(F.cmbTables.Text, FIsInterbase6, FSQLDialect)
						else
							FHeader.Table := F.cmbTables.Text;

						FTableName := F.cmbTables.Text;
						FHeader.Active := F.cmbActive.Text;
						FHeader.Position := F.cmbTrigPos.Text;
						FHeader.FireOrder := F.edPosition.Text;
						edTriggerHeader.Text := FHeader.GetCreateText;
					except
						on E: Exception do
							AddError(E.Message);
					end;
				end;
			end;
		end;
	finally
		qryTrigger.EndBusy;
		F.Free;
	end;
end;

procedure TfrmTriggerEditor.DoSaveDoco;
begin
	framDoco.SaveDoco;
end;

function TfrmTriggerEditor.CanReplace: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			Result := edEditor.Lines.Count > 0;

		PG_DOCO:
			Result := framDoco.CanReplace;
	end;
end;

procedure TfrmTriggerEditor.DoReplace;
begin
	case pgObjectEditor.ActivePageIndex of
		PG_EDIT:
			edEditor.WSReplace;

		PG_DOCO:
			framDoco.WSReplace;
	end;
end;

function TfrmTriggerEditor.CanSaveAsTemplate: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsObject then
		Result := edEditor.Lines.Count > 0
end;

procedure TfrmTriggerEditor.DoSaveAsTemplate;
var
	frmInputDialog: TfrmInputDialog;

begin
	frmInputDialog := TfrmInputDialog.Create(Self);
	try
		frmInputDialog.Caption := 'Save Trigger Template';
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

function TfrmTriggerEditor.CanQueryBuilder: Boolean;
begin
	Result := False;
end;

procedure TfrmTriggerEditor.DoQueryBuilder;
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

procedure TfrmTriggerEditor.OpenMessages;
begin
	pnlMessages.Visible := True;
	pnlMessages.Height := MarathonIDEInstance.CurrentProject.ResultsPanelHeight;
	stsEditor.Top := Height;
end;

procedure TfrmTriggerEditor.AddCompileError(ErrorText: String);
begin
	inherited;
	OpenMessages;
	AddError(ErrorText);
end;

procedure TfrmTriggerEditor.ClearErrors;
begin
	inherited;
	lstResults.Collection.Clear;
end;

procedure TfrmTriggerEditor.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

procedure TfrmTriggerEditor.SetObjectModified(Value: Boolean);
begin
	inherited;
	FObjectModified := False;
end;

procedure TfrmTriggerEditor.SetObjectName(Value: String);
begin
	inherited;
	FObjectName := Value;
	InternalCaption := 'Trigger - [' + FObjectName + ']';
	IT.Caption := Caption;
end;

procedure TfrmTriggerEditor.pnlMessagesResize(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.CurrentProject.ResultsPanelHeight := pnlMessages.Height;
	stsEditor.Top := Height;
end;

function TfrmTriggerEditor.CanObjectAddToProject: Boolean;
begin
	Result := False;
end;

procedure TfrmTriggerEditor.DoObjectAddToProject;
begin
	inherited;
end;

function TfrmTriggerEditor.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

procedure TfrmTriggerEditor.FormDestroy(Sender: TObject);
begin
	inherited;
	FNewTriggerProperties.Free;
	IT.Free;
end;

function TfrmTriggerEditor.CanObjectProperties: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsObject;
end;

function TfrmTriggerEditor.GetTableName: String;
begin
	Result := FTableName;
end;

procedure TfrmTriggerEditor.edEditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
	inherited;
	edEditorChange(Sender);
end;

procedure TfrmTriggerEditor.FormShow(Sender: TObject);
begin
  inherited;
	ActiveControl := edEditor;
end;

end.

