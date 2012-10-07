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
// $Id: MarathonMain.pas,v 1.21 2007/02/10 22:01:14 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{ Old History
	17.04.2002	CarlosMacao
		* Converted all Toolbar97 components to similar Toolbar2000 ones
	23.03.2002	tmuetze
		* TfrmMarathonMain.LoadOptions, added the creation of the Home registry key and
			some stuff that is needed for the shell extension
		* TfrmMarathonMain.FormCreate, added the ability to directly open the
			project properties from the shell menu
	28.01.2002	tmuetze
		* Added some GetDataType calls in TfrmMarathonMain.LoadOptions to prevent errors if registry
			values are invalid
}

{
$Log: MarathonMain.pas,v $
Revision 1.21  2007/02/10 22:01:14  rjmills
Fixes for Component Library updates

Revision 1.20  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.19  2006/10/19 03:54:59  rjmills
Numerous bug fixes and current work in progress

Revision 1.18  2005/11/16 06:44:50  rjmills
General Options Updates

Revision 1.17  2005/07/12 05:14:31  rjmills
*** empty log message ***

Revision 1.16  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.15  2005/04/13 16:04:29  rjmills
*** empty log message ***

Revision 1.13  2003/12/21 11:06:34  tmuetze
Added Alberts changes to get rid of some tree related AVs

Revision 1.12  2003/12/07 12:20:13  carlosmacao
To allow only one instance of Marathon to run, in desired case.

Revision 1.11  2003/11/19 19:29:54  tmuetze
Changes to be compatible with the rmControls and TBar 2k

Revision 1.10  2003/11/15 15:03:41  tmuetze
Minor changes and some cosmetic ones

Revision 1.9  2002/09/25 12:09:40  tmuetze
Enabled the hints for the Toolbar

Revision 1.8  2002/09/23 10:28:08  tmuetze
Beautified the sourcecode a bit

Revision 1.7  2002/08/28 14:54:03  tmuetze
Used function Tools.AddBackslash instead of adding the backslash manually

Revision 1.6  2002/05/15 08:58:11  tmuetze
Removed some references to TIBGSSDataset

Revision 1.5  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit MarathonMain;

{$I Compilerdefines.inc}

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Menus, ExtCtrls, Registry, DB, ComCtrls, ToolWin, Buttons, StdCtrls, ActnList,
	FileCtrl, CheckLst, ImgList,
	IB_Components,
	IB_Monitor,
	TB2Dock,
	TB2Toolbar,
    TB2Item,
	rmPathTreeView,
	rmTreeNonView,
	rmKeyBindings,
	rmTabs3x,
	rmDataStorage,
	SynEditHighlighter,
	SynHighlighterSQL,
	MarathonInternalInterfaces, rmComboBox, TB2MRU, rmPanel;

type
	TfrmMarathonMain = class(TForm, IMarathonMainForm)
    prnSetup: TPrinterSetupDialog;
    dlgOpen: TSaveDialog;
    ilMarathonImages: TImageList;
    ilErrorInfo: TImageList;
		dckTop: TTBDock;
    tlbrStandard: TTBToolbar;
    tlbrStandardOpenProject: TTBItem;
    tlbrStandardNewProject: TTBItem;
    actMain: TActionList;
    FileNewProject: TAction;
    FileOpenProject: TAction;
    FileCloseProject: TAction;
    FileConnect: TAction;
		FileDisconnect: TAction;
    ToolbarSep1: TTBSeparatorItem;
		FileNewObject: TAction;
    FileCreateDatabase: TAction;
		FilePrintSetup: TAction;
    FileExitApplication: TAction;
    tlbrTools: TTBToolbar;
		btnToolsViewDBManager: TTBItem;
    btnToolsSQLTrace: TTBItem;
    btnToolsCodeSnippets: TTBItem;
    btnToolsMetdataSearch: TTBItem;
		btnToolsSQLEditor: TTBItem;
    tlbrScript: TTBToolbar;
    btnScriptRecordNew: TTBItem;
    btnScriptAppendExisting: TTBItem;
    btnScriptExecute: TTBItem;
    ToolbarSep2: TTBSeparatorItem;
    ViewViewBrowser: TAction;
    ToolsSQLEditor: TAction;
    ProjectProjectOptions: TAction;
    ViewNextWindow: TAction;
    ScriptRecordScript: TAction;
    ScriptStartRecord: TAction;
    ScriptStopRecord: TAction;
    ToolsMetaExtract: TAction;
    ToolsMetaSearch: TAction;
    ToolsSyntaxHelp: TAction;
    ToolsSQLCodeSnippets: TAction;
    ToolsSQLTrace: TAction;
		ToolsMarathonOptions: TAction;
    WindowWindowList: TAction;
    HelpHelpTopics: TAction;
    HelpMarathonOnTheWeb: TAction;
    HelpEmailSupport: TAction;
    HelpAbout: TAction;
    imgMenuTools: TImageList;
    dlgOpenProject: TOpenDialog;
    FileSaveProject: TAction;
		FileSaveProjectAs: TAction;
		dlgSaveProject: TSaveDialog;
    btnPrint: TTBItem;
		btnPrintPreview: TTBItem;
    FilePrint: TAction;
    FilePrintPreview: TAction;
		tlbrSQLEditor: TTBToolbar;
    btnExecute: TTBItem;
    btnCompile: TTBItem;
    btnCommit: TTBItem;
		btnRollback: TTBItem;
    ToolbarSep6: TTBSeparatorItem;
    btnUndo: TTBItem;
    btnRedo: TTBItem;
    ToolbarSep7: TTBSeparatorItem;
    btnCaptureSnippet: TTBItem;
    ToolbarSep8: TTBSeparatorItem;
    btnCut: TTBItem;
    btnCopy: TTBItem;
    btnPaste: TTBItem;
    ToolbarSep9: TTBSeparatorItem;
    btnFind: TTBItem;
    ToolbarSep10: TTBSeparatorItem;
    btnDrop: TTBItem;
    ToolbarSep4: TTBSeparatorItem;
    EditUndo: TAction;
    EditRedo: TAction;
    EditCaptureSnippet: TAction;
		EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditFind: TAction;
    ObjectCompile: TAction;
    ObjectExecute: TAction;
    TransactionCommit: TAction;
    TransactionRollback: TAction;
		ToolsEditorProperties: TAction;
    EditSelectAll: TAction;
		EditFindNext: TAction;
		EditReplace: TAction;
    ToolsUserEditor: TAction;
    WindowCloseAllWindows: TAction;
    ViewToolbarTools: TAction;
		ViewToolbarScript: TAction;
    ViewToolbarStandard: TAction;
    ViewToolbarSQLEditor: TAction;
		mnuTools: TPopupMenu;
    Standard2: TMenuItem;
		Tools4: TMenuItem;
		Script2: TMenuItem;
    SQLEditor3: TMenuItem;
		ToolsQueryBuilder: TAction;
    btnStatementHistory: TTBItem;
    stsMain: TStatusBar;
    btnNextStatement: TTBItem;
		btnPrevStatement: TTBItem;
    btnQueryBuilder: TTBItem;
    ViewPrevStatement: TAction;
    ViewNextStatement: TAction;
    ViewStatementHistory: TAction;
    actMRU: TActionList;
    FileOpenFile: TAction;
    FileOpenDatabaseObject: TAction;
    FileClose: TAction;
    ProjectNewConnection: TAction;
    ProjectOpenItem: TAction;
    ProjectItemProperties: TAction;
    ProjectItemDelete: TAction;
    ProjectItemDrop: TAction;
    ViewRefresh: TAction;
    ProjectExtractMetadata: TAction;
    ProjectCreateFolder: TAction;
    ProjectAddToProject: TAction;
    EditEncANSI: TAction;
    EditEncDefault: TAction;
    EditEncSymbol: TAction;
    EncMacintosh: TAction;
    EditEncSHIFTJIS: TAction;
    EditEncHANGEUL: TAction;
    EditEncJOHAB: TAction;
    EditEncGB2312: TAction;
    EditEncCHINESEBIG5: TAction;
    EditEncGreek: TAction;
    EditEncTurkish: TAction;
    EditEncVietnamese: TAction;
		EditEncHebrew: TAction;
    EditEncArabic: TAction;
    EditEncBaltic: TAction;
    EditEncRussian: TAction;
    EditEncThai: TAction;
    EditEncEasternEuropean: TAction;
    EditEncOEM: TAction;
    ViewNextPage: TAction;
    ViewPrevPage: TAction;
    ViewMessages: TAction;
    EditClearEditBuffer: TAction;
		EditToggleBookmark1: TAction;
    EditToggleBookmark2: TAction;
    EditToggleBookmark0: TAction;
    EditToggleBookmark3: TAction;
		EditToggleBookmark4: TAction;
    EditToggleBookmark5: TAction;
    EditToggleBookmark6: TAction;
    EditToggleBookmark7: TAction;
    EditToggleBookmark8: TAction;
    EditToggleBookmark9: TAction;
    EditGotoBookmark0: TAction;
    EditGotoBookmark1: TAction;
    EditGotoBookmark2: TAction;
    EditGotoBookmark3: TAction;
    EditGotoBookmark4: TAction;
    EditGotoBookmark5: TAction;
    EditGotoBookmark6: TAction;
    EditGotoBookmark7: TAction;
    EditGotoBookmark8: TAction;
    EditGotoBookmark9: TAction;
    FileSave: TAction;
    FileSaveAs: TAction;
    ObjectShowQueryPlan: TAction;
    ObjectShowPerformanceData: TAction;
    ToolbarSep3: TTBSeparatorItem;
    cmbConnections: TrmComboBox;
    FileExport: TAction;
    ObjectParameters: TAction;
    ObjectSaveDocumentation: TAction;
    ObjectSaveAsTemplate: TAction;
    ObjectRevoke: TAction;
    ObjectGrant: TAction;
		ProjectNewItem: TAction;
    ObjectDrop: TAction;
		ObjectAddToProject: TAction;
    ToolsPlugins: TAction;
    ObjectExecuteAsScript: TAction;
		ObjectProperties: TAction;
    ObjectDebuggerEnabled: TAction;
    ObjectNewField: TAction;
    ObjectNewConstraint: TAction;
    ObjectNewIndex: TAction;
    ObjectNewTrigger: TAction;
    ObjectNewInputParam: TAction;
    ObjectDropField: TAction;
    ObjectDropTrigger: TAction;
    ObjectDropIndex: TAction;
    ObjectDropConstraint: TAction;
		ObjectDropInputParam: TAction;
		ObjectReorderColumns: TAction;
    ObjectResetGeneratorValue: TAction;
		ObjectStepOver: TAction;
    ObjectStepInto: TAction;
    ObjectShowExecutionPoint: TAction;
    ObjectPause: TAction;
		ObjectReset: TAction;
    ObjectEvalModify: TAction;
    ObjectAddWatch: TAction;
    ObjectAddWatchAtCursor: TAction;
    ObjectAddBreakPoint: TAction;
    ObjectToggleBreakPoint: TAction;
    ViewBreakPoints: TAction;
    ViewCallStack: TAction;
		ViewWatches: TAction;
    ViewLocalVariables: TAction;
    ProjectNewServer: TAction;
    ScriptNewScript: TAction;
		ScriptAppendExisting: TAction;
		ViewFolders: TAction;
    ViewSearch: TAction;
		kbgKeys: TrmKeyBindings;
    ObjectOpenSubObject: TAction;
    ViewList: TAction;
    FileLoad: TAction;
    FileLoadFrom: TAction;
    TBControlItem: TTBControlItem;
    TBToolbar1: TTBToolbar;
    File1: TTBSubmenuItem;
    New1: TTBItem;
    Open1: TTBItem;
    ReOpen1: TTBItem;
    Close1: TTBItem;
    SaveProject1: TTBItem;
    SaveProjectAs1: TTBItem;
    N20: TTBSeparatorItem;
    New2: TTBItem;
    Open2: TTBSubmenuItem;
    FileOpenFile1: TTBItem;
    FileOpenDatabaseObject1: TTBItem;
    FileSave1: TTBItem;
    FileSaveAs1: TTBItem;
    Close2: TTBItem;
    N28: TTBSeparatorItem;
    F1: TTBItem;
    N10: TTBSeparatorItem;
    CreateDatabase1: TTBItem;
    N3: TTBSeparatorItem;
    Connect1: TTBItem;
    Disconnect1: TTBItem;
    N1: TTBSeparatorItem;
    PrintSetup1: TTBItem;
    Print1: TTBItem;
    PrintPreview1: TTBItem;
    N2: TTBSeparatorItem;
    Exit1: TTBItem;
    Edit1: TTBSubmenuItem;
    Undo1: TTBItem;
    actRedo1: TTBItem;
    N4: TTBSeparatorItem;
    Cut1: TTBItem;
    Copy1: TTBItem;
    Paste1: TTBItem;
    SelectAll1: TTBItem;
    N34: TTBSeparatorItem;
    CaptureSnippet1: TTBItem;
    N18: TTBSeparatorItem;
    ToggleBookmark1: TTBSubmenuItem;
    EditToggleBookmark01: TTBItem;
    EditToggleBookmark11: TTBItem;
    EditGotoBookmark21: TTBItem;
    EditToggleBookmark31: TTBItem;
    EditToggleBookmark41: TTBItem;
    EditToggleBookmark51: TTBItem;
    EditToggleBookmark61: TTBItem;
    EditToggleBookmark71: TTBItem;
    EditToggleBookmark81: TTBItem;
    EditToggleBookmark91: TTBItem;
    GotoBookmark1: TTBSubmenuItem;
    EditGotoBookmark01: TTBItem;
    EditGotoBookmark11: TTBItem;
    EditGotoBookmark22: TTBItem;
    EditGotoBookmark31: TTBItem;
    EditGotoBookmark41: TTBItem;
    EditGotoBookmark51: TTBItem;
    EditGotoBookmark61: TTBItem;
    EditGotoBookmark71: TTBItem;
    EditGotoBookmark81: TTBItem;
    EditGotoBookmark91: TTBItem;
    N27: TTBSeparatorItem;
    Encoding1: TTBSubmenuItem;
    ANSI1: TTBItem;
    Arabic1: TTBItem;
    Symbol1: TTBItem;
    Macintosh1: TTBItem;
    Japanese1: TTBItem;
    KoreanWansung1: TTBItem;
    KoreanJohab1: TTBItem;
    ChineseSimplified1: TTBItem;
    ChineseTraditional1: TTBItem;
    Greek1: TTBItem;
    Turkish1: TTBItem;
    Vietnamese1: TTBItem;
    Hebrew1: TTBItem;
    Arabic2: TTBItem;
    Baltic1: TTBItem;
    Russian1: TTBItem;
    Thai1: TTBItem;
    EasternEuropean1: TTBItem;
    OEM1: TTBItem;
    N5: TTBSeparatorItem;
    Find1: TTBItem;
    FindNext1: TTBItem;
    Replace1: TTBItem;
    View1: TTBSubmenuItem;
    DatabaseManager1: TTBItem;
    ViewDebuggerHeader1: TTBSubmenuItem;
    ViewBreakPoints1: TTBItem;
    ViewCallStack1: TTBItem;
    ViewWatches1: TTBItem;
    ViewLocalVariables1: TTBItem;
    N19: TTBSeparatorItem;
    Tools2: TTBSubmenuItem;
    Standard1: TTBItem;
    Tools3: TTBItem;
    Scipt1: TTBItem;
    SQLEditor2: TTBItem;
    N6: TTBSeparatorItem;
    actPrevStatement1: TTBItem;
    actNextStatement1: TTBItem;
    actStatementHistory1: TTBItem;
    N17: TTBSeparatorItem;
    Folders1: TTBItem;
    Search1: TTBItem;
    List1: TTBItem;
    N12: TTBSeparatorItem;
    ViewRefresh1: TTBItem;
    N23: TTBSeparatorItem;
    ViewPrevPage1: TTBItem;
    ViewNextPage1: TTBItem;
    N33: TTBSeparatorItem;
    ObjectViewMessages1: TTBItem;
    N26: TTBSeparatorItem;
    NextWindow1: TTBItem;
    Browser1: TTBSubmenuItem;
    ProjectNewItem1: TTBItem;
    ProjectOpenItem1: TTBItem;
    ProjectExtractMetadata1: TTBItem;
    ProjectAddToProject1: TTBItem;
    ProjectCreateFolder1: TTBItem;
    N24: TTBSeparatorItem;
    ProjectItemDrop1: TTBItem;
    ProjectItemDelete1: TTBItem;
    N25: TTBSeparatorItem;
    ProjectItemProperties1: TTBItem;
    N22: TTBSeparatorItem;
    NewConnection1: TTBItem;
    NewServer1: TTBItem;
    N21: TTBSeparatorItem;
    ProjectOptions2: TTBItem;
    Transaction1: TTBSubmenuItem;
    Commit1: TTBItem;
    Rollback1: TTBItem;
    Object1: TTBSubmenuItem;
    Compile1: TTBItem;
    Execute1: TTBItem;
    ObjectParameters1: TTBItem;
    ScriptMode1: TTBItem;
    N31: TTBSeparatorItem;
    ObjectStepOver1: TTBItem;
    ObjectStepInto1: TTBItem;
    ObjectShowExecutionPoint1: TTBItem;
    ObjectPause1: TTBItem;
    ObjectReset1: TTBItem;
    ObjectDebuggerHeader1: TTBSubmenuItem;
    ObjectEvalModify1: TTBItem;
    ObjectAddWatch1: TTBItem;
    ObjectAddBreakPoint1: TTBItem;
    N29: TTBSeparatorItem;
    New3: TTBSubmenuItem;
    ObjectNewField1: TTBItem;
    ObjectNewConstraint1: TTBItem;
    ObjectNewIndex1: TTBItem;
    ObjectNewTrigger1: TTBItem;
    ObjectNewInputParam1: TTBItem;
    DropObject1: TTBSubmenuItem;
    ObjectDropField1: TTBItem;
    ObjectDropConstraint1: TTBItem;
    ObjectDropIndex1: TTBItem;
    ObjectDropTrigger1: TTBItem;
    ObjectDropInputParam1: TTBItem;
    Drop1: TTBItem;
    Properties1: TTBItem;
    N30: TTBSeparatorItem;
    Tools5: TTBSubmenuItem;
    ObjectShowPerformanceData1: TTBItem;
    ObjectShowQueryPlan1: TTBItem;
    N36: TTBSeparatorItem;
    ObjectReorderColumns1: TTBItem;
    ObjectResetGeneratorValue1: TTBItem;
    Permissions1: TTBSubmenuItem;
    ObjectGrant1: TTBItem;
    ObjectRevoke1: TTBItem;
    N32: TTBSeparatorItem;
    AddToProject1: TTBItem;
    ObjectSaveDocumentation1: TTBItem;
    ObjectSaveAsTemplate1: TTBItem;
    Script1: TTBSubmenuItem;
    RecordNewScript1: TTBItem;
    N37: TTBSeparatorItem;
    AppendtoExistingScript1: TTBItem;
    NewScript1: TTBItem;
    N14: TTBSeparatorItem;
    Record1: TTBItem;
    Stop1: TTBItem;
    Tools1: TTBSubmenuItem;
    SQLEditor1: TTBItem;
    UserEditor1: TTBItem;
    N16: TTBSeparatorItem;
    MetadataExtract1: TTBItem;
    SearchMetadata1: TTBItem;
    N13: TTBSeparatorItem;
    SyntaxHelp1: TTBItem;
    SQLCodeSnippets1: TTBItem;
    N15: TTBSeparatorItem;
    SQLTrace1: TTBItem;
    N7: TTBSeparatorItem;
    Plugins1: TTBItem;
    N35: TTBSeparatorItem;
    DebuggerEnabled1: TTBItem;
    Options1: TTBItem;
    Window1: TTBSubmenuItem;
    WindowList2: TTBItem;
    CloseAllWindows1: TTBItem;
    N9: TTBSeparatorItem;
    Help1: TTBSubmenuItem;
    HelpTopics1: TTBItem;
    N11: TTBSeparatorItem;
    MarathonOntheWeb1: TTBItem;
    EmailMarathonSupport1: TTBItem;
    N8: TTBSeparatorItem;
    About1: TTBItem;
    TBMRUListItem1: TTBMRUListItem;
    TBMRUList1: TTBMRUList;
    rmPanel1: TrmPanel;
    tabWindows: TrmTabSet;
    Bevel1: TBevel;
		procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Window1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FileNewProjectExecute(Sender: TObject);
    procedure FileOpenProjectExecute(Sender: TObject);
    procedure FileCloseProjectExecute(Sender: TObject);
    procedure FileConnectExecute(Sender: TObject);
    procedure FileCreateDatabaseExecute(Sender: TObject);
    procedure FilePrintSetupExecute(Sender: TObject);
    procedure FileExitApplicationExecute(Sender: TObject);
    procedure ViewViewBrowserExecute(Sender: TObject);
    procedure ToolsSQLEditorExecute(Sender: TObject);
    procedure ProjectProjectOptionsExecute(Sender: TObject);
    procedure ViewNextWindowExecute(Sender: TObject);
    procedure ToolsMetaExtractExecute(Sender: TObject);
    procedure ToolsMetaSearchExecute(Sender: TObject);
    procedure ToolsSQLCodeSnippetsExecute(Sender: TObject);
		procedure ToolsSQLTraceExecute(Sender: TObject);
    procedure ToolsMarathonOptionsExecute(Sender: TObject);
    procedure ToolsSyntaxHelpExecute(Sender: TObject);
    procedure WindowWindowListExecute(Sender: TObject);
    procedure dckTopResize(Sender: TObject);
    procedure FileSaveProjectExecute(Sender: TObject);
    procedure FileSaveProjectAsExecute(Sender: TObject);
		procedure FileCloseProjectUpdate(Sender: TObject);
    procedure FileConnectUpdate(Sender: TObject);
		procedure ProjectProjectOptionsUpdate(Sender: TObject);
		procedure FileSaveProjectUpdate(Sender: TObject);
    procedure FileSaveProjectAsUpdate(Sender: TObject);
		procedure ToolsEditorPropertiesExecute(Sender: TObject);
		procedure ToolsUserEditorExecute(Sender: TObject);
		procedure WindowCloseAllWindowsExecute(Sender: TObject);
		procedure ViewToolbarToolsExecute(Sender: TObject);
		procedure ViewToolbarScriptExecute(Sender: TObject);
		procedure ViewToolbarStandardExecute(Sender: TObject);
		procedure ViewToolbarSQLEditorExecute(Sender: TObject);
		procedure ViewToolbarToolsUpdate(Sender: TObject);
		procedure ViewToolbarScriptUpdate(Sender: TObject);
		procedure ViewToolbarStandardUpdate(Sender: TObject);
		procedure ViewToolbarSQLEditorUpdate(Sender: TObject);
		procedure ProjectNewConnectionExecute(Sender: TObject);
		procedure FileDisconnectUpdate(Sender: TObject);
		procedure FileDisconnectExecute(Sender: TObject);
		procedure FileCloseExecute(Sender: TObject);
		procedure FileCloseUpdate(Sender: TObject);
		procedure FileNewObjectExecute(Sender: TObject);
		procedure FilePrintExecute(Sender: TObject);
		procedure FilePrintUpdate(Sender: TObject);
		procedure FilePrintPreviewExecute(Sender: TObject);
		procedure FilePrintPreviewUpdate(Sender: TObject);
		procedure FileOpenFileExecute(Sender: TObject);
		procedure FileOpenDatabaseObjectExecute(Sender: TObject);
		procedure FileOpenDatabaseObjectUpdate(Sender: TObject);
		procedure ProjectNewConnectionUpdate(Sender: TObject);
		procedure tabWindowsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure ProjectOpenItemUpdate(Sender: TObject);
		procedure ProjectItemPropertiesUpdate(Sender: TObject);
		procedure ProjectItemDeleteUpdate(Sender: TObject);
		procedure ProjectItemDropUpdate(Sender: TObject);
		procedure ProjectOpenItemExecute(Sender: TObject);
		procedure ProjectItemDropExecute(Sender: TObject);
		procedure ProjectItemPropertiesExecute(Sender: TObject);
		procedure ProjectItemDeleteExecute(Sender: TObject);
		procedure ViewRefreshUpdate(Sender: TObject);
		procedure ViewRefreshExecute(Sender: TObject);
		procedure ProjectExtractMetadataExecute(Sender: TObject);
    procedure ProjectExtractMetadataUpdate(Sender: TObject);
		procedure ProjectCreateFolderExecute(Sender: TObject);
    procedure ProjectCreateFolderUpdate(Sender: TObject);
    procedure ProjectAddToProjectExecute(Sender: TObject);
    procedure ProjectAddToProjectUpdate(Sender: TObject);
    procedure ObjectExecuteUpdate(Sender: TObject);
    procedure ObjectExecuteExecute(Sender: TObject);
		procedure EditUndoExecute(Sender: TObject);
    procedure EditUndoUpdate(Sender: TObject);
    procedure EditRedoExecute(Sender: TObject);
    procedure EditRedoUpdate(Sender: TObject);
		procedure EditCaptureSnippetExecute(Sender: TObject);
    procedure EditCaptureSnippetUpdate(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure EditCutUpdate(Sender: TObject);
    procedure EditCopyExecute(Sender: TObject);
    procedure EditCopyUpdate(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure EditPasteUpdate(Sender: TObject);
    procedure EditFindExecute(Sender: TObject);
    procedure EditFindUpdate(Sender: TObject);
    procedure EditSelectAllExecute(Sender: TObject);
    procedure EditSelectAllUpdate(Sender: TObject);
    procedure EditFindNextExecute(Sender: TObject);
    procedure EditFindNextUpdate(Sender: TObject);
    procedure ViewPrevStatementExecute(Sender: TObject);
		procedure ViewPrevStatementUpdate(Sender: TObject);
    procedure ViewNextStatementExecute(Sender: TObject);
    procedure ViewNextStatementUpdate(Sender: TObject);
		procedure ViewStatementHistoryExecute(Sender: TObject);
    procedure ViewStatementHistoryUpdate(Sender: TObject);
    procedure ViewNextPageExecute(Sender: TObject);
    procedure ViewNextPageUpdate(Sender: TObject);
    procedure ViewPrevPageExecute(Sender: TObject);
    procedure ViewPrevPageUpdate(Sender: TObject);
		procedure TransactionCommitExecute(Sender: TObject);
    procedure TransactionCommitUpdate(Sender: TObject);
		procedure TransactionRollbackExecute(Sender: TObject);
		procedure TransactionRollbackUpdate(Sender: TObject);
    procedure ObjectCompileExecute(Sender: TObject);
		procedure ObjectCompileUpdate(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure FileSaveUpdate(Sender: TObject);
    procedure FileSaveAsExecute(Sender: TObject);
    procedure FileSaveAsUpdate(Sender: TObject);
    procedure ViewMessagesExecute(Sender: TObject);
		procedure ViewMessagesUpdate(Sender: TObject);
    procedure EditEncANSIExecute(Sender: TObject);
    procedure EditEncANSIUpdate(Sender: TObject);
    procedure EditClearEditBufferExecute(Sender: TObject);
		procedure EditClearEditBufferUpdate(Sender: TObject);
    procedure EditToggleBookmark1Execute(Sender: TObject);
    procedure EditToggleBookmark1Update(Sender: TObject);
    procedure EditGotoBookmark0Execute(Sender: TObject);
    procedure EditGotoBookmark0Update(Sender: TObject);
    procedure ObjectShowQueryPlanExecute(Sender: TObject);
    procedure ObjectShowQueryPlanUpdate(Sender: TObject);
    procedure ObjectShowPerformanceDataExecute(Sender: TObject);
    procedure ObjectShowPerformanceDataUpdate(Sender: TObject);
    procedure cmbConnectionsDropDown(Sender: TObject);
    procedure cmbConnectionsCloseUp(Sender: TObject);
    procedure cmbConnectionsChange(Sender: TObject);
    procedure FileExportExecute(Sender: TObject);
    procedure FileExportUpdate(Sender: TObject);
    procedure ProjectNewItemExecute(Sender: TObject);
		procedure ProjectNewItemUpdate(Sender: TObject);
    procedure ObjectDropExecute(Sender: TObject);
    procedure ObjectDropUpdate(Sender: TObject);
		procedure ObjectAddToProjectExecute(Sender: TObject);
    procedure ObjectAddToProjectUpdate(Sender: TObject);
    procedure ToolsEditorPropertiesUpdate(Sender: TObject);
    procedure EditReplaceUpdate(Sender: TObject);
    procedure EditReplaceExecute(Sender: TObject);
    procedure ObjectParametersExecute(Sender: TObject);
		procedure ObjectParametersUpdate(Sender: TObject);
    procedure ObjectSaveDocumentationExecute(Sender: TObject);
    procedure ObjectSaveDocumentationUpdate(Sender: TObject);
		procedure ObjectSaveAsTemplateExecute(Sender: TObject);
    procedure ObjectSaveAsTemplateUpdate(Sender: TObject);
    procedure ObjectRevokeExecute(Sender: TObject);
    procedure ObjectRevokeUpdate(Sender: TObject);
    procedure ObjectGrantExecute(Sender: TObject);
    procedure ObjectGrantUpdate(Sender: TObject);
    procedure FileNewObjectUpdate(Sender: TObject);
    procedure ToolsPluginsExecute(Sender: TObject);
		procedure ObjectExecuteAsScriptUpdate(Sender: TObject);
    procedure ObjectExecuteAsScriptExecute(Sender: TObject);
    procedure ObjectPropertiesExecute(Sender: TObject);
    procedure ObjectPropertiesUpdate(Sender: TObject);
		procedure ObjectDebuggerEnabledExecute(Sender: TObject);
    procedure ObjectDebuggerEnabledUpdate(Sender: TObject);
    procedure ObjectStepIntoExecute(Sender: TObject);
    procedure ObjectStepIntoUpdate(Sender: TObject);
    procedure ObjectAddBreakPointExecute(Sender: TObject);
    procedure ObjectAddBreakPointUpdate(Sender: TObject);
    procedure ObjectToggleBreakPointExecute(Sender: TObject);
    procedure ObjectToggleBreakPointUpdate(Sender: TObject);
    procedure ObjectEvalModifyExecute(Sender: TObject);
    procedure ObjectEvalModifyUpdate(Sender: TObject);
    procedure ObjectResetGeneratorValueExecute(Sender: TObject);
    procedure ObjectResetGeneratorValueUpdate(Sender: TObject);
    procedure ProjectNewServerExecute(Sender: TObject);
    procedure ProjectNewServerUpdate(Sender: TObject);
		procedure ObjectNewFieldUpdate(Sender: TObject);
    procedure ObjectNewFieldExecute(Sender: TObject);
    procedure ObjectNewTriggerExecute(Sender: TObject);
    procedure ObjectNewTriggerUpdate(Sender: TObject);
		procedure ObjectDropFieldExecute(Sender: TObject);
    procedure ObjectDropFieldUpdate(Sender: TObject);
    procedure ObjectDropTriggerExecute(Sender: TObject);
    procedure ObjectDropTriggerUpdate(Sender: TObject);
    procedure ObjectDropConstraintExecute(Sender: TObject);
		procedure ObjectDropConstraintUpdate(Sender: TObject);
    procedure ObjectDropIndexExecute(Sender: TObject);
    procedure ObjectDropIndexUpdate(Sender: TObject);
		procedure ObjectReorderColumnsExecute(Sender: TObject);
    procedure ObjectReorderColumnsUpdate(Sender: TObject);
    procedure ObjectNewConstraintExecute(Sender: TObject);
    procedure ObjectNewConstraintUpdate(Sender: TObject);
    procedure ObjectNewIndexExecute(Sender: TObject);
    procedure ObjectNewIndexUpdate(Sender: TObject);
		procedure ObjectNewInputParamExecute(Sender: TObject);
    procedure ObjectNewInputParamUpdate(Sender: TObject);
    procedure ObjectDropInputParamExecute(Sender: TObject);
		procedure ObjectDropInputParamUpdate(Sender: TObject);
    procedure ScriptRecordScriptUpdate(Sender: TObject);
    procedure ScriptRecordScriptExecute(Sender: TObject);
    procedure ScriptStopRecordExecute(Sender: TObject);
		procedure ScriptStopRecordUpdate(Sender: TObject);
    procedure ScriptStartRecordExecute(Sender: TObject);
    procedure ScriptStartRecordUpdate(Sender: TObject);
    procedure ScriptNewScriptExecute(Sender: TObject);
    procedure ScriptNewScriptUpdate(Sender: TObject);
    procedure ScriptAppendExistingExecute(Sender: TObject);
    procedure ScriptAppendExistingUpdate(Sender: TObject);
    procedure ViewFoldersExecute(Sender: TObject);
    procedure ViewFoldersUpdate(Sender: TObject);
    procedure ViewSearchExecute(Sender: TObject);
    procedure ViewSearchUpdate(Sender: TObject);
    procedure ObjectOpenSubObjectExecute(Sender: TObject);
    procedure ObjectOpenSubObjectUpdate(Sender: TObject);
    procedure ViewListExecute(Sender: TObject);
		procedure ViewListUpdate(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure ViewBreakPointsUpdate(Sender: TObject);
    procedure ViewBreakPointsExecute(Sender: TObject);
		procedure ViewWatchesExecute(Sender: TObject);
    procedure ViewWatchesUpdate(Sender: TObject);
    procedure ViewCallStackExecute(Sender: TObject);
    procedure ViewCallStackUpdate(Sender: TObject);
    procedure ViewLocalVariablesExecute(Sender: TObject);
		procedure ViewLocalVariablesUpdate(Sender: TObject);
    procedure ObjectAddWatchAtCursorExecute(Sender: TObject);
    procedure ObjectAddWatchAtCursorUpdate(Sender: TObject);
		procedure ObjectAddWatchExecute(Sender: TObject);
		procedure ObjectAddWatchUpdate(Sender: TObject);
		procedure ObjectShowExecutionPointUpdate(Sender: TObject);
		procedure ObjectShowExecutionPointExecute(Sender: TObject);
		procedure HelpMarathonOnTheWebExecute(Sender: TObject);
		procedure HelpHelpTopicsExecute(Sender: TObject);
		procedure HelpEmailSupportExecute(Sender: TObject);
    procedure FileLoadExecute(Sender: TObject);
    procedure FileLoadUpdate(Sender: TObject);
    procedure FileLoadFromExecute(Sender: TObject);
    procedure FileLoadFromUpdate(Sender: TObject);
	private
		{ Private declarations }
		FDroppedDown: Boolean;
		FInternalHeight: Integer;
		FForceClose: Boolean;
		procedure MinMaxInfo(var Message: TMessage); message WM_GETMINMAXINFO;
		procedure QueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
		procedure EndSession(var Message: TMessage); message WM_ENDSESSION;
		function AppHelp(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;
		procedure ExecuteMRU(Sender: TObject);
		procedure IdleHandler(Sender: TObject; var Done: Boolean);
    function MenuItem(Index: Integer): TMenuItem;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
	public
		{ Public declarations }
		// IMarathonMainForm
		function MenuCount: Integer;
		function MenuItemAction(Index: Integer): TBasicAction;
		procedure SetCaption(Value: String);
		function GetCaption: String;
		function GetFormTop: Integer;
		function GetFormHeight: Integer;
		procedure AddMenuItem(MenuAction: TBasicAction);
		procedure LoadMRUMenu;
		procedure LoadWindowList;
		procedure DoStatus(Status: String);
    function MainFormMonitor:TMonitor;
		procedure LoadOptions;
	end;

var
	frmMarathonMain: TfrmMarathonMain;

implementation

uses
	Globals,
	Tools,
	SyntaxHelp,
	CodeSnippets,
	TipOfTheDay,
	MenuModule,
	HelpMap,
	WindowLists,
	BaseDocumentForm,
	MarathonProjectCache,
	MarathonProjectCacheTypes,
	MarathonIDE,
	GSSRegistry;

{$R *.DFM}
{$R MarathonAVI.RES}
{$R MarathonButtons.RES}
{$R Toolmenus.RES}

function TfrmMarathonMain.AppHelp(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;
begin
	CallHelp := True;
	Result := True;
end;

procedure TfrmMarathonMain.MinMaxInfo(var Message: TMessage);
var
	Diff: Integer;
begin
	// Adjust for large fonts menu bar height
	Diff := GetSystemMetrics(SM_CYSIZEFRAME) * 2;
	Diff := Diff + GetSystemMetrics(SM_CYCAPTION);
//	Diff := Diff + GetSystemMetrics(SM_CYMENU);

	TMinMaxInfo(Pointer(Message.lParam)^).ptMaxSize.x := Monitor.Width + (GetSystemMetrics(SM_CYSIZEFRAME) * 2);
	TMinMaxInfo(Pointer(Message.lParam)^).ptMaxSize.y := FInternalHeight + Diff;

	TMinMaxInfo(Pointer(Message.lParam)^).ptMinTrackSize.x := 580;
	TMinMaxInfo(Pointer(Message.lParam)^).ptMinTrackSize.y := FInternalHeight + Diff;

	TMinMaxInfo(Pointer(Message.lParam)^).ptMaxTrackSize.x := Monitor.Width + (GetSystemMetrics(SM_CYSIZEFRAME) * 2);
	TMinMaxInfo(Pointer(Message.lParam)^).ptMaxTrackSize.y := FInternalHeight + Diff;
end;

procedure TfrmMarathonMain.FormCreate(Sender: TObject);
var
	F: TfrmTipOfTheDay;
	Idx: Integer;
	B: TBitmap;
begin
	Application.CreateForm(TdmMenus, dmMenus);
	Application.OnIdle := IdleHandler;
	MarathonIDEInstance.MainForm := Self;

	WindowWindowList.ShortCut := ShortCut(Ord('0'), [ssAlt]);

  LoadFormPosition(self);

	// KeyBindings Class Error with latest rmControls
	// ToDo
	if FileExists(ExtractFilePath(Application.ExeName) + 'keybind.dat') then
     kbgKeys.LoadBindingsFromFile(ExtractFilePath(Application.ExeName) + 'keybind.dat', False);

	ForceDirectories(ExtractFilePath(Application.ExeName) + 'Projects\');

	// Load the tree images from the resources
  B := TBitmap.Create;
  try
		B.LoadFromResourceName(hInstance, 'TREE_IMAGES_STRIP');
    ilMarathonImages.Clear;
		ilMarathonImages.AddMasked(B, B.TransparentColor);
    ilMarathonImages.Overlay(13,0); //First overlay imageindex = 0  // Connected
    ilMarathonImages.Overlay(14,1); //Second overlay imageindex = 1 // Inactive/Warning

		B.LoadFromResourceName(hInstance, 'ERROR_INFO_STRIP');
    ilErrorInfo.Clear;
    ilErrorInfo.AddMasked(B, B.TransparentColor);

		B.LoadFromResourceName(hInstance, 'TOOL_BAR_STRIP');
    imgMenuTools.Clear;
		imgMenuTools.AddMasked(B, B.TransparentColor);
	finally
		B.Free;
	end;

  TBRegLoadPositions(Self, HKEY_CURRENT_USER, REG_SETTINGS_TOOLBARS);
	dckTopResize(dckTop);

	Caption := 'Marathon';

	HelpContext := IDH_Contents;
	DoStatus('Ready');
	gAppPath := ExtractFilePath(Application.ExeName);
	Application.OnHelp := AppHelp;
	Application.HelpFile := gAppPath + 'help\marathon.hlp';

	LoadOptions;

	Show;
	Refresh;

	MarathonIDEInstance.InitPlugins;

	for Idx := 0 to actMain.ActionCount - 1 do
		actMain.Actions[Idx].Update;

	if gShowTips then
	begin
		F := TfrmTipOfTheDay.Create(Self);
		try
			F.ShowModal;
		finally
			F.Free;
		end;
	end;

	// Load the MRU Menu
	LoadMRUMenu;

	MarathonIDEInstance.ViewViewBrowser;

	if (ParamStr(1) <> '') then
	begin
		try
			MarathonIDEInstance.OpenProject(ParamStr(1));
			for Idx := 2 to ParamCount do
				if LowerCase(ParamStr(Idx)) = '/p' then
					ProjectProjectOptions.Execute;
		except
			on E: Exception do
				Exit;
		end;
	end
	else
	begin
		if gOpenLastProject then
		begin
			if gLastProject <> '' then
				try
					MarathonIDEInstance.OpenProject(gLastProject);
				except
					on E: Exception do
						Exit;
				end;
		end
		else
			if gOpenProjectOnStartup then
				MarathonIDEInstance.FileOpenProject;
	end;
end;

procedure TfrmMarathonMain.FormClose(Sender: TObject;	var Action: TCloseAction);
var
	Idx: Integer;
	Browser: IMarathonBrowser;

begin
	Browser := MarathonIDEInstance.GetBrowser;
	if Assigned(Browser) then
		Browser.SavePositions;

	for Idx := ReOpen1.Count - 1 downto 0 do
		ReOpen1.Items[Idx].Free;

	TBRegSavePositions(Self, HKEY_CURRENT_USER, REG_SETTINGS_TOOLBARS);
  SaveFormPosition(self);
	MarathonIDEInstance.MainForm := nil;
	MarathonIDEInstance.UnloadPlugins;
  Refresh;  //AC:
end;

procedure TfrmMarathonMain.LoadOptions;
var
	I: TRegistry;

begin
	dmMenus.synHighlighter.LoadFromRegistry(HKEY_CURRENT_USER, REG_SETTINGS_HIGHLIGHTING);
	I := TRegistry.Create;
	try
		// Create registry entries for the shell extension
		I.RootKey := HKEY_CLASSES_ROOT;
		I.OpenKey('.xmpr', True);
		I.WriteString('', 'XMPRFile');
		I.CloseKey;
		I.OpenKey('XMPRFile', True);
		I.WriteString('', 'Marathon project');
		I.CloseKey;
		I.OpenKey('XMPRFile\DefaultIcon', True);
		I.WriteString('', Application.ExeName + ',0');
		I.WriteString('OldAssociation', Application.ExeName + ',0');
		I.CloseKey;
		I.OpenKey('XMPRFile\QuickView', True);
		I.WriteString('', '*');
		I.CloseKey;
		I.OpenKey('XMPRFile\Shell\Open', True);
		I.WriteString('', 'Open with Marathon');
		I.CloseKey;
		I.OpenKey('XMPRFile\Shell\Open\Command', True);
		I.WriteString('', Application.ExeName + ' "%1"');
		I.WriteString('OldAssociation', Application.ExeName + ' "%1"');
		I.CloseKey;

		I.RootKey := HKEY_CURRENT_USER;

		if I.OpenKey(REG_VERSION_BASE, True) then
		begin
			// Set the Homedir for the Shellmenu
			if not (I.ValueExists('Home')) and (I.GetDataType('Home') <> rdString) then
				I.WriteString('Home', ExtractFilePath(Application.ExeName));

			I.CloseKey;
		end;

		// Set the defaults if the settings don't exist
		if I.OpenKey(REG_SETTINGS_BASE, True) then
		begin
			// General
			if not (I.ValueExists('MultiInstances')) or (I.GetDataType('MultiInstances') <> rdInteger) then
				I.WriteBool('MultiInstances', False);
			if not (I.ValueExists('ShowTips')) or (I.GetDataType('ShowTips') <> rdInteger) then
				I.WriteBool('ShowTips', True);
			if not (I.ValueExists('PromptTrans')) or (I.GetDataType('PromptTrans') <> rdInteger) then
				I.WriteBool('PromptTrans', True);
			if not (I.ValueExists('AlwaysSPParams')) or (I.GetDataType('AlwaysSPParams') <> rdInteger) then
				I.WriteBool('AlwaysSPParams', False);
			if not (I.ValueExists('SQLSave')) or (I.GetDataType('SQLSave') <> rdInteger) then
				I.WriteBool('SQLSave', True);
			if not (I.ValueExists('OpenLastProject')) or (I.GetDataType('OpenLastProject') <> rdInteger) then
				I.WriteBool('OpenLastProject', False);
			if not (I.ValueExists('OpenProjectOnStartup')) or (I.GetDataType('OpenProjectOnStartup') <> rdInteger) then
				I.WriteBool('OpenProjectOnStartup', False);
			if not (I.ValueExists('ShowPerformData')) or (I.GetDataType('ShowPerformData') <> rdInteger) then
				I.WriteBool('ShowPerformData', False);
			if not (I.ValueExists('ShowSystemInPerformance')) or (I.GetDataType('ShowSystemInPerformance') <> rdInteger) then
				I.WriteBool('ShowSystemInPerformance', False);
			if not (I.ValueExists('ShowQueryPlan')) or (I.GetDataType('ShowQueryPlan') <> rdInteger) then
				I.WriteBool('ShowQueryPlan', True);
			if not (I.ValueExists('DebuggerEnabled')) or (I.GetDataType('DebuggerEnabled') <> rdInteger) then
				I.WriteBool('DebuggerEnabled', False);
			if not (I.ValueExists('ViewListInDatabaseManager')) or (I.GetDataType('ViewListInDatabaseManager') <> rdInteger) then
				I.WriteBool('ViewListInDatabaseManager', True);

			// Data
			if not (I.ValueExists('DefaultView')) or (I.GetDataType('DefaultView') <> rdInteger) then
				I.WriteInteger('DefaultView', 0);
			if not (I.ValueExists('FloatDisplayFormat')) or (I.GetDataType('FloatDisplayFormat') <> rdString) then
				I.WriteString('FloatDisplayFormat', '#,###,##0.00');
			if not (I.ValueExists('IntDisplayFormat')) or (I.GetDataType('IntDisplayFormat') <> rdString) then
				I.WriteString('IntDisplayFormat', '#,###,##0');
			if not (I.ValueExists('DateDisplayFormat')) or (I.GetDataType('DateDisplayFormat') <> rdString) then
				I.WriteString('DateDisplayFormat', 'mm-dd-yyyy');
			if not (I.ValueExists('DateTimeDisplayFormat')) or (I.GetDataType('DateTimeDisplayFormat') <> rdString) then
				I.WriteString('DateTimeDisplayFormat', 'mm-dd-yyyy hh:mm');
			if not (I.ValueExists('TimeDisplayFormat')) or (I.GetDataType('TimeDisplayFormat') <> rdString) then
				I.WriteString('TimeDisplayFormat', 'hh:mm:ss');
			if not (I.ValueExists('CharDisplayWidth')) or (I.GetDataType('CharDisplayWidth') <> rdInteger) then
				I.WriteInteger('CharDisplayWidth', 0);

			// File Locations
			if not (I.ValueExists('DefaultProjectDir')) or (I.GetDataType('DefaultProjectDir') <> rdString) then
				I.WriteString('DefaultProjectDir', ExtractFilePath(Application.ExeName) + 'Projects');
			if not (I.ValueExists('DefaultScriptDir')) or (I.GetDataType('DefaultScriptDir') <> rdString) then
				I.WriteString('DefaultScriptDir', ExtractFilePath(Application.ExeName) + 'Scripts');
			if not (I.ValueExists('ExtractDDLDir')) or (I.GetDataType('ExtractDDLDir') <> rdString) then
				I.WriteString('ExtractDDLDir', ExtractFilePath(Application.ExeName) + 'Scripts');
			if not (I.ValueExists('SnippetsDir')) or (I.GetDataType('SnippetsDir') <> rdString) then
				I.WriteString('SnippetsDir', ExtractFilePath(Application.ExeName) + 'Snippets');

			I.CloseKey;
		end;

		// Editor
		if I.OpenKey(REG_SETTINGS_EDITOR, True) then
		begin
			// Editor Options
			if not (I.ValueExists('AutoIndent')) or (I.GetDataType('AutoIndent') <> rdInteger) then
				I.WriteBool('AutoIndent', True);
			if not (I.ValueExists('InsertMode')) or (I.GetDataType('InsertMode') <> rdInteger) then
				I.WriteBool('InsertMode', True);
			if not (I.ValueExists('SyntaxHighlight')) or (I.GetDataType('SyntaxHighlight') <> rdInteger) then
				I.WriteBool('SyntaxHighlight', True);
			if not (I.ValueExists('BlockIndent')) or (I.GetDataType('BlockIndent') <> rdInteger) then
				I.WriteInteger('BlockIndent', 1);
			if not (I.ValueExists('LineNumbers')) or (I.GetDataType('LineNumbers') <> rdInteger) then
				I.WriteBool('LineNumbers', False);
			if not (I.ValueExists('RightMargin')) or (I.GetDataType('RightMargin') <> rdInteger) then
				I.WriteInteger('RightMargin', 80);

			// Editor Display
			if not (I.ValueExists('EditorFontName')) or (I.GetDataType('EditorFontName') <> rdString) then
				I.WriteString('EditorFontName', 'Courier New');
			if not (I.ValueExists('EditorFontSize')) or (I.GetDataType('EditorFontSize') <> rdInteger) then
				I.WriteInteger('EditorFontSize', 10);
			if not (I.ValueExists('EditorVisibleGutter')) or (I.GetDataType('EditorVisibleGutter') <> rdInteger) then
				I.WriteBool('EditorVisibleGutter', True);

			// Editor Colors
			if not (I.ValueExists('MarkedBlockFontColor')) or (I.GetDataType('MarkedBlockFontColor') <> rdInteger) then
				I.WriteInteger('MarkedBlockFontColor', LongInt(clWhite));
			if not (I.ValueExists('MarkedBlockBGColor')) or (I.GetDataType('MarkedBlockBGColor') <> rdInteger) then
				I.WriteInteger('MarkedBlockBGColor', LongInt(clBlack));
			if not (I.ValueExists('ErrorLineFontColor')) or (I.GetDataType('ErrorLineFontColor') <> rdInteger) then
				I.WriteInteger('ErrorLineFontColor', LongInt(clWhite));
			if not (I.ValueExists('ErrorLineBGColor')) or (I.GetDataType('ErrorLineBGColor') <> rdInteger) then
				I.WriteInteger('ErrorLineBGColor', LongInt(clRed));

			I.CloseKey;
		end;

		// Editor SQLSmarts
		if I.OpenKey(REG_SETTINGS_SQLSMARTS, True) then
		begin
			if not (I.ValueExists('SQLKeywords')) or (I.GetDataType('SQLKeywords') <> rdInteger) then
				I.WriteBool('SQLKeywords', True);
			if not (I.ValueExists('TableNames')) or (I.GetDataType('TableNames') <> rdInteger) then
				I.WriteBool('TableNames', False);
			if not (I.ValueExists('FieldNames')) or (I.GetDataType('FieldNames') <> rdInteger) then
				I.WriteBool('FieldNames', False);
			if not (I.ValueExists('SPNames')) or (I.GetDataType('SPNames') <> rdInteger) then
				I.WriteBool('SPNames', False);
			if not (I.ValueExists('TriggerNames')) or (I.GetDataType('TriggerNames') <> rdInteger) then
				I.WriteBool('TriggerNames', False);
			if not (I.ValueExists('ExceptionNames')) or (I.GetDataType('ExceptionNames') <> rdInteger) then
				I.WriteBool('ExceptionNames', False);
			if not (I.ValueExists('GeneratorNames')) or (I.GetDataType('GeneratorNames') <> rdInteger) then
				I.WriteBool('GeneratorNames', False);
			if not (I.ValueExists('UDFNames')) or (I.GetDataType('UDFNames') <> rdInteger) then
				I.WriteBool('UDFNames', False);
			if not (I.ValueExists('Capitalise')) or (I.GetDataType('Capitalise') <> rdInteger) then
				I.WriteBool('Capitalise', False);
			if not (I.ValueExists('ListDelay')) or (I.GetDataType('ListDelay') <> rdInteger) then
				I.WriteInteger('ListDelay', 1000);

			I.CloseKey;
		end;

		// Editor SQLTrace
		if I.OpenKey(REG_SETTINGS_SQLTRACE, True) then
		begin
			if not (I.ValueExists('Connection')) or (I.GetDataType('Connection') <> rdInteger) then
				I.WriteBool('Connection', True);
			if not (I.ValueExists('Transaction')) or (I.GetDataType('Transaction') <> rdInteger) then
				I.WriteBool('Transaction', True);
			if not (I.ValueExists('Statement')) or (I.GetDataType('Statement') <> rdInteger) then
				I.WriteBool('Statement', True);
			if not (I.ValueExists('Row')) or (I.GetDataType('Row') <> rdInteger) then
				I.WriteBool('Row', False);
			if not (I.ValueExists('Blob')) or (I.GetDataType('Blob') <> rdInteger) then
				I.WriteBool('Blob', False);
			if not (I.ValueExists('Array')) or (I.GetDataType('Array') <> rdInteger) then
				I.WriteBool('Array', False);

			if not (I.ValueExists('Allocate')) or (I.GetDataType('Allocate') <> rdInteger) then
				I.WriteBool('Allocate', True);
			if not (I.ValueExists('Prepare')) or (I.GetDataType('Prepare') <> rdInteger) then
				I.WriteBool('Prepare', True);
			if not (I.ValueExists('Execute')) or (I.GetDataType('Execute') <> rdInteger) then
				I.WriteBool('Execute', True);
			if not (I.ValueExists('ExecuteImmediate')) or (I.GetDataType('ExecuteImmediate') <> rdInteger) then
				I.WriteBool('ExecuteImmediate', True);

			I.CloseKey;
		end;

		Sleep(400);

		if I.OpenKey(REG_SETTINGS_BASE, True) then
		begin
			// General
			gMultiInstances := I.ReadBool('MultiInstances');
			gShowTips := I.ReadBool('ShowTips');
			gPromptTrans := I.ReadBool('PromptTrans');
			gAlwaysSPParams := I.ReadBool('AlwaysSPParams');
			gSQLSave := I.ReadBool('SQLSave');
			gOpenLastProject := I.ReadBool('OpenLastProject');
			if I.ValueExists('LastProject') then
				gLastProject := I.ReadString('LastProject')
			else
				gLastProject := '';
			gOpenProjectOnStartup := I.ReadBool('OpenProjectOnStartup');
			gShowPerformData := I.ReadBool('ShowPerformData');
			gShowSystemInPerformance := I.ReadBool('ShowSystemInPerformance');
			gShowQueryPlan := I.ReadBool('ShowQueryPlan');
			gDebuggerEnabled := I.ReadBool('DebuggerEnabled');
			gViewListInDatabaseManager := I.ReadBool('ViewListInDatabaseManager');

			// Data
			gDefaultView := I.ReadInteger('DefaultView');
			gFloatDisplayFormat := I.ReadString('FloatDisplayFormat');
			gIntDisplayFormat := I.ReadString('IntDisplayFormat');
			gDateDisplayFormat := I.ReadString('DateDisplayFormat');
			gDateTimeDisplayFormat := I.ReadString('DateTimeDisplayFormat');
			gTimeDisplayFormat := I.ReadString('TimeDisplayFormat');
			gCharDisplayWidth := I.ReadInteger('CharDisplayWidth');

			// File Locations
			gDefProjectDir := I.ReadString('DefaultProjectDir');
			ForceDirectories(gDefProjectDir);
			gDefScriptDir := I.ReadString('DefaultScriptDir');
			ForceDirectories(gDefScriptDir);
			gExtractDDLDir := I.ReadString('ExtractDDLDir');
			ForceDirectories(gExtractDDLDir);
			gSnippetsDir := I.ReadString('SnippetsDir');
			if gSnippetsDir <> '' then
				gSnippetsDir := Tools.AddBackslash(gSnippetsDir);
			ForceDirectories(gSnippetsDir);

			I.CloseKey;
		end;

		// Editor
		if I.OpenKey(REG_SETTINGS_EDITOR, True) then
		begin
			// Editor Options
			gAutoIndent := I.ReadBool('AutoIndent');
			gInsertMode := I.ReadBool('InsertMode');
			gSyntaxHighlight := I.ReadBool('SyntaxHighlight');
			gBlockIndent := I.ReadInteger('BlockIndent');
			gRightMargin := I.ReadInteger('RightMargin');
      gLineNumbers := I.ReadBool('LineNumbers');

			// Editor Display
			gEditorFontName := I.ReadString('EditorFontName');
			gEditorFontSize := I.ReadInteger('EditorFontSize');
      gVisibleGutter := I.ReadBool('EditorVisibleGutter');

			// Editor Colors
			gMarkedBlockFontColor := TColor(I.ReadInteger('MarkedBlockFontColor'));
			gMarkedBlockBGColor := TColor(I.ReadInteger('MarkedBlockBGColor'));
			gErrorLineFontColor := TColor(I.ReadInteger('ErrorLineFontColor'));
			gErrorLineBGColor := TColor(I.ReadInteger('ErrorLineBGColor'));

			I.CloseKey;
		end;

		if I.OpenKey(REG_SETTINGS_SQLSMARTS, True) then
		begin
			gSQLKeyWords := I.ReadBool('SQLKeywords');
			gTableNames := I.ReadBool('TableNames');
			gFieldNames := I.ReadBool('FieldNames');
			gStoredProcNames := I.ReadBool('SPNames');
			gTriggerNames := I.ReadBool('TriggerNames');
			gExceptionNames := I.ReadBool('ExceptionNames');
			gGeneratorNames := I.ReadBool('GeneratorNames');
			gUDFNames := I.ReadBool('UDFNames');
			gCapitalise := I.ReadBool('Capitalise');
			gListDelay := I.ReadInteger('ListDelay');

			I.CloseKey;
		end;

		if I.OpenKey(REG_SETTINGS_SQLTrace, True) then
		begin
			gTraceConnection := I.ReadBool('Connection');
			gTraceTransaction := I.ReadBool('Transaction');
			gTraceStatement := I.ReadBool('Statement');
			gTraceRow := I.ReadBool('Row');
			gTraceBlob := I.ReadBool('Blob');
			gTraceArray := I.ReadBool('Array');

			gTraceAllocate := I.ReadBool('Allocate');
			gTracePrepare := I.ReadBool('Prepare');
			gTraceExecute := I.ReadBool('Execute');
			gTraceExecuteImmediate := I.ReadBool('ExecuteImmediate');

			I.CloseKey;
		end;
	finally
		I.Free;
	end;
	// Now whip around the list of forms and do what has to be done
	MarathonIDEInstance.RefreshForms;
end;

procedure TfrmMarathonMain.Window1Click(Sender: TObject);
var
	Idx, SpPos: Integer;
	Cap: String;

begin
	if Window1.Count = 3 then
		Window1.Items[2].Visible := False
	else
		Window1.Items[2].Visible := True;

	for Idx := 3 to Window1.Count - 1 do
	begin
		SPPos := Pos(' ', Window1.Items[idx].Caption);
		Cap := Copy(Window1.Items[idx].Caption, SPPos + 1, 200);
		Window1.Items[idx].Caption := '&' + IntToStr(Idx - 2) + ' ' + Cap;
	end;
end;

procedure TfrmMarathonMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if not FForceClose then
	begin
		if not MarathonIDEInstance.CloseQuery then
		begin
			CanClose := False;
			Exit;
		end;

		if MarathonIDEInstance.FileCloseProject then
			CanClose := True
		else
			CanClose := False;
	end
	else
    CanClose := True;
end;

procedure TfrmMarathonMain.FileNewProjectExecute(Sender: TObject);
begin
  MarathonIDEInstance.FileNewProject;
end;

procedure TfrmMarathonMain.FileOpenProjectExecute(Sender: TObject);
begin
  MarathonIDEInstance.FileOpenProject;
end;

procedure TfrmMarathonMain.FileCloseProjectExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileCloseProject;
end;

procedure TfrmMarathonMain.FileConnectExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoConnect;
end;

procedure TfrmMarathonMain.FileCreateDatabaseExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileCreateDatabase;
end;

procedure TfrmMarathonMain.FilePrintSetupExecute(Sender: TObject);
begin
	MarathonIDEInstance.FilePrintSetup;
end;

procedure TfrmMarathonMain.FileExitApplicationExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMarathonMain.ViewViewBrowserExecute(Sender: TObject);
begin
  MarathonIDEInstance.ViewViewBrowser;
end;

procedure TfrmMarathonMain.ToolsSQLEditorExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsSQLEditor;
end;

procedure TfrmMarathonMain.ProjectProjectOptionsExecute(Sender: TObject);
begin
	MarathonIDEInstance.ProjectProjectOptions;
end;

procedure TfrmMarathonMain.ViewNextWindowExecute(Sender: TObject);
begin
  MarathonIDEInstance.ViewViewNextWindow;
end;

procedure TfrmMarathonMain.ToolsMetaExtractExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsMetadataExtract;
end;

procedure TfrmMarathonMain.ToolsMetaSearchExecute(Sender: TObject);
begin
  MarathonIDEInstance.ToolsSearchMetadata;
end;

procedure TfrmMarathonMain.ToolsSQLCodeSnippetsExecute(Sender: TObject);
begin
  MarathonIDEInstance.ToolsCodeSnippets;
end;

procedure TfrmMarathonMain.ToolsSQLTraceExecute(Sender: TObject);
begin
  MarathonIDEInstance.ToolsSQLTrace;
end;

procedure TfrmMarathonMain.ToolsMarathonOptionsExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsEnvironmentOptions;
end;

procedure TfrmMarathonMain.ToolsSyntaxHelpExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsSyntaxHelp;
end;

procedure TfrmMarathonMain.WindowWindowListExecute(Sender: TObject);
begin
	MarathonIDEInstance.WindowWindowList;
end;

procedure TfrmMarathonMain.HelpHelpTopicsExecute(Sender: TObject);
begin
	Application.HelpCommand(HELP_FINDER, 0);
end;

procedure TfrmMarathonMain.HelpMarathonOnTheWebExecute(Sender: TObject);
begin
	Tools.ExecuteWin32Program('http://gmarathon.sourceforge.net');
end;

procedure TfrmMarathonMain.HelpEmailSupportExecute(Sender: TObject);
begin
	Tools.ExecuteWin32Program('http://gmarathon.sourceforge.net');
end;

procedure TfrmMarathonMain.dckTopResize(Sender: TObject);
begin
	FInternalHeight := dckTop.Height + stsMain.Height + rmPanel1.Height;
	ClientHeight := FInternalHeight;
end;

procedure TfrmMarathonMain.FileSaveProjectExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileSaveProject;
end;

procedure TfrmMarathonMain.FileSaveProjectAsExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileSaveProjectAs;
end;

procedure TfrmMarathonMain.FileCloseProjectUpdate(Sender: TObject);
begin
	FileCloseProject.Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.FileConnectUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileConnect.Enabled := F.CanConnect
	else
		FileConnect.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectProjectOptionsUpdate(Sender: TObject);
begin
  ProjectProjectOptions.Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.FileSaveProjectUpdate(Sender: TObject);
begin
	if MarathonIDEInstance.CurrentProject.Open then
		FileSaveProject.Enabled := MarathonIDEInstance.CurrentProject.Modified
	else
		FileSaveProject.Enabled := False;
end;

procedure TfrmMarathonMain.FileSaveProjectAsUpdate(Sender: TObject);
begin
	FileSaveProjectAs.Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ToolsEditorPropertiesExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsEnvironmentOptions;
end;

procedure TfrmMarathonMain.QueryEndSession(var Message: TMessage);
begin
	FForceClose := True;
	Message.Result := 1;
end;

procedure TfrmMarathonMain.EndSession(var Message: TMessage);
begin
	Close;
end;

procedure TfrmMarathonMain.ToolsUserEditorExecute(Sender: TObject);
begin
	MarathonIDEInstance.ToolsUserEditor;
end;

procedure TfrmMarathonMain.WindowCloseAllWindowsExecute(Sender: TObject);
begin
	MarathonIDEInstance.WindowCLoseAllWindows;
end;

procedure TfrmMarathonMain.ViewToolbarToolsExecute(Sender: TObject);
begin
  tlbrTools.Visible := not(tlbrTools.Visible);
end;

procedure TfrmMarathonMain.ViewToolbarScriptExecute(Sender: TObject);
begin
  tlbrScript.Visible := not(tlbrScript.Visible);
end;

procedure TfrmMarathonMain.ViewToolbarStandardExecute(Sender: TObject);
begin
  tlbrStandard.Visible := not(tlbrStandard.Visible);
end;

procedure TfrmMarathonMain.ViewToolbarSQLEditorExecute(Sender: TObject);
begin
  tlbrSQLEditor.Visible := not(tlbrSQLEditor.Visible); 
end;

procedure TfrmMarathonMain.ViewToolbarToolsUpdate(Sender: TObject);
begin
  ViewToolbarTools.Checked := tlbrTools.Visible;
end;

procedure TfrmMarathonMain.ViewToolbarScriptUpdate(Sender: TObject);
begin
  ViewToolbarScript.Checked := tlbrScript.Visible;
end;

procedure TfrmMarathonMain.ViewToolbarStandardUpdate(Sender: TObject);
begin
  ViewToolbarStandard.Checked := tlbrStandard.Visible;
end;

procedure TfrmMarathonMain.ViewToolbarSQLEditorUpdate(Sender: TObject);
begin
	ViewToolbarSQLEditor.Checked := tlbrSQLEditor.Visible;
end;

procedure TfrmMarathonMain.LoadMRUMenu;
var
	RList: TStringList;
	Idx: Integer;
	Action: TMRUAction;
	MItem: TMenuItem;

begin
{	// Clean up
	for Idx := ReOpen1.Count - 1 downto 0 do
		ReOpen1.Items[Idx].Free;
	for Idx := actMRU.ActionCount - 1 downto 0 do
		actMRU.Actions[Idx].Free;

	RList := TStringList.Create;
	try
		RList.Text := MarathonIDEInstance.RecentFileData;
		for Idx := 0 to RList.Count -1 do
		begin
			Action := TMRUAction.Create(Self);
			Action.Caption := '&' + IntToStr(Idx) + ' ' + RList[Idx];
			Action.FileName := RList[Idx];
			Action.OnExecute := ExecuteMRU;
			Action.ActionList := actMRU;
			MItem := TMenuItem.Create(Self);
			MItem.Action := Action;
			ReOpen1_old.Add(MItem); //rjm - tbmenufix
		end;
	finally
		RList.Free;
	end;}
end;

procedure TfrmMarathonMain.LoadWindowList;
var
	Idx: Integer;

begin
	tabWindows.Tabs.Clear;
	for Idx := 0 to MarathonIDEInstance.WindowList.Count - 1 do
		tabWindows.Tabs.AddObject(TForm(MarathonIDEInstance.WindowList[Idx]).Caption, TForm(MarathonIDEInstance.WindowList[Idx]));
  if (tabWindows.TabIndex = -1) and (tabWindows.Tabs.Count > 0) then
     tabWindows.TabIndex := 0;
end;

procedure TfrmMarathonMain.IdleHandler(Sender: TObject; var Done: Boolean);
var
	Idx: Integer;
	MF: IMarathonForm;
	SQLForm: IMarathonSQLForm;
	Browser: IMarathonBrowser;

begin
	if not (csDestroying in ComponentState) then
	begin
		for Idx := 0 to tabWindows.Tabs.Count - 1 do
			if tabWindows.Tabs.Objects[Idx] = Screen.ActiveForm then
			begin
				tabWindows.TabIndex := Idx;
				Break;
			end;

		if MarathonIDEInstance.CurrentProject.Open then
		begin
			// Update active connection
			MF := MarathonIDEInstance.ScreenActiveForm;
			if Assigned(MF) then
			begin
				MF.QueryInterface(IMarathonBrowser, Browser);
				if Assigned(Browser) then
				begin
					if Browser.GetUpdateActiveConnection <> '' then
						MarathonIDEInstance.CurrentProject.Cache.ActiveConnection := Browser.GetUpdateActiveConnection;
				end
				else
					if MF.GetActiveConnectionName <> '' then
						MarathonIDEInstance.CurrentProject.Cache.ActiveConnection := MF.GetActiveConnectionName;
			end;

			// Update Combobox
			if MarathonIDEInstance.CurrentProject.Cache.ConnectionsChanged then
			begin
				cmbConnections.Items.Clear;
				cmbConnections.Items.Add('(none)');
				for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
				begin
					cmbConnections.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
				end;
				MarathonIDEInstance.CurrentProject.Cache.ConnectionsChanged := False;
			end;

      MF := MarathonIDEInstance.ScreenActiveForm;
      if Assigned(MF) then
      begin
        MF.QueryInterface(IMarathonSQLForm, SQLForm);
        if Assigned(SQLForm) then
        begin
          if not cmbConnections.Enabled then
            cmbConnections.Enabled := True;

          if SQLForm.CurrentConnection = '' then
					begin
            if not FDroppedDown then
							if cmbConnections.ItemIndex <> 0 then
								cmbConnections.ItemIndex := 0
					end
					else
					begin
						if not FDroppedDown then
						begin
							Idx := cmbConnections.Items.IndexOf(SQLForm.CurrentConnection);
							if Idx <> cmbConnections.ItemIndex then
								cmbConnections.ItemIndex := Idx;
						end;
					end;
				end
				else
				begin
					cmbConnections.Enabled := False;
					cmbConnections.ItemIndex := -1;
				end;
			end
			else
      begin
        cmbConnections.Enabled := False;
        cmbConnections.ItemIndex := -1;
      end;  
    end
    else
    begin
      cmbConnections.Items.Clear;
      cmbConnections.Enabled := False;
    end;
	end;
end;

procedure TfrmMarathonMain.ExecuteMRU(Sender: TObject);
var
	FExt: String;

begin
	if Sender is TMRUAction then
	begin
		FExt := LowerCase(ExtractFileExt(TMRUAction(Sender).FileName));

		if FExt = '.xmpr' then
		begin
			if MarathonIDEInstance.FileCloseProject then
				MarathonIDEInstance.OpenProject(TMRUAction(Sender).FileName);
		end
		else
			MarathonIDEInstance.FileOpenNamedFile(TMRUAction(Sender).FileName);
	end;
end;

procedure TfrmMarathonMain.ProjectNewConnectionExecute(Sender: TObject);
begin
	MarathonIDEInstance.ProjectNewConnection;
end;

procedure TfrmMarathonMain.FileDisconnectUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileDisconnect.Enabled := F.CanDisconnect
	else
		FileDisconnect.Enabled := False;
end;

procedure TfrmMarathonMain.FileDisconnectExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoDisconnect;
end;

function TfrmMarathonMain.GetCaption: String;
begin
  Result := Caption;
end;

procedure TfrmMarathonMain.SetCaption(Value: String);
begin
  Caption := Value;
end;

procedure TfrmMarathonMain.FileCloseExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoInternalClose;
end;

procedure TfrmMarathonMain.FileCloseUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileClose.Enabled := F.CanInternalClose
	else
		FileClose.Enabled := False;
end;

procedure TfrmMarathonMain.FileNewObjectExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileNewObject;
end;

procedure TfrmMarathonMain.FilePrintExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoPrint;
end;

procedure TfrmMarathonMain.FilePrintUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FilePrint.Enabled := F.CanPrint
	else
		FilePrint.Enabled := False;
end;

procedure TfrmMarathonMain.FilePrintPreviewExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoPrintPreview;
end;

procedure TfrmMarathonMain.FilePrintPreviewUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FilePrintPreview.Enabled := F.CanPrintPreview
	else
		FilePrintPreview.Enabled := False;
end;

procedure TfrmMarathonMain.FileOpenFileExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileOpenFile;
end;

procedure TfrmMarathonMain.FileOpenDatabaseObjectExecute(Sender: TObject);
begin
	MarathonIDEInstance.FileOpenDatabaseObject;
end;

procedure TfrmMarathonMain.FileOpenDatabaseObjectUpdate(Sender: TObject);
begin
	FileOpenDatabaseObject.Enabled := MarathonIDEInstance.CurrentProject.Cache.ConnectionCount > 0;
end;

procedure TfrmMarathonMain.ProjectNewConnectionUpdate(Sender: TObject);
begin
  ProjectNewConnection.Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.tabWindowsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
	MarathonIDEInstance.BringWindowToFront(NewTab);
end;

procedure TfrmMarathonMain.ProjectOpenItemUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectOpenItem.Enabled := F.CanOpenItem
	else
		ProjectOpenItem.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectItemPropertiesUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectItemProperties.Enabled := F.CanItemProperties
	else
		ProjectItemProperties.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectItemDeleteUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectItemDelete.Enabled := F.CanDeleteItem
	else
		ProjectItemDelete.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectItemDropUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectItemDrop.Enabled := F.CanDropItem
	else
		ProjectItemDrop.Enabled := False;
end;

function TfrmMarathonMain.GetFormTop: Integer;
begin
	Result := Top;
end;

function TfrmMarathonMain.GetFormHeight: Integer;
begin
	Result := Height;
end;

procedure TfrmMarathonMain.ProjectOpenItemExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoOpenItem;
end;

procedure TfrmMarathonMain.ProjectItemDropExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoDropItem;
end;

procedure TfrmMarathonMain.ProjectItemPropertiesExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoItemProperties;
end;

procedure TfrmMarathonMain.ProjectItemDeleteExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoDeleteItem;
end;

procedure TfrmMarathonMain.ViewRefreshUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewRefresh.Enabled := F.CanRefresh
	else
		ViewRefresh.Enabled := False;
end;

procedure TfrmMarathonMain.ViewRefreshExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoRefresh;
end;

procedure TfrmMarathonMain.ProjectExtractMetadataExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoExtractMetadata;
end;

procedure TfrmMarathonMain.ProjectExtractMetadataUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectExtractMetadata.Enabled := F.CanExtractMetadata
	else
		ProjectExtractMetadata.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectCreateFolderExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoCreateFolder;
end;

procedure TfrmMarathonMain.ProjectCreateFolderUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectCreateFOlder.Enabled := F.CanCreateFolder
	else
		ProjectCreateFolder.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectAddToProjectExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoAddToProject;
end;

procedure TfrmMarathonMain.ProjectAddToProjectUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ProjectAddToProject.Enabled := F.CanAddToProject
	else
		ProjectAddToProject.Enabled := False;
end;

procedure TfrmMarathonMain.ObjectExecuteUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ObjectExecute.Enabled := F.CanExecute
	else
		ObjectExecute.Enabled := False;
end;

procedure TfrmMarathonMain.ObjectExecuteExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoExecute;
end;

procedure TfrmMarathonMain.EditUndoExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoUndo;
end;

procedure TfrmMarathonMain.EditUndoUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditUndo.Enabled := F.CanUndo
	else
		EditUndo.Enabled := False;
end;

procedure TfrmMarathonMain.EditRedoExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoRedo;
end;

procedure TfrmMarathonMain.EditRedoUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditRedo.Enabled := F.CanRedo
	else
		EditRedo.Enabled := False;
end;

procedure TfrmMarathonMain.EditCaptureSnippetExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoCaptureSnippet;
end;

procedure TfrmMarathonMain.EditCaptureSnippetUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditCaptureSnippet.Enabled := F.CanCaptureSnippet
	else
		EditCaptureSnippet.Enabled := False;
end;

procedure TfrmMarathonMain.EditCutExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoCut;
end;

procedure TfrmMarathonMain.EditCutUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditCut.Enabled := F.CanCut
	else
		EditCut.Enabled := False;
end;

procedure TfrmMarathonMain.EditCopyExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoCopy;
end;

procedure TfrmMarathonMain.EditCopyUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditCopy.Enabled := F.CanCopy
	else
		EditCopy.Enabled := False;
end;

procedure TfrmMarathonMain.EditPasteExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoPaste;
end;

procedure TfrmMarathonMain.EditPasteUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditPaste.Enabled := F.CanPaste
	else
		EditPaste.Enabled := False;
end;

procedure TfrmMarathonMain.EditFindExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoFind;
end;

procedure TfrmMarathonMain.EditFindUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditFind.Enabled := F.CanFind
	else
		EditFind.Enabled := False;
end;

procedure TfrmMarathonMain.EditSelectAllExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSelectAll;
end;

procedure TfrmMarathonMain.EditSelectAllUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditSelectAll.Enabled := F.CanSelectAll
	else
		EditSelectAll.Enabled := False;
end;

procedure TfrmMarathonMain.EditFindNextExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoFindNext;
end;

procedure TfrmMarathonMain.EditFindNextUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		EditFindNext.Enabled := F.CanFindNext
	else
		EditFindNext.Enabled := False;
end;

procedure TfrmMarathonMain.ViewPrevStatementExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoViewPrevStatement;
end;

procedure TfrmMarathonMain.ViewPrevStatementUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewPrevStatement.Enabled := F.CanViewPrevStatement
	else
		ViewPrevStatement.Enabled := False;
end;

procedure TfrmMarathonMain.ViewNextStatementExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoViewNextStatement;
end;

procedure TfrmMarathonMain.ViewNextStatementUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewNextStatement.Enabled := F.CanViewNextStatement
	else
		ViewNextStatement.Enabled := False;
end;

procedure TfrmMarathonMain.ViewStatementHistoryExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoStatementHistory;
end;

procedure TfrmMarathonMain.ViewStatementHistoryUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewStatementHistory.Enabled := F.CanStatementHistory
	else
		ViewStatementHistory.Enabled := False;
end;

procedure TfrmMarathonMain.ViewNextPageExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoViewNextPage;
end;

procedure TfrmMarathonMain.ViewNextPageUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewNextPage.Enabled := F.CanViewNextPage
	else
		ViewNextPage.Enabled := False;
end;

procedure TfrmMarathonMain.ViewPrevPageExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoViewPrevPage;
end;

procedure TfrmMarathonMain.ViewPrevPageUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ViewPrevPage.Enabled := F.CanViewPrevPage
	else
		ViewPrevPage.Enabled := False;
end;

procedure TfrmMarathonMain.TransactionCommitExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoTransactionCommit;
end;

procedure TfrmMarathonMain.TransactionCommitUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		TransactionCommit.Enabled := F.CanTransactionCommit
	else
		TransactionCommit.Enabled := False;
end;

procedure TfrmMarathonMain.TransactionRollbackExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoTransactionRollback;
end;

procedure TfrmMarathonMain.TransactionRollbackUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		TransactionRollback.Enabled := F.CanTransactionRollback
	else
		TransactionRollback.Enabled := False;
end;

procedure TfrmMarathonMain.ObjectCompileExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoCompile;
end;

procedure TfrmMarathonMain.ObjectCompileUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		ObjectCompile.Enabled := F.CanCompile
	else
		ObjectCompile.Enabled := False;
end;

procedure TfrmMarathonMain.FileLoadExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoLoad;
end;

procedure TfrmMarathonMain.FileLoadUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileLoad.Enabled := F.CanLoad
	else
		FileLoad.Enabled := False;
end;

procedure TfrmMarathonMain.FileLoadFromExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoLoadFrom;
end;

procedure TfrmMarathonMain.FileLoadFromUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileLoadFrom.Enabled := F.CanLoadFrom
	else
		FileLoadFrom.Enabled := False;
end;

procedure TfrmMarathonMain.FileSaveExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSave;
end;

procedure TfrmMarathonMain.FileSaveUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileSave.Enabled := F.CanSave
	else
		FileSave.Enabled := False;
end;

procedure TfrmMarathonMain.FileSaveAsExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSaveAs;
end;

procedure TfrmMarathonMain.FileSaveAsUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileSaveAs.Enabled := F.CanSaveAs
	else
		FileSaveAs.Enabled := False;
end;

procedure TfrmMarathonMain.ViewMessagesExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoViewMessages;
end;

procedure TfrmMarathonMain.ViewMessagesUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		ViewMessages.Enabled := F.CanViewMessages;
		ViewMessages.Checked := F.AreMessagesVisible;
	end
	else
		ViewMessages.Enabled := False;
end;

procedure TfrmMarathonMain.EditEncANSIExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoChangeEncoding((Sender as TAction).Tag);
end;

procedure TfrmMarathonMain.EditEncANSIUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanChangeEncoding;
		(Sender as TAction).Checked := F.IsEncoding((Sender as TAction).Tag);
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.EditClearEditBufferExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoClearBuffer;
end;

procedure TfrmMarathonMain.EditClearEditBufferUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanClearBuffer
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.EditToggleBookmark1Execute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoToggleBookmark((Sender as TAction).Tag);
end;

procedure TfrmMarathonMain.EditToggleBookmark1Update(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanToggleBookmark((Sender as TAction).Tag);
		(Sender as TAction).Checked := F.IsBookmarkSet((Sender as TAction).Tag);
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.EditGotoBookmark0Execute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoGotoBookmark((Sender as TAction).Tag);
end;

procedure TfrmMarathonMain.EditGotoBookmark0Update(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanGotoBookmark((Sender as TAction).Tag)
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.AddMenuItem(MenuAction: TBasicAction);
var
  wTBItem : TTBItem;
begin
//	Window1_old.Add(TMenuItem(Menu));  //rjm - tbmenufix
  wTBItem := TTBItem.Create(TBToolbar1);
  wTBItem.Action := MenuAction;
  Menuaction.FreeNotification(self);
  Window1.Add(wTBItem);
end;

procedure TfrmMarathonMain.ObjectShowQueryPlanExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoShowQueryPlan;
end;

procedure TfrmMarathonMain.ObjectShowQueryPlanUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanShowQueryPlan;
		(Sender as TAction).Checked := F.IsShowingQueryPlan;
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectShowPerformanceDataExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoShowPerformanceData;
end;

procedure TfrmMarathonMain.ObjectShowPerformanceDataUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanShowPerformanceData;
		(Sender as TAction).Checked := F.IsShowingPerformanceData;
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.cmbConnectionsDropDown(Sender: TObject);
begin
	FDroppedDown := True;
end;

procedure TfrmMarathonMain.cmbConnectionsCloseUp(Sender: TObject);
begin
	FDroppedDown := False;
end;

procedure TfrmMarathonMain.cmbConnectionsChange(Sender: TObject);
var
	MF: IMarathonFOrm;
	SQLForm: IMarathonSQLForm;

begin
	MF := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(MF) then
	begin
		MF.QueryInterface(IMarathonSQLForm, SQLForm);
		if Assigned(SQLForm) then
			if cmbConnections.ItemIndex = 0 then
				SQLForm.DatabaseName := ''
			else
				if not MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[cmbConnections.Text].Connected then
				begin
					MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[cmbConnections.Text].ErrorOnConnection := False;
					if MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[cmbConnections.Text].Connect then
						SQLForm.DatabaseName := cmbConnections.Text;
				end
				else
					SQLForm.DatabaseName := cmbConnections.Text;
	end;
end;

procedure TfrmMarathonMain.FileExportExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoExport;
end;

procedure TfrmMarathonMain.FileExportUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		FileExport.Enabled := F.CanExport
	else
		FileExport.Enabled := False;
end;

procedure TfrmMarathonMain.ProjectNewItemExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoNewItem;
end;

procedure TfrmMarathonMain.ProjectNewItemUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanNewItem
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDrop;
end;

procedure TfrmMarathonMain.ObjectDropUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDrop
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectAddToProjectExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectAddToProject;
end;

procedure TfrmMarathonMain.ObjectAddToProjectUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectAddToProject
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ToolsEditorPropertiesUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanToolsEditorProperties
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.EditReplaceUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanReplace
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.EditReplaceExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoReplace;
end;

procedure TfrmMarathonMain.ObjectParametersExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectParameters;
end;

procedure TfrmMarathonMain.ObjectParametersUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectParameters
	else
    (Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectSaveDocumentationExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSaveDoco;
end;

procedure TfrmMarathonMain.ObjectSaveDocumentationUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanSaveDoco
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectSaveAsTemplateExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSaveAsTemplate;
end;

procedure TfrmMarathonMain.ObjectSaveAsTemplateUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanSaveAsTemplate
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectRevokeExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoRevoke;
end;

procedure TfrmMarathonMain.ObjectRevokeUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanRevoke
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectGrantExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoGrant;
end;

procedure TfrmMarathonMain.ObjectGrantUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanGrant
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.FileNewObjectUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open and (MarathonIDEInstance.CurrentProject.Cache.ConnectionCount > 0);
end;

function TfrmMarathonMain.MenuCount: Integer;
begin
  raise exception.create('MenuCount');
//  Result := MainMenu1.Items.Count;
end;

function TfrmMarathonMain.MenuItem(Index: Integer): TMenuItem;
begin
  raise exception.Create('MenuItem');
//  Result := MainMenu1.Items.Items[Index];
//  TBToolbar1.Items.Items[Index].Action;
end;

procedure TfrmMarathonMain.ToolsPluginsExecute(Sender: TObject);
begin
  MarathonIDEInstance.ManagePlugins;
end;

procedure TfrmMarathonMain.ObjectExecuteAsScriptUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanExecuteAsScript;
		(Sender as TAction).Checked := F.IsExecuteAsScript;
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectExecuteAsScriptExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoExecuteAsScript;
end;

procedure TfrmMarathonMain.ObjectPropertiesExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectProperties;
end;

procedure TfrmMarathonMain.ObjectPropertiesUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectProperties
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDebuggerEnabledExecute(Sender: TObject);
begin
	MarathonIDEInstance.DoDebuggerEnabled;
end;

procedure TfrmMarathonMain.ObjectDebuggerEnabledUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CanDebuggerEnabled;
	(Sender as TAction).Checked := MarathonIDEInstance.IsDebuggerEnabled;
end;

procedure TfrmMarathonMain.ObjectStepIntoExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoStepInto;
end;

procedure TfrmMarathonMain.ObjectStepIntoUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanStepInto
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectAddBreakPointExecute(Sender: TObject);
var
	F: IMarathonForm;
begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoAddBreakPoint;
end;

procedure TfrmMarathonMain.ObjectAddBreakPointUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanAddBreakPoint
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectToggleBreakPointExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoToggleBreakPoint;
end;

procedure TfrmMarathonMain.ObjectToggleBreakPointUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanToggleBreakPoint
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectEvalModifyExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoEvalModify;
end;

procedure TfrmMarathonMain.ObjectEvalModifyUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanEvalModify
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectResetGeneratorValueExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoResetValue;
end;

procedure TfrmMarathonMain.ObjectResetGeneratorValueUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanResetValue
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ProjectNewServerExecute(Sender: TObject);
begin
	MarathonIDEInstance.ProjectNewServer;
end;

procedure TfrmMarathonMain.ProjectNewServerUpdate(Sender: TObject);
begin
	ProjectNewServer.Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ObjectNewFieldUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectNewField
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectNewFieldExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectNewField;
end;

procedure TfrmMarathonMain.ObjectNewTriggerExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectNewTrigger;
end;

procedure TfrmMarathonMain.ObjectNewTriggerUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectNewTrigger
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropFieldExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDropField;
end;

procedure TfrmMarathonMain.ObjectDropFieldUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDropField
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropTriggerExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDropTrigger;
end;

procedure TfrmMarathonMain.ObjectDropTriggerUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDropTrigger
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropConstraintExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDropConstraint;
end;

procedure TfrmMarathonMain.ObjectDropConstraintUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDropConstraint
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropIndexExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDropIndex;
end;

procedure TfrmMarathonMain.ObjectDropIndexUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDropIndex
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectReorderColumnsExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectReorderColumns;
end;

procedure TfrmMarathonMain.ObjectReorderColumnsUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectReorderColumns
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectNewConstraintExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectNewConstraint;
end;

procedure TfrmMarathonMain.ObjectNewConstraintUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectNewConstraint
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectNewIndexExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectNewIndex;
end;

procedure TfrmMarathonMain.ObjectNewIndexUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectNewIndex
	else
    (Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectNewInputParamExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectNewInputParam;
end;

procedure TfrmMarathonMain.ObjectNewInputParamUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectNewInputParam
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectDropInputParamExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectDropInputParam;
end;

procedure TfrmMarathonMain.ObjectDropInputParamUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectDropInputParam
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ScriptRecordScriptUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ScriptRecordScriptExecute(Sender: TObject);
begin
	MarathonIDEInstance.ScriptScriptRecording;
end;

procedure TfrmMarathonMain.ScriptStopRecordExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoStopScriptRecord;
end;

procedure TfrmMarathonMain.ScriptStopRecordUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanStopScriptRecord
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ScriptStartRecordExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoStartScriptRecord;
end;

procedure TfrmMarathonMain.ScriptStartRecordUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanStartScriptRecord
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ScriptNewScriptExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoNewScriptRecord;
end;

procedure TfrmMarathonMain.ScriptNewScriptUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanNewScriptRecord
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ScriptAppendExistingExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoAppendExistingScript;
end;

procedure TfrmMarathonMain.ScriptAppendExistingUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanAppendExistingScript
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ViewFoldersExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoFolderMode;
end;

procedure TfrmMarathonMain.ViewFoldersUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanDoFolderMode;
		(Sender as TAction).Checked := F.IsFolderMode;
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ViewSearchExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoSearchMode;
end;

procedure TfrmMarathonMain.ViewSearchUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanDoSearchMode;
		(Sender as TAction).Checked := F.IsSearchMode;
	end
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectOpenSubObjectExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoObjectOpenSubObject;
end;

procedure TfrmMarathonMain.ObjectOpenSubObjectUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanObjectOpenSubObject
	else
    (Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ViewListExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoListMode;
end;

procedure TfrmMarathonMain.ViewListUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
	begin
		(Sender as TAction).Enabled := F.CanDoListMode;
		(Sender as TAction).Checked := F.IsListMode;
  end
  else
    (Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.HelpAboutExecute(Sender: TObject);
begin
	MarathonIDEInstance.DoAboutBox;
end;

procedure TfrmMarathonMain.ViewBreakPointsUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ViewBreakPointsExecute(Sender: TObject);
begin
  MarathonIDEInstance.DoViewBreakpoints;
end;

procedure TfrmMarathonMain.ViewWatchesExecute(Sender: TObject);
begin
  MarathonIDEInstance.DoViewWatches;
end;

procedure TfrmMarathonMain.ViewWatchesUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ViewCallStackExecute(Sender: TObject);
begin
	MarathonIDEInstance.DoViewCallStack;
end;

procedure TfrmMarathonMain.ViewCallStackUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ViewLocalVariablesExecute(Sender: TObject);
begin
	MarathonIDEInstance.DoViewLocalVars;
end;

procedure TfrmMarathonMain.ViewLocalVariablesUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ObjectAddWatchAtCursorExecute(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		F.DoAddWatchAtCursor;
end;

procedure TfrmMarathonMain.ObjectAddWatchAtCursorUpdate(Sender: TObject);
var
	F: IMarathonForm;

begin
	F := MarathonIDEInstance.ScreenActiveForm;
	if Assigned(F) then
		(Sender as TAction).Enabled := F.CanAddWatchAtCursor
	else
		(Sender as TAction).Enabled := False;
end;

procedure TfrmMarathonMain.ObjectAddWatchExecute(Sender: TObject);
begin
	MarathonIDEInstance.DebuggerVM.AddWatchDialog;
end;

procedure TfrmMarathonMain.ObjectAddWatchUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.DebuggerVM.Enabled
		and MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmMarathonMain.ObjectShowExecutionPointUpdate(Sender: TObject);
begin
	(Sender as TAction).Enabled := MarathonIDEInstance.DebuggerVM.Executing;
end;

procedure TfrmMarathonMain.ObjectShowExecutionPointExecute(Sender: TObject);
begin
	MarathonIDEInstance.DebuggerVM.ShowExecutionPoint;
end;

procedure TfrmMarathonMain.DoStatus(Status: String);
begin
	stsMain.Panels[0].Text := Status;
	stsMain.Refresh;
end;

function TfrmMarathonMain.MenuItemAction(Index: Integer): TBasicAction;
begin
//
end;

procedure TfrmMarathonMain.Notification(AComponent: TComponent; Operation: TOperation);
var
  loop : integer;
  wFound : boolean;
  wComponent : TComponent;
begin
  if (operation = opRemove) then
  begin
     if aComponent is TBasicAction then
     begin
        wFound := false;
        loop := 0;
        while not wFound and (loop < Self.ComponentCount-1) do
        begin
           wComponent := self.Components[loop];
           if (wComponent is TTBItem) and (TTBItem(wComponent).Action = TBasicAction(aComponent)) then
           begin
              wFound := true;
              TTBItem(wComponent).Action := nil;
              TTBItem(wComponent).Free;
           end
           else
           inc(loop);
        end;
     end;
  end;

  inherited;
end;

function TfrmMarathonMain.MainFormMonitor: TMonitor;
begin
   result := self.Monitor;
end;

end.


