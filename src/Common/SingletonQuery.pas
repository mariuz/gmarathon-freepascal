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

unit SingletonQuery;

{$MODE Delphi}

{ Firebird executes some statements "with output" rather than through a
  cursor: a singleton INSERT/UPDATE/DELETE ... RETURNING, and an
  EXECUTE PROCEDURE against a procedure with output parameters. Both come back
  from prepare as SQLExecProcedure with output columns, and the values arrive
  in the statement's output buffer rather than a result set.

  IBX's TIBCustomDataSet only builds a cursor when the statement type is
  SQLSelect, so TIBQuery.Open returns no rows at all for these, and TIBQuery
  does not expose its inner TIBSQL - which is why the SQL editor used to
  execute them and then silently drop whatever they returned.

  A *multi-row* RETURNING is a different case that already worked: Firebird
  gives it a real cursor and reports SQLSelect, so it takes the ordinary path.

  This unit is deliberately free of any LCL dependency so that
  test/ibx_smoke_test.lpr can cover it - anything reached through the IDE's
  form units cannot be run from a console test. }

interface

uses SysUtils, Classes, DB, BufDataset, IBDatabase, IBSQL;

{ Runs SQLText once and returns its single output row as an in-memory dataset,
  positioned on that row. Returns nil - without executing anything - when the
  statement has no output columns, so the caller can fall back to an ordinary
  execute. The caller owns the result. }
function ExecuteSingletonOutput(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const SQLText: String; AOwner: TComponent): TBufDataset;

implementation

function ExecuteSingletonOutput(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  const SQLText: String; AOwner: TComponent): TBufDataset;
var
  S: TIBSQL;
  Idx, Dup: Integer;
  BaseName, FieldName: String;
begin
  Result := nil;
  S := TIBSQL.Create(nil);
  try
    S.Database := ADatabase;
    S.Transaction := ATransaction;
    S.SQL.Text := SQLText;
    S.Prepare;
    { Nothing to show - and importantly, nothing has been executed yet, so the
      caller can run the statement itself without it happening twice. }
    if S.MetaData.Count = 0 then
      Exit;

    S.ExecQuery;
    if S.Current.Count = 0 then
      Exit;

    Result := TBufDataset.Create(AOwner);
    try
      for Idx := 0 to S.Current.Count - 1 do
      begin
        BaseName := Trim(S.Current[Idx].Name);
        if BaseName = '' then
          BaseName := 'COLUMN_' + IntToStr(Idx + 1);
        { A safety net only: "returning ID, ID" is legal SQL, but Firebird
          already hands back distinct names for it (ID, ID1 - verified), so
          this loop is not expected to fire against a current server. }
        FieldName := BaseName;
        Dup := 1;
        { IndexOf, not Find - TFieldDefs.Find raises when the name is absent
          rather than returning nil, which is the opposite of what a
          "does this already exist?" test needs. }
        while Result.FieldDefs.IndexOf(FieldName) >= 0 do
        begin
          Inc(Dup);
          FieldName := BaseName + '_' + IntToStr(Dup);
        end;
        { Everything is rendered as text. This is a one-row confirmation of
          what the statement returned, not a result set to compute over, and
          going via AsString is what keeps DECFLOAT/INT128 exact - the same
          reason the JSON exporter avoids AsFloat for them. }
        Result.FieldDefs.Add(FieldName, ftString, 4096);
      end;
      Result.CreateDataset;
      Result.Open;
      Result.Append;
      for Idx := 0 to S.Current.Count - 1 do
        if not S.Current[Idx].IsNull then
          Result.Fields[Idx].AsString := S.Current[Idx].AsString;
      Result.Post;
      Result.First;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    S.Free;
  end;
end;

end.
