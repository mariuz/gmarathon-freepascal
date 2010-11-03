{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************}
// $Id: DatabaseManager.pas,v 1.8 2007/02/10 22:01:14 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: DatabaseManager.pas,v $
Revision 1.8  2007/02/10 22:01:14  rjmills
Fixes for Component Library updates

Revision 1.7  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.6  2006/10/19 03:38:53  rjmills
Numerous bug fixes and current work in progress

Revision 1.5  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.4  2003/12/01 15:03:24  carlosmacao
AV when closing Project solved

Revision 1.3  2003/11/05 05:24:46  figmentsoft
Added UnloadTree method.  This method is used to release all the visual tree references before the non visual tree is deallocated.  Before this method was added, the non visual tree nodes are deallocated before the visual tree.  As a result, SOMETIMES... if Windows is in a mood to do a repaint the visual tree, it will AV since the non visual tree nodes are already deallocated.  By removing all the nodes and deallocating the visual tree first, we prevent Windows from pulling a repaint function on us which requires the non visual tree nodes to be referenced.  We can then deallocate the non visual tree safely without any risk of AV.  (at least that's my theory?!) :)  I have tested this changed code for a month already.

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit DatabaseManager;

{$I compilerdefines.inc}

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, ExtCtrls, Menus, StdCtrls, Printers, ToolWin,
	Buttons, FileCtrl, ActnList, Registry, OleCtrls,
	rmTreeNonView,
	rmSplit,
	rmPanel,
	rmPathTreeView,
	MarathonProjectCacheTypes,
	Globals,
	BaseDocumentForm,
	MarathonIDE,
	MarathonInternalInterfaces,
	MetadataSearchObject,
	GimbalToolsAPI,
	GimbalToolsAPIImpl;

type
	TfrmDatabaseExplorer = class(TfrmBaseDocumentForm, IMarathonBrowser, IGimbalIDEBrowserWindow)
		stsDatabase: TStatusBar;
		pnlTreeList: TPanel;
		pnlListContent: TrmPanel;
		pnlRichContent: TPanel;
		Image1: TImage;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		lnkOpenProject: TLabel;
		lnkCreateNewProject: TLabel;
		lnkCreateDatabase: TLabel;
		bvlOne: TBevel;
		lvRecent: TListView;
		lnkOpenSelected: TLabel;
		pnlToolbar: TPanel;
		btnViewFolders: TSpeedButton;
		btnViewSearch: TSpeedButton;
		actList: TActionList;
		ViewFolders: TAction;
		ViewSearch: TAction;
		pnlFolderSearch: TPanel;
		tvDatabase: TrmPathTreeView;
		sbSearch: TScrollBox;
		Label4: TLabel;
		edSearchString: TComboBox;
		Label5: TLabel;
		cmbSearchIn: TComboBox;
		chkSearchIn: TCheckBox;
		GroupBox1: TGroupBox;
		chkNamesOnly: TCheckBox;
		chkCase: TCheckBox;
		GroupBox2: TGroupBox;
		chkStoredProc: TCheckBox;
		chkTriggers: TCheckBox;
		chkDoco: TCheckBox;
		chkDomains: TCheckBox;
		chkTables: TCheckBox;
		chkViews: TCheckBox;
		chkGenerators: TCheckBox;
		chkExceptions: TCheckBox;
		chkUDFs: TCheckBox;
		Label6: TLabel;
		Bevel1: TBevel;
		btnSearchNow: TButton;
		btnStopSearch: TButton;
		Bevel2: TBevel;
		lnkManageItems: TLabel;
		btnViewList: TSpeedButton;
		ViewList: TAction;
		Panel1: TPanel;
		pnlListBrowser: TPanel;
		lvDatabase: TListView;
		chkSaveToFile: TCheckBox;
		dlgSave: TSaveDialog;
		SpeedButton1: TSpeedButton;
		ViewRecent: TAction;
    actWindowBroswer: TAction;
		procedure FormCreate(Sender: TObject);
		procedure tvDatabaseGetImageIndex(Sender: TObject; Node: TrmTreeNode);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure WindowListClick(Sender: TObject);
		procedure tvDatabaseMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure tvDatabaseChange(Sender: TObject; Node: TrmTreeNode);
		procedure lvDatabaseKeyPress(Sender: TObject; var Key: Char);
		procedure tvDatabaseKeyPress(Sender: TObject; var Key: Char);
		procedure tvDatabaseExpanding(Sender: TObject; Node: TrmTreeNode;	var AllowExpansion: Boolean);
		procedure tvDatabaseDblClick(Sender: TObject);
		procedure lvDatabaseDblClick(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure lnkOpenProjectClick(Sender: TObject);
		procedure lnkCreateNewProjectClick(Sender: TObject);
		procedure lnkCreateDatabaseClick(Sender: TObject);
		procedure lnkOpenSelectedClick(Sender: TObject);
		procedure ViewFoldersExecute(Sender: TObject);
		procedure ViewSearchExecute(Sender: TObject);
		procedure ViewSearchUpdate(Sender: TObject);
		procedure ViewFoldersUpdate(Sender: TObject);
		procedure btnSearchNowClick(Sender: TObject);
		procedure btnStopSearchClick(Sender: TObject);
		procedure lvDatabaseDeletion(Sender: TObject; Item: TListItem);
		procedure lnkManageItemsClick(Sender: TObject);
		procedure ViewListExecute(Sender: TObject);
		procedure ViewListUpdate(Sender: TObject);
		procedure tvDatabaseKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure lvDatabaseKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure ViewRecentUpdate(Sender: TObject);
		procedure ViewRecentExecute(Sender: TObject);
	private
		{ Private declarations }
		It : TMenuItem;
		FClipboard : TStringList;
		FSO : TMDSearchObject;
		FResFileName : String;
		FOldListisVisible : Boolean;
		procedure SavePositions;
		function GetUpdateActiveConnection : String;
		function CanDoBrowserOperation(BrowserOp : TGSSCacheOp) : Boolean;
		procedure DoBrowserOperation(Op: TGSSCacheOp);
		procedure SearchEventHandler(Sender : TObject; Event : TSearchEventType; Status : String; Item : TResultItem);
	public
		{ Public declarations }
		procedure LoadTree;
		procedure UnloadTree; //AC:
		procedure RefreshNode(Item : TObject; PreserveFocus : Boolean);
		procedure ExpandNode(Item: TObject);
		procedure RemoveNode(Item: TObject);
		procedure LoadRecentProjects;

		//file category
		function CanCut : Boolean; override;
		procedure DoCut; override;

		function CanCopy : Boolean; override;
		procedure DoCopy; override;

		function CanPaste : Boolean; override;
		procedure DoPaste; override;

		function CanInternalClose : Boolean; override;
		procedure DoInternalClose; override;

		function CanConnect : Boolean; override;
		procedure DoConnect; override;

		function CanDisconnect : Boolean; override;
		procedure DoDisconnect; override;

		function CanPrint : Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview : Boolean; override;
		procedure DoPrintPreview; override;

		function CanOpenItem : Boolean; override;
		procedure DoOpenItem; override;

		function CanNewItem : Boolean; override;
		procedure DoNewItem; override;

		function CanDeleteItem : Boolean; override;
		procedure DoDeleteItem; override;

		function CanDropItem : Boolean; override;
		procedure DoDropItem; override;

		function CanRefresh : Boolean; override;
		procedure DoRefresh; override;

		function CanItemProperties : Boolean; override;
		procedure DoItemProperties; override;

		function CanCreateFolder : Boolean; override;
		procedure DoCreateFolder; override;

		function CanAddToProject : Boolean; override;
		procedure DoAddToProject; override;

		function CanExtractMetadata : Boolean; override;
		procedure DoExtractMetadata; override;

		function CanDoFolderMode : Boolean; override;
		function IsFolderMode : Boolean; override;
		procedure DoFolderMode; override;

		function CanDoSearchMode : Boolean; override;
		function IsSearchMode : Boolean; override;
		procedure DoSearchMode; override;

		function CanDoListMode : Boolean; override;
		function IsListMode : Boolean; override;
		procedure DoListMode; override;

		//toolsAPI
		function IDEGetSelectedItems : IGimbalIDESelectedItems; override; safecall;

	end;

var
	frmDatabaseExplorer: TfrmDatabaseExplorer;

implementation

uses
	MarathonProjectCache,
	ManageBrowserItems,
	HelpMap,
	MenuModule,
	GSSRegistry;

{$R *.DFM}

procedure TfrmDatabaseExplorer.FormCreate(Sender: TObject);
var
	R : TRegistry;

begin
	FClipboard := TStringList.Create;
	FSO := TMDSearchObject.Create;
	FSO.OnSearchEvent := SearchEventHandler;

	R := TRegistry.Create;
	try
		if R.OpenKey(REG_SETTINGS_BASE, True) then
		begin
			if R.ValueExists('ViewList') then
			begin
				pnlListContent.Visible := R.ReadBool('ViewList');
			end
			else
				pnlListContent.Visible := True;
			R.CLoseKey;
		end;
	finally
		R.Free;
	end;

	LoadRecentProjects;

	HelpContext := IDH_Database_Manager;
//	It := TMenuItem.Create(Self);
//	It.Caption := '&1 Browser';
//	It.OnClick := WindowListClick;
//	frmMarathonMain.Window1_old.Add(It);  //rjm - tbmenufix
  MarathonIDEInstance.MainForm.AddMenuItem(actWindowBroswer);
	Left := MarathonScreen.Left;
	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Width := 565;
	LoadFormPosition(Self);
	LoadSplitterPosition(Self, pnlListContent);
	Show;
	Refresh;
	LoadTree;
	MarathonIDEInstance.MainForm.DoStatus('Ready');
end;

procedure TfrmDatabaseExplorer.WindowListClick(Sender: TObject);
begin
	BringToFront;
end;

procedure TfrmDatabaseExplorer.LoadTree;
var
	NodeStates : TStringList;
	SelectedItem : String;

begin
	SelectedItem := '';
	NodeStates := TStringList.Create;
	try
		try
			if MarathonIDEInstance.CurrentProject.Open then
			begin
				pnlTreeList.Visible := True;
				pnlRichContent.Visible := False;

				//save positions and open states of nodes....
				if tvDatabase.Selected <> nil then
				begin
					SelectedItem := tvDatabase.NodePath(tvDatabase.Selected);
				end;
				//------
				Screen.Cursor := crHourGlass;

				tvDatabase.Items.Clear;
				lvDatabase.Items.Clear;
				lvDatabase.Columns.Clear;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Object';
					Width := 200;
				end;
				Refresh;

				MarathonIDEInstance.CurrentProject.Cache.StartTree(tvDatabase);
			end
			else
			begin
				pnlTreeList.Visible := False;
				pnlRichContent.Visible := True;
				tvDatabase.Items.Clear;
				lvDatabase.Items.Clear;
				lvDatabase.Columns.Clear;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Object';
					Width := 200;
				end;
				Refresh;
			end;
		finally
			stsDatabase.Panels[0].Text := ' Objects';
			stsDatabase.Refresh;
			Screen.Cursor := crDefault;
		end;
	finally
		NodeStates.Free;
	end;
end;

//AC: TfrmDatabaseExplorer.UnLoadTree was added because this procedure has to
//    be executed to release all the visual tree references to the non visual
//    tree nodes before we release the non visual tree nodes.
procedure TfrmDatabaseExplorer.UnloadTree;
var
	NodeStates : TStringList;
	SelectedItem : String;

begin
	SelectedItem := '';
	NodeStates := TStringList.Create;
	try
		try
      pnlTreeList.Visible := False;
      pnlRichContent.Visible := True;
      tvDatabase.Items.Clear;
      lvDatabase.Items.Clear;
      lvDatabase.Columns.Clear;
      with lvDatabase.Columns.Add do
      begin
        Caption := 'Object';
        Width := 200;
      end;
      Refresh;
		finally
			stsDatabase.Panels[0].Text := ' Objects';
			stsDatabase.Refresh;
			Screen.Cursor := crDefault;
		end;
	finally
		NodeStates.Free;
	end;
end;

procedure TfrmDatabaseExplorer.tvDatabaseGetImageIndex(Sender: TObject; Node: TrmTreeNode);
var
	TNV : TrmTreeNonViewNode;
begin
	if Node.Data <> nil then
	begin
      TNV := TrmTreeNonViewNode(Node.Data);
      if Assigned(TNV.Data) then
      begin
        if Node.OverlayIndex <> TMarathonCacheBaseNode(TNV.Data).OverlayIndex then
           Node.OverlayIndex := TMarathonCacheBaseNode(TNV.Data).OverlayIndex;
        Node.ImageIndex := TMarathonCacheBaseNode(TNV.Data).ImageIndex;
        Node.SelectedIndex := TMarathonCacheBaseNode(TNV.Data).ImageIndex;
        Node.StateIndex := -1;
      end;
  end
  else
  begin
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
    Node.OverlayIndex := -1;
    Node.StateIndex := -1;
  end;
end;

procedure TfrmDatabaseExplorer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	It.Free;
	Action := caFree;
	FClipboard.Free;
	FSO.Free;
	SaveFormPosition(Self);
	SaveSplitterPosition(Self, pnlListContent);
	inherited;
end;

procedure TfrmDatabaseExplorer.tvDatabaseMouseDown(Sender: TObject;	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	T : TrmTreeNode;

begin
	if Button = mbRight then
	begin
		T := tvDatabase.GetNodeAt(X, Y);
		tvDatabase.Selected := T;
	end;
end;

procedure TfrmDatabaseExplorer.tvDatabaseChange(Sender: TObject; Node: TrmTreeNode);
var
	WNode: TrmTreeNode;
	WItem: TListItem;
	tscObj: TMarathonCacheBaseNode;

begin
	if MarathonIDEInstance.CurrentProject.Open then
	begin
		Screen.Cursor := crHourGlass;

		tscObj := TMarathonCacheBaseNode(TrmTreeNonViewNode(Node.Data).Data);
		if Assigned(tscObj) then
		begin
			if tscObj.ContentStr = '' then
			begin
				pnlListBrowser.Visible := False;
			end
			else
			begin
				//we need to have something to display here....
				pnlListBrowser.Visible := False;
			end;
		end
		else
		begin
			pnlListBrowser.Visible := False;
		end;

		//update the list...
		lvDatabase.Items.BeginUpdate;
		try
			lvDatabase.Items.Clear;
			lvDatabase.Columns.Clear;
			with lvDatabase.Columns.Add do
			begin
				Caption := 'Object';
				Width := 200;
			end;
			if Assigned(node) then
			begin
				WNode := Node.getFirstChild;
				while WNode <> nil do
				begin
					WItem := lvDatabase.Items.Add;
					WItem.Caption := WNode.Text;
					if Assigned(wNode.Data) then
					begin
						if Assigned(TrmTreeNonViewNode(WNode.Data).Data) then
						begin
							tscObj := TMarathonCacheBaseNode(TrmTreeNonViewNode(WNode.Data).Data);
							if assigned(tscObj) then
							begin
								WItem.Data := WNode;
								WItem.ImageIndex := tscObj.imageindex;
                wItem.OverlayIndex := tscObj.OverlayIndex;
								WItem.StateIndex := -1;
							end;
						end;
					end;
					WNode := WNode.getNextSibling;
				end;
				stsDatabase.Panels[0].Text := IntToStr(node.count) + ' item(s)';
			end
			else
				stsDatabase.Panels[0].Text := 'No item selected.';
		finally
			lvDatabase.Items.EndUpdate;
			Screen.Cursor := crDefault;
		end;
	end;
end;

procedure TfrmDatabaseExplorer.lvDatabaseKeyPress(Sender: TObject; var Key: Char);
begin
	if Key = #13 then
	begin
		if CanDoBrowserOperation(opOpen) then
			DoBrowserOperation(opOpen);
	end;
end;

procedure TfrmDatabaseExplorer.tvDatabaseKeyPress(Sender: TObject; var Key: Char);
begin
	if Key = #13 then
	begin
		if CanDoBrowserOperation(opOpen) then
			DoBrowserOperation(opOpen);
	end;
end;

procedure TfrmDatabaseExplorer.tvDatabaseExpanding(Sender: TObject; Node: TrmTreeNode; var AllowExpansion: Boolean);
var
	tnvNode, wtnvNode: TrmTreeNonViewNode;
	tscObj: TMarathonCacheBaseNode;
	WNode: TrmTreeNode;

begin
	Screen.Cursor := crHourGlass;
	try
		if (Node.Count = 0) and (Node.HasChildren) then
		begin
      tvDatabase.Items.BeginUpdate;
      try
         tnvNode := TrmTreeNonViewNode(Node.Data);
         tscObj := TMarathonCacheBaseNode(tnvNode.data);
         if assigned(tscObj) then
         begin
           if not tscObj.Expanded then
             tscObj.Expand(False);

           if tscObj.Expanded then
           begin
             wtnvNode := tnvNode.GetFirstChild;
             while wtnvNode <> nil do
             begin
               WNode := tvDatabase.Items.AddChild(Node, TMarathonCacheBaseNode(wtnvNode.data).Caption);
               WNode.Data := wtnvNode;
               WNode.HasChildren := true;
               WNode.Expanded := false;

               if Assigned(wtnvNode.Data) then
               begin
                 wNode.OverlayIndex := TMarathonCacheBaseNode(wTNVNode.Data).OverlayIndex;
                 wNode.ImageIndex := TMarathonCacheBaseNode(wTNVNode.Data).ImageIndex;
                 wNode.SelectedIndex := TMarathonCacheBaseNode(wTNVNode.Data).ImageIndex;
               end;
               
               wtnvNode := wtnvNode.GetNextSibling;
             end;
             AllowExpansion := true;
           end;
           if Node.Count = 0 then
           begin
             if (tscObj.CacheType = ctConnection) and ((tscObj as TMarathonCacheConnection).Connected = false) then
                Node.HasChildren := true
             else
                Node.HasChildren := false;
           end;
         end;
      finally
         tvDatabase.Items.EndUpdate;
      end;
		end;
	finally
		Screen.Cursor := crDefault;
	end;
end;

function TfrmDatabaseExplorer.CanConnect: Boolean;
begin
	Result := CanDoBrowserOperation(opConnect);
end;

procedure TfrmDatabaseExplorer.DoConnect;
begin
	DoBrowserOperation(opConnect);
end;

procedure TfrmDatabaseExplorer.RefreshNode(Item : TObject; PreserveFocus : Boolean);
var
	TNV : TrmTreeNonViewNode;
	TN : TrmTreeNode;
	SelNode : TrmTreeNode;
//	AllowChange: Boolean;
	WNExpanded : Boolean;
  wSelNodePath : string;
begin
	SelNode := tvDatabase.Selected;
  if SelNode <> nil then
     wSelNodePath := tvDatabase.NodePath(SelNode)
  else
     wSelNodePath := '';

  SelNode := nil;
	tvDatabase.Items.BeginUpdate;
	try
		TNV := (Item as TMarathonCacheBaseNode).ContainerNode;
    Assert(Assigned(TNV), 'TNV is not assigned');
		TN := tvDatabase.FindPathNode(TNV.NodePath);
		if Assigned(TN) then
		begin
			WNExpanded := TN.Expanded;
			(Item as TMarathonCacheBaseNode).Expanded := False;
			TN.Expanded := False;
			TN.DeleteChildren;
			TN.HasChildren := True;
			if WNExpanded then
				TN.Expand(false);
//			AllowChange := True;
			if not PreserveFocus then
			begin
//				tvDatabaseChanging(tvDatabase, TN, AllowChange);
				tvDatabaseChange(tvDatabase, TN);
			end;
		end;
	finally
		tvDatabase.Items.EndUpdate;
	end;
	if PreserveFocus then
	begin
		if wSelNodePath <> '' then
		begin
      SelNode := tvDatabase.FindPathNode(wSelNodePath);
      if assigned(SelNode) then
      begin
         SelNode.Selected := True;
         SelNode.Focused := True;
   //			tvDatabaseChanging(tvDatabase, SelNode, AllowChange);
         tvDatabaseChange(tvDatabase, SelNode);
      end;
		end;
	end;
end;

procedure TfrmDatabaseExplorer.ExpandNode(Item : TObject);
var
	TNV : TrmTreeNonViewNode;
	Path : String;
	TN : TrmTreeNode;
//	AllowChange: Boolean;

begin
	tvDatabase.Items.BeginUpdate;
	try
		TNV := (Item as TMarathonCacheBaseNode).ContainerNode;
		Path := TrmTreeNonView(TNV.TreeNonView).NodePath(TNV);
		TN := tvDatabase.FindPathNode(Path);
		if Assigned(TN) then
		begin
			TN.Expanded := False;
			TN.DeleteChildren;
			TN.HasChildren := True;
			TN.Expand(False);
//			AllowChange := True;
//			tvDatabaseChanging(tvDatabase, TN, AllowChange);
			tvDatabaseChange(tvDatabase, TN);
		end
		else
		begin
			TN.HasChildren := True;
		end;
	finally
		tvDatabase.Items.EndUpdate;
	end;
end;

procedure TfrmDatabaseExplorer.RemoveNode(Item: TObject);
var
	TNV : TrmTreeNonViewNode;
	Path : String;
	TN : TrmTreeNode;
	Idx : Integer;

begin
	tvDatabase.Items.BeginUpdate;
	try
		TNV := (Item as TMarathonCacheBaseNode).ContainerNode;
		Path := TrmTreeNonView(TNV.TreeNonView).NodePath(TNV);
		TN := tvDatabase.FindPathNode(Path);

		if Assigned(TN) then
		begin
			for Idx := 0 to lvDatabase.Items.Count - 1 do
			begin
				if lvDatabase.Items.Item[Idx].Data = TN then
				begin
					lvDatabase.Items.Item[Idx].Free;
					Break;
				end;
			end;
			TN.Free;
		end;

	finally
		tvDatabase.Items.EndUpdate;
	end;
end;

function TfrmDatabaseExplorer.CanDeleteItem: Boolean;
begin
	Result := CanDoBrowserOperation(opDelete);
end;

function TfrmDatabaseExplorer.CanDisconnect: Boolean;
begin
	Result := CanDoBrowserOperation(opDisconnect);
end;

function TfrmDatabaseExplorer.CanInternalClose: Boolean;
begin
	Result := True;
end;

function TfrmDatabaseExplorer.CanItemProperties: Boolean;
begin
	Result := CanDoBrowserOperation(opProperties);
end;

function TfrmDatabaseExplorer.CanNewItem: Boolean;
begin
	Result := CanDoBrowserOperation(opNew);
end;

function TfrmDatabaseExplorer.CanOpenItem: Boolean;
begin
	Result := CanDoBrowserOperation(opOpen);
end;

function TfrmDatabaseExplorer.CanPrint: Boolean;
begin
	Result := CanDoBrowserOperation(opPrint);
end;

function TfrmDatabaseExplorer.CanPrintPreview: Boolean;
begin
	Result := CanDoBrowserOperation(opPrintPreview);
end;

procedure TfrmDatabaseExplorer.DoDeleteItem;
begin
	DoBrowserOperation(opDelete);
end;

procedure TfrmDatabaseExplorer.DoDisconnect;
begin
	DoBrowserOperation(opDisconnect);
end;

procedure TfrmDatabaseExplorer.DoInternalClose;
begin
	Close;
end;

procedure TfrmDatabaseExplorer.DoItemProperties;
begin
	DoBrowserOperation(opProperties);
end;

procedure TfrmDatabaseExplorer.DoNewItem;
begin
	DoBrowserOperation(opNew);
end;

procedure TfrmDatabaseExplorer.DoOpenItem;
begin
	DoBrowserOperation(opOpen);
end;

procedure TfrmDatabaseExplorer.DoPrint;
begin
	DoBrowserOperation(opPrint);
end;

function TfrmDatabaseExplorer.CanDropItem: Boolean;
begin
	Result := CanDoBrowserOperation(opDrop);
end;

procedure TfrmDatabaseExplorer.DoDropItem;
begin
	DoBrowserOperation(opDrop);
end;

procedure TfrmDatabaseExplorer.DoPrintPreview;
begin
	DoBrowserOperation(opPrintPreview);
end;

function TfrmDatabaseExplorer.CanDoBrowserOperation(BrowserOp : TGSSCacheOp): Boolean;
var
	tnvNode: TrmTreeNonViewNode;
	tscObj: TMarathonCacheBaseNode;
	WNode: TrmTreeNode;
	loop: integer;

begin
	if ActiveControl = tvDatabase then
	begin
		if assigned(tvDatabase.Selected) then
		begin
			tnvNode := TrmTreeNonViewNode(tvDatabase.Selected.Data);
			if assigned(tnvNode) then
			begin
				tscObj := TMarathonCacheBaseNode(tnvNode.data);
				if assigned(tscObj) then
					result := tscObj.CanDoOperation(BrowserOp, False)
				else
					result := false;
			end
			else
				result := false;
		end
		else
			result := false;
	end
	else
		if ActiveControl = lvDatabase then
		begin
			if lvDatabase.SelCount = 0 then
				result := false
			else
				if lvDatabase.SelCount = 1 then
				begin
					if TObject(lvDatabase.Selected.Data) is TrmTreeNode then
					begin
						WNode := TrmTreeNode(lvDatabase.Selected.Data);
						if assigned(WNode) then
						begin
							tnvNode := TrmTreeNonViewNode(WNode.Data);
							if assigned(tnvNode) then
							begin
								tscObj := TMarathonCacheBaseNode(tnvNode.data);
								if assigned(tscObj) then
									result := tscObj.CanDoOperation(BrowserOp, False)
								else
									result := false;
							end
							else
								result := false;
						end
						else
							result := false;
					end
					else
					begin
						tscObj := TMarathonCacheBaseNode(lvDatabase.Selected.Data);
						if assigned(tscObj) then
							result := tscObj.CanDoOperation(BrowserOp, False)
						else
							result := false;
					end;
				end
				else
				begin
					result := true;
					loop := 0;
					while loop < lvDatabase.Items.Count do
					begin
						if lvDatabase.Items[loop].Selected then
						begin
							if TObject(lvDatabase.Items[loop].Data) is TrmTreeNode then
							begin
								WNode := TrmTreeNode(lvDatabase.Items[loop].Data);
								if assigned(WNode) then
								begin
									tnvNode := TrmTreeNonViewNode(WNode.Data);
									if assigned(tnvNode) then
									begin
										tscObj := TMarathonCacheBaseNode(tnvNode.data);
										if assigned(tscObj) then
											result := result and tscObj.CanDoOperation(BrowserOp, True)
										else
											result := false;
									end
									else
										result := false;
								end
								else
									result := false;
							end
							else
							begin
								tscObj := TMarathonCacheBaseNode(lvDatabase.Items[loop].Data);
								if assigned(tscObj) then
									result := result and tscObj.CanDoOperation(BrowserOp, True)
								else
									result := false;
							end;
						end;
						inc(loop);
					end;
				end;
		end
		else
			result := false;
end;

procedure TfrmDatabaseExplorer.DoBrowserOperation(Op: TGSSCacheOp);
var
	tnvNode: TrmTreeNonViewNode;
	tscObj: TMarathonCacheBaseNode;
	WNode: TrmTreeNode;
	loop: integer;
	ContinueFlag: boolean;
	ParentTSCObj: TMarathonCacheBaseNode;

begin
	try
		if ActiveControl = tvDatabase then
		begin
			tnvNode := TrmTreeNonViewNode(tvDatabase.Selected.Data);
			if assigned(tnvNode) then
			begin
				tscObj := TMarathonCacheBaseNode(tnvNode.data);
				if assigned(tscObj) then
					tscObj.DoOperation(Op);
			end
		end
		else
			if ActiveControl = lvDatabase then
			begin
				if lvDatabase.SelCount = 1 then
				begin
					if TObject(lvDatabase.Selected.Data) is TrmTreeNode then
					begin
						WNode := TrmTreeNode(lvDatabase.Selected.Data);
						if assigned(WNode) then
						begin
							tnvNode := TrmTreeNonViewNode(WNode.Data);
							if assigned(tnvNode) then
							begin
								tscObj := TMarathonCacheBaseNode(tnvNode.data);
								if assigned(tscObj) then
									tscObj.DoOperation(Op);
							end;
						end;
					end
					else
					begin
						tscObj := TMarathonCacheBaseNode(lvDatabase.Selected.Data);
						if assigned(tscObj) then
							tscObj.DoOperation(Op);
					end;
				end
				else
				begin
					loop := 0;
					ContinueFlag := false;
					tnvNode := nil;
					ParentTSCObj := nil;

					if TObject(lvDatabase.Selected.Data) is TrmTreeNode then
					begin
						WNode := TrmTreeNode(lvDatabase.Selected.Data);
						if assigned(WNode) then
							tnvNode := TrmTreeNonViewNode(WNode.Data);
						if assigned(tnvNode) and assigned(tnvNode.Parent) then
							ParentTSCObj := TMarathonCacheBaseNode(tnvNode.Parent.data);
						if assigned(ParentTSCObj) then
							ParentTSCObj.ClearList;
					end
					else
					begin
						ParentTSCObj := MarathonIDEInstance.CurrentProject.Cache.MultiSelectItem;
						if assigned(ParentTSCObj) then
							ParentTSCObj.ClearList;
					end;


					while loop < lvDatabase.Items.Count do
					begin
						if (Op = opOpen) and (loop >= 10) and (not ContinueFlag) then
						begin
							if Messagedlg('You have commenced a command that will open a large number of editor windows. This may have a negative impact on resource usage. Do you wish to continue?', mtConfirmation, [mbyes, mbno], 0) = idyes then
								ContinueFlag := true
							else
								break;
						end;

						if lvDatabase.items[loop].Selected then
						begin
							if TObject(lvDatabase.Items[loop].Data) is TrmTreeNode then
							begin
								WNode := TrmTreeNode(lvDatabase.items[loop].Data);
								if assigned(WNode) then
								begin
									tnvNode := TrmTreeNonViewNode(WNode.Data);
									if assigned(tnvNode) then
									begin
										tscObj := TMarathonCacheBaseNode(tnvNode.data);
										if assigned(tscObj) then
										begin
											if assigned(ParentTSCObj) then
												ParentTSCObj.AddToList(tscObj);
										end;
									end;
								end;
							end
							else
							begin
								tscObj := TMarathonCacheBaseNode(lvDatabase.Items[loop].Data);
								if assigned(tscObj) then
								begin
									if assigned(ParentTSCObj) then
										ParentTSCObj.AddToList(tscObj);
								end;
							end;
						end;
						inc(loop);
					end;
					if assigned(ParentTSCObj) then
						ParentTSCObj.DoOperation(Op);
				end;
			end;
	finally

	end;
end;

function TfrmDatabaseExplorer.CanRefresh: Boolean;
begin
	Result := CanDoBrowserOperation(opRefresh);
end;

procedure TfrmDatabaseExplorer.DoRefresh;
begin
	DoBrowserOperation(opRefresh);
end;

function TfrmDatabaseExplorer.CanExtractMetadata: Boolean;
begin
	Result := CanDoBrowserOperation(opExtractDDL);
end;

procedure TfrmDatabaseExplorer.DoExtractMetadata;
begin
	DoBrowserOperation(opExtractDDL);
end;

function TfrmDatabaseExplorer.CanAddToProject: Boolean;
begin
	Result := CanDoBrowserOperation(opAddToProject);
end;

function TfrmDatabaseExplorer.CanCreateFolder: Boolean;
begin
	Result := CanDoBrowserOperation(opCreateFolder);
end;

procedure TfrmDatabaseExplorer.DoAddToProject;
begin
	DoBrowserOperation(opAddToProject);
end;

procedure TfrmDatabaseExplorer.DoCreateFolder;
begin
	DoBrowserOperation(opCreateFOlder);
end;

procedure TfrmDatabaseExplorer.tvDatabaseDblClick(Sender: TObject);
begin
	if tvDatabase.Selected <> nil then
	begin
		if CanDoBrowserOperation(opOpen) then
			DoBrowserOperation(opOpen)
		else
			if CanDoBrowserOperation(opConnect) then
				DoBrowserOperation(opConnect)
	end;
end;

procedure TfrmDatabaseExplorer.lvDatabaseDblClick(Sender: TObject);
begin
	if lvDatabase.Selected <> nil then
	begin
		if CanDoBrowserOperation(opOpen) then
			DoBrowserOperation(opOpen)
		else
			if CanDoBrowserOperation(opConnect) then
				DoBrowserOperation(opConnect)
	end;
end;

function TfrmDatabaseExplorer.GetUpdateActiveConnection: String;
var
	N : TrmTreeNode;
	tscObj: TMarathonCacheBaseNode;
	tnvNode: TrmTreeNonViewNode;

begin
	N := tvDatabase.FocussedNode;
	if Assigned(N) then
	begin
		tnvNode := TrmTreeNonViewNode(N.Data);
		if assigned(tnvNode) then
		begin
			tscObj := TMarathonCacheBaseNode(tnvNode.data);
			if assigned(tscObj) then
			begin
				case tscObj.CacheType of
					 ctConnection:
						 begin
							 Result := TMarathonCacheConnection(tscObj).Caption;
						 end;

					 ctDomainHeader,
					 ctTableHeader,
					 ctViewHeader,
					 ctSPHeader,
					 ctTriggerHeader,
					 ctGeneratorHeader,
					 ctExceptionHeader,
					 ctUDFHeader:
						 begin
							 Result := TMarathonCacheHeader(tscObj).ConnectionName;
						 end;

					 ctDomain,
					 ctTable,
					 ctView,
					 ctSP,
					 ctTrigger,
					 ctGenerator,
					 ctException,
					 ctUDF:
						 begin
							 Result := TMarathonCacheObject(tscObj).ConnectionName;
						 end;
				else
					Result := '';
				end;
			end
			else
				Result := '';
		end
		else
			Result := '';
	end
	else
	begin
		Result := '';
	end;
end;

procedure TfrmDatabaseExplorer.LoadRecentProjects;
var
	R : TRegistry;
	RList : TStringList;
	Idx : Integer;

begin
	R := TRegistry.Create;
	try
		RList := TStringList.Create;
		try
			if R.OpenKey(REG_SETTINGS_RECENTPROJECTS, True) then
			begin
				if R.ValueExists('Data') then
				begin
					RList.Text := R.ReadString('Data');
					for Idx := 0 to RList.Count -1 do
					begin
						//bit of a sanity check to see whether the file exists or not...
						if FileExists(RList[Idx]) then
						begin
							with lvRecent.Items.Add do
							begin
								Caption := RList[Idx];
								if ExtractFileExt(Caption) = '.xmpr' then
								begin
									SubItems.Add(QueryProjectFile(Caption));
								end;
							end;
						end;	
					end;
				end;
				R.CloseKey;
			end;
		finally
			RList.Free;
		end;
	finally
		R.Free;
	end;
end;

procedure TfrmDatabaseExplorer.FormResize(Sender: TObject);
begin
	//we are resizing controls here because dumb constraints
	//don't seem to work properly
	bvlOne.Width := pnlRichContent.Width - bvlOne.Left - 15;
	lvRecent.Width := pnlRichContent.Width - lvRecent.Left - 15;
	lvRecent.Height := pnlRichContent.Height - lvRecent.Top - 30;
	lnkOpenSelected.Left := pnlRichContent.Width - lnkOpenSelected.Width - 15;
	lnkOpenSelected.Top := lvRecent.Height + lvRecent.Top + 5;
	lnkManageItems.Left := lvRecent.Left;
	lnkManageItems.Top := lvRecent.Height + lvRecent.Top + 5;
end;

procedure TfrmDatabaseExplorer.lnkOpenProjectClick(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.FileOpenProject;
end;

procedure TfrmDatabaseExplorer.lnkCreateNewProjectClick(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.FileNewProject;
end;

procedure TfrmDatabaseExplorer.lnkCreateDatabaseClick(Sender: TObject);
begin
	inherited;
	MarathonIDEInstance.FileCreateDatabase;
end;

procedure TfrmDatabaseExplorer.lnkOpenSelectedClick(Sender: TObject);
var
	FExt : String;
begin
	inherited;
	if lvRecent.Selected <> nil then
	begin
		FExt := ExtractFileExt(lvRecent.Selected.Caption);

		if FExt = '.xmpr' then
		begin
			if MarathonIDEInstance.FileCloseProject then
				MarathonIDEInstance.OpenProject(lvRecent.Selected.Caption);
		end
		else
			MarathonIDEInstance.FileOpenNamedFile(lvRecent.Selected.Caption);
	end;
end;

function TfrmDatabaseExplorer.CanCopy: Boolean;
var
	tnvNode: TrmTreeNonViewNode;
	tscObj: TMarathonCacheBaseNode;
	WNode: TrmTreeNode;
	loop: integer;

begin
	if ActiveControl = tvDatabase then
	begin
		if assigned(tvDatabase.Selected) then
		begin
			tnvNode := TrmTreeNonViewNode(tvDatabase.Selected.Data);
			if assigned(tnvNode) then
			begin
				tscObj := TMarathonCacheBaseNode(tnvNode.data);
				if assigned(tscObj) then
				begin
					Result := False;

				end
				else
					result := false;
			end
			else
				result := false;
		end
		else
			result := false;
	end
	else
		if ActiveControl = lvDatabase then
		begin
			if lvDatabase.SelCount = 0 then
				result := false
			else
				if lvDatabase.SelCount = 1 then
				begin
					if TObject(lvDatabase.Selected.Data) is TrmTreeNode then
					begin
						WNode := TrmTreeNode(lvDatabase.Selected.Data);
						if assigned(WNode) then
						begin
							tnvNode := TrmTreeNonViewNode(WNode.Data);
							if assigned(tnvNode) then
							begin
								tscObj := TMarathonCacheBaseNode(tnvNode.data);
								if assigned(tscObj) then
								begin
									Result := False;
								end
								else
									result := false;
							end
							else
								result := false;
						end
						else
							result := false;
					end
					else
					begin
						tscObj := TMarathonCacheBaseNode(lvDatabase.Selected.Data);
						if assigned(tscObj) then
						begin
							Result := False;
						end
						else
							result := false;
					end;
				end
				else
				begin
					result := true;
					loop := 0;
					while loop < lvDatabase.Items.Count do
					begin
						if lvDatabase.Items[loop].Selected then
						begin
							if TObject(lvDatabase.Items[loop].Data) is TrmTreeNode then
							begin
								WNode := TrmTreeNode(lvDatabase.Items[loop].Data);
								if assigned(WNode) then
								begin
									tnvNode := TrmTreeNonViewNode(WNode.Data);
									if assigned(tnvNode) then
									begin
										tscObj := TMarathonCacheBaseNode(tnvNode.data);
										if assigned(tscObj) then
										begin
											Result := False;
										end
										else
											result := false;
									end
									else
										result := false;
								end
								else
									result := false;
							end
							else
							begin
								tscObj := TMarathonCacheBaseNode(lvDatabase.Items[loop].Data);
								if assigned(tscObj) then
								begin
									Result := False;
								end
								else
									result := false;
							end;
						end;
						inc(loop);
					end;
				end;
		end
		else
			result := false;
end;

function TfrmDatabaseExplorer.CanCut: Boolean;
begin
	Result := False;
end;

function TfrmDatabaseExplorer.CanPaste: Boolean;
begin
	Result := False;
end;

procedure TfrmDatabaseExplorer.DoCopy;
begin
end;

procedure TfrmDatabaseExplorer.DoCut;
begin
end;

procedure TfrmDatabaseExplorer.DoPaste;
begin
end;

function TfrmDatabaseExplorer.CanDoFolderMode: Boolean;
begin
	Result := MarathonIDEInstance.CurrentProject.Open;
end;

function TfrmDatabaseExplorer.CanDoSearchMode: Boolean;
begin
	Result := MarathonIDEInstance.CurrentProject.Open;
end;

procedure TfrmDatabaseExplorer.DoFolderMode;
var
	R : TRegistry;
	WasSearchMode : Boolean;

begin
	if FSO.Searching then
	begin
		MessageDlg('There is a search in progress. Stop the search before attempting to switch views.', mtInformation, [mbOK], 0);
		Exit;
	end;
	if IsSearchMode then
	begin
		WasSearchMode := True;
	end
	else
	begin
		WasSearchMode := False;
	end;
	tvDatabase.Visible := True;
	sbSearch.Visible := False;
	if WasSearchMode then
	begin
		pnlListContent.Visible := FOldListisVisible;

		R := TRegistry.Create;
		try
			if R.OpenKey(REG_SETTINGS_BASE, True) then
			begin
				R.WriteBool('ViewList', pnlListContent.Visible);
				R.CLoseKey;
			end;
		finally
			R.Free;
		end;
	end;
end;

procedure TfrmDatabaseExplorer.DoSearchMode;
var
	Idy : Integer;

begin
	if FSO.Searching then
	begin
		MessageDlg('There is a search in progress. Stop the search before attempting to switch views.', mtInformation, [mbOK], 0);
		Exit;
	end;
	tvDatabase.Visible := False;
	sbSearch.Visible := True;
	FOldListisVisible := IsListMode;
	if not IsListMode then
		DoListMode;

	for Idy := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
	begin
		cmbSearchIn.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idy].Caption);
	end;
	if cmbSearchIn.Items.Count > 0 then
		cmbSearchIn.ItemIndex := 0;

	edSearchString.Items.Assign(MarathonIDEInstance.CurrentProject.MetaSearchStrings);
	edSearchString.Text := MarathonIDEInstance.CurrentProject.LastMetaSearchString;

	chkCase.Checked := soCaseSensitive in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkNamesOnly.Checked	:= soNamesOnly in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkDomains.Checked := soDomains in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkTables.Checked := soTables in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkViews.Checked := soViews in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkTriggers.Checked := soTrig in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkStoredProc.Checked := soSP in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkGenerators.Checked := soGenerators in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkExceptions.Checked := soExceptions in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkUDFs.Checked := soUDFs in MarathonIDEInstance.CurrentProject.SearchOptions;
	chkDoco.Checked := soDoco in MarathonIDEInstance.CurrentProject.SearchOptions;
	edSearchString.SetFocus;
end;

function TfrmDatabaseExplorer.IsFolderMode: Boolean;
begin
	Result := tvDatabase.Visible;
end;

function TfrmDatabaseExplorer.IsSearchMode: Boolean;
begin
	Result := sbSearch.Visible;
end;

procedure TfrmDatabaseExplorer.ViewFoldersExecute(Sender: TObject);
begin
	DoFolderMode;
end;

procedure TfrmDatabaseExplorer.ViewSearchExecute(Sender: TObject);
begin
	DoSearchMode;
end;

procedure TfrmDatabaseExplorer.ViewSearchUpdate(Sender: TObject);
begin
	btnViewSearch.Down := IsSearchMode;
	(Sender As TAction).Enabled := CanDoSearchMode;
end;

procedure TfrmDatabaseExplorer.ViewFoldersUpdate(Sender: TObject);
begin
	btnViewFolders.Down := IsFolderMode;
	(Sender As TAction).Enabled := CanDoFolderMode;
end;

procedure TfrmDatabaseExplorer.btnSearchNowClick(Sender: TObject);
var
	SearchString : String;
	Options : TSearchOptions;
	Idx : Integer;

begin
	if not FSO.Searching then
	begin
		if chkSaveToFile.Checked then
		begin
			if dlgSave.Execute then
			begin
				FResFileName := dlgSave.FileName;
			end
			else
			 Exit;
		end;

		MarathonIDEInstance.CurrentProject.LastMetaSearchString := edSearchString.Text;
		if MarathonIDEInstance.CurrentProject.MetaSearchStrings.IndexOf(MarathonIDEInstance.CurrentProject.LastMetaSearchString) = -1 then
			MarathonIDEInstance.CurrentProject.MetaSearchStrings.Add(MarathonIDEInstance.CurrentProject.LastMetaSearchString);

		SearchString := edSearchString.Text;
		Options := [];
		if chkCase.Checked then
			Include(Options, soCaseSensitive);
		if chkNamesOnly.Checked then
			Include(Options, soNamesOnly);

		if chkDomains.Checked then
			Include(Options, soDomains);
		if chkTables.Checked then
			Include(Options, soTables);
		if chkViews.Checked then
			Include(Options, soViews);
		if chkTriggers.Checked then
			Include(Options, soTrig);
		if chkStoredProc.Checked then
			Include(Options, soSP);
		if chkGenerators.Checked then
			Include(Options, soGenerators);
		if chkExceptions.Checked then
			Include(Options, soExceptions);
		if chkUDFs.Checked then
			Include(Options, soUDFs);
		if chkDoco.Checked then
			Include(Options, soDoco);
		MarathonIDEInstance.CurrentProject.SearchOptions := Options;

		btnSearchNow.Enabled := False;
		btnStopSearch.Enabled := True;
		sbSearch.Enabled := False;

		FSO.SearchString := SearchString;
		FSO.Options := Options;

		FSO.ConnectionList.Clear;
		if chkSearchIn.Checked then
		begin
			for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
			begin
				FSO.ConnectionList.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
			end;
		end
		else
		begin
			FSO.ConnectionList.Add(cmbSearchIn.Text);
		end;

		FSO.Execute;
	end
	else
	begin
		MessageDlg('Marathon is already searching. Click Stop to stop the search.', mtInformation, [mbOK], 0);
	end;
end;

procedure TfrmDatabaseExplorer.btnStopSearchClick(Sender: TObject);
begin
	FSO.Terminated := True;
end;

procedure TfrmDatabaseExplorer.SearchEventHandler(Sender: TObject; Event: TSearchEventType; Status: String; Item: TResultItem);
var
	wNode : TMarathonCacheBaseNode;
	Line : String;
	Idx : Integer;
	L : TStringList;

begin
	case Event of
		setError:
			begin

			end;

		setStart:
			begin
				MarathonIDEInstance.CurrentProject.Cache.ClearSearchList;
				lvDatabase.Items.Clear;
				lvDatabase.Columns.Clear;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Object';
					Width := 200;
				end;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Text';
					Width := 400;
				end;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Line';
					Width := 50;
				end;
				with lvDatabase.Columns.Add do
				begin
					Caption := 'Column';
					Width := 50;
				end;
			end;

		setFinish:
			begin
				if chkSaveToFile.Checked then
				begin
					L := TStringList.Create;
					try
						for Idx := 0 to lvDatabase.Items.Count - 1 do
						begin
							Line := lvDatabase.Items.Item[Idx].Caption + #9 +
											lvDatabase.Items.Item[Idx].SubItems[0] + #9 +
											lvDatabase.Items.Item[Idx].SubItems[1] + #9 +
											lvDatabase.Items.Item[Idx].SubItems[2];
							L.Add(Line);
						end;
						try
							L.SaveToFile(FResFileName);
						except
							On E : Exception do
							begin
								MessageDlg('Unable to save results file.', mtError, [mbOK], 0);
							end;
						end;	
					finally
						L.Free;
					end;
				end;
				btnSearchNow.Enabled := True;
				btnStopSearch.Enabled := False;
				sbSearch.Enabled := True;
				stsDatabase.Panels[0].Text := 'Search Complete';
			end;

		setMDStatus:
			begin
				stsDatabase.Panels[0].Text := Status;
			end;

		setItemFound:
			begin
				case Item.ObjType of
					ctTable :
						begin
							wNode := TMarathonCacheTable.Create;
						end;
					ctDomain :
						begin
							wNode := TMarathonCacheDomain.Create;
						end;
					ctView :
						begin
							wNode := TMarathonCacheView.Create;
						end;
					ctSP :
						begin
							wNode := TMarathonCacheProcedure.Create;
						end;
					ctTrigger :
						begin
							wNode := TMarathonCacheTrigger.Create;
						end;
					ctException :
						begin
							wNode := TMarathonCacheException.Create;
						end;
					ctGenerator :
						begin
							wNode := TMarathonCacheGenerator.Create;
						end;
					ctUDF :
						begin
							wNode := TMarathonCacheFunction.Create;
						end;
				else
					wNode := nil;
				end;
				if Assigned(wNode) then
				begin
					MarathonIDEInstance.CurrentProject.Cache.SearchList.Add(wNode);
					wNode.ContainerNode := nil;
					wNode.RootItem := nil;
					wNode.Caption := Item.ObjName;
					wNode.RootItem := MarathonIDEInstance.CurrentProject.Cache;
					TMarathonCacheObject(wNode).ObjectName := Item.ObjName;
					TMarathonCacheObject(wNode).ConnectionName := Item.ConnectionName;
					with lvDatabase.Items.Add do
					begin
						Caption := Item.ObjName;
						ImageIndex := wNode.ImageIndex;
						SubItems.Add(Item.LineText);
						SubItems.Add(IntToStr(Item.Line));
						SubItems.Add(IntToStr(Item.Position));
						Data := wNode;
					end;
				end;
			end;
	end;
end;

procedure TfrmDatabaseExplorer.lvDatabaseDeletion(Sender: TObject; Item: TListItem);
begin
//
end;

procedure TfrmDatabaseExplorer.lnkManageItemsClick(Sender: TObject);
var
	FM : TfrmManageBrowserItems;
	R : TRegistry;
	Tmp : TStringList;
	Idx : Integer;

begin
	inherited;
	FM := TfrmManageBrowserItems.Create(Self);
	try
		FM.lvRecent.Items.Assign(lvRecent.Items);
		if FM.ShowModal = mrOK then
		begin
			lvRecent.Items.Assign(FM.lvRecent.Items);

			R := TRegistry.Create;
			try
				if R.OpenKey(REG_SETTINGS_RECENTPROJECTS, True) then
				begin
					Tmp := TStringList.Create;
					try
						for Idx := 0 to lvRecent.Items.Count - 1 do
							Tmp.Add(lvRecent.Items.Item[Idx].Caption);

						R.WriteString('Data', Tmp.Text);
					finally
						Tmp.Free;
					end;
					R.CloseKey;
				end;
			finally
				R.Free;
			end;
			if Assigned(MarathonIDEInstance.MainForm) then
				MarathonIDEInstance.MainForm.LoadMRUMenu;
		end;
	finally
		FM.Free;
	end;
end;

function TfrmDatabaseExplorer.CanDoListMode: Boolean;
begin
	Result := MarathonIDEInstance.CurrentProject.Open and (not IsSearchMode);
end;

procedure TfrmDatabaseExplorer.DoListMode;
var
	R : TRegistry;

begin
	if IsListMode then
	begin
		pnlListContent.Visible := False;
	end
	else
	begin
		pnlListContent.Visible := True;
	end;

	R := TRegistry.Create;
	try
		if R.OpenKey(REG_SETTINGS_BASE, True) then
		begin
			R.WriteBool('ViewList', pnlListContent.Visible);
			R.CLoseKey;
		end;
	finally
		R.Free;
	end;
end;

function TfrmDatabaseExplorer.IsListMode: Boolean;
begin
	Result := pnlListContent.Visible;
end;

procedure TfrmDatabaseExplorer.ViewListExecute(Sender: TObject);
begin
	DoListMode;
end;

procedure TfrmDatabaseExplorer.ViewListUpdate(Sender: TObject);
begin
	btnViewList.Down := IsListMode;
	(Sender As TAction).Enabled := CanDoListMode;
end;

function TfrmDatabaseExplorer.IDEGetSelectedItems: IGimbalIDESelectedItems;
var
	Items : TGimbalIDESelectedItems;
	Item : TGimbalIDESelectedItem;
	tnvNode : TrmTreeNonViewNode;
	tscObj : TMarathonCacheBaseNode;
	WNode : TrmTreeNode;
	loop : Integer;

begin
	Items := TGimbalIDESelectedItems.Create;
	Result := Items;
	if ActiveControl = tvDatabase then
	begin
		tnvNode := TrmTreeNonViewNode(tvDatabase.Selected.Data);
		if assigned(tnvNode) then
		begin
			tscObj := TMarathonCacheBaseNode(tnvNode.data);
			if assigned(tscObj) then
			begin
				Item := Items.Add;
				Item.Name := tscObj.Caption;
				Item.ItemType := CacheTypetoItemType(tscObj.CacheType);
				if (tscObj is TMarathonCacheConnection) then
					Item.ConnectionName := tscObj.Caption;

				if (tscObj is TMarathonCacheHeader) then
					Item.ConnectionName := TMarathonCacheHeader(tscObj).ConnectionName;

				if (tscObj is TMarathonCacheObject) then
					Item.ConnectionName := TMarathonCacheObject(tscObj).ConnectionName;
			end;
		end
	end
	else
	begin
		if ActiveControl = lvDatabase then
		begin
			if lvDatabase.SelCount = 1 then
			begin
				if TObject(lvDatabase.Selected.Data) is TrmTreeNode then
				begin
					WNode := TrmTreeNode(lvDatabase.Selected.Data);
					if assigned(WNode) then
					begin
						tnvNode := TrmTreeNonViewNode(WNode.Data);
						if assigned(tnvNode) then
						begin
							tscObj := TMarathonCacheBaseNode(tnvNode.data);
							if Assigned(tscObj) then
							begin
								Item := Items.Add;
								Item.Name := tscObj.Caption;
								Item.ItemType := CacheTypetoItemType(tscObj.CacheType);
								if (tscObj is TMarathonCacheConnection) then
									Item.ConnectionName := tscObj.Caption;

								if (tscObj is TMarathonCacheHeader) then
									Item.ConnectionName := TMarathonCacheHeader(tscObj).ConnectionName;

								if (tscObj is TMarathonCacheObject) then
									Item.ConnectionName := TMarathonCacheObject(tscObj).ConnectionName;
							end;
						end;
					end;
				end
				else
				begin
					tscObj := TMarathonCacheBaseNode(lvDatabase.Selected.Data);
					if assigned(tscObj) then
					begin
						Item := Items.Add;
						Item.Name := tscObj.Caption;
						Item.ItemType := CacheTypetoItemType(tscObj.CacheType);
						if (tscObj is TMarathonCacheConnection) then
							Item.ConnectionName := tscObj.Caption;

						if (tscObj is TMarathonCacheHeader) then
							Item.ConnectionName := TMarathonCacheHeader(tscObj).ConnectionName;

						if (tscObj is TMarathonCacheObject) then
							Item.ConnectionName := TMarathonCacheObject(tscObj).ConnectionName;
					end;
				end;
			end
			else
			begin
				loop := 0;
				while loop < lvDatabase.Items.Count do
				begin
					if lvDatabase.items[loop].Selected then
					begin
						if TObject(lvDatabase.Items[loop].Data) is TrmTreeNode then
						begin
							WNode := TrmTreeNode(lvDatabase.items[loop].Data);
							if assigned(WNode) then
							begin
								tnvNode := TrmTreeNonViewNode(WNode.Data);
								if assigned(tnvNode) then
								begin
									tscObj := TMarathonCacheBaseNode(tnvNode.data);
									if assigned(tscObj) then
									begin
										Item := Items.Add;
										Item.Name := tscObj.Caption;
										Item.ItemType := CacheTypetoItemType(tscObj.CacheType);
										if (tscObj is TMarathonCacheConnection) then
											Item.ConnectionName := tscObj.Caption;

										if (tscObj is TMarathonCacheHeader) then
											Item.ConnectionName := TMarathonCacheHeader(tscObj).ConnectionName;

										if (tscObj is TMarathonCacheObject) then
											Item.ConnectionName := TMarathonCacheObject(tscObj).ConnectionName;
									end;
								end;
							end;
						end
						else
						begin
							tscObj := TMarathonCacheBaseNode(lvDatabase.Items[loop].Data);
							if assigned(tscObj) then
							begin
								Item := Items.Add;
								Item.Name := tscObj.Caption;
								Item.ItemType := CacheTypetoItemType(tscObj.CacheType);
								if (tscObj is TMarathonCacheConnection) then
									Item.ConnectionName := tscObj.Caption;

								if (tscObj is TMarathonCacheHeader) then
									Item.ConnectionName := TMarathonCacheHeader(tscObj).ConnectionName;

								if (tscObj is TMarathonCacheObject) then
									Item.ConnectionName := TMarathonCacheObject(tscObj).ConnectionName;
							end;
						end;
					end;
					inc(loop);
				end;
			end;
		end;
	end;
end;

procedure TfrmDatabaseExplorer.tvDatabaseKeyDown(Sender: TObject;	var Key: Word; Shift: TShiftState);
begin
	inherited;
	if (Key = VK_INSERT) and (Shift = []) then
		if CanDoBrowserOperation(opNew) then
			DoBrowserOperation(opNew);
	if (Key = VK_DELETE) and (Shift = []) then
		if CanDoBrowserOperation(opDrop) then
			DoBrowserOperation(opDrop);
end;

procedure TfrmDatabaseExplorer.lvDatabaseKeyDown(Sender: TObject;	var Key: Word; Shift: TShiftState);
begin
	inherited;
	if (Key = VK_INSERT) and (Shift = []) then
		if CanDoBrowserOperation(opNew) then
			DoBrowserOperation(opNew);
	if (Key = VK_DELETE) and (Shift = []) then
		if CanDoBrowserOperation(opDrop) then
			DoBrowserOperation(opDrop);
end;

procedure TfrmDatabaseExplorer.SavePositions;
begin
	SaveFormPosition(Self);
	SaveSplitterPosition(Self, pnlListContent);
end;

procedure TfrmDatabaseExplorer.ViewRecentUpdate(Sender: TObject);
begin
	inherited;
	(Sender as TAction).Enabled := MarathonIDEInstance.CurrentProject.Open and tvDatabase.Visible;
end;

procedure TfrmDatabaseExplorer.ViewRecentExecute(Sender: TObject);
var
	N : TrmTreeNode;
begin
	inherited;
	N := tvDatabase.FindPathNode(#2 + 'Recent');
	if Assigned(N) then
	begin
		N.Selected := True;
		N.Focused := True;
	end;
end;

end.


