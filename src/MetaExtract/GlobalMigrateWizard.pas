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
// $Id: GlobalMigrateWizard.pas,v 1.4 2005/04/25 13:15:18 rjmills Exp $

unit GlobalMigrateWizard;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ExtCtrls, ComCtrls, MetaExtractUnit, Menus, ActnList, rmBtnEdit,
	IBHeader, IBDatabase, Db, VirtualTrees, IBCustomDataSet, rmCornerGrip, Globals,
	rmBaseEdit, rmNotebook2;

type
	PTreeData = ^TTreeData;
	TTreeData = record
		FCaption: String;
	end;

	TfrmGlobalMigrateWizard = class(TForm)
		btnClose: TButton;
		btnNext: TButton;
		btnPrev: TButton;
    nbWizard: TrmNoteBookControl;
		pgDBMigrate: TPageControl;
		tsObjects: TTabSheet;
		tsOptions: TTabSheet;
		pbScriptProgress: TProgressBar;
		btnStop: TButton;
		lblProgress: TLabel;
		Bevel1: TBevel;
		PopupMenu1: TPopupMenu;
		ActionList1: TActionList;
		Label5: TLabel;
		edFileName: TrmBtnEdit;
		chkCreateDatabase: TCheckBox;
		chkInclPassword: TCheckBox;
		chkInclDependents: TCheckBox;
		chkWrapat: TCheckBox;
		edWrap: TEdit;
		upWrap: TUpDown;
		udDecPlaces: TUpDown;
		edDecPlaces: TEdit;
		Label7: TLabel;
		Label8: TLabel;
		cmbDecSep: TComboBox;
		Label6: TLabel;
		tvObjects: TVirtualStringTree;
		Panel1: TPanel;
		Bevel2: TBevel;
		Panel2: TPanel;
		Bevel3: TBevel;
		Panel3: TPanel;
		Bevel4: TBevel;
		Panel4: TPanel;
		Bevel5: TBevel;
		dlgOpen: TOpenDialog;
		Image1: TImage;
		lblPrompt: TLabel;
		Label1: TLabel;
		Image2: TImage;
		Label2: TLabel;
		Image3: TImage;
		Label3: TLabel;
		Image4: TImage;
		Label9: TLabel;
		Label10: TLabel;
		Label11: TLabel;
		Label12: TLabel;
		chkIncludeDoc: TCheckBox;
		rmCornerGrip1: TrmCornerGrip;
    rdoMigrate: TRadioGroup;
    btnStart: TButton;
    nbpOne: TrmNotebookPage;
    nbpTwo: TrmNotebookPage;
    nbpThree: TrmNotebookPage;
    nbpFour: TrmNotebookPage;

		procedure btnNextClick(Sender: TObject);
		procedure btnPrevClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure btnStopClick(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//		procedure tvObjectsChecked(Sender: TObject; Node: TTreeNTNode);
		procedure edFileNameBtn1Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvObjectsInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure btnStartClick(Sender: TObject);
    procedure tvObjectsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
	private
		{ Private declarations }
		data: PTreeData;
		FStop : Boolean;
		FExtracting : Boolean;
		FDatabase: TIBDatabase;
		FTransaction: TIBTransaction;
		FDBUserName: String;
		FDBPassword: String;
		FFillingTree : Boolean;
		FClearingChecks : Boolean;
		FIsIB6: Boolean;
		FSQLDialect: Integer;
		FDatabaseName: String;
		FDefaultDirectory: String;
		FObjectList: TStringList;
		procedure FillDatabaseTreeView;
		procedure MigrateToScript;
		procedure ClearChecks(Node: PVirtualNode);
		procedure ExtractNotify(Sender : TObject; CurObj : String; PercentDone : Integer; var Stop : Boolean);
		procedure UnClearChecks(Node: PVirtualNode);
	public
		{ Public declarations }
		property Database : TIBDatabase read FDatabase write FDatabase;
		property Transaction : TIBTransaction read FTransaction write FTransaction;
		property UserName : String read FDBUserName write FDBUserName;
		property Password : String read FDBPassword write FDBPassword;
		property DatabaseName : String read FDatabaseName write FDatabaseName;
		property IsIB6 : Boolean read FIsIB6 write FIsIB6;
		property SQLDialect : Integer read FSQLDialect write FSQLDialect;
		property DefaultDirectory : String read FDefaultDirectory write FDefaultDirectory;
		property ObjectList : TStringList read FObjectList write FObjectList;
	end;

implementation

uses
	gssscript_TLB,
	ComObj,
	ComServ,
	DDLExtractor,
	MarathonProjectCacheTypes;

{$R *.DFM}

{ TfrmGlobalMigrateWizard }

procedure TfrmGlobalMigrateWizard.btnNextClick(Sender: TObject);
begin
	case nbWizard.ActivePageIndex of
		0 :
			begin
				case rdoMigrate.ItemIndex of
					0, 1, 2 :
						begin
							nbWizard.ActivePage := nbpTwo;
              ActiveControl := edFileName;
							btnPrev.Enabled := True;
						end;
				end;
			end;
		1 :
			begin
				if edFileName.Text = '' then
				begin
					MessageDlg('You must enter a file name.', mtError, [mbOK], 0);
					edFileName.SetFocus;
				end
        else
        begin
				  FillDatabaseTreeView;
				  nbWizard.ActivePage := nbpThree;
        end;
			end;
		2 :
			begin
				case rdoMigrate.ItemIndex of
					0, 1, 2 :
						begin
							nbWizard.ActivePage := nbpFour;
							btnPrev.Enabled := True;
						end;
				end;
			end;
	end;
end;

procedure TfrmGlobalMigrateWizard.btnPrevClick(Sender: TObject);
begin
	case nbWizard.ActivePageIndex of
		0 :
			begin
				//shouldn't get here...
			end;
		1 :
			begin
				nbWizard.ActivePage := nbpOne;
				btnPrev.Enabled := False;
			end;
		2 :
			begin
				tvObjects.Clear;
				nbWizard.ActivePage := nbpTwo;
				btnNext.Caption := 'Next &>';
			end;
		3 :
			begin
        begin
				  nbWizard.ActivePage := nbpThree;
          btnNext.Enabled := True;
          btnPrev.Enabled := True;
        end;
			end;
   end;
end;

procedure TfrmGlobalMigrateWizard.FillDatabaseTreeView;
var
	Root : PVirtualNode;
	IItem : PVirtualNode;
	SubItem : PVirtualNode;
	Q : TIBDataSet;
	Grants : PVirtualNode;
	Idx : Integer;

begin
	FFillingTree := True;
	try
		Root := tvObjects.AddChild(nil);
		Data := tvObjects.GetNodeData(Root);
		Data^.FCaption := 'Database';
		Root.CheckType := ctTriStateCheckBox;
		Q := TIBDataSet.Create(Self);
		try
			Q.Database := FDatabase;
			Q.Transaction := FTransaction;

			FTransaction.StartTransaction;
			try
				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Domains';

					Q.SelectSQL.Text := 'select rdb$field_name from rdb$fields where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$field_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						if AnsiUpperCase(Copy(Trim(Q.FieldByName('rdb$field_name').AsString), 1, 4)) <> 'RDB$' then
						begin
							SubItem := tvObjects.AddChild(IItem);
							Data := tvObjects.GetNodeData(SubItem);
							Data^.FCaption := Trim(Q.FieldByName('rdb$field_name').AsString);
            end;
						Q.Next;
					end;
					Q.Close;
				end;

				IItem := tvObjects.AddChild(Root);
				Data := tvObjects.GetNodeData(IItem);
				Data^.FCaption := 'Tables';

				IItem.CheckType := ctCheckbox;
				if FObjectList.Count > 0 then
					IItem.CheckState := csUncheckedNormal
				else
					IItem.CheckState := csCheckedNormal;

				Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is null order by rdb$relation_name asc;';
				Q.Open;
				while not Q.EOF do
				begin
					SubItem := tvObjects.AddChild(IItem);
					Data := tvObjects.GetNodeData(SubItem);
					Data^.FCaption := Trim(Q.FieldByName('rdb$relation_name').AsString);
					Q.Next;
				end;
				Q.Close;

				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Views';

					IItem.CheckType := ctCheckbox;
					if FObjectList.Count > 0 then
						IItem.CheckState := csUncheckedNormal
					else
						IItem.CheckState := csCheckedNormal;

					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$relation_name').AsString);
						SubItem.CheckType := ctCheckbox;
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Stored Procedures';
					Q.SelectSQL.Text := 'select rdb$procedure_name from rdb$procedures where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$procedure_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$procedure_name').AsString);

						SubItem.CheckType := ctCheckbox;
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Triggers';
					Q.SelectSQL.Text := 'select rdb$trigger_name from rdb$triggers where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and (rdb$trigger_source is not null) order by rdb$trigger_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$trigger_name').AsString);
						Q.Next;
					end;
					Q.Close;
				end;

				IItem := tvObjects.AddChild(Root);
				Data := tvObjects.GetNodeData(IItem);
				Data^.FCaption := 'Generators';
				Q.SelectSQL.Text := 'select rdb$generator_name from rdb$generators where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$generator_name asc;';
				Q.Open;
				while not Q.EOF do
				begin
					SubItem := tvObjects.AddChild(IItem);
					Data := tvObjects.GetNodeData(SubItem);
					Data^.FCaption := Trim(Q.FieldByName('rdb$generator_name').AsString);
					Q.Next;
				end;
				Q.Close;

				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Exceptions';
					Q.SelectSQL.Text := 'select rdb$exception_name from rdb$exceptions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$exception_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$exception_name').AsString);
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'UDFs';
					Q.SelectSQL.Text := 'select rdb$function_name from rdb$functions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$function_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$function_name').AsString);
						Q.Next;
					end;
					Q.Close;

					Grants := tvObjects.AddChild(Root);
					Data := tvObjects.GetNodeData(Grants);
					Data^.FCaption := 'Grants';
					IItem := tvObjects.AddChild(Grants);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Tables';
					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$relation_name').AsString);
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.AddChild(Grants);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Views';
					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$relation_name').AsString);
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.AddChild(Grants);
					Data := tvObjects.GetNodeData(IItem);
					Data^.FCaption := 'Stored Procedures';
					Q.SelectSQL.Text := 'select rdb$procedure_name from rdb$procedures where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$procedure_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.AddChild(IItem);
						Data := tvObjects.GetNodeData(SubItem);
						Data^.FCaption := Trim(Q.FieldByName('rdb$procedure_name').AsString);
						Q.Next;
					end;
					Q.Close;
				end;


			finally
				FTransaction.Commit;
			end;
		finally
			Q.Free;
		end;
	finally
    tvObjects.ReinitChildren(Root ,True);

		FFillingTree := False;
	end;
end;

procedure TfrmGlobalMigrateWizard.FormCreate(Sender: TObject);
begin
	tvObjects.NodeDataSize := SizeOf(TTreeData);
	LoadFormPosition(Self);
	nbWizard.ActivePage := nbpOne;
	rdoMigrate.ItemIndex := 0;
	FObjectList := TStringList.Create;
end;

procedure TfrmGlobalMigrateWizard.MigrateToScript;
var
	M : TIBMetaExtract;
	N : PVirtualNode;
	WNode : PVirtualNode;
	WSubNode : PVirtualNode;
	Root : PVirtualNode;
	HNode : PVirtualNode;

begin
	FStop := False;
	FExtracting := True;
	try
		btnPrev.Enabled := False;
		btnNext.Enabled := False;
		btnClose.Enabled := False;
		M := TIBMetaExtract.Create(Self);
		try
			M.Database := FDatabase;
			M.Transaction := FTransaction;
			M.DatabaseName := FDatabaseName;
			M.UserName := FDBUserName;
			M.Password := FDBPassword;
			M.IsIB6 := FIsIB6;
			M.SQLDialect := FSQLDialect;
			M.FileName := edFileName.Text;
			case rdoMigrate.ItemIndex of
				0 :
					begin
						M.ExtractType := exMetaOnly;
					end;
				1 :
					begin
						M.ExtractType := exMetaAndData;
					end;
				2 :
					begin
						M.ExtractType := exDataOnly;
					end;
			end;
			M.CreateDatabase := chkCreateDatabase.Checked;
			M.IncludePassword := chkInclPassword.Checked;
			M.IncludeDependents := chkInclDependents.Checked;
			M.IncludeDoc := chkIncludeDoc.Checked;
			M.DecimalPlaces := udDecPlaces.Position;
			M.DecimalSeparator := cmbDecSep.Text;
			M.Wrap := chkWrapat.Checked;
			M.RightMargin := upWrap.Position;

			Root := tvObjects.GetFirst;
			Data := tvObjects.GetNodeData(Root);
			if Data.FCaption = 'Database' then
			begin
				HNode := Root.FirstChild;
				while HNode <> nil do
				begin
					Data := tvObjects.GetNodeData(HNode);
					if Data.FCaption = 'Domains' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Domains.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Tables' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Tables.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Views' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Views.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Stored Procedures' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.SPs.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Triggers' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Triggers.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Generators' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Generators.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Exceptions' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.Exceptions.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'UDFs' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if WNode.CheckState = csCheckedNormal then
								M.UDFs.Add(Data.FCaption);
							WNode := WNode.NextSibling;
						end;
					end;

					if Data.FCaption = 'Grants' then
					begin
						N := HNode;
						WNode := N.FirstChild;
						while WNode <> nil do
						begin
							Data := tvObjects.GetNodeData(WNode);
							if Data.FCaption = 'Tables' then
							begin
								WSubNode := WNode.FirstChild;
								while Assigned(WSubNode) do
								begin
									Data := tvObjects.GetNodeData(WSubNode);
									if WSubNode.CheckState = csCheckedNormal then
										M.GrantTables.Add(Data.FCaption);
									WSubNode := WSubNode.NextSibling;
								end;
							end;

							Data := tvObjects.GetNodeData(WNode);
							if Data.FCaption = 'Views' then
							begin
								WSubNode := WNode.FirstChild;
								while Assigned(WSubNode) do
								begin
									Data := tvObjects.GetNodeData(WSubNode);
									if WSubNode.CheckState = csCheckedNormal then
										M.GrantViews.Add(Data.FCaption);
									WSubNode := WSubNode.NextSibling;
								end;
							end;

							Data := tvObjects.GetNodeData(WNode);
							if Data.FCaption = 'Stored Procedures' then
							begin
								WSubNode := WNode.FirstChild;
								while Assigned(WSubNode) do
								begin
									Data := tvObjects.GetNodeData(WSubNode);
									if WSubNode.CheckState = csCheckedNormal then
										M.GrantSPs.Add(Data.FCaption);
									WSubNode := WSubNode.NextSibling;
								end;
							end;

							WNode := wNode.NextSibling; //rjm: fix to allow for all grants to be extracted.
						end;
					end;
          HNode := HNode.NextSibling;
				end;
			end;

			M.OnExtractNotify := ExtractNotify;

			M.IsIB6 := FIsIB6;
			M.SQLDialect := FSQLDialect;
			M.ExtractFullMetaData;
			if FStop then
			begin
				pbScriptProgress.Visible := False;
			end;
		finally
			M.Free;
		end;
		btnClose.Enabled := True;
		btnStop.Enabled := False;
	finally
		FExtracting := False;
	end;
end;

procedure TfrmGlobalMigrateWizard.ClearChecks(Node: PVirtualNode);
var
	N : PVirtualNode;

begin
	if tvObjects.HasChildren[Node] then
	begin
		N := Node.FirstChild;
		while N <> nil do
		begin
			N.CheckState := csUncheckedNormal;
			ClearChecks(N);
			N := N.NextSibling;
		end;
	end;
end;

procedure TfrmGlobalMigrateWizard.UnClearChecks(Node: PVirtualNode);
var
	N : PVirtualNode;

begin
	if tvObjects.HasChildren[Node] then
	begin
		N := Node.FirstChild;
		while N <> nil do
		begin
			N.CheckState := csCheckedNormal;
			UnClearChecks(N);
			N := N.NextSibling;
		end;
	end;
	N := Node.Parent;
	while N <> nil do
	begin
		N.CheckState := csCheckedNormal;
		N := N.Parent;
	end;
end;

procedure TfrmGlobalMigrateWizard.ExtractNotify(Sender: TObject;
	CurObj: String; PercentDone: Integer; var Stop : Boolean);
begin
	lblProgress.Caption := CurObj;
	lblProgress.Refresh;
	pbScriptProgress.Position := PercentDone;
	Application.ProcessMessages;
	if FStop then
		Stop := True;
end;

procedure TfrmGlobalMigrateWizard.btnStopClick(Sender: TObject);
begin
	FStop := True;
  btnStop.Enabled := True;
  btnPrev.Enabled := True;  
end;

procedure TfrmGlobalMigrateWizard.FormCloseQuery(Sender: TObject;
	var CanClose: Boolean);
begin
	if FExtracting then
		CanClose := False;
end;

procedure TfrmGlobalMigrateWizard.edFileNameBtn1Click(Sender: TObject);
begin
	try
		dlgOpen.InitialDir := FDefaultDirectory;
	except
		//bite my crunker...
	end;
	if dlgOpen.Execute then
		edFileName.Text := dlgOpen.FileName;
end;

procedure TfrmGlobalMigrateWizard.FormDestroy(Sender: TObject);
begin
	FObjectList.Free;
end;

procedure TfrmGlobalMigrateWizard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	SaveFormPosition(Self);
end;

procedure TfrmGlobalMigrateWizard.tvObjectsInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PTreeData;

begin
  Node.CheckType := ctTriStateCheckBox;
  Node.CheckState := csCheckedNormal;
end;

procedure TfrmGlobalMigrateWizard.btnStartClick(Sender: TObject);
begin
	btnStop.Enabled := True;
	ActiveControl := btnStop;
	btnStart.Enabled := False;
	FStop := False;
	MigrateToScript;
	Refresh;
	btnStart.Enabled := True;
	btnPrev.Enabled := True;
end;

procedure TfrmGlobalMigrateWizard.tvObjectsGetText(
	Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
	TextType: TVSTTextType; var CellText: WideString);
begin
	Data := tvObjects.GetNodeData(Node);
	CellText := Data^.FCaption;
end;

end.

{ Old History
	* Major revision of treeview fill and MigratetoScript routines. (john)
	* Removal of some unused routines. (john)
	* Various changes to the Wizard functionality. (a script can be rerun after changing some walues) (john)
	* Added Start button to script generation.	(john)
}

{
$Log: GlobalMigrateWizard.pas,v $
Revision 1.4  2005/04/25 13:15:18  rjmills
*** empty log message ***

Revision 1.3  2002/04/25 07:34:50  tmuetze
New CVS powered comment block

}
