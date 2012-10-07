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
// $Id: BaseDocumentForm.pas,v 1.5 2006/10/22 06:04:28 rjmills Exp $

unit BaseDocumentForm;

interface

uses
	Windows, Messages, SysUtils, Classes, MarathonInternalInterfaces,
	Graphics, Controls, Forms, Dialogs, ComCtrls,
	MarathonProjectCacheTypes, Globals,
	GimbalToolsAPI;

type
  TfrmBaseDocumentForm = class(TForm, IMarathonForm, IGimbalIDEWindow)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function GetInternalCaption: String;
    procedure SetInternalCaption(const Value: String);
    { Private declarations }
  protected
		FByPassClose: Boolean;
    function GetObjectName: String; virtual;
  public
    { Public declarations }

    procedure ByPassClose;

    //file category
    function GetActiveConnectionName: String; virtual;
		function GetActiveObjectType : TGSSCacheType; virtual;
    function GetActiveStatusBar : TStatusBar; virtual;
    function GetObjectNewStatus: Boolean; virtual;

    function InternalCloseQuery: Boolean; virtual;

    function CanInternalClose: Boolean; virtual;
    procedure DoInternalClose; virtual;

    function CanConnect: Boolean; virtual;
    procedure DoConnect; virtual;

    function CanDisconnect: Boolean; virtual;
    procedure DoDisconnect; virtual;

    function CanPrint: Boolean; virtual;
    procedure DoPrint; virtual;

		function CanPrintPreview: Boolean; virtual;
    procedure DoPrintPreview; virtual;

    function CanOpenItem: Boolean; virtual;
    procedure DoOpenItem; virtual;

    function CanNewItem: Boolean; virtual;
    procedure DoNewItem; virtual;

    function CanDeleteItem: Boolean; virtual;
    procedure DoDeleteItem; virtual;

    function CanDropItem: Boolean; virtual;
    procedure DoDropItem; virtual;

    function CanItemProperties: Boolean; virtual;
    procedure DoItemProperties; virtual;

    function CanObjectAddToProject: Boolean; virtual;
    procedure DoObjectAddToProject; virtual;

    function CanRefresh: Boolean; virtual;
    procedure DoRefresh; virtual;

    function CanExtractMetadata: Boolean; virtual;
    procedure DoExtractMetadata; virtual;

    function CanCreateFolder: Boolean; virtual;
    procedure DoCreateFolder; virtual;

    function CanAddToProject: Boolean; virtual;
    procedure DoAddToProject; virtual;

    function CanExecute: Boolean; virtual;
    procedure DoExecute; virtual;

    function CanUndo: Boolean; virtual;
    procedure DoUndo; virtual;

    function CanRedo: Boolean; virtual;
    procedure DoRedo; virtual;

    function CanCaptureSnippet: Boolean; virtual;
    procedure DoCaptureSnippet; virtual;

    function CanCut: Boolean; virtual;
    procedure DoCut; virtual;

    function CanCopy: Boolean; virtual;
    procedure DoCopy; virtual;

    function CanPaste: Boolean; virtual;
		procedure DoPaste; virtual;

		function CanFind: Boolean; virtual;
		procedure DoFind; virtual;

		function CanFindNext: Boolean; virtual;
		procedure DoFindNext; virtual;

		function CanReplace: Boolean; virtual;
		procedure DoReplace; virtual;

		function CanSelectAll: Boolean; virtual;
		procedure DoSelectAll;  virtual;

		function CanViewPrevStatement: Boolean; virtual;
		procedure DoViewPrevStatement; virtual;

		function CanViewNextStatement: Boolean; virtual;
		procedure DoViewNextStatement; virtual;

		function CanStatementHistory: Boolean; virtual;
		procedure DoStatementHistory; virtual;

		function CanViewNextPage: Boolean; virtual;
		procedure DoViewNextPage; virtual;

		function CanViewPrevPage: Boolean; virtual;
		procedure DoViewPrevPage; virtual;

		function CanTransactionCommit: Boolean; virtual;
		procedure DoTransactionCommit; virtual;

		function CanTransactionRollback: Boolean; virtual;
		procedure DoTransactionRollback; virtual;

		function CanCompile: Boolean; virtual;
		procedure DoCompile; virtual;

		function CanSaveAsTemplate: Boolean; virtual;
		procedure DoSaveAsTemplate; virtual;

		function CanExport: Boolean; virtual;
		procedure DoExport; virtual;

		function CanLoad: Boolean; virtual;
		procedure DoLoad; virtual;

		function CanLoadFrom: Boolean; virtual;
		procedure DoLoadFrom; virtual;

		function CanSave: Boolean; virtual;
		procedure DoSave; virtual;

		function CanSaveAs: Boolean; virtual;
		procedure DoSaveAs; virtual;

		function CanViewMessages: Boolean; virtual;
		function AreMessagesVisible: Boolean; virtual;
    procedure DoViewMessages; virtual;

    function CanChangeEncoding: Boolean; virtual;
    procedure DoChangeEncoding(Index: Integer); virtual;
    function IsEncoding(Index: Integer): Boolean; virtual;

    function CanClearBuffer: Boolean; virtual;
    procedure DoClearBuffer; virtual;

    function CanSaveDoco: Boolean; virtual;
    procedure DoSaveDoco; virtual;

    function CanGrant: Boolean; virtual;
    procedure DoGrant; virtual;

    function CanRevoke: Boolean; virtual;
    procedure DoRevoke; virtual;

    function CanObjectDrop: Boolean; virtual;
    procedure DoObjectDrop; virtual;

    function CanQueryBuilder: Boolean; virtual;
    procedure DoQueryBuilder; virtual;

    function CanToggleBookmark(Index: Integer): Boolean; virtual;
    procedure DoToggleBookmark(Index: Integer); virtual;
    function IsBookmarkSet(Index: Integer): Boolean; virtual;

    function CanGotoBookmark(Index: Integer): Boolean; virtual;
    procedure DoGotoBookmark(Index: Integer); virtual;

    function CanToolsEditorProperties: Boolean; virtual;
    procedure DoToolsEditorProperties; virtual;

    function CanObjectParameters: Boolean; virtual;
    procedure DoObjectParameters; virtual;

    function CanShowQueryPlan: Boolean; virtual;
    function IsShowingQueryPlan: Boolean; virtual;
    procedure DoShowQueryPlan; virtual;

    function CanShowPerformanceData: Boolean; virtual;
    function IsShowingPerformanceData: Boolean; virtual;
    procedure DoShowPerformanceData; virtual;

    function CanExecuteAsScript: Boolean; virtual;
    function IsExecuteAsScript: Boolean; virtual;
    procedure DoExecuteAsScript; virtual;

    function CanObjectProperties: Boolean; virtual;
    procedure DoObjectProperties; virtual;

    function CanStepInto: Boolean; virtual;
    procedure DoStepInto; virtual;

    function CanAddBreakPoint: Boolean; virtual;
    procedure DoAddBreakPoint; virtual;

    function CanToggleBreakPoint: Boolean; virtual;
    procedure DoToggleBreakPoint; virtual;

    function CanAddWatchAtCursor: Boolean; virtual;
		procedure DoAddWatchAtCursor; virtual;

		function CanEvalModify: Boolean; virtual;
		procedure DoEvalModify; virtual;

    function CanResetValue: Boolean; virtual;
    procedure DoResetValue; virtual;

    function CanObjectOpenSubObject: Boolean; virtual;
    procedure DoObjectOpenSubObject; virtual;

    function CanObjectNewField: Boolean; virtual;
    procedure DoObjectNewField; virtual;

    function CanObjectNewTrigger: Boolean; virtual;
    procedure DoObjectNewTrigger; virtual;

    function CanObjectNewConstraint: Boolean; virtual;
    procedure DoObjectNewConstraint; virtual;

    function CanObjectNewIndex: Boolean; virtual;
    procedure DoObjectNewIndex; virtual;

    function CanObjectNewInputParam: Boolean; virtual;
    procedure DoObjectNewInputParam; virtual;

    function CanObjectDropField: Boolean; virtual;
    procedure DoObjectDropField; virtual;

    function CanObjectDropTrigger: Boolean; virtual;
    procedure DoObjectDropTrigger; virtual;

    function CanObjectDropConstraint: Boolean; virtual;
    procedure DoObjectDropConstraint; virtual;

    function CanObjectDropIndex: Boolean; virtual;
    procedure DoObjectDropIndex; virtual;

    function CanObjectDropInputParam: Boolean; virtual;
    procedure DoObjectDropInputParam; virtual;

    function CanObjectReorderColumns: Boolean; virtual;
		procedure DoObjectReorderColumns; virtual;

    function CanStopScriptRecord: Boolean; virtual;
    procedure DoStopScriptRecord; virtual;

    function CanStartScriptRecord: Boolean; virtual;
    procedure DoStartScriptRecord; virtual;

    function CanNewScriptRecord: Boolean; virtual;
    procedure DoNewScriptRecord; virtual;

    function CanAppendExistingScript: Boolean; virtual;
    procedure DoAppendExistingScript; virtual;

    function CanDoFolderMode: Boolean; virtual;
    function IsFolderMode: Boolean; virtual;
    procedure DoFolderMode; virtual;

    function CanDoSearchMode: Boolean; virtual;
		function IsSearchMode: Boolean; virtual;
    procedure DoSearchMode; virtual;

    function CanDoListMode: Boolean; virtual;
    function IsListMode: Boolean; virtual;
    procedure DoListMode; virtual;

    procedure OpenMessages; virtual;
    procedure AddCompileError(ErrorText: String); virtual;
    procedure ClearErrors; virtual;
    procedure ForceRefresh; virtual;
    procedure SetObjectName(Value: String); virtual;
		procedure SetObjectModified(Value: Boolean); virtual;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure ProjectOptionsRefresh; virtual;
    procedure EnvironmentOptionsRefresh; virtual;

		property InternalCaption: String read GetInternalCaption write SetInternalCaption;

    //ToolsAPI
    function IDEGetSelectedItems : IGimbalIDESelectedItems; virtual; safecall; 
  end;

implementation

{$R *.DFM}

uses
	MarathonIDE, Types;

function TfrmBaseDocumentForm.CanAddToProject: Boolean;
begin
	Result := False;
end;

function TfrmBaseDocumentForm.CanCaptureSnippet: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanConnect: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanCopy: Boolean;
begin
	Result := False;
end;

function TfrmBaseDocumentForm.CanCreateFolder: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanCut: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanDeleteItem: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanDisconnect: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanDropItem: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanExecute: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanExtractMetadata: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanInternalClose: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanItemProperties: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanNewItem: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanOpenItem: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanPaste: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanPrint: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanPrintPreview: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanRedo: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanRefresh: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanUndo: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoCopy;
begin

end;

procedure TfrmBaseDocumentForm.DoCut;
begin

end;

procedure TfrmBaseDocumentForm.DoPaste;
begin

end;

constructor TfrmBaseDocumentForm.Create(AOwner: TComponent);
begin
  inherited;
	MarathonIDEInstance.WindowList.Add(Self);
  MarathonIDEInstance.WindowListChanged := True;
end;

destructor TfrmBaseDocumentForm.Destroy;
var
	Idx: Integer;

begin
  if Assigned(MarathonIDEInstance.MainForm) then
  begin
		Idx := MarathonIDEInstance.WindowList.IndexOf(Self);
    if Idx > -1 then
    begin
      MarathonIDEInstance.WindowList.Delete(Idx);
      MarathonIDEInstance.WindowListChanged := True;
    end;
  end;  
  inherited;
end;

procedure TfrmBaseDocumentForm.DoAddToProject;
begin

end;

procedure TfrmBaseDocumentForm.DoCaptureSnippet;
begin

end;

procedure TfrmBaseDocumentForm.DoConnect;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoCreateFolder;
begin

end;

procedure TfrmBaseDocumentForm.DoDeleteItem;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoDisconnect;
begin

end;

procedure TfrmBaseDocumentForm.DoDropItem;
begin

end;

procedure TfrmBaseDocumentForm.DoExecute;
begin

end;

procedure TfrmBaseDocumentForm.DoExtractMetadata;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoInternalClose;
begin

end;

procedure TfrmBaseDocumentForm.DoItemProperties;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoNewItem;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoOpenItem;
begin
  //
end;

procedure TfrmBaseDocumentForm.DoPrint;
begin

end;

procedure TfrmBaseDocumentForm.DoPrintPreview;
begin

end;

procedure TfrmBaseDocumentForm.DoRedo;
begin

end;

procedure TfrmBaseDocumentForm.DoRefresh;
begin

end;

procedure TfrmBaseDocumentForm.DoUndo;
begin

end;

procedure TfrmBaseDocumentForm.EnvironmentOptionsRefresh;
begin
  //do nothing
end;

procedure TfrmBaseDocumentForm.FormActivate(Sender: TObject);
begin
  MarathonIDEInstance.ScreenActiveForm := Self;
end;

procedure TfrmBaseDocumentForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  MarathonIDEInstance.ScreenActiveForm := nil;
end;

function TfrmBaseDocumentForm.GetInternalCaption: String;
begin
  Result := Caption;
end;

procedure TfrmBaseDocumentForm.ProjectOptionsRefresh;
begin
  //do nothing
end;


procedure TfrmBaseDocumentForm.SetInternalCaption(const Value: String);
begin
  Caption := Value;
  MarathonIDEInstance.WindowListChanged := True;
end;

function TfrmBaseDocumentForm.CanFind: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoFind;
begin

end;

function TfrmBaseDocumentForm.CanFindNext: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoFindNext;
begin

end;

function TfrmBaseDocumentForm.CanSelectAll: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoSelectAll;
begin

end;

function TfrmBaseDocumentForm.CanViewNextStatement: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanViewPrevStatement: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoViewNextStatement;
begin

end;

procedure TfrmBaseDocumentForm.DoViewPrevStatement;
begin

end;

function TfrmBaseDocumentForm.CanStatementHistory: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoStatementHistory;
begin

end;

function TfrmBaseDocumentForm.CanViewNextPage: Boolean;
begin
	Result := False;
end;

function TfrmBaseDocumentForm.CanViewPrevPage: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoViewNextPage;
begin

end;

procedure TfrmBaseDocumentForm.DoViewPrevPage;
begin

end;

function TfrmBaseDocumentForm.CanTransactionCommit: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanTransactionRollback: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DOTransactionCommit;
begin

end;

procedure TfrmBaseDocumentForm.DoTransactionRollback;
begin

end;

function TfrmBaseDocumentForm.CanCompile: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoCompile;
begin

end;

function TfrmBaseDocumentForm.CanLoad: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoLoad;
begin

end;

function TfrmBaseDocumentForm.CanLoadFrom: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoLoadFrom;
begin

end;

function TfrmBaseDocumentForm.CanSave: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoSave;
begin

end;

function TfrmBaseDocumentForm.CanSaveAs: Boolean;
begin
	Result := False;
end;

procedure TfrmBaseDocumentForm.DoSaveAs;
begin

end;

function TfrmBaseDocumentForm.CanViewMessages: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoViewMessages;
begin

end;

function TfrmBaseDocumentForm.CanChangeEncoding: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoChangeEncoding(Index: Integer);
begin

end;

function TfrmBaseDocumentForm.IsEncoding(Index: Integer): Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanClearBuffer: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoClearBuffer;
begin

end;

function TfrmBaseDocumentForm.CanToggleBookmark(Index: Integer): Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoToggleBookmark(Index: Integer);
begin

end;

function TfrmBaseDocumentForm.IsBookmarkSet(Index: Integer): Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanGotoBookmark(Index: Integer): Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoGotoBookmark(Index: Integer);
begin

end;

function TfrmBaseDocumentForm.CanShowQueryPlan: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoShowQueryPlan;
begin

end;

function TfrmBaseDocumentForm.CanShowPerformanceData: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoShowPerformanceData;
begin

end;

function TfrmBaseDocumentForm.IsShowingQueryPlan: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.IsShowingPerformanceData: Boolean;
begin
  Result := False;
end;


function TfrmBaseDocumentForm.InternalCloseQuery: Boolean;
begin
  Result := True;
end;

function TfrmBaseDocumentForm.CanExport: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoExport;
begin

end;

function TfrmBaseDocumentForm.CanSaveDoco: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoSaveDoco;
begin

end;

function TfrmBaseDocumentForm.CanReplace: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoReplace;
begin

end;

function TfrmBaseDocumentForm.CanSaveAsTemplate: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoSaveAsTemplate;
begin

end;

function TfrmBaseDocumentForm.CanGrant: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanRevoke: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoGrant;
begin

end;

procedure TfrmBaseDocumentForm.DoRevoke;
begin

end;

function TfrmBaseDocumentForm.CanQueryBuilder: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoQueryBuilder;
begin

end;

function TfrmBaseDocumentForm.CanObjectDrop: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDrop;
begin

end;

function TfrmBaseDocumentForm.AreMessagesVisible: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.OpenMessages;
begin
  //
end;

procedure TfrmBaseDocumentForm.AddCompileError(ErrorText: String);
begin
  //
end;

procedure TfrmBaseDocumentForm.ClearErrors;
begin
 
end;

procedure TfrmBaseDocumentForm.ForceRefresh;
begin

end;

function TfrmBaseDocumentForm.GetObjectName: String;
begin
  //
end;

procedure TfrmBaseDocumentForm.SetObjectModified(Value: Boolean);
begin
  //
end;

procedure TfrmBaseDocumentForm.SetObjectName(Value: String);
begin
  //
end;

function TfrmBaseDocumentForm.CanObjectAddToProject: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectAddToProject;
begin

end;

function TfrmBaseDocumentForm.CanToolsEditorProperties: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoToolsEditorProperties;
begin

end;

function TfrmBaseDocumentForm.CanObjectParameters: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectParameters;
begin

end;

function TfrmBaseDocumentForm.GetActiveConnectionName: String;
begin
  Result := '';
end;

function TfrmBaseDocumentForm.GetActiveObjectType: TGSSCacheType;
begin
  Result := ctDontCare;
end;

function TfrmBaseDocumentForm.GetActiveStatusBar: TStatusBar;
begin
  Result := nil;
end;


function TfrmBaseDocumentForm.CanExecuteAsScript: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoExecuteAsScript;
begin

end;

function TfrmBaseDocumentForm.IsExecuteAsScript: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanObjectProperties: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectProperties;
begin

end;

procedure TfrmBaseDocumentForm.ByPassClose;
begin
  FByPassClose := True;
  Close;
end;

function TfrmBaseDocumentForm.CanStepInto: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoStepInto;
begin

end;


function TfrmBaseDocumentForm.CanAddBreakPoint: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoAddBreakPoint;
begin

end;

function TfrmBaseDocumentForm.CanToggleBreakPoint: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoToggleBreakPoint;
begin

end;

function TfrmBaseDocumentForm.CanEvalModify: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoEvalModify;
begin

end;

function TfrmBaseDocumentForm.CanResetValue: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoResetValue;
begin

end;

function TfrmBaseDocumentForm.CanObjectNewField: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectNewField;
begin

end;

function TfrmBaseDocumentForm.CanObjectNewTrigger: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectNewTrigger;
begin

end;

function TfrmBaseDocumentForm.CanObjectDropField: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDropField;
begin

end;

function TfrmBaseDocumentForm.CanObjectDropTrigger: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDropTrigger;
begin

end;

function TfrmBaseDocumentForm.CanObjectDropConstraint: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDropConstraint;
begin

end;

function TfrmBaseDocumentForm.CanObjectDropIndex: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDropIndex;
begin

end;

function TfrmBaseDocumentForm.CanObjectReorderColumns: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectReorderColumns;
begin

end;

function TfrmBaseDocumentForm.CanObjectNewConstraint: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectNewConstraint;
begin

end;

function TfrmBaseDocumentForm.CanObjectNewIndex: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectNewIndex;
begin

end;

function TfrmBaseDocumentForm.CanObjectNewInputParam: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectNewInputParam;
begin

end;

function TfrmBaseDocumentForm.CanObjectDropInputParam: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectDropInputParam;
begin

end;

function TfrmBaseDocumentForm.CanAppendExistingScript: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanNewScriptRecord: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanStartScriptRecord: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanStopScriptRecord: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoAppendExistingScript;
begin

end;

procedure TfrmBaseDocumentForm.DoNewScriptRecord;
begin

end;

procedure TfrmBaseDocumentForm.DoStartScriptRecord;
begin

end;

procedure TfrmBaseDocumentForm.DoStopScriptRecord;
begin

end;

function TfrmBaseDocumentForm.CanDoFolderMode: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanDoSearchMode: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoFolderMode;
begin

end;

procedure TfrmBaseDocumentForm.DoSearchMode;
begin

end;

function TfrmBaseDocumentForm.IsFolderMode: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.IsSearchMode: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.CanObjectOpenSubObject: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoObjectOpenSubObject;
begin

end;

function TfrmBaseDocumentForm.CanDoListMode: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoListMode;
begin

end;

function TfrmBaseDocumentForm.IsListMode: Boolean;
begin
  Result := False;
end;

function TfrmBaseDocumentForm.IDEGetSelectedItems: IGimbalIDESelectedItems;
begin
  Result := nil;
end;

function TfrmBaseDocumentForm.GetObjectNewStatus: Boolean;
begin
  Result := True;
end;

function TfrmBaseDocumentForm.CanAddWatchAtCursor: Boolean;
begin
  Result := False;
end;

procedure TfrmBaseDocumentForm.DoAddWatchAtCursor;
begin

end;

end.

{
$Log: BaseDocumentForm.pas,v $
Revision 1.5  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.4  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.3  2002/09/23 10:32:51  tmuetze
Added the possibility to load files into the SQL Editor

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
