unit MetaExtractWizard;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
	SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, ExtCtrls, CheckLst,
	IBDatabase, IBQuery, MetaExtractUnit, MarathonProjectCacheTypes;

type
	TfrmMetaExtractWizard = class(TForm)
		pnlTop: TPanel;
		lblConnection: TLabel;
		lblOutputFile: TLabel;
		edOutputFile: TEdit;
		btnBrowseOutput: TButton;
		dlgSaveScript: TSaveDialog;
		pgMain: TPageControl;
		tsDomains: TTabSheet;
		lstDomains: TCheckListBox;
		tsTables: TTabSheet;
		lstTables: TCheckListBox;
		tsViews: TTabSheet;
		lstViews: TCheckListBox;
		tsProcedures: TTabSheet;
		lstProcedures: TCheckListBox;
		tsTriggers: TTabSheet;
		lstTriggers: TCheckListBox;
		tsGenerators: TTabSheet;
		lstGenerators: TCheckListBox;
		tsExceptions: TTabSheet;
		lstExceptions: TCheckListBox;
		tsUDFs: TTabSheet;
		lstUDFs: TCheckListBox;
		tsPackages: TTabSheet;
		lstPackages: TCheckListBox;
		tsOptions: TTabSheet;
		rdoExtractType: TRadioGroup;
		chkCreateDatabase: TCheckBox;
		chkIncludePassword: TCheckBox;
		chkIncludeDependents: TCheckBox;
		chkIncludeDoc: TCheckBox;
		chkWrap: TCheckBox;
		lblWrapAt: TLabel;
		edWrapAt: TEdit;
		udWrapAt: TUpDown;
		lblDecimalPlaces: TLabel;
		edDecimalPlaces: TEdit;
		udDecimalPlaces: TUpDown;
		lblDecimalSeparator: TLabel;
		cmbDecimalSeparator: TComboBox;
		pnlBottom: TPanel;
		btnSelectAll: TButton;
		btnSelectNone: TButton;
		pbProgress: TProgressBar;
		lblProgress: TLabel;
		btnExtract: TButton;
		btnStop: TButton;
		btnClose: TButton;
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure btnBrowseOutputClick(Sender: TObject);
		procedure btnSelectAllClick(Sender: TObject);
		procedure btnSelectNoneClick(Sender: TObject);
		procedure btnExtractClick(Sender: TObject);
		procedure btnStopClick(Sender: TObject);
		procedure chkWrapClick(Sender: TObject);
	private
		FConnectionName: String;
		FDatabase: TIBDatabase;
		FTransaction: TIBTransaction;
		FIsIB6: Boolean;
		FSQLDialect: Integer;
		FStop: Boolean;
		FExtracting: Boolean;
		function GetExtractType: Integer;
		procedure SetExtractType(Value: Integer);
		function GetCreateDatabase: Boolean;
		procedure SetCreateDatabase(Value: Boolean);
		function GetIncludePassword: Boolean;
		procedure SetIncludePassword(Value: Boolean);
		function GetIncludeDependents: Boolean;
		procedure SetIncludeDependents(Value: Boolean);
		function GetIncludeDoc: Boolean;
		procedure SetIncludeDoc(Value: Boolean);
		function GetWrapOutput: Boolean;
		procedure SetWrapOutput(Value: Boolean);
		function GetDecimalPlaces: Integer;
		procedure SetDecimalPlaces(Value: Integer);
		function GetDecimalSeparator: String;
		procedure SetDecimalSeparator(const Value: String);
		function GetWrapAt: Integer;
		procedure SetWrapAt(Value: Integer);
		procedure RunObjectQuery(LB: TCheckListBox; const SQL, FieldName, ExcludePrefix: String);
		function FunctionListSQL: String;
		function ProcedureListSQL: String;
		function PackagesSupported: Boolean;
		function SchemaClause: String;
		procedure PopulateObjectLists;
		function GetChecklistFor(CacheType: TGSSCacheType): TCheckListBox;
		function CurrentChecklist: TCheckListBox;
		procedure CollectChecked(LB: TCheckListBox; List: TStringList);
		procedure ExtractNotifyHandler(Sender: TObject; CurObj: String; PercentDone: Integer; var Stop: Boolean);
	public
		procedure SetConnection(const ConnectionName: String; Database: TIBDatabase; Transaction: TIBTransaction;
			IsIB6: Boolean; SQLDialect: Integer);
		procedure PreSelectObject(CacheType: TGSSCacheType; const ObjectName: String);
		{ Ord(TExtractType) rather than TExtractType itself, so callers don't need
		  MetaExtractUnit in their uses clause just to set this. }
		property ExtractType: Integer read GetExtractType write SetExtractType;
		property CreateDatabase: Boolean read GetCreateDatabase write SetCreateDatabase;
		property IncludePassword: Boolean read GetIncludePassword write SetIncludePassword;
		property IncludeDependents: Boolean read GetIncludeDependents write SetIncludeDependents;
		property IncludeDoc: Boolean read GetIncludeDoc write SetIncludeDoc;
		property WrapOutput: Boolean read GetWrapOutput write SetWrapOutput;
		property DecimalPlaces: Integer read GetDecimalPlaces write SetDecimalPlaces;
		property DecimalSeparator: String read GetDecimalSeparator write SetDecimalSeparator;
		property WrapAt: Integer read GetWrapAt write SetWrapAt;
	end;

implementation

uses Globals;

{$R *.lfm}

procedure TfrmMetaExtractWizard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	CanClose := not FExtracting;
	if not CanClose then
		MessageDlg('Stop the extraction before closing this window.', mtInformation, [mbOK], 0);
end;

procedure TfrmMetaExtractWizard.chkWrapClick(Sender: TObject);
begin
	edWrapAt.Enabled := chkWrap.Checked;
	udWrapAt.Enabled := chkWrap.Checked;
end;

function TfrmMetaExtractWizard.GetExtractType: Integer;
begin
	Result := rdoExtractType.ItemIndex;
end;

procedure TfrmMetaExtractWizard.SetExtractType(Value: Integer);
begin
	rdoExtractType.ItemIndex := Value;
end;

function TfrmMetaExtractWizard.GetCreateDatabase: Boolean;
begin
	Result := chkCreateDatabase.Checked;
end;

procedure TfrmMetaExtractWizard.SetCreateDatabase(Value: Boolean);
begin
	chkCreateDatabase.Checked := Value;
end;

function TfrmMetaExtractWizard.GetIncludePassword: Boolean;
begin
	Result := chkIncludePassword.Checked;
end;

procedure TfrmMetaExtractWizard.SetIncludePassword(Value: Boolean);
begin
	chkIncludePassword.Checked := Value;
end;

function TfrmMetaExtractWizard.GetIncludeDependents: Boolean;
begin
	Result := chkIncludeDependents.Checked;
end;

procedure TfrmMetaExtractWizard.SetIncludeDependents(Value: Boolean);
begin
	chkIncludeDependents.Checked := Value;
end;

function TfrmMetaExtractWizard.GetIncludeDoc: Boolean;
begin
	Result := chkIncludeDoc.Checked;
end;

procedure TfrmMetaExtractWizard.SetIncludeDoc(Value: Boolean);
begin
	chkIncludeDoc.Checked := Value;
end;

function TfrmMetaExtractWizard.GetWrapOutput: Boolean;
begin
	Result := chkWrap.Checked;
end;

procedure TfrmMetaExtractWizard.SetWrapOutput(Value: Boolean);
begin
	chkWrap.Checked := Value;
	chkWrapClick(chkWrap);
end;

function TfrmMetaExtractWizard.GetDecimalPlaces: Integer;
begin
	Result := udDecimalPlaces.Position;
end;

procedure TfrmMetaExtractWizard.SetDecimalPlaces(Value: Integer);
begin
	udDecimalPlaces.Position := Value;
end;

function TfrmMetaExtractWizard.GetDecimalSeparator: String;
begin
	Result := cmbDecimalSeparator.Text;
end;

procedure TfrmMetaExtractWizard.SetDecimalSeparator(const Value: String);
var
	Idx: Integer;
begin
	Idx := cmbDecimalSeparator.Items.IndexOf(Value);
	if Idx >= 0 then
		cmbDecimalSeparator.ItemIndex := Idx;
end;

function TfrmMetaExtractWizard.GetWrapAt: Integer;
begin
	Result := udWrapAt.Position;
end;

procedure TfrmMetaExtractWizard.SetWrapAt(Value: Integer);
begin
	udWrapAt.Position := Value;
end;

procedure TfrmMetaExtractWizard.SetConnection(const ConnectionName: String; Database: TIBDatabase;
	Transaction: TIBTransaction; IsIB6: Boolean; SQLDialect: Integer);
begin
	FConnectionName := ConnectionName;
	FDatabase := Database;
	FTransaction := Transaction;
	FIsIB6 := IsIB6;
	FSQLDialect := SQLDialect;
	Caption := 'Extract Metadata - ' + ConnectionName;
	lblConnection.Caption := 'Connection: ' + ConnectionName;
	PopulateObjectLists;
end;

procedure TfrmMetaExtractWizard.RunObjectQuery(LB: TCheckListBox; const SQL, FieldName, ExcludePrefix: String);
var
	Tr: TIBTransaction;
	Q: TIBQuery;
	Nm: String;
begin
	LB.Items.Clear;
	if (not Assigned(FDatabase)) or (not FDatabase.Connected) then
		Exit;

	Tr := TIBTransaction.Create(nil);
	Q := TIBQuery.Create(nil);
	try
		Tr.DefaultDatabase := FDatabase;
		Q.Database := FDatabase;
		Q.Transaction := Tr;
		Tr.StartTransaction;
		try
			Q.SQL.Text := SQL;
			Q.Open;
			while not Q.EOF do
			begin
				Nm := Trim(Q.FieldByName(FieldName).AsString);
				if (ExcludePrefix = '') or (AnsiUpperCase(Copy(Nm, 1, Length(ExcludePrefix))) <> ExcludePrefix) then
					LB.Items.Add(Nm);
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

function TfrmMetaExtractWizard.PackagesSupported: Boolean;
begin
  Result := False;
  if Assigned(FDatabase) and FDatabase.Connected then
  begin
    try
      Result := FDatabase.Attachment.GetODSMajorVersion >= 12;
    except
      Result := False;
    end;
  end;
end;

{ See TMarathonCacheConnection.SchemaFilterClause - same rule, same reason: the
  wizard extracts unqualified DDL, so it must offer only what an unqualified
  name reaches. }
function TfrmMetaExtractWizard.SchemaClause: String;
begin
  Result := '';
  if Assigned(FDatabase) and FDatabase.Connected then
    try
      if FDatabase.Attachment.GetODSMajorVersion >= 14 then
        Result := ' and (rdb$schema_name = current_schema or current_schema is null)';
    except
      Result := '';
    end;
end;

function TfrmMetaExtractWizard.FunctionListSQL: String;
var
  ODSMajor: Integer;
begin
  { Mirrors the object tree's UDF node: packaged functions are not standalone
    objects, but RDB$PACKAGE_NAME only exists from Firebird 3 (ODS 12) on, and
    naming a missing column is a hard query error. }
  ODSMajor := 0;
  if Assigned(FDatabase) and FDatabase.Connected then
  begin
    try
      ODSMajor := FDatabase.Attachment.GetODSMajorVersion;
    except
      ODSMajor := 0;
    end;
  end;
  Result := 'select rdb$function_name from rdb$functions where ' +
            '((rdb$system_flag = 0) or (rdb$system_flag is null))';
  if ODSMajor >= 12 then
    Result := Result + ' and rdb$package_name is null';
  Result := Result + SchemaClause + ' order by rdb$function_name asc';
end;

{ The same exclusion for packaged procedures, which cannot be created or
  dropped standalone either. }
function TfrmMetaExtractWizard.ProcedureListSQL: String;
begin
  Result := 'select rdb$procedure_name from rdb$procedures where ' +
            '((rdb$system_flag = 0) or (rdb$system_flag is null))';
  if PackagesSupported then
    Result := Result + ' and rdb$package_name is null';
  Result := Result + SchemaClause + ' order by rdb$procedure_name asc';
end;

procedure TfrmMetaExtractWizard.PopulateObjectLists;
begin
	{ Same RDB$*/CHECK_* filtering as DatabaseManager.pas's tree "header" node
	  Expand() methods (TMarathonCacheUserDomainsHeader, TMarathonCacheTablesHeader,
	  etc.) - kept identical so this wizard's object lists always match what the
	  Database Explorer tree shows. }
	RunObjectQuery(lstDomains,
		'select rdb$field_name from rdb$fields where ((rdb$system_flag = 0) or (rdb$system_flag is null))' + SchemaClause + ' order by rdb$field_name asc',
		'rdb$field_name', 'RDB$');
	RunObjectQuery(lstTables,
		'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is null' + SchemaClause + ' order by rdb$relation_name asc',
		'rdb$relation_name', 'RDB$');
	RunObjectQuery(lstViews,
		'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null' + SchemaClause + ' order by rdb$relation_name asc',
		'rdb$relation_name', '');
	RunObjectQuery(lstProcedures,
		ProcedureListSQL,
		'rdb$procedure_name', '');
	RunObjectQuery(lstTriggers,
		'select rdb$trigger_name from rdb$triggers where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and (rdb$trigger_source is not null) order by rdb$trigger_name asc',
		'rdb$trigger_name', 'CHECK_');
	RunObjectQuery(lstGenerators,
		'select rdb$generator_name from rdb$generators where ((rdb$system_flag = 0) or (rdb$system_flag is null))' + SchemaClause + ' order by rdb$generator_name asc',
		'rdb$generator_name', '');
	RunObjectQuery(lstExceptions,
		'select rdb$exception_name from rdb$exceptions where ((rdb$system_flag = 0) or (rdb$system_flag is null))' + SchemaClause + ' order by rdb$exception_name asc',
		'rdb$exception_name', '');
	RunObjectQuery(lstUDFs,
		FunctionListSQL,
		'rdb$function_name', '');
	{ Packages are Firebird 3 (ODS 12); RDB$PACKAGES does not exist earlier, and
	  querying a missing table is a hard error, so skip it entirely there. }
	if PackagesSupported then
		RunObjectQuery(lstPackages,
			'select rdb$package_name from rdb$packages where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$package_name asc',
			'rdb$package_name', '')
	else
		lstPackages.Items.Clear;
end;

function TfrmMetaExtractWizard.GetChecklistFor(CacheType: TGSSCacheType): TCheckListBox;
begin
	case CacheType of
		ctDomain: Result := lstDomains;
		ctTable: Result := lstTables;
		ctView: Result := lstViews;
		ctSP: Result := lstProcedures;
		ctTrigger: Result := lstTriggers;
		ctGenerator: Result := lstGenerators;
		ctException: Result := lstExceptions;
		ctUDF: Result := lstUDFs;
		ctPackage: Result := lstPackages;
	else
		Result := nil;
	end;
end;

procedure TfrmMetaExtractWizard.PreSelectObject(CacheType: TGSSCacheType; const ObjectName: String);
var
	LB: TCheckListBox;
	Idx: Integer;
begin
	LB := GetChecklistFor(CacheType);
	if not Assigned(LB) then
		Exit;
	Idx := LB.Items.IndexOf(ObjectName);
	if Idx >= 0 then
		LB.Checked[Idx] := True;
end;

function TfrmMetaExtractWizard.CurrentChecklist: TCheckListBox;
begin
	if pgMain.ActivePage = tsDomains then Result := lstDomains
	else if pgMain.ActivePage = tsTables then Result := lstTables
	else if pgMain.ActivePage = tsViews then Result := lstViews
	else if pgMain.ActivePage = tsProcedures then Result := lstProcedures
	else if pgMain.ActivePage = tsTriggers then Result := lstTriggers
	else if pgMain.ActivePage = tsGenerators then Result := lstGenerators
	else if pgMain.ActivePage = tsExceptions then Result := lstExceptions
	else if pgMain.ActivePage = tsUDFs then Result := lstUDFs
	else if pgMain.ActivePage = tsPackages then Result := lstPackages
	else Result := nil;
end;

procedure TfrmMetaExtractWizard.btnSelectAllClick(Sender: TObject);
var
	LB: TCheckListBox;
	Idx: Integer;
begin
	LB := CurrentChecklist;
	if Assigned(LB) then
		for Idx := 0 to LB.Items.Count - 1 do
			LB.Checked[Idx] := True;
end;

procedure TfrmMetaExtractWizard.btnSelectNoneClick(Sender: TObject);
var
	LB: TCheckListBox;
	Idx: Integer;
begin
	LB := CurrentChecklist;
	if Assigned(LB) then
		for Idx := 0 to LB.Items.Count - 1 do
			LB.Checked[Idx] := False;
end;

procedure TfrmMetaExtractWizard.btnBrowseOutputClick(Sender: TObject);
begin
	if gExtractDDLDir <> '' then
		dlgSaveScript.InitialDir := gExtractDDLDir;
	if dlgSaveScript.Execute then
		edOutputFile.Text := dlgSaveScript.FileName;
end;

procedure TfrmMetaExtractWizard.CollectChecked(LB: TCheckListBox; List: TStringList);
var
	Idx: Integer;
begin
	List.Clear;
	for Idx := 0 to LB.Items.Count - 1 do
		if LB.Checked[Idx] then
			List.Add(LB.Items[Idx]);
end;

procedure TfrmMetaExtractWizard.ExtractNotifyHandler(Sender: TObject; CurObj: String; PercentDone: Integer; var Stop: Boolean);
begin
	{ TIBMetaExtract's percent-done estimate is based on the initial object
	  count and can run past 100 once grants (not counted up front) start
	  being written - clamp so the progress bar doesn't visually overflow. }
	if PercentDone > 100 then
		PercentDone := 100;
	if PercentDone >= 0 then
		pbProgress.Position := PercentDone;
	lblProgress.Caption := CurObj;
	Application.ProcessMessages;
	Stop := FStop;
end;

procedure TfrmMetaExtractWizard.btnStopClick(Sender: TObject);
begin
	FStop := True;
end;

procedure TfrmMetaExtractWizard.btnExtractClick(Sender: TObject);
var
	M: TIBMetaExtract;
begin
	if Trim(edOutputFile.Text) = '' then
	begin
		MessageDlg('Choose an output file first.', mtError, [mbOK], 0);
		Exit;
	end;

	if (lstDomains.Items.Count = 0) and (lstTables.Items.Count = 0) and (lstViews.Items.Count = 0) and
		(lstProcedures.Items.Count = 0) and (lstTriggers.Items.Count = 0) and (lstGenerators.Items.Count = 0) and
		(lstExceptions.Items.Count = 0) and (lstUDFs.Items.Count = 0) and
		(lstPackages.Items.Count = 0) then
	begin
		MessageDlg('There are no objects to extract - is the connection open?', mtError, [mbOK], 0);
		Exit;
	end;

	FStop := False;
	FExtracting := True;
	btnExtract.Enabled := False;
	btnStop.Enabled := True;
	btnClose.Enabled := False;
	pbProgress.Position := 0;
	lblProgress.Caption := 'Starting...';

	M := TIBMetaExtract.Create(nil);
	try
		M.Database := FDatabase;
		M.Transaction := FTransaction;
		M.DatabaseName := FDatabase.DatabaseName;
		M.UserName := FDatabase.Params.Values['user_name'];
		M.Password := FDatabase.Params.Values['password'];
		M.IsIB6 := FIsIB6;
		M.SQLDialect := FSQLDialect;
		M.FileName := edOutputFile.Text;
		M.OnExtractNotify := ExtractNotifyHandler;

		M.ExtractType := TExtractType(ExtractType);
		M.CreateDatabase := CreateDatabase;
		M.IncludePassword := IncludePassword;
		M.IncludeDependents := IncludeDependents;
		M.IncludeDoc := IncludeDoc;
		M.Wrap := WrapOutput;
		M.RightMargin := WrapAt;
		M.DecimalPlaces := DecimalPlaces;
		M.DecimalSeparator := DecimalSeparator;

		CollectChecked(lstDomains, M.Domains);
		CollectChecked(lstTables, M.Tables);
		CollectChecked(lstViews, M.Views);
		CollectChecked(lstProcedures, M.SPs);
		CollectChecked(lstTriggers, M.Triggers);
		CollectChecked(lstGenerators, M.Generators);
		CollectChecked(lstExceptions, M.Exceptions);
		CollectChecked(lstUDFs, M.UDFs);
		CollectChecked(lstPackages, M.Packages);

		{ Grants are extracted for whatever tables/views/procedures were
		  selected above - there's no separate grant-object picker here. }
		M.GrantTables.Assign(M.Tables);
		M.GrantViews.Assign(M.Views);
		M.GrantSPs.Assign(M.SPs);

		try
			M.ExtractFullMetaData;
			if FStop then
			begin
				lblProgress.Caption := 'Stopped.';
				MessageDlg('Extraction stopped.', mtInformation, [mbOK], 0);
			end
			else
			begin
				pbProgress.Position := 100;
				lblProgress.Caption := 'Done.';
				MessageDlg('Metadata extracted to ' + edOutputFile.Text, mtInformation, [mbOK], 0);
			end;
		except
			on E: Exception do
			begin
				lblProgress.Caption := 'Failed.';
				MessageDlg('Extraction failed: ' + E.Message, mtError, [mbOK], 0);
			end;
		end;
	finally
		M.Free;
		FExtracting := False;
		btnExtract.Enabled := True;
		btnStop.Enabled := False;
		btnClose.Enabled := True;
	end;
end;

end.
