unit IBPerformanceMonitor;

{$MODE Delphi}

interface

uses SysUtils, Classes, IBDatabase, IBQuery;

type
  TMetricValue = class(TObject)
  private
    FData : LongInt;
    FThisRead : LongInt;
    FLastRead : LongInt;
  public
    property Data : LongInt read FData write FData;
    property ThisRead : LongInt read FThisRead write FThisRead;
    property LastRead : LongInt read FLastRead write FLastRead;
  end;

  TPerformItem = class(TCollectionItem)
  private
    FMetric : String;
    FValue : TMetricValue;
  public
    property Metric : String read FMetric write FMetric;
    property Value : TMetricValue read FValue write FValue;
    constructor Create(Collection : TCollection); override;
    destructor Destroy; override;
  end;

  TPerformItems = class(TCollection)
  private
    function GetItem(Index: Integer): TPerformItem;
    procedure SetItem(Index: Integer; Value: TPerformItem);
  public
    function Add: TPerformItem;
    property Items[Index: Integer]: TPerformItem read GetItem write SetItem; default;
    constructor Create;
  end;

  { Drives the "Query Performance Analysis" tab in SQLForm.pas from Firebird's
    MON$ monitoring tables rather than the legacy isc_database_info() call this
    used to make - IBX's TIBDatabase doesn't expose the raw isc_db_handle that
    call needed. MON$RECORD_STATS/MON$IO_STATS are live, continuously-updated
    counters scoped to a transaction (via MON$TRANSACTIONS.MON$STAT_ID), so the
    same "snapshot now, diff against the last snapshot" model as the original
    isc_database_info-based counters still applies: call ResetCounters right
    before running a statement, Refresh right after, then read the Read*
    properties - each .Data is the delta between those two snapshots. }
  TIBPerformanceMonitor = class(TComponent)
  private
    FInitialised : Boolean;
    FShowSystemTables : Boolean;
    FIBConnection : TIBDatabase;
    FTransaction : TIBTransaction;
    FReadIdxCount : TPerformItems;
    FReadSeqCount : TPerformItems;
    FReadBackoutCount: TMetricValue;
    FReadDeleteCount: TMetricValue;
    FReadExpungeCount: TMetricValue;
    FReadFetchesCount: TMetricValue;
    FReadInsertCount: TMetricValue;
    FReadMarksCount: TMetricValue;
    FReadPurgeCount: TMetricValue;
    FReadReadCount: TMetricValue;
    FReadUpdateCount: TMetricValue;
    FReadWriteCount: TMetricValue;
    FCurrentMemory: Integer;
    FNumBuffers: Integer;
    procedure SetPerformItemsRetVal(ItemList : TPerformItems; RelName : String; RVal : LongInt);
    procedure SetPerformMetricRetVal(Item : TMetricValue; RVal : LongInt);
    procedure TakeSnapshot;
  public
    property Initialised : Boolean read FInitialised;
    property ShowSystemTables : Boolean read FShowSystemTables write FShowSystemTables;
    property ReadIdxCount : TPerformItems read FReadIdxCount;
    property ReadSeqCount : TPerformItems read FReadSeqCount;
    property ReadCurrentMemory : Integer read FCurrentMemory;
    property ReadReadCount : TMetricValue read FReadReadCount;
    property ReadWriteCount : TMetricValue read FReadWriteCount;
    property ReadFetchesCount : TMetricValue read FReadFetchesCount;
    property ReadMarksCount : TMetricValue read FReadMarksCount;
    property ReadNumBuffers : Integer read FNumBuffers;
    property ReadInsertCount : TMetricValue read FReadInsertCount;
    property ReadUpdateCount : TMetricValue read FReadUpdateCount;
    property ReadDeleteCount : TMetricValue read FReadDeleteCount;
    property ReadBackoutCount : TMetricValue read FReadBackoutCount;
    property ReadPurgeCount : TMetricValue read FReadPurgeCount;
    property ReadExpungeCount : TMetricValue read FReadExpungeCount;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Initialise;
    procedure ResetCounters;
    procedure Refresh;
  published
    property IB_Connection : TIBDatabase read FIBConnection write FIBConnection;
    property Transaction : TIBTransaction read FTransaction write FTransaction;
  end;

procedure Register;

implementation

//==============================================================================
// TPerformItem
//==============================================================================
constructor TPerformItem.Create(Collection : TCollection);
begin
  inherited Create(Collection);
  FValue := TMetricValue.Create;
end;

destructor TPerformItem.Destroy;
begin
  FValue.Free;
  inherited Destroy;
end;

//==============================================================================
// TPerformItems
//==============================================================================
constructor TPerformItems.Create;
begin
  inherited Create(TPerformItem);
end;

function TPerformItems.GetItem(Index: Integer): TPerformItem;
begin
  Result := TPerformItem(inherited GetItem(Index));
end;

procedure TPerformItems.SetItem(Index: Integer; Value: TPerformItem);
begin
  inherited SetItem(Index, Value);
end;

function TPerformItems.Add: TPerformItem;
begin
  Result := TPerformItem(inherited Add);
end;

//==============================================================================
// TIBPerformanceMonitor
//==============================================================================
constructor TIBPerformanceMonitor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FReadIdxCount := TPerformItems.Create;
  FReadSeqCount := TPerformItems.Create;
  FReadBackoutCount := TMetricValue.Create;
  FReadDeleteCount := TMetricValue.Create;
  FReadExpungeCount := TMetricValue.Create;
  FReadFetchesCount := TMetricValue.Create;
  FReadInsertCount := TMetricValue.Create;
  FReadMarksCount := TMetricValue.Create;
  FReadPurgeCount := TMetricValue.Create;
  FReadReadCount := TMetricValue.Create;
  FReadUpdateCount := TMetricValue.Create;
  FReadWriteCount := TMetricValue.Create;
  FInitialised := False;
  FShowSystemTables := False;
end;

destructor TIBPerformanceMonitor.Destroy;
begin
  FReadIdxCount.Free;
  FReadSeqCount.Free;
  FReadBackoutCount.Free;
  FReadDeleteCount.Free;
  FReadExpungeCount.Free;
  FReadFetchesCount.Free;
  FReadInsertCount.Free;
  FReadMarksCount.Free;
  FReadPurgeCount.Free;
  FReadReadCount.Free;
  FReadUpdateCount.Free;
  FReadWriteCount.Free;
  inherited Destroy;
end;

procedure TIBPerformanceMonitor.Initialise;
begin
  FInitialised := True;
  ResetCounters;
end;

procedure TIBPerformanceMonitor.ResetCounters;
begin
  TakeSnapshot;
end;

procedure TIBPerformanceMonitor.Refresh;
begin
  TakeSnapshot;
end;

procedure TIBPerformanceMonitor.SetPerformItemsRetVal(ItemList : TPerformItems; RelName : String; RVal : LongInt);
var
  Idx : Integer;
  Found : Boolean;
begin
  if (not FShowSystemTables) and (Copy(RelName, 1, 4) = 'RDB$') then
    Exit;

  Found := False;
  for Idx := 0 to ItemList.Count - 1 do
    if ItemList[Idx].Metric = RelName then
    begin
      ItemList[Idx].Value.LastRead := ItemList[Idx].Value.ThisRead;
      ItemList[Idx].Value.ThisRead := RVal;
      ItemList[Idx].Value.Data := ItemList[Idx].Value.ThisRead - ItemList[Idx].Value.LastRead;
      Found := True;
      Break;
    end;
  if not Found then
    with ItemList.Add do
    begin
      Metric := RelName;
      Value.Data := RVal;
      Value.ThisRead := RVal;
      Value.LastRead := 0;
    end;
end;

procedure TIBPerformanceMonitor.SetPerformMetricRetVal(Item: TMetricValue; RVal: LongInt);
begin
  Item.LastRead := Item.ThisRead;
  Item.ThisRead := RVal;
  Item.Data := Item.ThisRead - Item.LastRead;
end;

procedure TIBPerformanceMonitor.TakeSnapshot;
var
  Tr: TIBTransaction;
  Q: TIBQuery;
  TransID, AttachID: Integer;
begin
  if (not Assigned(FIBConnection)) or (not FIBConnection.Connected) or
     (not Assigned(FTransaction)) or (not FTransaction.Active) then
    Exit;

  TransID := FTransaction.TransactionID;

  Tr := TIBTransaction.Create(nil);
  Q := TIBQuery.Create(nil);
  try
    Tr.DefaultDatabase := FIBConnection;
    Q.Database := FIBConnection;
    Q.Transaction := Tr;
    Tr.StartTransaction;
    try
      { Per-table sequential vs. indexed record reads for the monitored
        transaction - feeds the Series1 bar chart. }
      Q.SQL.Text :=
        'select ts.mon$table_name, rs.mon$record_seq_reads, rs.mon$record_idx_reads ' +
        'from mon$table_stats ts ' +
        'join mon$record_stats rs on rs.mon$stat_id = ts.mon$record_stat_id ' +
        'where ts.mon$stat_id = (select mon$stat_id from mon$transactions where mon$transaction_id = ' + IntToStr(TransID) + ')';
      Q.Open;
      while not Q.EOF do
      begin
        SetPerformItemsRetVal(FReadSeqCount, Trim(Q.FieldByName('mon$table_name').AsString),
          Q.FieldByName('mon$record_seq_reads').AsInteger);
        SetPerformItemsRetVal(FReadIdxCount, Trim(Q.FieldByName('mon$table_name').AsString),
          Q.FieldByName('mon$record_idx_reads').AsInteger);
        Q.Next;
      end;
      Q.Close;

      { Transaction-level aggregate record/page counters - feeds the Stats grid. }
      Q.SQL.Text :=
        'select rs.mon$record_inserts, rs.mon$record_updates, rs.mon$record_deletes, ' +
        'rs.mon$record_backouts, rs.mon$record_purges, rs.mon$record_expunges, ' +
        'io.mon$page_reads, io.mon$page_writes, io.mon$page_fetches, io.mon$page_marks ' +
        'from mon$transactions t ' +
        'join mon$record_stats rs on rs.mon$stat_id = t.mon$stat_id ' +
        'left join mon$io_stats io on io.mon$stat_id = t.mon$stat_id ' +
        'where t.mon$transaction_id = ' + IntToStr(TransID);
      Q.Open;
      if not Q.EOF then
      begin
        SetPerformMetricRetVal(FReadReadCount, Q.FieldByName('mon$page_reads').AsInteger);
        SetPerformMetricRetVal(FReadWriteCount, Q.FieldByName('mon$page_writes').AsInteger);
        SetPerformMetricRetVal(FReadFetchesCount, Q.FieldByName('mon$page_fetches').AsInteger);
        SetPerformMetricRetVal(FReadMarksCount, Q.FieldByName('mon$page_marks').AsInteger);
        SetPerformMetricRetVal(FReadInsertCount, Q.FieldByName('mon$record_inserts').AsInteger);
        SetPerformMetricRetVal(FReadUpdateCount, Q.FieldByName('mon$record_updates').AsInteger);
        SetPerformMetricRetVal(FReadDeleteCount, Q.FieldByName('mon$record_deletes').AsInteger);
        SetPerformMetricRetVal(FReadBackoutCount, Q.FieldByName('mon$record_backouts').AsInteger);
        SetPerformMetricRetVal(FReadPurgeCount, Q.FieldByName('mon$record_purges').AsInteger);
        SetPerformMetricRetVal(FReadExpungeCount, Q.FieldByName('mon$record_expunges').AsInteger);
      end;
      Q.Close;

      { Server-wide page buffer count - not transaction-scoped. }
      Q.SQL.Text := 'select mon$page_buffers from mon$database';
      Q.Open;
      if not Q.EOF then
        FNumBuffers := Q.FieldByName('mon$page_buffers').AsInteger;
      Q.Close;

      { This attachment's current memory usage - not transaction-scoped either. }
      Q.SQL.Text := 'select current_connection from rdb$database';
      Q.Open;
      AttachID := Q.FieldByName('current_connection').AsInteger;
      Q.Close;

      Q.SQL.Text :=
        'select mon$memory_used from mon$memory_usage ' +
        'where mon$stat_id = (select mon$stat_id from mon$attachments where mon$attachment_id = ' + IntToStr(AttachID) + ')';
      Q.Open;
      if not Q.EOF then
        FCurrentMemory := Q.FieldByName('mon$memory_used').AsInteger;
      Q.Close;

      Tr.Commit;
    except
      if Tr.Active then
        Tr.Rollback;
      raise;
    end;
  finally
    Q.Free;
    Tr.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('Data Access', [TIBPerformanceMonitor]);
end;

end.
