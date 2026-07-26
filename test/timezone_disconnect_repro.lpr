program timezone_disconnect_repro;
{ Minimal reproduction of an IBX defect, kept so it can be re-run against a
  future ibx4lazarus.

  Reading a Firebird 4 WITH TIME ZONE column through TIBQuery leaves the
  attachment in a state where disconnecting raises
  EObjectCheck: Object reference is Nil, from inside IBX's own
  FBTransaction.Commit <- EndAllTransactions <- Disconnect.

  Narrowed by elimination: an integer column and a plain TIMESTAMP disconnect
  cleanly; TIMESTAMP WITH TIME ZONE and TIME WITH TIME ZONE do not. It is not
  the prepared statement (unpreparing first does not help), not schema
  qualification, and not the query or transaction lifetime (freeing both first
  does not help) - which places the residue on the attachment.

  This was first met through the profiler, whose PLG$PROF_SESSIONS view has
  TIMESTAMP WITH TIME ZONE columns; the profiler was a symptom, not the cause.

  Casting the column to VARCHAR on the server side avoids it entirely, and has
  the side benefit of preserving the IANA zone name that IBX otherwise reduces
  to a numeric offset. That is what Marathon's own MON$ queries do.

  Usage:
    ./timezone_disconnect_repro <database> <user> <password> "<select>"
  Expected today:
    select TS_PLAIN from TZT                    -> DISCONNECTED CLEANLY
    select TS_TZ from TZT                       -> EObjectCheck
    select cast(TS_TZ as varchar(60)) from TZT  -> DISCONNECTED CLEANLY
  When the middle case disconnects cleanly, the defect is fixed. }

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
