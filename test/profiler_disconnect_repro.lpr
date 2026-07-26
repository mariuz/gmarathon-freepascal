program profiler_disconnect_repro;
{ Minimal reproduction of an IBX defect found while implementing the Firebird
  profiler support, kept so it can be re-run against a future ibx4lazarus.

  Reading one of the profiler's own PLG$PROF_* relations through TIBQuery
  leaves the attachment in a state where disconnecting raises
  EObjectCheck: Object reference is Nil, from inside IBX's own
  FBTransaction.Commit <- EndAllTransactions <- Disconnect.

  It is not schema qualification (PUBLIC.RT reads and disconnects cleanly), not
  the prepared statement (unpreparing first does not help), and not global
  temporary tables (the relations are ordinary persistent tables and views).
  Freeing the query and the transaction before disconnecting does not help
  either, which places the residue on the attachment.

  Usage:
    ./profiler_disconnect_repro <database> <user> <password> "<select>"
  Expected today: a plain table disconnects cleanly, a PLG$PROF_* relation
  does not. When both disconnect cleanly, the defect is fixed and Marathon can
  gain a profiler window. }

{$MODE Delphi}{$H+}
uses SysUtils, Classes, IBDatabase, IBQuery;
var DB: TIBDatabase; Tr: TIBTransaction; Q: TIBQuery;
begin
  DB := TIBDatabase.Create(nil); Tr := TIBTransaction.Create(nil);
  DB.DatabaseName := ParamStr(1);
  DB.Params.Values['user_name'] := ParamStr(2);
  DB.Params.Values['password'] := ParamStr(3);
  DB.LoginPrompt := False;
  Tr.DefaultDatabase := DB; DB.DefaultTransaction := Tr;
  DB.Connected := True; Tr.StartTransaction;
  Q := TIBQuery.Create(nil); Q.Database := DB; Q.Transaction := Tr;
  try
    Q.SQL.Text := ParamStr(4);
    Q.Open;
    WriteLn('read ok, EOF=', Q.EOF);
    Q.Close;
    if ParamStr(5) = 'freequery' then FreeAndNil(Q);
    if Tr.Active then Tr.Commit;
    if ParamStr(5) = 'freetrans' then begin FreeAndNil(Q); FreeAndNil(Tr); end;
    DB.Connected := False;
    WriteLn('DISCONNECTED CLEANLY');
  except
    on E: Exception do WriteLn('EXCEPTION: ', E.ClassName, ': ', E.Message);
  end;
end.
