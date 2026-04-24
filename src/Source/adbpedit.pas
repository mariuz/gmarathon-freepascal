unit adbpedit;

interface
uses {$IFDEF FPC}
  LCLIntf, LCLType, LMessages, {$ELSE}
  Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB, StdCtrls, DBCtrls, ExtCtrls;

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

TDBPanelEditControl = class(TPersistent)
private
  FDBControl : TControl;
  FField : TField;
  FLabel : TLabel;
  FDBPanelEditControlType : TDBPanelEditControlType;
public
  property DBControl : TControl read FDBControl write FDBControl;
  property Field : TField read FField write FField;
  property DBLabel : TLabel read FLabel write FLabel;
  property DBPanelEditControlType : TDBPanelEditControlType
           read FDBPanelEditControlType write FDBPanelEditControlType;
end;

TDBPanelEdit = class(TScrollingWinControl)
private
  FDataLink: TDataLinkDBPanelEdit;
  FDataSource: TDataSource;
  FControls : TList;
  FReadOnly : Boolean;
  FActive : Boolean;
  AFont : TFont;
  ScrollBox : TScrollBox;
  procedure SetDataSource(Value: TDataSource);
  procedure SetActive(Value: Boolean);
  procedure SetReadOnly(Value: Boolean);
  procedure ClearControls;
  procedure CreateDBControl(f : TField; DBPanelEditControl : TDBPanelEditControl);
  function GetEditControlType(Field : TField) : TDBPanelEditControlType;
  function CalculateDefaultWidth(f : TField; Font : TFont): Integer;
  procedure LayoutControls;
protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
published
  property Active: Boolean read FActive write SetActive;
  property DataSource: TDataSource read FDataSource write SetDataSource;
  property ReadOnly: Boolean read FReadOnly write SetReadOnly;
  property Font : TFont read AFont write AFont;
end;

implementation

procedure TDataLinkDBPanelEdit.ActiveChanged;
begin
  if FDBPanelEdit <> nil then FDBPanelEdit.Active := Active;
end;

constructor TDBPanelEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TDataLinkDBPanelEdit.Create;
  FDataLink.FDBPanelEdit := Self;
  FControls := TList.Create;
  FReadOnly := False;
  FActive := False;
  AFont := TFont.Create;
  ScrollBox := TScrollBox.Create(Self);
  ScrollBox.Parent := Self;
  ScrollBox.Align := alClient;
end;

destructor TDBPanelEdit.Destroy;
begin
  ClearControls;
  FControls.Free;
  FDataLink.Free;
  AFont.Free;
  inherited Destroy;
end;

procedure TDBPanelEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSource) then
    DataSource := nil;
end;

procedure TDBPanelEdit.SetDataSource(Value: TDataSource);
begin
  FDataSource := Value;
  if FDataSource <> nil then
    FDataSource.FreeNotification(Self);
  SetActive(FActive);
end;

procedure TDBPanelEdit.SetActive(Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    if FActive then
    begin
      ClearControls;
      if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
      begin
        LayoutControls;
      end;
    end
    else
      ClearControls;
  end;
end;

procedure TDBPanelEdit.SetReadOnly(Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TDBPanelEdit.ClearControls;
var
  i : Integer;
  DBPanelEditControl : TDBPanelEditControl;
begin
  for i := 0 to FControls.Count - 1 do
  begin
    DBPanelEditControl := TDBPanelEditControl(FControls[i]);
    DBPanelEditControl.DBControl.Free;
    DBPanelEditControl.DBLabel.Free;
    DBPanelEditControl.Free;
  end;
  FControls.Clear;
end;

procedure TDBPanelEdit.LayoutControls;
var
  i : Integer;
  f : TField;
  DBPanelEditControl : TDBPanelEditControl;
  CurTop : Integer;
begin
  CurTop := 10;
  for i := 0 to FDataSource.DataSet.FieldCount - 1 do
  begin
    f := FDataSource.DataSet.Fields[i];
    if f.Visible then
    begin
      DBPanelEditControl := TDBPanelEditControl.Create;
      FControls.Add(DBPanelEditControl);
      DBPanelEditControl.Field := f;
      DBPanelEditControl.DBLabel := TLabel.Create(Nil);
      with DBPanelEditControl.DBLabel do begin
        parent := ScrollBox;
        Caption := f.DisplayLabel;
        Left := 10;
        Top := CurTop;
      end;
      CreateDBControl(f, DBPanelEditControl);
      DBPanelEditControl.DBControl.Left := 100;
      DBPanelEditControl.DBControl.Top := CurTop;
      CurTop := CurTop + DBPanelEditControl.DBControl.Height + 10;
    end;
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
          Width := CalculateDefaultWidth(f, Font);
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
             Width := CalculateDefaultWidth(f.LookUpDataSet.FindField(f.LookUpResultField), Font)
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

function TDBPanelEdit.CalculateDefaultWidth(f : TField; Font : TFont): Integer;
var
  RestoreCanvas: Boolean;
  TM: TTextMetric;
  h: HDC;
begin
   if(f = Nil) then begin
     Result := 100;
     exit;
   end;

   RestoreCanvas := not HandleAllocated;
   if RestoreCanvas then
     h := GetDC(0)
   else
     h := Canvas.Handle;
     
   try
     Canvas.Font := Font;
     GetTextMetrics(h, TM);
     if F.DisplayWidth < 10 then
       Result := 10 * (Canvas.TextWidth('0')) + 4
     else
       Result := f.DisplayWidth * (Canvas.TextWidth('0')) + 4;
   finally
     if RestoreCanvas then begin
       ReleaseDC(0, h);
     end;
   end;
end;

end.
