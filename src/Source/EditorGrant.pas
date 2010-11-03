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
// $Id: EditorGrant.pas,v 1.6 2006/10/22 06:04:28 rjmills Exp $

unit EditorGrant;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, StdCtrls, ComCtrls, CheckLst, CommCtrl, Menus, DB,
	IB_Components,
	IBODataset;

type
	TGrantObjectType = (otTable, otView, otProcedure);

	TfrmEditorGrant = class(TForm)
		dsqlGrants: TIB_DSQL;
		cmbPrivileges: TComboBox;
		Label6: TLabel;
		lblObject: TLabel;
    cmbObjects: TComboBox;
    stsEditorGrant: TStatusBar;
    pmnuGrantRevoke: TPopupMenu;
    mnuiGrantAll: TMenuItem;
    mnuiGrantAllGrantOption: TMenuItem;
    mnuiRevokeAll: TMenuItem;
		N2: TMenuItem;
    mnuiGrantToAll: TMenuItem;
    mnuiGrantToAllGrantOption: TMenuItem;
    mnuiRevokeFromAll: TMenuItem;
		pgEditorGrant: TPageControl;
		tsObjects: TTabSheet;
		tsColumns: TTabSheet;
		lvObjects: TListView;
		lvColumns: TListView;
		lblObjectName: TLabel;
		cmbObjectsNames: TComboBox;
		Label1: TLabel;
		cmbPrivilegeName: TComboBox;
		N4: TMenuItem;
		mnuiGrant: TMenuItem;
		mnuiRevoke: TMenuItem;
		qryGrants: TIBOQuery;
		qryGrants2: TIBOQuery;
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure cmbObjectsChange(Sender: TObject);
		procedure cmbPrivilegesChange(Sender: TObject);
		procedure cmbObjectsNamesChange(Sender: TObject);
		procedure cmbPrivilegeNameChange(Sender: TObject);
		procedure mnuiGrantClick(Sender: TObject);
		procedure mnuiGrantAllClick(Sender: TObject);
		procedure mnuiGrantAllGrantOptionClick(Sender: TObject);
		procedure mnuiGrantToAllClick(Sender: TObject);
		procedure pmnuGrantRevokePopup(Sender: TObject);
		procedure lvObjectsDblClick(Sender: TObject);
		procedure lvObjectsMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure lvColumnsDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
	private
		FObjectName: String;
		FGrantObjectType: TGrantObjectType;
		FClickedOnSubItem: Shortint;
		procedure SetGrantObjectType(const Value: TGrantObjectType);
		property GrantObjectType: TGrantObjectType read FGrantObjectType write SetGrantObjectType;
		{ Private declarations }
	public
		{ Public declarations }
		constructor Create(const AOwner: TComponent; FDatabaseName, ObjectName: String; GrantObjectType: TGrantObjectType); reintroduce; overload;
	end;

implementation

{$R *.DFM}

uses
	Globals,
	HelpMap,
	MarathonIDE;

constructor TfrmEditorGrant.Create(const AOwner: TComponent; FDatabaseName, ObjectName: String; GrantObjectType: TGrantObjectType);
begin
	inherited Create(AOwner);
	qryGrants.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].Connection;
	qryGrants.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].Transaction;
	qryGrants2.IB_Connection := qryGrants.IB_Connection;
	qryGrants2.IB_Transaction := qryGrants.IB_Transaction;
	FObjectName := ObjectName;
	Self.GrantObjectType := GrantObjectType;
end;

procedure TfrmEditorGrant.SetGrantObjectType(const Value: TGrantObjectType);

	procedure SetColumns;
	var
		Column: TListColumn;

	begin
		lvObjects.Columns.Clear;
		case cmbObjects.ItemIndex of
			0, 1: // Tables, Views
			begin
				Column := lvObjects.Columns.Add;
				Column.Caption := 'Name';
				Column.Width := 150;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'select';
				Column.Width := 65;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'update';
				Column.Width := 65;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'delete';
				Column.Width := 65;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'insert';
				Column.Width := 65;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'reference';
				Column.Width := 65;
				tsColumns.TabVisible := True;
			end;
			2: // Procedures
			begin
				Column := lvObjects.Columns.Add;
				Column.Caption := 'Name';
				Column.Width := 150;
				Column := lvObjects.Columns.Add;
				Column.Caption := 'execute';
				Column.Width := 65;
				tsColumns.TabVisible := False;
			end;
		end;
	end;

begin
	FGrantObjectType := Value;
	cmbObjectsNames.Items.Clear;
	case FGrantObjectType of
		otTable:
		begin
			cmbObjects.ItemIndex := 0;
			tsColumns.TabVisible := True;

			qryGrants.SQL.Clear;
			qryGrants.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where'
				+ ' RDB$VIEW_SOURCE is null order by RDB$RELATION_NAME');
			qryGrants.Open;
			while not qryGrants.Eof do
			begin
				cmbObjectsNames.Items.Add(qryGrants.FieldByName('RDB$RELATION_NAME').AsString);
				qryGrants.Next;
			end;
			qryGrants.Close;
		end;

		otView:
		begin
			cmbObjects.ItemIndex := 1;
			tsColumns.TabVisible := True;

			qryGrants.SQL.Clear;
			qryGrants.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where not'
					+ ' RDB$VIEW_SOURCE is null order by RDB$RELATION_NAME');
			qryGrants.Open;
			while not qryGrants.Eof do
			begin
				cmbObjectsNames.Items.Add(qryGrants.FieldByName('RDB$RELATION_NAME').AsString);
				qryGrants.Next;
			end;
			qryGrants.Close;
		end;

		otProcedure:
		begin
			cmbObjects.ItemIndex := 2;
			tsColumns.TabVisible := False;

			qryGrants.SQL.Clear;
			qryGrants.SQL.Add('select RDB$PROCEDURE_NAME from RDB$PROCEDURES order by RDB$PROCEDURE_NAME');
			qryGrants.Open;
			while not qryGrants.Eof do
			begin
				cmbObjectsNames.Items.Add(qryGrants.FieldByName('RDB$PROCEDURE_NAME').AsString);
				qryGrants.Next;
			end;
			qryGrants.Close;
		end;
	end;

	// Set a default object, if FObjectName cannot be found, default to the first item
	cmbObjectsNames.ItemIndex := cmbObjectsNames.Items.IndexOf(FObjectName);
	if cmbObjectsNames.ItemIndex = -1 then
		cmbObjectsNames.ItemIndex := 0;

	// Set the default privilege
	cmbPrivileges.ItemIndex := 0;
	cmbPrivileges.OnChange(Self);

	// Set the appropriate columns
	SetColumns;
end;

procedure TfrmEditorGrant.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
end;

procedure TfrmEditorGrant.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Grant_Editor;
end;

procedure TfrmEditorGrant.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgEditorGrant)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgEditorGrant);
end;

procedure TfrmEditorGrant.pmnuGrantRevokePopup(Sender: TObject);
var
	X, Y: Integer;

begin
	// Grant option is only valid when we want to modify user or roles privileges
	mnuiGrantAllGrantOption.Enabled := (cmbPrivileges.ItemIndex = 0) or (cmbPrivileges.ItemIndex = 1);
	mnuiGrantToAllGrantOption.Enabled := mnuiGrantAllGrantOption.Enabled;

	// Clicked on a subitem, if yes decide if grant or revoke has to be enabled
	X := lvObjects.ScreenToClient(Mouse.CursorPos).X;
	Y := lvObjects.ScreenToClient(Mouse.CursorPos).Y;
	lvObjects.OnMouseDown(Sender, mbLeft, [], X, Y);
	if FClickedOnSubItem >= 0 then
	begin
		mnuiGrant.Enabled := lvObjects.Selected.SubItems[FClickedOnSubItem] = 'No';
		mnuiRevoke.Enabled := not mnuiGrant.Enabled;
	end
	else
	begin
		mnuiGrant.Enabled := False;
		mnuiRevoke.Enabled := False;
	end;
end;

procedure TfrmEditorGrant.mnuiGrantClick(Sender: TObject);
begin
	lvObjects.OnDblClick(Sender);
end;

procedure TfrmEditorGrant.mnuiGrantAllClick(Sender: TObject);
var
	Errors: Boolean;
	GrantOrRevoke, GrantOrRevoke2, PrivilegeFor: String;

begin
	// Do we need to grant or revoke
	if Sender = mnuiGrantAll then
	begin
		GrantOrRevoke := 'grant all on ';
		GrantOrRevoke2 := ' to ';
	end
	else
		if Sender = mnuiRevokeAll then
		begin
			GrantOrRevoke := 'revoke all on ';
			GrantOrRevoke2 := ' from ';
		end;

	// What privilege type we go for
	case cmbPrivileges.ItemIndex of
		0, 1: // Users, Roles
			PrivilegeFor := '';

		2: // Views
			PrivilegeFor := 'view';

		3: // Triggers
			PrivilegeFor := 'trigger';

		4: // Procedures
			PrivilegeFor := 'procedure';
	end;

	// Do the action
	Errors := False;
	try
		try
			qryGrants.SQL.Clear;
			qryGrants.SQL.Add(GrantOrRevoke + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');
			qryGrants.ExecSQL;
		except
			Errors := True;
		end;
	finally
		if Errors then
			qryGrants.IB_Transaction.Rollback
		else
		begin
			qryGrants.IB_Transaction.Commit;
			cmbPrivileges.OnChange(Sender);
		end;
	end;
end;

procedure TfrmEditorGrant.mnuiGrantAllGrantOptionClick(Sender: TObject);
var
	Errors: Boolean;

begin
	// Do the action
	Errors := False;
	try
		try
			qryGrants.SQL.Clear;
			qryGrants.SQL.Add('grant all on ' + cmbObjectsNames.Text + ' to ' + lvObjects.Selected.Caption + ' with grant option;');
			qryGrants.ExecSQL;
		except
			Errors := True;
		end;
	finally
		if Errors then
			qryGrants.IB_Transaction.Rollback
		else
		begin
			qryGrants.IB_Transaction.Commit;
			cmbPrivileges.OnChange(Sender);
		end;
	end;
end;

procedure TfrmEditorGrant.mnuiGrantToAllClick(Sender: TObject);
var
	Errors: Boolean;
	I: Integer;
	GrantOrRevoke, GrantOrRevoke2, PrivilegeFor, GrantOption: String;

begin
	// Do we need to grant or revoke
	if (Sender = mnuiGrantToAll) or (Sender = mnuiGrantToAllGrantOption) then
	begin
		GrantOrRevoke := 'grant ';
		GrantOrRevoke2 := ' to ';
	end
	else
		if Sender = mnuiRevokeFromAll then
		begin
			GrantOrRevoke := 'revoke ';
			GrantOrRevoke2 := ' from ';
		end;

	// Is "with grant option" menu item clicked
	if Sender = mnuiGrantToAllGrantOption then
		GrantOption := ' with grant option'
	else
		GrantOption := '';

	// What privilege type we go for
	case cmbPrivileges.ItemIndex of
		0, 1: // Users, Roles
			PrivilegeFor := '';

		2: // Views
			PrivilegeFor := 'view';

		3: // Triggers
			PrivilegeFor := 'trigger';

		4: // Procedures
			PrivilegeFor := 'procedure';
	end;

	// Do the action
	Errors := False;
	try
		try
			for I := 0 to lvObjects.Items.Count - 1 do
			begin
				qryGrants.SQL.Clear;
				case FClickedOnSubItem of
					0: // Select, execute column
					if cmbObjects.ItemIndex < 2 then // We have tables or views
						qryGrants.SQL.Add(GrantOrRevoke + 'select on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';')
					else // We have a procedure
						qryGrants.SQL.Add(GrantOrRevoke + 'execute on procedure ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';');

					1: // Update column
						qryGrants.SQL.Add(GrantOrRevoke + 'update on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';');

					2: // Delete column
						qryGrants.SQL.Add(GrantOrRevoke + 'delete on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';');

					3: // Insert column
						qryGrants.SQL.Add(GrantOrRevoke + 'insert on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';');

					4: // Reference column
						qryGrants.SQL.Add(GrantOrRevoke + 'references on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Items[I].Caption + GrantOption + ';');
				end;
				qryGrants.ExecSQL;
			end;
		except
			Errors := True;
		end;
	finally
		if Errors then
			qryGrants.IB_Transaction.Rollback
		else
		begin
			qryGrants.IB_Transaction.Commit;
			cmbPrivileges.OnChange(Sender);
		end;
	end;
end;

procedure TfrmEditorGrant.cmbObjectsChange(Sender: TObject);
begin
	SetGrantObjectType(TGrantObjectType(cmbObjects.ItemIndex));
end;

procedure TfrmEditorGrant.cmbObjectsNamesChange(Sender: TObject);
begin
	cmbPrivileges.OnChange(Sender);
end;

procedure TfrmEditorGrant.cmbPrivilegesChange(Sender: TObject);
var
	Grants: array[1..5] of Char;
	ListItem: TListItem;

	procedure FillPermissions(PrivilegeType: String);
	var
		I: Byte;

	begin
		// Fill the permissions
		qryGrants2.SQL.Clear;
		qryGrants2.SQL.Add('select RDB$PRIVILEGE, RDB$GRANT_OPTION from RDB$USER_PRIVILEGES'
			+ ' where RDB$RELATION_NAME = ' + AnsiQuotedStr(cmbObjectsNames.Text, '''')
			+ ' and RDB$USER = ' + AnsiQuotedStr(ListItem.Caption, '''')
			+ ' and RDB$USER_TYPE = ' + PrivilegeType + ' and RDB$FIELD_NAME is null order by RDB$USER');
		qryGrants2.Open;
		for I := 1 to 5 do
			if qryGrants2.Locate('RDB$PRIVILEGE', Grants[I], []) then
			begin
				if qryGrants2.FieldByName('RDB$GRANT_OPTION').AsInteger = 0 then
					ListItem.SubItems.Add('Yes')
				else
					ListItem.SubItems.Add('Yes(GO)');
			end
			else
				ListItem.SubItems.Add('No');
		qryGrants2.Close;
	end;

begin
	Grants[1] := 'S';
	Grants[2] := 'U';
	Grants[3] := 'D';
	Grants[4] := 'I';
	Grants[5] := 'R';

	try
		Screen.Cursor := crHourglass;
		lvObjects.Items.BeginUpdate;

		cmbPrivilegeName.Items.Clear;
		lvObjects.Items.Clear;

		case cmbPrivileges.ItemIndex of
			0: // Users
				begin
					qryGrants.SQL.Clear;
					qryGrants.SQL.Add('select USER from RDB$DATABASE');
					qryGrants.Open;

					// Add the standard grant user PUBLIC
					ListItem := lvObjects.Items.Add;
					ListItem.Caption := 'PUBLIC';
					cmbPrivilegeName.Items.Add(ListItem.Caption);
					FillPermissions('8');

					while not qryGrants.Eof do
					begin
						ListItem := lvObjects.Items.Add;
						ListItem.Caption := qryGrants.FieldByName('USER').AsString;
						cmbPrivilegeName.Items.Add(ListItem.Caption);
						FillPermissions('8');

						qryGrants.Next;
					end;
					qryGrants.Close;
				end;

			1: // Roles
				begin
					qryGrants.SQL.Clear;
					qryGrants.SQL.Add('select RDB$ROLE_NAME from RDB$ROLES order by RDB$ROLE_NAME');
					qryGrants.Open;

					if not qryGrants.Eof then
						while not qryGrants.Eof do
						begin
							ListItem := lvObjects.Items.Add;
							ListItem.Caption := qryGrants.FieldByName('RDB$ROLE_NAME').AsString;
							cmbPrivilegeName.Items.Add(ListItem.Caption);
							FillPermissions('13');

							qryGrants.Next;
						end;
					qryGrants.Close;
				end;

			2: // Views
				begin
					qryGrants.SQL.Clear;
					qryGrants.SQL.Add('select RDB$RELATION_NAME from RDB$RELATIONS where not'
						+ ' (RDB$VIEW_SOURCE is NULL) order by RDB$RELATION_NAME');
					qryGrants.Open;

					if not qryGrants.Eof then
						while not qryGrants.Eof do
						begin
							ListItem := lvObjects.Items.Add;
							ListItem.Caption := qryGrants.FieldByName('RDB$RELATION_NAME').AsString;
							cmbPrivilegeName.Items.Add(ListItem.Caption);
							FillPermissions('1');

							qryGrants.Next;
						end;
					qryGrants.Close;
				end;

			3: // Triggers
				begin
					qryGrants.SQL.Clear;
					qryGrants.SQL.Add('select T.RDB$TRIGGER_NAME from RDB$TRIGGERS T'
						+ ' left join RDB$CHECK_CONSTRAINTS CC on CC.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME'
						+ ' where ((T.RDB$SYSTEM_FLAG = 0) or (T.RDB$SYSTEM_FLAG is null))'
						+ ' and (CC.RDB$TRIGGER_NAME is null) order by T.RDB$TRIGGER_NAME');
					qryGrants.Open;

					if not qryGrants.Eof then
						while not qryGrants.Eof do
						begin
							ListItem := lvObjects.Items.Add;
							ListItem.Caption := qryGrants.FieldByName('RDB$TRIGGER_NAME').AsString;
							cmbPrivilegeName.Items.Add(ListItem.Caption);
							FillPermissions('2');

							qryGrants.Next;
						end;
					qryGrants.Close;
				end;

			4: // Procedures
				begin
					qryGrants.SQL.Clear;
					qryGrants.SQL.Add('select RDB$PROCEDURE_NAME from RDB$PROCEDURES order by RDB$PROCEDURE_NAME');
					qryGrants.Open;

					if not qryGrants.Eof then
						while not qryGrants.Eof do
						begin
							ListItem := lvObjects.Items.Add;
							ListItem.Caption := qryGrants.FieldByName('RDB$PROCEDURE_NAME').AsString;
							cmbPrivilegeName.Items.Add(ListItem.Caption);
							FillPermissions('5');

							qryGrants.Next;
						end;
					qryGrants.Close;
				end;
		end;

		cmbPrivilegeName.ItemIndex := 0;
		cmbPrivilegeName.OnChange(Sender);
	finally
		lvObjects.Items.EndUpdate;
		Screen.Cursor := crDefault;
	end;
end;

procedure TfrmEditorGrant.cmbPrivilegeNameChange(Sender: TObject);
var
	I: Integer;
	Grants: array[1..2] of Char;

	procedure FillColumnPermissions(PrivilegeType: String);
	var
		I: Byte;
		ListItem: TListItem;

	begin
		ListItem := lvColumns.Items.Add;
		ListItem.Caption := qryGrants.FieldByName('RDB$FIELD_NAME').AsString;

		// Fill the column permissions
		qryGrants2.SQL.Clear;
		qryGrants2.SQL.Add('select RDB$PRIVILEGE, RDB$GRANT_OPTION from RDB$USER_PRIVILEGES'
			+ ' where RDB$RELATION_NAME = ' + AnsiQuotedStr(cmbObjectsNames.Text, '''')
			+ ' and RDB$USER = ' + AnsiQuotedStr(cmbPrivilegeName.Text, '''')
			+ ' and RDB$USER_TYPE = ' + PrivilegeType + ' and RDB$FIELD_NAME = '
			+ AnsiQuotedStr(qryGrants.FieldByName('RDB$FIELD_NAME').AsString, '''')
			+ ' order by RDB$USER');
		qryGrants2.Open;
		for I := 1 to 2 do
			if qryGrants2.Locate('RDB$PRIVILEGE', Grants[I], []) then
			begin
				if qryGrants2.FieldByName('RDB$GRANT_OPTION').AsInteger = 0 then
					ListItem.SubItems.Add('Yes')
				else
					ListItem.SubItems.Add('Yes(GO)');
			end
			else
				ListItem.SubItems.Add('No');
		qryGrants2.Close;
	end;

begin
	Grants[1] := 'U';
	Grants[2] := 'R';

	try
		Screen.Cursor := crHourGlass;
		lvColumns.Items.BeginUpdate;

		lvColumns.Items.Clear;

		qryGrants.SQL.Clear;
		qryGrants.SQL.Add('select RF.RDB$FIELD_NAME, F.RDB$FIELD_TYPE, F.RDB$FIELD_LENGTH,'
			+ ' F.RDB$FIELD_SCALE, F.RDB$FIELD_SUB_TYPE from RDB$RELATION_FIELDS RF'
			+ ' left join RDB$FIELDS F on F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE'
			+ ' where RF.RDB$RELATION_NAME = ' + AnsiQuotedStr(cmbObjectsNames.Text, '''')
			+ ' order by RF.RDB$FIELD_POSITION');
		qryGrants.Open;
		while not qryGrants.Eof do
		begin
			case cmbPrivileges.ItemIndex of
				0: // Users
					FillColumnPermissions('8');

				1: // Roles
					FillColumnPermissions('13');

				2: // Views
					FillColumnPermissions('1');

				3: // Triggers
					FillColumnPermissions('2');

				4: // Procedures
					FillColumnPermissions('5');
			end;
			qryGrants.Next;
		end;
		qryGrants.Close;

		for I := 0 to lvObjects.Items.Count - 1 do
			if lvObjects.Items[I].Caption = cmbPrivilegeName.Text then
			begin
				lvObjects.Selected := lvObjects.Items[I];
				Exit;
			end;
	finally
		lvColumns.Items.EndUpdate;
		Screen.Cursor := crDefault;
	end;
end;

procedure TfrmEditorGrant.lvObjectsDblClick(Sender: TObject);
var
	Errors: Boolean;
	GrantOrRevoke, GrantOrRevoke2, PrivilegeFor: String;

begin
	if FClickedOnSubItem >= 0 then
	begin
		// Do we need to grant or revoke
		if lvObjects.Selected.SubItems[FClickedOnSubItem] = 'No' then
		begin
			GrantOrRevoke := 'grant ';
			GrantOrRevoke2 := ' to ';
		end
		else
		begin
			GrantOrRevoke := 'revoke ';
			GrantOrRevoke2 := ' from ';
		end;

		// What privilege type we go for
		case cmbPrivileges.ItemIndex of
			0, 1: // Users, Roles
				PrivilegeFor := '';

			2: // Views
				PrivilegeFor := ' view ';

			3: // Triggers
				PrivilegeFor := ' trigger ';

			4: // Procedures
				PrivilegeFor := ' procedure ';
		end;

		// do the action
		Errors := False;
		try
			try
				qryGrants.SQL.Clear;
				case FClickedOnSubItem of
					0: // select, execute column
						if cmbObjects.ItemIndex < 2 then
							qryGrants.SQL.Add(GrantOrRevoke + 'select on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';')
						else
							qryGrants.SQL.Add(GrantOrRevoke + 'execute on procedure ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');

					1: // update column
						qryGrants.SQL.Add(GrantOrRevoke + 'update on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');

					2: // delete column
						qryGrants.SQL.Add(GrantOrRevoke + 'delete on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');

					3: // insert column
						qryGrants.SQL.Add(GrantOrRevoke + 'insert on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');

					4: // reference column
						qryGrants.SQL.Add(GrantOrRevoke + 'references on ' + cmbObjectsNames.Text + GrantOrRevoke2 + PrivilegeFor + lvObjects.Selected.Caption + ';');
				end;
				qryGrants.ExecSQL;
			except
				Errors := True;
			end;
		finally
			if Errors then
				qryGrants.IB_Transaction.Rollback
			else
			begin
				qryGrants.IB_Transaction.Commit;
				if lvObjects.Selected.SubItems[FClickedOnSubItem] = 'No' then
					lvObjects.Selected.SubItems[FClickedOnSubItem] := 'Yes'
				else
					lvObjects.Selected.SubItems[FClickedOnSubItem] := 'No';
			end;
		end;
	end;
end;

procedure TfrmEditorGrant.lvObjectsMouseDown(Sender: TObject;	Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
var
	Item: TListItem;
	HitTestInfo: TLVHitTestInfo;

begin
	Item := (Sender as TListView).GetItemAt(X, Y);
	if Assigned(Item) then
	begin
		HitTestInfo.pt := Point(X, Y);
		ListView_SubItemHitTest((Sender as TListView).Handle, @HitTestInfo);
		FClickedOnSubItem := HitTestInfo.iSubItem - 1;
	end
	else
		FClickedOnSubItem := -1;
end;

procedure TfrmEditorGrant.lvColumnsDblClick(Sender: TObject);
var
	Errors: Boolean;
	GrantOrRevoke, GrantOrRevoke2: String;

begin

	if FClickedOnSubItem >= 0 then
	begin
		// Do we need to grant or revoke
		if lvColumns.Selected.SubItems[FClickedOnSubItem] = 'No' then
		begin
			GrantOrRevoke := 'grant ';
			GrantOrRevoke2 := ' to ';
		end
		else
		begin
			GrantOrRevoke := 'revoke ';
			GrantOrRevoke2 := ' from ';
		end;

		// Do the action
		Errors := False;
		try
			try
				qryGrants.SQL.Clear;
				case FClickedOnSubItem of
					0: // Update column
						qryGrants.SQL.Add(GrantOrRevoke + 'update(' + lvColumns.Selected.Caption + ') on ' + cmbObjectsNames.Text + GrantOrRevoke2 + cmbPrivilegeName.Text + ';');

					1: // Reference column
						qryGrants.SQL.Add(GrantOrRevoke + 'references(' + lvColumns.Selected.Caption + ') on ' + cmbObjectsNames.Text + GrantOrRevoke2 + cmbPrivilegeName.Text + ';');
				end;
				qryGrants.ExecSQL;
			except
				Errors := True;
			end;
		finally
			if Errors then
				qryGrants.IB_Transaction.Rollback
			else
			begin
				qryGrants.IB_Transaction.Commit;
				if lvColumns.Selected.SubItems[FClickedOnSubItem] = 'No' then
					lvColumns.Selected.SubItems[FClickedOnSubItem] := 'Yes'
				else
					lvColumns.Selected.SubItems[FClickedOnSubItem] := 'No';
			end;
		end;
	end;
end;

end.

{ Old History
	26.03.2002	tmuetze
		* Renamed from to GrantEditor to EditorGrant
		* Complete rewrite to allow proper granting and revoking
	20.03.2002	tmuetze
		+ Added in TfrmGrantEditor.FormShow the setting of the Panel1 and Panel2
			BevelInner and BevelOuter properties, this has been done to enhance the
			D5 compatibility
}

{
$Log: EditorGrant.pas,v $
Revision 1.6  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.5  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.4  2002/04/29 06:47:09  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
