program ibx_smoke_test;

{ Standalone smoke test for the IBX (MWASoftware ibx4lazarus) database layer.
  Connects to a real Firebird server, creates a table, writes and reads a row,
  and verifies the round trip, then exercises DDLExtractor (Marathon's DDL
  scripting engine) against a table, a view, a stored procedure, and a
  trigger built on that table - each object type is its own code path in
  DDLExtractor.pas. Used by CI to prove the IBX conversion and DDL extraction
  actually work against Firebird, not just that the app compiles. }

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
