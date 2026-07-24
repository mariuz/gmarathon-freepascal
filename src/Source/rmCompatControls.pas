unit rmCompatControls;

{$MODE Delphi}

interface

uses
  Classes, SysUtils, Controls, ComCtrls, StdCtrls, Graphics, EditBtn, ImgList;

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

  { TrmCollectionListBoxTextData - replacement for rmControls' item TextData holder }
  TrmCollectionListBoxTextData = class(TPersistent)
  private
    FText: String;
  published
    property Text: String read FText write FText;
  end;

  { TrmCollectionListBoxItem - replacement for rmControls' item within a collection list box }
  TrmCollectionListBoxItem = class(TCollectionItem)
  private
    FImageIndex: Integer;
    FTextData: TrmCollectionListBoxTextData;
    FData: TObject;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    property Data: TObject read FData write FData;
  published
    property ImageIndex: Integer read FImageIndex write FImageIndex default -1;
    property TextData: TrmCollectionListBoxTextData read FTextData;
  end;

  { TrmCollectionListBoxCollection - replacement for rmControls' collection list box collection }
  TrmCollectionListBoxCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TrmCollectionListBoxItem;
  public
    constructor Create;
    property Items[Index: Integer]: TrmCollectionListBoxItem read GetItem; default;
  end;

  { TrmCollectionListBox - replacement for rmControls TrmCollectionListBox (icon + text listbox) }
  TrmCollectionListBox = class(TCustomListBox)
  private
    FCollection: TrmCollectionListBoxCollection;
    FImages: TCustomImageList;
    FAutoSelect: Boolean;
  protected
    procedure DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Add(const AText: String; AImageIndex: Integer; AData: TObject): Integer;
    procedure Clear;
    property Collection: TrmCollectionListBoxCollection read FCollection write FCollection;
  published
    property Align;
    property AutoSelect: Boolean read FAutoSelect write FAutoSelect default True;
    property Anchors;
    property Color;
    property Constraints;
    property Font;
    property Images: TCustomImageList read FImages write FImages;
    property ItemHeight;
    property ItemIndex;
    property ParentFont;
    property PopupMenu;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnKeyDown;
  end;

procedure Register;

implementation

{ TrmCollectionListBoxItem }

constructor TrmCollectionListBoxItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FImageIndex := -1;
  FTextData := TrmCollectionListBoxTextData.Create;
end;

destructor TrmCollectionListBoxItem.Destroy;
begin
  FTextData.Free;
  inherited Destroy;
end;

{ TrmCollectionListBoxCollection }

constructor TrmCollectionListBoxCollection.Create;
begin
  inherited Create(TrmCollectionListBoxItem);
end;

function TrmCollectionListBoxCollection.GetItem(Index: Integer): TrmCollectionListBoxItem;
begin
  Result := TrmCollectionListBoxItem(inherited Items[Index]);
end;

{ TrmCollectionListBox }

constructor TrmCollectionListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCollection := TrmCollectionListBoxCollection.Create;
  FAutoSelect := True;
  Style := lbOwnerDrawFixed;
end;

destructor TrmCollectionListBox.Destroy;
begin
  FCollection.Free;
  inherited Destroy;
end;

function TrmCollectionListBox.Add(const AText: String; AImageIndex: Integer; AData: TObject): Integer;
var
  Item: TrmCollectionListBoxItem;
begin
  Item := TrmCollectionListBoxItem(FCollection.Add);
  Item.ImageIndex := AImageIndex;
  Item.TextData.Text := AText;
  Item.Data := AData;
  Result := Items.Add(AText);
end;

procedure TrmCollectionListBox.Clear;
begin
  Items.Clear;
  FCollection.Clear;
end;

procedure TrmCollectionListBox.DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  TextLeft: Integer;
  ImgIdx: Integer;
begin
  Canvas.FillRect(ARect);
  TextLeft := ARect.Left + 2;
  if Assigned(FImages) and (Index < FCollection.Count) then
  begin
    ImgIdx := FCollection[Index].ImageIndex;
    if ImgIdx >= 0 then
    begin
      FImages.Draw(Canvas, ARect.Left + 2, ARect.Top, ImgIdx);
      TextLeft := ARect.Left + FImages.Width + 6;
    end;
  end;
  Canvas.TextOut(TextLeft, ARect.Top, Items[Index]);
end;

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
  RegisterComponents('Marathon', [TrmNoteBookControl, TrmNotebookPage, TrmTabSet, TrmBtnEdit, TrmCollectionListBox]);
end;

end.
