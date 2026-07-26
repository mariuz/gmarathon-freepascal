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

unit ProfilerQueries;

{$MODE Delphi}

{ Drives Firebird's built-in profiler (the RDB$PROFILER package, Firebird 5)
  and reads back what it recorded.

  The profiler writes into a set of PLG$PROF_* tables that the plugin creates
  on first use. Where those tables live is *not* fixed: on Firebird 6 they are
  in a schema of their own, PLG$PROFILER, and have to be qualified; before
  schemas existed they sat in the default schema and must not be. Rather than
  branch on a version, the prefix is resolved by asking the catalogue which
  schema the tables are actually in - which needs no version test and keeps
  working if that placement changes again.

  LCL-free so test/ibx_smoke_test.lpr can drive a real session end to end. }

interface

uses SysUtils, Classes, IBDatabase, IBQuery, IBSQL;

{ True when this server has the profiler package at all. Firebird 5 introduced
  it; on anything older the whole feature is unavailable rather than empty. }
function ProfilerAvailable(DB: TIBDatabase; Tr: TIBTransaction): Boolean;

{ '' or 'PLG$PROFILER.', whichever this server needs in front of a PLG$PROF_*
  table. Empty when the tables do not exist yet, which is the case until a
  session has been run. }
function ProfilerSchemaPrefix(DB: TIBDatabase; Tr: TIBTransaction): String;

{ Starts recording on this attachment, and returns the new session's id. }
function StartProfilerSession(DB: TIBDatabase; Tr: TIBTransaction;
  const Description: String): Int64;

{ Stops recording and flushes what was gathered into the PLG$PROF_* tables.
  Nothing is readable until this has run. }
procedure FinishProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);

procedure PauseProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);
procedure ResumeProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);

{ Throws away what this attachment has gathered but not yet flushed. It does
  NOT touch anything already written to the PLG$PROF_* tables - verified, and
  worth stating because the name suggests otherwise. Use ClearProfilerData for
  that. }
procedure DiscardProfilerData(DB: TIBDatabase; Tr: TIBTransaction);

{ Removes every recorded session and everything hanging off it. Deleting from
  the sessions table is enough: the dependent rows go with it (verified - the
  statements table empties too). }
procedure ClearProfilerData(DB: TIBDatabase; Tr: TIBTransaction; const Prefix: String);

{ The three things worth showing, given a prefix from ProfilerSchemaPrefix. }
function ProfilerSessionsSQL(const Prefix: String): String;
function ProfilerStatementStatsSQL(const Prefix: String): String;
function ProfilerRecordSourceStatsSQL(const Prefix: String): String;

implementation

{ Every entry point here can be called just after something else committed, so
  none of them may assume a transaction is open. Learned the hard way: without
  this, ProfilerAvailable reported "no profiler" on a server that has one,
  because the query raised and the guard swallowed it. }
procedure EnsureActive(Tr: TIBTransaction);
begin
  if Assigned(Tr) and not Tr.Active then
    Tr.StartTransaction;
end;

function ProfilerAvailable(DB: TIBDatabase; Tr: TIBTransaction): Boolean;
var
  Q: TIBQuery;
begin
  Result := False;
  EnsureActive(Tr);
  Q := TIBQuery.Create(nil);
  try
    Q.Database := DB;
    Q.Transaction := Tr;
    try
      { RDB$PACKAGES itself is Firebird 3, so on an older server this query is
        the error rather than the answer - either way the profiler is absent. }
      Q.SQL.Text := 'select 1 from rdb$packages where rdb$package_name = ''RDB$PROFILER''';
      Q.Open;
      Result := not Q.EOF;
      Q.Close;
    except
      on E: Exception do
        Result := False;
    end;
  finally
    Q.Free;
  end;
end;

function ProfilerSchemaPrefix(DB: TIBDatabase; Tr: TIBTransaction): String;
var
  Q: TIBQuery;
  SchemaField: TObject;
begin
  Result := '';
  EnsureActive(Tr);
  Q := TIBQuery.Create(nil);
  try
    Q.Database := DB;
    Q.Transaction := Tr;
    try
      Q.SQL.Text := 'select * from rdb$relations where rdb$relation_name = ' +
        '''PLG$PROF_SESSIONS''';
      Q.Open;
      if not Q.EOF then
      begin
        { RDB$SCHEMA_NAME does not exist before Firebird 6, and naming a column
          that is not there is a hard error rather than a NULL - so ask for it
          only if the dataset actually has it. }
        SchemaField := Q.FindField('rdb$schema_name');
        if Assigned(SchemaField) and not Q.FieldByName('rdb$schema_name').IsNull then
          Result := Trim(Q.FieldByName('rdb$schema_name').AsString) + '.';
      end;
      Q.Close;
    except
      on E: Exception do
        Result := '';
    end;
  finally
    Q.Free;
  end;
end;

procedure RunProfilerStatement(DB: TIBDatabase; Tr: TIBTransaction; const SQL: String);
var
  S: TIBSQL;
begin
  EnsureActive(Tr);
  S := TIBSQL.Create(nil);
  try
    S.Database := DB;
    S.Transaction := Tr;
    S.SQL.Text := SQL;
    S.ExecQuery;
    { Closed explicitly: leaving the statement open survives the Free but
      trips the attachment up at disconnect, when IBX ends the transaction
      underneath it. }
    S.Close;
  finally
    S.Free;
  end;
end;

function StartProfilerSession(DB: TIBDatabase; Tr: TIBTransaction;
  const Description: String): Int64;
var
  S: TIBSQL;
begin
  Result := -1;
  EnsureActive(Tr);
  S := TIBSQL.Create(nil);
  try
    S.Database := DB;
    S.Transaction := Tr;
    { START_SESSION is a function, so it is selected rather than executed. }
    S.SQL.Text := 'select rdb$profiler.start_session(' +
      AnsiQuotedStr(Description, '''') + ') from rdb$database';
    S.ExecQuery;
    if S.Current.Count > 0 then
      Result := S.Current[0].AsInt64;
    S.Close;
  finally
    S.Free;
  end;
end;

procedure FinishProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);
begin
  { The flag flushes the gathered data; without it nothing is readable. }
  RunProfilerStatement(DB, Tr, 'execute procedure rdb$profiler.finish_session(true)');
end;

procedure PauseProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);
begin
  RunProfilerStatement(DB, Tr, 'execute procedure rdb$profiler.pause_session(true)');
end;

procedure ResumeProfilerSession(DB: TIBDatabase; Tr: TIBTransaction);
begin
  RunProfilerStatement(DB, Tr, 'execute procedure rdb$profiler.resume_session');
end;

procedure DiscardProfilerData(DB: TIBDatabase; Tr: TIBTransaction);
begin
  RunProfilerStatement(DB, Tr, 'execute procedure rdb$profiler.discard');
end;

procedure ClearProfilerData(DB: TIBDatabase; Tr: TIBTransaction; const Prefix: String);
begin
  RunProfilerStatement(DB, Tr, 'delete from ' + Prefix + 'plg$prof_sessions');
end;

function ProfilerSessionsSQL(const Prefix: String): String;
begin
  Result :=
    'select profile_id, attachment_id, user_name, description, ' +
    'start_timestamp, finish_timestamp ' +
    'from ' + Prefix + 'plg$prof_sessions order by profile_id desc';
end;

function ProfilerStatementStatsSQL(const Prefix: String): String;
begin
  { Ordered by total time: the slowest statement is the reason anyone opens a
    profiler. }
  Result :=
    'select profile_id, statement_id, statement_type, routine_name, ' +
    'counter, min_elapsed_time, max_elapsed_time, total_elapsed_time, ' +
    'avg_elapsed_time, sql_text ' +
    'from ' + Prefix + 'plg$prof_statement_stats_view ' +
    'order by total_elapsed_time desc nulls last';
end;

function ProfilerRecordSourceStatsSQL(const Prefix: String): String;
begin
  Result :=
    'select profile_id, statement_id, cursor_id, record_source_id, ' +
    'access_path, open_counter, open_total_elapsed_time, ' +
    'fetch_counter, fetch_total_elapsed_time ' +
    'from ' + Prefix + 'plg$prof_record_source_stats_view ' +
    'order by fetch_total_elapsed_time desc nulls last';
end;

end.
