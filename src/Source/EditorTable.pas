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
// $Id: EditorTable.pas,v 1.15 2006/10/19 03:54:58 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{ Old History
	10.04.2002	tmuetze
		* TfrmStoredProcedure.DoGrant, TfrmStoredProcedure.DoRevoke rewritten for new
			and revised EditorGrant
	23.03.2002	tmuetze
		* TfrmTables.pgObjectEditorChange, added some checks before SetActive of the
			frames is called, else we will get a exception because at this time the
			form is not visible
	17.03.2002	tmuetze
		* TfrmTables.CanObjectProperties, TfrmTables.NewConstraint have now the new
			TfrmEditorConstraint calls instead of the old TfrmNewConstraint ones
	15.03.2002	tmuetze
		* TfrmTables.CanObjectProperties, TfrmTables.NewIndex have now the new TfrmEditorIndex
			calls instead of the old TfrmNewIndex ones
	14.03.2002	tmuetze
		* TfrmTables.CanObjectProperties, let's show the Indices properties
	13.03.2002	tmuetze
		* completed implementation of column properties in method TfrmTables.DoObjectProperties
	21.01.2002	tmuetze
		* Beginning implementation of column properties in method TfrmTables.DoObjectProperties
}

{
$Log: EditorTable.pas,v $
Revision 1.15  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.14  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.13  2005/04/13 16:04:27  rjmills
*** empty log message ***

Revision 1.12  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.11  2002/05/06 06:23:32  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.10  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit EditorTable;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, Grids, DBGrids, DBCtrls, StdCtrls,	ExtCtrls,
	ClipBrd, Tabs, ActnList, Buttons,
	rmTabs3x,
	IB_Components,
	IBODataset,
	adbpedit,
	MarathonProjectCacheTypes,
	MarathonInternalInterfaces,
	MarathonIDE,
	BaseDocumentDataAwareForm,
	FrameDependencies,
	FrameDescription,
	FrameMetadata,
	FramePermissions,
  MenuModule,
	GimbalToolsAPI,
	GimbalToolsAPIImpl, rmNotebook2;

type
	TfrmTables = class(TfrmBaseDocumentDataAwareForm, IMarathonTableEditor, IGimbalIDETableEditorWindow)
		stsEditor: TStatusBar;
		pgObjectEditor: TPageControl;
		tsTableView: TTabSheet;
		tsDependenciesView: TTabSheet;
		tsTriggerView: TTabSheet;
		tsData: TTabSheet;
		tvTriggers: TTreeView;
		pnlDataView: TPanel;
		navDataView: TDBNavigator;
		dsTableData: TDataSource;
		tsConstraints: TTabSheet;
		lvFieldList: TListView;
		tsDoco: TTabSheet;
		lvConstraints: TListView;
		tsIndexes: TTabSheet;
		lvIndex: TListView;
    qryTable: TIBOQuery;
    qryConstraints: TIBOQuery;
    qryTriggers: TIBOQuery;
    tblTableData: TIBOQuery;
    nbResults: TrmNoteBookControl;
    nbpForm : TrmNotebookPage;
    nbpDatasheet : TrmNotebookPage;
		tabResults: TrmTabSet;
		grdDataView: TDBGrid;
		pnledResults: TDBPanelEdit;
		tranTableData: TIB_Transaction;
		tsGrants: TTabSheet;
		tsDDL: TTabSheet;
		btnRefresh: TSpeedButton;
		framDepend: TframeDepend;
		framDoco: TframeDesc;
		framDDL: TframDisplayDDL;
		framPerms: TframePerms;
		Panel1: TPanel;
		Label1: TLabel;
		cmbTriggerDisplay: TComboBox;
    PopupMenu1: TPopupMenu;
    sizerect1: TMenuItem;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure tvTriggersDblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure tvTriggersMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure lvIndexKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure grdDataViewDblClick(Sender: TObject);
		procedure tvTriggersGetImageIndex(Sender: TObject; Node: TTreeNode);
		procedure tabResultsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
		procedure lvFieldListDblClick(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure tblTableDataAfterOpen(DataSet: TDataSet);
		procedure lvFieldListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure lvConstraintsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure tvTriggersKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure lvFieldListColumnClick(Sender: TObject; Column: TListColumn);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure cmbTriggerDisplayChange(Sender: TObject);
    procedure sizerect1Click(Sender: TObject);
	private
		{ Private declarations }
		It: TMenuItem;
		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var message: TMessage); message WM_MOVE;
		procedure NewField;
		procedure NewConstraint;
		procedure NewIndex;
		procedure CheckCommit;
		procedure DoTableFieldSort(ChangeDir: Boolean);
		procedure FillFieldList;
		//ToolsAPI
		function IDEGetActivePage : TGimbalIDETableEditorPage; safecall;
	public
		{ Public declarations }
		procedure LoadTable(TableName: String);
		procedure NewTable;
		function InternalCloseQuery: Boolean; override;
		procedure ForceRefresh; override;
		procedure SetObjectName(Value: String); override;
		procedure SetObjectModified(Value: Boolean); override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar: TStatusBar; override;

		function CanInternalClose: Boolean; override;
		procedure DoInternalClose; override;

		function CanViewNextPage: Boolean; override;
		procedure DoViewNextPage; override;

		function CanViewPrevPage: Boolean; override;
		procedure DoViewPrevPage; override;

		function CanObjectDrop: Boolean; override;
		procedure DoObjectDrop; override;

		function CanSaveDoco: Boolean; override;
		procedure DoSaveDoco; override;

		function CanUndo: Boolean; override;
		procedure DoUndo; override;

		function CanRedo: Boolean; override;
		procedure DoRedo; override;

		function CanCaptureSnippet: Boolean; override;
		procedure DoCaptureSnippet; override;

		function CanCut: Boolean; override;
		procedure DoCut; override;

		function CanCopy: Boolean; override;
		procedure DoCopy; override;

		function CanPaste: Boolean; override;
		procedure DoPaste; override;

		function CanFind: Boolean; override;
		procedure DoFind; override;

		function CanFindNext: Boolean; override;
		procedure DoFindNext; override;

		function CanReplace: Boolean; override;
		procedure DoReplace; override;

		function CanSelectAll: Boolean; override;
		procedure DoSelectAll;	override;

		function CanObjectOpenSubObject: Boolean; override;
		procedure DoObjectOpenSubObject; override;

		function CanObjectNewField: Boolean; override;
		procedure DoObjectNewField; override;

		function CanObjectNewTrigger: Boolean; override;
		procedure DoObjectNewTrigger; override;

		function CanObjectNewConstraint: Boolean; override;
		procedure DoObjectNewConstraint; override;

		function CanObjectNewIndex: Boolean; override;
		procedure DoObjectNewIndex; override;

		function CanObjectDropField: Boolean; override;
		procedure DoObjectDropField; override;

		function CanObjectDropTrigger: Boolean; override;
		procedure DoObjectDropTrigger; override;

		function CanObjectDropConstraint: Boolean; override;
		procedure DoObjectDropConstraint; override;

		function CanObjectDropIndex: Boolean; override;
		procedure DoObjectDropIndex; override;

		function CanObjectProperties: Boolean; override;
		procedure DoObjectProperties; override;

		function CanObjectReorderColumns: Boolean; override;
		procedure DoObjectReorderColumns; override;

		function CanGrant: Boolean; override;
		procedure DoGrant; override;

		function CanRevoke: Boolean; override;
		procedure DoRevoke; override;

		function CanTransactionCommit: Boolean; override;
		procedure DoTransactionCommit; override;

		function CanTransactionRollback: Boolean; override;
		procedure DoTransactionRollback; override;

		procedure UpdateTriggers;

		function IsInterbaseSix: Boolean;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;

		//ToolsAPI
		function IDEGetSelectedItems : IGimbalIDESelectedItems; override; safecall;
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonOptions,
	DropObject,
	SaveFileFormat,
	EditorColumn,
	CompileDBObject,
	EditorConstraint,
	EditorIndex,
	BlobViewer,
	ReOrderColumns,
	EditorGrant, Math;

{$R *.DFM}

const
	 PG_STRUCT = 0;
	 PG_CONST = 1;
	 PG_INDEX = 2;
	 PG_DEPEND = 3;
	 PG_TRIGGER = 4;
	 PG_DATA = 5;
	 PG_DOCO = 6;
	 PG_GRANTS = 7;
	 PG_DDL = 8;

procedure TfrmTables.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmTables.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[0].Width := lvFieldList.Columns[0].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[1].Width := lvFieldList.Columns[1].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[2].Width := lvFieldList.Columns[2].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[3].Width := lvFieldList.Columns[3].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[4].Width := lvFieldList.Columns[4].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[5].Width := lvFieldList.Columns[5].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[6].Width := lvFieldList.Columns[6].Width;

	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[0].Width := lvConstraints.Columns[0].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[1].Width := lvConstraints.Columns[1].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[2].Width := lvConstraints.Columns[2].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[3].Width := lvConstraints.Columns[3].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[4].Width := lvConstraints.Columns[4].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[5].Width := lvConstraints.Columns[5].Width;
	MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[6].Width := lvConstraints.Columns[6].Width;

	MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[0].Width := lvIndex.Columns[0].Width;
	MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[1].Width := lvIndex.Columns[1].Width;
	MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[2].Width := lvIndex.Columns[2].Width;
	MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[3].Width := lvIndex.Columns[3].Width;
	MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[4].Width := lvIndex.Columns[4].Width;

	framDepend.SaveColWidths;
	Action := caFree;
end;

procedure TfrmTables.tvTriggersDblClick(Sender: TObject);
begin
	if Assigned(tvTriggers.Selected) then
		if tvTriggers.Selected.Level = 2 then
			MarathonIDEInstance.OpenTrigger(tvTriggers.Selected.Text, FDatabaseName);
end;

procedure TfrmTables.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	FObjectType := ctTable;

	HelpContext := IDH_Table_Editor;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;

	FCharSet := SetUpEncodingControl(grdDataView);
	FCharSet := SetUpEncodingControl(pnledResults);

	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framDepend.Init(TmpIntf);
	framPerms.Init(TmpIntf);
	framDDL.Init(TmpIntf);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 Table [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);

	cmbTriggerDisplay.ItemIndex := 0;
end;

procedure TfrmTables.tvTriggersMouseDown(Sender: TObject;	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	T: TTreeNode;

begin
	if Button = mbRight then
	begin
		T := tvTriggers.GetNodeAt(x, Y);
		tvTriggers.Selected := T;
	end;
end;

procedure TfrmTables.UpdateTriggers;
var
	Root, AbsRoot: TTreeNode;

	BefInsRoot: TTreeNode;
	AftInsRoot: TTreeNode;
	BefUpdRoot: TTreeNode;
	AftUpdRoot: TTreeNode;
	BefDelRoot: TTreeNode;
	AftDelRoot: TTreeNode;

begin
	try
		tvTriggers.Items.BeginUpdate;
		qryTriggers.BeginBusy(False);

		tvTriggers.Items.Clear;

		AbsRoot := tvTriggers.Items.GetFirstNode;
		Root := tvTriggers.Items.AddChild(AbsRoot, 'Triggers for [' + FObjectName + ']');

		BefInsRoot := tvTriggers.Items.AddChild(Root, 'Before Insert');
		AftInsRoot := tvTriggers.Items.AddChild(Root, 'After Insert');
		BefUpdRoot := tvTriggers.Items.AddChild(Root, 'Before Update');
		AftUpdRoot := tvTriggers.Items.AddChild(Root, 'After Update');
		BefDelRoot := tvTriggers.Items.AddChild(Root, 'Before Delete');
		AftDelRoot := tvTriggers.Items.AddChild(Root, 'After Delete');

		case cmbTriggerDisplay.ItemIndex of
			0:
				begin
					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 1 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefInsRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 2 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftInsRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 3 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefUpdRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 4 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftUpdRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 5 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefDelRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name from rdb$triggers where rdb$trigger_type = 6 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftDelRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;
				end;

			1:
				begin
					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 1 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefInsRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 2 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftInsRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 3 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefUpdRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 4 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftUpdRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 5 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(BefDelRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;

					qryTriggers.Close;
					qryTriggers.SQL.Clear;
					qryTriggers.SQL.Add('select rdb$trigger_name, rdb$trigger_sequence from rdb$triggers where rdb$trigger_type = 6 and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_sequence asc;');
					qryTriggers.Open;
					while not qryTriggers.EOF do
					begin
						tvTriggers.Items.AddChild(AftDelRoot, qryTriggers.FieldByName('rdb$trigger_name').AsString);
						qryTriggers.Next;
					end;
				end;
		end;
		qryTriggers.Close;
		qryTriggers.IB_Transaction.Commit;
	finally
		qryTriggers.EndBusy;
		tvTriggers.Items.EndUpdate;
	end;
	Root.Expand(True);
	if Screen.ActiveForm = Self then
		tvTriggers.SetFocus;
end;

procedure TfrmTables.CheckCommit;
begin
	if tblTableData.Active then
	begin
		tblTableData.Close;
		if tblTableData.Modified then
		begin
			if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
				tranTableData.Commit
			else
				tranTableData.Rollback;
		end
		else
			if tranTableData.Started then
				tranTableData.Rollback;
	end;
end;

procedure TfrmTables.FillFieldList;
var
	Idx, Dimensions: Integer;
	DataTypeText: String;
	L: TListItem;
begin
	// Field list
	lvFieldList.Items.BeginUpdate;

	lvFieldList.Items.Clear;
	qryTable.Close;
	qryTable.SQL.Clear;

	if FIsInterbase6 and (FSQLDialect = 3) then
		qryTable.SQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
			'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
			'b.rdb$computed_source, b.rdb$field_length, b.rdb$field_precision, a.rdb$description, ' +
			'b.rdb$dimensions, ' +
			'b.rdb$field_scale, b.rdb$field_type, b.rdb$field_sub_type from ' +
			'rdb$relation_fields a, rdb$fields b where ' +
			'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
			AnsiQuotedStr(fObjectName, '''') + ' ' +
			' order by a.rdb$field_position asc;')
	else
		qryTable.SQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
			'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
			'b.rdb$computed_source, b.rdb$field_length, a.rdb$description, ' +
			'b.rdb$dimensions, ' +
			'b.rdb$field_scale, b.rdb$field_type, b.rdb$field_sub_type from ' +
			'rdb$relation_fields a, rdb$fields b where ' +
			'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
			AnsiQuotedStr(fObjectName, '''') + ' ' +
			' order by a.rdb$field_position asc;');
	qryTable.Open;
	while not qryTable.EOF do
	begin
		L := lvFieldList.Items.Add;
		L.ImageIndex := 6;
		L.Caption := qryTable.FieldByName('rdb$field_name').AsString;

		if FIsInterbase6 and (FSQLDialect = 3) then
			DataTypeText := ConvertFieldType(qryTable.FieldByName('rdb$field_type').AsInteger,
				qryTable.FieldByName('rdb$field_length').AsInteger,
				qryTable.FieldByName('rdb$field_scale').AsInteger,
				qryTable.FieldByName('rdb$field_sub_type').AsInteger,
				qryTable.FieldByName('rdb$field_precision').AsInteger,
				True, FSQLDialect)
		else
			DataTypeText := ConvertFieldType(qryTable.FieldByName('rdb$field_type').AsInteger,
				qryTable.FieldByName('rdb$field_length').AsInteger,
				qryTable.FieldByName('rdb$field_scale').AsInteger,
				-1, -1, False, FSQLDialect);
		if qryTable.FieldByName('rdb$dimensions').AsInteger > 0 then
		begin
			DataTypeText := DataTypeText + '[';
			Dimensions := qryTable.FieldByName('rdb$dimensions').AsInteger;
			for Idx := 0 to Dimensions do
			begin
				qryConstraints.Close;
				qryConstraints.SQL.Clear;
				qryConstraints.SQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
																'rdb$dimension = ' + IntToStr(Idx)	+ 'and rdb$field_name = ' + AnsiQuotedStr(qryTable.FieldByName('rdb$field_source').AsString, ''''));
				qryConstraints.Open;
				if not (qryConstraints.EOF and qryConstraints.BOF) then
				begin
					DataTypeText := DataTypeText + qryConstraints.FieldByName('rdb$lower_bound').AsString + ':' + qryConstraints.FieldByName('rdb$upper_bound').AsString + ', ';
				end;
			end;
			DataTypeText := Trim(DataTypeText);
			if DataTypeText[Length(DataTypeText)] = ',' then
				DataTypeText := Copy(DataTypeText, 1, Length(DataTypeText) - 1);
			DataTypeText := DataTypeText + ']';
		end;
		L.SubItems.Add(DataTypeText);

		if qryTable.FieldByName('rdb$field_type').AsInteger = 261 then
			L.SubItems.Add(qryTable.FieldByName('rdb$field_sub_type').AsString)
		else
			L.SubItems.Add('');
		L.SubItems.Add(qryTable.FieldByName('rdb$field_source').AsString);

		if qryTable.FieldByName('tnull_flag').IsNull and qryTable.FieldByName('fnull_flag').IsNull then
			L.SubItems.Add('False')
		else
			L.SubItems.Add('True');

		L.SubItems.Add(Trim(qryTable.FieldByName('rdb$description').AsString));
		L.SubItems.Add(Trim(qryTable.FieldByName('rdb$default_source').AsString));
		L.SubItems.Add(Trim(qryTable.FieldByName('rdb$computed_source').AsString));
		qryTable.Next;
	end;
	qryTable.Close;
	qryTable.IB_Transaction.Commit;
end;

procedure TfrmTables.pgObjectEditorChange(Sender: TObject);
var
	Tmp: String;
	L: TListItem;
	Q: TIBOQuery;

begin
	try
		qryTable.BeginBusy(False);
		case pgObjectEditor.ActivePage.PageIndex of
			PG_STRUCT:
				begin
					CheckCommit;
					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

					FillFieldList;

					// fix the column widths
					lvFieldList.Columns[0].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[0].Width;
					lvFieldList.Columns[1].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[1].Width;
					lvFieldList.Columns[2].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[2].Width;
					lvFieldList.Columns[3].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[3].Width;
					lvFieldList.Columns[4].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[4].Width;
					lvFieldList.Columns[5].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[5].Width;
					lvFieldList.Columns[6].Width := MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[6].Width;
					lvFieldList.Items.EndUpdate;
					ActiveControl := lvFieldList;
				end;

			PG_CONST:
				begin
					CheckCommit;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

					lvConstraints.Items.BeginUpdate;
					lvConstraints.Items.Clear;

					qryConstraints.Close;
					qryConstraints.SQL.Clear;
					qryConstraints.SQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type <> ''NOT NULL'') and rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
					qryConstraints.Open;

					while not qryConstraints.EOF do
					begin
						L := lvConstraints.Items.Add;
						L.ImageIndex := 10;
						L.Caption := qryConstraints.FieldByName('rdb$constraint_name').AsString;
						L.SubItems.Add(qryConstraints.FieldByName('rdb$constraint_type').AsString);

						if ((qryConstraints.FieldByName('rdb$constraint_type').AsString = 'FOREIGN KEY') or
							(qryConstraints.FieldByName('rdb$constraint_type').AsString = 'PRIMARY KEY') or
							(qryConstraints.FieldByName('rdb$constraint_type').AsString = 'UNIQUE')) then
						begin
							Q := TIBOQuery.Create(Self);
							try
								Q.IB_Connection := qryTable.IB_Connection;
								Q.SQL.Add('select * from rdb$index_segments where rdb$index_name = ''' +
									qryConstraints.FieldByName('rdb$index_name').AsString + ''' order by rdb$field_position asc;');
								Q.Open;
								Tmp := '';
								while not Q.EOF do
								begin
									Tmp := Tmp + Q.FieldByName('rdb$field_name').AsString;
									Q.Next;
									If not Q.EOF then Tmp := Tmp + ', ';
								end;
								L.SubItems.Add(Tmp);
								Q.Close;
							finally
								Q.Free;
							end;

							Q := TIBOQuery.Create(Self);
							try
								Q.IB_Connection := qryTable.IB_Connection;
								Q.SQL.Add('select rdb$relation_name from rdb$indices where rdb$index_name in ' +
									'(select rdb$foreign_key from rdb$indices where rdb$index_name	= ''' +
									qryConstraints.FieldByName('rdb$index_name').AsString + ''');');
								Q.Open;
								L.SubItems.Add(Q.FieldByName('rdb$relation_name').AsString);
								Q.Close;
								Q.SQL.Clear;
								Q.SQL.Add('select * from rdb$index_segments where rdb$index_name in ' +
									'(select rdb$index_name from rdb$indices where rdb$index_name in ' +
									'(select rdb$foreign_key from rdb$indices where rdb$index_name	= ''' +
									qryConstraints.FieldByName('rdb$index_name').AsString + ''')) order by rdb$field_position asc;');
								Q.Open;
								Tmp := '';
								while not Q.EOF do
								begin
									Tmp := Tmp + Q.FieldByName('rdb$field_name').AsString;
									Q.Next;
									if not Q.EOF then
										Tmp := Tmp + ', ';
								end;
								L.SubItems.Add(tmp);
								Q.Close;
							finally
								Q.Free;
							end;

							// IB 5.0 only
							try
								Q := TIBOQuery.Create(Self);
								try
									Q.IB_Connection := qryTable.IB_Connection;
									Q.SQL.Add('select rdb$update_rule, rdb$delete_rule from rdb$ref_constraints where rdb$constraint_name = ''' +
										qryConstraints.FieldByName('rdb$constraint_name').AsString + ''';');
									Q.Open;
									while not Q.EOF do
									begin
										L.SubItems.Add(Q.FieldByName('rdb$update_rule').AsString);
										L.SubItems.Add(Q.FieldByName('rdb$delete_rule').AsString);
										Q.Next;
									end;
									Q.Close;
								finally
									Q.Free;
								end;
							except
								on E : Exception do
								begin
									// eat it
								end;
							end;
						end
						else
						begin
							if (qryConstraints.FieldByName('rdb$constraint_type').AsString = 'CHECK') then
							begin
								Q := TIBOQuery.Create(Self);
								try
									Q.IB_Connection := qryTable.IB_Connection;
									Q.SQL.Add('select rdb$trigger_name from rdb$check_constraints where rdb$constraint_name = ''' + qryConstraints.FieldByName('rdb$constraint_name').AsString + ''';');
									Q.Open;

									Tmp := Q.FieldByName('rdb$trigger_name').AsString;
									Q.Close;
									Q.SQL.Clear;
									Q.SQL.Add('select rdb$trigger_source from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(Tmp, '''') + ';');
									Q.Open;
									L.SubItems.Add(Q.FieldByName('rdb$trigger_source').AsString);
									Q.Close;
								finally
									Q.Free;
								end;
							end;
						end;
						qryConstraints.Next;
					end;
					lvConstraints.Columns[0].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[0].Width;
					lvConstraints.Columns[1].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[1].Width;
					lvConstraints.Columns[2].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[2].Width;
					lvConstraints.Columns[3].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[3].Width;
					lvConstraints.Columns[4].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[4].Width;
					lvConstraints.Columns[5].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[5].Width;
					lvConstraints.Columns[6].Width := MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[6].Width;
					lvConstraints.Items.EndUpdate;
					qryConstraints.Close;
					qryConstraints.IB_Transaction.Commit;
					ActiveControl := lvConstraints;
				end;

			PG_INDEX: 
				begin
					CheckCommit;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

					lvIndex.Items.BeginUpdate;
					lvIndex.Items.Clear;
					qryTable.Close;
					qryTable.SQL.Clear;
					qryTable.SQL.Add('select * from rdb$indices where rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');

					qryTable.Open;
					while not qryTable.EOF do
					begin
						L := lvIndex.Items.Add;
						L.ImageIndex := 10;
						L.Caption := qryTable.FieldByName('rdb$index_name').AsString;

						Q := TIBOQuery.Create(Self);
						try
							Q.IB_Connection := qryTable.IB_Connection;
							Q.SQL.Add('select * from rdb$index_segments where rdb$index_name = ''' +
								qryTable.FieldByName('rdb$index_name').AsString + ''' order by rdb$field_position asc;');
							Q.Open;
							Tmp := '';
							while not Q.EOF do
							begin
								Tmp := Tmp + Q.FieldByName('rdb$field_name').AsString;
								Q.Next;
								if not Q.EOF then
									Tmp := Tmp + ', ';
							end;
							L.SubItems.Add(Tmp);
							Q.Close;
						finally
							Q.Free;
						end;

						if qryTable.FieldByName('rdb$unique_flag').AsInteger = 1 then
							L.SubItems.Add('Yes')
						else
							L.SubItems.Add('No');

						if qryTable.FieldByName('rdb$index_inactive').AsInteger = 0 then
							L.SubItems.Add('Yes')
						else
							L.SubItems.Add('No');

						if qryTable.FieldByName('rdb$index_type').AsInteger = 1 then
							L.SubItems.Add('DESC')
						else
							L.SubItems.Add('ASC');

						qryTable.Next;
					end;

					lvIndex.Columns[0].Width := MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[0].Width;
					lvIndex.Columns[1].Width := MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[1].Width;
					lvIndex.Columns[2].Width := MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[2].Width;
					lvIndex.Columns[3].Width := MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[3].Width;
					lvIndex.Columns[4].Width := MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[4].Width;
					lvIndex.Items.EndUpdate;
					qryTable.Close;
					qryTable.IB_Transaction.Commit;
					ActiveControl := lvIndex;
				end;

			PG_DEPEND: 
				begin
					CheckCommit;

					framDepend.LoadDependencies;
					if Self.Visible then
						framDepend.SetActive;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

				end;

			PG_TRIGGER: 
				begin
					CheckCommit;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

					UpdateTriggers;
				end;

			PG_DATA: 
				begin
					CheckCommit;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';

					tblTableData.SQL.Clear;
					tblTableData.SQL.Add('select * from ' + MakeQuotedIdent(FObjectName, IsInterbase6, FSQLDialect) + ';');

					tblTableData.Open;

					case gDefaultView of
						0:
							begin
								nbResults.ActivePage := nbpDatasheet;
								tabResults.TabIndex := gDefaultView;
							end;

						1:
							begin
								nbResults.ActivePage := nbpForm;
								tabResults.TabIndex := gDefaultView;
							end;
					end;


					case nbResults.ActivePageIndex of
						0:
							ActiveControl := grdDataView;

						1:
							ActiveControl := pnledResults;
					end;
				end;

			PG_DOCO: 
				begin
					CheckCommit;

					framDoco.LoadDoco;
					if Self.Visible then
						framDoco.SetActive;
				end;

			PG_GRANTS: 
				begin
					CheckCommit;

					framPerms.OpenGrants;
					if Self.Visible then
						framPerms.SetActive;
					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';
				end;

			PG_DDL:
				begin
					CheckCommit;

					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';
					if Self.Visible then
						framDDL.SetActive;

					Self.Refresh;
					if not FNewObject then
						framDDL.GetDDL;
				end;
		end;

		MarathonIDEInstance.CurrentProject.LastSelectedTableTab := pgObjectEditor.ActivePage.PageIndex;
	finally
		qryTable.EndBusy;
	end;
end;

procedure TfrmTables.NewField;
var
	NewCol: String;
	F: TfrmColumns;
	Item: TListItem;
	
begin
	Refresh;
	F := TfrmColumns.Create(Self);
	try
		F.DatabaseName := FDatabaseName;
		F.TableEditor := Self;
		F.Caption := 'New Column';
		F.State := stNewColumn;
		F.NewColumn;
		if F.ShowModal = mrOK then
		begin
			NewCol := F.NewColumnName;
			pgObjectEditorChange(pgObjectEditor);
			Item := lvFieldList.FindCaption(0, NewCol, False, True, False);
			if Assigned(Item) then
			begin
				Item.Selected := True;
				Item.Focused := True;
			end;
		end;
	finally
		F.Free;
	end;
end;

procedure TfrmTables.NewConstraint;
var
	Count: Integer;
	Found: Boolean;
	NewPKName, NewFKName, NewCheckName, NewUniqueName: String;

	function ConstraintNameInList(Name: String): Integer;
	var
		I: Integer;
	begin
		Result := -1;
		for I := 0 to lvConstraints.Items.Count - 1 do
			if lvConstraints.Items.Item[I].Caption = Name then
			begin
				Result := I;
				Break;
			end;
	end;

begin
	// There can be maximal one primary key per table
	NewPKName := 'PK_' + FObjectName;

	// Try to find a name for the new foreign key
	Count := 1;
	NewFKName := 'FK' + IntToStr(Count) + '_' + FObjectName;
	repeat
		if ConstraintNameInList(NewFKName) <> -1 then
		begin
			Found := True;
			Count := Count + 1;
			NewFKName := 'FK' + IntToStr(Count) + '_' + FObjectName;
		end
		else
			Found := False;
	until Found = False;

	// Try to find a name for the new check
	Count := 1;
	NewCheckName := 'CHK' + IntToStr(Count) + '_' + FObjectName;
	repeat
		if ConstraintNameInList(NewCheckName) <> -1 then
		begin
			Found := True;
			Count := Count + 1;
			NewCheckName := 'CHK' + IntToStr(Count) + '_' + FObjectName;
		end
		else
			Found := False;
	until Found = False;

	// Try to find a name for the new unique constraint
	Count := 1;
	NewUniqueName := 'UNQ' + IntToStr(Count) + '_' + FObjectName;
	repeat
		if ConstraintNameInList(NewUniqueName) <> -1 then
		begin
			Found := True;
			Count := Count + 1;
			NewUniqueName := 'UNQ' + IntToStr(Count) + '_' + FObjectName;
		end
		else
			Found := False;
	until Found = False;

	// create EditorConstraint
	with TfrmEditorConstraint.CreateNewConstraint(Self, FDatabaseName, FObjectName, NewPKName,
		NewFKName, NewCheckName, NewUniqueName) do
		try
			if ShowModal = mrOK then
				pgObjectEditor.OnChange(pgObjectEditor);
		finally
			Free;
		end;
end;

procedure TfrmTables.NewIndex;
var
	Count: Integer;
	Found: Boolean;
	NewIndexName: String;

	function IndexNameInList(Name: String): Integer;
	var
		I: Integer;
	begin
		Result := -1;
		for I := 0 to lvIndex.Items.Count - 1 do
			if lvIndex.Items.Item[I].Caption = Name then
			begin
				Result := I;
				Break;
			end;
	end;

begin
	// Try to find a name for the new index
	Count := 1;
	NewIndexName := 'IDX' + IntToStr(Count) + '_' + FObjectName;
	repeat
		if IndexNameInList(NewIndexName) <> -1 then
		begin
			Found := True;
			Count := Count + 1;
			NewIndexName := 'IDX' + IntToStr(Count) + '_' + FObjectName;
		end
		else
			Found := False;
	until Found = False;

	// create EditorIndex
	with TfrmEditorIndex.CreateNewIndex(Self, FDatabaseName, FObjectName, NewIndexName) do
		try
			if ShowModal = mrOK then
				pgObjectEditor.OnChange(pgObjectEditor);
		finally
			Free;
		end;
end;

procedure TfrmTables.lvIndexKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
      If CanObjectNewIndex then
         DoObjectNewIndex;

		VK_DELETE:
 			if CanObjectDropIndex then
			   DoObjectDropIndex;

		VK_RETURN:
      if CanObjectProperties then
				 DoObjectProperties;
	end;
end;

procedure TfrmTables.grdDataViewDblClick(Sender: TObject);
begin
	EditBlobColumn(grdDataView.SelectedField);
end;

procedure TfrmTables.tvTriggersGetImageIndex(Sender: TObject;	Node: TTreeNode);
begin
	case Node.Level of
		0:
			begin
				Node.ImageIndex := 0;
				Node.SelectedIndex := 0;
			end;

		1:
			begin
				Node.ImageIndex := 1;
				Node.SelectedIndex := 1;
			end;

		2:
			begin
				Node.ImageIndex := 4;
				Node.SelectedIndex := 4;
			end;
	end;
end;

procedure TfrmTables.tabResultsChange(Sender: TObject; NewTab: Integer;	var AllowChange: Boolean);
begin
	nbResults.ActivePageIndex := NewTab;
end;

procedure TfrmTables.pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			begin
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[0].Width := lvFieldList.Columns[0].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[1].Width := lvFieldList.Columns[1].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[2].Width := lvFieldList.Columns[2].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[3].Width := lvFieldList.Columns[3].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[4].Width := lvFieldList.Columns[4].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[5].Width := lvFieldList.Columns[5].Width;
				MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[6].Width := lvFieldList.Columns[6].Width;
			end;

		PG_CONST:
			begin
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[0].Width := lvConstraints.Columns[0].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[1].Width := lvConstraints.Columns[1].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[2].Width := lvConstraints.Columns[2].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[3].Width := lvConstraints.Columns[3].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[4].Width := lvConstraints.Columns[4].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[5].Width := lvConstraints.Columns[5].Width;
				MarathonIDEInstance.CurrentProject.TEConstraintsColumns.Items[6].Width := lvConstraints.Columns[6].Width;
			end;

		PG_INDEX:
			begin
				MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[0].Width := lvIndex.Columns[0].Width;
				MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[1].Width := lvIndex.Columns[1].Width;
				MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[2].Width := lvIndex.Columns[2].Width;
				MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[3].Width := lvIndex.Columns[3].Width;
				MarathonIDEInstance.CurrentProject.TEIndexesColumns.Items[4].Width := lvIndex.Columns[4].Width;
			end;

		PG_DEPEND:
			framDepend.SaveColWidths;
	end;
	AllowChange := True;
end;

procedure TfrmTables.lvFieldListDblClick(Sender: TObject);
begin
	if Assigned(TListView(Sender).Selected) then
		DoObjectProperties;
end;

procedure TfrmTables.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
  inherited;
end;

procedure TfrmTables.WMMove(var message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmTables.tblTableDataAfterOpen(DataSet: TDataSet);
begin
	GlobalFormatFields(DataSet);
end;

procedure TfrmTables.lvFieldListKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewField;

		VK_DELETE:
			DoObjectDropField;

		VK_RETURN:
			if Assigned(lvFieldList.Selected) then
				DoObjectProperties;
	end;
end;

procedure TfrmTables.lvConstraintsKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewConstraint;

		VK_DELETE:
			DoObjectDropConstraint;

		VK_RETURN:
			if Assigned(lvConstraints.Selected) then
				DoObjectProperties;
	end;
end;

procedure TfrmTables.tvTriggersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewTrigger;

		VK_DELETE:
			DoObjectDropTrigger;

		VK_RETURN:
			if Assigned(tvTriggers.Selected) then
				if tvTriggers.Selected.Level = 2 then
					MarathonIDEInstance.OpenTrigger(tvTriggers.Selected.Text, FDatabaseName);
	end;
end;

procedure TfrmTables.lvFieldListColumnClick(Sender: TObject; Column: TListColumn);
begin
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn := Column.Index;
	DoTableFieldSort(True);
end;

function CustomFieldSortProc(Item1, Item2: TListItem; ParamSort: integer): integer; stdcall;
begin
	if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn = 0 then
	begin
		if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder = srtAsc then
			Result := lstrcmp(PChar(TListItem(Item1).Caption), PChar(TListItem(Item2).Caption))
		else
			Result := -lstrcmp(PChar(TListItem(Item1).Caption), PChar(TListItem(Item2).Caption));
	end
	else
		if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder = srtAsc then
			Result := lstrcmp(PChar(TListItem(Item1).SubItems[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn - 1]),
				PChar(TListItem(Item2).SubItems[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn - 1]))
		else
			Result := -lstrcmp(PChar(TListItem(Item1).SubItems[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn - 1]),
				PChar(TListItem(Item2).SubItems[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn - 1]));
end;

procedure TfrmTables.DoTableFieldSort(ChangeDir: Boolean);
var
	Idx: Integer;
	
begin
	if ChangeDir then
		if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder = srtAsc then
		begin
			MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder := srtDesc;
			lvFieldList.Columns[0].ImageIndex := 11;
		end
		else
		begin
			MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder := srtAsc;
			lvFieldList.Columns[0].ImageIndex := 12;
		end;

	lvFieldList.CustomSort(@CustomFieldSortProc,0);
	for Idx := 0 to lvFieldList.Columns.Count - 1 do
		lvFieldList.Columns[Idx].ImageIndex := -1;

	if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder = srtDesc then
		lvFieldList.Columns[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn].ImageIndex := 11
	else
		lvFieldList.Columns[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn].ImageIndex := 12;
end;


procedure TfrmTables.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

procedure TfrmTables.LoadTable(TableName: String);
begin
	FObjectName := TableName;
	InternalCaption := 'Table - [' + FObjectName + ']';
	IT.Caption := Caption;

	case MarathonIDEInstance.CurrentProject.LastSelectedTableTab of
		PG_STRUCT:
			pgObjectEditor.ActivePage := tsTableView;

		PG_CONST:
			pgObjectEditor.ActivePage := tsConstraints;

		PG_INDEX:
			pgObjectEditor.ActivePage := tsIndexes;

		PG_DEPEND:
			pgObjectEditor.ActivePage := tsDependenciesView;

		PG_TRIGGER:
				pgObjectEditor.ActivePage := tsTriggerView;

		PG_DATA:
			pgObjectEditor.ActivePage := tsData;

		PG_DOCO:
			pgObjectEditor.ActivePage := tsDoco;

		PG_GRANTS:
			pgObjectEditor.ActivePage := tsGrants;

		PG_DDL:
			pgObjectEditor.ActivePage := tsDDL;
	else
		pgObjectEditor.ActivePage := tsTableView;
	end;
	pgObjectEditorChange(pgObjectEditor);
end;

procedure TfrmTables.NewTable;
var
	F: TfrmColumns;
	
begin
	Refresh;
	F := TfrmColumns.Create(Self);
	try
		F.DatabaseName := FDatabaseName;
		F.TableEditor := Self;
		F.Caption := 'Create New Table and Add First Column';
		F.State := stNewTable;
		F.NewColumn;
		if F.ShowModal = mrOK then
		begin
      FObjectName := AnsiUpperCase(fObjectName);
			pgObjectEditor.ActivePage := tsTableView;
			MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctTable);
			pgObjectEditorChange(pgObjectEditor);
		end
		else
			raise Exception.Create('Table Create cancelled');
	finally
		F.Free;
	end;
end;

procedure TfrmTables.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

function TfrmTables.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if framDoco.Modified then
			case MessageDlg('The documentation for table ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
				mrYes:
					framDoco.SaveDoco;

				mrCancel:
					Result := False;

				mrNo:
					Result := True;
			end;
	end
	else
		Result := True;
end;

procedure TfrmTables.SetObjectModified(Value: Boolean);
begin
	inherited;
	FObjectModified := False;
end;

procedure TfrmTables.SetObjectName(Value: String);
begin
	inherited;
	FObjectName := Value;
	InternalCaption := 'Table - [' + FObjectName + ']';
	IT.Caption := Caption;
end;

procedure TfrmTables.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

function TfrmTables.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

procedure TfrmTables.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		tblTableData.IB_Connection := nil;
		tranTableData.IB_Connection := nil;
		qryTable.IB_Connection := nil;
		qryConstraints.IB_Connection := nil;
		qryTriggers.IB_Connection := nil;
		framDoco.qryDoco.IB_Connection := nil;
		framDoco.qryDoco.IB_Transaction := nil;
		IsInterbase6 := False;
		SQLDialect := 0;
		stsEditor.Panels[3].Text := 'No Connection';
	end
	else
	begin
		tblTableData.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		tranTableData.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;

		qryTable.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryTable.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryConstraints.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryConstraints.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryTriggers.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryTriggers.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qryTable.IB_Connection.SQLDialect;
		stsEditor.Panels[3].Text := Value;
	end;
end;

function TfrmTables.CanInternalClose: Boolean;
begin
	Result := True;
end;

procedure TfrmTables.DoInternalClose;
begin
	inherited;
	Close;
end;

function TfrmTables.CanObjectDrop: Boolean;
begin
	Result := True;
end;

function TfrmTables.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmTables.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

procedure TfrmTables.DoObjectDrop;
var
	frmDropObject : TfrmDropObject;
	DoClose: Boolean;

begin
	if MessageDlg('Are you sure that you wish to drop the Table "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctTable, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

procedure TfrmTables.DOViewNextPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(True);
end;

procedure TfrmTables.DOViewPrevPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(False);
end;

function TfrmTables.CanCaptureSnippet: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCaptureSnippet;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := framDDL.CanCaptureSnippet;
	else
		Result := False;
	end;
end;

function TfrmTables.CanCopy: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCopy;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := framDDL.CanCopy;
	else
		Result := False;
	end;
end;

function TfrmTables.CanCut: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanCut;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmTables.CanFind: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanFind;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := framDDL.CanFind;
	else
		Result := False;
	end;
end;

function TfrmTables.CanFindNext: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanFindNext;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := framDDL.CanFindNext;
	else
		Result := False;
	end;
end;

function TfrmTables.CanPaste: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanPaste;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmTables.CanRedo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanRedo;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmTables.CanReplace: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
				Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanReplace;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmTables.CanSaveDoco: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanSaveDoco;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

function TfrmTables.CanSelectAll: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanSelectAll;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := framDDL.CanSelectAll;
	else
		Result := False;
	end;
end;

function TfrmTables.CanUndo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := False;

		PG_CONST:
			Result := False;

		PG_INDEX:
			Result := False;

		PG_DEPEND:
			Result := False;

		PG_TRIGGER:
			Result := False;

		PG_DATA:
			Result := False;

		PG_DOCO:
			Result := framDoco.CanUndo;

		PG_GRANTS:
			Result := False;

		PG_DDL:
			Result := False;
	else
		Result := False;
	end;
end;

procedure TfrmTables.DoCaptureSnippet;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:;

		PG_CONST:;

		PG_INDEX:;

		PG_DEPEND:;

		PG_TRIGGER:;

		PG_DATA:;

		PG_DOCO:
			framDoco.CaptureSnippet;

		PG_GRANTS:;

		PG_DDL:
			framDDL.CaptureSnippet;
	end;
end;

procedure TfrmTables.DoCopy;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.CopyToClipboard;

		PG_DDL:
			framDDL.CopyToClipboard;
	end;
end;

procedure TfrmTables.DoCut;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.CutToClipboard;
	end;
end;

procedure TfrmTables.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSFind;

		PG_DDL:
			framDDL.WSFind;
	end;
end;

procedure TfrmTables.DoFindNext;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSFindNext;

		PG_DDL:
			framDDL.WSFindNext;
	end;
end;

procedure TfrmTables.DoPaste;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.PasteFromClipboard;
	end;
end;

procedure TfrmTables.DoRedo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.Redo;
	end;
end;

procedure TfrmTables.DoReplace;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.WSReplace;
	end;
end;

procedure TfrmTables.DoSaveDoco;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.SaveDoco;
	end;
end;

procedure TfrmTables.DoSelectAll;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.SelectAll;

		PG_DDL:
			framDDL.SelectAll;
	end;
end;

procedure TfrmTables.DoUndo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.Undo;
	end;
end;

function TfrmTables.CanObjectNewField: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTableView;
end;

procedure TfrmTables.DoObjectNewField;
begin
	NewField;
end;

function TfrmTables.CanObjectNewTrigger: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTriggerView;
end;

procedure TfrmTables.DoObjectNewTrigger;
begin
	if tvTriggers.Selected <> nil then
	begin
		case tvTriggers.Selected.Level of
			0:
				MarathonIDEInstance.NewTriggerWithInfo(FDatabaseName, '', FObjectName);

			1:
				MarathonIDEInstance.NewTriggerWithInfo(FDatabaseName, AnsiUpperCase(tvTriggers.Selected.Text), FObjectName);

			2:
				MarathonIDEInstance.NewTriggerWithInfo(FDatabaseName, AnsiUpperCase(tvTriggers.Selected.Parent.Text), FObjectName);
		end;
	end
	else
		MarathonIDEInstance.NewTriggerWithInfo(FDatabaseName, '', FObjectName);
end;

function TfrmTables.CanObjectDropField: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsTableView) and (Assigned(lvFieldList.Selected));
end;

procedure TfrmTables.DoObjectDropField;
var
	FErrors: Boolean;
	Idx: Integer;
	FCompileText, DropObjectName: String;
	TmpIntf : IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	if MessageDlg('Are you sure that you wish to drop the field "' + lvFieldList.Selected.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		Idx := lvFieldList.Selected.Index;
		if Idx = lvFieldList.Items.Count - 1 then
			Idx := Idx - 1;

		DropObjectName := lvFieldList.Selected.Caption;

		FCompileText := 'alter table ' + MakeQUotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' drop ' + MakeQUotedIdent(DropObjectName, IsInterbase6, SQLDialect);

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateAlter(Self, TmpIntf, qryTable.IB_Connection, qryTable.IB_Transaction, ctSQL, FCompileText, 'Dropping Column', 'Dropping...');
		FErrors := FCompile.CompileErrors;
		FCompile.Free;
		pgObjectEditorChange(pgObjectEditor);
		if not FErrors then
		begin
			try
				if Assigned(lvFieldList.Items.Item[Idx]) then
				begin
					lvFieldList.Items.Item[Idx].Selected := True;
					lvFieldList.Items.Item[Idx].Focused := True;
				end;
			except
				on E : Exception do
				begin
					// do nothing
				end;
			end;
		end;
	end;
end;

function TfrmTables.CanObjectDropTrigger: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsTriggerView) and
		(tvTriggers.Selected <> nil) and (tvTriggers.Selected.Level = 2);
end;

procedure TfrmTables.DoObjectDropTrigger;
var
	FErrors: Boolean;
	DropObjectName, FCompileText: String;
	N: TTreeNode;
	TmpIntf : IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	if MessageDlg('Are you sure that you wish to drop the trigger "' + tvTriggers.Selected.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		N := tvTriggers.Selected.Parent;
		DropObjectName := tvTriggers.Selected.Text;

		FCompileText := 'drop trigger ' + MakeQuotedIdent(DropObjectName, IsInterbase6, SQLDialect);

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateAlter(Self, TmpIntf, qryTable.IB_Connection, qryTable.IB_Transaction, ctSQL, FCompileText, 'Dropping Trigger', 'Dropping...');
		FErrors := FCompile.CompileErrors;
		FCompile.Free;
		pgObjectEditorChange(pgObjectEditor);

		// Find any trigger forms and drop them
		MarathonIDEInstance.CloseDroppedTrigger(DropObjectName);

		if not FErrors then
		begin
			try
				if Assigned(N) then
				begin
					N.Selected := True;
					N.Focused := True;
				end;
			except
				on E : Exception do
				begin
					// do nothing
				end;
			end;
		end;
	end;
end;

function TfrmTables.CanObjectDropConstraint: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsConstraints) and
						(lvConstraints.Selected <> nil);
end;

procedure TfrmTables.DoObjectDropConstraint;
var
	FErrors: Boolean;
	Idx: Integer;
	DropObjectName, FCompileText: String;
	TmpIntf: IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	if MessageDlg('Are you sure that you wish to drop the constraint "' + lvConstraints.Selected.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		Idx := lvConstraints.Selected.Index;
		if Idx = lvConstraints.Items.Count - 1 then
			Idx := Idx - 1;

		DropObjectName := lvConstraints.Selected.Caption;

		FCompileText := 'alter table ' + MakeQUotedIdent(FObjectName, IsInterbase6, SQLDialect) + ' drop constraint ' + MakeQUotedIdent(DropObjectName, IsInterbase6, SQLDialect);

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateAlter(Self, TmpIntf, qryTable.IB_Connection, qryTable.IB_Transaction, ctSQL, FCompileText, 'Dropping Constraint', 'Dropping...');
		FErrors := FCompile.CompileErrors;
		FCompile.Free;
		pgObjectEditorChange(pgObjectEditor);
		if not FErrors then
		begin
			try
				if Assigned(lvConstraints.Items.Item[Idx]) then
				begin
					lvConstraints.Items.Item[Idx].Selected := True;
					lvConstraints.Items.Item[Idx].Focused := True;
				end;
			except
				on E : Exception do
				begin
					// do nothing
				end;
			end;
		end;
	end;
end;

function TfrmTables.CanObjectDropIndex: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsIndexes) and (Assigned(lvIndex.Selected));
end;

procedure TfrmTables.DoObjectDropIndex;
var
	FErrors: Boolean;
	Idx: Integer;
	DropObjectName, FCompileText: String;
	TmpIntf: IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	if MessageDlg('Are you sure that you wish to drop the index "' + lvIndex.Selected.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		Idx := lvIndex.Selected.Index;
		if Idx = lvIndex.Items.Count - 1 then
			Idx := Idx - 1;

		DropObjectName := lvIndex.Selected.Caption;

		FCompileText := 'drop index ' + MakeQUotedIdent(DropObjectName, IsInterbase6, SQLDialect);

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateAlter(Self, TmpIntf, qryTable.IB_Connection, qryTable.IB_Transaction, ctSQL, FCompileText, 'Dropping Index', 'Dropping...');
		FErrors := FCompile.CompileErrors;
		FCompile.Free;
		pgObjectEditorChange(pgObjectEditor);
		if not FErrors then
		begin
			try
				if Assigned(lvIndex.Items.Item[Idx]) then
				begin
					lvIndex.Items.Item[Idx].Selected := True;
					lvIndex.Items.Item[Idx].Focused := True;
				end;
			except
				On E : Exception do
				begin
					// do nothing
				end;
			end;
		end;
	end;
end;

function TfrmTables.CanObjectProperties: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := (pgObjectEditor.ActivePage = tsTableView) and	(lvFieldList.Selected <> nil);

		PG_INDEX:
			Result := (pgObjectEditor.ActivePage = tsIndexes) and	(lvIndex.Selected <> nil);

		PG_CONST:
			Result := (pgObjectEditor.ActivePage = tsConstraints) and	(lvConstraints.Selected <> nil);
	end;
end;

procedure TfrmTables.DoObjectProperties;
var
	ConstraintType: Byte;
	qryFields: TIBOQuery;
	frmColumns: TfrmColumns;

begin
	try
		qryTable.BeginBusy(False);
		case pgObjectEditor.ActivePage.PageIndex of
			PG_STRUCT:
				begin
					if lvFieldList.Selected <> nil then
					begin
						frmColumns := TfrmColumns.Create(Self);
						with frmColumns do
						begin
							qryFields := TIBOQuery.Create(Self);
							try
								qryFields.IB_Connection := qryTable.IB_Connection;
								qryFields.IB_Transaction := qryTable.IB_Transaction;
								qryFields.Close;
								qryFields.SQL.Clear;
								qryFields.SQL.Add('select RDB$FIELD_SOURCE, RDB$DESCRIPTION, RDB$DEFAULT_SOURCE, RDB$NULL_FLAG ' +
									'from RDB$RELATION_FIELDS where RDB$FIELD_NAME = ''' + lvFieldList.Selected.Caption +
									''' and RDB$RELATION_NAME = ' + AnsiQuotedStr(FObjectName, '''') + ';');
								qryFields.Open;
								DatabaseName := FDatabaseName;
								TableEditor := Self;
								State := stColumnProperties;
								Caption := 'Properties for ' + lvFieldList.Selected.Caption;
								LoadColumn(lvFieldList.Selected.Caption);
								if ShowModal = mrOK then
									Self.pgObjectEditor.OnChange(Self.pgObjectEditor);
							finally
								frmColumns.Free;
								if qryFields.IB_Transaction.Started then
									qryFields.IB_Transaction.Commit;
								qryFields.RequestLive := False;
								qryFields.Free;
							end;
						end;
					end;
				end;

			PG_INDEX:
				with TfrmEditorIndex.CreateModifyIndex(Self, FDatabaseName, FObjectName, lvIndex.Selected.Caption) do
					try
						if ShowModal = mrOK then
							pgObjectEditorChange(pgObjectEditor);
					finally
						Free;
					end;

			PG_CONST:
				begin
					ConstraintType := 0;
					if lvConstraints.Selected.SubItems[0] = 'PRIMARY KEY' then
						ConstraintType := 0
					else
						if lvConstraints.Selected.SubItems[0] = 'FOREIGN KEY' then
							ConstraintType := 1
						else
							if lvConstraints.Selected.SubItems[0] = 'CHECK' then
								ConstraintType := 2
							else
								if lvConstraints.Selected.SubItems[0] = 'UNIQUE' then
									ConstraintType := 3;

					with TfrmEditorConstraint.CreateModifyConstraint(Self, FDatabaseName, FObjectName, lvConstraints.Selected.Caption, ConstraintType) do
						try
							if ShowModal = mrOK then
								pgObjectEditorChange(pgObjectEditor);
						finally
							Free;
						end;
				end;
		end;
	finally
		Screen.Cursor := crDefault;
		qryTable.EndBusy;
	end;
end;

function TfrmTables.CanObjectReorderColumns: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTableView;
end;

procedure TfrmTables.DoObjectReorderColumns;
var
	Idx: Integer;
	F: TfrmReorderColumns;

begin
	F := TfrmReorderColumns.Create(Self);
	try
		for Idx := 0 to lvFieldList.Items.Count - 1 do
			with F.lvColumns.Items.Add do
			begin
				Caption := lvFieldList.Items.Item[Idx].Caption;
				ImageIndex := 6;
			end;

		if F.ShowModal = mrOK then
		begin
			try
				qryTable.BeginBusy(False);
				Screen.Cursor := crHourGlass;
				for Idx := 0 to F.lvColumns.Items.Count - 1 do
				begin
					qryTable.SQL.Clear;
					qryTable.SQL.Add('update rdb$relation_fields set rdb$field_position = ' + IntToStr(Idx) +
						' where rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') +
						' and rdb$field_name = ' + AnsiQuotedStr(F.lvColumns.Items.Item[Idx].Caption, '''') + ';');
					qryTable.ExecSQL;
				end;
				qryTable.IB_Transaction.Commit;
			finally
				qryTable.EndBusy;
				Screen.Cursor := crDefault;
			end;

			pgObjectEditorChange(pgObjectEditor);
		end;
	finally
		F.Free;
	end;
end;

function TfrmTables.CanGrant: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTableView;
end;

procedure TfrmTables.DoGrant;
begin
	with TfrmEditorGrant.Create(Self, FDatabaseName, FObjectName, otTable) do
		try
			if ShowModal = mrOK then
				if pgObjectEditor.ActivePage = tsGrants then
					pgObjectEditor.OnChange(pgObjectEditor);
		finally
			Free;
		end;
end;

function TfrmTables.CanRevoke: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTableView;
end;

procedure TfrmTables.DoRevoke;
begin
	DoGrant;
end;

function TfrmTables.CanObjectNewConstraint: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsConstraints;
end;

procedure TfrmTables.DoObjectNewConstraint;
begin
	NewConstraint;
end;

function TfrmTables.CanObjectNewIndex: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsIndexes;
end;

procedure TfrmTables.DoObjectNewIndex;
begin
	NewIndex;
end;

function TfrmTables.IsInterbaseSix: Boolean;
begin
	Result := IsInterbase6;
end;

function TfrmTables.CanTransactionCommit: Boolean;
begin
	Result := tranTableData.Started;
end;

function TfrmTables.CanTransactionRollback: Boolean;
begin
	Result := tranTableData.Started;
end;

procedure TfrmTables.DoTransactionCommit;
begin
	if gPromptTrans then
	begin
		if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			if tblTableData.State in [dsEdit, dsInsert] then
				tblTableData.Post;

			tblTableData.Close;
			tranTableData.Commit;
			tblTableData.Open;
		end;
	end
	else
	begin
		if tblTableData.State in [dsEdit, dsInsert] then
			tblTableData.Post;

		tblTableData.Close;
		tranTableData.Commit;
		tblTableData.Open;
	end;
end;

procedure TfrmTables.DoTransactionRollback;
begin
	if gPromptTrans then
	begin
		if MessageDlg('Rollback Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			if tblTableData.State in [dsEdit, dsInsert] then
				tblTableData.Post;

			tblTableData.Close;
			tranTableData.Rollback;
			tblTableData.Open;
		end;
	end
	else
	begin
		if tblTableData.State in [dsEdit, dsInsert] then
			tblTableData.Post;

		tblTableData.Close;
		tranTableData.Rollback;
		tblTableData.Open;
	end;
end;

procedure TfrmTables.EnvironmentOptionsRefresh;
begin
	inherited;
end;

procedure TfrmTables.ProjectOptionsRefresh;
begin
	inherited;
end;

function TfrmTables.CanObjectOpenSubObject: Boolean;
begin
	Result := False;
	if pgObjectEditor.ActivePage = tsTriggerView then
	begin
		if tvTriggers.Selected <> nil then
		begin
			case tvTriggers.Selected.Level of
				0:
					Result := False;

				1:
					Result := False;

				2:
					Result := True;
			end;
		end
		else
			Result := False;
	end;
end;

procedure TfrmTables.DoObjectOpenSubObject;
begin
	inherited;
	if pgObjectEditor.ActivePage = tsTriggerView then
		if tvTriggers.Selected <> nil then
			case tvTriggers.Selected.Level of
				2:
					MarathonIDEInstance.OpenTrigger(tvTriggers.Selected.Text, FDatabaseName);
			end;
end;

function TfrmTables.IDEGetActivePage: TGimbalIDETableEditorPage; safecall;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			Result := pgColumns;

		PG_CONST:
			Result := pgContraints;

		PG_INDEX:
			Result := pgIndices;

		PG_DEPEND:
			Result := pgDependencies;

		PG_TRIGGER:
			Result := pgTriggers;

		PG_DATA:
			Result := pgData;

		PG_DOCO:
			Result := pgDocumentation;

		PG_GRANTS:
			Result := pgGrants;

		PG_DDL:
			Result := pgDDL;
	end;
end;

function TfrmTables.IDEGetSelectedItems: IGimbalIDESelectedItems;
var
	Items: TGimbalIDESelectedItems;
	Item: TGimbalIDESelectedItem;

begin
	Items := TGimbalIDESelectedItems.Create;
	Result := Items;
	Item := Items.Add;
	Item.Name := FObjectName;
	Item.ItemType := ctIDETable;
	Item.ConnectionName := FDatabaseName;
end;

function TfrmTables.CanPrint: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		0:
			Result := True;

		1:
			Result := True;

		2:
			Result := True;

		3:
			Result := framDepend.CanPrint;

		4:
			Result := True;

		5:
			Result := True;

		6:
			Result := framDoco.CanPrint;

		7:
			Result := framPerms.CanPrint;

		8:
			Result := framDDL.CanPrint;
	end;
end;

function TfrmTables.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

procedure TfrmTables.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		0:
			MarathonIDEInstance.PrintTableStruct(False, FObjectName, FDatabaseName);

		1:
			MarathonIDEInstance.PrintTableConstraints(False, FObjectName, FDatabaseName);

		2:
			MarathonIDEInstance.PrintTableIndexes(False, FObjectName, FDatabaseName);

		3:
			framDepend.DoPrint;

		4:
			MarathonIDEInstance.PrintTableTriggers(False, FObjectName, FDatabaseName);

		5:
			MarathonIDEInstance.PrintDataSet(tblTableData, False, 'Data for table ' + FObjectName);

		6:
			framDoco.DoPrint;

		7:
			framPerms.DoPrint;

		8:
			framDDL.DoPrint;
	end;
end;

procedure TfrmTables.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		0:
			MarathonIDEInstance.PrintTableStruct(True, FObjectName, FDatabaseName);

		1:
			MarathonIDEInstance.PrintTableConstraints(True, FObjectName, FDatabaseName);

		2:
			MarathonIDEInstance.PrintTableIndexes(True, FObjectName, FDatabaseName);

		3:
			framDepend.DoPrintPreview;

		4:
			MarathonIDEInstance.PrintTableTriggers(True, FObjectName, FDatabaseName);

		5:
			MarathonIDEInstance.PrintDataSet(tblTableData, True, 'Data for table ' + FObjectName);

		6:
			framDoco.DoPrintPreview;

		7:
			framPerms.DoPrintPreview;

		8:
			framDDL.DoPrintPreview;
	end;
end;

procedure TfrmTables.cmbTriggerDisplayChange(Sender: TObject);
begin
	UpdateTriggers;
	inherited;
end;

procedure TfrmTables.sizerect1Click(Sender: TObject);
begin
  showmessage('L:'+inttostr(left) +' T:'+inttostr(top) +' W:'+inttostr(width) +' H:'+inttostr(height));
end;

end.

