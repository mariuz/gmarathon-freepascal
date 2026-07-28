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

unit SchemaNames;

{$MODE Delphi}

{ Naming an object that lives in a schema.

  Firebird 6 (ODS 14) made a name two parts. Before it, RDB$RELATION_NAME was
  unique across the database and a query could find an object by name alone;
  now the same name can exist in as many schemas as there are, and a query that
  filters on name alone matches all of them at once.

  That is not a missing feature but a wrong answer. An editor whose column
  query says

    where rdb$relation_name = 'DUPTAB'

  against a database holding S_ALPHA.DUPTAB(A1, A2) and S_BETA.DUPTAB(B1, B2,
  B3) gets five rows back and shows a table with five columns, three of which
  belong to something else entirely. Every metadata query in the object editors
  had that shape.

  Two things are needed to fix one of those queries, and they are the two
  functions here: a predicate that narrows the query to one schema, and a way
  to write the object's name in generated DDL so it names the same object the
  query found.

  Neither needs a database or a widgetset, so both are tested without either.
  DDLExtractor worked all of this out first and now calls into this rather than
  keeping its own copy - having two implementations of "which schema is this"
  is how they end up disagreeing. }

interface

uses SysUtils;

{ The ' and (...)' fragment that narrows a catalogue query to one schema, ready
  to append to a WHERE clause that already has a condition in it.

  Alias is the table alias with its dot ('a.'), or '' for an unaliased query.
  Column is the schema column on the table being filtered, which is
  RDB$SCHEMA_NAME on most of the catalogue but not all of it. Read off a live
  Firebird 6 server rather than from the release notes, because several are not
  what one would guess:

    RDB$USER_PRIVILEGES     RDB$RELATION_SCHEMA_NAME for the object granted on
                            (RDB$USER_SCHEMA_NAME is the grantee's, not it)
    RDB$RELATION_FIELDS     RDB$SCHEMA_NAME is the table's;
                            RDB$FIELD_SOURCE_SCHEMA_NAME is the domain behind
                            the column, which is a different thing
    RDB$INDICES             RDB$SCHEMA_NAME is the index's;
                            RDB$FOREIGN_KEY_SCHEMA_NAME is the referenced table
    RDB$REF_CONSTRAINTS     RDB$CONST_SCHEMA_NAME_UQ - note the suffix
    RDB$DEPENDENCIES        both ends are named, RDB$DEPENDENT_SCHEMA_NAME and
                            RDB$DEPENDED_ON_SCHEMA_NAME

  Passing the wrong one filters on the wrong thing and quietly returns nothing,
  which looks exactly like an object that has no triggers or no privileges.

  Empty when the server has no schemas: naming RDB$SCHEMA_NAME on Firebird 5 is
  a hard error, not a null, so the fragment has to disappear entirely rather
  than evaluate to true.

  With no schema named it falls back to CURRENT_SCHEMA, which is what an
  unqualified name means. The null guard matters: with an empty search path
  CURRENT_SCHEMA is null, and without it every query would return nothing at
  all rather than everything. }
function SchemaPredicate(const Alias, Column, Schema: String;
  SupportsSchemas: Boolean): String; overload;
function SchemaPredicate(const Alias, Schema: String;
  SupportsSchemas: Boolean): String; overload;

{ The extra condition for a join from a table's columns to the domains behind
  them - RDB$RELATION_FIELDS or RDB$PROCEDURE_PARAMETERS to RDB$FIELDS.

  RDB$FIELD_SOURCE names the domain, and on Firebird 6 that name is only unique
  within a schema, so joining on it alone matches the domain in every schema
  that has one by that name. The column then shows whichever row the server
  handed back first: a column declared varchar(7) reads as varchar(19) because
  another schema has a domain of the same name.

  Which schema the domain is in is a column of its own,
  RDB$FIELD_SOURCE_SCHEMA_NAME - not the row's RDB$SCHEMA_NAME, which is the
  table's. Empty on servers without schemas, where the name is unique anyway. }
function FieldSourceJoin(const RelAlias, FieldAlias: String;
  SupportsSchemas: Boolean): String;

{ The object's name as DDL should spell it: qualified when a schema is named,
  bare when one is not, and quoted by the same rules the rest of the extractor
  uses. }
function QualifiedIdent(const Schema, ObjectName: String; IsIB6: Boolean;
  Dialect: Integer): String;

{ 'S_ALPHA.DUPTAB' as its two parts, and 'DUPTAB' as a name with no schema.
  Quoted parts are unquoted, so "My Schema"."My Table" splits on the dot
  between them rather than on one inside a name. Returns False when the text
  names no schema, in which case Name is the whole of it. }
function SplitSchemaName(const Text: String; out Schema, Name: String): Boolean;

{ How an object is named on screen and in a window caption: qualified only when
  it is in a schema worth mentioning, since 'PUBLIC.CUSTOMERS' everywhere would
  be noise on a database that has one schema. }
function DisplaySchemaName(const Schema, ObjectName: String): String;

implementation

uses SQLIdentifiers;

function SchemaPredicate(const Alias, Column, Schema: String;
  SupportsSchemas: Boolean): String;
begin
  if not SupportsSchemas then
    Result := ''
  else if Trim(Schema) <> '' then
    { A named schema is asked for exactly, not through CURRENT_SCHEMA - the
      point of naming one is to reach objects the search path does not. }
    Result := ' and (' + Alias + Column + ' = ' +
      AnsiQuotedStr(Trim(Schema), '''') + ')'
  else
    Result := ' and (' + Alias + Column +
      ' = current_schema or current_schema is null)';
end;

function SchemaPredicate(const Alias, Schema: String;
  SupportsSchemas: Boolean): String;
begin
  Result := SchemaPredicate(Alias, 'rdb$schema_name', Schema, SupportsSchemas);
end;

function FieldSourceJoin(const RelAlias, FieldAlias: String;
  SupportsSchemas: Boolean): String;
begin
  if not SupportsSchemas then
    Result := ''
  else
    Result := ' and (' + FieldAlias + 'rdb$schema_name = ' +
      RelAlias + 'rdb$field_source_schema_name)';
end;

function QualifiedIdent(const Schema, ObjectName: String; IsIB6: Boolean;
  Dialect: Integer): String;
begin
  Result := MakeQuotedIdent(Trim(ObjectName), IsIB6, Dialect);
  if Trim(Schema) <> '' then
    Result := MakeQuotedIdent(Trim(Schema), IsIB6, Dialect) + '.' + Result;
end;

function SplitSchemaName(const Text: String; out Schema, Name: String): Boolean;
var
  Trimmed: String;
  Idx: Integer;
  InQuote: Boolean;
  DotAt: Integer;
begin
  Schema := '';
  Name := Trim(Text);
  Trimmed := Name;
  Result := False;
  if Trimmed = '' then
    Exit;

  { The separating dot is the first one outside quotes. Scanning for it rather
    than taking the first dot is what keeps "My.Schema"."T" in one piece. }
  DotAt := 0;
  InQuote := False;
  for Idx := 1 to Length(Trimmed) do
  begin
    if Trimmed[Idx] = '"' then
      InQuote := not InQuote
    else if (Trimmed[Idx] = '.') and not InQuote then
    begin
      DotAt := Idx;
      Break;
    end;
  end;
  if DotAt = 0 then
    Exit;

  Schema := StripQuotesFromQuotedIdentifier(Trim(Copy(Trimmed, 1, DotAt - 1)));
  Name := StripQuotesFromQuotedIdentifier(Trim(Copy(Trimmed, DotAt + 1, MaxInt)));
  Result := Trim(Schema) <> '';
  if not Result then
    { A leading dot names no schema; treat the whole thing as a name rather
      than inventing an empty one. }
    Name := Trim(Text);
end;

function DisplaySchemaName(const Schema, ObjectName: String): String;
begin
  Result := Trim(ObjectName);
  if Trim(Schema) <> '' then
    Result := Trim(Schema) + '.' + Result;
end;

end.
