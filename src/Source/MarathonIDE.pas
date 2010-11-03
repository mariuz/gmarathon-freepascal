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
// $Id: MarathonIDE.pas,v 1.16 2006/10/22 06:04:28 rjmills Exp $

unit MarathonIDE;

interface

{$I compilerdefines.inc}

uses
	Classes, Windows, SysUtils, Forms, Controls, Dialogs, Registry, Menus, CheckLst,
	StdCtrls, ActnList, Graphics, Chart, DB, ComObj,
	{$IFDEF D6_or_higher}
	Variants,
	{$ENDIF}
	IBODataset,
	IB_Components,
	rmTreeNonView,
	SyntaxMemoWithStuff2,
	MarathonInternalInterfaces,
	MarathonProjectCache,
	MarathonProjectCacheTypes,
	GimbalToolsAPI,
	GimbalToolsAPIImpl,
	GSSRegistry,
	IBDebuggerVM,
	PluginsDialog;

type
	TMarathonIDE = class(TComponent, IMarathonIDE, IGimbalIDEServices)
	private
		FPluginsDialog: TfrmPlugins;
		FScreenActiveForm: IMarathonForm;
		FCurrentProject: TMarathonProject;
		FMainForm: IMarathonMainForm;
		FDlgSaveProject: TSaveDialog;
		FDlgOpenProject: TOpenDialog;
		FDlgOpenFile: TOpenDialog;
		FPrnSetup: TPrinterSetupDialog;
		FInternalActionList: TActionList;
		FMenus: TGimbalIDEMenus;
		FPlugins: TList;
		FPluginCommandObjects: TList;
		FPluginMenuObjects: TList;
		FIDENotifierChain: TList;
		FWindowList: TList;
		FWindowListChanged: Boolean;
		FFileCounter: Integer;
		FDebuggerVM: TIBDebuggerVM;
		FProjectDir: String;
		procedure CacheEventHandler(Sender: TObject; Event: TGSSCacheOp; Item: TMarathonCacheBaseNode);
		procedure SaveWindowStates;
		procedure RestoreWindowStates;
		procedure SetMainForm(const Value: IMarathonMainForm);
		function GetRecentFileData: String;
		procedure AddToRecentProjects(FileName: String);
		procedure SetWindowListChanged(const Value: Boolean);
		procedure CreateProjectFolder(Item: TMarathonCacheBaseNode);
		function CheckConnected(Connection: String): Boolean;
		procedure DoConnect(Item: TMarathonCacheBaseNode);
		procedure DoDisconnect(Item: TMarathonCacheBaseNode);
		procedure DoDelete(Item: TMarathonCacheBaseNode);
		procedure UpdateScriptRecorderHost;
		procedure DisconnectHandler(Sender: TObject; ConnectionName: String);
	public
		property CurrentProject: TMarathonProject read FCurrentProject write FCurrentProject;
		property ScreenActiveForm: IMarathonForm read FScreenActiveForm write FScreenActiveForm;
		property MainForm: IMarathonMainForm read FMainForm write SetMainForm;
		function NewProject(ShowOptions: Boolean): Boolean;
		function GetNewFileName: String;
		procedure BringWindowToFront(Index: Integer);
		property WindowList: TList read FWindowList write FWindowList;
		property RecentFileData: String read GetRecentFileData;
		property WindowListChanged: Boolean read FWindowListChanged write SetWindowListChanged;
		function GetBrowser: IMarathonBrowser;
		procedure OpenProject(ProjName: String);
		procedure DoProperties(Item: TMarathonCacheBaseNode);
		procedure DoAboutBox;
		procedure DoViewBreakPoints;
		procedure DoViewWatches;
		procedure DoViewCallStack;
		procedure DoViewLocalVars;
		procedure RefreshForms;
		procedure DoStatus(Status: String);
		procedure CloseDroppedWindow(Connection: String; ObjectName: String);
		procedure RecordToScript(Script: String; ConnectionName: String);
		procedure AddMenuToMainForm(MenuItem: TMenuItem);
		function GetHintTextForToken(Token: String; Connection: String): String;
		procedure NavigateToLink(Token: String; Connection: String);
		procedure GetTableColumnsEvent(Sender: TObject; TableName: String; Connection: String; List: TCheckListBox);
		procedure GetTablesEvent(Sender: TObject; SysTables: Boolean; Connection: String; List: TListBox);
		procedure PrintSyntaxMemo(TSM: TSyntaxMemoWithStuff2; Preview: Boolean; Title: String);
		procedure PrintDataSet(DataSet: TDataSet; Preview: Boolean; Title: String);
		procedure PrintPerformanceAnalysis(Preview: Boolean; Query: TStrings; Dataset: TDataSet; Chart: TChart);
		procedure PrintQueryPlan(Preview: Boolean; Query: TStrings; Plan: String; GPlan: TMetafile);
		procedure PrintLinesWithTitle(Lines: TStrings; PageTitle: String; Preview: Boolean; Title: String);
		procedure PrintDatabase(Preview: Boolean; ConnectionName: String);
		procedure PrintDomain(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintDomains(Preview: Boolean; ConnectionName: String);
		procedure PrintException(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintExceptions(Preview: Boolean; ConnectionName: String);
		procedure PrintGenerator(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintGenerators(Preview: Boolean; ConnectionName: String);
		procedure PrintTable(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTables(Preview: Boolean; ConnectionName: String);
		procedure PrintTableStruct(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTableConstraints(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTableIndexes(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTableTriggers(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTrigger(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintTriggers(Preview: Boolean; ConnectionName: String);
		procedure PrintSP(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintSPs(Preview: Boolean; ConnectionName: String);
		procedure PrintUDF(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintUDFs(Preview: Boolean; ConnectionName: String);
		procedure PrintView(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintViews(Preview: Boolean; ConnectionName: String);
		procedure PrintViewSource(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintViewStruct(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintViewTriggers(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintObjectDependencies(Preview: Boolean; ObjectName: String; ConnectionName: String);
		procedure PrintObjectDoco(Preview: Boolean; ObjectName: String; ConnectionName: String;
			ObjectType: TGSSCacheType);
		procedure PrintObjectDRUIMatrix(Preview: Boolean; ObjectName: String; ConnectionName: String;
			ObjectType: TGSSCacheType);
		procedure PrintObjectDDL(Preview: Boolean; ObjectName: String; ConnectionName: String;
			ObjectType: TGSSCacheType);
		procedure PrintObjectPerms(Preview: Boolean; ObjectName: String; ConnectionName: String;
			ObjectType: TGSSCacheType);
		procedure LoadPluginFromFile(FileName: String);
		procedure UnLoadPluginByName(Name: String);
		function GetMatchingTableEditor(TableName: String): IMarathonTableEditor;
		procedure CLoseDroppedTrigger(TriggerName: String);
		procedure UnloadPlugins;
		procedure InitPlugins;
		procedure ManagePlugins;
		procedure SavePluginStates;
		procedure RefreshPluginsDialog;
		procedure ProcessInternalLink(URL: String);
		property PluginMenuObjects: TList read FPluginMenuObjects write FPluginMenuObjects;
		function CloseQuery: Boolean;
		procedure FileNewProject;
		function FileSaveProject: Boolean;
		function FileSaveProjectAs: Boolean;
		function FileCloseProject: Boolean;
		procedure FileOpenProject;
		procedure FileCreateDatabase;
		procedure FilePrintSetup;
		procedure ProjectNewConnection;
		procedure ProjectNewServer;
    procedure FileNewObject;
    function FileOpenFile: TForm;
    function FileOpenNamedFile(FileName: String): TForm;
    procedure FileOpenDatabaseObject;
    procedure ViewViewBrowser;
    procedure ViewViewNextWindow;
    procedure ProjectProjectOptions;
    procedure ToolsSQLEditor;
		procedure ToolsMetadataExtract;
    procedure ToolsSearchMetadata;
    procedure ToolsSyntaxHelp;
    procedure ToolsCodeSnippets;
    procedure ToolsSQLTrace;
    procedure ToolsEnvironmentOptions;
    procedure ToolsUserEditor;
    procedure ScriptScriptRecording;
    procedure WindowWindowList;
    procedure WindowCloseAllWindows;

    procedure RefreshCodeSnippets(Snip:string);

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

		//Object Editors
		procedure NewDomain(Connection: String);
    function OpenDomain(DomainName: String; COnnection: String): TForm;
    procedure NewProcedure(Connection: String);
		function DebugOpenProcedure(ProcedureName, Connection: String;
			OpenEditor, MakeVisible: Boolean): IMarathonStoredProcEditor;
		function OpenProcedure(ProcedureName: String; Connection: String): TForm;
		procedure NewTrigger(Connection: String);
		procedure NewTriggerWithInfo(Connection: String; TriggerType: String; Table: String);
		function OpenTrigger(TriggerName: String; Connection: String): TForm;
		procedure NewException(Connection: String);
		function OpenException(ExceptionName: String; Connection: String): TForm;
		procedure NewGenerator(Connection: String);
		function OpenGenerator(GeneratorName: String; Connection: String): TForm;
		procedure NewTable(Connection: String);
		function OpenTable(TableName: String; Connection: String): TForm;
		procedure NewView(Connection: String);
		function OpenView(ViewName: String; Connection: String): TForm;
		procedure NewUDF(Connection: String);
		function OpenUDF(UDFName: String; Connection: String): TForm;

		//stuff for external Tools API
		//actual
		procedure RegisteredCommandOnExecute(Sender: TObject);
		procedure RegisteredCommandOnUpdate(Sender: TObject);
		function IDEAddCommand(ThisPlugin: Integer; Name: WideString): IGimbalIDECommand; safecall;
		function IDEGetMenu(MenuType: TGimbalMenuType): IGimbalIDEMenus; safecall;
		function IDEAddSQLEditorKeyPressNotifier(ThisPlugin: Integer; Notifier: IGimbalIDEEditorKeyPressNotifier): Boolean; safecall;
		function IDEGetApplicationHandle: THandle; safecall;
		function IDEGetActiveWindow: IGimbalIDEWindow; safecall;
		procedure IDERecordToScript(ConnectionName: WideString; Script: WideString); safecall;
		function IDEGetProject: IGimbalIDEMarathonProject; safecall;
		function IDECreateMarathonForm: IGimbalIDEMarathonForm;
		//supporting routines
		procedure ProcessKeyPressNotifierChain(Key: Word; Shift: TShiftstate);

		//debugger...
		procedure DoDebuggerEnabled;
		function IsDebuggerEnabled: Boolean;
		function CanDebuggerEnabled: Boolean;
		property DebuggerVM: TIBDebuggerVM read FDebuggerVM write FDebuggerVM;
	end;

var
	MarathonIDEInstance: TMarathonIDE;

implementation

uses
  MarathonMain,
	Login,
	DatabaseManager,
	SyntaxHelp,
	CodeSnippets,
	EditorStoredProcedure,
	EditorTable,
	EditorView,
	EditorTrigger,
	NewObjectDialog,
	SQLForm,
	MarathonOptions,
	EditorException,
	AboutBox,
	WindowList,
	EditorGenerator,
	EditorUDF,
	ScriptEditorHost,
	PrintPreviewForm,
	EditorDomain,
	TipOfTheDay,
	SQLTrace,
	ShellAPI,
	UserEditor,
	DropObject,
	MarathonMasterProperties,
	Globals,
	BaseDocumentForm,
	BaseDocumentDataAwareForm,
	GlobalPrintingRoutines,
	SelectConnectionDialog,
	GSSCreateDatabaseConsts,
	InputDialog,
	MenuModule,
	MarathonToolsAPIDocForm,
	DebugBreakPoints,
	DebugWatches,
	DebugCallStack,
	DebugLocalVariables,
	gssscript_TLB;

type
	TPluginInit = procedure (const ToolServices: IGimbalIDEServices; var ThisPlugin: TPlugin); stdcall;
	TPluginExecute = procedure; stdcall;

{ TMarathonIDE }
procedure TMarathonIDE.FileNewProject;
begin
	if FileCloseProject then
		if NewProject(True) then
		begin
			ProjectNewServer;
			ProjectNewConnection;
		end;
end;

procedure TMarathonIDE.ProjectNewConnection;
begin
	with TfrmMasterProperties.CreateNewConnection(Self) do
		try
			if ShowModal = mrOK then
				UpdateScriptRecorderHost;
		finally
			Free;
		end;
end;

procedure TMarathonIDE.ProjectNewServer;
begin
	with TfrmMasterProperties.CreateNewServer(Self) do
		try
			ShowModal;
		finally
			Free;
		end;
end;

function TMarathonIDE.FileCloseProject: Boolean;
var
	I: Integer;
	DoSave: Boolean;
	F: IMarathonBrowser;

begin
	Result := True;
	if FCurrentProject.Open then
	begin
		DoSave := False;

		if not CloseQuery then
			Exit;

		if FCurrentProject.Modified then
			case MessageDlg('Project has changed - do you wish to save?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
				mrYes:
					DoSave := True;

				mrNo:
					DoSave := False;

				mrCancel:
					begin
						Result := False;
						Exit;
					end;
			end;
		if DoSave then
			if not FileSaveProject then
			begin
				Result := False;
				Exit;
			end;
	end;

	for I := Screen.FormCount - 1 downto 0 do
	begin
		if Screen.Forms[I] is TfrmBaseDocumentDataAwareForm Then
			TfrmBaseDocumentForm(Screen.Forms[i]).ByPassClose;
		if Screen.Forms[I] is TfrmScriptEditorHost Then
			TfrmScriptEditorHost(Screen.Forms[i]).ByPassClose;
		if Screen.Forms[I] is TfrmPrintPreview Then
			TfrmPrintPreview(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmMarathonToolsDocForm Then
			TfrmMarathonToolsDocForm(Screen.Forms[i]).Close;
	end;

  //AC: .Close frees the non visual nodes
//AC: 	FCurrentProject.Close;

	F := GetBrowser;

  //AC: .LoadTree references the non visual nodes when setting to invisible
	if Assigned(F) then
//AC: 		F.LoadTree;
		F.UnloadTree;   //AC:

 	FCurrentProject.Close;

	if Assigned(FMainForm) then
		FMainForm.Caption := 'Marathon';
end;

function TMarathonIDE.NewProject(ShowOptions: Boolean): Boolean;
var
	F: IMarathonBrowser;

begin
  result := false;
	if ShowOptions then
	begin
		with TfrmMasterProperties.CreateNewProject(Self) do
			try
				if ShowModal = mrOK then
				begin
					F := GetBrowser;
					if Assigned(F) then
						F.LoadTree;
				end;
			finally
				Free
			end;
	end
	else
	begin
		FileNewProject;
		Result := True;
	end;
end;

function TMarathonIDE.FileSaveProject: Boolean;
begin
	if Assigned(FCurrentProject) then
	begin
		FDlgSaveProject.InitialDir := gDefProjectDir;
		if FCurrentProject.FileName = '' then
		begin
			FDlgSaveProject.Title := 'Save Project';
			FDlgSaveProject.Filter := 'Marathon Project (*.xmpr)|*.xmpr|All Files (*.*)|*.*';
			FDlgSaveProject.DefaultExt := 'xmpr';
			if FDlgSaveProject.Execute then
				FCurrentProject.FileName := FDlgSaveProject.FileName
			else
			begin
				Result := False;
				Exit;
			end;
		end
		else
    try
			if FileDateToDateTime(FileAge(FCurrentProject.FileName)) > FCurrentProject.TimeStamp then
      begin
			  if MessageDlg('Project file may have changed. Do you wish to overwrite changes?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
				begin
					Result := False;
					Exit;
				end;
      end;
    except
      //do nothing...

    end;

		SaveWindowStates;

		try
			FCurrentProject.SaveToFile(FCurrentProject.FileName);
			FCurrentProject.Modified := False;
      if FileAge(FCurrentProject.FileName) = -1 then
         FCurrentProject.TimeStamp := Now
      else
			   FCurrentProject.TimeStamp := FileDateToDateTime(FileAge(FCurrentProject.FileName));
			Result := True;

			if Assigned(FMainForm) then
				FMainForm.Caption := 'Marathon';

			if Assigned(FMainForm) then
				FMainForm.Caption := FMainForm.Caption + ' - ' + FCurrentProject.FriendlyName;
		except
			on E: Exception do
			begin
				MessageDlg(E.Message, mtError, [mbOK], 0);
				Result := False;
			end;
		end;
	end
	else
		Result := False;
end;

function TMarathonIDE.FileSaveProjectAs: Boolean;
begin
	FDlgSaveProject.Title := 'Save Project As';
	FDlgSaveProject.Filter := 'Marathon Project (*.xmpr)|*.xmpr|All Files (*.*)|*.*';
	FDlgSaveProject.DefaultExt := 'xmpr';
	if FDlgSaveProject.Execute then
	begin
		FCurrentProject.FileName := FDlgSaveProject.FileName;
		Result := FileSaveProject;
	end
	else
		Result := False;
end;

function TMarathonIDE.GetBrowser: IMarathonBrowser;
var
	I: Integer;
	Browser: TfrmDatabaseExplorer;

begin
	Result := nil;
	for i := 0 to Screen.FormCount-1 do
	begin
		if Screen.Forms[I] is TfrmDatabaseExplorer Then
		begin
			Browser := TfrmDatabaseExplorer(Screen.Forms[I]);
			Result := Browser;
			Break;
		end;
	end;
end;

constructor TMarathonIDE.Create(AOwner: TComponent);
begin
	inherited;
	FCurrentProject := TMarathonProject.Create(Self);
	FCurrentProject.Cache.OnCacheEvent := CacheEventHandler;
	FCurrentProject.Cache.OnDatabaseDisconnecting := DisconnectHandler;
	FDlgSaveProject := TSaveDialog.Create(Self);
  FDlgOpenProject := TOpenDialog.Create(Self);
  FDlgOpenFile := TOpenDialog.Create(Self);
	FPrnSetup := TPrinterSetupDialog.Create(Self);
  FInternalActionList := TActionList.Create(Self);
	FIDENotifierChain := TList.Create;
  FMenus := TGimbalIDEMenus.Create(Self);
  FPlugins := TList.Create;
  FPluginCommandObjects := TList.Create;
  FPluginMenuObjects := TList.Create;
  FWindowList := TList.Create;
  FDebuggerVM := TIBDebuggerVM.Create;
end;

destructor TMarathonIDE.Destroy;
begin
  FCurrentProject.Free;
  FDlgSaveProject.Free;
  FDlgOpenProject.Free;
  FdlgOpenFile.Free;
	FPrnSetup.Free;
	FInternalActionList.Free;
	FMenus.Free;
	FPluginCommandObjects.Free;
	FPluginMenuObjects.Free;
	FIDENotifierChain.Free;
	FPlugins.Free;
	FWindowList.Free;
	FDebuggerVM.Free;
	inherited;
end;

procedure TMarathonIDE.CacheEventHandler(Sender: TObject;	Event: TGSSCacheOp; Item: TMarathonCacheBaseNode);
var
	B: IMarathonBrowser;
	Idx: Integer;
	SubItem: TMarathonCacheBaseNode;
	DropObject: TfrmDropObject;
	L: TStringList;
	Extractor: IGSSDDLExtractor;
	ConnectName: String;
	N: TrmTreeNonViewNode;

begin
	case Event of
		opOpen:
			begin
				case Item.CacheType of
					ctDomainHeader,
					ctTableHeader,
					ctViewHeader,
					ctSPHeader,
					ctTriggerHeader,
					ctGeneratorHeader,
					ctExceptionHeader,
					ctUDFHeader:
						begin
							for Idx := 0 to Item.SubItems.Count - 1 do
							begin
								SubItem := TMarathonCacheBaseNode(Item.SubItems[Idx]);
								case SubItem.CacheType of
									ctDomain:
										OpenDomain(SubItem.Caption, TMarathonCacheObject(SubItem).ConnectionName);

									ctSP:
										OpenProcedure(SubItem.Caption, TMarathonCacheObject(SubItem).ConnectionName);

									ctTrigger:
										OpenTrigger(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

									ctException:
										OpenException(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

									ctGenerator:
										OpenGenerator(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

									ctTable:
										OpenTable(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

									ctView:
										OpenView(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

									ctUDF:
										OpenUDF(Item.Caption, TMarathonCacheObject(Item).ConnectionName);
								end;
							end;
						end;

					ctDomain:
						OpenDomain(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctSP:
						OpenProcedure(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTrigger:
						OpenTrigger(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctException:
						OpenException(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctGenerator:
						OpenGenerator(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTable:
						OpenTable(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctView:
						OpenView(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctUDF:
						OpenUDF(Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctRecentItem:
						begin
							case TMarathonCacheRecentItem(Item).ActualCacheType of
								ctDomain:
									OpenDomain(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheRecentItem(Item).ConnectionName);

								ctSP:
									OpenProcedure(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheRecentItem(Item).ConnectionName);

								ctTrigger:
									OpenTrigger(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheRecentItem(Item).ConnectionName);

								ctException:
									OpenException(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheObject(Item).ConnectionName);

								ctGenerator:
									OpenGenerator(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheObject(Item).ConnectionName);

								ctTable:
									OpenTable(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheObject(Item).ConnectionName);

								ctView:
									OpenView(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheObject(Item).ConnectionName);

								ctUDF:
									OpenUDF(TMarathonCacheRecentItem(Item).ObjectName, TMarathonCacheObject(Item).ConnectionName);
							end;
						end;
				end;
			end;

		opDrop:
			begin
				case Item.CacheType of
					ctDomainHeader,
					ctTableHeader,
					ctViewHeader,
					ctSPHeader,
					ctTriggerHeader,
					ctGeneratorHeader,
					ctExceptionHeader,
					ctUDFHeader:
						begin
							L := TStringList.Create;
							try
								for Idx := 0 to Item.SubItems.Count - 1 do
								begin
									SubItem := TMarathonCacheBaseNode(Item.SubItems[Idx]);
									L.AddObject(SubItem.Caption, SubItem);
								end;
								DropObject := TfrmDropObject.CreateDrop(nil, L);
								DropObject.Free;
							finally
								L.Free;
							end;
						end;
				else
					begin
						L := TStringList.Create;
						try
							L.AddObject(Item.Caption, Item);
							DropObject := TfrmDropObject.CreateDrop(nil, L);
							DropObject.Free;
						finally
							L.Free;
						end;
					end;
				end;
			end;

		opNew:
			begin
				case Item.CacheType of
					ctDomain,
					ctDomainHeader:
						NewDomain(TMarathonCacheObject(Item).ConnectionName);

					ctSP,
					ctSPHeader:
						NewProcedure(TMarathonCacheObject(Item).ConnectionName);

					ctTrigger,
					ctTriggerHeader:
						NewTrigger(TMarathonCacheObject(Item).ConnectionName);

					ctException,
					ctExceptionHeader:
						NewException(TMarathonCacheObject(Item).ConnectionName);

					ctGenerator,
					ctGeneratorHeader:
						NewGenerator(TMarathonCacheObject(Item).ConnectionName);

					ctTable,
					ctTableHeader:
						NewTable(TMarathonCacheObject(Item).ConnectionName);

					ctView,
					ctViewHeader:
						NewView(TMarathonCacheObject(Item).ConnectionName);

					ctUDF,
					ctUDFHeader:
						NewUDF(TMarathonCacheObject(Item).ConnectionName);
				end;
			end;

		opProperties:
			DoProperties(Item);

		opConnect:
			DoConnect(Item);

		opDisconnect:
			DoDisconnect(Item);

		opDelete:
			DoDelete(Item);

		opPrint:
			begin
				case Item.CacheType of
					ctConnection:
						PrintDatabase(False, Item.Caption);

					ctDomain:
						PrintDomain(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctDomainHeader:
						PrintDomains(False, TMarathonCacheHeader(Item).ConnectionName);

					ctSP:
						PrintSP(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctSPHeader:
						PrintSPs(False, TMarathonCacheHeader(Item).ConnectionName);

					ctTrigger:
						PrintTrigger(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTriggerHeader:
						PrintTriggers(False, TMarathonCacheHeader(Item).ConnectionName);

					ctException:
						PrintException(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctExceptionHeader:
						PrintExceptions(False, TMarathonCacheHeader(Item).ConnectionName);

					ctGenerator:
						PrintGenerator(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctGeneratorHeader:
						PrintGenerators(False, TMarathonCacheHeader(Item).ConnectionName);

					ctTable:
						PrintTable(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTableHeader:
						PrintTables(False, TMarathonCacheHeader(Item).ConnectionName);

					ctView:
						PrintView(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctViewHeader:
						PrintViews(False, TMarathonCacheHeader(Item).ConnectionName);

					ctUDF:
						PrintUDF(False, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctUDFHeader:
						PrintUDFs(False, TMarathonCacheHeader(Item).ConnectionName);
				end;
			end;

		opPrintPreview:
			begin
				case Item.CacheType of
					ctConnection:
						PrintDatabase(True, Item.Caption);

					ctDomain:
						PrintDomain(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctDomainHeader:
						PrintDomains(True, TMarathonCacheHeader(Item).ConnectionName);

					ctSP:
						PrintSP(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctSPHeader:
						PrintSPs(True, TMarathonCacheHeader(Item).ConnectionName);

					ctTrigger:
						PrintTrigger(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTriggerHeader:
						PrintTriggers(True, TMarathonCacheHeader(Item).ConnectionName);

					ctException:
						PrintException(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctExceptionHeader:
						PrintExceptions(True, TMarathonCacheHeader(Item).ConnectionName);

					ctGenerator:
						PrintGenerator(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctGeneratorHeader:
						PrintGenerators(True, TMarathonCacheHeader(Item).ConnectionName);

					ctTable:
						PrintTable(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctTableHeader:
						PrintTables(True, TMarathonCacheHeader(Item).ConnectionName);

					ctView:
						PrintView(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctViewHeader:
						PrintViews(True, TMarathonCacheHeader(Item).ConnectionName);

					ctUDF:
						PrintUDF(True, Item.Caption, TMarathonCacheObject(Item).ConnectionName);

					ctUDFHeader:
						PrintUDFs(True, TMarathonCacheHeader(Item).ConnectionName);
				end;
			end;

		opAddToProject:
			MessageDlg('Add To Project', mtInformation, [mbOK], 0);

		opCreateFolder:
			CreateProjectFolder(Item);

		opRefresh:
			begin
				B := GetBrowser;
				if Assigned(B) then
					B.RefreshNode(Item, False);
			end;

		opRefreshNoFocus:
			begin
				B := GetBrowser;
				if Assigned(B) then
					B.RefreshNode(Item, True);
			end;

		opExpandNode:
			begin
				B := GetBrowser;
				if Assigned(B) then
					B.ExpandNode(Item);
			end;

		opRemoveNode:
			begin
				B := GetBrowser;
				if Assigned(B) then
					B.RemoveNode(Item);
			end;

		opExtractDDL:
			begin
				Screen.Cursor := crHourGlass;
				L := TStringList.Create;
				try
					try
						case Item.CacheType of
							ctDomainHeader,
							ctTableHeader,
							ctViewHeader,
							ctSPHeader,
							ctTriggerHeader,
							ctGeneratorHeader,
							ctExceptionHeader,
							ctUDFHeader:
								begin
									N := Item.ContainerNode;
									if Assigned(N) then
									begin
										N := N.GetFirstChild;
										while Assigned(N) do
										begin
											SubItem := TMarathonCacheBaseNode(N.Data);
											L.AddObject(SubItem.Caption, SubItem);
											N := N.GetNextSibling;
										end;
									end;
								end;
						else
							L.AddObject(Item.Caption, Item);
						end;
					finally
						Screen.Cursor := crDefault;
					end;
					if L.Count > 0 then
					begin
						Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
						Extractor.AppHandle := Application.Handle;
						ConnectName := TMarathonCacheObject(Item).ConnectionName;
						Extractor.SQLDialect := FCurrentProject.Cache.ConnectionByName[ConnectName].Connection.SQLDialect;
						Extractor.DatabaseHandle := Integer(FCurrentProject.Cache.ConnectionByName[ConnectName].Connection.DBHandle);
						Extractor.IB6 := FCurrentProject.Cache.ConnectionByName[ConnectName].IsIB6;
						Extractor.MetaDBDatabaseName := FCurrentProject.Cache.ConnectionByName[ConnectName].DBFileName;
						Extractor.MetaDBUserName := FCurrentProject.Cache.ConnectionByName[ConnectName].UserName;
						Extractor.MetaDBPassword := FCurrentProject.Cache.ConnectionByName[ConnectName].Password;
						Extractor.MetaDefaultDirectory := gExtractDDLDir;
						// Load the properties
						Extractor.MetaExtractType := Ord(CurrentProject.MetaExtractType);
						Extractor.MetaCreateDatabase := CurrentProject.MetaCreateDatabase;
						Extractor.MetaIncludePassword := CurrentProject.MetaIncludePassword;
						Extractor.MetaIncludeDependents := CurrentProject.MetaIncludeDependents;
						Extractor.MetaIncludeDoc := CurrentProject.MetaIncludeDoc;
						Extractor.MetaWrapOutput := CurrentProject.MetaWrap;
						Extractor.MetaDecimalPlaces := CurrentProject.MetaDecimalPlaces;
						Extractor.MetaDecimalSeperator := CurrentProject.MetaDecimalSeparator;
						Extractor.MetaWrapOutputAt := CurrentProject.MetaWrapAt;

						for Idx := 0 to L.Count - 1 do
							Extractor.AddObjectInfo(L[Idx], Ord(TMarathonCacheBaseNode(L.Objects[Idx]).CacheType));

						Extractor.DoWizardList;
						// Save the properties
						CurrentProject.MetaExtractType := TExtractType(Extractor.MetaExtractType);
						CurrentProject.MetaCreateDatabase := Extractor.MetaCreateDatabase;
						CurrentProject.MetaIncludePassword := Extractor.MetaIncludePassword;
						CurrentProject.MetaIncludeDependents := Extractor.MetaIncludeDependents;
						CurrentProject.MetaIncludeDoc := Extractor.MetaIncludeDoc;
            CurrentProject.MetaWrap := Extractor.MetaWrapOutput;
            CurrentProject.MetaDecimalPlaces := Extractor.MetaDecimalPlaces;
            CurrentProject.MetaDecimalSeparator := Extractor.MetaDecimalSeperator;
            CurrentProject.MetaWrapAt := Extractor.MetaWrapOutputAt;
					end;
				finally
					L.Free;
				end;
			end;
	end;
end;

procedure TMarathonIDE.FileOpenProject;
begin
	if FileCloseProject then
	begin
		if FProjectDir = '' then
			FProjectDir := gDefProjectDir;

		FDlgOpenProject.InitialDir := FProjectDir;
		FDlgOpenProject.Title := 'Open Project';
		FDlgOpenProject.Filter := 'Marathon Project (*.xmpr)|*.xmpr|All Files (*.*)|*.*';
		if FDlgOpenProject.Execute then
		begin
			try
				OpenProject(FDlgOpenProject.FileName);
				FProjectDir := ExtractFilePath(FDlgOpenProject.FileName);
			except
				on E: Exception do
					Exit;
			end;
		end;
	end;
end;

procedure TMarathonIDE.OpenProject(ProjName: String);
var
	F: IMarathonBrowser;
	I: TRegistry;

begin
	try
		FCurrentProject.LoadFromFile(ProjName);
		FCurrentProject.FileName := ProjName;
		FCurrentProject.TimeStamp := FileDateToDateTime(FileAge(ProjName));
	except
		on E: Exception do
		begin
			MessageDlg('Unable to open project "' + ProjName + '".', mtError, [mbOK], 0);
			raise;
		end;
	end;

	AddToRecentProjects(FCurrentProject.FileName);

	I := TRegistry.Create;
	try
		if I.OpenKey(REG_SETTINGS_BASE, True) then
		begin
			I.WriteString('LastProject', FCUrrentProject.FileName);
			I.CLoseKey;
		end;
	finally
		I.Free;
	end;

	F := GetBrowser;
	if Assigned(F) then
		F.LoadTree;

	if Assigned(FMainForm) then
	begin
		FMainForm.Caption := 'Marathon';
		FMainForm.Caption := FMainForm.Caption + ' - ' + FCurrentProject.FriendlyName;
	end;

	RestoreWindowStates;
end;

procedure TMarathonIDE.AddToRecentProjects(FileName: String);
var
	R: TRegistry;
	Tmp: TStringList;

begin
	R := TRegistry.Create;
	try
		if R.OpenKey(REG_SETTINGS_RECENTPROJECTS, True) then
		begin
			Tmp := TStringList.Create;
			try
				if R.ValueExists('Data') then
					Tmp.Text := R.ReadString('Data')
				else
					Tmp.Text := '';

				if Tmp.IndexOf(FileName) = -1 then
					Tmp.Add(FileName);

				R.WriteString('Data', Tmp.Text);
			finally
				Tmp.Free;
			end;
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
	if Assigned(FMainForm) then
		FMainForm.LoadMRUMenu;
end;

procedure TMarathonIDE.RestoreWindowStates;
var
	Idx: Integer;
	F: TForm;
	SkipList: TStringList;

begin
	if Assigned(FCurrentProject) then
	begin
		if FCurrentProject.SaveWindowPositions then
		begin
			SkipList := TStringList.Create;
			try
				for Idx := 0 to FCurrentProject.WindowList.Count - 1 do
				begin
					F := nil;
					if FCurrentProject.WindowList.Items[Idx].ConnectionName <> '' then
					begin
						if SkipList.IndexOf(FCurrentProject.WindowList.Items[Idx].ConnectionName) <> -1 then
							Continue
						else
						begin
							if Assigned(FCurrentProject.Cache.ConnectionByName[FCurrentProject.WindowList.Items[Idx].ConnectionName]) then
							begin
								if not FCurrentProject.Cache.ConnectionByName[FCurrentProject.WindowList.Items[Idx].ConnectionName].Connected then
									if not FCurrentProject.Cache.ConnectionByName[FCurrentProject.WindowList.Items[Idx].ConnectionName].Connect then
									begin
										SkipList.Add(FCurrentProject.WindowList.Items[Idx].ConnectionName);
										Continue;
									end;
							end
							else
							begin
								SkipList.Add(FCurrentProject.WindowList.Items[Idx].ConnectionName);
								Continue;
							end;
						end;
					end;
					try
						case FCurrentProject.WindowList.Items[Idx].WindowType of
							ctSQLEditor:
								if FCurrentProject.WindowList.Items[Idx].ObjectName = '' then
								begin
									F := TfrmSQLForm.Create(nil);
									TfrmSQLForm(F).ConnectionName := FCurrentProject.WindowList.Items[Idx].ConnectionName;
									TfrmSQLForm(F).NewFile;
									F.Show;
								end
								else
								begin
									F := FileOpenNamedFile(FCurrentProject.WindowList.Items[Idx].ObjectName);
									TfrmSQLForm(F).ConnectionName := FCurrentProject.WindowList.Items[Idx].ConnectionName;
								end;

							ctDomain:
								F := OpenDomain(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctTable:
								F := OpenTable(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctView:
								F := OpenView(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctSP:
								F := OpenProcedure(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctTrigger:
								F := OpenTrigger(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctGenerator:
								F := OpenGenerator(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctException:
								F := OpenException(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);

							ctUDF:
								F := OpenUDF(FCurrentProject.WindowList.Items[Idx].ObjectName, FCurrentProject.WindowList.Items[Idx].ConnectionName);
						end;
					except
						on E: Exception do
						begin
							MessageDlg(E.Message, mtError, [mbOK], 0);
							F := nil;
						end;
          end;
          if Assigned(F) then
					begin
            if FCurrentProject.WindowList.Items[Idx].IsMaximised then
              F.WindowState := wsMaximized;
            F.Top := FCurrentProject.WindowList.Items[Idx].PositionTop;
            F.Left := FCurrentProject.WindowList.Items[Idx].PositionLeft;
            F.Height := FCurrentProject.WindowList.Items[Idx].SizeHeight;
            F.Width := FCurrentProject.WindowList.Items[Idx].SizeWidth;
          end;
        end;
      finally
        SkipList.Free;
      end;
    end;
  end;
end;

procedure TMarathonIDE.SaveWindowStates;
var
  I: Integer;

begin
  if Assigned(FCurrentProject) then
  begin
    // Save the state of all open windows
    FCurrentProject.WindowList.Clear;
    if FCurrentProject.SaveWindowPositions then
		begin
			for I := 0 to Screen.FormCount - 1 do
			begin
				if Screen.Forms[I] is TfrmSQLForm Then
				begin
					with FCurrentProject.WindowList.Add do
					begin
						PositionLeft := Screen.Forms[I].Left;
						PositionTop := Screen.Forms[I].Top;
						SizeWidth := Screen.Forms[I].Width;
						SizeHeight := Screen.Forms[I].Height;
						IsMaximised := Screen.Forms[I].WindowState = wsMaximized;
						WindowType := ctSQLEditor;
						if TfrmSQLForm(Screen.Forms[I]).New then
							ObjectName := ''
						else
							ObjectName := TfrmSQLForm(Screen.Forms[I]).FileName;
						ConnectionName := TfrmBaseDocumentDataAwareForm(Screen.Forms[I]).ConnectionName;
					end;
				end
				else
				begin
					if Screen.Forms[I] is TfrmBaseDocumentDataAwareForm Then
						if not TfrmBaseDocumentDataAwareForm(Screen.Forms[I]).NewObject then
							with FCurrentProject.WindowList.Add do
							begin
								PositionLeft := Screen.Forms[I].Left;
								PositionTop := Screen.Forms[I].Top;
								SizeWidth := Screen.Forms[I].Width;
								SizeHeight := Screen.Forms[I].Height;
								IsMaximised := Screen.Forms[I].WindowState = wsMaximized;
								WindowType := TfrmBaseDocumentDataAwareForm(Screen.Forms[I]).ObjectType;
								ObjectName := TfrmBaseDocumentDataAwareForm(Screen.Forms[I]).ObjectName;
								ConnectionName := TfrmBaseDocumentDataAwareForm(Screen.Forms[I]).ConnectionName;
							end;
				end;
			end;
		end;
	end;
end;


procedure TMarathonIDE.FileCreateDatabase;
var
	State: Integer;
	D, DBInfo: Variant;
	Connection: TMarathonCacheConnection;
	Item: TMarathonCacheBaseNode;
	F: IMarathonBrowser;
begin
	try
		if FCurrentProject.Open then
			State := APP_MARATHON_OPEN_PROJECT
		else
			State := APP_MARATHON_NO_OPEN_PROJECT;

		D := CreateOLEObject('GimbalCreateDatabase.GSSCreateDatabase');
		DBInfo := D.Execute(Application.Handle, APP_MARATHON, State);
		{$IFDEF Ver150}
		if not VarIsClear(DBInfo) then
		{$ELSE}
		if not VarIsEmpty(DBInfo) then
		{$ENDIF}
		begin
			if DBInfo.CreateProject then
			begin
				if FileCloseProject then
				begin
					FCurrentProject.NewProject;
					FCurrentProject.FriendlyName := DBInfo.ProjectName;

          if Assigned(FMainForm) then
            FMainForm.Caption := 'Marathon';

					if Assigned(FMainForm) then
            FMainForm.Caption := FMainForm.Caption + ' - ' + FCurrentProject.FriendlyName;
          F := GetBrowser;
          if Assigned(F) then
            F.LoadTree;

					Connection := FCurrentProject.Cache.AddConnectionInternal;
          Connection.Caption := DBInfo.ConnectionName;
          Connection.DBFileName := DBInfo.DatabaseName;
          Connection.UserName := DBInfo.UserName;
          Connection.Password := DBInfo.Password;
          Connection.SQLDialect := DBInfo.Dialect;
          Connection.LangDriver := DBInfo.CharSet;
					Item := Connection.GetParentObject;
          if Assigned(Item) then
          begin
            Item.FireEvent(opRefresh);
            Item.FireEvent(opExpandNode);
          end;
          Connection.FireEvent(opRefresh);
          Connection.FireEvent(opExpandNode);
          Connection.Connect;
        end;
      end
      else
      begin
        if DBInfo.CreateConnection then
        begin
					Connection := FCurrentProject.Cache.AddConnectionInternal;
//          wPath := Connection.ContainerNode.NodePath;
          Connection.Caption := DBInfo.ConnectionName;
          Connection.DBFileName := DBInfo.DatabaseName;
          Connection.UserName := DBInfo.UserName;
          Connection.Password := DBInfo.Password;
          Connection.SQLDialect := DBInfo.Dialect;
          Connection.LangDriver := DBInfo.CharSet;
          Item := Connection.GetParentObject;
          if Assigned(Item) then
          begin
            Item.FireEvent(opRefresh);
            Item.FireEvent(opExpandNode);
          end;
//          Connection.FireEvent(opRefresh);
//          Connection.FireEvent(opExpandNode);
//          Connection.Connect;
        end;
      end;
    end;

  except
		on E: Exception do
		begin
			MessageDlg(E.Message, mtError, [mbOK], 0);
			Exit;
		end;
	end;
end;

procedure TMarathonIDE.FilePrintSetup;
begin
	FPrnSetup.Execute;
end;

procedure TMarathonIDE.FileNewObject;
var
	F: TfrmNewObject;

begin
	F := TfrmNewObject.Create(Self);
	try
		if F.ShowModal = mrOK then
			case F.RtnType of
				ctDomain:
					NewDomain(F.ConnectionName);

				ctTable:
					NewTable(F.ConnectionName);

				ctView:
					NewView(F.ConnectionName);

				ctSP:
					NewProcedure(F.ConnectionName);

				ctSPTemplate:;

				ctTrigger:
					NewTrigger(F.ConnectionName);

				ctGenerator:
					NewGenerator(F.ConnectionName);

				ctException:
					NewException(F.ConnectionName);

				ctUDF:
					NewUDF(F.ConnectionName);
			end;
	finally
		F.Free;
	end;
end;

function TMarathonIDE.FileOpenFile: TForm;
var
	Ext: String;
	FSQL: TfrmSQLForm;

begin
	FdlgOpenFile.Filter := 'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
	FDlgOpenFile.Title := 'Open File';
	if FDlgOpenFile.Execute then
	begin
		Ext := ExtractFileExt(FdlgOpenFIle.FileName);
		FSQL := TfrmSQLForm.Create(nil);
		FSQL.ConnectionName := '';
		FSQL.OpenFile(FDlgOpenFile.FileName);
		FSQL.Show;
		Result := FSQL;
		AddToRecentProjects(FDlgOpenFile.FileName);
	end
	else
		Result := nil;
end;

function TMarathonIDE.FileOpenNamedFile(FileName: String): TForm;
var
	Ext: String;
	FSQL: TfrmSQLForm;

begin
	Ext := ExtractFileExt(FileName);
	FSQL := TfrmSQLForm.Create(nil);
	FSQL.ConnectionName := '';
	FSQL.OpenFile(FileName);
	FSQL.Show;
	Result := FSQL;
	AddToRecentProjects(FileName);
end;

procedure TMarathonIDE.FileOpenDatabaseObject;
begin

end;

procedure TMarathonIDE.ViewViewBrowser;
var
	I: Integer;
	Found: Boolean;
	F: TfrmDatabaseExplorer;

begin
	Found := False;
	for I := 0 to Screen.FormCount-1 do
		if Screen.Forms[I] is TfrmDatabaseExplorer Then
		begin
			Found := True;
			TfrmDatabaseExplorer(Screen.Forms[i]).BringToFront;
		end;
	if not Found Then
	begin
		F := TfrmDatabaseExplorer.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.ProjectProjectOptions;
begin
	with TfrmMasterProperties.CreateModifyProject(Self) do
		try
			if ShowModal = mrOK then
				RefreshForms;
		finally
			Free;
		end;
end;

procedure TMarathonIDE.RefreshForms;
var
	Idx: Integer;
	Test: TForm;

begin
	for Idx := 0 to Screen.FormCount - 1 do
	begin
		Test := Screen.Forms[Idx];
		if Test is TfrmBaseDocumentForm then
		begin
			TfrmBaseDocumentForm(Test).ProjectOptionsRefresh;
			TfrmBaseDocumentForm(Test).EnvironmentOptionsRefresh;
		end;
	end;
end;

procedure TMarathonIDE.ViewViewNextWindow;
var
	NewIdx, FndIdx, CurIdx: Integer;
	List: TStringList;

begin
	CurIdx := 0;
	List := TStringList.Create;
	try
		for NewIdx := 0 to Screen.FormCount - 1 do
		begin
			if (not(Screen.Forms[NewIdx] is TfrmMarathonMain) and
				not(Screen.Forms[NewIdx] is TfrmDatabaseExplorer) and
				not(Screen.Forms[NewIdx].WindowState = wsMinimized)) then
			begin
				if Screen.Forms[NewIdx] = Screen.ActiveForm then
					CurIdx := NewIdx;
				List.Add(IntToStr(NewIdx));
			end;
		end;

		if List.Count > 1 then
		begin
			FndIdx := 0;
			for NewIdx := 0 to List.Count - 1 do
			begin
				if StrToInt(List[NewIdx]) = CurIdx then
				begin
					FndIdx := NewIdx;
					Break;
				end;
			end;
			NewIdx := FndIdx - 1;
			if NewIdx < 0 then
				NewIdx := List.Count - 1;

      Screen.Forms[StrToInt(List[NewIdx])].BringToFront;
    end;
  finally
    List.Free;
  end;
end;

procedure TMarathonIDE.WindowWindowList;
var
	Idx: Integer;
	frmWindowList: TfrmWindowList;

begin
	frmWindowList := TfrmWindowList.Create(Self);
	try
		if frmWindowList.ShowModal = mrOK then
			if Assigned(frmWindowList.lvWindows.Selected) then
				for Idx := 0 to Screen.FormCount - 1 do
					if Screen.Forms[Idx].Caption = frmWindowList.lvWindows.Selected.Caption then
					begin
						if Screen.Forms[Idx].WindowState = wsMinimized then
							Screen.Forms[Idx].WindowState := wsNormal
						else
							Screen.Forms[Idx].BringToFront;
						Break;
					end;
	finally
		frmWindowList.Free;
	end;
end;

procedure TMarathonIDE.WindowCloseAllWindows;
var
	I: Integer;

begin
	for I := 0 to Screen.FormCount - 1 do
	begin
		if Screen.Forms[I] is TfrmDatabaseExplorer Then
			TfrmDatabaseExplorer(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmStoredProcedure Then
			TfrmStoredProcedure(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmTables Then
			TfrmTables(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmSQLForm Then
			TfrmSQLForm(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmTriggerEditor Then
			TfrmTriggerEditor(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmGenerators Then
			TfrmGenerators(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmExceptions Then
			TfrmExceptions(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmPrintPreview Then
			TfrmPrintPreview(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmScriptEditorHost Then
			TfrmScriptEditorHost(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmUDFEditor Then
			TfrmUDFEditor(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmViewEditor Then
			TfrmViewEditor(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmSyntaxHelp Then
			TfrmSyntaxHelp(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmCodeSnippets Then
			TfrmCodeSnippets(Screen.Forms[i]).Close;
		if Screen.Forms[I] is TfrmUsers Then
			TfrmUsers(Screen.Forms[i]).Close;
	end;
end;

procedure TMarathonIDE.ToolsSQLEditor;
var
	ConnectName: String;
	F: TfrmSQLForm;
	SC: TfrmSelectConnection;

begin
	if FCurrentProject.Open then
	begin
		if FCurrentProject.Cache.ConnectionCount = 1 then
		begin
			if not FCurrentProject.Cache.Connections[0].Connected then
			begin
				FCurrentProject.Cache.Connections[0].ErrorOnConnection := False;
				if not FCurrentProject.Cache.Connections[0].Connect then
					Exit;
			end;
			F := TfrmSQLForm.Create(nil);
			F.ConnectionName := FCurrentProject.Cache.Connections[0].Caption;
			F.NewFile;
			F.Show;
		end
		else
		begin
			SC := TfrmSelectConnection.Create(Self);
			try
				SC.cmbConnections.ItemIndex := SC.cmbConnections.Items.IndexOf(FCurrentProject.Cache.ActiveConnection);
				if SC.ShowModal = mrOK then
				begin
					if SC.cmbConnections.ItemIndex = 0 then
						ConnectName := ''
					else
					begin
						ConnectName := SC.cmbConnections.Text;
						if not FCurrentProject.Cache.ConnectionByName[ConnectName].Connected then
						begin
							FCurrentProject.Cache.ConnectionByName[ConnectName].ErrorOnConnection := False;
							if not FCurrentProject.Cache.ConnectionByName[ConnectName].Connect then
								Exit;
						end;
					end;

					F := TfrmSQLForm.Create(nil);
					F.ConnectionName := ConnectName;
					F.NewFile;
					F.Show;
				end;
			finally
				SC.Free;
			end;
		end;
	end
	else
	begin
		F := TfrmSQLForm.Create(nil);
		F.ConnectionName := '';
		F.NewFile;
		F.Show;
	end;
end;

procedure TMarathonIDE.ToolsMetadataExtract;
var
	ConnectName: String;
	Extractor: IGSSDDLExtractor;
	SC: TfrmSelectConnection;

begin
	SC := TfrmSelectConnection.Create(Self);
	try
		SC.cmbConnections.ItemIndex := SC.cmbConnections.Items.IndexOf(FCurrentProject.Cache.ActiveConnection);
		if SC.ShowModal = mrOK then
		begin
			if SC.cmbConnections.ItemIndex = 0 then
				Exit
			else
			begin
				ConnectName := SC.cmbConnections.Text;
				if not FCurrentProject.Cache.ConnectionByName[ConnectName].Connected then
				begin
					FCurrentProject.Cache.ConnectionByName[ConnectName].ErrorOnConnection := False;
					if not FCurrentProject.Cache.ConnectionByName[ConnectName].Connect then
						Exit;
				end;
			end;

			Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
			Extractor.AppHandle := Application.Handle;
			Extractor.SQLDialect := FCurrentProject.Cache.ConnectionByName[ConnectName].Connection.SQLDialect;
			Extractor.DatabaseHandle := Integer(FCurrentProject.Cache.ConnectionByName[ConnectName].Connection.DBHandle);
			Extractor.IB6 := FCurrentProject.Cache.ConnectionByName[ConnectName].IsIB6;
			Extractor.MetaDBDatabaseName := FCurrentProject.Cache.ConnectionByName[ConnectName].DBFileName;
			Extractor.MetaDBUserName := FCurrentProject.Cache.ConnectionByName[ConnectName].UserName;
			Extractor.MetaDBPassword := FCurrentProject.Cache.ConnectionByName[ConnectName].Password;
			Extractor.MetaDefaultDirectory := gExtractDDLDir;
			// Load the properties
			Extractor.MetaExtractType := Ord(CurrentProject.MetaExtractType);
			Extractor.MetaCreateDatabase := CurrentProject.MetaCreateDatabase;
			Extractor.MetaIncludePassword := CurrentProject.MetaIncludePassword;
			Extractor.MetaIncludeDependents := CurrentProject.MetaIncludeDependents;
			Extractor.MetaIncludeDoc := CurrentProject.MetaIncludeDoc;
			Extractor.MetaWrapOutput := CurrentProject.MetaWrap;
			Extractor.MetaDecimalPlaces := CurrentProject.MetaDecimalPlaces;
			Extractor.MetaDecimalSeperator := CurrentProject.MetaDecimalSeparator;
			Extractor.MetaWrapOutputAt := CurrentProject.MetaWrapAt;

			if Extractor.DoWizard(FCurrentProject.Cache.ConnectionByName[ConnectName].UserName,
				FCurrentProject.Cache.ConnectionByName[ConnectName].Password) then
			begin
				// Save the properties
				CurrentProject.MetaExtractType := TExtractType(Extractor.MetaExtractType);
				CurrentProject.MetaCreateDatabase := Extractor.MetaCreateDatabase;
				CurrentProject.MetaIncludePassword := Extractor.MetaIncludePassword;
				CurrentProject.MetaIncludeDependents := Extractor.MetaIncludeDependents;
				CurrentProject.MetaIncludeDoc := Extractor.MetaIncludeDoc;
				CurrentProject.MetaWrap := Extractor.MetaWrapOutput;
				CurrentProject.MetaDecimalPlaces := Extractor.MetaDecimalPlaces;
				CurrentProject.MetaDecimalSeparator := Extractor.MetaDecimalSeperator;
				CurrentProject.MetaWrapAt := Extractor.MetaWrapOutputAt;
			end;
		end;
	finally
		SC.Free;
	end;
end;

procedure TMarathonIDE.ToolsSearchMetadata;
var
	F: IMarathonForm;
	B: IMarathonBrowser;

begin
	B := GetBrowser;
	if B.QueryInterface(IMarathonForm, F) = S_OK then
	begin
		if Assigned(F) then
		begin
			F.BringToFront;
			F.DoSearchMode;
		end;
	end;
end;

procedure TMarathonIDE.ToolsSyntaxHelp;
var
	I: Integer;
	Found: Boolean;

begin
	Found := False;
	for I := 0 to Screen.FormCount-1 do
		if Screen.Forms[I] is TfrmSyntaxHelp Then
		begin
			Found := True;
			TfrmSyntaxHelp(Screen.Forms[I]).BringToFront;
		end;
	if not Found Then
	begin
		frmSyntaxHelp := TfrmSyntaxHelp.Create(Self);
		frmSyntaxHelp.Show;
	end;
end;

procedure TMarathonIDE.ToolsCodeSnippets;
var
	I: Integer;
	Found: Boolean;

begin
	Found := False;
	for I := 0 to Screen.FormCount-1 do
		if Screen.Forms[I] is TfrmCodeSnippets Then
		begin
			Found := True;
			TfrmCodeSnippets(Screen.Forms[i]).BringToFront;
		end;
	if not Found Then
	begin
		frmCodeSnippets := TfrmCodeSnippets.Create(Self);
		frmCodeSnippets.Show;
	end;
end;

procedure TMarathonIDE.ToolsSQLTrace;
var
	Idx: Integer;
	Found: Boolean;
	frmSQLTrace: TfrmSQLTrace;

begin
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmSQLTrace then
		begin
			Found := True;
			TfrmSQLTrace(Screen.Forms[Idx]).trcSQL.Enabled := True;
			TfrmSQLTrace(Screen.Forms[Idx]).BringToFront;
			Break;
		end;
	if not Found then
	begin
		frmSQLTrace := TfrmSQLTrace.Create(Self);
		frmSQLTrace.trcSQL.Enabled := True;
		frmSQLTrace.Show;
	end;
end;

procedure TMarathonIDE.ToolsEnvironmentOptions;
var
	frmMarathonOptions: TfrmMarathonOptions;

begin
	frmMarathonOptions := TfrmMarathonOptions.Create(self);
	try
		if frmMarathonOptions.ShowModal = mrok then
    begin
      MarathonIDEInstance.MainForm.LoadOptions;
    end;
	finally
		frmMarathonOptions.Free;
	end;
end;

procedure TMarathonIDE.ToolsUserEditor;
var
	F: TfrmUsers;

begin
	F := TfrmUsers.Create(Application);
	F.Show;
end;

//==============================================================================
function TMarathonIDE.IDEAddCommand(ThisPlugin: Integer; Name: WideString): IGimbalIDECommand;
var
	C: TGimbalIDECommand;
	Idx: Integer;
	A: TGimbalInternalAction;

begin
  Result := nil;
  for Idx := 0 to FPluginCommandObjects.Count - 1 do
  begin
    if TGimbalIDECommand(FPluginCommandObjects[Idx]).Name = Name then
    begin
			MessageDlg('Command "' + Name + '" already exists.', mtError, [mbOK], 0);
			Exit;
    end;
  end;

  A := TGimbalInternalAction.Create(nil);
  A.ActionList := FInternalActionList;
  A.Name := Name;
  A.Caption := Name;
  A.OnExecute := RegisteredCommandOnExecute;
  A.OnUpdate := RegisteredCommandOnUpdate;

  C := TGimbalIDECommand.Create;
  C.Action := A;
  C.PluginIdx := ThisPlugin;

  A.IDECOmmand := C;

  FPluginCommandObjects.Add(C);
  Result := C;
end;

procedure TMarathonIDE.RegisteredCommandOnExecute(Sender: TObject);
var
  C: TGimbalIDECommand;

begin
	C := TGimbalInternalAction(Sender).IDECOmmand;
  if Assigned(C) and Assigned(C.Notifier) then
    C.Notifier.OnExecute;
end;

procedure TMarathonIDE.RegisteredCommandOnUpdate(Sender: TObject);
var
  C: TGimbalIDECommand;

begin
  C := TGimbalInternalAction(Sender).IDECOmmand;
  if Assigned(C) and Assigned(C.Notifier) then
		C.Action.Enabled := C.Notifier.OnUpdateEnabled;
	if Assigned(C) and Assigned(C.Notifier) then
    C.Action.Checked := C.Notifier.OnUpdateChecked;
end;

procedure TMarathonIDE.SetMainForm(const Value: IMarathonMainForm);
begin
  FMainForm := Value;
end;

procedure TMarathonIDE.UnloadPlugins;
var
	Idx, Idy, CurIdx: Integer;
	H: THandle;

begin
	for Idx := FPlugins.Count - 1 downto 0 do
	begin
		CurIdx := TGimbalIDEPlugin(FPlugins[Idx]).PluginIdx;

		for Idy := FPluginMenuObjects.Count - 1 downto 0  do
			if TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).PluginIdx = CurIdx then
			begin
				TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).Item.Free;
				TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).Free;
				FPluginMenuObjects.Delete(Idy);
			end;

		for Idy := FPluginCommandObjects.Count - 1 downto 0 do
			if TGimbalIDECommand(FPluginCommandObjects[Idy]).PluginIdx  = CurIdx then
			begin
				TGimbalIDECommand(FPluginCommandObjects[Idy]).Notifier := nil;
				TGimbalIDECommand(FPluginCommandObjects[Idy]).Action.Free;
				FPluginCommandObjects.Delete(Idy);
			end;

		for Idy := FIDENotifierChain.Count - 1 downto 0 do
			if TGimbalIDENotifierObject(FIDENotifierChain[Idy]).PluginIdx  = CurIdx then
			begin
				TGimbalIDENotifierObject(FIDENotifierChain[Idy]).IDEInterface := nil;
				FIDENotifierChain.Delete(Idy);
			end;

		H := TGimbalIDEPlugin(FPlugins[Idx]).DLLHandle;
		TGimbalIDEPlugin(FPlugins[Idx]).Free;
		FreeLibrary(H);
		FPlugins.Delete(Idx);
	end;
end;


procedure TMarathonIDE.BringWindowToFront(Index: Integer);
begin
	TForm(FWindowList[Index]).BringToFront;
end;

procedure TMarathonIDE.ProcessInternalLink(URL: String);
begin
	//
end;

procedure TMarathonIDE.NewDomain(COnnection: String);
var
	F: TfrmDomains;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmDomains.Create(nil);
	F.ConnectionName := Connection;
	F.NewDomain;
	F.Show;
end;

function TMarathonIDE.OpenDomain(DomainName: String; Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmDomains;

begin
  Result := nil;
  if not CheckConnected(Connection) then
    Exit;
  Found := False;
  for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmDomains then
			if (TfrmDomains(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmDomains(Screen.Forms[Idx]).ObjectName  = DomainName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(DomainName, ctDomain, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmDomains.Create(nil);
		F.ConnectionName := Connection;
		F.LoadDomain(DomainName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(DomainName, ctDomain, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewProcedure(COnnection: String);
var
  F: TfrmStoredProcedure;

begin
  if not CheckConnected(Connection) then
    Exit;
  F := TfrmStoredProcedure.Create(nil);
  F.ConnectionName := Connection;
  F.NewProcedure;
  F.Show;
end;

function TMarathonIDE.OpenProcedure(ProcedureName, COnnection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmStoredProcedure;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
	begin
		if SCreen.Forms[Idx] is TfrmStoredProcedure then
		begin
			if (TfrmStoredProcedure(Screen.Forms[Idx]).ConnectionName = Connection) and
				 (TfrmStoredProcedure(Screen.Forms[Idx]).ObjectName  = ProcedureName) then
			begin
				FOund := True;
				Screen.FOrms[Idx].BringToFront;
				Break;
			end;
		end;
	end;
	if not Found then
	begin
		if not DoesObjectExist(ProcedureName, ctSP, Connection) then
		begin
      Result := nil;
      Exit;
    end;
    F := TfrmStoredProcedure.Create(nil);
    F.ConnectionName := Connection;
    F.LoadProcedure(ProcedureName);
    F.Show;
    FCurrentProject.Cache.AddRecentObjectOpen(ProcedureName, ctSP, Connection);
    Result := F;
  end;
end;

function TMarathonIDE.DebugOpenProcedure(ProcedureName,	Connection: String;
	OpenEditor, MakeVisible: Boolean): IMarathonStoredProcEditor;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmStoredProcedure;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;

	if FCurrentProject.Cache.ConnectionByName[Connection].IsIB6 and (FCurrentProject.Cache.ConnectionByName[Connection].SQLDialect = 3) then
	begin
		if not ShouldBeQuoted(ProcedureName) then
			ProcedureName := AnsiUpperCase(ProcedureName);
	end
	else
		ProcedureName := AnsiUpperCase(ProcedureName);

	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmStoredProcedure then
			if (TfrmStoredProcedure(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmStoredProcedure(Screen.Forms[Idx]).ObjectName  = ProcedureName) then
			begin
				Found := True;
				F := TfrmStoredProcedure(Screen.Forms[Idx]);
				if MakeVisible then
					F.BringToFront;
				Result := F;
				Break;
			end;
	if not Found then
		if OpenEditor then
		begin
			F := TfrmStoredProcedure.Create(nil);
			F.ConnectionName := Connection;
			F.LoadProcedure(ProcedureName);
			F.Show;
			FCurrentProject.Cache.AddRecentObjectOpen(ProcedureName, ctSP, Connection);
			Result := F;
		end;
end;


procedure TMarathonIDE.NewTrigger(Connection: String);
var
	F: TfrmTriggerEditor;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmTriggerEditor.Create(nil);
	F.ConnectionName := Connection;
	try
		F.NewTrigger('', '');
		F.Show;
	except
		on E: Exception do
			F.Free;
	end;
end;

procedure TMarathonIDE.NewTriggerWithInfo(Connection, TriggerType, Table: String);
var
	F: TfrmTriggerEditor;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmTriggerEditor.Create(nil);
	F.ConnectionName := Connection;
	F.NewTrigger(TriggerType, Table);
	F.Show;
end;

function TMarathonIDE.OpenTrigger(TriggerName, Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmTriggerEditor;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmTriggerEditor then
			if (TfrmTriggerEditor(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmTriggerEditor(Screen.Forms[Idx]).ObjectName  = TriggerName) then
			begin
				Found := True;
				Screen.FOrms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(TriggerName, ctTrigger, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmTriggerEditor.Create(nil);
		F.ConnectionName := Connection;
		F.LoadTrigger(TriggerName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(TriggerName, ctTrigger, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewException(Connection: String);
var
	F: TfrmExceptions;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmExceptions.Create(nil);
	F.ConnectionName := Connection;
	F.NewException;
	F.Show;
end;

function TMarathonIDE.OpenException(ExceptionName, Connection: String): TForm;
var
	F: TfrmExceptions;
	Idx: Integer;
	Found: Boolean;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmExceptions then
			if (TfrmExceptions(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmExceptions(Screen.Forms[Idx]).ObjectName  = ExceptionName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(ExceptionName, ctException, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmExceptions.Create(nil);
		F.ConnectionName := Connection;
		F.LoadException(ExceptionName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(ExceptionName, ctException, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewGenerator(Connection: String);
var
	F: TfrmGenerators;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmGenerators.Create(nil);
	F.ConnectionName := Connection;
	F.NewGenerator;
	F.Show;
end;

function TMarathonIDE.OpenGenerator(GeneratorName, Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmGenerators;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if SCreen.Forms[Idx] is TfrmGenerators then
			if (TfrmGenerators(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmGenerators(Screen.Forms[Idx]).ObjectName  = GeneratorName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(GeneratorName, ctGenerator, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmGenerators.Create(nil);
		F.ConnectionName := Connection;
		F.LoadGenerator(GeneratorName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(GeneratorName, ctGenerator, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewTable(Connection: String);
var
  F: TfrmTables;

begin
  if not CheckConnected(Connection) then
    Exit;
  F := TfrmTables.Create(nil);
  F.ConnectionName := Connection;
  try
    F.NewTable;
    F.Show;
  except
		on E: Exception do
			F.Free;
	end;
end;

function TMarathonIDE.OpenTable(TableName, Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmTables;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmTables then
			if (TfrmTables(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmTables(Screen.Forms[Idx]).ObjectName  = TableName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(TableName, ctTable, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmTables.Create(nil);
		F.ConnectionName := Connection;
		F.LoadTable(TableName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(TableName, ctTable, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewView(Connection: String);
var
	F: TfrmViewEditor;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmViewEditor.Create(nil);
	F.ConnectionName := Connection;
	try
		F.NewView;
		F.Show;
	except
		on E: Exception do
			F.Free;
	end;
end;

function TMarathonIDE.OpenView(ViewName, Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmViewEditor;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmViewEditor then
			if (TfrmViewEditor(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmViewEditor(Screen.Forms[Idx]).ObjectName  = ViewName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(ViewName, ctView, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmViewEditor.Create(nil);
		F.ConnectionName := Connection;
		F.LoadView(ViewName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(ViewName, ctView, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.NewUDF(Connection: String);
var
	F: TfrmUDFEditor;

begin
	if not CheckConnected(Connection) then
		Exit;
	F := TfrmUDFEditor.Create(nil);
	F.ConnectionName := Connection;
	try
		F.NewUDF;
		F.Show;
	except
		on E: Exception do
			F.Free;
	end;
end;

function TMarathonIDE.OpenUDF(UDFName, Connection: String): TForm;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmUDFEditor;

begin
	Result := nil;
	if not CheckConnected(Connection) then
		Exit;
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmUDFEditor then
			if (TfrmUDFEditor(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmUDFEditor(Screen.Forms[Idx]).ObjectName  = UDFName) then
			begin
				Found := True;
				Screen.Forms[Idx].BringToFront;
				Break;
			end;
	if not Found then
	begin
		if not DoesObjectExist(UDFName, ctUDF, Connection) then
		begin
			Result := nil;
			Exit;
		end;
		F := TfrmUDFEditor.Create(nil);
		F.ConnectionName := Connection;
		F.LoadUDF(UDFName);
		F.Show;
		FCurrentProject.Cache.AddRecentObjectOpen(UDFName, ctUDF, Connection);
		Result := F;
	end;
end;

procedure TMarathonIDE.RecordToScript(Script: String; ConnectionName: String);
var
	Connection: TMarathonCacheConnection;

begin
	Connection := FCurrentProject.Cache.ConnectionByName[ConnectionName];
	if Assigned(Connection) then
		if Connection.ScriptRecorder.Recording then
			Connection.ScriptRecorder.RecordScript(Script);
end;

procedure TMarathonIDE.CloseDroppedWindow(Connection: String; ObjectName: String);
var
	Idx: Integer;

begin
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmBaseDocumentDataAwareForm then
			if (TfrmBaseDocumentDataAwareForm(Screen.Forms[Idx]).ConnectionName = Connection) and
				(TfrmBaseDocumentDataAwareForm(Screen.Forms[Idx]).ObjectName = ObjectName) then
				TfrmBaseDocumentDataAwareForm(Screen.Forms[Idx]).DropClose;
end;

procedure TMarathonIDE.DoConnect(Item: TMarathonCacheBaseNode);
var
//	F: TfrmMasterProperties;
	Connection: TMarathonCacheConnection;

begin
	case Item.CacheType of
	 ctConnection:
		 begin
			 Connection := TMarathonCacheConnection(Item);
			 Connection.ErrorOnConnection := False;
			 if Connection.Connect then
			 begin
				 Connection.FireEvent(opRefresh);
				 Connection.FireEvent(opExpandNode);
			 end;
		 end;
	end;
end;

procedure TMarathonIDE.DoDisconnect(Item: TMarathonCacheBaseNode);
var
//	F: TfrmMasterProperties;
	Connection: TMarathonCacheConnection;

begin
	case Item.CacheType of
	 ctConnection:
		 begin
			 Connection := TMarathonCacheConnection(Item);
			 Connection.ErrorOnConnection := True;
       try
          Connection.DisConnect;
          Connection.FireEvent(opRefresh);
          Connection.FireEvent(opExpandNode);
       finally
			    Connection.ErrorOnConnection := false;
       end;
		 end;
	end;
end;

procedure TMarathonIDE.DoDelete(Item: TMarathonCacheBaseNode);
var
	Connection: TMarathonCacheConnection;

begin
	case Item.CacheType of
	 ctConnection:
		 begin
			 Connection := TMarathonCacheConnection(Item);
			 Connection. ErrorOnConnection := True;
			 Connection.DisConnect;
       Connection.FireEvent(opDrop);
//			 Connection.FireEvent(opRefresh); //rjm
//			 Connection.FireEvent(opExpandNode);  //rjm
		 end;
	end;
end;

procedure TMarathonIDE.DoProperties(Item: TMarathonCacheBaseNode);
begin
	case Item.CacheType of
		ctConnection:
			with TfrmMasterProperties.CreateModifyConnection(Self, TMarathonCacheConnection(Item)) do
				try
					ShowModal;
				finally
					Free;
				end;

		ctServer:
			with TfrmMasterProperties.CreateModifyServer(Self, TMarathonCacheServer(Item)) do
				try
					ShowModal;
				finally
					Free;
				end;
    ctTrigger:
       messagedlg('This feature has not been completed yet.  Please notify Ryan.',mtinformation, [mbok], 0);
	end;
end;

function TMarathonIDE.GetRecentFileData: String;
begin
	Result := '';
	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_RECENTPROJECTS, True) then
			begin
				if ValueExists('Data') then
					Result := ReadString('Data');
				CloseKey;
			end;
		finally
			Free;
		end;
end;

procedure TMarathonIDE.SetWindowListChanged(const Value: Boolean);
begin
	FWindowListChanged := Value;
	if Assigned(FMainForm) then
		FMainForm.LoadWindowList;
end;

procedure TMarathonIDE.AddMenuToMainForm(MenuItem: TMenuItem);
begin
{	if Assigned(FMainForm) then
		FMainForm.AddMenuItem(MenuItem);}
end;

function TMarathonIDE.GetHintTextForToken(Token, Connection: String): String;
begin
	//
end;

procedure TMarathonIDE.NavigateToLink(Token, Connection: String);
begin
	//
end;

procedure TMarathonIDE.GetTableColumnsEvent(Sender: TObject; TableName,
	Connection: String; List: TCheckListBox);
begin
	with TIBOQuery.Create(Self) do
		try
			SQL.Add('select A.RDB$FIELD_NAME, A.RDB$FIELD_SOURCE, B.RDB$FIELD_LENGTH, B.RDB$FIELD_SCALE, ' +
				'B.RDB$FIELD_TYPE from RDB$RELATION_FIELDS A, RDB$FIELDS B where ' +
				'A.RDB$FIELD_SOURCE = B.RDB$FIELD_NAME and A.RDB$RELATION_NAME = ''' +
				(TableName) + ''' order by A.RDB$FIELD_POSITION asc;');
			Open;
			while not EOF do
			begin
				List.Items.Add(FieldByName('RDB$FIELD_NAME').AsString);
				Next;
			end;
			Close;
		finally
			Free;
		end;
end;

procedure TMarathonIDE.GetTablesEvent(Sender: TObject; SysTables: Boolean;
	Connection: String; List: TListBox);
{var
	Idx: Integer;}

begin
{  for Idx := 0 to MTableList.Count - 1 do
	begin
		if Copy(MTableList[Idx], 1, 4) <> 'RDB$' then
			List.Items.Add(MTableList[Idx]);
	end;
	for Idx := 0 to MViewList.Count - 1 do
	begin
		if Copy(MViewList[Idx], 1, 4) <> 'RDB$' then
			List.Items.Add(MViewList[Idx]);
	end;
	for Idx := 0 to MSPList.Count - 1 do
	begin
		if Copy(MSPList[Idx], 1, 4) <> 'RDB$' then
			List.Items.Add(MSPList[Idx]);
	end;}
end;

procedure TMarathonIDE.PrintSyntaxMemo(TSM: TSyntaxMemoWithStuff2; Preview: Boolean; Title: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintSyntaxMemo(TSM, Preview, Title);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintDataSet(DataSet: TDataSet; Preview: Boolean; Title: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintDataSet(DataSet, Preview, Title);
	finally
		if not Preview then
			P.Free;
	end;
end;

function TMarathonIDE.GetNewFileName: String;
begin
	Result := 'untitled' + Format('%2.2d', [FFileCounter]);
end;

function TMarathonIDE.CloseQuery: Boolean;
var
	Idx: Integer;

begin
	Result := True;
	for Idx := 0 to Screen.FOrmCOunt - 1 do
		if Screen.Forms[Idx] is TfrmBaseDocumentForm then
			if not TfrmBaseDocumentForm(SCreen.Forms[Idx]).InternalCloseQuery then
			begin
				Result := False;
				Exit;
			end;
end;

procedure TMarathonIDE.LoadPluginFromFile(FileName: String);
var
	H: THandle;
	P: TPlugInInit;
	Ex: TPluginExecute;
	Plugin: TGimbalIDEPlugin;
	PlugInIdx: Integer;
	Found: Boolean;
	Idx: Integer;
	PluginRec: TPlugin;

begin
	H := LoadLibrary(Pchar(FileName));
	if H > 0 then
	begin
		P := GetProcAddress(H, 'GimbalPluginInit');
		if Assigned(P) then
		begin
			PlugInIdx := FPlugins.Count + 1;
			Plugin := TGimbalIDEPlugin.Create;
			Plugin.PluginIdx := PluginIdx;
			Plugin.DLLHandle := H;
			Plugin.DLLName := FileName;

			PluginRec.Index := PluginIdx;
			P(Self, PluginRec);
			Plugin.Name := PluginRec.Name;
			// Now check all of the names to make sure we haven't got a dupe
			Found := False;
			for Idx := FPlugins.Count - 1 downto 0 do
			begin
				if TGimbalIDEPlugin(FPlugins[Idx]).Name = Plugin.Name then
				begin
					Found := True;
					Break;
				end;
			end;
			if not Found then
			begin
				Ex := GetProcAddress(H, 'GimbalPluginExecute');
				if Assigned(Ex) then
				begin
					Ex;
				end
				else
					FreeLibrary(H);
				FPlugins.Add(Plugin);
			end
			else
			begin
				MessageDlg('This plugin is already loaded.', mtError, [mbOK], 0);
				Plugin.Free;
				FreeLibrary(H);
			end;
		end
		else
			FreeLibrary(H);
	end;
end;

procedure TMarathonIDE.SavePluginStates;
var
	Idx: Integer;

begin
	with TRegistry.Create do
		try
			DeleteKey(REG_SETTINGS_PLUGINS);
			if OpenKey(REG_SETTINGS_PLUGINS, True) then
			begin
				for Idx := 0 to FPlugins.Count - 1 do
					WriteString(TGimbalIDEPlugin(FPlugins[Idx]).Name, TGimbalIDEPlugin(FPlugins[Idx]).DLLName);
				CloseKey;
			end;
		finally
			Free;
		end;
end;

procedure TMarathonIDE.ManagePlugins;
begin
	FPluginsDialog := TfrmPlugins.Create(nil);
	try
		RefreshPluginsDialog;
		FPluginsDialog.SHowModal;
	finally
		FPluginsDialog.Free;
    FPluginsDialog := nil;
  end;
end;

procedure TMarathonIDE.RefreshPluginsDialog;
var
  Idx: Integer;
  Item: String;

begin
	if Assigned(FPluginsDialog) then
	begin
		FPluginsDialog.lbPlugins.Items.Clear;
		for Idx := 0 to FPlugins.Count - 1 do
		begin
			Item := TGimbalIDEPlugin(FPlugins[Idx]).Name;
			FPluginsDialog.lbPlugins.Items.Add(Item);
		end;
	end;
end;

procedure TMarathonIDE.UnLoadPluginByName(Name: String);
var
	Idx: Integer;
	H: THandle;
	CurIdx: Integer;
	Idy: Integer;
	Bill: TObject;

begin
	for Idx := FPlugins.Count - 1 downto 0 do
	begin
		if TGimbalIDEPlugin(FPlugins[Idx]).Name = Name then
		begin
			CurIdx := TGimbalIDEPlugin(FPlugins[Idx]).PluginIdx;

			for Idy := FPluginMenuObjects.Count - 1 downto 0  do
				if TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).PluginIdx = CurIdx then
				begin
					TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).Item.Free;
					TGimbalIDEMenuItem(FPluginMenuObjects[Idy]).Free;
					FPluginMenuObjects.Delete(Idy);
				end;

			for Idy := FPluginCommandObjects.Count - 1 downto 0 do
				if TGimbalIDECommand(FPluginCommandObjects[Idy]).PluginIdx  = CurIdx then
				begin
					TGimbalIDECommand(FPluginCommandObjects[Idy]).Notifier := nil;
					TGimbalIDECommand(FPluginCommandObjects[Idy]).Action.Free;
					FPluginCommandObjects.Delete(Idy);
				end;

			for Idy := FIDENotifierChain.Count - 1 downto 0 do
				if TGimbalIDENotifierObject(FIDENotifierChain[Idy]).PluginIdx  = CurIdx then
				begin
					TGimbalIDENotifierObject(FIDENotifierChain[Idy]).IDEInterface := nil;
					FIDENotifierChain.Delete(Idy);
				end;

			H := TGimbalIDEPlugin(FPlugins[Idx]).DLLHandle;
			Bill := TGimbalIDEPlugin(FPlugins[Idx]);
			FPlugins.Remove(Bill);
			Bill.Free;
			FreeLibrary(H);
			RefreshPluginsDialog;
			Break;
		end;
	end;
end;

procedure TMarathonIDE.InitPlugins;
var
	Idx: Integer;
	R: TRegistry;
	L: TStringList;
	FileName: String;

begin
	R := TRegistry.Create;
	L := TStringList.Create;
	try
		if R.OpenKey(REG_SETTINGS_PLUGINS, False) then
		begin
			R.GetValueNames(L);
			for Idx := 0 to L.Count - 1 do
			begin
				FileName := R.ReadString(L[Idx]);
				LoadPluginFromFile(FileName);
			end;
			R.CloseKey;
		end;
	finally
		R.Free;
		L.Free;
	end;
end;

procedure TMarathonIDE.CreateProjectFolder(Item: TMarathonCacheBaseNode);
var
	wNode: TrmTreeNonViewNode;
	NV: TrmTreeNonViewNode;
//	CNV: TrmTreeNonViewNode;
	wFolder: TMarathonCacheProjectFolder;
//	Usages: TStringList;
//	Found: Boolean;
	F: TfrmInputDialog;

begin
	F := TfrmInputDialog.Create(nil);
	try
    F.Caption := 'New Project Folder';
		F.lblPrompt.Caption := 'Enter a name for the new folder';
		if F.ShowModal = mrOK then
		begin
			NV := Item.ContainerNode;
			if Assigned(NV) then
			begin
				wNode := FCurrentProject.Cache.Cache.AddPathNode(NV, F.edItem.Text);
				wFolder := TMarathonCacheProjectFolder.Create;
				wFolder.ContainerNode := wNode;
				wFolder.RootItem := FCurrentProject.Cache;
				wFolder.Caption := F.edItem.Text;
				wFolder.Expanded := True;
				wNode.Data := wFolder;
				if Assigned(NV.Data) then
					TMarathonCacheBaseNode(NV.Data).DoOperation(opRefresh);
			end;
		end;
	finally
		F.Free;
	end;
end;

procedure TMarathonIDE.DoDebuggerEnabled;
begin
	FDebuggerVM.Enabled := not FDebuggerVM.Enabled;
end;

function TMarathonIDE.IsDebuggerEnabled: Boolean;
begin
  Result := FDebuggerVM.Enabled;
end;

function TMarathonIDE.CanDebuggerEnabled: Boolean;
begin
  Result := not FDebuggerVM.Executing;
end;

function TMarathonIDE.CheckConnected(Connection: String): Boolean;
begin
  if not FCurrentProject.Cache.ConnectionByName[Connection].Connected then
  begin
    if not FCurrentProject.Cache.ConnectionByName[Connection].Connect then
			Result := False
		else
			Result := True;
	end
	else
		Result := True;
end;

function TMarathonIDE.IDEAddSQLEditorKeyPressNotifier(ThisPlugin: Integer; Notifier: IGimbalIDEEditorKeyPressNotifier): Boolean;
var
	NotifierObj: TGimbalIDENotifierObject;

begin
	NotifierObj := TGimbalIDENotifierObject.Create;
	NotifierObj.PluginIdx := ThisPlugin;
	NotifierObj.IDEInterface := Notifier;
	FIDENotifierChain.Add(NotifierObj);
end;

procedure TMarathonIDE.ProcessKeyPressNotifierChain(Key: Word; Shift: TShiftstate);
var
	Idx: Integer;
	NotifierObj: TGimbalIDENotifierObject;
	Intf: IGimbalIDEEditorKeyPressNotifier;

begin
	for Idx := 0 to FIDENotifierChain.Count - 1 do
	begin
		NotifierObj := TGimbalIDENotifierObject(FIDENotifierChain[Idx]);
		NotifierObj.IDEInterface.QueryInterface(IGimbalIDEEditorKeyPressNotifier, Intf);
		if Assigned(Intf) then
			Intf.IDEKeyPress(Shift, Key);
	end;
end;

function TMarathonIDE.GetMatchingTableEditor(TableName: String): IMarathonTableEditor;
var
	I: Integer;
	Editor: TfrmTables;
	VEditor: TfrmViewEditor;

begin
	Result := nil;
	for i := 0 to Screen.FormCount-1 do
	begin
		if Screen.Forms[I] is TfrmTables Then
		begin
			Editor := TfrmTables(Screen.Forms[I]);
			if Editor.ObjectName = TableName then
			begin
				Result := Editor;
				Break;
			end;
		end;
		if Screen.Forms[I] is TfrmViewEditor Then
		begin
			VEditor := TfrmViewEditor(Screen.Forms[I]);
			if VEditor.ObjectName = TableName then
			begin
				Result := VEditor;
				Break;
			end;
		end;
	end;
end;

procedure TMarathonIDE.CLoseDroppedTrigger(TriggerName: String);
var
	I: Integer;
	Editor: TfrmTriggerEditor;

begin
	for I := 0 to Screen.FormCount-1 do
		if Screen.Forms[I] is TfrmTriggerEditor Then
		begin
			Editor := TfrmTriggerEditor(Screen.Forms[I]);
			if Editor.ObjectName = TriggerName then
			begin
				Editor.DropClose;
				Break;
			end;
		end;
end;

procedure TMarathonIDE.ScriptScriptRecording;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmScriptEditorHost;

begin
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
	begin
		if Screen.Forms[Idx] is TfrmScriptEditorHost then
		begin
			Found := True;
			F := TfrmScriptEditorHost(Screen.Forms[Idx]);
			if F.WindowState = wsMinimized then
				F.WindowState := wsNormal;
			F.BringToFront;
		end;
	end;
	if not Found then
	begin
		F := TfrmScriptEditorHost.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.UpdateScriptRecorderHost;
var
	Idx: Integer;
	F: TfrmScriptEditorHost;

begin
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmScriptEditorHost then
		begin
			F := TfrmScriptEditorHost(Screen.Forms[Idx]);
			F.UpdateConnections;
		end;
end;

procedure TMarathonIDE.DisconnectHandler(Sender: TObject; ConnectionName: String);
var
	I: Integer;

begin
	for I := 0 to Screen.FormCount - 1 do
		if Screen.Forms[I] is TfrmBaseDocumentDataAwareForm Then
		begin
			if TfrmBaseDocumentForm(Screen.Forms[i]).GetActiveConnectionName = ConnectionName then
				TfrmBaseDocumentForm(Screen.Forms[i]).ByPassClose;
		end;
end;

function TMarathonIDE.IDEGetApplicationHandle: THandle;
begin
	Result := Application.Handle;
end;

function TMarathonIDE.IDEGetMenu(MenuType: TGimbalMenuType): IGimbalIDEMenus;
begin
	case MenuType of
		mtMain:
			begin
        raise exception.Create('IDEGetMenu');
//				FMenus.Menu := frmMarathonMain.MainMenu1;
//				Result := FMenus;
			end;

		mtBrowser:
			begin
				FMenus.Menu := dmMenus.mnuTree;
				Result := FMenus;
			end;

		mtTableEditor:
			begin
				FMenus.Menu := dmMenus.mnuFields;
				Result := FMenus;
			end;

		mtEditor:
			begin
				FMenus.Menu := dmMenus.mnuSQLEditor;
				Result := FMenus;
			end;
	end;
end;

function TMarathonIDE.IDEGetActiveWindow: IGimbalIDEWindow;
var
	F: IMarathonForm;
	R: IGimbalIDEWindow;

begin
	Result := nil;
	F := ScreenActiveForm;
	if Assigned(F) then
		if F.QueryInterface(IGimbalIDEWindow, R) = S_OK then
			Result := R;
end;

function TMarathonIDE.IDEGetProject: IGimbalIDEMarathonProject;
begin
	Result := TGimbalIDEMarathonProject.Create;
end;

procedure TMarathonIDE.IDERecordToScript(ConnectionName, Script: WideString);
begin
  RecordToScript(Script, ConnectionName);
end;

procedure TMarathonIDE.PrintPerformanceAnalysis(Preview: Boolean; Query: TStrings;
  Dataset: TDataSet; Chart: TChart);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintPerformanceAnalysis(Preview, Query, DataSet, Chart);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintQueryPlan(Preview: Boolean; Query: TStrings; Plan: String; GPlan: TMetafile);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintQueryPlan(Preview, Query, Plan, GPlan);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintLinesWithTitle(Lines: TStrings;
	PageTitle: String; Preview: Boolean; Title: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintLinesWithTitle(Lines, PageTitle, Preview, Title);
	finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintDomain(Preview: Boolean; ObjectName, ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintDomain(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintException(Preview: Boolean; ObjectName, ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintException(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintGenerator(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintGenerator(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTable(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTable(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTableConstraints(Preview: Boolean; ObjectName, ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTableConstraints(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTableIndexes(Preview: Boolean; ObjectName, ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTableIndexes(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTableTriggers(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTableTriggers(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTrigger(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTrigger(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintUDF(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintUDF(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintView(Preview: Boolean; ObjectName, ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintView(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintViewStruct(Preview: Boolean; ObjectName, ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintViewStruct(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintViewTriggers(Preview: Boolean; ObjectName, ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintViewTriggers(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintSP(Preview: Boolean; ObjectName,
  ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintSP(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintObjectDependencies(Preview: Boolean;
  ObjectName, ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
	try
    P.PrintObjectDependencies(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintObjectDoco(Preview: Boolean; ObjectName,
  ConnectionName: String; ObjectType: TGSSCacheType);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintObjectDoco(Preview, ObjectName, ConnectionName, ObjectType);
  finally
    if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintObjectDRUIMatrix(Preview: Boolean; ObjectName,
  ConnectionName: String; ObjectType: TGSSCacheType);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintObjectDRUIMatrix(Preview, ObjectName, ConnectionName, ObjectType);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintObjectDDL(Preview: Boolean; ObjectName,
	ConnectionName: String; ObjectType: TGSSCacheType);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintObjectDDL(Preview, ObjectName, ConnectionName, ObjectType);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintObjectPerms(Preview: Boolean; ObjectName,
  ConnectionName: String; ObjectType: TGSSCacheType);
var
  P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintObjectPerms(Preview, ObjectName, ConnectionName, ObjectType);
  finally
    if not Preview then
      P.Free;
  end;
end;

function TMarathonIDE.IDECreateMarathonForm: IGimbalIDEMarathonForm;
var
  FObj: TGimbalIDEMarathonForm;
  FForm: TfrmMarathonToolsDocForm;
begin
  if FCurrentProject.Open then
  begin
    FObj := TGimbalIDEMarathonForm.Create;
    FForm := TfrmMarathonToolsDocForm.Create(nil);
    FObj.Form := FFOrm;
    FForm.FormInterface := FObj;
    Result := FObj;
  end
  else
    Result := nil;
end;

procedure TMarathonIDE.DoAboutBox;
var
  F: TfrmAboutBox;

begin
	F := TfrmAboutBox.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TMarathonIDE.DoViewBreakPoints;
var
  Idx: Integer;
  Found: Boolean;
  F: TfrmDebugBreakPoints;
begin
  Found := False;
  for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmDebugBreakpoints then
		begin
			F := TfrmDebugBreakPoints(Screen.Forms[Idx]);
			F.BringToFront;
			Found := True;
			Break;
		end;
	if not Found then
	begin
		F := TfrmDebugBreakPoints.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.DoViewWatches;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmWatches;

begin
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmWatches then
		begin
			F := TfrmWatches(Screen.Forms[Idx]);
			F.BringToFront;
			Found := True;
			Break;
		end;
	if not Found then
	begin
		F := TfrmWatches.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.DoViewCallStack;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmDebugCallStack;

begin
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmDebugCallStack then
		begin
			F := TfrmDebugCallStack(Screen.Forms[Idx]);
			F.BringToFront;
			Found := True;
			Break;
		end;
	if not Found then
	begin
		F := TfrmDebugCallStack.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.DoViewLocalVars;
var
	Idx: Integer;
	Found: Boolean;
	F: TfrmDebugLocals;

begin
	Found := False;
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmDebugLocals then
		begin
			F := TfrmDebugLocals(Screen.Forms[Idx]);
			F.BringToFront;
			Found := True;
			Break;
		end;
	if not Found then
	begin
		F := TfrmDebugLocals.Create(nil);
		F.Show;
	end;
end;

procedure TMarathonIDE.PrintDomains(Preview: Boolean; ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintDomains(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintDatabase(Preview: Boolean; ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintDatabase(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintSPs(Preview: Boolean; ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintSps(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintExceptions(Preview: Boolean; ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintExceptions(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintGenerators(Preview: Boolean; ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintGenerators(Preview, ConnectionName);
	finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintTables(Preview: Boolean; ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTables(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTableStruct(Preview: Boolean; ObjectName,	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintTableStruct(Preview, ObjectName, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintTriggers(Preview: Boolean; ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintTriggers(Preview, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintUDFs(Preview: Boolean; ConnectionName: String);
var
  P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintUDFs(Preview, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.PrintViews(Preview: Boolean;	ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
	P := TfrmGlobalPrintingRoutines.Create(nil);
	try
		P.PrintViews(Preview, ConnectionName);
	finally
		if not Preview then
			P.Free;
	end;
end;

procedure TMarathonIDE.PrintViewSource(Preview: Boolean; ObjectName, ConnectionName: String);
var
	P: TfrmGlobalPrintingRoutines;

begin
  P := TfrmGlobalPrintingRoutines.Create(nil);
  try
    P.PrintViewSource(Preview, ObjectName, ConnectionName);
  finally
    if not Preview then
      P.Free;
  end;
end;

procedure TMarathonIDE.DoStatus(Status: String);
begin
  if Assigned(FMainForm) then
    FMainForm.DoStatus(Status);
end;

procedure TMarathonIDE.RefreshCodeSnippets(Snip: string);
var
 	Idx: Integer;
begin
	for Idx := 0 to Screen.FormCount - 1 do
		if Screen.Forms[Idx] is TfrmCodeSnippets then
			TfrmCodeSnippets(Screen.Forms[Idx]).AddSnippet(Snip);
end;

initialization
  MarathonIDEInstance := TMarathonIDE.Create(nil);
  MarathonIDEInstance._AddRef;

finalization
	MarathonIDEInstance.Free;
  MarathonIDEInstance := nil;

end.

{
$Log: MarathonIDE.pas,v $
Revision 1.16  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.15  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.14  2005/06/29 22:29:51  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.13  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.12  2005/04/13 16:04:29  rjmills
*** empty log message ***

Revision 1.10  2003/12/21 11:06:34  tmuetze
Added Alberts changes to get rid of some tree related AVs

Revision 1.9  2003/11/15 15:03:41  tmuetze
Minor changes and some cosmetic ones

Revision 1.8  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.7  2002/04/29 14:46:11  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.6  2002/04/29 06:48:50  tmuetze
Fixed bug 538259, charsets are not saved

Revision 1.5  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
