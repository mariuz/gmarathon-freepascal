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
// $Id: EditorView.pas,v 1.13 2007/02/10 22:01:14 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{ Old History
	10.04.2002	tmuetze
		* TfrmStoredProcedure.DoGrant, TfrmStoredProcedure.DoRevoke rewritten for new
			and revised EditorGrant
	05.02.2002	tmuetze
		* TfrmViewEditor.FillFieldList, put in a check that makes sure that the IB6 compatible sql statement
			is only issued if we have also dialect 3, e.g. the field rdb&field_precision is not
			available in dialect 1
}

{
$Log: EditorView.pas,v $
Revision 1.13  2007/02/10 22:01:14  rjmills
Fixes for Component Library updates

Revision 1.12  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.11  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.10  2005/05/20 19:24:09  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.9  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.8  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.7  2002/05/06 06:23:32  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.6  2002/04/25 12:31:54  tmuetze
Bugfix for 509075, Syntax error while creating a new view

Revision 1.5  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit EditorView;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, Grids, DBGrids, DBCtrls, StdCtrls,	ExtCtrls, ClipBrd,
	Printers, Tabs, ActnList, Buttons,
	rmPanel,
	rmCollectionListBox,
	rmTabs3x,
	IB_Components,
	IBODataset,
	SynEdit,
  SynEditTypes,
	SyntaxMemoWithStuff2,
	adbpedit,
	BaseDocumentDataAwareForm,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes,
	FrameDependencies,
	FrameDescription,
	FrameMetadata,
	FramePermissions, rmNotebook2;

type
	TfrmViewEditor = class(TfrmBaseDocumentDataAwareForm, IMarathonTableEditor)
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
		tsSQL: TTabSheet;
		lvFieldList: TListView;
		tsDoco: TTabSheet;
    qryTable: TIBOQuery;
    qryTriggers: TIBOQuery;
    tblTableData: TIBOQuery;
    nbResults: TrmNoteBookControl;
    nbpDatasheet : TrmNotebookPage;
    nbpForm : TrmNotebookPage;
		tabResults: TrmTabSet;
		grdDataView: TDBGrid;
		pnledResults: TDBPanelEdit;
		tranTableData: TIB_Transaction;
		tsGrants: TTabSheet;
		btnRefresh: TSpeedButton;
		framDepend: TframeDepend;
		framDoco: TframeDesc;
		framPerms: TframePerms;
    qryUtil: TIBOQuery;
		pnlMessages: TrmPanel;
		lstResults: TrmCollectionListBox;
		edEditor: TSyntaxMemoWithStuff2;
		Panel1: TPanel;
		Label1: TLabel;
		cmbTriggerDisplay: TComboBox;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure tvTriggersDblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure tvTriggersMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure pgObjectEditorChange(Sender: TObject);
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
		procedure edEditorChange(Sender: TObject);
		procedure edEditorKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure edEditorGetHintText(Sender: TObject; Token: String;	var HintText: String; HintType: THintType);
		procedure edEditorDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure edEditorDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
		procedure edEditorStatusChange(Sender: TObject;	Changes: TSynStatusChanges);
		procedure lstResultsDblClick(Sender: TObject);
	private
		{ Private declarations }
		It: TMenuItem;
		FErrors: Boolean;
		LinePos: LongInt;
		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var Message: TMessage);message WM_MOVE;
		procedure CheckCommit;
		procedure DoTableFieldSort(ChangeDir: Boolean);
		procedure FillFieldList;
		procedure LoadViewSource;
	public
		{ Public declarations }
		procedure LoadView(ViewName: String);
		procedure NewView;
		function InternalCloseQuery: Boolean; override;
		procedure ForceRefresh; override;
		procedure SetObjectName(Value: String); override;
		procedure SetObjectModified(Value: Boolean); override;

		procedure SetDatabaseName(const Value: String); override;
		function GetActiveStatusBar: TStatusBar; override;

		function CanPrint: Boolean; override;
		procedure DoPrint; override;

		function CanPrintPreview: Boolean; override;
		procedure DoPrintPreview; override;

		function CanInternalClose: Boolean; override;
		procedure DoInternalClose; override;

		function CanCompile: Boolean; override;
		procedure DoCompile; override;

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

		function CanObjectNewTrigger: Boolean; override;
		procedure DoObjectNewTrigger; override;

		function CanObjectDropTrigger: Boolean; override;
		procedure DoObjectDropTrigger; override;

		function CanTransactionCommit: Boolean; override;
		procedure DOTransactionCommit; override;

		function CanTransactionRollback: Boolean; override;
		procedure DoTransactionRollback; override;

		function CanGrant: Boolean;	override;
		procedure DoGrant;	override;

		function CanRevoke: Boolean;  override;
		procedure DoRevoke;  override;

		function CanQueryBuilder: Boolean; override;
		procedure DoQueryBuilder; override;

		procedure UpdateTriggers;

		function IsInterbaseSix: Boolean;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE,
	MarathonOptions,
	DropObject,
	SaveFileFormat,
	CompileDBObject,
	BlobViewer,
	QBuilder,
	EditorGrant;

{$R *.DFM}

const
	 PG_SQL = 0;
	 PG_STRUCT = 1;
	 PG_DEPEND = 2;
	 PG_TRIGGER = 3;
	 PG_DATA = 4;
	 PG_DOCO = 5;
	 PG_GRANTS = 6;

procedure TfrmViewEditor.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
		WindowState := wsNormal
	else
		BringToFront;
end;

procedure TfrmViewEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	inherited;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[0].Width := lvFieldList.Columns[0].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[1].Width := lvFieldList.Columns[1].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[2].Width := lvFieldList.Columns[2].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[3].Width := lvFieldList.Columns[3].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[4].Width := lvFieldList.Columns[4].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[5].Width := lvFieldList.Columns[5].Width;
	MarathonIDEInstance.CurrentProject.TEFieldsColumns.Items[6].Width := lvFieldList.Columns[6].Width;

	framDepend.SaveColWidths;
	Action := caFree;
end;

procedure TfrmViewEditor.tvTriggersDblClick(Sender: TObject);
begin
	if tvTriggers.Selected <> nil then
		if tvTriggers.Selected.Level = 2 then
			MarathonIDEInstance.OpenTrigger(tvTriggers.Selected.Text, FDatabaseName);
end;

procedure TfrmViewEditor.FormCreate(Sender: TObject);
var
	TmpIntf: IMarathonForm;

begin
	FObjectType := ctView;

	HelpContext := IDH_Table_Editor;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
	Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
	Height := (MarathonScreen.Height div 2) + MarathonIDEInstance.MainForm.FormHeight;
	Width := MarathonScreen.Width - Left + MarathonScreen.Left;
	pnlMessages.Visible := False;

	FCharSet := SetUpEncodingControl(grdDataView);
	FCharSet := SetUpEncodingControl(pnledResults);

	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framDepend.Init(TmpIntf);
	framPerms.Init(TmpIntf);

	It := TMenuItem.Create(Self);
	It.Caption := '&1 View [' + FObjectName + ']';
	It.OnClick := WindowListClick;
	MarathonIDEInstance.AddMenuToMainForm(IT);

	cmbTriggerDisplay.ItemIndex := 0;

  SetupSyntaxEditor(edEditor);
end;

procedure TfrmViewEditor.tvTriggersMouseDown(Sender: TObject;	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	T: TTreeNode;

begin
	if Button = mbRight then
	begin
		T := tvTriggers.GetNodeAt(x, Y);
		tvTriggers.Selected := T;
	end;
end;

procedure TfrmViewEditor.UpdateTriggers;
var
	AbsRoot: TTreeNode;
	Root: TTreeNode;

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

procedure TfrmViewEditor.CheckCommit;
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

procedure TfrmViewEditor.FillFieldList;
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
	if (FIsInterbase6) and (FSQLDialect = 3) then
		qryTable.SQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
			'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
			'b.rdb$computed_source, b.rdb$field_length, b.rdb$field_precision, a.rdb$description, ' +
			'b.rdb$dimensions, ' +
			'b.rdb$field_scale, b.rdb$field_type, b.rdb$field_sub_type from ' +
			'rdb$relation_fields a, rdb$fields b where ' +
			'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
			AnsiQuotedStr(FObjectName, '''') + ' ' + ' order by a.rdb$field_position asc;')
	else
		qryTable.SQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
			'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
			'b.rdb$computed_source, b.rdb$field_length, a.rdb$description, ' +
			'b.rdb$dimensions, ' +
			'b.rdb$field_scale, b.rdb$field_type, b.rdb$field_sub_type from ' +
			'rdb$relation_fields a, rdb$fields b where ' +
			'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
			AnsiQuotedStr(FObjectName, '''') + ' ' + ' order by a.rdb$field_position asc;');
	qryTable.Open;
	while not qryTable.EOF do
	begin
		L := lvFieldList.Items.Add;
		L.ImageIndex := 6;
		L.Caption := qryTable.FieldByName('rdb$field_name').AsString;

		if (FIsInterbase6) and (FSQLDialect = 3) then
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
				qryUtil.Close;
				qryUtil.SQL.Clear;
				qryUtil.SQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
																'rdb$dimension = ' + IntToStr(Idx)	+ 'and rdb$field_name = ' + AnsiQuotedStr(qryTable.FieldByName('rdb$field_source').AsString, ''''));
				qryUtil.Open;
				if not (qryUtil.EOF and qryUtil.BOF) then
					DataTypeText := DataTypeText + qryUtil.FieldByName('rdb$lower_bound').AsString + ':' + qryUtil.FieldByName('rdb$upper_bound').AsString + ', ';
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

procedure TfrmViewEditor.pgObjectEditorChange(Sender: TObject);
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

					// Fix the column widths
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

			PG_DEPEND:
				begin
					CheckCommit;

					framDepend.LoadDependencies;
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
					framDoco.SetActive;
				end;

			PG_GRANTS:
				begin
					CheckCommit;
					framPerms.OpenGrants;
					framPerms.SetActive;
					stsEditor.Panels[0].Text := '';
					stsEditor.Panels[1].Text := '';
					stsEditor.Panels[2].Text := '';
				end;
		end;
	finally
		qryTable.EndBusy;
	end;
end;

procedure TfrmViewEditor.grdDataViewDblClick(Sender: TObject);
begin
	EditBlobColumn(grdDataView.SelectedField);
end;

procedure TfrmViewEditor.tvTriggersGetImageIndex(Sender: TObject;	Node: TTreeNode);
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

procedure TfrmViewEditor.tabResultsChange(Sender: TObject; NewTab: Integer;	var AllowChange: Boolean);
begin
	nbResults.ActivePageIndex := NewTab;
end;

procedure TfrmViewEditor.pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
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

		PG_DEPEND:
			framDepend.SaveColWidths;
	end;
	AllowChange := True;
end;

procedure TfrmViewEditor.lvFieldListDblClick(Sender: TObject);
begin
	if TListView(Sender).Selected <> nil then
		DoObjectProperties;
end;

procedure TfrmViewEditor.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmViewEditor.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmViewEditor.tblTableDataAfterOpen(DataSet: TDataSet);
begin
	GlobalFormatFields(DataSet);
end;

procedure TfrmViewEditor.lvFieldListKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewField;

		VK_DELETE:
			DoObjectDropField;
	end;
end;

procedure TfrmViewEditor.lvConstraintsKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewConstraint;

		VK_DELETE:
			DoObjectDropConstraint;
	end;
end;

procedure TfrmViewEditor.tvTriggersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_INSERT:
			DoObjectNewTrigger;

		VK_DELETE:
			DoObjectDropTrigger;

		VK_RETURN:
			if tvTriggers.Selected <> nil then
				if tvTriggers.Selected.Level = 2 then
					MarathonIDEInstance.OpenTrigger(tvTriggers.Selected.Text, FDatabaseName);
	end;
end;

procedure TfrmViewEditor.lvFieldListColumnClick(Sender: TObject; Column: TListColumn);
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

procedure TfrmViewEditor.DoTableFieldSort(ChangeDir: Boolean);
var
	Idx: Integer;

begin
	if ChangeDir then
	begin
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
	end;
	lvFieldList.CustomSort(@CustomFieldSortProc,0);
	for Idx := 0 to lvFieldList.Columns.Count - 1 do
		lvFieldList.Columns[Idx].ImageIndex := -1;

	if MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortOrder = srtDesc then
		lvFieldList.Columns[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn].ImageIndex := 11
	else
		lvFieldList.Columns[MarathonIDEInstance.CurrentProject.TEFieldsColumns.SortedColumn].ImageIndex := 12;
end;

procedure TfrmViewEditor.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

procedure TfrmViewEditor.LoadView(ViewName: String);
begin
	FObjectName := ViewName;
	InternalCaption := 'View - [' + FObjectName + ']';
	IT.Caption := Caption;
	LoadViewSource;

	pgObjectEditor.ActivePage := tsSQL;
	pgObjectEditorChange(pgObjectEditor);
	ActiveControl := edEditor;
end;

procedure TfrmViewEditor.NewView;
var
	Tmp: String;

begin
	FObjectName := 'new_view';
	InternalCaption := 'View - [' + FObjectName + ']';
	IT.Caption := Caption;
	tmp := 'create view VW_NEW () ' + #13#10;
	tmp := Tmp + 'as' + #13#10;
	edEditor.Text := AdjustLineBreaks(tmp);
	FObjectModified := True;
	FNewObject := True;
	stsEditor.Panels[1].Text := '';
end;

procedure TfrmViewEditor.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

function TfrmViewEditor.InternalCloseQuery: Boolean;
begin
	if not FDropClose then
	begin
		Result := True;
		if framDoco.Modified then
			case MessageDlg('The documentation for view ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
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

procedure TfrmViewEditor.SetObjectModified(Value: Boolean);
begin
	inherited;
	FObjectModified := False;
end;

procedure TfrmViewEditor.SetObjectName(Value: String);
begin
	inherited;
	FObjectName := Value;
	InternalCaption := 'View - [' + FObjectName + ']';
	IT.Caption := Caption;
end;

procedure TfrmViewEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

function TfrmViewEditor.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

procedure TfrmViewEditor.SetDatabaseName(const Value: String);
begin
	inherited;
	if Value = '' then
	begin
		tblTableData.IB_Connection := nil;
		tranTableData.IB_Connection := nil;
		qryTable.IB_Connection := nil;
		qryUtil.IB_Connection := nil;
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

		qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		qryTriggers.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		qryTriggers.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
		framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

		IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qryTable.IB_Connection.SQLDialect;
		stsEditor.Panels[3].Text := Value;
	end;
end;

function TfrmViewEditor.CanInternalClose: Boolean;
begin
	Result := True;
end;

procedure TfrmViewEditor.DoInternalClose;
begin
	inherited;
	Close;
end;

function TfrmViewEditor.CanObjectDrop: Boolean;
begin
	Result := True;
end;

function TfrmViewEditor.CanViewNextPage: Boolean;
begin
	Result := True;
end;

function TfrmViewEditor.CanViewPrevPage: Boolean;
begin
	Result := True;
end;

procedure TfrmViewEditor.DoObjectDrop;
var
	DoClose: Boolean;
	frmDropObject: TfrmDropObject;

begin
	if MessageDlg('Are you sure that you wish to drop the View "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctView, FObjectName);
		DoClose := frmDropObject.ModalResult = mrOK;
		frmDropObject.Free;
		if DoClose then
			DropClose;
	end;
end;

procedure TfrmViewEditor.DOViewNextPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(True);
end;

procedure TfrmViewEditor.DOViewPrevPage;
begin
	inherited;
	pgObjectEditor.SelectNextPage(False);
end;

function TfrmViewEditor.CanCaptureSnippet: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := Length(edEditor.SelText) > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanCopy: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			if lstResults.Focused then
				Result := lstResults.ItemIndex > -1
			else
				Result := Length(edEditor.SelText) > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanCut: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := Length(edEditor.SelText) > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanFind: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.Lines.Count > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanFindNext: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.Lines.Count > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanPaste: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := Clipboard.HasFormat(CF_TEXT);

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanRedo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.CanRedo;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanReplace: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.Lines.Count > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanSaveDoco: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanSelectAll: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.Lines.Count > 0;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

function TfrmViewEditor.CanUndo: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.CanUndo;

		PG_STRUCT:
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
	else
		Result := False;
	end;
end;

procedure TfrmViewEditor.DoCaptureSnippet;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			CaptureCodeSnippet(edEditor);

		PG_DOCO:
			framDoco.CaptureSnippet;
	end;
end;

procedure TfrmViewEditor.DoCopy;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			if lstResults.Focused then
				Clipboard.AsText := lstResults.Collection[lstResults.ItemIndex].TextData.Text
			else
				edEditor.CopyToClipboard;

		PG_DOCO:
			framDoco.CopyToClipboard;
	end;
end;

procedure TfrmViewEditor.DoCut;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.CutToCLipboard;

		PG_DOCO:
			framDoco.CutToClipboard;
	end;
end;

procedure TfrmViewEditor.DoFind;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.WSFind;

		PG_DOCO:
			framDoco.WSFind;
	end;
end;

procedure TfrmViewEditor.DoFindNext;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.WSFindNext;

		PG_DOCO:
			framDoco.WSFindNext;
	end;
end;

procedure TfrmViewEditor.DoPaste;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.PasteFromClipboard;

		PG_DOCO:
			framDoco.PasteFromClipboard;
	end;
end;

procedure TfrmViewEditor.DoRedo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.Redo;

		PG_DOCO:
			framDoco.Redo;
	end;
end;

procedure TfrmViewEditor.DoReplace;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.WSReplace;

		PG_DOCO:
			framDoco.WSReplace;
	end;
end;

procedure TfrmViewEditor.DoSaveDoco;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_DOCO:
			framDoco.SaveDoco;
	end;
end;

procedure TfrmViewEditor.DoSelectAll;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.SelectAll;

		PG_DOCO:
			framDoco.SelectAll;
	end;
end;

procedure TfrmViewEditor.DoUndo;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			edEditor.Undo;

		PG_DOCO:
			framDoco.Undo;
	end;
end;

function TfrmViewEditor.CanObjectNewTrigger: Boolean;
begin
	Result := pgObjectEditor.ActivePage = tsTriggerView;
end;

procedure TfrmViewEditor.DoObjectNewTrigger;
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


function TfrmViewEditor.CanObjectDropTrigger: Boolean;
begin
	Result := (pgObjectEditor.ActivePage = tsTriggerView) and
		(tvTriggers.Selected <> nil) and (tvTriggers.Selected.Level = 2);
end;

procedure TfrmViewEditor.DoObjectDropTrigger;
var
	FErrors: Boolean;
	FCompileText, DropObjectName: String;
	N: TTreeNode;
	TmpIntf: IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	if MessageDlg('Are you sure that you wish to drop the trigger "' + tvTriggers.Selected.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
	begin
		N := tvTriggers.Selected.Parent;
		DropObjectName := tvTriggers.Selected.Text;

		FCompileText := 'drop trigger ' + MakeQUotedIdent(DropObjectName, IsInterbase6, SQLDialect);

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
				on E: Exception do
					// Do nothing
			end;
		end;
	end;
end;

function TfrmViewEditor.IsInterbaseSix: Boolean;
begin
	Result := IsInterbase6;
end;

function TfrmViewEditor.CanTransactionCommit: Boolean;
begin
	Result := tranTableData.Started;
end;

function TfrmViewEditor.CanTransactionRollback: Boolean;
begin
	Result := tranTableData.Started;
end;

procedure TfrmViewEditor.DOTransactionCommit;
begin
	if gPromptTrans then
	begin
		if MessageDlg('Commit Work?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			if tblTableData.State in [dsEdit, dsInsert] then
				tblTableData.Post;

			tblTableData.Close;
			tranTableData.Commit;
			tblTableData.Close;
		end;
	end
	else
	begin
		if tblTableData.State in [dsEdit, dsInsert] then
			tblTableData.Post;

		tblTableData.Close;
		tranTableData.Commit;
		tblTableData.Close;
	end;
end;

procedure TfrmViewEditor.DoTransactionRollback;
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

procedure TfrmViewEditor.EnvironmentOptionsRefresh;
begin
	inherited;

end;

procedure TfrmViewEditor.ProjectOptionsRefresh;
begin
	inherited;

end;

function TfrmViewEditor.CanCompile: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := edEditor.Lines.Count > 0;
	end;
end;

procedure TfrmViewEditor.DoCompile;
var
	Doco: String;
	TmpIntf: IMarathonForm;
	FCompile: TfrmCompileDBObject;

begin
	try
		Doco := framDoco.Doco;

		edEditor.ErrorLine := -1;

		Refresh;

		TmpIntf := Self;
		FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryTable.IB_Connection, qryTable.IB_Transaction, ctView, edEditor.Text);
		FErrors := FCompile.CompileErrors;
		FCompile.Free;

		if FErrors then
			Exit;

		pnlMessages.Visible := False;

		if FNewObject then
			// Update the tree cache
			MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctView);

		FNewObject := False;

		edEditor.Modified := False;
		edEditorChange(edEditor);

		framDoco.Doco := Doco;
		framDoco.SaveDoco;
	finally
		edEditor.SetFocus;
	end;
end;

procedure TfrmViewEditor.edEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_STRUCT:
			FObjectModified := UpdateEditorStatusBar(stsEditor, edEditor);

		PG_DEPEND:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_TRIGGER:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_DATA:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;

		PG_GRANTS:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
			end;
	end;
end;

procedure TfrmViewEditor.edEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	edEditor.ErrorLine := -1;
end;

procedure TfrmViewEditor.edEditorGetHintText(Sender: TObject;	Token: String; var HintText: String; HintType: THintType);
begin
	HintText := MarathonIDEInstance.GetHintTextForToken(Token, ConnectionName);
end;

procedure TfrmViewEditor.edEditorDragDrop(Sender, Source: TObject; X,	Y: Integer);
var
	Tmp: String;

begin
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	if Source is TDragQueen then
		Tmp := TDragQueen(Source).DragText;

	edEditor.SelText := Tmp;
end;

procedure TfrmViewEditor.edEditorDragOver(Sender, Source: TObject; X,	Y: Integer; State: TDragState; var Accept: Boolean);
begin
	SetFocus;
	if edEditor.InsertMode then
		stsEditor.Panels[2].Text := 'Insert'
	else
		stsEditor.Panels[2].Text := 'Overwrite';
	edEditor.CaretXY := TBufferCoord(edEditor.PixelsToRowColumn(X, Y));
	Accept := True;
end;

function TfrmViewEditor.CanGrant: Boolean;
begin
	Result := True;
end;

function TfrmViewEditor.CanQueryBuilder: Boolean;
begin
	Result := False;
end;

function TfrmViewEditor.CanRevoke: Boolean;
begin
	Result := True;
end;

procedure TfrmViewEditor.DoGrant;
begin
	with TfrmEditorGrant.Create(Self, FDatabaseName, FObjectName, otView) do
		try
			if ShowModal = mrOK then
				if pgObjectEditor.ActivePage = tsGrants then
					pgObjectEditor.OnChange(pgObjectEditor);
		finally
			Free;
		end;
end;

procedure TfrmViewEditor.DoQueryBuilder;
var
	B: TQBuilderDialog;

begin
	B := TQBuilderDialog.Create(Self);
	try
		B.OnGetTableColumns := MarathonIDEInstance.GetTableColumnsEvent;
		B.OnGetTables := MarathonIDEInstance.GetTablesEvent;
		B.SystemTables := False;
		if B.Execute then
			edEditor.SelText := B.SQL.Text;
		B.OnGetTableColumns := nil;
		B.OnGetTables := nil;
	finally
		B.Free;
	end;
end;

procedure TfrmViewEditor.DoRevoke;
begin
	DoGrant;
end;

procedure TfrmViewEditor.LoadViewSource;
var
	tmp, tmp1: String;

begin
	qryUtil.Close;
	qryUtil.SQL.Clear;
	if ShouldBeQuoted(FObjectName) then
		tmp := 'create view ' + MakeQuotedIdent(FObjectName, FIsInterbase6, FSQLDialect) + ' (' + #13#10
	else
		tmp := 'create view ' + FObjectName + ' (' + #13#10;


	qryUtil.Close;
	qryUtil.SQL.Clear;
	qryUtil.SQL.Add('select rdb$view_source from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ';');
	qryUtil.Open;
	Tmp1 := ConvertTabs(AdjustLineBreaks(qryUtil.FieldByName('rdb$view_source').AsString), edEditor);
	qryUtil.Close;

	qryUtil.Close;
	qryUtil.SQL.Clear;
	qryUtil.SQL.Add('select a.rdb$field_name ' +
									 'from rdb$relation_fields a, rdb$fields b where a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' + AnsiQuotedStr(FObjectName, '''') + ' ' +
									 ' order by a.rdb$field_position asc;');
	qryUtil.Open;
	while not qryUtil.EOF do
	begin
		Tmp := Tmp + '	' + MakeQuotedIdent(qryUtil.FieldByName('rdb$field_name').AsString, FIsInterbase6, FSQLDialect);
		qryUtil.Next;
		if not qryUtil.EOF then
			Tmp := Tmp + ',' + #13#10;
	end;
	qryUtil.Close;
	Tmp := Tmp + ')' + #13#10 + 'as ' + #13#10 + Trim(Tmp1);
	if qryUtil.IB_Transaction.Started then
		qryUtil.IB_Transaction.Commit;
	edEditor.Text := Tmp;
end;

procedure TfrmViewEditor.edEditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
	inherited;
	edEditorChange(Sender);
end;

function TfrmViewEditor.CanPrint: Boolean;
begin
	Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			Result := (not FNewObject);

		PG_STRUCT:
			Result := (not FNewObject);

		PG_DEPEND:
			Result := (not FNewObject) and framDepend.CanPrint;

		PG_TRIGGER:
			Result := (not FNewObject);

		PG_DATA:
			Result := (not FNewObject);

		PG_DOCO:
			Result := (not FNewObject) and framDoco.CanPrint;

		PG_GRANTS:
			Result := (not FNewObject) and framPerms.CanPrint;
	end;
end;

function TfrmViewEditor.CanPrintPreview: Boolean;
begin
	Result := CanPrint;
end;

procedure TfrmViewEditor.DoPrint;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			MarathonIDEInstance.PrintViewSource(False, FObjectName, FDatabaseName);

		PG_STRUCT:
			MarathonIDEInstance.PrintViewStruct(False, FObjectName, FDatabaseName);

		PG_DEPEND:
			framDepend.DoPrint;

		PG_TRIGGER:
			MarathonIDEInstance.PrintViewTriggers(False, FObjectName, FDatabaseName);

		PG_DATA:
			MarathonIDEInstance.PrintDataSet(tblTableData, False, 'Data for view ' + FObjectName);

		PG_DOCO:
			framDoco.DoPrint;

		PG_GRANTS:
			framPerms.DoPrint;
	end;
end;

procedure TfrmViewEditor.DoPrintPreview;
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_SQL:
			MarathonIDEInstance.PrintViewSource(True, FObjectName, FDatabaseName);

		PG_STRUCT:
			MarathonIDEInstance.PrintViewStruct(True, FObjectName, FDatabaseName);

		PG_DEPEND:
			framDepend.DoPrintPreview;

		PG_TRIGGER:
			MarathonIDEInstance.PrintViewTriggers(True, FObjectName, FDatabaseName);

		PG_DATA:
			MarathonIDEInstance.PrintDataSet(tblTableData, True, 'Data for view ' + FObjectName);

		PG_DOCO:
			framDoco.DoPrintPreview;

		PG_GRANTS:
			framPerms.DoPrintPreview;
	end;
end;

procedure TfrmViewEditor.lstResultsDblClick(Sender: TObject);
var
	Line: String;
	CharPos: Integer;
	FoundLine, FoundChar: Boolean;
	Tok: TToken;
	Parser: TTextParser;

begin
	if lstResults.ItemIndex <> -1 then
	begin
		CharPos := 0;

		edEditor.ErrorLine := -1;

		Line := lstResults.Collection[lstResults.ItemIndex].TextData.Text;

		FoundLine := False;
		FoundChar := False;

		Parser := TTextParser.Create;
		Parser.Input := Line;
		Tok := Parser.NextToken;
		while Tok.TokenType <> tkNone do
		begin
			if AnsiUpperCase(Tok.TokenText)  = 'LINE' then
			begin
				Tok := Parser.NextToken;
				while (Tok.TokenType <> tkNumber) do
				begin
					Tok := Parser.NextToken;
					if Tok.TokenType = tkNone then
						Break;
				end;
				if Tok.TokenType = tkNumber then
				begin
					try
						LinePos := StrToInt(Tok.TokenText);
						FoundLine := True;
					except

					end;
				end;
			end;
			if AnsiUpperCase(Tok.TokenText)  = 'CHAR' then
			begin
				Tok := Parser.NextToken;
				while (Tok.TokenType <> tkNumber) do
				begin
					Tok := Parser.NextToken;
					if Tok.TokenType = tkNone then
						Break;
				end;
				if Tok.TokenType = tkNumber then
				begin
					try
						CharPos := StrToInt(Tok.TokenText);
						FoundChar := True;
					except

					end;
				end;
			end;
			Tok := Parser.NextToken;
		end;
		if FoundChar then
			CharPos := Abs(CharPos)
		else
			CharPos := 1;
		if FoundLine then
			LinePos := Abs(LinePos)
		else
			LinePos := 1;

		if not ((LinePos = 0) and (CharPos = 0)) then
		begin
			edEditor.CaretXY := BufferCoord(CharPos, LinePos);
			edEditor.ErrorLine := LinePos;
			if pgObjectEditor.ActivePage.PageIndex = 0 then
				edEditor.SetFocus;
		end;
	end;
end;

end.


