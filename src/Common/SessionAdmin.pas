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

unit SessionAdmin;

{$MODE Delphi}

{ Killing an attachment and cancelling a statement, as the statements that do
  it.

  Firebird has no CANCEL or KILL verb: both are done by deleting the row from
  the monitoring table, which is the one place in the catalogue the engine
  treats a DELETE as a command rather than as a write. That is unusual enough
  that it is worth having in one named place rather than concatenated at two
  button handlers.

  Here rather than in the Session Monitor because the window cannot be driven
  headlessly - both handlers ask for confirmation first, and a modal dialog
  under Xvfb is a hang rather than a failure. The statements and the guard can
  be checked without a window; that the statements actually take effect is
  checked against a real server by the GUI harness, which runs them itself. }

interface

uses SysUtils;

{ The attachment this window is itself connected on. Deleting that row would
  kill the monitor along with the attachment, so the button refuses it - and
  refusing needs to know which one it is. }
const
  CurrentAttachmentSQL = 'select current_connection from rdb$database';

{ Disconnects an attachment. Immediate: whatever it had uncommitted is lost,
  which is why the caller asks first. }
function DisconnectAttachmentSQL(AAttachmentId: Integer): String;

{ Cancels a running statement, leaving the attachment connected. }
function CancelStatementSQL(AStatementId: Integer): String;

{ True when the attachment picked out is the one asking. The check is the
  reason the Session Monitor does not disconnect itself the first time anyone
  presses the button with the top row selected - its own attachment is
  normally in the list, and often first. }
function IsOwnAttachment(ACandidate, ACurrent: Integer): Boolean;

implementation

function DisconnectAttachmentSQL(AAttachmentId: Integer): String;
begin
  Result := 'delete from mon$attachments where mon$attachment_id = ' +
    IntToStr(AAttachmentId);
end;

function CancelStatementSQL(AStatementId: Integer): String;
begin
  Result := 'delete from mon$statements where mon$statement_id = ' +
    IntToStr(AStatementId);
end;

function IsOwnAttachment(ACandidate, ACurrent: Integer): Boolean;
begin
  { An id that could not be read is not a match for anything - answering True
    would block every disconnect rather than just this window's own. }
  if (ACandidate <= 0) or (ACurrent <= 0) then
    Result := False
  else
    Result := ACandidate = ACurrent;
end;

end.
