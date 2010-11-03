unit adbpedit;

interface
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     DB, StdCtrls, DBCtrls, ExtCtrls;

type

TDBPanelEdit = class;

TDataLinkDBPanelEdit = class(TDataLink)
private
  FDBPanelEdit: TDBPanelEdit;
protected
  procedure ActiveChanged; override;
end;

TDBPanelEditControlType = (pectEdit, pectMemo, pectImage, pectLookUp,
                         pectDate, pectTime, pectDateTime);

TDBPanelEditControls = class;

TDBPanelEditControl = class
private
  FOwner : TDBPanelEditControls;
  FDBControl : TWinControl;
  FLabel : TLabel;
  FControlType : TDBPanelEditControlType;
public
  property ControlType : TDBPanelEditControlType read FControlType write FControlType;
  property DBControl : TWinControl read FDBControl write FDBControl;
  property LControl : TLabel read FLabel write FLabel;

  constructor Create(AOwner : TDBPanelEditControls);
  destructor Destroy; override;
  procedure SetFieldName(FieldName : String);
end;

TDBPanelEditControls = class
private
  FList : TList;
  FDBPanelEdit : TDBPanelEdit;

  function GetCount : Integer;
  function GetDBPanelEditControl(Index : Integer) : TDBPanelEditControl;
protected
  procedure Clear;
public
  property Count : Integer read GetCount;
  property Items[Index: Integer]: TDBPanelEditControl read GetDBPanelEditControl; default;
  constructor Create(DBPanelEdit : TDBPanelEdit);
  destructor Destroy; override;
  procedure Add(FieldName : String);
end;  

TDBPanelEdit = class(TCustomPanel)
private
  FDataLink : TDataLinkDBPanelEdit;
  ScrollBox : TScrollBox;
  Controls : TDBPanelEditControls;
  FDataSource : TDataSource;
  FRefreshed : Boolean;

  AFont : TFont;
  AFontLabel : TFont;

  function GetDataSource : TDataSource;
  function GetReadOnly : Boolean;
  procedure SetDataSource(Value : TDataSource);
  procedure SetFontControl(Value : TFont);
  procedure SetFontLabel(Value : TFont);
  procedure SetReadOnly(Value : Boolean);
  procedure SetRefrehed(Value : Boolean);
protected
  procedure CreateField(DBEditControl : TDBPanelEditControl; FieldName : String);
  procedure CreateDBControl(f : TField; DBPanelEditControl : TDBPanelEditControl); virtual;
  function GetEditControlType(Field : TField) : TDBPanelEditControlType; virtual;
  procedure DataActiveChanged;
  function GetControlParent : TWinControl;
  function GetDefaultWidth(f : TField; Font : TFont): Integer;
public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
  procedure RefreshControls;
published
  property DataSource : TDataSource read GetDataSource write SetDataSource;
  property ControlFont : TFont read AFont write SetFontControl;
  property LabelFont : TFont read AFontLabel write SetFontLabel;
  property ReadOnly : Boolean read GetReadOnly write SetReadOnly;
  property Refreshed : Boolean read FRefreshed write SetRefrehed;
  property Align;
  property BevelInner;
  property BevelOuter;
  property BevelWidth;
  property BorderWidth;
  property TabOrder;
  property PopUpMenu;
end;

procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('Data Controls', [TDBPanelEdit]);
end;

{TDBPanelEditControl}
constructor TDBPanelEditControl.Create(AOwner : TDBPanelEditControls);
begin
  inherited Create;
  FOwner := AOwner;
  FLabel := Nil;
  FDBControl := Nil;
end;

destructor TDBPanelEditControl.Destroy;
begin
  if(FLabel <> NIl) And Not (csDestroying in FLabel.ComponentState) then
    FLabel.Free;
  if(FDBControl <> NIl) And Not (csDestroying in FDBControl.ComponentState) then
    FDBControl.Free;
  if(FOwner <> Nil) then
    FOwner.FList.Remove(self);
  inherited Destroy;
end;

procedure TDBPanelEditControl.SetFieldName(FieldName : String);
begin
  if(FDBControl <> NIl) then
    FDBControl.Free;
  if(FLabel = Nil) then
  begin
    FLabel := TLabel.Create(Nil);
    FLabel.Parent := FOwner.FDBPanelEdit.GetControlParent;
  end;
  FOwner.FDBPanelEdit.CreateField(self, FieldName);
end;

{TDBPanelEditControls}
constructor TDBPanelEditControls.Create(DBPanelEdit : TDBPanelEdit);
begin
  inherited Create;
  FDBPanelEdit := DBPanelEdit;
  FList := TList.Create;
end;

destructor TDBPanelEditControls.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TDBPanelEditControls.GetCount : Integer;
begin
  Result := FList.Count;
end;

function TDBPanelEditControls.GetDBPanelEditControl(Index : Integer) : TDBPanelEditControl;
begin
  Result := Nil;
  if(Index > -1) And (Index < Count) then
    Result := TDBPanelEditControl(FList[Index]);
end;

procedure TDBPanelEditControls.Clear;
begin
  While Count > 0 do
    Items[0].Free;
end;

procedure TDBPanelEditControls.Add(FieldName : String);
var
  DBControl : TDBPanelEditControl;
begin
  DBControl := TDBPanelEditControl.Create(self);
  FList.Add(DBControl);
  DBControl.SetFieldName(FieldName);
end;

{TDataLinkDBPanelEdit}
procedure TDataLinkDBPanelEdit.ActiveChanged;
begin
  if(FDBPanelEdit <> Nil) then FDBPanelEdit.DataActiveChanged;
end;

{ TDBPanelEdit}

constructor TDBPanelEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TDataLinkDBPanelEdit.Create;
  FDataLink.FDBPanelEdit := self;
  FDataSource := TDataSource.Create(self);

  Controls := TDBPanelEditControls.Create(self);

  ScrollBox := TScrollBox.Create(self);
  ScrollBox.Parent := self;
  ScrollBox.Align := alClient;

  AFont := TFont.Create;
  AFontLabel := TFont.Create;

  BevelInner := bvNone;
  BevelOuter := bvNone;
  BorderWidth := 0;
end;

destructor TDBPanelEdit.Destroy;
begin
  Controls.Clear;
  
  FDataLink.FDBPanelEdit := Nil;
  FDataLink.Free;
  FDataSource.Free;

  Controls.Free;

  ScrollBox.Free;

  AFont.Free;
  AFontLabel.Free;
  inherited Destroy;
end;

function TDBPanelEdit.GetDataSource : TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TDBPanelEdit.GetReadOnly : Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TDBPanelEdit.SetDataSource(Value : TDataSource);
begin
  FDataLink.DataSource := Value;
  if(FDataLink.DataSource = Nil) then
    FDataSource.DataSet := Nil;
end;

procedure TDBPanelEdit.DataActiveChanged;
begin
  if(FDataLink.DataSource <> Nil) then
    FDataSource.DataSet := FDataLink.DataSource.DataSet;
  RefreshControls;
end;

function TDBPanelEdit.GetControlParent : TWinControl;
begin
  Result := TWinControl(ScrollBox);
end;

procedure TDBPanelEdit.SetFontControl(Value : TFont);
begin
  if(Value = Nil) then exit;
  AFont.Assign(Value);
  if(Value <> Nil) then
    RefreshControls;
end;

procedure TDBPanelEdit.SetFontLabel(Value : TFont);
begin
  if(Value = Nil) then exit;
  AFontLabel.Assign(Value);
  if(Value <> Nil) then
    RefreshControls;
end;


procedure TDBPanelEdit.SetReadOnly(Value : Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

procedure TDBPanelEdit.SetRefrehed(Value : Boolean);
begin
  FRefreshed := Value;
  if (Value) then begin
    RefreshControls;
    FRefreshed := False;
  end;
end;

procedure TDBPanelEdit.RefreshControls;
var
  i, w, MaxLabelWidth : Integer;
  Field : TField;
begin
  ScrollBox.Visible := False;
  ScrollBox.Width := Width - 2 * BorderWidth;
  Controls.Clear;

  if Not (FDataLink.Active) then begin
    ScrollBox.Visible := True;
    exit;
  end;

  for i := 0 to FDataLink.DataSet.FieldCount - 1  do begin
    Field := FDataLink.DataSet.Fields[i];
    if(Field.Visible) then
      Controls.Add(Field.FieldName)
  end;

  MaxLabelWidth := 0;
  for i := 0 to Controls.Count - 1 do
    if(MaxLabelWidth < Controls[i].LControl.Width) then
      MaxLabelWidth := Controls[i].LControl.Width;

  for i := 0 to Controls.Count - 1 do begin
    if( i = 0) then
      Controls[i].LControl.Top := BorderWidth + BevelWidth + 5
   else
     Controls[i].LControl.Top := (Controls[i - 1].DBControl.Top + Controls[i - 1].DBControl.Height + BorderWidth + BevelWidth) + 4;


   Controls[i].DBControl.Top := Controls[i].LControl.Top - 3;
   Controls[i].LControl.Left := (BorderWidth + BevelWidth + MaxLabelWidth - Controls[i].LControl.Width) + 5;
   Controls[i].DBControl.Left := (2 * BorderWidth + BevelWidth + MaxLabelWidth) + 5;

   w := Width - 3 * ((BorderWidth + BevelWidth + MaxLabelWidth) + 5);

   if(w < 100) then
     w := 100;

   if(Controls[i].DBControl.Width > w) then
     Controls[i].DBControl.Width := w;

  end;
  ScrollBox.Visible := True;
end;

procedure TDBPanelEdit.CreateField(DBEditControl : TDBPanelEditControl; FieldName : String);
Var
  f : TField;
begin
  if(FDataLink.DataSet <> Nil) then
  begin
     f := FDataLink.DataSet.FindField(FieldName);

    with DBEditControl.LControl do
    begin
      DBEditControl.LControl.Caption := f.DisplayLabel + ':';
      Left := 10;

      if(AFontLabel <> Nil) then
        Font := AFontLabel;
    end;

    CreateDBControl(f, DBEditControl);
  end;  
end;

procedure TDBPanelEdit.CreateDBControl(f : TField; DBPanelEditControl : TDBPanelEditControl);
begin
  case GetEditControlType(f) of
    pectEdit :
      begin
        DBPanelEditControl.DBControl := TDBEdit.Create(Nil);
        with TDBEdit(DBPanelEditControl.DBControl) do begin
          parent := ScrollBox;
          DataSource :=  FDataSource;
          DataField := f.FieldName;
          if(AFont <> Nil) then
             Font := AFont;
          Width := GetDefaultWidth(f, Font);
        end;
      end;
    pectImage :
      begin
        DBPanelEditControl.DBControl := TDBImage.Create(Nil);
        with TDBImage(DBPanelEditControl.DBControl)do begin
          parent := ScrollBox;
          DataField := f.FieldName;
          DataSource :=  FDataSource;
          if(AFont <> Nil) then
             Font := AFont;
          Height := Picture.Height;
          Width := Picture.Width;
        end;
      end;
    pectLookUp :
      begin
        DBPanelEditControl.DBControl := TDBLookUpComboBox.Create(Nil);
        with TDBLookUpComboBox(DBPanelEditControl.DBControl) do begin
          parent := ScrollBox;
          DataSource :=  FDataSource;
          DataField := f.FieldName;
          if(AFont <> Nil) then
             Font := AFont;
          if (f.LookUpDataSet <> Nil) then
             GetDefaultWidth(f.LookUpDataSet.FindField(f.LookUpResultField), Font)
          else Width := 100;
        end;
      end;
    pectMemo :
      begin
        DBPanelEditControl.DBControl :=  TDBMemo.Create(Nil);
        with TDBMemo(DBPanelEditControl.DBControl) do begin
          parent := ScrollBox;
          DataSource :=  FDataSource;
          DataField := f.FieldName;
          if(AFont <> Nil) then
             Font := AFont;
          Height := 100;
          Width := 300;
        end;
      end;
    end;
end;

function TDBPanelEdit.GetEditControlType(Field : TField) : TDBPanelEditControlType;
begin
  case Field.DataType of
    ftMemo, ftFmtMemo : Result := pectMemo;
    ftGraphic, ftTypedBinary : Result := pectImage;
   else
     if(Field.LookUp) then
        Result := pectLookUp
     else Result := pectEdit;
  end;
end;

function TDBPanelEdit.GetDefaultWidth(f : TField; Font : TFont): Integer;
var
  RestoreCanvas: Boolean;
  TM: TTextMetric;

begin
   if(f = Nil) then begin
     Result := 100;
     exit;
   end;

   RestoreCanvas := not HandleAllocated;
   if RestoreCanvas then
     Canvas.Handle := GetDC(0);
   try
     Canvas.Font := Font;
     GetTextMetrics(Canvas.Handle, TM);
     if F.DisplayWidth < 10 then
       Result := 10 * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4
     else
       Result := f.DisplayWidth * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4;
   finally
     if RestoreCanvas then begin
       ReleaseDC(0,Canvas.Handle);
       Canvas.Handle := 0;
     end;
   end;
end;


end.
