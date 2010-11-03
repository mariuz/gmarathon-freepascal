unit DiagramTree;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ImgList, CommCtrl, InterBaseExplainPlan;

type
  TLayout = (loVertical, loHorizontal);
  TConnector = (ctSimple, ctOrthogonal);

  TDiagramNode = class(TObject)
  private
    FBitmap : TBitmap;
    FChildren : TList;
    FColor : TColor;
    FImageIndex : Integer;
    FNodeID : string;
    FCaption : string;
    FData : TObject;
    FOwner : TComponent;
    FParentNode : TDiagramNode;
    FPosition : TRect;
    function GetLeft : integer;
    function GetTop : integer;
  public
    constructor Create(AOwner : TComponent; AParentNode : TDiagramNode);
    destructor Destroy; override;

    procedure SetVPosition(var start_x : Integer; start_y : Integer);
    procedure SetHPosition(start_x : Integer; var start_y : Integer);
    procedure DrawNode(cvs : TCanvas; selected_node : TDiagramNode);
    procedure DrawSubtree(cvs : TCanvas; selected_node : TDiagramNode);
    function NodeAtPoint(X, Y : Integer) : TDiagramNode;
    function RemoveNode(target_node : TDiagramNode) : Boolean;
    function FindNodeValue(target_value : string) : TDiagramNode;

    property Caption : string read FCaption write FCaption;
    property Children : TList read FChildren;
    property Color : TColor read FColor write FColor;
    property Data : TObject read FData write FData;
    property ImageIndex : Integer read FImageIndex write FImageIndex;
    property Left : integer read GetLeft;
    property NodeID : string read FNodeID write FNodeID;
    property ParentNode : TDiagramNode read FParentNode;
    property Top : integer read GetTop;
  end;

  TDiagramHintWindow = class(THintWindow)
  private
    FNode : TDiagramNode;
    FData : TObject;
    procedure PaintItem(var Rect : TRect; sName, sValue : string; Flags : longint);  
    procedure PaintText(var R : TRect; sName, sText : string; Flags : longint);
    procedure PaintPlanObject(var R : TRect; PlanItem : TInterbasePlanObject; Flags : longint);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ActivateHintData(Rect: TRect; const AHint: string; AData: Pointer); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string;
      AData: Pointer): TRect; override;
    procedure HideHint;
    property BiDiMode;
    property Caption;
    property Color;
    property Canvas;
    property Font;
    property Node : TDiagramNode read FNode write FNode;
  end;

  TDiagramTreeCanvas = class(TGraphicControl)
  private
    FHintWindow : TDiagramHintWindow;
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
    procedure MouseMove(Shift : TShiftState; X, Y : Integer); override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    property OnMouseUp;
    property Canvas;
  end;

  TDiagramTree = class(TScrollBox)
  private
    FShowBitmap : Boolean;
    FCentred : Boolean;
    FBoxHeight : Integer;
    FBoxHGap : Integer;
    FBoxWidth : Integer;
    FBoxVGap : Integer;
    FConnector : TConnector;
    FLayout : TLayout;
    FImageChangeLink : TChangeLink;
    FImages : TCustomImageList;
    FOnSelectedChange: TNotifyEvent;
    procedure ImageListChange(Sender : TObject);
    procedure SetImages(Value : TCustomImageList);
  protected
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
    procedure MouseMove(Shift : TShiftState; X, Y : Integer); override;
  public
    Root : TDiagramNode;
    DVCanvas : TDiagramTreeCanvas;
    SelectedNode : TDiagramNode;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function AddNode(id : string; ParentNode : TDiagramNode) : TDiagramNode;
    procedure SelectNode(new_selected : TDiagramNode);
    procedure Redraw;
    procedure Clear;
    procedure PaintToCanvas(Canvas : TCanvas);
  published
    property OnSelectedChange : TNotifyEvent read FOnSelectedChange write FOnSelectedChange;
    property BoxWidth : Integer read FBoxWidth write FBoxWidth default 100;
    property BoxHeight : Integer read FBoxHeight write FBoxHeight default 18;
    property BoxHGap : Integer read FBoxHGap write FBoxHGap default 10;
    property BoxVGap : Integer read FBoxVGap write FBoxVGap default 10;
    property Layout : TLayout read FLayout write FLayout default loVertical;
    property Connector : TConnector read FConnector write FConnector default ctSimple;
    property Centred : Boolean read FCentred write FCentred default True;
    property ShowBitmap : Boolean read FShowBitmap write FShowBitmap default True;
    property Images : TCustomImageList read FImages write SetImages;
    property OnClick;
  end;

procedure Register;

implementation

var
  tree_xmin, tree_ymin : Integer;

procedure DrawSourceTriangle(Canvas : TCanvas; X, Y : Integer; Cl : TColor);
begin
   Canvas.Brush.Color := Cl;
   Canvas.Brush.Style := bsSolid;
   Canvas.Polygon([Point(X, Y),
                   Point(X + 10, Y + 6),
                   Point(X + 10, Y - 6),
                   Point(X, Y)]);
end;


constructor TDiagramTreeCanvas.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  FHintWindow := TDiagramHintWindow.Create(self);
  FHintWindow.Color := Application.HintColor;

  Height := 20;
  Width := 20;
  (Owner as TDiagramTree).Root := TDiagramNode.Create(self, nil);
  (Owner as TDiagramTree).Root.Caption := 'Root';
  (Owner as TDiagramTree).Root.Color := clInfoBk;

  // Save the coordinates where we will start drawing.
  tree_xmin := 20;
  tree_ymin := 20;
end;

destructor TDiagramTreeCanvas.Destroy;
begin
  FHintWindow.Free;
  inherited destroy;
end;

procedure TDiagramTreeCanvas.Paint;
var
  OldStyle : TPenStyle;

begin
  inherited;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(0, 0, Width, Height));
  if csDesigning in ComponentState then
  begin
    OldStyle := Canvas.Pen.Style;
    Canvas.Pen.Style := psDash;
    Canvas.Rectangle(0, 0, Width, Height);
    Canvas.Pen.Style := OldStyle;
  end
  else
    if (Owner as TDiagramTree).Root <> nil then
      (Owner as TDiagramTree).Root.DrawSubtree(Canvas, (Owner as TDiagramTree).SelectedNode);
end;

procedure TDiagramTreeCanvas.Click;
begin
  inherited click;
  if Assigned(TDiagramTree(Owner).OnClick) then
    TDiagramTree(Owner).OnClick(Self);
end;

procedure TDiagramTreeCanvas.MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
begin
  inherited;
  if Assigned(TDiagramTree(Owner).Root) then
    TDiagramTree(Owner).SelectNode((Owner as TDiagramTree).Root.NodeAtPoint(X, Y));
end;

procedure TDiagramTreeCanvas.MouseMove(Shift : TShiftState; X, Y : Integer);
var
  Pt : TPoint;
  DN : TDiagramNode;
  Rect : TRect;
begin
  inherited;
  if Assigned(TDiagramTree(Owner).Root) then
  begin
    DN := TDiagramTree(Owner).Root.NodeAtPoint(X, Y);
    if Assigned(DN) and Assigned(DN.Data) and (DN.Data is TInterbasePlanObject) then
      begin
        if not FHintWindow.Visible then
        begin
          SetCapture(TDiagramTree(Owner).Handle);  
          FHintWindow.Node := DN;
          Rect := FHintWindow.CalcHintRect(250, '', TInterbasePlanObject(DN.Data));
          Pt := ClientToScreen(Point(X, Y + GetSystemMetrics(SM_CYCURSOR)));
          OffsetRect(Rect, Pt.X, Pt.Y);
          FHintWindow.ActivateHintData(Rect, '', TInterbasePlanObject(DN.Data));
        end;
      end
      else
        begin
          FHintWindow.HideHint;
          ReleaseCapture;
        end;
  end
  else
    begin
      FHintWindow.HideHint;
      ReleaseCapture;
    end;
end;

constructor TDiagramNode.Create(AOwner : TComponent; AParentNode : TDiagramNode);
begin
  inherited Create;
  FOwner := AOwner;
  FParentNode := AParentNode;
  FChildren := TList.Create;
  FBitmap := TBitmap.Create;
  FColor := clWindow;
end;

destructor TDiagramNode.Destroy;
var
  i : Integer;
  Child : TDiagramNode;

begin
  // Free the Children.
  for i := 0 to FChildren.Count - 1 do
  begin
    Child := FChildren.Items[i];
    Child.Free;
  end;

  // Free the Children list.
  FChildren.Free;
  FBitmap.Free;

  if Assigned(FData) then
    TObject(FData).Free;
  inherited Destroy;
end;

procedure TDiagramNode.SetVPosition(var start_x : Integer; start_y : Integer);
var
  i, xmin : Integer;
  Child : TDiagramNode;

begin
  // reset global variables for canvas extents
  {with (FOwner.Owner as TDiagramTree) do
  begin
    FWidthExtents := 0;
    FHeightExtents := 0;
  end;}

  // Set the node's top and bottom. (or left & right)
  FPosition.Top := start_y;
  FPosition.Bottom := start_y + TDiagramTree(FOwner.Owner).BoxHeight;

  // Record the leftmost (or Topmost) Position used.
  xmin := start_x;

  // If there are no Children, put the node here.
  if (FChildren.Count = 0) then
  begin
    start_x := xmin + TDiagramTree(FOwner.Owner).BoxWidth;
  end
  else
  begin
    // This is where the Children will start.
    start_y := start_y + (FOwner.Owner as TDiagramTree).BoxHeight
      + (FOwner.Owner as TDiagramTree).BoxVGap;

    // Position the Children.
    for i := 0 to FChildren.Count - 1 do
    begin
      // Position this child.
      child := FChildren.Items[i];
      child.SetVPosition(start_x, start_y);
      // Add a little room before the next child.
      start_x := start_x + (FOwner.Owner as TDiagramTree).BoxHGap;
    end;

    // Subtract the gap after the last child.
    start_x := start_x - (FOwner.Owner as TDiagramTree).BoxHGap;
  end;

  // Center this node over its Children (or not!).
  if TDiagramTree(FOwner.Owner).Centred then
    FPosition.Left := (xmin + start_x - TDiagramTree(FOwner.Owner).BoxWidth) div 2
  else
    FPosition.Left := xmin;

  FPosition.Right := FPosition.Left + TDiagramTree(FOwner.Owner).BoxWidth;

  if FPosition.Right > TDiagramTree(FOwner.Owner).DVCanvas.Width then
    TDiagramTree(FOwner.Owner).DVCanvas.Width := FPosition.Right + 10;
  if FPosition.Bottom > TDiagramTree(FOwner.Owner).DVCanvas.Height then
    TDiagramTree(FOwner.Owner).DVCanvas.Height := FPosition.Bottom + 10;
end;

procedure TDiagramNode.SetHPosition(start_x : Integer; var start_y : Integer);
var
  i, ymin : Integer;
  child : TDiagramNode;
begin
  // Set the node's top and bottom. (or left & right)
  FPosition.Left := start_x;
  FPosition.Right := start_x + (FOwner.Owner as TDiagramTree).BoxWidth;

  // Record the leftmost (or Topmost) Position used.
  ymin := start_y;

  // If there are no Children, put the node here.
  if (FChildren.Count = 0) then
  begin
    start_y := ymin + (FOwner.Owner as TDiagramTree).BoxHeight;
  end
  else
  begin
    // This is where the Children will start.
    start_x := start_x + (FOwner.Owner as TDiagramTree).BoxWidth
      + (FOwner.Owner as TDiagramTree).BoxHGap;

    // Position the Children.
    for i := 0 to FChildren.Count - 1 do
    begin
      // Position this child.
      child := FChildren.Items[i];
      child.SetHPosition(start_x, start_y);

      // Add a little room before the next child.
      start_y := start_y + (FOwner.Owner as TDiagramTree).BoxVGap;
    end;

    // Subtract the gap after the last child.
    start_y := start_y - (FOwner.Owner as TDiagramTree).BoxVGap;
  end;

  // Center this node over its Children (or not!).
  if (FOwner.Owner as TDiagramTree).Centred then
    FPosition.Top := (ymin + start_y
      - (FOwner.Owner as TDiagramTree).BoxHeight) div 2
  else
    FPosition.Top := ymin;
  FPosition.Bottom := FPosition.Top + (FOwner.Owner as TDiagramTree).BoxHeight;

  if FPosition.Right > TDiagramTree(FOwner.Owner).DVCanvas.Width then
    TDiagramTree(FOwner.Owner).DVCanvas.Width := FPosition.Right + 10;
  if FPosition.Bottom > TDiagramTree(FOwner.Owner).DVCanvas.Height then
    TDiagramTree(FOwner.Owner).DVCanvas.Height := FPosition.Bottom + 10;

end;

procedure TDiagramNode.DrawNode(cvs : TCanvas; selected_node : TDiagramNode);
var
  R : TRect;

begin
  // Set colors depending on whether we need to highlight this node.
  cvs.Font.Assign(TdiagramTree(FOwner.Owner).Font);
  cvs.Brush.Color := clWindow;
  cvs.Font.Color := TDiagramTree(FOwner.Owner).Font.Color;

  // Erase the node's Position and draw a box.
  cvs.FillRect(FPosition);

  // draw the bitmap
  if TDiagramTree(FOwner.Owner).ShowBitmap and (TDiagramTree(FOwner.Owner).Images <> nil) then
  begin
    TDiagramTree(FOwner.Owner).Images.GetBitmap(FImageIndex, FBitmap);
    FBitmap.Transparent := True;

    cvs.Draw(FPosition.Left + ((FPosition.Right - FPosition.Left - FBitmap.Width) div 2), FPosition.Top, FBitmap)
  end;

  if (selected_node = Self) then
  begin
    cvs.Font.Color := clHighlightText;
    cvs.Brush.Color := clHighlight;
    R := Rect(FPosition.Left, FPosition.Top + 32, FPosition.Right, FPosition.Bottom);
    cvs.FillRect(R);
    DrawFocusRect(cvs.Handle, R);
  end;

  // Draw the node's value text.
  R := Rect(FPosition.Left + 2, FPosition.Top + 32, FPosition.Right - 2, FPosition.Bottom - 16);
  DrawTextEx(cvs.Handle, PChar(Caption), Length(Caption), R, DT_CENTER or DT_SINGLELINE or DT_END_ELLIPSIS, nil);
end;

// Draw the subtree rooted at this node.

procedure TDiagramNode.DrawSubtree(cvs : TCanvas; selected_node : TDiagramNode);
var
  i : Integer;
  x1, y1, mx, my, x2, y2 : Integer;
  child : TDiagramNode;
begin
  // Draw this node.
  DrawNode(cvs, selected_node);

  // Draw the Children.
  for i := 0 to FChildren.Count - 1 do
  begin
    child := FChildren.Items[i];

    // Draw the node itself.
    child.DrawSubtree(cvs, selected_node);

    // Draw lines connecting the node and the child.
    if (FOwner.Owner as TDiagramTree).Layout = loVertical then
    begin
      x1 := (FPosition.Left + (FOwner.Owner as TDiagramTree).BoxWidth div 2) + 4;
      y1 := FPosition.Top + (FOwner.Owner as TDiagramTree).BoxHeight;
      x2 := (child.Left + (FOwner.Owner as TDiagramTree).BoxWidth div 2) - 4;
      y2 := child.Top;
    end
    else
    begin
      x1 := FPosition.Right + 4;
      y1 := (FPosition.Top + FPosition.Bottom) div 2;
      x2 := child.FPosition.Left - 4;
      y2 := (child.FPosition.Top + child.FPosition.Bottom) div 2;
    end;

    mx := (x1 + x2) div 2;
    my := (y1 + y2) div 2;

    cvs.Pen.Width := 2;
    cvs.MoveTo(x1, y1);
    if (FOwner.Owner as TDiagramTree).Connector = ctOrthogonal then
    begin
      if (FOwner.Owner as TDiagramTree).Layout = loVertical then
      begin
        cvs.LineTo(x1, my);
        cvs.LineTo(x2, my);
      end
      else
      begin
        cvs.LineTo(mx, y1);
        cvs.LineTo(mx, y2);
      end
    end;
    cvs.LineTo(x2, y2);
    //draw arrow...
    DrawSourceTriangle(cvs, X1, Y1, cvs.Pen.Color);


    cvs.Pen.Width := 1;
    cvs.Pen.Color := clBlack;
  end;
end;

function TDiagramNode.NodeAtPoint(X, Y : Integer) : TDiagramNode;
var
  i : Integer;
  child : TDiagramNode;
  iCentreX : integer;
  blOnNode : boolean;
begin
  // Assume we will not find the node.
  Result := nil;

  // See if the point is on the bitmap
  iCentreX := (FPosition.Right + FPosition.Left) div 2;

  // See if the point is on the bitmap
  blOnNode := (iCentreX - (FBitmap.Width div 2) <= X) and (X <= iCentreX + (FBitmap.Width div 2)) and
              (FPosition.Top <= Y) and (Y <= FPosition.Top + FBitmap.Height);
  // See if the point is on the text
  blOnNode := blOnNode or (FPosition.Left + 2 <= X) and (X <= FPosition.Right - 2) and
                          (FPosition.Top + FBitmap.Height <= Y) and (Y <= FPosition.Bottom);

  if blOnNode then
  begin
    // We are the node.
    Result := Self;
  end
  else
  begin
    // Recursively check the Children.
    for i := 0 to FChildren.Count - 1 do
    begin
      child := FChildren.Items[i];
      Result := child.NodeAtPoint(X, Y);
      if (Result <> nil) then break;
    end;
  end;
end;

function TDiagramNode.RemoveNode(target_node : TDiagramNode) : Boolean;
var
  i : Integer;
  child : TDiagramNode;
begin
  // Assume we will fail to find the target.
  Result := False;
  // Examine each child.
  for i := 0 to FChildren.Count - 1 do
  begin
    child := FChildren.Items[i];
    // See if the child is the target.
    if (child = target_node) then
    begin
      // The child is the target. Remove it.
      FChildren.Delete(i);
      Result := True;
      break;
    end
    else
    begin
      // Recursively make the child look for the target.
      Result := child.RemoveNode(target_node);
      // If the child removed the target, we're done.
      if (Result) then break;
    end;
  end;
end;

function TDiagramNode.FindNodeValue(target_value : string) : TDiagramNode;
var
  i : Integer;
  child : TDiagramNode;
begin
  // Assume we will not find the target.
  Result := nil;

  // See if this is the node we want.
  if (NodeID = target_value) then
  begin
    // It is. Return this node.
    Result := Self;
  end
  else
  begin
    // It is not. Make the Children search for it.
    for i := 0 to FChildren.Count - 1 do
    begin
      child := FChildren.Items[i];

      // See if this child can find the target.
      Result := child.FindNodeValue(target_value);

      // If the child found it, we are done.
      if (Result <> nil) then
        Break;
    end;
  end;
end;

{ TDiagramTree }

function TDiagramTree.AddNode(id : string; ParentNode : TDiagramNode) : TDiagramNode;
var
  node : TDiagramNode;
begin
  node := TDiagramNode.Create(self.DVCanvas, ParentNode);
  node.NodeID := id;
  node.Color := clGreen;
  if ParentNode = nil then
  begin
    Root := node;
  end
  else
  begin
    ParentNode.Children.Add(node);
  end;
  Result := Node;
end;

constructor TDiagramTree.Create(AOwner : TComponent);
begin
  inherited;
  FBoxWidth := 100;
  FBoxHeight := 18;
  FBoxHGap := 10;
  FBoxVGap := 10;
  FLayout := loVertical;
  FConnector := ctSimple;
  FCentred := True;
  FShowBitmap := True;
  DVCanvas := TDiagramTreeCanvas.Create(self);
  with DVCanvas do
  begin
    Parent := Self;
  end;
  // Start with no node selected.
  SelectedNode := nil;

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  Redraw;
  Resize;
end;

destructor TDiagramTree.Destroy;
begin
  DVCanvas.Free;
  FImageChangeLink.Free;
  inherited;
end;

procedure TDiagramTree.Resize;
begin
  inherited;
end;

procedure TDiagramTree.Redraw;
var
  tree_xmin, tree_ymin : Integer;
  start_x : Integer;
begin
  tree_xmin := 20;
  tree_ymin := 20;

  // Position the Root.
  start_x := tree_xmin;
  if Root <> nil then
  begin
    if FLayout = loVertical then
      Root.SetVPosition(start_x, tree_ymin)
    else
      Root.SetHPosition(start_x, tree_ymin);
    Resize;
    Refresh;
  end;
end;

procedure TDiagramTree.Clear;
begin
  Root.Free;
  Root := nil;
  redraw;
end;

procedure TDiagramTree.CreateWnd;
begin
  inherited CreateWnd;
  if (Images <> nil) and Images.HandleAllocated then
    Perform(TCM_SETIMAGELIST, 0, Images.Handle);
end;

procedure TDiagramTree.DestroyWnd;
begin
  inherited DestroyWnd;
end;

procedure TDiagramTree.ImageListChange(Sender : TObject);
begin
  Perform(TCM_SETIMAGELIST, 0, TCustomImageList(Sender).Handle);
end;


procedure TDiagramTree.SetImages(Value : TCustomImageList);
begin
  if Images <> nil then
    Images.UnRegisterChanges(FImageChangeLink);
  FImages := Value;
  if Images <> nil then
  begin
    Images.RegisterChanges(FImageChangeLink);
    Images.FreeNotification(Self);
    Perform(TCM_SETIMAGELIST, 0, Images.Handle);
  end
  else
    Perform(TCM_SETIMAGELIST, 0, 0);
end;

procedure TDiagramTree.SelectNode(new_selected : TDiagramNode);
begin
  // Save the newly selected node.
  SelectedNode := new_selected;

  if Assigned(FOnSelectedChange) then
    FOnSelectedChange(Self);

  Invalidate;
end;

procedure TDiagramTree.MouseMove(Shift: TShiftState; X, Y: Integer);      
var
  Pt : TPoint;
begin
  inherited;                     
  Pt := ClientToScreen(Point(X, Y));
  Pt := DVCanvas.ScreenToClient(Pt);
  TDiagramTreeCanvas(DVCanvas).MouseMove(Shift, Pt.X,Pt.Y);
end;

procedure TDiagramTree.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Pt : TPoint;
begin
  inherited;
  Pt := ClientToScreen(Point(X, Y));
  Pt := DVCanvas.ScreenToClient(Pt);
  TDiagramTreeCanvas(DVCanvas).MouseDown(Button, Shift, Pt.X,Pt.Y);
end;

procedure TDiagramTree.PaintToCanvas(Canvas: TCanvas);
begin
  Root.DrawSubtree(Canvas, nil);
end;

{ TDiagramHintWindow }

constructor TDiagramHintWindow.Create(AOwner: TComponent);
begin
  inherited;
  Visible := False;
end;

procedure TDiagramHintWindow.ActivateHintData(Rect: TRect;
  const AHint: string; AData: Pointer);
begin
  if Assigned(AData) and (TObject(AData) is TInterbasePlanObject) then
    begin
      FData := TInterbasePlanObject(AData);
      ActivateHint(Rect, '');
      Visible := True;
    end;
end;

function TDiagramHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string;
      AData: Pointer): TRect;
var
  Flags : longint;
begin
  Result := Rect(0, 0, MaxWidth, 0);
  Flags := DT_TOP or DT_NOPREFIX or DT_CALCRECT or DrawTextBiDiModeFlagsReadingOnly;

  if Assigned(AData) and (TObject(AData) is TInterbasePlanObject) then
  begin
    PaintPlanObject(Result, TInterbasePlanObject(AData), Flags);
    Result.Top := 0;
    Result.Right := 250;
  end
  else
    DrawText(Canvas.Handle, PChar(Caption), -1, Result, Flags);

  InflateRect(Result, 5, 5);
end;

procedure TDiagramHintWindow.HideHint;
begin
  if HandleAllocated and
    IsWindowVisible(Self.Handle) then
    ShowWindow(Self.Handle, SW_HIDE);
  Visible := False;
end;

procedure TDiagramHintWindow.Paint;
var
  Flags : longint;
  R: TRect;
begin
  R := ClientRect;
  InflateRect(R, -4, -4);
  Canvas.Font.Color := clInfoText;
  Flags := DT_TOP or DT_NOPREFIX or DT_WORDBREAK or DrawTextBiDiModeFlagsReadingOnly;

  if Assigned(FData) and (TObject(FData) is TInterbasePlanObject) then
    PaintPlanObject(R, TInterbasePlanObject(FData), Flags)
  else
    DrawText(Canvas.Handle, PChar(Caption), -1, R, Flags);
end;

procedure TDiagramHintWindow.PaintPlanObject(var R: TRect;
  PlanItem: TInterbasePlanObject; Flags : longint);
var
  StartRect : TRect;
  Idx : Integer;

begin
  with PlanItem do
  begin
    case NodeType of
      pntOperation :
        begin
          StartRect := R;
          Canvas.Font.Style := Canvas.Font.Style + [fsBold];
          R.Top := R.Top + DrawText(Canvas.Handle, PChar('Operation'), -1, R, Flags or DT_CENTER);
          Canvas.Font.Style := Canvas.Font.Style - [fsBold];

          R := Rect(StartRect.Left, R.Top, StartRect.Right, R.Bottom);
          PaintItem(R, '', '', Flags);
          PaintText(R, '', 'Logical Operation : ' + PlanItem.Caption, Flags);
          PaintItem(R, '', '', Flags);
        end;
      pntRelation :
        begin
          StartRect := R;
          Canvas.Font.Style := Canvas.Font.Style + [fsBold];
          R.Top := R.Top + DrawText(Canvas.Handle, PChar('Relation'), -1, R, Flags or DT_CENTER);
          Canvas.Font.Style := Canvas.Font.Style - [fsBold];

          R := Rect(StartRect.Left, R.Top, StartRect.Right, R.Bottom);
          PaintItem(R, '', '', Flags);
          PaintText(R, '', 'Relation : ' + PlanItem.Caption, Flags);
          PaintText(R, '', 'Access Method : ' + PlanItem.AccessType, Flags);
          PaintItem(R, '', '', Flags);
          if PlanItem.AccessType = 'INDEX' then
          begin
            PaintItem(R, 'Indexes:', '', Flags);
            for Idx := 0 to PlanItem.ItemList.Count - 1 do
            begin
              PaintText(R, '', PlanItem.ItemList[Idx], Flags);
            end;
          end;
        end;
   end;
  end;
end;

procedure TDiagramHintWindow.PaintItem(var Rect: TRect; sName,
  sValue: string; Flags : longint);
begin
  if (sName <> '') then
  begin
    DrawText(Canvas.Handle, PChar(sValue), -1, Rect, Flags or DT_RIGHT);
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    Rect.Top := Rect.Top + DrawText(Canvas.Handle, PChar(sName), -1, Rect, Flags or DT_LEFT);
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];
  end
  else
  begin
    OffsetRect(Rect, 0, Canvas.TextHeight('W'));
  end;
end;            

procedure TDiagramHintWindow.PaintText(var R: TRect; sName,
  sText: string; Flags: Integer);
var                   
  StartRect : TRect;
  BlockRect : TRect;
begin
  StartRect := R;
  if (sName <> '') then
  begin
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    R.Top := R.Top + DrawText(Canvas.Handle, PChar(sName), -1, R, Flags or DT_LEFT);
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];
  end;
  BlockRect := Rect(StartRect.Left, R.Top, StartRect.Right, R.Top + 120);
  Flags := Flags or DT_LEFT or DT_WORDBREAK or DT_EDITCONTROL or DT_END_ELLIPSIS;
  BlockRect.Top := BlockRect.Top + DrawText(Canvas.Handle, PChar(sText), -1, BlockRect, Flags);
  if (BlockRect.Top > R.Top + 120) then
  begin
    R.Top := R.Top + 120;
    R.Bottom := R.Bottom + 120;
  end
  else
  begin
    R.Top := BlockRect.Top;
    if R.Bottom < R.Top then
      R.Bottom := R.Top;
  end;
end;

function TDiagramNode.GetLeft: integer;
begin
  Result := FPosition.Left;
end;

function TDiagramNode.GetTop: integer;
begin
  Result := FPosition.Top;
end;

procedure Register;
begin
  RegisterComponents('GSS', [TDiagramTree]);
end;

end.

