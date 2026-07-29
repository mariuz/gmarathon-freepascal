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
// $Id: Globals.pas,v 1.15 2007/06/15 21:31:32 rjmills Exp $

unit Globals;

{$MODE Delphi}

interface

uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils, Graphics, ImgList, Registry, ActnList, Dialogs, ExtCtrls, DB, Forms, Controls, Comctrls, DBGrids, StdCtrls, SynEdit, SynEditTypes, SynGutter, StrUtils, IBDatabase, IBQuery, IBCustomDataSet, SyntaxMemoWithStuff2, DOM, XMLRead, XMLWrite, adbpedit, GSSRegistry, MarathonProjectCacheTypes, MenuModule, LMessages, UITheme;

const
  WM_USER = 1024;
	WM_BUGGER_OFF = WM_USER + 101;

var
	gAppPath: String;

	// Marathon global options
	gShowQueryPlan: Boolean;
	gShowPerformData: Boolean;
	gDefProjectDir: String;
	gDefScriptDir: String;
	gSnippetsDir: String;
	gExtractDDLDir: String;
	gOpenProjectOnStartup: Boolean;
	gSQLSave: Boolean;
	gOpenLastProject: Boolean;
	gLastProject: String;
	gDebuggerEnabled: Boolean;
	gViewListInDatabaseManager: Boolean;
	{ Light or dark. Held as the enum rather than a boolean so a third palette
	  does not have to break the setting - see UITheme. }
	gTheme: TThemeKind;

	gPromptTrans: Boolean;
	gAlwaysSPParams: Boolean;
	gShowSystemInPerformance: Boolean;

	// Data formatting options
	gDefaultView: Integer;
	gFloatDisplayFormat: String;
	gIntDisplayFormat: String;
	gDateDisplayFormat: String;
	gDateTimeDisplayFormat: String;
	gTimeDisplayFormat: String;
	gCharDisplayWidth: Integer;

	// General options
	gMultiInstances: Boolean;

	gEditorFontName: String;
	gEditorFontSize: Integer;

	gMarkedBlockFontColor : TColor;
	gMarkedBlockBGColor : TColor;

	gErrorLineFontColor : TColor;
	gErrorLineBGColor : TColor;

	// SQLSmarts Options
	gSQLKeywords: Boolean;
	gTableNames: Boolean;
	gFieldNames: Boolean;
	gStoredProcNames: Boolean;
	gTriggerNames: Boolean;
	gExceptionNames: Boolean;
	gGeneratorNames: Boolean;
	gUDFNames: Boolean;
	gCapitalise: Boolean;

	// Editor options
	gAutoIndent: Boolean;
	gInsertMode: Boolean;
	gSyntaxHighlight: Boolean;
	gBlockIndent: Integer;
	gListDelay: Integer;
	gRightMargin: Integer;
  gLineNumbers: Boolean;
  gVisibleGutter: boolean;

	// SQL Trace options
	gTraceConnection: Boolean;
	gTraceTransaction: Boolean;
	gTraceStatement: Boolean;
	gTraceRow: Boolean;
	gTraceBlob: Boolean;
	gTraceArray: Boolean;

	gTraceAllocate: Boolean;
	gTracePrepare: Boolean;
	gTraceExecute: Boolean;
	gTraceExecuteImmediate: Boolean;

type
	TMRUAction = class(TAction)
	private
		FFileName: String;
	public
		property FileName: String read FFileName write FFileName;
	end;

	TStringTransport = class(TObject)
	public
		Value: String;
	end;

	TDragQueen = class(TDragControlObject)
	private
		function GetText: String; virtual; abstract;
	public
		property DragText: String read GetText;
	end;

	TDragQueenCarla = class(TDragQueen)
	private
		FData: String;
		function GetText: String; override;
	public
		constructor Create(AControl: TControl); override;
		destructor Destroy; override;
		property DragData: String read FData write FData;
	end;

	TDragQueenPearl = class(TDragQueen)
	private
		FData: String;
//    FDragItemType: TNodeType;
		function GetText: String; override;
  public
    constructor Create(AControl : TControl); override;
    destructor Destroy; override;
    property DragItem: String read FData write FData;
//    property DragItemType : TNodeType read FDragItemType write FDragItemType;
  end;

  TDragQueenFiFi = class(TDragQueen)
  private
    FData : TStringList;
//    FDragItemType: TNodeType;
    FItemData: String;
		function GetText: String; override;
	public
    constructor Create(AControl : TControl); override;
    destructor Destroy; override;
    property DragList : TStringList read FData write FData;
    property DragItem: String read FItemData write FItemData;
//    property DragItemType : TNodeType read FDragItemType write FDragItemType;
  end;

  TResultItem = record
    Line: Integer;
    Position: Integer;
		ObjName: String;
    ConnectionName: String;
    ObjType : TGSSCacheType;
    LineText: String;
    SearchString: String;
  end;

	TNodeData = record
		ImageIndex: Integer;
		Caption: String;
		NodeText: String
	end;
	PNodeData = ^TNodeData;

	TExportType = record
    ExType: Integer;
    FirstRowNames: Boolean;
    SepChar: String;
    QualChar: String;
    InsertColumnNames: Boolean;
    InsertColumnNamesSep: Boolean;
  end;

var
  gDaysRemaining: Integer;

const
	G_VERSION = '2.00 Beta3';
	G_INTERNAL_VERSION = 6;

function ConvertFieldType(ftype, flen, fscale, fsubtype, fprecision: Integer; IsInterbase6: Boolean; Dialect: Integer): String;

{ The length to declare a field with, from a row of RDB$FIELDS or a join onto
  it. Pass this to ConvertFieldType instead of RDB$FIELD_LENGTH: for text in a
  multi-byte character set the two differ - a UTF8 varchar(10) has
  RDB$FIELD_LENGTH 40 and RDB$CHARACTER_LENGTH 10 - so the byte length showed
  the user a type four times wider than the one they declared. Null for
  everything else, hence the fallback. Deliberately a second copy of the
  MetaExtractGlobals function of the same name rather than an import: the two
  units both export a ConvertFieldType with different arities, and pulling one
  into the other's clients would change which of those a call resolves to. }
function DeclaredFieldLength(Q: TDataSet): Integer;

{ Adds every icon of a horizontal image strip to an image list, one image per
  cell, with MaskColor taken as transparent.

  Delphi's TImageList.AddMasked split a bitmap wider than the list's image size
  into as many images as it held; LCL's adds the whole bitmap as a *single*
  image - and swallows the exception if anything goes wrong, returning -1, so
  nothing said the strips had not loaded. Every list built from a strip
  therefore held one image, and every icon index above 0 was out of range. That
  is not a cosmetic fault: gtk2's ItemSetImage writes
  Widgets^.Images.Items[AImageIndex] with no bound check of its own, so
  selecting a connection in the object browser raised "List index (1) out of
  bounds" from inside the widgetset. }
procedure AddStripMasked(IL: TCustomImageList; Strip: TBitmap; MaskColor: TColor);

{ Fills an image list from the strip that suits the display.

  The icons are rendered from SVG into one strip per size (see icons/ and
  tools/build_icons.sh), so a high-DPI display gets icons drawn at its own size
  rather than a 16-pixel strip stretched to fit. Which size that is, is
  IconScaling's decision and is tested without a display.

  Falls back to the base strip when the bigger one is missing, so a resource
  file that has not been rebuilt still gives working icons rather than none. }
procedure LoadScaledStrip(IL: TCustomImageList; const BaseResource: String;
	APixelsPerInch: Integer);

{ Lets every IBX dataset owned by AOwner start a transaction for itself when it
  is opened without one.

  The editors share one metadata transaction per connection, and plenty of code
  commits it - the object tree's own queries do, and so does saving. Opening a
  dataset afterwards then fails with "Transaction is not active", because IBX
  will not start one on its own unless told it may: switching tabs in the table
  editor raised exactly that. Rather than guard every Open in every editor, the
  permission is granted once here, which is the behaviour this Delphi-era code
  was written against. }
procedure AllowAutoTransactions(AOwner: TComponent);

{ The predicate that narrows a catalogue query to one schema, for callers that
  have a connection name rather than a connection.

  The object editors get this from their base class; the frames on their tabs
  do not have one - they are frames, and reach their form through an interface
  - so they come here instead. Both end at SchemaNames, so there is one rule.

  Not every catalogue table spells the column rdb$schema_name. The ones that
  hold a reference to another object name that column after the reference -
  rdb$user_privileges has rdb$relation_schema_name, rdb$dependencies has
  rdb$dependent_schema_name and rdb$depended_on_schema_name - and asking those
  for rdb$schema_name is "Column unknown" and a dead tab. Pass AColumn for
  them; the default suits the tables whose rows are the object itself. }
function SchemaClauseFor(const ConnectionName, Schema: String;
  const AColumn: String = ''): String;

{ Teaches the shared SQL highlighter whatever this server reserves.

  Called when a connection opens. Here rather than in the cache because the
  highlighter belongs to the menu data module, and the cache has no business
  knowing about it. }
procedure ApplyConnectionKeywords(ADatabase: TIBDatabase;
	ATransaction: TIBTransaction);
function BracketNear(StartCh: Integer; s: String): Boolean;
function DoNiftyWrap(St: String; Width: Integer): String;
procedure ExportGrid(ExType : TExportType; Q : TDataSet; FieldList : TStringList; TableName: String; FileName: String);
function ParseSection (ParseLine: String; ParseNum: Integer; ParseSep : Char): String;
function StripUglies(S: String): String;
function MakeQuotedIdent(S: String; IB6: Boolean; Dialect: Integer): String;
function StripQuotesFromQuotedIdentifier(S: String): String;
function IsIdentifierQuoted(S: String): Boolean;
function ShouldBeQuoted(S: String): Boolean;
function CheckNameLength(S: String): Boolean;
function ObjectExists(S: String; ObjType : TGSSCacheType; DatabaseName: String;
	Schema: String): Boolean;
function DoesObjectExist(S: String; ObjType : TGSSCacheType; DatabaseName: String;
	Schema: String = ''): Boolean;

procedure ProcessNextTab(PageControl: TPageControl);
procedure ProcessPriorTab(PageControl: TPageControl);

procedure SetupSyntaxEditor(Editor : TSyntaxMemoWithStuff2);
procedure SetupNonSyntaxEditor(Editor : TSyntaxMemoWithStuff2);
procedure GlobalSetBookmark(Editor : TSyntaxMemoWithStuff2; Bookmark: Integer);
function IsABookmarkSet(Editor : TSyntaxMemoWithStuff2; Bookmark: Integer): Boolean;
function LoadEditorContent(Editor: TSyntaxMemoWithStuff2; FileName: String): Boolean;
function SaveEditorContent(Editor: TSyntaxMemoWithStuff2; FileName: String): Boolean;

function SetupEncodingControl(Control : TControl) : Byte;
function EscapeQuotes(I: String): String;
function XMLEscapeQuotes(I: String): String;
function StripQuotes(I: String): String;
procedure EditBlobColumn(BlobField : TField);
procedure CaptureCodeSnippet(Editor: TSyntaxMemoWithStuff2);
function UpdateEditorStatusBar(StatusBar : TStatusBar; Editor : TSyntaxMemoWithStuff2): Boolean;
function GetCharSetValue(CharSetName: String): Integer;
function GetCharSetName(CharSetVal: Integer): String;
function GetCharSetByIndex(Index: Integer): Integer;
function ConvertTabs(Data: String; Editor : TSyntaxMemoWithStuff2): String;
procedure GetCharSetNames(S : TStrings);

function QueryProjectFile(FileName: String): String;

procedure LoadFormPosition(F : TForm);
procedure SaveFormPosition(F : TForm);
procedure ValidateFormState(F:TForm);

procedure LoadSplitterPosition(F : TForm; Panel : TPanel);
procedure SaveSplitterPosition(F : TForm; Panel : TPanel);

function NoLangFormatDateTime(const Format: string; DateTime: TDateTime): string;

procedure GlobalFormatFields(DataSet : TDataSet);

{ Background and text colour for a connection's environment band. Deliberately
  fixed rather than user-configurable: the value of the feature is that "red
  means production" reads the same in every window and on every machine. }
function EnvironmentColor(Env: TConnectionEnvironment): TColor;
function EnvironmentTextColor(Env: TConnectionEnvironment): TColor;

type
	TMarathonScreen = class(TObject)
  private
    function GetHeight: Integer;
		function GetWidth: Integer;
    function GetTop: Integer;
    function GetLeft: Integer;
  public
    function GetMonitor : TMonitor;
    function GetScreenRect : TRect;
    property Height: Integer read GetHeight;
		property Width: Integer read GetWidth;
    property Top: Integer read GetTop;
    property Left: Integer read GetLeft;
	end;

  TTokenType = (tkNone, tkKeyWord, tkIdent, tkNumber, tkString, tkComment,
                tkTerm, tkComma, tkBracket, tkOperator, tkOther);

  TToken = record
    Offset : Longint;
    Len : LongInt;
    TokenType : TTokenType;
    TokenText: String;
  end;

  TParseState = (psNormal, psIdent, psKeyword, psNumber,
                 psString, psComment, psBracket, psOperator,
                 psTerminator, psComma);

  TTextParser = class(TObject)
  private
		FInput: String;
    FTermChar : Char;
    Ch, Next: Char;
    FState : TParseState;
    FOutPut: String;
		FPrior: Boolean;
		FIndex: Integer;
		StrDelimCount: Integer;
		procedure PushChar(Ch: Char);
		procedure Mark;

		procedure SetInput(Value: String);
		function GetNextToken : TToken;
  public
    property NextToken : TToken read GetNextToken;
    property Input: String read FInput write SetInPut;
    property TerminatorChar : Char read FTermChar write FTermChar;
  end;

var
  MarathonScreen : TMarathonScreen;

implementation

uses BlobViewer, SQLAssistantDragAndDrop, MarathonProjectCache, EditorSnippet, MarathonIDE, XlsxWriter, RowEdits, ObjectCatalogue, SchemaNames, IconScaling, SchemaObjects, FirebirdKeywords;

const
  // Firebird BLR type constants (from ibase.h), as stored in
  // RDB$FIELDS.RDB$FIELD_TYPE. Values for the Firebird 3+ types below were
  // verified empirically against a live Firebird 6 server rather than taken
  // from a header, since the int128 code in particular is easy to get wrong
  // (it is 26, historically blr_dec_fixed, not the blr_int128 value of 32
  // used in the wire/BLR layer).
  blr_short        = 7;
  blr_long         = 8;
  blr_float        = 10;
  blr_sql_date     = 12;
  blr_sql_time     = 13;
  blr_text         = 14;
  blr_int64        = 16;
  blr_bool         = 23;   // Firebird 3: BOOLEAN
  blr_dec64        = 24;   // Firebird 4: DECFLOAT(16)
  blr_dec128       = 25;   // Firebird 4: DECFLOAT(34)
  blr_int128       = 26;   // Firebird 4: INT128 / NUMERIC|DECIMAL(38,x)
  blr_double       = 27;
  blr_sql_time_tz  = 28;   // Firebird 4: TIME WITH TIME ZONE
  blr_timestamp_tz = 29;   // Firebird 4: TIMESTAMP WITH TIME ZONE
  blr_timestamp    = 35;
  blr_varying      = 37;
  blr_cstring      = 40;
  blr_blob         = 261;

function TMarathonScreen.GetTop: Integer;
var
	R : TRect;
begin
	R := GetScreenRect;
	Result := R.Top;
end;

function TMarathonScreen.GetLeft: Integer;
var
	R : TRect;
begin
	R := GetScreenRect;
	Result := R.Left;
end;

function TMarathonScreen.GetHeight: Integer;
var
  R : TRect;
begin
	R := GetScreenRect;
  Result := R.Bottom - R.Top;
end;

function TMarathonScreen.GetWidth: Integer;
var
  R : TRect;
begin
  R := GetScreenRect;
	Result := R.Right - R.Left;
end;

function TMarathonScreen.GetScreenRect : TRect;
begin
  if assigned(MarathonIDEInstance) and assigned(MarathonIDEInstance.MainForm) then
     result := MarathonIDEInstance.MainForm.MainFormMonitor.WorkareaRect // frmMarathonMain.Monitor.WorkareaRect;
  else
     result := Application.MainForm.Monitor.WorkareaRect;
end;

function ParseSection (ParseLine: String; ParseNum: Integer; ParseSep : Char): String;
var
  iPos: LongInt;
  i: Integer;
  tmp: String;

begin
  tmp := ParseLine;
  for i := 1 To ParseNum do
  begin
		iPos := Pos(ParseSep, tmp);
    If iPos > 0 Then
    begin
      if i = ParseNum Then
      begin
	Result := Copy(tmp, 1, iPos - 1);
        Exit;
      end
			else
      begin
        Delete(tmp, 1, iPos);
      end;
    end
    else
      If ParseNum > i Then
      begin
        Result := '';
				Exit;
      end
      else
      begin
        Result := tmp;
        Exit;
      end;
  end;
end; { ParseSection }

function EscapeQuotes(I: String): String;
var
  Idx: Integer;

begin
  Result := '';
  for Idx := 1 to Length(I) do
  begin
    if I[Idx] = '"' then
			Result := Result + '"';

		if I[Idx] = '''' then
			Result := Result + '''';

		Result := Result + I[Idx];
	end;
end;

function XMLEscapeQuotes(I: String): String;
var
	Idx: Integer;

begin
	Result := '';
	for Idx := 1 to Length(I) do
	begin
		if I[Idx] = '"' then
			Result := Result + '&34'
		else
			Result := Result + I[Idx];
	end;
end;

function StripQuotes(I: String): String;
var
  Idx: Integer;

begin
  Result := '';
  for Idx := 1 to Length(I) do
	begin
    if not (I[Idx] in ['"', '''']) then
      Result := Result + I[Idx];
  end;
end;

function SetupEncodingControl(Control : TControl) : Byte;
begin
	if Control is TDBGrid then
		TDBGrid(Control).Font.CharSet := MarathonIDEInstance.CurrentProject.Encoding;
  if Control is TDBPanelEdit then
    TDBPanelEdit(Control).Font.CharSet := MarathonIDEInstance.CurrentProject.Encoding;
  if Control is TSyntaxMemoWithStuff2 then
    TSyntaxMemoWithStuff2(Control).Font.CharSet := MarathonIDEInstance.CurrentProject.Encoding;
  Result := MarathonIDEInstance.CurrentProject.Encoding;
end;

procedure SetupSyntaxEditor(Editor : TSyntaxMemoWithStuff2);
var
	Idx: Integer;

begin
	if gSyntaxHighlight then
		Editor.Highlighter := dmMenus.synHighlighter
	else
		Editor.Highlighter := nil;

	{$IFNDEF FPC}
	Editor.FindSettingsRegistryKey := REG_SETTINGS_EDITOR_FIND;
	Editor.FindDialogCaption := 'Find';
	Editor.ReplaceDialogCaption := 'Replace';
	{$ENDIF}

	Editor.RightEdge := gRightMargin;
	Editor.Font.Name := gEditorFontName;
	Editor.Font.Size := gEditorFontSize;
	Editor.SelectedColor.Foreground := gMarkedBlockFontColor;
	Editor.SelectedColor.Background := gMarkedBlockBGColor;
	Editor.ErrorBackColor := gErrorLineBGColor;
	Editor.ErrorForeColor := gErrorLineFontColor;
//  Editor.ExecutionBackColor := ;
//  Editor.ExecutionForeColor := ;

	Editor.Options := [eoDragDropEditing, eoScrollPastEof, eoShowScrollHint,
		eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces];

	if gAutoIndent then
		Editor.Options := Editor.Options + [eoAutoIndent]
	else
		Editor.Options := Editor.Options - [eoAutoIndent];

  if Assigned(Editor.Gutter.LineNumberPart(0)) then
    Editor.Gutter.LineNumberPart(0).Visible := gLineNumbers;
  Editor.Gutter.AutoSize := true;
  Editor.Gutter.Visible := gVisibleGutter;
  Editor.TabWidth := gBlockIndent;

  {$IFNDEF FPC}
  Editor.SearchEngine := dmMenus.SynEditSearch1;
  {$ENDIF}

	Editor.InsertMode := gInsertMode;
	Editor.WantTabs := True;

  {$IFNDEF FPC}
	Editor.KeywordCapitalise := gCapitalise;
	Editor.NavigatorHyperLinkStyle.Clear;
	Editor.NavigatorHyperLinkStyle.Add('4');

	Editor.WordList.Clear;
	if gSQLKeyWords then
	begin
		for Idx := 0 to dmMenus.lstKeyWords.Data.Count - 1 do
		begin
			with Editor.WordList.Add do
			begin
				ItemType := itSQL;
				MatchItem := dmMenus.lstKeyWords.Data[Idx];
				InsertText := dmMenus.lstKeyWords.Data[Idx];
			end;
		end;
	end;
  {$ENDIF}

{  if gTableNames then
	begin
		for Idx := 0 to frmMarathonMain.MTableList.Count - 1 do
		begin
			with Editor.WordList.Add do
			begin
				ItemType := itTable;
				MatchItem := frmMarathonMain.MTableList[Idx];
				InsertText := frmMarathonMain.MTableList[Idx];
			end;
		end;
	end;
	if gFieldNames then
	begin
		for Idx := 0 to frmMarathonMain.MFieldList.Count - 1 do
		begin
			with Editor.WordList.Add do
			begin
				ItemType := itColumn;
				MatchItem := frmMarathonMain.MFieldList[Idx];
				InsertText := frmMarathonMain.MFieldList[Idx];
			end;
		end;
	end;
	if gStoredProcNames then
	begin
		for Idx := 0 to frmMarathonMain.MSPList.Count - 1 do
		begin
			with Editor.WordList.Add do
			begin
				ItemType := itProcedure;
				MatchItem := frmMarathonMain.MSPList[Idx];
        InsertText := frmMarathonMain.MSPList[Idx];
      end;
    end;
  end;
	if gTriggerNames then
  begin
    for Idx := 0 to frmMarathonMain.MTriggerList.Count - 1 do
		begin
      with Editor.WordList.Add do
      begin
        ItemType := itTrigger;
				MatchItem := frmMarathonMain.MTriggerList[Idx];
        InsertText := frmMarathonMain.MTriggerList[Idx];
      end;
    end;
  end;
  if gExceptionNames then
	begin
    for Idx := 0 to frmMarathonMain.MExceptionList.Count - 1 do
		begin
      with Editor.WordList.Add do
      begin
        ItemType := itException;
        MatchItem := frmMarathonMain.MExceptionList[Idx];
        InsertText := frmMarathonMain.MExceptionList[Idx];
      end;
    end;
  end;
  if gGeneratorNames then
  begin
    for Idx := 0 to frmMarathonMain.MGeneratorList.Count - 1 do
    begin
      with Editor.WordList.Add do
      begin
        ItemType := itGenerator;
        MatchItem := frmMarathonMain.MGeneratorList[Idx];
        InsertText := frmMarathonMain.MGeneratorList[Idx];
			end;
		end;
  end;
  if gUDFNames then
  begin
    for Idx := 0 to frmMarathonMain.MUDFList.Count - 1 do
		begin
      with Editor.WordList.Add do
      begin
				ItemType := itUDF;
				MatchItem := frmMarathonMain.MUDFList[Idx];
				InsertText := frmMarathonMain.MUDFList[Idx];
			end;
		end;
	end;}

	{ Code templates are expanded by the editor itself on Ctrl+J - see
	  TSyntaxMemoWithStuff2.KeyDown - rather than through a list the caller
	  fills, which is what the commented-out block above was doing. }
end;

procedure SetupNonSyntaxEditor(Editor : TSyntaxMemoWithStuff2);
begin
	Editor.Highlighter := nil;
	{$IFNDEF FPC}
	Editor.FindSettingsRegistryKey := REG_SETTINGS_EDITOR_FIND;
	Editor.FindDialogCaption := 'Find';
	Editor.ReplaceDialogCaption := 'Replace';
	Editor.SearchEngine := dmMenus.SynEditSearch1;
	{$ENDIF}

	Editor.RightEdge := gRightMargin;
	Editor.Font.Name := gEditorFontName;
	Editor.Font.Size := gEditorFontSize;
	Editor.SelectedColor.Foreground := gMarkedBlockFontColor;
	Editor.SelectedColor.Background := gMarkedBlockBGColor;

	Editor.Options := [eoDragDropEditing, eoScrollPastEof, eoShowScrollHint,
		eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces];

	if gAutoIndent then
		Editor.Options := Editor.Options + [eoAutoIndent]
	else
		Editor.Options := Editor.Options - [eoAutoIndent];

  if Assigned(Editor.Gutter.LineNumberPart(0)) then
    Editor.Gutter.LineNumberPart(0).Visible := gLineNumbers;

	Editor.InsertMode := gInsertMode;
  Editor.TabWidth := gBlockIndent;
	Editor.WantTabs := True;
end;

procedure GlobalSetBookmark(Editor : TSyntaxMemoWithStuff2; Bookmark: Integer);
var
	Line: Integer;
	Col: Integer;
	Idx: Integer;

begin
	for Idx := 0 to 9 do
	begin
		if Editor.GetBookmark(Idx, Line, Col) then
		begin
			if Idx <> Bookmark then
			begin
				if Editor.CaretY = Line then
				begin
					if MessageDlg('Bookmark ' + IntToStr(Bookmark) + ' is already set on this line. Do you wish to replace this bookmark?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
						Exit
					else
						Break;
				end
			end;
		end;
	end;

  if Editor.GetBookmark(Bookmark, Line, Col) then
  begin
    if Editor.CaretY = Line then
			Editor.ClearBookmark(Bookmark)
    else
    begin
       if MessageDlg('This bookmark is already set on another line. DO you wish to reassign it?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
         Editor.SetBookmark(Bookmark,
					 Editor.CaretY,
           Editor.CaretX);
    end;
  end
  else
  begin
    Editor.SetBookmark(Bookmark,
			Editor.CaretY,
      Editor.CaretX);
	end;
end;

function IsABookmarkSet(Editor : TSyntaxMemoWithStuff2; Bookmark: Integer): Boolean;
var
  Line: Integer;
	Col: Integer;

begin
	if Editor.GetBookmark(Bookmark, Line, Col) then
		Result := True
	else
		Result := False;
end;

function LoadEditorContent(Editor: TSyntaxMemoWithStuff2; FileName: String): Boolean;
var
	L: TStringList;

begin
	L := TStringList.Create;
	try
		try
			L.LoadFromFile(FileName);
      Editor.Text := AdjustLineBreaks(L.Text);
			Result := True;
		except
			on E : Exception do
			begin
				Result := False;
				MessageDlg(E.Message, mtError, [mbOK], 0);
			end;
		end;
	finally
		L.Free;
	end;
end;

function SaveEditorContent(Editor: TSyntaxMemoWithStuff2; FileName: String): Boolean;
var
	L: TStringList;

begin
	L := TStringList.Create;
	try
		L.Text := AdjustLineBreaks(Editor.Text);
		try
			L.SaveToFile(FileName);
			Result := True;
		except
			on E : Exception do
			begin
				Result := False;
				MessageDlg(E.Message, mtError, [mbOK], 0);
			end;
		end;
	finally
		L.Free;
	end;
end;

function StripUglies(S: String): String;
var
	Idx: Integer;
begin
	Result := '';
	for Idx := 1 to Length(S) do
	begin
		if S[Idx] in [#13, #10, #9] then
      Result := Result + ' '
    else
      Result := Result + S[Idx];
  end;
end;

function MakeQuotedIdent(S: String; IB6: Boolean; Dialect: Integer): String;
begin
  if not IB6 then
  begin
		Result := S;
  end
  else
  begin
    if Dialect in [3] then
    begin
      if not IsIdentifierQuoted(S) then
      begin
        if ShouldBeQuoted(S) then
          Result := AnsiQuotedStr(S, '"')
        else
          Result := S;
      end
			else
        Result := S;
    end
    else
      Result := S;
	end;
end;

{ Whether an object of that name is in the database, without saying anything
  about it. Split from DoesObjectExist so both answers can be checked: that one
  raises a dialog when the answer is no, and a modal dialog cannot be driven by
  the harness at all - so the "not there" path was untestable while it was the
  only entry point. }
function ObjectExists(S: String; ObjType : TGSSCacheType; DatabaseName: String;
	Schema: String): Boolean;
var
	DB : TMarathonCacheConnection;
	Q : TIBQuery;
	Table_, Column_ : String;

begin
	Result := False;
	DB := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[DatabaseName];
	if not Assigned(DB) then
		Exit;
	if not CatalogueTableFor(ObjType, Table_, Column_) then
		raise Exception.Create('Invalid Object Type.');

	Q := TIBQuery.Create(nil);
	try
		Q.Database := DB.Connection;
		Q.Transaction := DB.Transaction;
		{ Assigning a transaction does not start one, and the tree's own queries
		  commit when they finish - so by the time a user opens an object there is
		  often none open, and IBX answers that with "Transaction is not active"
		  rather than starting one itself. Same rule as ScriptAs.EnsureActive. }
		if Assigned(Q.Transaction) and not TIBTransaction(Q.Transaction).Active then
			TIBTransaction(Q.Transaction).StartTransaction;
		try
			{ Upper-cased and schema-qualified first, which is how an ordinary
			  unquoted name is stored and found. }
			Q.SQL.Text := ObjectExistsSQL(Table_, Column_, AnsiUpperCase(S),
				SchemaClauseFor(DatabaseName, Schema));
			Q.Open;
			Result := not (Q.BOF and Q.EOF);
			Q.Close;
			if not Result then
			begin
				{ Then as it was typed, unqualified: a quoted identifier is stored
				  with the case it was created with, and may be in another schema
				  than the one being asked about. }
				Q.SQL.Text := ObjectExistsSQL(Table_, Column_, S, '');
				Q.Open;
				Result := not (Q.BOF and Q.EOF);
				Q.Close;
			end;
		except
			{ RDB$PACKAGES is Firebird 3 and later, and querying a table that is
			  not there is a hard error rather than an empty answer. The package
			  branch swallowed that; every kind does now, since "the catalogue
			  cannot answer" and "there is no such object" mean the same thing to
			  every caller of this. }
			on E: Exception do
				Result := False;
		end;
	finally
		Q.Free;
	end;
end;

function DoesObjectExist(S: String; ObjType : TGSSCacheType; DatabaseName: String;
	Schema: String): Boolean;
begin
	Result := ObjectExists(S, ObjType, DatabaseName, Schema);
	if not Result then
		MessageDlg('The object "' + S + '" does not exist in the database',
			mtError, [mbOK], 0);
end;

procedure ApplyConnectionKeywords(ADatabase: TIBDatabase;
	ATransaction: TIBTransaction);
var
	Words: TStringList;
begin
	if not Assigned(dmMenus) or not Assigned(dmMenus.synHighlighter) then
		Exit;
	Words := ReadServerKeywords(ADatabase, ATransaction);
	try
		ApplyServerKeywords(dmMenus.synHighlighter, Words);
	finally
		Words.Free;
	end;
end;

function SchemaClauseFor(const ConnectionName, Schema: String;
	const AColumn: String = ''): String;
var
	Conn: TMarathonCacheConnection;
	Supported: Boolean;
begin
	Supported := False;
	if Assigned(MarathonIDEInstance) and
	   Assigned(MarathonIDEInstance.CurrentProject) then
	begin
		Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
		Supported := Assigned(Conn) and Conn.Connected and
			Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0);
	end;
	if AColumn = '' then
		Result := SchemaPredicate('', Schema, Supported)
	else
		Result := SchemaPredicate('', AColumn, Schema, Supported);
end;

procedure AllowAutoTransactions(AOwner: TComponent);
var
	Idx: Integer;
	Child: TComponent;
begin
	if not Assigned(AOwner) then
		Exit;
	for Idx := 0 to AOwner.ComponentCount - 1 do
	begin
		Child := AOwner.Components[Idx];
		if Child is TIBCustomDataSet then
			TIBCustomDataSet(Child).AllowAutoActivateTransaction := True;
		{ Recursive because a form does not own the components on its frames -
		  each frame owns its own. The editors put their Dependencies, Metadata
		  and Description tabs on frames, and a first version of this walked only
		  the form's own list, so every one of those tabs still failed. }
		if Child.ComponentCount > 0 then
			AllowAutoTransactions(Child);
	end;
end;

procedure LoadScaledStrip(IL: TCustomImageList; const BaseResource: String;
	APixelsPerInch: Integer);
var
	Size: Integer;
	B: TBitmap;
	Name: String;
	Loaded: Boolean;
begin
	if not Assigned(IL) then
		Exit;
	Size := IconSizeForDPI(APixelsPerInch);
	B := TBitmap.Create;
	try
		Loaded := False;
		while not Loaded do
		begin
			Name := BaseResource + IconResourceSuffix(Size);
			try
				B.LoadFromResourceName(hInstance, Name);
				Loaded := True;
			except
				on E: Exception do
				begin
					{ No such resource. Step down a size rather than give up: a
					  resource file built before the larger strips existed still has
					  the base one, and icons at the wrong size beat no icons. }
					if Size <= BaseIconSize then
						Exit;
					if Size > 24 then
						Size := 24
					else
						Size := BaseIconSize;
				end;
			end;
		end;
		{ The list has to be told how big its images are before they go in, or
		  every one of them is cut to the 16 pixels the .lfm declared. }
		IL.Width := Size;
		IL.Height := Size;
		IL.Clear;
		AddStripMasked(IL, B, B.TransparentColor);
	finally
		B.Free;
	end;
end;

procedure AddStripMasked(IL: TCustomImageList; Strip: TBitmap; MaskColor: TColor);
var
	Cols, Rows, Col, Row: Integer;
	Tile: TBitmap;
begin
	if (IL = nil) or (Strip = nil) or (IL.Width <= 0) or (IL.Height <= 0) then
		Exit;
	{ So the icons follow the rest of the interface when it is scaled up. The
	  artwork is 16x16 and there is no larger version of it in the tree, so this
	  stretches rather than sharpens - but an icon at the wrong size next to
	  scaled text is worse than a soft one at the right size. }
	IL.Scaled := True;
	Cols := Strip.Width div IL.Width;
	Rows := Strip.Height div IL.Height;
	{ A strip narrower than one cell is not a strip - add it as it is rather
	  than silently adding nothing. }
	if (Cols < 1) or (Rows < 1) then
	begin
		IL.AddMasked(Strip, MaskColor);
		Exit;
	end;
	for Row := 0 to Rows - 1 do
		for Col := 0 to Cols - 1 do
		begin
			Tile := TBitmap.Create;
			try
				Tile.SetSize(IL.Width, IL.Height);
				Tile.Canvas.CopyRect(Rect(0, 0, IL.Width, IL.Height), Strip.Canvas,
					Bounds(Col * IL.Width, Row * IL.Height, IL.Width, IL.Height));
				IL.AddMasked(Tile, MaskColor);
			finally
				Tile.Free;
			end;
		end;
end;

function DeclaredFieldLength(Q: TDataSet): Integer;
var
	Fld: TField;
begin
	Fld := Q.FindField('rdb$character_length');
	if Assigned(Fld) and not Fld.IsNull and (Fld.AsInteger > 0) then
		Result := Fld.AsInteger
	else
		Result := Q.FieldByName('rdb$field_length').AsInteger;
end;

function ConvertFieldType(ftype, flen, fscale, fsubtype, fprecision: Integer; IsInterbase6: Boolean; Dialect: Integer): String;
begin
	{ Must be initialised - see the note on the MetaExtractGlobals copy: an
	  unrecognised ftype matches no branch and an uninitialised string result
	  returns arbitrary memory. }
	Result := '';
	fScale := Abs(fscale);
	Case ftype of
		blr_short :
			begin
				if IsInterbase6 then
				begin
					case fsubtype of
						0 :
							begin
								Result := 'smallint';
              end;
            1 :
              begin
                Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
              begin
                Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
          end;
        end
        else
        begin
          if fscale <> 0 then
          begin
            Result := 'decimal(4, ' + IntToStr(fscale) + ')'
          end
          else
            Result := 'smallint';
        end;
      end;

    blr_long :
      begin
        if IsInterbase6 then
        begin
          case fsubtype of
            0 :
							begin
                Result := 'integer';
              end;
            1 :
              begin
                Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
							begin
                Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
							end;
          end;
        end
        else
        begin
          if fscale <> 0 then
          begin
            Result := 'decimal(9, ' + IntToStr(fscale) + ')'
          end
          else
            Result := 'integer';
        end;
      end;

    blr_int64 :
      begin
        if IsInterbase6 then
        begin
          case fsubtype of
            0 :
              begin
                if Dialect = 3 then
                  Result := 'bigint'
                else
                  Result := 'decimal(18, 0)';
							end;
            1 :
              begin
                Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
              begin
								Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
          end;
        end;
      end;

    { Firebird 3+ types. Without these ConvertFieldType fell through leaving
      Result empty, and callers emitted the internal domain name (RDB$29,
      RDB$30, ...) in place of the type - producing DDL that cannot run. }
    blr_bool :
      begin
        Result := 'boolean';
      end;

    blr_dec64 :
      begin
        Result := 'decfloat(16)';
      end;

    blr_dec128 :
      begin
        Result := 'decfloat(34)';
      end;

    blr_int128 :
      begin
        { Same subtype convention as short/long/int64: 0 = raw integer type,
          1 = NUMERIC, 2 = DECIMAL. }
        case fsubtype of
          1 :
            Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')';
          2 :
            Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')';
        else
          Result := 'int128';
        end;
      end;

    blr_sql_time_tz :
      begin
        Result := 'time with time zone';
      end;

    blr_timestamp_tz :
      begin
        Result := 'timestamp with time zone';
      end;
    blr_float :
      begin
				Result := 'float';
      end;

		blr_text :
			begin
				Result := 'char(' + IntToStr(flen) + ')';
			end;

		blr_double :
			begin
				if fscale <> 0 then
				begin
					Result := 'decimal(15, ' + IntToStr(fscale) + ')';
				end
				else
          Result := 'double precision';
      end;

    blr_timestamp :
      begin
        if IsInterbase6 and (Dialect = 3) then
          Result := 'timestamp'
        else
          Result := 'date'
			end;

    blr_sql_time :
      begin
        Result := 'time'
      end;

    blr_sql_date :
      begin
        Result := 'date'
      end;

    blr_varying :
      begin
        Result := 'varchar(' + IntToStr(flen) + ')';
			end;

		blr_cstring :
			begin
				Result := 'cstring(' + IntToStr(flen) + ')';
			end;

		blr_blob :
			begin
				Result := 'blob' + ifthen(fSubType > 0, ' sub_type '+inttostr(fSubType), '');
			end;
	end;
end;

function BracketNear(StartCh: Integer; s: String): Boolean;
var
  x: Integer;

begin
  Result := False;
  for x := StartCh to StartCh + 6 do
  begin
    try
      if s[x] = ')' then
			begin
        Result := True;
				Break;
			end;
		except
			On E : Exception do
			begin
				Result := False;
				Exit;
			end;
		end;
	end;
end;

function DoNiftyWrap(St: String; Width: Integer): String;
begin
	Result := WrapText(St, #13#10, [' ', ',', #9], Width);
end;

procedure ExportGrid(ExType : TExportType; Q : TDataSet; FieldList : TStringList; TableName: String; FileName: String);
var
	F : TextFile;
	idx, idy: Integer;
	Rec: String;
	Found: Boolean;
	FCnt: Integer;
  FirstBit: String;
  Fld : TField;
  IsFirstRow: Boolean;


  function AddSepChar(S: String): String;
  begin
    if ((ExType.QualChar <> '') and (ExType.QualChar <> ' ')) then
    begin
      Result := ExType.QualChar + S + ExType.QualChar;
    end
    else
      Result := S;
  end;

  function PlainFieldValue(AFld: TField): String;
  begin
    if AFld.IsNull then
    begin
      Result := '';
      Exit;
    end;
    case AFld.DataType of
      ftFloat:
        Result := FormatFloat('##########0.000000', AFld.AsFloat);
      ftCurrency:
        Result := FormatFloat('##########0.00', AFld.AsFloat);
      ftDate, ftTime, ftDateTime:
        Result := DateTimeToStr(AFld.AsDateTime);
      ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftTypedBinary:
        Result := '(BLOB)';
    else
      Result := AFld.AsString;
    end;
  end;

  function JSONEscape(S: String): String;
  var
    i: Integer;
    C: Char;
  begin
    Result := '';
    for i := 1 to Length(S) do
    begin
      C := S[i];
      case C of
        '"': Result := Result + '\"';
        '\': Result := Result + '\\';
        #8: Result := Result + '\b';
        #9: Result := Result + '\t';
        #10: Result := Result + '\n';
        #12: Result := Result + '\f';
        #13: Result := Result + '\r';
      else
        if Ord(C) < 32 then
          Result := Result + '\u' + IntToHex(Ord(C), 4)
        else
          Result := Result + C;
      end;
    end;
  end;

  function JSONFieldValue(AFld: TField): String;
  begin
    if AFld.IsNull then
    begin
      Result := 'null';
      Exit;
    end;
    case AFld.DataType of
      ftSmallint, ftInteger, ftLargeint, ftWord:
        Result := AFld.AsString;
      ftFloat:
        Result := StringReplace(FormatFloat('##########0.000000', AFld.AsFloat), ',', '.', [rfReplaceAll]);
      ftCurrency:
        Result := StringReplace(FormatFloat('##########0.00', AFld.AsFloat), ',', '.', [rfReplaceAll]);
      { Firebird's DECFLOAT, INT128 and NUMERIC/DECIMAL all arrive as BCD
        fields. They are numbers, so emit them unquoted - going through
        AsFloat instead would silently lose precision, which is the entire
        point of DECFLOAT and INT128, so use AsString and only normalise the
        decimal separator, which is locale-dependent whereas JSON is not. }
      ftBCD, ftFMTBcd:
        Result := StringReplace(Trim(AFld.AsString), ',', '.', [rfReplaceAll]);
      ftBoolean:
        if AFld.AsBoolean then
          Result := 'true'
        else
          Result := 'false';
    else
      Result := '"' + JSONEscape(PlainFieldValue(AFld)) + '"';
    end;
  end;

  function MDEscape(S: String): String;
  begin
    Result := StringReplace(S, '|', '\|', [rfReplaceAll]);
    Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  end;

  function TSVEscape(S: String): String;
  begin
    Result := StringReplace(S, #9, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  end;

begin
  if FieldList.Count = 0 then
  begin
		MessageDlg('There are no Columns to Export.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if (Q.BOF and Q.EOF) Then
  begin
    MessageDlg('There are no Rows to Export.', mtInformation, [mbOK], 0);
    Exit;
  end;

  Case ExType.ExType of
    0 :
      begin  //seperated text file
        AssignFile(F, FileName);
        Rewrite(F);
        try
          Q.DisableControls;
          try
            if ExType.FirstRowNames then
						begin
              Rec := '';
              FCnt := 0;
							for idx := 0 to FieldList.Count - 1 do
              begin
                Rec := Rec + FieldList[idx];
                FCnt := FCnt + 1;
                If FCnt < FieldList.Count then
                  Rec := Rec + ExType.SepChar;
              end;
              WriteLn(F, Rec);
            end;

            Q.First;
            While not Q.EOF do
            begin
							Rec := '';
              FCnt := 0;
              for idx := 0 to Q.Fields.Count - 1 do
              begin
								Found := False;
                for idy := 0 to FieldList.Count - 1 do
                begin
                  if Q.Fields[idx].FieldName = FieldList[idy] then
                  begin
                    Found := True;
                    Break;
                  end;
                end;

                if Found then
                begin
                  Case Q.Fields[idx].DataType of
                    ftString:
                      begin
                        Rec := Rec + AddSepChar(Q.Fields[idx].AsString);
                      end;

                    ftSmallint:
											begin
                        Rec := Rec + Q.Fields[idx].AsString;
                      end;

                    ftInteger:
                      begin
                        Rec := Rec + Q.Fields[idx].AsString;
                      end;

                    ftLargeint:
                      begin
                        Rec := Rec + Q.Fields[idx].AsString;
                      end;

                    ftWord:
                      begin
												Rec := Rec + Q.Fields[idx].AsString;
                      end;

                    ftFloat:
                      begin
                        Rec := Rec + FormatFloat('##########0.000000', Q.Fields[idx].AsFloat);
                      end;

                    ftCurrency:
											begin
                        Rec := Rec + FormatFloat('##########0.00', Q.Fields[idx].AsFloat);
                      end;

                    ftDate:
                      begin
                        Rec := Rec + AddSepChar(DateTimeToStr(Q.Fields[idx].AsDateTime));
                      end;

                    ftTime:
                      begin
                        Rec := Rec + AddSepChar(DateTimeToStr(Q.Fields[idx].AsDateTime));
                      end;

                    ftDateTime:
                      begin
                        Rec := Rec + AddSepChar(DateTimeToStr(Q.Fields[idx].AsDateTime));
                      end;

										ftVarBytes:
                      begin
                        Rec := Rec + AddSepChar(Q.Fields[idx].AsString);
											end;

                    ftBlob:
                      begin
                        Rec := Rec + AddSepChar('(BLOB)');
                      end;

                    ftMemo:
											begin
                        Rec := Rec + AddSepChar('(BLOB)');
                      end;

                    ftGraphic:
                      begin
                        Rec := Rec + AddSepChar('(BLOB)');
                      end;

										ftFmtMemo:
                      begin
                        Rec := Rec + AddSepChar('(BLOB)');
                      end;

                    ftTypedBinary:
                      begin
                        Rec := Rec + AddSepChar('(BLOB)');
                      end;
                  else
                    Rec := Rec + AddSepChar(Q.Fields[idx].AsString);
                  end;

                  FCnt := FCnt + 1;
                  If FCnt < FieldList.Count then
                    Rec := Rec + ExType.SepChar;
                end;
              end;

							WriteLn(F, Rec);
              Q.Next;
            end;
					finally
            Q.First;
            Q.EnableControls;
          end;
        finally
          CloseFile(F);
        end;
      end;
		1:  //insert statement
      begin
        AssignFile(F, FileName);
        Rewrite(F);
        try
          Q.DisableControls;
          try
            FirstBit := 'insert into ' + TableName;

            if ExType.InsertColumnNames then begin
              FirstBit := FirstBit+'(';
              Found := false;
              for idy := 0 to FieldList.Count-1 do
              begin
                Fld := Q.FindField(FieldList[idy]);
                if Fld <> nil then
                begin
                  if Found then
                  begin
                    FirstBit := FirstBit + ', ';
                  end
                  else
                  begin
                    Found := true;
                  end;
                  if ExType.InsertColumnNamesSep then FirstBit := FirstBit + '"';
                  FirstBit := FirstBit + FieldList[idy];
                  if ExType.InsertColumnNamesSep then FirstBit := FirstBit + '"';
                end;
              end;

              FirstBit := FirstBit+')';

            end;
            FirstBit := FirstBit + ' values (';

						Q.First;
            While not Q.EOF do
            begin
							Rec := '';
              FCnt := 0;
              for idx := 0 to Q.Fields.Count - 1 do
              begin
                Found := False;
                for idy := 0 to FieldList.Count - 1 do
                begin
                  if Q.Fields[idx].FieldName = FieldList[idy] then
                  begin
                    Found := True;
                    Break;
                  end;
                end;

                if Found then
                begin
                  { One rule for what a value looks like written into a
                    statement, shared with the data grid's own edits -
                    see RowEdits.SQLFieldLiteral. The hundred lines of
                    type switch this replaces had no null test at all, so
                    a null column emitted nothing and left
                    "values (1, , 'x')", and it did not double quotes, so
                    one apostrophe in the data ended the literal. Neither
                    script would run. }
                  Rec := Rec + SQLFieldLiteral(Q.Fields[idx]);

                  FCnt := FCnt + 1;
                  If FCnt < FieldList.Count then
										Rec := Rec + ExType.SepChar;
                end;
              end;

              Rec := FirstBit + Rec + ');';
              WriteLn(F, Rec);
              Q.Next;
            end;
          finally
            Q.First;
            Q.EnableControls;
          end;
        finally
          CloseFile(F);
        end;
			end;
    2:  //JSON
      begin
        AssignFile(F, FileName);
        Rewrite(F);
        try
          Q.DisableControls;
          try
            WriteLn(F, '[');
            Q.First;
            IsFirstRow := True;
            While not Q.EOF do
            begin
              if IsFirstRow then
                IsFirstRow := False
              else
                WriteLn(F, ',');

              Rec := '  {';
              FCnt := 0;
              for idx := 0 to Q.Fields.Count - 1 do
              begin
                Found := False;
                for idy := 0 to FieldList.Count - 1 do
                begin
                  if Q.Fields[idx].FieldName = FieldList[idy] then
                  begin
                    Found := True;
                    Break;
                  end;
                end;

                if Found then
                begin
                  if FCnt > 0 then
                    Rec := Rec + ', ';
                  Rec := Rec + '"' + JSONEscape(Q.Fields[idx].FieldName) + '": ' + JSONFieldValue(Q.Fields[idx]);
                  FCnt := FCnt + 1;
                end;
              end;
              Rec := Rec + '}';
              Write(F, Rec);
              Q.Next;
            end;
            if not IsFirstRow then
              WriteLn(F, '');
            WriteLn(F, ']');
          finally
            Q.First;
            Q.EnableControls;
          end;
        finally
          CloseFile(F);
        end;
      end;
    3:  //Markdown table
      begin
        AssignFile(F, FileName);
        Rewrite(F);
        try
          Q.DisableControls;
          try
            Rec := '|';
            for idx := 0 to FieldList.Count - 1 do
              Rec := Rec + ' ' + MDEscape(FieldList[idx]) + ' |';
            WriteLn(F, Rec);

            Rec := '|';
            for idx := 0 to FieldList.Count - 1 do
              Rec := Rec + ' --- |';
            WriteLn(F, Rec);

            Q.First;
            While not Q.EOF do
            begin
              Rec := '|';
              for idx := 0 to Q.Fields.Count - 1 do
              begin
                Found := False;
                for idy := 0 to FieldList.Count - 1 do
                begin
                  if Q.Fields[idx].FieldName = FieldList[idy] then
                  begin
                    Found := True;
                    Break;
                  end;
                end;

                if Found then
                  Rec := Rec + ' ' + MDEscape(PlainFieldValue(Q.Fields[idx])) + ' |';
              end;
              WriteLn(F, Rec);
              Q.Next;
            end;
          finally
            Q.First;
            Q.EnableControls;
          end;
        finally
          CloseFile(F);
        end;
      end;
    4:  //Tab Separated Values
      begin
        AssignFile(F, FileName);
        Rewrite(F);
        try
          Q.DisableControls;
          try
            Rec := '';
            FCnt := 0;
            for idx := 0 to FieldList.Count - 1 do
            begin
              Rec := Rec + TSVEscape(FieldList[idx]);
              FCnt := FCnt + 1;
              If FCnt < FieldList.Count then
                Rec := Rec + #9;
            end;
            WriteLn(F, Rec);

            Q.First;
            While not Q.EOF do
            begin
              Rec := '';
              FCnt := 0;
              for idx := 0 to Q.Fields.Count - 1 do
              begin
                Found := False;
                for idy := 0 to FieldList.Count - 1 do
                begin
                  if Q.Fields[idx].FieldName = FieldList[idy] then
                  begin
                    Found := True;
                    Break;
                  end;
                end;

                if Found then
                begin
                  Rec := Rec + TSVEscape(PlainFieldValue(Q.Fields[idx]));
                  FCnt := FCnt + 1;
                  If FCnt < FieldList.Count then
                    Rec := Rec + #9;
                end;
              end;
              WriteLn(F, Rec);
              Q.Next;
            end;
          finally
            Q.First;
            Q.EnableControls;
          end;
        finally
          CloseFile(F);
        end;
      end;

    5 :
      begin  //xlsx workbook
        Q.DisableControls;
        try
          Q.First;
          WriteXlsx(Q, FieldList, 'Results', FileName);
        finally
          Q.First;
          Q.EnableControls;
        end;
      end;
  end;
end;

function ConvertTabs(Data: String; Editor : TSyntaxMemoWithStuff2): String;
var
  Idx: Integer;
  Idy: Integer;
  Tmp: String;

begin
  Tmp := '';
  for Idx := 1 to Length(Data) do
  begin
    if Data[Idx] = #9 then
    begin
      for Idy := 1 to Editor.TabWidth do
				Tmp := Tmp + ' ';
		end
		else
			Tmp := Tmp + Data[Idx];
	end;
	Result := Tmp;
end;

procedure NoLangDateTimeToString(var Result: string; const Format: string; DateTime: TDateTime);
var
	BufPos, AppendLevel: Integer;
	Buffer: array[0..255] of Char;

const
	NoLangShortMonthNames : array[1..12] of Shortstring =
													 ('JAN',
													 'FEB',
													 'MAR',
													 'APR',
													 'MAY',
													 'JUN',
													 'JUL',
													 'AUG',
													 'SEP',
													 'OCT',
													 'NOV',
													 'DEC');

	NoLangLongMonthNames : array[1..12] of Shortstring =
													 ('January',
													 'February',
													 'March',
													 'April',
													 'May',
													 'June',
													 'July',
													 'August',
													 'September',
													 'October',
                           'November',
                           'December');

  procedure AppendChars(P: PChar; Count: Integer);
	var
    N: Integer;
  begin
    N := SizeOf(Buffer) - BufPos;
    if N > Count then N := Count;
    if N <> 0 then Move(P[0], Buffer[BufPos], N);
    Inc(BufPos, N);
  end;

  procedure AppendString(const S: string);
  begin
    AppendChars(Pointer(S), Length(S));
  end;

  procedure AppendNumber(Number, Digits: Integer);
  const
    Format: array[0..3] of Char = '%.*d';
  var
		NumBuf: array[0..15] of Char;
	begin
    AppendChars(NumBuf, FormatBuf(NumBuf, SizeOf(NumBuf), Format,
      SizeOf(Format), [Digits, Number]));
  end;

  procedure AppendFormat(Format: PChar);
  var
    Starter, Token, LastToken: Char;
    DateDecoded, TimeDecoded, Use12HourClock,
    BetweenQuotes: Boolean;
    P: PChar;
    Count: Integer;
    Year, Month, Day, Hour, Min, Sec, MSec, H: Word;

		procedure GetCount;
		var
      P: PChar;
    begin
      P := Format;
      while Format^ = Starter do Inc(Format);
      Count := Format - P + 1;
    end;

    procedure GetDate;
    begin
      if not DateDecoded then
      begin
        DecodeDate(DateTime, Year, Month, Day);
        DateDecoded := True;
      end;
    end;

    procedure GetTime;
    begin
      if not TimeDecoded then
      begin
        DecodeTime(DateTime, Hour, Min, Sec, MSec);
        TimeDecoded := True;
			end;
		end;

    function ConvertEraString(const Count: Integer) : string;
    begin
      Result := ''; // Windows-only Japanese/Chinese era formatting not supported on Linux
    end;

    function ConvertYearString(const Count: Integer): string;
    begin
      Result := ''; // Windows-only Japanese/Chinese year formatting not supported on Linux
    end;

  begin
    if (Format <> nil) and (AppendLevel < 2) then
    begin
      Inc(AppendLevel);
      LastToken := ' ';
      DateDecoded := False;
      TimeDecoded := False;
      Use12HourClock := False;
      while Format^ <> #0 do
      begin
				Starter := Format^;
				Inc(Format);
        if Starter in LeadBytes then
        begin
          if Format^ = #0 then Break;
          Inc(Format);
          LastToken := ' ';
          Continue;
        end;
        Token := Starter;
        if Token in ['a'..'z'] then Dec(Token, 32);
        if Token in ['A'..'Z'] then
        begin
          if (Token = 'M') and (LastToken = 'H') then Token := 'N';
          LastToken := Token;
				end;
				case Token of
          'Y':
            begin
              GetCount;
              GetDate;
              if Count <= 2 then
                AppendNumber(Year mod 100, 2) else
                AppendNumber(Year, 4);
            end;
          'G':
            begin
              GetCount;
              GetDate;
              AppendString(ConvertEraString(Count));
            end;
          'E':
            begin
              GetCount;
              GetDate;
              AppendString(ConvertYearString(Count));
            end;
          'M':
            begin
							GetCount;
							GetDate;
              case Count of
                1, 2: AppendNumber(Month, Count);
                3: AppendString(NoLangShortMonthNames[Month]);
              else
                AppendString(NoLangLongMonthNames[Month]);
              end;
            end;
          'D':
            begin
              GetCount;
              case Count of
                1, 2:
                  begin
										GetDate;
										AppendNumber(Day, Count);
                  end;
                3: AppendString(ShortDayNames[DayOfWeek(DateTime)]);
                4: AppendString(LongDayNames[DayOfWeek(DateTime)]);
                5: AppendFormat(Pointer(ShortDateFormat));
              else
                AppendFormat(Pointer(LongDateFormat));
              end;
            end;
          'H':
            begin
              GetCount;
              GetTime;
              BetweenQuotes := False;
              P := Format;
              while P^ <> #0 do
              begin
                if P^ in LeadBytes then
                begin
                  Inc(P);
                  if P^ = #0 then Break;
                  Inc(P);
                  Continue;
								end;
								case P^ of
                  'A', 'a':
                    if not BetweenQuotes then
                    begin
                      if ( (StrLIComp(P, 'AM/PM', 5) = 0)
                        or (StrLIComp(P, 'A/P',   3) = 0)
                        or (StrLIComp(P, 'AMPM',  4) = 0) ) then
                        Use12HourClock := True;
                      Break;
                    end;
                  'H', 'h':
                    Break;
                  '''', '"': BetweenQuotes := not BetweenQuotes;
                end;
								Inc(P);
							end;
              H := Hour;
              if Use12HourClock then
                if H = 0 then H := 12 else if H > 12 then Dec(H, 12);
              if Count > 2 then Count := 2;
              AppendNumber(H, Count);
            end;
          'N':
            begin
              GetCount;
              GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Min, Count);
            end;
          'S':
            begin
              GetCount;
              GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Sec, Count);
            end;
          'T':
            begin
							GetCount;
							if Count = 1 then
                AppendFormat(Pointer(ShortTimeFormat)) else
                AppendFormat(Pointer(LongTimeFormat));
            end;
          'A':
            begin
              GetTime;
              P := Format - 1;
              if StrLIComp(P, 'AM/PM', 5) = 0 then
              begin
                if Hour >= 12 then Inc(P, 3);
                AppendChars(P, 2);
                Inc(Format, 4);
                Use12HourClock := TRUE;
							end else
							if StrLIComp(P, 'A/P', 3) = 0 then
              begin
                if Hour >= 12 then Inc(P, 2);
                AppendChars(P, 1);
                Inc(Format, 2);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AMPM', 4) = 0 then
              begin
                if Hour < 12 then
                  AppendString(TimeAMString) else
                  AppendString(TimePMString);
                Inc(Format, 3);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AAAA', 4) = 0 then
              begin
                GetDate;
                AppendString(LongDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 3);
              end else
              if StrLIComp(P, 'AAA', 3) = 0 then
              begin
								GetDate;
								AppendString(ShortDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 2);
              end else
              AppendChars(@Starter, 1);
            end;
          'C':
            begin
              GetCount;
              AppendFormat(Pointer(ShortDateFormat));
              GetTime;
              if (Hour <> 0) or (Min <> 0) or (Sec <> 0) then
              begin
                AppendChars(' ', 1);
                AppendFormat(Pointer(LongTimeFormat));
							end;
						end;
          '/':
            AppendChars(@DateSeparator, 1);
          ':':
            AppendChars(@TimeSeparator, 1);
          '''', '"':
            begin
              P := Format;
              while (Format^ <> #0) and (Format^ <> Starter) do
              begin
                if Format^ in LeadBytes then
                begin
                  Inc(Format);
                  if Format^ = #0 then Break;
                end;
                Inc(Format);
              end;
              AppendChars(P, Format - P);
              if Format^ <> #0 then Inc(Format);
            end;
        else
          AppendChars(@Starter, 1);
				end;
			end;
			Dec(AppendLevel);
		end;
	end;

begin
	BufPos := 0;
	AppendLevel := 0;
	if Format <> '' then AppendFormat(Pointer(Format)) else AppendFormat('C');
	SetString(Result, Buffer, BufPos);
end;

function NoLangFormatDateTime(const Format: string; DateTime: TDateTime): string;
begin
	NoLangDateTimeToString(Result, Format, DateTime);
end;

procedure EditBlobColumn(BlobField : TField);
var
  frmBlobViewer: TfrmBlobViewer;
  M : TMemoryStream;

begin
  if BlobField <> nil then
  begin
    case BlobField.Datatype of
			ftBytes, ftVarBytes, ftTypedBinary, ftGraphic:
				begin
					MessageDlg('Blob Viewers for these subtypes have not yet been implemented.', mtInformation, [mbOK], 0);
				end;
			ftBlob, ftMemo, ftFmtMemo:
				begin
					frmBlobViewer := TfrmBlobViewer.Create(nil);
					try
						M := TMemoryStream.Create;
						try
							TBlobField(BlobField).SaveToStream(M);
							M.Position := 0;
							frmBlobViewer.Data := M;

							if BlobField.DataSet.CanModify then
							begin
								frmBlobViewer.ReadOnly := False;
								if frmBlobViewer.ShowModal = mrOK then
								begin
									if Not (BlobField.DataSet.State in [dsEdit, dsInsert]) then
										BlobField.DataSet.Edit;
									M.Position := 0;
									TBlobField(BlobField).LoadFromStream(M);
								end;
							end
							else
							begin
								frmBlobViewer.ReadOnly := True;
								frmBlobViewer.ShowModal;
              end;
            finally
              M.Free;
            end;  
          finally
            frmBlobViewer.Free;
          end;
				end;
		end;
	end;
end;

procedure CaptureCodeSnippet(Editor: TSyntaxMemoWithStuff2);
var
	NewNodePath: String;

begin
	with TfrmEditorSnippet.NewSnippet(Application, '') do
		try
			edSnippet.Text := Editor.SelText;
			if ShowModal = mrOK then
			begin
				NewNodePath := GetNodePath(True);
				marathonIDEInstance.RefreshCodeSnippets(NewNodePath + edSnippetName.Text);
			end;
		finally
			Free;
		end;
end;

function UpdateEditorStatusBar(StatusBar : TStatusBar; Editor : TSyntaxMemoWithStuff2): Boolean;
begin
	StatusBar.Panels[0].Text := IntToStr(Editor.CaretY) + ':' + IntToStr(Editor.CaretX);

  if Editor.Modified then
  begin
    StatusBar.Panels[1].Text :=  'Modified';
    Result := True;
  end
  else
  begin
    StatusBar.Panels[1].Text := '';
    Result := False;
  end;

  if Editor.ReadOnly then
  begin
    StatusBar.Panels[2].Text := 'Read Only';
  end
  else
	begin
    if Editor.InsertMode then
			StatusBar.Panels[2].Text := 'Insert'
    else
      StatusBar.Panels[2].Text := 'Overwrite';
  end;
end;

function GetCharSetValue(CharSetName: String): Integer;
begin
	Result := 1;
  if CharSetName = 'ANSI Character Set' then
    Result := 0;
  if CharSetName = 'Default Character Set' then
    Result := 1;
  if CharSetName = 'SYmbol Character Set' then
    Result := 2;
  if CharSetName = 'Macintosh Character Set' then
    Result := 77;
  if CharSetName = 'SHIFTJIS Character Set' then
    Result := 128;
  if CharSetName = 'HANGEUL Character Set' then
    Result := 129;
  if CharSetName = 'JOHAB Character Set' then
    Result := 130;
  if CharSetName = 'GB2312 Character Set' then
    Result := 134;
  if CharSetName = 'CHINESEBIG5 Character Set' then
    Result := 136;
  if CharSetName = 'GREEK Character Set' then
    Result := 161;
  if CharSetName = 'TURKISH Character Set' then
    Result := 162;
  if CharSetName = 'VIETNAMESE Character Set' then
    Result := 163;
  if CharSetName = 'HEBREW Character Set' then
    Result := 177;
  if CharSetName = 'ARABIC Character Set' then
    Result := 178;
	if CharSetName = 'BALTIC Character Set' then
    Result := 186;
	if CharSetName = 'RUSSIAN Character Set' then
    Result := 204;
  if CharSetName = 'THAI Character Set' then
    Result := 222;
  if CharSetName = 'EASTERN EUROPE Character Set' then
    Result := 238;
  if CharSetName = 'OEM Character Set' then
    Result := 255;
end;

function GetCharSetName(CharSetVal: Integer): String;
begin
  Result := 'Default Character Set';
  case CharSetVal of
    0: Result := 'ANSI Character Set';
    1: Result := 'Default Character Set';
    2: Result := 'SYmbol Character Set';
    77: Result := 'Macintosh Character Set';
    128: Result := 'SHIFTJIS Character Set';
    129: Result := 'HANGEUL Character Set';
    130: Result := 'JOHAB Character Set';
    134: Result := 'GB2312 Character Set';
    136: Result := 'CHINESEBIG5 Character Set';
    161: Result := 'GREEK Character Set';
    162: Result := 'TURKISH Character Set';
    163: Result := 'VIETNAMESE Character Set';
    177: Result := 'HEBREW Character Set';
    178: Result := 'ARABIC Character Set';
    186: Result := 'BALTIC Character Set';
    204: Result := 'RUSSIAN Character Set';
    222: Result := 'THAI Character Set';
    238: Result := 'EASTERN EUROPE Character Set';
    255: Result := 'OEM Character Set';
  end;
end;

function GetCharSetByIndex(Index: Integer): Integer;
begin
  case Index of
		1 : Result := 0;
    2 : Result := 1;
    3 : Result := 2;
    4 : Result := 77;
    5 : Result := 128;
    6 : Result := 129;
    7 : Result := 130;
    8 : Result := 134;
		9 : Result := 136;
    10 : Result := 161;
    11 : Result := 162;
    12 : Result := 163;
    13 : Result := 177;
    14 : Result := 178;
    15 : Result := 186;
    16 : Result := 204;
    17 : Result := 222;
    18 : Result := 238;
    19 : Result := 255;
  else
    Result := 0;  
  end;
end;

procedure GetCharSetNames(S : TStrings);
begin
  S.Clear;
  S.Add('ANSI Character Set');
  S.Add('Default Character Set');
  S.Add('SYmbol Character Set');
  S.Add('Macintosh Character Set');
  S.Add('SHIFTJIS Character Set');
  S.Add('HANGEUL Character Set');
  S.Add('JOHAB Character Set');
  S.Add('GB2312 Character Set');
  S.Add('CHINESEBIG5 Character Set');
  S.Add('GREEK Character Set');
	S.Add('TURKISH Character Set');
  S.Add('VIETNAMESE Character Set');
	S.Add('HEBREW Character Set');
  S.Add('ARABIC Character Set');
  S.Add('BALTIC Character Set');
  S.Add('RUSSIAN Character Set');
  S.Add('THAI Character Set');
  S.Add('EASTERN EUROPE Character Set');
  S.Add('OEM Character Set');
end;

function GetDBCharSetIndexByID(ID: Integer): Integer;
begin
	case ID of
		0 : Result := 0;
		1 : Result := 2;
		2 : Result := 3;
		3 : Result := 4;
		5 : Result := 5;
		6 : Result := 6;
		10 : Result := 7;
		11 : Result := 8;
		12 : Result := 9;
		21 : Result := 10;
		45 : Result := 11;
		46 : Result := 12;
		13 : Result := 13;
		47 : Result := 14;
		14 : Result := 15;
		50 : Result := 16;
		51 : Result := 17;
		52 : Result := 18;
		53 : Result := 19;
		54 : Result := 20;
		55 : Result := 21;
		19 : Result := 22;
		44 : Result := 23;
		56 : Result := 24;
		57 : Result := 25;
	else
		Result := 0;
	end;
end;

function GetDBCharSetNameByID(ID: Integer): String;
begin
  case ID of
    0 : Result := '';
    1 : Result := 'OCTETS';
		2 : Result := 'ASCII';
    3 : Result := 'UNICODE_FSS';
		5 : Result := 'SJIS_0208';
    6 : Result := 'EUCJ_0208';
    10 : Result := 'DOS437';
    11 : Result := 'DOS850';
    12 : Result := 'DOS865';
    21 : Result := 'ISO8859_1';
    45 : Result := 'DOS852';
    46 : Result := 'DOS857';
    13 : Result := 'DOS860';
    47 : Result := 'DOS861';
    14 : Result := 'DOS863';
    50 : Result := 'CYRL';
    51 : Result := 'WIN1250';
    52 : Result := 'WIN1251';
    53 : Result := 'WIN1252';
    54 : Result := 'WIN1253';
    55 : Result := 'WIN1254';
    19 : Result := 'NEXT';
    44 : Result := 'KSC_5601';
    56 : Result := 'BIG_5';
    57 : Result := 'GB_2312';
  else
    Result := '';
  end;
end;

procedure LoadFormPosition(F : TForm);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName, False) then
		begin
			if R.ValueExists('Top') then
				F.Top := R.ReadInteger('Top');
			if R.ValueExists('Left') then
				F.Left := R.ReadInteger('Left');
      if R.ValueExists('Width') then
        F.Width := R.ReadInteger('Width');
      if R.ValueExists('Height') then
        F.Height := R.ReadInteger('Height');
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure SaveFormPosition(F : TForm);
var
  R : TRegistry;

begin
  R := TRegistry.Create;
  try
    if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName, True) then
    begin
      R.WriteInteger('Top', F.Top);
      R.WriteInteger('Left', F.Left);
      R.WriteInteger('Width', F.Width);
      R.WriteInteger('Height', F.Height);
      R.CloseKey;
    end;
  finally
		R.Free;
  end;
end;

procedure ValidateFormState(F:TForm);
var
  wMonitor : TMonitor;
begin
   wMonitor := screen.MonitorFromWindow(f.Handle, mdNull);
   F.MakeFullyVisible(wMonitor);
end;

procedure LoadSplitterPosition(F : TForm; Panel : TPanel);
var
  R : TRegistry;

begin
  R := TRegistry.Create;
  try
		if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName + '\' + Panel.Name, False) then
    begin
      if R.ValueExists('Width') then
        Panel.Width := R.ReadInteger('Width');
      if R.ValueExists('Height') then
        Panel.Height := R.ReadInteger('Height');
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure SaveSplitterPosition(F : TForm; Panel : TPanel);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName + '\' + Panel.Name, True) then
		begin
			R.WriteInteger('Width', Panel.Width);
			R.WriteInteger('Height', Panel.Height);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

procedure GlobalFormatFields(DataSet : TDataSet);
var
	Idx: Integer;

begin
	if DataSet.Active then
	begin
		for Idx := 0 to DataSet.FieldCount - 1 do
		begin
			if DataSet.Fields[Idx] is TFloatField then
			begin
				if gFloatDisplayFormat <> '' then
					TFloatField(DataSet.Fields[Idx]).DisplayFormat := gFloatDisplayFormat;

				if Length(gFloatDisplayFormat) > TFloatField(DataSet.Fields[Idx]).DisplayWidth then
					TFloatField(DataSet.Fields[Idx]).DisplayWidth := Length(gFloatDisplayFormat);
			end;
			if DataSet.Fields[Idx] is TIntegerField then
			begin
				if gIntDisplayFormat <> '' then
					TIntegerField(DataSet.Fields[Idx]).DisplayFormat := gIntDisplayFormat;

				if Length(gIntDisplayFormat) > TIntegerField(DataSet.Fields[Idx]).DisplayWidth then
					TIntegerField(DataSet.Fields[Idx]).DisplayWidth := Length(gIntDisplayFormat);
			end;
			if DataSet.Fields[Idx] is TDateField then
			begin
				if gDateDisplayFormat <> '' then
					TDateField(DataSet.Fields[Idx]).DisplayFormat := gDateDisplayFormat;

				if Length(gDateDisplayFormat) > TDateField(DataSet.Fields[Idx]).DisplayWidth then
					TDateField(DataSet.Fields[Idx]).DisplayWidth := Length(gDateDisplayFormat);

			end;
			if DataSet.Fields[Idx] is TDateTimeField then
			begin
				if gDateTimeDisplayFormat <> '' then
					TDateTimeField(DataSet.Fields[Idx]).DisplayFormat := gDateTimeDisplayFormat;

				if Length(gDateTimeDisplayFormat) > TDateTimeField(DataSet.Fields[Idx]).DisplayWidth then
					TDateTimeField(DataSet.Fields[Idx]).DisplayWidth := Length(gDateTimeDisplayFormat);

			end;
			if DataSet.Fields[Idx] is TTimeField then
			begin
				if gTimeDisplayFormat <> '' then
					TTimeField(DataSet.Fields[Idx]).DisplayFormat := gTimeDisplayFormat;

				if Length(gTimeDisplayFormat) > TTimeField(DataSet.Fields[Idx]).DisplayWidth then
					TTimeField(DataSet.Fields[Idx]).DisplayWidth := Length(gTimeDisplayFormat);

			end;
			if DataSet.Fields[Idx] is TStringField then
			begin
				if gCharDisplayWidth <> 0 then
				begin
					if TStringField(DataSet.Fields[Idx]).DisplayWidth > gCharDisplayWidth then
						TStringField(DataSet.Fields[Idx]).DisplayWidth := gCharDisplayWidth;
				end;
			end;
		end;
	end;
end;

function QueryProjectFile(FileName: String): String;
var
  doc: TXMLDocument;
  oProject : TDOMNode;

begin
  Result := '';
  try
    try
      ReadXMLFile(doc, FileName);
    except
      on E: EXMLReadError do
      begin
        //ignore
      end;
    end;

    oProject := doc.DocumentElement;
    oProject := oProject.FindNode('project');

    if Assigned(oProject) then
    begin
      if oProject.NodeName = 'project' then
      begin
        Result := oProject.Attributes.GetNamedItem('name').NodeValue;
			end;
    end;
  except
    on E: Exception do
    begin
      //ignore
    end;
	end;
end;

{ TDragQueenCarla }

constructor TDragQueenCarla.Create(AControl: TControl);
begin
	inherited Create(AControl);
end;

destructor TDragQueenCarla.Destroy;
begin
	inherited Destroy;
end;

function TDragQueenCarla.GetText: String;
begin
  Result := FData;
end;
       
{ TDragQueenPearl }

constructor TDragQueenPearl.Create(AControl: TControl);
begin
  inherited Create(AControl)
end;

destructor TDragQueenPearl.Destroy;
begin
  inherited Destroy;
end;

function TDragQueenPearl.GetText: String;
{var
  frmSQLAssistant: TfrmSQLAssistant;
  Tmp: String;
  Idx: Integer;
  Alias: String;
	qryUtil : TIBQuery;
 } 
begin
(*  frmSQLAssistant := TfrmSQLAssistant.Create(nil);
  try
    Tmp := FData;

    Alias := '';

    for Idx := 0 to MarathonIDEInstance.CurrentProject.SATableAlias.Count - 1 do
    begin
      if AnsiUpperCase(ParseSection(MarathonIDEInstance.CurrentProject.SATableAlias[Idx], 1, ':')) = AnsiUpperCase(Tmp) then
      begin
        Alias := ParseSection(MarathonIDEInstance.CurrentProject.SATableAlias[Idx], 2, ':');
        Break;
      end;
    end;

    frmSQLAssistant.edRelationAlias.Text := Alias;
    frmSQLAssistant.lblRelationName.Caption := Tmp;
    frmSQLAssistant.chkWrapColumns.Enabled := False;
    frmSQLAssistant.edColsPerLine.Enabled := False;
    frmSQLAssistant.udColsPerLine.Enabled := False;
    if frmSQLAssistant.ShowModal = mrOK then
		begin
      Alias := frmSQLAssistant.edRelationAlias.Text;
      if FDragItemType = dbntStoredProc then
      begin
        //add arguments...
				qryUtil := TIBQuery.Create(nil);
        try
//          qryUtil.Database := frmMarathonMain.IBObjDatabase;
//          qryUtil.Transaction := frmMarathonMain.IBObjTransaction;

          qryUtil.Close;
          qryUtil.SQL.Clear;
          qryUtil.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale from rdb$procedure_parameters a, rdb$fields b where ' +
                        'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ''' + AnsiUpperCase(FData) +
                        ''' order by rdb$parameter_number asc;');
          qryUtil.Open;
          If Not (qryUtil.EOF and qryUtil.BOF) Then
          begin
            Tmp := Tmp + '(';
            Tmp := Tmp + qryUtil.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
                                                                                                     DeclaredFieldLength(qryUtil),
                                                                                                     qryUtil.FieldByName('rdb$field_scale').AsInteger);
            qryUtil.Next;
            while not qryUtil.EOF do
            begin
              Tmp := Tmp + ', ';
              Tmp := Tmp + qryUtil.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(qryUtil.FieldByName('rdb$field_type').AsInteger,
                                                                                                       DeclaredFieldLength(qryUtil),
                                                                                                       qryUtil.FieldByName('rdb$field_scale').AsInteger);
              qryUtil.Next;
            end;
            tmp := tmp + ')';
          end;
          qryUtil.Close;
//          if frmMarathonMain.IBObjTransaction.Active then
//            frmMarathonMain.IBObjTransaction.Commit;
        finally
          qryUtil.Free;
        end;
			end;
      Tmp := Tmp + ' ' + Alias;

      //save the results to the project...
      if MarathonIDEInstance.CurrentProject.SATableAlias.IndexOf(FData + ':' + Alias) = -1 then
			begin
        if MarathonIDEInstance.CurrentProject.SATableAlias.Count > 50 then
          MarathonIDEInstance.CurrentProject.SATableAlias.Delete(0);

				MarathonIDEInstance.CurrentProject.SATableAlias.Add(FData + ':' + Alias);
      end;

      Result := Tmp;
    end;
  finally
    frmSQLAssistant.Free;
  end; *)
end;

{ TDragQueenFiFi }

constructor TDragQueenFiFi.Create(AControl: TControl);
begin
  inherited Create(AControl);
  FData := TStringList.Create;
end;

destructor TDragQueenFiFi.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

function TDragQueenFiFi.GetText: String;
{var
  frmSQLAssistant: TfrmSQLAssistant;
  Tmp: String;
  Idx: Integer;
  Alias: String;
	qryUtil : TIBQuery;
  Cnt: Integer;
  Wrap: Boolean;
  ColsPerLine: Integer;
 }
begin
{  frmSQLAssistant := TfrmSQLAssistant.Create(nil);
  try
    Tmp := '';

    Alias := DragItem;

    for Idx := 0 to MarathonIDEInstance.CurrentProject.SATableAlias.Count - 1 do
    begin
      if AnsiUpperCase(ParseSection(MarathonIDEInstance.CurrentProject.SATableAlias[Idx], 1, ':')) = AnsiUpperCase(FItemData) then
      begin
        Alias := ParseSection(MarathonIDEInstance.CurrentProject.SATableAlias[Idx], 2, ':');
        Break;
      end;
    end;

    frmSQLAssistant.edRelationAlias.Text := Alias;
    frmSQLAssistant.lblRelationName.Caption := Tmp;
    frmSQLAssistant.chkWrapColumns.Checked := MarathonIDEInstance.CurrentProject.SAWrapFields;
    frmSQLAssistant.udColsPerLine.Position := MarathonIDEInstance.CurrentProject.SAFieldsPerLine;
    if frmSQLAssistant.ShowModal = mrOK then
    begin
      Alias := frmSQLAssistant.edRelationAlias.Text;
      ColsPerLine := frmSQLAssistant.udColsPerLine.Position;
      Wrap := frmSQLAssistant.chkWrapColumns.Checked;

      Cnt := 1;
      for Idx := 0 to FData.Count - 1 do
      begin
        if Alias <> '' then
          Tmp := Tmp + Alias + '.' + FData[Idx] + ','
        else
          Tmp := Tmp + FData[Idx] + ',';

				if Wrap then
        begin
          if Cnt >= ColsPerLine then
          begin
						Tmp := Tmp + #13#10;
            Cnt := 1;
            Continue;
          end
          else
						Tmp := Tmp + ' ';
          Cnt := Cnt + 1;
        end
        else
          Tmp := Tmp + ' ';
      end;
      Tmp := Trim(Tmp);
      if Tmp[Length(Tmp)] = ',' then
        Tmp := Copy(Tmp, 1, Length(Tmp) - 1);

      //save the results to the project...
      if MarathonIDEInstance.CurrentProject.SATableAlias.IndexOf(FItemData + ':' + Alias) = -1 then
      begin
        if MarathonIDEInstance.CurrentProject.SATableAlias.Count > 50 then
          MarathonIDEInstance.CurrentProject.SATableAlias.Delete(0);

        MarathonIDEInstance.CurrentProject.SATableAlias.Add(FItemData + ':' + Alias);
      end;

      MarathonIDEInstance.CurrentProject.SAWrapFields := Wrap;
      MarathonIDEInstance.CurrentProject.SAFieldsPerLine := ColsPerLine;


      Result := Tmp;
    end;
	finally
		frmSQLAssistant.Free;
	end; }
end;

procedure ProcessNextTab(PageControl: TPageControl);
begin
	PageControl.SelectNextPage(True);
end;

procedure ProcessPriorTab(PageControl: TPageControl);
begin
	PageControl.SelectNextPage(False);
end;

const
	STRDELIM1 = '"';
	STRDELIM2 = #39;

const
	DIGIT = ['0'..'9'];
	ALPHA = ['A'..'Z', 'a'..'z'];
	IDENT = ALPHA + DIGIT + ['_', '$'];

	ZERO =  '0';
	NINE =  '9';
	TAB =   #9;
	SPACE = ' ';
	CR =    #13;
	NULL =  #0;
	LF =    #10;

procedure TTextParser.SetInput(Value: String);
begin
	FInput := Value;
  FTermChar := ';';
  Findex := 1;
end;

procedure TTextParser.PushChar(Ch: Char);
begin
  FOutput := FOutPut + Ch;
  Inc(FIndex);
end;

procedure TTextParser.Mark;
begin
  FPrior := False;
end;

function TTextParser.GetNextToken : TToken;
begin
	if Not (Length(FInput) > 0) then
    raise Exception.Create('No input'); 
  if FIndex > Length(FInput) then
  begin
    Result.Offset := 0;
    Result.Len := 0;
		Result.TokenType := tkNone;
    Result.TokenText := '';
  end;

  while FIndex <= Length(FInput) do
  begin
    Ch := FInput[FIndex];
    if FIndex < Length(FInput) then
      Next := FInput[FIndex + 1]
    else
      Next := #0;

    case FState of
      psIdent :
        begin
          if not (Ch in  ALPHA + [ZERO..NINE, '_', '$']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkIdent;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psOperator :
        begin
					if not (Ch in ['>','<','=','+','-']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
						Result.Len := Length(FOutPut);
            Result.TokenType := tkOperator;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
					else
            FOutPut := FOutPut + Ch;
        end;

      psBracket :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkBracket;
          Result.TokenText := FOutPut;
          FState := psNormal;
          Exit;
        end;

      psTerminator :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkTerm;
          Result.TokenText := FOutPut;
          FState := psNormal;
          Exit;
        end;

      psComma :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkComma;
          Result.TokenText := FOutPut;
					FState := psNormal;
          Exit;
        end;

      psNumber :
        begin
          if not (Ch in [ZERO..NINE,'.','E','e']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
						Result.Len := Length(FOutPut);
            Result.TokenType := tkNumber;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psString :
        begin
          case Ch of
            STRDELIM1, STRDELIM2:
              begin
                FOutPut := FOutPut + Ch;
                StrDelimCount := StrDelimCount + 1;
                if Not Odd(StrDelimCount) then
                begin
                  if Not (Next in [STRDELIM1, STRDELIM2]) then
                  begin
                    Result.Offset := FIndex - Length(FOutPut);
                    Result.Len := Length(FOutPut);
                    Result.TokenType := tkString;
                    Result.TokenText := FOutPut;
                    FState := psNormal;
                    PushChar(Next);
                    Exit;
                  end
                  else
									begin
                    PushChar(Next);
                    StrDelimCount := StrDelimCount + 1;
									end;
                end
                else
                begin
                  StrDelimCount := StrDelimCount + 1;
                end;
							end;
          else
            begin
              FOutPut := FOutPut + Ch;
            end;
          end;
        end;

      psNormal :
        begin
          if Ch = FTermChar then
          begin
            FState := psTerminator;
          end
          else
          begin
            case Ch of
              SPACE, NULL, TAB, CR, LF : ;

              '>','<','=','+','-' :
                begin
                  FState := psOperator;
                end;

              '[',']','(',')' :
                begin
                  FState := psBracket;
                end;

              ',' :
								begin
                  FState := psComma;
                end;

              ZERO..NINE :
                begin
                  FState := psNumber;
                end;

							'#','$' :
                begin
                  if Next in DIGIT then
                  begin
                    FState := psNumber;
                    Mark;
                  end;
                end;

              'A'..'Z','a'..'z', '_' :
                begin
                  begin
                    FState := psIdent;
                    Mark;
                  end;
                end;

              STRDELIM1, STRDELIM2:
                begin
                  begin
                    FState := psString;
                    StrDelimCount := 1;
                    Mark;
                  end;
                end;


              '/' :
                begin
                  if Next = '*' then
									begin
                    FState := psComment;
                    Mark;
									end;
                end;
            end;
          end;
          FOutPut := Ch;
        end;

      psComment :
        begin
          if Ch = '*' then
          begin
            FOutput := FOutPut + Ch;
            if Next = '/' then
            begin
              PushChar(Next);
              Result.Offset := FIndex - Length(FOutPut);
              Result.Len := Length(FOutPut);
              Result.TokenType := tkComment;
              Result.TokenText := FOutPut;
              FState := psNormal;
              Exit
            end;
          end
          else
            FOutput := FOutPut + Ch;
        end;
    end;
    Inc(FIndex);
  end;
  if FIndex > Length(FInput) then
  begin
    Result.Offset := 0;
    Result.Len := 0;
    Result.TokenType := tkNone;
    Result.TokenText := '';
  end;
end;

function StripQuotesFromQuotedIdentifier(S: String): String;
begin
	if Length(S) > 0 then
	begin
		if S[1] in ['''', '"'] then
		begin
			S := Copy(S, 2, Length(S));
		end;
	end;

	if Length(S) > 0 then
	begin
		if S[Length(S)] in ['''', '"'] then
		begin
			S := Copy(S, 1, Length(S) - 1);
		end;
	end;
	Result := S;
end;

function IsIdentifierQuoted(S: String): Boolean;
var
	BeginQuote: Boolean;
	EndQuote: Boolean;

begin
  BeginQuote := False;
  EndQuote := False;

  if Length(S) > 0 then
  begin
    if S[1] in ['''', '"'] then
    begin
      BeginQuote := True;
    end;
  end;

	if Length(S) > 0 then
  begin
    if S[Length(S)] in ['''', '"'] then
    begin
      EndQuote := True;
    end;
  end;
  Result := BeginQuote and EndQuote;
end;

function ShouldBeQuoted(S: String): Boolean;
var
	Idx: Integer;

begin
  Result := False;
  for Idx := 1 to Length(S) do
  begin
		// If there is something different in the name as these chars the string
		// should be quoted
		if not (S[Idx] in ['A'..'Z', '_', '$', '0'..'9']) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function CheckNameLength(S: String): Boolean;
begin
  Result := False;
  if Length(S) > 0 then
  begin
    if S[1] = '"' then
    begin
      if Length(S) > 33 then
        {$IFDEF WINDOWS}MessageBeep(MB_ICONEXCLAMATION){$ENDIF};
    end
    else
    begin
      if Length(S) > 31 then
        {$IFDEF WINDOWS}MessageBeep(MB_ICONEXCLAMATION){$ENDIF};
    end;
  end;
end;

function TMarathonScreen.GetMonitor: TMonitor;
begin
   result := MarathonIDEInstance.MainForm.MainFormMonitor; 
end;

function EnvironmentColor(Env: TConnectionEnvironment): TColor;
begin
  { TColor is $00BBGGRR, not RGB. }
  case Env of
    envDevelopment: Result := $0060C060;   // green
    envTest:        Result := $00C08000;   // blue
    envStaging:     Result := $0020A0E0;   // amber
    envProduction:  Result := $003030C0;   // red
  else
    Result := clBtnFace;
  end;
end;

function EnvironmentTextColor(Env: TConnectionEnvironment): TColor;
begin
  if Env = envUnset then
    Result := clWindowText
  else
    Result := clWhite;
end;

initialization


end.

