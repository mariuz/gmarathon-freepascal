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

unit MemoryUsage;

{$MODE Delphi}

{ What the server is holding memory for.

  MON$MEMORY_USAGE has a row per memory pool, and on its own it says almost
  nothing: a stat id, a group number, and four byte counts. What makes it
  readable is joining it back to whatever owns the pool - the attachment, or
  the database itself - and turning the group number into a word.

  The group numbers are the engine's, and nothing in the catalogue explains
  them, which is exactly why they belong in one named place rather than in a
  case statement inside a form.

  No LCL and no IBX: a query is text and a group is a number. }

interface

uses SysUtils;

const
  { MON$STAT_GROUP, as the engine numbers it. }
  StatGroupDatabase    = 0;
  StatGroupAttachment  = 1;
  StatGroupTransaction = 2;
  StatGroupStatement   = 3;
  StatGroupCall        = 4;

{ The group as a word rather than a number. An unknown number is shown as
  itself: a later Firebird adding a group should read as "group 5" rather than
  as one of the ones that exist. }
function StatGroupName(AGroup: Integer): String;

{ Bytes, in something a person can compare at a glance. The grid shows several
  pools at once and the interesting question is which is large. }
function FormatBytes(ABytes: Int64): String;

{ Every pool, largest first, with the attachment that owns it where there is
  one.

  Left-joined rather than joined: the database's own pool has no attachment,
  and it is usually the largest row in the table - dropping it would leave the
  window showing the small ones. }
function MemoryUsageSQL: String;

implementation

function StatGroupName(AGroup: Integer): String;
begin
  case AGroup of
    StatGroupDatabase:    Result := 'Database';
    StatGroupAttachment:  Result := 'Attachment';
    StatGroupTransaction: Result := 'Transaction';
    StatGroupStatement:   Result := 'Statement';
    StatGroupCall:        Result := 'Call';
  else
    Result := 'Group ' + IntToStr(AGroup);
  end;
end;

function FormatBytes(ABytes: Int64): String;
const
  KB = Int64(1024);
  MB = KB * 1024;
  GB = MB * 1024;
begin
  if ABytes < 0 then
    Result := ''
  else if ABytes >= GB then
    Result := FormatFloat('0.0', ABytes / GB) + ' GB'
  else if ABytes >= MB then
    Result := FormatFloat('0.0', ABytes / MB) + ' MB'
  else if ABytes >= KB then
    Result := FormatFloat('0.0', ABytes / KB) + ' KB'
  else
    Result := IntToStr(ABytes) + ' B';
end;

function MemoryUsageSQL: String;
begin
  Result :=
    'select m.mon$stat_group, m.mon$stat_id, ' +
    '       m.mon$memory_used, m.mon$memory_allocated, ' +
    '       m.mon$max_memory_used, m.mon$max_memory_allocated, ' +
    '       a.mon$attachment_id, a.mon$user, a.mon$remote_address ' +
    'from mon$memory_usage m ' +
    '  left join mon$attachments a on a.mon$stat_id = m.mon$stat_id ' +
    'order by m.mon$memory_allocated desc';
end;

end.
