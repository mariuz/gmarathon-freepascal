unit MaintenanceDialog;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
	SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, Spin, ExtCtrls, CheckLst,
	DB, IBDatabase, IBQuery, IBXServices;

type
	TfrmMaintenance = class(TForm)
		pnlTop: TPanel;
		lblConnection: TLabel;
		pgMaint: TPageControl;
		tsSweepValidate: TTabSheet;
		btnSweep: TButton;
		lblValidateOptions: TLabel;
		chkFullValidation: TCheckBox;
		chkIgnoreChecksums: TCheckBox;
		chkMendDatabase: TCheckBox;
		chkKillShadows: TCheckBox;
		chkReadOnlyValidation: TCheckBox;
		btnUpgradeODS: TButton;
		btnValidate: TButton;
		tsBackupHistory: TTabSheet;
		lstBackupHistory: TListView;
		pnlHistoryBottom: TPanel;
		lblHistoryNote: TLabel;
		btnRefreshHistory: TButton;
		tsStatistics: TTabSheet;
		lstIndexes: TCheckListBox;
		pnlStatsBottom: TPanel;
		btnRefreshIndexes: TButton;
		btnRecomputeSelectivity: TButton;
		tsBackup: TTabSheet;
		lblBackupFile: TLabel;
		edBackupFile: TEdit;
		btnBrowseBackup: TButton;
		chkBackupMetadataOnly: TCheckBox;
		lblParallelWorkers: TLabel;
		edParallelWorkers: TSpinEdit;
		btnBackup: TButton;
		dlgSaveBackup: TSaveDialog;
		tsRestore: TTabSheet;
		lblRestoreSource: TLabel;
		edRestoreSource: TEdit;
		btnBrowseRestoreSource: TButton;
		lblRestoreTarget: TLabel;
		edRestoreTarget: TEdit;
		btnBrowseRestoreTarget: TButton;
		btnRestore: TButton;
		dlgOpenRestoreSource: TOpenDialog;
		dlgSaveRestoreTarget: TSaveDialog;
		pnlLog: TPanel;
		lblLog: TLabel;
		mmoLog: TMemo;
		svcConn: TIBXServicesConnection;
		svcValidate: TIBXValidationService;
		svcBackup: TIBXClientSideBackupService;
		svcRestore: TIBXClientSideRestoreService;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnRefreshHistoryClick(Sender: TObject);
		procedure btnSweepClick(Sender: TObject);
		procedure btnValidateClick(Sender: TObject);
		procedure btnUpgradeODSClick(Sender: TObject);
		procedure btnRefreshIndexesClick(Sender: TObject);
		procedure btnRecomputeSelectivityClick(Sender: TObject);
		procedure btnBrowseBackupClick(Sender: TObject);
		procedure btnBackupClick(Sender: TObject);
		procedure btnBrowseRestoreSourceClick(Sender: TObject);
		procedure btnBrowseRestoreTargetClick(Sender: TObject);
		procedure btnRestoreClick(Sender: TObject);
		procedure ServiceGetNextLine(Sender: TObject; var Line: string);
	private
		FConnectionName: String;
		FDatabase: TIBDatabase;
		procedure SetConnectionName(const Value: String);
		procedure EnsureServicesConnected;
		procedure Log(const Msg: String);
		procedure RefreshIndexes;
	public
		property ConnectionName: String read FConnectionName write SetConnectionName;
	end;

implementation

uses MarathonIDE, MarathonProjectCache;

{$R *.lfm}

procedure TfrmMaintenance.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	if svcConn.Connected then
		svcConn.Connected := False;
	Action := caFree;
end;

procedure TfrmMaintenance.SetConnectionName(const Value: String);
var
	Conn: TMarathonCacheConnection;
begin
	FConnectionName := Value;
	Caption := 'Database Maintenance - ' + Value;
	lblConnection.Caption := 'Connection: ' + Value;

	Conn := CacheConnectionNamed(Value);
	{ Everything this dialog does needs a database. Without one it holds nil and
	  lists nothing, rather than dereferencing a connection that is not there. }
	if not Assigned(Conn) then
	begin
		FDatabase := nil;
		lblConnection.Caption := 'Connection: none';
		lstIndexes.Items.Clear;
		Exit;
	end;
	FDatabase := Conn.Connection;

	RefreshIndexes;
end;

procedure TfrmMaintenance.Log(const Msg: String);
begin
	mmoLog.Lines.Add(Msg);
end;

procedure TfrmMaintenance.EnsureServicesConnected;
begin
	if svcConn.Connected then
		Exit;
	svcConn.LoginPrompt := False;
	svcConn.SetDBParams(FDatabase.Params);
	svcConn.ConnectUsing(FDatabase);
end;

procedure TfrmMaintenance.ServiceGetNextLine(Sender: TObject; var Line: string);
begin
	Application.ProcessMessages;
end;

procedure TfrmMaintenance.RefreshIndexes;
var
	Q: TIBQuery;
	Tr: TIBTransaction;
begin
	lstIndexes.Items.Clear;
	Tr := TIBTransaction.Create(nil);
	Q := TIBQuery.Create(nil);
	try
		Tr.DefaultDatabase := FDatabase;
		Q.Database := FDatabase;
		Q.Transaction := Tr;
		Tr.StartTransaction;
		try
			Q.SQL.Text :=
				'select rdb$index_name, rdb$relation_name from rdb$indices ' +
				'where coalesce(rdb$system_flag, 0) = 0 ' +
				'order by rdb$relation_name, rdb$index_name';
			Q.Open;
			while not Q.EOF do
			begin
				lstIndexes.Items.Add(Trim(Q.FieldByName('rdb$relation_name').AsString) + '.' +
					Trim(Q.FieldByName('rdb$index_name').AsString));
				Q.Next;
			end;
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

procedure TfrmMaintenance.btnRefreshIndexesClick(Sender: TObject);
begin
	RefreshIndexes;
end;

procedure TfrmMaintenance.btnRecomputeSelectivityClick(Sender: TObject);
var
	Idx: Integer;
	IndexName: String;
	Q: TIBQuery;
	Tr: TIBTransaction;
	AnyChecked: Boolean;
begin
	AnyChecked := False;
	for Idx := 0 to lstIndexes.Items.Count - 1 do
		if lstIndexes.Checked[Idx] then
		begin
			AnyChecked := True;
			Break;
		end;
	if not AnyChecked then
	begin
		MessageDlg('Check one or more indexes first.', mtInformation, [mbOK], 0);
		Exit;
	end;

	Tr := TIBTransaction.Create(nil);
	Q := TIBQuery.Create(nil);
	try
		Tr.DefaultDatabase := FDatabase;
		Q.Database := FDatabase;
		Q.Transaction := Tr;
		for Idx := 0 to lstIndexes.Items.Count - 1 do
		begin
			if not lstIndexes.Checked[Idx] then
				Continue;
			IndexName := Copy(lstIndexes.Items[Idx], Pos('.', lstIndexes.Items[Idx]) + 1, MaxInt);
			Tr.StartTransaction;
			try
				Q.SQL.Text := 'set statistics index "' + IndexName + '"';
				Q.ExecSQL;
				Tr.Commit;
				Log('Recomputed selectivity: ' + lstIndexes.Items[Idx]);
			except
				on E: Exception do
				begin
					if Tr.Active then
						Tr.Rollback;
					Log('FAILED: ' + lstIndexes.Items[Idx] + ' - ' + E.Message);
				end;
			end;
		end;
		MessageDlg('Recompute selectivity finished - see log for details.', mtInformation, [mbOK], 0);
	finally
		Q.Free;
		Tr.Free;
	end;
end;

procedure TfrmMaintenance.btnSweepClick(Sender: TObject);
begin
	if MessageDlg('Sweep database ' + FConnectionName + '?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
		Exit;
	try
		EnsureServicesConnected;
		svcValidate.DatabaseName := FDatabase.DatabaseName;
		svcValidate.Options := [SweepDB];
		Log('Sweep started...');
		svcValidate.Execute(mmoLog.Lines);
		Log('Sweep complete.');
		MessageDlg('Sweep complete.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
		begin
			Log('Sweep FAILED: ' + E.Message);
			MessageDlg('Sweep failed: ' + E.Message, mtError, [mbOK], 0);
		end;
	end;
end;

{ Firebird 5's in-place on-disk-structure upgrade, the alternative to a backup
  and restore. Deliberately its own button rather than another checkbox beside
  Mend: it rewrites the database's structure, cannot be undone, and is not
  something to tick by accident while validating. }
procedure TfrmMaintenance.btnUpgradeODSClick(Sender: TObject);
begin
	if MessageDlg('Upgrade the on-disk structure of ' + FConnectionName + '?' +
		#13#10#13#10 +
		'This rewrites the database to the format of the server it is attached to, ' +
		'and cannot be undone. Older Firebird versions will no longer be able to ' +
		'open it. Take a backup first, and close other windows using this ' +
		'connection - the upgrade needs exclusive access.',
		mtWarning, [mbYes, mbNo], 0) <> mrYes then
		Exit;

	Screen.Cursor := crHourGlass;
	try
		try
			EnsureServicesConnected;
			svcValidate.DatabaseName := FDatabase.DatabaseName;
			svcValidate.Options := [UpgradeODS];
			Log('ODS upgrade started');
			svcValidate.Execute(mmoLog.Lines);
			Log('ODS upgrade finished');
			MessageDlg('The upgrade request completed. A database already at the ' +
				'server''s format is left unchanged.', mtInformation, [mbOK], 0);
		except
			on E: Exception do
			begin
				Log('ODS upgrade failed: ' + E.Message);
				MessageDlg('ODS upgrade failed: ' + E.Message, mtError, [mbOK], 0);
			end;
		end;
	finally
		Screen.Cursor := crDefault;
	end;
end;

procedure TfrmMaintenance.btnValidateClick(Sender: TObject);
var
	Options: TValidateOptions;
begin
	Options := [ValidateDB];
	if chkFullValidation.Checked then
		Options := Options + [ValidateFull];
	if chkIgnoreChecksums.Checked then
		Options := Options + [IgnoreChecksum];
	if chkMendDatabase.Checked then
		Options := Options + [MendDB];
	if chkKillShadows.Checked then
		Options := Options + [KillShadows];
	if chkReadOnlyValidation.Checked then
		Options := Options + [CheckDB];

	if MessageDlg('Validate/repair database ' + FConnectionName + '?' + #13#10#13#10 +
		'This may fail if other connections currently have the database open - ' +
		'close other windows using this connection first if it errors out.',
		mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
		Exit;

	try
		EnsureServicesConnected;
		svcValidate.DatabaseName := FDatabase.DatabaseName;
		svcValidate.Options := Options;
		Log('Validate/repair started...');
		svcValidate.Execute(mmoLog.Lines);
		Log('Validate/repair complete.');
		MessageDlg('Validate/repair complete.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
		begin
			Log('Validate/repair FAILED: ' + E.Message);
			MessageDlg('Validate/repair failed: ' + E.Message, mtError, [mbOK], 0);
		end;
	end;
end;

procedure TfrmMaintenance.btnBrowseBackupClick(Sender: TObject);
begin
	if dlgSaveBackup.Execute then
		edBackupFile.Text := dlgSaveBackup.FileName;
end;

procedure TfrmMaintenance.btnBackupClick(Sender: TObject);
var
	BytesWritten: Integer;
begin
	if Trim(edBackupFile.Text) = '' then
	begin
		MessageDlg('Choose a backup file first.', mtError, [mbOK], 0);
		Exit;
	end;

	try
		EnsureServicesConnected;
		svcBackup.DatabaseName := FDatabase.DatabaseName;
		if chkBackupMetadataOnly.Checked then
			svcBackup.Options := [MetadataOnly]
		else
			svcBackup.Options := [];
		{ Firebird 5 and later; the service only sends the parameter when the
		  server can take it, so an older server simply backs up as before. }
		svcBackup.ParallelWorkers := edParallelWorkers.Value;
		if edParallelWorkers.Value > 1 then
			Log(Format('Requesting %d parallel workers', [edParallelWorkers.Value]));
		Log('Backup started: ' + edBackupFile.Text);
		svcBackup.BackupToFile(edBackupFile.Text, BytesWritten);
		Log(Format('Backup complete: %d bytes written to %s', [BytesWritten, edBackupFile.Text]));
		MessageDlg('Backup complete.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
		begin
			Log('Backup FAILED: ' + E.Message);
			MessageDlg('Backup failed: ' + E.Message, mtError, [mbOK], 0);
		end;
	end;
end;

procedure TfrmMaintenance.btnBrowseRestoreSourceClick(Sender: TObject);
begin
	if dlgOpenRestoreSource.Execute then
		edRestoreSource.Text := dlgOpenRestoreSource.FileName;
end;

procedure TfrmMaintenance.btnBrowseRestoreTargetClick(Sender: TObject);
begin
	if dlgSaveRestoreTarget.Execute then
		edRestoreTarget.Text := dlgSaveRestoreTarget.FileName;
end;

procedure TfrmMaintenance.btnRestoreClick(Sender: TObject);
begin
	if Trim(edRestoreSource.Text) = '' then
	begin
		MessageDlg('Choose a backup file to restore from first.', mtError, [mbOK], 0);
		Exit;
	end;
	if Trim(edRestoreTarget.Text) = '' then
	begin
		MessageDlg('Choose a target database file first.', mtError, [mbOK], 0);
		Exit;
	end;
	if FileExists(edRestoreTarget.Text) then
	begin
		MessageDlg('The target file already exists. Restore always creates a new database - ' +
			'choose a target file that does not exist yet, to avoid any risk to an existing database.',
			mtError, [mbOK], 0);
		Exit;
	end;

	if MessageDlg('Restore ' + edRestoreSource.Text + ' to new database ' + edRestoreTarget.Text + '?',
		mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
		Exit;

	try
		EnsureServicesConnected;
		svcRestore.DatabaseFiles.Clear;
		svcRestore.DatabaseFiles.Add(edRestoreTarget.Text);
		svcRestore.Options := [CreateNewDB];
		Log('Restore started: ' + edRestoreSource.Text + ' -> ' + edRestoreTarget.Text);
		svcRestore.RestoreFromFile(edRestoreSource.Text, mmoLog.Lines);
		Log('Restore complete.');
		MessageDlg('Restore complete.', mtInformation, [mbOK], 0);
	except
		on E: Exception do
		begin
			Log('Restore FAILED: ' + E.Message);
			MessageDlg('Restore failed: ' + E.Message, mtError, [mbOK], 0);
		end;
	end;
end;

{ What the server has recorded of its own incremental backups.

  RDB$BACKUP_HISTORY is Firebird's own log of nbackup runs - it is written by
  the server, not by this program, so it shows backups taken by anything
  including a scheduled job. An older server has no such table, which is why
  the failure is reported in the list rather than raised: a missing table is an
  answer, not an error.

  Shown beside the backup and restore this dialog already performs, which is
  where someone asking "when was this last backed up" would look. }
procedure TfrmMaintenance.btnRefreshHistoryClick(Sender: TObject);
var
	Q: TIBQuery;
	Tr: TIBTransaction;
	Item: TListItem;
begin
	lstBackupHistory.Items.BeginUpdate;
	try
		lstBackupHistory.Items.Clear;
		{ Its own transaction, as the index list beside it does: this dialog holds
		  a connection rather than one of the shared metadata transactions.

		  The whole read is guarded, not just the Open: a server with no such
		  table, a connection that is not there, and a transaction that will not
		  start are all the same answer to the user - this database has no
		  backup history to show - and none of them is worth an exception
		  dialog. }
		Tr := TIBTransaction.Create(nil);
		Q := TIBQuery.Create(nil);
		try
			try
				Tr.DefaultDatabase := FDatabase;
				Q.Database := FDatabase;
				Q.Transaction := Tr;
				Tr.StartTransaction;
				Q.SQL.Text :=
					'select rdb$timestamp, rdb$backup_level, rdb$scn, rdb$file_name ' +
					'from rdb$backup_history order by rdb$timestamp desc';
				Q.Open;
				while not Q.EOF do
				begin
					Item := lstBackupHistory.Items.Add;
					Item.Caption := Q.Fields[0].AsString;
					Item.SubItems.Add(Q.Fields[1].AsString);
					Item.SubItems.Add(Q.Fields[2].AsString);
					Item.SubItems.Add(Trim(Q.Fields[3].AsString));
					Q.Next;
				end;
				Q.Close;
				if lstBackupHistory.Items.Count = 0 then
					{ An empty table is the ordinary case on a database nobody has
					  run nbackup against, and saying so beats an empty list. }
					lstBackupHistory.Items.Add.Caption :=
						'(the server has recorded no incremental backups)';
			except
				on E: Exception do
					lstBackupHistory.Items.Add.Caption :=
						'This server keeps no backup history: ' + E.Message;
			end;
		finally
			if Tr.InTransaction then
				Tr.Commit;
			Q.Free;
			Tr.Free;
		end;
	finally
		lstBackupHistory.Items.EndUpdate;
	end;
end;

end.
