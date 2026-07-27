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

unit FirebirdKeywords;

{$MODE Delphi}

{ Firebird keywords newer than the highlighter knows about.

  Lazarus's SynHighlighterSQL ships per-dialect keyword lists but its
  TSQLDialect enum stops at sqlFirebird40, so anything added by Firebird 5 or 6
  renders as a plain identifier. The list below closes that gap.

  How, and why this way: TSynSQLSyn's own DoAddKeyword is declared `private`,
  which in Object Pascal means unit-scoped - a descendant declared anywhere
  else cannot reach it, so there is no way to add a word as a true tkKey from
  outside the SynEdit unit. The one public injection point is the published
  TableNames property, which feeds PutTableNamesInKeywordList and does add
  words to the same keyword hash - but as tkTableName. Verified by tokenising:
  before injection "locked" comes back as Identifier, after it as Table Name.

  The visible consequence is that these words are painted with the Table Name
  attribute rather than the Reserved Word one, so ApplyFirebirdKeywords copies
  the keyword styling across. Marathon does not otherwise use TableNames (the
  gTableNames setting drives code completion, not the highlighter), so nothing
  else competes for that attribute. The clean long-term fix is an FB5/FB6
  keyword set upstream in Lazarus, which would make this unit unnecessary.

  The list below is now a fallback rather than the answer. Firebird 5 added
  RDB$KEYWORDS, a system table holding every word the server itself reserves -
  527 of them on the 6.0.0 test server - so a connection can be asked instead
  of a list being maintained here by hand. ApplyServerKeywords does that, and
  it is better than any hand-kept list in three ways: it is exactly right for
  the server in front of the user, it needs no maintenance when Firebird adds a
  word, and a feature that is not in this server does not get highlighted as
  though it were.

  It also settles something the roadmap had blocked: the JSON functions are
  absent from the list below because Firebird 6.0.0 rejects them, and a server
  that does support them will simply report them in RDB$KEYWORDS.

  The hand-kept list stays for servers older than 5, which have no
  RDB$KEYWORDS. Every word in it was checked twice: that the test server
  accepts it, and that Lazarus's sqlFirebird40 list does not already have
  it. }

interface

uses SysUtils, Classes, SynHighlighterSQL;

const
  ExtraFirebirdKeywords: array[0..5] of String = (
    'ANY_VALUE',     { Firebird 5 }
    'BLOB_APPEND',   { Firebird 5 }
    'GREATEST',      { Firebird 6 }
    'LEAST',         { Firebird 6 }
    'LOCKED',        { Firebird 5 - "SKIP LOCKED"; SKIP itself is already known }
    'UNICODE_CHAR'
    );

{ Teaches Highlighter the keywords above and makes them look like the reserved
  words they are. Safe to call repeatedly - the word list is replaced, not
  appended to. Call it after LoadFromRegistry, since that restores the
  attribute colours this has to copy from. }
procedure ApplyFirebirdKeywords(Highlighter: TSynSQLSyn);

{ The same, from a list the server supplied - RDB$KEYWORDS.

  Only words the highlighter does not already know are injected. Handing it all
  527 would work but would replace its own keyword handling with the
  TableName attribute for every one of them, which is a worse rendering of the
  words it already gets right.

  Falls back to the hand-kept list when ServerWords is empty, which is what a
  server older than Firebird 5 gives. }
procedure ApplyServerKeywords(Highlighter: TSynSQLSyn; ServerWords: TStrings);

{ Which of ServerWords the highlighter does not already tokenise as a keyword.
  Separated out because it is the decision worth checking, and it needs no
  connection. }
procedure SelectUnknownKeywords(Highlighter: TSynSQLSyn; ServerWords,
  Dest: TStrings);

{ Adds the SQL words worth offering in a completion list to Dest.

  Kept here rather than read back from the highlighter because TSynSQLSyn does
  not expose its keyword list - only TableNames is published - so there is
  nothing to borrow. The list is deliberately the words people type rather than
  every reserved word Firebird knows: a completion list that offers 300 entries
  is a list nobody reads. }
procedure AddFirebirdKeywords(Dest: TStrings);

implementation

const
  CompletionKeywords: array[0..92] of String = (
    'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AVG',
    'BEGIN', 'BETWEEN', 'BY',
    'CASE', 'CAST', 'CHAR', 'CHECK', 'COALESCE', 'COMMIT', 'CONSTRAINT',
    'COUNT', 'CREATE', 'CROSS', 'CURRENT_DATE', 'CURRENT_TIME',
    'CURRENT_TIMESTAMP', 'CURSOR',
    'DECLARE', 'DECIMAL', 'DEFAULT', 'DELETE', 'DESC', 'DISTINCT', 'DO', 'DROP',
    'ELSE', 'END', 'EXCEPTION', 'EXECUTE', 'EXISTS', 'EXIT',
    'FETCH', 'FIRST', 'FOR', 'FOREIGN', 'FROM', 'FULL', 'FUNCTION',
    'GENERATOR', 'GRANT', 'GROUP', 'HAVING',
    'IF', 'IN', 'INDEX', 'INNER', 'INSERT', 'INTO', 'IS',
    'JOIN', 'KEY', 'LEFT', 'LIKE', 'MAX', 'MERGE', 'MIN',
    'NOT', 'NULL', 'ON', 'OR', 'ORDER', 'OUTER',
    'PLAN', 'PRIMARY', 'PROCEDURE', 'RETURNING', 'RETURNS', 'RIGHT', 'ROLLBACK',
    'ROWS', 'SELECT', 'SET', 'SKIP', 'SUM',
    'TABLE', 'THEN', 'TRIGGER', 'UNION', 'UNIQUE', 'UPDATE', 'USING',
    'VALUES', 'VIEW', 'WHEN', 'WHERE', 'WHILE', 'WITH'
    );

procedure AddFirebirdKeywords(Dest: TStrings);
var
  Idx: Integer;
begin
  if not Assigned(Dest) then
    Exit;
  for Idx := Low(CompletionKeywords) to High(CompletionKeywords) do
    Dest.Add(CompletionKeywords[Idx]);
  { The newer words this unit exists for, so completion and highlighting agree
    on what the server understands. }
  for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
    Dest.Add(ExtraFirebirdKeywords[Idx]);
end;

procedure ApplyFirebirdKeywords(Highlighter: TSynSQLSyn);
var
  Words: TStringList;
  Idx: Integer;
begin
  if not Assigned(Highlighter) then
    Exit;

  Words := TStringList.Create;
  try
    for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
      Words.Add(ExtraFirebirdKeywords[Idx]);
    { The setter assigns and re-initialises the keyword hash. }
    Highlighter.TableNames := Words;
  finally
    Words.Free;
  end;

  Highlighter.TableNameAttri.Foreground := Highlighter.KeyAttri.Foreground;
  Highlighter.TableNameAttri.Background := Highlighter.KeyAttri.Background;
  Highlighter.TableNameAttri.Style := Highlighter.KeyAttri.Style;
end;

{ True when the highlighter already paints this word as something other than a
  plain identifier - a reserved word, a function, a type. Asked by tokenising,
  because TSynSQLSyn does not publish its keyword list. }
function AlreadyKnown(Highlighter: TSynSQLSyn; const Word_: String): Boolean;
var
  Kind: Integer;
begin
  Highlighter.SetLine(Word_, 0);
  Kind := -1;
  while not Highlighter.GetEol do
  begin
    if Trim(Highlighter.GetToken) <> '' then
    begin
      Kind := Highlighter.GetTokenKind;
      Break;
    end;
    Highlighter.Next;
  end;
  Result := (Kind >= 0) and (Kind <> Ord(tkIdentifier));
end;

procedure SelectUnknownKeywords(Highlighter: TSynSQLSyn; ServerWords,
  Dest: TStrings);
var
  Idx: Integer;
  Word_: String;
begin
  Dest.Clear;
  if not Assigned(Highlighter) or not Assigned(ServerWords) then
    Exit;
  for Idx := 0 to ServerWords.Count - 1 do
  begin
    Word_ := Trim(ServerWords[Idx]);
    { A word with anything but letters and underscores in it is not something
      the highlighter tokenises as one word, so injecting it would do nothing
      useful. }
    if Word_ = '' then
      Continue;
    if AlreadyKnown(Highlighter, Word_) then
      Continue;
    if Dest.IndexOf(Word_) < 0 then
      Dest.Add(Word_);
  end;
end;

procedure ApplyServerKeywords(Highlighter: TSynSQLSyn; ServerWords: TStrings);
var
  Unknown: TStringList;
begin
  if not Assigned(Highlighter) then
    Exit;
  { No list means a server too old to have RDB$KEYWORDS. }
  if not Assigned(ServerWords) or (ServerWords.Count = 0) then
  begin
    ApplyFirebirdKeywords(Highlighter);
    Exit;
  end;
  Unknown := TStringList.Create;
  try
    SelectUnknownKeywords(Highlighter, ServerWords, Unknown);
    Highlighter.TableNames.Assign(Unknown);
    { The same styling copy ApplyFirebirdKeywords makes, for the same reason:
      injected words arrive with the TableName attribute. }
    Highlighter.TableNameAttri.Assign(Highlighter.KeyAttri);
  finally
    Unknown.Free;
  end;
end;

end.
