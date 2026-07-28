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

unit ObjectCatalogue;

{ Which catalogue table holds which kind of object, and the query that asks
  whether one is there.

  This was nine copies of the same twenty lines in Globals.DoesObjectExist,
  differing only in the table and column names - and each copy also carried its
  own fallback, its own transaction handling and its own error dialog, so a fix
  to any of it reached one kind. The knowledge is a mapping, so it is one here,
  and the query is built once.

  Views live in RDB$RELATIONS with tables and domains in RDB$FIELDS with every
  column's implicit domain: this answers "is there an object of that name",
  which is what the callers ask before opening or creating one, not "is it of
  exactly this kind".

  No LCL and no IBX - a table name and a column name are strings. }

{$MODE Delphi}

interface

uses SysUtils, MarathonProjectCacheTypes;

{ The catalogue table and name column for that kind of object. False when the
  kind is not one that lives in a catalogue of its own - a column or an index
  belongs to a table and is not looked up this way. }
function CatalogueTableFor(AKind: TGSSCacheType;
  out ATable, AColumn: String): Boolean;

{ Asks whether an object of that name is in that catalogue. ASchemaClause is
  appended as given - it already begins with "and" when there is one, and is
  empty on a server without schemas. }
function ObjectExistsSQL(const ATable, AColumn, AName,
  ASchemaClause: String): String;

implementation

function CatalogueTableFor(AKind: TGSSCacheType;
  out ATable, AColumn: String): Boolean;
begin
  Result := True;
  case AKind of
    { A view is a relation with a view source, so both look here. }
    ctTable, ctView:
      begin
        ATable := 'rdb$relations';
        AColumn := 'rdb$relation_name';
      end;
    ctTrigger:
      begin
        ATable := 'rdb$triggers';
        AColumn := 'rdb$trigger_name';
      end;
    ctSP:
      begin
        ATable := 'rdb$procedures';
        AColumn := 'rdb$procedure_name';
      end;
    ctGenerator:
      begin
        ATable := 'rdb$generators';
        AColumn := 'rdb$generator_name';
      end;
    ctException:
      begin
        ATable := 'rdb$exceptions';
        AColumn := 'rdb$exception_name';
      end;
    { Firebird 3 and later. RDB$PACKAGES does not exist on an older server and
      asking is a hard error rather than an empty answer, which is why the
      caller runs these queries inside a try. }
    ctPackage:
      begin
        ATable := 'rdb$packages';
        AColumn := 'rdb$package_name';
      end;
    { Both a legacy external UDF and a Firebird 3 PSQL function. }
    ctUDF:
      begin
        ATable := 'rdb$functions';
        AColumn := 'rdb$function_name';
      end;
    ctDomain:
      begin
        ATable := 'rdb$fields';
        AColumn := 'rdb$field_name';
      end;
  else
    ATable := '';
    AColumn := '';
    Result := False;
  end;
end;

function ObjectExistsSQL(const ATable, AColumn, AName,
  ASchemaClause: String): String;
begin
  Result := 'select ' + AColumn + ' from ' + ATable +
    ' where ' + AColumn + ' = ' + AnsiQuotedStr(AName, '''') + ASchemaClause;
end;

end.
