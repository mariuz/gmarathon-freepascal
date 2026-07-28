program marathon;

{$MODE Delphi}

uses
  { First, and before anything that might start one: the SQL Trace's monitor
    runs a reader thread, and on Unix a program with no thread driver dies
    with "no thread support compiled in" the moment a thread is created -
    which is at the point the trace window is opened, not at startup. }
  {$IFDEF UNIX}cthreads,{$ENDIF}
  LCLIntf, LCLType, LMessages,
  Forms,
  SysUtils,
  Dialogs, Interfaces,
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
  SessionMonitor in 'SessionMonitor.pas' {frmSessionMonitor},
  SQLParamsDialog in 'SQLParamsDialog.pas' {frmSQLParams},
  SQLParamTypes in 'SQLParamTypes.pas',
  EditorPackage in 'EditorPackage.pas' {frmPackageEditor},
  ProfilerWindow in 'ProfilerWindow.pas' {frmProfiler},
  SystemPrivilegesWindow in 'SystemPrivilegesWindow.pas' {frmSystemPrivileges},
  MaintenanceDialog in 'MaintenanceDialog.pas' {frmMaintenance},
  MetaExtractWizard in 'MetaExtractWizard.pas' {frmMetaExtractWizard},
  SchemaCompareDialog in 'SchemaCompareDialog.pas' {frmSchemaCompare},
  TableDesignerForm in 'TableDesignerForm.pas' {frmTableDesigner},
  PrintRenderer in 'PrintRenderer.pas',
  QueryBuilderForm in 'QueryBuilderForm.pas' {frmQueryBuilder},
  KeyBindingEditor in 'KeyBindingEditor.pas' {frmKeyBindings},
  SchemaDiagramForm in 'SchemaDiagramForm.pas' {frmSchemaDiagram},
  CreateDatabaseDialog in 'CreateDatabaseDialog.pas' {frmCreateDatabase},
  CommandPaletteDialog in 'CommandPaletteDialog.pas' {frmCommandPalette},
  SaveFileFormat in 'SaveFileFormat.pas' {frmSaveFileFormat},
  WindowList in 'WindowList.pas' {frmWindowList},
  UDFInputParam in 'UDFInputParam.pas' {frmUDFAddInput},
  UserEditor in 'UserEditor.pas' {frmUsers},
  ScriptEditorHost in 'ScriptEditorHost.pas' {frmScriptEditorHost},
  EditorColumn in 'EditorColumn.pas' {frmColumns},
  EditorConstraint in 'EditorConstraint.pas' {frmEditorConstraint},
  EditorIndex in 'EditorIndex.pas' {frmEditorIndex},
  BlobViewer in 'BlobViewer.pas' {frmBlobViewer},
  SyntaxHelp in 'SyntaxHelp.pas' {frmSyntaxHelp},
  CodeSnippets in 'CodeSnippets.pas' {frmCodeSnippets},
  SQLTrace in 'SQLTrace.pas' {frmSQLTrace},
  SQLInsightItem in 'SQLInsightItem.pas' {frmSQLInsight},
  {$IFDEF WINDOWS}ShlObj,{$ENDIF}
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
{$R marathon.res}

type
	{ Prints a Pascal backtrace for any exception the LCL would otherwise only
	  show in a message box.

	  This exists because gdb cannot produce one: the FPC RTL is compiled
	  without frame pointers, so a backtrace taken inside, say, TFPList.Error
	  unwinds to "#2 0x0" and the actual caller is lost. FPC's own
	  DumpExceptionBackTrace uses the DWARF line info instead and gets the whole
	  chain with unit names and line numbers.

	  Off unless MARATHON_TRACE_EXCEPTIONS is set in the environment, so it
	  costs a normal run nothing and cannot change what the user sees - the
	  handler re-shows the dialog itself. }
	TExceptionTracer = class
		procedure HandleException(Sender: TObject; E: Exception);
	end;

procedure TExceptionTracer.HandleException(Sender: TObject; E: Exception);
begin
	WriteLn(StdErr);
	WriteLn(StdErr, '=== ', E.ClassName, ': ', E.Message);
	DumpExceptionBackTrace(StdErr);
	Flush(StdErr);
	Application.ShowException(E);
end;

var
	frmSplash : TfrmSplash;
	Tracer : TExceptionTracer;
begin
	MarathonScreen := TMarathonScreen.Create;
	try
		{ Without this the whole interface renders at 96 DPI regardless of the
		  display, which on a 4K screen means controls and text at a quarter of
		  their intended size. Every .lfm was carrying Delphi's Scaled = False,
		  which switches LCL's scaling off form by form; those now say True, and
		  this turns it on for the application. On a 96 DPI display the factor is
		  1.0 and nothing moves. }
		Application.Scaled := True;
		Application.Initialize;
		Application.Title := 'Marathon - The SQL Tool for Firebird ';
		Tracer := nil;
		if GetEnvironmentVariable('MARATHON_TRACE_EXCEPTIONS') <> '' then
		begin
			Tracer := TExceptionTracer.Create;
			Application.OnException := Tracer.HandleException;
		end;
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
		Tracer.Free;
		MarathonScreen.Free;
		// The single-instance mutex this used to release was dropped during the
		// port: nothing in the tree creates a mutex any more, and MutexHandle
		// is not declared anywhere, so this cleanup was dead code that only
		// ever compiled because no Windows build was attempted.
	end;
end.
