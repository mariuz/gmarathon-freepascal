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

unit ServerDashboard;

{$MODE Delphi}

{ Tools > Server Dashboard: how busy the database is, as it happens.

  Everything else here that reads MON$ shows a snapshot - the Session Monitor
  says what is running now, the performance panel says what a statement cost.
  Neither answers "is this getting worse", and that is the question someone
  watching a server has.

  Firebird's counters are cumulative, so what is plotted is the rate between
  samples rather than the counters themselves; ServerMetrics does that
  arithmetic and is checked without a window, including the three ways a naive
  rate goes wrong. This window samples on a timer, keeps a bounded history and
  draws it.

  Sampling costs a query against MON$ every few seconds, which is not free on a
  busy server - so it starts stopped, says so, and the interval is the user's
  to choose. A dashboard that begins hammering the server the moment it opens
  would be its own worst example. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Grids, IBDatabase, IBQuery, TAGraph, TASeries, TASources,
  ServerMetrics;

type
  TfrmServerDashboard = class(TForm)
    pnlTop: TPanel;
    lblConnection: TLabel;
    lblInterval: TLabel;
    cmbInterval: TComboBox;
    btnStart: TButton;
    btnStop: TButton;
    btnSampleNow: TButton;
    chtRates: TChart;
    grdRates: TStringGrid;
    splDashboard: TSplitter;
    stsDashboard: TStatusBar;
    tmrSample: TTimer;
    qryMetrics: TIBQuery;
    tranMetrics: TIBTransaction;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSampleNowClick(Sender: TObject);
    procedure cmbIntervalChange(Sender: TObject);
    procedure tmrSampleTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FConnectionName: String;
    FHistory: TMetricHistory;
    FSeries: array[TMetricKind] of TLineSeries;
    procedure SetConnectionName(const Value: String);
    function GetSamplingState: Boolean;
    procedure BuildSeries;
    procedure ShowLatest;
    function ReadSample(out ASample: TMetricSample): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { One reading, added to the history and drawn. Public so the harness can
      sample without waiting for a timer. }
    procedure SampleNow;
    procedure StartSampling;
    procedure StopSampling;
    property ConnectionName: String read FConnectionName write SetConnectionName;
    property History: TMetricHistory read FHistory;
    property Sampling: Boolean read GetSamplingState;
  end;

implementation

{$R *.lfm}

uses MarathonIDE, MarathonProjectCache;

const
  { Twenty minutes at five seconds, which is long enough to see a trend and
    short enough that a window left open overnight holds a bounded amount. }
  HistoryLength = 240;

  { What the plot shows. The rest are in the grid: nine lines on one chart is
    a colour puzzle rather than a picture, and these three are the ones that
    say whether the server is working hard. }
  PlottedKinds = [mkPageReads, mkPageWrites, mkPageFetches];

constructor TfrmServerDashboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHistory := TMetricHistory.Create(HistoryLength);
  BuildSeries;
end;

destructor TfrmServerDashboard.Destroy;
begin
  FHistory.Free;
  inherited Destroy;
end;

function TfrmServerDashboard.GetSamplingState: Boolean;
begin
  Result := tmrSample.Enabled;
end;

procedure TfrmServerDashboard.BuildSeries;
var
  Kind: TMetricKind;
  Colours: array[0..2] of TColor = (clNavy, clMaroon, clGreen);
  Next: Integer;
begin
  Next := 0;
  for Kind := Low(TMetricKind) to High(TMetricKind) do
  begin
    if not (Kind in PlottedKinds) then
    begin
      FSeries[Kind] := nil;
      Continue;
    end;
    FSeries[Kind] := TLineSeries.Create(chtRates);
    FSeries[Kind].Title := MetricName(Kind) + ' /s';
    FSeries[Kind].SeriesColor := Colours[Next mod Length(Colours)];
    FSeries[Kind].LinePen.Width := 2;
    chtRates.AddSeries(FSeries[Kind]);
    Inc(Next);
  end;
end;

procedure TfrmServerDashboard.SetConnectionName(const Value: String);
var
  Conn: TMarathonCacheConnection;
begin
  FConnectionName := Value;
  Caption := 'Server Dashboard - ' + Value;
  lblConnection.Caption := 'Connection: ' + Value;

  Conn := CacheConnectionNamed(Value);
  if not Assigned(Conn) then
  begin
    tranMetrics.DefaultDatabase := nil;
    qryMetrics.Database := nil;
    lblConnection.Caption := 'Connection: none';
    stsDashboard.SimpleText := 'No connection';
    btnStart.Enabled := False;
    btnSampleNow.Enabled := False;
    Exit;
  end;

  tranMetrics.DefaultDatabase := Conn.Connection;
  qryMetrics.Database := Conn.Connection;
  qryMetrics.Transaction := tranMetrics;
  qryMetrics.SQL.Text := DatabaseMetricsSQL;
  { Stopped, and saying so: sampling costs a MON$ query every few seconds, and
    a dashboard that starts hammering the server the moment it opens would be
    its own worst example. }
  stsDashboard.SimpleText :=
    'Not sampling. Press Start, or Sample Now for a single reading.';
end;

function TfrmServerDashboard.ReadSample(out ASample: TMetricSample): Boolean;
var
  Kind: TMetricKind;
  Names: array[TMetricKind] of String = ('PAGE_READS', 'PAGE_WRITES',
    'PAGE_FETCHES', 'PAGE_MARKS', 'SEQ_READS', 'IDX_READS', 'INSERTS',
    'UPDATES', 'DELETES');
begin
  Result := False;
  ASample.Valid := False;
  ASample.Taken := Now;
  for Kind := Low(TMetricKind) to High(TMetricKind) do
    ASample.Counts[Kind] := 0;

  if not Assigned(qryMetrics.Database) or not qryMetrics.Database.Connected then
    Exit;
  try
    { Firebird takes a fresh MON$ snapshot for the first statement of each new
      transaction, so re-opening on the same one would sample the same instant
      for ever - which is the whole point of this window, got wrong. }
    qryMetrics.Close;
    if tranMetrics.Active then
      tranMetrics.Commit;
    tranMetrics.StartTransaction;
    qryMetrics.Open;
    if qryMetrics.EOF then
    begin
      qryMetrics.Close;
      Exit;
    end;
    for Kind := Low(TMetricKind) to High(TMetricKind) do
      ASample.Counts[Kind] :=
        qryMetrics.FieldByName(Names[Kind]).AsLargeInt;
    ASample.Valid := True;
    Result := True;
    qryMetrics.Close;
    if tranMetrics.Active then
      tranMetrics.Commit;
  except
    on E: Exception do
    begin
      if tranMetrics.Active then
        tranMetrics.Rollback;
      stsDashboard.SimpleText := 'Could not read the counters: ' + E.Message;
      { Stop rather than raise the same error every few seconds at someone. }
      StopSampling;
    end;
  end;
end;

procedure TfrmServerDashboard.SampleNow;
var
  S: TMetricSample;
begin
  if not ReadSample(S) then
    Exit;
  FHistory.Add(S);
  ShowLatest;
end;

procedure TfrmServerDashboard.ShowLatest;
var
  Kind: TMetricKind;
  Idx, Row: Integer;
  Rate: Double;
begin
  grdRates.BeginUpdate;
  try
    grdRates.RowCount := Ord(High(TMetricKind)) + 2;
    grdRates.Cells[0, 0] := 'Counter';
    grdRates.Cells[1, 0] := 'Per second';
    grdRates.Cells[2, 0] := 'Total';
    Row := 1;
    for Kind := Low(TMetricKind) to High(TMetricKind) do
    begin
      grdRates.Cells[0, Row] := MetricName(Kind);
      grdRates.Cells[1, Row] := FormatFloat('0.0', FHistory.LatestRate(Kind));
      if FHistory.Count > 0 then
        grdRates.Cells[2, Row] :=
          IntToStr(FHistory[FHistory.Count - 1].Counts[Kind])
      else
        grdRates.Cells[2, Row] := '';
      Inc(Row);
    end;
  finally
    grdRates.EndUpdate;
  end;

  { The plot is of rates, so it starts one sample in - there is nothing to
    plot for the first reading, and drawing its raw counter would put a
    meaningless spike at the left of every session. }
  for Kind := Low(TMetricKind) to High(TMetricKind) do
  begin
    if not Assigned(FSeries[Kind]) then
      Continue;
    FSeries[Kind].Clear;
    for Idx := 1 to FHistory.Count - 1 do
    begin
      Rate := MetricRate(FHistory[Idx - 1], FHistory[Idx], Kind);
      FSeries[Kind].AddXY(Idx, Rate);
    end;
  end;

  if FHistory.Count < 2 then
    stsDashboard.SimpleText :=
      'One reading so far - a rate needs two, so the next sample fills the chart.'
  else
    stsDashboard.SimpleText := IntToStr(FHistory.Count) + ' readings, ' +
      FormatFloat('0.0', FHistory.LatestRate(mkPageFetches)) +
      ' page fetches a second';
end;

procedure TfrmServerDashboard.StartSampling;
begin
  if not Assigned(qryMetrics.Database) then
    Exit;
  tmrSample.Enabled := True;
  btnStart.Enabled := False;
  btnStop.Enabled := True;
  { A first reading straight away, so something is on screen before the first
    interval has passed. }
  SampleNow;
end;

procedure TfrmServerDashboard.StopSampling;
begin
  tmrSample.Enabled := False;
  btnStart.Enabled := Assigned(qryMetrics.Database);
  btnStop.Enabled := False;
end;

procedure TfrmServerDashboard.btnStartClick(Sender: TObject);
begin
  StartSampling;
end;

procedure TfrmServerDashboard.btnStopClick(Sender: TObject);
begin
  StopSampling;
  stsDashboard.SimpleText := 'Stopped after ' + IntToStr(FHistory.Count) +
    ' reading(s).';
end;

procedure TfrmServerDashboard.btnSampleNowClick(Sender: TObject);
begin
  SampleNow;
end;

procedure TfrmServerDashboard.cmbIntervalChange(Sender: TObject);
var
  Seconds: Integer;
begin
  case cmbInterval.ItemIndex of
    0: Seconds := 1;
    2: Seconds := 15;
    3: Seconds := 60;
  else
    Seconds := 5;
  end;
  tmrSample.Interval := Seconds * 1000;
end;

procedure TfrmServerDashboard.tmrSampleTimer(Sender: TObject);
begin
  SampleNow;
end;

procedure TfrmServerDashboard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopSampling;
  qryMetrics.Close;
  if tranMetrics.Active then
    tranMetrics.Commit;
  Action := caFree;
end;

end.
