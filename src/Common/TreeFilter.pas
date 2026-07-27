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

unit TreeFilter;

{$MODE Delphi}

{ Deciding what an object tree filter shows.

  The VS Code MSSQL extension filters its object explorer by name and by object
  type; Marathon has the same capability as a separate Metadata Search window,
  which is the right feature in the wrong place. This is the deciding half -
  what a filter means and whether a given object matches it - with no tree and
  no LCL, so it is tested without a widgetset.

  The syntax is one line, because a filter box that needs explaining is a
  filter box nobody uses:

    cust            anything whose name contains "cust"
    table:cust      tables whose name contains "cust"
    table:          every table
    "cust"          anything whose name is exactly "cust"

  Matching is case-insensitive: Firebird stores unquoted names folded to upper
  case, and nobody types them that way. }

interface

uses SysUtils, Classes;

type
  TTreeFilter = record
    { Empty when the filter names no type, in which case every type matches. }
    Kind: String;
    { What the name must contain, or equal when Exact is set. }
    Fragment: String;
    Exact: Boolean;
    { True when the filter asks for nothing at all, so everything shows. }
    IsEmpty: Boolean;
  end;

{ Reads a filter box's text. Never fails: anything unrecognised is taken as a
  name fragment, because a filter that rejects what was typed is worse than one
  that shows too much. }
function ParseTreeFilter(const Text: String): TTreeFilter;

{ True when an object of that kind and name should be shown.

  Kind is the caption Marathon uses for the group the object sits in - 'Tables',
  'Views', 'Stored Procedures' - and is matched loosely, so 'proc' finds stored
  procedures and 'table' finds tables without the user knowing the exact
  wording. }
function TreeFilterMatches(const Filter: TTreeFilter;
  const ObjectName, KindCaption: String): Boolean;

implementation

function ParseTreeFilter(const Text: String): TTreeFilter;
var
  Trimmed, Rest: String;
  ColonAt: Integer;
begin
  Result.Kind := '';
  Result.Fragment := '';
  Result.Exact := False;
  Trimmed := Trim(Text);
  Result.IsEmpty := Trimmed = '';
  if Result.IsEmpty then
    Exit;

  Rest := Trimmed;
  { A type prefix, if there is one. Only before any quote, so a name containing
    a colon inside quotes is not mistaken for one. }
  ColonAt := Pos(':', Rest);
  if (ColonAt > 1) and ((Pos('"', Rest) = 0) or (ColonAt < Pos('"', Rest))) then
  begin
    Result.Kind := Trim(Copy(Rest, 1, ColonAt - 1));
    Rest := Trim(Copy(Rest, ColonAt + 1, MaxInt));
  end;

  { Quoted means the whole name, not part of it. }
  if (Length(Rest) >= 2) and (Rest[1] = '"') and (Rest[Length(Rest)] = '"') then
  begin
    Result.Exact := True;
    Rest := Copy(Rest, 2, Length(Rest) - 2);
  end;

  Result.Fragment := Rest;
  { 'table:' with nothing after it is a filter on type alone, which is a
    perfectly ordinary thing to want. }
  Result.IsEmpty := (Result.Kind = '') and (Result.Fragment = '');
end;

function KindMatches(const Wanted, KindCaption: String): Boolean;
var
  W, K: String;
begin
  if Wanted = '' then
    Exit(True);
  W := AnsiLowerCase(Wanted);
  K := AnsiLowerCase(KindCaption);
  { Either way round: 'procedure' should find 'Stored Procedures', and 'proc'
    should too. A plural typed against a singular caption works for the same
    reason. }
  Result := (Pos(W, K) > 0) or (Pos(K, W) > 0);
  if Result then
    Exit;
  { The one pairing the substring test does not reach, because neither word
    contains the other. }
  if ((W = 'sp') or (W = 'procs')) and (Pos('procedure', K) > 0) then
    Result := True;
end;

function TreeFilterMatches(const Filter: TTreeFilter;
  const ObjectName, KindCaption: String): Boolean;
var
  Name, Fragment: String;
begin
  if Filter.IsEmpty then
    Exit(True);
  if not KindMatches(Filter.Kind, KindCaption) then
    Exit(False);
  if Filter.Fragment = '' then
    Exit(True);

  Name := AnsiUpperCase(Trim(ObjectName));
  Fragment := AnsiUpperCase(Trim(Filter.Fragment));
  if Filter.Exact then
    Result := Name = Fragment
  else
    Result := Pos(Fragment, Name) > 0;
end;

end.
