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

unit ServerMetrics;

{$MODE Delphi}

{ How busy the database is, over time.

  The Session Monitor answers "what is happening now" and the performance panel
  answers "what did that statement cost". Neither answers "is this getting
  worse", which is the question someone watching a server actually has - and
  the one thing this program had no way to show, because everything it reads
  from MON$ is a snapshot.

  Firebird's counters are cumulative since the database was attached, so a
  snapshot on its own says almost nothing: 19,772 page fetches is a number
  without a second number to compare it with. What is worth plotting is the
  *rate* - the difference between two samples over the time between them.

  Three things that rate has to survive, all of which produce nonsense if
  ignored: two samples with the same timestamp (a division by zero), a counter
  that went backwards because the database was detached and reattached in
  between (a large negative rate, drawn as a spike), and the first sample,
  which has nothing to be compared against.

  No LCL, no IBX, no chart: this is arithmetic over samples. }

interface

uses SysUtils, Classes;

type
  { The counters worth watching, all from MON$IO_STATS and MON$RECORD_STATS
    for the database's own stat id. }
  TMetricKind = (mkPageReads, mkPageWrites, mkPageFetches, mkPageMarks,
    mkSeqReads, mkIdxReads, mkInserts, mkUpdates, mkDeletes);

  TMetricSample = record
    Taken: TDateTime;
    Counts: array[TMetricKind] of Int64;
    Valid: Boolean;
  end;

  { A fixed number of samples, oldest dropped. A dashboard left open for a day
    must not grow without limit. }
  TMetricHistory = class
  private
    FSamples: array of TMetricSample;
    FCount: Integer;
    FCapacity: Integer;
    function GetSample(Index: Integer): TMetricSample;
  public
    constructor Create(ACapacity: Integer);
    procedure Add(const ASample: TMetricSample);
    procedure Clear;
    property Count: Integer read FCount;
    { Oldest first, so a plot reads left to right. }
    property Samples[Index: Integer]: TMetricSample read GetSample; default;
    { The rate of that counter between the last two samples, per second. Zero
      when there are not two to compare. }
    function LatestRate(AKind: TMetricKind): Double;
  end;

{ What to call a counter on screen. }
function MetricName(AKind: TMetricKind): String;

{ The rate per second between two samples.

  Zero rather than an exception or a spike when the two cannot be compared:
  either sample invalid, no time between them, or the counter lower than it
  was - which means the server started counting again, not that work was
  undone. }
function MetricRate(const AEarlier, ALater: TMetricSample;
  AKind: TMetricKind): Double;

{ Every counter this reads, for the database rather than for one attachment. }
function DatabaseMetricsSQL: String;

implementation

function MetricName(AKind: TMetricKind): String;
begin
  case AKind of
    mkPageReads:   Result := 'Page reads';
    mkPageWrites:  Result := 'Page writes';
    mkPageFetches: Result := 'Page fetches';
    mkPageMarks:   Result := 'Page marks';
    mkSeqReads:    Result := 'Sequential reads';
    mkIdxReads:    Result := 'Indexed reads';
    mkInserts:     Result := 'Inserts';
    mkUpdates:     Result := 'Updates';
    mkDeletes:     Result := 'Deletes';
  else
    Result := 'Unknown';
  end;
end;

function MetricRate(const AEarlier, ALater: TMetricSample;
  AKind: TMetricKind): Double;
var
  Seconds: Double;
  Delta: Int64;
begin
  Result := 0;
  if not (AEarlier.Valid and ALater.Valid) then
    Exit;

  Seconds := (ALater.Taken - AEarlier.Taken) * SecsPerDay;
  { Two samples taken inside the same instant have no rate between them, and
    dividing by that is how a dashboard shows infinity. }
  if Seconds <= 0 then
    Exit;

  Delta := ALater.Counts[AKind] - AEarlier.Counts[AKind];
  { A counter that went backwards means the server started counting again -
    these are cumulative since the attachment began - rather than that work
    was undone. Nothing is a better answer than a negative spike. }
  if Delta < 0 then
    Exit;

  Result := Delta / Seconds;
end;

function DatabaseMetricsSQL: String;
begin
  { Left-joined: a server that keeps one of these tables empty for the
    database's own stat id should give zeroes rather than no row at all. }
  Result :=
    'select coalesce(io.mon$page_reads, 0) as PAGE_READS, ' +
    '       coalesce(io.mon$page_writes, 0) as PAGE_WRITES, ' +
    '       coalesce(io.mon$page_fetches, 0) as PAGE_FETCHES, ' +
    '       coalesce(io.mon$page_marks, 0) as PAGE_MARKS, ' +
    '       coalesce(rs.mon$record_seq_reads, 0) as SEQ_READS, ' +
    '       coalesce(rs.mon$record_idx_reads, 0) as IDX_READS, ' +
    '       coalesce(rs.mon$record_inserts, 0) as INSERTS, ' +
    '       coalesce(rs.mon$record_updates, 0) as UPDATES, ' +
    '       coalesce(rs.mon$record_deletes, 0) as DELETES ' +
    'from mon$database d ' +
    '  left join mon$io_stats io on io.mon$stat_id = d.mon$stat_id ' +
    '  left join mon$record_stats rs on rs.mon$stat_id = d.mon$stat_id';
end;

constructor TMetricHistory.Create(ACapacity: Integer);
begin
  inherited Create;
  if ACapacity < 2 then
    ACapacity := 2;
  FCapacity := ACapacity;
  SetLength(FSamples, FCapacity);
  FCount := 0;
end;

procedure TMetricHistory.Clear;
begin
  FCount := 0;
end;

function TMetricHistory.GetSample(Index: Integer): TMetricSample;
begin
  Result := FSamples[Index];
end;

procedure TMetricHistory.Add(const ASample: TMetricSample);
var
  Idx: Integer;
begin
  if FCount < FCapacity then
  begin
    FSamples[FCount] := ASample;
    Inc(FCount);
    Exit;
  end;
  { Full: drop the oldest and keep the order, which is what a plot reads. }
  for Idx := 0 to FCapacity - 2 do
    FSamples[Idx] := FSamples[Idx + 1];
  FSamples[FCapacity - 1] := ASample;
end;

function TMetricHistory.LatestRate(AKind: TMetricKind): Double;
begin
  if FCount < 2 then
    Exit(0);
  Result := MetricRate(FSamples[FCount - 2], FSamples[FCount - 1], AKind);
end;

end.
