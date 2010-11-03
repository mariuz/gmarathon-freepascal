unit CloseUpCombo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TCloseUpCustomComboBox = class(TCustomComboBox)
  private
    FBeepOnInvalidKey : Boolean;
    FSearchString : string;
    FOnCloseUp : TNotifyEvent;
    procedure WMKeyDown(var Msg : TWMKeyDown); message wm_KeyDown;
    procedure WMChar(var Msg : TWMChar); message wm_Char;
    procedure WMCut(var Msg : TMessage); message wm_Cut;
    procedure WMPaste(var Msg : TMessage); message wm_Paste;
    procedure WMKillFocus(var Msg : TWMKillFocus); message wm_KillFocus;
    procedure CNCommand(var Msg : TWMCommand); message cn_Command;
    function GetSelLength : Integer;
    procedure SetSelLength(Value : Integer);
    function GetSelStart : Integer;
    procedure SetSelStart(Value : Integer);
  protected
    function FindClosest(const S : string) : Integer; virtual;
    procedure ComboWndProc(var Msg : TMessage; ComboWnd : HWnd; ComboProc : Pointer); override;
    procedure UpdateSearchStr;
    procedure CloseUp; dynamic;
    property OnCloseUp : TNotifyEvent read FOnCloseUp write FOnCloseUp;
  public
    constructor Create(AOwner : TComponent); override;

    property BeepOnInvalidKey : Boolean read FBeepOnInvalidKey write FBeepOnInvalidKey default True;
    property SearchString : string read FSearchString;
    property SelLength : Integer read GetSelLength write SetSelLength;
    property SelStart : Integer read GetSelStart write SetSelStart;
  end;


  TCloseUpCombo = class(TCloseUpCustomComboBox)
  private

  published
    property BeepOnInvalidKey;
    property Style;
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;

    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDrag;
    property ImeMode;
    property ImeName;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
  end;


procedure Register;


implementation

constructor TCloseUpCustomComboBox.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FBeepOnInvalidKey := True;
  FSearchString := '';
end;


{= wm_KeyDown is generated only when ComboBox has csDropDownList style =}

procedure TCloseUpCustomComboBox.WMKeyDown(var Msg : TWMKeyDown);
begin
  if Msg.CharCode in [vk_Escape, vk_Prior..vk_Down] then
    FSearchString := '';
  inherited;
end;


function TCloseUpCustomComboBox.FindClosest(const S : string) : Integer;
var
  T : string;
begin
  if Length(S) = 0 then
  begin
    Result := -1;
    Exit;
  end;

  for Result := 0 to Items.Count - 1 do
  begin
    T := Copy(Items[Result], 1, Length(S));
    if AnsiCompareText(T, S) = 0 then
      Exit;
  end;
  Result := -1;
end;


{= wm_Char is generated only when ComboBox has csDropDownList style =}

procedure TCloseUpCustomComboBox.WMChar(var Msg : TWMChar);
var
  TempStr : string;
  Index : Integer;

  procedure UpdateIndex;
  begin
    Index := FindClosest(TempStr);
    if Index <> -1 then
    begin
      ItemIndex := Index;
      FSearchString := TempStr;
      Click; {!!}
      Change;
      DoKeyPress(Msg);
    end
    else
      if FBeepOnInvalidKey then
        MessageBeep(0);
  end;


begin
  TempStr := FSearchString;

  case Msg.CharCode of
    vk_Back :
      begin
        if Length(TempStr) > 0 then
        begin
          Delete(TempStr, Length(TempStr), 1);
          if Length(TempStr) = 0 then
          begin
            ItemIndex := -1;
            Click; {!!}
            Change;
            FSearchString := '';
            DoKeyPress(Msg);
            Exit;
          end;
        end
        else
          if FBeepOnInvalidKey then
            MessageBeep(0);

        UpdateIndex;
      end;

    vk_Escape :
      begin
        ItemIndex := -1;
        Click; {!!}
        Change;
      end;

    32..255 :
      begin
        TempStr := TempStr + Char(Msg.CharCode);
        UpdateIndex;
      end;
  end;
end;


{= ComboWndProc has keyboard actions when Style is csSimple or csDropDown =}

procedure TCloseUpCustomComboBox.ComboWndProc(var Msg : TMessage; ComboWnd : HWnd;
  ComboProc : Pointer);
var
  TempStr, OldSearchString : string;
  OldSelStart : Integer; {!! Add}

  function Max(A, B : Integer) : Integer;
  begin
    if A > B then
      Result := A
    else
      Result := B;
  end;

  function FindListItem(const S : string) : Boolean;
  var
    Index : Integer;
  begin
    Index := FindClosest(FSearchString);
    if Index <> -1 then
    begin
      ItemIndex := Index;
      Click; {!!}
      Change;
      DoKeyPress(TWMKey(Msg));

      SelStart := Length(FSearchString);
      SelLength := Length(Items[ItemIndex]) - SelStart;

      Result := True;
    end
    else
      Result := False;
  end;

begin {= TCloseUpCustomComboBox.ComboWndProd =}
  case Msg.Msg of
    wm_LButtonDown :
      begin
        if Style = csDropDown then
          FSearchString := Text;
      end;

    wm_Char :
      begin
        TempStr := FSearchString;

        case Msg.WParam of
          vk_Back :
            begin
              if Length(TempStr) > 0 then
              begin
                if SelStart >= Length(FSearchString) then
                  Delete(TempStr, SelStart, 1)
                else
                  if SelLength > 0 then
                    Delete(TempStr, SelStart + 1, SelLength)
                  else
                    Delete(TempStr, SelStart, 1);
                Change;
                if Length(TempStr) = 0 then
                begin
                  ItemIndex := -1;
                  FSearchString := '';
                  Click; {!!}
                  Change;
                  DoKeyPress(TWMKey(Msg));
                end;
              end
              else
                if FBeepOnInvalidKey then
                  MessageBeep(0);

              FSearchString := TempStr;
              if FindListItem(FSearchString) then
                Exit;

            end; { vk_Back }

          vk_Escape :
            begin
              ItemIndex := -1;
              FSearchString := '';
              Click; {!!}
              Change;
              DoKeyPress(TWMKey(Msg));
              Exit;
            end;

          32..255 :
            begin
          { Invoke any user defined OnKeyPress handlers }
              DoKeyPress(TWMKey(Msg));
          { Then use new character }
              if Msg.WParam in [32..255] then
              begin
            { If text is selected, it will be erased when new char is inserted.
              Therefore, delete the selected text from the search string }
                if SelLength > 0 then
                  Delete(FSearchString, SelStart + 1, SelLength);

                OldSearchString := FSearchString;
                Insert(Char(Msg.WParam), FSearchString, SelStart + 1);
                Change;
                if FindListItem(FSearchString) then
                  Exit
                else
                begin
                  OldSelStart := SelStart; {!! Add }
                  Text := OldSearchString;
              {SelStart := Length( OldSearchString );}{!! Remove}
                  SelStart := OldSelStart; {!! Add}
                  SelLength := 0;
                end;
              end;
            end;
        end;
      end; { wm_Char }

    wm_KeyDown :
      begin
        case Msg.WParam of
          vk_Delete :
            begin
              FSearchString := Text;
              Delete(FSearchString, SelStart + 1, Max(SelLength, 1));
          (*  !!Remove this so that substring can be entered in
          if FindListItem( FSearchString ) then
            Exit;
            *)
            end;

          vk_End, vk_Home, vk_Left, vk_Right :
            begin
              FSearchString := Text;
            end;

          vk_Prior, vk_Next, vk_Up, vk_Down :
            begin
              FSearchString := '';
            end;
        end; { case }
      end; { wm_KeyDown }

  end;

  inherited ComboWndProc(Msg, ComboWnd, ComboProc);

  { Handle Ctrl+V and Ctrl+X combinations }
  if (Msg.Msg = wm_Char) and
    ((Msg.WParam = 22) or (Msg.WParam = 24)) then
  begin
    FSearchString := Text;
    FindListItem(FSearchString);
  end;

end; {= TCloseUpCustomComboBox.ComboWndProc =}


procedure TCloseUpCustomComboBox.UpdateSearchStr;
var
  Index : Integer;
begin
  if Style = csDropDown then
  begin
//    SelStart := Length( FSearchString );
//    SelLength := Length( Text ) - SelStart;
    FSearchString := Text;

    Index := FindClosest(FSearchString);
    if Index <> -1 then
    begin
      ItemIndex := Index;

      SelStart := Length(FSearchString);
      SelLength := Length(Items[ItemIndex]) - SelStart;
    end;
  end;
end;


procedure TCloseUpCustomComboBox.WMCut(var Msg : TMessage);
begin
  UpdateSearchStr;
  inherited;
end;


procedure TCloseUpCustomComboBox.WMPaste(var Msg : TMessage);
begin
  inherited;
  UpdateSearchStr;
end;


procedure TCloseUpCustomComboBox.WMKillFocus(var Msg : TWMKillFocus);
begin
  inherited;
  FSearchString := '';
end;


procedure TCloseUpCustomComboBox.CNCommand(var Msg : TWMCommand);
begin
  inherited;
  if Msg.NotifyCode = cbn_CloseUp then
    CloseUp;
end;


procedure TCloseUpCustomComboBox.CloseUp;
begin
  if Assigned(FOnCloseUp) then
    FOnCloseUp(Self);
end;


function TCloseUpCustomComboBox.GetSelStart : Integer;
begin
  SendMessage(Handle, cb_GetEditSel, Longint(@Result), 0);
end;


procedure TCloseUpCustomComboBox.SetSelStart(Value : Integer);
begin
  SendMessage(Handle, cb_SetEditSel, 0, MakeLParam(Value, Value));
end;


function TCloseUpCustomComboBox.GetSelLength : Integer;
var
  StartPos, EndPos : Integer;
begin
  StartPos := 0;
  EndPos := 0;
  SendMessage(Handle, cb_GetEditSel, Longint(@StartPos), Longint(@EndPos));
  Result := EndPos - StartPos;
end;


procedure TCloseUpCustomComboBox.SetSelLength(Value : Integer);
var
  StartPos, EndPos : Integer;
begin
  StartPos := GetSelStart;
  EndPos := StartPos + Value;
  SendMessage(Handle, cb_SetEditSel, 0, MakeLParam(StartPos, EndPos));
end;


procedure Register;
begin
  RegisterComponents('GSS', [TCloseUpCombo]);
end;

end.

