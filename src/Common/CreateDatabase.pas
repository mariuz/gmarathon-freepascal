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

unit CreateDatabase;

{$MODE Delphi}

{ Creating a Firebird database.

  This exists because the original Create Database wizard was a Windows COM
  component with a Delphi .dfm and no .lfm, so on this port File > Create
  Database did nothing at all - not even report that it could not. See
  ROADMAP.md.

  Nothing here needs the COM component: IBX creates a database from the
  connection parameters, turning user_name, password, page_size, lc_ctype and
  sql_dialect into the CREATE DATABASE statement itself. That is also why the
  option list is what it is - those five are what the DPB route can express.

  LCL-free so test/ibx_smoke_test.lpr can create databases and check what came
  out. }

interface

uses SysUtils, Classes, IBDatabase;

type
  TCreateDatabaseOptions = record
    { Server host, or empty for a local file. Combined with FileName the way
      IBX wants it: 'host:/path/to/db.fdb'. }
    ServerName: String;
    FileName: String;
    UserName: String;
    Password: String;
    { Firebird's own default is used when this is empty, rather than a guess
      made here. }
    CharacterSet: String;
    PageSize: Integer;
    Dialect: Integer;
  end;

{ The connection string IBX wants for these options. Exposed because the caller
  needs the same string to register a connection afterwards, and because it is
  worth testing on its own. }
function DatabaseConnectString(const Options: TCreateDatabaseOptions): String;

{ Creates the database. Returns True on success; on failure returns False and
  puts the reason in ErrorMessage rather than raising, because every caller has
  a dialog to put it in. }
function CreateFirebirdDatabase(const Options: TCreateDatabaseOptions;
  out ErrorMessage: String): Boolean;

{ The page sizes worth offering.

  Only the ones the server will actually honour. Firebird does not refuse a size
  outside its range, it silently clamps it: on Firebird 6, asking for 1024, 2048
  or 4096 all produce an 8192-byte page, and 65536 produces 32768 (verified by
  creating a database at each size and reading MON$DATABASE.MON$PAGE_SIZE back).
  Offering 4096 would therefore show a choice that is quietly ignored, which is
  worse than not offering it. }
function SupportedPageSizes: TStringList;

implementation

function DatabaseConnectString(const Options: TCreateDatabaseOptions): String;
begin
  Result := Trim(Options.FileName);
  if Trim(Options.ServerName) <> '' then
    Result := Trim(Options.ServerName) + ':' + Result;
end;

function SupportedPageSizes: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('8192');
  Result.Add('16384');
  Result.Add('32768');
end;

function CreateFirebirdDatabase(const Options: TCreateDatabaseOptions;
  out ErrorMessage: String): Boolean;
var
  DB: TIBDatabase;
begin
  Result := False;
  ErrorMessage := '';

  if Trim(Options.FileName) = '' then
  begin
    ErrorMessage := 'No database file name was given.';
    Exit;
  end;

  { Checked here only for a local path. A remote file lives on the server and
    is not ours to stat - Firebird will refuse it and say so. Worth catching
    locally all the same, because CREATE DATABASE over an existing file is the
    one mistake in this dialog that could cost somebody a database. }
  if (Trim(Options.ServerName) = '') and FileExists(Trim(Options.FileName)) then
  begin
    ErrorMessage := Trim(Options.FileName) + ' already exists. Creating a ' +
      'database will not overwrite it - choose another name, or remove the ' +
      'existing file first.';
    Exit;
  end;

  DB := TIBDatabase.Create(nil);
  try
    DB.DatabaseName := DatabaseConnectString(Options);
    DB.Params.Values['user_name'] := Options.UserName;
    DB.Params.Values['password'] := Options.Password;
    if Trim(Options.CharacterSet) <> '' then
      DB.Params.Values['lc_ctype'] := Trim(Options.CharacterSet);
    if Options.PageSize > 0 then
      DB.Params.Values['page_size'] := IntToStr(Options.PageSize);
    if Options.Dialect > 0 then
      DB.SQLDialect := Options.Dialect;
    DB.LoginPrompt := False;
    try
      DB.CreateDatabase;
      { Created, and left closed: the caller decides whether to connect, and a
        connection held open here would keep the file locked with nothing
        watching it. }
      if DB.Connected then
        DB.Connected := False;
      Result := True;
    except
      on E: Exception do
        ErrorMessage := E.Message;
    end;
  finally
    DB.Free;
  end;
end;

end.
