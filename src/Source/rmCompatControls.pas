unit rmCompatControls;

{$MODE Delphi}

interface

uses
  Classes, SysUtils, Controls, ComCtrls, StdCtrls, Graphics, EditBtn;

type
  { TrmNoteBookControl - replacement for rmControls TrmNoteBookControl }
  TrmNoteBookControl = class(TPageControl)
  end;

  { TrmNotebookPage - replacement for rmControls TrmNotebookPage }
  TrmNotebookPage = class(TTabSheet)
  private
    FData: Integer;
  published
    property Data: Integer read FData write FData default 0;
  end;

  { TrmTabSet - replacement for rmControls TrmTabSet (tab set control) }
  TrmTabSet = class(TTabControl)
  end;

  { TrmBtnEdit - replacement for rmControls TrmBtnEdit (edit with browse button) }
  TrmBtnEdit = class(TEditButton)
  private
    FOnBtn1Click: TNotifyEvent;
    FBtn2Glyph: TBitmap;
    FBtn1NumGlyphs: Integer;
    FBtn2NumGlyphs: Integer;
    procedure SetBtn1Glyph(Value: TBitmap);
    function GetBtn1Glyph: TBitmap;
    procedure SetBtn2Glyph(Value: TBitmap);
    function GetBtn2Glyph: TBitmap;
  protected
    procedure ButtonClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Btn1Glyph: TBitmap read GetBtn1Glyph write SetBtn1Glyph;
    property Btn1NumGlyphs: Integer read FBtn1NumGlyphs write FBtn1NumGlyphs default 1;
    property Btn2Glyph: TBitmap read GetBtn2Glyph write SetBtn2Glyph;
    property Btn2NumGlyphs: Integer read FBtn2NumGlyphs write FBtn2NumGlyphs default 1;
    property OnBtn1Click: TNotifyEvent read FOnBtn1Click write FOnBtn1Click;
  end;

procedure Register;

implementation

{ TrmBtnEdit }

constructor TrmBtnEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBtn2Glyph := TBitmap.Create;
  FBtn1NumGlyphs := 1;
  FBtn2NumGlyphs := 1;
end;

destructor TrmBtnEdit.Destroy;
begin
  FBtn2Glyph.Free;
  inherited;
end;

procedure TrmBtnEdit.SetBtn1Glyph(Value: TBitmap);
begin
  Glyph.Assign(Value);
end;

function TrmBtnEdit.GetBtn1Glyph: TBitmap;
begin
  Result := Glyph;
end;

function TrmBtnEdit.GetBtn2Glyph: TBitmap;
begin
  Result := FBtn2Glyph;
end;

procedure TrmBtnEdit.SetBtn2Glyph(Value: TBitmap);
begin
  FBtn2Glyph.Assign(Value);
end;

procedure TrmBtnEdit.ButtonClick;
begin
  inherited;
  if Assigned(FOnBtn1Click) then
    FOnBtn1Click(Self);
end;

procedure Register;
begin
  RegisterComponents('Marathon', [TrmNoteBookControl, TrmNotebookPage, TrmTabSet, TrmBtnEdit]);
end;

end.
