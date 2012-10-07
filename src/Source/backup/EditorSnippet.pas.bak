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
// $Id: EditorSnippet.pas,v 1.4 2005/04/13 16:04:27 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: EditorSnippet.pas,v $
Revision 1.4  2005/04/13 16:04:27  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:15:20  tmuetze
Completeted the revisiting of the Code Snippets functionality, also added a patch from Paul Gittings to support drag&drop in the Code Snippets window

Revision 1.2  2002/08/28 15:01:58  tmuetze
Fixed the CVS comment block

Revision 1.1  2002/08/28 14:56:56  tmuetze
Revised the Code Snippets functionality, only SaveSnippetAs.* needs revising

}

unit EditorSnippet;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls,
	rmCornerGrip,
	rmPathTreeView,
	SynEdit,
	SyntaxMemoWithStuff2;

type
	TfrmEditorSnippet = class(TForm)
		btnCancel: TButton;
		btnOK: TButton;
		rmCornerGrip1: TrmCornerGrip;
		lblSnippetName: TLabel;
		edSnippetName: TEdit;
		btnHelp: TButton;
		pgEditorSnippet: TPageControl;
		tsFolder: TTabSheet;
		Label2: TLabel;
		tvSnippetsFolders: TrmPathTreeView;
		tsSnippet: TTabSheet;
		Label3: TLabel;
		edSnippet: TSyntaxMemoWithStuff2;
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnOKClick(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure btnHelpClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
	private
		FullPathWithFileName, NodePath: String;
		FNewSnippet, FModifySnippet: Boolean;
		procedure CatalogSnippets(Path: String; Node: TrmTreeNode);
		procedure SetSelectedFolder(Value: String);
		{ Private declarations }
	public
		{ Public declarations }
		function GetNodePath(RemoveSnippetsRootFolder: Boolean): String;
		property SelectedFolder: String write SetSelectedFolder;
		constructor NewSnippet(const AOwner: TComponent; NodePath: String); reintroduce; overload;
		constructor ModifySnippet(const AOwner: TComponent; NodePath, FullPathWithFileName: String); reintroduce; overload;
	end;

implementation

uses
	Globals,
	HelpMap,
	Tools,
	MenuModule;

{$R *.DFM}

function TfrmEditorSnippet.GetNodePath(RemoveSnippetsRootFolder: Boolean): String;
begin
	if Assigned(tvSnippetsFolders.Selected) then
	begin
		Result := Tools.AddBackSlash(tvSnippetsFolders.NodePath(tvSnippetsFolders.Selected));
		if RemoveSnippetsRootFolder then
			Delete(Result, 1, 9);
	end
	else
		Result := '';
end;

procedure TfrmEditorSnippet.CatalogSnippets(Path: String; Node: TrmTreeNode);
var
	R: TSearchRec;
	Res: Integer;
	N: TrmTreeNode;

begin
	Res := FindFirst(Path + '\*.*', faAnyFile, R);
	while Res = 0 do
	begin
		if R.Attr = faDirectory then
		begin
			if ((R.Name <> '.') and (R.Name <> '..')) then
			begin
				N := tvSnippetsFolders.Items.AddChild(Node, R.Name);
				CatalogSnippets(Path + '\' + R.Name, N);
				N.ImageIndex := 1;
				N.SelectedIndex := 1;
			end;
		end;
		Res := FindNext(R);
	end;
	FindClose(R);
end;

procedure TfrmEditorSnippet.SetSelectedFolder(Value: String);
var
	N : TrmTreeNode;
begin
	// make sure there is no backslash at the end of the path string
	if Copy(Value, Length(Value), 1) = '\' then
		Delete(Value, Length(Value), 1);

	N := tvSnippetsFolders.FindPathNode('\Snippets' + Value);
	if Assigned(N) then
	begin
		N.Selected := True;
		N.Focused := True;
	end
	else
		tvSnippetsFolders.TopItem.Selected;
end;

constructor TfrmEditorSnippet.NewSnippet(const AOwner: TComponent; NodePath: String);
begin
	inherited Create(AOwner);
	FNewSnippet := True;
	FModifySnippet := False;
	Self.NodePath := NodePath;
end;

constructor TfrmEditorSnippet.ModifySnippet(const AOwner: TComponent; NodePath, FullPathWithFileName: String);
begin
	inherited Create(AOwner);
	FNewSnippet := False;
	FModifySnippet := True;
	Self.NodePath := NodePath;
	Self.FullPathWithFileName := FullPathWithFileName;
end;

procedure TfrmEditorSnippet.FormCreate(Sender: TObject);
var
	N: TrmTreeNode;

begin
	LoadFormPosition(Self);
	HelpContext := IDH_New_Modify_Code_Snippet_Dialog;

	N := tvSnippetsFolders.Items.Add(nil, 'Snippets');
	CatalogSnippets(gSnippetsDir, N);
	N.Expand(True);
	SetSelectedFolder(NodePath);

	SetupSyntaxEditor(edSnippet);

	pgEditorSnippet.ActivePageIndex := 0;
end;

procedure TfrmEditorSnippet.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgEditorSnippet)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgEditorSnippet);
end;

procedure TfrmEditorSnippet.FormShow(Sender: TObject);
begin
	if FNewSnippet then
	begin
		Caption := 'New Code Snippet';
		edSnippetName.SetFocus;
	end
	else
	begin
		Caption := 'Modify Code Snippet';
		lblSnippetName.Enabled := False;
		edSnippetName.Enabled := False;
		tsFolder.TabVisible := False;
		edSnippetName.Text := ExtractFileName(FullPathWithFileName);
		edSnippet.Lines.LoadFromFile(FullPathWithFileName);
		edSnippet.SetFocus;
	end;
end;

procedure TfrmEditorSnippet.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	SaveFormPosition(Self);
	Action := caFree;
end;

procedure TfrmEditorSnippet.btnOKClick(Sender: TObject);
var
	FullFileName: String;
begin
	if FNewSnippet then
		if Assigned(tvSnippetsFolders.Selected) = False then
		begin
			MessageDlg('Specify the folder you wish to save the snippet in.', mtError, [mbOK], 0);
			pgEditorSnippet.ActivePage := tsSnippet;
			tvSnippetsFolders.SetFocus;
			Exit;
		end;

	if FNewSnippet then
		if edSnippetName.Text = '' then
		begin
			MessageDlg('You must give the snippet a name.', mtError, [mbOK], 0);
			edSnippetName.SetFocus;
			Exit;
		end;

	if edSnippet.Text = '' then
	begin
		MessageDlg('The code snippet cannot be emtpy.', mtError, [mbOK], 0);
		edSnippet.SetFocus;
		Exit;
	end;

	if FNewSnippet then
	begin
		FullFileName := gSnippetsDir + GetNodePath(True) + edSnippetName.Text + '.snp';
		if FileExists(FullFileName) then
		begin
			MessageDlg('The snippet "' + edSnippetName.Text + '" already exists in this folder.', mtError, [mbOK], 0);
			edSnippetName.SetFocus;
			Exit;
		end
		else
			edSnippet.Lines.SaveToFile(FullFileName);
	end
	else
		edSnippet.Lines.SaveToFile(FullPathWithFileName);

	ModalResult := mrOK;
end;

procedure TfrmEditorSnippet.btnHelpClick(Sender: TObject);
begin
	Application.HelpCommand(HELP_CONTEXT, IDH_New_Modify_Code_Snippet_Dialog);
end;

end.


