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

unit SQLParamTypes;

{$MODE Delphi}

{ Bridges Firebird's parameter type codes to what the parameter dialog needs to
  know. Kept apart from SQLParamsDialog.pas so that unit stays free of any IBX
  dependency, and apart from SQLForm.pas so this rule can be exercised on its
  own. }

interface

uses IB, SQLParamsDialog;

{ The SQL_* codes and the scale rule were confirmed against a live Firebird 6
  server rather than read off a header. The trap is NUMERIC/DECIMAL: a
  NUMERIC(10,2) parameter arrives as SQL_INT64 with scale -2, so it is the
  scale that separates a whole number from a decimal, not the type code. }
function SQLParamKindOf(SQLType: Cardinal; Scale: Integer): TSQLParamKind;

implementation

function SQLParamKindOf(SQLType: Cardinal; Scale: Integer): TSQLParamKind;
begin
  case SQLType of
    SQL_SHORT, SQL_LONG, SQL_INT64:
      if Scale < 0 then
        Result := pkDecimal
      else
        Result := pkInteger;
    SQL_FLOAT, SQL_DOUBLE:
      Result := pkDecimal;
    SQL_TYPE_DATE:
      Result := pkDate;
    SQL_TYPE_TIME:
      Result := pkTime;
    SQL_TIMESTAMP:
      Result := pkDateTime;
    SQL_BOOLEAN:
      Result := pkBoolean;
  else
    Result := pkText;
  end;
end;

end.
