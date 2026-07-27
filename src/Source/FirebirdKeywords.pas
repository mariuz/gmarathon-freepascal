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

  Every word here was checked twice: that the Firebird 6.0.0 test server
  actually accepts it, and that Lazarus's sqlFirebird40 list does not already
  contain it. Notably absent for that reason are the JSON functions
  (JSON_VALUE, JSON_QUERY and friends) and UNLIST - Firebird 6.0.0 rejects
  them, so there is nothing yet to highlight. }

interface

uses Classes, SynHighlighterSQL;

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

end.
