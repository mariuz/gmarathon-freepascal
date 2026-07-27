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

unit SQLCompletion;

{$MODE Delphi}

{ Deciding what a completion list should offer at a given point in a statement.

  Only the reading of the text lives here - no popup, no metadata, no LCL - so
  the decisions can be tested without a database or a widgetset. The editor
  supplies the caret position and gets back what is being typed and, where
  there is one, the name in front of the dot; the caller then fills the list
  from the connection's cache.

  This replaces the `SQLInsightList` surface the original editor wrapper had
  and this port never carried. Nothing needed porting in the end: SynEdit ships
  TSynCompletion, so what was missing was the decision of what to put in it. }

interface

uses SysUtils, Classes;

type
  { What the caret is sitting in. }
  TCompletionKind = (
    { A bare word: offer keywords and object names. }
    ckAny,
    { Something followed by a dot: offer that object's columns, and nothing
      else - a keyword after a dot is never right. }
    ckQualified);

  TCompletionContext = record
    Kind: TCompletionKind;
    { The part of the word already typed, which the list filters on. Empty when
      the caret is on whitespace or just past a dot. }
    Partial: String;
    { The qualifier before the dot, for ckQualified. }
    Qualifier: String;
  end;

{ Reads backwards from CaretX (1-based, as SynEdit counts) over LineText. }
function CompletionContextAt(const LineText: String; CaretX: Integer): TCompletionContext;

{ The table an alias stands for, by reading the statement's FROM and JOIN
  clauses: given 'select * from CUSTOMERS c join ORDERS o on ...' and 'o' this
  answers ORDERS. Returns Alias itself when nothing matches, so a real table
  name typed in full still resolves. }
function ResolveAlias(const SQLText, Alias: String): String;

implementation

function IsNameChar(Ch: Char): Boolean;
begin
  { $ and _ are ordinary in Firebird names, and RDB$ prefixes are everywhere. }
  Result := (Ch in ['A'..'Z', 'a'..'z', '0'..'9', '_', '$']);
end;

function CompletionContextAt(const LineText: String; CaretX: Integer): TCompletionContext;
var
  Idx, WordEnd: Integer;
begin
  Result.Kind := ckAny;
  Result.Partial := '';
  Result.Qualifier := '';

  { CaretX is the column the next character would go in, so the character to
    its left is the last one typed. }
  Idx := CaretX - 1;
  if Idx > Length(LineText) then
    Idx := Length(LineText);

  WordEnd := Idx;
  while (Idx >= 1) and IsNameChar(LineText[Idx]) do
    Dec(Idx);
  Result.Partial := Copy(LineText, Idx + 1, WordEnd - Idx);

  { A dot immediately before the word makes this a qualified reference. }
  if (Idx >= 1) and (LineText[Idx] = '.') then
  begin
    Dec(Idx);
    WordEnd := Idx;
    while (Idx >= 1) and IsNameChar(LineText[Idx]) do
      Dec(Idx);
    Result.Qualifier := Copy(LineText, Idx + 1, WordEnd - Idx);
    { A dot with nothing before it qualifies nothing - leave it as a plain
      word, or the caller would look up columns of ''. }
    if Result.Qualifier <> '' then
      Result.Kind := ckQualified;
  end;
end;

function ResolveAlias(const SQLText, Alias: String): String;
var
  Words: TStringList;
  Idx, Scan: Integer;
  Cleaned: String;
  Ch: Char;

  { True for a word that ends the table list. Without this the scan would walk
    out of the FROM clause and read the first column of a WHERE as an alias. }
  function EndsTableList(const W: String): Boolean;
  begin
    Result := SameText(W, 'where') or SameText(W, 'group') or
              SameText(W, 'order') or SameText(W, 'having') or
              SameText(W, 'on') or SameText(W, 'union') or
              SameText(W, 'select') or SameText(W, 'join') or
              SameText(W, 'inner') or SameText(W, 'left') or
              SameText(W, 'right') or SameText(W, 'full') or
              SameText(W, 'cross') or SameText(W, 'into') or
              SameText(W, 'plan') or SameText(W, 'rows');
  end;

begin
  Result := Alias;
  if Trim(Alias) = '' then
    Exit;

  { Punctuation becomes whitespace so the split sees the names - except the
    comma, which is kept as a word of its own. It is the only thing separating
    one table from the next in 'from CUSTOMERS c, ORDERS o', and blanking it
    made the second table unreachable. }
  Cleaned := '';
  for Idx := 1 to Length(SQLText) do
  begin
    Ch := SQLText[Idx];
    if IsNameChar(Ch) then
      Cleaned := Cleaned + Ch
    else if Ch = ',' then
      Cleaned := Cleaned + ' , '
    else
      Cleaned := Cleaned + ' ';
  end;

  Words := TStringList.Create;
  try
    Words.Delimiter := ' ';
    Words.StrictDelimiter := False;
    Words.DelimitedText := Cleaned;

    for Idx := 0 to Words.Count - 1 do
      if SameText(Words[Idx], 'from') or SameText(Words[Idx], 'join') then
      begin
        Scan := Idx + 1;
        while (Scan < Words.Count) and not EndsTableList(Words[Scan]) do
        begin
          { Each entry is a name, then optionally AS, then optionally an
            alias, and entries are separated by commas. }
          if Words[Scan] = ',' then
          begin
            Inc(Scan);
            Continue;
          end;
          if (Scan + 1 < Words.Count) and SameText(Words[Scan + 1], 'as') then
          begin
            if (Scan + 2 < Words.Count) and SameText(Words[Scan + 2], Alias) then
              Exit(Words[Scan]);
            Inc(Scan, 3);
          end
          else
          begin
            if (Scan + 1 < Words.Count) and SameText(Words[Scan + 1], Alias) then
              Exit(Words[Scan]);
            { A table with no alias at all still answers to its own name. }
            if SameText(Words[Scan], Alias) then
              Exit(Words[Scan]);
            Inc(Scan, 2);
          end;
        end;
      end;
  finally
    Words.Free;
  end;
end;

end.
