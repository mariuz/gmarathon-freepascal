unit NewColorGrd;

{$R-}

interface

uses Windows, Messages, Classes, Graphics, Forms, Controls, ExtCtrls;

const
  NumPaletteEntries = 20;

type
  TGridOrdering = (go16x1, go8x2, go4x4, go2x8, go1x16);

  TMarathonColorGrid = class(TCustomControl)
  private
    FPaletteEntries: array[0..NumPaletteEntries - 1] of TPaletteEntry;
    FClickEnablesColor: Boolean;
    FForegroundIndex: Integer;
    FBackgroundIndex: Integer;
    FForegroundEnabled: Boolean;
    FBackgroundEnabled: Boolean;
    FSelection: Integer;
    FCellXSize, FCellYSize: Integer;
    FNumXSquares, FNumYSquares: Integer;
    FGridOrdering: TGridOrdering;
    FHasFocus: Boolean;
    FOnChange: TNotifyEvent;
    FButton: TMouseButton;
    FButtonDown: Boolean;
    procedure DrawSquare(Which: Integer; ShowSelector: Boolean);
    procedure DrawFgBg;
    procedure UpdateCellSizes(DoRepaint: Boolean);
    procedure SetGridOrdering(Value: TGridOrdering);
    function GetForegroundColor: TColor;
    procedure SetForeGroundColor(cl : TColor);
    function GetBackgroundColor: TColor;
    procedure SetBackGroundColor(cl: TColor);
    procedure SetForegroundIndex(Value: Integer);
    procedure SetBackgroundIndex(Value: Integer);
    procedure SetSelection(Value: Integer);
    procedure EnableForeground(Value: Boolean);
    procedure EnableBackground(Value: Boolean);
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Change; dynamic;
    function SquareFromPos(X, Y: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    property ForegroundColor: TColor read GetForegroundColor write SetForeGroundColor;
    property BackgroundColor: TColor read GetBackgroundColor write SetBackGroundColor;
  published
    property ClickEnablesColor: Boolean read FClickEnablesColor write FClickEnablesColor default False;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property GridOrdering: TGridOrdering read FGridOrdering write SetGridOrdering default go4x4;
    property ForegroundIndex: Integer read FForegroundIndex write SetForegroundIndex default 0;
    property BackgroundIndex: Integer read FBackgroundIndex write SetBackgroundIndex default 0;
    property ForegroundEnabled: Boolean read FForegroundEnabled write EnableForeground default True;
    property BackgroundEnabled: Boolean read FBackgroundEnabled write EnableBackground default True;
    property Font;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopUpMenu;
    property Selection: Integer read FSelection write SetSelection default 0;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

uses SysUtils, Consts, StdCtrls;

constructor TMarathonColorGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FGridOrdering := go4x4;
  FNumXSquares := 4;
  FNumYSquares := 4;
  FForegroundEnabled := True;
  FBackgroundEnabled := True;
  Color := clBtnFace;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Color := clBlack;
  SetBounds(0, 0, 100, 100);
  GetPaletteEntries(GetStockObject(DEFAULT_PALETTE), 0, NumPaletteEntries,
    FPaletteEntries);
end;

procedure TMarathonColorGrid.CreateWnd;
begin
  inherited CreateWnd;
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE)
    or WS_CLIPSIBLINGS);
end;

procedure TMarathonColorGrid.DrawSquare(Which: Integer; ShowSelector: Boolean);
var
  WinTop, WinLeft: Integer;
  PalIndex: Integer;
  CellRect: TRect;
begin
  if (Which >=0) and (Which <= 15) then
  begin
    if Which < 8 then
      PalIndex := Which else PalIndex := Which + 4;
    WinTop := (Which div FNumXSquares) * FCellYSize;
    WinLeft := (Which mod FNumXSquares) * FCellXSize;
    CellRect := Bounds(WinLeft, WinTop, FCellXSize, FCellYSize);
    if Ctl3D then
    begin
      Canvas.Pen.Color := clBtnFace;
      with CellRect do Canvas.Rectangle(Left, Top, Right, Bottom);
      InflateRect(CellRect, -1, -1);
      Frame3D(Canvas, CellRect, clBtnShadow, clBtnHighlight, 2);
    end else Canvas.Pen.Color := clBlack;
    with FPaletteEntries[PalIndex] do
    begin
      Canvas.Brush.Color := TColor(RGB(peRed, peGreen, peBlue));
      if Ctl3D then Canvas.Pen.Color := TColor(RGB(peRed, peGreen, peBlue));
    end;
    if not ShowSelector then with CellRect do
      Canvas.Rectangle(Left, Top, Right, Bottom)
    else with CellRect do
    begin
      if Ctl3D then
      begin
        Canvas.Rectangle(Left, Top, Right, Bottom);
        InflateRect(CellRect, -1, -1);
        DrawFocusRect(Canvas.Handle, CellRect);
      end else with Canvas do
      begin
        Pen.Color := clBlack;
        Pen.Mode := pmNot;
        Rectangle(Left, Top, Right, Bottom);
        Pen.Mode := pmCopy;
        Rectangle(Left + 2, Top + 2, Right - 2, Bottom - 2);
      end;
    end;
  end;
end;

procedure TMarathonColorGrid.DrawFgBg;
var
  TextColor: TPaletteEntry;
  PalIndex: Integer;
  TheText: string;
  OldBkMode: Integer;
  R: TRect;

  function TernaryOp(Test: Boolean; ResultTrue, ResultFalse: Integer): Integer;
  begin
    if Test then
      Result := ResultTrue
    else Result := ResultFalse;
  end;

begin
  OldBkMode := SetBkMode(Canvas.Handle, TRANSPARENT);
  if FForegroundEnabled then
  begin
    if (FForegroundIndex = FBackgroundIndex) and FBackgroundEnabled then
      TheText := 'FB' else TheText := 'FG';
    if FForegroundIndex < 8 then
      PalIndex := FForegroundIndex else PalIndex := FForegroundIndex + 4;
    TextColor := FPaletteEntries[PalIndex];
    with TextColor do
    begin
      peRed := TernaryOp(peRed >= $80, 0, $FF);
      peGreen := TernaryOp(peGreen >= $80, 0, $FF);
      peBlue := TernaryOp(peBlue >= $80, 0, $FF);
      Canvas.Font.Color := TColor(RGB(peRed, peGreen, peBlue));
    end;
    with R do
    begin
      left := (FForegroundIndex mod FNumXSquares) * FCellXSize;
      right := left + FCellXSize;
      top := (FForegroundIndex div FNumXSquares) * FCellYSize;
      bottom := top + FCellYSize;
    end;
    DrawText(Canvas.Handle, PChar(TheText), -1, R,
       DT_NOCLIP or DT_SINGLELINE or DT_CENTER or DT_VCENTER);
  end;
  if FBackgroundEnabled then
  begin
    if (FForegroundIndex = FBackgroundIndex) and FForegroundEnabled then
      TheText := 'FB' else TheText := 'BG';
    if FBackgroundIndex < 8 then
      PalIndex := FBackgroundIndex else PalIndex := FBackgroundIndex + 4;
    TextColor := FPaletteEntries[PalIndex];
    with TextColor do
    begin
      peRed := TernaryOp(peRed >= $80, 0, $FF);
      peGreen := TernaryOp(peGreen >= $80, 0, $FF);
      peBlue := TernaryOp(peBlue >= $80, 0, $FF);
      Canvas.Font.Color := TColor(RGB(peRed, peGreen, peBlue));
    end;
    with R do
    begin
      left := (FBackgroundIndex mod FNumXSquares) * FCellXSize;
      right := left + FCellXSize;
      top := (FBackgroundIndex div FNumXSquares) * FCellYSize;
      bottom := top + FCellYSize;
    end;
    DrawText(Canvas.Handle, PChar(TheText), -1, R,
      DT_NOCLIP or DT_SINGLELINE or DT_CENTER or DT_VCENTER);
  end;
  SetBkMode(Canvas.Handle, OldBkMode);
end;

procedure TMarathonColorGrid.EnableForeground(Value: Boolean);
begin
  if FForegroundEnabled = Value then Exit;
  FForegroundEnabled := Value;
  DrawSquare(FForegroundIndex, (FForegroundIndex = FSelection) and FHasFocus);
  DrawFgBg;
end;

procedure TMarathonColorGrid.EnableBackground(Value: Boolean);
begin
  if FBackgroundEnabled = Value then Exit;
  FBackgroundEnabled := Value;
  DrawSquare(FBackgroundIndex, (FBackgroundIndex = FSelection) and FHasFocus);
  DrawFgBg;
end;

function TMarathonColorGrid.GetForegroundColor: TColor;
var
  PalIndex: Integer;
begin
  if FForegroundIndex < 8 then
    PalIndex := FForegroundIndex else PalIndex := FForegroundIndex + 4;
  with FPaletteEntries[PalIndex] do
    Result := TColor(RGB(peRed, peGreen, peBlue));
end;

procedure TMarathonColorGrid.SetForegroundColor(cl: TColor);
var
  PalIndex: Integer;
  Result : TColor;
  x : Integer;

begin
  for x := 0 to 19 do
  begin
    if x < 8 then
      PalIndex := x else PalIndex := x + 4;
    with FPaletteEntries[PalIndex] do
      Result := TColor(RGB(peRed, peGreen, peBlue));
    if cl = Result then
    begin
      FForeGroundIndex := x;
      Break;
    end;
  end;
  Invalidate;
end;

function TMarathonColorGrid.GetBackgroundColor: TColor;
var
  PalIndex: Integer;

begin
  if FBackgroundIndex < 8 then
    PalIndex := FBackgroundIndex else PalIndex := FBackgroundIndex + 4;
  with FPaletteEntries[PalIndex] do
    Result := TColor(RGB(peRed, peGreen, peBlue));
end;

procedure TMarathonColorGrid.SetBackGroundColor(cl: TColor);
var
  PalIndex: Integer;
  Result : TColor;
  x : Integer;

begin
  for x := 0 to 19 do
  begin
    if x < 8 then
      PalIndex := x else PalIndex := x + 4;
    with FPaletteEntries[PalIndex] do
      Result := TColor(RGB(peRed, peGreen, peBlue));
    if cl = Result then
    begin
      FBackGroundIndex := x;
      Break;
    end;
  end;
  Invalidate;
end;

procedure TMarathonColorGrid.WMSetFocus(var Message: TWMSetFocus);
begin
  FHasFocus := True;
  DrawSquare(FSelection, True);
  DrawFgBg;
  inherited;
end;

procedure TMarathonColorGrid.WMKillFocus(var Message: TWMKillFocus);
begin
  FHasFocus := False;
  DrawSquare(FSelection, False);
  DrawFgBg;
  inherited;
end;

procedure TMarathonColorGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  NewSelection: Integer;
  Range: Integer;
begin
  inherited KeyDown(Key, Shift);
  NewSelection := FSelection;
  Range := FNumXSquares * FNumYSquares;
  case Key of
    $46, $66:
      begin
        if not FForegroundEnabled and FClickEnablesColor then
        begin
          FForegroundEnabled := True;
          DrawSquare(FForegroundIndex, (FForegroundIndex = FSelection) and FHasFocus);
          FForegroundIndex := -1;
        end;
        SetForegroundIndex(NewSelection);
        SetSelection(NewSelection);
        Click;
      end;
    $42, $62:
      begin
        if not FBackgroundEnabled and FClickEnablesColor then
        begin
          FBackgroundEnabled := True;
          DrawSquare(FBackgroundIndex, (FBackgroundIndex = FSelection) and FHasFocus);
          FBackgroundIndex := -1;
        end;
        SetBackgroundIndex(NewSelection);
        SetSelection(NewSelection);
        Click;
      end;
    VK_HOME: NewSelection := 0;
    VK_UP:
      if FSelection >= FNumXSquares then
        NewSelection := FSelection - FNumXSquares
      else if FSelection <> 0 then
        NewSelection := Range - FNumXSquares + FSelection - 1
      else NewSelection := Range - 1;
    VK_LEFT:
      if FSelection <> 0 then
        NewSelection := FSelection - 1
      else NewSelection := Range - 1;
    VK_DOWN:
      if FSelection + FNumXSquares < Range then
        NewSelection := FSelection + FNumXSquares
      else if FSelection <> Range - 1 then
        NewSelection := FSelection mod FNumXSquares + 1
      else NewSelection := 0;
    VK_SPACE,
    VK_RIGHT:
      if FSelection <> Range - 1 then
        NewSelection := FSelection + 1
      else NewSelection := 0;
    VK_END: NewSelection := Range - 1;
  else
    inherited KeyDown(Key, Shift);
    Exit;
  end;
  Key := 0;
  if FSelection <> NewSelection then
    SetSelection(NewSelection);
end;

procedure TMarathonColorGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS;
end;

procedure TMarathonColorGrid.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateCellSizes(False);
end;

procedure TMarathonColorGrid.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TMarathonColorGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Square: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  FButton := Button;
  FButtonDown := True;
  Square := SquareFromPos(X, Y);
  if Button = mbLeft then
  begin
    if not FForegroundEnabled and FClickEnablesColor then
    begin
      FForegroundEnabled := True;
      DrawSquare(FForegroundIndex, (FForegroundIndex = FSelection) and FHasFocus);
      FForegroundIndex := -1;
    end;
    SetForegroundIndex(Square);
  end
  else begin
    MouseCapture := True;
    if not FBackgroundEnabled and FClickEnablesColor then
    begin
      FBackgroundEnabled := True;
      DrawSquare(FBackgroundIndex, (FBackgroundIndex = FSelection) and FHasFocus);
      FBackgroundIndex := -1;
    end;
    SetBackgroundIndex(Square);
  end;
  SetSelection(Square);
  if TabStop then SetFocus;
end;

procedure TMarathonColorGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Square: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FButtonDown then
  begin
    Square := SquareFromPos(X, Y);
    if FButton = mbLeft then
      SetForegroundIndex(Square)
    else SetBackgroundIndex(Square);
    SetSelection(Square);
  end;
end;

procedure TMarathonColorGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FButtonDown := False;
  if FButton = mbRight then MouseCapture := False;
end;

procedure TMarathonColorGrid.Paint;
var
  Row, Col, wEntryIndex: Integer;
begin
  Canvas.Font := Font;
  for Row := 0 to FNumYSquares do
    for Col := 0 to FNumXSquares do
    begin
      wEntryIndex := Row * FNumXSquares + Col;
      DrawSquare(wEntryIndex, False);
    end;
  DrawSquare(FSelection, FHasFocus);
  DrawFgBg;
end;

procedure TMarathonColorGrid.SetBackgroundIndex(Value: Integer);
begin
  if (FBackgroundIndex <> Value) and FBackgroundEnabled then
  begin
    DrawSquare(FBackgroundIndex, (FBackgroundIndex = FSelection) and FHasFocus);
    FBackgroundIndex := Value;
    if FBackgroundIndex = FForegroundIndex then
      DrawSquare(FBackgroundIndex, (FBackgroundIndex = FSelection) and FHasFocus);
    DrawFgBg;
    Change;
  end;
end;

procedure TMarathonColorGrid.SetForegroundIndex(Value: Integer);
begin
  if (FForegroundIndex <> Value) and FForegroundEnabled then
  begin
    DrawSquare(FForegroundIndex, (FForegroundIndex = FSelection) and FHasFocus);
    FForegroundIndex := Value;
    if FForegroundIndex = FBackgroundIndex then
      DrawSquare(FForegroundIndex, (FForegroundIndex = FSelection) and FHasFocus);
    DrawFgBg;
    Change;
  end;
end;

procedure TMarathonColorGrid.SetGridOrdering(Value: TGridOrdering);
begin
  if FGridOrdering = Value then Exit;
  FGridOrdering := Value;
  FNumXSquares := 16 shr Ord(FGridOrdering);
  FNumYSquares := 1 shl Ord(FGridOrdering);
  UpdateCellSizes(True);
end;

procedure TMarathonColorGrid.SetSelection(Value: Integer);
begin
  if FSelection = Value then Exit;
  DrawSquare(FSelection, False);
  FSelection := Value;
  DrawSquare(FSelection, FHasFocus);
  DrawFgBg;
end;

function TMarathonColorGrid.SquareFromPos(X, Y: Integer): Integer;
begin
  if X > Width - 1 then X := Width - 1
  else if X < 0 then X := 0;
  if Y > Height - 1 then Y := Height - 1
  else if Y < 0 then Y := 0;
  Result := (Y div FCellYSize) * FNumXSquares + (X div FCellXSize);
end;

procedure TMarathonColorGrid.UpdateCellSizes(DoRepaint: Boolean);
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := (Width div FNumXSquares) * FNumXSquares;
  NewHeight := (Height div FNumYSquares) * FNumYSquares;
  BoundsRect := Bounds(Left, Top, NewWidth, NewHeight);
  FCellXSize := Width div FNumXSquares;
  FCellYSize := Height div FNumYSquares;
  if DoRepaint then Invalidate;
end;

procedure TMarathonColorGrid.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure Register;
begin
  RegisterComponents('Additional', [TMarathonColorGrid]);
end;

end.


