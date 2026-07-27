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

unit SchemaObjects;

{$MODE Delphi}

{ Listing the objects of one kind in one schema.

  The object tree has always asked for what an unqualified name reaches, which
  is right when there is nowhere else to look but hides everything in any other
  schema. This answers the other question - what is in *this* schema - so a
  tree can offer those objects at all.

  LCL-free, so which objects a schema holds is checked against a real database
  in test/ibx_smoke_test.lpr rather than by opening a window and looking. }

interface

uses SysUtils, Classes, IBDatabase;

type
  { The kinds a schema can hold that the tree shows. Deliberately not the whole
    of TGSSCacheType: this unit answers about schema contents, and a connection
    or a folder is not that. }
  TSchemaObjectKind = (sokDomain, sokTable, sokView, sokProcedure,
    sokFunction, sokTrigger, sokGenerator, sokException, sokPackage);

{ The names of that kind in that schema, in name order.

  Schema empty means the current one, which is what the tree asked for before
  schemas existed and what a pre-Firebird-6 server has to be asked. On such a
  server the schema clause is omitted entirely, since RDB$SCHEMA_NAME is not
  there to filter on and naming it is a hard error rather than an empty
  result. }
function ListSchemaObjects(DB: TIBDatabase; Tr: TIBTransaction;
  Kind: TSchemaObjectKind; const Schema: String; HasSchemas: Boolean): TStringList;

{ Exposed for testing: the statement ListSchemaObjects runs. }
function SchemaObjectListSQL(Kind: TSchemaObjectKind; const Schema: String;
  HasSchemas: Boolean): String;

{ Every word the server reserves, from RDB$KEYWORDS.

  Firebird 5 added that table, so an older server has none and this comes back
  empty - which the caller takes as "use the built-in list". Asking the server
  beats keeping a list here: it is right for the server in front of the user,
  needs no maintenance when Firebird adds a word, and does not highlight a
  feature the server does not have. }
function ReadServerKeywords(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction): TStringList;

implementation

uses IBQuery;

function SchemaObjectListSQL(Kind: TSchemaObjectKind; const Schema: String;
  HasSchemas: Boolean): String;
const
  NotSystem = '((rdb$system_flag = 0) or (rdb$system_flag is null))';
var
  SchemaClause, NotPackaged: String;
begin
  if not HasSchemas then
    SchemaClause := ''
  else if Trim(Schema) <> '' then
    SchemaClause := ' and (rdb$schema_name = ' + AnsiQuotedStr(Trim(Schema), '''') + ')'
  else
    { The null guard is load-bearing: CURRENT_SCHEMA is null when the search
      path is empty, and without it every list would come back empty rather
      than unfiltered. }
    SchemaClause := ' and (rdb$schema_name = current_schema or current_schema is null)';

  { A routine belonging to a package is created by its package's DDL, so it is
    not listed in its own right. }
  if HasSchemas then
    NotPackaged := ' and rdb$package_name is null'
  else
    NotPackaged := '';

  case Kind of
    sokDomain:
      { The RDB$ test is not redundant with the system flag: Firebird puts a
        row here for every column of every table, named RDB$1 upwards and
        flagged 0 exactly as a user's domain is. }
      Result := 'select rdb$field_name from rdb$fields where ' + NotSystem +
        ' and (rdb$field_name not starting with ''RDB$'')' + SchemaClause;
    sokTable:
      Result := 'select rdb$relation_name from rdb$relations where ' + NotSystem +
        ' and rdb$view_source is null' + SchemaClause;
    sokView:
      Result := 'select rdb$relation_name from rdb$relations where ' + NotSystem +
        ' and rdb$view_source is not null' + SchemaClause;
    sokProcedure:
      Result := 'select rdb$procedure_name from rdb$procedures where ' + NotSystem +
        NotPackaged + SchemaClause;
    sokFunction:
      Result := 'select rdb$function_name from rdb$functions where ' + NotSystem +
        NotPackaged + SchemaClause;
    sokTrigger:
      Result := 'select rdb$trigger_name from rdb$triggers where ' + NotSystem +
        ' and rdb$trigger_source is not null' + SchemaClause;
    sokGenerator:
      Result := 'select rdb$generator_name from rdb$generators where ' + NotSystem +
        SchemaClause;
    sokException:
      Result := 'select rdb$exception_name from rdb$exceptions where ' + NotSystem +
        SchemaClause;
    sokPackage:
      Result := 'select rdb$package_name from rdb$packages where ' + NotSystem +
        SchemaClause;
  else
    Result := '';
  end;
  if Result <> '' then
    Result := Result + ' order by 1';
end;

function ListSchemaObjects(DB: TIBDatabase; Tr: TIBTransaction;
  Kind: TSchemaObjectKind; const Schema: String; HasSchemas: Boolean): TStringList;
var
  Q: TIBQuery;
  SQL: String;
begin
  Result := TStringList.Create;
  SQL := SchemaObjectListSQL(Kind, Schema, HasSchemas);
  if SQL = '' then
    Exit;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := DB;
    Q.Transaction := Tr;
    { The shared transaction is committed by anything else on this connection,
      so being asked to list without one open is the normal case. }
    if Assigned(Tr) and not Tr.Active then
      Tr.StartTransaction;
    Q.SQL.Text := SQL;
    Q.Open;
    while not Q.EOF do
    begin
      Result.Add(Trim(Q.Fields[0].AsString));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function ReadServerKeywords(ADatabase: TIBDatabase;
  ATransaction: TIBTransaction): TStringList;
var
  Q: TIBQuery;
begin
  Result := TStringList.Create;
  if not Assigned(ADatabase) or not ADatabase.Connected then
    Exit;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := ADatabase;
    Q.Transaction := ATransaction;
    Q.AllowAutoActivateTransaction := True;
    { RDB$RESERVED tells a reserved word from one that is merely recognised;
      both are worth painting, so both are taken. }
    Q.SQL.Text := 'select rdb$keyword_name from rdb$keywords';
    try
      Q.Open;
      while not Q.EOF do
      begin
        Result.Add(Trim(Q.Fields[0].AsString));
        Q.Next;
      end;
      Q.Close;
    except
      { No such table: a server older than Firebird 5. Empty is the answer, and
        the caller falls back to the built-in list. }
      on E: Exception do
        Result.Clear;
    end;
  finally
    Q.Free;
  end;
end;

end.
