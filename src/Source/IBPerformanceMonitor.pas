unit IBPerformanceMonitor;

{$MODE Delphi}

interface

uses SysUtils, Classes, Graphics, Controls, Forms, Dialogs, IBConnection, SQLDB;

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

  TRelationItem = class(TCollectionItem)
  private
    FRelationName : String;
    FRelationID : Integer;
  public
    property RelationID : Integer read FRelationID write FRelationID;
    property RelationName : String read FRelationName write FRelationName;
  end;

  TRelationItems = class(TCollection)
  private
    function GetItem(Index: Integer): TRelationItem;
    procedure SetItem(Index: Integer; Value: TRelationItem);
  public
    function Add: TRelationItem;
    function GetRelationName(ID : String) : String;
    property Items[Index: Integer]: TRelationItem read GetItem write SetItem; default;
    constructor Create;
  end;

  TIBPerformanceMonitor = class(TComponent)
  private
    FInitialised : Boolean;
    FShowSystemTables : Boolean;
    FRelationList : TRelationItems;
    FIBConnection : TIBConnection;
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
    function GetReadIdxCount : TPerformItems;
    function GetReadSeqCount : TPerformItems;
    function GetReadCurrentMemory: Integer;
    procedure SetIBConnection(Value : TIBConnection);
    procedure SetPerformItemsRetVal(ItemList : TPerformItems; RelId : String; RVal : LongInt);
    procedure SetPerformMetricRetVal(Item : TMetricValue; RVal : LongInt);
    function GetReadBackoutCount: TMetricValue;
    function GetReadDeleteCount: TMetricValue;
    function GetReadExpungeCount: TMetricValue;
    function GetReadFetchesCount: TMetricValue;
    function GetReadInsertCount: TMetricValue;
    function GetReadMarksCount: TMetricValue;
    function GetReadNumBuffers: Integer;
    function GetReadPurgeCount: TMetricValue;
    function GetReadReadCount: TMetricValue;
    function GetReadUpdateCount: TMetricValue;
    function GetReadWriteCount: TMetricValue;
    function DoDBInfo(InfoCmd: Byte; out Buf: array of Char): Boolean;
  protected
  public
    property Initialised : Boolean read FInitialised;
    property ShowSystemTables : Boolean read FShowSystemTables write FShowSystemTables;
    property ReadIdxCount : TPerformItems read GetReadIdxCount;
    property ReadSeqCount : TPerformItems read GetReadSeqCount;
    property ReadCurrentMemory : Integer read GetReadCurrentMemory;
    property ReadReadCount : TMetricValue read GetReadReadCount;
    property ReadWriteCount : TMetricValue read GetReadWriteCount;
    property ReadFetchesCount : TMetricValue read GetReadFetchesCount;
    property ReadMarksCount : TMetricValue read GetReadMarksCount;
    property ReadNumBuffers : Integer read GetReadNumBuffers;
    property ReadInsertCount : TMetricValue read GetReadInsertCount;
    property ReadUpdateCount : TMetricValue read GetReadUpdateCount;
    property ReadDeleteCount : TMetricValue read GetReadDeleteCount;
    property ReadBackoutCount : TMetricValue read GetReadBackoutCount;
    property ReadPurgeCount : TMetricValue read GetReadPurgeCount;
    property ReadExpungeCount : TMetricValue read GetReadExpungeCount;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Initialise;
    procedure ResetCounters;
  published
    property IB_Connection : TIBConnection read FIBConnection write SetIBConnection;
  end;

procedure Register;

implementation

uses ibase60dyn;

// isc_info constants not in the subset exported by ibase60dyn
const
  isc_info_backout_count  = 31;
  isc_info_delete_count   = 32;
  isc_info_expunge_count  = 33;
  isc_info_insert_count   = 34;
  isc_info_purge_count    = 35;
  isc_info_update_count   = 36;
  isc_info_fetches        = 13;
  isc_info_marks          = 14;
  isc_info_reads          = 15;
  isc_info_writes         = 16;
  isc_info_num_buffers    = 18;

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
// TRelationItem
//==============================================================================

//==============================================================================
// TRelationItems
//==============================================================================
constructor TRelationItems.Create;
begin
  inherited Create(TRelationItem);
end;

function TRelationItems.GetItem(Index: Integer): TRelationItem;
begin
  Result := TRelationItem(inherited GetItem(Index));
end;

procedure TRelationItems.SetItem(Index: Integer; Value: TRelationItem);
begin
  inherited SetItem(Index, Value);
end;

function TRelationItems.Add: TRelationItem;
begin
  Result := TRelationItem(inherited Add);
end;

function TRelationItems.GetRelationName(ID : String) : String;
var
  Idx : Integer;
begin
  Result := ID;
  for Idx := 0 to Count - 1 do
    if IntToStr(Items[Idx].RelationID) = ID then
    begin
      Result := Items[Idx].RelationName;
      Break;
    end;
end;

//==============================================================================
// TIBPerformanceMonitor
//==============================================================================
constructor TIBPerformanceMonitor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FRelationList := TRelationItems.Create;
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
  FRelationList.Free;
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

function TIBPerformanceMonitor.DoDBInfo(InfoCmd: Byte; out Buf: array of Char): Boolean;
var
  Status: array[0..19] of ISC_STATUS;
  DBHandle: isc_db_handle;
  Cmd: Char;
begin
  Result := False;
  if not Assigned(FIBConnection) or not FIBConnection.Connected then
    Exit;
  DBHandle := isc_db_handle(FIBConnection.Handle);
  Cmd := Char(InfoCmd);
  if isc_database_info(@Status[0], @DBHandle, 1, @Cmd, SizeOf(Buf), @Buf[0]) = 0 then
    Result := True;
end;

procedure TIBPerformanceMonitor.Initialise;
var
  Q: TSQLQuery;
begin
  FRelationList.Clear;
  if not Assigned(FIBConnection) or not FIBConnection.Connected then
    Exit;
  Q := TSQLQuery.Create(nil);
  try
    Q.Database := FIBConnection;
    Q.Transaction := FIBConnection.Transaction;
    Q.SQL.Text := 'select rdb$relation_id, rdb$relation_name from rdb$relations';
    Q.Open;
    while not Q.EOF do
    begin
      with FRelationList.Add do
      begin
        RelationId := Q.FieldByName('rdb$relation_id').AsInteger;
        RelationName := Trim(Q.FieldByName('rdb$relation_name').AsString);
      end;
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
  ResetCounters;
  FInitialised := True;
end;

procedure TIBPerformanceMonitor.ResetCounters;
begin
  GetReadCurrentMemory;
  GetReadBackoutCount;
  GetReadDeleteCount;
  GetReadExpungeCount;
  GetReadFetchesCount;
  GetReadInsertCount;
  GetReadMarksCount;
  GetReadPurgeCount;
  GetReadReadCount;
  GetReadUpdateCount;
  GetReadWriteCount;
end;

procedure TIBPerformanceMonitor.SetPerformItemsRetVal(ItemList : TPerformItems; RelId : String; RVal : LongInt);
var
  Idx : Integer;
  Found : Boolean;
begin
  Found := False;
  for Idx := 0 to ItemList.Count - 1 do
    if (FShowSystemTables = True) or ((FShowSystemTables = False) and (Copy(ItemList[Idx].Metric, 1, 4) <> 'RDB$')) then
      if ItemList[Idx].Metric = FRelationList.GetRelationName(RelId) then
      begin
        ItemList[Idx].Value.LastRead := ItemList[Idx].Value.ThisRead;
        ItemList[Idx].Value.ThisRead := RVal;
        ItemList[Idx].Value.Data := ItemList[Idx].Value.ThisRead - ItemList[Idx].Value.LastRead;
        Found := True;
        Break;
      end;
  if not Found then
    if (FShowSystemTables = True) or ((FShowSystemTables = False) and (Copy(FRelationList.GetRelationName(RelId), 1, 4) <> 'RDB$')) then
      with ItemList.Add do
      begin
        Metric := FRelationList.GetRelationName(RelId);
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

function TIBPerformanceMonitor.GetReadIdxCount : TPerformItems;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  Idx: Integer;
  RelId: String;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_read_idx_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  Idx := 3;
  while Idx < Len do
  begin
    RelId := IntToStr(isc_vax_integer(@local_buffer[Idx], 2));
    RVal := isc_vax_integer(@local_buffer[Idx + 2], 4);
    SetPerformItemsRetVal(FReadIdxCount, RelId, RVal);
    Idx := Idx + 6;
  end;
  Result := FReadIdxCount;
end;

function TIBPerformanceMonitor.GetReadSeqCount : TPerformItems;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  Idx: Integer;
  RelId: String;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_read_seq_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  Idx := 3;
  while Idx < Len do
  begin
    RelId := IntToStr(isc_vax_integer(@local_buffer[Idx], 2));
    RVal := isc_vax_integer(@local_buffer[Idx + 2], 4);
    SetPerformItemsRetVal(FReadSeqCount, RelId, RVal);
    Idx := Idx + 6;
  end;
  Result := FReadSeqCount;
end;

function TIBPerformanceMonitor.GetReadCurrentMemory: Integer;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
begin
  Result := 0;
  if not DoDBInfo(isc_info_current_memory, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  Result := isc_vax_integer(@local_buffer[3], Len);
end;

procedure TIBPerformanceMonitor.SetIBConnection(Value : TIBConnection);
begin
  FIBConnection := Value;
end;

function TIBPerformanceMonitor.GetReadBackoutCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_backout_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadBackoutCount, RVal);
  Result := FReadBackoutCount;
end;

function TIBPerformanceMonitor.GetReadDeleteCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_delete_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadDeleteCount, RVal);
  Result := FReadDeleteCount;
end;

function TIBPerformanceMonitor.GetReadExpungeCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_expunge_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadExpungeCount, RVal);
  Result := FReadExpungeCount;
end;

function TIBPerformanceMonitor.GetReadFetchesCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_fetches, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadFetchesCount, RVal);
  Result := FReadFetchesCount;
end;

function TIBPerformanceMonitor.GetReadInsertCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_insert_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadInsertCount, RVal);
  Result := FReadInsertCount;
end;

function TIBPerformanceMonitor.GetReadMarksCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_marks, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadMarksCount, RVal);
  Result := FReadMarksCount;
end;

function TIBPerformanceMonitor.GetReadNumBuffers: Integer;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
begin
  Result := 0;
  if not DoDBInfo(isc_info_num_buffers, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  Result := isc_vax_integer(@local_buffer[3], Len);
end;

function TIBPerformanceMonitor.GetReadPurgeCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_purge_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadPurgeCount, RVal);
  Result := FReadPurgeCount;
end;

function TIBPerformanceMonitor.GetReadReadCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_reads, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadReadCount, RVal);
  Result := FReadReadCount;
end;

function TIBPerformanceMonitor.GetReadUpdateCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_update_count, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadUpdateCount, RVal);
  Result := FReadUpdateCount;
end;

function TIBPerformanceMonitor.GetReadWriteCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  RVal: LongInt;
begin
  Result := nil;
  if not DoDBInfo(isc_info_writes, local_buffer) then Exit;
  len := isc_vax_integer(@local_buffer[1], 2);
  RVal := isc_vax_integer(@local_buffer[3], Len);
  SetPerformMetricRetVal(FReadWriteCount, RVal);
  Result := FReadWriteCount;
end;

procedure Register;
begin
  RegisterComponents('Data Access', [TIBPerformanceMonitor]);
end;

end.
