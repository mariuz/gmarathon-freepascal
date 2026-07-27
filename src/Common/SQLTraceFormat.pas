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

unit SQLTraceFormat;

{$MODE Delphi}

{ What the SQL trace watches, and how a traced statement is written down.

  Marathon's SQL Trace window has been a window onto nothing. TIB_Monitor, the
  component it is built on, was IB Objects' and was replaced during the port by
  a class with all the right properties and no behaviour at all - so the
  window opened, the Options dialog saved settings into it, and not one line
  ever appeared.

  IBX has a real monitor, so the feature can work; what it does not have is
  Marathon's vocabulary. Marathon asks for categories - connections,
  transactions, statements, rows - and offers a second, finer set for
  statements; IBX has one flat set of trace flags. Translating between them is
  a decision with several ways to be wrong, and it is here rather than in the
  component so it can be checked without a database.

  Nothing in this unit references IBX either, for the same reason: the flags
  come back as a set of this unit's own enumeration, which the component maps
  across one for one. }

interface

uses SysUtils, Classes;

type
  { What the Options dialog offers, unchanged - these are the names it has
    always saved under, and changing them would silently discard the settings
    of anyone upgrading. }
  TMonitorGroup = (mgConnection, mgTransaction, mgStatement, mgRow, mgBlob, mgArray);
  TMonitorGroups = set of TMonitorGroup;

  TStatementGroup = (sgAllocate, sgPrepare, sgDescribe, sgStatementInfo, sgExecute,
    sgExecuteImmediate, sgServerCursor, sgFree, sgFetch, sgField, sgError);
  TStatementGroups = set of TStatementGroup;

  { IBX's trace flags, mirrored so this unit needs no IBX. The component that
    does the watching maps these onto the real ones by name. }
  TTraceCategory = (tcPrepare, tcExecute, tcFetch, tcError, tcStatement,
    tcConnect, tcTransact, tcBlob, tcService, tcMisc);
  TTraceCategories = set of TTraceCategory;

{ The categories to watch for a given pair of Marathon's sets.

  The statement groups only matter when statements are being watched at all -
  asking for Prepare while Statements is off means the same as asking for
  nothing, and turning it on regardless would trace what the user had just
  switched off. }
function TraceCategoriesFor(Groups: TMonitorGroups;
  Statements: TStatementGroups): TTraceCategories;

{ One traced event as a line for the window.

  IncludeTimeStamp and ItemEnd are settings the Options dialog has always
  offered and that have never done anything, because nothing was producing
  lines for them to affect. }
function FormatTraceLine(const EventText: String; EventTime: TDateTime;
  IncludeTimeStamp: Boolean; const ItemEnd: String): String;

{ True when an event that took ElapsedTicks is worth showing.

  MinTicks is how the trace is made usable on a busy connection: a statement
  that came back instantly is rarely what is being looked for. Zero means show
  everything, which is the default and what someone who has not thought about
  it expects. }
function PassesMinTicks(ElapsedTicks, MinTicks: Integer): Boolean;

implementation

function TraceCategoriesFor(Groups: TMonitorGroups;
  Statements: TStatementGroups): TTraceCategories;
begin
  Result := [];
  if mgConnection in Groups then
    Include(Result, tcConnect);
  if mgTransaction in Groups then
    Include(Result, tcTransact);
  if mgBlob in Groups then
    Include(Result, tcBlob);
  { A row is a fetch. IBX has no separate notion of one, and tracing fetches is
    what makes rows appear. }
  if mgRow in Groups then
    Include(Result, tcFetch);
  { Arrays have no flag of their own; they arrive among the miscellany. }
  if mgArray in Groups then
    Include(Result, tcMisc);

  if not (mgStatement in Groups) then
    Exit;

  Include(Result, tcStatement);
  if sgPrepare in Statements then
    Include(Result, tcPrepare);
  if (sgExecute in Statements) or (sgExecuteImmediate in Statements) then
    Include(Result, tcExecute);
  if sgFetch in Statements then
    Include(Result, tcFetch);
  if sgError in Statements then
    Include(Result, tcError);
  { Allocate, Describe, StatementInfo, ServerCursor, Free and Field have no
    flag apiece. They are the housekeeping around a statement rather than the
    statement, and IBX reports them among the miscellany - so asking for any of
    them asks for that. }
  if Statements * [sgAllocate, sgDescribe, sgStatementInfo, sgServerCursor,
                   sgFree, sgField] <> [] then
    Include(Result, tcMisc);
end;

function FormatTraceLine(const EventText: String; EventTime: TDateTime;
  IncludeTimeStamp: Boolean; const ItemEnd: String): String;
begin
  Result := TrimRight(EventText);
  if IncludeTimeStamp then
    { To the millisecond: two statements in the same second is the ordinary
      case, and a timestamp that cannot tell them apart is decoration. }
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', EventTime) + '  ' + Result;
  if ItemEnd <> '' then
    Result := Result + ItemEnd;
end;

function PassesMinTicks(ElapsedTicks, MinTicks: Integer): Boolean;
begin
  Result := (MinTicks <= 0) or (ElapsedTicks >= MinTicks);
end;

end.
