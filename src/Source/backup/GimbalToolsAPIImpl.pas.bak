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
// $Id: GimbalToolsAPIImpl.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit GimbalToolsAPIImpl;

interface

uses
	Windows, SysUtils, Classes, ActnList, Menus, Dialogs, Forms,
	GimbalToolsAPI,
	MarathonProjectCache,
	MarathonProjectCacheTypes;

type
  TGimbalIDEPlugin = class(TObject)
  private
    FPluginIdx: Integer;
    FHandle: THandle;
    FName : String;
    FDLLName: String;
  public
    property PluginIdx : Integer read FPluginIdx write FPluginIdx;
    property DLLHandle : THandle read FHandle write FHandle;
    property Name : String read FName write FName;
    property DLLName : String read FDLLName write FDLLName;
    destructor Destroy; override;
  end;

  TGimbalIDENotifierObject = class(TObject)
  private
    FIDEInterface: IUnknown;
    FPluginIdx: Integer;
  public
    property IDEInterface : IUnknown read  FIDEInterface write FIDEInterface;
    property PluginIdx : Integer read FPluginIdx write FPluginIdx;
  end;

  IGimbalInternalIDECommand = interface
    ['{70D3AD9D-E70D-4567-BBC8-AF35AAC6DBB1}']
    function GetActionItem : TAction;
  end;

  TGimbalIDECommand = class;

  TGimbalInternalAction = class(TAction)
  private
    FIDECommand: TGimbalIDECommand;
  public
    property IDECOmmand : TGimbalIDECommand read FIDECommand write FIDECommand;
    destructor Destroy; override;
  end;

  TGimbalIDECommand = class(TInterfacedObject, IGimbalIDECommand, IGimbalInternalIDECommand)
  private
    FNotifier : IGimbalIDECommandNotifier;
    FAction: TAction;
    FName: String;
    FPluginIdx: Integer;
    procedure IDESetCommandNotifier(Value : IGimbalIDECommandNotifier); safecall;
    function IDEGetCommandNotifier : IGimbalIDECommandNotifier; safecall;
    function GetActionItem : TAction;
    procedure IDERemove; safecall;
  public
    property Notifier : IGimbalIDECommandNotifier read FNotifier write FNotifier;
    property Action : TAction read FAction write FAction;
    property Name : String read FName write FName;
    property PluginIdx : Integer read FPluginIdx write FPluginIdx;
    procedure IDESetCaption(Value : WideString);
    function IDEGetCaption : WideString;
    constructor Create;
    destructor Destroy; override;
  end;

  TGimbalIDEMenuItem = class(TComponent, IGimbalIDEMenuItem)
  private
    FItem : TMenuItem;
    FPluginIdx: Integer;
    function IDEMenuCount : Integer; safecall;
    function IDEMenuItem(Index : Integer) : IGimbalIDEMenuItem; safecall;
    function IDEGetIndex : Integer; safecall;
    function IDEGetName : WideString; safecall;
    function IDEAddMenuItem(ThisPlugin : Integer; Index : Integer; Name : WideString; Caption : WideString; IsSubItem : Boolean; Command : IGimbalIDECommand) : IGimbalIDEMenuItem; safecall;
    procedure IDERemove; safecall;
  public
    property Item : TMenuItem read FItem write FItem;
    property PluginIdx : Integer read FPluginIdx write FPluginIdx;
    constructor Create(MenuItem : TMenuItem); reintroduce;
    destructor Destroy; override;
  end;

	TGimbalIDEMenus = class(TComponent, IGimbalIDEMenus)
  private
    FMenu: TMenu;
    function IDEMenuCount : Integer; safecall;
    function IDEMenuItem(Index : Integer) : IGimbalIDEMenuItem; safecall;
    function IDEAddMenuItem(ThisPlugin : Integer; Index : Integer; Name : WideString; Caption : WideString; IsSubItem : Boolean; Command : IGimbalIDECommand) : IGimbalIDEMenuItem; safecall;
  public
    property Menu : TMenu read FMenu write FMenu;
    destructor Destroy; override;
  end;

  TGimbalIDESelectedItem = class(TInterfacedObject, IGimbalIDESelectedItem)
  private
    FConnectionName: String;
    FName: String;
    FItemType: TGimbalIDESelectedItemType;
  public
    function IDEGetItemType : TGimbalIDESelectedItemType; safecall;
    function IDEGetName : WideString; safecall;
    function IDEGetConnectionName : WideString; safecall;
    property Name : String read FName write FName;
    property ConnectionName : String read FConnectionName write FConnectionName;
    property ItemType : TGimbalIDESelectedItemType read FItemType write FItemType;
  end;


  TGimbalIDESelectedItems = class(TInterfacedObject, IGimbalIDESelectedItems)
  private
    FList : TList;
  public
    function IDEGetCount : Integer; safecall;
    function IDEGetItem(Index : Integer) : IGimbalIDESelectedItem; safecall;
    function Add : TGimbalIDESelectedItem;
    constructor Create;
    destructor Destroy; override;
  end;


  TGimbalIDEMarathonProject = class(TInterfacedObject, IGimbalIDEMarathonProject)
	private
    function IDEGetConnectionCount : Integer; safecall;
    function IDEGetOpen : Boolean; safecall;
    function IDEGetConnection(Index : Integer) : IGimbalIDEConnection; safecall;
    function IDEGetConnectionByName(Index : WideString) : IGimbalIDEConnection; safecall;
    procedure IDEAddItemToTree(ConnectionName : WideString; ObjectName : WideString; ObjectType : TGimbalIDETreeType); safecall;
    procedure IDEWriteCustomProperty(PropertyName : String; PropertyValue : Variant); safecall;
    function IDEReadCustomProperty(PropertyName : String) : Variant; safecall;
  public

  end;

  TGimbalIDEConnection = class(TInterfacedObject, IGimbalIDEConnection)
  private
    FConnection: TMarathonCacheConnection;
    function IDEGetCurrentDBHandle : Integer; safecall;
    function IDEGetCurrentTransHandle : Integer; safecall;
    function IDEGetIsInterbaseSix : Boolean; safecall;
    function IDEGetSQLDialect : Integer; safecall;
  public
    property Connection : TMarathonCacheConnection read FConnection write FConnection;
  end;

  TGimbalIDEMarathonForm = class(TInterfacedObject, IGimbalIDEMarathonForm)
  private
    FDocInterface : IGimbalIDEPluginDocInterface;
    FForm: TForm;
    function GetIDEHandle : THandle; safecall;
    function GetIDEPluginDocInterface : IGimbalIDEPluginDocInterface; safecall;
    procedure SetIDEPluginDocInterface(Value : IGimbalIDEPluginDocInterface); safecall;
    procedure IDESetCaption(Value : WideString); safecall;
    function IDEGetCaption : WideString; safecall;
    procedure IDESHow; safecall;
    function IDEGetClientRect : TRect; safecall;
    procedure IDEBringToFront; safecall;
  public
    property Form : TForm read FForm write FForm;
    property DocInterface : IGimbalIDEPluginDocInterface read FDocInterface;
  end;

	function CacheTypetoItemType(CacheType : TGSSCacheType) : TGimbalIDESelectedItemType;
	function TreeTypetoCacheType(CacheType : TGimbalIDETreeType) : TGSSCacheType;

implementation

uses
  MarathonToolsAPIDocForm,
  MarathonIDE;

function CacheTypetoItemType(CacheType : TGSSCacheType) : TGimbalIDESelectedItemType;
begin
  case CacheType of
    ctDontCare:
      Result := ctIDEUnknown;
    ctErrorItem:
      Result := ctIDEUnknown;
    ctConnection:
      Result := ctIDEConnection;
    ctServer:
      Result := ctIDEServer;
    ctSQL:
      Result := ctIDEUnknown;
    ctSQLEditor:
      Result := ctIDEUnknown;
    ctFolder:
      Result := ctIDEFolder;
    ctFolderItem:
      Result := ctIDEFolderItem;
    ctRecentHeader:
      Result := ctIDERecentHeader;
    ctRecentItem:
      Result := ctIDERecentItem;
    ctCacheHeader:
      Result := ctIDEUnknown;
    ctDomainHeader:
      Result := ctIDEDomainHeader;
    ctDomain:
      Result := ctIDEDomain;
    ctTableHeader:
      Result := ctIDETableHeader;
    ctTable:
      Result := ctIDETable;
		ctViewHeader:
      Result := ctIDEViewHeader;
    ctView:
      Result := ctIDEView;
    ctSPHeader:
      Result := ctIDESPHeader;
    ctSP:
      Result := ctIDESP;
    ctSPTemplate:
      Result := ctIDEUnknown;
    ctTriggerHeader:
      Result := ctIDETriggerHeader;
    ctTrigger:
      Result := ctIDETrigger;
    ctGeneratorHeader:
      Result := ctIDEGeneratorHeader;
    ctGenerator:
      Result := ctIDEGenerator;
    ctExceptionHeader:
      Result := ctIDEExceptionHeader;
    ctException:
      Result := ctIDEException;
    ctUDFHeader:
      Result := ctIDEUDFHeader;
    ctUDF:
      Result := ctIDEUDF;
  end;
end;

function TreeTypetoCacheType(CacheType : TGimbalIDETreeType) : TGSSCacheType;
begin
  case CacheType of
    ttIDEDomain :
      Result := ctDomain;

    ttIDETable :
      Result := ctTable;

    ttIDEView :
			Result := ctView;

    ttIDESP :
      Result := ctSP;

    ttIDETrigger :
      Result := ctTrigger;

    ttIDEGenerator :
      Result := ctGenerator;

    ttIDEException :
      Result := ctException;

    ttIDEUDF :
      Result := ctUDF;

  end;
end;
{ TGimbalIDECommand }

constructor TGimbalIDECommand.Create;
begin
  inherited;
end;

destructor TGimbalIDECommand.Destroy;
begin
  inherited;
end;

function TGimbalIDECommand.GetActionItem: TAction;
begin
  Result := FAction;
end;

function TGimbalIDECommand.IDEGetCaption: WideString;
begin
  Result := FAction.Caption;
end;

function TGimbalIDECommand.IDEGetCommandNotifier: IGimbalIDECommandNotifier;
begin
  Result := FNotifier;
end;

procedure TGimbalIDECommand.IDERemove;
begin
  FNotifier := nil;
  FAction.Free;
end;

procedure TGimbalIDECommand.IDESetCaption(Value: WideString);
begin
  FAction.Caption := Value;
end;

procedure TGimbalIDECommand.IDESetCommandNotifier(Value: IGimbalIDECommandNotifier);
begin
  FNotifier := Value;
end;

{ TGimbalIDEMenus }

function TGimbalIDEMenus.IDEAddMenuItem(ThisPlugin, Index: Integer; Name,
  Caption: WideString; IsSubItem: Boolean;
  Command: IGimbalIDECommand): IGimbalIDEMenuItem;
var
  M : TMenuItem;
  Idx : Integer;
  MI : TGimbalIDEMenuItem;

begin
  Result := nil;
  for Idx := 0 to MarathonIDEInstance.PluginMenuObjects.Count - 1 do
  begin
    if TObject(MarathonIDEInstance.PluginMenuObjects[Idx]) is TGimbalIDEMenuItem then
    begin
			if TGimbalIDEMenuItem(MarathonIDEInstance.PluginMenuObjects[Idx]).Name = Name then
      begin
        MessageDlg('Menu item "' + Name + '" already exists.', mtError, [mbOK], 0);
        Exit;
      end;
    end;
  end;

  M := TMenuItem.Create(Self);
  M.Name := Name;
  M.Caption := Caption;
  if Assigned(Command) then
    M.Action := (Command as IGimbalInternalIDECommand).GetActionItem;
  FMenu.Items.Insert(Index, M);

  MI := TGimbalIDEMenuItem.Create(M);
  MI.Item := M;
  MI.PluginIdx := ThisPlugin;

  MarathonIDEInstance.PluginMenuObjects.Add(MI);
  Result := MI;
end;

destructor TGimbalIDEMenus.Destroy;
begin
  inherited;
end;

function TGimbalIDEMenus.IDEMenuCount: Integer;
begin
  Result := FMenu.Items.Count;
end;

function TGimbalIDEMenus.IDEMenuItem(Index: Integer): IGimbalIDEMenuItem;
var
  Item : IGimbalIDEMenuItem;

begin
  try
		Item := TGimbalIDEMenuItem.Create(FMenu.Items[Index]);
    Result := Item;
  except
    On E : Exception do
    begin
      Result := nil;
    end;
  end;
end;

{ TGimbalIDEMenuItem }

function TGimbalIDEMenuItem.IDEAddMenuItem(ThisPlugin : Integer; Index : Integer; Name : WideString; Caption : WideString; IsSubItem : Boolean; Command : IGimbalIDECommand) : IGimbalIDEMenuItem; safecall;
var
  M : TMenuItem;
  Idx : Integer;
  MI : TGimbalIDEMenuItem;

begin
  Result := nil;
  for Idx := 0 to MarathonIDEInstance.PluginMenuObjects.Count - 1 do
  begin
    if TObject(MarathonIDEInstance.PluginMenuObjects[Idx]) is TGimbalIDEMenuItem then
    begin
      if TGimbalIDEMenuItem(MarathonIDEInstance.PluginMenuObjects[Idx]).Name = Name then
      begin
        MessageDlg('Menu item "' + Name + '" already exists.', mtError, [mbOK], 0);
        Exit;
      end;
    end;
  end;

  M := TMenuItem.Create(Self);
  M.Name := Name;
  M.Caption := Caption;
  if Assigned(Command) then
    M.Action := (Command as IGimbalInternalIDECommand).GetActionItem;
  FItem.Insert(Index, M);

	MI := TGimbalIDEMenuItem.Create(M);
  MI.Item := M;
  MI.PluginIdx := ThisPlugin;

  MarathonIDEInstance.PluginMenuObjects.Add(MI);
  Result := MI;
end;

constructor TGimbalIDEMenuItem.Create(MenuItem: TMenuItem);
begin
  inherited Create(nil);
  FItem := MenuItem;
end;

destructor TGimbalIDEMenuItem.Destroy;
begin
  inherited;
end;

function TGimbalIDEMenuItem.IDEGetIndex: Integer;
begin
  Result := FItem.MenuIndex;
end;

function TGimbalIDEMenuItem.IDEGetName: WideString;
begin
  Result := FItem.Caption;
end;

function TGimbalIDEMenuItem.IDEMenuCount: Integer;
begin
  Result := FItem.Count;
end;

function TGimbalIDEMenuItem.IDEMenuItem(Index: Integer): IGimbalIDEMenuItem;
var
  Item : IGimbalIDEMenuItem;

begin
	try
    Item := TGimbalIDEMenuItem.Create(FItem.Items[Index]);
    Result := Item;
  except
    On E : Exception do
    begin
      Result := nil;
    end;
  end;
end;

procedure TGimbalIDEMenuItem.IDERemove;
begin
  FItem.Free;
end;


{ TGimbalIDEPlugin }

destructor TGimbalIDEPlugin.Destroy;
begin
  inherited;
end;

{ TGimbalInternalAction }

destructor TGimbalInternalAction.Destroy;
begin
  inherited;
end;


{ TGimbalIDESelectedItems }

function TGimbalIDESelectedItems.Add: TGimbalIDESelectedItem;
begin
  Result := TGimbalIDESelectedItem.Create;
  FList.Add(Result);
end;


constructor TGimbalIDESelectedItems.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TGimbalIDESelectedItems.Destroy;
begin
  FList.Free;
  inherited;
end;

function TGimbalIDESelectedItems.IDEGetCount: Integer;
begin
  Result := FList.Count;
end;

function TGimbalIDESelectedItems.IDEGetItem(Index: Integer): IGimbalIDESelectedItem;
begin
  try
    Result := TGimbalIDESelectedItem(FList[Index]);
  except
    Result := nil;
  end;     
end;

{ TGimbalSelectedItem }

function TGimbalIDESelectedItem.IDEGetConnectionName: WideString;
begin
  Result := FConnectionName;
end;

function TGimbalIDESelectedItem.IDEGetItemType: TGimbalIDESelectedItemType;
begin
  Result := FItemType;
end;

function TGimbalIDESelectedItem.IDEGetName: WideString;
begin
  Result := FName;
end;

{ TGimbalIDEMarathonProject }

procedure TGimbalIDEMarathonProject.IDEAddItemToTree(ConnectionName, ObjectName: WideString; ObjectType: TGimbalIDETreeType);
begin
  MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(ConnectionName, ObjectName, TreeTypeToCacheType(ObjectType));
end;

function TGimbalIDEMarathonProject.IDEGetConnection(Index: Integer): IGimbalIDEConnection;
var
  Connection : TGimbalIDEConnection;
  InternalConn : TMarathonCacheConnection;

begin
  InternalConn := MarathonIDEInstance.CurrentProject.Cache.Connections[Index];
  if Assigned(InternalConn) then
  begin
    Connection := TGimbalIDEConnection.Create;
    Connection.Connection := InternalConn;
    Result := Connection;
  end
  else
    Result := nil;
end;

function TGimbalIDEMarathonProject.IDEGetConnectionByName(Index: WideString): IGimbalIDEConnection;
var
  Connection : TGimbalIDEConnection;
  InternalConn : TMarathonCacheConnection;

begin
  InternalConn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Index];
  if Assigned(InternalConn) then
  begin
		Connection := TGimbalIDEConnection.Create;
    Connection.Connection := InternalConn;
    Result := Connection;
  end
  else
    Result := nil;
end;

function TGimbalIDEMarathonProject.IDEGetConnectionCount: Integer;
begin
  Result := MarathonIDEInstance.CurrentProject.Cache.ConnectionCount;
end;

function TGimbalIDEMarathonProject.IDEGetOpen: Boolean;
begin
  Result := MarathonIDEInstance.CurrentProject.Open;
end;

function TGimbalIDEMarathonProject.IDEReadCustomProperty(PropertyName: String): Variant;
begin
  Result := MarathonIDEInstance.CurrentProject.ReadCustomProperty(PropertyName);
end;

procedure TGimbalIDEMarathonProject.IDEWriteCustomProperty(PropertyName: String; PropertyValue: Variant);
begin
  MarathonIDEInstance.CurrentProject.WriteCustomProperty(PropertyName, PropertyValue);
end;

{ TGimbalIDEConnection }

function TGimbalIDEConnection.IDEGetCurrentDBHandle: Integer;
begin
  Result := Integer(FConnection.Connection.dbHandle);
end;

function TGimbalIDEConnection.IDEGetCurrentTransHandle: Integer;
begin
  Result := Integer(FConnection.Transaction.trHandle);
end;

function TGimbalIDEConnection.IDEGetIsInterbaseSix: Boolean;
begin
	Result := FConnection.IsIB6;
end;

function TGimbalIDEConnection.IDEGetSQLDialect: Integer;
begin
	Result := FConnection.SQLDialect;
end;

{ TGimbalIDEMarathonForm }

function TGimbalIDEMarathonForm.GetIDEHandle: THandle;
begin
  Result := FForm.Handle;
end;

function TGimbalIDEMarathonForm.GetIDEPluginDocInterface: IGimbalIDEPluginDocInterface;
begin
  Result := FDocInterface;
end;

procedure TGimbalIDEMarathonForm.IDEBringToFront;
begin
  if FForm.WindowState = wsMinimized then
    FForm.WindowState := wsNormal
  else
    FForm.BringToFront;
end;

function TGimbalIDEMarathonForm.IDEGetCaption: WideString;
begin
  Result := FForm.Caption;
end;

function TGimbalIDEMarathonForm.IDEGetClientRect: TRect;
begin
	Result := FForm.ClientRect;
end;

procedure TGimbalIDEMarathonForm.IDESetCaption(Value: WideString);
begin
  TfrmMarathonToolsDocForm(FForm).Caption := Value;
  TfrmMarathonToolsDocForm(FForm).InternalCaption := Value;
end;

procedure TGimbalIDEMarathonForm.IDESHow;
begin
	FForm.Show;
end;

procedure TGimbalIDEMarathonForm.SetIDEPluginDocInterface(Value: IGimbalIDEPluginDocInterface);
begin
	FDocInterface := Value;
end;

end.

{
$Log: GimbalToolsAPIImpl.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
