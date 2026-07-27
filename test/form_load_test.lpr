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
  { Before anything that starts a thread - see marathon.lpr. }
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, SysUtils, Classes, Forms, Controls, ComCtrls, ExtCtrls, StdCtrls,
  ActnList, Menus, DB, DBGrids, Registry, Graphics, ImgList, IBCustomDataSet,
  GSSRegistry, Globals, MarathonProjectCacheTypes, MarathonProjectCache, SQLParamsDialog, SQLParamTypes, IB, Crypt32, SyntaxMemoWithStuff2, SynCompletion, SQLCompletionHost, SchemaObjects, DocumentHost, CommandPaletteDialog,
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
  StoredProcParamWarn, StoredProcedureParams, SyntaxHelp,
  UDFInputParam, UserEditor, WindowList, TableDesignerForm, TableDesign, TableDesignIO, CommandPalette, SynEdit, BaseDocumentDataAwareForm, PrintDocument, PrintRenderer, QueryBuilderForm, QueryModel, IBQuery, KeyBindingEditor, KeyBindings, LCLType, CodeTemplates;

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

{ The main form can open a project on create, which this test does not want.
  Run it with an isolated HOME (see the workflow) so turning that off cannot
  disturb a real installation's settings.

  It used to turn off a Tip of the Day dialog here too: that was modal on
  startup and would hang the run with nobody to dismiss it. The dialog is gone,
  so the setting is not written any more. }
procedure SuppressStartupDialogs;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(REG_SETTINGS_BASE, True) then
    begin
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
  SP: TfrmStoredProcedure;
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
    { The stored procedure editor too - it could not be constructed at all
      until its in-memory parameter list was fixed, so it was never checked. }
    SP := TfrmStoredProcedure.Create(nil);
    try
      Walk(SP);
    finally
      SP.Free;
    end;
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
{ Finds the completion popup a form should have created.

  Construction is wrapped the way TryConstruct wraps it, and for the same
  reason: some editors raise from OnCreate without a live database. Letting
  that escape here does not fail the run, it hangs it - an unhandled exception
  becomes a modal dialog with nobody under Xvfb to dismiss it, which is exactly
  what happened the first time. A form that cannot be built is reported as not
  checked rather than quietly passed. }
procedure CheckHasCompletion(FormClass: TFormClass; const What: String);
var
  AForm: TForm;
  Idx: Integer;
  Comp: TSynCompletion;
begin
  AForm := nil;
  try
    try
      AForm := FormClass.Create(nil);
    except
      on E: Exception do
      begin
        WriteLn('  .... ', What, ' could not be built here (', E.ClassName,
          '), completion not checked');
        Exit;
      end;
    end;
    Comp := nil;
    for Idx := 0 to AForm.ComponentCount - 1 do
      if AForm.Components[Idx] is TSQLCompletionHost then
        Comp := TSQLCompletionHost(AForm.Components[Idx]).Completion;
    Check(Assigned(Comp), What + ' has a completion popup');
    if Assigned(Comp) then
      Check(Assigned(Comp.Editor), What + '''s popup is attached to an editor');
  finally
    try
      AForm.Free;
    except
      on E: Exception do ;
    end;
  end;
end;

{ Opens one editor on the first object of its kind the database holds.

  Each editor runs its own metadata queries, so each is a separate thing that
  can break; loading is the shallowest useful check and the one that catches a
  query naming the wrong thing. A kind the database has none of is skipped
  rather than passed. }
procedure CheckEditorLoads(Conn: TMarathonCacheConnection;
  Kind: TSchemaObjectKind; const What: String);
var
  Names: TStringList;
  Name: String;
  Form: TForm;
begin
  Names := ListSchemaObjects(Conn.Connection, Conn.Transaction, Kind, '',
    Conn.IsODSAtLeast(14, 0));
  try
    if Names.Count = 0 then
    begin
      WriteLn('  .... ', What, ': nothing of that kind here to open');
      Exit;
    end;
    Name := Trim(Names[0]);
  finally
    Names.Free;
  end;

  Form := nil;
  try
    try
      case Kind of
        sokView:
          begin
            Form := TfrmViewEditor.Create(nil);
            TfrmViewEditor(Form).ConnectionName := Conn.Caption;
            TfrmViewEditor(Form).LoadView(Name);
          end;
        sokProcedure:
          begin
            Form := TfrmStoredProcedure.Create(nil);
            TfrmStoredProcedure(Form).ConnectionName := Conn.Caption;
            TfrmStoredProcedure(Form).LoadProcedure(Name);
          end;
        sokTrigger:
          begin
            Form := TfrmTriggerEditor.Create(nil);
            TfrmTriggerEditor(Form).ConnectionName := Conn.Caption;
            TfrmTriggerEditor(Form).LoadTrigger(Name);
          end;
        sokDomain:
          begin
            Form := TfrmDomains.Create(nil);
            TfrmDomains(Form).ConnectionName := Conn.Caption;
            TfrmDomains(Form).LoadDomain(Name);
          end;
        sokGenerator:
          begin
            Form := TfrmGenerators.Create(nil);
            TfrmGenerators(Form).ConnectionName := Conn.Caption;
            TfrmGenerators(Form).LoadGenerator(Name);
          end;
        sokException:
          begin
            Form := TfrmExceptions.Create(nil);
            TfrmExceptions(Form).ConnectionName := Conn.Caption;
            TfrmExceptions(Form).LoadException(Name);
          end;
      end;
      Check(True, What + ' opens ' + Name);
    except
      on E: Exception do
      begin
        Check(False, What + ' opens ' + Name + ' (' + E.ClassName + ': ' +
          E.Message + ')');
        { Where it failed, not just that it did. These editors run dozens of
          metadata queries and the message alone rarely says which. }
        DumpExceptionBackTrace(Output);
        Flush(Output);
      end;
    end;
  finally
    try
      Form.Free;
    except
      on E: Exception do ;
    end;
  end;
end;

{ Opens an object editor on a real table.

  Everything else in this harness runs without a database, which is why the
  editors have never been covered by anything: they need a live connection and
  a widgetset at once, and the console smoke test can supply only the first.
  Given credentials this fills that gap - and it is the harness any change to
  the editors' queries would need, because there is otherwise no way to tell
  whether one still loads what it should.

  The credentials come from the environment rather than the command line, and
  that is not a preference: TfrmMarathonMain treats ParamStr(1) as a project
  file to open, so passing a database name there makes the main form try to
  open it as a project and the run hangs on the resulting dialog before any of
  this is reached.

  Skipped, loudly, when the variables are unset, so a run without a server
  still means something and does not quietly report success it did not earn. }
{ Everything an editor is showing, as one string.

  Read generically from the controls rather than from each editor's own fields:
  six editors surface their content six different ways, and what matters here
  is only whether a name belonging to the other schema's object appears
  anywhere on the form. }
function EditorContentText(Form: TComponent): String;
var
  Idx, N: Integer;
  C: TComponent;
begin
  Result := '';
  for Idx := 0 to Form.ComponentCount - 1 do
  begin
    C := Form.Components[Idx];
    if C is TCustomListView then
      for N := 0 to TCustomListView(C).Items.Count - 1 do
        Result := Result + ' ' + TCustomListView(C).Items[N].Caption
    else if C is TCustomMemo then
      Result := Result + ' ' + TCustomMemo(C).Lines.Text
    else if C is TCustomSynEdit then
      Result := Result + ' ' + TCustomSynEdit(C).Lines.Text
    else if C is TCustomEdit then
      Result := Result + ' ' + TCustomEdit(C).Text;
    { Frames own their own controls, so a tab built on one is invisible from
      the form's list. }
    if C.ComponentCount > 0 then
      Result := Result + ' ' + EditorContentText(C);
  end;
end;

{ One editor kind, opened on its own object in each of the two schemas. }
procedure CheckEditorSchema(Kind: TSchemaObjectKind;
  const ObjName, OnlyThere, OnlyHere, What: String);

  function ContentOf(const ASchema: String): String;
  var
    Form: TfrmBaseDocumentDataAwareForm;
  begin
    Result := '';
    Form := nil;
    try
      case Kind of
        sokView:      Form := TfrmViewEditor.Create(nil);
        sokProcedure: Form := TfrmStoredProcedure.Create(nil);
        sokException: Form := TfrmExceptions.Create(nil);
        sokGenerator: Form := TfrmGenerators.Create(nil);
        sokDomain:    Form := TfrmDomains.Create(nil);
      else
        Exit;
      end;
      Form.ConnectionName := 'EditorHarness';
      Form.Schema := ASchema;
      try
        case Kind of
          sokView:      TfrmViewEditor(Form).LoadView(ObjName);
          sokProcedure: TfrmStoredProcedure(Form).LoadProcedure(ObjName);
          sokException: TfrmExceptions(Form).LoadException(ObjName);
          sokGenerator: TfrmGenerators(Form).LoadGenerator(ObjName);
          sokDomain:    TfrmDomains(Form).LoadDomain(ObjName);
        end;
      except
        on E: Exception do
          Exit('<' + E.ClassName + ': ' + E.Message + '>');
      end;
      Result := EditorContentText(Form);
    finally
      Form.Free;
    end;
  end;

var
  There, Here: String;
begin
  There := ContentOf('EDIT_SCH');
  Here := ContentOf('');
  Check(Pos(OnlyThere, There) > 0, What + ' shows the named schema''s object');
  Check(Pos(OnlyHere, There) = 0,
    What + ' does not show the other schema''s object');
  Check(Pos(OnlyHere, Here) > 0, What + ' shows the current schema''s object');
  Check(Pos(OnlyThere, Here) = 0, What + ' keeps the two apart the other way');
  if (Pos(OnlyHere, There) > 0) or (Pos(OnlyThere, Here) > 0) then
  begin
    WriteLn('       EDIT_SCH showed: ', Copy(Trim(There), 1, 200));
    WriteLn('       current showed:  ', Copy(Trim(Here), 1, 200));
  end;
end;

{ The SQL Trace window, which has opened onto nothing for the whole of this
  port.

  The component behind it had every property the Options dialog writes to and
  no behaviour at all, so the window set itself up correctly and then waited
  for lines that could not come. What is checked here is the thing that
  distinguishes the two: run a statement, and see it appear in the window's
  editor.

  keyword_test covers which IBX flags Marathon's categories map to; the smoke
  test covers that the monitor delivers at all. This covers the window. }
procedure CheckSQLTrace(Conn: TMarathonCacheConnection);
var
  F: TfrmSQLTrace;
  Q: TIBQuery;
  Waited: Integer;
begin
  WriteLn('SQL trace window:');
  try
    F := TfrmSQLTrace.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the trace window .lfm streams (' + E.ClassName + ': ' +
        E.Message + ')');
      Exit;
    end;
  end;
  try
    Check(Assigned(F.edTrace) and Assigned(F.trcSQL),
      'the trace window streams its editor and its monitor');
    { Enabled by FormCreate, which is the line that had never existed. }
    Check(F.trcSQL.Enabled, 'and the monitor is switched on when the window opens');
    Check(F.trcSQL.CurrentTraceFlags <> [],
      'with something actually being watched');

    F.AttachConnections;
    F.edTrace.Lines.Clear;

    Q := TIBQuery.Create(nil);
    try
      Q.Database := Conn.Connection;
      Q.Transaction := Conn.Transaction;
      Q.AllowAutoActivateTransaction := True;
      Q.SQL.Text := 'select 1 as WINDOW_PROBE from rdb$database';
      Q.Open;
      Q.Close;
    finally
      Q.Free;
    end;

    { The monitor delivers through a reader thread and Synchronize, so the
      line arrives when the message loop next runs rather than immediately. }
    Waited := 0;
    while (Pos('WINDOW_PROBE', F.edTrace.Lines.Text) = 0) and (Waited < 3000) do
    begin
      Application.ProcessMessages;
      CheckSynchronize(50);
      Inc(Waited, 50);
    end;

    Check(Pos('WINDOW_PROBE', F.edTrace.Lines.Text) > 0,
      'a statement run while the window is open appears in it');
    if Pos('WINDOW_PROBE', F.edTrace.Lines.Text) = 0 then
      WriteLn('       the window held: ', Copy(F.edTrace.Lines.Text, 1, 300));
  finally
    F.Free;
  end;
end;

{ The query builder, which replaces a unit that was never compiled into the
  program at all.

  The SQL it generates is checked in keyword_test without a widgetset and run
  against a live server in the smoke test. What needs a display is the canvas,
  and it is driven through the very mouse handlers the user's mouse reaches -
  a check that called the model directly would prove the model, which is
  already proven, and nothing about the form. }
procedure CheckQueryBuilder(Conn: TMarathonCacheConnection);
var
  F: TfrmQueryBuilder;
  Box2Left: Integer;

  { The form lays its first box out at (12, 12) with a 20-pixel caption and
    16-pixel rows, and the second one 174 pixels to the right. Repeated here
    rather than exported, because a test that asked the form where it drew
    something would agree with whatever the form did. }
  function TickX(BoxLeft: Integer): Integer;
  begin
    Result := BoxLeft + 8;
  end;

  function RowY(Row: Integer): Integer;
  begin
    Result := 12 + 20 + Row * 16 + 6;
  end;

  { The column name, to the right of the tick box - where a drag starts. }
  function NameX(BoxLeft: Integer): Integer;
  begin
    Result := BoxLeft + 60;
  end;

begin
  WriteLn('Query builder:');
  try
    F := TfrmQueryBuilder.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the builder .lfm streams (' + E.ClassName + ': ' + E.Message + ')');
      Exit;
    end;
  end;
  try
    Check(Assigned(F.pbCanvas) and Assigned(F.memSQL) and Assigned(F.grdColumns),
      'the builder .lfm streams its canvas, grid and SQL pane');
    Check(F.SQL = '', 'an empty builder produces no SQL');

    F.LoadFrom(Conn.Connection, Conn.Transaction);
    Check(F.lstTables.Items.Count > 0,
      'it lists the connection''s tables (' +
      IntToStr(F.lstTables.Items.Count) + ')');
    if F.lstTables.Items.IndexOf('QB_A') < 0 then
    begin
      WriteLn('  .... skipped the canvas: the smoke test''s QB_A is not here');
      Exit;
    end;

    { Added the way the Add button adds them. }
    F.lstTables.ItemIndex := F.lstTables.Items.IndexOf('QB_A');
    F.btnAddClick(nil);
    F.lstTables.ItemIndex := F.lstTables.Items.IndexOf('QB_B');
    F.btnAddClick(nil);
    Check(F.Model.TableCount = 2, 'Add puts a table on the canvas');
    Check(Pos('QB_A', F.SQL) > 0, 'and it reaches the SQL');
    Box2Left := 12 + 150 + 24;

    { Painting. This is where a nil canvas or a bad index shows up, and it
      cannot be reached except by drawing. }
    try
      F.pbCanvasPaint(nil);
      Check(True, 'the canvas paints its boxes');
    except
      on E: Exception do
        Check(False, 'the canvas paints (' + E.ClassName + ': ' + E.Message + ')');
    end;

    { Ticking a column by clicking its box, through the real handler. QB_A's
      first column is ID. }
    F.pbCanvasMouseDown(mbLeft, [], TickX(12), RowY(0));
    F.pbCanvasMouseUp(mbLeft, [], TickX(12), RowY(0));
    Check(Pos('QA.ID', F.SQL) > 0, 'clicking a tick box chooses that column');
    Check(Pos('select *', F.SQL) = 0, 'and replaces the *');
    Check(F.grdColumns.RowCount = 2, 'and the column grid shows it');

    { Clicking it again unticks it. The form keeps the entry with an empty
      name so the grid indices hold; what must not happen is that emptiness
      reaching the SQL as a dangling "QA." reference. }
    F.pbCanvasMouseDown(mbLeft, [], TickX(12), RowY(0));
    F.pbCanvasMouseUp(mbLeft, [], TickX(12), RowY(0));
    Check(Pos('QA.,', F.SQL) = 0, 'clicking again unticks it without leaving a stub');
    Check(Pos('select *', F.SQL) > 0, 'and the SQL goes back to selecting everything');

    { Joining, by dragging from a column of one box to a column of the other -
      press, move, release, exactly as a mouse does it. }
    Check(F.Model.JoinCount = 0, 'nothing is joined yet');
    F.pbCanvasMouseDown(mbLeft, [], NameX(12), RowY(0));
    F.pbCanvasMouseMove([], NameX(Box2Left), RowY(1));
    F.pbCanvasMouseUp(mbLeft, [], NameX(Box2Left), RowY(1));
    Check(F.Model.JoinCount = 1, 'dragging between two columns makes a join');
    Check(Pos('inner join', F.SQL) > 0, 'which reaches the SQL');
    Check(IsFullyJoined(F.Model), 'and the query becomes fully joined');

    { A drag that ends on nothing must not make a join out of thin air. }
    F.pbCanvasMouseDown(mbLeft, [], NameX(12), RowY(0));
    F.pbCanvasMouseUp(mbLeft, [], 600, 400);
    Check(F.Model.JoinCount = 1, 'a drag released on empty canvas joins nothing');

    { Dragging a box by its caption moves it rather than joining anything. }
    F.pbCanvasMouseDown(mbLeft, [], 60, 16);
    F.pbCanvasMouseMove([], 260, 216);
    F.pbCanvasMouseUp(mbLeft, [], 260, 216);
    Check(F.Model.JoinCount = 1, 'dragging a box by its caption makes no join');
    Check(F.SQL <> '', 'and the query survives being rearranged');
  finally
    F.Free;
  end;
end;

{ The object editors against two schemas holding the same table name.

  This is the one that matters. Firebird 6 made an object name unique per
  schema rather than per database, and every metadata query in every editor
  filtered on the name alone - so on a database holding EDIT_DUP in the current
  schema (ID, HERE_A, HERE_B) and EDIT_SCH.EDIT_DUP (OVER_THERE), opening
  either showed a table with all four columns. Not a missing feature: a wrong
  answer, silently.

  The fixture comes from the smoke test, which leaves the pair behind
  deliberately. Skipped on anything before Firebird 6, where the pair cannot
  exist and there is nothing to get wrong. }
procedure CheckSchemaQualifiedEditor(Conn: TMarathonCacheConnection);
var
  F: TfrmTables;

  { The editor's column list as one string, so a check can say which columns
    are there rather than only how many. }
  function ColumnsOf(ATable, ASchema: String): String;
  var
    E: TfrmTables;
    Idx: Integer;
  begin
    Result := '';
    E := TfrmTables.Create(nil);
    try
      E.ConnectionName := 'EditorHarness';
      E.Schema := ASchema;
      try
        E.LoadTable(ATable);
      except
        on Ex: Exception do
        begin
          Result := '<' + Ex.ClassName + ': ' + Ex.Message + '>';
          Exit;
        end;
      end;
      for Idx := 0 to E.lvFieldList.Items.Count - 1 do
        Result := Result + Trim(E.lvFieldList.Items[Idx].Caption) + ' ';
    finally
      E.Free;
    end;
  end;

var
  Here, There: String;
begin
  WriteLn('Editors against two schemas:');
  if not Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0) then
  begin
    WriteLn('  .... skipped: server has no SQL schemas');
    Exit;
  end;

  F := TfrmTables.Create(nil);
  try
    Check(F.Schema = '', 'an editor defaults to no schema, as it always did');
  finally
    F.Free;
  end;

  There := ColumnsOf('EDIT_DUP', 'EDIT_SCH');
  Here := ColumnsOf('EDIT_DUP', '');

  { Each editor shows its own table's columns and none of the other's. Before
    the schema predicate both of these held all four. }
  Check(Pos('OVER_THERE', There) > 0,
    'the named schema''s table shows its own column');
  Check(Pos('HERE_A', There) = 0,
    'and not a column belonging to the same-named table in another schema');
  Check(Pos('HERE_A', Here) > 0, 'the current schema''s table shows its own columns');
  Check(Pos('OVER_THERE', Here) = 0, 'and not the other schema''s');

  { Counting as well as naming: a predicate that filtered on the wrong column
    would return nothing at all, which passes every "is X absent" check above
    while showing an empty table. }
  Check(Length(Trim(There)) > 0, 'the named schema''s table is not empty');
  Check(Length(Trim(Here)) > 0, 'and neither is the current schema''s');
  if (Pos('HERE_A', There) > 0) or (Pos('OVER_THERE', Here) > 0) then
  begin
    WriteLn('       EDIT_SCH.EDIT_DUP showed: ', There);
    WriteLn('       EDIT_DUP showed:          ', Here);
  end;

  { And the other six editors, each on its own pair. Every one of them ran the
    same kind of name-only query, so every one of them had the same defect. }
  CheckEditorSchema(sokView, 'EDIT_VW', 'VOTH', 'VCUR', 'the view editor');
  CheckEditorSchema(sokProcedure, 'EDIT_SP', 'POTH', 'PCUR',
    'the procedure editor');
  CheckEditorSchema(sokException, 'EDIT_EXC', 'exoth', 'excur',
    'the exception editor');
  CheckEditorSchema(sokDomain, 'EDIT_DOM', '19', '7', 'the domain editor');
end;

{ The table designer, on a real table.

  The model underneath it is checked twice already - keyword_test says what an
  edit should generate, and the smoke test says Firebird accepts it. Neither
  says the form is wired to any of that. What is left to get wrong is exactly
  what a build cannot catch: an .lfm that does not stream, a grid whose hidden
  original-name column was dropped so every column looks like an addition, a
  script pane nothing refreshes, an Apply button enabled with nothing to apply. }
procedure CheckTableDesignerOn(Conn: TMarathonCacheConnection; const TableName: String);
var
  F: TfrmTableDesigner;
  Before: Integer;
begin
  WriteLn('Table designer:');
  try
    F := TfrmTableDesigner.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the designer''s .lfm streams (' + E.ClassName + ': ' + E.Message + ')');
      Exit;
    end;
  end;
  try
    Check(Assigned(F.grdColumns) and Assigned(F.memScript) and Assigned(F.btnApply),
      'the designer''s .lfm streams its grid, script pane and Apply button');
    { Six visible columns and the hidden one behind them. Without that seventh
      the form still builds and still runs - and every column read from the
      database looks like one being added, so Apply would try to add columns
      that already exist. }
    Check(F.grdColumns.ColCount = 7,
      'the grid keeps its hidden original-name column (has ' +
      IntToStr(F.grdColumns.ColCount) + ' columns)');

    try
      F.LoadTable(Conn.Connection, 'EditorHarness', TableName);
    except
      on E: Exception do
      begin
        Check(False, 'the designer loads ' + TableName + ' (' + E.ClassName +
          ': ' + E.Message + ')');
        Exit;
      end;
    end;
    Check(F.grdColumns.RowCount > 1,
      'it reads the table''s columns into the grid (' +
      IntToStr(F.grdColumns.RowCount - 1) + ')');

    { The property the whole design-then-apply idea rests on: opening a table
      and touching nothing has nothing to apply. If this failed, the first
      thing a user did would be to run an unintended script. }
    Check(F.memScript.Lines.Count = 0, 'a freshly opened table has an empty script');
    Check(not F.btnApply.Enabled, 'and Apply is disabled with nothing to apply');

    { An edit, made the way the grid makes one. }
    Before := F.memScript.Lines.Count;
    F.grdColumns.Cells[1, 1] := 'varchar(123)';
    F.grdColumnsEditingDone(F.grdColumns);
    Check(F.memScript.Lines.Count > Before,
      'editing a cell puts something in the script pane');
    Check(Pos('varchar(123)', F.memScript.Lines.Text) > 0,
      'and the script says what was actually typed');
    Check(F.btnApply.Enabled, 'and Apply becomes available');
    { Retyping is the flagged kind, so the warning has to reach the pane - it
      is the only thing standing between a mistyped width and a truncated
      column. }
    Check(Pos('lose data', F.memScript.Lines.Text) > 0,
      'a retype is marked as able to lose data');

    { And backing out. Nothing was applied, so this has to leave the table
      alone and the form back where it started. }
    F.btnRevertClick(nil);
    Check(F.memScript.Lines.Count = 0, 'Revert empties the script again');
    Check(not F.btnApply.Enabled, 'and disables Apply');

    { Adding a column through the toolbar, which is the other way the grid
      changes. }
    Before := F.grdColumns.RowCount;
    F.btnAddColumnClick(nil);
    Check(F.grdColumns.RowCount = Before + 1, 'Add column adds a grid row');
    { A row with no name yet is one the user has started, not a column called
      nothing - so it must not reach the script. }
    Check(F.memScript.Lines.Count = 0, 'an unnamed new row generates nothing');
    F.grdColumns.Cells[0, F.grdColumns.RowCount - 1] := 'HARNESS_NEW';
    F.grdColumnsEditingDone(F.grdColumns);
    Check(Pos('add HARNESS_NEW', F.memScript.Lines.Text) > 0,
      'and naming it makes it an ADD');
    { The hidden original-name column is what tells an addition from a rename;
      a new row must have it empty. }
    Check(Trim(F.grdColumns.Cells[6, F.grdColumns.RowCount - 1]) = '',
      'a new row carries no original name, so it is an addition');

    { Removing it again. }
    F.grdColumns.Row := F.grdColumns.RowCount - 1;
    F.btnDeleteColumnClick(nil);
    Check(F.grdColumns.RowCount = Before, 'Remove takes the row away again');
    Check(F.memScript.Lines.Count = 0, 'and the script goes quiet');

    { Reordering. Moving a row must not be mistaken for renaming two columns -
      each row carries its own original name with it. }
    F.grdColumns.Row := 1;
    F.btnMoveDownClick(nil);
    Check(F.memScript.Lines.Count = 0,
      'moving a column generates nothing, since order is not a change to apply');
  finally
    F.Free;
  end;
end;

procedure CheckTableEditorAgainstDatabase(const DatabaseName, User, Password: String);
var
  Conn: TMarathonCacheConnection;
  Server: TMarathonCacheServer;
  F: TfrmTables;
  Fields: Integer;
  FilePart, TableName: String;
begin
  WriteLn('Table editor against a live database:');
  if DatabaseName = '' then
  begin
    WriteLn('  .... skipped: set MARATHON_TEST_DB, MARATHON_TEST_USER and ' +
      'MARATHON_TEST_PASSWORD to include it');
    Exit;
  end;

  { A server has to exist first: Connect looks its connection's server up by
    name and builds the database string from it. Without one the first attempt
    fails and Connect falls back to its own login dialog - which under Xvfb is
    a hang rather than a failure. }
  Server := MarathonIDEInstance.CurrentProject.Cache.AddServerInternal;
  Server.Caption := 'HarnessServer';
  Server.UserName := User;
  Server.Password := Password;
  if Pos(':/', DatabaseName) > 0 then
  begin
    Server.Local := False;
    Server.HostName := Copy(DatabaseName, 1, Pos(':/', DatabaseName) - 1);
    FilePart := Copy(DatabaseName, Pos(':/', DatabaseName) + 1, MaxInt);
  end
  else
  begin
    Server.Local := True;
    FilePart := DatabaseName;
  end;

  Conn := MarathonIDEInstance.CurrentProject.Cache.AddConnectionInternal;
  Conn.Caption := 'EditorHarness';
  Conn.ServerName := 'HarnessServer';
  Conn.DBFileName := FilePart;
  Conn.UserName := User;
  Conn.Password := Password;
  Conn.SQLDialect := 3;
  if not Conn.Connect then
  begin
    Check(False, 'the harness connection opens');
    Exit;
  end;
  Check(True, 'the harness connection opens');

  { Whatever table the database happens to hold, rather than one this suite
    expects another suite to have left behind. That coupling would fail
    confusingly the moment the steps were reordered, and it stops the harness
    being usable against any database. }
  if Conn.TableList.Count = 0 then
  begin
    WriteLn('  .... skipped: ', DatabaseName, ' holds no user tables');
    Exit;
  end;
  TableName := Trim(Conn.TableList[0]);

  F := TfrmTables.Create(nil);
  try
    F.ConnectionName := 'EditorHarness';
    try
      F.LoadTable(TableName);
    except
      on E: Exception do
      begin
        Check(False, 'the table editor loads ' + TableName + ' (' + E.ClassName +
          ': ' + E.Message + ')');
        Exit;
      end;
    end;
    Check(True, 'the table editor loads ' + TableName);
    { Loading is not enough: it has to have read the columns. An editor that
      opens on an empty structure looks fine and is useless. }
    Fields := F.lvFieldList.Items.Count;
    Check(Fields > 0, 'it reads the table''s columns (' + IntToStr(Fields) + ')');
  finally
    F.Free;
  end;

  { The other editors, on whatever their kind of object the database holds.
    None of them has ever been opened by a test either, and each runs its own
    metadata queries - so each is a separate thing that can break. }
  CheckEditorLoads(Conn, sokView, 'the view editor');
  CheckEditorLoads(Conn, sokProcedure, 'the procedure editor');
  CheckEditorLoads(Conn, sokTrigger, 'the trigger editor');
  CheckEditorLoads(Conn, sokDomain, 'the domain editor');
  CheckEditorLoads(Conn, sokGenerator, 'the generator editor');
  CheckEditorLoads(Conn, sokException, 'the exception editor');

  CheckTableDesignerOn(Conn, TableName);
  CheckSchemaQualifiedEditor(Conn);
  CheckQueryBuilder(Conn);
  CheckSQLTrace(Conn);
end;

procedure CheckCompletionWiring;
var
  F: TfrmSQLForm;
  Comp: TSynCompletion;
  Idx: Integer;
begin
  WriteLn('SQL completion:');
  { All four editors, not just the SQL one. The PSQL editors are where routine
    bodies are written, so completion matters there at least as much. }
  CheckHasCompletion(TfrmSQLForm, 'the SQL editor');
  CheckHasCompletion(TfrmViewEditor, 'the view editor');
  CheckHasCompletion(TfrmTriggerEditor, 'the trigger editor');
  CheckHasCompletion(TfrmStoredProcedure, 'the procedure editor');

  F := TfrmSQLForm.Create(nil);
  try
    Comp := nil;
    for Idx := 0 to F.ComponentCount - 1 do
      if F.Components[Idx] is TSQLCompletionHost then
        Comp := TSQLCompletionHost(F.Components[Idx]).Completion;
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

{ Hosting documents as tabs - the shell Phase 9 is built around.

  Checked without a database, because none of this needs one: what matters is
  that a form put in a tab is reparented and shown, that a second request
  activates the existing tab rather than adding a duplicate, and that closing a
  document takes its tab with it. Leaking tabs would be invisible until a user
  had opened and closed a few dozen documents. }
procedure CheckDocumentHost;
var
  Shell: TForm;
  Pages: TPageControl;
  Host: TDocumentHost;
  DocA, DocB, DocC: TForm;
  Sheet: TTabSheet;
begin
  WriteLn('Document host:');
  Shell := TForm.CreateNew(nil);
  try
    Shell.Width := 600;
    Shell.Height := 400;
    Pages := TPageControl.Create(Shell);
    Pages.Parent := Shell;
    Pages.Align := alClient;
    Host := TDocumentHost.Create(Shell, Pages);

    Check(Host.DocumentCount = 0, 'a new host holds no documents');
    Check(Host.ActiveDocument = nil, 'and has no active document');

    DocA := TForm.CreateNew(Shell);
    DocA.Caption := 'Document A';
    Sheet := Host.Host(DocA);
    Check(Assigned(Sheet), 'a document is hosted');
    Check(Host.DocumentCount = 1, 'it becomes one tab');
    Check(Sheet.Caption = 'Document A', 'the tab takes the document''s caption');
    Check(DocA.Parent = Sheet, 'the form is reparented into the tab');
    Check(DocA.BorderStyle = bsNone, 'its window border is gone');
    Check(DocA.Align = alClient, 'and it fills the tab');
    Check(Host.IsHosted(DocA), 'the host knows it holds it');
    Check(Host.ActiveDocument = DocA, 'and it is the active document');

    DocB := TForm.CreateNew(Shell);
    DocB.Caption := 'Document B';
    Host.Host(DocB);
    Check(Host.DocumentCount = 2, 'a second document is a second tab');
    Check(Host.ActiveDocument = DocB, 'opening one activates it');

    { Opening the same document again must not add a tab - the object tree
      opens by name and will ask for one that is already up. }
    Host.Host(DocA);
    Check(Host.DocumentCount = 2, 'hosting the same document again adds no tab');
    Check(Host.ActiveDocument = DocA, 'it activates the existing one instead');

    Check(Host.Activate(DocB), 'an open document can be activated by request');
    Check(Host.ActiveDocument = DocB, 'and becomes active');

    DocA.Close;
    Application.ProcessMessages;
    Check(Host.DocumentCount = 1, 'closing a document removes its tab');
    Check(not Host.IsHosted(DocA), 'and the host forgets it');

    { A document can also be destroyed without ever being closed. The tab
      identifies its form by address, so one left behind by that would match
      whatever the allocator next puts at the same address, and a brand new
      window would be reported as already open. Found by exactly that: a freed
      probe collided with the object explorer.

      Ownerless on purpose. TComponent.Notification reaches components that
      share an owner, so a document owned by the same form as the host would be
      cleaned up whether or not the host asked to be told - and the check would
      pass with the mechanism removed. The application creates its documents
      with Create(nil), and that is the case that needs the notification. }
    DocC := TForm.CreateNew(nil);
    DocC.Caption := 'Document C';
    Host.Host(DocC);
    Check(Host.DocumentCount = 2, 'an ownerless document is hosted');
    DocC.Free;
    Application.ProcessMessages;
    Check(Host.DocumentCount = 1,
      'freeing an ownerless document without closing it removes its tab');

    DocB.Free;
    Application.ProcessMessages;
    Check(Host.DocumentCount = 0, 'and freeing the last one empties the host');
    Check(Host.ActiveDocument = nil, 'leaving no dangling active document');
  finally
    Shell.Free;
  end;
end;

{ The shell as the main window actually builds it, rather than the standalone
  host exercised above. A document opened through the IDE has to become a tab;
  before Phase 9 it became another floating window. }
procedure CheckShellWiring;
var
  Probe: TForm;
begin
  WriteLn('Shell:');
  Check(Assigned(Documents), 'the main window provides a document host');
  if not Assigned(Documents) then
    Exit;
  Check(Documents.Pages = frmMarathonMain.pgDocuments,
    'it hosts into the main window''s document area');
  { The dock shows exactly when it holds something. Stated as an invariant
    rather than "it starts hidden": by this point in the run a project has been
    opened, which docks the explorer, so checking the startup state here would
    be checking it in the wrong place. }
  Check(frmMarathonMain.pnlExplorerDock.Visible =
        (frmMarathonMain.pnlExplorerDock.ControlCount > 0),
    'the explorer dock is shown only when something is in it');

  { Hosted through the shell's own page control, not a stand-in for it. A real
    document form is deliberately not built here: this harness has already
    constructed several by this point and doing it again hangs - which is worth
    knowing but is about repeated construction in one process, not about the
    shell. That a document opens as a tab is checked by running the
    application. }
  Probe := TForm.CreateNew(frmMarathonMain);
  try
    Probe.Caption := 'Probe';
    Check(Assigned(Documents.Host(Probe)), 'the shell hosts a document');
    Check(Documents.ActiveDocument = Probe, 'and activates it');
    Check(Probe.Parent = Documents.Pages.ActivePage,
      'reparenting it into the document area');
    Check(frmMarathonMain.pgDocuments.PageCount > 0,
      'the main window''s document area holds it');
  finally
    Probe.Free;
  end;
end;

{ The object explorer docked into the shell rather than floating.

  Uses the real TfrmDatabaseExplorer, not a stand-in: the previous item was
  reported as working on the strength of a stand-in and then died with runtime
  error 217 in the application, because a reparented form behaves differently
  from a plain one. }
procedure CheckExplorerDocks;
var
  Explorer: TfrmDatabaseExplorer;
begin
  WriteLn('Explorer dock:');
  Explorer := nil;
  try
    try
      Explorer := TfrmDatabaseExplorer.Create(nil);
    except
      on E: Exception do
      begin
        WriteLn('  .... skipped: the explorer could not be built here (',
          E.ClassName, ')');
        Exit;
      end;
    end;
    Check(DockInto(Explorer, frmMarathonMain.pnlExplorerDock,
      frmMarathonMain.splExplorer), 'the explorer docks');
    Check(Explorer.Parent = frmMarathonMain.pnlExplorerDock,
      'into the shell''s left panel');
    Check(Explorer.BorderStyle = bsNone, 'without its own window border');
    Check(Explorer.Align = alClient, 'filling the dock');
    { The dock and its splitter are hidden until something is in them, so
      putting the explorer there has to reveal both. }
    Check(frmMarathonMain.pnlExplorerDock.Visible, 'which becomes visible');
    Check(frmMarathonMain.splExplorer.Visible, 'along with its splitter');
    { And it must not have become a document tab by accident. }
    Check(not Documents.IsHosted(Explorer),
      'and is not also opened as a document tab');
  finally
    if Assigned(Explorer) then
    begin
      Explorer.Parent := nil;
      Explorer.Free;
    end;
  end;
end;

{ The explorer's filter box against a tree, rather than the matcher alone -
  what a filter means is covered without a GUI in keyword_test. What matters
  here is that filtering hides the right nodes and, more importantly, never
  strands one: an object that survives must keep a visible path to it, or it
  is filtered into somewhere the user cannot reach. }
procedure CheckExplorerFilter;
var
  Explorer: TfrmDatabaseExplorer;
  Conn, Tables, Views, Cust, Ord, SomeView: TTreeNode;
begin
  WriteLn('Explorer filter:');
  Explorer := nil;
  try
    try
      Explorer := TfrmDatabaseExplorer.Create(nil);
    except
      on E: Exception do
      begin
        WriteLn('  .... skipped: the explorer could not be built here (',
          E.ClassName, ')');
        Exit;
      end;
    end;

    { A tree shaped like a real one: connection, groups, objects. Built by hand
      so the check does not need a database. }
    Explorer.tvDatabase.Items.Clear;
    Conn := Explorer.tvDatabase.Items.Add(nil, 'MyConnection');
    Tables := Explorer.tvDatabase.Items.AddChild(Conn, 'Tables');
    Cust := Explorer.tvDatabase.Items.AddChild(Tables, 'CUSTOMERS');
    Ord := Explorer.tvDatabase.Items.AddChild(Tables, 'ORDERS');
    Views := Explorer.tvDatabase.Items.AddChild(Conn, 'Views');
    SomeView := Explorer.tvDatabase.Items.AddChild(Views, 'CUSTOMER_VIEW');

    Explorer.edFilter.Text := '';
    Explorer.ApplyTreeFilter;
    Check(Cust.Visible and Ord.Visible and SomeView.Visible,
      'an empty filter shows everything');

    Explorer.edFilter.Text := 'cust';
    Explorer.ApplyTreeFilter;
    Check(Cust.Visible, 'a matching table stays');
    Check(not Ord.Visible, 'a table that does not match goes');
    Check(SomeView.Visible, 'a matching view stays');
    { The path has to survive with them, or the objects are unreachable. }
    Check(Tables.Visible and Views.Visible and Conn.Visible,
      'and the groups and connection above them stay visible');

    Explorer.edFilter.Text := 'table:cust';
    Explorer.ApplyTreeFilter;
    Check(Cust.Visible, 'a type-qualified filter keeps the right object');
    Check(not SomeView.Visible, 'and drops one of the wrong type');
    Check(not Views.Visible, 'along with the group that is now empty');

    Explorer.edFilter.Text := 'zzz_nothing_matches';
    Explorer.ApplyTreeFilter;
    Check(not Cust.Visible and not SomeView.Visible,
      'a filter matching nothing hides the objects');

    { And it has to be reversible - a filter box is typed into and cleared. }
    Explorer.edFilter.Text := '';
    Explorer.ApplyTreeFilter;
    Check(Cust.Visible and Ord.Visible and SomeView.Visible,
      'clearing the filter brings everything back');
  finally
    if Assigned(Explorer) then
    begin
      Explorer.Parent := nil;
      Explorer.Free;
    end;
  end;
end;

{ SQL text and its results on screen together.

  Marathon used to put results on a tab of their own, so seeing them meant
  leaving the statement behind. This is the arrangement the VS Code extension
  uses and the point of the item: editor above, results below, a splitter
  between them. }
procedure CheckResultsUnderEditor;
var
  F: TfrmSQLForm;
begin
  WriteLn('Results under the editor:');
  F := TfrmSQLForm.Create(nil);
  try
    Check(F.nbResults.Parent = F.edSQLStatement.Parent,
      'the results share the editor''s tab');
    Check(F.nbResults.Align = alBottom, 'sitting below it');
    Check(F.edSQLStatement.Align = alClient, 'with the editor taking the rest');
    Check(Assigned(F.splResults) and (F.splResults.Parent = F.nbResults.Parent),
      'and a splitter between them');
    { Both on screen at once is the whole point, so it is asserted rather than
      inferred from the alignments. }
    Check(F.nbResults.Visible and F.edSQLStatement.Visible,
      'both are visible at the same time');

    { The menu guards used to ask which tab was active. They now ask where the
      focus is, so they must not claim the results have it when nothing does. }
    Check(not F.ResultsHaveFocus,
      'the results do not claim focus when nothing has it');
  finally
    F.Free;
  end;
end;

{ The command palette against the application's real action list.

  What a query matches is decided without a GUI in keyword_test; what matters
  here is that it finds the commands that actually exist, narrows as you type,
  and refuses to run one that cannot run. }
{ The designer is only worth having if it can be reached.

  Everything else about it is checked directly - construct the form, call
  LoadTable. That is exactly what a user cannot do: they get there through the
  tree's context menu, which is streamed from an .lfm and silently does nothing
  if the item is not bound to the action. }
procedure CheckDesignTableReachable;
var
  Idx: Integer;
  Action: TContainedAction;
  Found: TCustomAction;
  MenuFound: Boolean;

  { Depth-first, because the item sits inside the popup's item tree rather than
    at its top level. }
  function BoundSomewhere(Item: TMenuItem): Boolean;
  var
    N: Integer;
  begin
    Result := Item.Action = Found;
    if Result then
      Exit;
    for N := 0 to Item.Count - 1 do
      if BoundSomewhere(Item.Items[N]) then
        Exit(True);
  end;

begin
  WriteLn('Table designer is reachable:');
  Found := nil;
  for Idx := 0 to frmMarathonMain.actMain.ActionCount - 1 do
  begin
    Action := frmMarathonMain.actMain.Actions[Idx];
    if (Action is TCustomAction) and (Action.Name = 'ObjectDesignTable') then
      Found := TCustomAction(Action);
  end;
  Check(Assigned(Found), 'the Design Table action is in the action list');
  if not Assigned(Found) then
    Exit;
  { Which also puts it in the command palette, since that reads the same list. }
  Check(Assigned(Found.OnExecute), 'it has something to run');
  Check(Pos('Design', CommandDisplayName(Found.Caption)) > 0,
    'and a caption that finds it by typing "design"');

  MenuFound := False;
  for Idx := 0 to dmMenus.mnuTree.Items.Count - 1 do
    if BoundSomewhere(dmMenus.mnuTree.Items[Idx]) then
      MenuFound := True;
  Check(MenuFound, 'the object tree''s context menu offers it');
end;

{ Printing, which until now has been a no-op showing "Printing is not
  available in this build".

  Pagination itself is checked in keyword_test without a printer or a
  widgetset. What needs a display is the preview: that its .lfm streams, that
  it can be handed a document and render a page without a printer configured -
  the machine running this has none - and that the page navigation the toolbar
  has always offered is now actually wired to something. }
procedure CheckPrintPreview;
var
  F: TfrmPrintPreview;
  Doc: TPrintDocument;
  Printed: TPrintedDocument;
  Bmp: TBitmap;
  Idx, Ink, WideW: Integer;
begin
  WriteLn('Print preview:');

  Doc := TPrintDocument.Create('Harness Report');
  try
    Doc.AddTitle('A Report');
    for Idx := 1 to 120 do
      Doc.AddText('line ' + IntToStr(Idx));
    Printed := PaginateDocument(Doc, 40, 80);
  finally
    Doc.Free;
  end;
  Check(Printed.PageCount > 1, 'the harness document runs to several pages');

  try
    F := TfrmPrintPreview.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the preview .lfm streams (' + E.ClassName + ': ' + E.Message + ')');
      Printed.Free;
      Exit;
    end;
  end;
  try
    Check(True, 'the preview .lfm streams');
    { Handed over, not copied - the preview frees it. }
    F.LoadDocument(Printed, 80);

    { Navigation. Every one of these handlers used to be an empty body, so the
      buttons moved nothing. }
    F.actNextExecute(nil);
    Check(Pos('Page 2', F.stsPreview.Panels[0].Text) > 0,
      'Next moves to the second page');
    F.actLastExecute(nil);
    Check(Pos('Page ' + IntToStr(F.PageCount), F.stsPreview.Panels[0].Text) > 0,
      'Last moves to the end');
    F.actNextExecute(nil);
    Check(Pos('Page ' + IntToStr(F.PageCount), F.stsPreview.Panels[0].Text) > 0,
      'and Next past the end stays there rather than running off it');
    F.actFirstExecute(nil);
    Check(Pos('Page 1 ', F.stsPreview.Panels[0].Text) > 0, 'First comes back');
    F.actPreviousExecute(nil);
    Check(Pos('Page 1 ', F.stsPreview.Panels[0].Text) > 0,
      'and Previous before the start stays there');

    { The two zoom buttons, whose handlers were empty bodies: the toolbar has
      always offered Full Page and Page Width and neither did anything. They
      size the sheet inside the scroll box, so what changes is the paint box. }
    F.Width := 760;
    F.Height := 520;
    F.btnPageWidthClick(nil);
    WideW := F.PaperWidth;
    F.btnFullPageClick(nil);
    Check(F.PaperWidth > 0, 'Full Page gives the sheet a size');
    Check(WideW > 0, 'and so does Page Width');
    { Page Width fills the window and lets the page run off the bottom; Full
      Page fits the whole sheet, so it must be the narrower of the two. }
    Check(F.PaperWidth < WideW,
      'and Full Page is narrower than Page Width, as fitting the height requires');

    { Rendering, onto a bitmap rather than the screen so the check can look at
      what came out. This is the part that needs no printer: the machine
      running the tests has none, and the preview still has to work. }
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(600, 850);
      Bmp.Canvas.Brush.Color := clWhite;
      Bmp.Canvas.FillRect(0, 0, Bmp.Width, Bmp.Height);
      RenderPage(Bmp.Canvas, F.CurrentPage, Rect(20, 20, 580, 830), 80);
      { Something was actually drawn. A renderer that silently drew nothing
        would pass every other check here. }
      Ink := 0;
      for Idx := 20 to 400 do
        if Bmp.Canvas.Pixels[Idx, 30] <> clWhite then
          Inc(Ink);
      Check(Ink > 0, 'a page renders ink onto the canvas');
    finally
      Bmp.Free;
    end;
  finally
    F.Free;
  end;
end;

{ The keybinding editor, which the Options dialog has offered a button for
  since the port began and which has done nothing at all - the component it
  needed went with the rest of rmControls.

  What a shortcut is called and which commands clash is checked in
  keyword_test without a widgetset. This is the form: that it lists the real
  action list, that a keystroke in the capture box becomes a binding, that the
  clash is named rather than merely counted, and that OK and Cancel differ. }
procedure CheckKeyBindingEditor;
var
  F: TfrmKeyBindings;
  Idx, Rows, Filtered: Integer;
  Action, Other: TCustomAction;
  Key: Word;
  Saved, WasShortCut: Word;
  Name: String;

  { Finds the grid row showing a given command, or -1. }
  function RowOf(const ACaption: String): Integer;
  var
    R: Integer;
  begin
    Result := -1;
    for R := 1 to F.grdKeys.RowCount - 1 do
      if Pos(AnsiUpperCase(ACaption), AnsiUpperCase(F.grdKeys.Cells[0, R])) > 0 then
        Exit(R);
  end;

begin
  WriteLn('Keybinding editor:');
  try
    F := TfrmKeyBindings.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the editor .lfm streams (' + E.ClassName + ': ' + E.Message + ')');
      Exit;
    end;
  end;
  try
    Check(Assigned(F.grdKeys) and Assigned(F.edCapture) and Assigned(F.lblConflict),
      'the editor .lfm streams its grid, capture box and conflict line');

    F.LoadFrom(frmMarathonMain.actMain);
    Check(F.Map.Count > 20,
      'it reads the application''s commands (' + IntToStr(F.Map.Count) + ')');
    Rows := F.grdKeys.RowCount - 1;
    Check(Rows = F.Map.Count, 'and shows every one of them');

    { Every action, including any with no caption at all, must be identifiable
      - a blank row cannot be rebound. }
    for Idx := 1 to F.grdKeys.RowCount - 1 do
      if Trim(F.grdKeys.Cells[0, Idx]) = '' then
      begin
        Check(False, 'row ' + IntToStr(Idx) + ' has no command name');
        Break;
      end;

    { Filtering, which is how a list this long is usable at all. }
    F.edFilter.Text := 'connection';
    F.edFilterChange(nil);
    Filtered := F.grdKeys.RowCount - 1;
    Check((Filtered > 0) and (Filtered < Rows),
      'the filter narrows the list (' + IntToStr(Filtered) + ' of ' +
      IntToStr(Rows) + ')');
    F.edFilter.Text := 'zzz not a command';
    F.edFilterChange(nil);
    Check(F.grdKeys.RowCount = 1, 'a filter matching nothing leaves nothing');
    { And with nothing selectable, a keystroke must not go anywhere. }
    F.AssignToSelected(Ord('J') or kbCtrl);
    Check(True, 'assigning with nothing selected does not raise');
    F.edFilter.Text := '';
    F.edFilterChange(nil);
    Check(F.grdKeys.RowCount - 1 = Rows, 'and clearing it brings them all back');

    { Capturing a keystroke, through the handler the keyboard reaches. }
    F.grdKeys.Row := 1;
    F.grdKeysSelection(nil, 0, 1);
    Name := F.grdKeys.Cells[0, 1];
    Check(Trim(F.lblCommand.Caption) <> '', 'selecting a row names the command');

    Key := Ord('J');
    F.edCaptureKeyDown(nil, Key, [ssCtrl]);
    Check(Key = 0, 'the keystroke is swallowed, so the box does not also type it');
    Check(F.edCapture.Text = 'Ctrl+J', 'and shows what was pressed');
    Check(F.grdKeys.Cells[2, 1] = 'Ctrl+J', 'and the grid row updates');

    { A modifier on its own is half a keystroke - the user is still pressing -
      and must not wipe what is there. }
    Key := VK_CONTROL;
    F.edCaptureKeyDown(nil, Key, [ssCtrl]);
    Check(F.edCapture.Text = 'Ctrl+J', 'a modifier alone does not clear the binding');

    { Clearing deliberately. }
    F.btnClearClick(nil);
    Check(F.edCapture.Text = '', 'the No Shortcut button clears it');

    { A clash has to be named. Two commands are given the same key, and the
      second must say which one already has it. }
    Key := Ord('K');
    F.grdKeys.Row := 1;
    F.grdKeysSelection(nil, 0, 1);
    F.edCaptureKeyDown(nil, Key, [ssCtrl, ssShift]);
    F.grdKeys.Row := 2;
    F.grdKeysSelection(nil, 0, 2);
    Key := Ord('K');
    F.edCaptureKeyDown(nil, Key, [ssCtrl, ssShift]);
    Check(Pos('Already used by', F.lblConflict.Caption) > 0,
      'a shortcut already in use is reported');
    { Named, not merely counted - "already in use" leaves the user hunting. }
    Check(Length(Trim(F.lblConflict.Caption)) > Length('Already used by '),
      'and says which command has it');
    { Shown, not refused: which of the two should move is the user''s call, and
      refusing the keystroke would make swapping two shortcuts impossible. }
    Check(F.grdKeys.Cells[2, 2] = 'Ctrl+Shift+K',
      'and the binding is still made rather than refused');
  finally
    F.Free;
  end;

  { Applying to the real action list, and the difference between OK and
    Cancel. Done on a copy of the shortcut so the running application is put
    back exactly as it was. }
  Action := nil;
  for Idx := 0 to frmMarathonMain.actMain.ActionCount - 1 do
    if frmMarathonMain.actMain.Actions[Idx] is TCustomAction then
    begin
      Action := TCustomAction(frmMarathonMain.actMain.Actions[Idx]);
      Break;
    end;
  if not Assigned(Action) then
  begin
    Check(False, 'the application has an action to test against');
    Exit;
  end;
  WasShortCut := Action.ShortCut;

  F := TfrmKeyBindings.Create(nil);
  try
    F.LoadFrom(frmMarathonMain.actMain);
    F.Map.Assign_(Action.Name, Ord('Y') or kbCtrl or kbAlt);
    Check(Action.ShortCut = WasShortCut,
      'changing the map alone leaves the action alone, so Cancel can work');
    F.ApplyTo(frmMarathonMain.actMain);
    Check(Action.ShortCut = (Ord('Y') or kbCtrl or kbAlt),
      'and applying puts the new shortcut onto the action');
    Check(F.Map.ChangedCount = 1, 'with one command reported as changed');

    { Only the difference is saved, so a command whose built-in shortcut
      changes in a later build picks the new one up. }
    Saved := 0;
    Check(Pos(Action.Name, F.Map.SaveToText) > 0, 'the change is what gets saved');
    F.Map.ResetAll;
    F.ApplyTo(frmMarathonMain.actMain);
    Check(Action.ShortCut = WasShortCut, 'and Reset All puts it back');
    Check(F.Map.SaveToText = '', 'leaving nothing to save');
  finally
    F.Free;
  end;
  { Whatever happened above, the running application is left as it was. }
  Action.ShortCut := WasShortCut;
  Check(Action.ShortCut = WasShortCut, 'the application is left as it was found');
end;

{ Code templates and the debugger's gutter glyphs - the last two things the
  reduced editor wrapper could not do.

  What a template expands to is checked in keyword_test without an editor.
  These are the parts that need one: that Ctrl+J in a real editor replaces the
  word with the body and leaves the caret where the template asked, that the
  Options tab lists and edits the templates rather than looking complete and
  holding nothing, and that a glyph put on a line is actually there. }
{ KeyDown is protected, as it should be - it is the editor's own business, not
  something callers poke. A descendant declared here reaches it without
  widening the real class's interface just for a test. }
type
  TEditorUnderTest = class(TSyntaxMemoWithStuff2);

procedure CheckCodeTemplates;
var
  Ed: TEditorUnderTest;
  Opts: TfrmMarathonOptions;
  Key: Word;
  T: TCodeTemplate;
  Before: Integer;
begin
  WriteLn('Code templates:');

  GlobalCodeTemplates.Clear;
  T := GlobalCodeTemplates.Add('sel', 'Select all rows');
  T.Body.Add('select *');
  T.Body.Add('from |');

  Ed := TEditorUnderTest.Create(nil);
  try
    { A parent, because SynEdit needs a handle before its caret can be moved. }
    Ed.Parent := frmMarathonMain;
    Ed.Lines.Text := 'sel';
    Ed.CaretY := 1;
    Ed.CaretX := 4;

    Key := Ord('J');
    Ed.KeyDown(Key, [ssCtrl]);
    Check(Key = 0, 'Ctrl+J on a template name is swallowed');
    Check(Pos('select *', Ed.Lines.Text) > 0, 'and the template is expanded');
    { Replaced, not appended - otherwise the abbreviation is left behind in
      front of what it expanded to. }
    Check(Pos('sel' + #13, Ed.Lines.Text) = 0, 'the name it replaced is gone');
    Check(Ed.CaretY = 2, 'the caret lands on the marked line');
    Check(Ed.CaretX = 6, 'at the marked column');

    { One undo step, not one per line: an expansion the user did not want must
      come back out in a single press. }
    Ed.Undo;
    Check(Trim(Ed.Lines.Text) = 'sel', 'and one Undo takes the whole expansion back');

    { Indentation. The same template inside a block lines up with where it was
      typed, or every expansion has to be re-indented by hand. }
    Ed.Lines.Text := '    sel';
    Ed.CaretY := 1;
    Ed.CaretX := 8;
    Key := Ord('J');
    Ed.KeyDown(Key, [ssCtrl]);
    Check(Pos('    from', Ed.Lines.Text) > 0, 'a template indents to where it was typed');

    { A word that names no template must be left alone, so Ctrl+J still
      reaches anything else that wants it. }
    Ed.Lines.Text := 'notatemplate';
    Ed.CaretY := 1;
    Ed.CaretX := 13;
    Before := Length(Ed.Lines.Text);
    Key := Ord('J');
    Ed.KeyDown(Key, [ssCtrl]);
    Check(Length(Ed.Lines.Text) = Before, 'an unknown word expands to nothing');
    Check(Key <> 0, 'and the keystroke is passed on rather than swallowed');

    { The debugger's blue dots. Every call site was an empty statement, so a
      procedure opened for debugging looked like one that could not be. }
    Ed.Lines.Text := 'line one'#13#10'line two'#13#10'line three';
    Ed.ClearQuestGlyphs;
    Check(Ed.QuestGlyphCount = 0, 'an editor starts with no glyphs');
    Ed.AddQuestGlyph(2);
    Check(Ed.HasQuestGlyph(2), 'a glyph can be put on a line');
    Check(not Ed.HasQuestGlyph(1), 'and is only on that line');
    Check(Ed.QuestGlyphCount = 1, 'and is counted once');
    { The debugger redraws the whole set whenever it refreshes, so asking
      twice must not stack them up. }
    Ed.AddQuestGlyph(2);
    Check(Ed.QuestGlyphCount = 1, 'asking for the same line twice adds one glyph');
    Ed.AddQuestGlyph(3);
    Check(Ed.QuestGlyphCount = 2, 'a second line adds a second');
    Ed.RemoveQuestGlyph(2);
    Check(not Ed.HasQuestGlyph(2), 'a glyph can be taken off again');
    Check(Ed.HasQuestGlyph(3), 'leaving the others alone');
    Ed.ClearQuestGlyphs;
    Check(Ed.QuestGlyphCount = 0, 'and they can all be cleared');
  finally
    Ed.Parent := nil;
    Ed.Free;
  end;

  { The Options tab, which has looked complete and held nothing. }
  try
    Opts := TfrmMarathonOptions.Create(nil);
  except
    on E: Exception do
    begin
      Check(False, 'the Options dialog streams (' + E.ClassName + ': ' + E.Message + ')');
      Exit;
    end;
  end;
  try
    Opts.RefreshTemplateList;
    Check(Opts.lstTemplates.Items.Count = GlobalCodeTemplates.Count,
      'the SQL Insight tab lists the templates (' +
      IntToStr(Opts.lstTemplates.Items.Count) + ')');
    Check(Opts.lstTemplates.Items[0].Caption = 'sel', 'by name');
    Check(Opts.lstTemplates.Items[0].SubItems[0] = 'Select all rows',
      'and description');

    { Selecting one shows its body. }
    Opts.lstTemplates.Items[0].Selected := True;
    Opts.lstTemplatesChange(nil, Opts.lstTemplates.Items[0], ctState);
    Check(Pos('select *', Opts.edSQLInsightCode.Lines.Text) > 0,
      'selecting a template shows its body');

    { Editing the body writes back to the template, not to whichever one
      happens to be selected later. }
    Opts.edSQLInsightCode.Lines.Text := 'select 1 from rdb$database';
    Opts.edSQLInsightCodeChange(nil);
    Check(Pos('rdb$database', GlobalCodeTemplates.FindByName('sel').Body.Text) > 0,
      'editing the body writes back to the template');

    { And re-selecting must not write the pane back over it - the handler
      fires on deselection too, with the item that was let go. }
    Opts.lstTemplatesChange(nil, Opts.lstTemplates.Items[0], ctState);
    Check(Pos('rdb$database', GlobalCodeTemplates.FindByName('sel').Body.Text) > 0,
      'and re-selecting it does not overwrite what was just typed');
  finally
    Opts.Free;
  end;
end;

procedure CheckCommandPalette;
var
  P: TfrmCommandPalette;
  AllCommands, Narrowed: Integer;
  Idx, Disabled: Integer;
  Action: TCustomAction;
begin
  WriteLn('Command palette:');
  P := TfrmCommandPalette.Create(nil);
  try
    P.AddActions(frmMarathonMain.actMain);
    AllCommands := P.VisibleCount;
    Check(AllCommands > 20, 'it finds the application''s commands (' +
      IntToStr(AllCommands) + ')');

    P.edQuery.Text := 'connection';
    P.edQueryChange(nil);
    Narrowed := P.VisibleCount;
    Check(Narrowed > 0, 'a query finds something');
    Check(Narrowed < AllCommands, 'and narrows the list');

    P.edQuery.Text := 'zzz not a command at all';
    P.edQueryChange(nil);
    Check(P.VisibleCount = 0, 'a query matching nothing leaves nothing');
    Check(P.ChosenAction = nil, 'and offers nothing to run');
    Check(not P.ExecuteChosen, 'so nothing is executed');

    P.edQuery.Text := '';
    P.edQueryChange(nil);
    Check(P.VisibleCount = AllCommands, 'clearing the query restores the list');

    { A disabled command must be listed - hiding it sends the user hunting for
      something that exists - but must not run. Most commands are disabled with
      no project open, so there is certainly one to find. }
    Disabled := -1;
    for Idx := 0 to P.VisibleCount - 1 do
    begin
      Action := TCustomAction(P.lstCommands.Items.Objects[Idx]);
      if Assigned(Action) and not Action.Enabled then
      begin
        Disabled := Idx;
        Break;
      end;
    end;
    if Disabled >= 0 then
    begin
      P.lstCommands.ItemIndex := Disabled;
      Check(Assigned(P.ChosenAction), 'a command that cannot run is still listed');
      Check(not P.ExecuteChosen, 'but is not executed');
    end
    else
      WriteLn('  .... no disabled command here to check that path with');
  finally
    P.Free;
  end;
end;

{ Connections gathered under a heading per environment.

  The point of the check is not the headings but everything that reads the
  connection list: ConnectionCount, Connections[] and ConnectionByName were all
  defined as the direct children of the Connections node, so adding a level
  under it would have emptied the connection list everywhere - including the
  project file, silently, on the next save. }
procedure CheckConnectionGrouping;
var
  Cache: TMarathonProjectDatabaseCache;
  A, B, C: TMarathonCacheConnection;
  Root, Node: TMarathonTreeNode;
  Groups: Integer;
begin
  WriteLn('Connection grouping:');
  Cache := MarathonIDEInstance.CurrentProject.Cache;

  A := Cache.AddConnectionInternal;
  A.Caption := 'GroupProd';
  A.Environment := envProduction;
  B := Cache.AddConnectionInternal;
  B.Caption := 'GroupDev';
  B.Environment := envDevelopment;
  C := Cache.AddConnectionInternal;
  C.Caption := 'GroupDev2';
  C.Environment := envDevelopment;

  Cache.RegroupConnections;

  { What every caller depends on, checked first. }
  Check(Cache.ConnectionCount >= 3, 'grouping leaves the connection count intact (' +
    IntToStr(Cache.ConnectionCount) + ')');
  Check(Cache.ConnectionByName['GroupProd'] = A, 'a grouped connection is still found by name');
  Check(Cache.ConnectionByName['GroupDev2'] = C, 'including one in a group of several');
  Check(Cache.Connections[0] <> nil, 'and by index');

  { And then the headings themselves. }
  Root := Cache.Cache.FindPathNode(#2 + 'Connections');
  Groups := 0;
  Node := Root.GetFirstChild;
  while Assigned(Node) do
  begin
    if TObject(Node.Data) is TMarathonCacheConnectionGroup then
      Inc(Groups);
    Node := Node.GetNextSibling;
  end;
  Check(Groups >= 2, 'connections of different environments get separate headings (' +
    IntToStr(Groups) + ')');
  Check(A.ContainerNode.Parent <> Root, 'and the connections move under them');

  { Grouping is presentation, so doing it twice must not multiply headings or
    lose a connection - it runs again whenever an environment changes. }
  Cache.RegroupConnections;
  Groups := 0;
  Node := Root.GetFirstChild;
  while Assigned(Node) do
  begin
    if TObject(Node.Data) is TMarathonCacheConnectionGroup then
      Inc(Groups);
    Node := Node.GetNextSibling;
  end;
  Check(Groups >= 2, 'regrouping does not multiply the headings (' +
    IntToStr(Groups) + ')');
  Check(Cache.ConnectionByName['GroupProd'] = A,
    'and the connections survive it');
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
  CheckDocumentHost;
  CheckShellWiring;
  CheckExplorerDocks;
  CheckExplorerFilter;
  CheckResultsUnderEditor;
  CheckCommandPalette;
  CheckKeyBindingEditor;
  CheckCodeTemplates;
  CheckPrintPreview;
  CheckDesignTableReachable;
  CheckConnectionGrouping;
  CheckHighDPIScaling;
  CheckCompletionWiring;
  CheckEditorSearch;
  CheckEditorsAllowAutoTransactions;
  CheckProjectSaveWithRememberedPassword;
  CheckTableEditorAgainstDatabase(
    GetEnvironmentVariable('MARATHON_TEST_DB'),
    GetEnvironmentVariable('MARATHON_TEST_USER'),
    GetEnvironmentVariable('MARATHON_TEST_PASSWORD'));

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' form check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: forms load and the expected controls are wired up.');
end.
