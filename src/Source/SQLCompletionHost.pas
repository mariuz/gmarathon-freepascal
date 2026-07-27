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

unit SQLCompletionHost;

{$MODE Delphi}

{ Ctrl+Space completion for an editor.

  Attaches SynEdit's own TSynCompletion to an editor and fills it: the
  connection's tables and views followed by SQL keywords, or - after a dot -
  that object's columns and nothing else.

  A component rather than code in each form because five editors want the same
  behaviour: the SQL editor, and the view, trigger and stored-procedure
  editors, which is where PSQL is actually written. The form supplies the
  connection name, since that changes while a window is open - the SQL editor
  can be repointed at another connection without being reopened.

  What to offer is decided in the LCL-free SQLCompletion unit, which is where
  that is tested. This unit is the wiring only. }

interface

uses SysUtils, Classes, Menus, Controls, LCLType, SynEdit, SynCompletion,
  SQLCompletion, MarathonProjectCacheTypes;

type
  TSQLCompletionHost = class(TComponent)
  private
    FCompletion: TSynCompletion;
    FEditor: TCustomSynEdit;
    FConnectionName: String;
    procedure Execute(Sender: TObject);
    procedure ShowRoutineHint(Sender: TObject; HintInfo: PHintInfo);
  public
    { Owned by AOwner, so the form frees it. }
    constructor Create(AOwner: TComponent; AEditor: TCustomSynEdit); reintroduce;
    { Which connection's objects to offer. Empty means keywords only, which is
      what a disconnected editor should still get. }
    property ConnectionName: String read FConnectionName write FConnectionName;
    property Completion: TSynCompletion read FCompletion;
  end;

implementation

uses Globals, MarathonIDE, MarathonProjectCache, ScriptAs, FirebirdKeywords;

constructor TSQLCompletionHost.Create(AOwner: TComponent; AEditor: TCustomSynEdit);
begin
  inherited Create(AOwner);
  FEditor := AEditor;
  FCompletion := TSynCompletion.Create(Self);
  FCompletion.Editor := AEditor;
  { Ctrl+Space, which is what every other SQL tool uses. Set explicitly so a
    change of SynEdit's default does not silently move it. }
  FCompletion.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl]);
  { The dot has to end a token, or 'c.' reads as one word and the qualifier is
    never seen. }
  FCompletion.EndOfTokenChr := '()[]. ,;:-+*/=<>''"';
  FCompletion.OnExecute := Execute;

  { Hovering a routine name shows its call signature. The same information the
    object tree puts in its status bar, at the point where it is actually
    needed - while writing the call. }
  AEditor.ShowHint := True;
  AEditor.OnShowHint := ShowRoutineHint;
end;

procedure TSQLCompletionHost.ShowRoutineHint(Sender: TObject; HintInfo: PHintInfo);
var
  Conn: TMarathonCacheConnection;
  Ctx: TScriptAsContext;
  Token, Signature: String;
begin
  if not Assigned(HintInfo) or (FConnectionName = '') then
    Exit;
  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FConnectionName];
  if not Assigned(Conn) or not Conn.Connected then
    Exit;

  Token := Trim(FEditor.GetWordAtRowCol(FEditor.PixelsToRowColumn(HintInfo^.CursorPos)));
  if Token = '' then
    Exit;

  Ctx := ScriptAsContext(Conn.Connection, Conn.Transaction, Conn.IsIB6,
    Conn.SQLDialect, Conn.ServerMajorVersion);
  try
    { RoutineSignature answers with an empty string for anything that is not a
      procedure or a PSQL function, so there is no need to ask the catalogue
      first what kind of thing this is - a table name simply produces nothing
      and no hint is shown. }
    Signature := RoutineSignature(Ctx, AnsiUpperCase(Token), False);
    if Signature = '' then
      Signature := RoutineSignature(Ctx, AnsiUpperCase(Token), True);
  except
    { A hint is a convenience; failing to read one must not interrupt typing. }
    on E: Exception do
      Signature := '';
  end;

  if Signature <> '' then
    HintInfo^.HintStr := Signature;
end;

procedure TSQLCompletionHost.Execute(Sender: TObject);
var
  Ctx: TCompletionContext;
  Conn: TMarathonCacheConnection;
  Cols: TStringList;
  Idx: Integer;
  TableName: String;
begin
  FCompletion.ItemList.BeginUpdate;
  try
    FCompletion.ItemList.Clear;
    Ctx := CompletionContextAt(FEditor.LineText, FEditor.CaretX);

    Conn := nil;
    if FConnectionName <> '' then
      Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FConnectionName];

    if Ctx.Kind = ckQualified then
    begin
      { After a dot only that object's columns make sense. Nothing is offered
        when the connection is closed or the name resolves to nothing, which
        is better than a list belonging to something else. }
      if Assigned(Conn) and Conn.Connected then
      begin
        TableName := ResolveAlias(FEditor.Text, Ctx.Qualifier);
        try
          Cols := ScriptAsColumnNames(
            ScriptAsContext(Conn.Connection, Conn.Transaction, Conn.IsIB6,
              Conn.SQLDialect, Conn.ServerMajorVersion),
            AnsiUpperCase(TableName));
          try
            for Idx := 0 to Cols.Count - 1 do
              FCompletion.ItemList.Add(Trim(Cols[Idx]));
          finally
            Cols.Free;
          end;
        except
          { A name that is not a table yet is the normal case while typing, not
            something to report - it simply has no columns to offer. }
          on E: Exception do ;
        end;
      end;
      Exit;
    end;

    { Objects first: they are what the reader cannot remember. Keywords are
      already highlighted as they type. }
    if Assigned(Conn) and Conn.Connected then
    begin
      FCompletion.ItemList.AddStrings(Conn.TableList);
      FCompletion.ItemList.AddStrings(Conn.ViewList);
    end;
    AddFirebirdKeywords(FCompletion.ItemList);
  finally
    FCompletion.ItemList.EndUpdate;
  end;
end;

end.
