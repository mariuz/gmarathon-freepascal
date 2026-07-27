unit MarathonSQLMonitor;

{$MODE Delphi}

{ The component the SQL Trace window is built on.

  It was IB Objects' TIB_Monitor. The port replaced it with a class carrying
  all the right properties and no behaviour whatever, which is why the trace
  window has opened onto nothing ever since: the Options dialog saved settings
  into it, the window waited for lines, and none was ever produced.

  IBX has a real monitor - TIBSQLMonitor, over the hook every TIBSQL reports
  through - so this is now a thin adapter onto it. Thin deliberately: the names
  and the property set are unchanged, so SQLTrace.pas and the Options dialog
  work as they were written, and what those settings mean in IBX's vocabulary
  is decided in SQLTraceFormat where it is tested without a database. }

interface

uses Classes, SysUtils, IBDatabase, IBSQLMonitor, IBInternals, SQLTraceFormat;

type
  { The sets themselves live in SQLTraceFormat, which is where what they mean
    is decided. Aliasing the types here would not bring the enumeration's
    *values* with them, so a unit naming mgConnection has to name
    SQLTraceFormat too, as SQLTrace does. }
  TMonitorGroups = SQLTraceFormat.TMonitorGroups;
  TStatementGroups = SQLTraceFormat.TStatementGroups;

  TMonitorOutputEvent = procedure(Sender: TObject; const NewString: String) of object;

  TIB_Monitor = class(TComponent)
  private
    FMonitor: TIBSQLMonitor;
    FMonitorGroups: TMonitorGroups;
    FStatementGroups: TStatementGroups;
    FEnabled: Boolean;
    FOnMonitorOutputItem: TMonitorOutputEvent;
    FIncludeTimeStamp: Boolean;
    FItemEnd: String;
    FMinTicks: Integer;
    FNewLineText: String;
    { The connections being watched. Not owned - they belong to the project's
      connection cache and outlive any trace window. }
    FWatched: TList;
    procedure SetEnabled(const Value: Boolean);
    procedure SetMonitorGroups(const Value: TMonitorGroups);
    procedure SetStatementGroups(const Value: TStatementGroups);
    { Puts the current settings onto the IBX monitor. Called whenever any of
      them changes, because the flags are read when tracing starts and a
      setting changed afterwards would otherwise not take. }
    procedure ApplySettings;
    procedure MonitorSQL(EventText: String; EventTime: TDateTime);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Tracing has two halves, and having only one is why nothing arrives: the
      monitor receives, but a connection publishes nothing until its own
      TraceFlags say to. Every connection to be watched has to be handed over
      here, and again whenever the settings change - which is why the caller
      keeps the list rather than this. }
    procedure Watch(ADatabase: TIBDatabase);
    { Makes this the monitor that connections opened later are handed to. }
    procedure MakeActive;
    procedure Unwatch(ADatabase: TIBDatabase);
    { What a watched connection should publish, exposed so a caller applying
      this to several connections need not work it out itself. }
    function CurrentTraceFlags: TTraceFlags;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property MonitorGroups: TMonitorGroups read FMonitorGroups write SetMonitorGroups;
    property StatementGroups: TStatementGroups read FStatementGroups write SetStatementGroups;
    property OnMonitorOutputItem: TMonitorOutputEvent read FOnMonitorOutputItem write FOnMonitorOutputItem;
    property IncludeTimeStamp: Boolean read FIncludeTimeStamp write FIncludeTimeStamp;
    property ItemEnd: String read FItemEnd write FItemEnd;
    property MinTicks: Integer read FMinTicks write FMinTicks;
    property NewLineText: String read FNewLineText write FNewLineText;
  end;

procedure Register;

var
  { The trace window's monitor while one is open, so a connection opened after
    the window can be told to publish as well. Nil the rest of the time, which
    is what stops every connection paying for a trace nobody is watching. }
  ActiveTraceMonitor: TIB_Monitor = nil;

implementation

{ SQLTraceFormat mirrors IBX's flags rather than using them, so that deciding
  what to watch needs no IBX. This is where the two meet, and it is one line
  per flag on purpose: a lookup table would hide a missing case, whereas a
  case statement without one does not compile. }
function ToTraceFlag(Category: TTraceCategory): TTraceFlag;
begin
  case Category of
    tcPrepare:   Result := tfQPrepare;
    tcExecute:   Result := tfQExecute;
    tcFetch:     Result := tfQFetch;
    tcError:     Result := tfError;
    tcStatement: Result := tfStmt;
    tcConnect:   Result := tfConnect;
    tcTransact:  Result := tfTransact;
    tcBlob:      Result := tfBlob;
    tcService:   Result := tfService;
  else
    Result := tfMisc;
  end;
end;

{ Set by the trace window on open and cleared on close. A variable rather than
  a list because there is one trace window: SQLTrace brings the existing one to
  the front rather than opening a second. }
procedure TIB_Monitor.MakeActive;
begin
  ActiveTraceMonitor := Self;
end;

constructor TIB_Monitor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItemEnd := '';
  FNewLineText := #13#10;
  FWatched := TList.Create;
  FMonitor := TIBSQLMonitor.Create(Self);
  FMonitor.OnSQL := MonitorSQL;
  { Off until asked. The monitor starts a reader thread when it is enabled, and
    a trace window that has never been opened should not be paying for one. }
  FMonitor.Enabled := False;
end;

destructor TIB_Monitor.Destroy;
begin
  if Assigned(FMonitor) then
  begin
    { Detached first: the monitor's reader thread can deliver an event while
      the component is being torn down, and the handler would then run against
      a half-destroyed object. }
    FMonitor.OnSQL := nil;
    FMonitor.Enabled := False;
  end;
  { The connections outlive this, so they are left not publishing rather than
    left tracing into a monitor that has gone. }
  if ActiveTraceMonitor = Self then
    ActiveTraceMonitor := nil;
  while FWatched.Count > 0 do
    Unwatch(TIBDatabase(FWatched[0]));
  FWatched.Free;
  inherited Destroy;
end;

function TIB_Monitor.CurrentTraceFlags: TTraceFlags;
var
  Categories: TTraceCategories;
  Category: TTraceCategory;
begin
  Result := [];
  if not FEnabled then
    Exit;
  Categories := TraceCategoriesFor(FMonitorGroups, FStatementGroups);
  for Category := Low(TTraceCategory) to High(TTraceCategory) do
    if Category in Categories then
      Include(Result, ToTraceFlag(Category));
end;

procedure TIB_Monitor.Watch(ADatabase: TIBDatabase);
begin
  if not Assigned(ADatabase) then
    Exit;
  if FWatched.IndexOf(ADatabase) < 0 then
    FWatched.Add(ADatabase);
  ADatabase.TraceFlags := CurrentTraceFlags;
end;

procedure TIB_Monitor.Unwatch(ADatabase: TIBDatabase);
begin
  if not Assigned(ADatabase) then
    Exit;
  FWatched.Remove(ADatabase);
  { Left silent rather than left as it was: a connection that has stopped being
    watched must stop publishing, or it goes on paying for the trace. }
  ADatabase.TraceFlags := [];
end;

procedure TIB_Monitor.ApplySettings;
var
  Flags: TTraceFlags;
  Idx: Integer;
begin
  if not Assigned(FMonitor) then
    Exit;
  Flags := CurrentTraceFlags;
  FMonitor.TraceFlags := Flags;
  FMonitor.Enabled := FEnabled and (Flags <> []);
  { And the hook every TIBSQL publishes through, which is a third switch again
    and starts off. Enabling the monitor only starts the side that listens; the
    writer thread that carries the events to it does not exist until this is
    set, which is why watching a connection and enabling the monitor still
    produced nothing at all. }
  MonitorHook.TraceFlags := Flags;
  MonitorHook.Enabled := FEnabled and (Flags <> []);
  { And the publishing half, on every connection already handed over. }
  for Idx := 0 to FWatched.Count - 1 do
    TIBDatabase(FWatched[Idx]).TraceFlags := Flags;
end;

procedure TIB_Monitor.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  ApplySettings;
end;

procedure TIB_Monitor.SetMonitorGroups(const Value: TMonitorGroups);
begin
  FMonitorGroups := Value;
  ApplySettings;
end;

procedure TIB_Monitor.SetStatementGroups(const Value: TStatementGroups);
begin
  FStatementGroups := Value;
  ApplySettings;
end;

procedure TIB_Monitor.MonitorSQL(EventText: String; EventTime: TDateTime);
begin
  if not Assigned(FOnMonitorOutputItem) then
    Exit;
  FOnMonitorOutputItem(Self,
    FormatTraceLine(EventText, EventTime, FIncludeTimeStamp, FItemEnd));
end;

procedure Register;
begin
  RegisterComponents('Marathon', [TIB_Monitor]);
end;

end.
