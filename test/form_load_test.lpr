program form_load_test;

{ Constructs the forms this port has changed and checks their .lfm actually
  loads and the new controls are wired up.

  This catches what compiling cannot: an .lfm naming a property or class that
  does not exist, a control declared in the .pas but missing from the .lfm (or
  the reverse), an action referenced by a menu item that was never declared,
  and an event handler that was never hooked up. All of that fails at
  streaming time - the first time the form is created.

  Needs a real widgetset, so unlike keyword_test this one cannot use nogui
  (which cannot construct a form at all). It needs no visible screen though:
    lazbuild test/form_load_test.lpi
    xvfb-run -a ./test/form_load_test
  which is how CI runs it. No database connection is made. }

{$MODE Delphi}

uses
  Interfaces, SysUtils, Classes, Forms, Controls, ComCtrls, ExtCtrls, StdCtrls,
  ActnList, Menus, DB, DBGrids, Registry, Graphics,
  GSSRegistry, Globals, MarathonProjectCacheTypes, MarathonProjectCache, SQLParamsDialog,
  MarathonIDE, MenuModule, MarathonMain,
  AboutBox, AddGrantee, AddWatch, ArrayDialog,
  BaseDocumentForm, BlobViewer, CodeSnippets, CompileDBObject,
  DatabaseManager, DebugAddBreakPoint, DebugBreakPoints, DebugCallStack,
  DebugEvalModify, DebugLocalVariables, DebugWatches, DescribeForm,
  DropObject, EditorColumn, EditorConstraint, EditorDomain,
  EditorException, EditorGenerator, EditorGrant, EditorIndex,
  EditorSnippet, EditorStoredProcedure, EditorTable, EditorTrigger,
  EditorUDF, EditorView, GlobalPrintDialog, GlobalPrintingRoutines,
  InputDialog, Login, MaintenanceDialog, ManageBrowserItems,
  MarathonMasterProperties, MarathonOptions, MarathonToolsAPIDocForm, MetaExtractWizard,
  NewObjectDialog, NewTrigger, PluginsDialog, PrintPreviewForm,
  QBAppendTo, QBCriteria, QBLnkFrm, ReorderColumns,
  SQLAssistantDragAndDrop, SQLForm, SQLInsightItem, SQLTrace,
  SaveFileFormat, ScriptEditorHost, ScriptRecorder, SecureDBLogin,
  SelectConnectionDialog, SessionMonitor, SplashForm, StatementHistory,
  StoredProcParamWarn, StoredProcedureParams, SyntaxHelp, TipOfTheDay,
  UDFInputParam, UserEditor, WindowList;

var
  Failures: Integer = 0;

procedure Check(Condition: Boolean; const What: String);
begin
  if Condition then
    WriteLn('  ok   ', What)
  else
  begin
    WriteLn('  FAIL ', What);
    Inc(Failures);
  end;
  Flush(Output);
end;

function FindPage(PC: TPageControl; const Caption: String): TTabSheet;
var
  Idx: Integer;
begin
  Result := nil;
  for Idx := 0 to PC.PageCount - 1 do
    if PC.Pages[Idx].Caption = Caption then
    begin
      Result := PC.Pages[Idx];
      Exit;
    end;
end;

{ Session Monitor - the Compiled Statements tab added for MON$COMPILED_STATEMENTS. }
procedure CheckSessionMonitor;
var
  F: TfrmSessionMonitor;
begin
  WriteLn('TfrmSessionMonitor:');
  try
    F := TfrmSessionMonitor.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'creating the form raised ' + E.ClassName + ': ' + E.Message);
      Exit;
    end;
  end;
  try
    Check(F.pgMonitor.PageCount = 4, 'has four tabs');
    Check(FindPage(F.pgMonitor, 'Attachments') <> nil, 'Attachments tab present');
    Check(FindPage(F.pgMonitor, 'Statements') <> nil, 'Statements tab present');
    Check(FindPage(F.pgMonitor, 'Transactions') <> nil, 'Transactions tab present');
    Check(FindPage(F.pgMonitor, 'Compiled Statements') <> nil, 'Compiled Statements tab present');

    Check(Assigned(F.grdCompiled), 'grdCompiled exists');
    Check(Assigned(F.memCompiled), 'memCompiled exists');
    Check(Assigned(F.splCompiled), 'splCompiled exists');
    Check(Assigned(F.dsCompiled), 'dsCompiled exists');
    Check(Assigned(F.qryCompiled), 'qryCompiled exists');
    Check(F.grdCompiled.DataSource = F.dsCompiled, 'grid is bound to dsCompiled');
    Check(F.dsCompiled.DataSet = F.qryCompiled, 'dsCompiled is bound to qryCompiled');
    Check(Assigned(F.dsCompiled.OnDataChange), 'dsCompiled.OnDataChange is hooked up');
    Check(F.memCompiled.ReadOnly, 'the detail pane is read-only');

    { Layout: the grid fills the tab with the detail pane docked below it, or
      the splitter has nothing to split. }
    Check(F.grdCompiled.Align = alClient, 'grid fills the tab');
    Check(F.pnlCompiledDetail.Align = alBottom, 'detail pane is docked at the bottom');
    Check(F.splCompiled.Align = alBottom, 'splitter is docked at the bottom');
    Check(F.grdCompiled.Parent = F.pnlCompiledDetail.Parent, 'grid and detail pane share a parent');
    Check(F.grdCompiled.Parent = FindPage(F.pgMonitor, 'Compiled Statements'),
      'they live on the Compiled Statements tab');
  finally
    F.Free;
  end;
end;

{ The "Script As" actions and their menu items. MenuModule.lfm references these
  by name on frmMarathonMain, so a missing action fails when the menu streams. }
procedure CheckScriptAsWiring;
var
  Idx: Integer;
  A: TAction;

  function FindAction(const Name: String): TAction;
  var
    J: Integer;
  begin
    Result := nil;
    for J := 0 to frmMarathonMain.ComponentCount - 1 do
      if (frmMarathonMain.Components[J] is TAction) and
         SameText(frmMarathonMain.Components[J].Name, Name) then
      begin
        Result := TAction(frmMarathonMain.Components[J]);
        Exit;
      end;
  end;

  function FindMenuItem(const Name: String): TMenuItem;
  var
    J: Integer;
  begin
    Result := nil;
    for J := 0 to dmMenus.ComponentCount - 1 do
      if (dmMenus.Components[J] is TMenuItem) and
         SameText(dmMenus.Components[J].Name, Name) then
      begin
        Result := TMenuItem(dmMenus.Components[J]);
        Exit;
      end;
  end;

const
  NewActions: array[0..2] of String = ('ObjectScriptAlter', 'ObjectScriptDrop', 'ObjectScriptMerge');
var
  MI: TMenuItem;
begin
  WriteLn('Script As actions and menu items:');
  for Idx := Low(NewActions) to High(NewActions) do
  begin
    A := FindAction(NewActions[Idx]);
    Check(Assigned(A), NewActions[Idx] + ' action exists on frmMarathonMain');
    if Assigned(A) then
    begin
      Check(A.Caption <> '', NewActions[Idx] + ' has a caption (' + A.Caption + ')');
      Check(Assigned(A.OnExecute), NewActions[Idx] + '.OnExecute is hooked up');
      Check(Assigned(A.OnUpdate), NewActions[Idx] + '.OnUpdate is hooked up');
    end;

    MI := FindMenuItem(NewActions[Idx] + '1');
    Check(Assigned(MI), NewActions[Idx] + '1 menu item exists in dmMenus');
    if Assigned(MI) and Assigned(A) then
      Check(MI.Action = A, NewActions[Idx] + '1 is bound to its action');
  end;
end;

{ The SQL editor - no .lfm change, but it gained the singleton-result rebinding
  and the EXPLAIN path, so it is worth proving it still streams. }
procedure CheckSQLForm;
var
  F: TfrmSQLForm;
begin
  WriteLn('TfrmSQLForm:');
  try
    F := TfrmSQLForm.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'creating the form raised ' + E.ClassName + ': ' + E.Message);
      Exit;
    end;
  end;
  try
    Check(Assigned(F.qrySQLStatement), 'qrySQLStatement exists');
    Check(Assigned(F.dsSQLStatement), 'dsSQLStatement exists');
    Check(F.dsSQLStatement.DataSet = F.qrySQLStatement,
      'the results grid starts bound to qrySQLStatement');
    Check(Assigned(F.grdSQLStatement), 'results grid exists');
    Check(F.grdSQLStatement.DataSource = F.dsSQLStatement, 'grid is bound via dsSQLStatement');
    Check(Assigned(F.edPlan), 'the Plan tab memo exists (EXPLAIN writes to it)');
    Check(Assigned(F.tsPlan), 'the Plan tab exists');

    { The connection strip: which connection this editor runs against, and the
      environment colouring. }
    Check(Assigned(F.pnlEnvironment), 'the connection strip exists');
    Check(F.pnlEnvironment.Align = alTop, 'the strip sits at the top of the window');
    Check(Assigned(F.cmbConnection), 'the connection switcher exists');
    Check(F.cmbConnection.Style = csDropDownList,
      'the switcher only offers connections that exist');
    Check(Assigned(F.cmbConnection.OnChange), 'switching connection is hooked up');
    Check(Assigned(F.cmbConnection.OnDropDown),
      'the list refreshes on drop-down, so connections added since do appear');
    Check(F.cmbConnection.Parent = F.pnlEnvironment, 'the switcher lives on the strip');
    Check(Assigned(F.lblEnvironmentName), 'the environment label exists');
    Check(F.lblEnvironmentName.Caption = '',
      'no environment is named for an editor with no connection');
    { With no connection the strip must look like ordinary chrome. }
    Check(F.pnlEnvironment.Color = EnvironmentColor(envUnset),
      'the strip is the default colour with no connection');
  finally
    F.Free;
  end;
end;

{ The main form shows a modal Tip of the Day on create when ShowTips is set,
  and ShowTips defaults to True on a machine that has never run Marathon -
  which would hang this test forever with nobody to dismiss it. Turn it off
  before the form is built. Run the test with an isolated HOME (see the
  workflow) so this cannot disturb a real installation's settings. }
procedure SuppressStartupDialogs;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(REG_SETTINGS_BASE, True) then
    begin
      R.WriteBool('ShowTips', False);
      R.WriteBool('OpenLastProject', False);
      R.WriteBool('OpenProjectOnStartup', False);
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

{ Constructs one form and reports whether its .lfm streamed. Every form in the
  application gets this, because the failure mode being guarded against - an
  .lfm still setting a property that the FPC/Lazarus replacement class does not
  have - takes the entire form down and is invisible until someone opens it. }
procedure TryConstruct(FormClass: TComponentClass; const Name: String);
var
  C: TComponent;
begin
  Write('  .... ', Name); Flush(Output);
  try
    C := FormClass.Create(nil);
    try
      WriteLn(#13'       ');
      Check(True, Name + ' constructs');
    finally
      C.Free;
    end;
  except
    { Only streaming failures are this test's business. EReadError means the
      .lfm sets a property the class does not have, EClassNotFound that it
      names a class nothing registered - both mean the form cannot open at
      all. Anything else (typically a form whose OnCreate wants a live
      database) streamed fine, which is what is being checked here. }
    on E: EReadError do
    begin
      WriteLn;
      Check(False, Name + ' raised ' + E.ClassName + ': ' + E.Message);
    end;
    on E: EClassNotFound do
    begin
      WriteLn;
      Check(False, Name + ' raised ' + E.ClassName + ': ' + E.Message);
    end;
    on E: Exception do
    begin
      WriteLn;
      Check(True, Name + ' streams (OnCreate needs a connection: ' + E.ClassName + ')');
    end;
  end;
end;

{ The environment colours are the whole point of the feature: they have to be
  distinct from each other and readable, and "not set" has to stay the plain
  system colour so that anyone not using the feature sees no change. }
procedure CheckEnvironmentColours;
var
  Env: TConnectionEnvironment;
  Seen: array[TConnectionEnvironment] of TColor;
  A, B: TConnectionEnvironment;
begin
  WriteLn('Environment colour coding:');
  Check(EnvironmentColor(envUnset) = clBtnFace, 'unset uses the default window colour');
  Check(EnvironmentTextColor(envUnset) = clWindowText, 'unset uses the default text colour');
  Check(EnvironmentDisplayName(envUnset) = '', 'unset has no label');
  for Env := Low(TConnectionEnvironment) to High(TConnectionEnvironment) do
  begin
    Seen[Env] := EnvironmentColor(Env);
    if Env <> envUnset then
    begin
      Check(EnvironmentDisplayName(Env) <> '', EnvironmentDisplayName(Env) + ' has a label');
      Check(Seen[Env] <> clBtnFace,
        EnvironmentDisplayName(Env) + ' has a colour of its own');
    end;
  end;
  for A := Low(TConnectionEnvironment) to High(TConnectionEnvironment) do
    for B := Succ(A) to High(TConnectionEnvironment) do
      if A <> B then
        Check(Seen[A] <> Seen[B],
          'colours differ: ' + IntToStr(Ord(A)) + ' vs ' + IntToStr(Ord(B)));
end;

{ The load side of environment persistence, which is the half that can quietly
  lose the setting. Two cases matter: a project that names an environment, and
  one written before the feature existed, which must come back as "not set"
  rather than as whatever enum value happens to sit at ordinal zero of some
  garbage read. }
procedure CheckEnvironmentPersistence;

  function WriteProject(const EnvAttr: String): String;
  var
    L: TStringList;
  begin
    Result := GetTempDir + 'marathon_env_test.xmpr';
    L := TStringList.Create;
    try
      L.Add('<?xml version="1.0" encoding="utf-8"?>');
      L.Add('<marathon-project>');
      L.Add('  <project name="EnvTest" encoding="1" showsystem="0" resultpanelheight="0"' +
            ' viewsystemdomains="0" viewsystemtriggers="0" savewindowpositions="1">');
      L.Add('    <connections>');
      L.Add('      <connection name="EnvRoundTrip" databasefilename="/tmp/nowhere.fdb"' +
            ' servername="" username="SYSDBA" rememberpassword="0" charset=""' +
            ' sqlrole="" sqldialect="3"' + EnvAttr + '/>');
      L.Add('    </connections>');
      L.Add('    <servers/><windows/><recentitems/><sqlhistory/><custom-properties/>');
      L.Add('  </project>');
      L.Add('</marathon-project>');
      L.SaveToFile(Result);
    finally
      L.Free;
    end;
  end;

  function LoadAndFindEnvironment(const FileName: String;
    out Env: TConnectionEnvironment): Boolean;
  var
    Idx: Integer;
  begin
    Result := False;
    Env := envUnset;
    MarathonIDEInstance.CurrentProject.LoadFromFile(FileName);
    for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
      if MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption = 'EnvRoundTrip' then
      begin
        Env := MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Environment;
        Result := True;
      end;
  end;

var
  FileName, SavedName: String;
  Env: TConnectionEnvironment;
  Written: TStringList;
begin
  WriteLn('Environment persistence:');

  FileName := WriteProject(' environment="envProduction"');
  Check(LoadAndFindEnvironment(FileName, Env), 'a project with an environment loads');
  Check(Env = envProduction, 'the environment is read back as Production');

  { And writing it back out must carry the environment with it. }
  SavedName := GetTempDir + 'marathon_env_saved.xmpr';
  MarathonIDEInstance.CurrentProject.SaveToFile(SavedName);
  Written := TStringList.Create;
  try
    Written.LoadFromFile(SavedName);
    Check(Pos('environment="envProduction"', Written.Text) > 0,
      'saving writes the environment back out');
  finally
    Written.Free;
  end;
  DeleteFile(SavedName);

  { A project saved by any earlier build has no environment attribute at all. }
  FileName := WriteProject('');
  Check(LoadAndFindEnvironment(FileName, Env), 'a project without the attribute still loads');
  Check(Env = envUnset, 'a missing environment reads back as unset');

  DeleteFile(FileName);
end;

{ The connection switcher, driven the way the user drives it. Needs a project
  with more than one connection, so it builds one and loads it - no server is
  contacted, since pointing an editor at a connection does not open it. }
procedure CheckConnectionSwitcher;
var
  FileName: String;
  L: TStringList;
  F: TfrmSQLForm;
begin
  WriteLn('Connection switcher:');
  FileName := GetTempDir + 'marathon_switch_test.xmpr';
  L := TStringList.Create;
  try
    L.Add('<?xml version="1.0" encoding="utf-8"?>');
    L.Add('<marathon-project>');
    L.Add('  <project name="SwitchTest" encoding="1" showsystem="0" resultpanelheight="0"' +
          ' viewsystemdomains="0" viewsystemtriggers="0" savewindowpositions="1">');
    L.Add('    <connections>');
    L.Add('      <connection name="DevBox" databasefilename="/tmp/dev.fdb" servername=""' +
          ' username="SYSDBA" rememberpassword="0" charset="" sqlrole="" sqldialect="3"' +
          ' environment="envDevelopment"/>');
    L.Add('      <connection name="LiveBox" databasefilename="/tmp/live.fdb" servername=""' +
          ' username="SYSDBA" rememberpassword="0" charset="" sqlrole="" sqldialect="3"' +
          ' environment="envProduction"/>');
    L.Add('    </connections>');
    L.Add('    <servers/><windows/><recentitems/><sqlhistory/><custom-properties/>');
    L.Add('  </project>');
    L.Add('</marathon-project>');
    L.SaveToFile(FileName);
  finally
    L.Free;
  end;
  MarathonIDEInstance.CurrentProject.LoadFromFile(FileName);

  F := TfrmSQLForm.Create(nil);
  try
    { Assigning the property is all it takes - the strip is driven from the
      setter, not from any one caller. }
    F.ConnectionName := 'DevBox';
    Check(F.cmbConnection.Items.IndexOf('DevBox') >= 0, 'the switcher lists DevBox');
    Check(F.cmbConnection.Items.IndexOf('LiveBox') >= 0, 'the switcher lists LiveBox');
    Check(F.cmbConnection.Text = 'DevBox', 'the switcher shows the current connection');
    Check(F.pnlEnvironment.Color = EnvironmentColor(envDevelopment),
      'the strip takes the development colour');
    Check(F.lblEnvironmentName.Caption = 'DEVELOPMENT', 'the strip names the environment');

    { Now switch, exactly as picking from the dropdown does. Nothing is in
      flight, so no commit prompt can appear. }
    F.cmbConnection.ItemIndex := F.cmbConnection.Items.IndexOf('LiveBox');
    F.cmbConnectionChange(F.cmbConnection);
    Check(F.ConnectionName = 'LiveBox', 'the editor is repointed at LiveBox');
    Check(F.pnlEnvironment.Color = EnvironmentColor(envProduction),
      'the strip turns the production colour');
    Check(F.lblEnvironmentName.Caption = 'PRODUCTION', 'the strip names the new environment');
    Check(F.cmbConnection.Text = 'LiveBox', 'the switcher still shows the current connection');
  finally
    F.Free;
  end;
  DeleteFile(FileName);
end;

{ The statement-parameter dialog. It is deliberately free of any IBX types -
  it deals in names and strings and the caller does the binding - which is what
  makes it checkable here without a database. }
procedure CheckParameterDialog;
var
  Dlg: TfrmSQLParams;
  Names: TStringList;
begin
  WriteLn('Statement parameter dialog:');
  Names := TStringList.Create;
  Dlg := TfrmSQLParams.Create(nil);
  try
    Names.Add('ID');
    Names.Add('NOTE');
    Dlg.SetParameters(Names);
    Check(Dlg.ParameterCount = 2, 'one row per parameter');
    Check(Dlg.grdParams.Cells[colParamName, 1] = 'ID', 'first parameter is named');
    Check(Dlg.grdParams.Cells[colParamName, 2] = 'NOTE', 'second parameter is named');

    { The default must be an empty value that is NOT null: a user who just
      presses OK should get empty strings, not the silent NULLs this dialog
      exists to prevent. }
    Check(not Dlg.IsNullAt(0), 'parameters do not start as NULL');
    Check(Dlg.ValueOf(0) = '', 'parameters start empty');

    Dlg.SetValue(0, '42', False);
    Dlg.SetValue(1, '', True);
    Check(Dlg.ValueOf(0) = '42', 'a typed value reads back');
    Check(not Dlg.IsNullAt(0), 'a typed value is not NULL');
    Check(Dlg.IsNullAt(1), 'a ticked NULL reads back as NULL');

    { Re-filling must not leave the previous run's values behind. }
    Dlg.SetParameters(Names);
    Check(Dlg.ValueOf(0) = '', 'values are cleared when the dialog is reused');
    Check(not Dlg.IsNullAt(1), 'NULL flags are cleared when the dialog is reused');

    Names.Add('EXTRA');
    Dlg.SetParameters(Names);
    Check(Dlg.ParameterCount = 3, 'the grid grows with the parameter list');
    Names.Clear;
    Dlg.SetParameters(Names);
    Check(Dlg.ParameterCount = 0, 'a statement with no parameters shows no rows');
  finally
    Dlg.Free;
    Names.Free;
  end;
end;

{ Some forms read a data file from the executable's directory on create and
  pop a modal error dialog when it is missing - which would hang this test with
  nobody to dismiss it. Give them empty files to find. }
procedure ProvideDataFiles;
const
  Names: array[0..1] of String = ('sqlref.dta', 'fnref.dta');
var
  Idx: Integer;
  F: TFileStream;
begin
  for Idx := Low(Names) to High(Names) do
    if not FileExists(ExtractFilePath(ParamStr(0)) + Names[Idx]) then
    begin
      F := TFileStream.Create(ExtractFilePath(ParamStr(0)) + Names[Idx], fmCreate);
      F.Free;
    end;
end;

procedure CheckEveryFormConstructs;
begin
  ProvideDataFiles;
  WriteLn('Every form in the application:');
  TryConstruct(TfrmAboutBox, 'TfrmAboutBox');
  TryConstruct(TfrmGranteeAdd, 'TfrmGranteeAdd');
  TryConstruct(TfrmAddWatch, 'TfrmAddWatch');
  TryConstruct(TfrmArrayDialog, 'TfrmArrayDialog');
  TryConstruct(TfrmBaseDocumentForm, 'TfrmBaseDocumentForm');
  TryConstruct(TfrmBlobViewer, 'TfrmBlobViewer');
  TryConstruct(TfrmCodeSnippets, 'TfrmCodeSnippets');
  TryConstruct(TfrmCompileDBObject, 'TfrmCompileDBObject');
  TryConstruct(TfrmDatabaseExplorer, 'TfrmDatabaseExplorer');
  TryConstruct(TfrmDebugAddBreakPoint, 'TfrmDebugAddBreakPoint');
  TryConstruct(TfrmDebugBreakPoints, 'TfrmDebugBreakPoints');
  TryConstruct(TfrmDebugCallStack, 'TfrmDebugCallStack');
  TryConstruct(TfrmGetSetVariable, 'TfrmGetSetVariable');
  TryConstruct(TfrmDebugLocals, 'TfrmDebugLocals');
  TryConstruct(TfrmWatches, 'TfrmWatches');
  TryConstruct(TfrmDescribe, 'TfrmDescribe');
  TryConstruct(TfrmDropObject, 'TfrmDropObject');
  TryConstruct(TfrmColumns, 'TfrmColumns');
  TryConstruct(TfrmEditorConstraint, 'TfrmEditorConstraint');
  TryConstruct(TfrmDomains, 'TfrmDomains');
  TryConstruct(TfrmExceptions, 'TfrmExceptions');
  TryConstruct(TfrmGenerators, 'TfrmGenerators');
  TryConstruct(TfrmEditorGrant, 'TfrmEditorGrant');
  TryConstruct(TfrmEditorIndex, 'TfrmEditorIndex');
  TryConstruct(TfrmEditorSnippet, 'TfrmEditorSnippet');
  TryConstruct(TfrmStoredProcedure, 'TfrmStoredProcedure');
  TryConstruct(TfrmTables, 'TfrmTables');
  TryConstruct(TfrmTriggerEditor, 'TfrmTriggerEditor');
  TryConstruct(TfrmUDFEditor, 'TfrmUDFEditor');
  TryConstruct(TfrmViewEditor, 'TfrmViewEditor');
  TryConstruct(TfrmGlobalPrintDialog, 'TfrmGlobalPrintDialog');
  TryConstruct(TfrmGlobalPrintingRoutines, 'TfrmGlobalPrintingRoutines');
  TryConstruct(TfrmInputDialog, 'TfrmInputDialog');
  TryConstruct(TfrmConnect, 'TfrmConnect');
  TryConstruct(TfrmMaintenance, 'TfrmMaintenance');
  TryConstruct(TfrmManageBrowserItems, 'TfrmManageBrowserItems');
  TryConstruct(TfrmMasterProperties, 'TfrmMasterProperties');
  TryConstruct(TfrmMarathonOptions, 'TfrmMarathonOptions');
  TryConstruct(TfrmMarathonToolsDocForm, 'TfrmMarathonToolsDocForm');
  TryConstruct(TfrmMetaExtractWizard, 'TfrmMetaExtractWizard');
  TryConstruct(TfrmNewObject, 'TfrmNewObject');
  TryConstruct(TfrmNewTrigger, 'TfrmNewTrigger');
  TryConstruct(TfrmPlugins, 'TfrmPlugins');
  TryConstruct(TfrmPrintPreview, 'TfrmPrintPreview');
  TryConstruct(TfrmAppendTo, 'TfrmAppendTo');
  TryConstruct(TfrmCriteria, 'TfrmCriteria');
  TryConstruct(TQBLinkForm, 'TQBLinkForm');
  TryConstruct(TfrmReorderColumns, 'TfrmReorderColumns');
  TryConstruct(TfrmSQLAssistant, 'TfrmSQLAssistant');
  TryConstruct(TfrmSQLForm, 'TfrmSQLForm');
  TryConstruct(TfrmSQLInsight, 'TfrmSQLInsight');
  TryConstruct(TfrmSQLTrace, 'TfrmSQLTrace');
  TryConstruct(TfrmSaveFileFormat, 'TfrmSaveFileFormat');
  TryConstruct(TfrmScriptEditorHost, 'TfrmScriptEditorHost');
  TryConstruct(TfrmScriptRecorder, 'TfrmScriptRecorder');
  TryConstruct(TfrmSecureConnect, 'TfrmSecureConnect');
  TryConstruct(TfrmSelectConnection, 'TfrmSelectConnection');
  TryConstruct(TfrmSessionMonitor, 'TfrmSessionMonitor');
  TryConstruct(TfrmSplash, 'TfrmSplash');
  TryConstruct(TfrmStatementHistory, 'TfrmStatementHistory');
  TryConstruct(TfrmParameterChange, 'TfrmParameterChange');
  TryConstruct(TfrmStoredProcParameters, 'TfrmStoredProcParameters');
  TryConstruct(TfrmSyntaxHelp, 'TfrmSyntaxHelp');
  TryConstruct(TfrmTipOfTheDay, 'TfrmTipOfTheDay');
  TryConstruct(TfrmUDFAddInput, 'TfrmUDFAddInput');
  { TfrmUsers is deliberately not constructed: its OnCreate loops until it
    can log in to the security database, prompting modally each time round,
    and it is only reachable on Windows anyway. }
  TryConstruct(TfrmWindowList, 'TfrmWindowList');
end;

begin
  Application.Initialize;
  WriteLn('-- Application.Initialize done'); Flush(Output);
  SuppressStartupDialogs;
  { MenuModule and the main form come first: other forms and the menu .lfm
    reference them by name. }
  Application.CreateForm(TdmMenus, dmMenus);
  WriteLn('-- dmMenus created'); Flush(Output);
  Application.CreateForm(TfrmMarathonMain, frmMarathonMain);
  WriteLn('-- frmMarathonMain created'); Flush(Output);

  CheckSessionMonitor;
  CheckScriptAsWiring;
  CheckSQLForm;
  CheckEveryFormConstructs;
  CheckEnvironmentColours;
  CheckEnvironmentPersistence;
  CheckConnectionSwitcher;
  CheckParameterDialog;

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' form check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: forms load and the expected controls are wired up.');
end.
