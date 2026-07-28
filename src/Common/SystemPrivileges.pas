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

unit SystemPrivileges;

{$MODE Delphi}

{ What a role is allowed to do to the server, rather than to the data.

  Firebird 4 added system privileges - the right to run gbak, to trace another
  attachment, to read raw pages, to create a database - and grants them to
  roles rather than to users. They are not in a table: `RDB$ROLES` holds one
  `CHAR(8) CHARACTER SET OCTETS` column, a bitmask, and nothing in it says what
  any bit means.

  What the catalogue *does* publish is the names, in `RDB$TYPES` under
  `RDB$FIELD_NAME = 'RDB$SYSTEM_PRIVILEGES'` - 27 of them on the 6.0.0 test
  server. So the names are read from the server rather than hard-coded here,
  the same way the monitor decodes MON$STATE: a privilege a later Firebird adds
  appears by itself, and one this build has never heard of is not silently
  dropped.

  The layout was measured rather than assumed. A role granted USER_MANAGEMENT
  (type 1) reads 0200000000000000; READ_RAW_PAGES (2) reads 0400...;
  CREATE_DATABASE (9) reads 0002...; and all three of 1, 9 and 27 together read
  0202000800000000. So bit *n* of the mask is privilege type *n*, stored little
  end first: byte n div 8, bit n mod 8.

  The bits arrive as hex - `HEX_ENCODE` on the server - rather than as the raw
  eight bytes, because a binary column carrying NULs through a dataset and into
  a grid is a series of small surprises, and the hex is what a person reading
  the window would want to see anyway.

  No LCL and no IBX. }

interface

uses SysUtils;

{ Whether this server has system privileges at all. They are Firebird 4 and
  later; before that RDB$ROLES has no such column, and naming a column that is
  not there is a hard error rather than a null. }
function SystemPrivilegesSupportedSQL: String;

{ The names, from the catalogue rather than from a list here. }
function SystemPrivilegeNamesSQL: String;

{ Every role, with its mask as hex and its owner. RDB$ADMIN has every bit set
  and is the one role that is always there. }
function RoleSystemPrivilegesSQL: String;

{ True when that privilege type is granted by this mask.

  AHexBits is what HEX_ENCODE returned: two characters per byte, low byte
  first. Anything that is not that - empty, odd length, a character that is not
  a hex digit - is no privilege rather than an exception, because this decodes
  what a server sent and a window showing one role wrongly is better than a
  window that will not open. }
function HasSystemPrivilege(const AHexBits: String; ATypeCode: Integer): Boolean;

{ How many privileges that mask grants, given how many the server defines. Used
  for the summary column, so a role can be read at a glance without opening
  it. }
function SystemPrivilegeCount(const AHexBits: String; AHighestType: Integer): Integer;

implementation

function SystemPrivilegesSupportedSQL: String;
begin
  Result :=
    'select count(*) from rdb$relation_fields ' +
    'where rdb$relation_name = ''RDB$ROLES'' ' +
    '  and rdb$field_name = ''RDB$SYSTEM_PRIVILEGES''';
end;

function SystemPrivilegeNamesSQL: String;
begin
  Result :=
    'select rdb$type, trim(rdb$type_name) as PRIV_NAME ' +
    'from rdb$types ' +
    'where rdb$field_name = ''RDB$SYSTEM_PRIVILEGES'' ' +
    'order by rdb$type';
end;

function RoleSystemPrivilegesSQL: String;
begin
  Result :=
    'select trim(r.rdb$role_name) as ROLE_NAME, ' +
    '       trim(r.rdb$owner_name) as OWNER_NAME, ' +
    '       coalesce(hex_encode(r.rdb$system_privileges), '''') as PRIV_BITS ' +
    'from rdb$roles r ' +
    'order by r.rdb$role_name';
end;

{ One hex digit, or -1 for anything that is not one. }
function HexValue(AChar: Char): Integer;
begin
  case AChar of
    '0'..'9': Result := Ord(AChar) - Ord('0');
    'a'..'f': Result := Ord(AChar) - Ord('a') + 10;
    'A'..'F': Result := Ord(AChar) - Ord('A') + 10;
  else
    Result := -1;
  end;
end;

function HasSystemPrivilege(const AHexBits: String; ATypeCode: Integer): Boolean;
var
  ByteIndex, BitIndex, Hi, Lo, First: Integer;
begin
  Result := False;
  if (ATypeCode < 0) or (Length(AHexBits) = 0) or Odd(Length(AHexBits)) then
    Exit;

  ByteIndex := ATypeCode div 8;
  BitIndex := ATypeCode mod 8;
  { Two hex characters per byte. }
  First := ByteIndex * 2 + 1;
  if First + 1 > Length(AHexBits) then
    Exit;

  Hi := HexValue(AHexBits[First]);
  Lo := HexValue(AHexBits[First + 1]);
  if (Hi < 0) or (Lo < 0) then
    Exit;

  Result := ((Hi * 16 + Lo) and (1 shl BitIndex)) <> 0;
end;

function SystemPrivilegeCount(const AHexBits: String; AHighestType: Integer): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to AHighestType do
    if HasSystemPrivilege(AHexBits, Idx) then
      Inc(Result);
end;

end.
