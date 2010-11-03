unit Dbvalcb;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Menus, Dialogs, StdCtrls, DB, DBCtrls;

type
  TDBValComboBox = class(TComboBox)
  private
    FDataLink: TFieldDataLink;
    FValue: PString;
    FValues: TStrings;
    FOnChange: TNotifyEvent;
    procedure UpdateData(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    function GetValue: string;
    function GetButtonValue(Index: Integer): string;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure SetValue(const Value: string);
    procedure SetValues(Value: TStrings);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    procedure Change; dynamic;
    procedure Click; override;
    procedure DropDown; override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    property DataLink: TFieldDataLink read FDataLink;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DataChange(Sender: TObject);
    property Field: TField read GetField;
    property Value: string read GetValue write SetValue;
    property ItemIndex;

  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Values: TStrings read FValues write SetValues;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;


implementation

constructor TDBValComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FValue  := NullStr;
  FValues := TStringList.Create;
  style   := csDropDownList;
end;

destructor TDBValComboBox.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  DisposeStr (FValue);
  FValues.Free;
  inherited Destroy;
end;

procedure TDBValComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TDBValComboBox.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    ItemIndex := FValues.IndexOf(FDataLink.Field.Text) else
   ItemIndex := -1;
end;

procedure TDBValComboBox.UpdateData(Sender: TObject);
begin
  if items.IndexOf(Text)<>-1 then
    FDataLink.Field.Text := FValues[items.IndexOf(Text)]
  else
    FDataLink.Field.Text := '';
end;

function TDBValComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBValComboBox.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TDBValComboBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBValComboBox.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBValComboBox.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TDBValComboBox.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TDBValComboBox.GetField: TField;
begin
  Result := FDataLink.Field;
end;

function TDBValComboBox.GetValue : string;
begin
  Result := FValue^;
end;

function TDBValComboBox.GetButtonValue(Index: Integer): string;
begin
  if (Index < FValues.Count) and (FValues[Index] <> '') then
    Result := FValues[Index]
  else if (Index < Items.Count) then
    Result := Items[Index]
  else
    Result := '';
end;

procedure TDBValComboBox.SetValue (const Value: string);
var
  I : Integer;
begin
  AssignStr(FValue, Value);
  if (ItemIndex < 0) or (GetButtonValue(ItemIndex) <> Value) then
  begin
    if (ItemIndex >= 0) then ItemIndex := -1;
    for I := 0 to Items.Count - 1 do
    begin
      if GetButtonValue(I) = Value then
      begin
        ItemIndex := I;
        break;
      end;
    end;
    Change;
  end;
end;

procedure TDBValComboBox.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TDBValComboBox.Click;
begin
  if FDataLink.Edit then
  begin
   inherited Click;
   FDataLink.Modified;
  end;
end;

procedure TDBValComboBox.DropDown;
begin
  FDataLink.Edit;
  inherited DropDown;
end;

procedure TDBValComboBox.SetValues(Value: TStrings);
begin
  FValues.Assign(Value);
  DataChange(Self);
end;

procedure TDBValComboBox.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TDBValComboBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  case Key of
    #32..#255:
      if not FDataLink.Edit then Key := #0;
    #27:
      FDataLink.Reset;
  end;
end;

procedure Register;
begin
  RegisterComponents('Data Controls', [TDBValComboBox]);
end;

end.
