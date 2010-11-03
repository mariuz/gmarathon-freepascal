program marathon;

{%File 'compilerdefines.inc'}

uses
  FastMM4,
  FastMove,
  Fastcode,
  PatchLib,
  FastObj,
  FastSys,
  Windows,
  Forms,
  SysUtils,
  Dialogs,
  Messages,
  Classes,
  Registry,
  MarathonMain in 'MarathonMain.pas' {frmMarathonMain},
  Globals in 'Globals.pas',
  SecureDBLogin in 'SecureDBLogin.pas' {frmSecureConnect},
  EditorStoredProcedure in 'EditorStoredProcedure.pas' {frmStoredProcedure},
  EditorView in 'EditorView.pas' {frmViewEditor},
  NewObjectDialog in 'NewObjectDialog.pas' {frmNewObject},
  DropObject in 'DropObject.pas' {frmDropObject},
  StoredProcedureParams in 'StoredProcedureParams.pas' {frmStoredProcParameters},
  SQLForm in 'SQLForm.pas' {frmSQLForm},
  MarathonOptions in 'MarathonOptions.pas' {frmMarathonOptions},
  PrintPreviewForm in 'PrintPreviewForm.pas' {frmPrintPreview},
  SplashForm in 'SplashForm.pas' {frmSplash},
  AboutBox in '..\Common\AboutBox.pas' {frmAboutBox},
  EditorUDF in 'EditorUDF.pas' {frmUDFEditor},
  InputDialog in 'InputDialog.pas' {frmInputDialog},
  NewTrigger in 'NewTrigger.pas' {frmNewTrigger},
  StatementHistory in 'StatementHistory.pas' {frmStatementHistory},
  SaveFileFormat in 'SaveFileFormat.pas' {frmSaveFileFormat},
  WindowList in 'WindowList.pas' {frmWindowList},
  UDFInputParam in 'UDFInputParam.pas' {frmUDFAddInput},
  UserEditor in 'UserEditor.pas' {frmUsers},
  ScriptEditorHost in 'ScriptEditorHost.pas' {frmScriptEditorHost},
  EditorColumn in 'EditorColumn.pas' {frmColumns},
  EditorConstraint in 'EditorConstraint.pas' {frmEditorConstraint},
  EditorIndex in 'EditorIndex.pas' {frmEditorIndex},
  BlobViewer in 'BlobViewer.pas' {frmBlobViewer},
  TipOfTheDay in 'TipOfTheDay.pas' {frmTipOfTheDay},
  SyntaxHelp in 'SyntaxHelp.pas' {frmSyntaxHelp},
  CodeSnippets in 'CodeSnippets.pas' {frmCodeSnippets},
  SQLTrace in 'SQLTrace.pas' {frmSQLTrace},
  SQLInsightItem in 'SQLInsightItem.pas' {frmSQLInsight},
  QBuilder in 'QBuilder.pas' {QBForm},
  ShlObj,
  ReorderColumns in 'ReorderColumns.pas' {frmReorderColumns},
  WindowLists in 'WindowLists.pas',
  EditorGenerator in 'EditorGenerator.pas' {frmGenerators},
  Login in 'Login.pas' {frmConnect},
  MetaDataSearchObject in 'MetaDataSearchObject.pas',
  DebugWatches in 'DebugWatches.pas' {frmWatches},
  AddWatch in 'AddWatch.pas' {frmAddWatch},
  ParseCollection in 'ParseCollection.pas',
  DebugEvalModify in 'DebugEvalModify.pas' {frmGetSetVariable},
  SQLYacc in 'SQLYacc.pas',
  LexLib in 'LexLib.pas',
  YaccLib in 'YaccLib.pas',
  EditorGrant in 'EditorGrant.pas' {frmEditorGrant},
  AddGrantee in 'AddGrantee.pas' {frmGranteeAdd},
  ChooseFolder in '..\Common\ChooseFolder.pas' {frmChooseFolder},
  StoredProcParamWarn in 'StoredProcParamWarn.pas' {frmParameterChange},
  ArrayDialog in 'ArrayDialog.pas' {frmArrayDialog},
  SQLAssistantDragAndDrop in 'SQLAssistantDragAndDrop.pas' {frmSQLAssistant},
  DatabaseManager in 'DatabaseManager.pas' {frmDatabaseExplorer},
  EditorSnippet in 'EditorSnippet.pas' {frmEditorSnippet},
  HelpMap in '..\Common\HelpMap.pas',
  DescribeForm in 'DescribeForm.pas' {frmDescribe},
  MarathonProjectCache in 'MarathonProjectCache.pas',
  BaseDocumentForm in 'BaseDocumentForm.pas' {frmBaseDocumentForm},
  MarathonMasterProperties in 'MarathonMasterProperties.pas' {frmMasterProperties},
  MarathonProjectCacheTypes in 'MarathonProjectCacheTypes.pas',
  MarathonIDE in 'MarathonIDE.pas',
  MarathonInternalInterfaces in 'MarathonInternalInterfaces.pas',
  GimbalToolsAPI in 'GimbalToolsAPI.pas',
  GimbalToolsAPIImpl in 'GimbalToolsAPIImpl.pas',
  BaseDocumentDataAwareForm in 'BaseDocumentDataAwareForm.pas' {frmBaseDocumentDataAwareForm},
  FrameMetadata in 'FrameMetadata.pas' {framDisplayDDL: TFrame},
  MenuModule in 'MenuModule.pas' {dmMenus: TDataModule},
  GlobalPrintingRoutines in 'GlobalPrintingRoutines.pas' {frmGlobalPrintingRoutines},
  GlobalPrintDialog in 'GlobalPrintDialog.pas' {frmGlobalPrintDialog},
  SelectConnectionDialog in 'SelectConnectionDialog.pas' {frmSelectConnection},
  GSSCreateDatabaseConsts in '..\CreateDBWizard\GSSCreateDatabaseConsts.pas',
  FrameDependencies in 'FrameDependencies.pas' {frameDepend: TFrame},
  FrameDRUIMatrix in 'FrameDRUIMatrix.pas' {frameDRUI: TFrame},
  FramePermissions in 'FramePermissions.pas' {framePerms: TFrame},
  CompileDBObject in 'CompileDBObject.pas' {frmCompileDBObject},
  PluginsDialog in 'PluginsDialog.pas' {frmPlugins},
  EditorTrigger in 'EditorTrigger.pas' {frmTriggerEditor},
  GSSRegistry in '..\Common\GSSRegistry.pas',
  IBDebuggerVM in 'IBDebuggerVM.pas',
  DebugAddBreakPoint in 'DebugAddBreakPoint.pas' {frmDebugAddBreakPoint},
  FrameDescription in 'FrameDescription.pas' {frameDesc: TFrame},
  EditorDomain in 'EditorDomain.pas' {frmDomains},
  EditorTable in 'EditorTable.pas' {frmTables},
  EditorException in 'EditorException.pas' {frmExceptions},
  gssscript_TLB in '..\MetaExtract\gssscript_TLB.pas',
  ScriptRecorder in 'ScriptRecorder.pas' {frmScriptRecorder},
  MarathonDragQueens in 'MarathonDragQueens.pas',
  ScriptExecutive in '..\Common\ScriptExecutive.pas',
  ManageBrowserItems in 'ManageBrowserItems.pas' {frmManageBrowserItems},
  PlanUnit in 'PlanUnit.pas',
  MarathonToolsAPIDocForm in 'MarathonToolsAPIDocForm.pas' {frmMarathonToolsDocForm},
  DebugBreakPoints in 'DebugBreakPoints.pas' {frmDebugBreakPoints},
  DebugCallStack in 'DebugCallStack.pas' {frmDebugCallStack},
  DebugLocalVariables in 'DebugLocalVariables.pas' {frmDebugLocals},
  Crypt32 in 'Crypt32.pas',
  QBAppendTo in 'QBAppendTo.pas' {frmAppendTo},
  QBCriteria in 'QBCriteria.pas' {frmCriteria},
  QBLnkFrm in 'QBLnkFrm.pas' {QBLinkForm},
  Tools in '..\Common\Tools.pas',
  GlobalQueriesText in 'GlobalQueriesText.pas';

{$R MarathonVersion.RES}
{$R Marathon.RES}

var
	frmSplash : TfrmSplash;
	MutexHandle : THandle;

	function OneInstanceAndRunning: Boolean;
	var
		I : TRegistry;
	begin
		result := false;
		I := TRegistry.Create;
		try
			I.RootKey := HKEY_CURRENT_USER;

			// check to see if the registry options permits multiple instances
			if not I.OpenKey(REG_SETTINGS_BASE, True) or
				(I.ValueExists('MultiInstances') and not I.ReadBool('MultiInstances')) and
				// check to see if the mutex object existed before this call
				(MutexHandle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
			begin
				// show warning and close the mutex handle
				MessageDlg('Marathon is already running', mtWarning, [mbOK], 0);
				result := true;
			end;
			I.CloseKey;
		finally
			I.Free;
		end;
	end;

begin
	MutexHandle := CreateMutex(nil, True, 'Marathon');
	// Allow just one instance of Marathon running, case desired
	if OneInstanceAndRunning then
	begin
		CloseHandle(MutexHandle);
		Halt;
	end;

	MarathonScreen := TMarathonScreen.Create;
	try
		Application.Initialize;
		Application.Title := 'Marathon - The SQL Tool for Firebird & InterBase';
		frmSplash := TfrmSplash.Create(Application);
		frmSplash.ShowModal;
		Application.CreateForm(TfrmMarathonMain, frmMarathonMain);
    if assigned(frmMarathonMain) then
    begin
        LoadFormPosition(frmMarathonMain);
        ValidateFormState(frmMarathonMain);
    end;

    Application.Run;
	finally
		MarathonScreen.Free;
		if LongBool(MutexHandle) then CloseHandle(MutexHandle);
	end;
end.
