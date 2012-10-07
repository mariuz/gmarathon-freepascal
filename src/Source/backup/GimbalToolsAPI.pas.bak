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
// $Id: GimbalToolsAPI.pas,v 1.3 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: GimbalToolsAPI.pas,v $
Revision 1.3  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit GimbalToolsAPI;

interface

uses
  Windows, SysUtils, Classes;

type
  TGimbalMenuType = (
    mtMain,
    mtBrowser,
    mtTableEditor,
    mtEditor);

  IGimbalIDECommandNotifier = interface
    ['{6D649681-ABDD-41E5-B9C6-4C57A3D74E76}']
    procedure OnExecute; safecall;
    function OnUpdateEnabled : Boolean; safecall;
    function OnUpdateChecked : Boolean; safecall;
  end;

  IGimbalIDECommand = interface
    ['{30D3C818-810C-437C-AFBE-FD6E07B35D11}']
    procedure IDESetCommandNotifier(Value : IGimbalIDECommandNotifier); safecall;
    function IDEGetCommandNotifier : IGimbalIDECommandNotifier; safecall;
    property IDECommandNotifier : IGimbalIDECommandNotifier read IDEGetCommandNotifier write IDESetCommandNotifier;
    procedure IDESetCaption(Value : WideString);
    function IDEGetCaption : WideString;
    property IDECaption : WideString read IDEGetCaption write IDESetCaption;
    procedure IDERemove; safecall;
  end;

  IGimbalIDEMenuItem = interface
    ['{8398F9CB-0D88-4D07-BF64-6A8FA239A091}']
    function IDEMenuCount : Integer; safecall;
    function IDEMenuItem(Index : Integer) : IGimbalIDEMenuItem; safecall;
    function IDEGetIndex : Integer; safecall;
    function IDEGetName : WideString; safecall;
    property IDEIndex : Integer read IDEGetIndex;
    property IDEName : WideString read IDEGetName;
    procedure IDERemove; safecall;
    function IDEAddMenuItem(ThisPlugin : Integer; Index : Integer; Name : WideString; Caption : WideString; IsSubItem : Boolean; Command : IGimbalIDECommand) : IGimbalIDEMenuItem; safecall;
  end;

  IGimbalIDEMenus = interface
    ['{B66BAC23-E6E2-4D7D-8806-8537B60668B5}']
    function IDEMenuCount : Integer; safecall;
    function IDEMenuItem(Index : Integer) : IGimbalIDEMenuItem; safecall;
    function IDEAddMenuItem(ThisPlugin : Integer; Index : Integer; Name : WideString; Caption : WideString; IsSubItem : Boolean; Command : IGimbalIDECommand) : IGimbalIDEMenuItem; safecall;
  end;

  IGimbalIDEEditorKeyPressNotifier = interface
    ['{FBB2E2B0-BDB8-420D-A30C-150919287659}']
    procedure IDEKeyPress(ShiftState : TShiftState; Key : Word); safecall;
  end;

  IGimbalIDELines = interface
    ['{128A8EC7-7677-4373-B29D-79244667C427}']
  end;

  IGimbalIDESQLTextEditor = interface
    ['{E6C17F3C-20A7-43B3-9301-733FFDB0FED8}']
    procedure IDESetLines(Value : IGimbalIDELines); safecall;
    function IDEGetLines : IGimbalIDELines; safecall;
    property IDELines : IGimbalIDELines read IDEGetLines write IDESetLines;
  end;

  TGimbalIDESelectedItemType = (
    ctIDEUnknown,
    ctIDEConnection,
		ctIDEServer,
    ctIDEFolder,
    ctIDEFolderItem,
    ctIDERecentHeader,
    ctIDERecentItem,
    ctIDEDomainHeader,
    ctIDEDomain,
    ctIDETableHeader,
    ctIDETable,
    ctIDEViewHeader,
    ctIDEView,
    ctIDESPHeader,
    ctIDESP,
    ctIDETriggerHeader,
    ctIDETrigger,
    ctIDEGeneratorHeader,
    ctIDEGenerator,
    ctIDEExceptionHeader,
    ctIDEException,
    ctIDEUDFHeader,
    ctIDEUDF);

  IGimbalIDESelectedItem = interface
    ['{0A24EC53-5D07-458F-9CEF-21F3D50509B3}']
    function IDEGetItemType : TGimbalIDESelectedItemType; safecall;
    function IDEGetName : WideString; safecall;
    function IDEGetConnectionName : WideString; safecall;

    property IDEItemType : TGimbalIDESelectedItemType read IDEGetItemType;
    property IDEName : WideString read IDEGetName;
    property IDEConnectionName : WideString read IDEGetConnectionName;
  end;

  IGimbalIDESelectedItems = interface
    ['{8314FC2B-086C-4C2C-9509-39C9ABAB0FAF}']
    function IDEGetCount : Integer; safecall;
    property IDECount : Integer read IDEGetCount;
    function IDEGetItem(Index : Integer) : IGimbalIDESelectedItem; safecall;
  end;

  IGimbalIDEWindow = interface
    ['{27F5245B-8485-45BE-998F-72C0D707200C}']
    function IDEGetSelectedItems : IGimbalIDESelectedItems; safecall;
    property IDESelectedItems : IGimbalIDESelectedItems read IDEGetSelectedItems;
  end;

  IGimbalIDEBrowserWindow = interface(IGimbalIDEWindow)
    ['{DA14A869-BA2A-4A5F-BBF6-882497AB62A1}']
  end;

  TGimbalIDETableEditorPage = (
    pgColumns,
    pgContraints,
    pgIndices,
    pgDependencies,
    pgTriggers,
    pgData,
    pgDocumentation,
    pgGrants,
    pgDDL);

  IGimbalIDETableEditorWindow = interface(IGimbalIDEWindow)
    ['{9E62FCAC-4037-41E1-BFCF-576CB85D3BC4}']
    function IDEGetActivePage : TGimbalIDETableEditorPage; safecall;
    property IDEActivePage : TGimbalIDETableEditorPage read IDEGetActivePage;
  end;

  IGimbalIDEConnection = interface
    ['{BC46D321-8264-4C2E-821D-32702F3FB4A6}']
    function IDEGetCurrentDBHandle : Integer; safecall;
    function IDEGetCurrentTransHandle : Integer; safecall;
    function IDEGetIsInterbaseSix : Boolean; safecall;
    function IDEGetSQLDialect : Integer; safecall;

    property IDECurrentDBHandle : Integer read IDEGetCurrentDBHandle;
    property IDECurrentTransHandle : Integer read IDEGetCurrentTransHandle;
    property IDEIsInterbaseSix : Boolean read IDEGetIsInterbaseSix;
    property IDESQLDialect : Integer read IDEGetSQLDialect;
	end;

  TGimbalIDETreeType = (
    ttIDEDomain,
    ttIDETable,
    ttIDEView,
    ttIDESP,
    ttIDETrigger,
    ttIDEGenerator,
    ttIDEException,
    ttIDEUDF);

  IGimbalIDEMarathonProject = interface
    ['{DEF05F04-09D2-459D-86C9-610F1C677F83}']
    function IDEGetConnectionCount : Integer; safecall;
    function IDEGetOpen : Boolean; safecall;
    function IDEGetConnection(Index : Integer) : IGimbalIDEConnection; safecall;
    function IDEGetConnectionByName(Index : WideString) : IGimbalIDEConnection; safecall;
    procedure IDEAddItemToTree(ConnectionName : WideString; ObjectName : WideString; ObjectType : TGimbalIDETreeType); safecall;
    procedure IDEWriteCustomProperty(PropertyName : String; PropertyValue : Variant); safecall;
    function IDEReadCustomProperty(PropertyName : String) : Variant; safecall;
    property IDEConnectionCount : Integer read IDEGetConnectionCount;
    property IDEOpen : Boolean read IDEGetOpen;
  end;

  IGimbalIDEPluginDocInterface = interface
    ['{040EA75A-C495-4422-8DA8-1E5BB7F0B1B5}']
    procedure IDEOnClose; safecall;
    procedure IDEOnResize; safecall;
  end;

  IGimbalIDEMarathonForm = interface
    ['{25063604-06BB-4985-911D-56BFD6B5676F}']
    function GetIDEHandle : THandle; safecall;
    function GetIDEPluginDocInterface : IGimbalIDEPluginDocInterface; safecall;
    procedure SetIDEPluginDocInterface(Value : IGimbalIDEPluginDocInterface); safecall;
    property IDEHandle : THandle read GetIDEHandle;
    property IDEPluginDocInterface : IGimbalIDEPluginDocInterface read GetIDEPluginDocInterface write SetIDEPluginDocInterface;
    procedure IDESetCaption(Value : WideString); safecall;
    function IDEGetCaption : WideString; safecall;
    property IDECaption : WideString read IDEGetCaption write IDESetCaption;
    function IDEGetClientRect : TRect; safecall;
    procedure IDEBringToFront; safecall;
    property IDEClientRect : TRect read IDEGetClientRect;
    procedure IDEShow; safecall;
  end;  

  IGimbalIDEServices = interface(IUnknown)
    ['{332FD356-0434-4A2E-B954-A828207294CB}']
    function IDEGetApplicationHandle : THandle; safecall;
    property IDEApplicationHandle : THandle read IDEGetApplicationHandle;
    function IDEGetActiveWindow : IGimbalIDEWindow; safecall;
    procedure IDERecordToScript(ConnectionName : WideString; Script : WideString); safecall;
    function IDEGetProject : IGimbalIDEMarathonProject; safecall;
    function IDECreateMarathonForm : IGimbalIDEMarathonForm;

    //commands and menus...
    function IDEAddCommand(ThisPlugin : Integer; Name : WideString) : IGimbalIDECommand; safecall;
    function IDEGetMenu(MenuType : TGimbalMenuType) : IGimbalIDEMenus; safecall;

    //notifiers...
    function IDEAddSQLEditorKeyPressNotifier(ThisPlugin : Integer; Notifier : IGimbalIDEEditorKeyPressNotifier) : Boolean; safecall;
  end;

  TPlugin = record
    Index : Integer;
    Name : ShortString;
  end;

var
	GimbalIDEServices: IGimbalIDEServices;

implementation

end.


