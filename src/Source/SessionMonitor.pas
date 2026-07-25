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

unit SessionMonitor;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
	SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
	DB, DBGrids, IBDatabase, IBQuery;

type
	TfrmSessionMonitor = class(TForm)
		pnlTop: TPanel;
		btnRefresh: TButton;
		lblConnection: TLabel;
		pgMonitor: TPageControl;
		tsAttachments: TTabSheet;
		tsStatements: TTabSheet;
		tsTransactions: TTabSheet;
		grdAttachments: TDBGrid;
		grdStatements: TDBGrid;
		grdTransactions: TDBGrid;
		dsAttachments: TDataSource;
		dsStatements: TDataSource;
		dsTransactions: TDataSource;
		qryAttachments: TIBQuery;
		qryStatements: TIBQuery;
		qryTransactions: TIBQuery;
		tranMonitor: TIBTransaction;
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnRefreshClick(Sender: TObject);
	private
		FConnectionName: String;
		procedure SetConnectionName(const Value: String);
	public
		procedure RefreshData;
		property ConnectionName: String read FConnectionName write SetConnectionName;
	end;

implementation

uses Globals, MarathonIDE, MarathonProjectCache;

{$R *.lfm}

procedure TfrmSessionMonitor.FormCreate(Sender: TObject);
begin
	LoadFormPosition(Self);
end;

procedure TfrmSessionMonitor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	SaveFormPosition(Self);
	if tranMonitor.Active then
		tranMonitor.Commit;
	Action := caFree;
end;

procedure TfrmSessionMonitor.SetConnectionName(const Value: String);
var
	Conn: TMarathonCacheConnection;
begin
	FConnectionName := Value;
	Caption := 'Session Monitor - ' + Value;
	lblConnection.Caption := 'Connection: ' + Value;

	Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value];
	tranMonitor.DefaultDatabase := Conn.Connection;
	qryAttachments.Database := Conn.Connection;
	qryAttachments.Transaction := tranMonitor;
	qryStatements.Database := Conn.Connection;
	qryStatements.Transaction := tranMonitor;
	qryTransactions.Database := Conn.Connection;
	qryTransactions.Transaction := tranMonitor;

	RefreshData;
end;

procedure TfrmSessionMonitor.btnRefreshClick(Sender: TObject);
begin
	RefreshData;
end;

procedure TfrmSessionMonitor.RefreshData;
begin
	{ Firebird takes a fresh MON$ snapshot for the first statement of each new
	  transaction, so a plain re-open on the same transaction would keep
	  showing the old snapshot - start a new transaction every refresh. }
	qryAttachments.Close;
	qryStatements.Close;
	qryTransactions.Close;
	if tranMonitor.Active then
		tranMonitor.Commit;
	tranMonitor.StartTransaction;

	qryAttachments.SQL.Text :=
		'select mon$attachment_id, mon$user, mon$remote_address, mon$remote_process, ' +
		'mon$timestamp, mon$state ' +
		'from mon$attachments order by mon$attachment_id';
	qryAttachments.Open;

	qryStatements.SQL.Text :=
		'select mon$statement_id, mon$attachment_id, mon$transaction_id, mon$state, ' +
		'mon$timestamp, mon$sql_text ' +
		'from mon$statements order by mon$statement_id';
	qryStatements.Open;

	qryTransactions.SQL.Text :=
		'select mon$transaction_id, mon$attachment_id, mon$state, mon$timestamp, ' +
		'mon$isolation_mode, mon$read_only ' +
		'from mon$transactions order by mon$transaction_id';
	qryTransactions.Open;
end;

end.
