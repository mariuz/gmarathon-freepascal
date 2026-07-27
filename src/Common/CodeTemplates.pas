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

unit CodeTemplates;

{$MODE Delphi}

{ Code templates: a short name typed in an editor, expanded into a block of
  SQL.

  The Options dialog has had a SQL Insight tab since the port began, with a
  list of templates, a body pane and Add, Edit and Delete buttons - all of them
  wired to handlers whose bodies say only that SQLInsightList is not available
  on this port. So the tab looked complete, held nothing, and saved nothing.

  This is the part with decisions in it: what a template file looks like, where
  the caret lands after expanding one, and how the editor works out which
  template the user meant. None of it needs an editor or a widgetset.

  Indentation is the reason expansion is more than string substitution. A
  template typed at the start of a line and the same one typed inside a nested
  BEGIN block should both come out aligned with where they were typed;
  otherwise every expansion has to be re-indented by hand, which is more work
  than typing it out. }

interface

uses SysUtils, Classes, StrUtils;

const
  { Where the caret goes after expanding. A vertical bar because it looks like
    a caret and is rare in SQL - it is the concatenation operator, so a
    template wanting a literal one doubles it. }
  CaretMarker = '|';

type
  TCodeTemplate = class
  public
    { What the user types to get it. Matched without case, since nobody
      remembers whether they called it 'sel' or 'SEL'. }
    Name: String;
    Description: String;
    Body: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

  TCodeTemplateList = class
  private
    FItems: TList;
    function GetItem(Index: Integer): TCodeTemplate;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AName, ADescription: String): TCodeTemplate;
    procedure Delete(Index: Integer);
    procedure Clear;
    function Count: Integer;
    function IndexOfName(const AName: String): Integer;
    function FindByName(const AName: String): TCodeTemplate;
    property Items[Index: Integer]: TCodeTemplate read GetItem; default;

    { The file form, which is the one the original used: a bracketed name and
      description, then the body until the next bracket.

        [sel | Select all rows]
        select *
        from |

      Chosen over anything tidier because a user who has hand-written a
      template file for the Delphi build should not have to redo it. }
    function SaveToText: String;
    procedure LoadFromText(const AText: String);
    { A starter set, so the tab is not empty on a machine that has never had
      one. Only used when there is no file at all. }
    procedure AddDefaults;
  end;

{ The template's body with the caret marker taken out, indented to sit under
  AIndent, and the caret's line and column reported.

  CaretLine is relative to the first line of the expansion, and CaretCol is a
  column in the finished text - so a caller adds its own line offset and uses
  the column as it stands. Both come back as the end of the text when the
  template names no caret position. }
function ExpandTemplate(ATemplate: TCodeTemplate; const AIndent: String;
  out ACaretLine, ACaretCol: Integer): String;

{ The word immediately before ACaretX on ALine, which is what the user just
  typed and therefore the template they mean. Empty when the caret is not at
  the end of a word. }
function TemplateWordBefore(const ALine: String; ACaretX: Integer): String;

{ The leading whitespace of ALine, so an expansion lines up with where it was
  typed. }
function IndentOf(const ALine: String): String;

{ The one list the editors expand from and the Options dialog edits. A single
  list because a template is a property of the user, not of a window - a
  template added in Options has to be usable in an editor already open.

  Created empty on first use; who fills it from a file is the application's
  business, since only it knows where the file lives. }
function GlobalCodeTemplates: TCodeTemplateList;

implementation

var
  FGlobalTemplates: TCodeTemplateList = nil;

function GlobalCodeTemplates: TCodeTemplateList;
begin
  if not Assigned(FGlobalTemplates) then
    FGlobalTemplates := TCodeTemplateList.Create;
  Result := FGlobalTemplates;
end;

constructor TCodeTemplate.Create;
begin
  inherited Create;
  Body := TStringList.Create;
end;

destructor TCodeTemplate.Destroy;
begin
  Body.Free;
  inherited Destroy;
end;

constructor TCodeTemplateList.Create;
begin
  inherited Create;
  FItems := TList.Create;
end;

destructor TCodeTemplateList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

function TCodeTemplateList.GetItem(Index: Integer): TCodeTemplate;
begin
  Result := TCodeTemplate(FItems[Index]);
end;

function TCodeTemplateList.Count: Integer;
begin
  Result := FItems.Count;
end;

function TCodeTemplateList.Add(const AName, ADescription: String): TCodeTemplate;
begin
  Result := TCodeTemplate.Create;
  Result.Name := Trim(AName);
  Result.Description := Trim(ADescription);
  FItems.Add(Result);
end;

procedure TCodeTemplateList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FItems.Count) then
    Exit;
  TCodeTemplate(FItems[Index]).Free;
  FItems.Delete(Index);
end;

procedure TCodeTemplateList.Clear;
var
  Idx: Integer;
begin
  for Idx := 0 to FItems.Count - 1 do
    TCodeTemplate(FItems[Idx]).Free;
  FItems.Clear;
end;

function TCodeTemplateList.IndexOfName(const AName: String): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  if Trim(AName) = '' then
    Exit;
  for Idx := 0 to FItems.Count - 1 do
    if SameText(TCodeTemplate(FItems[Idx]).Name, Trim(AName)) then
      Exit(Idx);
end;

function TCodeTemplateList.FindByName(const AName: String): TCodeTemplate;
var
  At: Integer;
begin
  Result := nil;
  At := IndexOfName(AName);
  if At >= 0 then
    Result := GetItem(At);
end;

function TCodeTemplateList.SaveToText: String;
var
  Idx, N: Integer;
  Lines: TStringList;
  T: TCodeTemplate;
begin
  Lines := TStringList.Create;
  try
    for Idx := 0 to FItems.Count - 1 do
    begin
      T := GetItem(Idx);
      Lines.Add('[' + T.Name + ' | ' + T.Description + ']');
      for N := 0 to T.Body.Count - 1 do
        Lines.Add(T.Body[N]);
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TCodeTemplateList.LoadFromText(const AText: String);
var
  Lines: TStringList;
  Idx, Bar: Integer;
  Line, Head: String;
  Current: TCodeTemplate;
begin
  Clear;
  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    Current := nil;
    for Idx := 0 to Lines.Count - 1 do
    begin
      Line := Lines[Idx];
      { A header is a bracketed line, and only one that opens at the very
        start - a body line may perfectly well contain brackets. }
      if (Length(Trim(Line)) >= 2) and (Copy(TrimLeft(Line), 1, 1) = '[') and
         (Copy(TrimRight(Line), Length(TrimRight(Line)), 1) = ']') then
      begin
        Head := Trim(Line);
        Head := Copy(Head, 2, Length(Head) - 2);
        Bar := Pos('|', Head);
        if Bar > 0 then
          Current := Add(Copy(Head, 1, Bar - 1), Copy(Head, Bar + 1, MaxInt))
        else
          { A header with no description is still a template. }
          Current := Add(Head, '');
        Continue;
      end;
      { Anything before the first header is a stray, and belongs to no
        template. Dropped rather than guessed at. }
      if Assigned(Current) then
        Current.Body.Add(Line);
    end;

    { A trailing blank line is an artefact of how the file was written, not
      part of the last template. }
    for Idx := 0 to FItems.Count - 1 do
    begin
      Current := GetItem(Idx);
      while (Current.Body.Count > 0) and
            (Trim(Current.Body[Current.Body.Count - 1]) = '') do
        Current.Body.Delete(Current.Body.Count - 1);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TCodeTemplateList.AddDefaults;
var
  T: TCodeTemplate;
begin
  T := Add('sel', 'Select all rows from a table');
  T.Body.Add('select *');
  T.Body.Add('from |');

  T := Add('selw', 'Select with a condition');
  T.Body.Add('select *');
  T.Body.Add('from |');
  T.Body.Add('where ');

  T := Add('ins', 'Insert a row');
  T.Body.Add('insert into | ()');
  T.Body.Add('values ()');

  T := Add('upd', 'Update rows');
  T.Body.Add('update |');
  T.Body.Add('set ');
  T.Body.Add('where ');

  T := Add('blk', 'Execute block');
  T.Body.Add('execute block as');
  T.Body.Add('begin');
  T.Body.Add('  |');
  T.Body.Add('end');

  T := Add('fors', 'For select loop');
  T.Body.Add('for select | from ');
  T.Body.Add('  into :');
  T.Body.Add('do');
  T.Body.Add('begin');
  T.Body.Add('end');
end;

function IndentOf(const ALine: String): String;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := 1 to Length(ALine) do
  begin
    if not (ALine[Idx] in [' ', #9]) then
      Break;
    Result := Result + ALine[Idx];
  end;
end;

function ExpandTemplate(ATemplate: TCodeTemplate; const AIndent: String;
  out ACaretLine, ACaretCol: Integer): String;
var
  Idx, Bar: Integer;
  Line: String;
  Lines: TStringList;
  Found: Boolean;
begin
  ACaretLine := 0;
  ACaretCol := 0;
  Result := '';
  if not Assigned(ATemplate) then
    Exit;

  Lines := TStringList.Create;
  try
    Found := False;
    for Idx := 0 to ATemplate.Body.Count - 1 do
    begin
      Line := ATemplate.Body[Idx];
      { The first line is typed where the caret already is, so it is not
        indented again; the rest line up under it. }
      if Idx > 0 then
        Line := AIndent + Line;

      if not Found then
      begin
        Bar := Pos(CaretMarker, Line);
        { A doubled marker is a literal one - the concatenation operator - and
          is not where the caret goes. }
        while (Bar > 0) and (Copy(Line, Bar, 2) = CaretMarker + CaretMarker) do
          Bar := PosEx(CaretMarker, Line, Bar + 2);
        if Bar > 0 then
        begin
          Found := True;
          ACaretLine := Idx;
          ACaretCol := Bar;
          Delete(Line, Bar, Length(CaretMarker));
        end;
      end;
      Line := StringReplace(Line, CaretMarker + CaretMarker, CaretMarker,
        [rfReplaceAll]);
      Lines.Add(Line);
    end;

    Result := Lines.Text;
    { TStringList.Text ends every line, including the last. A template is
      inserted into a line that already exists, so the trailing break would
      push whatever followed onto a line of its own. }
    while (Length(Result) > 0) and (Result[Length(Result)] in [#13, #10]) do
      Delete(Result, Length(Result), 1);

    if not Found then
    begin
      { No marker: the caret goes to the end, which is where someone typing
        would expect to carry on from. }
      if Lines.Count > 0 then
      begin
        ACaretLine := Lines.Count - 1;
        ACaretCol := Length(Lines[Lines.Count - 1]) + 1;
      end
      else
        ACaretCol := 1;
    end;
  finally
    Lines.Free;
  end;
end;

function TemplateWordBefore(const ALine: String; ACaretX: Integer): String;
var
  Start: Integer;
begin
  Result := '';
  if (ACaretX < 2) or (ACaretX > Length(ALine) + 1) then
    Exit;
  Start := ACaretX - 1;
  while (Start >= 1) and (ALine[Start] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
    Dec(Start);
  Inc(Start);
  if Start < ACaretX then
    Result := Copy(ALine, Start, ACaretX - Start);
end;

initialization

finalization
  FGlobalTemplates.Free;

end.
