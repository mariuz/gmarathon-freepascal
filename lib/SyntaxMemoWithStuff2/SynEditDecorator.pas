unit SynEditDecorator;

interface
uses windows, SynEdit, classes, graphics, sysutils;

type
  TSynEditDecorator = class;

  TDecorationType = (dtSpelling,dtGrammar,dtHyperlink,dtCustom);

  TSynEditDecoration = class(TCollectionItem)
  private
    fStartIndex : integer;
    fEndIndex   : integer;
    fType       : TDecorationType;
    fData       : pointer;
    fLine       : integer;

    procedure SetEndIndex(const Value: integer);
    procedure SetStartIndex(const Value: integer);
    procedure SetType(const Value: TDecorationType);
    procedure SetLine(const Value: integer);
  protected
  public
    property Data           : pointer         read fData       write fData;
  published
    property Line           : integer         read fLine       write SetLine;
    property StartIndex     : integer         read fStartIndex write SetStartIndex;
    property EndIndex       : integer         read fEndIndex   write SetEndIndex;
    property DecorationType : TDecorationType read fType       write SetType;
  end;

  TSynEditDecorations = class(TCollection)
  private
    fOwner : TSynEditDecorator;
    function GetItem(index: integer): TSynEditDecoration;
    procedure SetItem(index: integer; const Value: TSynEditDecoration);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner:TPersistent; override;
  public
    constructor Create(AOwner : TSynEditDecorator);

    function Add:TSynEditDecoration;

    property Items[index : integer] : TSynEditDecoration read GetItem write SetItem; default;
  end;

  TDrawDecorationEvent = procedure(Sender : TObject; decoration : TSynEditDecoration; rect : TRect) of object;

  TSynEditDecorator = class(TComponent)
  private
    fSpellingColor    : TColor;
    fLinkColor        : TColor;
    fGrammarColor     : TColor;
    fDecorations      : TSynEditDecorations;
    fEditor           : TCustomSynEdit;
    fOnDrawDecoration : TDrawDecorationEvent;

    Plugin            : TSynEditPlugin;

    procedure PaintDecorations(Canvas: TCanvas; AClip: TRect; FirstLine,LastLine: integer);
    procedure LinesDeleted(StartLine, Count : integer);
    procedure LinesInserted(StartLine, Count : integer);
    
    procedure SetGrammarColor(const Value: TColor);
    procedure SetLinkColor(const Value: TColor);
    procedure SetSpellingColor(const Value: TColor);
    procedure SetEditor(const Value: TCustomSynEdit);
  protected
    procedure InvalidateEditor;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function DecorationAt(Pos : TPoint):TSynEditDecoration;
  published
    property Decorations      : TSynEditDecorations  read fDecorations      write fDecorations;
    property HyperlinkColor   : TColor               read fLinkColor        write SetLinkColor;
    property SpellingColor    : TColor               read fSpellingColor    write SetSpellingColor;
    property GrammarColor     : TColor               read fGrammarColor     write SetGrammarColor;
    property Editor           : TCustomSynEdit       read fEditor           write SetEditor;
    property OnDrawDecoration : TDrawDecorationEvent read fOnDrawDecoration write fOnDrawDecoration;
  end;

implementation

type
  TDecoratorPlugin = class(TSynEditPlugin)
    decorator : TSynEditDecorator;

    constructor Create(ADecorator : TSynEditDecorator);
    destructor Destroy; override;

    procedure AfterPaint(Canvas: TCanvas; AClip: TRect; FirstLine, LastLine: integer); override;
    procedure LinesInserted(StartLine, Count : integer); override;
    procedure LinesDeleted(StartLine, Count : integer); override;
  end;

{ TSynEditDecorator }

constructor TSynEditDecorator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fDecorations:=TSynEditDecorations.Create(self);
  fLinkColor:=clBlue;
  fSpellingColor:=clRed;
  fGrammarColor:=clGreen;
end;

destructor TSynEditDecorator.Destroy;
begin
  fDecorations.Free;

  if Plugin<>nil then
    TDecoratorPlugin(Plugin).decorator:=nil;

  inherited Destroy;
end;

procedure TSynEditDecorator.SetGrammarColor(const Value: TColor);
begin
  fGrammarColor := Value;
  InvalidateEditor;
end;

procedure TSynEditDecorator.SetLinkColor(const Value: TColor);
begin
  fLinkColor := Value;
  InvalidateEditor;
end;

procedure TSynEditDecorator.SetSpellingColor(const Value: TColor);
begin
  fSpellingColor := Value;
  InvalidateEditor;
end;

type
  TInvasionOfPrivacy = class(TCustomSynEdit);

procedure TSynEditDecorator.PaintDecorations(Canvas : TCanvas; AClip : TRect; FirstLine,LastLine: integer);
var
  i           : integer;
  r           : TRect;
  p           : TPoint;
  colEditorBG : TColor;
  selection   : TColor;
  
  procedure DrawWavyLine(color : TColor);
  var
    b     : TBitmap;
    state : integer;
    i,c,x : integer;

  begin
    b:=TBitmap.Create;
    try
      b.PixelFormat:=pf4Bit;
      b.width:=4;
      b.height:=3;
      b.Canvas.Brush.Color:=clWhite;
      b.TransparentColor:=clWhite;
      b.Transparent:=TRUE;
      b.Canvas.Brush.Style:=bsSolid;
      b.Canvas.FillRect(rect(0,0,5,4));
      b.Canvas.Pixels[0,2]:=color;
      b.Canvas.Pixels[1,1]:=color;
      b.Canvas.Pixels[2,0]:=color;
      b.Canvas.Pixels[3,1]:=color;

      r.top:=r.bottom-4;

      state:=saveDC(canvas.Handle);  // Save the state of the device context
      try
        // Set the new clipping rectangle
        IntersectClipRect(canvas.Handle,r.left,r.top,r.right,r.bottom);

        c:=((r.right-r.left) div b.width)+1;
        x:=r.left;

        // Draw the wavy line
        for i:=0 to c do
          begin
            canvas.Draw(x,r.top,b);
            x:=x+b.width;
          end;
      finally
        RestoreDC(canvas.Handle,state); // Restore the state of the device context
      end;
    finally
      b.Free;
    end;
  end;

  procedure DrawHyperLink;
  var
    b   : TBitmap;
    i,j : integer;
    c   : TColor;
    dc  : THandle;

  begin
    b:=TBitmap.Create;
    try
      // Create a bitmap compatible with the device context.
// TODO 1 -cUI -oDJLP: test this with multiple moitors
      dc:=GetDC(editor.handle);
      try
        b.Handle:=CreateCompatibleBitmap(dc,r.right-r.left,r.bottom-r.top);
      finally
        ReleaseDC(editor.handle,DC);
      end;

      b.canvas.CopyRect(rect(0,0,b.width,b.height),canvas,r);

      {24/10/00: PW: QCM #27657 - background color when hyperlinking was changing
       to the hyperlink colour on screens with low color settings (ie 64k).
       ie: setting color to clBlue ($800000) would return $840000 when reading
           back the pixels, resulting in all of the rect being set to blue rather
           than just the text}
      colEditorBG := b.canvas.Pixels[0,0];

      // Now go through all pixels in the temporary bitmap and convert any pixels
      // that aren't background or selection color to the hyperlink color
      for i:=0 to b.width-1 do
        for j:=0 to b.height-1 do
          begin
            c:=b.canvas.Pixels[i,j];
            if (c<>colEditorBG) and (c<>selection) then
              b.canvas.Pixels[i,j]:=HyperlinkColor;
          end;

      // Draw a line under the text
      canvas.Draw(r.left,r.top,b);
      canvas.Pen.Color:=HyperlinkColor;
      canvas.MoveTo(r.left,r.bottom-2);
      canvas.LineTo(r.right,r.bottom-2);
    finally
      b.Free;
    end;
  end;

var
  colBG : TColor;

begin
  if Editor<>nil then
    with Editor do
      begin
        colEditorBG := Color;
        if Assigned(Highlighter) and Assigned(Highlighter.WhitespaceAttribute) then
        begin
          colBG := Highlighter.WhitespaceAttribute.Background;
          if colBG <> clNone then
            colEditorBG := colBG;
        end;

        // Convert these colors to their RGB values
        colEditorBG:=ColorToRGB(colEditorBG);
        selection:=ColorToRGB(TInvasionOfPrivacy(editor).SelectedColor.Background);

        // Go through the decoration list looking for decorations that are on the screen
        for i:=0 to fDecorations.Count-1 do
          with fDecorations[i] do
            if (Line>=FirstLine) and (Line<=LastLine) then
              begin
                p.x:=StartIndex;
                p.y:=Line;
                p:=LogicalToPhysicalPos(p);
                p.y:=Line+1;
                p:=RowColumnToPixels(p);
                r.left:=p.x;
                r.bottom:=p.y;

                p.x:=EndIndex;
                p.y:=Line;
                p:=LogicalToPhysicalPos(p);
                p:=RowColumnToPixels(p);
                r.right:=p.x;
                r.top:=p.y;

                if IntersectRect(r,AClip,r) then
                  case DecorationType of
                    dtSpelling  : DrawWavyLine(SpellingColor);
                    dtGrammar   : DrawWavyLine(GrammarColor);
                    dtHyperlink : DrawHyperLink;
                    dtCustom    : if assigned(fOnDrawDecoration) then
                                    fOnDrawDecoration(self,fDecorations[i],r);
                  end;
              end;
      end;
end;


procedure TSynEditDecorator.LinesDeleted(StartLine, Count : integer);
var
  i : integer;

begin
  for i := Decorations.Count - 1 downto 0 do
    if (Decorations[i].Line >= StartLine) and (Decorations[i].Line < StartLine+Count) then
      Decorations[i].Free // The line this decoration was on has been deleted
    else
      if Decorations[i].Line > StartLine then
        begin
          fEditor.InvalidateLine(Decorations[I].Line);
          Decorations[i].Line := Decorations[i].Line - Count;
        end;
end;

procedure TSynEditDecorator.LinesInserted(StartLine, Count : integer);
var
  i : integer;

begin
  for i := 0 to Decorations.Count-1 do
    if Decorations[I].Line >= StartLine-1 then
      begin
        fEditor.InvalidateLine(Decorations[I].Line);
        Decorations[I].Line := Decorations[I].Line + Count;
      end;
end;

procedure TSynEditDecorator.SetEditor(const Value: TCustomSynEdit);
begin
  fEditor := Value;
  if fEditor<>nil then
    FreeNotification(fEditor);

  if Plugin<>nil then
    Plugin.Free;

  Plugin:=TDecoratorPlugin.Create(self);
end;

procedure TSynEditDecorator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation=opRemove) and (AComponent=fEditor) then
    fEditor:=nil;
end;

procedure TSynEditDecorator.InvalidateEditor;
begin
  if fEditor<>nil then
    fEditor.Invalidate;
end;

function TSynEditDecorator.DecorationAt(Pos: TPoint): TSynEditDecoration;
var
  i : integer;

begin
  result:=nil;
  
  for i:=0 to fDecorations.Count-1 do
    if fDecorations[i].Line=Pos.Y then
      if (Pos.X >= fDecorations[i].StartIndex) and (Pos.X <= fDecorations[i].EndIndex) then
        begin
          result:=fDecorations[i];
          break;  
        end;
end;

{ TSynEditDecorations }

constructor TSynEditDecorations.Create(AOwner: TSynEditDecorator);
begin
  inherited Create(TSynEditDecoration);
  fOwner:=AOwner;
end;

function TSynEditDecorations.Add: TSynEditDecoration;
begin
  result:=TSynEditDecoration(inherited Add);
end;

function TSynEditDecorations.GetItem(index: integer): TSynEditDecoration;
begin
  result:=TSynEditDecoration(inherited GetItem(index));
end;

procedure TSynEditDecorations.SetItem(index: integer; const Value: TSynEditDecoration);
begin
  inherited SetItem(index,Value);
end;

procedure TSynEditDecorations.Update(Item: TCollectionItem);
begin
  inherited Update(Item);

  if item<>nil then
    fOwner.Editor.InvalidateLine(TSynEditDecoration(item).Line)
  else
    fOwner.Editor.Invalidate;
end;

function TSynEditDecorations.GetOwner: TPersistent;
begin
  result:=TPersistent(fOwner);
end;

{ TSynEditDecoration }

procedure TSynEditDecoration.SetEndIndex(const Value: integer);
begin
  if Value<>fEndIndex then
    begin
      fEndIndex := Value;
      Changed(FALSE);
    end;
end;

procedure TSynEditDecoration.SetLine(const Value: integer);
begin
  if Value<>fLine then
    begin
      if fLine<>0 then
        TCustomSynEdit(TSynEditDecorations(Collection).GetOwner).InvalidateLine(fLine);

      fLine := Value;
      Changed(FALSE);
    end;
end;

procedure TSynEditDecoration.SetStartIndex(const Value: integer);
begin
  if Value<>fStartIndex then
    begin
      fStartIndex := Value;
      Changed(FALSE);
    end;
end;

procedure TSynEditDecoration.SetType(const Value: TDecorationType);
begin
  if Value<>fType then
    begin
      fType := Value;
      Changed(FALSE);
    end;
end;


{ TDecoratorPlugin }

procedure TDecoratorPlugin.AfterPaint(Canvas: TCanvas; AClip: TRect; FirstLine,LastLine: integer);
begin
  decorator.PaintDecorations(canvas,AClip,FirstLine,LastLine);
end;

constructor TDecoratorPlugin.Create(ADecorator: TSynEditDecorator);
begin
  if ADecorator=nil then
    raise Exception.Create('ADecorator must not be nil');

  inherited Create(ADecorator.Editor);

  Decorator:=ADecorator;
end;

destructor TDecoratorPlugin.Destroy;
begin
  if Decorator<>nil then
    Decorator.Plugin:=nil;

  inherited Destroy;
end;

procedure TDecoratorPlugin.LinesDeleted(StartLine, Count: integer);
begin
  Decorator.LinesDeleted(StartLine,Count);
end;

procedure TDecoratorPlugin.LinesInserted(StartLine, Count: integer);
begin
  Decorator.LinesInserted(StartLine,Count);
end;

end.


