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

unit SchemaCompare;

{$MODE Delphi}

{ Compares the metadata of two databases and writes a script that moves the
  target towards the source.

  What it does, and what it deliberately does not:

  - Objects in the source and not the target are emitted as CREATE, in an order
    that respects the obvious dependencies (domains and generators before the
    tables that use them, tables before the views and routines over them).
  - Objects in the target and not the source are emitted as DROP, but **always
    commented out**. Dropping is the one direction that destroys data, and a
    generated script should not be able to do that by being run without being
    read.
  - Objects in both whose DDL differs are reported. Where Firebird has a form
    that redefines the whole object - a view, trigger, procedure, PSQL function
    or package - the replacement is emitted and is safe to run. A table that
    differs is reported as a comment only: the difference could be a column
    added, dropped, retyped or renamed, and guessing wrong writes a migration
    that silently loses a column.

  The comparison is by extracted DDL text, so it sees anything DDLExtractor
  renders and nothing it does not. That is a real limit worth knowing: two
  objects that differ only in something the extractor omits will compare equal.

  LCL-free so test/ibx_smoke_test.lpr can run a comparison between two real
  databases. }

interface

uses SysUtils, Classes, ScriptAs, MarathonProjectCacheTypes;

type
  { What a comparison found, so a caller can report a summary without parsing
    the script back. }
  TSchemaDifferences = record
    ToCreate: Integer;
    ToDrop: Integer;
    Changed: Integer;
    { Objects that differ but cannot be migrated automatically - tables, in
      practice - which the script reports rather than rewrites. }
    NeedingAttention: Integer;
  end;

{ Writes a migration script taking Target towards Source. Differences, if
  passed, receives the counts. }
function CompareSchemas(const Source, Target: TScriptAsContext;
  out Differences: TSchemaDifferences): String;

implementation

uses IBDatabase, IBQuery;

type
  TComparedKind = record
    Caption: String;
    CacheType: TGSSCacheType;
    ListSQL: String;
    { True when Firebird can redefine the object wholesale, so a difference can
      be migrated by emitting the replacement. }
    Replaceable: Boolean;
  end;

  TComparedKinds = array of TComparedKind;

{ The kinds to compare, ordered so that a script run top to bottom creates
  things before whatever depends on them.

  HasPackages says whether this server has RDB$PACKAGE_NAME - Firebird 3 and
  later. Where it does, a routine that belongs to a package is skipped: it is
  created by its package's DDL, and listing it here would emit it twice.

  The system-flag test is enough to keep the catalogue's own objects out, and
  it also covers the triggers Firebird writes for CHECK constraints: those
  carry RDB$SYSTEM_FLAG = 4 (verified on Firebird 6), so no separate
  RDB$CHECK_CONSTRAINTS exclusion is needed. Domains are the exception - the
  implicit per-column ones are flagged 0, like a user's, and are told apart
  only by their RDB$ name. }
function ComparedKinds(HasPackages: Boolean): TComparedKinds;
const
  NotSystem = '((rdb$system_flag = 0) or (rdb$system_flag is null))';
var
  NotPackaged: String;
begin
  if HasPackages then
    NotPackaged := ' and rdb$package_name is null'
  else
    NotPackaged := '';

  SetLength(Result, 8);

  Result[0].Caption := 'Domains';
  Result[0].CacheType := ctDomain;
  Result[0].ListSQL := 'select rdb$field_name from rdb$fields where ' +
    NotSystem + ' and (rdb$field_name not starting with ''RDB$'') order by 1';
  Result[0].Replaceable := False;

  Result[1].Caption := 'Generators';
  Result[1].CacheType := ctGenerator;
  Result[1].ListSQL := 'select rdb$generator_name from rdb$generators where ' +
    NotSystem + ' order by 1';
  Result[1].Replaceable := False;

  Result[2].Caption := 'Exceptions';
  Result[2].CacheType := ctException;
  Result[2].ListSQL := 'select rdb$exception_name from rdb$exceptions where ' +
    NotSystem + ' order by 1';
  Result[2].Replaceable := False;

  Result[3].Caption := 'Tables';
  Result[3].CacheType := ctTable;
  Result[3].ListSQL := 'select rdb$relation_name from rdb$relations where ' +
    NotSystem + ' and rdb$view_source is null order by 1';
  Result[3].Replaceable := False;

  Result[4].Caption := 'Views';
  Result[4].CacheType := ctView;
  Result[4].ListSQL := 'select rdb$relation_name from rdb$relations where ' +
    NotSystem + ' and rdb$view_source is not null order by 1';
  Result[4].Replaceable := True;

  Result[5].Caption := 'Stored procedures';
  Result[5].CacheType := ctSP;
  Result[5].ListSQL := 'select rdb$procedure_name from rdb$procedures where ' +
    NotSystem + NotPackaged + ' order by 1';
  Result[5].Replaceable := True;

  Result[6].Caption := 'Functions';
  Result[6].CacheType := ctUDF;
  Result[6].ListSQL := 'select rdb$function_name from rdb$functions where ' +
    NotSystem + NotPackaged + ' order by 1';
  Result[6].Replaceable := True;

  Result[7].Caption := 'Triggers';
  Result[7].CacheType := ctTrigger;
  Result[7].ListSQL := 'select rdb$trigger_name from rdb$triggers where ' +
    NotSystem + ' and rdb$trigger_source is not null order by 1';
  Result[7].Replaceable := True;
end;

function ObjectNames(const Ctx: TScriptAsContext; const SQL: String): TStringList;
var
  Q: TIBQuery;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := Ctx.Database;
    Q.Transaction := Ctx.Transaction;
    if Assigned(Q.Transaction) and not Q.Transaction.Active then
      Q.Transaction.StartTransaction;
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

{ The whole DDL for one object, which is what the comparison is made on. }
function ObjectDDL(const Ctx: TScriptAsContext; const Name: String;
  CacheType: TGSSCacheType): String;
begin
  Result := ScriptAsCreate(Ctx, Name, CacheType);
end;

function CompareSchemas(const Source, Target: TScriptAsContext;
  out Differences: TSchemaDifferences): String;
var
  Script: TStringList;
  SourceKinds, TargetKinds: TComparedKinds;
  K, Idx: Integer;
  InSource, InTarget: TStringList;
  SourceDDL, TargetDDL: String;
  Header: Boolean;

  procedure Section(const Caption: String; var Emitted: Boolean);
  begin
    if not Emitted then
    begin
      Script.Add('');
      Script.Add('/* ---- ' + Caption + ' ---- */');
      Emitted := True;
    end;
  end;

begin
  Differences.ToCreate := 0;
  Differences.ToDrop := 0;
  Differences.Changed := 0;
  Differences.NeedingAttention := 0;

  Script := TStringList.Create;
  try
    Script.Add('/* Migration script generated by comparing two databases.');
    Script.Add('');
    Script.Add('   Read it before running it. DROP statements are commented out');
    Script.Add('   deliberately - dropping is the only direction that destroys');
    Script.Add('   data, and a generated script should not be able to do that by');
    Script.Add('   being run without being read. Tables that differ are reported');
    Script.Add('   rather than altered, because the difference could be a column');
    Script.Add('   added, dropped, retyped or renamed and guessing wrong loses');
    Script.Add('   data. */');

    { Listed with each side's own capabilities: the two databases can be on
      different servers, and asking an older one for RDB$PACKAGE_NAME is an
      error rather than a null. }
    SourceKinds := ComparedKinds(Source.EngineMajor >= 3);
    TargetKinds := ComparedKinds(Target.EngineMajor >= 3);
    for K := 0 to High(SourceKinds) do
    begin
      Header := False;
      InSource := ObjectNames(Source, SourceKinds[K].ListSQL);
      InTarget := ObjectNames(Target, TargetKinds[K].ListSQL);
      try
        { Present in the source only - create it. }
        for Idx := 0 to InSource.Count - 1 do
          if InTarget.IndexOf(InSource[Idx]) < 0 then
          begin
            Section(SourceKinds[K].Caption, Header);
            Script.Add('');
            Script.Add('/* missing from target */');
            Script.Add(Trim(ObjectDDL(Source, InSource[Idx], SourceKinds[K].CacheType)));
            Inc(Differences.ToCreate);
          end;

        { Present in both - compare, and replace where that is safe. }
        for Idx := 0 to InSource.Count - 1 do
          if InTarget.IndexOf(InSource[Idx]) >= 0 then
          begin
            SourceDDL := Trim(ObjectDDL(Source, InSource[Idx], SourceKinds[K].CacheType));
            TargetDDL := Trim(ObjectDDL(Target, InSource[Idx], SourceKinds[K].CacheType));
            if SourceDDL <> TargetDDL then
            begin
              Section(SourceKinds[K].Caption, Header);
              Script.Add('');
              if SourceKinds[K].Replaceable then
              begin
                { Compared on the CREATE form, but emitted as the ALTER one.
                  The object already exists in the target, so a CREATE would
                  fail on the name; ScriptAsAlter renders each replaceable kind
                  in the form Firebird accepts against an existing object -
                  ALTER VIEW, ALTER TRIGGER, ALTER PROCEDURE, CREATE OR ALTER
                  for a PSQL function or package. }
                Script.Add('/* differs - redefining */');
                Script.Add(Trim(ScriptAsAlter(Source, InSource[Idx],
                  SourceKinds[K].CacheType)));
                Inc(Differences.Changed);
              end
              else
              begin
                Script.Add('/* ' + InSource[Idx] + ' differs and cannot be migrated');
                Script.Add('   automatically. Source definition, for reference:');
                Script.Add('');
                Script.Add(SourceDDL);
                Script.Add('*/');
                Inc(Differences.NeedingAttention);
              end;
            end;
          end;

        { Present in the target only - drop it, commented out. }
        for Idx := 0 to InTarget.Count - 1 do
          if InSource.IndexOf(InTarget[Idx]) < 0 then
          begin
            Section(SourceKinds[K].Caption, Header);
            Script.Add('');
            Script.Add('/* only in target - uncomment to remove */');
            Script.Add('-- ' + Trim(ScriptAsDrop(Target, InTarget[Idx], SourceKinds[K].CacheType)));
            Inc(Differences.ToDrop);
          end;
      finally
        InTarget.Free;
        InSource.Free;
      end;
    end;

    if (Differences.ToCreate = 0) and (Differences.ToDrop = 0) and
       (Differences.Changed = 0) and (Differences.NeedingAttention = 0) then
    begin
      Script.Add('');
      Script.Add('/* No differences found. */');
    end;

    Result := Script.Text;
  finally
    Script.Free;
  end;
end;

end.
