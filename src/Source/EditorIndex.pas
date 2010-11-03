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
// $Id: EditorIndex.pas,v 1.8 2006/10/19 03:54:58 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{ Old History
	17.03.2002	tmuetze
		* TfrmEditorIndex.btnOKClick, added TfrmCompileDBObject.CreateMultiStatementCompile
			to have a better control if the statement is a multiline one
	15.03.2002	tmuetze
		* Complete rewrite to allow proper adding or modification of an index
		* Renamed from TfrmNewIndex to TfrmEditorIndex
}

{
$Log: EditorIndex.pas,v $
Revision 1.8  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.7  2005/04/13 16:04:27  rjmills
*** empty log message ***

Revision 1.6  2002/09/23 10:28:08  tmuetze
Beautified the sourcecode a bit

Revision 1.5  2002/05/15 08:58:11  tmuetze
Removed some references to TIBGSSDataset

Revision 1.4  2002/04/29 06:47:09  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit EditorIndex;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, DB, ExtCtrls,
	IBODataset,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes;

type
	TfrmEditorIndex = class(TForm, IMarathonBaseForm)
    btnOK: TButton;
		btnCancel: TButton;
		btnHelp: TButton;
    PageControl1: TPageControl;
    tsIndex: TTabSheet;
		Label6: TLabel;
		edIdxName: TEdit;
		lvIdxColumns: TListView;
		Bevel1: TBevel;
		chkUnique: TCheckBox;
		Label2: TLabel;
		cmbOrder: TComboBox;
		chkActive: TCheckBox;
		Label1: TLabel;
		cmbIdxColumn: TComboBox;
		btnAdd: TButton;
		btnDelete: TButton;
		qryIndex: TIBOQuery;
		procedure btnOKClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure btnHelpClick(Sender: TObject);
		procedure btnAddClick(Sender: TObject);
		procedure btnDeleteClick(Sender: TObject);
		procedure edIdxNameChange(Sender: TObject);
		procedure lvIdxColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		FSQLDialect: Integer;
		FModifyIndex: Boolean;
		FIsInterbase6, FIsInterbase5: Boolean;
		FIndexName, FTableName, FDatabaseName: String;
		// Old values, are used to determine if something was changed
		FOldUnique, FOldActive: Boolean;
		FOldOrder: Byte;
		FOldColumns: TStringList;
		{ Private declarations }
		function GetObjectName: String;
		function GetActiveConnectionName: String;
		function GetActiveObjectType: TGSSCacheType;
		function GetActiveStatusBar: TStatusBar;
		function GetObjectNewStatus: Boolean;
		procedure OpenMessages;
		procedure AddCompileError(ErrorText: String);
		procedure ClearErrors;
		procedure ForceRefresh;
		procedure SetObjectName(Value: String);
		procedure SetObjectModified(Value: Boolean);
		procedure SetDatabaseName(const Value: String);
//		property TableName: String read FTableName write FTableName;
//		property DatabaseName: String read FDatabaseName write SetDatabaseName;
	public
		{ Public declarations }
		// This constructor is used whenever an index is modified
		constructor CreateModifyIndex(const AOwner: TComponent; DatabaseName, TableName, IndexName: String);
		// This constructor is used whenever a new index is created
		constructor CreateNewIndex(const AOwner: TComponent; DatabaseName, TableName, NewIndexName: String);
	end;

implementation

uses
	Globals,
	HelpMap,
	Tools,
	MarathonIDE,
	CompileDBObject;

{$R *.DFM}

constructor TfrmEditorIndex.CreateModifyIndex(const AOwner: TComponent; DatabaseName, TableName, IndexName: String);
var
	I: Integer;
	CanAdd: Boolean;
	ColumnItem: TListItem;

begin
	inherited Create(AOwner);
	SetDatabaseName(DatabaseName);
	FModifyIndex := True;
	FTableName := TableName;
	FIndexName := IndexName;

	qryIndex.SQL.Add('select I.RDB$INDEX_NAME, I.RDB$RELATION_NAME, I.RDB$UNIQUE_FLAG, I.RDB$INDEX_INACTIVE,'
		+ ' I.RDB$INDEX_TYPE, ISE.RDB$FIELD_NAME, ISE.RDB$FIELD_POSITION'
		+ ' from RDB$INDICES I left join RDB$INDEX_SEGMENTS ISE on ISE.RDB$INDEX_NAME = I.RDB$INDEX_NAME'
		+ ' where I.RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''') + ' and I.RDB$INDEX_NAME = ' + AnsiQuotedStr(IndexName, '''')
		+ ' order by ISE.RDB$FIELD_POSITION');
	qryIndex.Open;
	chkUnique.Checked := qryIndex.FieldByName('RDB$UNIQUE_FLAG').AsInteger = 1;
	if qryIndex.FieldByName('RDB$INDEX_TYPE').AsInteger = 0 then
		cmbOrder.ItemIndex := 0
	else
		cmbOrder.ItemIndex := 1;
	chkActive.Checked := qryIndex.FieldByName('RDB$INDEX_INACTIVE').AsInteger = 0;
	FOldColumns := TStringList.Create;
	while not qryIndex.Eof do
	begin
		ColumnItem := lvIdxColumns.Items.Add;
		ColumnItem.Caption := qryIndex.FieldByName('RDB$FIELD_NAME').AsString;
		FOldColumns.Add(ColumnItem.Caption);
		qryIndex.Next;
	end;
	qryIndex.Close;

	qryIndex.SQL.Clear;
	qryIndex.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = '
		+ AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
	qryIndex.Open;
	while not qryIndex.Eof do
	begin
		CanAdd := True;
		for I := 0 to lvIdxColumns.Items.Count - 1 do
		begin
			if lvIdxColumns.Items[I].Caption = qryIndex.FieldByName('RDB$FIELD_NAME').AsString then
			begin
				CanAdd := False;
				Break;
			end;
		end;
		if (CanAdd = True) then
			cmbIdxColumn.Items.Add(qryIndex.FieldByName('RDB$FIELD_NAME').AsString);
		qryIndex.Next;
	end;
	qryIndex.Close;

	Caption := 'Modify ' + Caption;
	cmbIdxColumn.ItemIndex := 0;
	edIdxName.Text := IndexName;
	edIdxName.Enabled := False;
	if AnsiUpperCase(Copy(IndexName, 1, 4)) = 'RDB$' then
		Tools.ChangeEnables([chkUnique, cmbOrder, chkActive, cmbIdxColumn, lvIdxColumns, btnAdd, btnDelete], False);

	// Old values, are used to determine if something was changed
	FOldUnique := chkUnique.Checked;
	FOldActive := chkActive.Checked;
	FOldOrder := cmbOrder.ItemIndex;
end;

constructor TfrmEditorIndex.CreateNewIndex(const AOwner: TComponent; DatabaseName, TableName, NewIndexName: String);
begin
	inherited Create(AOwner);
	SetDatabaseName(DatabaseName);
	FModifyIndex := False;
	FTableName := TableName;

	qryIndex.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS'
		+ ' where RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
	qryIndex.Open;
	while not qryIndex.Eof do
	begin
		cmbIdxColumn.Items.Add(qryIndex.FieldByName('RDB$FIELD_NAME').AsString);
		qryIndex.Next;
	end;
	qryIndex.Close;

	Caption := 'New ' + Caption;
	edIdxName.Text := NewIndexName;
	cmbIdxColumn.ItemIndex := 0;
	cmbOrder.ItemIndex := 0;
	chkActive.Enabled := False;
end;

procedure TfrmEditorIndex.AddCompileError(ErrorText: String);
begin
	// Do nothing
end;

procedure TfrmEditorIndex.ClearErrors;
begin
	// Do nothing
end;

procedure TfrmEditorIndex.ForceRefresh;
begin
	Refresh;
end;

function TfrmEditorIndex.GetActiveConnectionName: String;
begin
	Result := FDatabaseName;
end;

function TfrmEditorIndex.GetActiveObjectType: TGSSCacheType;
begin
	Result := ctDontCare;
end;

function TfrmEditorIndex.GetActiveStatusBar: TStatusBar;
begin
	Result := nil;
end;

function TfrmEditorIndex.GetObjectName: String;
begin
	Result := '';
end;

procedure TfrmEditorIndex.OpenMessages;
begin
	// Do nothing
end;

procedure TfrmEditorIndex.SetDatabaseName(const Value: String);
begin
	FDatabaseName := Value;
	qryIndex.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
	qryIndex.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;
	FIsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
	FIsInterbase5 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB5;
	FSQLDialect := qryIndex.IB_Connection.SQLDialect;
end;

procedure TfrmEditorIndex.SetObjectModified(Value: Boolean);
begin
	// Do nothing
end;

procedure TfrmEditorIndex.SetObjectName(Value: String);
begin
	// Do nothing
end;

function TfrmEditorIndex.GetObjectNewStatus: Boolean;
begin
	Result := True;
end;

procedure TfrmEditorIndex.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Add_Index_Dialog;
end;

procedure TfrmEditorIndex.FormShow(Sender: TObject);
begin
	if edIdxName.CanFocus then
		edIdxName.SetFocus
	else
		if cmbIdxColumn.CanFocus then
			cmbIdxColumn.SetFocus;
end;

procedure TfrmEditorIndex.btnOKClick(Sender: TObject);
var
	I: Integer;
	FErrors, ModifiedColumns: Boolean;
	TempText, TempText2: String;
	AlterSQL: TStringList;

begin
	if FModifyIndex = False then
	begin
		// If there is a new index, check that there are included columns
		if Trim(edIdxName.Text) = '' then
		begin
			MessageDlg('The index must have a name.', mtError, [mbOK], 0);
			edIdxName.SetFocus;
			Exit;
		end;
	end;

	// Check for a given name
	if lvIdxColumns.Items.Count = 0 then
	begin
		MessageDlg('Please select the field(s) to be used in the index.', mtError, [mbOK], 0);
		cmbIdxColumn.SetFocus;
		Exit;
	end;

	AlterSQL := TStringList.Create;

	// Build the sql for index modify
	if FModifyIndex then
	begin
    ModifiedColumns := lvIdxColumns.Items.Count <> FOldColumns.count;
//		ModifiedColumns := False;
		// Check if the index columns were changed

    if not ModifiedColumns then
    begin
       for I := 0 to lvIdxColumns.Items.Count - 1 do
         if lvIdxColumns.Items[I].Caption <> FOldColumns[I] then
           ModifiedColumns := True;
    end;

		// Only do it if there was something changed
		if (FOldUnique <> chkUnique.Checked) or (FOldOrder <> cmbOrder.ItemIndex) or (ModifiedColumns) then
		begin

			// First drop the existing index
			AlterSQL.Add('drop index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ';');

			if chkUnique.Checked then
				TempText2 := 'create unique ' + cmbOrder.Text + ' index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '('
			else
				TempText2 := 'create ' + cmbOrder.Text + ' index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '(';

			// Get the column names
			TempText := '';
			for I := 0 to lvIdxColumns.Items.Count - 1 do
				TempText := TempText + MakeQuotedIdent(lvIdxColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
			TempText := Copy(TempText, 1, Length(TempText) - 2);

			AlterSQL.Add(TempText2 + TempText + ');');
		end
		else
			// If the user has only changed the active status
			if FOldActive <> chkActive.Checked then
				if chkActive.Checked then
					AlterSQL.Add('alter index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' active')
				else
					AlterSQL.Add('alter index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' inactive');
	end
	else
	begin
		// Build the sql for a new index
    //removed by RJM....
{		if chkActive.Checked then
			TempText := ' active'
		else
			TempText := ' inactive';}

		if chkUnique.Checked then
			TempText2 := 'create unique ' + cmbOrder.Text + ' index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '('
		else
			TempText2 := 'create ' + cmbOrder.Text + ' index ' + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '(';

{		if chkUnique.Checked then
			TempText2 := 'create unique ' + cmbOrder.Text + ' index ' + TempText + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '('
		else
			TempText2 := 'create ' + cmbOrder.Text + ' index ' + TempText + MakeQuotedIdent(edIdxName.Text, FIsInterbase6, FSQLDialect) + ' on ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + '(';}

		// Get the column names
		TempText := '';
		for I := 0 to lvIdxColumns.Items.Count - 1 do
			TempText := TempText + MakeQuotedIdent(lvIdxColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
		TempText := Copy(TempText, 1, Length(TempText) - 2);

		AlterSQL.Add(TempText2 + TempText + ')');

	end;

	with TfrmCompileDBObject.CreateMultiStatementCompile(Self, Self,
		qryIndex.IB_Connection, qryIndex.IB_Transaction, AlterSQL) do
	begin
		FErrors := CompileErrors;
		Free;
	end;
	if not FErrors then
		ModalResult := mrOK;
end;

procedure TfrmEditorIndex.btnHelpClick(Sender: TObject);
begin
	Application.HelpCommand(HELP_CONTEXT, IDH_Add_Index_Dialog);
end;

procedure TfrmEditorIndex.edIdxNameChange(Sender: TObject);
begin
	CheckNameLength(edIdxName.Text);
end;

procedure TfrmEditorIndex.btnAddClick(Sender: TObject);
var
	Idx: Integer;
	Found: Boolean;

begin
	if cmbIdxColumn.Text <> '' then
	begin
		Found := False;
		for Idx := 0 to lvIdxColumns.Items.Count - 1 do
			if AnsiUpperCase(cmbIdxColumn.Text) = AnsiUpperCase(lvIdxColumns.Items.Item[Idx].Caption) then
			begin
				Found := True;
				Break;
			end;
		if not Found then
			with lvIdxColumns.Items.Add do
				Caption := cmbIdxColumn.Text;
	end;
end;

procedure TfrmEditorIndex.btnDeleteClick(Sender: TObject);
begin
	if Assigned(lvIdxColumns.Selected) then
		if MessageDlg('Are you sure you wish to remove column "' + lvIdxColumns.Selected.Caption + '" from the index?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
			lvIdxColumns.Selected.Delete;
end;

procedure TfrmEditorIndex.lvIdxColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE:
			btnDelete.OnClick(Sender);
	end;
end;

end.


