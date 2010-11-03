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
// $Id: CodeSnippets.pas,v 1.10 2006/10/22 06:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: CodeSnippets.pas,v $
Revision 1.10  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.9  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.7  2002/09/23 10:15:20  tmuetze
Completeted the revisiting of the Code Snippets functionality, also added a patch from Paul Gittings to support drag&drop in the Code Snippets window

Revision 1.6  2002/08/28 14:56:56  tmuetze
Revised the Code Snippets functionality, only SaveSnippetAs.* needs revising

Revision 1.5  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit CodeSnippets;

interface

{$I compilerdefines.inc}

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls, Menus, Registry, FileCtrl, ActnList, Buttons,
	rmPathTreeView,
	Globals,
  MarathonIDE;

type
	TfrmCodeSnippets = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    memCodeSnippets: TMemo;
    tvCodeSnippets: TrmPathTreeView;
    PopupMenu1: TPopupMenu;
    mnuiStayOnTop: TMenuItem;
    N1: TMenuItem;
    mnuiClose: TMenuItem;
    mnuiNew: TMenuItem;
    DeleteFolder1: TMenuItem;
    N2: TMenuItem;
		mnuiRename: TMenuItem;
    N4: TMenuItem;
    ActionList1: TActionList;
    actStayOnTop: TAction;
    actNewFolder: TAction;
		actNewSnippet: TAction;
		actDeleteFolder: TAction;
		actDeleteSnippet: TAction;
		actRename: TAction;
		actClose: TAction;
		actEditSnippet: TAction;
    mnuiNewFolder: TMenuItem;
		mnuiNewSnippet: TMenuItem;
		Folder2: TMenuItem;
		Snippet2: TMenuItem;
    mnuiEditSnippet: TMenuItem;
		actCopy: TAction;
    mnuiCopy: TMenuItem;
    sbtnToolWin: TSpeedButton;
    N3: TMenuItem;
    mnuiFullExpand: TMenuItem;
    mnuiFullCollapse: TMenuItem;
    actFullExpand: TAction;
    actFullCollapse: TAction;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure tvCodeSnippetsChange(Sender: TObject; Node: TrmTreeNode);
		procedure tvCodeSnippetsMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure tvCodeSnippetsStartDrag(Sender: TObject; var DragObject: TDragObject);
		procedure actStayOnTopExecute(Sender: TObject);
		procedure actStayOnTopUpdate(Sender: TObject);
		procedure actNewFolderExecute(Sender: TObject);
		procedure actNewFolderUpdate(Sender: TObject);
		procedure actNewSnippetExecute(Sender: TObject);
		procedure actNewSnippetUpdate(Sender: TObject);
		procedure actDeleteFolderExecute(Sender: TObject);
		procedure actDeleteFolderUpdate(Sender: TObject);
		procedure actDeleteSnippetExecute(Sender: TObject);
		procedure actDeleteSnippetUpdate(Sender: TObject);
		procedure actEditSnippetExecute(Sender: TObject);
		procedure actEditSnippetUpdate(Sender: TObject);
		procedure actRenameExecute(Sender: TObject);
		procedure actRenameUpdate(Sender: TObject);
		procedure actCopyExecute(Sender: TObject);
		procedure actCopyUpdate(Sender: TObject);
		procedure actFullExpandExecute(Sender: TObject);
		procedure actFullCollapseExecute(Sender: TObject);
		procedure actCloseExecute(Sender: TObject);
		procedure sbtnToolWinClick(Sender: TObject);
		procedure tvCodeSnippetsDblClick(Sender: TObject);
		procedure tvCodeSnippetsDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure tvCodeSnippetsDragOver(Sender, Source: TObject; X,
			Y: Integer; State: TDragState; var Accept: Boolean);
		procedure tvCodeSnippetsCompare(Sender: TObject; Node1,
			Node2: TrmTreeNode; Data: Integer; var Compare: Integer);
		procedure tvCodeSnippetsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
	private
		{ Private declarations }
		FOnTop: Boolean;
		FCarla: TDragQueenCarla;
		procedure RecurseAdd(FullPath, Snip: String; Node: TrmTreeNode);
		procedure CatalogSnippets(Path: String; Node: TrmTreeNode);
		public
		{ Public declarations }
		procedure LoadSnippets;
		procedure AddSnippet(Snip: String);
	end;

var
	frmCodeSnippets: TfrmCodeSnippets;

implementation

uses
	InputDialog,
	EditorSnippet,
	HelpMap,
	GSSRegistry;

{$R *.DFM}

procedure TfrmCodeSnippets.RecurseAdd(FullPath, Snip: String; Node: TrmTreeNode);
var
	N: TrmTreeNode;
	P: PNodeData;
	L: TStringList;

begin
	N := tvCodeSnippets.AddPathNode(nil, '\Snippets' + FullPath);
	New(P);
	P^.Caption := Snip;
	L := TStringList.Create;
	try
		L.LoadFromFile(gSnippetsDir + FullPath);
		P^.NodeText := L.Text;
	finally
		L.Free;
	end;
	N.Data := P;
	N.ImageIndex := 10;
	N.SelectedIndex := 10;
end;

procedure TfrmCodeSnippets.CatalogSnippets(Path: String; Node: TrmTreeNode);
var
	R: TSearchRec;
	Res: Integer;
	N: TrmTreeNode;
	P: PNodeData;
	L: TStringList;

begin
	Res := FindFirst(Path + '\*.*', faAnyFile, R);
	while Res = 0 do
	begin
		if R.Attr = faDirectory then
		begin
			if ((R.Name <> '.') and (R.Name <> '..')) then
			begin
				N := tvCodeSnippets.Items.AddChild(Node, R.Name);
				CatalogSnippets(Path + '\' + R.Name, N);
				N.ImageIndex := 1;
				N.SelectedIndex := 1;
			end;
		end
		else
		begin
			if (ExtractFileExt(R.Name) = '.snp') or (ExtractFileExt(R.Name) = '.txt')
				or (ExtractFileExt(R.Name) = '.sql') then
			begin
				N := tvCodeSnippets.Items.AddChild(Node, R.Name);
				New(P);
				P^.Caption := R.Name;
				L := TStringList.Create;
				try
					L.LoadFromFile(Path + '\' + R.Name);
					P^.NodeText := L.Text;
				finally
					L.Free;
				end;
				N.Data := P;
				N.ImageIndex := 10;
				N.SelectedIndex := 10;
			end;
		end;
		Res := FindNext(R);
	end;
	FindClose(R);

	tvCodeSnippets.AlphaSort;
end;

procedure TfrmCodeSnippets.LoadSnippets;
var
	N: TrmTreeNode;

begin
	tvCodeSnippets.Items.Clear;
	N := tvCodeSnippets.Items.Add(nil, 'Snippets');

	CatalogSnippets(gSnippetsDir, N);
end;

procedure TfrmCodeSnippets.AddSnippet(Snip: String);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Items.GetFirstNode;
	RecurseAdd(Snip, ExtractFilePath(Snip + '.snp'), N);
end;

procedure TfrmCodeSnippets.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_SYNHELP, True) then
			begin
				WriteInteger('Left', Left);
				WriteInteger('Width', Width);
				WriteInteger('Top', Top);
				WriteInteger('Height', Height);
				if FormStyle = fsStayOnTop then
					WriteBool('OnTop', True)
				else
					WriteBool('OnTop', False);
				WriteInteger('SplitterPos', Panel1.Height);
				CloseKey;
			end;
		finally
			Free;
		end;

	FCarla.Free;

	Action := caFree;
end;

procedure TfrmCodeSnippets.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Code_Snippets_Catalog;
	FCarla := TDragQueenCarla.Create(tvCodeSnippets);

	with TRegistry.Create do
		try
			if OpenKey(REG_SETTINGS_SYNHELP, True) then
			begin
				if not ValueExists('Left') then
					WriteInteger('Left', MarathonScreen.Left + MarathonScreen.Width - Width);

				if not ValueExists('Width') then
					WriteInteger('Width', Width);

				if not ValueExists('Top') then
					WriteInteger('Top', MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2);

				if not ValueExists('Height') then
					WriteInteger('Height', Height);

				if not ValueExists('OnTop') then
					WriteBool('OnTop', True);

				if not ValueExists('SplitterPos') then
					WriteInteger('SplitterPos', Trunc((Height div 4) * 3));

				Left := ReadInteger('Left');
				Width := ReadInteger('Width');
				Top := ReadInteger('Top');
				Height := ReadInteger('Height');
				Panel1.Height := ReadInteger('SplitterPos');

				if ReadBool('OnTop') then
					FOnTop := False
				else
					FOnTop := True;
				actStayOnTop.Execute;

				CloseKey;
			end;
		finally
			Free;
		end;

	{$IFDEF VER150}
	sbtnToolWin.Visible := True;
	{$ENDIF}

	LoadSnippets;
end;

procedure TfrmCodeSnippets.actStayOnTopExecute(Sender: TObject);
begin
	if FOnTop then
	begin
		FormStyle := fsNormal;
		FOnTop := False;
	end
	else
	begin
		FormStyle := fsStayOnTop;
		FOnTop := True;
	end;
end;

procedure TfrmCodeSnippets.actStayOnTopUpdate(Sender: TObject);
begin
	actStayOnTop.Checked := FOnTop;
end;

procedure TfrmCodeSnippets.actNewFolderExecute(Sender: TObject);
var
	Imp: TfrmInputDialog;
	N: TrmTreeNode;
	Path, NodePath: String;

begin
	Imp := TfrmInputDialog.Create(Self);
	try
		Imp.Caption := 'New Folder';
		Imp.lblPrompt.Caption := 'Enter a name for the new folder';

		if Imp.ShowModal = mrOK then
		begin
			// Get the full path, but delete the first "\Snippets\", because it is just
			// the root and no folder name
			NodePath := tvCodeSnippets.NodePath(tvCodeSnippets.Selected);
			Delete(NodePath, 1, 10);

			Path := gSnippetsDir + NodePath + '\' + Imp.edItem.Text;
			ForceDirectories(Path);
			if tvCodeSnippets.FindPathNode(NodePath + '\' + Imp.edItem.Text) <> nil then
			begin
				MessageDlg('The folder "' + Imp.edItem.Text + '" already exists.', mtError, [mbOK], 0);
				Exit;
			end;
			N := tvCodeSnippets.Items.AddChild(tvCodeSnippets.Selected, Imp.edItem.Text);
			N.ImageIndex := 1;
			N.SelectedIndex := 1;

			// Resort the tree after the insert
			tvCodeSnippets.AlphaSort;
		end;
	finally
		Imp.Free;
	end;
end;

procedure TfrmCodeSnippets.actNewFolderUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actNewFolder.Enabled := ((N.ImageIndex = 1) or (N.ImageIndex = 0))
	else
		actNewFolder.Enabled := False;
end;

procedure TfrmCodeSnippets.actNewSnippetExecute(Sender: TObject);
var
	N: TrmTreeNode;
	NodePath, NewNodePath: String;

begin
	if Assigned(tvCodeSnippets.Selected) then
	begin
		// Get the full path, but delete the first "\Snippets", because it is just
		// the root and no folder name
		N := tvCodeSnippets.Selected;
		NodePath := tvCodeSnippets.NodePath(N);
		Delete(NodePath, 1, 9);

		with TfrmEditorSnippet.NewSnippet(Self, NodePath) do
			try
				if ShowModal = mrOK then
				begin
					NewNodePath := GetNodePath(True);
          AddSnippet(NewNodePath + edSnippetName.Text + '.snp');

					// Resort the tree after the insert
					tvCodeSnippets.AlphaSort;
				end;
			finally
				Free;
			end;
	end;
end;

procedure TfrmCodeSnippets.actNewSnippetUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actNewSnippet.Enabled := ((N.ImageIndex = 1) or (N.ImageIndex = 0))
	else
		actNewSnippet.Enabled := False;
end;

procedure TfrmCodeSnippets.actDeleteFolderExecute(Sender: TObject);
var
	N: TrmTreeNode;
	NodePath: String;

		procedure KillDirectory(Path : String);
		var
			R: TSearchRec;
			Res: Integer;

		begin
			Res := FindFirst(Path + '\*.*', faAnyFile, R);
			while Res = 0 do
			begin
				if R.Attr = faDirectory then
				begin
					if ((R.Name <> '.') and (R.Name <> '..')) then
						KillDirectory(Path + '\' + R.Name)
				end
				else
					DeleteFile(Path + '\' + R.Name);
				Res := FindNext(R);
			end;
			FindClose(R);
			if not RemoveDirectory(PChar(Path + '\')) then
				ShowMessage(IntToStr(GetLastError));
		end;

begin
	N := tvCodeSnippets.Selected;
	if MessageDlg('Are you sure you wish to delete the folder "' + N.Text + '" and its contents?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		// Get the full path, but delete the first "\Snippets\", because it is just
		// the root and no folder name
		NodePath := tvCodeSnippets.NodePath(N);
		Delete(NodePath, 1, 10);

		NodePath := gSnippetsDir + NodePath;
		KillDirectory(NodePath);
		N.Delete;
	end;
end;

procedure TfrmCodeSnippets.actDeleteFolderUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actDeleteFolder.Enabled := (N.ImageIndex = 1) and (AnsiUpperCase(N.Text) <> 'SNIPPETS')
	else
		actDeleteFolder.Enabled := False;
end;

procedure TfrmCodeSnippets.actDeleteSnippetExecute(Sender: TObject);
var
	N: TrmTreeNode;
	NodePath, Path: String;

begin
	N := tvCodeSnippets.Selected;
	if MessageDlg('Are you sure you wish to delete the snippet "' + N.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		// Get the full path, but delete the first "\Snippets\", because it is just
		// the root and no folder name
		NodePath := tvCodeSnippets.NodePath(N);
		Delete(NodePath, 1, 10);

		Path := gSnippetsDir + NodePath;
		if FileExists(Path) then
		begin
			DeleteFile(Path);
			N.Delete;
		end
	end;
end;

procedure TfrmCodeSnippets.actDeleteSnippetUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actDeleteSnippet.Enabled := N.ImageIndex = 10
	else
		actDeleteSnippet.Enabled := False;
end;

procedure TfrmCodeSnippets.actRenameExecute(Sender: TObject);
var
	NodePath, OldName, NewName: String;
	N: TrmTreeNode;
	Imp: TfrmInputDialog;

begin
	N := tvCodeSnippets.Selected;
	Imp := TfrmInputDialog.Create(Self);
	try
		Imp.Caption := 'Rename Folder/Snippet';
		Imp.lblPrompt.Caption := 'Enter a new name for the folder/snippet';
		Imp.edItem.Text := N.Text;

		if Imp.ShowModal = mrOK then
		begin
			// Get the full path, but delete the first "\Snippets\", because it is just
			// the root and no folder name
			NodePath := tvCodeSnippets.NodePath(tvCodeSnippets.Selected);
			Delete(NodePath, 1, 10);

			NodePath := gSnippetsDir + NodePath;
			OldName := NodePath;
			NewName := ExtractFilePath(OldName) + Imp.edItem.Text;
			RenameFile(OldName, NewName);
			N.Text := Imp.edItem.Text;
		end;
	finally
		Imp.Free;
	end;
end;

procedure TfrmCodeSnippets.actRenameUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actRename.Enabled := AnsiUpperCase(N.Text) <> 'SNIPPETS'
	else
		actRename.Enabled := False;
end;

procedure TfrmCodeSnippets.actEditSnippetExecute(Sender: TObject);
var
	NodePath, FullPathWithFileName: String;
	N: TrmTreeNode;

begin
	// Get the full path, but delete the first "\Snippets\", because it is just
	// the root and no folder name
	N := tvCodeSnippets.Selected;
	NodePath := tvCodeSnippets.NodePath(N);
	Delete(NodePath, 1, 10);

	FullPathWithFileName := gSnippetsDir + NodePath;

	if FileExists(FullPathWithFileName) then
		with TfrmEditorSnippet.ModifySnippet(Self, ExtractFilePath(NodePath), FullPathWithFileName) do
			try
				if ShowModal = mrOK then
				begin
					TNodeData(N.Data^).NodeText := edSnippet.Text;
					memCodeSnippets.Text := TNodeData(N.Data^).NodeText;
				end;
			finally
				Free;
			end;
end;

procedure TfrmCodeSnippets.actEditSnippetUpdate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	N := tvCodeSnippets.Selected;
	if N <> nil then
		actEditSnippet.Enabled := N.ImageIndex = 10
	else
		actEditSnippet.Enabled := False;
end;

procedure TfrmCodeSnippets.actCopyExecute(Sender: TObject);
begin
	memCodeSnippets.CopyToClipboard;
end;

procedure TfrmCodeSnippets.actCopyUpdate(Sender: TObject);
begin
	actCopy.Enabled := memCodeSnippets.Focused and (memCodeSnippets.SelLength > 0);
end;

procedure TfrmCodeSnippets.actFullExpandExecute(Sender: TObject);
begin
	tvCodeSnippets.FullExpand;
end;

procedure TfrmCodeSnippets.actFullCollapseExecute(Sender: TObject);
begin
	tvCodeSnippets.FullCollapse;
end;

procedure TfrmCodeSnippets.actCloseExecute(Sender: TObject);
begin
	Close;
end;

procedure TfrmCodeSnippets.sbtnToolWinClick(Sender: TObject);
begin
	{$IFDEF VER150}
	AlphaBlendValue := 150;
	Self.AlphaBlend := sbtnToolWin.Down;
	{$ENDIF}
end;

procedure TfrmCodeSnippets.tvCodeSnippetsChange(Sender: TObject; Node: TrmTreeNode);
begin
	if Assigned(Node) then
		if Assigned(Node.Data) then
			memCodeSnippets.Text := TNodeData(Node.Data^).NodeText
		else
			memCodeSnippets.Text := '';
end;

procedure TfrmCodeSnippets.tvCodeSnippetsCompare(Sender: TObject; Node1,
	Node2: TrmTreeNode; Data: Integer; var Compare: Integer);
begin
	// Make sure that folders are sorted before snippets
	if Node1.ImageIndex < Node2.ImageIndex then
		Compare := -1
	else
		Compare := 1;

	// If we compare snippets with snippets or folders with folders, make sure
	// they are sorted alphanumeric
	if ((Node1.ImageIndex = 10) and (Node2.ImageIndex = 10)) or
		((Node1.ImageIndex = 1) and (Node2.ImageIndex = 1)) then
		Compare := CompareText(Node1.Text, Node2.Text);
end;

procedure TfrmCodeSnippets.tvCodeSnippetsDblClick(Sender: TObject);
begin
	if tvCodeSnippets.Selected.HasChildren = False then
		actEditSnippet.Execute;
end;

procedure TfrmCodeSnippets.tvCodeSnippetsDragDrop(Sender, Source: TObject;
	X, Y: Integer);
var
	Attrs: Integer;
	NodePath, ToPath, FromPath, FromTreePath: String;
	Node, FromNode: TrmTreeNode;

begin
	if (Source is TDragQueenCarla) and (Sender is TrmPathTreeView) then
	begin
		Node := tvCodeSnippets.GetNodeAt(X, Y);
		// Get the full path, but delete the first "\Snippets\", because it is just
		// the root and no folder name
		NodePath := tvCodeSnippets.NodePath(Node);
		Delete(NodePath, 1, 10);

		ToPath := gSnippetsDir + NodePath;

		Attrs := FileGetAttr(ToPath);
		// Make sure we are moving a snippet or directory to another directory
		if (Attrs > 0) and ((Attrs and faDirectory) <> 0) then
		begin
			FromPath := TDragQueenCarla(Source).DragData;
			FromTreePath := Copy(FromPath, Length(gSnippetsDir) - 9, Length(FromPath));
//			Attrs := FileGetAttr(ToPath);  //Removed to clear compiler warning. RJM

			if FromPath <> '' then
			begin
				FromNode := tvCodeSnippets.FindPathNode(FromTreePath);
				if Assigned(FromNode) then
				begin
					FromNode.MoveTo(Node, naAddChild);
					ToPath := ToPath + '\' + ExtractFileName(FromPath);
					RenameFile(FromPath, ToPath);
				end;
			end;
		end;
	end;
end;

procedure TfrmCodeSnippets.tvCodeSnippetsDragOver(Sender, Source: TObject;
	X, Y: Integer; State: TDragState; var Accept: Boolean);
var
	Attrs: Integer;
	NodePath, FromFolder, ToFolder: String;
	Node: TrmTreeNode;
begin
	Accept := false;
	if (Source is TDragQueenCarla) and (Sender is TrmPathTreeView) then
	begin
		Node := tvCodeSnippets.GetNodeAt(X, Y);
		// Get the full path, but delete the first "\Snippets\", because it is just
		// the root and no folder name
		NodePath := tvCodeSnippets.NodePath(Node);
		Delete(NodePath, 1, 10);

		ToFolder :=  gSnippetsDir + NodePath;

		Attrs := FileGetAttr(ToFolder);
		if Attrs = faDirectory then
		begin
			Accept := True;
			FromFolder := (Source as TDragQueenCarla).DragData;
			// Make sure that we are not moving a directory into one of its sub-directories
			Attrs := FileGetAttr(FromFolder);
			if Attrs = faDirectory then
				if StrLComp(PChar(FromFolder), PChar(ToFolder), Length(FromFolder)) = 0 then
					Accept := False;
			end;
	 end;
end;

procedure TfrmCodeSnippets.tvCodeSnippetsKeyDown(Sender: TObject;	var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			if actNewFolder.Enabled then
				actNewFolder.Execute
			else
				if actNewSnippet.Enabled then
					actNewSnippet.Execute;
		VK_DELETE:
			if actDeleteFolder.Enabled then
				actDeleteFolder.Execute
			else
				if actDeleteSnippet.Enabled then
					actDeleteSnippet.Execute;
	end;
end;

procedure TfrmCodeSnippets.tvCodeSnippetsMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	T: TrmTreeNode;

begin
	if Button = mbRight then
	begin
		T := tvCodeSnippets.GetNodeAt(X, Y);
		tvCodeSnippets.Selected := T;
	end;
end;

procedure TfrmCodeSnippets.tvCodeSnippetsStartDrag(Sender: TObject;	var DragObject: TDragObject);
var
	NodePath: String;

begin
	if tvCodeSnippets.Selected.Data <> nil then
		FCarla.DragData := TNodeData(tvCodeSnippets.Selected.Data^).NodeText
	else
		FCarla.DragData := '';

	// Get the full path, but delete the first "Snippets\", because it is just the root
	// and no folder name
	NodePath := tvCodeSnippets.NodePath(tvCodeSnippets.Selected);
	Delete(NodePath, 1, 10);

	FCarla.DragData := gSnippetsDir + NodePath;

	DragObject := FCarla;
end;

end.


