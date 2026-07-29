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

unit CommandBar;

{$MODE Delphi}

{ One toolbar that shows what the thing in front of you can do.

  The shell used to carry four toolbars at once - Standard, Tools, Script and
  SQL Editor, 27 buttons - all visible whatever was open and whatever it could
  accept. Most of them did not apply: Commit and Rollback sat beside Print
  Preview and a Query Builder while a table editor was in front, and the one
  button being reached for was somewhere among them.

  This is the other arrangement, the one every modern editor settles on: a
  short bar of what applies now, and everything else a search away. The bar
  rebuilds itself when the active document changes, and Ctrl+Shift+P still
  reaches all 181 actions by name.

  Nothing here decides what an action does or whether it is enabled - the
  actions do that themselves, as they always have. This only decides which of
  them are worth a button, which is a layout question and belongs in one
  place rather than spread across four .lfm sections.

  The old toolbars are not deleted, only hidden, and the View menu still
  toggles them: someone who wants the 27 buttons back can have them. }

interface

uses SysUtils, Classes, Controls, ComCtrls, ActnList, ImgList,
  MarathonInternalInterfaces, MarathonProjectCacheTypes;

type
  { What is in front of the user, which is what decides the buttons. Deliberately
    coarser than the form class: two editors that accept the same commands want
    the same bar. }
  TCommandContext = (
    { Nothing open, or something that is not a document. }
    ccShell,
    { The SQL editor - a statement to run, and a transaction to end. }
    ccSQLEditor,
    { An object editor: a definition to compile and apply. }
    ccObjectEditor);

  TMarathonCommandBar = class(TComponent)
  private
    FBar: TToolBar;
    FContext: TCommandContext;
    FActions: TActionList;
    FBuilt: Boolean;
    function ActionNamed(const AName: String): TAction;
    procedure AddButton(const AActionName: String);
    procedure AddSeparator;
    procedure Rebuild(AContext: TCommandContext);
  public
    { AParent is where the bar lives, AActions the shell's list - every button
      is bound to an action already on it, by name, so a renamed or removed
      action loses its button rather than breaking the build. }
    constructor Create(AOwner: TComponent; AParent: TWinControl;
      AActions: TActionList; AImages: TCustomImageList); reintroduce;
    { Point it at the active document. Cheap to call repeatedly: the bar is
      only rebuilt when the context actually changes. }
    procedure ShowFor(AForm: IMarathonForm);
    property Bar: TToolBar read FBar;
    property Context: TCommandContext read FContext;
  end;

{ Which bar a document wants. Public so it can be checked without a widgetset. }
function ContextOf(AForm: IMarathonForm): TCommandContext;

implementation

function ContextOf(AForm: IMarathonForm): TCommandContext;
var
  SQLForm: IMarathonSQLForm;
begin
  Result := ccShell;
  if not Assigned(AForm) then
    Exit;
  { The SQL editor is the one that answers this interface, which is a better
    question than its class name - anything that runs statements the same way
    should get the same bar. }
  if Supports(AForm, IMarathonSQLForm, SQLForm) then
    Result := ccSQLEditor
  else
    { Everything else that is about one database object. A document with no
      object - the preview, the trace window - is shell chrome as far as this
      bar is concerned. }
    if AForm.GetActiveObjectType <> ctDontCare then
      Result := ccObjectEditor;
end;

constructor TMarathonCommandBar.Create(AOwner: TComponent; AParent: TWinControl;
  AActions: TActionList; AImages: TCustomImageList);
begin
  inherited Create(AOwner);
  FActions := AActions;
  FBar := TToolBar.Create(Self);
  FBar.Parent := AParent;
  FBar.Align := alTop;
  FBar.Images := AImages;
  FBar.ShowHint := True;
  FBar.ParentShowHint := False;
  { Flat and without a raised edge: the four it replaces each drew their own
    border, which is most of why the top of the window looked like a stack. }
  FBar.Flat := True;
  FBar.EdgeBorders := [];
  FContext := ccShell;
  FBuilt := False;
end;

function TMarathonCommandBar.ActionNamed(const AName: String): TAction;
var
  Idx: Integer;
begin
  Result := nil;
  if not Assigned(FActions) then
    Exit;
  for Idx := 0 to FActions.ActionCount - 1 do
    if SameText(FActions.Actions[Idx].Name, AName) then
      Exit(TAction(FActions.Actions[Idx]));
end;

procedure TMarathonCommandBar.AddButton(const AActionName: String);
var
  Btn: TToolButton;
  Act: TAction;
begin
  Act := ActionNamed(AActionName);
  { A name that no longer matches an action simply gets no button. The bar is
    a convenience; a missing one is not worth refusing to start over. }
  if not Assigned(Act) then
    Exit;
  Btn := TToolButton.Create(FBar);
  Btn.Parent := FBar;
  { Left decides the order in a TToolBar, and every button so far is already
    placed, so putting this one past all of them appends it. }
  Btn.Left := FBar.Width + 1;
  Btn.Action := Act;
end;

procedure TMarathonCommandBar.AddSeparator;
var
  Btn: TToolButton;
begin
  Btn := TToolButton.Create(FBar);
  Btn.Parent := FBar;
  Btn.Left := FBar.Width + 1;
  Btn.Style := tbsDivider;
end;

procedure TMarathonCommandBar.Rebuild(AContext: TCommandContext);
var
  Idx: Integer;
begin
  FBar.BeginUpdate;
  try
    for Idx := FBar.ButtonCount - 1 downto 0 do
      FBar.Buttons[Idx].Free;

    case AContext of
      ccSQLEditor:
        begin
          { Running the statement, and deciding what happens to what it did.
            Nothing else earns a button here - Find, Undo and the rest are
            keystrokes people already know. }
          AddButton('ObjectExecute');
          AddButton('ObjectExecuteAsScript');
          AddSeparator;
          AddButton('TransactionCommit');
          AddButton('TransactionRollback');
          AddSeparator;
          AddButton('ViewStatementHistory');
        end;

      ccObjectEditor:
        begin
          { Applying the definition, and getting back what the database
            actually holds. }
          AddButton('ObjectCompile');
          AddButton('ViewRefresh');
          AddSeparator;
          AddButton('ObjectDrop');
        end;

      ccShell:
        begin
          { With nothing open the only useful moves are opening something. }
          AddButton('ToolsSQLEditor');
          AddButton('FileOpenDatabaseObject');
          AddSeparator;
          AddButton('FileConnect');
          AddButton('FileDisconnect');
        end;
    end;
  finally
    FBar.EndUpdate;
  end;
  FContext := AContext;
  FBuilt := True;
end;

procedure TMarathonCommandBar.ShowFor(AForm: IMarathonForm);
var
  Wanted: TCommandContext;
begin
  Wanted := ContextOf(AForm);
  { Rebuilding on every focus change would flicker and would throw away the
    button the mouse is over. }
  if FBuilt and (Wanted = FContext) then
    Exit;
  Rebuild(Wanted);
end;

end.
