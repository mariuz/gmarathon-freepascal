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

unit KeyBindingEditor;

{$MODE Delphi}

{ The keybinding editor: every command, the key that runs it, and a way to
  change it.

  The button that opens this has been on the Options dialog since the port
  began with an empty handler, because the component it needed - TrmKeyBindings
  from rmControls - went and nothing replaced it.

  What a shortcut is called, which command owns it and which two are fighting
  over one is KeyBindings' business and is tested without a widgetset. This
  lists them, captures a keystroke, and says when the key just pressed already
  belongs to something else. }

interface

uses
  SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Grids,
  ActnList, Menus, LCLType, KeyBindings;

type
  TfrmKeyBindings = class(TForm)
    pnlTop: TPanel;
    lblFilter: TLabel;
    edFilter: TEdit;
    grdKeys: TStringGrid;
    pnlEdit: TPanel;
    lblCommand: TLabel;
    lblPress: TLabel;
    edCapture: TEdit;
    btnClear: TButton;
    lblConflict: TLabel;
    pnlButtons: TPanel;
    btnReset: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure grdKeysSelection(Sender: TObject; aCol, aRow: Integer);
    procedure edCaptureKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnClearClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  private
    FMap: TKeyMap;
    { The action name on each visible row, so a filtered list still knows which
      command a row is. Row 0 is the header. }
    FRowActions: TStringList;
    function SelectedAction: String;
    procedure RefreshGrid;
    procedure ShowConflictFor(AShortCut: Word);
  public
    { Reads every action in the list into the map, keeping what each was built
      with as its default. }
    procedure LoadFrom(AActions: TActionList);
    { Puts the map's shortcuts back onto the actions. }
    procedure ApplyTo(AActions: TActionList);
    property Map: TKeyMap read FMap;
    { Assigns a shortcut to the selected command exactly as a keystroke would,
      so the capture path is one piece of code rather than two. }
    procedure AssignToSelected(AShortCut: Word);
  end;

{ Opens the editor on an action list and applies what the user chose. Returns
  True when anything was changed, so a caller knows whether to save. }
function EditKeyBindings(AActions: TActionList): Boolean;

{ Where the bindings are kept. Beside the executable, as keybind.dat was - the
  name the original used, so an existing file is still found. }
function KeyBindingsFileName: String;

{ Applies the saved bindings, if there are any. Called at startup, before the
  main form is shown, so the menus come up with the user's own keys on them. }
procedure LoadKeyBindings(AActions: TActionList);
procedure SaveKeyBindings(AMap: TKeyMap);

implementation

{$R *.lfm}

uses LazFileUtils;

function KeyBindingsFileName: String;
begin
  Result := ExtractFilePath(Application.ExeName) + 'keybind.dat';
end;

{ Builds a map from an action list. Shared by the editor and by the startup
  load, so the two cannot disagree about what a command is called. }
function MapOf(AActions: TActionList): TKeyMap;
var
  Idx: Integer;
  Action: TContainedAction;
begin
  Result := TKeyMap.Create;
  if not Assigned(AActions) then
    Exit;
  for Idx := 0 to AActions.ActionCount - 1 do
  begin
    Action := AActions.Actions[Idx];
    if not (Action is TCustomAction) then
      Continue;
    Result.Add(Action.Name, TCustomAction(Action).Caption,
      TCustomAction(Action).Category, TCustomAction(Action).ShortCut);
  end;
end;

procedure LoadKeyBindings(AActions: TActionList);
var
  Map: TKeyMap;
  Lines: TStringList;
  Idx: Integer;
  Action: TContainedAction;
begin
  if not FileExistsUTF8(KeyBindingsFileName) then
    Exit;
  Map := MapOf(AActions);
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(KeyBindingsFileName);
    except
      { An unreadable bindings file is not worth refusing to start over. }
      on E: Exception do
        Exit;
    end;
    Map.LoadFromText(Lines.Text);
    for Idx := 0 to AActions.ActionCount - 1 do
    begin
      Action := AActions.Actions[Idx];
      if Action is TCustomAction then
        TCustomAction(Action).ShortCut := Map.ShortCutOf(Action.Name);
    end;
  finally
    Lines.Free;
    Map.Free;
  end;
end;

procedure SaveKeyBindings(AMap: TKeyMap);
var
  Lines: TStringList;
begin
  if not Assigned(AMap) then
    Exit;
  Lines := TStringList.Create;
  try
    Lines.Text := AMap.SaveToText;
    try
      if Trim(Lines.Text) = '' then
      begin
        { Nothing differs from the defaults, so there is nothing to remember -
          and leaving a stale file behind would reapply yesterday's changes. }
        if FileExistsUTF8(KeyBindingsFileName) then
          DeleteFileUTF8(KeyBindingsFileName);
      end
      else
        Lines.SaveToFile(KeyBindingsFileName);
    except
      on E: Exception do
        MessageDlg('The keyboard shortcuts could not be saved: ' + E.Message,
          mtWarning, [mbOK], 0);
    end;
  finally
    Lines.Free;
  end;
end;

function EditKeyBindings(AActions: TActionList): Boolean;
var
  F: TfrmKeyBindings;
begin
  Result := False;
  F := TfrmKeyBindings.Create(nil);
  try
    F.LoadFrom(AActions);
    if F.ShowModal <> mrOK then
      Exit;
    F.ApplyTo(AActions);
    SaveKeyBindings(F.Map);
    Result := F.Map.ChangedCount > 0;
  finally
    F.Free;
  end;
end;

procedure TfrmKeyBindings.FormCreate(Sender: TObject);
begin
  FMap := TKeyMap.Create;
  FRowActions := TStringList.Create;
  grdKeys.RowCount := 1;
  grdKeys.Cells[0, 0] := 'Command';
  grdKeys.Cells[1, 0] := 'Category';
  grdKeys.Cells[2, 0] := 'Shortcut';
end;

procedure TfrmKeyBindings.FormDestroy(Sender: TObject);
begin
  FMap.Free;
  FRowActions.Free;
end;

procedure TfrmKeyBindings.LoadFrom(AActions: TActionList);
begin
  FMap.Free;
  FMap := MapOf(AActions);
  RefreshGrid;
end;

procedure TfrmKeyBindings.ApplyTo(AActions: TActionList);
var
  Idx: Integer;
  Action: TContainedAction;
begin
  if not Assigned(AActions) then
    Exit;
  for Idx := 0 to AActions.ActionCount - 1 do
  begin
    Action := AActions.Actions[Idx];
    if Action is TCustomAction then
      TCustomAction(Action).ShortCut := FMap.ShortCutOf(Action.Name);
  end;
end;

{ A command's readable name, without the accelerator markers and trailing
  ellipsis that are noise in a list of shortcuts. }
function Readable(const ACaption, AName: String): String;
begin
  Result := StringReplace(ACaption, '&', '', [rfReplaceAll]);
  Result := Trim(Result);
  while (Length(Result) > 0) and (Result[Length(Result)] = '.') do
    Result := TrimRight(Copy(Result, 1, Length(Result) - 1));
  Result := Trim(Result);
  { An action with no caption still has to be findable, or it would appear as a
    blank row that cannot be identified. }
  if Result = '' then
    Result := AName;
end;

procedure TfrmKeyBindings.RefreshGrid;
var
  Idx, Row: Integer;
  Binding: TKeyBinding;
  Filter, Name: String;
begin
  Filter := AnsiUpperCase(Trim(edFilter.Text));
  FRowActions.Clear;
  grdKeys.RowCount := 1;
  for Idx := 0 to FMap.Count - 1 do
  begin
    Binding := FMap.Item(Idx);
    Name := Readable(Binding.Caption, Binding.ActionName);
    { The category is searched too, so someone who half-remembers which menu a
      command is under can still find it. }
    if (Filter <> '') and
       (Pos(Filter, AnsiUpperCase(Name + ' ' + Binding.Category)) = 0) then
      Continue;
    Row := grdKeys.RowCount;
    grdKeys.RowCount := Row + 1;
    grdKeys.Cells[0, Row] := Name;
    grdKeys.Cells[1, Row] := Binding.Category;
    grdKeys.Cells[2, Row] := ShortCutToStorageText(Binding.ShortCut);
    FRowActions.Add(Binding.ActionName);
  end;
end;

function TfrmKeyBindings.SelectedAction: String;
begin
  Result := '';
  { Row 0 is the header, and the grid can be left with nothing selected at
    all - a filter that matches nothing does exactly that. }
  if (grdKeys.Row >= 1) and (grdKeys.Row - 1 < FRowActions.Count) then
    Result := FRowActions[grdKeys.Row - 1];
end;

procedure TfrmKeyBindings.edFilterChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TfrmKeyBindings.grdKeysSelection(Sender: TObject; aCol, aRow: Integer);
var
  Name: String;
begin
  Name := '';
  if (aRow >= 1) and (aRow - 1 < FRowActions.Count) then
    Name := FRowActions[aRow - 1];
  if Name = '' then
  begin
    lblCommand.Caption := '';
    edCapture.Text := '';
    lblConflict.Caption := '';
    Exit;
  end;
  lblCommand.Caption := grdKeys.Cells[0, aRow];
  edCapture.Text := ShortCutToStorageText(FMap.ShortCutOf(Name));
  ShowConflictFor(FMap.ShortCutOf(Name));
end;

procedure TfrmKeyBindings.ShowConflictFor(AShortCut: Word);
var
  Conflicts: TStringList;
begin
  lblConflict.Caption := '';
  if SelectedAction = '' then
    Exit;
  Conflicts := FMap.ConflictsFor(SelectedAction, AShortCut);
  try
    { Named rather than merely counted: "already in use" leaves the user
      hunting for what it is in use by. }
    if Conflicts.Count > 0 then
      lblConflict.Caption := 'Already used by ' +
        StringReplace(Conflicts.Text, #13#10, ', ', [rfReplaceAll]);
    while (Length(lblConflict.Caption) > 0) and
          (lblConflict.Caption[Length(lblConflict.Caption)] in [',', ' ']) do
      lblConflict.Caption := Copy(lblConflict.Caption, 1,
        Length(lblConflict.Caption) - 1);
  finally
    Conflicts.Free;
  end;
end;

procedure TfrmKeyBindings.AssignToSelected(AShortCut: Word);
var
  Name: String;
begin
  Name := SelectedAction;
  if Name = '' then
    Exit;
  FMap.Assign_(Name, AShortCut);
  edCapture.Text := ShortCutToStorageText(AShortCut);
  grdKeys.Cells[2, grdKeys.Row] := edCapture.Text;
  { Shown, not refused. Two commands on one key is a mistake, but which of them
    should move is the user's decision, and refusing the keystroke would make
    swapping two shortcuts impossible. }
  ShowConflictFor(AShortCut);
end;

procedure TfrmKeyBindings.edCaptureKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  SC: Word;
begin
  { A modifier on its own is half a keystroke - the user is still pressing.
    Swallowed so it does not clear what is there. }
  if Key in [VK_SHIFT, VK_CONTROL, VK_MENU, VK_LWIN, VK_RWIN] then
  begin
    Key := 0;
    Exit;
  end;

  SC := Key;
  if ssCtrl in Shift then
    SC := SC or kbCtrl;
  if ssShift in Shift then
    SC := SC or kbShift;
  if ssAlt in Shift then
    SC := SC or kbAlt;

  { Only shortcuts this build can write down, or it would be saved as nothing
    and silently lost on the next start. }
  if ShortCutToStorageText(SC) = '' then
  begin
    Key := 0;
    Exit;
  end;

  AssignToSelected(SC);
  { Swallowed so the edit box does not also type the character. }
  Key := 0;
end;

procedure TfrmKeyBindings.btnClearClick(Sender: TObject);
begin
  AssignToSelected(kbNone);
end;

procedure TfrmKeyBindings.btnResetClick(Sender: TObject);
begin
  if MessageDlg('Reset shortcuts',
    'Put every keyboard shortcut back to what it was built with?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  FMap.ResetAll;
  RefreshGrid;
  lblConflict.Caption := '';
  edCapture.Text := '';
end;

end.
