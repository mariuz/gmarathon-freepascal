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
		tsCompiled: TTabSheet;
		pnlAttachmentsBottom: TPanel;
		btnDisconnectAttachment: TButton;
		pnlStatementsBottom: TPanel;
		btnCancelStatement: TButton;
		pnlCompiledDetail: TPanel;
		lblCompiledDetail: TLabel;
		memCompiled: TMemo;
		splCompiled: TSplitter;
		grdAttachments: TDBGrid;
		grdStatements: TDBGrid;
		grdTransactions: TDBGrid;
		grdCompiled: TDBGrid;
		dsAttachments: TDataSource;
		dsStatements: TDataSource;
		dsTransactions: TDataSource;
		dsCompiled: TDataSource;
		qryAttachments: TIBQuery;
		qryStatements: TIBQuery;
		qryTransactions: TIBQuery;
		qryCompiled: TIBQuery;
		tranMonitor: TIBTransaction;
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnRefreshClick(Sender: TObject);
		procedure btnDisconnectAttachmentClick(Sender: TObject);
		procedure btnCancelStatementClick(Sender: TObject);
		procedure dsCompiledDataChange(Sender: TObject; Field: TField);
	private
		FConnectionName: String;
		FCompiledSupported: Boolean;
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
	qryCompiled.Database := Conn.Connection;
	qryCompiled.Transaction := tranMonitor;

	{ MON$COMPILED_STATEMENTS is Firebird 5 (ODS 13.1). Querying a table that
	  does not exist is a hard error, so hide the tab rather than let a refresh
	  fail on older servers. }
	FCompiledSupported := Conn.IsODSAtLeast(ODS_FB4_MAJOR, ODS_FB5_MINOR);
	tsCompiled.TabVisible := FCompiledSupported;

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

procedure TfrmSessionMonitor.dsCompiledDataChange(Sender: TObject; Field: TField);
begin
	{ Only interested in moving between records, not in a single field edit. }
	if Assigned(Field) then
		Exit;
	memCompiled.Lines.BeginUpdate;
	try
		memCompiled.Clear;
		if qryCompiled.Active and not (qryCompiled.EOF and qryCompiled.BOF) then
		begin
			memCompiled.Lines.Add(qryCompiled.FieldByName('mon$sql_text').AsString);
			memCompiled.Lines.Add('');
			memCompiled.Lines.Add('/* Cached plan */');
			memCompiled.Lines.Add(qryCompiled.FieldByName('mon$explained_plan').AsString);
		end;
	finally
		memCompiled.Lines.EndUpdate;
	end;
end;

procedure TfrmSessionMonitor.RefreshData;
begin
	{ Firebird takes a fresh MON$ snapshot for the first statement of each new
	  transaction, so a plain re-open on the same transaction would keep
	  showing the old snapshot - start a new transaction every refresh. }
	qryAttachments.Close;
	qryStatements.Close;
	qryTransactions.Close;
	qryCompiled.Close;
	if tranMonitor.Active then
		tranMonitor.Commit;
	tranMonitor.StartTransaction;

	{ MON$TIMESTAMP is TIMESTAMP WITH TIME ZONE from Firebird 4 on, and is cast
	  to text on the server for two reasons. It preserves the IANA zone name -
	  IBX surfaces the column as a plain ftDateTime and reduces the zone to a
	  numeric offset, so "Europe/Berlin" arrives as "+02:00". And it steps
	  around a defect in this IBX version, where reading a WITH TIME ZONE
	  column leaves the attachment unable to disconnect afterwards; see
	  test/timezone_disconnect_repro.lpr. 64 characters, not 40: the longest
	  IANA names plus a timestamp with fractional seconds overflow a smaller
	  cast, and Firebird raises a truncation error rather than shortening it.

	  MON$STATE, MON$ISOLATION_MODE and MON$OBJECT_TYPE are raw code numbers.
	  Rather than hard-code a decode table that would go stale on a newer
	  server, join RDB$TYPES, which is where Firebird itself publishes the
	  meaning of each code - a code the running server does not know about
	  falls back to its number instead of being mislabelled. Aliases are
	  unquoted and upper case because IBX normalises a field name to that
	  anyway, so a prettier quoted alias would not survive to the grid. }
	qryAttachments.SQL.Text :=
		'select a.mon$attachment_id, a.mon$user, a.mon$remote_address, a.mon$remote_process, ' +
		'cast(a.mon$timestamp as varchar(64)) as MON$TIMESTAMP, ' +
		'coalesce(replace(trim(st.rdb$type_name), ''_'', '' ''), cast(a.mon$state as varchar(11))) as STATE ' +
		'from mon$attachments a ' +
		'left join rdb$types st on st.rdb$field_name = ''MON$STATE'' and st.rdb$type = a.mon$state ' +
		'order by a.mon$attachment_id';
	qryAttachments.Open;

	qryStatements.SQL.Text :=
		'select s.mon$statement_id, s.mon$attachment_id, s.mon$transaction_id, ' +
		'coalesce(replace(trim(st.rdb$type_name), ''_'', '' ''), cast(s.mon$state as varchar(11))) as STATE, ' +
		'cast(s.mon$timestamp as varchar(64)) as MON$TIMESTAMP, s.mon$sql_text ' +
		'from mon$statements s ' +
		'left join rdb$types st on st.rdb$field_name = ''MON$STATE'' and st.rdb$type = s.mon$state ' +
		'order by s.mon$statement_id';
	qryStatements.Open;

	{ Firebird 4 added isolation mode 4, READ COMMITTED READ CONSISTENCY, and
	  makes it the default for read-committed transactions (ReadConsistency=1
	  in firebird.conf), so on a stock FB4+ server this is what nearly every
	  transaction here reports - including ones that asked for RECORD VERSION
	  or NO RECORD VERSION, which the engine silently upgrades. }
	qryTransactions.SQL.Text :=
		'select t.mon$transaction_id, t.mon$attachment_id, ' +
		'coalesce(replace(trim(st.rdb$type_name), ''_'', '' ''), cast(t.mon$state as varchar(11))) as STATE, ' +
		'cast(t.mon$timestamp as varchar(64)) as MON$TIMESTAMP, ' +
		'coalesce(replace(trim(iso.rdb$type_name), ''_'', '' ''), cast(t.mon$isolation_mode as varchar(11))) as ISOLATION, ' +
		'case when t.mon$read_only <> 0 then ''Yes'' else ''No'' end as READ_ONLY, ' +
		't.mon$lock_timeout ' +
		'from mon$transactions t ' +
		'left join rdb$types iso on iso.rdb$field_name = ''MON$ISOLATION_MODE'' and iso.rdb$type = t.mon$isolation_mode ' +
		'left join rdb$types st on st.rdb$field_name = ''MON$STATE'' and st.rdb$type = t.mon$state ' +
		'order by t.mon$transaction_id';
	qryTransactions.Open;

	if FCompiledSupported then
	begin
		{ Unlike the other three, this is a server-wide cache rather than a view
		  of live activity: rows outlive the attachment that compiled them, so
		  it shows what Firebird still has compiled and the plan it chose. }
		qryCompiled.SQL.Text :=
			'select c.mon$compiled_statement_id, c.mon$object_name, c.mon$package_name, ' +
			'coalesce(replace(trim(ot.rdb$type_name), ''_'', '' ''), cast(c.mon$object_type as varchar(11))) as OBJECT_TYPE, ' +
			'c.mon$sql_text, c.mon$explained_plan ' +
			'from mon$compiled_statements c ' +
			'left join rdb$types ot on ot.rdb$field_name = ''RDB$OBJECT_TYPE'' and ot.rdb$type = c.mon$object_type ' +
			'order by c.mon$compiled_statement_id';
		qryCompiled.Open;
	end;
end;

end.
