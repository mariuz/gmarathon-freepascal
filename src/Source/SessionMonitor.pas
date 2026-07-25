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
		pnlAttachmentsBottom: TPanel;
		btnDisconnectAttachment: TButton;
		pnlStatementsBottom: TPanel;
		btnCancelStatement: TButton;
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
		procedure btnDisconnectAttachmentClick(Sender: TObject);
		procedure btnCancelStatementClick(Sender: TObject);
	private
		FConnectionName: String;
		procedure SetConnectionName(const Value: String);
		function GetCurrentAttachmentId: Integer;
		procedure ExecuteAdminStatement(const SQL: String);
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

procedure TfrmSessionMonitor.ExecuteAdminStatement(const SQL: String);
var
	Q: TIBQuery;
	Tr: TIBTransaction;
begin
	{ Deliberately a fresh connection-scoped transaction, not tranMonitor (which
	  is holding the MON$ snapshot from the last refresh) - keeps the admin
	  action independent of whatever state the monitoring grids are in. }
	Tr := TIBTransaction.Create(nil);
	Q := TIBQuery.Create(nil);
	try
		Tr.DefaultDatabase := qryAttachments.Database;
		Q.Database := qryAttachments.Database;
		Q.Transaction := Tr;
		Tr.StartTransaction;
		try
			Q.SQL.Text := SQL;
			Q.ExecSQL;
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

function TfrmSessionMonitor.GetCurrentAttachmentId: Integer;
var
	Q: TIBQuery;
	Tr: TIBTransaction;
begin
	Result := -1;
	Tr := TIBTransaction.Create(nil);
	Q := TIBQuery.Create(nil);
	try
		Tr.DefaultDatabase := qryAttachments.Database;
		Q.Database := qryAttachments.Database;
		Q.Transaction := Tr;
		Tr.StartTransaction;
		try
			Q.SQL.Text := 'select current_connection from rdb$database';
			Q.Open;
			if not Q.EOF then
				Result := Q.FieldByName('current_connection').AsInteger;
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

procedure TfrmSessionMonitor.btnDisconnectAttachmentClick(Sender: TObject);
var
	AttachId: Integer;
begin
	if qryAttachments.EOF and qryAttachments.BOF then
		Exit;
	if qryAttachments.FieldByName('mon$attachment_id').IsNull then
		Exit;
	AttachId := qryAttachments.FieldByName('mon$attachment_id').AsInteger;

	if AttachId = GetCurrentAttachmentId then
	begin
		MessageDlg('That is this Session Monitor''s own connection - disconnecting it would break this window. Choose a different attachment.',
			mtWarning, [mbOK], 0);
		Exit;
	end;

	if MessageDlg('Disconnect attachment ' + IntToStr(AttachId) + ' (' +
		qryAttachments.FieldByName('mon$user').AsString + ')?' + #13#10#13#10 +
		'This immediately terminates that connection. Any uncommitted work on it will be lost.',
		mtWarning, [mbYes, mbNo], 0) <> mrYes then
		Exit;

	try
		ExecuteAdminStatement('delete from mon$attachments where mon$attachment_id = ' + IntToStr(AttachId));
		MessageDlg('Attachment disconnected.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
			MessageDlg('Could not disconnect attachment: ' + E.Message, mtError, [mbOK], 0);
	end;
	RefreshData;
end;

procedure TfrmSessionMonitor.btnCancelStatementClick(Sender: TObject);
var
	StmtId: Integer;
begin
	if qryStatements.EOF and qryStatements.BOF then
		Exit;
	if qryStatements.FieldByName('mon$statement_id').IsNull then
		Exit;
	StmtId := qryStatements.FieldByName('mon$statement_id').AsInteger;

	if MessageDlg('Cancel statement ' + IntToStr(StmtId) + '?' + #13#10#13#10 +
		qryStatements.FieldByName('mon$sql_text').AsString,
		mtWarning, [mbYes, mbNo], 0) <> mrYes then
		Exit;

	try
		ExecuteAdminStatement('delete from mon$statements where mon$statement_id = ' + IntToStr(StmtId));
		MessageDlg('Statement cancelled.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
			MessageDlg('Could not cancel statement: ' + E.Message, mtError, [mbOK], 0);
	end;
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
