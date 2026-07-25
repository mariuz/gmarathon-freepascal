program ibx_smoke_test;

{ Standalone smoke test for the IBX (MWASoftware ibx4lazarus) database layer.
  Connects to a real Firebird server, creates a table, writes and reads a row,
  and verifies the round trip, then exercises DDLExtractor (Marathon's DDL
  scripting engine) against the live table. Used by CI to prove the IBX
  conversion and DDL extraction actually work against Firebird, not just
  that the app compiles. }

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
      WriteLn('DDL extraction OK:');
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
