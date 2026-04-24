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
	IBHeader, IBDatabase, Db, IBCustomDataSet, Globals,
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
		tvObjects: TTreeView;
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
    procedure btnStartClick(Sender: TObject);
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
		procedure ClearChecks(Node: TTreeNode);
		procedure ExtractNotify(Sender : TObject; CurObj : String; PercentDone : Integer; var Stop : Boolean);
		procedure UnClearChecks(Node: TTreeNode);
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
				tvObjects.Items.Clear;
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
	Root : TTreeNode;
	IItem : TTreeNode;
	SubItem : TTreeNode;
	Q : TIBDataSet;
	Grants : TTreeNode;

begin
	FFillingTree := True;
	try
		Root := tvObjects.Items.Add(nil, 'Database');
		Q := TIBDataSet.Create(Self);
		try
			Q.Database := FDatabase;
			Q.Transaction := FTransaction;

			FTransaction.StartTransaction;
			try
				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.Items.AddChild(Root, 'Domains');

					Q.SelectSQL.Text := 'select rdb$field_name from rdb$fields where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$field_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						if AnsiUpperCase(Copy(Trim(Q.FieldByName('rdb$field_name').AsString), 1, 4)) <> 'RDB$' then
						begin
							SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$field_name').AsString));
            end;
						Q.Next;
					end;
					Q.Close;
				end;

				IItem := tvObjects.Items.AddChild(Root, 'Tables');

				if FObjectList.Count > 0 then
					// IItem.StateIndex := ... // Handle checked state via StateIndex or Checkboxes property
				else
					// IItem.StateIndex := ...

				Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is null order by rdb$relation_name asc;';
				Q.Open;
				while not Q.EOF do
				begin
					SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$relation_name').AsString));
					Q.Next;
				end;
				Q.Close;

				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.Items.AddChild(Root, 'Views');

					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$relation_name').AsString));
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.Items.AddChild(Root, 'Stored Procedures');
					Q.SelectSQL.Text := 'select rdb$procedure_name from rdb$procedures where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$procedure_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$procedure_name').AsString));
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.Items.AddChild(Root, 'Triggers');
					Q.SelectSQL.Text := 'select rdb$trigger_name from rdb$triggers where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and (rdb$trigger_source is not null) order by rdb$trigger_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$trigger_name').AsString));
						Q.Next;
					end;
					Q.Close;
				end;

				IItem := tvObjects.Items.AddChild(Root, 'Generators');
				Q.SelectSQL.Text := 'select rdb$generator_name from rdb$generators where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$generator_name asc;';
				Q.Open;
				while not Q.EOF do
				begin
					SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$generator_name').AsString));
					Q.Next;
				end;
				Q.Close;

				if not (rdoMigrate.ItemIndex = 2) then
				begin
					IItem := tvObjects.Items.AddChild(Root, 'Exceptions');
					Q.SelectSQL.Text := 'select rdb$exception_name from rdb$exceptions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$exception_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$exception_name').AsString));
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.Items.AddChild(Root, 'UDFs');
					Q.SelectSQL.Text := 'select rdb$function_name from rdb$functions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$function_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$function_name').AsString));
						Q.Next;
					end;
					Q.Close;

					Grants := tvObjects.Items.AddChild(Root, 'Grants');
					IItem := tvObjects.Items.AddChild(Grants, 'Tables');
					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$relation_name').AsString));
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.Items.AddChild(Grants, 'Views');
					Q.SelectSQL.Text := 'select rdb$relation_name from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null order by rdb$relation_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$relation_name').AsString));
						Q.Next;
					end;
					Q.Close;

					IItem := tvObjects.Items.AddChild(Grants, 'Stored Procedures');
					Q.SelectSQL.Text := 'select rdb$procedure_name from rdb$procedures where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$procedure_name asc;';
					Q.Open;
					while not Q.EOF do
					begin
						SubItem := tvObjects.Items.AddChild(IItem, Trim(Q.FieldByName('rdb$procedure_name').AsString));
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
		FFillingTree := False;
	end;
end;

procedure TfrmGlobalMigrateWizard.FormCreate(Sender: TObject);
begin
	LoadFormPosition(Self);
	nbWizard.ActivePage := nbpOne;
	rdoMigrate.ItemIndex := 0;
	FObjectList := TStringList.Create;
end;

procedure TfrmGlobalMigrateWizard.MigrateToScript;
var
	M : TIBMetaExtract;
	N : TTreeNode;
	WNode : TTreeNode;
	WSubNode : TTreeNode;
	Root : TTreeNode;
	HNode : TTreeNode;

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

			Root := tvObjects.Items.GetFirstNode;
			if Root.Text = 'Database' then
			begin
				HNode := Root.GetFirstChild;
				while HNode <> nil do
				begin
					if HNode.Text = 'Domains' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ... // Check state
								M.Domains.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Tables' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.Tables.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Views' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.Views.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Stored Procedures' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.SPs.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Triggers' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.Triggers.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Generators' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.Generators.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Exceptions' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.Exceptions.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'UDFs' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							// if WNode.StateIndex = ...
								M.UDFs.Add(WNode.Text);
							WNode := WNode.GetNextSibling;
						end;
					end;

					if HNode.Text = 'Grants' then
					begin
						N := HNode;
						WNode := N.GetFirstChild;
						while WNode <> nil do
						begin
							if WNode.Text = 'Tables' then
							begin
								WSubNode := WNode.GetFirstChild;
								while Assigned(WSubNode) do
								begin
									// if WSubNode.StateIndex = ...
										M.GrantTables.Add(WSubNode.Text);
									WSubNode := WSubNode.GetNextSibling;
								end;
							end;

							if WNode.Text = 'Views' then
							begin
								WSubNode := WNode.GetFirstChild;
								while Assigned(WSubNode) do
								begin
									// if WSubNode.StateIndex = ...
										M.GrantViews.Add(WSubNode.Text);
									WSubNode := WSubNode.GetNextSibling;
								end;
							end;

							if WNode.Text = 'Stored Procedures' then
							begin
								WSubNode := WNode.GetFirstChild;
								while Assigned(WSubNode) do
								begin
									// if WSubNode.StateIndex = ...
										M.GrantSPs.Add(WSubNode.Text);
									WSubNode := WSubNode.GetNextSibling;
								end;
							end;

							WNode := wNode.GetNextSibling; 
						end;
					end;
          HNode := HNode.GetNextSibling;
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

procedure TfrmGlobalMigrateWizard.ClearChecks(Node: TTreeNode);
var
	N : TTreeNode;

begin
	if Node.HasChildren then
	begin
		N := Node.GetFirstChild;
		while N <> nil do
		begin
			// N.StateIndex := ... 
			ClearChecks(N);
			N := N.GetNextSibling;
		end;
	end;
end;

procedure TfrmGlobalMigrateWizard.UnClearChecks(Node: TTreeNode);
var
	N : TTreeNode;

begin
	if Node.HasChildren then
	begin
		N := Node.GetFirstChild;
		while N <> nil do
		begin
			// N.StateIndex := ...
			UnClearChecks(N);
			N := N.GetNextSibling;
		end;
	end;
	N := Node.Parent;
	while N <> nil do
	begin
		// N.StateIndex := ...
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
