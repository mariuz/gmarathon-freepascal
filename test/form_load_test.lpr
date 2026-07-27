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
  ActnList, Menus, DB, DBGrids, Registry, Graphics, ImgList, IBCustomDataSet,
  GSSRegistry, Globals, MarathonProjectCacheTypes, MarathonProjectCache, SQLParamsDialog, SQLParamTypes, IB, Crypt32, SyntaxMemoWithStuff2, SynCompletion,
  EditorPackage, ProfilerWindow, Spin,
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
  SchemaCompareDialog, CreateDatabaseDialog,
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

    { Per-type checking. The dialog must reject what the database is certain to
      refuse, and must not block anything it cannot judge. }
    Names.Clear;
    Names.Add('N_INT');
    Names.Add('N_DEC');
    Names.Add('N_DATE');
    Names.Add('N_BOOL');
    Names.Add('N_TEXT');
    Dlg.SetParameters(Names, [pkInteger, pkDecimal, pkDate, pkBoolean, pkText], nil);
    Check(Dlg.KindOf(0) = pkInteger, 'the integer parameter keeps its kind');
    Check(Dlg.KindOf(4) = pkText, 'the text parameter keeps its kind');
    Check(Dlg.KindOf(99) = pkText, 'an out-of-range index is treated as text');

    Dlg.SetValue(0, '12', False);
    Check(Dlg.AcceptsValues, 'a whole number is accepted for an integer');
    Dlg.SetValue(0, 'twelve', False);
    Check(not Dlg.AcceptsValues, 'a word is rejected for an integer');
    Dlg.SetValue(0, '12.5', False);
    Check(not Dlg.AcceptsValues, 'a decimal is rejected for an integer');

    { NULL wins over whatever is in the value cell - a ticked row is not
      validated at all. }
    Dlg.SetValue(0, 'nonsense', True);
    Check(Dlg.AcceptsValues, 'a ticked NULL is not validated');

    Dlg.SetValue(0, '', False);
    Check(Dlg.AcceptsValues, 'an empty value is left for the database to judge');

    Dlg.SetValue(1, '12.5', False);
    Check(Dlg.AcceptsValues, 'a decimal is accepted for a decimal');
    Dlg.SetValue(1, 'x', False);
    Check(not Dlg.AcceptsValues, 'a word is rejected for a decimal');
    Dlg.SetValue(1, '', False);

    Dlg.SetValue(3, 'true', False);
    Check(Dlg.AcceptsValues, 'true is accepted for a boolean');
    Dlg.SetValue(3, '0', False);
    Check(Dlg.AcceptsValues, '0 is accepted for a boolean');
    Dlg.SetValue(3, 'maybe', False);
    Check(not Dlg.AcceptsValues, 'maybe is rejected for a boolean');
    Dlg.SetValue(3, '', False);

    { Free text must never be rejected, whatever it contains. }
    Dlg.SetValue(4, 'anything at all !@#', False);
    Check(Dlg.AcceptsValues, 'free text is never rejected');

    Names.Clear;
    Names.Add('ID');
    Names.Add('NOTE');
    Dlg.SetParameters(Names);
    Check(Dlg.KindOf(0) = pkText, 'without kinds every parameter is free text');

    { The map from Firebird's type codes. The scale rule is the interesting
      one: the same SQL_INT64 is a whole number at scale 0 and a decimal below
      it, which is how NUMERIC(10,2) arrives. }
    Check(SQLParamKindOf(SQL_SHORT, 0) = pkInteger, 'SQL_SHORT is a whole number');
    Check(SQLParamKindOf(SQL_LONG, 0) = pkInteger, 'SQL_LONG is a whole number');
    Check(SQLParamKindOf(SQL_INT64, 0) = pkInteger, 'SQL_INT64 at scale 0 is a whole number');
    Check(SQLParamKindOf(SQL_INT64, -2) = pkDecimal, 'SQL_INT64 at scale -2 is a decimal');
    Check(SQLParamKindOf(SQL_SHORT, -1) = pkDecimal, 'a scaled SQL_SHORT is a decimal');
    Check(SQLParamKindOf(SQL_DOUBLE, 0) = pkDecimal, 'SQL_DOUBLE is a decimal');
    Check(SQLParamKindOf(SQL_FLOAT, 0) = pkDecimal, 'SQL_FLOAT is a decimal');
    Check(SQLParamKindOf(SQL_TYPE_DATE, 0) = pkDate, 'SQL_TYPE_DATE is a date');
    Check(SQLParamKindOf(SQL_TYPE_TIME, 0) = pkTime, 'SQL_TYPE_TIME is a time');
    Check(SQLParamKindOf(SQL_TIMESTAMP, 0) = pkDateTime, 'SQL_TIMESTAMP is a date and time');
    Check(SQLParamKindOf(SQL_BOOLEAN, 0) = pkBoolean, 'SQL_BOOLEAN is a boolean');
    Check(SQLParamKindOf(SQL_VARYING, 0) = pkText, 'SQL_VARYING is free text');
    Check(SQLParamKindOf(SQL_TEXT, 0) = pkText, 'SQL_TEXT is free text');
    Check(SQLParamKindOf(SQL_BLOB, 0) = pkText, 'anything unrecognised is free text');

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

{ The package viewer, and what the tree node offers for a package. Packages are
  read-only, so the node must not advertise operations that have no handler. }
procedure CheckPackageEditor;
var
  F: TfrmPackageEditor;
  Node: TMarathonCachePackage;
begin
  WriteLn('Package viewer:');
  F := TfrmPackageEditor.Create(nil);
  try
    Check(F.pgObjectEditor.PageCount = 3, 'has Header, Body and DDL tabs');
    Check(F.tsHeader.Caption = 'Header', 'header tab');
    Check(F.tsBody.Caption = 'Body', 'body tab');
    Check(F.tsDDL.Caption = 'DDL', 'DDL tab');
    { Header and body are separate because a package may have a header and no
      body; both are read-only because a package is edited as a whole. }
    Check(F.edHeader.ReadOnly, 'the header view is read-only');
    Check(F.edBody.ReadOnly, 'the body view is read-only');
    Check(Assigned(F.framDDL), 'the DDL frame is present');
    Check(F.GetActiveObjectType = ctPackage, 'the form identifies as a package');
  finally
    F.Free;
  end;

  Node := TMarathonCachePackage.Create;
  try
    Check(Node.CanDoOperation(opOpen, False), 'a package node can be opened');
    Check(Node.CanDoOperation(opScriptCreate, False), 'a package node can be scripted');
    Check(Node.CanDoOperation(opExtractDDL, False), 'a package node can be extracted');
    { The drop dialog does know how to drop a package, so this one is offered. }
    Check(Node.CanDoOperation(opDrop, False), 'a package node can be dropped');
    { These three have no ctPackage branch in the dispatch - offering them would
      be a menu item that does nothing at all. }
    Check(not Node.CanDoOperation(opNew, False), 'a package node does not offer New');
    Check(not Node.CanDoOperation(opPrint, False), 'a package node does not offer Print');
    Check(not Node.CanDoOperation(opPrintPreview, False),
      'a package node does not offer Print Preview');
  finally
    Node.Free;
  end;
end;

{ What each kind of tree node claims it can do. The failure this guards
  against is a node advertising an operation the dispatch in MarathonIDE has no
  branch for: the menu item appears, the user clicks it, and nothing happens.
  Adding a cache type without wiring the dispatch should fail here.

  The expectations below were checked against the dispatch by hand: opDrop
  reaches every leaf through the drop dialog's else-branch, opOpen covers every
  type but publications, and opNew/opPrint/opPrintPreview cover the eight
  classic object types only. }
procedure CheckNodeOperations;

  procedure Expect(Node: TMarathonCacheBaseNode; const What: String;
    Op: TGSSCacheOp; Wanted: Boolean);
  begin
    Check(Node.CanDoOperation(Op, False) = Wanted, What);
  end;

var
  Table: TMarathonCacheTable;
  Proc: TMarathonCacheProcedure;
  Pkg: TMarathonCachePackage;
  Pub: TMarathonCachePublication;
begin
  WriteLn('Tree node operations:');
  Table := TMarathonCacheTable.Create;
  Proc := TMarathonCacheProcedure.Create;
  Pkg := TMarathonCachePackage.Create;
  Pub := TMarathonCachePublication.Create;
  try
    { A classic object type: the dispatch covers all of these. }
    Expect(Table, 'a table can be opened', opOpen, True);
    Expect(Table, 'a table can be dropped', opDrop, True);
    Expect(Table, 'a table offers New', opNew, True);
    Expect(Table, 'a table can be scripted as SELECT', opScriptSelect, True);
    Expect(Table, 'a table can be scripted as MERGE', opScriptMerge, True);
    Expect(Table, 'a table cannot be scripted as EXECUTE', opScriptExecute, False);

    Expect(Proc, 'a procedure can be scripted as EXECUTE', opScriptExecute, True);
    Expect(Proc, 'a procedure cannot be scripted as SELECT', opScriptSelect, False);
    Expect(Proc, 'a procedure cannot be scripted as MERGE', opScriptMerge, False);

    { Packages: droppable through the dialog, but New/Print have no branch. }
    Expect(Pkg, 'a package can be opened', opOpen, True);
    Expect(Pkg, 'a package can be dropped', opDrop, True);
    Expect(Pkg, 'a package does not offer New', opNew, False);
    Expect(Pkg, 'a package does not offer Print', opPrint, False);

    { Publications are an attribute of the database, not an object: scripting
      is the only thing that applies. }
    Expect(Pub, 'a publication can be scripted', opScriptCreate, True);
    Expect(Pub, 'a publication cannot be opened', opOpen, False);
    Expect(Pub, 'a publication cannot be dropped', opDrop, False);
    Expect(Pub, 'a publication does not offer New', opNew, False);
  finally
    Pub.Free;
    Pkg.Free;
    Proc.Free;
    Table.Free;
  end;
end;

{ The profiler window. Its buttons are a small state machine - a session can be
  paused only while recording, resumed only while paused - and getting that
  wrong leaves buttons that do nothing or double-start a session. }
procedure CheckProfilerWindow;
var
  F: TfrmProfiler;
begin
  WriteLn('Profiler window:');
  F := TfrmProfiler.Create(nil);
  try
    Check(F.pgProfiler.PageCount = 3, 'has Sessions, Statements and Record Sources tabs');
    Check(F.tsSessions.Caption = 'Sessions', 'sessions tab');
    Check(F.tsStatements.Caption = 'Statements', 'statements tab');
    Check(F.tsRecordSources.Caption = 'Record Sources', 'record sources tab');
    Check(F.grdSessions.DataSource = F.dsSessions, 'sessions grid is bound');
    Check(F.dsSessions.DataSet = F.qrySessions, 'sessions datasource is bound');
    Check(F.grdStatements.DataSource = F.dsStatements, 'statements grid is bound');
    Check(F.grdRecordSources.DataSource = F.dsRecordSources, 'record sources grid is bound');

    { Nothing is recording yet, so only Start applies. }
    Check(not F.Recording, 'a new window is not recording');
    Check(F.btnStart.Enabled, 'Start is available');
    Check(not F.btnPause.Enabled, 'Pause is unavailable before recording');
    Check(not F.btnResume.Enabled, 'Resume is unavailable before recording');
    Check(not F.btnFinish.Enabled, 'Finish is unavailable before recording');

    Check(Assigned(F.btnStart.OnClick), 'Start is hooked up');
    Check(Assigned(F.btnPause.OnClick), 'Pause is hooked up');
    Check(Assigned(F.btnResume.OnClick), 'Resume is hooked up');
    Check(Assigned(F.btnFinish.OnClick), 'Finish is hooked up');
    Check(Assigned(F.btnClear.OnClick), 'Clear is hooked up');
    Check(Assigned(F.btnRefresh.OnClick), 'Refresh is hooked up');
  finally
    F.Free;
  end;
end;

{ The parallel worker control on the Maintenance dialog. Firebird 5 lets a
  backup or restore use several workers; the service only sends the parameter
  when the server can take it, so the default has to be the single-worker
  behaviour an older server expects. }
procedure CheckMaintenanceParallelWorkers;
var
  F: TfrmMaintenance;
begin
  WriteLn('Maintenance parallel workers:');
  F := TfrmMaintenance.Create(nil);
  try
    Check(Assigned(F.edParallelWorkers), 'the worker count control exists');
    Check(F.edParallelWorkers.Value = 1, 'it defaults to one worker');
    Check(F.edParallelWorkers.MinValue = 1, 'it cannot be set below one');
    Check(F.edParallelWorkers.MaxValue > 1, 'it allows more than one');

    { The in-place ODS upgrade is irreversible, so it gets its own button
      rather than a checkbox alongside the validate options. }
    Check(Assigned(F.btnUpgradeODS), 'the ODS upgrade button exists');
    Check(Assigned(F.btnUpgradeODS.OnClick), 'it is hooked up');
    Check(Pos('...', F.btnUpgradeODS.Caption) > 0,
      'its caption marks it as asking before acting');
  finally
    F.Free;
  end;
end;

{ The schema comparison dialog. Its FormCreate lists only connected databases,
  and with no project loaded there are none - so what can be checked here is
  the wiring rather than the contents: both sides present, OK guarded by a
  handler (it refuses an empty side and a self-comparison), and Cancel able to
  close the form without one. }
procedure CheckSchemaCompareDialog;
var
  F: TfrmSchemaCompare;
begin
  WriteLn('Schema compare dialog:');
  F := TfrmSchemaCompare.Create(nil);
  try
    Check(Assigned(F.cmbSource), 'the source side exists');
    Check(Assigned(F.cmbTarget), 'the target side exists');
    Check(Assigned(F.btnOK.OnClick), 'OK is guarded by a handler');
    Check(F.btnCancel.ModalResult = mrCancel, 'Cancel closes the dialog');
    Check(F.SourceConnection = '', 'no connection is chosen with none open');
    { The script alternative. It opens on the database side, since that is the
      common case, and the two inputs are enabled by which one is chosen. }
    Check(F.rbFromConnection.Checked, 'it opens comparing against a database');
    Check(not F.ComparingWithScript, 'and reports that as its mode');
    Check(F.cmbSource.Enabled and not F.edScript.Enabled,
      'the script box is disabled while comparing databases');
    F.rbFromScript.Checked := True;
    F.SourceKindChanged(nil);
    Check(F.ComparingWithScript, 'choosing a script switches mode');
    Check(F.edScript.Enabled and not F.cmbSource.Enabled,
      'the connection list is disabled while comparing against a script');
    Check(Assigned(F.btnBrowseScript.OnClick), 'Browse is hooked up');
  finally
    F.Free;
  end;
end;

{ The application image list, which every tree and list icon indexes into.

  gtk2's ItemSetImage writes Widgets^.Images.Items[AImageIndex] with no bound
  check of its own beyond requiring that list to match the image list's Count -
  so an ImageIndex at or past ImageList.Count raises EListError from inside the
  widgetset, which is what "List index (1) out of bounds" was. }
{ Every IBX dataset on a document form must be allowed to start a transaction
  for itself. The editors share one metadata transaction per connection and
  plenty of code commits it, so a dataset opened afterwards would otherwise
  fail with "Transaction is not active" - which is what switching tabs in the
  table editor did. }
procedure CheckEditorsAllowAutoTransactions;
var
  F: TfrmTables;
  Datasets, Refused: Integer;
  FirstRefused: String;

  { Recursive for the same reason the fix is: a form does not own the
    components sitting on its frames, and the editors put whole tabs on
    frames. Counting only the form's own datasets would have called the first
    version of this fix a pass. }
  procedure Walk(C: TComponent);
  var
    Idx: Integer;
    Child: TComponent;
  begin
    for Idx := 0 to C.ComponentCount - 1 do
    begin
      Child := C.Components[Idx];
      if Child is TIBCustomDataSet then
      begin
        Inc(Datasets);
        if not TIBCustomDataSet(Child).AllowAutoActivateTransaction then
        begin
          Inc(Refused);
          if FirstRefused = '' then
            FirstRefused := Child.Name;
        end;
      end;
      if Child.ComponentCount > 0 then
        Walk(Child);
    end;
  end;

begin
  WriteLn('Editor transactions:');
  F := TfrmTables.Create(nil);
  try
    Datasets := 0;
    Refused := 0;
    FirstRefused := '';
    Walk(F);
    Check(Datasets > 0, 'the table editor has IBX datasets to check');
    { More than the form's own, or the frames are not being reached. }
    Check(Datasets > 4, 'the datasets on its frames are counted too (' +
      IntToStr(Datasets) + ' found)');
    if Refused = 0 then
      Check(True, 'all ' + IntToStr(Datasets) +
        ' datasets may start their own transaction')
    else
      Check(False, IntToStr(Refused) + ' dataset(s) may not start a ' +
        'transaction, first: ' + FirstRefused);
  finally
    F.Free;
  end;
end;

{ Saving a project that remembers a password. The password is stored with the
  Borland XOR cipher, whose output is arbitrary bytes - Encrypt('masterkey')
  contains $15 and $04, both of which XML forbids outright. Writing those raw
  into an attribute made the whole save fail, and the only thing the user was
  told was "Unable to save project.". }
procedure CheckProjectSaveWithRememberedPassword;
var
  Conn: TMarathonCacheConnection;
  SavedName, Failure: String;
  Legacy: TStringList;
begin
  WriteLn('Project save with a remembered password:');
  Conn := MarathonIDEInstance.CurrentProject.Cache.AddConnectionInternal;
  Conn.Caption := 'PwdRoundTrip';
  Conn.DBFileName := '/tmp/whatever.fdb';
  Conn.ServerName := '';
  Conn.UserName := 'SYSDBA';
  Conn.Password := 'masterkey';
  Conn.RememberPassword := True;

  SavedName := GetTempDir + 'marathon_pwd_saved.xmpr';
  Failure := '';
  try
    MarathonIDEInstance.CurrentProject.SaveToFile(SavedName);
  except
    on E: Exception do
      Failure := E.Message;
  end;
  if Failure = '' then
    Check(True, 'a project with a remembered password saves')
  else
    Check(False, 'a project with a remembered password saves -- ' + Failure);

  if Failure = '' then
  begin
    MarathonIDEInstance.CurrentProject.LoadFromFile(SavedName);
    Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName['PwdRoundTrip'];
    Check(Assigned(Conn), 'the connection is read back');
    if Assigned(Conn) then
      Check(Conn.Password = 'masterkey', 'the password survives the round trip');
  end;

  { A project written by an earlier build stores the raw ciphertext. That only
    survived XML at all when it happened to contain no forbidden byte, which is
    exactly the case still out there to be read - Encrypt('a') is the single
    printable byte 'b'. Built by rewriting a project this build just saved,
    rather than by hand, so everything else in the file is genuinely what the
    loader expects. }
  Conn.Password := 'a';
  MarathonIDEInstance.CurrentProject.SaveToFile(SavedName);
  Legacy := TStringList.Create;
  try
    Legacy.LoadFromFile(SavedName);
    Legacy.Text := StringReplace(Legacy.Text,
      'passwordhex="' + EncryptToHex('a', E_START_KEY, E_MULT_KEY, E_ADD_KEY) + '"',
      'password="' + Encrypt('a', E_START_KEY, E_MULT_KEY, E_ADD_KEY) + '"',
      [rfReplaceAll]);
    Legacy.SaveToFile(SavedName);
  finally
    Legacy.Free;
  end;
  MarathonIDEInstance.CurrentProject.LoadFromFile(SavedName);
  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName['PwdRoundTrip'];
  Check(Assigned(Conn), 'a project written by an earlier build still loads');
  if Assigned(Conn) then
    Check(Conn.Password = 'a', 'its raw-ciphertext password is still read');
  DeleteFile(SavedName);
end;

{ The image lists that live in a .lfm rather than being rebuilt from a resource
  strip at runtime. These inherited Delphi's TImageList blob, which LCL reads
  as a single image no matter how many it held, so they were converted to LCL's
  own format (see tools/imagelist_convert.lpr). Checked here because a blob
  that round-trips standalone is not proof it survives being streamed as part
  of a form. }
{ DPI scaling. Every .lfm carried Delphi's Scaled = False, which switches LCL's
  scaling off form by form, so on a high-DPI display the whole interface
  rendered at 96 DPI - controls and text at a fraction of their intended size.
  Checked here because the fault is invisible on a 96 DPI display, where the
  scale factor is 1.0 and everything looks correct either way. }
{ Find, Find Next and Replace in the editors. Every caller had been reduced to
  a comment on this port, so Ctrl+F did nothing anywhere - while the dialogs
  themselves were ported and working, and only the three methods that raise
  them were missing. Checked through the forms' own Can/Do pair rather than the
  editor control, since that is the path the menu actually takes. }
procedure CheckEditorSearch;
var
  F: TfrmSQLForm;
begin
  WriteLn('Editor search:');
  { Nothing here asserts the three methods exist - that is a compile-time fact,
    and a test that only says "it compiles" is worth nothing. What matters is
    that the menu path reaches them and that the search reads the editor's
    text. }
  F := TfrmSQLForm.Create(nil);
  try
    { Text first: the form only offers Find on a document with something in it,
      which is why the order here matters. }
    Check(not F.CanFind, 'Find is not offered on an empty document');
    F.edSQLStatement.Text := 'select * from rdb$database';
    Check(F.CanFind, 'the SQL editor offers Find once there is text');
    Check(F.CanFindNext, 'and Find Next');
    Check(F.CanReplace, 'and Replace');
    Check(F.edSQLStatement.SearchReplace('rdb$database', '', []) > 0,
      'a search over the editor text finds a match');
    Check(F.edSQLStatement.SearchReplace('no_such_token', '', []) = 0,
      'and reports nothing for text that is not there');
  finally
    F.Free;
  end;
end;

{ Ctrl+Space completion in the SQL editor. The decision of what to offer is
  tested without a GUI in keyword_test; what matters here is that the popup is
  wired to the editor at all, and that a dot ends a token - without that,
  'c.' reads as one word and the qualifier is never seen. }
procedure CheckCompletionWiring;
var
  F: TfrmSQLForm;
  Comp: TSynCompletion;
  Idx: Integer;
begin
  WriteLn('SQL completion:');
  F := TfrmSQLForm.Create(nil);
  try
    Comp := nil;
    for Idx := 0 to F.ComponentCount - 1 do
      if F.Components[Idx] is TSynCompletion then
        Comp := TSynCompletion(F.Components[Idx]);
    Check(Assigned(Comp), 'the editor has a completion popup');
    if not Assigned(Comp) then
      Exit;
    Check(Comp.Editor = F.edSQLStatement, 'it is attached to the SQL editor');
    Check(Assigned(Comp.OnExecute), 'it fills its list on demand');
    Check(Pos('.', Comp.EndOfTokenChr) > 0,
      'a dot ends a token, so a qualifier is seen');
    { With no connection there are no object names, but the keywords must still
      be offered - completion has to work on a disconnected editor. }
    Comp.OnExecute(Comp);
    Check(Comp.ItemList.Count > 0, 'keywords are offered without a connection');
    Check(Comp.ItemList.IndexOf('SELECT') >= 0, 'SELECT is among them');
  finally
    F.Free;
  end;
end;

procedure CheckHighDPIScaling;
var
  Idx, Unscaled: Integer;
  FirstUnscaled: String;
  F: TCustomForm;
begin
  WriteLn('High-DPI scaling:');
  { Application.Scaled is one line in marathon.lpr, which this harness does not
    run. Asserting it here would mean asserting something the harness had to set
    itself, which proves nothing. What is worth checking is the forms: every one
    of them shipped with Delphi's Scaled = False, and that is the setting that
    made the interface render at 96 DPI whatever the display. }
  Unscaled := 0;
  FirstUnscaled := '';
  for Idx := 0 to Screen.CustomFormCount - 1 do
  begin
    F := Screen.CustomForms[Idx];
    if not F.Scaled then
    begin
      Inc(Unscaled);
      if FirstUnscaled <> '' then
        FirstUnscaled := FirstUnscaled + ', ';
      FirstUnscaled := FirstUnscaled + F.ClassName;
    end;
  end;
  if Unscaled = 0 then
    Check(True, 'every open form scales with the display')
  else
    Check(False, IntToStr(Unscaled) + ' form(s) do not scale: ' + FirstUnscaled);
  { The icons have to follow, or they sit at 16 pixels beside scaled text. }
  Check(frmMarathonMain.ilMarathonImages.Scaled,
    'the tree image list scales with the display');
end;

procedure CheckDesignedImageLists;
var
  NewObj: TfrmNewObject;
  Drop: TfrmDropObject;
  SQL: TfrmSQLForm;
begin
  WriteLn('Image lists stored in .lfm files:');
  Check(dmMenus.ilErrors.Count = 2, 'the menu module error list holds 2 images (has ' +
    IntToStr(dmMenus.ilErrors.Count) + ')');
  NewObj := TfrmNewObject.Create(nil);
  try
    Check(NewObj.ilImages.Count = 8, 'the new-object list holds 8 images (has ' +
      IntToStr(NewObj.ilImages.Count) + ')');
  finally
    NewObj.Free;
  end;
  Drop := TfrmDropObject.Create(nil);
  try
    Check(Drop.ilResults.Count = 2, 'the drop-object list holds 2 images (has ' +
      IntToStr(Drop.ilResults.Count) + ')');
  finally
    Drop.Free;
  end;
  SQL := TfrmSQLForm.Create(nil);
  try
    Check(SQL.ImageList1.Count = 8, 'the SQL editor list holds 8 images (has ' +
      IntToStr(SQL.ImageList1.Count) + ')');
  finally
    SQL.Free;
  end;
end;

procedure CheckImageListsSliced;

  { Every strip is a single row of square icons, so the image count the list
    should end up with is simply how many cells the strip holds. }
  procedure CheckList(IL: TCustomImageList; const ResName, What: String);
  var
    B: TBitmap;
    Expected: Integer;
  begin
    B := TBitmap.Create;
    try
      B.LoadFromResourceName(HInstance, ResName);
      Expected := B.Width div IL.Width;
    finally
      B.Free;
    end;
    Check(IL.Count = Expected, What + ' holds all ' + IntToStr(Expected) +
      ' icons of its strip (has ' + IntToStr(IL.Count) + ')');
  end;

begin
  WriteLn('Image lists built from strips:');
  CheckList(frmMarathonMain.ilMarathonImages, 'TREE_IMAGES_STRIP', 'the tree image list');
  CheckList(frmMarathonMain.ilErrorInfo, 'ERROR_INFO_STRIP', 'the error image list');
  CheckList(frmMarathonMain.imgMenuTools, 'TOOL_BAR_STRIP', 'the toolbar image list');
  { The two overlays the tree uses for connected and inactive connections are
    indexed directly, so they have to exist. }
  Check(frmMarathonMain.ilMarathonImages.Count > 14,
    'the overlay images the tree indexes (13 and 14) are present');
end;

{ The object browser's list pane, rebuilt the way TfrmDatabaseExplorer rebuilds
  it. Clearing and re-adding the columns inside an Items.BeginUpdate block
  makes the gtk2 widget rebuild its store, so the rows added afterwards are not
  there yet as far as the widgetset is concerned - and TListItem.SetImageIndex
  hands it the item's index. The second item therefore raised
  "EListError: List index (1) out of bounds", which is exactly what a user saw
  on selecting a connection: one entry listed, then the error. }
procedure CheckListViewRebuild;
var
  F: TForm;
  LV: TListView;
  Idx: Integer;
  Item: TListItem;
  Failure: String;
  Images: TImageList;
  Bmp: TBitmap;
begin
  WriteLn('Object list rebuild:');
  Failure := '';
  F := TForm.CreateNew(nil);
  try
    F.Width := 300;
    F.Height := 200;
    { Configured like lvDatabase: a report view with a small-image list. The
      image list matters - TListItem.SetImageIndex only reaches the widgetset
      code that failed when one is assigned. }
    Images := TImageList.Create(F);
    Images.Width := 16;
    Images.Height := 16;
    for Idx := 0 to 11 do
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.SetSize(16, 16);
        Bmp.Canvas.Brush.Color := clWhite;
        Bmp.Canvas.FillRect(0, 0, 16, 16);
        Images.Add(Bmp, nil);
      finally
        Bmp.Free;
      end;
    end;
    LV := TListView.Create(F);
    LV.Parent := F;
    LV.ViewStyle := vsReport;
    LV.SmallImages := Images;
    LV.HandleNeeded;
    F.Show;
    Application.ProcessMessages;
    try
      { The order under test: columns settled first, then the items added
        inside the update block. }
      LV.Items.Clear;
      LV.Columns.Clear;
      with LV.Columns.Add do
      begin
        Caption := 'Object';
        Width := 200;
      end;
      LV.Items.BeginUpdate;
      try
        for Idx := 0 to 3 do
        begin
          Item := LV.Items.Add;
          Item.Caption := 'Item ' + IntToStr(Idx);
          Item.ImageIndex := Idx;
        end;
      finally
        LV.Items.EndUpdate;
      end;
    except
      on E: Exception do
        Failure := E.ClassName + ': ' + E.Message;
    end;
    Check(Failure = '', 'rebuilding the list with several items does not raise' +
      TrimRight(' ' + Failure));
    Check(LV.Items.Count = 4, 'every item is added');
    for Idx := 0 to LV.Items.Count - 1 do
    begin
      Item := LV.Items[Idx];
      if Item.ImageIndex <> Idx then
      begin
        Check(False, 'item ' + IntToStr(Idx) + ' keeps its image index');
        Break;
      end;
    end;
  finally
    F.Free;
  end;
end;

{ IBX raises a login dialog of its own whenever LoginPrompt is left at its
  default of True - and that dialog lives in the GUI half of the package, so in
  a program that does not pull it in the attempt fails with "Default Login
  Dialog not found. Have you included ibexpress in your program uses list?"
  rather than connecting. Marathon collects credentials itself, so every
  connection it makes has to turn the prompt off; this checks the one every
  connection in the object tree is built from. }
procedure CheckConnectionDoesNotPrompt;
var
  Conn: TMarathonCacheConnection;
begin
  WriteLn('Connection login prompt:');
  Conn := TMarathonCacheConnection.Create;
  Check(not Conn.Connection.LoginPrompt,
    'a new connection does not ask IBX to prompt for a login');
  { Deliberately not freed. Destroy writes through FRootItem, which only a
    connection belonging to a project has, so freeing this one raises - and an
    unhandled exception here means a modal error dialog with nobody to dismiss
    it, which hangs the run rather than failing it. Leaking one object in a
    process that is about to exit is the lesser problem. }
end;

{ The three variants of the master properties dialog. Each shows one tab of a
  page control that holds all three; making that tab visible does not make it
  the active page, so New Project and New Server both used to open completely
  empty - the right tab drawn over the page the .lfm left active, which was
  the hidden connection one. Only the connection dialogs escaped, because that
  is where ActivePage already pointed. }
procedure CheckMasterPropertiesTabs;

  procedure CheckOne(F: TfrmMasterProperties; const Expected, What: String);
  begin
    try
      Check(Assigned(F.pgProperties.ActivePage) and
            (F.pgProperties.ActivePage.Name = Expected),
        What + ' shows the ' + Expected + ' page');
      Check(Assigned(F.pgProperties.ActivePage) and
            (F.pgProperties.ActivePage.ControlCount > 0),
        What + ' shows a page with controls on it');
      Check(Assigned(F.pgProperties.ActivePage) and
            F.pgProperties.ActivePage.TabVisible,
        What + ' shows a page whose tab is visible');
    finally
      F.Free;
    end;
  end;

begin
  WriteLn('Master properties dialog tabs:');
  CheckOne(TfrmMasterProperties.CreateNewProject(nil), 'tsProject', 'New Project');
  CheckOne(TfrmMasterProperties.CreateNewServer(nil), 'tsServer', 'New Server');
  CheckOne(TfrmMasterProperties.CreateNewConnection(nil), 'tsConnection', 'New Connection');
end;

{ The Create Database dialog. The wizard it replaces could not run on this
  platform at all, so the defaults it opens with are the whole user-facing
  contract: a page size the server will honour, dialect 3, and a character set
  that is not NONE. }
procedure CheckCreateDatabaseDialog;
var
  F: TfrmCreateDatabase;
begin
  WriteLn('Create Database dialog:');
  F := TfrmCreateDatabase.Create(nil);
  try
    Check(F.cmbPageSize.Items.Count > 0, 'page sizes are offered');
    Check(F.cmbPageSize.Items.IndexOf('4096') < 0,
      'no page size the server would silently clamp');
    Check(F.Options.PageSize = 8192, 'the default page size is 8192');
    Check(F.Options.Dialect = 3, 'the default dialect is 3');
    Check(F.Options.CharacterSet = 'UTF8', 'the default character set is UTF8');
    Check(F.Options.UserName = 'SYSDBA', 'the user name is pre-filled');
    { Editable, because the database does not exist yet and so the server's
      real character set list cannot be read to populate it. }
    Check(F.cmbCharSet.Style <> csDropDownList,
      'a character set outside the list can be typed');
    Check(Assigned(F.btnOK.OnClick), 'Create is guarded by a handler');
    Check(F.Options.FileName = '', 'no file name is assumed');
  finally
    F.Free;
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
  TryConstruct(TfrmSchemaCompare, 'TfrmSchemaCompare');
  TryConstruct(TfrmCreateDatabase, 'TfrmCreateDatabase');
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
  CheckPackageEditor;
  CheckNodeOperations;
  CheckProfilerWindow;
  CheckMaintenanceParallelWorkers;
  CheckSchemaCompareDialog;
  CheckCreateDatabaseDialog;
  CheckMasterPropertiesTabs;
  CheckConnectionDoesNotPrompt;
  CheckListViewRebuild;
  CheckImageListsSliced;
  CheckDesignedImageLists;
  CheckHighDPIScaling;
  CheckCompletionWiring;
  CheckEditorSearch;
  CheckEditorsAllowAutoTransactions;
  CheckProjectSaveWithRememberedPassword;

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' form check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: forms load and the expected controls are wired up.');
end.
