unit IBSQLMonitor;

{ Stub unit - IBO IBSQLMonitor/TIB_Monitor not available for FPC/SQLDB }

{$MODE Delphi}

interface

uses Classes, SysUtils;

type
  TMonitorGroup = (mgConnection, mgTransaction, mgStatement, mgRow, mgBlob, mgArray);
  TMonitorGroups = set of TMonitorGroup;

  TStatementGroup = (sgAllocate, sgPrepare, sgDescribe, sgStatementInfo, sgExecute,
    sgExecuteImmediate, sgServerCursor, sgFree, sgFetch, sgField, sgError);
  TStatementGroups = set of TStatementGroup;

  TMonitorOutputEvent = procedure(Sender: TObject; const NewString: String) of object;

  TIB_Monitor = class(TComponent)
  private
    FMonitorGroups: TMonitorGroups;
    FStatementGroups: TStatementGroups;
    FEnabled: Boolean;
    FOnMonitorOutputItem: TMonitorOutputEvent;
    FIncludeTimeStamp: Boolean;
    FItemEnd: String;
    FMinTicks: Integer;
    FNewLineText: String;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property MonitorGroups: TMonitorGroups read FMonitorGroups write FMonitorGroups;
    property StatementGroups: TStatementGroups read FStatementGroups write FStatementGroups;
    property OnMonitorOutputItem: TMonitorOutputEvent read FOnMonitorOutputItem write FOnMonitorOutputItem;
    property IncludeTimeStamp: Boolean read FIncludeTimeStamp write FIncludeTimeStamp;
    property ItemEnd: String read FItemEnd write FItemEnd;
    property MinTicks: Integer read FMinTicks write FMinTicks;
    property NewLineText: String read FNewLineText write FNewLineText;
  end;

  TIBSQLMonitor = TIB_Monitor;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('IBO', [TIB_Monitor]);
end;

end.
