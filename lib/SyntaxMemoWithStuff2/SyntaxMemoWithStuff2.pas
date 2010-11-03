unit SyntaxMemoWithStuff2;

interface

uses
	Windows, SynEdit, Classes, dialogs, Graphics, SysUtils, Controls, ImgList, ExtCtrls, StdCtrls,
	Messages, Forms, SynEditTypes, SynEditDecorator;

type
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

const
	mk_ID = 10;

type
	TSyntaxMemoWithStuff2 = class;

	TChangeKeywordCase = procedure(Sender : TObject; CursorPos : TPoint; keyword : string; var allow : boolean) of object;
	TGetHighlighterTokenEvent = procedure(Sender : TObject; XY: TPoint; var Token: string; var start,tokenType : integer) of object;
	
	TEdPersistent = class(TComponent)
	private
		FGetList : TStringList;
		FFindSettingsRegistryKey: String;
		FEditor: TSyntaxMemoWithStuff2;
		function GetFindList : TStrings;
		function GetReplList : TStrings;
		procedure SetFindList(const Value : TStrings);
		procedure SetReplList(const Value : TStrings);
		procedure SetFindOpt(const Value : TSynSearchOptions);
		procedure SetFindText(const Value : string);
		procedure SetLastPromptOnReplace(const Value : boolean);
		procedure SetReplaceText(const Value : string);
		function GetFindOpt: TSynSearchOptions;
		function GetFindText: string;
		function GetLastPromptOnReplace: boolean;
		function GetReplaceText: string;
	public
		constructor Create(AOwner : TComponent); override;
		destructor Destroy; override;
		property Editor : TSyntaxMemoWithStuff2 read FEditor write FEditor;
		property FindList : TStrings read GetFindList write SetFindList;
		property ReplList : TStrings read GetReplList write SetReplList;
		property LastFindText : string read GetFindText write SetFindText;
		property LastReplaceText : string read GetReplaceText write SetReplaceText;
		property LastFindOpt : TSynSearchOptions read GetFindOpt write SetFindOpt;
		property LastPromptOnReplace : boolean read GetLastPromptOnReplace write SetLastPromptOnReplace;
		property FindSettingsRegistryKey : String read FFindSettingsRegistryKey write FFindSettingsRegistryKey;
	end;


	TPopUpHintWindow = class(TPanel)
	private
		FDrawRect : TRect;
		FHintText : string;
		FEditor : TCustomSynEdit;
		FHintVisible : Boolean;
		procedure SetHintText(const Value : string);
	protected
		procedure Paint; override;
		procedure CreateParams(var Params : TCreateParams); override;
		procedure CreateWnd; override;
	public
		property HintText : string read FHintText write SetHintText;
		property Editor : TCustomSynEdit read FEditor write FEditor;
		property HintVisible : Boolean read FHintVisible write FHintVisible;
		procedure PopUp(Position : TPoint);
		procedure Close;
	end;

	TPopupListbox = class(TCustomListbox)
	private
	protected
		procedure CreateParams(var Params : TCreateParams); override;
		procedure CreateWnd; override;
	end;

	TItemType = (itSQL,
		itPLSQL,
		itTable,
		itColumn,
		itTrigger,
		itException,
		itGenerator,
		itFunction,
		itProcedure,
		itUDF);

	TWordListItem = class(TCollectionItem)
	private
		FItemType : TItemType;
		FMatchItem : string;
		FInsertText : string;
	protected

	public

	published
		property ItemType : TItemType read FItemType write FItemType;
		property MatchItem : string read FMatchItem write FMatchItem;
		property InsertText : string read FInsertText write FInsertText;
	end;

	TWordList = class(TCollection)
	private
		FOwner : TSyntaxMemoWithStuff2;
		function GetItem(Index : Integer) : TWordListItem;
		procedure SetItem(Index : Integer; Value : TWordListItem);
	protected
		function GetOwner : TPersistent; override;
	public
		function Add : TWordListItem;
		procedure LoadFromFile(FileName : string);
		constructor Create(AOwner : TSyntaxMemoWithStuff2);
		property Items[Index : Integer] : TWordListItem read GetItem write SetItem; default;
		property Owner : TSyntaxMemoWithStuff2 read FOwner;
	end;

	TSQLInsightListItem = class(TCollectionItem)
	private
		FMatchItem : string;
		FInsertText : TStringList;
		FDescription : string;
		procedure SetInsertText(Value : TStringList);
		function GetInsertText : TStringList;
	protected

	public
		constructor Create(Collection : TCollection); override;
		destructor Destroy; override;
	published
		property Description : string read FDescription write FDescription;
		property MatchItem : string read FMatchItem write FMatchItem;
		property InsertText : TStringList read GetInsertText write SetInsertText;
	end;

	TSQLInsightList = class(TCollection)
	private
		FOwner : TSyntaxMemoWithStuff2;
		function GetItem(Index : Integer) : TSQLInsightListItem;
		procedure SetItem(Index : Integer; Value : TSQLInsightListItem);
	protected
		function GetOwner : TPersistent; override;
	public
		procedure LoadFromFile(FileName : string);
		procedure SaveToFile(FileName : string);
		function Add : TSQLInsightListItem;
		constructor Create(AOwner : TSyntaxMemoWithStuff2);
		property Items[Index : Integer] : TSQLInsightListItem read GetItem write SetItem; default;
		property Owner : TSyntaxMemoWithStuff2 read FOwner;
	end;

	THintType = (htInformation);

	TOpenFileAtCursorEvent = procedure(Sender : TObject; FileName : string) of object;
	TNavigateHyperLinkClick = procedure(Sender : TObject; Token : string) of object;
	TGetHintText = procedure(Sender : TObject; Token : string; var HintText : string; HintType : THintType) of object;


	TSyntaxMemoWithStuff2Breakpoint = class(TSynEditMark)
	private
		fValid: boolean;
		fEnabled: boolean;
		procedure SetEnabled(const Value: boolean);
		procedure SetValid(const Value: boolean);
		procedure UpdateImage;
	public
		constructor Create(AOwner : TCustomSynEdit);
		property Enabled : boolean read fEnabled write SetEnabled;
		property Valid	 : boolean read fValid	 write SetValid;
	end;

	TDotLookupEvent = procedure(Sender: TObject; const Items: TStrings; const IsManual: boolean) of object;

	TPopupListbox2 = class(TPopupListbox)
	end;

	TSyntaxMemoWithStuff2 = class(TSynEdit)
	private
		FChangeKeywordCase: TChangeKeywordCase;
		FGetHyperlinkToken: TGetHighlighterTokenEvent;
		function GetSelStart: integer;
		procedure SetSelStart(const Value: integer);
		function GetSelLength: integer;
		procedure SetSelLength(const Value: integer);
	private
		FStaticLineColors: TList;
		FQuestGutterGlyphs: TImageList;
		FExecutelineBegin: integer;
		FExecuteLineEnd: integer;
		FErrorLine: integer;
		FFileName: string;
		FSaveFormat: TSynEditSaveFormat;
		FErrorBackColor: TColor;
		FErrorForeColor: TColor;
		FExecutionBackColor: TColor;
		FExecutionForeColor: TColor;

// SyntaxMemoWithStuff
		FJustDidIndent : Boolean;
		FListPos : TPoint;
		FWordList : TWordList;
		mpos : TPoint;
		FLinking : Boolean;
		FSQLInsightList : TSQLInsightList;
		FTimer : TTimer;
		FHintTimer : TTimer;
		F : TPopUpListBox;
		FSQLListVisible : Boolean;
		FSQL : TPopUpListBox;
		FSQLInsListVisible : Boolean;
		FBuffer : string;
		FOnOpenFileAtCursor : TOpenFileAtCursorEvent;
		FNavigateHyperLinkClick : TNavigateHyperLinkClick;
		FUseNavigateHyperLinks : Boolean;
		FMarkHintPos : TPoint;
		FHintWindow : TPopupHintWindow;
		FOnGetHintText : TGetHintText;
		FNavigatorHyperLinkStyle : TStringList;
		FKeywordCapitalise : Boolean;
		FPersist : TEdPersistent;
		FFindSettingsRegistryKey: String;
		FFindDialogCaption: String;
		FReplaceDialogCaption: String;
		FReplaceDialogHelpContext: Integer;
		FFindDialogHelpContext: Integer;

		fDecorator : TSynEditDecorator;
		fHyperLink : TSynEditDecoration;

		FDotLBX: TPopUpListBox2;
		FDotLookupVisible: Boolean;
		FDotLookupTimer: TTimer;
		FDotLookupList: TStringList;
		FOnDotLookup: TDotLookupEvent;
		FDotLookupBuffer: string;
		FAutoDotLookup: boolean;
		FManualLookupInvoked: boolean;
		procedure DotLookupTimerEvent(Sender : TObject);

// SyntaxMemoWithStuff
		function GetExecutionBackColor: TColor;
		function GetExecutionForeColor: TColor;
		procedure SetErrorForeColor(const Value: TColor);
		procedure SetErrorBackColor(const Value: TColor);
		procedure SetExecutionBackColor(const Value: TColor);
		procedure SetExecutionForeColor(const Value: TColor);
		function GetErrorBackColor: TColor;
		function GetErrorForeColor: TColor;
		function GetErrorLine: Integer;
		procedure SetErrorLine(const Value: integer);

		procedure TimerEvent(Sender : TObject);
		procedure DrawListItem(Control : TWinControl; Index : Integer;
			Rect : TRect; State : TOwnerDrawState);
		procedure DrawSQLListItem(Control : TWinControl; Index : Integer;
			Rect : TRect; State : TOwnerDrawState);
		procedure SetWordList(Value : TWordList);
		procedure SetSQLInsightList(Value : TSQLInsightList);
		procedure SetListDelay(Value : Integer);
		function GetListDelay : Integer;
		procedure HintTimerEvent(Sender : TObject);
		procedure SetFindSettingsRegistryKey(const Value: String);
		function GetNavigatorHyperLinkStyle: TStringList;
		procedure SetNavigatorHyperLinkStyle(const Value: TStringList);

		procedure SetSelTextBuf(buf : PChar);
		function TokenTextAtPos(pos : integer; var dummy : longint):string;

		property SelStart  : integer read GetSelStart  write SetSelStart;
		property SelLength : integer read GetSelLength write SetSelLength;
	protected
// SyntaxMemoWithStuff
		procedure KeyPress(var Key : Char); override;
		procedure KeyUp(var Key : Word; Shift : TShiftState); override;
		procedure KeyDown(var Key : Word; Shift : TShiftState); override;
		procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
		procedure MouseMove(Shift : TShiftState; X, Y : Integer); override;
		procedure WMKillFocus(var Message : TMessage); message WM_KILLFOCUS;
		procedure WMWindowPosChanging(var Message : TMessage); message WM_WINDOWPOSCHANGING;
		procedure CMMouseLeave(var Message : TMessage); message CM_MOUSELEAVE;
		procedure Loaded; override;

		procedure CapitaliseKeyword;
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;

		function GetHighlighterTokenAtRowCol(XY: TPoint; var Token: string;
			var start, tokenType : integer):boolean;

		procedure CloseLookupList; 
		
		function DoOnSpecialLineColors(Line: integer; var Foreground, Background: TColor): boolean; override;

		procedure Clear;
		procedure CommentSelection;
		procedure UnCommentSelection;
		procedure Capitalise;
		procedure UnCapitalise;
		procedure AddQuestGlyph(const Glyphno: TSynEditGutterImageIndex; const LineNo: integer);
		procedure RemoveQuestGlyph(const Glyphno: TSynEditGutterImageIndex; const LineNo: integer);
		procedure SetExecutionHighlighting(const ExecutelineBegin: integer; const ExecuteLineEnd: integer);
		procedure SetLineColor(line: integer; kind: TErrorKind);
		procedure ClearStaticLineColors;
		procedure RemoveMarkers;

		function CoorToIndex(CPos: TPoint): integer;
		function IndexToCoor(ind: integer): TPoint;
		function GetTokenAtRowCol(XY: TPoint; var start, stop: integer): string;

		procedure EnsureSelectedIsVisible;

// SyntaxMemoWithStuff
		procedure CloseUpLists;
		procedure OpenFileAtCursor;
		procedure WSFind;
		procedure WSFindNext;
		procedure WSReplace;

		function FindBreakpoint(Row : integer):TSyntaxMemoWithStuff2Breakpoint;

		procedure ToggleBreakpoint(Row: integer);
		procedure DisableBreakpoint(Row: integer);
		procedure EnableBreakpoint(Row: integer);
		procedure InvalidBreakpoint(Row: integer);
		procedure ValidBreakpoint(Row: integer);
		function IsABreakpoint(Row: integer): boolean;
		procedure RemoveAllBreakpoints;
		procedure SetBreakpoint(Row: integer);
		procedure RemoveBreakpoint(Row: integer);

		property PersistentFindData : TEdPersistent read FPersist;

		property FileName: string read FFileName write FFileName;
		property SaveFormat: TSynEditSaveFormat read FSaveFormat write FSaveFormat;
		property ErrorLine: Integer read GetErrorLine write SetErrorLine;
		property ErrorBackColor: TColor read GetErrorBackColor write SetErrorBackColor;
		property ErrorForeColor: TColor read GetErrorForeColor write SetErrorForeColor;
		property ExecutionBackColor: TColor read GetExecutionBackColor write SetExecutionBackColor;
		property ExecutionForeColor: TColor read GetExecutionForeColor write SetExecutionForeColor;

	published
// SyntaxMemoWithStuff
		property FindDialogCaption				: String										read FFindDialogCaption 				write FFindDialogCaption;
		property ReplaceDialogCaption 		: String										read FReplaceDialogCaption			write FReplaceDialogCaption;
		property FindDialogHelpContext		: Integer 									read FFindDialogHelpContext 		write FFindDialogHelpContext;
		property ReplaceDialogHelpContext : Integer 									read FReplaceDialogHelpContext	write FReplaceDialogHelpContext;
		property KeywordCapitalise				: Boolean 									read FKeywordCapitalise 				write FKeywordCapitalise;
		property OnGetHintText						: TGetHintText							read FOnGetHintText 						write FOnGetHintText;
		property UseNavigateHyperLinks		: Boolean 									read FUseNavigateHyperLinks 		write FUseNavigateHyperLinks;
		property NavigatorHyperLinkStyle	: TStringList 							read GetNavigatorHyperLinkStyle write SetNavigatorHyperLinkStyle;
		property OnNavigateHyperLinkClick : TNavigateHyperLinkClick 	read FNavigateHyperLinkClick		write FNavigateHyperLinkClick;
		property OnOpenFileAtCursor 			: TOpenFileAtCursorEvent		read FOnOpenFileAtCursor				write FOnOpenFileAtCursor;
		property ListDelay								: Integer 									read GetListDelay 							write SetListDelay;
		property WordList 								: TWordList 								read FWordList									write SetWordList;
		property SQLInsightList 					: TSQLInsightList 					read FSQLInsightList						write SetSQLInsightList;
		property FindSettingsRegistryKey	: String										read FFindSettingsRegistryKey 	write SetFindSettingsRegistryKey;
		property OnDotLookup							: TDotLookupEvent 					read FOnDotLookup 							write FOnDotLookup;
		property AutoDotLookup						: boolean 									read FAutoDotLookup 						write FAutoDotLookup default true;
		property OnChangeKeywordCase			: TChangeKeywordCase				read FChangeKeywordCase 				write FChangeKeywordCase;
		property OnGetHyperlinkToken			: TGetHighlighterTokenEvent read FGetHyperlinkToken 				write FGetHyperlinkToken;
	end;

procedure Register;

implementation
uses
	FindDlg,
	ReplDlg,
	SynEditKeyCmds,
	Registry;

const
	DIGIT = ['0'..'9'];
	ALPHA = ['A'..'Z', 'a'..'z'];
	IDENT = ALPHA + DIGIT + ['_'];

{$R SyntaxMemoWithStuff2.res}

procedure Register;
begin
	RegisterComponents('SynEdit', [TSyntaxMemoWithStuff2]);
end;

{ TSyntaxMemoWithStuff2 }

procedure TSyntaxMemoWithStuff2.AddQuestGlyph(const Glyphno: TSynEditGutterImageIndex;
	const LineNo: integer);
var
	item: TSynEditMark;
	CntMark: Integer;
begin
	if (Marks.Count > 0) then
	begin
		// because marks also used for showing bookmarks
		// we have to watch out to delete or replace them
		// Glyphs got bookmarkNumber > -1
		CntMark := Marks.Count;
		if (Marks.Items[CntMark - 1].Line = LineNo)
			and (Marks.Items[CntMark - 1].BookmarkNumber = -1) then
		begin
			Marks.Items[CntMark - 1].ImageIndex := Ord(Glyphno) + 10;
			exit;
		end;
	end;
	item := TSynEditMark.Create(Self);
	Marks.Add(item);
	item.Line := LineNo;
	item.Column := 1;
	item.ImageIndex := Ord(Glyphno) + 10;
	item.Visible := TRUE;
	item.BookmarkNumber := -1;
end;

procedure TSyntaxMemoWithStuff2.RemoveQuestGlyph(const Glyphno: TSynEditGutterImageIndex;
	const LineNo: integer);
var
	item: TSynEditMark;
	CntMark: Integer;
begin
	// remove only glyphs, not bookmarks.
	// Bookmarks have a bookmarknumber
	if (Marks.Count > 0) then
	begin
		CntMark := Marks.Count;
		while (CntMark > 0)
			and (Marks.Items[CntMark - 1].Line <> LineNo)
			and (Marks.Items[Cntmark - 1].BookmarkNumber = -1) do
		begin
			CntMark := CntMark - 1;
		end;
		if (CntMark > 0)
			and (Marks.Items[CntMark - 1].Line = LineNo)
			and (Marks.Items[CntMark - 1].ImageIndex = Ord(Glyphno) + 10) then
		begin
			item := Marks.Items[Cntmark - 1];
			marks.Remove(item);
			item.free;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.Capitalise;
var
	S: string;
begin
	if not ReadOnly then
	begin
		S := SelText;
		S := AnsiUpperCase(S);
		SelText := S;
	end;
end;

procedure TSyntaxMemoWithStuff2.CommentSelection;
var
	S: TStringList;
	Idx: Integer;
	LogEOL:boolean;

begin
	if (ReadOnly = false) and (SelText <> '')then
	begin
		S := TStringList.Create;
		try
			if (copy(SelText,length(SelText) - 1,2) = #13#10) then
				LogEOL := true
			else
				LogEOL := false;

			S.Text := SelText;
			for Idx := 0 to S.Count - 1 do
			begin
				S[Idx] := '/*  ' + S[Idx] + '  */';
			end;
			if LogEOL = false then
				SelText := copy(S.Text, 1, length(S.Text) - 2)
			else
				SelText := S.Text;
		finally
			S.Free;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.SetErrorBackColor(const Value: TColor);
begin
	FErrorBackColor := Value;
end;

procedure TSyntaxMemoWithStuff2.SetErrorForeColor(const Value: TColor);
begin
	FErrorForeColor := Value;
end;

procedure TSyntaxMemoWithStuff2.SetErrorLine(const Value: Integer);
begin
	if (Value <> FErrorLine) then
	begin
		FErrorLine := Value;
		refresh;
	end;
end;

procedure TSyntaxMemoWithStuff2.UnCapitalise;
var
	S: string;
begin
	if not ReadOnly then
	begin
		S := SelText;
		S := AnsiLowerCase(S);
		SelText := S;
	end;
end;

procedure TSyntaxMemoWithStuff2.UnCommentSelection;
var
	S: TStringList;
	Idx: Integer;
	Temp: string;
	CommPos: Integer;
	i, j:integer;
	strSpace : string;
	LogEOL:boolean;
begin
	if not ReadOnly then
	begin
		S := TStringList.Create;
		try
			if (copy(SelText,length(SelText) - 1,2) = #13#10) then
				LogEOL := true
			else
				LogEOL := false;
			S.Text := SelText;
			for Idx := 0 to S.Count - 1 do
			begin
				Temp := S[Idx];
				for i := 2 downto 0 do
				begin
					strSpace := '/*';
					for j := 1 to i do
					begin
						strSpace := strSpace + ' ';
					end;
					CommPos := Pos(strSpace, Temp);
					while CommPos <> 0 do
					begin
						Delete(Temp, CommPos, 2 + i);
						CommPos := Pos(strSpace, Temp);
					end;

					strSpace := '*/';
					for j := 1 to i do
					begin
						strSpace := ' ' + strSpace;
					end;
					CommPos := Pos(strSpace, Temp);
					while CommPos <> 0 do
					begin
						Delete(Temp, CommPos, 2 + i);
						CommPos := Pos(strSpace, Temp);
					end;
				end;
				S[Idx] := Temp;
			end;
			if LogEOL = false then
				SelText := copy(S.Text, 1, length(S.Text) - 2)
			else
				SelText := S.Text;
		finally
			S.Free;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.SetExecutionHighlighting(const ExecutelineBegin: integer;
	const ExecuteLineEnd: integer);
// Set the colour of an execution line
// Color of line may be something else - namely a breakpoint which need to be re-coloured
var
	CaretPoint: TPoint;
begin
	// set new execution line
	FExecutelineBegin := ExecutelineBegin;
	FExecuteLineEnd := ExecuteLineEnd;
	if (FExecutelineBegin > -1) then // Only set if fexecline is valid (ie. > -1)
	begin
		// Set cursor position
		CaretPoint.Y := FExecutelineBegin;
		CaretPoint.X := 1;
		CaretXY := CaretPoint;
	end;
	Refresh;
end;

function TSyntaxMemoWithStuff2.GetExecutionBackColor: TColor;
begin
	result := FExecutionBackColor;
end;

procedure TSyntaxMemoWithStuff2.SetExecutionBackColor(const Value: TColor);
begin
	FExecutionBackColor := value;
end;

function TSyntaxMemoWithStuff2.GetExecutionForeColor: TColor;
begin
	result := FExecutionForeColor;
end;

procedure TSyntaxMemoWithStuff2.SetExecutionForeColor(const Value: TColor);
begin
	FExecutionForeColor := Value;
end;

constructor TSyntaxMemoWithStuff2.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
	FStaticLineColors := TList.Create;

	FExecutelineBegin := -1; // No execution line to start
	FExecutelineEnd := -1; // No execution line to end
	FErrorLine := -1; // No error line to start
	FErrorBackColor := clMaroon;
	FErrorForeColor := clWhite;
	FExecutionBackColor := clAqua;
	FExecutionForeColor := clBlack;
	Font.Name := 'Courier New';
	Font.Size := 10;

	// SyntaxMemoWithStuff
	FNavigatorHyperLinkStyle := TStringList.Create;
	FNavigatorHyperLinkStyle.Add('4');

	FLinking := False;
	FWordList := TWordList.Create(Self);
	FSQLInsightList := TSQLInsightList.Create(Self);
	FTimer := TTimer.Create(Self);
	FTimer.Interval := 800;
	FTimer.Enabled := False;
	FTimer.OnTimer := TimerEvent;

	FHintTimer := TTimer.Create(Self);
	FHintTimer.Interval := 800;
	FHintTimer.Enabled := False;
	FHintTimer.OnTimer := HintTimerEvent;

	if not (csDesigning in ComponentState) then
	begin
		F := TPopUpListBox.Create(Self);
		F.Visible := False;
		F.Font.Name := 'MS Sans Serif';
		F.Font.Size := 9;
		F.Width := 250;
		F.Parent := Self;
		F.Height := 100;
		F.Style := lbOwnerDrawFixed;
		F.OnDrawItem := DrawListItem;

		FSQL := TPopUpListBox.Create(Self);
		FSQL.Visible := False;
		FSQL.Font.Name := 'MS Sans Serif';
		FSQL.Font.Size := 9;
		FSQL.Width := 250;
		FSQL.Height := 100;
		FSQL.Parent := Self;
		FSQL.Style := lbOwnerDrawFixed;
		FSQL.OnDrawItem := DrawSQLListItem;

		FHintWindow := TPopupHintWindow.Create(Self);
		FHintWindow.Editor := Self;
		FHintWindow.Parent := Self;
		FHintWindow.Visible := False;
		FHintWindow.Height := 18;
		FHintWindow.Width := 260;
	end;
	FPersist := TEdPersistent.Create(Self);
	FPersist.Editor := Self;

	// QuestSyntaxMemo
	FDotLookupVisible := false;
	FManualLookupInvoked := false;
	FAutoDotLookup := TRUE;
	FDotLookupList := TStringList.Create;
	FDotLookupTimer := TTimer.Create(Self);
	FDotLookupTimer.Interval := 1000;
	FDotLookupTimer.Enabled := False;
	FDotLookupTimer.OnTimer := DotLookupTimerEvent;
	if not (csDesigning in ComponentState) then
	begin
		FDotLBX := TPopUpListBox2.Create(Self);
		FDotLBX.Visible := False;
		FDotLBX.Font.Name := 'MS Sans Serif';
		FDotLBX.Font.Size := 9;
		FDotLBX.Width := 250;
		FDotLBX.Parent := Self;
		FDotLBX.Height := 100;
		//FDotLBX.Style := lbOwnerDrawFixed;
		//FDotLBX.OnDrawItem := DrawDotLookupItem;
	end;

	fDecorator := TSynEditDecorator.Create(nil);
	fDecorator.Editor := self;
end;

destructor TSyntaxMemoWithStuff2.Destroy;
begin
	RemoveMarkers;
	ClearStaticLineColors;
	FStaticLineColors.free;
	FQuestGutterGlyphs.free;

	// TSyntaxMemoWithStuff
	FPersist.Free;
	FTimer.OnTimer := nil;
	FTimer.Free;
	F.Free;
	FSQL.Free;
	FWordList.Free;
	FSQLInsightList.Free;
	FNavigatorHyperLinkStyle.Free;

	// QuestSyntaxMemo
	FDotLBX.Free;
	FDotLookupList.Free;
	FDotLookupTimer.Free;

	fDecorator.Free;

	inherited;
end;

function TSyntaxMemoWithStuff2.GetErrorBackColor: TColor;
begin
	result := FErrorBackColor;
end;

function TSyntaxMemoWithStuff2.GetErrorForeColor: TColor;
begin
	result := FErrorForeColor;
end;


function TSyntaxMemoWithStuff2.GetErrorLine: Integer;
begin
	result := FErrorLine;
end;


function TSyntaxMemoWithStuff2.DoOnSpecialLineColors(Line: integer; var Foreground,
	Background: TColor): boolean;
var
	i: integer;

begin
	result := inherited DoOnSpecialLineColors(Line, Foreground, Background);

	if (FExecutelineBegin <= Line)
		and (Line <= FExecuteLineEnd) then
	begin
		Background := FExecutionBackColor;
		Foreground := FExecutionForeColor;
		Result := TRUE;
	end
	else
	begin
		if Line = FErrorLine then
		begin
			Background := FErrorBackColor;
			Foreground := FErrorForeColor;
			Result := TRUE;
		end
		else
			if FStaticLineColors.count > 0 then
			begin
				for i := 0 to FStaticLineColors.Count - 1 do
					if PColorRec(FStaticLineColors.Items[i])^.Line = Line then
					begin
						case PColorRec(FStaticLineColors.Items[i])^.kind of
							ekError:
								begin
									Background := Color;
									Foreground := clRed;
								end;
							ekServer:
								begin
									Background := Color;
									Foreground := clBlue;
								end;
						end;
						Result := TRUE;
					end;
			end;
	end;
end;

procedure TSyntaxMemoWithStuff2.SetLineColor(line: integer; kind: TErrorKind);
var
	temp: PColorRec;
	i: integer;
	LogFound: Boolean;
begin
	i := 0;
	LogFound := false;
	while (logFound = false) and (i < FStaticLineColors.Count) do
	begin
		if PColorRec(FStaticLineColors.Items[i])^.Line = Line then
		begin
			LogFound := true;
		end
		else
		begin
			i := i + 1;
		end;
	end;
	if not LogFound then
	begin
		new(temp);
		temp^.line := line;
		temp^.kind := kind;
		FStaticLineColors.Add(temp);
	end
	else
	begin
		PColorRec(FStaticLineColors.Items[i])^.kind := kind;
	end;
	InvalidateLine(line);
end;


procedure TSyntaxMemoWithStuff2.ClearStaticLineColors;
var
	i: integer;
begin
	for i := 0 to FStaticLineColors.Count - 1 do
		dispose(PColorRec(FStaticLineColors[i]));
	FStaticLineColors.Clear;
end;


procedure TSyntaxMemoWithStuff2.RemoveMarkers;
var
	item: TSynEditMark;
	i: Integer;
begin
	// Reset all markers except bookmarks
	for i := Marks.count - 1 downto 0 do
	begin
		item := Marks.Items[i];
		if item.BookmarkNumber = -1 then
		begin
			Marks.Remove(item);
			item.free;
		end;
	end;
	Invalidate;
end;

procedure TSyntaxMemoWithStuff2.Clear;
begin
	RemoveMarkers;
	ClearStaticLineColors;
	Lines.Clear;
	FErrorLine := -1
end;


//
//==============================================================================
//Utility functions
//------------------------------------------------------------------------------

function ParseSection(ParseLine : string; ParseNum : Integer; ParseSep : Char) : string;
var
	iPos : LongInt;
	i : Integer;
	tmp : string;

begin
	tmp := ParseLine;
	for i := 1 to ParseNum do
	begin
		iPos := Pos(ParseSep, tmp);
		if iPos > 0 then
		begin
			if i = ParseNum then
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
			if ParseNum > i then
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
end;

function StripCRLF(Line : string) : string;
var
	Idx : Integer;

begin
	Result := '';
	for Idx := 1 to Length(Line) do
		if not (Line[Idx] in [#13, #10]) then
			Result := Result + Line[Idx];
end;

function StripLine(Line : string) : string;
var
	Idx : Integer;

begin
	Result := '';
	for Idx := 1 to Length(Line) do
		if Line[Idx] in ['a'..'z', 'A'..'Z', '0'..'9', '_'] then
			Result := Result + Line[Idx];
end;

function IsUpperCase(Ch : Char) : Boolean;
begin
	Result := False;
	if Ch in ['A'..'Z', 'a'..'z'] then
	begin
		if Ch in ['A'..'Z'] then
			Result := True;
	end;
end;

function IsStringPredominatelyUpperCase(St : string) : Boolean;
var
	Idx : Integer;
	StLen : Integer;
	HalfStLen : Integer;
	TrueCount : Integer;

begin
	Result := False;
	StLen := Length(St);

	if StLen > 0 then
	begin
		if IsUpperCase(St[1]) then
		begin
			Result := True;
		end
		else
		begin
			HalfStLen := StLen div 2;
			TrueCount := 0;
			for Idx := 1 to StLen do
			begin
				if IsUpperCase(St[Idx]) then
					TrueCount := TrueCount + 1;
			end;

			if TrueCount > HalfStLen then
				Result := True;
		end;
	end;
end;

procedure TPopupListBox.CreateParams(var Params : TCreateParams);
begin
	inherited CreateParams(Params);
	with Params do
	begin
		Style := Style or WS_BORDER;
		ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
		{$IFDEF VER120}
			AddBiDiModeExStyle(ExStyle);
		{$ENDIF}
		WindowClass.Style := CS_SAVEBITS;
	end;
end;

procedure TPopupListbox.CreateWnd;
begin
	inherited CreateWnd;
	Windows.SetParent(Handle, 0);
	CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopupHintWindow.CreateParams(var Params : TCreateParams);
begin
	inherited CreateParams(Params);
	with Params do
	begin
		Style := Style or WS_BORDER;
		ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
		{$IFDEF VER120}
			AddBiDiModeExStyle(ExStyle);
		{$ENDIF}
		WindowClass.Style := CS_SAVEBITS;
	end;
end;

procedure TPopupHintWindow.CreateWnd;
begin
	inherited CreateWnd;
	Windows.SetParent(Handle, 0);
	CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopupHintWindow.Paint;
begin
	with Canvas do
	begin
		Brush.Color := clInfobk;
		FillRect(ClientRect);
	end;
	DrawText(Canvas.Handle, PChar(FHintText), Length(FHintText), FDrawRect, DT_WORDBREAK);
end;

procedure TPopUpHintWindow.SetHintText(const Value : string);
begin
	FHintText := Value;
	Canvas.Font.Name := 'MS Sans Serif';
	Canvas.Font.Size := 8;

	//calc the rect for the hint window...
	FDrawRect.Top := 1;
	FDrawRect.Left := 2;
	FDrawRect.Bottom := FDrawRect.Top + Canvas.TextHeight(FHintText);
	if Canvas.TextWidth(FHintText) < 260 then
		FDrawRect.Right := FDrawRect.Left + Canvas.TextWidth(FHintText)
	else
		FDrawRect.Right := FDrawRect.Left + 260;

	DrawText(Canvas.Handle, PChar(FHintText), Length(FHintText), FDrawRect, DT_CALCRECT or DT_WORDBREAK);
	Width := FDrawRect.Right - FDrawRect.Left + 5;
	Height := FDrawRect.Bottom - FDrawRect.Top + 4;
end;

procedure TPopUpHintWindow.PopUp(Position : TPoint);
begin
	SetWindowPos(Handle, HWND_TOP, Position.X, Position.Y, 0, 0,
		SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
	FHintVisible := True;
	if Assigned(FEditor) then
		Windows.SetFocus(FEditor.Handle);
end;

procedure TPopUpHintWindow.Close;
begin
	SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
		SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
	FHintVisible := False;
end;

//==============================================================================
//TWordList
//------------------------------------------------------------------------------

constructor TWordList.Create(AOwner : TSyntaxMemoWithStuff2);
begin
	inherited Create(TWordListItem);
	FOwner := AOwner;
end;

function TWordList.GetItem(Index : Integer) : TWordListItem;
begin
	Result := TWordListItem(inherited GetItem(Index));
end;

procedure TWordList.SetItem(Index : Integer; Value : TWordListItem);
begin
	inherited SetItem(Index, Value);
end;

function TWordList.Add : TWordListItem;
begin
	Result := TWordListItem(inherited Add);
end;

function TWordList.GetOwner : TPersistent;
begin
	Result := FOwner;
end;

procedure TWordList.LoadFromFile(FileName : string);
var
	InFile : TextFile;
	Line : string;

begin
	Clear;
	AssignFile(InFile, FileName);
	Reset(InFile);
	while not Eof(InFile) do
	begin
		ReadLn(InFile, Line);
		Line := AnsiLowerCase(Line);
		with Self.Add do
		begin
			case StrToInt(ParseSection(Line, 1, '`')) of
				0 : ItemType := itSQL;
				1 : ItemType := itPLSQL;
				2 : ItemType := itTable;
				3 : ItemType := itColumn;
				4 : ItemType := itTrigger;
				5 : ItemType := itException;
				6 : ItemType := itGenerator;
				7 : ItemType := itFunction;
				8 : ItemType := itProcedure;
				9 : ItemType := itUDF;
			end;
			MatchItem := ParseSection(Line, 2, '`');
			InsertText := ParseSection(Line, 3, '`');
		end;
	end;
	CloseFile(InFile);
end;

//==============================================================================
//TSQLInsightListItem
//------------------------------------------------------------------------------

constructor TSQLInsightListItem.Create(Collection : TCollection);
begin
	inherited Create(Collection);
	FInsertText := TStringList.Create;
end;

destructor TSQLInsightListItem.Destroy;
begin
	FInsertText.Free;
	inherited Destroy;
end;

procedure TSQLInsightListItem.SetInsertText(Value : TStringList);
begin
	FInsertText.Assign(Value);
end;

function TSQLInsightListItem.GetInsertText : TStringList;
begin
	Result := FInsertText;
end;

//==============================================================================
//TSQLInsightList.
//------------------------------------------------------------------------------

constructor TSQLInsightList.Create(AOwner : TSyntaxMemoWithStuff2);
begin
	inherited Create(TSQLInsightListItem);
	FOwner := AOwner;
end;

function TSQLInsightList.GetItem(Index : Integer) : TSQLInsightListItem;
begin
	Result := TSQLInsightListItem(inherited GetItem(Index));
end;

procedure TSQLInsightList.SetItem(Index : Integer; Value : TSQLInsightListItem);
begin
	inherited SetItem(Index, Value);
end;

function TSQLInsightList.Add : TSQLInsightListItem;
begin
	Result := TSQLInsightListItem(inherited Add);
end;

function TSQLInsightList.GetOwner : TPersistent;
begin
	Result := FOwner;
end;

procedure TSQLInsightList.LoadFromFile(FileName : string);
var
	InFile : TextFile;
	Line : string;
	wLine: string;

	Match : string;
	Descript : string;
	T : TStringList;

	State : Integer;

begin
	Clear;
	T := TStringList.Create;
	try
		AssignFile(InFile, FileName);
		Try
			 Reset(InFile);
			 try
					State := 0;
					while not Eof(InFile) do
					begin
						ReadLn(InFile, Line);
						wLine := AnsiLowerCase(Line);
						case State of
							0 :
								begin
									if Pos('<====', wLine) = 1 then
									begin
										State := 1;
										Match := '';
										Descript := '';
										T.Clear;
									end;
								end;
							1 :
								begin
									if Pos('item=', wLine) = 1 then
									begin
										Match := Copy(wLine, 6, 255);
										State := 2;
									end;
								end;

							2 :
								begin
									if Pos('desc=', wLine) = 1 then
									begin
										Descript := Copy(Line, 6, 255);
										State := 3;
									end;
								end;

							3 :
								begin
									if Pos('====>', wLine) = 1 then
									begin
										with Self.Add do
										begin
											Description := Descript;
											MatchItem := Match;
											InsertText.Text := T.Text;
										end;
										State := 0;
									end
									else
										T.Add(Line);
								end;
						end;
					end;
			 finally
					CloseFile(InFile);
			 end;
		except
			 //Do nothing....
		end;
	finally
		T.Free;
	end;
end;

procedure TSQLInsightList.SaveToFile(FileName : string);
var
	InFile : TextFile;
	Line : string;
	Idx : Integer;

begin
	AssignFile(InFile, FileName);
	Rewrite(InFile);
	try
		for Idx := 0 to Self.Count - 1 do
		begin
			with Items[Idx] do
			begin
				Line := '<====' + IntToStr(Idx) + #13#10;
				Line := Line + 'item=' + MatchItem + #13#10;
				Line := Line + 'desc=' + Description + #13#10;
				Line := Line + trim(InsertText.Text)+#13#10;
				Line := Line + '====>' + #13#10;
				Write(InFile, Line);
			end;
		end;
	finally
		CloseFile(InFile);
	end;
end;



//==============================================================================
//TSyntaxMemoWithStuff2
//------------------------------------------------------------------------------


procedure TSyntaxMemoWithStuff2.Loaded;
begin
	inherited Loaded;

	if not (csDesigning in ComponentState) and not Assigned(BookMarkOptions.BookmarkImages) then
		begin
			FQuestGutterGlyphs := TImageList.Create(Self);
			FQuestGutterGlyphs.Width := 16;
			FQuestGutterGlyphs.Height := 16;
			FquestGutterGlyphs.BlendColor := clBtnFace;
			FquestGutterGlyphs.DrawingStyle := dsTransparent;
			FQuestGutterGlyphs.ResourceLoad(rtBitmap, 'GUTTER', clFuchsia);
			BookMarkOptions.BookmarkImages := FQuestGutterGlyphs;
		end;
	Invalidate;
end;

procedure TSyntaxMemoWithStuff2.SetListDelay(Value : Integer);
begin
	FTimer.Interval := Value;
	FHintTimer.Interval := Value;
	FDotLookupTimer.Interval := Value;
end;

function TSyntaxMemoWithStuff2.GetListDelay : Integer;
begin
	Result := FTimer.Interval;
end;


procedure TSyntaxMemoWithStuff2.DrawListItem(Control : TWinControl; Index : Integer;
	Rect : TRect; State : TOwnerDrawState);
var
	Bit1,
		Bit2,
		Bit3 : string;
	R : TRect;

begin
	with F.Canvas do
	begin
		case TWordListItem(F.Items.Objects[Index]).ItemType of
			itSQL : Bit1 := 'SQL';
			itPLSQL : Bit1 := 'PL/SQL';
			itTable : Bit1 := 'Relation';
			itColumn : Bit1 := 'Column';
			itTrigger : Bit1 := 'Trigger';
			itException : Bit1 := 'Exception';
			itGenerator : Bit1 := 'Generator';
			itFunction : Bit1 := 'Function';
			itProcedure : Bit1 := 'Procedure';
			itUDF : Bit1 := 'UDF';
		end;

		Bit2 := TWordListItem(F.Items.Objects[Index]).MatchItem;
		Bit3 := TWordListItem(F.Items.Objects[Index]).InsertText;

		FillRect(Rect);
		R := Rect;
		R.Right := R.Left + 55;
		TextOut(R.Left, R.Top, Bit1);

		Font.Style := [fsBold];
		R.Left := R.Right;
		R.Right := R.Left + TextWidth(Bit2);
		TextOut(R.Left, R.Top, Bit2);

		if TWordListItem(F.Items.Objects[Index]).ItemType in [itFunction, itProcedure] then
		begin
			Font.Style := [];
			R.Left := R.Right + 3;
			R.Right := Rect.Right;
			TextOut(R.Left, R.Top, Bit3);
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.DrawSQLListItem(Control : TWinControl; Index : Integer;
	Rect : TRect; State : TOwnerDrawState);
var
	Bit1,
		Bit2 : string;
	R : TRect;

begin
	with FSQL.Canvas do
	begin
		Bit1 := TSQLInsightListItem(FSQL.Items.Objects[Index]).Description;
		Bit2 := TSQLInsightListItem(FSQL.Items.Objects[Index]).MatchItem;

		FillRect(Rect);
		R := Rect;
		R.Right := R.Left + 180;
		TextOut(R.Left, R.Top, Bit1);

		Font.Style := [fsBold];
		R.Left := R.Right + 3;
		R.Right := R.Left + TextWidth(Bit2);
		TextOut(R.Left, R.Top, Bit2);
	end;
end;

procedure TSyntaxMemoWithStuff2.SetWordList(Value : TWordList);
begin
	FWordList.Assign(Value);
end;

procedure TSyntaxMemoWithStuff2.SetSQLInsightList(Value : TSQLInsightList);
begin
	FSQLInsightList.Assign(Value);
end;

procedure TSyntaxMemoWithStuff2.TimerEvent(Sender : TObject);
begin
	if FHintWindow.HintVisible then
		FHintWindow.Close;

	SetWindowPos(F.Handle, HWND_TOP, FListPos.X, FListPos.Y, 0, 0,
		SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
	FSQLListVisible := True;
	Windows.SetFocus(Handle);
	F.ItemIndex := 0;
	FTimer.Enabled := False;
end;

procedure TSyntaxMemoWithStuff2.HintTimerEvent(Sender : TObject);
begin
	if Focused then
		FHintWindow.PopUp(Point(FMarkHintPos.x, FMarkHintPos.Y));
	FHintTimer.Enabled := False;
end;


procedure TSyntaxMemoWithStuff2.CloseUpLists;
begin
	FTimer.Enabled := False;
	FHintTimer.Enabled := False;
	if Assigned(F) then
	begin
		SetWindowPos(F.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
			SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
	end;
	FSQLListVisible := False;

	if Assigned(FSQL) then
	begin
		SetWindowPos(FSQL.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
			SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
	end;
	FSQLInsListVisible := False;

	if Assigned(FHintWindow) then
	begin
		FHintWindow.Close;
	end;
end;

procedure TSyntaxMemoWithStuff2.KeyPress(var Key : Char);
var
	idx 				: Integer;
	P 					: TPoint;
	InsertText	: string;
	NewSelStart : LongInt;
	Offset			: Integer;
	OffsetText	: string;
	OffsetList	: TStringList;

	s1,s2 			: string;
	L 					: integer;

begin
	if not ReadOnly then
	begin
		if FJustDidIndent then
		begin
			FJustDidIndent := False;
			Exit;
		end;

		if FHintWindow.HintVisible then
			FHintWindow.Close;

		FHintTimer.Enabled := False;
		FTimer.Enabled := False;

		if FSQLInsListVisible then
		begin
			if Key in [#27] then
			begin
				CloseUpLists;
			end
			else
			begin
				if Key in [#13, #32] then
				begin
					OffsetText := '';
					Offset := CaretXY.x - 1;
					for Idx := 1 to Offset do
						OffsetText := OffsetText + ' ';

					OffsetList := TStringList.Create;
					try
						OffsetList.Text := TSQLInsightListItem(FSQL.Items.Objects[FSQL.ItemIndex]).InsertText.Text;
						for Idx := 1 to OffsetList.Count - 1 do
							OffsetList[Idx] := OffsetText + OffsetList[Idx];
						InsertText := Trim(OffsetList.Text);
					finally
						OffsetList.Free;
					end;

					Idx := Pos('^', InsertText);
					if Idx > 0 then
					begin
						NewSelStart := SelStart + Idx - 1;
						Delete(InsertText, Idx, 1);
						SetSelTextBuf(PChar(InsertText));
						SelStart := NewSelStart;
						CaretXY:=BlockBegin;
						Key := #0;
					end
					else
						begin
							SetSelTextBuf(PChar(InsertText));  
						end;

					CloseUpLists;
				end
				else
					Key := #0;
			end;
		end
		else
		begin
			if Key in [#27] then
			begin
				CloseUpLists;
			end
			else
			begin
				if Key in [#13, #9, #32, #40, #41, #44, #46] then
				begin
					if FSQLListVisible then
					begin
						CloseUpLists;
						InsertText := StripCRLF(TWordListItem(F.Items.Objects[F.ItemIndex]).InsertText);
						//InsertText := Copy(InsertText, Length(FBuffer) + 1, Length(InsertText));
						if IsStringPredominatelyUpperCase(FBuffer) then
							InsertText := AnsiUpperCase(InsertText)
						else
							InsertText := AnsiLowerCase(InsertText);

						Idx := Pos('^', InsertText);
						if Idx > 0 then
						begin
							SelStart := SelStart - Length(FBuffer);
							SelLength := Length(FBuffer);

							Delete(InsertText, Idx, 1);
							SetSelTextBuf(PChar(InsertText));
							SelStart := SelStart - (Length(InsertText) - Idx) - 1;
							CaretXY:=BlockBegin;
							Key := #0;
						end
						else
						begin
							SelStart := SelStart - Length(FBuffer);
							SelLength := Length(FBuffer);
							SetSelTextBuf(PChar(InsertText));
						end;

					end;
					FBuffer := '';
				end
				else
				begin
					if key = #8 then
					begin
						FBuffer := Copy(FBuffer, 1, Length(FBuffer) - 1);
						if FSQLListVisible then
						begin
							if (Length(FBuffer) = 0) then
							begin
								CloseUpLists;
							end;
						end;
					end
					else
					begin
						FBuffer := FBuffer + Key
					end;

					//now search in the buffer...
					F.Clear;
					for idx := 0 to FWordList.Count - 1 do
					begin
						if Pos(AnsiUpperCase(FBuffer), AnsiUpperCase(FWordList[idx].MatchItem)) = 1 then
							F.Items.AddObject(FWordList[idx].InsertText, FWordList[idx]);
					end;

					if F.Items.Count > 0 then
					begin
						if (F.Items.Count <> 1) and (AnsiUpperCase(F.Items[0]) <> AnsiUpperCase(FBuffer)) then
						begin
							if FSQLListVisible = False then
							begin
								if GetCaretPos(P) then
								begin
									P := Self.ClientToScreen(P);

									FListPos.X := P.X + ((Length(FBuffer) - 1) * Canvas.TextWidth('W'));
									FListPos.Y := P.Y + Canvas.TextHeight('W');

									//set timer here...
									FTimer.Enabled := True;
								end;
							end;
							F.ItemIndex := 0;
						end
						else
						begin
							CloseUpLists;
						end;
					end
					else
					begin
						CloseUpLists;
					end;
				end;
			end;
		end;
	end;

	if FKeywordCapitalise and (Highlighter<>nil)	then
		if not (key in Highlighter.IdentChars) and (key>#31) then
			CapitaliseKeyword;

	// lookup list box control ==================================================
	if (Key= ' ') and FManualLookupInvoked then
	begin
		FManualLookupInvoked := false;
		Exit; // don't do anything else, the key was Ctrl+Space
	end;

	if FDotLookupVisible then
		begin
			if Key in [#27] then
			begin
				CloseLookupList;
			end
			else
			begin
				if (Key<>#8) and (((Highlighter<>nil) and not (Key in Highlighter.IdentChars)) or
													((Highlighter=nil) and (Key in [#13, #9, ' ', '(', ')', ',', '.', ';']))) then
				begin
					CloseLookupList;

					if FDotLBX.ItemIndex<>-1 then
						begin
							InsertText := FDotLBX.Items[FDotLBX.ItemIndex];
							Idx := Pos('^', InsertText);
							if Idx > 0 then
							begin
								SelStart := SelStart - Length(FDotLookupBuffer);
								SelLength := Length(FDotLookupBuffer);

								Delete(InsertText, Idx, 1);
								SetSelTextBuf(PChar(InsertText));
								SelStart := SelStart - (Length(InsertText) - Idx) - 1;
								CaretXY:=BlockBegin;
							end
							else
							begin
								s1:=lines[CaretY-1];
								idx:=CaretX-1;
								while (idx>0) and (s1[idx]<>'.') do
									dec(idx);

								BlockBegin:=Point(idx+1,CaretY);
								p:=BlockBegin;
								SelLength := CaretX-idx;
								SetSelTextBuf(PChar(InsertText));

								Idx := Pos('(', InsertText);
								if Idx > 0 then
									begin
										CaretXY:=point(p.X+Idx,p.y);
										Key:=#0;
									end;
							end;
						end;

					if Key=#13 then
						Key := #0;
						
					FDotLookupBuffer := '';
				end
				else
				begin
					if key = #8 then
					begin
						FDotLookupBuffer := Copy(FDotLookupBuffer, 1, Length(FDotLookupBuffer) - 1);
						if (Length(FDotLookupBuffer) = 0) then
							CloseLookupList;
							
						Key := #0;
					end
					else
					begin
						FDotLookupBuffer := FDotLookupBuffer + Key
					end;

					//now search in the buffer...
					FDotLbx.Clear;
					for idx := 0 to FDotLookupList.Count - 1 do
					begin
						s1 := AnsiUpperCase(FDotLookupBuffer);
						s2 := AnsiUpperCase(FDotLookupList[idx]);
						if Pos(s1, s2) = 1 then
							FDotLBX.Items.Add(FDotLookupList[idx]);
					end;
					FDotLBX.ItemIndex := 0;
				end;
			end;
		end
	else
	if (Key='.')
		 and FAutoDotLookup
		 and Assigned(FOnDotLookup)
		 and not FDotLookupTimer.Enabled
		 and Assigned(FDotLBX)
		 and not ReadOnly
	then
		begin
			CloseUpLists;
			FManualLookupInvoked := false;
			FDotLookupTimer.Enabled := true;
		end;
	// end of lookup list box control ===========================================


	if ((key=#9) or (key>=' ')) and (CaretY<=lines.count) then
		begin
			L:=length(Lines[CaretY-1]);

			if CaretX>L then
				L:=CaretX;
// Does not work with the current SynEdit implementation
// Later ToDo				
{			if L>=MaxLeftChar then
				begin
					MaxLeftChar:=L+1;
				end;}
		end;

	inherited KeyPress(Key);
end;

procedure TSyntaxMemoWithStuff2.KeyDown(var Key : Word; Shift : TShiftState);
var
	InsightWord : string;
	Found : Boolean;
	Idx : Integer;
	P : TPoint;
	InsertText : string;

	Dum : LongInt;

	ID : string;
	start, tokenType : integer;

	NewSelStart : LongInt;
	Offset : Integer;
	OffsetText : string;
	OffsetList : TStringList;
	Idy : Integer;

begin
	SetErrorLine(-1);

	if FHintWindow.HintVisible then
		FHintWindow.Close;

	if not ReadOnly then
	begin
		FHintTimer.Enabled := False;
		FTimer.Enabled := False;
		if FSQLInsListVisible then
		begin
			case Key of
				VK_UP :
					begin
						if FSQL.ItemIndex <> 0 then
							FSQL.ItemIndex := FSQL.ItemIndex - 1;
						Key := 0;
					end;
				VK_DOWN :
					begin
						if FSQL.ItemIndex <> FSQL.Items.Count - 1 then
							FSQL.ItemIndex := FSQL.ItemIndex + 1;
						Key := 0;
					end;

				VK_LEFT, VK_RIGHT,
					VK_PRIOR, VK_NEXT,
					VK_END, VK_HOME,
					VK_MENU, VK_CONTROL,
					VK_TAB, VK_HELP :
					begin
						CloseUpLists;
					end;

				VK_F1, VK_F2, VK_F3,
					VK_F4, VK_F5, VK_F6,
					VK_F7, VK_F8, VK_F9,
					VK_F10, VK_F11, VK_F12 :
					begin
						CloseUpLists;
					end;

			end;
		end
		else
		begin
			if FSQLListVisible then
			begin
				case Key of
					VK_UP :
						begin
							if F.ItemIndex <> 0 then
								F.ItemIndex := F.ItemIndex - 1;
							Key := 0;
						end;
					VK_DOWN :
						begin
							if F.ItemIndex <> F.Items.Count - 1 then
								F.ItemIndex := F.ItemIndex + 1;
							Key := 0;
						end;
          VK_RETURN :
            begin
              Key := 0;
            end;

					VK_LEFT, VK_RIGHT,
						VK_PRIOR, VK_NEXT,
						VK_END, VK_HOME,
						VK_MENU, VK_CONTROL,
						VK_TAB, VK_HELP :
						begin
							CloseUpLists;
						end;

					VK_F1, VK_F2, VK_F3,
						VK_F4, VK_F5, VK_F6,
						VK_F7, VK_F8, VK_F9,
						VK_F10, VK_F11, VK_F12 :
						begin
							CloseUpLists;
						end;
				end;
			end
			else
			begin
				case Key of
					VK_UP, VK_DOWN,
						VK_LEFT, VK_RIGHT :
						begin
							FBuffer := '';
						end;
					VK_PRIOR, VK_NEXT,
						VK_END, VK_HOME,
						VK_MENU, VK_CONTROL,
						VK_TAB, VK_HELP :
						begin
							FBuffer := '';
						end;

					VK_F1, VK_F2, VK_F3,
						VK_F4, VK_F5, VK_F6,
						VK_F7, VK_F8, VK_F9,
						VK_F10, VK_F11, VK_F12 :
						begin
							FBuffer := '';
						end;
				end;
			end;

			if (ssCtrl in Shift) and (Key = VK_RETURN) then
			begin
				Key := 0;
				Shift := [];
				OpenFileAtCursor;
			end;

			if (ssCtrl in Shift) and (Key = VK_INSERT) then
			begin
				Key := 0;
				Shift := [];
				CopyToClipBoard;
			end;

			if (ssShift in Shift) and (Key = VK_DELETE) then
			begin
				Key := 0;
				Shift := [];
				CutToClipBoard;
			end;

			if (ssShift in Shift) and (Key = VK_INSERT) then
			begin
				Key := 0;
				Shift := [];
				PasteFromClipBoard;
			end;

			if (ssCtrl in Shift) and (ssShift in Shift) and (Key = Ord('I')) then
			begin
				Key := 0;
				Shift := [];
				FJustDidIndent := True;

				ExecuteCommand(ecBlockIndent,#0,nil);
			end;

			if (ssCtrl in Shift) and (ssShift in Shift) and (Key = Ord('U')) then
			begin
				Key := 0;
				Shift := [];
				FJustDidIndent := True;
				ExecuteCommand(ecBlockUnIndent,#0,nil);
			end;

			//SQL Insight....
			if (ssCtrl in Shift) and (Key = Ord('J')) then
			begin
				InsightWord := StripLine(TokenTextAtPos(SelStart, Dum));
				if InsightWord = '' then
					if SelStart <> 1 then
						InsightWord := TokenTextAtPos(SelStart - 1, Dum);

				Found := False;
				//now search in the buffer...
				F.Clear;
				for idx := 0 to FSQLInsightList.Count - 1 do
				begin
					if AnsiUpperCase(InsightWord) = AnsiUpperCase(FSQLInsightList[Idx].MatchItem) then
					begin
						Found := True;
						OffsetText := '';
						Offset := CaretXY.x - 1;
						Offset := Offset - Length(InsightWord);
						for Idy := 1 to Offset do
							OffsetText := OffsetText + ' ';

						OffsetList := TStringList.Create;
						try
							OffsetList.Text := FSQLInsightList[Idx].InsertText.Text;
							for Idy := 1 to OffsetList.Count - 1 do
								OffsetList[Idy] := OffsetText + OffsetList[Idy];
							InsertText := OffsetList.Text;
						finally
							OffsetList.Free;
						end;

						Idy := Pos('^', InsertText);
						if Idy > 0 then
						begin
							SelStart := SelStart - Length(InsightWord);
							NewSelStart := SelStart + Idy - 1;
							Delete(InsertText, Idy, 1);
							SelLength := Length(InsightWord);
							SetSelTextBuf(PChar(InsertText));
							SelStart := NewSelStart;
							CaretXY:=BlockBegin;
						end
						else
						begin
							SelStart := SelStart - Length(InsightWord);
							SelLength := Length(InsightWord);
							SetSelTextBuf(PChar(InsertText));
						end;
						FBuffer := '';
						Break;
					end;
				end;

				if not Found then
				begin
					FSQL.Clear;
					for idx := 0 to FSQLInsightList.Count - 1 do
					begin
						FSQL.Items.AddObject(FSQLInsightList[idx].Description, FSQLInsightList[idx]);
					end;

					if FSQL.Items.Count > 0 then
					begin
						if FSQLInsListVisible = False then
						begin
							if GetCaretPos(P) then
							begin
								if FHintWindow.HintVisible then
									FHintWindow.Close;

								P := Self.ClientToScreen(P);
								FSQL.Left := P.X;
								FSQL.Top := P.Y + Canvas.TextHeight('W');
								;
								SetWindowPos(FSQL.Handle, HWND_TOP, FSQL.Left, FSQL.Top, 0, 0,
									SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
								Windows.SetFocus(Handle);
								FSQLInsListVisible := True;
							end;
						end;
						FSQL.ItemIndex := 0;
					end;
				end;
				Key := 0;
			end;
		end;
	end;

	// lookup list box control ==================================================
	FDotLookupTimer.Enabled := false;
	if (Key=Ord(' ')) and (ssCtrl in Shift) // Ctrl+SPACE always forces lookup
		 and Assigned(FOnDotLookup)
		 and Assigned(FDotLBX)
		 and not ReadOnly
	then
		begin
			FManualLookupInvoked := true;
			DotLookupTimerEvent(Self);
			Key := 0;
		end;
	if FDotLookupVisible and not ReadOnly then
	begin
		case Key of
			VK_RETURN : begin
										key:=0;
									end;
			VK_LEFT,
			VK_UP :
				begin
					if FDotLbx.ItemIndex <> 0 then
						FDotLBX.ItemIndex := FDotLBX.ItemIndex - 1;
					Key := 0;
				end;
			VK_RIGHT,
			VK_DOWN :
				begin
					if FDotLBX.ItemIndex <> FDotLBX.Items.Count - 1 then
						FDotLBX.ItemIndex := FDotLBX.ItemIndex + 1;
					Key := 0;
				end;

			VK_PRIOR :
				begin
					Idx:=FDotLBX.ItemIndex-(FDotLBX.Height div FDotLBX.ItemHeight);
					if Idx<0 then
						Idx:=0;

					FDotLBX.ItemIndex:=Idx;
					Key := 0;
				end;

			VK_NEXT :
				begin
					Idx:=FDotLBX.ItemIndex+(FDotLBX.Height div FDotLBX.ItemHeight);
					if Idx>=FDotLBX.Items.Count then
						Idx:=FDotLBX.Items.Count-1;

					FDotLBX.ItemIndex:=Idx;
					Key := 0;
				end;

			VK_HOME :
				begin
					FDotLBX.ItemIndex:=0;
					Key:=0;
				end;

			VK_END :
				begin
					FDotLBX.ItemIndex:=FDotLBX.Items.Count-1;
					Key:=0;
				end;

			VK_MENU, VK_CONTROL,
				VK_TAB, VK_HELP :
				begin
					CloseLookupList;
				end;

			VK_F1, VK_F2, VK_F3,
				VK_F4, VK_F5, VK_F6,
				VK_F7, VK_F8, VK_F9,
				VK_F10, VK_F11, VK_F12 :
				begin
					CloseLookupList;
				end;
		end; // case
	end;
	// end of lookup list box control ===========================================


	if FKeywordCapitalise and (Highlighter<>nil)	then
		if (key=VK_RETURN) or (key=VK_TAB) then
			CapitaliseKeyword;

	inherited KeyDown(Key, Shift);

	if FUseNavigateHyperLinks and (SelLength = 0) then
	begin
		if (not FLinking) and (Key = VK_CONTROL) then
		begin
			GetCursorPos(p);
			p:=ScreenToClient(p);
			p:=PixelsToRowColumn(p);
			tokenType:=-1;
			start:=-1;
			ID:='';
						
			if Assigned(FGetHyperlinkToken) then
				FGetHyperlinkToken(self,p,ID,start,tokenType)
			else
				GetHighlighterTokenAtRowCol(p,ID,start,tokenType);

			if FNavigatorHyperLinkStyle.IndexOf(IntToStr(tokenType)) > -1 then
			begin
				FLinking := True;

				if fHyperLink<>nil then
					fHyperLink.Free;

				fHyperLink:=fDecorator.Decorations.Add;
				fHyperLink.Line:=P.Y;
				fHyperLink.StartIndex:=start;
				fHyperLink.EndIndex:=start+length(ID);
				fHyperLink.DecorationType:=dtHyperLink;

				Screen.Cursor := crHandPoint;
			end;
		end;

		if Key <> VK_CONTROL then
		begin
			if FLinking then
			begin
				FLinking := False;

				if fHyperLink<>nil then
					begin
						fHyperLink.Free;
						fHyperLink:=nil;
					end;

				Screen.Cursor := crDefault;
			end;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
var
	ID : string;
	start, tokenType : integer;

begin
	SetErrorLine(-1);
	FBuffer := '';
	FHintTimer.Enabled := False;
	FTimer.Enabled := False;

	CloseLookupList;

	if FUseNavigateHyperLinks and (SelLength = 0) then
	begin
		if FLinking then
		begin
			if Assigned(FGetHyperlinkToken) then
				FGetHyperlinkToken(self,PixelsToRowColumn(Point(x,y)),ID,start,tokenType)
			else
				GetHighlighterTokenAtRowCol(PixelsToRowColumn(Point(x,y)),ID,start,tokenType);

			if FNavigatorHyperLinkStyle.IndexOf(IntToStr(tokenType)) > -1 then
			begin
				FLinking := False;

				if fHyperLink<>nil then
					begin
						fHyperLink.Free;
						fHyperLink:=nil;
					end;

				Screen.Cursor := crDefault;

				if Assigned(FNavigateHyperLinkClick) then
				begin
					FHintTimer.Enabled := False;
					FNavigateHyperLinkClick(Self, ID);
				end;

				Exit;
			end;
		end;
	end;

	inherited MouseDown(Button, Shift, X, Y);
end;

procedure TSyntaxMemoWithStuff2.OpenFileAtCursor;
var
	ID : string;
	start, tokenType : integer;

begin
	GetHighlighterTokenAtRowCol(CaretXY,ID,start,tokenType);

	if FNavigatorHyperLinkStyle.IndexOf(IntToStr(tokenType)) > -1 then
	begin
		if Assigned(FOnOpenFileAtCursor) then
			FOnOpenFileAtCursor(Self, ID);
	end;
end;

procedure TSyntaxMemoWithStuff2.MouseMove(Shift : TShiftState; X, Y : Integer);
var
	aKey : Word;
	ID : string;
	Temp : string;
	start,tokenType : integer;
	
begin
	inherited MouseMove(Shift, X, Y);

	if FUseNavigateHyperLinks and (SelLength = 0) then
	begin
		mpos := Point(X, Y);

		// Are we linking now ?
		if FLinking then
		begin
			if fDecorator.DecorationAt(PixelsToRowColumn(mpos))<>fHyperLink then
				begin
					//mouse has moved out of ID rect cancel link effect
					aKey := VK_CONTROL;
					KeyUp(aKey, []);
				end;
		end
		else
		begin
			FMarkHintPos:=mpos;
			mpos:=PixelsToRowColumn(mpos);

			if not FHintWindow.HintVisible and (SelLength = 0) then
			begin
				if not (FSQLListVisible or FSQLInsListVisible) then
				begin
					GetHighlighterTokenAtRowCol(mpos,id,start,tokenType);
					if FNavigatorHyperLinkStyle.IndexOf(IntToStr(TokenType)) > -1 then
					begin
						FMarkHintPos := Self.ClientToScreen(FMarkHintPos);
						FMarkHintPos.Y := FMarkHintPos.Y + Canvas.TextHeight('W') + 1;

						Temp := '';
						if Assigned(FOnGetHintText) then
						begin
							FOnGetHintText(Self, ID, Temp, htInformation);
							if Temp <> '' then
							begin
								FHintWindow.HintText := Temp;
								FHintTimer.Enabled := True;
							end;
						end;
					end;
				end;
			end
			else
			begin
					GetHighlighterTokenAtRowCol(mpos,id,start,tokenType);
				if FNavigatorHyperLinkStyle.IndexOf(IntToStr(tokenType)) = -1 then
				begin
					//mouse has moved out of ID rect cancel link effect
					FHintWindow.Close;
					FHintTimer.Enabled := False;
				end;
			end;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.KeyUp(var Key : Word; Shift : TShiftState);
begin
	inherited KeyUp(Key, Shift);

	if FUseNavigateHyperLinks and (SelLength = 0) then
	begin
		if FLinking then
		begin
			FLinking := False;
			if fHyperLink<>nil then
				begin
					fHyperLink.Free;
					fHyperLink:=nil;
				end;
				
			Screen.Cursor := crDefault;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.WMWindowPosChanging(var Message : TMessage);
begin
	CloseUpLists;
end;

procedure TSyntaxMemoWithStuff2.WMKillFocus(var Message : TMessage);
begin
	inherited;
	
	CloseUpLists;
end;

procedure TSyntaxMemoWithStuff2.CMMouseLeave(var Message : TMessage);
begin
	FHintWindow.Close;
	inherited;
end;

procedure TSyntaxMemoWithStuff2.SetFindSettingsRegistryKey(
	const Value: String);
begin
	FFindSettingsRegistryKey := Value;
	FPersist.FindSettingsRegistryKey := FFindSettingsRegistryKey;
end;

function TSyntaxMemoWithStuff2.GetSelStart: integer;
begin
	result:=CoorToIndex(BlockBegin);
end;

procedure TSyntaxMemoWithStuff2.SetSelStart(const Value: integer);
begin
	BlockBegin:=IndexToCoor(value);
end;

function TSyntaxMemoWithStuff2.GetSelLength: integer;
begin
	result:=CoorToIndex(BlockEnd)-CoorToIndex(BlockBegin);
end;

procedure TSyntaxMemoWithStuff2.SetSelLength(const Value: integer);
begin
	BlockEnd:=IndexToCoor(CoorToIndex(BlockBegin)+Value);
end;

procedure TSyntaxMemoWithStuff2.SetSelTextBuf(buf: PChar);
begin
	SelText:=buf;
end;

function TSyntaxMemoWithStuff2.TokenTextAtPos(pos : integer; var dummy: Integer): string;
var
	start,tt : integer;
begin
	dummy:=0;
	GetHighlighterTokenAtRowCol(IndexToCoor(pos),result,start,tt);
end;

procedure TSyntaxMemoWithStuff2.EnsureSelectedIsVisible;
begin
	if SelText = '' then
	begin
		EnsureCursorPosVisible;
	end
	else
	begin
		IncPaintLock;
		try
			// Make sure X is visible
			if BlockBegin.X < (LeftChar - 1) then
				LeftChar := BlockBegin.X
			else if BlockEnd.X >= (CharsInWindow + LeftChar) then
				LeftChar := BlockEnd.X - CharsInWindow + 2;

			// Make sure Y is Visible
			if BlockBegin.Y < (TopLine - 1) then
				TopLine := BlockBegin.Y + 1
			else if BlockEnd.Y > (TopLine + (LinesInWindow - 2)) then
				TopLine := BlockEnd.Y - (LinesInWindow - 2);
		finally
			DecPaintLock;
		end;
	end;
end;

procedure TSyntaxMemoWithStuff2.DisableBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		bp.Enabled:=FALSE;
end;

procedure TSyntaxMemoWithStuff2.EnableBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		bp.Enabled:=TRUE;
end;

procedure TSyntaxMemoWithStuff2.InvalidBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		bp.Valid:=FALSE;
end;

function TSyntaxMemoWithStuff2.IsABreakpoint(Row: integer): boolean;
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		result:=TRUE
	else
		result:=FALSE;
end;

procedure TSyntaxMemoWithStuff2.RemoveAllBreakpoints;
var
	i  : integer;
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	for i:=Marks.count-1 downto 0 do
		if Marks[i] is TSyntaxMemoWithStuff2Breakpoint then
			begin
				bp:=TSyntaxMemoWithStuff2Breakpoint(Marks[i]);
				Marks.Delete(i);
				bp.Free;
			end;
end;

procedure TSyntaxMemoWithStuff2.RemoveBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		begin
			Marks.Remove(bp);
			bp.free;
		end;
end;

procedure TSyntaxMemoWithStuff2.SetBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=TSyntaxMemoWithStuff2Breakpoint.Create(self);
	bp.Line:=Row;
	bp.Valid:=TRUE;
	bp.Enabled:=TRUE;
	bp.Visible:=TRUE;
	marks.Add(bp);
end;

procedure TSyntaxMemoWithStuff2.ToggleBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		begin
			Marks.Remove(bp);
			bp.free;
		end
	else
		SetBreakpoint(Row);
end;

procedure TSyntaxMemoWithStuff2.ValidBreakpoint(Row: integer);
var
	bp : TSyntaxMemoWithStuff2Breakpoint;

begin
	bp:=FindBreakpoint(Row);
	if bp<>nil then
		bp.Valid:=TRUE;
end;

function TSyntaxMemoWithStuff2.FindBreakpoint(Row: integer): TSyntaxMemoWithStuff2Breakpoint;
var
	i : integer;

begin
	result:=nil;

	for i:=0 to Marks.Count-1 do
		if (Marks[i].Line=row) and (Marks[i] is TSyntaxMemoWithStuff2Breakpoint) then
			begin
				result:=TSyntaxMemoWithStuff2Breakpoint(marks[i]);
				break;
			end;
end;

procedure TSyntaxMemoWithStuff2.CapitaliseKeyword;
var
	temp,line  : string;
	start,stop : integer;
	allow 		 : boolean;
	p 				 : TPoint;

begin
	if Highlighter=nil then
		raise Exception.Create('Highlighter must not be nil');

	p:=CaretXY;
	temp:=GetTokenAtRowCol(p,start,stop);

	p.X:=start;
	allow:=TRUE;
	if assigned(fChangeKeywordCase) then
		fChangeKeywordCase(self,p,temp,allow);

	if allow and (temp<>'') and Highlighter.isKeyword(temp) then
		begin
			temp:=AnsiUpperCase(temp);
			line:=lines[CaretXY.Y-1];
			lines[CaretXY.Y-1]:=copy(line,1,start-1)+temp+copy(line,stop,length(line));
		end;
end;

procedure TSyntaxMemoWithStuff2.DotLookupTimerEvent(Sender: TObject);
var i: integer;
	P: TPoint;
begin
	FDotLookupTimer.Enabled := False;
	CloseLookupList;
	if not Assigned(FOnDotLookup) then Exit;
	FDotLookupList.Clear;
	FDotLBX.Clear;
	FDotLookupBuffer := '';
	FOnDotLookup(Sender, FDotLookupList, FManualLookupInvoked);
	if (FDotLookupList.Count<=0) then Exit;
	for i:=0 to FDotLookupList.Count-1 do
		FDotLBX.Items.Add(FDotLookupList[i]);
	FDotLBX.ItemIndex := 0;
	if GetCaretPos(P) then
		begin
			P := Self.ClientToScreen(P);
			FListPos.X := P.X + ((Length(FDotLookupBuffer) - 1) * Canvas.TextWidth('W'));
			FListPos.Y := P.Y + Canvas.TextHeight('W');
		end;
	SetWindowPos(FDotLBX.Handle, HWND_TOP, FListPos.X, FListPos.Y, 0, 0,
		SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
	FDotLookupVisible := True;
	Windows.SetFocus(Handle);
	FDotLBX.ItemIndex := 0;
end;

procedure TSyntaxMemoWithStuff2.CloseLookupList;
begin
	CloseUpLists;
	if Assigned(FDotLBX) then
	begin
		SetWindowPos(FDotLBX.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
			SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
	end;
	FDotLookupVisible := False;
end;

function TSyntaxMemoWithStuff2.GetHighlighterTokenAtRowCol(XY: TPoint;
	var Token: string; var start, tokenType: integer): boolean;
var
	PosX, PosY: integer;
	Line: string;
begin
	PosY := XY.Y;
	if Assigned(Highlighter) and (PosY >= 1) and (PosY <= Lines.Count) then
	begin
		Line := Lines[PosY - 1];
		Highlighter.SetRange(Lines.Objects[PosY - 1]);
		Highlighter.SetLine(Line, PosY);
		PosX := XY.X;
		if (PosX > 0) and (PosX <= Length(Line)) then
			while not Highlighter.GetEol do begin
				Start := Highlighter.GetTokenPos + 1;
				Token := Highlighter.GetToken;
				if (PosX >= Start) and (PosX < Start + Length(Token)) then begin
					Result := TRUE;
					TokenType := Highlighter.GetTokenKind;
					exit;
				end;
				Highlighter.Next;
			end;
	end;
	Token := '';
	Start := 0;
	TokenType := -1;
	Result := FALSE;
end;

procedure TSyntaxMemoWithStuff2.WSFind;
var
	EdFindDlg : TEdFindDlg;
begin
	EdFindDlg := TEdFindDlg.Create(Self);
	try
		EdFindDlg.Caption := FFindDialogCaption;
		EdFindDlg.HelpContext := FFindDialogHelpContext;
		if FPersist.LastFindText <> '' then
			EdFindDlg.Execute(FPersist.LastFindText, FPersist.LastFindOpt, Self, FPersist)
		else
		begin
			EdFindDlg.Execute('', FPersist.LastFindOpt, Self, FPersist);
		end;
	finally
		EdFindDlg.Free;
	end;
end;

procedure TSyntaxMemoWithStuff2.WSFindNext;
var
	FoundAt : LongInt;

begin
	FoundAt := SearchReplace(FPersist.LastFindText, '', FPersist.LastFindOpt);
	if FoundAt = 0 then
		MessageDlg(format('Search string "%s" not found.', [FPersist.LastFindText]), mtInformation, [mbOK], 0);
end;

procedure TSyntaxMemoWithStuff2.WSReplace;
var
	EdReplDlg : TEdReplDlg;

begin
	EdReplDlg := TEdReplDlg.Create(Self);
	try
		EdReplDlg.Caption := FReplaceDialogCaption;
		EdReplDlg.HelpContext := FReplaceDialogHelpContext;
		EdReplDlg.Execute(FPersist.LastFindText, FPersist.LastFindOpt, Self, FPersist);
	finally
		EdReplDlg.Free;
	end;
end;

{ TEdPersistent }

constructor TEdPersistent.Create(AOwner : TComponent);
begin
	inherited Create(AOwner);
	FGetList := TStringList.Create;
end;

destructor TEdPersistent.Destroy;
begin
	FGetList.Free;
	inherited Destroy;
end;

function TEdPersistent.GetFindList : TStrings;
var
	R : TRegistry;

begin
	FGetList.Text := '';
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('FindHistList') then
				FGetList.Text := R.ReadString('FindHistList');

			R.CloseKey;
		end;
	finally
		R.Free;
	end;
	Result := FGetList;
end;

function TEdPersistent.GetReplList : TStrings;
var
	R : TRegistry;

begin
	FGetList.Text := '';
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('ReplaceHistList') then
				FGetList.Text := R.ReadString('ReplaceHistList');
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
	Result := FGetList;
end;

procedure TEdPersistent.SetFindList(const Value : TStrings);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteString('FindHistList', Value.Text);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

procedure TEdPersistent.SetFindOpt(const Value : TSynSearchOptions);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteBool('MatchCase', ssoMatchCase in Value);
			R.WriteBool('WholeWord', ssoWholeWord in Value);
			R.WriteBool('BackDirection', ssoBackwards in Value);
			R.WriteBool('Prompt', ssoPrompt in Value);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function TEdPersistent.GetFindOpt: TSynSearchOptions;
var
	R : TRegistry;

begin
	Result := [];
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('MatchCase') then
				if R.ReadBool('MatchCase') then Result := Result + [ssoMatchCase];
			if R.ValueExists('WholeWord') then
				if R.ReadBool('WholeWord') then Result := Result + [ssoWholeWord];
			if R.ValueExists('BackDirection') then
				if R.ReadBool('BackDirection') then Result := Result + [ssoBackwards];
			if R.ValueExists('Prompt') then
				if R.ReadBool('Prompt') then Result := Result + [ssoPrompt];
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;


procedure TEdPersistent.SetFindText(const Value : string);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteString('LastFindText', Value);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function TEdPersistent.GetFindText: string;
var
	R : TRegistry;

begin
	Result := '';
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('LastFindText') then
				Result := R.ReadString('LastFindText');
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;		


procedure TEdPersistent.SetLastPromptOnReplace(const Value : boolean);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteBool('LastPromptOnReplace', Value);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function TEdPersistent.GetLastPromptOnReplace: boolean;
var
	R : TRegistry;

begin
	Result := False;
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('LastPromptOnReplace') then
				Result := R.ReadBool('LastPromptOnReplace');
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;


procedure TEdPersistent.SetReplaceText(const Value : string);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteString('LastReplaceText', Value);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function TEdPersistent.GetReplaceText: string;
var
	R : TRegistry;

begin
	Result := '';
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			if R.ValueExists('LastReplaceText') then
				Result := R.ReadString('LastReplaceText');
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;


procedure TEdPersistent.SetReplList(const Value : TStrings);
var
	R : TRegistry;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(FindSettingsRegistryKey, True) then
		begin
			R.WriteString('ReplaceHistList', Value.Text);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function TSyntaxMemoWithStuff2.GetNavigatorHyperLinkStyle: TStringList;
begin
	Result := FNavigatorHyperLinkStyle;
end;

procedure TSyntaxMemoWithStuff2.SetNavigatorHyperLinkStyle(const Value: TStringList);
begin
	FNavigatorHyperLinkStyle.Assign(Value);
end;

function TSyntaxMemoWithStuff2.CoorToIndex(CPos: TPoint): integer;
begin
	result := CharsInWindow * CPos.Y + CPos.X;
end;

function TSyntaxMemoWithStuff2.IndexToCoor(ind: integer): TPoint;
begin
	result.y := ind div CharsInWindow;
	result.x := ind - result.y * CharsInWindow;
end;

function TSyntaxMemoWithStuff2.GetTokenAtRowCol(XY: TPoint; var start,stop : integer): string;
var
	Line		: string;
	IdChars : TSynIdentChars;
	Len 		: integer;

begin
	Result := '';
	if (XY.Y >= 1) and (XY.Y <= Lines.Count) then begin
		Line := Lines[XY.Y - 1];
		Len := Length(Line);
		if (XY.X >= 1) and (XY.X <= Len + 1) then begin
			if Assigned(Highlighter) then
				IdChars := Highlighter.IdentChars
			else
				IdChars := ['a'..'z', 'A'..'Z'];
			Stop := XY.X;
			while (Stop <= Len) and (Line[Stop] in IdChars) do
				Inc(Stop);
			while (XY.X > 1) and (Line[XY.X - 1] in IdChars) do
				Dec(XY.X);
			if Stop > XY.X then
				Result := Copy(Line, XY.X, Stop - XY.X);
		end;
	end;

	start:=XY.X;
end;

{ TSyntaxMemoWithStuff2Breakpoint }

constructor TSyntaxMemoWithStuff2Breakpoint.Create(AOwner: TCustomSynEdit);
begin
	inherited Create(AOwner);
	fEnabled := TRUE;
	fValid := TRUE;
	UpdateImage;
end;

procedure TSyntaxMemoWithStuff2Breakpoint.SetEnabled(const Value: boolean);
begin
	fEnabled := Value;
	UpdateImage;
end;

procedure TSyntaxMemoWithStuff2Breakpoint.SetValid(const Value: boolean);
begin
	fValid := Value;
	UpdateImage;
end;

procedure TSyntaxMemoWithStuff2Breakpoint.UpdateImage;
begin
	if fValid then
		if fEnabled then
			ImageIndex:=10 + ord(ilEnabled)
		else
			ImageIndex:=10 + ord(ilDisabled)
	else
		ImageIndex:=10 + ord(ilInvalid);

end;

end.



