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
// $Id: MarathonOptions.pas,v 1.7 2006/10/22 06:04:28 rjmills Exp $

unit MarathonOptions;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, ComCtrls, Registry, Buttons, SynEditHighlighter, SynHighlighterSQL, SynEdit, SyntaxMemoWithStuff2, NewColorGrd;

type
  TfrmMarathonOptions = class(TForm)
    btnOK: TButton;
		btnCancel: TButton;
    btnHelp: TButton;
    pgOptions: TPageControl;
    tsFileLocs: TTabSheet;
    tsEditor: TTabSheet;
    pgEditor: TPageControl;
    tsEditOptions: TTabSheet;
    tsSQLSmarts: TTabSheet;
		Label6: TLabel;
		chkSQLKeyword: TCheckBox;
		chkTablesSQLSmarts: TCheckBox;
    chkFldSQLSmarts: TCheckBox;
    chkSPSQLSmarts: TCheckBox;
    chkTrigSQLSmarts: TCheckBox;
    chkExceptSQLSmarts: TCheckBox;
    chkGenSQLSmarts: TCheckBox;
		Bevel1: TBevel;
    Bevel2: TBevel;
		tsGeneral: TTabSheet;
    tsSQLInsight: TTabSheet;
    Bevel4: TBevel;
    tbDelay: TTrackBar;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    lstTemplates: TListView;
    edSQLInsightCode: TSyntaxMemoWithStuff2;
		btnSQLIAdd: TButton;
    btnSQLIEdit: TButton;
    btnSQLIDelete: TButton;
    chkSmartsUDFS: TCheckBox;
    Label13: TLabel;
    edDefProjectDir: TEdit;
    btnDefProjectDir: TSpeedButton;
    Label14: TLabel;
    edDefScriptDir: TEdit;
    btnDefScriptDir: TSpeedButton;
		chkCapitalise: TCheckBox;
    chkPromptTrans: TCheckBox;
    tsData: TTabSheet;
    Label16: TLabel;
    cmbDefaultView: TComboBox;
    Label17: TLabel;
		edFloatDisplayFormat: TEdit;
		Label18: TLabel;
    edIntDisplayFormat: TEdit;
		Label19: TLabel;
    edCharDisplayWidth: TEdit;
    udCharDisplayWidth: TUpDown;
    Label20: TLabel;
    edDateDisplayFormat: TEdit;
    Label21: TLabel;
    edSnippetsFolder: TEdit;
    btnDefCodeSnippetsDir: TSpeedButton;
    synOptions: TSynSQLSyn;
    chkSPParams: TCheckBox;
    chkOpenProject: TCheckBox;
    Label22: TLabel;
    edExtractDDLFolder: TEdit;
    btnDefExtractDDLDir: TSpeedButton;
    tsKeyboard: TTabSheet;
		btnEditKeys: TButton;
    chkSQLSave: TCheckBox;
    chkOpenLastProject: TCheckBox;
    chkShowSystemInPerformance: TCheckBox;
    chkShowPerformData: TCheckBox;
    chkShowQueryPlan: TCheckBox;
    tsDisplay: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    cmbEditorFont: TComboBox;
    cmbFontSize: TComboBox;
    pnlFontSample: TPanel;
    tsColors: TTabSheet;
		Label3: TLabel;
    Label4: TLabel;
		lstElements: TListBox;
    clrGrid: TMarathonColorGrid;
    edSample: TSyntaxMemoWithStuff2;
    gbxAttributes: TGroupBox;
    chkBold: TCheckBox;
    chkItalic: TCheckBox;
		chkUnderLine: TCheckBox;
    Label23: TLabel;
    edDateTimeDisplayFormat: TEdit;
    Label24: TLabel;
    edTimeDisplayFormat: TEdit;
    tsSQLTrace: TTabSheet;
    Label25: TLabel;
    chkConnection: TCheckBox;
    chkTransaction: TCheckBox;
    chkStatement: TCheckBox;
    chkRow: TCheckBox;
    chkBlob: TCheckBox;
    chkArray: TCheckBox;
    Label26: TLabel;
    chkAllocate: TCheckBox;
    chkPrepare: TCheckBox;
    chkExecute: TCheckBox;
    chkExecuteImmediate: TCheckBox;
    chkMultiInstances: TCheckBox;
    GroupBox1: TGroupBox;
    chkAutoIndent: TCheckBox;
    chkInsertMode: TCheckBox;
    chkLineNumbers: TCheckBox;
    GroupBox2: TGroupBox;
    chkHighlighting: TCheckBox;
    Label7: TLabel;
    edBlockIndent: TEdit;
    udBlockIndent: TUpDown;
    GroupBox3: TGroupBox;
    Label15: TLabel;
    cmbRightMargin: TComboBox;
    chkVisibleGutter: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbEditorFontChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cmbFontSizeChange(Sender: TObject);
    procedure lstElementsClick(Sender: TObject);
    procedure clrGridChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
		procedure lstTemplatesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
		procedure btnSQLIAddClick(Sender: TObject);
		procedure btnSQLIEditClick(Sender: TObject);
		procedure btnSQLIDeleteClick(Sender: TObject);
		procedure edSQLInsightCodeChange(Sender: TObject);
		procedure btnDefProjectDirClick(Sender: TObject);
		procedure btnDefScriptDirClick(Sender: TObject);
		procedure btnDefCodeSnippetsDirClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure btnDefExtractDDLDirClick(Sender: TObject);
		procedure btnEditKeysClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		FFonts: TStringList;
		FLocalErrorFore: TColor;
		FLocalErrorBack: TColor;
		FLockOut: Boolean;
		FCanSaveBindings: Boolean;
		{ True while the body pane is being filled from a template, so its own
		  OnChange does not write it straight back. }
		FLoadingTemplate: Boolean;
		procedure UpdateSample;
	public
		{ Public declarations }
		{ Refills the SQL Insight tab from the template list. }
		procedure RefreshTemplateList;
	end;

{ The code templates, kept beside the executable. Declared here because this is
  where they are edited, and called from startup so an editor can expand one
  without the Options dialog ever having been opened. }
procedure LoadCodeTemplates;
procedure SaveCodeTemplates;

implementation

uses Globals, HelpMap, MarathonMain, GSSRegistry, InputDialog, SQLInsightItem, FirebirdKeywords, KeyBindingEditor, CodeTemplates;

{$R *.lfm}

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
	FontType: Integer; Data: Pointer): Integer; stdcall;
begin
	if (LogFont.lfPitchAndFamily and FIXED_PITCH) = 1 then
		TStrings(Data).Add(LogFont.lfFaceName);
	Result := 1;
end;

procedure TfrmMarathonOptions.FormCreate(Sender: TObject);
var
	Idx: Integer;

begin
	pgOptions.ActivePage := tsGeneral;

	HelpContext := IDH_Marathon_Options;
	// Load options from globals and set current control contents from them
	// General
	chkMultiInstances.Checked := gMultiInstances;
	chkPromptTrans.Checked := gPromptTrans;
	chkSPParams.Checked := gAlwaysSPParams;
	chkSQLSave.Checked := gSQLSave;
	chkOpenLastProject.Checked := gOpenLastProject;
	chkOpenProject.Checked := gOpenProjectOnStartup;
	chkShowPerformData.Checked := gShowPerformData;
	chkShowSystemInPerformance.Checked := gShowSystemInPerformance;
	chkShowQueryPlan.Checked := gShowQueryPlan;

	// Data
	cmbDefaultView.ItemIndex := gDefaultView;
	edFloatDisplayFormat.Text := gFloatDisplayFormat;
	edIntDisplayFormat.Text := gIntDisplayFormat;
	edDateDisplayFormat.Text := gDateDisplayFormat;
	edDateTimeDisplayFormat.Text := gDateTimeDisplayFormat;
	edTimeDisplayFormat.Text := gTimeDisplayFormat;
	udCharDisplayWidth.Position := gCharDisplayWidth;

	// File Locations
	edDefProjectDir.Text := gDefProjectDir;
	edDefScriptDir.Text := gDefScriptDir;
	edExtractDDLFolder.Text := gExtractDDLDir;
	edSnippetsFolder.Text := gSnippetsDir;

	// Editor
	synOptions.LoadFromRegistry(HKEY_CURRENT_USER, REG_SETTINGS_HIGHLIGHTING);
	{ So the preview in this dialog highlights the same words the editors do. }
	ApplyFirebirdKeywords(synOptions);

	// Editor Display
	FFonts := TStringList.Create;
	FFonts.Assign(Screen.Fonts);
	cmbEditorFont.Items := FFonts;
	cmbEditorFont.ItemIndex := 0;
	cmbFontSize.ItemIndex := 0;

	// Set the fonts combo to the current value
	for Idx := 0 to cmbEditorFont.Items.Count - 1 do
		if cmbEditorFont.Items[Idx] = gEditorFontName then
		begin
			cmbEditorFont.ItemIndex := Idx;
			Break;
		end;

	// Set the size combo to the current value
	for Idx := 0 to cmbFontSize.Items.Count - 1 do
		if StrToInt(cmbFontSize.Items[Idx]) = gEditorFontSize then
		begin
			cmbFontSize.ItemIndex := Idx;
			Break;
		end;
	cmbEditorFont.OnChange(cmbEditorFont);
	cmbFontSize.OnChange(cmbFontSize);

	// Editor Colors
	edSample.Text := 'create procedure set_stock_levels(' + #13#10 +
		' stock_nb varchar(15),' + #13#10 +
		' level numeric(15, 2))' + #13#10 +
		'as' + #13#10 +
		'' + #13#10 +
		'  declare variable temp varchar(15);' + #13#10 +
		'' + #13#10 +
		'begin' + #13#10 +
		'  /* comment */' + #13#10 +
		'  temp = ''STOCK01'';' + #13#10 +
		'  suspend;' + #13#10 +
		'end';
	edSample.SelectedColor.Foreground := gMarkedBlockFontColor;
	edSample.SelectedColor.Background := gMarkedBlockBGColor;

	lstElements.ItemIndex := 0;
	lstElementsClick(Self);
	UpdateSample;

	FLocalErrorFore := gErrorLineFontColor;
	FLocalErrorBack := gErrorLineBGColor;

	// Editor Options
	chkAutoIndent.Checked := gAutoIndent;
	chkInsertMode.Checked := gInsertMode;
	chkHighlighting.Checked := gSyntaxHighlight;
	udBlockIndent.Position := gBlockIndent;
	cmbRightMargin.Text := IntToStr(gRightMargin);
  chkVisibleGutter.checked := gVisibleGutter;

	// Editor SQLSmarts
	if gSQLKeyWords then
		chkSQLKeyword.Checked := True
	else
		chkSQLKeyword.Checked := False;
	if gTableNames then
		chkTablesSQLSmarts.Checked := True
	else
		chkTablesSQLSmarts.Checked := False;
	if gFieldNames then
		chkFldSQLSmarts.Checked := True
	else
		chkFldSQLSmarts.Checked := False;
	if gStoredProcNames then
		chkSPSQLSmarts.Checked := True
	else
		chkSPSQLSmarts.Checked := False;
	if gTriggerNames then
		chkTrigSQLSmarts.Checked := True
	else
		chkTrigSQLSmarts.Checked := False;
	if gExceptionNames then
		chkExceptSQLSmarts.Checked := True
	else
		chkExceptSQLSmarts.Checked := False;
	if gGeneratorNames then
		chkGenSQLSmarts.Checked := True
	else
		chkGenSQLSmarts.Checked := False;
	if gUDFNames then
		chkSmartsUDFS.Checked := True
	else
		chkSmartsUDFS.Checked := False;
	chkCapitalise.Checked := gCapitalise;
	tbDelay.Position := gListDelay;

	{ The templates. Every handler on this tab used to say only that
	  SQLInsightList was unavailable, so the tab looked complete, held nothing
	  and saved nothing. }
	LoadCodeTemplates;
	RefreshTemplateList;
	edSQLInsightCode.Lines.Clear;

	// SQL Trace
	chkConnection.Checked := gTraceConnection;
	chkTransaction.Checked := gTraceTransaction;
	chkStatement.Checked := gTraceStatement;
	chkRow.Checked := gTraceRow;
	chkBlob.Checked := gTraceBlob;
	chkArray.Checked := gTraceArray;

	chkAllocate.Checked := gTraceAllocate;
	chkPrepare.Checked := gTracePrepare;
	chkExecute.Checked := gTraceExecute;
	chkExecuteImmediate.Checked := gTraceExecuteImmediate;
end;

{ Where the templates live: beside the executable, like the other per-user
  files this application keeps. }
function CodeTemplatesFileName: String;
begin
	Result := ExtractFilePath(Application.ExeName) + 'templates.dat';
end;

procedure LoadCodeTemplates;
var
	Lines: TStringList;
begin
	Lines := TStringList.Create;
	try
		if FileExists(CodeTemplatesFileName) then
		begin
			try
				Lines.LoadFromFile(CodeTemplatesFileName);
				GlobalCodeTemplates.LoadFromText(Lines.Text);
			except
				{ An unreadable file is not worth refusing over; the starter set is
				  better than an empty tab. }
				on E: Exception do
					GlobalCodeTemplates.Clear;
			end;
		end;
		{ Only when there is nothing at all - a user who has deliberately deleted
		  every template should not have them come back. }
		if GlobalCodeTemplates.Count = 0 then
			GlobalCodeTemplates.AddDefaults;
	finally
		Lines.Free;
	end;
end;

procedure SaveCodeTemplates;
var
	Lines: TStringList;
begin
	Lines := TStringList.Create;
	try
		Lines.Text := GlobalCodeTemplates.SaveToText;
		try
			Lines.SaveToFile(CodeTemplatesFileName);
		except
			on E: Exception do
				MessageDlg('The code templates could not be saved: ' + E.Message,
					mtWarning, [mbOK], 0);
		end;
	finally
		Lines.Free;
	end;
end;

procedure TfrmMarathonOptions.RefreshTemplateList;
var
	Idx: Integer;
begin
	lstTemplates.Items.Clear;
	for Idx := 0 to GlobalCodeTemplates.Count - 1 do
		with lstTemplates.Items.Add do
		begin
			Caption := GlobalCodeTemplates[Idx].Name;
			SubItems.Add(GlobalCodeTemplates[Idx].Description);
		end;
end;

procedure TfrmMarathonOptions.lstTemplatesChange(Sender: TObject;	Item: TListItem; Change: TItemChange);
var
	T: TCodeTemplate;
begin
	{ Fired for deselection too, with the item that was let go - so writing the
	  body pane back at that point would put one template's text onto
	  another. }
	if (Change <> ctState) or not Assigned(Item) or not Item.Selected then
		Exit;
	FLoadingTemplate := True;
	try
		T := GlobalCodeTemplates.FindByName(Item.Caption);
		if Assigned(T) then
			edSQLInsightCode.Lines.Assign(T.Body)
		else
			edSQLInsightCode.Lines.Clear;
	finally
		FLoadingTemplate := False;
	end;
end;

procedure TfrmMarathonOptions.UpdateSample;
begin
	edSample.Font.Name := cmbEditorFont.Text;
	edSample.Font.Size := StrToInt(cmbFontSize.Text);
end;

procedure TfrmMarathonOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FFonts.Free;
end;

procedure TfrmMarathonOptions.cmbEditorFontChange(Sender: TObject);
begin
	pnlFontSample.Font.Name := TComboBox(Sender).Text;
	UpdateSample;
end;

procedure TfrmMarathonOptions.cmbFontSizeChange(Sender: TObject);
begin
	pnlFontSample.Font.Size := StrToInt(TComboBox(Sender).Text);
	UpdateSample;
end;

procedure TfrmMarathonOptions.btnOKClick(Sender: TObject);
begin
	try
		StrToInt(cmbRightMargin.Text);
	except
		on E : Exception do
		begin
			MessageDlg('Right Margin Setting must be a number.', mtError, [mbOK], 0);
			Exit;
		end;
	end;

	try
		FormatDateTime(edDateDisplayFormat.Text, Now);
	except
		on E : Exception do
		begin
			MessageDlg('"' + edDateDisplayFormat.Text + '" is not a valid date format specifier.', mtError, [mbOK], 0);
			edDateDisplayFormat.SetFocus;
			Exit;
		end;
	end;

	synOptions.SaveToRegistry(HKEY_CURRENT_USER, REG_SETTINGS_HIGHLIGHTING);
	SaveCodeTemplates;

	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_BASE, False) then
			begin
				// General
				WriteBool('MultiInstances', chkMultiInstances.Checked);
				WriteBool('PromptTrans', chkPromptTrans.Checked);
				WriteBool('AlwaysSPParams', chkSPParams.Checked);
				WriteBool('SQLSave', chkSQLSave.Checked);
				WriteBool('OpenLastProject', chkOpenLastProject.Checked);
				WriteBool('OpenProjectOnStartup', chkOpenProject.Checked);
				WriteBool('ShowPerformData', chkShowPerformData.Checked);
				WriteBool('ShowSystemInPerformance', chkShowSystemInPerformance.Checked);
				WriteBool('ShowQueryPlan', chkShowQueryPlan.Checked);

				// Data
				WriteInteger('DefaultView', cmbDefaultView.ItemIndex);
				WriteString('FloatDisplayFormat', edFloatDisplayFormat.Text);
				WriteString('IntDisplayFormat', edIntDisplayFormat.Text);
				WriteString('DateDisplayFormat', edDateDisplayFormat.Text);
				WriteString('DateTimeDisplayFormat', edDateTimeDisplayFormat.Text);
				WriteString('TimeDisplayFormat', edTimeDisplayFormat.Text);
				WriteInteger('CharDisplayWidth', udCharDisplayWidth.Position);

				// File Locations
				WriteString('DefaultProjectDir', edDefProjectDir.Text);
				WriteString('DefaultScriptDir', edDefScriptDir.Text);
				WriteString('ExtractDDLDir', edExtractDDLFolder.Text);
				WriteString('SnippetsDir', edSnippetsFolder.Text);

				CloseKey;
			end;

			// Editor
			if OpenKey(REG_SETTINGS_EDITOR, True) then
			begin
				// Editor Options
				WriteBool('AutoIndent', chkAutoIndent.Checked);
				WriteBool('InsertMode', chkInsertMode.Checked);
				WriteBool('SyntaxHighlight', chkHighlighting.Checked);
				WriteInteger('BlockIndent', udBlockIndent.Position);
				WriteInteger('RightMargin', StrToInt(cmbRightMargin.Text));
        WriteBool('LineNumbers', chkLineNumbers.Checked);

				// Editor Display
				WriteString('EditorFontName', cmbEditorFont.Text);
				WriteInteger('EditorFontSize', StrToInt(cmbFontSize.Text));
        writeBool('EditorVisibleGutter', chkVisibleGutter.checked);

				// Editor Colors
				WriteInteger('MarkedBlockFontColor', LongInt(edSample.SelectedColor.Foreground));
				WriteInteger('MarkedBlockBGColor', LongInt(edSample.SelectedColor.Background));
				WriteInteger('ErrorLineFontColor', LongInt(FLocalErrorFore));
				WriteInteger('ErrorLineBGColor', LongInt(FLocalErrorBack));
				CloseKey;
			end;

			// Editor SQLSmarts
			if OpenKey(REG_SETTINGS_SQLSMARTS, True) then
			begin
				WriteBool('SQLKeywords', chkSQLKeyword.Checked);
				WriteBool('TableNames', chkTablesSQLSmarts.Checked);
				WriteBool('FieldNames', chkFldSQLSmarts.Checked);
				WriteBool('SPNames', chkSPSQLSmarts.Checked);
				WriteBool('TriggerNames', chkTrigSQLSmarts.Checked);
				WriteBool('ExceptionNames', chkExceptSQLSmarts.Checked);
				WriteBool('GeneratorNames', chkGenSQLSmarts.Checked);
				WriteBool('UDFNames', chkSmartsUDFS.Checked);
				WriteBool('Capitalise', chkCapitalise.Checked);
				WriteInteger('ListDelay', tbDelay.Position);
				CloseKey;
			end;

			// Editor SQL Trace
			if OpenKey(REG_SETTINGS_SQLTRACE, True) then
			begin
				WriteBool('Connection', chkConnection.Checked);
				WriteBool('Transaction', chkTransaction.Checked);
				WriteBool('Statement', chkStatement.Checked);
				WriteBool('Row', chkRow.Checked);
				WriteBool('Blob', chkBlob.Checked);
				WriteBool('Array', chkArray.Checked);

				WriteBool('Allocate', chkAllocate.Checked);
				WriteBool('Prepare', chkPrepare.Checked);
				WriteBool('Execute', chkExecute.Checked);
				WriteBool('ExecuteImmediate', chkExecuteImmediate.Checked);
				CloseKey;
			end;
		finally
			Free;
		end;
	ModalResult := mrOK;
end;


procedure TfrmMarathonOptions.lstElementsClick(Sender: TObject);
begin
	FLockOut := True;
	try
		case lstElements.ItemIndex of
			0: // Comment
				begin
					clrGrid.ForeGroundColor := synOptions.CommentAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.CommentAttri.Background;
					chkBold.Checked := fsBold in synOptions.CommentAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.CommentAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.CommentAttri.Style;
				end;

			1: // String
				begin
					clrGrid.ForeGroundColor := synOptions.StringAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.StringAttri.Background;
					chkBold.Checked := fsBold in synOptions.StringAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.StringAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.StringAttri.Style;
				end;

			2: // Keyword
				begin
					clrGrid.ForeGroundColor := synOptions.KeyAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.KeyAttri.Background;
					chkBold.Checked := fsBold in synOptions.KeyAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.KeyAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.KeyAttri.Style;
				end;

			3: // Operator
				begin
					clrGrid.ForeGroundColor := synOptions.SymbolAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.SymbolAttri.Background;
					chkBold.Checked := fsBold in synOptions.SymbolAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.SymbolAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.SymbolAttri.Style;
				end;

			4: // Identifier
				begin
					clrGrid.ForeGroundColor := synOptions.IdentifierAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.IdentifierAttri.Background;
					chkBold.Checked := fsBold in synOptions.IdentifierAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.IdentifierAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.IdentifierAttri.Style;
				end;

			5: // Function
				begin
					clrGrid.ForeGroundColor := synOptions.FunctionAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.FunctionAttri.Background;
					chkBold.Checked := fsBold in synOptions.FunctionAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.FunctionAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.FunctionAttri.Style;
				end;

			6: // Datatype
				begin
					clrGrid.ForeGroundColor := synOptions.DataTypeAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.DataTypeAttri.Background;
					chkBold.Checked := fsBold in synOptions.DataTypeAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.DataTypeAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.DataTypeAttri.Style;
				end;

			7: // Number
				begin
					clrGrid.ForeGroundColor := synOptions.NumberAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.NumberAttri.Background;
					chkBold.Checked := fsBold in synOptions.NumberAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.NumberAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.NumberAttri.Style;
				end;

			8: // Default
				begin
					clrGrid.ForeGroundColor := synOptions.SpaceAttri.Foreground;
					clrGrid.BackGroundColor := synOptions.SpaceAttri.Background;
					chkBold.Checked := fsBold in synOptions.SpaceAttri.Style;
					chkItalic.Checked := fsItalic in synOptions.SpaceAttri.Style;
					chkUnderLine.Checked := fsUnderline in synOptions.SpaceAttri.Style;
				end;

			9: // Marked Block
				begin
					clrGrid.ForeGroundColor := edSample.SelectedColor.Foreground;
					clrGrid.BackGroundColor := edSample.SelectedColor.Background;
				end;

			10: // Error Line
				begin
					clrGrid.ForeGroundColor := FLocalErrorFore;
					clrGrid.BackGroundColor := FLocalErrorBack;
				end;
		end;
	finally
		FLockOut := False;
	end;
end;

procedure TfrmMarathonOptions.clrGridChange(Sender: TObject);
begin
	if not FLockout then
	begin
		case lstElements.ItemIndex of
			0: // Comment
				begin
					synOptions.CommentAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.CommentAttri.Background := clrGrid.BackGroundColor;
					synOptions.CommentAttri.Style := [];
					if chkBold.Checked then
						synOptions.CommentAttri.Style := synOptions.CommentAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.CommentAttri.Style := synOptions.CommentAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.CommentAttri.Style := synOptions.CommentAttri.Style + [fsUnderline];
				end;

			1: // String
				begin
					synOptions.StringAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.StringAttri.Background := clrGrid.BackGroundColor;
					synOptions.StringAttri.Style := [];
					if chkBold.Checked then
						synOptions.StringAttri.Style := synOptions.StringAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.StringAttri.Style := synOptions.StringAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.StringAttri.Style := synOptions.StringAttri.Style + [fsUnderline];
				end;

			2: // Keyword
				begin
					synOptions.KeyAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.KeyAttri.Background := clrGrid.BackGroundColor;
					synOptions.KeyAttri.Style := [];
					if chkBold.Checked then
						synOptions.KeyAttri.Style := synOptions.KeyAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.KeyAttri.Style := synOptions.KeyAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.KeyAttri.Style := synOptions.KeyAttri.Style + [fsUnderline];
				end;

			3: // Operator
				begin
					synOptions.SymbolAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.SymbolAttri.Background := clrGrid.BackGroundColor;
					synOptions.SymbolAttri.Style := [];
					if chkBold.Checked then
						synOptions.SymbolAttri.Style := synOptions.SymbolAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.SymbolAttri.Style := synOptions.SymbolAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.SymbolAttri.Style := synOptions.SymbolAttri.Style + [fsUnderline];
				end;

			4: // Identifier
				begin
					synOptions.IdentifierAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.IdentifierAttri.Background := clrGrid.BackGroundColor;
					synOptions.IdentifierAttri.Style := [];
					if chkBold.Checked then
						synOptions.IdentifierAttri.Style := synOptions.IdentifierAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.IdentifierAttri.Style := synOptions.IdentifierAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.IdentifierAttri.Style := synOptions.IdentifierAttri.Style + [fsUnderline];
				end;

			5: // Function
				begin
					synOptions.FunctionAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.FunctionAttri.Background := clrGrid.BackGroundColor;
					synOptions.FunctionAttri.Style := [];
          if chkBold.Checked then
            synOptions.FunctionAttri.Style := synOptions.FunctionAttri.Style + [fsBold];
          if chkItalic.Checked then
            synOptions.FunctionAttri.Style := synOptions.FunctionAttri.Style + [fsItalic];
          if chkUnderLine.Checked then
            synOptions.FunctionAttri.Style := synOptions.FunctionAttri.Style + [fsUnderline];
				end;

			6: // Datatype
				begin
					synOptions.DataTypeAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.DataTypeAttri.Background := clrGrid.BackGroundColor;
					synOptions.DataTypeAttri.Style := [];
					if chkBold.Checked then
						synOptions.DataTypeAttri.Style := synOptions.DataTypeAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.DataTypeAttri.Style := synOptions.DataTypeAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.DataTypeAttri.Style := synOptions.DataTypeAttri.Style + [fsUnderline];
				end;

			7: // Number
				begin
					synOptions.NumberAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.NumberAttri.Background := clrGrid.BackGroundColor;
					synOptions.NumberAttri.Style := [];
					if chkBold.Checked then
						synOptions.NumberAttri.Style := synOptions.NumberAttri.Style + [fsBold];
					if chkItalic.Checked then
						synOptions.NumberAttri.Style := synOptions.NumberAttri.Style + [fsItalic];
					if chkUnderLine.Checked then
						synOptions.NumberAttri.Style := synOptions.NumberAttri.Style + [fsUnderline];
				end;

			8: // Default
				begin
					synOptions.SpaceAttri.Foreground := clrGrid.ForeGroundColor;
					synOptions.SpaceAttri.Background := clrGrid.BackGroundColor;
					synOptions.SpaceAttri.Style := [];
          if chkBold.Checked then
            synOptions.SpaceAttri.Style := synOptions.SpaceAttri.Style + [fsBold];
          if chkItalic.Checked then
            synOptions.SpaceAttri.Style := synOptions.SpaceAttri.Style + [fsItalic];
          if chkUnderLine.Checked then
						synOptions.SpaceAttri.Style := synOptions.SpaceAttri.Style + [fsUnderline];
				end;

			9: // Marked Block
				begin
					edSample.SelectedColor.Foreground := clrGrid.ForeGroundColor;
					edSample.SelectedColor.Background := clrGrid.BackGroundColor;
				end;

			10: // Error Line
				begin
					FLocalErrorFore := clrGrid.ForeGroundColor;
					FLocalErrorBack := clrGrid.BackGroundColor;
				end;
		end;
	end;
end;

procedure TfrmMarathonOptions.btnHelpClick(Sender: TObject);
begin
	Application.HelpCommand(HELP_CONTEXT, IDH_Marathon_Options);
end;

procedure TfrmMarathonOptions.btnSQLIAddClick(Sender: TObject);
var
	F: TfrmSQLInsight;

begin
	if lstTemplates.Selected <> nil then
	begin
		F := TfrmSQLInsight.Create(Self);
		try
			F.Caption := 'Add Code Template';
			if F.ShowModal = mrOK then
			begin
				GlobalCodeTemplates.Add(F.edShortCut.Text, F.edDescription.Text);
				with lstTemplates.Items.Add do
				begin
					Caption := F.edShortCut.Text;
					SubItems.Add(F.edDescription.Text);
				end;
			end;
		finally
			F.Free;
		end;
	end;
end;

procedure TfrmMarathonOptions.btnSQLIEditClick(Sender: TObject);
var
	F: TfrmSQLInsight;
	T: TCodeTemplate;

begin
	if lstTemplates.Selected <> nil then
	begin
		F := TfrmSQLInsight.Create(Self);
		try
			F.edShortCut.Text := lstTemplates.Selected.Caption;
			F.edDescription.Text := lstTemplates.Selected.SubItems[0];
			F.Caption := 'Edit Code Template';
			if F.ShowModal = mrOK then
			begin
				T := GlobalCodeTemplates.FindByName(lstTemplates.Selected.Caption);
				if Assigned(T) then
				begin
					T.Name := Trim(F.edShortCut.Text);
					T.Description := Trim(F.edDescription.Text);
				end;
				lstTemplates.Selected.Caption := F.edShortCut.Text;
				lstTemplates.Selected.SubItems[0] := F.edDescription.Text;
			end;
		finally
			F.Free;
		end;
	end;
end;

procedure TfrmMarathonOptions.edSQLInsightCodeChange(Sender: TObject);
var
	T: TCodeTemplate;
begin
	{ Not while the pane is being filled from a template - that would write it
	  straight back and, worse, onto whichever one is selected by then. }
	if FLoadingTemplate or not Assigned(lstTemplates.Selected) then
		Exit;
	T := GlobalCodeTemplates.FindByName(lstTemplates.Selected.Caption);
	if Assigned(T) then
		T.Body.Assign(edSQLInsightCode.Lines);
end;

procedure TfrmMarathonOptions.btnSQLIDeleteClick(Sender: TObject);
begin
	if lstTemplates.Selected <> nil then
	begin
		if MessageDlg('Are you sure you wish to delete the item "' +
			lstTemplates.Selected.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			GlobalCodeTemplates.Delete(
				GlobalCodeTemplates.IndexOfName(lstTemplates.Selected.Caption));
			lstTemplates.Selected.Delete;
			edSQLInsightCode.Lines.Clear;
		end;
	end;
end;

procedure TfrmMarathonOptions.btnDefProjectDirClick(Sender: TObject);
var
	Dir: String;

begin
	Dir := edDefProjectDir.Text;
	if SelectDirectory('Default Project Folder', edDefProjectDir.Text, Dir) then
		edDefProjectDir.Text := Dir;
end;

procedure TfrmMarathonOptions.btnDefScriptDirClick(Sender: TObject);
var
	Dir: String;

begin
	Dir := edDefScriptDir.Text;
	if SelectDirectory('Default Script Folder', edDefScriptDir.Text, Dir) then
		edDefScriptDir.Text := Dir;
end;

procedure TfrmMarathonOptions.btnDefCodeSnippetsDirClick(Sender: TObject);
var
	Dir: String;

begin
	Dir := edSnippetsFolder.Text;
	if SelectDirectory('Code Snippets Folder', edSnippetsFolder.Text, Dir) then
		edSnippetsFolder.Text := Dir;
end;

procedure TfrmMarathonOptions.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgOptions)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgOptions);
end;

procedure TfrmMarathonOptions.FormShow(Sender: TObject);
begin
	pnlFontSample.BevelInner := bvLowered;
	pnlFontSample.BevelOuter := bvNone;
end;

procedure TfrmMarathonOptions.btnDefExtractDDLDirClick(Sender: TObject);
var
	Dir: String;

begin
	Dir := edExtractDDLFolder.Text;
	if SelectDirectory('Extract DDL Folder', edExtractDDLFolder.Text, Dir) then
		edExtractDDLFolder.Text := Dir;
end;

procedure TfrmMarathonOptions.btnEditKeysClick(Sender: TObject);
begin
	{ Empty for the whole of this port: the editor needed TrmKeyBindings, which
	  went with the rest of rmControls. }
	EditKeyBindings(frmMarathonMain.actMain);
end;

end.

{ Old History
	20.03.2002	tmuetze
		+ Added in TfrmMarathonOptions.FormShow the setting of the pnlFontSample
			BevelInner and BevelOuter properties, this has been done to enhance the
			D5 compatibility
	28.01.2002	tmuetze
		* Restructured the options
		+ Added ShowSystemInPerformance, TimeFormat, DateFormat
}

{
$Log: MarathonOptions.pas,v $
Revision 1.7  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.6  2005/11/16 06:44:50  rjmills
General Options Updates

Revision 1.5  2003/12/07 12:20:13  carlosmacao
To allow only one instance of Marathon to run, in desired case.

Revision 1.4  2002/09/23 10:34:11  tmuetze
Revised the SQL Trace functionality, e.g. TIB_Monitor options can now be customized via the Option dialog

Revision 1.3  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
