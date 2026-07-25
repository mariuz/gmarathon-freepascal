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
  SysUtils, Classes, IBDatabase, IBQuery, DDLExtractor;

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
    finally
      Extractor.Free;
    end;

    DB.Connected := False;
    WriteLn('PASS: IBX round-trip against a live Firebird server succeeded.');
  finally
    Q.Free;
    Tr.Free;
    DB.Free;
  end;
end.
