unit SyntaxMemoWithStuff2;

interface

{$I CompilerDefines.inc}

uses
  {$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Types,
  {$ELSE}
  Windows, Messages,
  {$ENDIF}
  SynEdit, Classes, dialogs, Graphics, SysUtils, Controls, ImgList, ExtCtrls, StdCtrls, Forms, SynEditTypes, SynEditMarks, SynEditMiscClasses,
  SynEditDecorator;

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
		procedure KeyPress(var Key: Char); override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
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
    FOnDotLookup: TDotLookupEvent;
    FWordList: TWordList;
    FSQLInsightList: TSQLInsightList;
    FListDelay: Integer;
    FFindSettingsRegistryKey: String;
    FFindDialogCaption: String;
    FReplaceDialogCaption: String;
    FReplaceDialogHelpContext: Integer;
    FFindDialogHelpContext: Integer;

    function GetSelStart: integer;
    procedure SetSelStart(const Value: integer);
    function GetSelLength: integer;
    procedure SetSelLength(const Value: integer);
	protected
		procedure WMKillFocus(var Message : TLMessage); message WM_KILLFOCUS;
		procedure WMWindowPosChanging(var Message : TLMessage); message WM_WINDOWPOSCHANGING;
		procedure CMMouseLeave(var Message : TLMessage); message CM_MOUSELEAVE;
    procedure KeyPress(var Key: Char); override;
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure SetExecutionHighlighting(const ExecutelineBegin: integer;
			const ExecuteLineEnd: integer);
    procedure ClearExecutionHighlighting;
    function DoOnSpecialLineColors(Line: integer; var Foreground, Background: TColor): boolean;

		property SelStart: integer read GetSelStart write SetSelStart;
		property SelLength: integer read GetSelLength write SetSelLength;
	published
		property ErrorLine: integer read FErrorLine write FErrorLine;
		property ErrorForeColor: TColor read FErrorForeColor write FErrorForeColor;
		property ErrorBackColor: TColor read FErrorBackColor write FErrorBackColor;
		property ExecutionForeColor: TColor read FExecutionForeColor write FExecutionForeColor;
		property ExecutionBackColor: TColor read FExecutionBackColor write FExecutionBackColor;
    property UseNavigateHyperLinks: boolean read FUseNavigateHyperLinks write FUseNavigateHyperLinks;
    property GetHyperlinkToken: TGetHyperlinkTokenEvent read FGetHyperlinkToken write FGetHyperlinkToken;
    property OnHyperlinkClick: TOnHyperlinkClickEvent read FOnHyperLinkClick write FOnHyperLinkClick;
    property OnDotLookup: TDotLookupEvent read FOnDotLookup write FOnDotLookup;
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

uses
  FindDlg, ReplDlg;

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
constructor TSyntaxMemoWithStuff2.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
  FExecutelineBegin := -1;
  FExecuteLineEnd := -1;
  FWordList := TWordList.Create;
  FSQLInsightList := TSQLInsightList.Create;
end;

destructor TSyntaxMemoWithStuff2.Destroy;
begin
  FWordList.Free;
  FSQLInsightList.Free;
	inherited Destroy;
end;

function TSyntaxMemoWithStuff2.GetSelLength: integer;
begin
  Result := SelLength;
end;

procedure TSyntaxMemoWithStuff2.SetSelLength(const Value: integer);
begin
  SelLength := Value;
end;

function TSyntaxMemoWithStuff2.GetSelStart: integer;
begin
  Result := SelStart;
end;

procedure TSyntaxMemoWithStuff2.SetSelStart(const Value: integer);
begin
  SelStart := Value;
end;

procedure TSyntaxMemoWithStuff2.SetExecutionHighlighting(const ExecutelineBegin: integer;
	const ExecuteLineEnd: integer);
begin
	FExecutelineBegin := ExecutelineBegin;
	FExecuteLineEnd := ExecuteLineEnd;
	Invalidate;
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

end.
