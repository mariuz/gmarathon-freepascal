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
// $Id: MarathonInternalInterfaces.pas,v 1.6 2006/10/22 06:04:28 rjmills Exp $

//This comment block was moved to clear up a compiler warning, RJM

{
$Log: MarathonInternalInterfaces.pas,v $
Revision 1.6  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.5  2005/04/13 16:04:29  rjmills
*** empty log message ***

Revision 1.4  2003/11/05 05:40:31  figmentsoft
Added the UnloadTree() method to the interface for deallocating the visual tree before the non visual tree.  That is part of the bug fix to prevent AV on closing projects and quitting.

Revision 1.3  2002/09/23 10:32:51  tmuetze
Added the possibility to load files into the SQL Editor

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block
}

unit MarathonInternalInterfaces;

interface

uses
	Windows, SysUtils, Classes, Forms, Menus, ComCtrls,
	MarathonProjectCacheTypes;

type
  IMarathonIDE = interface
    ['{DABB9C12-82F2-4579-A281-4A63F6C4001A}']
  end;

  IMarathonBrowser = interface
    ['{F222BDC4-D502-4AC8-B87A-4E844AD8509B}']
    function GetUpdateActiveConnection: String;
    procedure LoadTree;
    procedure UnloadTree;   //AC: Added this to fix project close AV bug
    procedure RefreshNode(Item : TObject; PreserveFocus: Boolean);
    procedure ExpandNode(Item: TObject);
    procedure RemoveNode(Item: TObject);
    procedure SavePositions;
  end;

	IMarathonMainForm = interface
    ['{16583A5E-9FF8-4E66-9AC4-710C77EBA687}']
    procedure SetCaption(Value: String);
    function MenuCount: Integer;
    function MenuItemAction(Index: Integer) : TBasicAction;
    function GetCaption: String;
    function GetFormTop: Integer;
    function GetFormHeight: Integer;
    procedure DoStatus(Status: String);
    property Caption: String read GetCaption write SetCaption;
    property FormTop: Integer read GetFormTop;
    property FormHeight: Integer read GetFormHeight;
    procedure LoadMRUMenu;
    procedure LoadWindowList;
    procedure AddMenuItem(MenuAction : TBasicAction);
    function MainFormMonitor:TMonitor;
    procedure LoadOptions;
  end;

  IMarathonRecScriptHost = interface
    ['{5F74B60C-2809-47D9-BC94-98A743D9DCE2}']
    function GetStatusBar : TObject;
  end;

	IMarathonScriptRecorder = interface
    ['{438DFEB6-C9DA-4129-BD41-7DC4AFAA29C0}']
    function CanStopScriptRecord: Boolean;
    function CanStartScriptRecord: Boolean;
    function CanNewScriptRecord: Boolean;
    function CanAppendExistingScript: Boolean;
		function CanSave: Boolean;
		function CanSaveAs: Boolean;
		procedure DoSave;
    procedure DoSaveAs;
    procedure DoStopScriptRecord;
    procedure DoStartScriptRecord;
    procedure DoNewScriptRecord;
    procedure DoAppendExistingScript;
    procedure UpdateStatus;
  end;

	IMarathonSQLForm = interface
    ['{520CB01C-CEF5-4574-9472-F15EA55B02DD}']
    function CurrentConnection: String;
    procedure SetConnectionName(Value: String);
    property DatabaseName: String write SetConnectionName;
  end;

  IMarathonStoredProcEditor = interface
    ['{392F60BD-F8F3-4862-93C9-6ABB31859D57}']
    procedure DebugRefreshDots;
    procedure DebugSetExecutionPoint(Line: Integer);
    procedure DebugSetExceptionLine(Line: Integer; Message: String);
    procedure DebugSetBreakPointLine(Active: Boolean; Line: Integer);
  end;

  IMarathonDomainEditor = interface
    ['{D500DB8C-AC85-49A5-A61A-CD8E7F25E9E1}']
    procedure SaveDomain;
  end;

  IMarathonTriggerEditor = interface
		['{FEFD909E-D463-41BB-8A02-5C42175FDD93}']
    function GetTableName: String;
  end;  

  IMarathonTableEditor = interface
    ['{18CA1C5C-0836-471C-AA7A-B879BACA4770}']
    function IsInterbaseSix: Boolean;
    procedure UpdateTriggers;
  end;

  IMarathonUDFEditor = interface
    ['{59F92583-6467-4BA7-9D37-1A3E1FF0675B}']
    function IsInterbaseSix: Boolean;
    function GetCurrentName: String;
    function UDFParamCount: Integer;
    function ParamText(Index: Integer): String;
    function ReturnType: String;
    function EntryPoint: String;
    function LibraryName: String;
  end;  

  IMarathonBaseForm = interface
    ['{BF14AAD6-1BC3-49F7-A9DA-86620BF1AC18}']
    function GetObjectName: String;
    function GetObjectNewStatus: Boolean;
    function GetActiveConnectionName: String;
    function GetActiveObjectType : TGSSCacheType;
    function GetActiveStatusBar : TStatusBar;
    procedure OpenMessages;
    procedure AddCompileError(ErrorText: String);
    procedure ClearErrors;
    procedure ForceRefresh;
		procedure SetObjectName(Value: String);
    procedure SetObjectModified(Value: Boolean);
  end;

	IMarathonForm = interface(IMarathonBaseForm)
    ['{B0E00049-5517-4EB1-8A69-6FC3717FF035}']

		procedure BringToFront;

    procedure DoInternalClose;
    function CanInternalClose: Boolean;

    function CanObjectAddToProject: Boolean;
    procedure DoObjectAddToProject;

    procedure DoConnect;
    function CanConnect: Boolean;

    function CanDisconnect: Boolean;
    procedure DoDisconnect;

    function CanPrint: Boolean;
    procedure DoPrint;

    function CanPrintPreview: Boolean;
    procedure DoPrintPreview;

    function CanOpenItem: Boolean;
    procedure DoOpenItem;

    function CanNewItem: Boolean;
    procedure DoNewItem;

    function CanDeleteItem: Boolean;
    procedure DoDeleteItem;

    function CanDropItem: Boolean;
    procedure DoDropItem;

    function CanObjectDrop: Boolean;
    procedure DoObjectDrop;

    function CanItemProperties: Boolean;
		procedure DoItemProperties;

    function CanRefresh: Boolean;
		procedure DoRefresh;

    function CanExtractMetadata: Boolean;
    procedure DoExtractMetadata;

    function CanCreateFolder: Boolean;
    procedure DoCreateFolder;

    function CanAddToProject: Boolean;
    procedure DoAddToProject;

    function CanExecute: Boolean;
    procedure DoExecute;

    function CanUndo: Boolean;
    procedure DoUndo;

    function CanRedo: Boolean;
    procedure DoRedo;

    function CanCaptureSnippet: Boolean;
    procedure DoCaptureSnippet;

		function CanCut: Boolean;
		procedure DoCut;

		function CanCopy: Boolean;
		procedure DoCopy;

		function CanPaste: Boolean;
		procedure DoPaste;

		function CanFind: Boolean;
		procedure DoFind;

		function CanFindNext: Boolean;
		procedure DoFindNext;

		function CanSelectAll: Boolean;
		procedure DoSelectAll;

		function CanViewPrevStatement: Boolean;
		procedure DoViewPrevStatement;

		function CanViewNextStatement: Boolean;
		procedure DoViewNextStatement;

		function CanStatementHistory: Boolean;
		procedure DoStatementHistory;

		function CanViewNextPage: Boolean;
		procedure DoViewNextPage;

		function CanViewPrevPage: Boolean;
		procedure DoViewPrevPage;

		function CanTransactionCommit: Boolean;
		procedure DoTransactionCommit;

		function CanTransactionRollback: Boolean;
		procedure DoTransactionRollback;

		function CanCompile: Boolean;
		procedure DoCompile;

		function CanLoad: Boolean;
		procedure DoLoad;

		function CanSave: Boolean;
		procedure DoSave;

		function CanExport: Boolean;
		procedure DoExport;

		function CanLoadFrom: Boolean;
		procedure DoLoadFrom;

		function CanSaveAs: Boolean;
		procedure DoSaveAs;

		function CanViewMessages: Boolean;
		function AreMessagesVisible: Boolean;
		procedure DoViewMessages;

		function CanChangeEncoding: Boolean;
		procedure DoChangeEncoding(Index: Integer);
		function IsEncoding(Index: Integer): Boolean;

		function CanClearBuffer: Boolean;
		procedure DoClearBuffer;

		function CanToolsEditorProperties: Boolean;
		procedure DoToolsEditorProperties;

		function CanReplace: Boolean;
		procedure DoReplace;

		function CanObjectParameters: Boolean;
		procedure DoObjectParameters;

		function CanSaveDoco: Boolean;
		procedure DoSaveDoco;

		function CanSaveAsTemplate: Boolean;
		procedure DoSaveAsTemplate;

		function CanRevoke: Boolean;
		procedure DoRevoke;

		function CanGrant: Boolean;
		procedure DoGrant;

		function CanToggleBookmark(Index: Integer): Boolean;
		procedure DoToggleBookmark(Index: Integer);
		function IsBookmarkSet(Index: Integer): Boolean;

		function CanGotoBookmark(Index: Integer): Boolean;
		procedure DoGotoBookmark(Index: Integer);

		function CanExecuteAsScript: Boolean;
		function IsExecuteAsScript: Boolean;
		procedure DoExecuteAsScript;

		function CanObjectProperties: Boolean;
		procedure DoObjectProperties;

		function CanStepInto: Boolean;
		procedure DoStepInto;

		function CanAddBreakPoint: Boolean;
		procedure DoAddBreakPoint;

		function CanToggleBreakPoint: Boolean;
		procedure DoToggleBreakPoint;

		function CanAddWatchAtCursor: Boolean;
		procedure DoAddWatchAtCursor;

		function CanEvalModify: Boolean;
		procedure DoEvalModify;

		function CanResetValue: Boolean;
		procedure DoResetValue;

		function CanShowQueryPlan: Boolean;
		function IsShowingQueryPlan: Boolean;
		procedure DoShowQueryPlan;

		function CanShowPerformanceData: Boolean;
		function IsShowingPerformanceData: Boolean;
		procedure DoShowPerformanceData;

		function CanObjectOpenSubObject: Boolean;
		procedure DoObjectOpenSubObject;

		function CanObjectNewField: Boolean;
		procedure DoObjectNewField;

    function CanObjectNewTrigger: Boolean;
    procedure DoObjectNewTrigger;

    function CanObjectNewConstraint: Boolean;
		procedure DoObjectNewConstraint;

    function CanObjectNewIndex: Boolean;
    procedure DoObjectNewIndex;

    function CanObjectNewInputParam: Boolean;
    procedure DoObjectNewInputParam;

    function CanObjectDropField: Boolean;
    procedure DoObjectDropField;

    function CanObjectDropTrigger: Boolean;
    procedure DoObjectDropTrigger;

    function CanObjectDropConstraint: Boolean;
    procedure DoObjectDropConstraint;

    function CanObjectDropIndex: Boolean;
    procedure DoObjectDropIndex;

    function CanObjectDropInputParam: Boolean;
    procedure DoObjectDropInputParam;

    function CanObjectReorderColumns: Boolean;
    procedure DoObjectReorderColumns;

    function CanStopScriptRecord: Boolean;
    procedure DoStopScriptRecord;

    function CanStartScriptRecord: Boolean;
    procedure DoStartScriptRecord;

    function CanNewScriptRecord: Boolean;
    procedure DoNewScriptRecord;

    function CanAppendExistingScript: Boolean;
    procedure DoAppendExistingScript;

    function CanDoFolderMode: Boolean;
		function IsFolderMode: Boolean;
    procedure DoFolderMode;

    function CanDoSearchMode: Boolean;
    function IsSearchMode: Boolean;
    procedure DoSearchMode; 

    function CanDoListMode: Boolean;
		function IsListMode: Boolean;
    procedure DoListMode;

    procedure ProjectOptionsRefresh;
    procedure EnvironmentOptionsRefresh;

  end;

implementation

end.


