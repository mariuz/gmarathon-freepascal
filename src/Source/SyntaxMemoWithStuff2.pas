unit SyntaxMemoWithStuff2;

interface

{$I CompilerDefines.inc}

uses {$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Messages, Types, {$ELSE}
  Windows, Messages, {$ENDIF}
  SynEdit, Classes, dialogs, Graphics, SysUtils, Controls, ImgList, ExtCtrls, StdCtrls, Forms, SynEditTypes, SynEditMarks, SynEditMiscClasses, SynEditDecorator;

const
  WM_KILLFOCUS = 8;
  WM_WINDOWPOSCHANGING = 70;

type
  TMessage = TLMessage;

	TSynEditSaveFormat = (sfTEXT, sfRTF, sfHTML, sfUNIX);

	TSynEditGutterImageIndex = (ilEnabled, ilDisabled, ilExecute, ilInvalid,
		ilError, ilResult, ilExecutedOK, ilWarning,
		ilBeginBlock, ilEndBlock);

	TErrorKind = (ekNone, ekError, ekServer);

	PColorRec = ^TColorRec;
	TColorRec = record
		line: integer;
		kind: TErrorKind;
	end;

	TPopupListbox = class(TCustomListbox)
	protected
		procedure CreateParams(var Params : TCreateParams); override;
		procedure CreateWnd; override;
	end;

	TPopUpListBox2 = class(TCustomListbox)
	private
		FBuffer: string;
		FEditor: TSynEdit;
		procedure SetEditor(const Value: TSynEdit);
	protected
		procedure CreateParams(var Params : TCreateParams); override;
		procedure CreateWnd; override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyPress(var Key: Char); override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
	public
		constructor Create(AOwner : TComponent); override;
		property Editor : TSynEdit read FEditor write SetEditor;
	end;

	TPopupHintWindow = class(THintWindow)
	protected
		procedure CreateParams(var Params : TCreateParams); override;
		procedure CreateWnd; override;
		procedure Paint; override;
	end;

  TGetHyperlinkTokenEvent = procedure(Sender: TObject; XY: TPoint; var Token: string;
    var Start, TokenType: integer) of object;
  TOnHyperlinkClickEvent = procedure(Sender: TObject; XY: TPoint; Token: string;
    Shift: TShiftState) of object;

  THintType = (htInformation);
  TGetHintText = procedure(Sender : TObject; Token : string; var HintText : string; HintType : THintType) of object;

	TDotLookupEvent = procedure(Sender : TObject; var List : TStringList;
		Buffer : String) of object;

	TWordList = class(TCollection)
	public
		constructor Create;
	end;

	TSQLInsightList = class(TCollection)
	public
		constructor Create;
	end;

	{ Declared ahead of the editor, which holds one, and defined below it,
	  because it holds a reference back to the editor. }
	TEdPersistent = class;

	TSyntaxMemoWithStuff2 = class(TSynEdit)
	private
		{ Private declarations }
		FExecutelineBegin: integer;
		FExecuteLineEnd: integer;
		FExecutionForeColor: TColor;
		FExecutionBackColor: TColor;
		FErrorLine: integer;
		FErrorForeColor: TColor;
		FErrorBackColor: TColor;
    FUseNavigateHyperLinks: boolean;
    FLinking: boolean;
    FGetHyperlinkToken : TGetHyperlinkTokenEvent;
    FOnHyperLinkClick : TOnHyperlinkClickEvent;
    FOnGetHintText : TGetHintText;
    FOnDotLookup: TDotLookupEvent;
    FWordList: TWordList;
    FSQLInsightList: TSQLInsightList;
    { Search text, options and history, kept per editor so that Find Next after
      a Find in one window does not pick up what was typed in another. }
    FPersist: TEdPersistent;
    FListDelay: Integer;
    FFindSettingsRegistryKey: String;
    FFindDialogCaption: String;
    FReplaceDialogCaption: String;
    FReplaceDialogHelpContext: Integer;
    FFindDialogHelpContext: Integer;

    function GetSelLength: integer;
    procedure SetSelLength(const Value: integer);
	protected
		procedure WMKillFocus(var Message : TLMessage); message WM_KILLFOCUS;
		procedure WMWindowPosChanging(var Message : TLMessage); message WM_WINDOWPOSCHANGING;
		procedure CMMouseLeave(var Message : TLMessage); message CM_MOUSELEAVE;
    procedure KeyPress(var Key: Char); override;
		{ Ctrl+J expands the template named by the word before the caret - the
		  binding Delphi's editor used, and the one the Options tab's help text
		  has always described. }
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		{ Installs SynEdit's default key bindings when nothing else has - see the
		  body, this is not the no-op it looks like. }
		procedure EnsureKeystrokes;
		{ The mark on that line, if any. Bookmarks are SynEdit's own and are left
		  alone; only the debugger's are ours to add and remove. }
		function FindQuestMark(ALine: Integer): TSynEditMark;
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure SetExecutionHighlighting(const ExecutelineBegin: integer;
			const ExecuteLineEnd: integer);
    procedure ClearExecutionHighlighting;
    { No-op here. In the full editor wrapper (lib/SyntaxMemoWithStuff2) this
      hides the code-completion and hint popup windows; this reduced stub has
      neither, so there is nothing to close. Kept because editor forms call it
      from mouse/move handlers, and dropping it would mean scattering
      conditionals through every one of those call sites. }
    procedure CloseUpLists;
    { Find, Find Next and Replace. These were left unimplemented on this port
      and every caller had been reduced to a comment, so Ctrl+F did nothing in
      the SQL editor or any object editor. The dialogs themselves were ported
      and working - only the three methods that raise them were missing. The
      search is SynEdit's own SearchReplace; nothing here needs the code
      completion machinery this unit still lacks. }
    procedure WSFind;
    procedure WSFindNext;
    procedure WSReplace;

    { The debugger's "blue dots": a mark in the gutter on every line a
      breakpoint may be set on. The PSQL editor asked for these in three
      places and every one had been reduced to an empty statement, so a
      procedure opened for debugging looked identical to one that could not be
      debugged at all.

      Called Quest glyphs because that is what the original editor wrapper
      called them, and the call sites still say so. }
    procedure AddQuestGlyph(ALine: Integer);
    procedure RemoveQuestGlyph(ALine: Integer);
    procedure ClearQuestGlyphs;
    function HasQuestGlyph(ALine: Integer): Boolean;
    function QuestGlyphCount: Integer;

    { Expands the code template named by the word just before the caret, and
      leaves the caret where the template asks for it. Returns False when that
      word names no template, so a caller can leave the keystroke alone. }
    function ExpandTemplateAtCaret: Boolean;
    function DoOnSpecialLineColors(Line: integer; var Foreground, Background: TColor): boolean;

    property SelLength: integer read GetSelLength write SetSelLength;
	published
    property SelStart;
		property ErrorLine: integer read FErrorLine write FErrorLine;
		property ErrorForeColor: TColor read FErrorForeColor write FErrorForeColor;
		property ErrorBackColor: TColor read FErrorBackColor write FErrorBackColor;
		property ExecutionForeColor: TColor read FExecutionForeColor write FExecutionForeColor;
		property ExecutionBackColor: TColor read FExecutionBackColor write FExecutionBackColor;
    property UseNavigateHyperLinks: boolean read FUseNavigateHyperLinks write FUseNavigateHyperLinks;
    property GetHyperlinkToken: TGetHyperlinkTokenEvent read FGetHyperlinkToken write FGetHyperlinkToken;
    property OnHyperlinkClick: TOnHyperlinkClickEvent read FOnHyperLinkClick write FOnHyperLinkClick;
    property OnDotLookup: TDotLookupEvent read FOnDotLookup write FOnDotLookup;
    property OnGetHintText: TGetHintText read FOnGetHintText write FOnGetHintText;
	end;

  TEdPersistent = class(TComponent)
  private
    FEditor: TSyntaxMemoWithStuff2;
    FFindList: TStrings;
    FReplList: TStrings;
    FLastFindText: string;
    FLastReplaceText: string;
    FLastFindOpt: TSynSearchOptions;
    FLastPromptOnReplace: boolean;
    procedure SetFindList(Value: TStrings);
    procedure SetReplList(Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Editor: TSyntaxMemoWithStuff2 read FEditor write FEditor;
    property FindList: TStrings read FFindList write SetFindList;
    property ReplList: TStrings read FReplList write SetReplList;
    property LastFindText: string read FLastFindText write FLastFindText;
    property LastReplaceText: string read FLastReplaceText write FLastReplaceText;
    property LastFindOpt: TSynSearchOptions read FLastFindOpt write FLastFindOpt;
    property LastPromptOnReplace: boolean read FLastPromptOnReplace write FLastPromptOnReplace;
  end;

implementation

uses FindDlg, ReplDlg, CodeTemplates;

{ TWordList }
constructor TWordList.Create;
begin
  inherited Create(TCollectionItem);
end;

{ TSQLInsightList }
constructor TSQLInsightList.Create;
begin
  inherited Create(TCollectionItem);
end;

{ TPopupListbox }
procedure TPopupListbox.CreateParams(var Params : TCreateParams);
begin
	inherited CreateParams(Params);
	Params.Style := Params.Style or WS_POPUP;
end;
procedure TPopupListbox.CreateWnd;
begin
	inherited CreateWnd;
	CallWindowProc(DefWndProc, Handle, $0007 {LM_SETFOCUS}, 0, 0);
end;

{ TPopUpListBox2 }
constructor TPopUpListBox2.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Visible := False;
end;
procedure TPopUpListBox2.CreateParams(var Params : TCreateParams);
begin
	inherited CreateParams(Params);
	Params.Style := Params.Style or WS_POPUP;
end;
procedure TPopUpListBox2.CreateWnd;
begin
	inherited CreateWnd;
	CallWindowProc(DefWndProc, Handle, $0007 {LM_SETFOCUS}, 0, 0);
end;
procedure TPopUpListBox2.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;
procedure TPopUpListBox2.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
end;
procedure TPopUpListBox2.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;
procedure TPopUpListBox2.SetEditor(const Value: TSynEdit);
begin
  FEditor := Value;
end;

{ TPopupHintWindow }
procedure TPopupHintWindow.Paint;
begin
  inherited Paint;
end;
procedure TPopupHintWindow.CreateParams(var Params : TCreateParams);
begin
	inherited CreateParams(Params);
	Params.Style := Params.Style or WS_POPUP;
end;
procedure TPopupHintWindow.CreateWnd;
begin
	inherited CreateWnd;
	CallWindowProc(DefWndProc, Handle, $0007 {LM_SETFOCUS}, 0, 0);
end;

{ TSyntaxMemoWithStuff2 }
procedure TSyntaxMemoWithStuff2.EnsureKeystrokes;
begin
	{ Give the editor a keyboard, because nothing else does.

	  TCustomSynEdit.Create installs the default key bindings only when

	    assigned(Owner) and not (csLoading in Owner.ComponentState)

	  and an editor sitting on a form is constructed *during* that form's
	  streaming, when its owner is precisely csLoading. Lazarus's own designer
	  hides this by writing a Keystrokes collection into every .lfm it saves;
	  these forms were converted from Delphi .dfm files, which carry no such
	  collection, so nothing ever installed one and Keystrokes.Count stayed 0
	  for the life of the editor.

	  An empty table makes FindKeycodeEx answer ecNone for everything, so
	  KeyDown neither runs a command nor consumes the key: Backspace, Delete,
	  the arrow keys, Home/End, Ctrl+C/V and the rest all did nothing at all.
	  Typing still worked, because printable characters arrive through KeyPress
	  and never consult this table - which is why it looked like "backspace is
	  broken" rather than "this editor has no key bindings".

	  Guarded on Count so an .lfm that does define its own bindings keeps them. }
	if Keystrokes.Count = 0 then
		Keystrokes.ResetDefaults;
end;

constructor TSyntaxMemoWithStuff2.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
	EnsureKeystrokes;
  FExecutelineBegin := -1;
  FExecuteLineEnd := -1;
  FWordList := TWordList.Create;
  FSQLInsightList := TSQLInsightList.Create;
  FPersist := TEdPersistent.Create(Self);
  FPersist.Editor := Self;
  { Whole-word and case are off, and the search runs forwards from the caret -
    what a reader expects of a first Ctrl+F. }
  FPersist.LastFindOpt := [];
end;

destructor TSyntaxMemoWithStuff2.Destroy;
begin
  FWordList.Free;
  FSQLInsightList.Free;
  { FPersist is owned by this component, so it is freed with it. }
	inherited Destroy;
end;

procedure TSyntaxMemoWithStuff2.WSFind;
var
	Dlg: TEdFindDlg;
begin
	Dlg := TEdFindDlg.Create(Self);
	try
		if FFindDialogCaption <> '' then
			Dlg.Caption := FFindDialogCaption;
		Dlg.HelpContext := FFindDialogHelpContext;
		Dlg.Execute(FPersist.LastFindText, FPersist.LastFindOpt, Self, FPersist);
	finally
		Dlg.Free;
	end;
end;

procedure TSyntaxMemoWithStuff2.WSFindNext;
begin
	{ Nothing searched for yet, so ask rather than silently report that an empty
	  string was not found. }
	if FPersist.LastFindText = '' then
	begin
		WSFind;
		Exit;
	end;
	if SearchReplace(FPersist.LastFindText, '', FPersist.LastFindOpt) = 0 then
		MessageDlg(Format('Search string "%s" not found.', [FPersist.LastFindText]),
			mtInformation, [mbOK], 0);
end;

procedure TSyntaxMemoWithStuff2.WSReplace;
var
	Dlg: TEdReplDlg;
begin
	Dlg := TEdReplDlg.Create(Self);
	try
		if FReplaceDialogCaption <> '' then
			Dlg.Caption := FReplaceDialogCaption;
		Dlg.HelpContext := FReplaceDialogHelpContext;
		Dlg.Execute(FPersist.LastFindText, FPersist.LastFindOpt, Self, FPersist);
	finally
		Dlg.Free;
	end;
end;

function TSyntaxMemoWithStuff2.GetSelLength: integer;
begin
  Result := SelEnd - SelStart;
end;

procedure TSyntaxMemoWithStuff2.SetSelLength(const Value: integer);
begin
  SelEnd := SelStart + Value;
end;

procedure TSyntaxMemoWithStuff2.SetExecutionHighlighting(const ExecutelineBegin: integer;
	const ExecuteLineEnd: integer);
begin
	FExecutelineBegin := ExecutelineBegin;
	FExecuteLineEnd := ExecuteLineEnd;
	Invalidate;
end;

procedure TSyntaxMemoWithStuff2.CloseUpLists;
begin
  { see declaration - no popups exist in this stub }
end;

procedure TSyntaxMemoWithStuff2.ClearExecutionHighlighting;
begin
	FExecutelineBegin := -1;
	FExecuteLineEnd := -1;
	Invalidate;
end;

function TSyntaxMemoWithStuff2.DoOnSpecialLineColors(Line: integer; var Foreground, Background: TColor): boolean;
begin
  Result := False;
	if (FExecutelineBegin <= Line) and (Line <= FExecuteLineEnd) then
	begin
		Background := FExecutionBackColor;
		Foreground := FExecutionForeColor;
		Result := True;
	end;
end;

procedure TSyntaxMemoWithStuff2.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
end;

procedure TSyntaxMemoWithStuff2.WMKillFocus(var Message : TLMessage);
begin
	inherited;
end;

procedure TSyntaxMemoWithStuff2.WMWindowPosChanging(var Message : TLMessage);
begin
end;

procedure TSyntaxMemoWithStuff2.CMMouseLeave(var Message : TLMessage);
begin
	inherited;
end;

{ TEdPersistent }
constructor TEdPersistent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFindList := TStringList.Create;
  FReplList := TStringList.Create;
end;

destructor TEdPersistent.Destroy;
begin
  FFindList.Free;
  FReplList.Free;
  inherited Destroy;
end;

procedure TEdPersistent.SetFindList(Value: TStrings);
begin
  FFindList.Assign(Value);
end;

procedure TEdPersistent.SetReplList(Value: TStrings);
begin
  FReplList.Assign(Value);
end;

{ The debugger's blue dots, kept in SynEdit's own mark list rather than in a
  list of this unit's own. Doing it that way means the gutter draws them, the
  marks move when lines are inserted above them, and nothing here has to be
  told when the text changes. }

function TSyntaxMemoWithStuff2.FindQuestMark(ALine: Integer): TSynEditMark;
var
  Idx: Integer;
begin
  Result := nil;
  for Idx := 0 to Marks.Count - 1 do
    if (Marks[Idx].Line = ALine) and (not Marks[Idx].IsBookmark) then
      Exit(Marks[Idx]);
end;

procedure TSyntaxMemoWithStuff2.AddQuestGlyph(ALine: Integer);
var
  Mark: TSynEditMark;
begin
  if ALine < 1 then
    Exit;
  { Asking twice for the same line is the ordinary case - the debugger redraws
    the whole set whenever it refreshes - so it has to be idempotent rather
    than stack marks up. }
  if Assigned(FindQuestMark(ALine)) then
    Exit;
  Mark := TSynEditMark.Create(Self);
  Mark.Line := ALine;
  { With no image list configured, SynEdit draws one of its own built-in
    glyphs; without this the mark exists and nothing appears. }
  Mark.InternalImage := True;
  Mark.ImageIndex := 0;
  Mark.Visible := True;
  Marks.Add(Mark);
end;

procedure TSyntaxMemoWithStuff2.RemoveQuestGlyph(ALine: Integer);
var
  Mark: TSynEditMark;
begin
  Mark := FindQuestMark(ALine);
  if Assigned(Mark) then
  begin
    Marks.Remove(Mark);
    Mark.Free;
  end;
end;

procedure TSyntaxMemoWithStuff2.ClearQuestGlyphs;
var
  Idx: Integer;
  Mark: TSynEditMark;
begin
  for Idx := Marks.Count - 1 downto 0 do
  begin
    Mark := Marks[Idx];
    if not Mark.IsBookmark then
    begin
      Marks.Remove(Mark);
      Mark.Free;
    end;
  end;
end;

function TSyntaxMemoWithStuff2.HasQuestGlyph(ALine: Integer): Boolean;
begin
  Result := Assigned(FindQuestMark(ALine));
end;

function TSyntaxMemoWithStuff2.QuestGlyphCount: Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to Marks.Count - 1 do
    if not Marks[Idx].IsBookmark then
      Inc(Result);
end;

procedure TSyntaxMemoWithStuff2.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('J')) and (ssCtrl in Shift) and not (ssAlt in Shift) then
  begin
    { Only swallowed when a template was actually expanded, so Ctrl+J over a
      word that names none is left for anything else that wants it. }
    if ExpandTemplateAtCaret then
    begin
      Key := 0;
      Exit;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

function TSyntaxMemoWithStuff2.ExpandTemplateAtCaret: Boolean;
var
  Word_, Indent, Expanded: String;
  Template: TCodeTemplate;
  CaretLine, CaretCol, Line: Integer;
begin
  Result := False;
  Line := CaretY;
  if (Line < 1) or (Line > Lines.Count) then
    Exit;
  Word_ := TemplateWordBefore(Lines[Line - 1], CaretX);
  if Word_ = '' then
    Exit;
  Template := GlobalCodeTemplates.FindByName(Word_);
  if not Assigned(Template) then
    Exit;

  Indent := IndentOf(Lines[Line - 1]);
  Expanded := ExpandTemplate(Template, Indent, CaretLine, CaretCol);

  { The name the user typed is replaced, not added to. Selecting it and
    assigning over the selection keeps this one undo step. }
  BeginUndoBlock;
  try
    BlockBegin := Point(CaretX - Length(Word_), Line);
    BlockEnd := Point(CaretX, Line);
    SelText := Expanded;
    { Where the template asked for the caret. CaretLine counts from the first
      line of the expansion, which is the line the name was on. }
    CaretY := Line + CaretLine;
    CaretX := CaretCol;
  finally
    EndUndoBlock;
  end;
  Result := True;
end;

end.
