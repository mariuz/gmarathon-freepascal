unit IBPerformanceMonitor;

{$INCLUDE IB_Directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IB_Header, IB_Session, IB_Components;

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
		{ Private declarations }
		FInitialised : Boolean;
		FShowSystemTables : Boolean;
		FRelationList : TRelationItems;
		FIBConnection : TIB_Connection;
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
		procedure SetIBConnection(Value : TIB_Connection);
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
	protected
		{ Protected declarations }
	public
		{ Public declarations }
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
		{ Published declarations }
		property IB_Connection : TIB_Connection read FIBConnection write SetIBConnection;
	end;

procedure Register;

implementation

//==============================================================================
// TMetricValue
//------------------------------------------------------------------------------

//==============================================================================
// TPerformItem
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
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
// TRelationItems
//------------------------------------------------------------------------------
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
	Result := 'Unknown';
	for Idx := 0 to Count - 1 do
	begin
		if Items[Idx].RelationId = StrToInt(Id) then
		begin
			Result := Items[Idx].RelationName;
			Break;
		end;
	end;
end;

//==============================================================================
// TIBPerformanceMonitor
//------------------------------------------------------------------------------
constructor TIBPerformanceMonitor.Create(AOwner : TComponent);
begin
	inherited Create(AOwner);
	FShowSystemTables := True;
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
end;

destructor TIBPerformanceMonitor.Destroy;
begin
  FReadIdxCount.Free;
  FReadSeqCount.Free;
  FRelationList.Free;
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

procedure TIBPerformanceMonitor.ResetCounters;
begin
	// reset the counters
	GetReadIdxCount;
	GetReadSeqCount;
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

procedure TIBPerformanceMonitor.Initialise;
var
	Q : TIB_Cursor;

begin
	FRelationList.Clear;
	Q := TIB_Cursor.Create(Self);
	try
		Q.IB_Connection := FIBConnection;
		Q.SQL.Text := 'select rdb$relation_id, rdb$relation_name from rdb$relations';
		Q.Open;
		Q.First;
		while not Q.EOF do
		begin
			with FRelationList.Add do
			begin
				RelationId := Q.FieldByName('rdb$relation_id').AsInteger;
				RelationName := Trim(Q.FieldByName('rdb$relation_name').AsString);
			end;
			Q.Next;
		end;
	finally
		Q.Free;
	end;
	ResetCounters;
	FInitialised := True;
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

function TIBPerformanceMonitor.GetReadIdxCount : TPerformItems;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;
	Idx : Integer;

	RelId : String;
	RVal : LongInt;

begin
	Result := nil;
	_DBInfoCommand := Char(isc_info_read_idx_count);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		Idx := 3;
		while Idx < Len do
		begin
			RelId := IntToStr({$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[Idx], 2));
			RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[Idx + 2], 4);
			SetPerformItemsRetVal(FReadIdxCount, RelId, RVal);
			Idx := Idx + 6;
		end;
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadIdxCount;
end;

function TIBPerformanceMonitor.GetReadSeqCount : TPerformItems;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;
	Idx : Integer;

	RelId : String;
	RVal : LongInt;

begin
	Result := nil;
	_DBInfoCommand := Char(isc_info_read_seq_count);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		Idx := 3;
		while Idx < Len do
		begin
			RelId := IntToStr({$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[Idx], 2));
			RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[Idx + 2], 4);
			SetPerformItemsRetVal(FReadSeqCount, RelId, RVal);
			Idx := Idx + 6;
		end;
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadSeqCount;
end;

function TIBPerformanceMonitor.GetReadCurrentMemory: Integer;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;

	RVal : LongInt;

begin
	RVal := 0;
	Result := 0;
  _DBInfoCommand := Char(isc_info_current_memory);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
  begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
  end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
	else
    Result := RVal;
end;

procedure TIBPerformanceMonitor.SetIBConnection(Value : TIB_Connection);
begin
	FIBConnection := Value;
end;

function TIBPerformanceMonitor.GetReadBackoutCount: TMetricValue;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;

	RVal : LongInt;

begin
  Result := nil;
  _DBInfoCommand := Char(isc_info_backout_count);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
  begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadBackoutCount, RVal);
	end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
  else
    Result := FReadBackoutCount;
end;

function TIBPerformanceMonitor.GetReadDeleteCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
	len: Integer;
  _DBInfoCommand: Char;

	RVal : LongInt;

begin
  Result := nil;
  _DBInfoCommand := Char(isc_info_delete_count);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadDeleteCount, RVal);
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadDeleteCount;
end;

function TIBPerformanceMonitor.GetReadExpungeCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  _DBInfoCommand: Char;

  RVal : LongInt;

begin
  Result := nil;
  _DBInfoCommand := Char(isc_info_expunge_count);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
  begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadExpungeCount, RVal);
  end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
  else
		Result := FReadExpungeCount;
end;

function TIBPerformanceMonitor.GetReadFetchesCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
	_DBInfoCommand: Char;

  RVal : LongInt;

begin
	Result := nil;
  _DBInfoCommand := Char(isc_info_fetches);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
  begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadFetchesCount, RVal);
  end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
  else
    Result := FReadFetchesCount;
end;

function TIBPerformanceMonitor.GetReadInsertCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  _DBInfoCommand: Char;

  RVal : LongInt;

begin
  Result := nil;
  _DBInfoCommand := Char(isc_info_insert_count);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadInsertCount, RVal);
  end;
  if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
  else
    Result := FReadInsertCount;
end;

function TIBPerformanceMonitor.GetReadMarksCount: TMetricValue;
var
	local_buffer: array[0..8191] of Char;
  len: Integer;
  _DBInfoCommand: Char;

  RVal : LongInt;

begin
  Result := nil;
	_DBInfoCommand := Char(isc_info_marks);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
	begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadMarksCount, RVal);
  end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
  else
    Result := FReadMarksCount;
end;

function TIBPerformanceMonitor.GetReadNumBuffers: Integer;
var
  local_buffer: array[0..8191] of Char;
	len: Integer;
  _DBInfoCommand: Char;

  RVal : LongInt;

begin
  RVal := 0;
	Result := 0;
	_DBInfoCommand := Char(isc_info_num_buffers);
  FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
  begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
	end;
  if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
  else
		Result := RVal;
end;

function TIBPerformanceMonitor.GetReadPurgeCount: TMetricValue;
var
  local_buffer: array[0..8191] of Char;
  len: Integer;
  _DBInfoCommand: Char;

  RVal : LongInt;

begin
  Result := nil;
  _DBInfoCommand := Char(isc_info_purge_count);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
  if FIBConnection.IB_Session.errcode = 0 then
  begin
    len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
    RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
    SetPerformMetricRetVal(FReadPurgeCount, RVal);
  end;
	if FIBConnection.IB_Session.errcode <> 0 then
    FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadPurgeCount;
end;

function TIBPerformanceMonitor.GetReadReadCount: TMetricValue;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;

	RVal : LongInt;

begin
	Result := nil;
	_DBInfoCommand := Char(isc_info_reads);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
		SetPerformMetricRetVal(FReadReadCount, RVal);
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadReadCount;
end;

function TIBPerformanceMonitor.GetReadUpdateCount: TMetricValue;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;

	RVal : LongInt;

begin
	Result := nil;
	_DBInfoCommand := Char(isc_info_update_count);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
		SetPerformMetricRetVal(FReadUpdateCount, RVal);
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadUpdateCount;
end;

function TIBPerformanceMonitor.GetReadWriteCount: TMetricValue;
var
	local_buffer: array[0..8191] of Char;
	len: Integer;
	_DBInfoCommand: Char;

	RVal : LongInt;

begin
	Result := nil;
	_DBInfoCommand := Char(isc_info_writes);
	FIBConnection.IB_Session.errcode := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_database_info(@FIBConnection.IB_Session.Status, @FIBConnection.DBHandle, 1, @_DBInfoCommand, 8192, local_buffer);
	if FIBConnection.IB_Session.errcode = 0 then
	begin
		len := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[1], 2);
		RVal := {$IFnDEF IBO_40_OR_GREATER}FIBConnection.IB_Session.{$ENDIF}isc_vax_integer(@local_buffer[3], Len);
		SetPerformMetricRetVal(FReadWriteCount, RVal);
	end;
	if FIBConnection.IB_Session.errcode <> 0 then
		FIBConnection.IB_Session.HandleException(Self)
	else
		Result := FReadWriteCount;
end;

procedure TIBPerformanceMonitor.SetPerformMetricRetVal(Item: TMetricValue; RVal: Integer);
begin
	Item.LastRead := Item.ThisRead;
	Item.ThisRead := RVal;
	Item.Data := Item.ThisRead - Item.LastRead;
end;

procedure register;
begin
	RegisterComponents('Data Access', [TIBPerformanceMonitor]);
end;

end.
