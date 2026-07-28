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

unit CompileScript;

{$MODE Delphi}

{ Turning a CREATE into an ALTER, in place.

  Compiling an object from an editor writes CREATE when it is new and ALTER
  when it is not, and the editor does not know which it is until it has asked
  the database - so the text is written one way and edited afterwards. The
  parser says where the verb is; this replaces it.

  A three-line edit, which is why it was written inline - but it is three lines
  that index into a string at a position computed by a parser, and nothing
  checked that the position was on the line, or that the line was in the text.
  A parse that surprises it wrote into the wrong place or raised out of a
  compile that had nothing wrong with it.

  No LCL, no parser and no database: a list of lines and a position. }

interface

uses SysUtils, Classes;

{ Replaces the token at that position with ANewVerb.

  ALineNo and AColNo are the parser's, so both are 1-based and AColNo is the
  column *after* the token - which is where a lexer stops. ATokenLength is what
  it read.

  False when the position is not in the text, in which case nothing is
  changed: the caller compiles what the user wrote rather than something it
  half-edited. }
function ReplaceVerbAt(ALines: TStrings; ALineNo, AColNo, ATokenLength: Integer;
  const ANewVerb: String): Boolean;

implementation

function ReplaceVerbAt(ALines: TStrings; ALineNo, AColNo, ATokenLength: Integer;
  const ANewVerb: String): Boolean;
var
  Line: String;
  Start: Integer;
begin
  Result := False;
  if not Assigned(ALines) then
    Exit;
  if (ALineNo < 1) or (ALineNo > ALines.Count) then
    Exit;
  if ATokenLength <= 0 then
    Exit;

  Line := ALines[ALineNo - 1];
  { The lexer's column is one past the token, so the token starts this far
    back. }
  Start := AColNo - ATokenLength;
  if (Start < 1) or (Start + ATokenLength - 1 > Length(Line)) then
    Exit;

  Delete(Line, Start, ATokenLength);
  Insert(ANewVerb, Line, Start);
  ALines[ALineNo - 1] := Line;
  Result := True;
end;

end.
