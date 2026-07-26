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

unit SQLStatementText;

{$MODE Delphi}

{ Text-level inspection of what the user typed into the SQL editor, before any
  of it is handed to Firebird. Deliberately free of any LCL dependency so
  test/ibx_smoke_test.lpr can cover it. }

interface

uses SysUtils;

{ True when SQLText is an EXPLAIN request, with InnerSQL set to the statement
  being explained.

  EXPLAIN is *not* server DSQL - it is a client-side command that isql
  implements itself, and preparing it through IBX fails outright with
  "Token unknown - explain" (verified against Firebird 6). So the editor has
  to recognise it, strip it, and prepare what is left: a prepared statement
  already carries its explained plan, and preparing does not execute, which is
  the whole point of asking to explain a DELETE rather than run it. }
function IsExplainRequest(const SQLText: String; out InnerSQL: String): Boolean;

implementation

function IsExplainRequest(const SQLText: String; out InnerSQL: String): Boolean;
const
  Keyword = 'EXPLAIN';
var
  Trimmed: String;
  Next: Char;
begin
  Result := False;
  InnerSQL := '';
  Trimmed := TrimLeft(SQLText);
  if Length(Trimmed) <= Length(Keyword) then
    Exit;
  if UpperCase(Copy(Trimmed, 1, Length(Keyword))) <> Keyword then
    Exit;
  { Must be the whole word - "explainer" is not a request to explain, and a
    statement may legitimately start with an identifier beginning "explain". }
  Next := Trimmed[Length(Keyword) + 1];
  if not (Next in [' ', #9, #10, #13]) then
    Exit;
  InnerSQL := Trim(Copy(Trimmed, Length(Keyword) + 1, MaxInt));
  Result := InnerSQL <> '';
end;

end.
