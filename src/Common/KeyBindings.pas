{******************************************************************}
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}

unit KeyBindings;

{$MODE Delphi}

{ Which keys run which commands.

  Marathon's keybindings were TrmKeyBindings, an rmControls component that went
  during the port. What was left is a bare TComponent called kbgKeys, a
  keybind.dat loader compiled out with $IFNDEF FPC, and an Edit Keys button
  whose handler is empty - so shortcuts have been whatever each action carries
  in its .lfm, with no way to see them all or change any.

  This is the part that decides things: what a shortcut is called when written
  down, which command a key belongs to, and which two commands are fighting
  over the same key. No LCL, so it is tested without a widgetset.

  The text form is deliberately this unit's own rather than the LCL's
  ShortCutToText. That function is translated - on a German build Ctrl comes
  back as Strg - so a file written on one machine would not load on another,
  and a user changing their language would silently lose every binding. The
  numeric form is the LCL's, because it is what TAction.ShortCut takes. }

interface

uses SysUtils, Classes;

const
  { The LCL's modifier bits, so a value from here can be assigned straight to
    TAction.ShortCut. Repeated rather than imported to keep this unit free of
    the LCL; the test checks they still agree. }
  kbShift = $2000;
  kbCtrl  = $4000;
  kbAlt   = $8000;
  kbNone  = 0;

type
  TKeyBinding = record
    { The action's Name, which is what the map is keyed on. Captions change
      with wording and translation; names do not. }
    ActionName: String;
    { What the user sees in a menu, kept so an editor can list commands
      readably without holding the action itself. }
    Caption: String;
    Category: String;
    ShortCut: Word;
    { What the action was built with, so "reset" means something and so only
      what was actually changed need be saved. }
    DefaultShortCut: Word;
  end;

  TKeyMap = class
  private
    FItems: array of TKeyBinding;
    function IndexOfName(const AName: String): Integer;
  public
    { Records a command and the shortcut it came with. Called once per action
      while the map is being built from the action list. }
    procedure Add(const AActionName, ACaption, ACategory: String;
      ADefault: Word);
    function Count: Integer;
    function Item(Index: Integer): TKeyBinding;

    function ShortCutOf(const AActionName: String): Word;
    procedure Assign_(const AActionName: String; AShortCut: Word);
    { Puts every command back to the shortcut it was built with. }
    procedure ResetAll;
    function IsChanged(const AActionName: String): Boolean;
    function ChangedCount: Integer;

    { The commands other than AActionName that already use AShortCut.

      A shortcut can only run one command, so two commands holding the same one
      means one of them silently never fires. An editor has to be able to say
      which - hence the names rather than a yes or no. kbNone conflicts with
      nothing: any number of commands may have no shortcut at all. }
    function ConflictsFor(const AActionName: String; AShortCut: Word): TStringList;

    { Only what differs from the defaults, as 'ActionName=Ctrl+Shift+P' lines.
      Saving only the differences means a command whose built-in shortcut
      changes in a later build picks the new one up, instead of being pinned
      forever by a file that recorded the old one. }
    function SaveToText: String;
    { Applies stored lines. Unknown names are ignored rather than rejected: a
      binding for a command that no longer exists is stale, not a reason to
      refuse the whole file. }
    procedure LoadFromText(const AText: String);
  end;

{ 'Ctrl+Shift+P'. Stable across locales and builds, because it is written
  here. }
function ShortCutToStorageText(AShortCut: Word): String;

{ The reverse. Returns kbNone for anything it cannot read, so a corrupt line
  clears that binding rather than throwing. }
function StorageTextToShortCut(const AText: String): Word;

implementation

type
  TKeyName = record
    Code: Word;
    Name: String;
  end;

const
  { The keys worth naming. Letters and digits are handled by their character,
    so only the ones with no printable form are listed. }
  KeyNames: array[0..28] of TKeyName = (
    (Code: $08; Name: 'BkSp'),   (Code: $09; Name: 'Tab'),
    (Code: $0D; Name: 'Enter'),  (Code: $1B; Name: 'Esc'),
    (Code: $20; Name: 'Space'),  (Code: $21; Name: 'PgUp'),
    (Code: $22; Name: 'PgDn'),   (Code: $23; Name: 'End'),
    (Code: $24; Name: 'Home'),   (Code: $25; Name: 'Left'),
    (Code: $26; Name: 'Up'),     (Code: $27; Name: 'Right'),
    (Code: $28; Name: 'Down'),   (Code: $2D; Name: 'Ins'),
    (Code: $2E; Name: 'Del'),
    (Code: $70; Name: 'F1'),     (Code: $71; Name: 'F2'),
    (Code: $72; Name: 'F3'),     (Code: $73; Name: 'F4'),
    (Code: $74; Name: 'F5'),     (Code: $75; Name: 'F6'),
    (Code: $76; Name: 'F7'),     (Code: $77; Name: 'F8'),
    (Code: $78; Name: 'F9'),     (Code: $79; Name: 'F10'),
    (Code: $7A; Name: 'F11'),    (Code: $7B; Name: 'F12'),
    (Code: $2C; Name: 'PrtSc'),  (Code: $13; Name: 'Pause'));

function KeyCodeName(ACode: Word): String;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := Low(KeyNames) to High(KeyNames) do
    if KeyNames[Idx].Code = ACode then
      Exit(KeyNames[Idx].Name);
  { Letters and digits stand for themselves. }
  if ((ACode >= Ord('A')) and (ACode <= Ord('Z'))) or
     ((ACode >= Ord('0')) and (ACode <= Ord('9'))) then
    Result := Chr(ACode);
end;

function NameKeyCode(const AName: String): Word;
var
  Idx: Integer;
  N: String;
begin
  Result := 0;
  N := Trim(AName);
  if N = '' then
    Exit;
  for Idx := Low(KeyNames) to High(KeyNames) do
    if SameText(KeyNames[Idx].Name, N) then
      Exit(KeyNames[Idx].Code);
  if Length(N) = 1 then
  begin
    N := AnsiUpperCase(N);
    if ((N[1] >= 'A') and (N[1] <= 'Z')) or ((N[1] >= '0') and (N[1] <= '9')) then
      Result := Ord(N[1]);
  end;
end;

function ShortCutToStorageText(AShortCut: Word): String;
var
  KeyPart: String;
begin
  Result := '';
  if AShortCut = kbNone then
    Exit;
  KeyPart := KeyCodeName(AShortCut and not (kbShift or kbCtrl or kbAlt));
  { A modifier with no key is not a shortcut - Ctrl on its own runs nothing -
    so it comes back as no shortcut rather than as 'Ctrl+'. }
  if KeyPart = '' then
    Exit;
  { A fixed order, so the same shortcut always writes the same way and two
    files can be compared. }
  if AShortCut and kbCtrl <> 0 then
    Result := Result + 'Ctrl+';
  if AShortCut and kbShift <> 0 then
    Result := Result + 'Shift+';
  if AShortCut and kbAlt <> 0 then
    Result := Result + 'Alt+';
  Result := Result + KeyPart;
end;

function StorageTextToShortCut(const AText: String): Word;
var
  Parts: TStringList;
  Idx: Integer;
  Part: String;
  Code: Word;
begin
  Result := kbNone;
  if Trim(AText) = '' then
    Exit;
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := '+';
    Parts.DelimitedText := Trim(AText);
    Code := 0;
    for Idx := 0 to Parts.Count - 1 do
    begin
      Part := Trim(Parts[Idx]);
      if SameText(Part, 'Ctrl') then
        Result := Result or kbCtrl
      else if SameText(Part, 'Shift') then
        Result := Result or kbShift
      else if SameText(Part, 'Alt') then
        Result := Result or kbAlt
      else if Part <> '' then
        Code := NameKeyCode(Part);
    end;
    if Code = 0 then
      { Modifiers with no key, or a key name nothing recognises. Neither is a
        shortcut, and returning the bare modifiers would make one that can
        never be pressed. }
      Result := kbNone
    else
      Result := Result or Code;
  finally
    Parts.Free;
  end;
end;

function TKeyMap.IndexOfName(const AName: String): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  for Idx := 0 to High(FItems) do
    if SameText(FItems[Idx].ActionName, AName) then
      Exit(Idx);
end;

procedure TKeyMap.Add(const AActionName, ACaption, ACategory: String;
  ADefault: Word);
var
  At: Integer;
begin
  if Trim(AActionName) = '' then
    Exit;
  At := IndexOfName(AActionName);
  if At < 0 then
  begin
    At := Length(FItems);
    SetLength(FItems, At + 1);
  end;
  FItems[At].ActionName := AActionName;
  FItems[At].Caption := ACaption;
  FItems[At].Category := ACategory;
  FItems[At].ShortCut := ADefault;
  FItems[At].DefaultShortCut := ADefault;
end;

function TKeyMap.Count: Integer;
begin
  Result := Length(FItems);
end;

function TKeyMap.Item(Index: Integer): TKeyBinding;
begin
  Result := FItems[Index];
end;

function TKeyMap.ShortCutOf(const AActionName: String): Word;
var
  At: Integer;
begin
  Result := kbNone;
  At := IndexOfName(AActionName);
  if At >= 0 then
    Result := FItems[At].ShortCut;
end;

procedure TKeyMap.Assign_(const AActionName: String; AShortCut: Word);
var
  At: Integer;
begin
  At := IndexOfName(AActionName);
  if At >= 0 then
    FItems[At].ShortCut := AShortCut;
end;

procedure TKeyMap.ResetAll;
var
  Idx: Integer;
begin
  for Idx := 0 to High(FItems) do
    FItems[Idx].ShortCut := FItems[Idx].DefaultShortCut;
end;

function TKeyMap.IsChanged(const AActionName: String): Boolean;
var
  At: Integer;
begin
  Result := False;
  At := IndexOfName(AActionName);
  if At >= 0 then
    Result := FItems[At].ShortCut <> FItems[At].DefaultShortCut;
end;

function TKeyMap.ChangedCount: Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to High(FItems) do
    if FItems[Idx].ShortCut <> FItems[Idx].DefaultShortCut then
      Inc(Result);
end;

function TKeyMap.ConflictsFor(const AActionName: String;
  AShortCut: Word): TStringList;
var
  Idx: Integer;
begin
  Result := TStringList.Create;
  { Any number of commands may have no shortcut, so nothing conflicts with
    nothing. }
  if AShortCut = kbNone then
    Exit;
  for Idx := 0 to High(FItems) do
    if not SameText(FItems[Idx].ActionName, AActionName) and
       (FItems[Idx].ShortCut = AShortCut) then
      Result.Add(FItems[Idx].ActionName);
end;

function TKeyMap.SaveToText: String;
var
  Idx: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    for Idx := 0 to High(FItems) do
      if FItems[Idx].ShortCut <> FItems[Idx].DefaultShortCut then
        { An empty value is meaningful: it records a shortcut deliberately
          cleared, which is different from one never changed. }
        Lines.Add(FItems[Idx].ActionName + '=' +
          ShortCutToStorageText(FItems[Idx].ShortCut));
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TKeyMap.LoadFromText(const AText: String);
var
  Lines: TStringList;
  Idx, At, Eq: Integer;
  Name, Value: String;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    for Idx := 0 to Lines.Count - 1 do
    begin
      Eq := Pos('=', Lines[Idx]);
      if Eq < 2 then
        Continue;
      Name := Trim(Copy(Lines[Idx], 1, Eq - 1));
      Value := Trim(Copy(Lines[Idx], Eq + 1, MaxInt));
      At := IndexOfName(Name);
      { A binding for a command that no longer exists is stale, not an error. }
      if At >= 0 then
        FItems[At].ShortCut := StorageTextToShortCut(Value);
    end;
  finally
    Lines.Free;
  end;
end;

end.
