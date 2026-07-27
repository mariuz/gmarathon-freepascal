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

unit CommandPaletteDialog;

{$MODE Delphi}

{ Ctrl+Shift+P: find a command by typing part of its name.

  Every command Marathon has is already a TAction with a caption and a
  category, so this needs no list of its own - it reads the action lists it is
  given. What a query matches is decided in the LCL-free CommandPalette unit,
  which is where those rules are tested.

  Commands that cannot run right now are listed but not offered: an action is
  disabled because its document or connection is not there, and hiding it would
  leave someone hunting for a command that exists. It is shown greyed with the
  reason implicit, and Enter on it does nothing. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Controls, Forms, StdCtrls, ActnList, Graphics,
  CommandPalette;

type
  TfrmCommandPalette = class(TForm)
    edQuery: TEdit;
    lstCommands: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure edQueryChange(Sender: TObject);
    procedure edQueryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lstCommandsDblClick(Sender: TObject);
    procedure lstCommandsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    FActions: TList;
    procedure Repopulate;
  public
    destructor Destroy; override;
    { Adds every action of a list to what the palette can find. Called once per
      action list before showing. }
    procedure AddActions(AList: TCustomActionList);
    { The action the user chose, or nil. }
    function ChosenAction: TCustomAction;
    { How many commands the current query leaves - exposed so the filtering can
      be checked without driving the list box. }
    function VisibleCount: Integer;
    { Runs the chosen command if it can run. True when something was executed. }
    function ExecuteChosen: Boolean;
  end;

implementation

{$R *.lfm}

procedure TfrmCommandPalette.FormCreate(Sender: TObject);
begin
  FActions := TList.Create;
  lstCommands.Style := lbOwnerDrawFixed;
end;

destructor TfrmCommandPalette.Destroy;
begin
  FActions.Free;
  inherited Destroy;
end;

procedure TfrmCommandPalette.AddActions(AList: TCustomActionList);
var
  Idx: Integer;
begin
  if not Assigned(AList) then
    Exit;
  for Idx := 0 to AList.ActionCount - 1 do
    if AList.Actions[Idx] is TCustomAction then
    begin
      { An action with no caption has nothing to type against and nothing to
        show, so it is not a command as far as this is concerned. }
      if CommandDisplayName(TCustomAction(AList.Actions[Idx]).Caption) <> '' then
        FActions.Add(AList.Actions[Idx]);
    end;
  Repopulate;
end;

procedure TfrmCommandPalette.Repopulate;
var
  Idx, Rank, Best, BestAt, Placed: Integer;
  Action: TCustomAction;
  Label_: String;
  Taken: array of Boolean;
begin
  lstCommands.Items.BeginUpdate;
  try
    lstCommands.Items.Clear;
    SetLength(Taken, FActions.Count);
    { Selection sort by rank: the list is a few hundred entries at most, and
      keeping it obvious is worth more here than being clever. }
    Placed := 0;
    repeat
      Best := 0;
      BestAt := -1;
      for Idx := 0 to FActions.Count - 1 do
      begin
        if Taken[Idx] then
          Continue;
        Action := TCustomAction(FActions[Idx]);
        Rank := CommandRank(edQuery.Text, Action.Caption, Action.Category);
        if Rank > Best then
        begin
          Best := Rank;
          BestAt := Idx;
        end;
      end;
      if BestAt < 0 then
        Break;
      Taken[BestAt] := True;
      Action := TCustomAction(FActions[BestAt]);
      { The category is shown beside the name, since two menus can reasonably
        hold commands of the same name. }
      Label_ := CommandDisplayName(Action.Caption);
      if Trim(Action.Category) <> '' then
        Label_ := Label_ + '   (' + Trim(Action.Category) + ')';
      lstCommands.Items.AddObject(Label_, Action);
      Inc(Placed);
    until Placed >= FActions.Count;
    if lstCommands.Items.Count > 0 then
      lstCommands.ItemIndex := 0;
  finally
    lstCommands.Items.EndUpdate;
  end;
end;

procedure TfrmCommandPalette.edQueryChange(Sender: TObject);
begin
  Repopulate;
end;

procedure TfrmCommandPalette.edQueryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  { The list is driven from the query box, so the arrows have to reach it
    without the user leaving what they are typing. }
  case Key of
    VK_DOWN:
      if lstCommands.ItemIndex < lstCommands.Items.Count - 1 then
      begin
        lstCommands.ItemIndex := lstCommands.ItemIndex + 1;
        Key := 0;
      end;
    VK_UP:
      if lstCommands.ItemIndex > 0 then
      begin
        lstCommands.ItemIndex := lstCommands.ItemIndex - 1;
        Key := 0;
      end;
    VK_RETURN:
      begin
        if ExecuteChosen then
          ModalResult := mrOK;
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        ModalResult := mrCancel;
        Key := 0;
      end;
  end;
end;

procedure TfrmCommandPalette.lstCommandsDblClick(Sender: TObject);
begin
  if ExecuteChosen then
    ModalResult := mrOK;
end;

procedure TfrmCommandPalette.lstCommandsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Action: TCustomAction;
begin
  if (Index < 0) or (Index >= lstCommands.Items.Count) then
    Exit;
  Action := TCustomAction(lstCommands.Items.Objects[Index]);
  with lstCommands.Canvas do
  begin
    FillRect(ARect);
    { A command that cannot run now is still worth showing - hiding it leaves
      someone hunting for something that exists - but it is drawn greyed so it
      does not look like a choice. }
    if Assigned(Action) and not Action.Enabled then
      Font.Color := clGrayText;
    TextOut(ARect.Left + 4, ARect.Top + 1, lstCommands.Items[Index]);
  end;
end;

function TfrmCommandPalette.ChosenAction: TCustomAction;
begin
  Result := nil;
  if (lstCommands.ItemIndex >= 0) and
     (lstCommands.ItemIndex < lstCommands.Items.Count) then
    Result := TCustomAction(lstCommands.Items.Objects[lstCommands.ItemIndex]);
end;

function TfrmCommandPalette.VisibleCount: Integer;
begin
  Result := lstCommands.Items.Count;
end;

function TfrmCommandPalette.ExecuteChosen: Boolean;
var
  Action: TCustomAction;
begin
  Result := False;
  Action := ChosenAction;
  if not Assigned(Action) or not Action.Enabled then
    Exit;
  Action.Execute;
  Result := True;
end;

end.
