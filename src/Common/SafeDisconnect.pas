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

unit SafeDisconnect;

{$MODE Delphi}

{ Closing a connection without letting a fault in the database layer take the
  application down.

  This exists for a specific defect: reading a Firebird 4 WITH TIME ZONE column
  through TIBQuery leaves the attachment in a state where IBX raises
  EObjectCheck from inside its own EndAllTransactions while disconnecting. See
  test/timezone_disconnect_repro.lpr. Marathon's own queries cast such columns
  to text and so never trigger it, but a user's query in the SQL editor can,
  and that is not something this codebase can prevent.

  Propagating the fault is the worst option: the connection is being closed
  either way, the user cannot act on it, and in the caller it would abandon the
  tree cleanup that follows and leave a closed connection still displayed as
  open. So the disconnect is attempted, the message is handed back for the
  caller to record, and teardown carries on. }

interface

uses SysUtils, IBDatabase;

{ Closes DB. Returns an empty string on a clean disconnect, or the message the
  database layer raised. Never raises. }
function DisconnectQuietly(DB: TIBDatabase): String;

implementation

function DisconnectQuietly(DB: TIBDatabase): String;
begin
  Result := '';
  if not Assigned(DB) then
    Exit;
  try
    DB.Connected := False;
  except
    on E: Exception do
      Result := E.ClassName + ': ' + E.Message;
  end;
end;

end.
