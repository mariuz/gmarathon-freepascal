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
// $Id: EditorConstraint.pas,v 1.8 2007/06/15 21:31:32 rjmills Exp $

{ Old History
	17.03.2002
		* Complete rewrite to allow proper adding or modification of constraints
		* Renamed from TfrmNewConstraint to TfrmEditorConstraint
}

{
$Log: EditorConstraint.pas,v $
Revision 1.8  2007/06/15 21:31:32  rjmills
Numerous bug fixes and current work in progress

Revision 1.7  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.6  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.5  2002/05/15 08:58:11  tmuetze
Removed some references to TIBGSSDataset

Revision 1.4  2002/04/29 11:35:41  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/29 06:47:09  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit EditorConstraint;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, DB, Grids, DBGrids, math,
	IBODataset,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes, ActnList;

type
	TfrmEditorConstraint = class(TForm, IMarathonBaseForm)
    btnOK: TButton;
    btnCancel: TButton;
		btnHelp: TButton;
    pgConstraint: TPageControl;
    tsPK: TTabSheet;
		tsFK: TTabSheet;
    tsCheck: TTabSheet;
    Label1: TLabel;
    lvFKColumns: TListView;
		lvFKRefColumns: TListView;
    Label4: TLabel;
		cmbTables: TComboBox;
		Label5: TLabel;
    edCheck: TMemo;
    Label6: TLabel;
    edCheckName: TEdit;
    Label7: TLabel;
    edPKName: TEdit;
    lvPKColumns: TListView;
    cmbPKColumn: TComboBox;
    btnPKAdd: TButton;
    btnPKDelete: TButton;
    Label9: TLabel;
    edFKName: TEdit;
    Label10: TLabel;
    cmbFKRefColumns: TComboBox;
    btnFKRefAdd: TButton;
    btnFKRefDelete: TButton;
    Label11: TLabel;
    cmbFKColumns: TComboBox;
    btnFKAdd: TButton;
    btnFKDelete: TButton;
    chkOnDelete: TCheckBox;
    chkOnUpdate: TCheckBox;
    cmbOnDelete: TComboBox;
		cmbOnUpdate: TComboBox;
    tsUnique: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    edUniqueName: TEdit;
		lvUniqueColumns: TListView;
    cmbUniqueColumn: TComboBox;
    btnUniqueAdd: TButton;
    btnUniqueDelete: TButton;
    qryConstraint: TIBOQuery;
    ActionList1: TActionList;
    actFKAdd: TAction;
    actFKDelete: TAction;
    actFKAdd1: TAction;
    actFKDelete1: TAction;
    actPKAdd: TAction;
    actPKDelete: TAction;
    actUCAdd: TAction;
    actUCDelete: TAction;
    procedure cmbTablesChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
		procedure lvPKColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure edPKNameChange(Sender: TObject);
		procedure lvFKColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure lvFKRefColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure lvUniqueColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormShow(Sender: TObject);
    procedure actFKAddExecute(Sender: TObject);
    procedure actFKAddUpdate(Sender: TObject);
    procedure actFKDeleteExecute(Sender: TObject);
    procedure actFKDeleteUpdate(Sender: TObject);
    procedure actFKAdd1Execute(Sender: TObject);
    procedure actFKAdd1Update(Sender: TObject);
    procedure actFKDelete1Execute(Sender: TObject);
    procedure actFKDelete1Update(Sender: TObject);
    procedure actPKAddExecute(Sender: TObject);
    procedure actPKAddUpdate(Sender: TObject);
    procedure actPKDeleteExecute(Sender: TObject);
    procedure actPKDeleteUpdate(Sender: TObject);
    procedure actUCAddExecute(Sender: TObject);
    procedure actUCAddUpdate(Sender: TObject);
    procedure actUCDeleteExecute(Sender: TObject);
    procedure actUCDeleteUpdate(Sender: TObject);
	private
		FSQLDialect: Integer;
		FModifyConstraint: Boolean;
		FIsInterbase6, FIsInterbase5: Boolean;
		FConstraintName, FTableName, FDatabaseName: String;
		// Old values, are used to determine if something was changed
		FOldFKTable, FOldDeleteRule, FOldUpdateRule, FOldCheckText: String;
		FOldColumns, FOldRefColumns: TStringList;
		{ Private declarations }
		procedure OpenMessages;
		procedure ClearErrors;
		procedure ForceRefresh;
		procedure AddCompileError(ErrorText: String);
		procedure SetObjectName(Value: String);
		procedure SetObjectModified(Value: Boolean);
		procedure SetDatabaseName(const Value: String);
		function GetObjectName: String;
		function GetActiveConnectionName: String;
		function GetActiveObjectType: TGSSCacheType;
		function GetActiveStatusBar: TStatusBar;
		function GetObjectNewStatus: Boolean;
		function GetCheck: String;
//		property TableName: String read FTableName write FTableName;
//		property DatabaseName: String read FDatabaseName write SetDatabaseName;
	public
		{ Public declarations }
		// This constructor is used whenever a constraint is modified
		constructor CreateModifyConstraint(const AOwner: TComponent; DatabaseName, TableName,
			ConstraintName: String; PageIndex: Byte);
		// This constructor is used whenever a new constraint is created
		constructor CreateNewConstraint(const AOwner: TComponent; DatabaseName, TableName,
			NewPKName, NewFKName, NewCheckName, NewUniqueName: String);
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE,
	CompileDBObject;

{$R *.DFM}

const
	 PG_PKEY = 0;
	 PG_FKEY = 1;
	 PG_CHECK = 2;
	 PG_UNIQUE = 3;

constructor TfrmEditorConstraint.CreateModifyConstraint(const AOwner: TComponent; DatabaseName, TableName, ConstraintName: String; PageIndex: Byte);
var
	I: Integer;
	CanAdd: Boolean;
	ColumnItem: TListItem;

begin
	inherited Create(AOwner);
	SetDatabaseName(DatabaseName);
	FModifyConstraint := True;
	FTableName := TableName;
	FConstraintName := ConstraintName;
	FOldColumns := TStringList.Create;

	case PageIndex of
		PG_PKEY:
			begin
				qryConstraint.SQL.Add('select I.RDB$FIELD_NAME'
					+ ' from RDB$RELATION_CONSTRAINTS RC join RDB$INDEX_SEGMENTS I on I.RDB$INDEX_NAME = RC.RDB$INDEX_NAME'
					+ ' where RC.RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''')
					+ ' and RC.RDB$CONSTRAINT_NAME = ' + AnsiQuotedStr(ConstraintName, '''') + ' order by I.RDB$FIELD_POSITION');
				qryConstraint.Open;
				while not qryConstraint.Eof do
				begin
					ColumnItem := lvPKColumns.Items.Add;
					ColumnItem.Caption := qryConstraint.FieldByName('RDB$FIELD_NAME').AsString;
					FOldColumns.Add(ColumnItem.Caption);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				qryConstraint.SQL.Clear;
				qryConstraint.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = '
					+ AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
				qryConstraint.Open;
				while not qryConstraint.Eof do
				begin
					CanAdd := True;
					for I := 0 to lvPKColumns.Items.Count - 1 do
					begin
						if lvPKColumns.Items[I].Caption = qryConstraint.FieldByName('RDB$FIELD_NAME').AsString then
						begin
							CanAdd := False;
							Break;
						end;
					end;
					if (CanAdd = True) then
						cmbPKColumn.Items.Add(qryConstraint.FieldByName('RDB$FIELD_NAME').AsString);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				edPKName.Text := ConstraintName;
				cmbPKColumn.ItemIndex := 0;
				tsFK.TabVisible := False;
				tsCheck.TabVisible := False;
				tsUnique.TabVisible := False;
			end;

		PG_FKEY:
			begin
				FOldRefColumns := TStringList.Create;
				qryConstraint.SQL.Add('select RC.RDB$CONSTRAINT_NAME, REFC.RDB$UPDATE_RULE,'
					+ ' REFC.RDB$DELETE_RULE, RC2.RDB$RELATION_NAME as FK_TABLE,'
					+ ' ISEG.RDB$FIELD_NAME as FK_FIELD, ISEG2.RDB$FIELD_NAME as ON_FIELD'
					+ ' from RDB$RELATION_CONSTRAINTS RC'
					+ ' join RDB$REF_CONSTRAINTS REFC on RC.RDB$CONSTRAINT_NAME = REFC.RDB$CONSTRAINT_NAME'
					+ ' join RDB$RELATION_CONSTRAINTS RC2 on REFC.RDB$CONST_NAME_UQ = RC2.RDB$CONSTRAINT_NAME'
					+ ' join RDB$INDEX_SEGMENTS ISEG on RC2.RDB$INDEX_NAME = ISEG.RDB$INDEX_NAME'
					+ ' join RDB$INDEX_SEGMENTS ISEG2 on RC.RDB$INDEX_NAME = ISEG2.RDB$INDEX_NAME'
					+ ' where RC.RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''')
					+ ' and RC.RDB$CONSTRAINT_NAME = ' + AnsiQuotedStr(ConstraintName, '''') + ' order by ISEG.RDB$FIELD_POSITION');
				qryConstraint.Open;
				FOldFKTable := qryConstraint.FieldByName('FK_TABLE').AsString;
				FOldDeleteRule := qryConstraint.FieldByName('RDB$DELETE_RULE').AsString;
				FOldUpdateRule := qryConstraint.FieldByName('RDB$UPDATE_RULE').AsString;
				while not qryConstraint.Eof do
				begin
					ColumnItem := lvFKColumns.Items.Add;
					ColumnItem.Caption := qryConstraint.FieldByName('ON_FIELD').AsString;
					FOldColumns.Add(ColumnItem.Caption);
					ColumnItem := lvFKRefColumns.Items.Add;
					ColumnItem.Caption := qryConstraint.FieldByName('FK_FIELD').AsString;
					FOldRefColumns.Add(ColumnItem.Caption);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				qryConstraint.SQL.Clear;
				qryConstraint.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = '
					+ AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
				qryConstraint.Open;
				while not qryConstraint.Eof do
				begin
					CanAdd := True;
					for I := 0 to lvFKColumns.Items.Count - 1 do
					begin
						if lvFKColumns.Items[I].Caption = qryConstraint.FieldByName('RDB$FIELD_NAME').AsString then
						begin
							CanAdd := False;
							Break;
						end;
					end;
					if (CanAdd = True) then
						cmbFKColumns.Items.Add(qryConstraint.FieldByName('RDB$FIELD_NAME').AsString);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				edFKName.Text := ConstraintName;
				cmbFKColumns.ItemIndex := -1;
        cmbFKRefColumns.itemindex := -1;
				cmbTables.Items.Assign(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].TableList);
				cmbTables.ItemIndex := cmbTables.Items.IndexOf(FOldFKTable);
				cmbTables.OnChange(cmbTables);

				cmbOnDelete.ItemIndex := ifthen(ansilowercase(FOldDeleteRule) = 'restrict', 0, cmbOnDelete.Items.IndexOf(FOldDeleteRule));
        chkOnDelete.checked := (ansilowercase(FOldDeleteRule) = 'no action');

				cmbOnUpdate.ItemIndex := ifthen(ansilowercase(FOldUpdateRule) = 'restrict', 0, cmbOnUpdate.Items.IndexOf(FOldUpdateRule));
        chkOnUpdate.checked := (ansilowercase(FOldUpdateRule) = 'no action');

				tsPK.TabVisible := False;
				tsCheck.TabVisible := False;
				tsUnique.TabVisible := False;
			end;

		PG_CHECK:
			begin
				qryConstraint.SQL.Add('select T.RDB$TRIGGER_SOURCE from RDB$RELATION_CONSTRAINTS RC'
					+ ' join RDB$CHECK_CONSTRAINTS CC on RC.RDB$CONSTRAINT_NAME = CC.RDB$CONSTRAINT_NAME'
					+ ' join RDB$TRIGGERS T on CC.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME'
					+ ' where RC.RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''')
					+ ' and RC.RDB$CONSTRAINT_NAME = ' + AnsiQuotedStr(ConstraintName, '''')
					+ ' and T.RDB$TRIGGER_TYPE = 1');
				qryConstraint.Open;
				FOldCheckText := qryConstraint.FieldByName('RDB$TRIGGER_SOURCE').AsString;
				qryConstraint.Close;

				edCheckName.Text := ConstraintName;
				edCheck.Text := FOldCheckText;
				tsPK.TabVisible := False;
				tsFK.TabVisible := False;
				tsUnique.TabVisible := False;
			end;

		PG_UNIQUE:
			begin
				qryConstraint.SQL.Add('select I.RDB$FIELD_NAME'
					+ ' from RDB$RELATION_CONSTRAINTS RC join RDB$INDEX_SEGMENTS I on I.RDB$INDEX_NAME = RC.RDB$INDEX_NAME'
					+ ' where RC.RDB$RELATION_NAME = ' + AnsiQuotedStr(TableName, '''')
					+ ' and RC.RDB$CONSTRAINT_NAME = ' + AnsiQuotedStr(ConstraintName, '''') + ' order by I.RDB$FIELD_POSITION');
				qryConstraint.Open;
				while not qryConstraint.Eof do
				begin
					ColumnItem := lvUniqueColumns.Items.Add;
					ColumnItem.Caption := qryConstraint.FieldByName('RDB$FIELD_NAME').AsString;
					FOldColumns.Add(ColumnItem.Caption);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				qryConstraint.SQL.Clear;
				qryConstraint.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = '
					+ AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
				qryConstraint.Open;
				while not qryConstraint.Eof do
				begin
					CanAdd := True;
					for I := 0 to lvUniqueColumns.Items.Count - 1 do
					begin
						if lvUniqueColumns.Items[I].Caption = qryConstraint.FieldByName('RDB$FIELD_NAME').AsString then
						begin
							CanAdd := False;
							Break;
						end;
					end;
					if (CanAdd = True) then
						cmbUniqueColumn.Items.Add(qryConstraint.FieldByName('RDB$FIELD_NAME').AsString);
					qryConstraint.Next;
				end;
				qryConstraint.Close;

				edUniqueName.Text := ConstraintName;
				cmbUniqueColumn.ItemIndex := 0;
				tsPK.TabVisible := False;
				tsFK.TabVisible := False;
				tsCheck.TabVisible := False;
			end;
	end;
	Caption := 'Modify ' + Caption;
end;

constructor TfrmEditorConstraint.CreateNewConstraint(const AOwner: TComponent; DatabaseName, TableName,
	NewPKName, NewFKName, NewCheckName, NewUniqueName: String);
begin
	inherited Create(AOwner);
	SetDatabaseName(DatabaseName);
	FModifyConstraint := False;
	FTableName := TableName;
	// Primary key
	qryConstraint.SQL.Clear;
	qryConstraint.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = '
		+ AnsiQuotedStr(TableName, '''') + ' order by RDB$FIELD_POSITION');
	qryConstraint.Open;
	while not qryConstraint.Eof do
	begin
		cmbPKColumn.Items.Add(qryConstraint.FieldByName('RDB$FIELD_NAME').AsString);
		qryConstraint.Next;
	end;
	qryConstraint.Close;

	edPKName.Text := NewPKName;
	cmbPKColumn.ItemIndex := 0;

	// Foreign key
	cmbFKColumns.Items.Assign(cmbPKColumn.Items);
	edFKName.Text := NewFKName;
	cmbFKColumns.ItemIndex := 0;
	cmbTables.Items.Assign(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].TableList);
	cmbTables.ItemIndex := cmbTables.Items.IndexOf(FOldFKTable);
	cmbTables.OnChange(cmbTables);
	cmbOnDelete.ItemIndex := 0;
	cmbOnUpdate.ItemIndex := 0;

	// Check constraint
	edCheckName.Text := NewCheckName;

	// Unique constraint
	cmbUniqueColumn.Items.Assign(cmbPKColumn.Items);
	edUniqueName.Text := NewUniqueName;
	cmbUniqueColumn.ItemIndex := 0;

	Caption := 'Add ' + Caption;
end;

procedure TfrmEditorConstraint.AddCompileError(ErrorText: String);
begin
	// Do nothing
end;

procedure TfrmEditorConstraint.ClearErrors;
begin
	// Do nothing
end;

procedure TfrmEditorConstraint.ForceRefresh;
begin
	Refresh;
end;

function TfrmEditorConstraint.GetActiveConnectionName: String;
begin
	Result := FDatabaseName;
end;

function TfrmEditorConstraint.GetActiveObjectType: TGSSCacheType;
begin
	Result := ctDontCare;
end;

function TfrmEditorConstraint.GetActiveStatusBar: TStatusBar;
begin
	Result := nil;
end;

function TfrmEditorConstraint.GetObjectName: String;
begin
	Result := '';
end;

procedure TfrmEditorConstraint.OpenMessages;
begin
	// Do nothing
end;

procedure TfrmEditorConstraint.SetObjectModified(Value: Boolean);
begin
	// Do nothing
end;

procedure TfrmEditorConstraint.SetObjectName(Value: String);
begin
	// Do nothing
end;

procedure TfrmEditorConstraint.SetDatabaseName(const Value: String);
begin
	FDatabaseName := Value;
	qryConstraint.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
	qryConstraint.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;
	FIsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
	FIsInterbase5 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB5;
	FSQLDialect := qryConstraint.IB_Connection.SQLDialect;

	if FIsInterbase5 or FIsInterbase6 then
	begin
		chkOnDelete.Enabled := True;
		chkOnUpdate.Enabled := True;
		cmbOnDelete.Enabled := True;
		cmbOnUpdate.Enabled := True;
		cmbOnDelete.ItemIndex := 0;
		cmbOnUpdate.ItemIndex := 0;
	end
	else
	begin
		chkOnDelete.Enabled := False;
		chkOnUpdate.Enabled := False;
		cmbOnDelete.Enabled := False;
		cmbOnUpdate.Enabled := False;
	end;
end;


function TfrmEditorConstraint.GetObjectNewStatus: Boolean;
begin
	Result := True;
end;

function TfrmEditorConstraint.GetCheck: String;
var
	Temp : String;

begin
	Temp := Trim(edCheck.Text);
	if Temp <> '' then
	begin
		if Pos('check', AnsiLowerCase(Temp)) = 0 then
			Temp := 'check ' + Temp;
		Result := ' ' + Temp;
	end
	else
		Result := ' ';
end;

procedure TfrmEditorConstraint.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_Add_Constraint_Dialog;
  ValidateFormState(self);
end;

procedure TfrmEditorConstraint.FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgConstraint)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgConstraint);
end;

procedure TfrmEditorConstraint.FormShow(Sender: TObject);
begin
	if FModifyConstraint then
		case pgConstraint.ActivePage.PageIndex of
			PG_PKEY:
				edPKName.SetFocus;

			PG_FKEY:
				edFKName.SetFocus;

			PG_CHECK:
				edCheckName.SetFocus;

			PG_UNIQUE:
				edUniqueName.SetFocus;
		end
	else
	begin
		pgConstraint.ActivePage := tsPK;
		edPKName.SetFocus;
	end;
end;

procedure TfrmEditorConstraint.btnOKClick(Sender: TObject);
var
	I: Integer;
	FErrors, ModifiedColumns: Boolean;
	TempString, TempString2, TempString3: String;
	AlterSQL: TStringList;
begin
	// Do some checks before proceeding
	case pgConstraint.ActivePage.PageIndex of

		PG_PKEY:
			begin
				if Trim(edPKName.Text) = '' then
				begin
					MessageDlg('The primary key constraint must have a name.', mtError, [mbOK], 0);
					edPKName.SetFocus;
					Exit;
				end;
				if lvPKColumns.Items.Count = 0 then
				begin
					MessageDlg('Please select the field(s) to be used in the primary key.', mtError, [mbOK], 0);
					cmbPKColumn.SetFocus;
					Exit;
				end;
			end;

		PG_FKEY: 
			begin
				if Trim(edFKName.Text) = '' then
				begin
					MessageDlg('The foreign key contraint must have a name.', mtError, [mbOK], 0);
					edFKName.SetFocus;
					Exit;
				end;
				if lvFKColumns.Items.Count = 0 then
				begin
					MessageDlg('Please select the field to be used in the foreign key.', mtError, [mbOK], 0);
					cmbFKColumns.SetFocus;
					Exit;
				end;
				if lvFKRefColumns.Items.Count = 0 then
				begin
					MessageDlg('Please select the field to be referenced in the foreign key.', mtError, [mbOK], 0);
					cmbFKRefColumns.SetFocus;
					Exit;
				end;
			end;

		PG_CHECK: 
			begin
				if Trim(edCheckName.Text) = '' then
				begin
					MessageDlg('The check constraint must have a name.', mtError, [mbOK], 0);
					edCheckName.SetFocus;
					Exit;
				end;
				if Trim(edCheck.Text) = '' then
				begin
					MessageDlg('The check constraint must contain an expression.', mtError, [mbOK], 0);
					edCheck.SetFocus;
					Exit;
				end;
			end;

		PG_UNIQUE: 
			begin
				if Trim(edUniqueName.Text) = '' then
				begin
					MessageDlg('The unique constraint must have a name.', mtError, [mbOK], 0);
					edUniqueName.SetFocus;
					Exit;
				end;
				if lvUniqueColumns.Items.Count = 0 then
				begin
					MessageDlg('Please select the field(s) to be used in the unique constraint.', mtError, [mbOK], 0);
					cmbUniqueColumn.SetFocus;
					Exit;
				end;
			end;
	end;

	AlterSQL := TStringList.Create;

	// Build the sql for constraint modify
	if FModifyConstraint then
		case pgConstraint.ActivePage.PageIndex of
			PG_PKEY:
				begin
					ModifiedColumns := False;
					for I := 0 to lvPKColumns.Items.Count - 1 do
						if lvPKColumns.Items[I].Caption <> FOldColumns[I] then
							ModifiedColumns := True;
					if (edPKName.Text <> FConstraintName) or (ModifiedColumns) then
					begin
						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' drop constraint '
							+ MakeQuotedIdent(FConstraintName, FIsInterbase6, FSQLDialect));

						TempString := '';
						for I := 0 to lvPKColumns.Items.Count - 1 do
							TempString := TempString + MakeQuotedIdent(lvPKColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
						TempString := Copy(TempString, 1, Length(TempString) - 2);

						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' add constraint '
							+ MakeQuotedIdent(edPKName.Text, FIsInterbase6, FSQLDialect) + ' primary key (' + TempString + ')');
					end;
				end;

			PG_FKEY: 
				begin
					ModifiedColumns := False;
					for I := 0 to lvFKColumns.Items.Count - 1 do
						if lvFKColumns.Items[I].Caption <> FOldColumns[I] then
							ModifiedColumns := True;
					if ModifiedColumns = False then
						for I := 0 to lvFKRefColumns.Items.Count - 1 do
							if lvFKRefColumns.Items[I].Caption <> FOldRefColumns[I] then
								ModifiedColumns := True;
					if (edFKName.Text <> FConstraintName) or (ModifiedColumns) or (FOldFKTable <> cmbTables.Text)
						or (FOldDeleteRule <> cmbOnDelete.Text) or (FOldUpdateRule <> cmbOnUpdate.Text)
            or (chkOnDelete.checked <> (ansilowercase(FOldDeleteRule) = 'no action'))
            or (chkOnUpdate.checked <> (ansilowercase(FOldUpdateRule) = 'no action')) then
					begin
						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' drop constraint '
							+ MakeQuotedIdent(FConstraintName, FIsInterbase6, FSQLDialect));

						TempString := '';
						for I := 0 to lvFKColumns.Items.Count - 1 do
							TempString := TempString + MakeQuotedIdent(lvFKColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
						TempString := Copy(TempString, 1, Length(TempString) - 2);

						TempString2 := '';
						for I := 0 to lvFKRefColumns.Items.Count - 1 do
							TempString2 := TempString2 + MakeQuotedIdent(lvFKRefColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
						TempString2 := Copy(TempString2, 1, Length(TempString2) - 2);

						TempString3 := '';
						if cmbOnDelete.Enabled then
						begin
							if chkOnDelete.Checked then
								TempString3 := TempString3 + ' on delete ' + cmbOnDelete.Text;
							if chkOnUpdate.Checked then
								TempString3 := TempString3 + ' on update ' + cmbOnUpdate.Text;
						end;

						AlterSQL.Add('alter table '  + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) +  ' add constraint '
							+ MakeQuotedIdent(edFKName.Text, FIsInterbase6, FSQLDialect) + ' foreign key (' + TempString + ') references '
							+ MakeQuotedIdent(cmbTables.Text, FIsInterbase6, FSQLDialect) + '(' + TempString2 + ')' + TempString3);
					end;
				end;

			PG_CHECK:
				begin
					if (edCheckName.Text <> FConstraintName) or (FOldCheckText <> edCheck.Text) then
					begin
						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' drop constraint '
							+ MakeQuotedIdent(FConstraintName, FIsInterbase6, FSQLDialect));

						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect)
							+ ' add constraint ' + MakeQuotedIdent(edCheckName.Text, FIsInterbase6, FSQLDialect) + GetCheck);
					end;
				end;

			PG_UNIQUE: 
				begin
					ModifiedColumns := False;
					for I := 0 to lvUniqueColumns.Items.Count - 1 do
						if lvUniqueColumns.Items[I].Caption <> FOldColumns[I] then
							ModifiedColumns := True;
					if (edUniqueName.Text <> FConstraintName) or (ModifiedColumns) then
					begin
						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' drop constraint '
							+ MakeQuotedIdent(FConstraintName, FIsInterbase6, FSQLDialect));

						TempString := '';
						for I := 0 to lvUniqueColumns.Items.Count - 1 do
							TempString := TempString + MakeQuotedIdent(lvUniqueColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
						TempString := Copy(TempString, 1, Length(TempString) - 2);

						AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' add constraint '
							+ MakeQuotedIdent(edUniqueName.Text, FIsInterbase6, FSQLDialect) + ' unique (' + TempString + ')');
					end;
				end;
		end
	// Build the sql for a new constraint
	else
	begin
		case pgConstraint.ActivePage.PageIndex of
			PG_PKEY:
				begin
					TempString := '';
					for I := 0 to lvPKColumns.Items.Count - 1 do
						TempString := TempString + MakeQuotedIdent(lvPKColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
					TempString := Copy(TempString, 1, Length(TempString) - 2);

					AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' add constraint '
						+ MakeQuotedIdent(edPKName.Text, FIsInterbase6, FSQLDialect) + ' primary key (' + TempString + ')');
				end;

			PG_FKEY: 
				begin
					TempString := '';
					for I := 0 to lvFKColumns.Items.Count - 1 do
						TempString := TempString + MakeQuotedIdent(lvFKColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
					TempString := Copy(TempString, 1, Length(TempString) - 2);

					TempString2 := '';
					for I := 0 to lvFKRefColumns.Items.Count - 1 do
						TempString2 := TempString2 + MakeQuotedIdent(lvFKRefColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
					TempString2 := Copy(TempString2, 1, Length(TempString2) - 2);

					TempString3 := '';
					if cmbOnDelete.Enabled then
					begin
						if chkOnDelete.Checked then
							TempString3 := TempString3 + ' on delete ' + cmbOnDelete.Text;
						if chkOnUpdate.Checked then
							TempString3 := TempString3 + ' on update ' + cmbOnUpdate.Text;
					end;

					AlterSQL.Add('alter table '  + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) +  ' add constraint '
						+ MakeQuotedIdent(edFKName.Text, FIsInterbase6, FSQLDialect) + ' foreign key (' + TempString + ') references '
						+ MakeQuotedIdent(cmbTables.Text, FIsInterbase6, FSQLDialect) + '(' + TempString2 + ')' + TempString3);
				end;

			PG_CHECK:
				AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect)
					+ ' add constraint ' + MakeQuotedIdent(edCheckName.Text, FIsInterbase6, FSQLDialect) + GetCheck);

			PG_UNIQUE: 
				begin
					TempString := '';
					for I := 0 to lvUniqueColumns.Items.Count - 1 do
						TempString := TempString + MakeQuotedIdent(lvUniqueColumns.Items.Item[I].Caption, FIsInterbase6, FSQLDialect) + ', ';
					TempString := Copy(TempString, 1, Length(TempString) - 2);

					AlterSQL.Add('alter table ' + MakeQuotedIdent(FTableName, FIsInterbase6, FSQLDialect) + ' add constraint '
						+ MakeQuotedIdent(edUniqueName.Text, FIsInterbase6, FSQLDialect) + ' unique (' + TempString + ')');
				end;
		end
	end;

	with TfrmCompileDBObject.CreateMultiStatementCompile(Self, Self,
		qryConstraint.IB_Connection, qryConstraint.IB_Transaction, AlterSQL) do
	begin
		FErrors := CompileErrors;
		Free;
	end;
	if not FErrors then
		ModalResult := mrOK;
end;

procedure TfrmEditorConstraint.btnHelpClick(Sender: TObject);
begin
	Application.HelpCommand(HELP_CONTEXT, IDH_Add_Constraint_Dialog);
end;

procedure TfrmEditorConstraint.edPKNameChange(Sender: TObject);
begin
	CheckNameLength((Sender as TEdit).Text);
end;

procedure TfrmEditorConstraint.lvPKColumnsKeyDown(Sender: TObject;	var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE:
      actPKDelete.Execute;
	end;
end;

procedure TfrmEditorConstraint.lvFKColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE:
      actFKDelete.Execute;
	end;
end;

procedure TfrmEditorConstraint.lvFKRefColumnsKeyDown(Sender: TObject;	var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE:
      actFKDelete1.Execute;
	end;
end;

procedure TfrmEditorConstraint.cmbTablesChange(Sender: TObject);
var
	Q: TIBOQuery;

begin
	Q := TIBOQuery.Create(Self);
	try
		Q.IB_Connection := qryConstraint.IB_Connection;
		Q.IB_Transaction := qryConstraint.IB_Transaction;
		try
			Q.SQL.Add('select RDB$FIELD_NAME from RDB$RELATION_FIELDS where RDB$RELATION_NAME = ' +
								AnsiQuotedStr(cmbTables.Text, '''') + ' order by RDB$FIELD_POSITION asc');
			Q.Open;
			cmbFKRefColumns.Items.Clear;
			while not Q.EOF do
			begin
				cmbFKRefColumns.Items.Add(Q.FieldByName('RDB$FIELD_NAME').AsString);
				Q.Next;
			end;
			Q.Close;
			Q.IB_Transaction.Commit;
			cmbFKRefColumns.ItemIndex := 0;
		except
			on E : Exception do
			begin
				Q.IB_Transaction.Rollback;
				raise;
			end;
		end;
	finally
		Q.Free;
	end;
end;

procedure TfrmEditorConstraint.lvUniqueColumnsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE:
      actUCDelete.Execute;
	end;
end;

procedure TfrmEditorConstraint.actFKAddExecute(Sender: TObject);
begin
		with lvFKColumns.Items.Add do
		begin
			Caption := cmbFKColumns.Text;
			cmbFKColumns.Items.Delete(cmbFKColumns.ItemIndex);
		end;
end;

procedure TfrmEditorConstraint.actFKAddUpdate(Sender: TObject);
begin
  actFKAdd.enabled := (pgConstraint.ActivePage = tsFK) and (cmbFKColumns.ItemIndex <> -1);
end;

procedure TfrmEditorConstraint.actFKDeleteExecute(Sender: TObject);
begin
   if MessageDlg('Are you sure you wish to remove column "' + lvFKColumns.Selected.Caption + '" from the foreign key?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
   begin
     cmbFKColumns.Items.Add(lvFKColumns.Selected.Caption);
     lvFKColumns.Selected.Delete;
   end;
end;

procedure TfrmEditorConstraint.actFKDeleteUpdate(Sender: TObject);
begin
   actFKDelete.enabled := (pgConstraint.ActivePage = tsFK) and assigned(lvFKColumns.Selected);
end;

procedure TfrmEditorConstraint.actFKAdd1Execute(Sender: TObject);
begin
		with lvFKRefColumns.Items.Add do
		begin
			Caption := cmbFKRefColumns.Text;
			cmbFKRefColumns.Items.Delete(cmbFKRefColumns.ItemIndex);
		end;
end;

procedure TfrmEditorConstraint.actFKAdd1Update(Sender: TObject);
var
   wFound : boolean;
   wIdx : integer;
begin
	wFound := False;

	for wIdx := 0 to lvFKRefColumns.Items.Count - 1 do
  begin
    wFound := wFound or (cmbFKRefColumns.Text = lvFKRefColumns.Items.Item[wIdx].Caption);
    if wFound then
       break;
  end;

  actFKAdd1.enabled := (pgConstraint.ActivePage = tsFK) and (not wFound) and (cmbFKRefColumns.itemindex <> -1);
end;

procedure TfrmEditorConstraint.actFKDelete1Execute(Sender: TObject);
begin
		if MessageDlg('Are you sure you wish to remove reference column "' + lvFKRefColumns.Selected.Caption + '" from the foreign key?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			cmbFKRefColumns.Items.Add(lvFKRefColumns.Selected.Caption);
			lvFKRefColumns.Selected.Delete;
		end;
end;

procedure TfrmEditorConstraint.actFKDelete1Update(Sender: TObject);
begin
    actFKDelete1.enabled := (pgConstraint.ActivePage = tsFK) and assigned(lvFKRefColumns.Selected);
end;

procedure TfrmEditorConstraint.actPKAddExecute(Sender: TObject);
begin
		with lvPKColumns.Items.Add do
		begin
			Caption := cmbPKColumn.Text;
			cmbPKColumn.Items.Delete(cmbPKColumn.ItemIndex);
		end;
end;

procedure TfrmEditorConstraint.actPKAddUpdate(Sender: TObject);
begin
   actPKAdd.enabled := (pgConstraint.ActivePage = tsPK) and (cmbPKColumn.ItemIndex <> -1);
end;

procedure TfrmEditorConstraint.actPKDeleteExecute(Sender: TObject);
begin
		if MessageDlg('Are you sure you wish to remove column "' + lvPKColumns.Selected.Caption + '" from the primary key?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			cmbPKColumn.Items.Add(lvPKColumns.Selected.Caption);
			lvPKColumns.Selected.Delete;
		end;
end;

procedure TfrmEditorConstraint.actPKDeleteUpdate(Sender: TObject);
begin
   actPKDelete.enabled := (pgConstraint.ActivePage = tsPK) and assigned(lvPKColumns.selected);
end;

procedure TfrmEditorConstraint.actUCAddExecute(Sender: TObject);
begin
		with lvUniqueColumns.Items.Add do
		begin
			Caption := cmbUniqueColumn.Text;
			cmbUniqueColumn.Items.Delete(cmbUniqueColumn.ItemIndex);
		end;
end;

procedure TfrmEditorConstraint.actUCAddUpdate(Sender: TObject);
begin
   actUCAdd.enabled := (pgConstraint.ActivePage = tsUnique) and (cmbUniqueColumn.itemindex <> -1);
end;

procedure TfrmEditorConstraint.actUCDeleteExecute(Sender: TObject);
begin
		if MessageDlg('Are you sure you wish to remove column "' + lvUniqueColumns.Selected.Caption + '" from the primary key?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
		begin
			cmbUniqueColumn.Items.Add(lvUniqueColumns.Selected.Caption);
			lvUniqueColumns.Selected.Delete;
		end;
end;

procedure TfrmEditorConstraint.actUCDeleteUpdate(Sender: TObject);
begin
   actUCDelete.enabled := (pgConstraint.ActivePage = tsUnique) and assigned(lvUniqueColumns.selected);
end;

end.


