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

unit CommandPalette;

{$MODE Delphi}

{ Matching what someone types against the names of commands.

  The VS Code extension's palette is how most of its features are reached.
  Marathon already names and groups every command it has, in TActionList - so
  the palette needs no new list of commands, only a way to find one by typing
  part of its name.

  This is that: no dialog, no actions, no LCL, so the rules are tested without
  a widgetset.

  Words are matched independently and in any order, because nobody recalls the
  exact wording of a menu item: "new conn" finds New Connection, and so does
  "conn new". The category counts too, so "tools extract" finds Metadata
  Extract without knowing which menu it is under. }

interface

uses SysUtils, Classes;

{ A caption as a person reads it: without the ampersands that mark keyboard
  accelerators, and without a trailing ellipsis. Both are noise when typing -
  "e&xtract..." should be found by "extract". }
function CommandDisplayName(const Caption: String): String;

{ True when every word of Query appears somewhere in the command's name or its
  category. An empty query matches everything, which is what a palette shows
  before anything is typed. }
function CommandMatches(const Query, Caption, Category: String): Boolean;

{ How well it matches, for ordering: higher is better. A command whose name
  starts with what was typed is what was almost certainly meant, so it sorts
  above one that merely contains it, which sorts above one matched only through
  its category. Zero means no match. }
function CommandRank(const Query, Caption, Category: String): Integer;

implementation

function CommandDisplayName(const Caption: String): String;
begin
  Result := StringReplace(Caption, '&', '', [rfReplaceAll]);
  Result := Trim(Result);
  while (Length(Result) > 0) and (Result[Length(Result)] = '.') do
    Result := TrimRight(Copy(Result, 1, Length(Result) - 1));
  Result := Trim(Result);
end;

function SplitWords(const Text: String): TStringList;
begin
  Result := TStringList.Create;
  Result.Delimiter := ' ';
  Result.StrictDelimiter := False;
  Result.DelimitedText := Trim(Text);
end;

function CommandMatches(const Query, Caption, Category: String): Boolean;
var
  Words: TStringList;
  Haystack: String;
  Idx: Integer;
begin
  if Trim(Query) = '' then
    Exit(True);
  { Name and category searched as one string: a word may come from either, so
    "tools extract" works without the user knowing which is which. }
  Haystack := AnsiUpperCase(CommandDisplayName(Caption) + ' ' + Trim(Category));
  Words := SplitWords(AnsiUpperCase(Query));
  try
    Result := True;
    for Idx := 0 to Words.Count - 1 do
      if (Words[Idx] <> '') and (Pos(Words[Idx], Haystack) = 0) then
      begin
        Result := False;
        Exit;
      end;
  finally
    Words.Free;
  end;
end;

function CommandRank(const Query, Caption, Category: String): Integer;
var
  Name, Q: String;
begin
  if not CommandMatches(Query, Caption, Category) then
    Exit(0);
  if Trim(Query) = '' then
    Exit(1);

  Name := AnsiUpperCase(CommandDisplayName(Caption));
  Q := AnsiUpperCase(Trim(Query));

  if Name = Q then
    Result := 4
  else if Pos(Q, Name) = 1 then
    Result := 3
  else if Pos(Q, Name) > 0 then
    Result := 2
  else
    { Matched, but only through the category or through separate words. }
    Result := 1;
end;

end.
