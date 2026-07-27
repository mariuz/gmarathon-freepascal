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

unit SQLIdentifiers;

{$MODE Delphi}

{ Writing an identifier the way SQL wants it.

  These four came out of MetaExtractGlobals, which still declares them and now
  calls in here. Nothing about deciding whether a name needs double quotes has
  anything to do with Firebird's API, but that is where they lived, and
  MetaExtractGlobals uses IBHeader - so anything wanting to quote an identifier
  had to link the whole IBX package to do it. That is what kept identifier
  quoting out of the light test harness, and why SchemaNames could not be
  tested without a database that it never touches. }

interface

uses SysUtils;

{ True when S already carries its quotes, either kind. }
function IsIdentifierQuoted(S: String): Boolean;

{ True when S holds anything outside the unquoted identifier character set, so
  writing it bare would not parse. }
function ShouldBeQuoted(S: String): Boolean;

{ S with its outer quotes removed, if it had any. }
function StripQuotesFromQuotedIdentifier(S: String): String;

{ S as DDL should spell it: quoted when it has to be, left alone otherwise.

  Dialect 1 has no quoted identifiers at all, and neither does pre-InterBase 6
  metadata, so both are passed through untouched rather than given quotes the
  server would reject. }
function MakeQuotedIdent(S: String; IB6: Boolean; Dialect: Integer): String;

implementation

function IsIdentifierQuoted(S: String): Boolean;
var
  BeginQuote, EndQuote: Boolean;
begin
  BeginQuote := False;
  EndQuote := False;

  if Length(S) > 0 then
    if S[1] in ['''', '"'] then
      BeginQuote := True;

  if Length(S) > 0 then
    if S[Length(S)] in ['''', '"'] then
      EndQuote := True;

  Result := BeginQuote and EndQuote;
end;

function ShouldBeQuoted(S: String): Boolean;
var
  Idx: Integer;
begin
  Result := False;
  for Idx := 1 to Length(S) do
    if not (S[Idx] in ['A'..'Z', 'a'..'z', '_', '0'..'9']) then
    begin
      Result := True;
      Break;
    end;
end;

function StripQuotesFromQuotedIdentifier(S: String): String;
begin
  if Length(S) > 0 then
    if S[1] in ['''', '"'] then
      S := Copy(S, 2, Length(S));

  if Length(S) > 0 then
    if S[Length(S)] in ['''', '"'] then
      S := Copy(S, 1, Length(S) - 1);

  Result := S;
end;

function MakeQuotedIdent(S: String; IB6: Boolean; Dialect: Integer): String;
begin
  if not IB6 then
    Result := S
  else if Dialect in [3] then
  begin
    if not IsIdentifierQuoted(S) then
    begin
      if ShouldBeQuoted(S) then
        Result := AnsiQuotedStr(S, '"')
      else
        Result := S;
    end
    else
      Result := S;
  end
  else
    Result := S;
end;

end.
