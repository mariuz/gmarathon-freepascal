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
// $Id: GlobalQueriesText.pas,v 1.1 2002/06/06 07:36:43 tmuetze Exp $

unit GlobalQueriesText;

interface

function GetQueryText(
  ObjectType: string;
  ObjectName: string
): string;

implementation

uses
  SysUtils;
  
function GetQueryText(ObjectType: string; ObjectName: string): string;
var
  IsInterbase6: boolean;
  SQLDialect: integer;
begin
  IsInterbase6 := true;
  SQLDialect := 3;
  ObjectType := Trim(UpperCase(ObjectType));
  if ObjectType = 'TABLE' then
  begin
  	if IsInterbase6 and (SQLDialect = 3) then
	  begin
  		Result :=
        'select '+
        '  a.rdb$field_name, '+
        '  a.rdb$null_flag as tnull_flag, ' +
	      '  b.rdb$null_flag as fnull_flag, ' +
        '  a.rdb$field_source, ' +
        '  a.rdb$default_source, ' +
        '  b.rdb$computed_source, ' +
        '  b.rdb$field_length, ' +
        '  b.rdb$field_precision, ' +
        '  a.rdb$description, ' +
        '  b.rdb$dimensions, ' +
        '  b.rdb$field_scale, '+
        '  b.rdb$field_type, '+
        '  b.rdb$field_sub_type '+
        ' from ' +
        '  rdb$relation_fields a, rdb$fields b '+
        ' where ' +
        '  a.rdb$field_source = b.rdb$field_name '+
        '  and a.rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' ' +
        ' order by '+
        '  a.rdb$field_position asc;';
  	end
    else
  	begin
  		Result :=
        'select '+
        '  a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
				'  b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
				'  b.rdb$computed_source, b.rdb$field_length, a.rdb$description, ' +
				'  b.rdb$dimensions, ' +
				'  b.rdb$field_scale, b.rdb$field_type, b.rdb$field_sub_type '+
        ' from ' +
				'  rdb$relation_fields a, rdb$fields b '+
        ' where ' +
				'  a.rdb$field_source = b.rdb$field_name '+
        '  and a.rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' ' +
				' order by '+
        '  a.rdb$field_position asc;';
    end;
  end
  else if (ObjectType = 'CONSTRAINTS') or
    (ObjectType = 'CONSTRAINTS_REF') or
    (ObjectType = 'CONSTRAINTS_CHECK') then
  begin
    Result :=
      'select ' +
      '  * ' +
      ' from ' +
      '  rdb$relation_constraints ' +
      ' where ' +
      '  rdb$constraint_type <> ''NOT NULL'' ' +
      '  and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''');
    if ObjectType = 'CONSTRAINTS_REF' then
    begin
      Result := Result + '  and rdb$constraint_type in (''PRIMARY KEY'', ''FOREIGN KEY'', ''UNIQUE'') ';
    end
    else if ObjectType = 'CONSTRAINTS_CHECK' then
    begin
      Result := Result + '  and rdb$constraint_type in (''CHECK'') ';
    end;
    Result := Result + ';';
  end
  else if ObjectType = 'INDEX' then
  begin
    Result :=
      'select ' +
      '  * ' +
      ' from rdb$indices ' +
      ' where ' +
      '  rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';';
  end
  else if ObjectType = 'TRIGGER' then
  begin
    Result :=
      'select ' +
      '  * ' +
      ' from ' +
      '  rdb$triggers ' +
      ' where ' +
      '  rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') +
      '  and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) '+
      ' order by ' +
      '  rdb$trigger_type asc, '+
      '  rdb$trigger_name asc;';
  end
  else if ObjectType = 'FUNCTION_ARGUMENTS' then
  begin
    Result :=
      'select ' +
      '  * ' +
      ' from ' +
      '  rdb$function_arguments ' +
      ' where ' +
      '  rdb$function_name = ' + AnsiQuotedStr(ObjectName, '''') +
      ' order by ' +
      '  rdb$argument_position asc;';
  end
  else
  begin
  end;
end;

end.

{
$Log: GlobalQueriesText.pas,v $
Revision 1.1  2002/06/06 07:36:43  tmuetze
Added a patch from Pavel Odstrcil: Now most basic print functions (right click in db navigator, print) work.


Revision 1.0  2002/06/03 08:00:00  tmuetze
New CVS powered comment block

}
