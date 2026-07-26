program ibx_smoke_test;

{ Standalone smoke test for the IBX (MWASoftware ibx4lazarus) database layer.
  Connects to a real Firebird server, creates a table, writes and reads a row,
  and verifies the round trip, then exercises DDLExtractor (Marathon's DDL
  scripting engine) against a table, a view, a stored procedure, and a
  trigger built on that table - each object type is its own code path in
  DDLExtractor.pas. Used by CI to prove the IBX conversion and DDL extraction
  actually work against Firebird, not just that the app compiles.

  Also round-trips the modern (Firebird 3+) column types through
  ConvertFieldType, gated on the connected server's engine version, since
  those types silently produced unusable DDL (the internal RDB$nn domain name
  in place of the type) before they were mapped. }

{$MODE Delphi}

uses
  SysUtils, Classes, BufDataset, IB, IBDatabase, IBQuery, IBSQL, DDLExtractor,
  MarathonProjectCacheTypes, ScriptAs, SingletonQuery, SQLStatementText, XlsxWriter,
  ProfilerQueries, SafeDisconnect, SchemaCompare, ibxscript;

var
  DB: TIBDatabase;
  Tr: TIBTransaction;
  Q: TIBQuery;
  Extractor: TDDLExtractor;
  DatabaseName, UserName, Password: String;
  Value: String;
  DDL: String;
  EngineVersion: String;
  EngineMajor: Integer;
  Ctx: TScriptAsContext;
  PositionalCtx: TScriptAsContext;
  Script: String;
  Single: TBufDataset;
  ParamMeta: TIBSQL;
  Cols: TStringList;
  ProfileId: Int64;
  Prefix: String;
  FaultDB: TIBDatabase;
  FaultTr: TIBTransaction;
  FaultQ: TIBQuery;

{ The generators end their statements the way a user would type them; the API
  takes one statement without the terminator. }
function StripTrailingSemicolon(const SQLText: String): String;
begin
  Result := TrimRight(SQLText);
  while (Result <> '') and (Result[Length(Result)] = ';') do
    Result := TrimRight(Copy(Result, 1, Length(Result) - 1));
end;

{ The Script As generators run their own metadata queries and commit the
  transaction when they are done, so a caller cannot assume one is still open
  afterwards. }
procedure EnsureTransaction;
begin
  if not Tr.Active then
    Tr.StartTransaction;
end;

{ Compiles a statement without running it. Firebird still parses it and
  resolves every name, so a wrong verb or a bad identifier fails here - which
  is what we want for DROP, where actually executing would destroy the objects
  the rest of the run depends on. }
procedure PrepareOnly(const SQLText, What: String);
var
  S: TIBSQL;
begin
  S := TIBSQL.Create(nil);
  try
    EnsureTransaction;
    S.Database := DB;
    S.Transaction := Tr;
    S.SQL.Text := StripTrailingSemicolon(SQLText);
    try
      S.Prepare;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: generated ', What, ' did not compile: ', E.Message);
        WriteLn(SQLText);
        Halt(1);
      end;
    end;
  finally
    S.Free;
  end;
end;

{ Checks IsExplainRequest against one input, including what it hands back as
  the statement to actually prepare. }
procedure CheckExplain(const Input: String; ExpectIsExplain: Boolean; const ExpectInner: String);
var
  Inner: String;
  Got: Boolean;
begin
  Got := IsExplainRequest(Input, Inner);
  if Got <> ExpectIsExplain then
  begin
    WriteLn('FAIL: IsExplainRequest("', Input, '") returned ', Got, ', expected ', ExpectIsExplain);
    Halt(1);
  end;
  if Got and (Inner <> ExpectInner) then
  begin
    WriteLn('FAIL: IsExplainRequest("', Input, '") gave inner SQL "', Inner,
      '", expected "', ExpectInner, '"');
    Halt(1);
  end;
end;

{ Fails the test run unless Needle appears in the extracted DDL. }
procedure RequireInDDL(const DDLText, Needle, What: String);
begin
  if Pos(UpperCase(Needle), UpperCase(DDLText)) = 0 then
  begin
    WriteLn('FAIL: extracted DDL is missing ', What, ' (expected "', Needle, '"):');
    WriteLn(DDLText);
    Halt(1);
  end;
end;

{ 'localhost:' out of 'localhost:/tmp/db.fdb', so the databases this test makes
  are reached the same way as the one it was pointed at - a local path when the
  caller used one, and over the network when they did not. Matched on ':/'
  rather than ':' so a Windows drive letter is not mistaken for a host. }
function HostPrefixOf(const FullName: String): String;
var
  P: Integer;
begin
  P := Pos(':/', FullName);
  if P > 1 then
    Result := Copy(FullName, 1, P)
  else
    Result := '';
end;

procedure RequireNotInDDL(const DDLText, Needle, What: String);
begin
  if Pos(UpperCase(Needle), UpperCase(DDLText)) <> 0 then
  begin
    WriteLn('FAIL: ', What, ' should not appear ("', Needle, '"):');
    WriteLn(DDLText);
    Halt(1);
  end;
end;

{ Two throwaway databases with known differences, compared, and then the
  generated script run against the target to see whether it actually closes
  them. Anything less proves only that a script was produced. }
procedure TestSchemaCompare(const HostPrefix: String);
var
  SrcDB, TgtDB: TIBDatabase;
  SrcTr, TgtTr: TIBTransaction;
  SrcCtx, TgtCtx: TScriptAsContext;
  Diff, Diff2: TSchemaDifferences;
  MigrationScript: String;
  Runner: TIBXScript;
  Lines: TStringList;

  { A leftover from an aborted run has to go through the server: the file
    belongs to the account Firebird runs as, so deleting it from here fails and
    the CreateDatabase that follows then fails on "file already exists". }
  procedure DropIfExists(const Path: String);
  var
    Old: TIBDatabase;
  begin
    Old := TIBDatabase.Create(nil);
    try
      Old.DatabaseName := HostPrefix + Path;
      Old.Params.Values['user_name'] := UserName;
      Old.Params.Values['password'] := Password;
      Old.LoginPrompt := False;
      try
        Old.Connected := True;
        Old.DropDatabase;
      except
        { Not there, or not ours to drop - either way CreateDatabase is about
          to say so far more precisely than this could. }
        on E: Exception do ;
      end;
    finally
      Old.Free;
    end;
  end;

  procedure Build(var ADB: TIBDatabase; var ATr: TIBTransaction;
    const Path: String; Statements: array of String);
  var
    Idx: Integer;
    S: TIBSQL;
  begin
    DropIfExists(Path);
    ADB := TIBDatabase.Create(nil);
    ATr := TIBTransaction.Create(nil);
    ADB.DatabaseName := HostPrefix + Path;
    ADB.Params.Values['user_name'] := UserName;
    ADB.Params.Values['password'] := Password;
    ADB.Params.Values['lc_ctype'] := 'UTF8';
    ADB.LoginPrompt := False;
    ADB.SQLDialect := 3;
    ATr.DefaultDatabase := ADB;
    ADB.DefaultTransaction := ATr;
    ADB.CreateDatabase;
    for Idx := 0 to High(Statements) do
    begin
      if not ATr.Active then
        ATr.StartTransaction;
      S := TIBSQL.Create(nil);
      try
        S.Database := ADB;
        S.Transaction := ATr;
        S.SQL.Text := Statements[Idx];
        try
          S.ExecQuery;
        except
          on E: Exception do
          begin
            WriteLn('FAIL: could not build comparison database ', Path, ': ', E.Message);
            WriteLn(Statements[Idx]);
            Halt(1);
          end;
        end;
      finally
        S.Free;
      end;
      if ATr.Active then
        ATr.Commit;
    end;
  end;

begin
  { The source has objects of every compared kind. The target shares BOTH_TBL
    unchanged, redefines V_SHARED, is missing everything else, and has one
    table of its own to be offered for dropping. }
  Build(SrcDB, SrcTr, '/tmp/marathon_cmp_src.fdb', [
    'create domain D_CODE as varchar(10) not null',
    'create generator G_SEQ',
    'create exception E_BAD ''something went wrong''',
    'create table BOTH_TBL (ID integer not null primary key)',
    'create table ONLY_SRC (ID integer not null primary key, CODE D_CODE)',
    'create view V_SHARED as select ID from BOTH_TBL',
    'create procedure P_ONLY_SRC (A integer) returns (R integer) as ' +
      'begin R = A + 1; suspend; end',
    'create function F_ONLY_SRC (A integer) returns integer as begin return A * 2; end',
    'create trigger TR_BOTH for BOTH_TBL after insert as begin end']);

  Build(TgtDB, TgtTr, '/tmp/marathon_cmp_tgt.fdb', [
    'create table BOTH_TBL (ID integer not null primary key)',
    'create table ONLY_TGT (ID integer not null primary key)',
    { Same name, different body - the case a comparison exists to catch. }
    'create view V_SHARED as select ID + 0 as ID from BOTH_TBL']);

  try
    SrcCtx := ScriptAsContext(SrcDB, SrcTr, True, 3, EngineMajor);
    TgtCtx := ScriptAsContext(TgtDB, TgtTr, True, 3, EngineMajor);

    { These two databases are UTF8, so they also pin the character-length fix.
      D_CODE was declared varchar(10); the catalogue stores RDB$FIELD_LENGTH =
      40 and RDB$CHARACTER_LENGTH = 10, and reading the byte length rendered it
      as varchar(40) - which made a DDL round trip quadruple every string
      column, and stopped the comparison below from ever converging. }
    RequireInDDL(ScriptAsCreate(SrcCtx, 'D_CODE', ctDomain), 'varchar(10)',
      'the domain''s length in characters rather than bytes');
    RequireNotInDDL(ScriptAsCreate(SrcCtx, 'ONLY_SRC', ctTable), 'varchar(40)',
      'a column widened by reading the byte length');

    MigrationScript := CompareSchemas(SrcCtx, TgtCtx, Diff);

    { The implicit RDB$n domains must not be in here. Every table column makes
      one, so if they leaked in they would swamp the script - and each would be
      emitted as a CREATE DOMAIN that then fails on the reserved name. }
    RequireNotInDDL(MigrationScript, 'create domain RDB$', 'an implicit domain');

    RequireInDDL(MigrationScript, 'D_CODE', 'the missing domain');
    RequireInDDL(MigrationScript, 'G_SEQ', 'the missing generator');
    RequireInDDL(MigrationScript, 'E_BAD', 'the missing exception');
    RequireInDDL(MigrationScript, 'ONLY_SRC', 'the missing table');
    RequireInDDL(MigrationScript, 'P_ONLY_SRC', 'the missing procedure');
    RequireInDDL(MigrationScript, 'F_ONLY_SRC', 'the missing function');
    RequireInDDL(MigrationScript, 'TR_BOTH', 'the missing trigger');
    RequireInDDL(MigrationScript, '/* differs - redefining */', 'the changed view');
    RequireInDDL(MigrationScript, '-- drop table', 'the commented-out drop');

    { BOTH_TBL is identical on both sides, so it must not be recreated. Its
      name still appears - the view and trigger select from it - so the test is
      that no CREATE TABLE names it. }
    RequireNotInDDL(MigrationScript, 'create table BOTH_TBL', 'an unchanged table');

    if Diff.ToDrop <> 1 then
    begin
      WriteLn('FAIL: expected exactly one object to drop, got ', Diff.ToDrop);
      Halt(1);
    end;
    if Diff.Changed <> 1 then
    begin
      WriteLn('FAIL: expected exactly one redefinition, got ', Diff.Changed);
      Halt(1);
    end;
    WriteLn('Schema comparison OK (', Diff.ToCreate, ' to create, ',
      Diff.Changed, ' to redefine, ', Diff.ToDrop, ' to drop, ',
      Diff.NeedingAttention, ' needing attention)');

    { Now the part that matters: run it, and compare again. The drops stay
      commented out, so the one remaining difference afterwards should be
      exactly that - which is also what proves the drops really were inert. }
    Runner := TIBXScript.Create(nil);
    Lines := TStringList.Create;
    try
      Runner.Database := TgtDB;
      Runner.Transaction := TgtTr;
      Runner.Echo := False;
      Runner.StopOnFirstError := True;
      Lines.Text := MigrationScript;
      if not Runner.RunScript(Lines) then
      begin
        WriteLn('FAIL: the generated migration script did not run against the target:');
        WriteLn(MigrationScript);
        Halt(1);
      end;
    finally
      Lines.Free;
      Runner.Free;
    end;

    if TgtTr.Active then
      TgtTr.Commit;

    MigrationScript := CompareSchemas(SrcCtx, TgtCtx, Diff2);
    if (Diff2.ToCreate <> 0) or (Diff2.Changed <> 0) or
       (Diff2.NeedingAttention <> 0) then
    begin
      WriteLn('FAIL: the migration did not converge - still ', Diff2.ToCreate,
        ' to create, ', Diff2.Changed, ' to redefine, ', Diff2.NeedingAttention,
        ' needing attention');
      WriteLn(MigrationScript);
      Halt(1);
    end;
    if Diff2.ToDrop <> 1 then
    begin
      WriteLn('FAIL: the commented-out drop was not inert - ', Diff2.ToDrop,
        ' objects to drop, expected the same 1');
      Halt(1);
    end;
    WriteLn('Migration script converges (only the commented-out drop remains)');
  finally
    if SrcTr.Active then
      SrcTr.Rollback;
    if TgtTr.Active then
      TgtTr.Rollback;
    SrcDB.DropDatabase;
    TgtDB.DropDatabase;
    SrcTr.Free;
    SrcDB.Free;
    TgtTr.Free;
    TgtDB.Free;
  end;
end;

begin
  if ParamCount < 3 then
  begin
    WriteLn('Usage: ibx_smoke_test <database> <user> <password>');
    Halt(2);
  end;

  DatabaseName := ParamStr(1);
  UserName := ParamStr(2);
  Password := ParamStr(3);

  DB := TIBDatabase.Create(nil);
  Tr := TIBTransaction.Create(nil);
  Q := TIBQuery.Create(nil);
  try
    Tr.DefaultDatabase := DB;

    DB.DatabaseName := DatabaseName;
    DB.Params.Values['user_name'] := UserName;
    DB.Params.Values['password'] := Password;
    DB.LoginPrompt := False;
    DB.CreateIfNotExists := True;

    WriteLn('Connecting to ', DatabaseName, ' ...');
    DB.Connected := True;
    WriteLn('Connected. SQLDialect=', DB.SQLDialect);

    Q.Database := DB;
    Q.Transaction := Tr;

    { Drop objects left over from a previous run, in dependency order, before
      recreating the table - "recreate table" refuses to drop a table that
      other objects still depend on. Each drop is best-effort: ignore
      "doesn't exist" failures on a first-ever run. }
    Tr.StartTransaction;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_test_trig';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop procedure ibx_smoke_test_proc';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop view ibx_smoke_test_view';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_types';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop index ibx_smoke_ix_expr';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop index ibx_smoke_ix_part';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_ident';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop function ibx_smoke_fn';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_trg_multi';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop trigger ibx_smoke_trg_conn';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop package ibx_smoke_pkg';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop package ibx_smoke_pkg_nobody';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop procedure ibx_smoke_out';
      Q.ExecSQL;
    except
    end;
    try
      Q.SQL.Text := 'drop table ibx_smoke_tz';
      Q.ExecSQL;
    except
    end;
    Tr.Commit;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'recreate table ibx_smoke_test (id integer not null primary key, note varchar(50))';
      Q.ExecSQL;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not create table: ', E.Message);
        Halt(1);
      end;
    end;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (1, ''ibx works'')';
      Q.ExecSQL;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not insert row: ', E.Message);
        Halt(1);
      end;
    end;

    Tr.StartTransaction;
    try
      Q.SQL.Text := 'select note from ibx_smoke_test where id = 1';
      Q.Open;
      if Q.EOF then
      begin
        WriteLn('FAIL: no row returned');
        Halt(1);
      end;
      Value := Q.FieldByName('note').AsString;
      Q.Close;
      Tr.Commit;
    except
      on E: Exception do
      begin
        WriteLn('FAIL: could not query row: ', E.Message);
        Halt(1);
      end;
    end;

    if Trim(Value) <> 'ibx works' then
    begin
      WriteLn('FAIL: expected ''ibx works'', got ''', Value, '''');
      Halt(1);
    end;

    Extractor := TDDLExtractor.Create(nil);
    try
      Extractor.Database := DB;
      Extractor.Transaction := Tr;
      Extractor.SQLDialect := DB.SQLDialect;
      Extractor.IsInterbase6 := True;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_TEST');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;

      if (Pos('CREATE TABLE', UpperCase(DDL)) = 0) or (Pos('NOTE', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (table):');
      WriteLn(DDL);

      { Round-trip DDLExtractor against a view, a stored procedure, and a
        trigger too, not just a plain table - each code path in
        DDLExtractor.pas has its own metadata queries and is worth its own
        regression coverage. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter view ibx_smoke_test_view as select id, note from ibx_smoke_test';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create view: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        Q.SQL.Text :=
          'create or alter procedure ibx_smoke_test_proc (a_id integer) ' +
          'returns (a_note varchar(50)) ' +
          'as ' +
          'begin ' +
          '  select note from ibx_smoke_test where id = :a_id into :a_note; ' +
          '  suspend; ' +
          'end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create procedure: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        Q.SQL.Text :=
          'create or alter trigger ibx_smoke_test_trig for ibx_smoke_test ' +
          'active before insert position 0 ' +
          'as ' +
          'begin ' +
          'end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: could not create trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlView, ddlstNone, 'IBX_SMOKE_TEST_VIEW');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: view DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if (Pos('CREATE VIEW', UpperCase(DDL)) = 0) or (Pos('IBX_SMOKE_TEST_VIEW', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted view DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (view):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlStoredProc, ddlstNone, 'IBX_SMOKE_TEST_PROC');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: procedure DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      { ExtractStoredProcedure (ddlstNone) always emits the "alter procedure"
        body form - it's meant to follow a separate ddlstHeader "create
        procedure" stub for round-tripping procedures with forward
        references, matching how Phase 2's "Script as CREATE" already uses
        this extractor. }
      if (Pos('PROCEDURE', UpperCase(DDL)) = 0) or (Pos('A_NOTE', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted procedure DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (procedure):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TEST_TRIG');
        Tr.Commit;
      except
        on E: Exception do
        begin
          WriteLn('FAIL: trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if (Pos('CREATE', UpperCase(DDL)) = 0) or (Pos('TRIGGER', UpperCase(DDL)) = 0) or
         (Pos('IBX_SMOKE_TEST', UpperCase(DDL)) = 0) then
      begin
        WriteLn('FAIL: extracted trigger DDL does not look right:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (trigger):');
      WriteLn(DDL);

      { Modern column types. Which ones exist depends on the server: BOOLEAN
        arrived in Firebird 3, and DECFLOAT / INT128 / WITH TIME ZONE in
        Firebird 4 - so ask the engine rather than assuming. CI currently runs
        Firebird 3.0, which exercises the BOOLEAN path only. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'select rdb$get_context(''SYSTEM'', ''ENGINE_VERSION'') from rdb$database';
        Q.Open;
        EngineVersion := Trim(Q.Fields[0].AsString);
        Q.Close;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not read ENGINE_VERSION: ', E.Message);
          Halt(1);
        end;
      end;
      EngineMajor := StrToIntDef(Copy(EngineVersion, 1, Pos('.', EngineVersion + '.') - 1), 0);
      WriteLn('Server ENGINE_VERSION=', EngineVersion, ' (major ', EngineMajor, ')');

      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          if EngineMajor >= 4 then
            Q.SQL.Text := 'recreate table ibx_smoke_types (' +
              'c_bool boolean, c_dec16 decfloat(16), c_dec34 decfloat(34), ' +
              'c_int128 int128, c_num38 numeric(38,4), ' +
              'c_timetz time with time zone, c_tstz timestamp with time zone, ' +
              'c_bigint bigint)'
          else
            Q.SQL.Text := 'recreate table ibx_smoke_types (c_bool boolean, c_bigint bigint)';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create modern-types table: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_TYPES');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: modern-types DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;

        { An unmapped type leaves ConvertFieldType's Result empty and the
          caller falls back to the internal domain name, so guard against
          that explicitly as well as checking each expected type name. }
        if Pos('RDB$', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: extracted DDL contains an internal RDB$ domain name, ');
          WriteLn('      which means a column type is not mapped by ConvertFieldType:');
          WriteLn(DDL);
          Halt(1);
        end;
        RequireInDDL(DDL, 'boolean', 'BOOLEAN (Firebird 3)');
        RequireInDDL(DDL, 'bigint', 'BIGINT');
        if EngineMajor >= 4 then
        begin
          RequireInDDL(DDL, 'decfloat(16)', 'DECFLOAT(16) (Firebird 4)');
          RequireInDDL(DDL, 'decfloat(34)', 'DECFLOAT(34) (Firebird 4)');
          RequireInDDL(DDL, 'int128', 'INT128 (Firebird 4)');
          RequireInDDL(DDL, 'numeric(38, 4)', 'NUMERIC(38,4) (Firebird 4)');
          RequireInDDL(DDL, 'time with time zone', 'TIME WITH TIME ZONE (Firebird 4)');
          RequireInDDL(DDL, 'timestamp with time zone', 'TIMESTAMP WITH TIME ZONE (Firebird 4)');
        end;
        WriteLn('DDL extraction OK (modern types):');
        WriteLn(DDL);
      end;

      { Identity columns (Firebird 3) and SQL SECURITY (Firebird 4). Losing an
        identity on extraction is not cosmetic - the restored column silently
        stops auto-generating - so assert on the generated clause directly. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          if EngineMajor >= 4 then
            Q.SQL.Text := 'recreate table ibx_smoke_ident (' +
              'a integer generated always as identity (start with 100 increment by 5), ' +
              'b bigint generated by default as identity)'
          else
            Q.SQL.Text := 'recreate table ibx_smoke_ident (' +
              'a integer generated by default as identity, b bigint)';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create identity table: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlTable, ddlstNone, 'IBX_SMOKE_IDENT');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: identity DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'as identity', 'identity clause (Firebird 3)');
        if EngineMajor >= 4 then
        begin
          RequireInDDL(DDL, 'generated always as identity', 'GENERATED ALWAYS');
          RequireInDDL(DDL, 'generated by default as identity', 'GENERATED BY DEFAULT');
          RequireInDDL(DDL, 'start with 100 increment by 5', 'START WITH / INCREMENT BY');
        end;
        WriteLn('DDL extraction OK (identity columns):');
        WriteLn(DDL);
      end;

      { Packages (Firebird 3). Header and body are separate objects and a
        package may legitimately have a header and no body. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter package ibx_smoke_pkg as begin ' +
                        'function pf(a integer) returns integer; end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create package header: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          Q.SQL.Text := 'recreate package body ibx_smoke_pkg as begin ' +
                        'function pf(a integer) returns integer as begin return a + 1; end end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create package body: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPackage, ddlstHeader, 'IBX_SMOKE_PKG');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: package header DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'create or alter package', 'package header statement');
        RequireInDDL(DDL, 'returns integer', 'declared routine in the header');
        WriteLn('DDL extraction OK (package header):');
        WriteLn(DDL);

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPackage, ddlstProc, 'IBX_SMOKE_PKG');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: package body DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'package body', 'package body statement');
        RequireInDDL(DDL, 'return a + 1', 'package body source');
        WriteLn('DDL extraction OK (package body):');
        WriteLn(DDL);

        { The query the package viewer loads from. A package may legitimately
          be declared and left unimplemented, and the viewer reports that
          rather than treating it as an error - so the body of such a package
          has to come back NULL, not empty-and-indistinguishable. }
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter package ibx_smoke_pkg_nobody as begin ' +
                        'procedure declared_only(a integer); end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create a header-only package: ', E.Message);
            Halt(1);
          end;
        end;

        EnsureTransaction;
        Q.SQL.Text := 'select rdb$package_header_source, rdb$package_body_source ' +
                      'from rdb$packages where rdb$package_name = ''IBX_SMOKE_PKG_NOBODY''';
        Q.Open;
        if Q.EOF then
        begin
          WriteLn('FAIL: the header-only package was not found');
          Halt(1);
        end;
        if Trim(Q.FieldByName('rdb$package_header_source').AsString) = '' then
        begin
          WriteLn('FAIL: the header source came back empty');
          Halt(1);
        end;
        if not Q.FieldByName('rdb$package_body_source').IsNull then
        begin
          WriteLn('FAIL: a package with no body did not report a NULL body');
          Halt(1);
        end;
        Q.Close;

        { And one that does have a body reports both. }
        EnsureTransaction;
        Q.SQL.Text := 'select rdb$package_header_source, rdb$package_body_source ' +
                      'from rdb$packages where rdb$package_name = ''IBX_SMOKE_PKG''';
        Q.Open;
        if Q.EOF or Q.FieldByName('rdb$package_body_source').IsNull then
        begin
          WriteLn('FAIL: a package with a body reported no body');
          Halt(1);
        end;
        Q.Close;
        if Tr.Active then
          Tr.Commit;
        WriteLn('Package viewer query OK (header-only reports a NULL body)');
      end;

      { Replication publications (Firebird 4). Every FB4+ database owns exactly
        one, the built-in RDB$DEFAULT, and its whole DDL surface is spelled
        ALTER DATABASE. Including a table does not switch replication on
        (RDB$ACTIVE_FLAG stays 0), so this leaves the database inert - and the
        table is excluded again afterwards to leave it as found. }
      if EngineMajor >= 4 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'alter database include table ibx_smoke_test to publication';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not include a table in the publication: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlPublication, ddlstNone, DefaultPublicationName);
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: publication DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        RequireInDDL(DDL, 'publication', 'publication statement');
        RequireInDDL(DDL, 'include table', 'explicit publication member list');
        RequireInDDL(DDL, 'ibx_smoke_test', 'the included table');
        WriteLn('DDL extraction OK (publication):');
        WriteLn(DDL);

        Tr.StartTransaction;
        try
          Q.SQL.Text := 'alter database exclude table ibx_smoke_test from publication';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not exclude the table from the publication: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { Trigger forms beyond the six single-action table triggers. A multi-action
        trigger ("before insert or update") emitted no event clause at all, and
        a database-level trigger emitted "for " with an empty relation name -
        both invalid SQL. RDB$TRIGGER_TYPE is odd for BEFORE / even for AFTER,
        and decodes in base 4 as up to three action slots. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter trigger ibx_smoke_trg_multi for ibx_smoke_test ' +
                      'active before insert or update or delete position 0 as begin end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create multi-action trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TRG_MULTI');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: multi-action trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      RequireInDDL(DDL, 'before insert or update or delete', 'multi-action trigger event clause');
      WriteLn('DDL extraction OK (multi-action trigger):');
      WriteLn(DDL);

      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create or alter trigger ibx_smoke_trg_conn active on connect ' +
                      'position 0 as begin end';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create database-level trigger: ', E.Message);
          Halt(1);
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTrigger, ddlstNone, 'IBX_SMOKE_TRG_CONN');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: database-level trigger DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      RequireInDDL(DDL, 'on connect', 'ON CONNECT event clause');
      if Pos(' FOR ', UpperCase(DDL)) > 0 then
      begin
        WriteLn('FAIL: database-level trigger emitted a FOR <relation> clause:');
        WriteLn(DDL);
        Halt(1);
      end;
      WriteLn('DDL extraction OK (database-level trigger):');
      WriteLn(DDL);

      { PSQL functions (Firebird 3). These share RDB$FUNCTIONS with legacy
        external UDFs but are a different object entirely, and running one
        through the DECLARE EXTERNAL FUNCTION path produced nonsense - the
        arguments are typed via RDB$FIELD_SOURCE, not RDB$FIELD_TYPE, so
        ConvertFieldType saw a NULL type and (before it initialised its result)
        returned arbitrary memory. }
      if EngineMajor >= 3 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create or alter function ibx_smoke_fn(x integer) returns integer ' +
                        'as begin return x * 2; end';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create PSQL function: ', E.Message);
            Halt(1);
          end;
        end;

        Tr.StartTransaction;
        try
          DDL := Extractor.Extract(ddlUDF, ddlstNone, 'IBX_SMOKE_FN');
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: PSQL function DDL extraction raised: ', E.Message);
            Halt(1);
          end;
        end;
        if Pos('DECLARE EXTERNAL FUNCTION', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: PSQL function extracted as an external UDF:');
          WriteLn(DDL);
          Halt(1);
        end;
        if Pos('SELECT ', UpperCase(DDL)) > 0 then
        begin
          WriteLn('FAIL: a SQL query leaked into the generated DDL:');
          WriteLn(DDL);
          Halt(1);
        end;
        RequireInDDL(DDL, 'function', 'CREATE FUNCTION');
        RequireInDDL(DDL, 'returns integer', 'return type');
        RequireInDDL(DDL, 'return x * 2', 'function body');
        WriteLn('DDL extraction OK (PSQL function):');
        WriteLn(DDL);
      end;

      { Index DDL. An expression index has no RDB$INDEX_SEGMENTS rows, so it
        used to emit an empty column list ("on TBL()") - invalid SQL. Partial
        indexes (Firebird 5) additionally carry a WHERE condition that, if
        dropped, silently yields a full index instead of a partial one. }
      Tr.StartTransaction;
      try
        Q.SQL.Text := 'create index ibx_smoke_ix_expr on ibx_smoke_test computed by (upper(note))';
        Q.ExecSQL;
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: could not create expression index: ', E.Message);
          Halt(1);
        end;
      end;

      if EngineMajor >= 5 then
      begin
        Tr.StartTransaction;
        try
          Q.SQL.Text := 'create index ibx_smoke_ix_part on ibx_smoke_test (note) where note is not null';
          Q.ExecSQL;
          Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: could not create partial index: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      Tr.StartTransaction;
      try
        DDL := Extractor.Extract(ddlTable, ddlstIndex, 'IBX_SMOKE_TEST');
        Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: index DDL extraction raised: ', E.Message);
          Halt(1);
        end;
      end;
      if Pos('()', DDL) > 0 then
      begin
        WriteLn('FAIL: index DDL has an empty column list (expression index not handled):');
        WriteLn(DDL);
        Halt(1);
      end;
      RequireInDDL(DDL, 'computed by', 'COMPUTED BY for the expression index');
      if EngineMajor >= 5 then
        RequireInDDL(DDL, 'where note is not null', 'WHERE clause for the partial index (Firebird 5)');
      WriteLn('DDL extraction OK (indexes):');
      WriteLn(DDL);

      { The object tree's "Script As" generators. They live in ScriptAs.pas
        rather than MarathonIDE.pas precisely so they can be reached from here:
        MarathonProjectCache pulls in the LCL, which a console test cannot
        initialise. Each generated statement is either executed or prepared,
        so this checks the SQL is real rather than merely that the text looks
        plausible. }
      { IsIB6 is True for every Firebird a connection can be made to - see
        TMarathonCacheConnection.IsIB6 - so pass True here as well, or these
        tests exercise a configuration the application never uses. It decides
        identifier quoting and whether dialect-3 types are formatted at all:
        with False, ConvertFieldType returns an empty string for NUMERIC. }
      Ctx := ScriptAsContext(DB, Tr, True, DB.SQLDialect, EngineMajor);

      try
        { SELECT/INSERT/UPDATE/DELETE all have to parse. The SELECT is the only
          one safe to run as-is; the rest are prepared, which still makes
          Firebird compile them and resolve every name. }
        Script := ScriptAsSelect(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'select first 100', 'SELECT template');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.Open;
        Q.Close;

        Script := ScriptAsInsert(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'insert into', 'INSERT template');
        RequireInDDL(Script, ':ID', 'INSERT parameter');
        PrepareOnly(Script, 'INSERT template');

        Script := ScriptAsUpdate(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'update ', 'UPDATE template');
        PrepareOnly(Script, 'UPDATE template');

        Script := ScriptAsDelete(Ctx, 'IBX_SMOKE_TEST');
        RequireInDDL(Script, 'delete from', 'DELETE template');
        PrepareOnly(Script, 'DELETE template');

        Script := ScriptAsExecute(Ctx, 'IBX_SMOKE_TEST_PROC');
        RequireInDDL(Script, 'ibx_smoke_test_proc', 'EXECUTE template');
        PrepareOnly(Script, 'EXECUTE template');

        { Named arguments where the engine takes them - clearer for a routine
          with several parameters, and unaffected by a later reordering. The
          context carries the engine version so an older server still gets a
          positional call, which is the only form it will parse. }
        if EngineMajor >= 6 then
        begin
          RequireInDDL(Script, '=>', 'named arguments on Firebird 6');
          { Both forms have to compile, so build the positional one explicitly
            and prepare that too rather than assuming it still works. }
          PositionalCtx := ScriptAsContext(DB, Tr, True, DB.SQLDialect, 5);
          Script := ScriptAsExecute(PositionalCtx, 'IBX_SMOKE_TEST_PROC');
          if Pos('=>', Script) > 0 then
          begin
            WriteLn('FAIL: a pre-6 engine was given named arguments:');
            WriteLn(Script);
            Halt(1);
          end;
          PrepareOnly(Script, 'positional EXECUTE template');
        end
        else
          if Pos('=>', Script) > 0 then
          begin
            WriteLn('FAIL: named arguments generated for engine major ', EngineMajor);
            Halt(1);
          end;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a Script As DML template did not compile: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (SELECT/INSERT/UPDATE/DELETE/EXECUTE)');

      { Routine signatures, shown in the explorer's status bar so a routine's
        parameters can be read without opening it. Both catalogues type their
        arguments through the domain rather than carrying the type directly,
        which is the part worth checking. }
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_TEST_PROC', False);
      RequireInDDL(Script, 'IBX_SMOKE_TEST_PROC(', 'the routine name and an argument list');
      RequireInDDL(Script, 'A_ID integer', 'the parameter with its declared type');
      WriteLn('Signature OK (procedure): ', Script);

      if EngineMajor >= 3 then
      begin
        { A PSQL function's return type lives at argument position 0, not in a
          separate column - a detail easy to get wrong, and the reason the
          function path is checked separately. }
        Script := RoutineSignature(Ctx, 'IBX_SMOKE_FN', True);
        RequireInDDL(Script, 'IBX_SMOKE_FN(', 'the function name');
        RequireInDDL(Script, 'X integer', 'the function argument');
        RequireInDDL(Script, 'RETURNS', 'the function return type');
        WriteLn('Signature OK (function): ', Script);
      end;

      { A procedure with no parameters at all must still read sensibly. }
      EnsureTransaction;
      Q.SQL.Text := 'create or alter procedure ibx_smoke_noargs as begin end';
      Q.ExecSQL;
      if Tr.Active then
        Tr.Commit;
      Script := RoutineSignature(Ctx, 'IBX_SMOKE_NOARGS', False);
      if Script <> 'IBX_SMOKE_NOARGS()' then
      begin
        WriteLn('FAIL: a parameterless procedure reads as "', Script, '"');
        Halt(1);
      end;
      EnsureTransaction;
      Q.SQL.Text := 'drop procedure ibx_smoke_noargs';
      Q.ExecSQL;
      if Tr.Active then
        Tr.Commit;

      { MERGE. The join condition has to come from the real primary key - an ON
        clause that never matches would turn every MERGE into an INSERT - and
        the key columns must not appear in the UPDATE SET list, since they are
        what the rows were matched on. }
      Script := ScriptAsMerge(Ctx, 'IBX_SMOKE_TEST');
      RequireInDDL(Script, 'merge into', 'MERGE statement');
      RequireInDDL(Script, 't.ID = s.ID', 'MERGE join on the primary key');
      RequireInDDL(Script, 't.NOTE = s.NOTE', 'MERGE update of a non-key column');
      if Pos('T.ID = S.ID', UpperCase(Copy(Script, Pos('UPDATE SET', UpperCase(Script)), MaxInt))) > 0 then
      begin
        WriteLn('FAIL: MERGE updates the key columns it matched on:');
        WriteLn(Script);
        Halt(1);
      end;
      { The source table is a TODO placeholder by design; falling back to the
        keyless ON clause on a table that has a primary key would not be. }
      if Pos('NO PRIMARY KEY', UpperCase(Script)) > 0 then
      begin
        WriteLn('FAIL: MERGE fell back to the no-primary-key template on a keyed table:');
        WriteLn(Script);
        Halt(1);
      end;
      WriteLn('Script As OK (MERGE):');
      WriteLn(Script);

      { DROP, for every object type the tree offers it on. Prepared rather than
        executed, which still resolves the object name - a wrong verb or a name
        that does not exist fails here. }
      try
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_VIEW', ctView), 'DROP VIEW');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_PROC', ctSP), 'DROP PROCEDURE');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST_TRIG', ctTrigger), 'DROP TRIGGER');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST', ctTable), 'DROP TABLE');
        if EngineMajor >= 3 then
          PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_FN', ctUDF), 'DROP FUNCTION');
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a generated DROP statement did not compile: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (DROP: ', ScriptAsDrop(Ctx, 'IBX_SMOKE_TEST', ctTable), ')');

      { DROP PACKAGE takes the body with it, so one statement covers a package
        whether or not it has one - prepared against both to prove it. }
      if EngineMajor >= 3 then
      begin
        Script := ScriptAsDrop(Ctx, 'IBX_SMOKE_PKG', ctPackage);
        if Pos('PACKAGE BODY', UpperCase(Script)) > 0 then
        begin
          WriteLn('FAIL: the package DROP names the body separately:');
          WriteLn(Script);
          Halt(1);
        end;
        PrepareOnly(Script, 'DROP PACKAGE (with a body)');
        PrepareOnly(ScriptAsDrop(Ctx, 'IBX_SMOKE_PKG_NOBODY', ctPackage),
          'DROP PACKAGE (header only)');
        WriteLn('Script As OK (DROP PACKAGE: ', Trim(Script), ')');
      end;

      { ALTER. These are executed, not just prepared: restating an object
        exactly as it already is is harmless, and it is the only way to prove
        the ALTER forms are right. The trigger is the one that matters - ALTER
        TRIGGER rejects the "for <table>" clause that CREATE TRIGGER requires,
        so an extractor that simply swapped the verb would emit invalid SQL. }
      try
        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_VIEW', ctView);
        RequireInDDL(Script, 'alter view', 'ALTER VIEW form');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;

        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_TRIG', ctTrigger);
        RequireInDDL(Script, 'alter trigger', 'ALTER TRIGGER form');
        if Pos(' FOR ', UpperCase(Copy(Script, 1, Pos(#10, Script + #10)))) > 0 then
        begin
          WriteLn('FAIL: ALTER TRIGGER kept the FOR clause, which Firebird rejects:');
          WriteLn(Script);
          Halt(1);
        end;
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;

        Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST_PROC', ctSP);
        RequireInDDL(Script, 'alter procedure', 'ALTER PROCEDURE form');
        EnsureTransaction;
        Q.SQL.Text := StripTrailingSemicolon(Script);
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: a generated ALTER statement did not run: ', E.Message);
          Halt(1);
        end;
      end;
      WriteLn('Script As OK (ALTER: view, trigger, procedure)');

      { A table has no whole-table ALTER, so that path emits a template rather
        than executable DDL - check it is the template and not silently empty. }
      Script := ScriptAsAlter(Ctx, 'IBX_SMOKE_TEST', ctTable);
      RequireInDDL(Script, 'alter table', 'ALTER TABLE template');
      RequireInDDL(Script, 'Current columns', 'the template''s column inventory');

      { Statements Firebird executes "with output" rather than through a
        cursor. TIBQuery.Open returns nothing for these, so the SQL editor used
        to execute them and silently drop what they returned. }
      EnsureTransaction;
      try
        { Singleton INSERT ... RETURNING. }
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4242';
        Q.ExecSQL;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4242, ''returned'') returning id, note', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: singleton INSERT ... RETURNING produced no output row');
          Halt(1);
        end;
        try
          if Single.FieldByName('ID').AsString <> '4242' then
          begin
            WriteLn('FAIL: RETURNING gave ID=', Single.FieldByName('ID').AsString, ', expected 4242');
            Halt(1);
          end;
          if Trim(Single.FieldByName('NOTE').AsString) <> 'returned' then
          begin
            WriteLn('FAIL: RETURNING gave NOTE=', Single.FieldByName('NOTE').AsString);
            Halt(1);
          end;
          WriteLn('Singleton output OK (INSERT ... RETURNING): ID=',
            Single.FieldByName('ID').AsString, ' NOTE=', Trim(Single.FieldByName('NOTE').AsString));
        finally
          Single.Free;
        end;

        { A statement with no output columns must come back nil, and - the part
          that matters - must not have been executed, or the caller running it
          itself would run it twice. }
        EnsureTransaction;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4243, ''must not run'')', nil);
        if Assigned(Single) then
        begin
          WriteLn('FAIL: a statement with no output columns returned a dataset');
          Single.Free;
          Halt(1);
        end;
        EnsureTransaction;
        Q.SQL.Text := 'select count(*) from ibx_smoke_test where id = 4243';
        Q.Open;
        if Q.Fields[0].AsInteger <> 0 then
        begin
          WriteLn('FAIL: ExecuteSingletonOutput executed a statement it reported as having no output');
          Halt(1);
        end;
        Q.Close;
        WriteLn('Singleton output OK (no output columns: nil, and not executed)');

        { EXECUTE PROCEDURE with output parameters takes the same path. }
        EnsureTransaction;
        Q.SQL.Text := 'create or alter procedure ibx_smoke_out (a integer) ' +
                      'returns (b integer, c varchar(10)) as begin b = a * 2; c = ''ok''; end';
        Q.ExecSQL;
        Tr.Commit;
        EnsureTransaction;
        Single := ExecuteSingletonOutput(DB, Tr, 'execute procedure ibx_smoke_out(21)', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: EXECUTE PROCEDURE with output parameters produced no row');
          Halt(1);
        end;
        try
          if (Single.FieldByName('B').AsString <> '42') or
             (Trim(Single.FieldByName('C').AsString) <> 'ok') then
          begin
            WriteLn('FAIL: EXECUTE PROCEDURE returned B=', Single.FieldByName('B').AsString,
              ' C=', Single.FieldByName('C').AsString);
            Halt(1);
          end;
          WriteLn('Singleton output OK (EXECUTE PROCEDURE): B=', Single.FieldByName('B').AsString,
            ' C=', Trim(Single.FieldByName('C').AsString));
        finally
          Single.Free;
        end;

        { NULLs must stay NULL rather than becoming empty strings. }
        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4244';
        Q.ExecSQL;
        Single := ExecuteSingletonOutput(DB, Tr,
          'insert into ibx_smoke_test (id, note) values (4244, null) returning id, note', nil);
        if not Assigned(Single) then
        begin
          WriteLn('FAIL: RETURNING with a NULL column produced no row');
          Halt(1);
        end;
        try
          if not Single.FieldByName('NOTE').IsNull then
          begin
            WriteLn('FAIL: a NULL RETURNING column came back as non-NULL: "',
              Single.FieldByName('NOTE').AsString, '"');
            Halt(1);
          end;
        finally
          Single.Free;
        end;
        WriteLn('Singleton output OK (NULL stays NULL)');

        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (4242, 4244)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: singleton-output handling raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Parameter binding. The SQL editor prompts for a value per parameter and
        binds every one of them as text, leaving Firebird to convert - that is
        what lets one dialog serve every parameter type. Worth proving, since
        the alternative (an unbound parameter) is silently NULL rather than an
        error, which is the bug that prompted the dialog. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'execute procedure ibx_smoke_out(:A)';
        Q.Prepare;
        if Q.ParamCount <> 1 then
        begin
          WriteLn('FAIL: expected 1 parameter, got ', Q.ParamCount);
          Halt(1);
        end;
        if Q.Params[0].Name <> 'A' then
        begin
          WriteLn('FAIL: parameter came back named "', Q.Params[0].Name, '"');
          Halt(1);
        end;

        { An integer parameter fed a string, which is what the dialog does. }
        Q.Params[0].AsString := '21';
        Single := ExecuteSingletonOutput(DB, Tr, 'execute procedure ibx_smoke_out(21)', nil);
        if Assigned(Single) then
        try
          if Single.FieldByName('B').AsString <> '42' then
          begin
            WriteLn('FAIL: procedure did not double its argument');
            Halt(1);
          end;
        finally
          Single.Free;
        end;

        { And the case the dialog exists to prevent: left unbound, the
          parameter is NULL and the statement runs anyway. }
        EnsureTransaction;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (:ID, :NOTE)';
        Q.Prepare;
        Q.Params[0].AsString := '4321';
        Q.Params[1].AsString := 'bound as text';
        Q.ExecSQL;
        EnsureTransaction;
        Q.SQL.Text := 'select note from ibx_smoke_test where id = 4321';
        Q.Open;
        if Q.EOF or (Trim(Q.Fields[0].AsString) <> 'bound as text') then
        begin
          WriteLn('FAIL: a text-bound parameter did not reach the database intact');
          Halt(1);
        end;
        Q.Close;
        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id = 4321';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        WriteLn('Parameter binding OK (bound as text, converted by Firebird)');

        { The declared types of a statement's parameters, which the SQL editor
          reads to decide what to validate. They are NOT available from
          TIBQuery - its TParams come back ftUnknown - so it prepares a TIBSQL
          alongside; this checks that route still yields real types, and pins
          the codes SQLParamTypes.pas maps. The one that matters is
          NUMERIC(10,2): it arrives as SQL_INT64 with a negative scale, so
          scale is what separates a whole number from a decimal. }
        EnsureTransaction;
        ParamMeta := TIBSQL.Create(nil);
        try
          ParamMeta.Database := DB;
          ParamMeta.Transaction := Tr;
          ParamMeta.SQL.Text := 'select * from ibx_smoke_test where id = :P_INT ' +
                                'and note = :P_TEXT';
          ParamMeta.Prepare;
          if ParamMeta.Params.GetCount <> 2 then
          begin
            WriteLn('FAIL: expected 2 typed parameters, got ', ParamMeta.Params.GetCount);
            Halt(1);
          end;
          if ParamMeta.Params[0].SQLType <> SQL_LONG then
          begin
            WriteLn('FAIL: an integer parameter came back as SQLType ',
              ParamMeta.Params[0].SQLType, ', expected SQL_LONG');
            Halt(1);
          end;
          if ParamMeta.Params[0].getScale <> 0 then
          begin
            WriteLn('FAIL: an integer parameter has scale ', ParamMeta.Params[0].getScale);
            Halt(1);
          end;
          if ParamMeta.Params[1].SQLType <> SQL_VARYING then
          begin
            WriteLn('FAIL: a varchar parameter came back as SQLType ',
              ParamMeta.Params[1].SQLType, ', expected SQL_VARYING');
            Halt(1);
          end;
          WriteLn('Parameter metadata OK (typed via TIBSQL: SQL_LONG scale 0, SQL_VARYING)');
        finally
          ParamMeta.Free;
        end;
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: parameter binding raised: ', E.Message);
          Halt(1);
        end;
      end;

      { XLSX export. The file is a zip of XML parts, so the only way to know
        it is right is to write one and take it apart again - which the test
        harness does after this run. Here we write it from a real result set
        containing the things most likely to break the writer: a NULL, a
        number, and text needing XML escaping. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (9001, 9002)';
        Q.ExecSQL;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values ' +
                      '(9001, ''a & b <c> "d"'')';
        Q.ExecSQL;
        Q.SQL.Text := 'insert into ibx_smoke_test (id, note) values (9002, null)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        EnsureTransaction;
        Q.SQL.Text := 'select id, note from ibx_smoke_test where id in (9001, 9002) order by id';
        Q.Open;
        Cols := TStringList.Create;
        try
          Cols.Add('ID');
          Cols.Add('NOTE');
          WriteXlsx(Q, Cols, 'Results', GetTempDir + 'ibx_smoke_export.xlsx');
        finally
          Cols.Free;
        end;
        Q.Close;

        if not FileExists(GetTempDir + 'ibx_smoke_export.xlsx') then
        begin
          WriteLn('FAIL: no workbook was written');
          Halt(1);
        end;

        EnsureTransaction;
        Q.SQL.Text := 'delete from ibx_smoke_test where id in (9001, 9002)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        WriteLn('XLSX export OK (written to ', GetTempDir, 'ibx_smoke_export.xlsx)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: XLSX export raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Cell references are base-26 with no zero digit, which is the part of
        the format most easily got wrong past column Z. }
      if XlsxCellRef(0, 0) <> 'A1' then
      begin
        WriteLn('FAIL: cell (0,0) is ', XlsxCellRef(0, 0), ', expected A1');
        Halt(1);
      end;
      if XlsxCellRef(25, 0) <> 'Z1' then
      begin
        WriteLn('FAIL: cell (25,0) is ', XlsxCellRef(25, 0), ', expected Z1');
        Halt(1);
      end;
      if XlsxCellRef(26, 1) <> 'AA2' then
      begin
        WriteLn('FAIL: cell (26,1) is ', XlsxCellRef(26, 1), ', expected AA2');
        Halt(1);
      end;
      if XlsxCellRef(701, 0) <> 'ZZ1' then
      begin
        WriteLn('FAIL: cell (701,0) is ', XlsxCellRef(701, 0), ', expected ZZ1');
        Halt(1);
      end;
      if XlsxCellRef(702, 0) <> 'AAA1' then
      begin
        WriteLn('FAIL: cell (702,0) is ', XlsxCellRef(702, 0), ', expected AAA1');
        Halt(1);
      end;
      if XlsxEscape('a & b <c>') <> 'a &amp; b &lt;c&gt;' then
      begin
        WriteLn('FAIL: XML escaping is wrong: ', XlsxEscape('a & b <c>'));
        Halt(1);
      end;
      WriteLn('XLSX cell references and escaping OK');

      { Disconnect hardening. A user's own query in the SQL editor can still
        select a WITH TIME ZONE column - Marathon casts its own, but cannot
        rewrite the user's - and this IBX version then faults while closing the
        attachment. DisconnectQuietly turns that into a message so the caller's
        cleanup still runs instead of the application going down.

        Driven on a throwaway connection so the fault is real rather than
        simulated: if IBX is ever fixed, TookFault goes false and this test
        says so rather than silently passing. }
      if EngineMajor >= 4 then
      begin
        EnsureTransaction;
        Q.SQL.Text := 'recreate table ibx_smoke_tz2 (id integer, ts timestamp with time zone)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
        EnsureTransaction;
        Q.SQL.Text := 'insert into ibx_smoke_tz2 values (1, current_timestamp)';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;

        FaultDB := TIBDatabase.Create(nil);
        FaultTr := TIBTransaction.Create(nil);
        FaultQ := TIBQuery.Create(nil);
        try
          FaultDB.DatabaseName := DatabaseName;
          FaultDB.Params.Values['user_name'] := UserName;
          FaultDB.Params.Values['password'] := Password;
          FaultDB.LoginPrompt := False;
          FaultTr.DefaultDatabase := FaultDB;
          FaultDB.DefaultTransaction := FaultTr;
          FaultDB.Connected := True;
          FaultTr.StartTransaction;
          FaultQ.Database := FaultDB;
          FaultQ.Transaction := FaultTr;
          { Read the column raw - exactly what a user's own query does. }
          FaultQ.SQL.Text := 'select ts from ibx_smoke_tz2';
          FaultQ.Open;
          FaultQ.Close;
          if FaultTr.Active then
            FaultTr.Commit;

          { Must return rather than raise, whichever way it goes. }
          Value := DisconnectQuietly(FaultDB);
          if Value <> '' then
            WriteLn('Disconnect hardening OK (contained: ', Value, ')')
          else
            { Both workarounds stay regardless. The casts are not only a
              workaround - they are how the IANA zone name reaches the grid at
              all - and the guard still earns its place for anyone running an
              unpatched fbintf. }
            WriteLn('Disconnect hardening OK (clean - this fbintf has the fix from ' +
                    'MWASoftware/fbintf#7 or equivalent)');
        finally
          FaultQ.Free;
          FaultTr.Free;
          FaultDB.Free;
        end;

        EnsureTransaction;
        Q.SQL.Text := 'drop table ibx_smoke_tz2';
        Q.ExecSQL;
        if Tr.Active then
          Tr.Commit;
      end;

      { Firebird 4 WITH TIME ZONE columns. Two things are wrong with reading one
        directly through IBX, and one cast fixes both: IBX surfaces the column
        as a plain ftDateTime and reduces the zone to a numeric offset, losing
        the IANA name; and doing so leaves the attachment unable to disconnect
        afterwards (see test/timezone_disconnect_repro.lpr). Marathon's MON$
        queries therefore cast on the server, and this pins that the cast
        really does carry the zone name. }
      if EngineMajor >= 4 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text := 'recreate table ibx_smoke_tz (id integer, ts timestamp with time zone)';
          Q.ExecSQL;
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := 'insert into ibx_smoke_tz values ' +
                        '(1, timestamp ''2026-07-26 14:30:00 Europe/Berlin'')';
          Q.ExecSQL;
          if Tr.Active then
            Tr.Commit;

          EnsureTransaction;
          Q.SQL.Text := 'select cast(ts as varchar(64)) as TS_TEXT from ibx_smoke_tz';
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: no time zone row came back');
            Halt(1);
          end;
          if Pos('Europe/Berlin', Q.Fields[0].AsString) = 0 then
          begin
            WriteLn('FAIL: the cast lost the zone name: "', Q.Fields[0].AsString, '"');
            Halt(1);
          end;
          WriteLn('Time zone OK (cast keeps the name: ', Trim(Q.Fields[0].AsString), ')');
          Q.Close;
          Q.Prepared := False;

          { And the cast is wide enough for the longest names Firebird ships. }
          EnsureTransaction;
          Q.SQL.Text := 'select max(char_length(trim(rdb$time_zone_name))) from rdb$time_zones';
          Q.Open;
          if not Q.EOF then
            if Q.Fields[0].AsInteger + 25 > 64 then
            begin
              WriteLn('FAIL: varchar(64) is too narrow for the longest zone name (',
                Q.Fields[0].AsInteger, ' chars)');
              Halt(1);
            end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: time zone handling raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { The object-list queries behind the tree and the New Trigger dialog. Two
        gaps were found by running them against a live server rather than
        reading them: the table and view lists had no system-object filter, so
        they returned every MON$ and SEC$ relation - they are ordinary
        relations that happen to be flagged system, which the RDB$ name check
        does not catch - and the procedure list did not exclude packaged
        procedures, though the function list already excluded packaged
        functions. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'select count(*) from rdb$relations ' +
          'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
          'and rdb$view_source is null ' +
          'and rdb$relation_name starting with ''MON$''';
        Q.Open;
        if Q.Fields[0].AsInteger <> 0 then
        begin
          WriteLn('FAIL: the table list filter still admits MON$ relations');
          Halt(1);
        end;
        Q.Close;
        Q.Prepared := False;

        { And the filter must not throw the baby out - the smoke test's own
          table has to survive it. }
        EnsureTransaction;
        Q.SQL.Text := 'select count(*) from rdb$relations ' +
          'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
          'and rdb$view_source is null ' +
          'and rdb$relation_name = ''IBX_SMOKE_TEST''';
        Q.Open;
        if Q.Fields[0].AsInteger <> 1 then
        begin
          WriteLn('FAIL: the table list filter excludes an ordinary user table');
          Halt(1);
        end;
        Q.Close;
        Q.Prepared := False;

        if EngineMajor >= 3 then
        begin
          { A packaged procedure must not appear at top level, and a standalone
            one must. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$procedures ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and rdb$package_name is null ' +
            'and rdb$procedure_name = ''IBX_SMOKE_TEST_PROC''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 1 then
          begin
            WriteLn('FAIL: a standalone procedure is missing from the procedure list');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$procedures ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and rdb$package_name is null ' +
            'and rdb$package_name is distinct from null';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: the procedure filter is self-contradictory');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
        end;
        if Tr.Active then
          Tr.Commit;
        { Firebird 6 schemas. A database can hold objects the user never made -
          the profiler plugin puts its tables in a PLG$PROFILER schema of its
          own, and they are not flagged system, so no system filter excludes
          them. Marathon generates unqualified DDL, so the object lists show
          only what an unqualified name reaches. }
        if EngineMajor >= 6 then
        begin
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$relations ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and (rdb$schema_name = current_schema or current_schema is null) ' +
            'and rdb$relation_name starting with ''PLG$''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: the schema filter still admits another schema''s tables');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { And it must not hide the user's own. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$relations ' +
            'where ((rdb$system_flag = 0) or (rdb$system_flag is null)) ' +
            'and (rdb$schema_name = current_schema or current_schema is null) ' +
            'and rdb$relation_name = ''IBX_SMOKE_TEST''';
          Q.Open;
          if Q.Fields[0].AsInteger <> 1 then
          begin
            WriteLn('FAIL: the schema filter hides the user''s own table');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Schema filter OK (other schemas excluded, own schema kept)');
        end;

        WriteLn('Object list filters OK (no MON$ relations, no packaged procedures)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: object list filter check raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Encryption status. The obvious route - the raw fb_info_crypt_state
        information item - reaches the server and the item comes back, but this
        fbintf's parser does not classify that item code, so every accessor
        including getAsBytes refuses it. MON$DATABASE carries the same state,
        needs nothing outside this codebase, and its meanings are published in
        RDB$TYPES rather than having to be hard-coded. }
      if EngineMajor >= 3 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text :=
            'select coalesce(replace(trim(t.rdb$type_name), ''_'', '' ''), ' +
            'cast(d.mon$crypt_state as varchar(11))) as CRYPT_STATE ' +
            'from mon$database d ' +
            'left join rdb$types t on t.rdb$field_name = ''MON$CRYPT_STATE'' ' +
            'and t.rdb$type = d.mon$crypt_state';
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: MON$DATABASE returned no row');
            Halt(1);
          end;
          Value := Trim(Q.Fields[0].AsString);
          { The smoke-test database is not encrypted, so this is the state it
            has to report - and it must be the decoded name, not a bare code. }
          if Value <> 'NOT ENCRYPTED' then
          begin
            WriteLn('FAIL: crypt state came back "', Value, '", expected NOT ENCRYPTED');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { All four states are published, so a future one shows its own name. }
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from rdb$types where rdb$field_name = ''MON$CRYPT_STATE''';
          Q.Open;
          if Q.Fields[0].AsInteger < 4 then
          begin
            WriteLn('FAIL: expected at least 4 documented crypt states, got ',
              Q.Fields[0].AsInteger);
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Encryption status OK (', Value, ')');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: encryption status raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;

      { The built-in profiler (Firebird 5). Driven end to end here because the
        interesting part is not the SQL but where the PLG$PROF_* tables live:
        Firebird 6 puts them in a schema of their own, earlier versions did
        not, and ProfilerQueries resolves that from the catalogue rather than
        from a version test. }
      if ProfilerAvailable(DB, Tr) then
      begin
        EnsureTransaction;
        try
          ProfileId := StartProfilerSession(DB, Tr, 'ibx smoke test');
          if ProfileId < 0 then
          begin
            WriteLn('FAIL: START_SESSION returned no session id');
            Halt(1);
          end;

          { Something for it to record. }
          Q.SQL.Text := 'select count(*) from ibx_smoke_test';
          Q.Open;
          Q.Close;

          FinishProfilerSession(DB, Tr);
          if Tr.Active then
            Tr.Commit;

          { Where the PLG$PROF_* tables live is the part that varies: Firebird 6
            puts them in a schema of their own, earlier versions did not. This
            reads RDB$RELATIONS, not the profiler tables, so it is safe - see
            the note below about what is not. }
          EnsureTransaction;
          Prefix := ProfilerSchemaPrefix(DB, Tr);
          if EngineMajor >= 6 then
          begin
            if Prefix = '' then
            begin
              WriteLn('FAIL: no schema prefix resolved on a server that uses schemas');
              Halt(1);
            end;
          end;
          if (Prefix <> '') and (Copy(Prefix, Length(Prefix), 1) <> '.') then
          begin
            WriteLn('FAIL: the prefix is not dot-terminated: "', Prefix, '"');
            Halt(1);
          end;
          if Pos(Prefix + 'plg$prof_sessions', ProfilerSessionsSQL(Prefix)) = 0 then
          begin
            WriteLn('FAIL: the sessions query does not use the resolved prefix');
            Halt(1);
          end;
          { Reading these was what faulted before the cause was understood: the
            sessions view has TIMESTAMP WITH TIME ZONE columns, and handing one
            to this IBX version breaks the later disconnect. ProfilerSessionsSQL
            casts them, so the whole set is readable again - and if that
            regresses, this run ends with the fault rather than a pass. }
          Q.SQL.Text := ProfilerSessionsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: no profiler session was recorded');
            Halt(1);
          end;
          if Q.FieldByName('description').AsString <> 'ibx smoke test' then
          begin
            WriteLn('FAIL: session description came back "',
              Q.FieldByName('description').AsString, '"');
            Halt(1);
          end;
          { The cast keeps the zone name here too. }
          if Pos('/', Q.FieldByName('start_timestamp').AsString) = 0 then
          begin
            WriteLn('FAIL: the session start time lost its zone name: "',
              Q.FieldByName('start_timestamp').AsString, '"');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := ProfilerStatementStatsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: the profiler recorded no statement statistics');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          EnsureTransaction;
          Q.SQL.Text := ProfilerRecordSourceStatsSQL(Prefix);
          Q.Open;
          Q.Close;
          Q.Prepared := False;

          { DISCARD does not remove anything already flushed, despite the name,
            so a session survives it - a "clear" button wired to DISCARD would
            look broken. }
          EnsureTransaction;
          DiscardProfilerData(DB, Tr);
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := ProfilerSessionsSQL(Prefix);
          Q.Open;
          if Q.EOF then
          begin
            WriteLn('FAIL: DISCARD removed flushed sessions - it is not supposed to');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;

          { Deleting the session is what clears it, and the dependent rows go
            with it. }
          EnsureTransaction;
          ClearProfilerData(DB, Tr, Prefix);
          if Tr.Active then
            Tr.Commit;
          EnsureTransaction;
          Q.SQL.Text := 'select count(*) from ' + Prefix + 'plg$prof_statements';
          Q.Open;
          if Q.Fields[0].AsInteger <> 0 then
          begin
            WriteLn('FAIL: clearing the sessions left statement rows behind');
            Halt(1);
          end;
          Q.Close;
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Profiler OK (session ', ProfileId, ' recorded; prefix "', Prefix,
            '"; stats readable; clearing cascades)');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: profiler raised: ', E.Message);
            Halt(1);
          end;
        end;
      end
      else
        WriteLn('Profiler not available on this server - skipped');

      { EXPLAIN. It is a client-side command that isql implements itself, not
        server DSQL - preparing "explain select ..." through IBX fails with
        "Token unknown - explain" - so the editor recognises it, strips it and
        prepares what is left. Two things have to hold for that to work. }
      CheckExplain('explain select 1 from rdb$database', True, 'select 1 from rdb$database');
      CheckExplain('   EXPLAIN   select 1 from rdb$database  ', True, 'select 1 from rdb$database');
      CheckExplain('explain' + #13#10 + 'select 1 from rdb$database', True, 'select 1 from rdb$database');
      { Not a request to explain: the keyword has to be a whole word, and there
        has to be something after it. }
      CheckExplain('select * from EXPLAINED', False, '');
      CheckExplain('explainer select 1', False, '');
      CheckExplain('explain', False, '');
      CheckExplain('   ', False, '');
      WriteLn('EXPLAIN parsing OK');

      { First: a prepared statement carries its explained plan, so no execution
        is needed to get one. Second - the point of the whole feature - the
        statement really is not executed, which is what makes explaining a
        DELETE safe. }
      EnsureTransaction;
      try
        Q.SQL.Text := 'delete from ibx_smoke_test';
        Q.Prepare;
        Script := Q.GetPlan;
        if Trim(Script) = '' then
        begin
          WriteLn('FAIL: GetPlan after Prepare returned nothing - EXPLAIN would show an empty plan');
          Halt(1);
        end;
        Q.SQL.Text := 'select count(*) from ibx_smoke_test';
        Q.Open;
        if Q.Fields[0].AsInteger = 0 then
        begin
          WriteLn('FAIL: preparing a DELETE executed it - EXPLAIN would destroy data');
          Halt(1);
        end;
        Q.Close;
        if Tr.Active then
          Tr.Commit;
        WriteLn('EXPLAIN OK (plan available from Prepare alone, nothing executed)');
      except
        on E: Exception do
        begin
          if Tr.Active then
            Tr.Rollback;
          WriteLn('FAIL: EXPLAIN plan check raised: ', E.Message);
          Halt(1);
        end;
      end;

      { Multi-row RETURNING is the case the roadmap asked about, and it needs
        no special handling: Firebird gives it a real cursor and reports it as
        SQLSelect, so the editor's ordinary Open path shows every row. Assert
        that, so a future IBX bump that changes it is caught here. }
      if EngineMajor >= 5 then
      begin
        EnsureTransaction;
        try
          Q.SQL.Text := 'update ibx_smoke_test set note = note returning id, note';
          Q.Prepare;
          if Q.StatementType <> SQLSelect then
          begin
            WriteLn('FAIL: multi-row RETURNING no longer reports SQLSelect - the SQL ' +
                    'editor would stop showing its rows');
            Halt(1);
          end;
          Q.Open;
          Q.Close;
          { Unprepared before the commit, not after: a prepared statement holds
            a transaction interface, and touching it once that transaction has
            ended dereferences nil. }
          Q.Prepared := False;
          if Tr.Active then
            Tr.Commit;
          WriteLn('Multi-row RETURNING OK (reports SQLSelect, opens as a cursor)');
        except
          on E: Exception do
          begin
            if Tr.Active then
              Tr.Rollback;
            WriteLn('FAIL: multi-row RETURNING raised: ', E.Message);
            Halt(1);
          end;
        end;
      end;
    finally
      Extractor.Free;
    end;

    if Tr.Active then
      Tr.Commit;

    { Left until last: it makes and drops databases of its own, so a failure
      earlier in the run is not hidden behind it. }
    TestSchemaCompare(HostPrefixOf(DatabaseName));

    DB.Connected := False;
    WriteLn('PASS: IBX round-trip against a live Firebird server succeeded.');
  finally
    Q.Free;
    Tr.Free;
    DB.Free;
  end;
end.
