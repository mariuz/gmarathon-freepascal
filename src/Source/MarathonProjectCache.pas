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
// $Id: MarathonProjectCache.pas,v 1.14 2007/02/10 21:56:49 rjmills Exp $

{ History
	10.03.2002	tmuetze
		* TMarathonCacheConnection.GetDomainList, commented out the stuff that prevents
			the function from not getting back the Domains which start with $RDB
	05.02.2002	tmuetze
		* TMarathonCacheConnection.Connect, added a line which changes the variable
			FSQLDialect after the connect, if the connectino has detected the an other
			sql dialect. I think we can also drop the dialect from the project options dialog
			because the connection because of that.
}

{
$Log: MarathonProjectCache.pas,v $
Revision 1.14  2007/02/10 21:56:49  rjmills
Fix for Connection Information loss.  On connection failure it was forgetting the connection protocol and reverting to local.

Revision 1.13  2006/10/19 03:54:59  rjmills
Numerous bug fixes and current work in progress

Revision 1.12  2005/06/29 22:29:52  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.11  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.9  2003/12/21 11:06:34  tmuetze
Added Alberts changes to get rid of some tree related AVs

Revision 1.8  2003/11/15 15:03:41  tmuetze
Minor changes and some cosmetic ones

Revision 1.7  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.6  2002/05/04 08:48:12  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.5  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit MarathonProjectCache;

interface
{$I compilerdefines.inc}

uses
	SysUtils, Windows, Classes, ComCtrls, Controls, Dialogs,

	{$IFDEF D6_OR_HIGHER}
	Variants,
	{$ENDIF}
	rmTreeNonView,
	rmPathTreeView,
	IB_Components,
	IB_Session,
	IBODataset,
	DOM,
	XMLWrite,
	XMLRead,
	TypInfo,
	MarathonProjectCacheTypes,
	WindowLists,
	ScriptRecorder,
	GimbalToolsAPI;

const
   cSepChar = #2;

type
	TMarathonProjectDatabaseCache = class;

  TExtractType = (exMetaOnly, exMetaAndData, exDataOnly);

  TMarathonCacheBaseNode = class(TObject)
	private
    FItems: TList;
    FExpanded: Boolean;
    FCaption: String;
    FStatic: Boolean;
    FImageIndex: Integer;
    FRootItem: TMarathonProjectDatabaseCache;
    FContainerNode: TrmTreeNonViewNode;
    FWholePageContent: Boolean;
		FCacheType: TGSSCacheType;
    procedure SetCaption(const Value: String); virtual;
    function GetContentStr: String; virtual;
    function GetImageIndex: Integer; virtual;
    function GetOverlayIndex: integer; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Expand(Recursive: Boolean); virtual;
    procedure FireEvent(Event: TGSSCacheOp);
    function GetParentObject: TMarathonCacheBaseNode;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; virtual;
    procedure DoOperation(Op: TGSSCacheOp); virtual;
    procedure ClearList;
    procedure AddToList(Obj: TObject);
    procedure ResetCaption(Value: String); virtual;
    property SubItems: TList read FItems write FItems;
    property Expanded: Boolean read FExpanded write FExpanded;
    property Caption: String read FCaption write SetCaption;
    property ImageIndex: Integer read GetImageIndex write FImageIndex;
    property OverlayIndex: integer read GetOverlayIndex;
    property RootItem: TMarathonProjectDatabaseCache read FRootItem write FRootItem;
    property ContainerNode: TrmTreeNonViewNode read FContainerNode write FContainerNode;
    property ContentStr: String read GetContentStr;
		property WholePageContent: Boolean read FWholePageContent write FWholePageContent;
    property CacheType: TGSSCacheType read FCacheType write FCacheType;
  end;

	TMarathonCacheListNode = class(TObject)
	private
		FImageIndex: Integer;
		FCaption: String;
		FCacheType: TGSSCacheType;
		FConnectionName: String;
	public
		property Caption: String read FCaption write FCaption;
		property ConnectionName: String read FConnectionName write FConnectionName;
		property ImageIndex: Integer read FImageIndex write FImageIndex;
		property CacheType: TGSSCacheType read FCacheType write FCacheType;
	end;

	TMarathonCacheServersHeader = class(TMarathonCacheBaseNode)
	private
	public
		constructor Create; override;
		procedure Expand(Recursive: Boolean); override;
	end;

	TMarathonCacheConnectionsHeader = class(TMarathonCacheBaseNode)
	private
    function GetContentStr: String; override;
  public
    constructor Create; override;
    procedure Expand(Recursive: Boolean); override;
  end;

  TMarathonCacheServer = class(TMarathonCacheBaseNode)
	private
		FLocal: Boolean;
		FRememberPassword: Boolean;
		FSecureDatabaseRememberPassword: Boolean;
		FProtocol: Byte;
		FHostName: String;
		FPassword: String;
		FUserName: String;
		FSecureDatabaseName: String;
		FSecureDatabaseUsername: String;
		FSecureDatabasePassword: String;
		function GetConnected: Boolean;
		function GetEncPassword: String;
		function GetSecureDatabaseEncPassword: String;
		procedure SetHostName(const Value: String);
		procedure SetPassword(const Value: String);
		procedure SetRememberPassword(const Value: Boolean);
		procedure SetUserName(const Value: String);
		procedure SetLocal(const Value: Boolean);
		procedure SetProtocol(const Value: Byte);
		procedure SetSecureDatabaseName(const Value: String);
		procedure SetSecureDatabaseUserName(const Value: String);
		procedure SetSecureDatabasePassword(const Value: String);
		procedure SetSecureDatabaseRememberPassword(const Value: Boolean);
	public
		constructor Create; override;
		destructor Destroy; override;
		procedure Expand(Recursive: Boolean); override;
		procedure ResetCaption(Value: String); override;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
		function Connect: Boolean;
		procedure Disconnect;
		function IsIB5: Boolean;
		function IsIB6: Boolean;
		property Connected: Boolean read GetConnected;
		property HostName: String read FHostName write SetHostName;
		property UserName: String read FUserName write SetUserName;
		property EncPassword: String read GetEncPassword;
		property SecureDatabaseEncPassword: String read GetSecureDatabaseEncPassword;
		property Password: String read FPassword write SetPassword;
		property Local: Boolean read FLocal write SetLocal;
		property Protocol: Byte read FProtocol write SetProtocol;
		property RememberPassword: Boolean read FRememberPassword write SetRememberPassword;
		property SecureDatabaseName: String read FSecureDatabaseName write SetSecureDatabaseName;
		property SecureDatabaseUserName: String read FSecureDatabaseUserName write SetSecureDatabaseUserName;
		property SecureDatabasePassword: String read FSecureDatabasePassword write SetSecureDatabasePassword;
		property SecureDatabaseRememberPassword: Boolean read FSecureDatabaseRememberPassword write SetSecureDatabaseRememberPassword;
	end;

	TMarathonCacheServerAdminBackupHeader = class(TMarathonCacheBaseNode)
	private
		FServerName: String;
	public
		constructor Create; override;
		property ServerName: String read FServerName write FServerName;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
	end;

  TMarathonCacheServerAdminCertificatesHeader = class(TMarathonCacheBaseNode)
  private
    FServerName: String;
  public
    constructor Create; override;
    property ServerName: String read FServerName write FServerName;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
  end;

  TMarathonCacheServerAdminLogHeader = class(TMarathonCacheBaseNode)
	private
    FServerName: String;
  public
    constructor Create; override;
    property ServerName: String read FServerName write FServerName;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
  end;

  TMarathonCacheServerAdminUsersHeader = class(TMarathonCacheBaseNode)
  private
    FServerName: String;
  public
    constructor Create; override;
    property ServerName: String read FServerName write FServerName;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
  end;

	TMarathonCacheConnection = class(TMarathonCacheBaseNode)
	private
		FDBFileName: String;
		FUserName: String;
		FServerName: String;
		FConnection: TIB_Connection;
		FTransaction: TIB_Transaction;
		FPassword: String;
		FRememberPassword: Boolean;
		FSQLRole: String;
		FLangDriver: String;
		FSQLDialect: Integer;
		FTableList: TStringList;
		FViewList: TStringList;
		FDomainList: TStringList;
		FErrorOnConnection: Boolean;
		FRecorder: TfrmScriptRecorder;
		function GetEncPassword: String;
		procedure SetDBFileName(const Value: String);
		procedure SetServerName(const Value: String);
		procedure SetLangDriver(const Value: String);
		procedure SetPassword(const Value: String);
		procedure SetRememberPassword(const Value: Boolean);
		procedure SetSQLRole(const Value: String);
		procedure SetUserName(const Value: String);
		function GetConnected: Boolean;
		procedure SetSQLDialect(const Value: Integer);
		procedure SetCaption(const Value: String); override;
		function GetTableList: TStringList;
		function GetViewList: TStringList;
		function GetSQLDialect: Integer;
		function GetDomainList: TStringList;
    function GetOverlayIndex: integer; override;
    procedure SetErrorOnConnection(const Value: Boolean);
	public
		constructor Create; override;
		destructor Destroy; override;
		procedure Expand(Recursive: Boolean); override;
		procedure ResetCaption(Value: String); override;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
		function Connect: Boolean;
		procedure Disconnect;
		function IsIB5: Boolean;
		function IsIB6: Boolean;
		function GetDBCharSetName(CharSetID: Integer): String;
		function GetDBCollationName(CollationID, CharSetID: Integer): String;
		procedure GetCharSetNames(S: TStrings);
		procedure GetCollationNames(S: TStrings);
		property Connected: Boolean read GetConnected;
		property Connection: TIB_Connection read FConnection write FConnection;
		property Transaction: TIB_Transaction read FTransaction write FTransaction;
		property DBFileName: String read FDBFileName write SetDBFileName;
		property ServerName: String read FServerName write SetServerName;
		property UserName: String read FUserName write SetUserName;
		property SQLRole: String read FSQLRole write SetSQLRole;
		property SQLDialect: Integer read GetSQLDialect write SetSQLDialect;
		property EncPassword: String read GetEncPassword;
		property Password: String read FPassword write SetPassword;
		property LangDriver: String read FLangDriver write SetLangDriver;
		property RememberPassword: Boolean read FRememberPassword write SetRememberPassword;
		property ErrorOnConnection: Boolean read FErrorOnConnection write SetErrorOnConnection;
		property ScriptRecorder: TfrmScriptRecorder read FRecorder write FRecorder;
		// ObjectLists
		property TableList: TStringList read GetTableList;
		property ViewList: TStringList read GetViewList;
		property DomainList: TStringList read GetDomainList;
	end;

  TMarathonCacheHeader = class(TMarathonCacheBaseNode)
  private
    FConnectionName: String;
  public
    constructor Create; override;
    property ConnectionName: String read FConnectionName write FConnectionName;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
  end;

  TMarathonCacheObject = class(TMarathonCacheBaseNode)
  private
		FConnectionName: String;
		FSystem: Boolean;
		FObjectName: String;
	public
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
		property ConnectionName: String read FConnectionName write FConnectionName;
		property ObjectName: String read FObjectName write FObjectName;
		property System: Boolean read FSystem write FSystem;
	end;

	TMarathonCacheDomainsHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheUserDomainsHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheDomain = class(TMarathonCacheObject)
	private

	public
		constructor Create; override;
	end;

	TMarathonCacheTablesHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheSysTablesHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheTable = class(TMarathonCacheObject)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheViewsHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheView = class(TMarathonCacheObject)
	private

	public
		constructor Create; override;
	end;

	TMarathonCacheStoredProceduresHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheProcedure = class(TMarathonCacheObject)
	private

	public
		constructor Create; override;
	end;

	TMarathonCacheTriggersHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheSystemTriggersHeader = class(TMarathonCacheHeader)
	private

	public
		procedure Expand(Recursive: Boolean); override;
		constructor Create; override;
	end;

	TMarathonCacheTrigger = class(TMarathonCacheObject)
	private
    fIsActive: boolean;
    function getOverlayIndex:integer; override;
	public
    property IsActive : boolean read fIsActive write fIsActive;
		constructor Create; override;
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;

	end;

	TMarathonCacheGeneratorsHeader = class(TMarathonCacheHeader)
	private

  public
    procedure Expand(Recursive: Boolean); override;
    constructor Create; override;
  end;

  TMarathonCacheGenerator = class(TMarathonCacheObject)
  private

  public
    constructor Create; override;
  end;

  TMarathonCacheExceptionsHeader = class(TMarathonCacheHeader)
  private

  public
		procedure Expand(Recursive: Boolean); override;
    constructor Create; override;
  end;

  TMarathonCacheException = class(TMarathonCacheObject)
	private

  public
    constructor Create; override;
  end;

  TMarathonCacheUDFsHeader = class(TMarathonCacheHeader)
  private

  public
    procedure Expand(Recursive: Boolean); override;
    constructor Create; override;
  end;

  TMarathonCacheFunction = class(TMarathonCacheObject)
  private

  public
    constructor Create; override;
  end;

  TMarathonCacheProjectHeader = class(TMarathonCacheBaseNode)
  private

  public
    function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
    constructor Create; override;
    procedure Expand(Recursive: Boolean); override;
  end;

  TMarathonCacheProjectFolder = class(TMarathonCacheBaseNode)
  private

  public
		constructor Create; override;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
		procedure Expand(Recursive: Boolean); override;
	end;

	TMarathonProjectCacheFolderItem = class(TMarathonCacheBaseNode)
	private
		FConnection: String;
		FUsageCount: Integer;
		FActualCacheType: TGSSCacheType;
		FObjectName: String;
		function GetImageIndex: Integer; override;
	public
		property ConnectionName: String read FConnection write FConnection;
		property ObjectName: String read FObjectName write FObjectName;
		property UsageCount: Integer read FUsageCount write FUsageCount;
		property ActualCacheType: TGSSCacheType read FActualCacheType write FActualCacheType;
		constructor Create; override;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
	end;

	TMarathonCacheRecentHeader = class(TMarathonCacheBaseNode)
  private

	public
		constructor Create; override;
		procedure Expand(Recursive: Boolean); override;
	end;

	TMarathonCacheRecentItem = class(TMarathonCacheBaseNode)
	private
		FConnection: String;
		FUsageCount: Integer;
		FActualCacheType: TGSSCacheType;
		FObjectName: String;
		function GetImageIndex: Integer; override;
	public
		property ConnectionName: String read FConnection write FConnection;
		property ObjectName: String read FObjectName write FObjectName;
		property UsageCount: Integer read FUsageCount write FUsageCount;
		property ActualCacheType: TGSSCacheType read FActualCacheType write FActualCacheType;
		function CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean; override;
		constructor Create; override;
	end;

  TCacheEvent = procedure(Sender: TObject; Event: TGSSCacheOp; Item: TMarathonCacheBaseNode) of object;
  TDatabaseDisconnectingEvent = procedure(Sender: TObject; COnnectionName: String) of object;

  TMarathonProject = class;

  TMarathonProjectDatabaseCache = class(TComponent)
  private
    FCache: TrmTreeNonView;
    FModified: Boolean;
    FOnCacheEvent: TCacheEvent;
    FProjectItem: TMarathonProject;
		FConnectionsChanged: Boolean;
    FActiveConnection: String;
    FMultiSelectItem: TMarathonCacheBaseNode;
		FSearchList: TList;
    FOnDisconnecting: TDatabaseDisconnectingEvent;
		procedure BuildTree;
    function GetConnection(Index: Integer): TMarathonCacheConnection;
    function GetConnectionCount: Integer;
    function GetConnectionByName(Index: String): TMarathonCacheConnection;
    procedure SetModified(const Value: Boolean);
    procedure TreeDeletion(Sender: TObject; Node: TrmTreeNonViewNode);
    function GetServer(Index: Integer): TMarathonCacheServer;
    function GetServerByName(Index: String): TMarathonCacheServer;
    function GetServerCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
		function AddConnectionInternal: TMarathonCacheConnection;
    function AddServerInternal: TMarathonCacheServer;
    procedure DatabaseDisconnecting(ConnectionName: String);
    procedure StartTree(TV: TrmPathTreeView);
    procedure Clear;
		procedure AddRecentObjectOpen(ObjectName: String; ObjectType: TGSSCacheType; COnnectionName: String);
    procedure RemoveCacheItem(Item: TMarathonCacheBaseNode);
    procedure AddCacheItem(ConnectionName: String; ObjectName: String; ObjectType: TGSSCacheType);
    procedure RemoveCacheItemByName(Connection: String; ObjectName: String; ObjectType: TGSSCacheType);
    procedure FireEvent(Event: TGSSCacheOp; Item: TMarathonCacheBaseNode);
    procedure ClearSearchList;
    property ActiveConnection: String read FActiveConnection write FActiveConnection;
    property ConnectionCount: Integer read GetConnectionCount;
    property Connections[Index: Integer]: TMarathonCacheConnection read GetConnection;
    property ConnectionByName[Index: String]: TMarathonCacheConnection read GetConnectionByName;
    property ServerCount: Integer read GetServerCount;
    property Servers[Index: Integer]: TMarathonCacheServer read GetServer;
    property ServerByName[Index: String]: TMarathonCacheServer read GetServerByName;
    property Cache: TrmTreeNonView read FCache write FCache;
    property Modified: Boolean read FModified write SetModified;
    property OnCacheEvent: TCacheEvent read FOnCacheEvent write FOnCacheEvent;
    property ProjectItem: TMarathonProject read FProjectItem write FProjectItem;
		property ConnectionsChanged: Boolean read FCOnnectionsChanged write FConnectionsChanged;
    property MultiSelectItem: TMarathonCacheBaseNode read FMultiSelectItem write FMultiSelectItem;
    property SearchList: TList read FSearchList write FSearchList;
		property OnDatabaseDisconnecting: TDatabaseDisconnectingEvent read FOnDisconnecting write FOnDisconnecting;
	end;

	TSQLHistoryListItem = class(TCollectionItem)
	private
		FSQLText: TStringList;
		procedure SetSQLText(Value: TStringList);
		function GetSQLText: TStringList;
	protected

	public
		constructor Create(Collection: TCollection); Override;
		destructor Destroy; override;
	published
		property SQLText: TStringList read GetSQLText write SetSQLText;
	end;

	TSQLHistoryList = class(TCollection)
	private
		FOwner: TMarathonProject;
		function GetItem(Index: Integer): TSQLHistoryListItem;
		procedure SetItem(Index: Integer; Value: TSQLHistoryListItem);
	protected
		function GetOwner: TPersistent; override;
	public
		function Add: TSQLHistoryListItem;
		constructor Create(AOwner: TComponent);
		property Items[Index: Integer]: TSQLHistoryListItem read GetItem write SetItem; default;
//		property Owner: TMarathonProject read FOwner;
	end;

	TMListColumn = class(TCollectionItem)
	private
		FCaption: string;
		FWidth: TWidth;
		FSortedColumn: Integer;
		FSortOrder: TSortOrder;
		procedure SetCaption(const Value: string);
    procedure SetWidth(Value: TWidth);
    function GetWidth: TWidth;
  public
    constructor Create(Collection: TCollection); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Width: TWidth read GetWidth write SetWidth;
    property SortedColumn: Integer read FSortedColumn write FSortedColumn;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
  end;

	TMListColumns = class(TCollection)
	private
		FOwner: TComponent;
//		FSortedColumn: Integer;
//		FSortOrder: TSortOrder;
    function GetItem(Index: Integer): TMListColumn;
    procedure SetItem(Index: Integer; Value: TMListColumn);
    procedure SetSortedColumn(const Value: Integer);
    procedure SetSortOrder(const Value: TSortOrder);
		function GetSortedColumn: Integer;
    function GetSortOrder: TSortOrder;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TMListColumn;
    function Insert(Index: Integer): TMListColumn;
    property Items[Index: Integer]: TMListColumn read GetItem write SetItem; default;
    property SortedColumn: Integer read GetSortedColumn write SetSortedColumn;
    property SortOrder: TSortOrder read GetSortOrder write SetSortOrder;
	end;

	TMarathonCustomProperty = class(TObject)
	private
    FName: String;
    FValue: Variant;
  public
		property Name: String read FName write FName;
    property Value: Variant read FValue write FValue;
  end;

  TMarathonProject = class(TComponent)
  private
    FShowSystem: Boolean;
		FViewSystemDomains: Boolean;
		FViewSystemTriggers: Boolean;
		FRecording: Boolean;
    FFriendlyName: String;
    FFileName: String;
    FModified: Boolean;
    FSQLHistory: TSQLHistoryList;
    FNumHistory: Integer;
    FEncoding: Integer;
		FWindowList: TWindowList;
		FSaveWindowPositions: Boolean;
		FProjectView: TrmTreeNonView;
    FMetaSearchStrings: TStringList;
    FLastMetaSearchString: String;
    FSearchOptions: TSearchOptions;
    FRelationsColumns: TMListColumns;
    FRelationsFieldColumns: TMListColumns;
    FTEIndexesColumns: TMListColumns;
    FTEDependColumns: TMListColumns;
    FTEFieldsColumns: TMListColumns;
    FTEConstraintsColumns: TMListColumns;
    FVEFieldsColumns: TMListColumns;
    FVEDependColumns: TMListColumns;
		FSPEDependColumns: TMListColumns;
    FTREDependColumns: TMListColumns;
    FExceptPrintOptions: TEXPrintOptions;
		FSPPrintOptions: TSPPrintOptions;
    FTablePrintOptions: TTabPrintOptions;
    FTriggerPrintOptions: TTrigPrintOptions;
    FUDFPrintOptions: TUDFPrintOptions;
		FViewPrintOptions: TViewPrintOptions;
    FCurrentProfile: Integer;
    FMetaIncludeDependents: Boolean;
    FMetaIncludePassword: Boolean;
    FMetaCreateDatabase: Boolean;
    FMetaWrap: Boolean;
    FMetaDecimals: Integer;
    FMetaDecSeparator: String;
    FMetaExtractType: TExtractType;
    FMetaIncludeEnvironment: Boolean;
    FDBManagerListVisible: Boolean;
    FSAWrapFields: Boolean;
    FSAFieldsPerLine: Integer;
    FSATableAlias: TStringList;
    FLastSelectedTableTab: Integer;
		FCache: TMarathonProjectDatabaseCache;
    FOpen: Boolean;
    FResultsPanelHeight: Integer;
    FMetaWrapAt: Integer;
    FTimeStamp: TDateTime;
		FCustomProperties: TList;
    FMetaIncludeDoc: Boolean;
    procedure SetFriendlyName(const Value: String);
    procedure SetShowSystem(const Value: Boolean);
    procedure SetViewSystemDomains(const Value: Boolean);
    procedure SetViewSystemTriggers(const Value: Boolean);
		procedure SetNumHistory(const Value: Integer);
    procedure SetEncoding(const Value: Integer);
    procedure SetModified(const Value: Boolean);
		procedure SetSaveWindowPositions(const Value: Boolean);
    procedure SetLastMetaSearchString(const Value: String);
    procedure SetSearchOptions(const Value: TSearchOptions);
		procedure SetRelationsColumns(const Value: TMListColumns);
    procedure SetRelationsFieldColumns(const Value: TMListColumns);
    procedure ReadInternalTreeData(Stream: TStream);
		procedure WriteInternalTreeData(Stream: TStream);
    procedure SetTEConstraintsColumns(const Value: TMListColumns);
    procedure SetTEDependColumns(const Value: TMListColumns);
    procedure SetTEFieldsColumns(const Value: TMListColumns);
		procedure SetTEIndexesColumns(const Value: TMListColumns);
    procedure SetVEDependColumns(const Value: TMListColumns);
    procedure SetVEFieldsColumns(const Value: TMListColumns);
    procedure SetSPEDependColumns(const Value: TMListColumns);
    procedure SetTREDependColumns(const Value: TMListColumns);
    procedure SetExceptPrintOptions(const Value: TEXPrintOptions);
    procedure SetSPPrintOptions(const Value: TSPPrintOptions);
    procedure SetTablePrintOptions(const Value: TTabPrintOptions);
    procedure SetTriggerPrintOptions(const Value: TTrigPrintOptions);
    procedure SetUDFPrintOptions(const Value: TUDFPrintOptions);
    procedure SetViewPrintOptions(const Value: TViewPrintOptions);
    procedure SetCurrentProfile(const Value: Integer);
    procedure SetMetaCreateDatabase(const Value: Boolean);
    procedure SetMetaDecimals(const Value: Integer);
		procedure SetMetaDecSeparator(const Value: String);
    procedure SetMetaExtractType(const Value: TExtractType);
    procedure SetMetaIncludeDependents(const Value: Boolean);
    procedure SetMetaIncludeEnvironment(const Value: Boolean);
    procedure SetMetaIncludePassword(const Value: Boolean);
		procedure SetMetaWrap(const Value: Boolean);
		procedure SetDBManagerListVisible(const Value: Boolean);
		procedure SetSAFieldsPerLine(const Value: Integer);
		procedure SetSATableAlias(const Value: TStringList);
		procedure SetSAWrapFields(const Value: Boolean);
		procedure SetLastSelectedTableTab(const Value: Integer);
		procedure SetResultsPanelHeight(const Value: Integer);
		procedure SetMetaWrapAt(const Value: Integer);
		procedure SetMetaIncludeDoc(const Value: Boolean);
	public
		property Recording: Boolean read FRecording write FRecording;
		property FileName: String read FFileName write FFileName;
		property Modified: Boolean read FModified write SetModified;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		property Cache: TMarathonProjectDatabaseCache read FCache write FCache;
		procedure WriteCustomProperty(PropertyName: String; PropertyValue: Variant);
		function ReadCustomProperty(PropertyName: String): Variant;
		procedure LoadFromFile(FileName: String);
		procedure SaveToFile(FileName: String);
		procedure NewProject;
		procedure Close;
		property Open: Boolean read FOpen write FOpen;
		property Timestamp: TDateTime read FTimeStamp write FTimeStamp;
		property FriendlyName: String read FFriendlyName write SetFriendlyName;
		property ShowSystem: Boolean read FShowSystem write SetShowSystem;
		property ViewSystemDomains: Boolean read FViewSystemDomains write SetViewSystemDomains;
		property ViewSystemTriggers: Boolean read FViewSystemTriggers write SetViewSystemTriggers;
		property Encoding: Integer read FEncoding write SetEncoding;
		// Settings
		property ResultsPanelHeight: Integer read FResultsPanelHeight write SetResultsPanelHeight;
		// Table editor columns
    property TEFieldsColumns: TMListColumns read FTEFieldsColumns write SetTEFieldsColumns;
    property TEConstraintsColumns: TMListColumns read FTEConstraintsColumns write SetTEConstraintsColumns;
    property TEIndexesColumns: TMListColumns read FTEIndexesColumns write SetTEIndexesColumns;
    property TEDependColumns: TMListColumns read FTEDependColumns write SetTEDependColumns;
    property LastSelectedTableTab: Integer read FLastSelectedTableTab write SetLastSelectedTableTab;
		// View editor columns
		property VEFieldsColumns: TMListColumns read FVEFieldsColumns write SetVEFieldsColumns;
		property VEDependColumns: TMListColumns read FVEDependColumns write SetVEDependColumns;
		// SP editor columns
		property SPEDependColumns: TMListColumns read FSPEDependColumns write SetSPEDependColumns;
		// Trigger editor columns
		property TREDependColumns: TMListColumns read FTREDependColumns write SetTREDependColumns;
		// SQL History
		property SQLHistory: TSQLHistoryList read FSQLHistory write FSQLHistory;
		property NumHistory: Integer read FNumHistory write SetNumHistory;
		// Window list
		property SaveWindowPositions: Boolean read FSaveWindowPositions write SetSaveWindowPositions;
		property WindowList: TWindowList read FWindowList write FWindowList;
		property ProjectView: TrmTreeNonView read FProjectView write FProjectView;
		property MetaSearchStrings: TStringList read FMetaSearchStrings write FMetaSearchStrings;
		property LastMetaSearchString: String read FLastMetaSearchString write SetLastMetaSearchString;
		property SearchOptions: TSearchOptions read FSearchOptions write SetSearchOptions;
		// Printing options
		property ViewPrintOptions: TViewPrintOptions read FViewPrintOptions write SetViewPrintOptions;
		property TablePrintOptions: TTabPrintOptions read FTablePrintOptions write SetTablePrintOptions;
		property UDFPrintOptions: TUDFPrintOptions read FUDFPrintOptions write SetUDFPrintOptions;
		property ExceptPrintOptions: TEXPrintOptions read FExceptPrintOptions write SetExceptPrintOptions;
		property TriggerPrintOptions: TTrigPrintOptions read FTriggerPrintOptions write SetTriggerPrintOptions;
		property SPPrintOptions: TSPPrintOptions read FSPPrintOptions write SetSPPrintOptions;
		// Metadata extract Options
		property MetaExtractType: TExtractType read FMetaExtractType write SetMetaExtractType;
		property MetaCreateDatabase: Boolean read FMetaCreateDatabase write SetMetaCreateDatabase;
		property MetaIncludePassword: Boolean read FMetaIncludePassword write SetMetaIncludePassword;
		property MetaIncludeDependents: Boolean read FMetaIncludeDependents write SetMetaIncludeDependents;
		property MetaIncludeDoc: Boolean read FMetaIncludeDoc write SetMetaIncludeDoc;
		property MetaWrap: Boolean read FMetaWrap write SetMetaWrap;
		property MetaWrapAt: Integer read FMetaWrapAt write SetMetaWrapAt;
		property MetaDecimalPlaces: Integer read FMetaDecimals write SetMetaDecimals;
		property MetaDecimalSeparator: String read FMetaDecSeparator write SetMetaDecSeparator;
		// Drag and Drop from SQL Assistant
		property SATableAlias: TStringList read FSATableAlias write SetSATableAlias;
		property SAWrapFields: Boolean read FSAWrapFields write SetSAWrapFields;
		property SAFieldsPerLine: Integer read FSAFieldsPerLine write SetSAFieldsPerLine;
	end;

function GetImageIndexForCacheType(CT: TGSSCacheType): Integer;

implementation

uses
	Globals,
	MarathonIDE,
	Login,
	Crypt32, DB;

function GetImageIndexForCacheType(CT: TGSSCacheType): Integer;
begin
	case CT of
		ctDontCare:
			Result := 0;

		ctConnection:
			Result := 1;

		ctSQLEditor:
			Result := 0;

		ctRecentHeader:
			Result := 0;

		ctRecentItem:
			Result := 0;

		ctCacheHeader:
			Result := 0;

		ctDomainHeader:
			Result := 0;

		ctDomain:
			Result := 6;

		ctTableHeader:
			Result := 0;

		ctTable:
			Result := 2;

		ctViewHeader:
			Result := 0;

		ctView:
			Result := 5;

		ctSPHeader:
			Result := 0;

		ctSP:
			Result := 3;

		ctSPTemplate:
			Result := 0;

		ctTriggerHeader:
			Result := 0;

		ctTrigger:
			Result := 4;

		ctGeneratorHeader:
			Result := 0;

		ctGenerator:
			Result := 8;

		ctExceptionHeader:
			Result := 0;

		ctException:
			Result := 7;

		ctUDFHeader:
			Result := 0;

		ctUDF:
			Result := 9;
	else
		Result := 0;
  end;
end;

{ TMarathonProjectDatabaseCache }
function ParseSection (ParseLine: String; ParseNum: Integer; ParseSep: Char): String;
var
  iPos: LongInt;
  i: Integer;
  tmp: String;

begin
  tmp := ParseLine;
  for i := 1 To ParseNum do
	begin
    iPos := Pos(ParseSep, tmp);
		if iPos > 0 Then
		begin
			if i = ParseNum Then
			begin
				Result := Copy(tmp, 1, iPos - 1);
				Exit;
			end
			else
				Delete(tmp, 1, iPos);
		end
		else
			if ParseNum > i Then
			begin
				Result := '';
				Exit;
			end
			else
			begin
				Result := tmp;
				Exit;
			end;
	end;
end; { ParseSection }

procedure TMarathonProjectDatabaseCache.AddCacheItem(ConnectionName,
	ObjectName: String; ObjectType: TGSSCacheType);
var
	C: TMarathonCacheConnection;
	N: TrmTreeNonViewNode;
	CN: TrmTreeNonViewNode;
	wNode: TMarathonCacheObject;
	NV: TrmTreeNonViewNode;

begin
	C := GetConnectionByName(ConnectionName);
  if Assigned(C) then
  begin
    nv := nil;
    wNode := nil;
    N := C.ContainerNode;
    CN := N.GetFirstChild;
    while (CN <> nil) and (nv=nil) and (wNode=nil) do
		begin
      if (ObjectType = ctDomain) and (CN.Text='Domains') then
      begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheDomain.Create;
			end
      else if (ObjectType = ctTable) and (CN.Text = 'Tables') then
			begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheTable.Create;
      end
      else if (ObjectType = ctView) and (CN.Text = 'Views') then
      begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheView.Create;
      end
      else if (ObjectType = ctSP) and (CN.Text = 'Stored Procedures') then
			begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheProcedure.Create;
      end
      else if (ObjectType = ctTrigger) and (CN.Text = 'Triggers') then
      begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheTrigger.Create;
      end
      else if (ObjectType = ctGenerator) and (CN.Text = 'Generators') then
			begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheGenerator.Create;
      end
      else if (ObjectType = ctException) and (CN.Text = 'Exceptions') then
      begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheException.Create;
      end
      else if (ObjectType = ctUdf) and (CN.Text = 'User Defined Functions') then
			begin
        NV := FCache.AddPathNode(CN, ObjectName);
        WNode := TMarathonCacheFunction.Create;
      end;

      if assigned(NV) and assigned(wNode) then
      begin
				WNode.ContainerNode := NV;
        WNode.RootItem := Self;
        WNode.Caption := ObjectName;
        WNode.ObjectName := ObjectName;
				WNode.ConnectionName := ConnectionName;
        WNode.System := False;
        NV.Data := WNode;
        TMarathonCacheBaseNode(CN.Data).FireEvent(opRefreshNoFocus);
      end
      else
      CN := N.GetNextChild(CN);
    end;
  end;
end;

procedure TMarathonProjectDatabaseCache.AddRecentObjectOpen(ObjectName: String; ObjectType: TGSSCacheType; COnnectionName: String);
var
  NV: TrmTreeNonViewNode;
  CNV: TrmTreeNonViewNode;
	wNode: TrmTreeNonViewNode;
	wRecent: TMarathonCacheRecentItem;
	Found: Boolean;

begin
	NV := FCache.FindPathNode(FCache.SepChar + 'Recent');
	if Assigned(NV) then
	begin
		// Look for node in branch
		Found := False;
		CNV := NV.GetFirstChild;
		while CNV <> nil do
		begin
			if Assigned(CNV.Data) then
			begin
				wRecent := TMarathonCacheRecentItem(CNV.Data);
				if (wRecent.ConnectionName = ConnectionName) and
					(wRecent.ObjectName = ObjectName) and
					(wRecent.ActualCacheType = ObjectType) then
				begin
					Found := True;
					Break;
				end;
			end;
			CNV := NV.GetNextChild(CNV);
		end;

		if not Found then
		begin
			CNV := NV.GetFirstChild;
			while CNV <> nil do
			begin
				if Assigned(CNV.Data) then
				begin
					wRecent := TMarathonCacheRecentItem(CNV.Data);
					wRecent.UsageCount := wRecent.UsageCount + 1;
				end;
				CNV := NV.GetNextChild(CNV);
			end;

			CNV := NV.GetFirstChild;
			while CNV <> nil do
			begin
				if Assigned(CNV.Data) then
				begin
					wRecent := TMarathonCacheRecentItem(CNV.Data);
					if wRecent.UsageCount > 15 then
						wRecent.DoOperation(opRemoveNode);
				end;
				CNV := NV.GetNextChild(CNV);
			end;
      wNode := FCache.AddPathNode(NV, ObjectName);
			wRecent := TMarathonCacheRecentItem.Create;
			wRecent.ContainerNode := wNode;
			wRecent.RootItem := Self;
			wRecent.Caption := '['+ ObjectName + '] in ' + ConnectionName;
			wRecent.ConnectionName := ConnectionName;
			wRecent.ObjectName := ObjectName;
			wRecent.ActualCacheType := ObjectType;
			wRecent.FExpanded := True;
			wRecent.UsageCount := 1;
			wNode.Data := wRecent;

			if Assigned(NV.Data) then
				TMarathonCacheBaseNode(NV.Data).DoOperation(opRefreshNoFocus);
			FModified := True;
		end;
	end;
end;

function TMarathonProjectDatabaseCache.AddConnectionInternal: TMarathonCacheConnection;
var
	C: TMarathonCacheConnection;
	NV: TrmTreeNonViewNode;

begin
  NV := FCache.FindPathNode(FCache.SepChar + 'Connections');
	NV := FCache.AddPathNode(NV, 'New Connection');
	C := TMarathonCacheConnection.Create;
	C.RootItem := Self;
	ConnectionsChanged := True;
	C.ContainerNode := NV;
	NV.Data := C;
	Result := C;
end;

function TMarathonProjectDatabaseCache.AddServerInternal: TMarathonCacheServer;
var
  C: TMarathonCacheServer;
  NV: TrmTreeNonViewNode;

begin
  NV := FCache.FindPathNode(FCache.SepChar + 'Server Administration');
	NV := FCache.AddPathNode(NV, 'New Server');
	C := TMarathonCacheServer.Create;
	C.RootItem := Self;
	C.ContainerNode := NV;
	NV.Data := C;
	Result := C;
end;

function TMarathonProjectDatabaseCache.GetServer(Index: Integer): TMarathonCacheServer;
var
	TNV: TrmTreeNonViewNode;

begin
	Result := nil;
	TNV := FCache.FindPathNode(FCache.SepChar + 'Server Administration');
	if Assigned(TNV) then
		Result := TMarathonCacheServer(TNV.Item[Index].Data);
end;

function TMarathonProjectDatabaseCache.GetServerByName(Index: String): TMarathonCacheServer;
var
	TNV: TrmTreeNonViewNode;
	CTNV: TrmTreeNonViewNode;

begin
	Result := nil;
  TNV := FCache.FindPathNode(FCache.SepChar + 'Server Administration');
  if Assigned(TNV) then
  begin
    CTNV := TNV.GetFirstChild;
    while CTNV <> nil do
		begin
      if AnsiLowerCase(CTNV.Text) = AnsiLowerCase(Index) then
      begin
        Result := TMarathonCacheServer(CTNV.Data);
        Break;
      end;
			CTNV := TNV.GetNextChild(CTNV);
    end;
  end;
end;

function TMarathonProjectDatabaseCache.GetServerCount: Integer;
var
	TNV: TrmTreeNonViewNode;

begin
	Result := 0;
	TNV := FCache.FindPathNode(FCache.SepChar + 'Server Administration');
	if Assigned(TNV) then
		Result := TNV.Count;
end;

procedure TMarathonProjectDatabaseCache.ClearSearchList;
var
	Idx: Integer;

begin
	for Idx := 0 to FSearchList.Count - 1 do
		TObject(FSearchList[Idx]).Free;
end;

procedure TMarathonProjectDatabaseCache.DatabaseDisconnecting(ConnectionName: String);
begin
  if Assigned(FOnDisconnecting) then
    FOnDisconnecting(Self, ConnectionName);
end;

{ TMarathonCacheRecentItem }
function TMarathonCacheRecentItem.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opOpen:
				Result := True;
		else
			Result := False;
		end;
	end
	else
		Result := False;
end;

constructor TMarathonCacheRecentItem.Create;
begin
	inherited;
	FCacheType := ctRecentItem;
end;

procedure TMarathonProjectDatabaseCache.BuildTree;
var
	NV: TrmTreeNonViewNode;
	wProjects: TMarathonCacheProjectHeader;
	wConnections: TMarathonCacheConnectionsHeader;
	wRecent: TMarathonCacheRecentHeader;
	wServers: TMarathonCacheServersHeader;

begin
	NV := FCache.AddPathNode(nil, FCache.SepChar + 'Projects');
	wProjects := TMarathonCacheProjectHeader.Create;
	wProjects.RootItem := Self;
	wProjects.ContainerNode := NV;
	wProjects.Caption := 'Projects';
	wProjects.FExpanded := True;
	NV.Data := wProjects;

	NV := FCache.AddPathNode(nil, FCache.SepChar + 'Recent');
	wRecent := TMarathonCacheRecentHeader.Create;
	wRecent.RootItem := Self;
	wRecent.ContainerNode := NV;
	wRecent.Caption := 'Recent';
	wRecent.FExpanded := True;
  NV.Data := wRecent;

	NV := FCache.AddPathNode(nil, FCache.SepChar + 'Connections');
  wConnections := TMarathonCacheConnectionsHeader.Create;
  wConnections.RootItem := Self;
  wConnections.ContainerNode := NV;
  wConnections.Caption := 'Connections';
	wConnections.FExpanded := True;
  NV.Data := wConnections;

  NV := FCache.AddPathNode(nil, FCache.SepChar + 'Server Administration');
  wServers := TMarathonCacheServersHeader.Create;
	wServers.RootItem := Self;
  wServers.ContainerNode := NV;
  wServers.Caption := 'Server Administration';
  wServers.FExpanded := True;
  NV.Data := wServers;
end;

procedure TMarathonProjectDatabaseCache.Clear;
begin
  FCache.Items.Clear;
end;

constructor TMarathonProjectDatabaseCache.Create(AOwner: TComponent);
begin
  inherited;
  FCache := TrmTreeNonView.Create(nil);
//  FCache.FireEvents := True;
  FCache.SepChar := cSepChar;
  FCache.OnDeletion := TreeDeletion;
  FMultiSelectItem := TMarathonCacheBaseNode.Create;
  FSearchList := TList.Create;
end;

destructor TMarathonProjectDatabaseCache.Destroy;
begin
  FCache.Items.Clear;
  FCache.Free;
  FMultiSelectItem.Free;
	ClearSearchList;
  FSEarchList.Free;
  inherited;
end;

procedure TMarathonProjectDatabaseCache.FireEvent(Event: TGSSCacheOp; Item: TMarathonCacheBaseNode);
begin
  if Assigned(FOnCacheEvent) then
    FOnCacheEvent(Self, Event, Item);
end;

function TMarathonProjectDatabaseCache.GetConnection(Index: Integer): TMarathonCacheConnection;
var
  TNV: TrmTreeNonViewNode;

begin
  Result := nil;
	TNV := FCache.FindPathNode(cSepChar + 'Connections');
	if Assigned(TNV) then
		Result := TMarathonCacheConnection(TNV.Item[Index].Data);
end;

function TMarathonProjectDatabaseCache.GetConnectionByName(Index: String): TMarathonCacheConnection;
var
	TNV: TrmTreeNonViewNode;
	CTNV: TrmTreeNonViewNode;

begin
	Result := nil;
	TNV := FCache.FindPathNode(cSepChar + 'Connections');
	if Assigned(TNV) then
	begin
		CTNV := TNV.GetFirstChild;
		while CTNV <> nil do
		begin
			if AnsiLowerCase(CTNV.Text) = AnsiLowerCase(Index) then
			begin
				Result := TMarathonCacheConnection(CTNV.Data);
				Break;
			end;
			CTNV := TNV.GetNextChild(CTNV);
		end;
	end;
end;

function TMarathonProjectDatabaseCache.GetConnectionCount: Integer;
var
	TNV: TrmTreeNonViewNode;

begin
	Result := 0;
	TNV := FCache.FindPathNode(cSepChar + 'Connections');
	if Assigned(TNV) then
	begin
		Result := TNV.Count;
	end;
end;

{ TMarathonCacheCache }
function TMarathonCacheProjectHeader.CanDoOperation(Op: TGSSCacheOp;
	Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opNew,
			opOpen,
			opCreateFolder:
				Result := True;
		else
			Result := False;
		end;
	end
	else
	begin
		Result := False;
	end;
end;

constructor TMarathonCacheProjectHeader.Create;
begin
	inherited;
	FStatic := True;
	FImageIndex := 0;
end;

constructor TMarathonCacheRecentHeader.Create;
begin
	inherited;
	FStatic := True;
	FImageIndex := 0;
	FCacheType := ctRecentHeader;
end;

constructor TMarathonCacheConnectionsHeader.Create;
begin
	inherited;
	FStatic := True;
	FImageIndex := 1;
end;

procedure TMarathonProjectDatabaseCache.RemoveCacheItem(Item: TMarathonCacheBaseNode);
begin
  Item.FireEvent(opRemoveNode);
  Item.ContainerNode.Delete;
end;

procedure TMarathonProjectDatabaseCache.RemoveCacheItemByName(Connection, ObjectName: String; ObjectType: TGSSCacheType);
var
  C: TMarathonCacheConnection;
  N: TrmTreeNonViewNode;
  CN: TrmTreeNonViewNode;

  function CovertObjTypeToName(OT: TGSSCacheType): String;
  begin
    case OT of
			ctDomain:
				Result := 'Domains';

			ctTable:
				Result := 'Tables';

			ctView:
				Result := 'Views';

			ctSP:
				Result := 'Stored Procedures';

			ctTrigger:
				Result := 'Triggers';

			ctGenerator:
				Result := 'Generators';

			ctException:
				Result := 'Exceptions';

			ctUDF:
				Result := 'User Defined Functions';
		end;
	end;

begin
	C := GetConnectionByName(Connection);
	if Assigned(C) then
	begin
		N := C.ContainerNode;
		CN := N.GetFirstChild;
		while CN <> nil do
		begin
			if CN.Text = CovertObjTypeToName(ObjectType) then
			begin
				N := CN;
				CN := N.GetFirstChild;
				while CN <> nil do
				begin
					if CN.Text = ObjectName then
					begin
						RemoveCacheItem(TMarathonCacheBaseNode(CN.Data));
						Break;
					end;
					CN := N.GetNextChild(CN);
				end;
				Break;
			end;
			CN := N.GetNextChild(CN);
		end;
	end;
end;

procedure TMarathonProjectDatabaseCache.SetModified(const Value: Boolean);
begin
	FModified := Value;
	if Value then
		FProjectItem.Modified := Value;
end;

procedure TMarathonProjectDatabaseCache.StartTree(TV: TrmPathTreeView);
var
	NV: TrmTreeNonViewNode;
	N: TrmTreeNode;

begin
	TV.Items.Clear;
	NV := FCache.FindPathNode(cSepChar + 'Projects');
	if Assigned(NV) then
	begin
		N := TV.AddPathNode(nil, FCache.NodePath(NV));
		N.Data := NV;
		N.HasChildren := True;
	end;
	NV := FCache.FindPathNode(cSepChar + 'Recent');
	if Assigned(NV) then
	begin
		N := TV.AddPathNode(nil, FCache.NodePath(NV));
		N.Data := NV;
		N.HasChildren := True;
	end;
	NV := FCache.FindPathNode(cSepChar + 'Connections');
	if Assigned(NV) then
	begin
		N := TV.AddPathNode(nil, FCache.NodePath(NV));
		N.Data := NV;
		N.HasChildren := True;
		N.Expand(False);
	end;
	NV := FCache.FindPathNode(cSepChar + 'Server Administration');
	if Assigned(NV) then
	begin
		N := TV.AddPathNode(nil, FCache.NodePath(NV));
		N.Data := NV;
		N.HasChildren := True;
		N.Expand(False);
	end;
end;

procedure TMarathonProjectDatabaseCache.TreeDeletion(Sender: TObject;
	Node: TrmTreeNonViewNode);
begin
	if Assigned(Node.Data) then
  begin
		TObject(Node.Data).Free;
    Node.Data := nil; //AC:
  end;
end;

function TMarathonCacheRecentItem.GetImageIndex: Integer;
begin
	Result := GetImageIndexForCacheType(FActualCacheType);
end;

{ TMarathonCacheBaseNode }
procedure TMarathonCacheBaseNode.AddToList(Obj: TObject);
begin
	FItems.Add(Obj);
end;

function TMarathonCacheBaseNode.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
		Result := False
	else
		Result := False;
end;

procedure TMarathonCacheBaseNode.ClearList;
begin
	FItems.Clear;
end;

constructor TMarathonCacheBaseNode.Create;
begin
  inherited Create;
  FItems := TList.Create;
  FImageIndex := 1;
  FCacheType := ctDontCare;
end;

destructor TMarathonCacheBaseNode.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TMarathonCacheBaseNode.DoOperation(Op: TGSSCacheOp);
begin
  FRootItem.FireEvent(Op, Self);
end;

procedure TMarathonCacheBaseNode.Expand(Recursive: Boolean);
begin
	// Do nothing
end;

procedure TMarathonCacheBaseNode.FireEvent(Event: TGSSCacheOp);
begin
	FRootItem.FireEvent(Event, Self);
end;

function TMarathonCacheBaseNode.GetContentStr: String;
begin
	Result := '';
end;

function TMarathonCacheBaseNode.GetImageIndex: Integer;
begin
  Result := FImageIndex;
end;

function TMarathonCacheBaseNode.GetOverlayIndex: integer;
begin
  Result := -1;
end;

function TMarathonCacheBaseNode.GetParentObject: TMarathonCacheBaseNode;
begin
  Result := nil;
	if Assigned(FContainerNode) then
		if Assigned(FContainerNode.Parent) then
			Result := TMarathonCacheBaseNode(FContainerNode.Parent.Data);
end;

procedure TMarathonCacheBaseNode.ResetCaption(Value: String);
begin
	FCaption := Value;
	if Assigned(FContainerNode) then
	begin
		FContainerNode.Text := Value;
		if Assigned(FContainerNode.Parent) then
			TMarathonCacheBaseNode(FContainerNode.Parent.Data).FireEvent(opRefresh);
	end;
end;

procedure TMarathonCacheBaseNode.SetCaption(const Value: String);
begin
	FCaption := Value;
	if Assigned(FContainerNode) then
		FContainerNode.Text := Value;
end;

{ TMarathonCacheConnection }
function TMarathonCacheConnection.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opPrint,
			opPrintPreview:
				Result := Connected;

			opConnect:
				Result := not Connected;

			opDisConnect:
				Result := Connected;

			opDelete:
				Result := True;

			opProperties:
				Result := True;
		else
			Result := False;
		end;
	end
	else
		Result := False;
end;

function TMarathonCacheConnection.Connect: Boolean;
var
	Server: TMarathonCacheServer;

begin
	if FConnection.Connected then
	begin
		Result := True;
		Exit;
	end;

	Result := False;

	if FErrorOnConnection then
		Exit;

	FConnection.Path := FDBFileName;

	Server := MarathonIDEInstance.CurrentProject.Cache.ServerByName[FServerName];
	if Server.Local then
		FConnection.Protocol := cpLocal
	else
	begin
		FConnection.Server := Server.HostName;
		case Server.Protocol of
			0:
				FConnection.Protocol := cpTCP_IP;

			1:
				FConnection.Protocol := cpNetBEUI;

			2:
				FConnection.Protocol := cpNovell;
		end;
	end;
	FConnection.Username := FUserName;
	FConnection.Password := FPassword;
	FConnection.SQLRole := FSQLRole;
	if FSQLDialect = 0 then
		FSQLDialect := 1;
	try
		FConnection.Connect;
		if IsIB6 then
		begin
			FConnection.Disconnect;
			FConnection.SQLDialect := FSQLDialect;
			FConnection.Connect;
			if (FConnection.SQLDialect <> FSQLDialect) then
				FSQLDialect := FConnection.SQLDialect;
		end;
		Result := True;
		Exit;
	except
		// Do nothing, flow thru to the dialog
		FErrorOnConnection := True;
	end;

	with TfrmConnect.Create(nil) do
		try
			lblPrompt.Caption := Caption;

			if FUserName <> '' then
				edUserName.Text := FUserName;
			if FPassword <> '' then
				edPassword.Text := FPassword;
			if FSQLRole <> '' then
				edRole.Text := FSQLRole;

			if FSQLDialect = 0 then
				FSQLDialect := 1;
			cmbDialect.ItemIndex := FSQLDialect - 1;

			if ShowModal = mrOK then
			begin
				UserName := edUserName.Text;
				Password := edPassword.Text;
				if chkRememberPassword.Checked then
					RememberPassword := True
				else
					RememberPassword := False;

				fSQLDialect := cmbDialect.ItemIndex + 1;
				fSQLRole := edRole.Text;

				FConnection.Username := FUserName;
				FConnection.Password := FPassword;
				FConnection.SQLRole := FSQLRole;
				FConnection.SQLDialect := FSQLDialect;
				try
					FConnection.Connect;
					if IsIB6 then
					begin
						FConnection.Disconnect;
						FConnection.SQLDialect := FSQLDialect;
						FCOnnection.Connect;
					end;
					Result := True;
					FErrorOnConnection := False;
				except
					on E: Exception do
					begin
						Result := False;
						MessageDlg(E.Message, mtError, [mbOK], 0);
					end;
				end;
			end;
		finally
			Free;
		end;
end;

constructor TMarathonCacheConnection.Create;
begin
	inherited;
	FImageIndex := 0;
	FStatic := True;
	FConnection := TIB_Connection.Create(nil);
	FTransaction := TIB_Transaction.Create(nil);
	FTransaction.IB_Connection := FConnection;
	FCacheType := ctConnection;
	FTableList := TStringList.Create;
  FViewList := TStringList.Create;
  FDomainList := TStringList.Create;
  FRecorder := TfrmScriptRecorder.Create(nil);
end;

destructor TMarathonCacheConnection.Destroy;
begin
  FRootItem.ConnectionsChanged := True;
  FConnection.Free;
  FTransaction.Free;
  FTableList.Free;
  FViewList.Free;
  FDomainList.Free;
  FRecorder.Free;
  inherited;
end;

procedure TMarathonCacheConnection.Disconnect;
begin
	if MessageDlg('This will disconnect this connection. Any open editors connected'
		+ #13 +  'to this connection will close. Are you sure you wish to do this?',
		mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		FConnection.Disconnect;
		FContainerNode.DeleteChildren;
		FExpanded := False;
		FRootItem.DatabaseDisconnecting(Caption);
	end;
end;

procedure TMarathonCacheConnection.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheHeader;
	NV: TrmTreeNonViewNode;

begin
	if not Connected then
	begin
		if not Connect then
		begin
			FExpanded := False;
			Exit;
		end;
	end;

	if FStatic and ((FContainerNode.Count = 8) or (FContainerNode.Count = 9) or (FContainerNode.Count = 10)) then
	begin
		FExpanded := True;
		Exit;
	end;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Domains');
	wNode := TMarathonCacheUserDomainsHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	if FRootItem.FProjectItem.FViewSystemDomains then
	begin
		NV := FRootItem.FCache.AddPathNode(fContainerNode, 'System Domains');
		wNode := TMarathonCacheDomainsHeader.Create;
		wNode.ContainerNode := NV;
		wNode.RootItem := FRootItem;
		wNode.Caption := NV.Text;
		wNode.ConnectionName := FCaption;
		NV.Data := wNode;
	end;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Tables');
	wNode := TMarathonCacheTablesHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	if FRootItem.FProjectItem.ShowSystem then
	begin
		NV := FRootItem.FCache.AddPathNode(fContainerNode, 'System Tables');
		wNode := TMarathonCacheSysTablesHeader.Create;
		wNode.ContainerNode := NV;
		wNode.RootItem := FRootItem;
		wNode.Caption := NV.Text;
		wNode.ConnectionName := FCaption;
		NV.Data := wNode;
	end;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Views');
	wNode := TMarathonCacheViewsHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Stored Procedures');
	wNode := TMarathonCacheStoredProceduresHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Triggers');
	wNode := TMarathonCacheTriggersHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	if FRootItem.FProjectItem.FViewSystemTriggers then
	begin
		NV := FRootItem.FCache.AddPathNode(fContainerNode, 'System Triggers');
		wNode := TMarathonCacheSystemTriggersHeader.Create;
		wNode.ContainerNode := NV;
		wNode.RootItem := FRootItem;
		wNode.Caption := NV.Text;
		wNode.ConnectionName := FCaption;
		NV.Data := wNode;
	end;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Generators');
	wNode := TMarathonCacheGeneratorsHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Exceptions');
	wNode := TMarathonCacheExceptionsHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'User Defined Functions');
	wNode := TMarathonCacheUDFSHeader.Create;
  wNode.ContainerNode := NV;
  wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	wNode.ConnectionName := FCaption;
  NV.Data := wNode;

  FExpanded := True;
end;

function TMarathonCacheConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TMarathonCacheConnection.GetCharSetNames(S: TStrings);
var
  Q: TIBOQuery;
  TmpTrans: TIB_Transaction;

begin
  S.Clear;
  S.Add('');
  Q := TIBOQuery.Create(nil);
  TmpTrans := TIB_Transaction.Create(nil);
  try
    TmpTrans.IB_Connection := FConnection;
    TmpTrans.Isolation := tiConCurrency;

    Q.IB_Connection := FConnection;
    Q.IB_Transaction := TmpTrans;

		Q.SQL.Add('select distinct RDB$CHARACTER_SET_NAME from RDB$CHARACTER_SETS order by RDB$CHARACTER_SET_NAME asc');
		Q.Open;
		while not Q.EOF do
		begin
			S.Add(Q.FieldByName('RDB$CHARACTER_SET_NAME').AsString);
			Q.Next;
    end;
		Q.Close;

    TmpTrans.Commit;
  finally
		TmpTrans.Free;
    Q.Free;
  end;
end;

function TMarathonCacheConnection.GetDBCharSetName(CharSetID: Integer): String;
var
  Q: TIBOQuery;
  TmpTrans: TIB_Transaction;
  CharSet: String;

begin
  Q := TIBOQuery.Create(nil);
  TmpTrans := TIB_Transaction.Create(nil);
  try
    TmpTrans.IB_Connection := FConnection;
    TmpTrans.Isolation := tiConCurrency;

    Q.IB_Connection := FConnection;
    Q.IB_Transaction := TmpTrans;

		Q.SQL.Add('select RDB$CHARACTER_SET_NAME from RDB$CHARACTER_SETS where RDB$CHARACTER_SET_ID = ' + IntToStr(CharSetID));
		Q.Open;
		if not (Q.EOF and Q.BOF) then
			CharSet := Q.FieldByName('RDB$CHARACTER_SET_NAME').AsString
		else
			CharSet := '';
		Q.Close;

		if (CharSet <> '') and (AnsiUpperCase(CharSet) <> 'NONE') then
			Result := CharSet
		else
      Result := '';

    TmpTrans.Commit;
  finally
    TmpTrans.Free;
		Q.Free;
  end;
end;

procedure TMarathonCacheConnection.GetCollationNames(S: TStrings);
var
  Q: TIBOQuery;
  TmpTrans: TIB_Transaction;

begin
  S.Clear;
  S.Add('');
  Q := TIBOQuery.Create(nil);
  TmpTrans := TIB_Transaction.Create(nil);
  try
    TmpTrans.IB_Connection := FConnection;
    TmpTrans.Isolation := tiConCurrency;

    Q.IB_Connection := FConnection;
    Q.IB_Transaction := TmpTrans;

		Q.SQL.Add('select distinct RDB$COLLATION_NAME from RDB$COLLATIONS order by RDB$COLLATION_NAME asc');
		Q.Open;
		while not Q.EOF do
		begin
			S.Add(Q.FieldByName('RDB$COLLATION_NAME').AsString);
      Q.Next;
    end;
		Q.Close;

		TmpTrans.Commit;
	finally
		TmpTrans.Free;
		Q.Free;
	end;
end;

function TMarathonCacheConnection.GetDBCollationName(CollationID: Integer; CharSetID: Integer): String;
var
	Q: TIBOQuery;
	TmpTrans: TIB_Transaction;
  CharSet: String;

begin
  Q := TIBOQuery.Create(nil);
  TmpTrans := TIB_Transaction.Create(nil);
  try
    TmpTrans.IB_Connection := FConnection;
    TmpTrans.Isolation := tiConCurrency;

    Q.IB_Connection := FConnection;
    Q.IB_Transaction := TmpTrans;

		Q.SQL.Add('select RDB$COLLATION_NAME from RDB$COLLATIONS where RDB$CHARACTER_SET_ID = ' + IntToStr(CharSetID) + ' and RDB$COLLATION_ID = ' + IntToStr(CollationID));
		Q.Open;
		if not (Q.EOF and Q.BOF) then
			CharSet := Q.FieldByName('RDB$COLLATION_NAME').AsString
		else
			CharSet := '';
		Q.Close;

		if (CharSet <> '') and (AnsiUpperCase(CharSet) <> 'NONE') then
			Result := CharSet
		else
			Result := '';

		TmpTrans.Commit;
	finally
		TmpTrans.Free;
		Q.Free;
	end;
end;

function TMarathonCacheConnection.GetEncPassword: String;
begin
	Result := Encrypt(FPassword, E_START_KEY, E_MULT_KEY, E_ADD_KEY);
end;

function TMarathonCacheConnection.GetSQLDialect: Integer;
begin
	if FConnection.Connected then
	begin
		Result := FConnection.SQLDialect;
		FSQLDialect := FConnection.SQLDialect;
	end
	else
		Result := FSQLDialect;
end;

function TMarathonCacheConnection.GetTableList: TStringList;
var
	Q: TIBOQuery;

begin
	FTableList.Clear;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
    Q.IB_Connection := Connection;
    Q.IB_Transaction := Transaction;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;
    Q.IB_Transaction.StartTransaction;
    try
			Q.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where RDB$VIEW_SOURCE is null order by RDB$RELATION_NAME asc');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$RELATION_NAME').AsString, 1, 4)) = 'RDB$' then
				begin
					Q.Next;
					Continue;
				end;
				FTableList.Add(Q.FieldByName('RDB$RELATION_NAME').AsString);
				Q.Next;
			end;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
  end;
  Result := FTableList;
end;

function TMarathonCacheConnection.GetViewList: TStringList;
var
  Q: TIBOQuery;

begin
  FViewList.Clear;
  Q := TIBOQuery.Create(nil);
  try
		Q.BeginBusy(False);
		Q.IB_Connection := Connection;
		Q.IB_Transaction := Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try
			Q.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where RDB$VIEW_SOURCE is not null order by RDB$RELATION_NAME asc');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$RELATION_NAME').AsString, 1, 4)) = 'RDB$' then
				begin
					Q.Next;
					Continue;
				end;
				FViewList.Add(Q.FieldByName('RDB$RELATION_NAME').AsString);
				Q.Next;
			end;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
	Result := FViewList;
end;

function TMarathonCacheConnection.GetDomainList: TStringList;
var
	Q: TIBOQuery;

begin
	FDomainList.Clear;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := Connection;
		Q.IB_Transaction := Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try
			Q.SQL.Add('select RDB$FIELD_NAME from RDB$FIELDS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$FIELD_NAME asc');
			Q.Open;
			while not Q.EOF do
			begin
				FDomainList.Add(Q.FieldByName('rdb$field_name').AsString);
				Q.Next;
			end;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
	Result := FDomainList;
end;

function TMarathonCacheConnection.IsIB5: Boolean;
var
	Idx, MajorVersionNum: Integer;
	VersionString, Temp: String;

begin
	VersionString := FConnection.Characteristics.dbVersion;
	Idx := Pos('V', VersionString);
	if Idx > 0 then
		VersionString := Copy(VersionString, Idx + 1, 100)
	else
	begin
		Temp := '';
		for Idx := 1 to Length(VersionString) do
		begin
			if VersionString[Idx] in ['0'..'9', '.'] then
				Temp := Temp + VersionString[Idx];
		end;
		VersionString := Temp;
	end;
	MajorVersionNum := StrToInt(ParseSection(VersionString, 1, '.'));
	if MajorVersionNum >= 5 then
		Result := True
	else
		Result := False;
end;

function TMarathonCacheConnection.IsIB6: Boolean;
var
	Idx, MajorVersionNum: Integer;
	VersionString, Temp: String;

begin
	VersionString := FConnection.Characteristics.dbVersion;
	Idx := Pos('V', VersionString);
	if Idx > 0 then
		VersionString := Copy(VersionString, Idx + 1, 100)
	else
	begin
		Temp := '';
		for Idx := 1 to Length(VersionString) do
		begin
			if VersionString[Idx] in ['0'..'9', '.'] then
				Temp := Temp + VersionString[Idx];
		end;
		VersionString := Temp;
	end;
	MajorVersionNum := StrToInt(ParseSection(VersionString, 1, '.'));
	if (MajorVersionNum >= 6) or (MajorVersionNum = 1) then
		Result := True
	else
		Result := False;
end;

procedure TMarathonCacheConnection.ResetCaption(Value: String);
begin
	inherited;
	FRootItem.ConnectionsChanged := True;
end;

procedure TMarathonCacheConnection.SetCaption(const Value: String);
begin
	inherited;
	FRootItem.ConnectionsChanged := True;
end;

procedure TMarathonCacheConnection.SetDBFileName(const Value: String);
begin
	FDBFileName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetServerName(const Value: String);
begin
	FServerName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetLangDriver(const Value: String);
begin
	FLangDriver := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetPassword(const Value: String);
begin
	FPassword := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetRememberPassword(const Value: Boolean);
begin
	FRememberPassword := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetSQLDialect(const Value: Integer);
begin
	FSQLDialect := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetSQLRole(const Value: String);
begin
	FSQLRole := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetUserName(const Value: String);
begin
	FUserName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheConnection.SetErrorOnConnection(
  const Value: Boolean);
begin
  FErrorOnConnection := Value;
end;

{ TMarathonCacheConnectionsHeader }

function TMarathonCacheConnection.GetOverlayIndex: integer;
begin
   if connected then
      result := 0
   else
      result := -1;
end;

{ TMarathonProject }
constructor TMarathonProject.Create(AOwner: TComponent);
var
	N: TrmTreeNonViewNode;

begin
	inherited Create(AOwner);
	FCustomProperties := TList.Create;
	FCache := TMarathonProjectDatabaseCache.Create(Self);
	FCache.FProjectItem := Self;
	FSQLHistory := TSQLHistoryList.Create(Self);
	FWindowList := TWindowList.Create(Self);
	FProjectView := TrmTreeNonView.Create(Self);
	FProjectView.SepChar := cSepChar;
	FMetaSearchStrings := TStringList.Create;
	// Database Manager Columns
  FRelationsColumns := TMListColumns.Create(Self);
  FRelationsColumns.SortedColumn := 0;
  FRelationsColumns.SortOrder := srtAsc;
  with FRelationsColumns.Add do
  begin
    Width := 260;
    Caption := 'Relations';
  end;
  FRelationsFieldColumns := TMListColumns.Create(Self);
  FRelationsFieldColumns.SortedColumn := 0;
  FRelationsFieldColumns.SortOrder := srtAsc;
  with FRelationsFieldColumns.Add do
  begin
    Width := 150;
    Caption := 'Column';
	end;
  with FRelationsFieldColumns.Add do
  begin
    Width := 60;
    Caption := 'Pos';
  end;
  with FRelationsFieldColumns.Add do
  begin
    Width := 80;
		Caption := 'Type';
  end;
  with FRelationsFieldColumns.Add do
	begin
    Width := 90;
    Caption := 'Domain';
  end;

	// Table Editor Columns
  FTEFieldsColumns := TMListColumns.Create(Self);
  with FTEFieldsColumns.Add do
  begin
    Width := 200;
    Caption := 'Field Name';
  end;
  with FTEFieldsColumns.Add do
  begin
    Width := 90;
    Caption := 'Field Type';
  end;
  with FTEFieldsColumns.Add do
  begin
    Width := 60;
    Caption := 'Sub Type';
  end;
  with FTEFieldsColumns.Add do
  begin
    Width := 100;
    Caption := 'Domain';
  end;
	with FTEFieldsColumns.Add do
  begin
    Width := 100;
    Caption := 'Not Null';
  end;
  with FTEFieldsColumns.Add do
  begin
    Width := 200;
    Caption := 'Description';
  end;
  with FTEFieldsColumns.Add do
  begin
		Width := 300;
    Caption := 'Default Source';
  end;
  with FTEFieldsColumns.Add do
	begin
    Width := 300;
    Caption := 'Computed Source';
  end;
  FTEConstraintsColumns := TMListColumns.Create(Self);
  with FTEConstraintsColumns.Add do
  begin
    Width := 200;
    Caption := 'Constraint Name';
  end;
  with FTEConstraintsColumns.Add do
  begin
    Width := 200;
    Caption := 'Type';
  end;
  with FTEConstraintsColumns.Add do
  begin
    Width := 200;
    Caption := 'On Field';
  end;
  with FTEConstraintsColumns.Add do
  begin
    Width := 200;
		Caption := 'FK Table';
  end;
  with FTEConstraintsColumns.Add do
  begin
    Width := 200;
    Caption := 'FK Field';
  end;
  with FTEConstraintsColumns.Add do
  begin
    Width := 100;
    Caption := 'Update Rule';
  end;
	with FTEConstraintsColumns.Add do
  begin
    Width := 100;
    Caption := 'Delete Rule';
	end;
  FTEIndexesColumns := TMListColumns.Create(Self);
  with FTEIndexesColumns.Add do
  begin
    Width := 200;
    Caption := 'Index Name';
  end;
  with FTEIndexesColumns.Add do
  begin
    Width := 200;
    Caption := 'On Field(s)';
  end;
  with FTEIndexesColumns.Add do
  begin
    Width := 50;
    Caption := 'Unique';
	end;
	with FTEIndexesColumns.Add do
	begin
		Width := 50;
		Caption := 'Active';
	end;
	with FTEIndexesColumns.Add do
	begin
		Width := 80;
		Caption := 'Direction';
	end;
	FTEDependColumns := TMListColumns.Create(Self);
	with FTEDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Dependent';
	end;
	with FTEDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Field';
	end;

	// View Editor Columns
	FVEFieldsColumns := TMListColumns.Create(Self);
  with FVEFieldsColumns.Add do
  begin
    Width := 200;
    Caption := 'Field Name';
  end;
  with FVEFieldsColumns.Add do
  begin
    Width := 90;
    Caption := 'Field Type';
  end;
  with FVEFieldsColumns.Add do
  begin
    Width := 60;
		Caption := 'Sub Type';
	end;
  with FVEFieldsColumns.Add do
  begin
    Width := 100;
    Caption := 'Domain';
  end;
  with FVEFieldsColumns.Add do
	begin
    Width := 100;
    Caption := 'Not Null';
  end;
  with FVEFieldsColumns.Add do
  begin
    Width := 200;
    Caption := 'Description';
  end;
  with FVEFieldsColumns.Add do
  begin
    Width := 300;
		Caption := 'Default Source';
  end;
  with FVEFieldsColumns.Add do
  begin
    Width := 300;
    Caption := 'Computed Source';
  end;
  FVEDependColumns := TMListColumns.Create(Self);
  with FVEDependColumns.Add do
  begin
    Width := 300;
    Caption := 'Dependent';
	end;
	with FVEDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Field';
	end;

	// SP editor columns
	FSPEDependColumns := TMListColumns.Create(Self);
	with FSPEDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Dependent';
	end;
	with FSPEDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Field';
	end;

	// Trigger editor columns
	FTREDependColumns := TMListColumns.Create(Self);
	with FTREDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Dependent';
	end;
	with FTREDependColumns.Add do
	begin
		Width := 300;
		Caption := 'Field';
	end;

	FNumHistory := 20;
	FEncoding := 1;
	FSearchOptions := [soSP, soTrig];
	FSaveWindowPositions := True;

	// Printing options
	FExceptPrintOptions := [prEXCode, prEXDoco];
	FSPPrintOptions := [prSPCode, prSPDoco];
	FTablePrintOptions := [prTabStruct, prTabConstraints, prTabIndexes, prTabDepend, prTabTriggers, prTabDoco];
	FTriggerPrintOptions := [prTrigCode, prTrigDoco];
	FUDFPrintOptions := [prUDFCode, prUDFDoco];
	FViewPrintOptions := [prViewStruct, prViewDepend, prViewTriggers, prViewDoco];

	//Extract Settings
	FMetaExtractType := exMetaOnly;
	FMetaCreateDatabase := False;
	FMetaIncludePassword := False;
	FMetaIncludeEnvironment := False;
  FMetaIncludeDependents := False;
  FMetaWrap := False;
  FMetaDecimals := 2;
	FMetaDecSeparator := '.';

  FDBManagerListVisible := True;

  FSAWrapFields := True;
  FSAFieldsPerLine := 1;
  FSATableAlias := TStringList.Create;
end;

destructor TMarathonProject.Destroy;
var
	Idx: Integer;

begin
	FSQLHistory.Free;
	FWindowList.Free;
	FProjectView.Free;
	FMetaSearchStrings.Free;
	FRelationsColumns.Free;
	FRelationsFieldColumns.Free;
	FTEIndexesColumns.Free;
	FTEDependColumns.Free;
	FTEFieldsColumns.Free;
	FTEConstraintsColumns.Free;
	FVEFieldsColumns.Free;
  FVEDependColumns.Free;
  FSPEDependColumns.Free;
  FTREDependColumns.Free;
  FSATableAlias.Free;
  FCache.Free;
  for Idx := 0 to FCustomProperties.Count - 1 do
    TObject(FCustomProperties[Idx]).Free;
  FCustomProperties.Free;
  inherited Destroy;
end;

procedure TMarathonProject.ReadInternalTreeData(Stream: TStream);
begin
	Stream.ReadComponent(FProjectView);
end;

procedure TMarathonProject.WriteInternalTreeData(Stream: TStream);
begin
	Stream.WriteComponent(FProjectView);
end;

procedure TMarathonProject.SetEncoding(const Value: Integer);
begin
	FEncoding := Value;
	Modified := True;
end;

procedure TMarathonProject.SetFriendlyName(const Value: String);
begin
	FFriendlyName := Value;
	Modified := True;
end;

procedure TMarathonProject.SetLastMetaSearchString(const Value: String);
begin
	FLastMetaSearchString := Value;
	Modified := True;
end;

procedure TMarathonProject.SetModified(const Value: Boolean);
begin
	FModified := Value;
end;

procedure TMarathonProject.SetNumHistory(const Value: Integer);
begin
	FNumHistory := Value;
	Modified := True;
end;

procedure TMarathonProject.SetRelationsColumns(const Value: TMListColumns);
begin
	FRelationsColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetRelationsFieldColumns(const Value: TMListColumns);
begin
	FRelationsFieldColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSaveWindowPositions(const Value: Boolean);
begin
	FSaveWindowPositions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSearchOptions(const Value: TSearchOptions);
begin
	FSearchOptions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetShowSystem(const Value: Boolean);
begin
  FShowSystem := Value;
  Modified := True;
end;

procedure TMarathonProject.SetViewSystemDomains(const Value: Boolean);
begin
	FViewSystemDomains := Value;
	Modified := True;
end;

procedure TMarathonProject.SetViewSystemTriggers(const Value: Boolean);
begin
	FViewSystemTriggers := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTEConstraintsColumns(const Value: TMListColumns);
begin
	FTEConstraintsColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTEDependColumns(const Value: TMListColumns);
begin
	FTEDependColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTEFieldsColumns(const Value: TMListColumns);
begin
	FTEFieldsColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTEIndexesColumns(const Value: TMListColumns);
begin
	FTEIndexesColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetVEDependColumns(const Value: TMListColumns);
begin
  FVEDependColumns := Value;
  Modified := True;
end;

procedure TMarathonProject.SetVEFieldsColumns(const Value: TMListColumns);
begin
	FVEFieldsColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSPEDependColumns(const Value: TMListColumns);
begin
	FSPEDependColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTREDependColumns(const Value: TMListColumns);
begin
	FTREDependColumns := Value;
	Modified := True;
end;

procedure TMarathonProject.SetExceptPrintOptions(const Value: TEXPrintOptions);
begin
	FExceptPrintOptions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSPPrintOptions(const Value: TSPPrintOptions);
begin
	FSPPrintOptions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetTablePrintOptions(const Value: TTabPrintOptions);
begin
  FTablePrintOptions := Value;
  Modified := True;
end;

procedure TMarathonProject.SetTriggerPrintOptions(const Value: TTrigPrintOptions);
begin
	FTriggerPrintOptions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetUDFPrintOptions(const Value: TUDFPrintOptions);
begin
	FUDFPrintOptions := Value;
	Modified := True;
end;

procedure TMarathonProject.SetViewPrintOptions(const Value: TViewPrintOptions);
begin
  FViewPrintOptions := Value;
  Modified := True;
end;

procedure TMarathonProject.SetCurrentProfile(const Value: Integer);
begin
  FCurrentProfile := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaCreateDatabase(const Value: Boolean);
begin
  FMetaCreateDatabase := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaDecimals(const Value: Integer);
begin
  FMetaDecimals := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaDecSeparator(const Value: String);
begin
  FMetaDecSeparator := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaExtractType(const Value: TExtractType);
begin
  FMetaExtractType := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaIncludeDependents(const Value: Boolean);
begin
  FMetaIncludeDependents := Value;
	Modified := True;
end;

procedure TMarathonProject.SetMetaIncludeEnvironment(const Value: Boolean);
begin
  FMetaIncludeEnvironment := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaIncludePassword(const Value: Boolean);
begin
  FMetaIncludePassword := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaWrap(const Value: Boolean);
begin
  FMetaWrap := Value;
	Modified := True;
end;

procedure TMarathonProject.SetDBManagerListVisible(const Value: Boolean);
begin
  FDBManagerListVisible := Value;
  Modified := True;
end;

{procedure TMarathonProject.Loaded;
var
	Item: TMarathonCacheConnection;

begin
	inherited Loaded;
	if FTEIndexesColumns.Count < 5 then
	begin
		FTEIndexesColumns.Clear;
		with FTEIndexesColumns.Add do
		begin
			Width := 200;
			Caption := 'Index Name';
		end;
		with FTEIndexesColumns.Add do
		begin
			Width := 200;
			Caption := 'On Field(s)';
		end;
		with FTEIndexesColumns.Add do
		begin
			Width := 50;
			Caption := 'Unique';
		end;
		with FTEIndexesColumns.Add do
		begin
			Width := 50;
			Caption := 'Active';
		end;
		with FTEIndexesColumns.Add do
		begin
			Width := 80;
			Caption := 'Direction';
		end;
	end;

	if FRelationsFieldColumns.Count < 4 then
	begin
		FRelationsFieldColumns.Clear;
		with FRelationsFieldColumns.Add do
		begin
			Width := 150;
			Caption := 'Column';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 60;
			Caption := 'Pos';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 80;
			Caption := 'Type';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 90;
			Caption := 'Domain';
		end;
	end;

	if (FRelationsFieldColumns.Count = 4) and (FRelationsFieldColumns.Items[0].Caption = 'Pos') then
	begin
		FRelationsFieldColumns.Clear;
		with FRelationsFieldColumns.Add do
		begin
			Width := 150;
			Caption := 'Column';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 60;
			Caption := 'Pos';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 80;
			Caption := 'Type';
		end;
		with FRelationsFieldColumns.Add do
		begin
			Width := 90;
			Caption := 'Domain';
		end;
	end;
	FModified := False;
end;}

procedure TMarathonProject.SetSAFieldsPerLine(const Value: Integer);
begin
	FSAFieldsPerLine := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSATableAlias(const Value: TStringList);
begin
	FSATableAlias := Value;
	Modified := True;
end;

procedure TMarathonProject.SetSAWrapFields(const Value: Boolean);
begin
	FSAWrapFields := Value;
	Modified := True;
end;

procedure TMarathonProject.SetLastSelectedTableTab(const Value: Integer);
begin
	FLastSelectedTableTab := Value;
	Modified := True;
end;

procedure TMarathonProject.LoadFromFile(FileName: String);
var
  doc: TXMLDocument;
  oNode: TDomNode;
  oProject: TDOMNode;
  oConnection: TDOMNode;
  oConnections: TDOMNode;
  oServer: TDOMNode;
  oServers: TDOMNode;
	oWindows: TDOMNode;
  oWindow: TDOMNode;
	oRecents: TDOMNode;
	oRecent: TDOMNode;
  oFolders: TDOMNode;
  oSQLHistory: TDOMNode;
  oHistory: TDOMNode;
	oLine: TDOMNode;
  oProps: TDOMNode;
  oProp: TDOMNode;
	Prop: TMarathonCustomProperty;
  Hist: TSQLHistoryListItem;
  Connection: TMarathonCacheConnection;
  Server: TMarathonCacheServer;
	NV: TrmTreeNonViewNode;
  wNode: TrmTreeNonViewNode;
  wRecent: TMarathonCacheRecentItem;
  F: File;

  procedure ProcessFolders(NVNode: TrmTreeNonViewNode; Element: TDOMNode);
  var
    oFolderItem: TDOMNode;
    wNode: TrmTreeNonViewNode;
    wFolder: TMarathonCacheProjectFolder;
    attr: TDomNOde;

	begin
    if Assigned(Element) then
    begin
      oFolderItem := Element.FirstChild;
      while oFolderItem <> nil do
			begin
				if oFolderItem.NodeName = 'folder' then
				begin
					attr := oFolderItem.Attributes.GetNamedItem('foldername');

					wNode := FCache.Cache.AddPathNode(NVNode, attr.NodeValue);
					wFolder := TMarathonCacheProjectFolder.Create;
					wFolder.ContainerNode := wNode;
					wFolder.RootItem := FCache;
					wFolder.Caption := attr.NodeValue;
					wFolder.Expanded := True;
					wNode.Data := wFolder;
					ProcessFolders(wNode, oFolderItem);
				end;
				if oFolderItem.NodeName = 'folderitem' then
        begin


        end;
        oFolderItem := oFolderItem.NextSibling;
      end;
    end;
  end;

begin
	FCache.BuildTree;
	try
		AssignFile(f, FileName);
		try
			Reset(f, 1);
			try
				ReadXMLFile(doc, f);
			except
				on E: EXMLReadError do
				begin
					MessageDlg('Marathon does not recognise this file as a project file.', mtError, [mbOK], 0);
					raise;
				end;
			end;
		finally
			CloseFile(F);
		end;

		oProject := doc.DocumentElement;
		oProject := oProject.FindNode('project');

		if Assigned(oProject) then
		begin
			if oProject.NodeName = 'project' then
			begin
				FFriendlyName := oProject.Attributes.GetNamedItem('name').NodeValue;
				FShowSystem := oProject.Attributes.GetNamedItem('showsystem').NodeValue = '1';
				FViewSystemDomains := oProject.Attributes.GetNamedItem('viewsystemdomains').NodeValue = '1';
				FViewSystemTriggers := oProject.Attributes.GetNamedItem('viewsystemtriggers').NodeValue = '1';
				FEncoding := StrToInt(oProject.Attributes.GetNamedItem('encoding').NodeValue);
				FSaveWindowPositions := oProject.Attributes.GetNamedItem('savewindowpositions').NodeValue = '1';
				if Assigned(oProject.Attributes.GetNamedItem('resultpanelheight')) and (oProject.Attributes.GetNamedItem('resultpanelheight').NodeValue <> '') then
				begin
					FResultsPanelHeight := StrToInt(oProject.Attributes.GetNamedItem('resultpanelheight').NodeValue);
				end
				else
					FResultsPanelHeight := 100;

				oNode := oProject.FindNode('meta-extract-settings');
				if Assigned(oNode) then
				begin
					FMetaExtractType := TExtractType(GetEnumValue(TypeInfo(TExtractType), oNode.Attributes.GetNamedItem('metaextracttype').NodeValue));
					FMetaCreateDatabase := oNode.Attributes.GetNamedItem('metacreatedatabase').NodeValue = '1';
					FMetaIncludePassword := oNode.Attributes.GetNamedItem('metaincludepassword').NodeValue = '1';
					FMetaIncludeDependents := oNode.Attributes.GetNamedItem('metaincludedependents').NodeValue = '1';
					if Assigned(oNode.Attributes.GetNamedItem('metaincludedoc')) then
						FMetaIncludeDoc := oNode.Attributes.GetNamedItem('metaincludedoc').NodeValue = '1';
					FMetaWrap := oNode.Attributes.GetNamedItem('metawrap').NodeValue = '1';
					FMetawrapAt := StrToInt(oNode.Attributes.GetNamedItem('metawrapat').NodeValue);
					FMetaDecimals := StrToInt(oNode.Attributes.GetNamedItem('metadecimalplaces').NodeValue);
					FMetaDecSeparator := oNode.Attributes.GetNamedItem('metadecimalseperator').NodeValue;
				end;

				oConnections := oProject.FindNode('connections');
				if Assigned(oConnections) then
				begin
					oConnection := oConnections.FirstChild;
					while oConnection <> nil do
					begin
						if oConnection.NodeName = 'connection' then
						begin
							Connection := FCache.AddConnectionInternal;
							with Connection do
							begin
								Caption := oConnection.Attributes.GetNamedItem('name').NodeValue;
								DBFileName := oConnection.Attributes.GetNamedItem('databasefilename').NodeValue;
								ServerName := oConnection.Attributes.GetNamedItem('servername').NodeValue;
								UserName := oConnection.Attributes.GetNamedItem('username').NodeValue;
								if Assigned(oConnection.Attributes.GetNamedItem('password')) then
									Password := Decrypt(oConnection.Attributes.GetNamedItem('password').NodeValue, E_START_KEY, E_MULT_KEY, E_ADD_KEY)
								else
									Password := '';
								if Assigned(oConnection.Attributes.GetNamedItem('rememberpassword')) then
									RememberPassword := oConnection.Attributes.GetNamedItem('rememberpassword').NodeValue = '1'
								else
									RememberPassword := False;
								LangDriver := oConnection.Attributes.GetNamedItem('charset').NodeValue;
								SQLRole := oConnection.Attributes.GetNamedItem('sqlrole').NodeValue;

								if Assigned(oConnection.Attributes.GetNamedItem('sqldialect')) then
								begin
									if oConnection.Attributes.GetNamedItem('sqldialect').NodeValue <> '' then
										SQLDialect := StrToInt(oConnection.Attributes.GetNamedItem('sqldialect').NodeValue)
									else
										SQLDialect := 1;
								end
								else
									SQLDialect := 1;
							end;
						end;
						oConnection := oConnection.NextSibling;
					end;
				end;

				oServers := oProject.FindNode('servers');
				if Assigned(oServers) then
				begin
					oServer := oServers.FirstChild;
					while oServer <> nil do
					begin
						if oServer.NodeName = 'server' then
						begin
							Server := FCache.AddServerInternal;
							with Server do
							begin
								Caption := oServer.Attributes.GetNamedItem('name').NodeValue;
								UserName := oServer.Attributes.GetNamedItem('username').NodeValue;
								RememberPassword := oServer.Attributes.GetNamedItem('rememberpassword').NodeValue = '1';
								if RememberPassword then
									Password := Decrypt(oServer.Attributes.GetNamedItem('password').NodeValue, E_START_KEY, E_MULT_KEY, E_ADD_KEY);
								if oServer.Attributes.GetNamedItem('local').NodeValue = '1' then
									Local := True
								else
								begin
									Local := False;
									HostName := oServer.Attributes.GetNamedItem('hostname').NodeValue;
									Protocol := StrToInt(oServer.Attributes.GetNamedItem('protocol').NodeValue);
								end;
								SecureDatabaseName := oServer.Attributes.GetNamedItem('securedatabasename').NodeValue;
								SecureDatabaseUserName := oServer.Attributes.GetNamedItem('securedatabaseusername').NodeValue;
								SecureDatabaseRememberPassword := oServer.Attributes.GetNamedItem('securedatabaserememberpassword').NodeValue = '1';
								if SecureDatabaseRememberPassword then
									SecureDatabasePassword := Decrypt(oServer.Attributes.GetNamedItem('password').NodeValue, E_START_KEY, E_MULT_KEY, E_ADD_KEY);
							end;
						end;
						oServer := oServer.NextSibling;
					end;
				end;

				oWindows := oProject.FindNode('windows');
				if Assigned(oWindows) then
				begin
					oWindow := oWindows.FirstChild;
					while oWindow <> nil do
					begin
						if oWindow.NodeName = 'window' then
						begin
							with FWindowList.Add do
							begin
								PositionLeft := StrToInt(oWindow.Attributes.GetNamedItem('positionleft').NodeValue);
								PositionTop := StrToInt(oWindow.Attributes.GetNamedItem('positiontop').NodeValue);
								SizeWidth := StrToInt(oWindow.Attributes.GetNamedItem('sizewidth').NodeValue);
								SizeHeight := StrToInt(oWindow.Attributes.GetNamedItem('sizeheight').NodeValue);
								if oWindow.Attributes.GetNamedItem('ismaximized').NodeValue = '1' then
									IsMaximised := True
								else
									IsMaximised := False;
								WindowType := TGSSCacheType(GetEnumValue(TypeInfo(TGSSCacheType), oWindow.Attributes.GetNamedItem('windowtype').NodeValue));
								ObjectName := oWindow.Attributes.GetNamedItem('objectname').NodeValue;
								ConnectionName := oWindow.Attributes.GetNamedItem('connectionname').NodeValue;
							end;
						end;
						oWindow := oWindow.NextSibling;
					end;
				end;

				NV := FCache.Cache.FindPathNode(cSepChar + 'Recent');
				if Assigned(NV) then
				begin
					oRecents := oProject.FindNode('recentitems');
					if Assigned(oRecents) then
					begin
						oRecent := oRecents.FirstChild;
						while oRecent <> nil do
						begin
							if oRecent.NodeName = 'recentitem' then
							begin
                wNode := FCache.Cache.AddPathNode(NV, oRecent.Attributes.GetNamedItem('objectname').NodeValue);
                wRecent := TMarathonCacheRecentItem.Create;
                wRecent.ContainerNode := wNode;
                wRecent.RootItem := FCache;
                wRecent.Caption := '['+ oRecent.Attributes.GetNamedItem('objectname').NodeValue + '] in ' + oRecent.Attributes.GetNamedItem('connectionname').NodeValue;
                wRecent.ConnectionName := oRecent.Attributes.GetNamedItem('connectionname').NodeValue;
                wRecent.ObjectName := oRecent.Attributes.GetNamedItem('objectname').NodeValue;
                if oRecent.Attributes.GetNamedItem('usage').NodeValue <> '' then
                  wRecent.UsageCount := StrToInt(oRecent.Attributes.GetNamedItem('usage').NodeValue);
                wRecent.ActualCacheType := TGSSCacheType(GetEnumValue(TypeInfo(TGSSCacheType), oRecent.Attributes.GetNamedItem('itemtype').NodeValue));
                wRecent.FExpanded := True;
                wRecent.UsageCount := 1;
                wNode.Data := wRecent;
              end;
							oRecent := oRecent.NextSibling;
            end;
          end;
          if Assigned(NV.Data) then
            TMarathonCacheBaseNode(NV.Data).DoOperation(opRefresh);
        end;

        NV := FCache.Cache.FindPathNode(cSepChar + 'Projects');
        if Assigned(NV) then
        begin
          oFolders := oProject.FindNode('folders');
					ProcessFolders(NV, oFolders);
        end;


				oSQLHistory := oProject.FindNode('sqlhistory');
				if Assigned(oSQLHistory) then
        begin
          oHistory := oSQLHistory.FirstChild;
          while oHistory <> nil do
          begin
            if oHistory.NodeName = 'sqlhistoryitem' then
            begin
              Hist := FSQLHistory.Add;
              oLine := oHistory.FirstChild;
              while oLine <> nil do
              begin
                if oLine.NodeName = 'line' then
                begin
                  if oLine.Attributes.GetNamedItem('data') <> nil then
                    Hist.SQLText.Add(oLine.Attributes.GetNamedItem('data').NodeValue);
                end;
                oLine := oLine.NextSibling;
              end;
            end;
            oHistory := oHistory.NextSibling;
          end;
        end;

				oProps := oProject.FindNode('custom-properties');
        if Assigned(oProps) then
        begin
          oProp := oProps.FirstChild;
          while oProp <> nil do
          begin
            if oProp.NodeName = 'custom-property' then
            begin
							Prop := TMarathonCustomProperty.Create;
              Prop.Name := oProp.Attributes.GetNamedItem('name').NodeValue;
              if oProp.Attributes.GetNamedItem('name').NodeValue = 'NULL' then
								Prop.Value := NULL
              else
								Prop.Value := oProp.Attributes.GetNamedItem('value').NodeValue;
              FCustomProperties.Add(Prop);  
						end;
						oProp := oProp.NextSibling;
          end;
        end;

      end;
    end;
  except
    on E: Exception do
    begin
      Close;
      raise Exception.Create('Unable to load project');
    end;
  end;
  FOpen := True;
end;

procedure TMarathonProject.SaveToFile(FileName: String);
var
  Doc: TXMLDocument;
  oXML: TDomNode;
  oProject: TDomNode;
  oConnection: TDomNode;
  oConnections: TDomNode;
	oServer: TDomNode;
  oServers: TDomNode;
	oWindow: TDomNode;
  oWindows: TDomNode;
  oRecent: TDomNode;
  oRecents: TDomNode;
  oFolders: TDomNode;
  oNode: TDOMNode;
  oSQLHistory: TDOMNode;
  oHistory: TDOMNode;
  oLine: TDOMNode;
	oProps: TDOMNode;
  oProp: TDOMNode;
	Prop: TMarathonCustomProperty;
  Idx: Integer;
	Idy: Integer;
	NV: TrmTreeNonViewNode;
	CNV: TrmTreeNonViewNode;
	wRecent: TMarathonCacheRecentItem;

  procedure ProcessFolders(NonViewNode: TrmTreeNonViewNode; Element: TDomNode);
  var
    LNV: TrmTreeNonViewNode;
    oFolderItem: TDomNode;

  begin
    Lnv := NonViewNode.GetFirstChild;
    while Assigned(Lnv) do
    begin
      if Assigned(Lnv.Data) then
      begin
        if TObject(Lnv.Data) is TMarathonCacheProjectFolder then
        begin
          oFolderItem := Doc.CreateElement('folder');
          TDomElement(oFolderItem).SetAttribute('foldername', TMarathonCacheProjectFolder(Lnv.Data).Caption);
          Element.AppendChild(oFolderItem);
          ProcessFolders(Lnv, oFolderItem);
        end;
        if TObject(Lnv.Data) is TMarathonProjectCacheFolderItem then
				begin
          oFolderItem := Doc.CreateElement('folderitem');
					TDomElement(oFolderItem).SetAttribute('itemname', TMarathonCacheProjectFolder(Lnv.Data).Caption);
          Element.AppendChild(oFolderItem);
        end;
      end;
      Lnv := NonViewNode.GetNextChild(Lnv);
    end;
  end;

begin
  Doc := TXmlDocument.Create;
  try
		try
      oXML := Doc.CreateElement('marathon-project');
			Doc.AppendChild(oXML);

			oProject := Doc.CreateElement('project');
			oXML.AppendChild(oProject);

			TDOMElement(oProject).SetAttribute('name', FFriendlyName);
			if FShowSystem then
				TDOMElement(oProject).SetAttribute('showsystem', '1')
			else
				TDOMElement(oProject).SetAttribute('showsystem', '0');
			if FViewSystemDomains then
				TDOMElement(oProject).SetAttribute('viewsystemdomains', '1')
			else
				TDOMElement(oProject).SetAttribute('viewsystemdomains', '0');
			if FViewSystemTriggers then
				TDOMElement(oProject).SetAttribute('viewsystemtriggers', '1')
			else
				TDOMElement(oProject).SetAttribute('viewsystemtriggers', '0');
			TDOMElement(oProject).SetAttribute('encoding', IntToStr(FEncoding));

			if FSaveWindowPositions then
				TDOMElement(oProject).SetAttribute('savewindowpositions', '1')
			else
				TDOMElement(oProject).SetAttribute('savewindowpositions', '0');

			TDOMElement(oProject).SetAttribute('resultpanelheight', IntToStr(FResultsPanelHeight));

			oNode := Doc.CreateElement('meta-extract-settings');
			oProject.AppendChild(oNode);
			TDOMElement(oNode).SetAttribute('metaextracttype', GetEnumName(Typeinfo(TExtractType), Ord(FMetaExtractType)));
			if FMetaCreateDatabase then
				TDOMElement(oNode).SetAttribute('metacreatedatabase', '1')
			else
				TDOMElement(oNode).SetAttribute('metacreatedatabase', '0');
			if FMetaIncludePassword then
				TDOMElement(oNode).SetAttribute('metaincludepassword', '1')
			else
				TDOMElement(oNode).SetAttribute('metaincludepassword', '0');
			if FMetaIncludeDependents then
				TDOMElement(oNode).SetAttribute('metaincludedependents', '1')
			else
				TDOMElement(oNode).SetAttribute('metaincludedependents', '0');
			if FMetaIncludeDoc then
				TDOMElement(oNode).SetAttribute('metaincludedoc', '1')
			else
				TDOMElement(oNode).SetAttribute('metaincludedoc', '0');
			if FMetaWrap then
				TDOMElement(oNode).SetAttribute('metawrap', '1')
			else
				TDOMElement(oNode).SetAttribute('metawrap', '0');
			TDOMElement(oNode).SetAttribute('metawrapat', IntToStr(FMetawrapAt));
			TDOMElement(oNode).SetAttribute('metadecimalplaces', IntToStr(FMetadecimals));
			TDOMElement(oNode).SetAttribute('metadecimalseperator', FMetaDecSeparator);

			oConnections := Doc.CreateElement('connections');
			oProject.AppendChild(oConnections);

			// Save the connections
			for Idx := 0 to Cache.ConnectionCount - 1 do
			begin
				oConnection := Doc.CreateElement('connection');
				TDOMElement(oConnection).SetAttribute('name', Cache.Connections[Idx].Caption);
				TDOMElement(oConnection).SetAttribute('databasefilename', Cache.Connections[Idx].DBFileName);
				TDOMElement(oConnection).SetAttribute('servername', Cache.Connections[Idx].ServerName);
				TDOMElement(oConnection).SetAttribute('username', Cache.Connections[Idx].UserName);
				if Cache.Connections[Idx].RememberPassword then
					TDOMElement(oConnection).SetAttribute('rememberpassword', '1')
				else
					TDOMElement(oConnection).SetAttribute('rememberpassword', '0');

				if Cache.Connections[Idx].RememberPassword then
					TDOMElement(oConnection).SetAttribute('password', Cache.Connections[Idx].EncPassword);
				TDOMElement(oConnection).SetAttribute('charset', Cache.Connections[Idx].LangDriver);
				TDOMElement(oConnection).SetAttribute('sqlrole', Cache.Connections[Idx].SQLRole);
				TDOMElement(oConnection).SetAttribute('sqldialect', IntToStr(Cache.Connections[Idx].SQLDialect));
				oConnections.AppendChild(oConnection);
			end;

			oServers := Doc.CreateElement('servers');
			oProject.AppendChild(oServers);

			// Save the servers
			for Idx := 0 to Cache.ServerCount - 1 do
			begin
				oServer := Doc.CreateElement('server');
				TDOMElement(oServer).SetAttribute('name', Cache.Servers[Idx].Caption);
				TDOMElement(oServer).SetAttribute('username', Cache.Servers[Idx].UserName);
				if Cache.Servers[Idx].RememberPassword then
					TDOMElement(oServer).SetAttribute('rememberpassword', '1')
				else
					TDOMElement(oServer).SetAttribute('rememberpassword', '0');
				if Cache.Servers[Idx].RememberPassword then
					TDOMElement(oServer).SetAttribute('password', Cache.Servers[Idx].EncPassword);
				if Cache.Servers[Idx].Local then
					TDOMElement(oServer).SetAttribute('local', '1')
				else
				begin
					TDOMElement(oServer).SetAttribute('local', '0');
					TDOMElement(oServer).SetAttribute('hostname', Cache.Servers[Idx].HostName);
					TDOMElement(oServer).SetAttribute('protocol', IntToStr(Cache.Servers[Idx].Protocol));
				end;
				TDOMElement(oServer).SetAttribute('securedatabasename', Cache.Servers[Idx].SecureDatabaseName);
				TDOMElement(oServer).SetAttribute('securedatabaseusername', Cache.Servers[Idx].SecureDatabaseUserName);
				if Cache.Servers[Idx].SecureDatabaseRememberPassword then
					TDOMElement(oServer).SetAttribute('securedatabaserememberpassword', '1')
				else
					TDOMElement(oServer).SetAttribute('securedatabaserememberpassword', '0');
				if Cache.Servers[Idx].SecureDatabaseRememberPassword then
					TDOMElement(oServer).SetAttribute('securedatabasepassword', Cache.Servers[Idx].SecureDatabaseEncPassword);

				oServers.AppendChild(oServer);
			end;

			oWindows := Doc.CreateElement('windows');
			oProject.AppendChild(oWindows);

			// Save the windows
			for Idx := 0 to FWindowList.Count - 1 do
			begin
				oWindow := Doc.CreateElement('window');
				TDOMElement(oWindow).SetAttribute('positionleft', IntToStr(FWindowList.Items[Idx].PositionLeft));
				TDOMElement(oWindow).SetAttribute('positiontop', IntToStr(FWindowList.Items[Idx].PositionTop));
				TDOMElement(oWindow).SetAttribute('sizewidth', IntToStr(FWindowList.Items[Idx].SizeWidth));
				TDOMElement(oWindow).SetAttribute('sizeheight', IntToStr(FWindowList.Items[Idx].SizeHeight));
				if FWindowList.Items[Idx].IsMaximised then
					TDOMElement(oWindow).SetAttribute('ismaximized', '1')
				else
          TDOMElement(oWindow).SetAttribute('ismaximized', '0');
        TDOMElement(oWindow).SetAttribute('windowtype', GetEnumName(Typeinfo(TGSSCacheType), Ord(FWindowList.Items[Idx].WindowType)));
				TDOMElement(oWindow).SetAttribute('objectname', FWindowList.Items[Idx].ObjectName);
				TDOMElement(oWindow).SetAttribute('connectionname', FWindowList.Items[Idx].ConnectionName);
				oWindows.AppendChild(oWindow);
			end;

			oRecents := Doc.CreateElement('recentitems');
			oProject.AppendChild(oRecents);

			// Save the recent Items
			NV := FCache.Cache.FindPathNode(cSepChar + 'Recent');
			if Assigned(NV) then
			begin
				CNV := NV.GetFirstChild;
				while CNV <> nil do
				begin
					if Assigned(CNV.Data) then
					begin
						wRecent := TMarathonCacheRecentItem(CNV.Data);

						oRecent := Doc.CreateElement('recentitem');
						TDOMElement(oRecent).SetAttribute('itemtype', GetEnumName(Typeinfo(TGSSCacheType), Ord(wRecent.ActualCacheType)));
						TDOMElement(oRecent).SetAttribute('objectname', wRecent.ObjectName);
						TDOMElement(oRecent).SetAttribute('connectionname', wRecent.ConnectionName);
						TDOMElement(oRecent).SetAttribute('usage', IntToStr(wRecent.UsageCount));
						oRecents.AppendChild(oRecent);
					end;
					CNV := NV.GetNextChild(CNV);
				end;
			end;

			// Save the folders
      NV := FCache.Cache.FindPathNode(cSepChar + 'Projects');
      if Assigned(NV) then
      begin
        oFolders := Doc.CreateElement('folders');
        oProject.AppendChild(oFolders);
        ProcessFolders(NV, oFolders);
      end;

			// Save the SQL History
			oSQLHistory := Doc.CreateElement('sqlhistory');
			oProject.AppendChild(oSQLHistory);

			for Idx := 0 to FSQLHistory.Count - 1 do
			begin
				oHistory := Doc.CreateElement('sqlhistoryitem');
				for Idy := 0 to FSQLHistory.Items[Idx].SQLText.Count - 1 do
				begin
					oLine := Doc.CreateElement('line');
					TDOMElement(oLine).SetAttribute('num', IntToStr(Idy));
					TDOMElement(oLine).SetAttribute('data', FSQLHistory.Items[Idx].SQLText[Idy]);
					oHistory.AppendChild(oLine);
				end;
				oSQLHistory.AppendChild(oHistory);
			end;

			// Save custom properties
			oProps := Doc.CreateElement('custom-properties');
			oProject.AppendChild(oProps);

			for Idx := 0 to FCustomProperties.Count - 1 do
			begin
				Prop := TMarathonCustomProperty(FCustomProperties[Idx]);
				oProp := Doc.CreateElement('custom-property');
				TDOMElement(oProp).SetAttribute('name', Prop.Name);
				if VarIsNull(Prop.Value) then
					TDOMElement(oProp).SetAttribute('value', 'NULL')
				else
					TDOMElement(oProp).SetAttribute('value', Prop.Value);
				oProps.AppendChild(oProp);
			end;

			// Write the file
			WriteXMLFile(Doc, FileName);
		except
			on E: Exception do
				raise Exception.Create('Unable to save project.');
		end;
	finally
		Doc.Free;
	end;
end;

procedure TMarathonProject.Close;
var
	Idx: Integer;

begin
	FCache.Clear;
	FOpen := False;
	FWindowList.Clear;
	for Idx := 0 to FCustomProperties.Count - 1 do
    TObject(FCustomProperties[Idx]).Free;
  FCustomProperties.Clear;
end;

procedure TMarathonProject.NewProject;
begin
  Close;
  FCache.BuildTree;
  FOpen := True;
end;

procedure TMarathonProject.SetResultsPanelHeight(const Value: Integer);
begin
  FResultsPanelHeight := Value;
  Modified := True;
end;

procedure TMarathonProject.SetMetaWrapAt(const Value: Integer);
begin
  FMetaWrapAt := Value;
  Modified := True;
end;

function TMarathonProject.ReadCustomProperty(PropertyName: String): Variant;
var
	Idx: Integer;
	Prop: TMarathonCustomProperty;

begin
	Result := NULL;
	for Idx := 0 to FCustomProperties.Count - 1 do
	begin
		Prop := TMarathonCustomProperty(FCustomProperties[Idx]);
		if Prop.Name = PropertyName then
		begin
			Result := Prop.Value;
			Break;
		end;
	end;
end;

procedure TMarathonProject.WriteCustomProperty(PropertyName: String; PropertyValue: Variant);
var
	Idx: Integer;
	Found: Boolean;
	Prop: TMarathonCustomProperty;

begin
  Found := False;
  for Idx := 0 to FCustomProperties.Count - 1 do
  begin
		Prop := TMarathonCustomProperty(FCustomProperties[Idx]);
    if Prop.Name = PropertyName then
    begin
      Prop.Value := PropertyValue;
      Found := True;
      Break;
    end;
  end;
  if not Found then
  begin
		Prop := TMarathonCustomProperty.Create;
		Prop.Name := PropertyName;
		Prop.Value := PropertyValue;
		FCustomProperties.Add(Prop);
	end;
	FModified := True;
end;

procedure TMarathonProject.SetMetaIncludeDoc(const Value: Boolean);
begin
	FMetaIncludeDoc := Value;
	FModified := True;
end;

{ TSQLHistoryListItem }
constructor TSQLHistoryListItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSQLText := TStringList.Create;
end;

destructor TSQLHistoryListItem.Destroy;
begin
  FSQLText.Free;
  inherited Destroy;
end;

function TSQLHistoryListItem.GetSQLText: TStringList;
begin
  Result := FSQLText;
end;

procedure TSQLHistoryListItem.SetSQLText(Value: TStringList);
begin
  FSQLText.Assign(Value);
end;

{ TSQLHistoryList }
function TSQLHistoryList.Add: TSQLHistoryListItem;
begin
	Result := TSQLHistoryListItem(inherited Add);
	FOwner.Modified := True;
end;

constructor TSQLHistoryList.Create(AOwner: TComponent);
begin
	inherited Create(TSQLHistoryListItem);
	FOwner := TMarathonProject(AOwner);
end;

function TSQLHistoryList.GetItem(Index: Integer): TSQLHistoryListItem;
begin
	Result := TSQLHistoryListItem(inherited GetItem(Index));
end;

function TSQLHistoryList.GetOwner: TPersistent;
begin
	Result := FOwner;
end;

procedure TSQLHistoryList.SetItem(Index: Integer;	Value: TSQLHistoryListItem);
begin
	inherited SetItem(Index, Value);
end;

{ TMListColumn }
constructor TMListColumn.Create(Collection: TCollection);
begin
	inherited Create(Collection);
end;

function TMListColumn.GetWidth: TWidth;
begin
	Result := FWidth;
end;

procedure TMListColumn.SetCaption(const Value: string);
begin
	FCaption := Value;
end;

procedure TMListColumn.SetWidth(Value: TWidth);
begin
  FWidth := Value;
end;

{ TMListColumns }
function TMListColumns.Add: TMListColumn;
begin
	Result := TMListColumn(inherited Add);
end;

constructor TMListColumns.Create(AOwner: TComponent);
begin
	inherited Create(TMListColumn);
	FOwner := AOwner;
end;

function TMListColumns.GetItem(Index: Integer): TMListColumn;
begin
	Result := TMListColumn(inherited GetItem(Index));
end;

function TMListColumns.GetOwner: TPersistent;
begin
	Result := FOwner;
end;

procedure TMListColumns.SetSortedColumn(const Value: Integer);
var
	Idx: Integer;

begin
	for Idx := 0 to Count - 1 do
		Items[Idx].SortedColumn := Value;
end;

procedure TMListColumns.SetSortOrder(const Value: TSortOrder);
var
	Idx: Integer;

begin
	for Idx := 0 to Count - 1 do
		Items[Idx].SortOrder := Value;
end;

function TMListColumns.Insert(Index: Integer): TMListColumn;
begin
	Result := TMListColumn(inherited Insert(Index));
end;

procedure TMListColumns.SetItem(Index: Integer; Value: TMListColumn);
begin
	inherited SetItem(Index, Value);
end;

function TMListColumns.GetSortedColumn: Integer;
begin
	if Count <> 0 then
		Result := Items[0].SortedColumn
	else
		Result := 0;
end;

function TMListColumns.GetSortOrder: TSortOrder;
begin
	if Count <> 0 then
		Result := Items[0].SortOrder
	else
		Result := srtAsc;
end;

{ TMarathonCacheObject }
function TMarathonCacheObject.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
  begin
    case Op of
      opPrint,
      opPrintPreview,
      opNew,
      opOpen,
      opDrop,
      opExtractDDL,
			opAddToProject:
				Result := True;
		else
			Result := False;
		end;
	end
	else
	begin
		case Op of
			opPrint,
			opPrintPreview,
			opDrop,
			opOpen,
			opExtractDDL,
			opAddToProject:
				Result := True;
		else
			Result := False;
		end;
	end;
end;

{ TMarathonCacheDomainsHeader }
constructor TMarathonCacheDomainsHeader.Create;
begin
	inherited;
	FCacheType := ctDomainHeader;
end;

procedure TMarathonCacheDomainsHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheDomain;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try
			Q.SQL.Add('select RDB$FIELD_NAME from RDB$FIELDS where ((rdb$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$FIELD_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$FIELD_NAME').AsString, 1, 4)) = 'RDB$' then
				begin
					NV := FRootItem.FCache.AddPathNode(fContainerNode, Q.FieldByName('RDB$FIELD_NAME').AsString);
					wNode := TMarathonCacheDomain.Create;
					wNode.ContainerNode := NV;
					wNode.RootItem := FRootItem;
					wNode.Caption := Q.FieldByName('RDB$FIELD_NAME').AsString;
					wNode.ObjectName := Q.FieldByName('RDB$FIELD_NAME').AsString;
					wNode.ConnectionName := FConnectionName;
					wNode.System := True;
					NV.Data := wNode;
				end;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheUserDomainsHeader }
constructor TMarathonCacheUserDomainsHeader.Create;
begin
	inherited;
	FCacheType := ctDomainHeader;
end;

procedure TMarathonCacheUserDomainsHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheDomain;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;

		Q.SQL.Add('select RDB$FIELD_NAME from RDB$FIELDS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$FIELD_NAME asc;');
		Q.Open;
		while not Q.EOF do
		begin
			if AnsiUpperCase(Copy(Q.FieldByName('RDB$FIELD_NAME').AsString, 1, 4)) <> 'RDB$' then
			begin
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$FIELD_NAME').AsString);
				wNode := TMarathonCacheDomain.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$FIELD_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$FIELD_NAME').AsString;
				wNode.ConnectionName := FConnectionName;
				wNode.System := False;
				NV.Data := wNode;
			end;
			Q.Next;
		end;
		FExpanded := True;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheUDFsHeader }
constructor TMarathonCacheUDFsHeader.Create;
begin
	inherited;
	FCacheType := ctUDFHeader;
end;

procedure TMarathonCacheUDFsHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheFunction;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try

			Q.SQL.Add('select RDB$FUNCTION_NAME from RDB$FUNCTIONS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$FUNCTION_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$FUNCTION_NAME').AsString);
				wNode := TMarathonCacheFunction.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$FUNCTION_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$FUNCTION_NAME').AsString;
				wNode.ConnectionName := FConnectionName;
				wNode.System := False;
				NV.Data := wNode;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheExceptionsHeader }
constructor TMarathonCacheExceptionsHeader.Create;
begin
  inherited;
  FCacheType := ctExceptionHeader;
end;

procedure TMarathonCacheExceptionsHeader.Expand(Recursive: Boolean);
var
  wNode: TMarathonCacheException;
  NV: TrmTreeNonViewNode;
  Q: TIBOQuery;

begin
  FContainerNode.DeleteChildren;
  Q := TIBOQuery.Create(nil);
  try
    Q.BeginBusy(False);
    Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
    Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;
    Q.IB_Transaction.StartTransaction;
    try

			Q.SQL.Add('select RDB$EXCEPTION_NAME from RDB$EXCEPTIONS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$EXCEPTION_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin  
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$EXCEPTION_NAME').AsString);
				wNode := TMarathonCacheException.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$EXCEPTION_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$EXCEPTION_NAME').AsString;
        wNode.ConnectionName := FConnectionName;
        wNode.System := False;
        NV.Data := wNode;
        Q.Next;
      end;
			FExpanded := True;
		finally
      Q.IB_Transaction.Commit;
    end;
  finally
    Q.EndBusy;
    Q.Free;
  end;
end;

{ TMarathonCacheGeneratorsHeader }
constructor TMarathonCacheGeneratorsHeader.Create;
begin
	inherited;
	FCacheType := ctGeneratorHeader;
end;

procedure TMarathonCacheGeneratorsHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheGenerator;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
  FContainerNode.DeleteChildren;
  Q := TIBOQuery.Create(nil);
  try
    Q.BeginBusy(False);
    Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
    Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;
    Q.IB_Transaction.StartTransaction;
    try

			Q.SQL.Add('select RDB$GENERATOR_NAME from RDB$GENERATORS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$GENERATOR_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$GENERATOR_NAME').AsString);
				wNode := TMarathonCacheGenerator.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$GENERATOR_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$GENERATOR_NAME').AsString;
				wNode.ConnectionName := FConnectionName;
				wNode.System := False;
				NV.Data := wNode;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheTriggersHeader }
constructor TMarathonCacheTriggersHeader.Create;
begin
	inherited;
	FCacheType := ctTriggerHeader;
end;

procedure TMarathonCacheTriggersHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheTrigger;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try

			Q.SQL.Add('select RDB$TRIGGER_NAME, RDB$TRIGGER_INACTIVE from RDB$TRIGGERS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) and (RDB$TRIGGER_SOURCE is not null) order by RDB$TRIGGER_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$TRIGGER_NAME').AsString, 1, 6)) <> 'CHECK_' then
				begin
					NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$TRIGGER_NAME').AsString);
					wNode := TMarathonCacheTrigger.Create;
					wNode.ContainerNode := NV;
					wNode.RootItem := FRootItem;
					wNode.Caption := Q.FieldByName('RDB$TRIGGER_NAME').AsString;
					wNode.ObjectName := Q.FieldByName('RDB$TRIGGER_NAME').AsString;
          wNode.IsActive := Q.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger = 0;
					wNode.ConnectionName := FConnectionName;
					wNode.System := False;
					NV.Data := wNode;
				end;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheSystemTriggersHeader }
constructor TMarathonCacheSystemTriggersHeader.Create;
begin
	inherited;
	FCacheType := ctTriggerHeader;
end;

procedure TMarathonCacheSystemTriggersHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheTrigger;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try

			Q.SQL.Add('select RDB$TRIGGER_NAME from RDB$TRIGGERS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) and (RDB$TRIGGER_SOURCE is not null) order by RDB$TRIGGER_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$TRIGGER_NAME').AsString, 1, 6)) = 'CHECK_' then
				begin
					NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$TRIGGER_NAME').AsString);
					wNode := TMarathonCacheTrigger.Create;
					wNode.ContainerNode := NV;
					wNode.RootItem := FRootItem;
					wNode.Caption := Q.FieldByName('RDB$TRIGGER_NAME').AsString;
					wNode.ObjectName := Q.FieldByName('RDB$TRIGGER_NAME').AsString;
					wNode.ConnectionName := FConnectionName;
					wNode.System := False;
					NV.Data := wNode;
				end;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheStoredProceduresHeader }
constructor TMarathonCacheStoredProceduresHeader.Create;
begin
	inherited;
	FCacheType := ctSPHeader;
end;

procedure TMarathonCacheStoredProceduresHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheProcedure;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
    Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;
    Q.IB_Transaction.StartTransaction;
    try

			Q.SQL.Add('select RDB$PROCEDURE_NAME from RDB$PROCEDURES where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) order by RDB$PROCEDURE_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$PROCEDURE_NAME').AsString);
				wNode := TMarathonCacheProcedure.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$PROCEDURE_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$PROCEDURE_NAME').AsString;
        wNode.ConnectionName := FConnectionName;
        wNode.System := False;
        NV.Data := wNode;
        Q.Next;
      end;
      FExpanded := True;
    finally
      Q.IB_Transaction.Commit;
    end;
  finally
    Q.EndBusy;
    Q.Free;
  end;
end;

{ TMarathonCacheViewsHeader }

constructor TMarathonCacheViewsHeader.Create;
begin
	inherited;
	FCacheType := ctViewHeader;
end;

procedure TMarathonCacheViewsHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheView;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try

			Q.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) and RDB$VIEW_SOURCE is not null order by RDB$RELATION_NAME asc;');
			Q.Open;
			while not Q.EOF do
			begin
				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$RELATION_NAME').AsString);
				wNode := TMarathonCacheView.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$RELATION_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$RELATION_NAME').AsString;
				wNode.ConnectionName := FConnectionName;
				wNode.System := False;
				NV.Data := wNode;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheTablesHeader }
constructor TMarathonCacheTablesHeader.Create;
begin
	inherited;
	FCacheType := ctTableHeader;
end;

procedure TMarathonCacheTablesHeader.Expand(Recursive: Boolean);
var
	wNode: TMarathonCacheTable;
	NV: TrmTreeNonViewNode;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try

			Q.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) and RDB$VIEW_SOURCE is null order by RDB$RELATION_NAME asc');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('RDB$RELATION_NAME').AsString, 1, 4)) = 'RDB$' then
				begin
					Q.Next;
					Continue;
				end;

				NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$RELATION_NAME').AsString);
				wNode := TMarathonCacheTable.Create;
				wNode.ContainerNode := NV;
				wNode.RootItem := FRootItem;
				wNode.Caption := Q.FieldByName('RDB$RELATION_NAME').AsString;
				wNode.ObjectName := Q.FieldByName('RDB$RELATION_NAME').AsString;
				wNode.ConnectionName := FConnectionName;
				wNode.System := AnsiUpperCase(Copy(Q.FieldByName('RDB$RELATION_NAME').AsString, 1, 4)) = 'RDB$';
				NV.Data := wNode;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

{ TMarathonCacheDomain }
constructor TMarathonCacheDomain.Create;
begin
	inherited;
	FImageIndex := 6;
	FCacheType := ctDomain;
end;

{ TMarathonCacheTable }
constructor TMarathonCacheTable.Create;
begin
	inherited;
	FImageIndex := 2;
	FCacheType := ctTable;
end;

procedure TMarathonCacheTable.Expand(Recursive: Boolean);
begin
	inherited;
end;

{ TMarathonCacheView }
constructor TMarathonCacheView.Create;
begin
	inherited;
	FImageIndex := 5;
	FCacheType := ctView;
end;

{ TMarathonCacheProcedure }
constructor TMarathonCacheProcedure.Create;
begin
  inherited;
  FImageIndex := 3;
  FCacheType := ctSP;
end;

{ TMarathonCacheTrigger }
function TMarathonCacheTrigger.CanDoOperation(Op: TGSSCacheOp;
  Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opProperties:
				Result := True;
		else
			Result := False;
		end;
	end
	else
		Result := False;
end;

constructor TMarathonCacheTrigger.Create;
begin
	inherited;
  fIsActive := false;
	FImageIndex := 4;
	FCacheType := ctTrigger;
end;

function TMarathonCacheTrigger.getOverlayIndex: integer;
begin
   if not fIsActive then
      result := 1
   else
      result := -1;
end;

{ TMarathonCacheGenerator }
constructor TMarathonCacheGenerator.Create;
begin
	inherited;
	FImageIndex := 8;
	FCacheType := ctGenerator;
end;

{ TMarathonCacheException }
constructor TMarathonCacheException.Create;
begin
  inherited;
	FImageIndex := 7;
	FCacheType := ctException;
end;

{ TMarathonCacheFunction }
constructor TMarathonCacheFunction.Create;
begin
	inherited;
	FImageIndex := 9;
	FCacheType := ctUDF;
end;

{ TMarathonCacheHeader }
function TMarathonCacheHeader.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opPrint:
				Result := True;

			opPrintPreview:
				Result := True;

			opNew:
				Result := True;

			opRefresh:
				Result := True;

			opExpandNode:
				Result := True;

			opExtractDDL:
				Result := True;
		else
			Result := False;
		end;
	end
	else
		Result := False;
end;

constructor TMarathonCacheHeader.Create;
begin
	inherited;
	FImageIndex := 1;
	FCacheType := ctCacheHeader;
end;

procedure TMarathonCacheConnectionsHeader.Expand(Recursive: Boolean);
begin
	inherited;
	FExpanded := True;
end;

function TMarathonCacheConnectionsHeader.GetContentStr: String;
begin
	Result := 'res://gssres.dll/ConnectionHeader.htm'
end;

procedure TMarathonCacheRecentHeader.Expand(Recursive: Boolean);
begin
	inherited;
	FExpanded := True;
end;

{ TMarathonProjectCacheFolderItem }
function TMarathonProjectCacheFolderItem.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opOpen:
				Result := True;
		else
			Result := False;
		end;
	end
	else
	begin
		Result := False;
	end;
end;

constructor TMarathonProjectCacheFolderItem.Create;
begin
	inherited;
	FCacheType := ctFolder;
end;

function TMarathonProjectCacheFolderItem.GetImageIndex: Integer;
begin
	Result := GetImageIndexForCacheType(FActualCacheType);
end;

{ TMarathonCacheProjectFolder }
function TMarathonCacheProjectFolder.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opNew,
			opOpen,
			opCreateFolder:
				Result := True;
		else
			Result := False;
		end;
	end
	else
	begin
		Result := False;
	end;
end;

constructor TMarathonCacheProjectFolder.Create;
begin
	inherited;
	FCacheType := ctFolder;
end;

procedure TMarathonCacheProjectHeader.Expand(Recursive: Boolean);
begin
	inherited;
	FExpanded := True;
end;

procedure TMarathonCacheProjectFolder.Expand(Recursive: Boolean);
begin
	inherited;
	FExpanded := True;
end;

{ TMarathonCacheServersHeader }
constructor TMarathonCacheServersHeader.Create;
begin
	inherited;
	FStatic := True;
	FImageIndex := 1;
end;

procedure TMarathonCacheServersHeader.Expand(Recursive: Boolean);
begin
	inherited;
	FExpanded := True;
end;

{ TMarathonCacheServer }
function TMarathonCacheServer.CanDoOperation(Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	if not Multiple then
	begin
		case Op of
			opConnect:
				Result := not Connected;

			opDisConnect:
				Result := Connected;

			opProperties:
				Result := True;
		else
			Result := False;
		end;
	end
	else
		Result := False;
end;

function TMarathonCacheServer.Connect: Boolean;
begin
	Result := False;
end;

constructor TMarathonCacheServer.Create;
begin
	inherited;
	FImageIndex := 0;
	FStatic := True;
	FCacheType := ctServer;
end;

destructor TMarathonCacheServer.Destroy;
begin
	inherited;
end;

procedure TMarathonCacheServer.Disconnect;
begin

end;

procedure TMarathonCacheServer.Expand(Recursive: Boolean);
var
	NV: TrmTreeNonViewNode;
	wNode: TMarathonCacheBaseNode;

begin
	if not Connected then
	begin
		if not Connect then
		begin
			FExpanded := False;
			Exit;
		end;
	end;

	if FStatic and (FContainerNode.Count = 4) then
	begin
		FExpanded := True;
		Exit;
	end;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Backup');
	wNode := TMarathonCacheServerAdminBackupHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	TMarathonCacheServerAdminBackupHeader(wNode).ServerName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Certificates');
	wNode := TMarathonCacheServerAdminCertificatesHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	TMarathonCacheServerAdminCertificatesHeader(wNode).ServerName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Server Log');
	wNode := TMarathonCacheServerAdminLogHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	TMarathonCacheServerAdminLogHeader(wNode).ServerName := FCaption;
	NV.Data := wNode;

	NV := FRootItem.FCache.AddPathNode(fContainerNode, 'Users');
	wNode := TMarathonCacheServerAdminUsersHeader.Create;
	wNode.ContainerNode := NV;
	wNode.RootItem := FRootItem;
	wNode.Caption := NV.Text;
	TMarathonCacheServerAdminUsersHeader(wNode).ServerName := FCaption;
	NV.Data := wNode;

	FExpanded := True;
end;

function TMarathonCacheServer.GetConnected: Boolean;
begin
	Result := False;
end;

function TMarathonCacheServer.GetEncPassword: String;
begin
	Result := Encrypt(FPassword, E_START_KEY, E_MULT_KEY, E_ADD_KEY);
end;

function TMarathonCacheServer.GetSecureDatabaseEncPassword: String;
begin
	Result := Encrypt(FSecureDatabasePassword, E_START_KEY, E_MULT_KEY, E_ADD_KEY);
end;

function TMarathonCacheServer.IsIB5: Boolean;
begin
	Result := False;
end;

function TMarathonCacheServer.IsIB6: Boolean;
begin
	Result := False;
end;

procedure TMarathonCacheServer.ResetCaption(Value: String);
begin
	inherited;
  FRootItem.ConnectionsChanged := True;
end;

procedure TMarathonCacheServer.SetHostName(const Value: String);
begin
  FHostName := Value;
  FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetLocal(const Value: Boolean);
begin
	FLocal := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetProtocol(const Value: Byte);
begin
	FProtocol := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetPassword(const Value: String);
begin
	FPassword := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetRememberPassword(const Value: Boolean);
begin
	FRememberPassword := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetUserName(const Value: String);
begin
	FUserName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetSecureDatabaseName(const Value: String);
begin
	FSecureDatabaseName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetSecureDatabaseUserName(const Value: String);
begin
	FSecureDatabaseUserName := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetSecureDatabasePassword(const Value: String);
begin
	FSecureDatabasePassword := Value;
	FRootItem.Modified := True;
end;

procedure TMarathonCacheServer.SetSecureDatabaseRememberPassword(const Value: Boolean);
begin
	FSecureDatabaseRememberPassword := Value;
	FRootItem.Modified := True;
end;

{ TMarathonCacheServerAdminUsers }
function TMarathonCacheServerAdminUsersHeader.CanDoOperation(Op: TGSSCacheOp;
  Multiple: Boolean): Boolean;
begin
	Result := False;
end;

constructor TMarathonCacheServerAdminUsersHeader.Create;
begin
	inherited;

end;

{ TMarathonCacheServerAdminLog }

function TMarathonCacheServerAdminLogHeader.CanDoOperation(Op: TGSSCacheOp;
	Multiple: Boolean): Boolean;
begin
	Result := False;
end;

constructor TMarathonCacheServerAdminLogHeader.Create;
begin
	inherited;

end;

{ TMarathonCacheServerAdminCertificates }

function TMarathonCacheServerAdminCertificatesHeader.CanDoOperation(
	Op: TGSSCacheOp; Multiple: Boolean): Boolean;
begin
	Result := False;
end;

constructor TMarathonCacheServerAdminCertificatesHeader.Create;
begin
	inherited;
end;

{ TMarathonCacheServerAdminBackup }
function TMarathonCacheServerAdminBackupHeader.CanDoOperation(Op: TGSSCacheOp;
	Multiple: Boolean): Boolean;
begin
	Result := False;
end;

constructor TMarathonCacheServerAdminBackupHeader.Create;
begin
	inherited;
end;

{ TMarathonCacheSysTablesHeader }
constructor TMarathonCacheSysTablesHeader.Create;
begin
	inherited;
	FCacheType := ctTableHeader;
end;

procedure TMarathonCacheSysTablesHeader.Expand(Recursive: Boolean);
var
	NV: TrmTreeNonViewNode;
	wNode: TMarathonCacheTable;
	Q: TIBOQuery;

begin
	FContainerNode.DeleteChildren;
	Q := TIBOQuery.Create(nil);
	try
		Q.BeginBusy(False);
		Q.IB_Connection := FRootItem.ConnectionByName[FConnectionName].Connection;
		Q.IB_Transaction := FRootItem.ConnectionByName[FConnectionName].Transaction;
		if Q.IB_Transaction.Started then
			Q.IB_Transaction.Commit;
		Q.IB_Transaction.StartTransaction;
		try
			Q.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where (RDB$SYSTEM_FLAG = 1) and RDB$VIEW_SOURCE is null order by RDB$RELATION_NAME asc');
			Q.Open;
			while not Q.EOF do
			begin
				if AnsiUpperCase(Copy(Q.FieldByName('rdb$relation_name').AsString, 1, 4)) = 'RDB$' then
				begin
					NV := FRootItem.FCache.AddPathNode(FContainerNode, Q.FieldByName('RDB$RELATION_NAME').AsString);
					wNode := TMarathonCacheTable.Create;
					wNode.ContainerNode := NV;
					wNode.RootItem := FRootItem;
					wNode.Caption := Q.FieldByName('RDB$RELATION_NAME').AsString;
					wNode.ObjectName := Q.FieldByName('RDB$RELATION_NAME').AsString;
					wNode.ConnectionName := FConnectionName;
					wNode.System := AnsiUpperCase(Copy(Q.FieldByName('RDB$RELATION_NAME').AsString, 1, 4)) = 'RDB$';
					NV.Data := wNode;
				end;
				Q.Next;
			end;
			FExpanded := True;
		finally
			Q.IB_Transaction.Commit;
		end;
	finally
		Q.EndBusy;
		Q.Free;
	end;
end;

end.


