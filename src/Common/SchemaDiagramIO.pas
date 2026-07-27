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

unit SchemaDiagramIO;

{$MODE Delphi}

{ Reading the tables and their foreign keys out of the catalogue.

  Kept apart from SchemaDiagram so that unit needs no database: where the boxes
  go is decided there and checked without a server, and only the reading is
  here.

  Firebird records a foreign key in three places at once, which is why this is
  more than one query. RDB$RELATION_CONSTRAINTS says a constraint of type
  FOREIGN KEY exists on a table and names its index; RDB$REF_CONSTRAINTS pairs
  that constraint with the unique or primary key it points at; and the columns
  on each side are the segments of the two indexes, in RDB$INDEX_SEGMENTS. A
  compound key is several segments, matched by position. }

interface

uses SysUtils, Classes, DB, IBDatabase, IBQuery, SchemaDiagram;

{ Every table in the schema, with its columns and the foreign keys between
  them. The caller owns the result.

  ASchema selects one schema on Firebird 6; empty means whatever the search
  path reaches, which is what every other reader here does. }
function ReadSchemaDiagram(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ASchema: String = ''; ASupportsSchemas: Boolean = False): TSchemaDiagram;

implementation

uses SchemaNames;

function NewQuery(ADatabase: TIBDatabase; ATransaction: TIBTransaction): TIBQuery;
begin
  Result := TIBQuery.Create(nil);
  Result.Database := ADatabase;
  Result.Transaction := ATransaction;
  { The tree's queries commit constantly, so this often arrives on a closed
    transaction and IBX will not open one unless told it may. }
  Result.AllowAutoActivateTransaction := True;
end;

function ReadSchemaDiagram(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const ASchema: String; ASupportsSchemas: Boolean): TSchemaDiagram;
var
  Q: TIBQuery;
  T: TDiagramTable;
  Name: String;
begin
  Result := TSchemaDiagram.Create;
  if not Assigned(ADatabase) or not ADatabase.Connected then
    Exit;

  { The tables, with their columns in declaration order - the order they read
    in the diagram is the order they read in the table. }
  Q := NewQuery(ADatabase, ATransaction);
  try
    Q.SQL.Text :=
      'select rf.rdb$relation_name, rf.rdb$field_name ' +
      'from rdb$relation_fields rf ' +
      '  join rdb$relations r on r.rdb$relation_name = rf.rdb$relation_name ' +
      SchemaPredicate('r.', ASchema, ASupportsSchemas) +
      ' where ((r.rdb$system_flag = 0) or (r.rdb$system_flag is null)) ' +
      '  and r.rdb$view_source is null ' +
      'order by rf.rdb$relation_name, rf.rdb$field_position';
    Q.Open;
    while not Q.EOF do
    begin
      Name := Trim(Q.Fields[0].AsString);
      T := Result.AddTable(Name, ASchema);
      T.Columns.Add(Trim(Q.Fields[1].AsString));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;

  { The keys. Both ends come from the segments of the two indexes, matched by
    position so a compound key pairs its columns up rather than crossing
    them. }
  Q := NewQuery(ADatabase, ATransaction);
  try
    Q.SQL.Text :=
      'select rc.rdb$relation_name as FROM_TABLE, ' +
      '       s.rdb$field_name     as FROM_COLUMN, ' +
      '       uq.rdb$relation_name as TO_TABLE, ' +
      '       us.rdb$field_name    as TO_COLUMN, ' +
      '       rc.rdb$constraint_name as CONSTRAINT_NAME ' +
      'from rdb$relation_constraints rc ' +
      '  join rdb$ref_constraints ref ' +
      '    on ref.rdb$constraint_name = rc.rdb$constraint_name ' +
      '  join rdb$relation_constraints uq ' +
      '    on uq.rdb$constraint_name = ref.rdb$const_name_uq ' +
      '  join rdb$index_segments s on s.rdb$index_name = rc.rdb$index_name ' +
      '  join rdb$index_segments us on us.rdb$index_name = uq.rdb$index_name ' +
      '   and us.rdb$field_position = s.rdb$field_position ' +
      'where rc.rdb$constraint_type = ''FOREIGN KEY''' +
      SchemaPredicate('rc.', ASchema, ASupportsSchemas) +
      ' order by rc.rdb$constraint_name, s.rdb$field_position';
    Q.Open;
    while not Q.EOF do
    begin
      { A key naming a table outside this schema has nothing to draw to, so it
        is left out rather than drawn to nowhere. }
      if Assigned(Result.FindTable(Trim(Q.FieldByName('TO_TABLE').AsString))) and
         Assigned(Result.FindTable(Trim(Q.FieldByName('FROM_TABLE').AsString))) then
        Result.AddLink(Trim(Q.FieldByName('FROM_TABLE').AsString),
          Trim(Q.FieldByName('FROM_COLUMN').AsString),
          Trim(Q.FieldByName('TO_TABLE').AsString),
          Trim(Q.FieldByName('TO_COLUMN').AsString),
          Trim(Q.FieldByName('CONSTRAINT_NAME').AsString));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

end.
