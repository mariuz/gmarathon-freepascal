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

unit MaintenanceOps;

{$MODE Delphi}

{ What the Maintenance dialog refuses to do, and why.

  Backup and restore are the two operations in this program that can destroy a
  database that was never opened - restore writes a whole file - so the guards
  in front of them matter more than the calls themselves. They were written
  inline between MessageDlg calls, which means they could not be checked
  without a window: a modal dialog under Xvfb is a hang rather than a failure.

  Here they are the answer to a question - what is wrong with this request -
  and the dialog's job is only to show it. Empty means nothing is wrong.

  No LCL and no IBX: this is about file names, so it needs neither. }

interface

uses SysUtils;

{ Why this backup cannot be started. }
function BackupRefusalReason(const ABackupFile: String): String;

{ Why this restore cannot be started.

  The third guard is the one worth having: a restore always *creates* the
  database it writes, so pointing it at a file that already exists is either a
  mistake or a request to overwrite a live database. Firebird would refuse it
  too, but only after the backup has been read and the user has answered the
  confirmation - and the message would be the engine's rather than one saying
  what to do about it. }
function RestoreRefusalReason(const ASource, ATarget: String;
  ATargetExists: Boolean): String;

{ The number of parallel workers to ask for. Firebird 5 added the parameter;
  older servers ignore it, so it is always sent and never version-gated.
  Below one is not a smaller request, it is a nonsensical one - the service
  takes it as "no parallelism", which is what one means. }
function ParallelWorkersFor(ARequested: Integer): Integer;

implementation

function BackupRefusalReason(const ABackupFile: String): String;
begin
  if Trim(ABackupFile) = '' then
    Result := 'Choose a backup file first.'
  else
    Result := '';
end;

function RestoreRefusalReason(const ASource, ATarget: String;
  ATargetExists: Boolean): String;
begin
  if Trim(ASource) = '' then
    Result := 'Choose a backup file to restore from first.'
  else if Trim(ATarget) = '' then
    Result := 'Choose a target database file first.'
  else if ATargetExists then
    Result := 'The target file already exists. Restore always creates a new ' +
      'database - choose a target file that does not exist yet, to avoid any ' +
      'risk to an existing database.'
  else
    Result := '';
end;

function ParallelWorkersFor(ARequested: Integer): Integer;
begin
  if ARequested < 1 then
    Result := 1
  else
    Result := ARequested;
end;

end.
