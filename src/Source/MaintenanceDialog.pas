unit MaintenanceDialog;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
	SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, ExtCtrls, CheckLst,
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
		btnValidate: TButton;
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
		procedure btnSweepClick(Sender: TObject);
		procedure btnValidateClick(Sender: TObject);
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

	Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value];
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

end.
