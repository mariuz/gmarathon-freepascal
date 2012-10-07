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
// $Id: EditorColumn.pas,v 1.11 2007/02/10 22:01:14 rjmills Exp $

{ Old History
	13.03.2002	tmuetze
		+ Added methods for editing and for creating a domain, also the domain info
			box is now filled
	10.03.2002	tmuetze
		* TfrmColumns.LoadColumn, TfrmColumns.DoCompile, getting the column-properies
			showing and saving to work
	28.01.2002	tmuetze
		* Modifications in TfrmColumns.LoadColumn, so that we soon get the
			column-properties to work
}

{
$Log: EditorColumn.pas,v $
Revision 1.11  2007/02/10 22:01:14  rjmills
Fixes for Component Library updates

Revision 1.10  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.9  2006/10/19 03:54:58  rjmills
Numerous bug fixes and current work in progress

Revision 1.8  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.7  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.6  2002/04/29 10:45:38  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.5  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit EditorColumn;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, ExtCtrls, DB, Printers, Menus, ClipBrd, Buttons,
	IB_Header,
	IBODataset,
	rmPanel,
	rmTabs3x,
	rmCollectionListBox,
	SynEdit,
	SyntaxMemoWithStuff2,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes,
	FrameDescription, rmNotebook2, rmPageControl;

type
	TColumnEditState = (stNewTable, stNewColumn, stColumnProperties);

	TfrmColumns = class(TForm, IMarathonBaseForm)
    pgObjectEditor: TPageControl;
    tsMain: TTabSheet;
    tsConstraint: TTabSheet;
    qryUtil: TIBOQuery;
    tsDescription: TTabSheet;
		framDoco: TframeDesc;
		stsEditor: TStatusBar;
		edConstraint: TSyntaxMemoWithStuff2;
    pgColumn: TPageControl;
    tsRaw: TTabSheet;
    tsDomain: TTabSheet;
    tsComputed: TTabSheet;
		Label8: TLabel;
		cmbDomain: TComboBox;
		edComputed: TSyntaxMemoWithStuff2;
    nbRawDataType: TrmNoteBookControl;
    nbType: TrmNoteBookControl;
    Label3: TLabel;
    cmbDataType: TComboBox;
    nbpBlank : TrmNotebookPage;
    nbpBlob : TrmNotebookPage;
    nbpNumeric : TrmNotebookPage;
    nbpChar : TrmNotebookPage;
    nbpType : TrmNotebookPage;
    nbpDefault : TrmNotebookPage;
    Label4: TLabel;
    Label9: TLabel;
    Label2: TLabel;
		edLength: TEdit;
    udLen: TUpDown;
		cmbCharCharSet: TComboBox;
    cmbCollate: TComboBox;
		Label14: TLabel;
		Label15: TLabel;
		edPrecision: TEdit;
		edScale: TEdit;
    upPrec: TUpDown;
    upScale: TUpDown;
    Label18: TLabel;
		Label6: TLabel;
    Label11: TLabel;
    Label5: TLabel;
		edSubType: TEdit;
		cmbBlobCharSet: TComboBox;
		edSegSize: TEdit;
		udSegLength: TUpDown;
		cmbBlobCollate: TComboBox;
		pnlArray: TPanel;
		Label10: TLabel;
		lvArray: TListView;
		btnAddDimension: TButton;
		btnDeleteDimension: TButton;
		btnEditDimension: TButton;
		chkColNotNull: TCheckBox;
		edDefault: TSyntaxMemoWithStuff2;
    tsColumnDomain: TTabSheet;
    Label12: TLabel;
    cmbColumnDomain: TComboBox;
    btnColumnEditDomain: TButton;
    btnColumnNewDomain: TButton;
    cmbColumnCollate: TComboBox;
    lblColumnCollate: TLabel;
    chkColumnNotNull: TCheckBox;
    GroupBox1: TGroupBox;
    tsColumnDefault: TTabSheet;
    tsColumnDescription: TTabSheet;
		edColumnDefault: TSyntaxMemoWithStuff2;
		btnEditDomain: TButton;
		btnNewDomain: TButton;
		framColumnDoco: TframeDesc;
    edDomainInfo: TSyntaxMemoWithStuff2;
    tabRawDataType: TrmTabSet;
    rmPanel1: TrmPanel;
    edTableName: TEdit;
    Label1: TLabel;
    edColumnName: TEdit;
    Label7: TLabel;
    Bevel1: TBevel;
    rmPanel2: TrmPanel;
    btnOK: TButton;
    btnCancel: TButton;
		procedure cmbDataTypeChange(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure edColDefaultChange(Sender: TObject);
		procedure edColCheckChange(Sender: TObject);
		procedure btnAddDimensionClick(Sender: TObject);
		procedure btnDeleteDimensionClick(Sender: TObject);
		procedure btnEditDimensionClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure edColumnNameChange(Sender: TObject);
		procedure FormActivate(Sender: TObject);
		procedure btnOKClick(Sender: TObject);
		procedure tabRawDataTypeChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
		procedure edTableNameChange(Sender: TObject);
		procedure cmbColumnDomainChange(Sender: TObject);
		procedure chkColumnNotNullClick(Sender: TObject);
    procedure btnColumnEditDomainClick(Sender: TObject);
    procedure btnColumnNewDomainClick(Sender: TObject);
    procedure cmbDomainChange(Sender: TObject);
	private
		{ Private declarations }
		FChangeDefault : Boolean;
		FChangeCheck : Boolean;
		FChangeName : Boolean;
		FChangeNotNull: Boolean;
		FChangeDataType : Boolean;
		FTableEditor: IMarathonTableEditor;
		FObjectName : String;
		FDomainName: String;
		FSQLDialect : Integer;
		FDatabaseName : String;
		FNewTableObject : Boolean;
		FNewObject : Boolean;
		FModifyObject: Boolean;

		FIsInterbase6 : Boolean;
		FErrors : Boolean;
//		FObjectModified : Boolean;
		FState: TColumnEditState;
		FNewColumnName: String;

		function GetDataType : String;
		function GetDefault : String;
		function GetNotNull : String;
		function GetCheck : String;

//		function GetSaveFieldType : Integer;
//		function GetSaveFieldLength : Integer;
//		function GetSaveFieldScale : Integer;

		procedure DoCompile;
		function GetCollate: String;
		procedure SetDatabaseName(const Value: String);
		procedure SetState(const Value: TColumnEditState);
	public
		{ Public declarations }
		procedure NewColumn;
		procedure LoadColumn(ColumnName: String);

		property TableEditor : IMarathonTableEditor read FTableEditor write FTableEditor;
		property DatabaseName : String read FDatabaseName write SetDatabaseName;
		property State : TColumnEditState read FSTate write SetState;
		property NewColumnName : String read FNewColumnName;

		function GetObjectName : String;
		function GetActiveConnectionName : String;
		function GetActiveObjectType : TGSSCacheType;
		function GetActiveStatusBar : TStatusBar;
		function GetObjectNewStatus : Boolean;
		procedure OpenMessages;
		procedure AddCompileError(ErrorText : String);
		procedure ClearErrors;
		procedure ForceRefresh;
		procedure SetObjectName(Value : String);
		procedure SetObjectModified(Value : Boolean);
	end;

implementation

uses
	Globals,
	MarathonIDE,
	HelpMap,
	CompileDBObject,
	DropObject,
	PrintPreviewForm,
	ArrayDialog,
	EditorDomain;

const
	TY_NONE              = -1;
	TY_SMALLINT          = 0;
	TY_INTEGER           = 1;
	TY_FLOAT             = 2;
	TY_DOUBLE_PRECISION  = 3;
	TY_DECIMAL           = 4;
	TY_NUMERIC           = 5;
	TY_DATE              = 6;
	TY_TIME              = 7;
	TY_TIMESTAMP         = 8;
	TY_CHAR              = 9;
	TY_VARCHAR           = 10;
	TY_BLOB              = 11;

	PG_DOMAIN            = 0;
	PG_DEFAULT           = 1;
	PG_CONSTRAINT        = 2;
	PG_DESC              = 3;
	PG_DDL               = 4;

{$R *.DFM}

procedure TfrmColumns.cmbDataTypeChange(Sender: TObject);
begin
	FChangeDataType := True;
	if cmbDataType.ItemIndex = -1 then
	begin
		nbType.ActivePage := nbpBlank;
    pnlArray.Visible := True;
  end
  else
  begin
    case cmbDataType.ItemIndex of
      TY_DECIMAL :
        begin
          nbType.ActivePage := nbpNumeric;
					pnlArray.Visible := True;
        end;
      TY_NUMERIC :
        begin
          nbType.ActivePage := nbpNumeric;
          pnlArray.Visible := True;
        end;
      TY_CHAR :
        begin
          nbType.ActivePage := nbpChar;
					pnlArray.Visible := True;
        end;
      TY_VARCHAR :
				begin
          nbType.ActivePage := nbpChar;
          pnlArray.Visible := True;
        end;
      TY_BLOB :
        begin
          nbType.ActivePage := nbpBlob;
          pnlArray.Visible := False;
        end;
		else
      nbType.ActivePage := nbpBlank;
			pnlArray.Visible := True;
    end;
  end;
end;

function TfrmColumns.GetDataType : String;
var
	Idx : Integer;

begin
	Result := cmbDataType.Text;

	case cmbDataType.ItemIndex of
		TY_NUMERIC, TY_DECIMAL :
			begin
				Result := Result + '(' + edPrecision.Text + ', ' + edScale.Text + ')';
				if lvArray.Items.Count > 0 then
        begin
          Result := Result + ' [';
          for Idx := 0 to lvArray.Items.Count - 1 do
          begin
            Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
          end;
          Result := Trim(Result);
          if Result[Length(Result)] = ',' then
						Result := Copy(Result, 1, Length(Result) - 1);
          Result := Result + ']';
        end;
			end;

    TY_CHAR, TY_VARCHAR :
      begin
        Result := Result + '(' + edLength.Text + ')';
        if lvArray.Items.Count > 0 then
        begin
          Result := Result + ' [';
          for Idx := 0 to lvArray.Items.Count - 1 do
					begin
            Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
					end;
          Result := Trim(Result);
          if Result[Length(Result)] = ',' then
            Result := Copy(Result, 1, Length(Result) - 1);
					Result := Result + ']';
        end;
        if not ((cmbCharCharSet.Text = '') or (cmbCharCharSet.Text = 'NONE')) then
          Result := Result + ' character set ' + cmbCharCharSet.Text;
      end;

    TY_BLOB :
      begin
        Result := Result + ' sub_type ' + edSubType.Text;
        Result := Result + ' segment size ' + IntToStr(udSegLength.Position);
				if not ((cmbBlobCharSet.Text = '') or (cmbBlobCharSet.Text = 'NONE')) then
          Result := Result + ' character set ' + cmbBlobCharSet.Text;
			end;
	else
		begin
			if lvArray.Items.Count > 0 then
			begin
				Result := Result + ' [';
				for Idx := 0 to lvArray.Items.Count - 1 do
				begin
					Result := Result + lvArray.Items.Item[Idx].Caption + ':' + lvArray.Items.Item[Idx].SubItems[0] + ', ';
				end;
				Result := Trim(Result);
				if Result[Length(Result)] = ',' then
					Result := Copy(Result, 1, Length(Result) - 1);
				Result := Result + ']';
			end;
		end;
	end;
end;

function TfrmColumns.GetDefault : String;
var
	Temp : String;
begin
	Temp := Trim(edDefault.Text);
	if Temp <> '' then
  begin
    if Pos('default', AnsiLowerCase(Temp)) = 0 then
			Temp := 'default ' + Temp;
    Result := ' ' + Temp
  end
  else
    Result := ' ';
end;

function TfrmColumns.GetNotNull : String;
begin
	if chkColNotNull.Checked then
    Result := ' not null'
  else
		Result := ' ';
end;

function TfrmColumns.GetCheck : String;
var
	Temp : String;
begin
	Temp := Trim(edConstraint.Text);
	if Temp <> '' then
	begin
		if Pos('check', AnsiLowerCase(Temp)) = 0 then
		 Temp := 'check ' + Temp;
		Result := ' ' + Temp;
	end
	else
		Result := ' ';
end;

function TfrmColumns.GetCollate : String;
begin
	if (cmbCollate.Text <> '') then
		Result := ' collate ' + cmbCollate.Text
	else
		Result := ' ';
end;

{function TfrmColumns.GetSaveFieldType : Integer;
begin
	case cmbDataType.ItemIndex of
		TY_SMALLINT:
			Result := blr_short;

		TY_INTEGER:
			Result := blr_long;

		TY_FLOAT:
			Result := blr_float;

		TY_DOUBLE_PRECISION:
			Result := blr_double;

		TY_DECIMAL, TY_NUMERIC:
			begin
				case upPrec.Position of
					1..9 : Result := blr_long;
				else
					Result := blr_double;
				end;
			end;

		TY_DATE:
			Result := blr_timestamp;

		TY_TIME:
			raise Exception.Create('TIME datatype not supported in this version of Firebird, InterBase.');

		TY_TIMESTAMP:
			raise Exception.Create('TIMESTAMP datatype not supported in this version of Firebird/InterBase.');

		TY_CHAR:
			Result := blr_text;

		TY_VARCHAR:
			Result := blr_varying;

    TY_BLOB:
			Result := blr_blob;
  else
    Result := 0;
  end;
end;}

{function TfrmColumns.GetSaveFieldLength : Integer;
begin
  case cmbDataType.ItemIndex of
    TY_SMALLINT :
      Result := 2;

    TY_INTEGER :
      Result := 4;

    TY_FLOAT :
      Result := 4;

    TY_DOUBLE_PRECISION :
      Result := 8;

		TY_DECIMAL,
    TY_NUMERIC :
      begin
				case upPrec.Position of
          1..9 : Result := 4;

        else
					Result := 8;
        end;
      end;

    TY_DATE,
		TY_TIME,
    TY_TIMESTAMP :
			Result := 8;

    TY_CHAR :
      Result := udLen.Position;

    TY_VARCHAR :
      Result := udLen.Position;

    TY_BLOB :
      Result := 8;
	else
    Result := 0;
  end;
end;}

{function TfrmColumns.GetSaveFieldScale : Integer;
begin
  case cmbDataType.ItemIndex of
    TY_SMALLINT :
      Result := 0;

    TY_INTEGER :
      Result := 0;

		TY_FLOAT :
      Result := 0;

    TY_DOUBLE_PRECISION :
			Result := 0;

    TY_DECIMAL,
		TY_NUMERIC :
			begin
				case upPrec.Position of
					1..9 : Result := -(upScale.Position);

				else
					Result := -(upScale.Position);
				end;
			end;

		TY_DATE,
		TY_TIME,
		TY_TIMESTAMP :
			Result := 0;

    TY_CHAR :
      Result := udLen.Position;

    TY_VARCHAR :
      Result := udLen.Position;

    TY_BLOB :
			Result := 0;
	else
		Result := 0;
	end;
end;}

procedure TfrmColumns.FormCreate(Sender: TObject);
var
	TmpIntf : IMarathonBaseForm;

begin
	TmpIntf := Self;
	framDoco.Init(TmpIntf);
	framColumnDoco.Init(TmpIntf);
	SetupSyntaxEditor(edDefault);
	SetupSyntaxEditor(edConstraint);
	SetupSyntaxEditor(edComputed);
	SetupSyntaxEditor(edColumnDefault);
	HelpContext := IDH_Domain_Editor;
  pgObjectEditor.ActivePage := tsMain;
end;

procedure TfrmColumns.edColDefaultChange(Sender: TObject);
begin
	FChangeDefault := True;
end;

procedure TfrmColumns.edColCheckChange(Sender: TObject);
begin
  FChangeCheck := True;
end;

procedure TfrmColumns.btnAddDimensionClick(Sender: TObject);
var
	frmArrayDialog: TfrmArrayDialog;

begin
  frmArrayDialog := TfrmArrayDialog.Create(Self);
	try
    if frmArrayDialog.ShowModal = mrOK then
    begin
      with lvArray.Items.Add do
      begin
        Caption := frmArrayDialog.edLBound.Text;
        SubItems.Add(frmArrayDialog.edUBound.Text);
      end;
      FChangeDataType := True;
    end;
  finally
    frmArrayDialog.Free;
  end;
end;

procedure TfrmColumns.btnDeleteDimensionClick(Sender: TObject);
begin
  if lvArray.Selected <> nil then
	begin
		if MessageDlg('Are you sure you wish to delete this dimension?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      lvArray.Selected.Delete;
      FChangeDataType := True;
    end;
	end;
end;

procedure TfrmColumns.btnEditDimensionClick(Sender: TObject);
var
  frmArrayDialog: TfrmArrayDialog;

begin
	if lvArray.Selected <> nil then
	begin
    frmArrayDialog := TfrmArrayDialog.Create(Self);
		try
      frmArrayDialog.udLBound.Position := StrToInt(lvArray.Selected.Caption);
      frmArrayDialog.udUBound.Position := StrToInt(lvArray.Selected.SubItems[0]);
      if frmArrayDialog.ShowModal = mrOK then
			begin
				with lvArray.Items.Add do
				begin
          lvArray.Selected.Caption := frmArrayDialog.edLBound.Text;
          lvArray.Selected.SubItems[0] := frmArrayDialog.edUBound.Text;
        end;
        FChangeDataType := True;
      end;
    finally
			frmArrayDialog.Free;
    end;
  end;
end;

procedure TfrmColumns.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

procedure TfrmColumns.LoadColumn(ColumnName: String);
var
	Idx : Integer;
	Dimensions : Integer;

begin
	try
		Screen.Cursor := crHourGlass;
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbBlobCharSet.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbCharCharSet.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbBlobCollate.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbCollate.Items);
		cmbDomain.Items.Assign(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].DomainList);
		cmbColumnDomain.Items.Assign(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].DomainList);

		FObjectName := ColumnName;
		FNewObject := False;

		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select RDB$FIELD_SOURCE, RDB$DESCRIPTION, RDB$DEFAULT_SOURCE, RDB$NULL_FLAG ' +
			'from RDB$RELATION_FIELDS where RDB$FIELD_NAME = ''' + FObjectName +
			''' and RDB$RELATION_NAME = ' + AnsiQuotedStr(edTableName.Text, '''') + ';');
		qryUtil.Open;

		edColumnName.Text := FObjectName;
		edColumnDefault.Text := qryUtil.FieldByName('RDB$DEFAULT_SOURCE').AsString;
		framColumnDoco.edDoco.Text := qryUtil.FieldByName('RDB$DESCRIPTION').AsString;
		if (qryUtil.FieldByName('RDB$NULL_FLAG').IsNull) then
			chkColumnNotNull.Checked := False
		else
			chkColumnNotNull.Checked := True;

		FDomainName := qryUtil.FieldByName('RDB$FIELD_SOURCE').AsString;
		cmbDomain.ItemIndex := cmbDomain.Items.IndexOf(FDomainName);
		cmbColumnDomain.ItemIndex := cmbDomain.ItemIndex;

		qryUtil.Close;

		qryUtil.SQL.Clear;
		qryUtil.SQL.Add('select * from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FDomainName, '''') + ';');
		qryUtil.Open;

		// domain field type...
		case qryUtil.FieldByName('rdb$field_type').AsInteger of
			blr_short:
			begin
				if FIsInterbase6 then
					begin
						if qryUtil.FieldByName('rdb$field_sub_type').IsNull then
						begin
							cmbDataType.ItemIndex := TY_SMALLINT;
						end
						else
						begin
							case qryUtil.FieldByName('rdb$field_sub_type').AsInteger of
								0:
								begin
									cmbDataType.ItemIndex := TY_SMALLINT;
								end;
								1:
								begin
									cmbDataType.ItemIndex := TY_NUMERIC;
									upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
									upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
								end;
								2:
								begin
									cmbDataType.ItemIndex := TY_DECIMAL;
									upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
									upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
								end;
							end;
						end;
					end
					else
					begin
						if qryUtil.FieldByName('rdb$field_scale').AsInteger <> 0 then
						begin
							cmbDataType.ItemIndex := TY_DECIMAL;
							upPrec.Position := 4;
							upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
						end
						else
							cmbDataType.ItemIndex := TY_SMALLINT;
					end;
				end;

			blr_long:
			begin
				if FIsInterbase6 then
				begin
					if qryUtil.FieldByName('rdb$field_sub_type').IsNull then
					begin
						cmbDataType.ItemIndex := TY_INTEGER;
					end
					else
					begin
						case qryUtil.FieldByName('rdb$field_sub_type').AsInteger of
							0:
							begin
								cmbDataType.ItemIndex := TY_INTEGER;
							end;
							1:
							begin
								cmbDataType.ItemIndex := TY_NUMERIC;
								upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
								upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
							end;
							2:
							begin
								cmbDataType.ItemIndex := TY_DECIMAL;
								upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
								upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
							end;
						end;
					end;
				end
				else
				begin
					if qryUtil.FieldByName('rdb$field_scale').AsInteger <> 0 then
					begin
						cmbDataType.ItemIndex := TY_DECIMAL;
						upPrec.Position := 9;
						upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
					end
					else
						cmbDataType.ItemIndex := TY_INTEGER;
				end;
			end;

			blr_int64:
			begin
				if FIsInterbase6 then
				begin
					if qryUtil.FieldByName('rdb$field_sub_type').IsNull then
					begin
						cmbDataType.ItemIndex := TY_DECIMAL;
						upPrec.Position := 18;
						upScale.Position := 0;
					end
					else
					begin
						case qryUtil.FieldByName('rdb$field_sub_type').AsInteger of
							0:
							begin
								cmbDataType.ItemIndex := TY_DECIMAL;
								upPrec.Position := 18;
								upScale.Position := 0;
							end;
							1:
							begin
								cmbDataType.ItemIndex := TY_NUMERIC;
								upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
								upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
							end;
							2:
							begin
								cmbDataType.ItemIndex := TY_DECIMAL;
								upPrec.Position := qryUtil.FieldByName('rdb$field_precision').AsInteger;
								upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
							end;
						end;
					end;
				end;
			end;

			blr_float:
			begin
				cmbDataType.ItemIndex := TY_FLOAT;
			end;

			blr_text:
			begin
				cmbDataType.ItemIndex := TY_CHAR;
				udLen.Position := qryUtil.FieldByName('rdb$field_length').AsInteger;
				cmbCharCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryUtil.FieldByName('rdb$character_set_id').AsInteger));
				cmbCollate.ItemIndex := cmbCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryUtil.FieldByName('rdb$collation_id').AsInteger, qryUtil.FieldByName('rdb$character_set_id').AsInteger));

				cmbColumnCollate.Visible := True;
				lblColumnCollate.Visible := True;
			end;

			blr_double:
			begin
				if qryUtil.FieldByName('rdb$field_scale').AsInteger <> 0 then
				begin
					cmbDataType.ItemIndex := TY_DECIMAL;
					upPrec.Position := 15;
					upScale.Position := Abs(qryUtil.FieldByName('rdb$field_scale').AsInteger);
				end
				else
					cmbDataType.ItemIndex := TY_DOUBLE_PRECISION;
			end;

			blr_timestamp:
			begin
				if FIsInterbase6 then
					cmbDataType.ItemIndex := TY_TIMESTAMP
				else
					cmbDataType.ItemIndex := TY_DATE;
			end;

			blr_sql_time:
			begin
				cmbDataType.ItemIndex := TY_TIME;
			end;

			blr_sql_date:
			begin
				cmbDataType.ItemIndex := TY_DATE;
			end;

			blr_varying:
			begin
				cmbDataType.ItemIndex := TY_VARCHAR;
				udLen.Position := qryUtil.FieldByName('rdb$field_length').AsInteger;
				cmbCharCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryUtil.FieldByName('rdb$character_set_id').AsInteger));
				cmbCollate.ItemIndex := cmbCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryUtil.FieldByName('rdb$collation_id').AsInteger, qryUtil.FieldByName('rdb$character_set_id').AsInteger));

				cmbColumnCollate.Visible := True;
				lblColumnCollate.Visible := True;
			end;

			blr_blob:
			begin
				cmbDataType.ItemIndex := TY_BLOB;
				edSubType.Text := qryUtil.FieldByName('rdb$field_sub_type').AsString;
				udSegLength.Position := qryUtil.FieldByName('rdb$segment_length').AsInteger;
				cmbBlobCharSet.ItemIndex := cmbCharCharSet.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(qryUtil.FieldByName('rdb$character_set_id').AsInteger));
				cmbBlobCollate.ItemIndex := cmbBlobCollate.Items.Indexof(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCollationName(qryUtil.FieldByName('rdb$collation_id').AsInteger, qryUtil.FieldByName('rdb$character_set_id').AsInteger));
			end;
		else
			cmbDataType.ItemIndex := TY_NONE;
		end;
		cmbDataTypeChange(cmbDataType);

		// domain defaults
		edDefault.Text := qryUtil.FieldByName('rdb$default_source').AsString;

		// domain checks
		edConstraint.Text := qryUtil.FieldByName('rdb$validation_source').AsString;

		if qryUtil.FieldByName('rdb$null_flag').IsNull then
			chkColNotNull.Checked := False
		else
			chkColNotNull.Checked := True;

		if qryUtil.FieldByName('rdb$dimensions').AsInteger > 0 then
		begin
			Dimensions := qryUtil.FieldByName('rdb$dimensions').AsInteger;
			for Idx := 0 to Dimensions do
			begin
				qryUtil.Close;
				qryUtil.SQL.Clear;
				qryUtil.SQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
											'rdb$dimension = ' + IntToStr(Idx)  + 'and rdb$field_name = ' + AnsiQuotedStr(cmbDomain.Text, '''') + ';');
				qryUtil.Open;
				if not (qryUtil.EOF and qryUtil.BOF) then
				begin
					with lvArray.Items.Add do
					begin
						Caption := qryUtil.FieldByName('rdb$lower_bound').AsString;
						SubItems.Add(qryUtil.FieldByName('rdb$upper_bound').AsString);
					end;
				end;
			end;
		end;

		if not FIsInterbase6 then
		begin
			btnAddDimension.Enabled := False;
			btnDeleteDimension.Enabled := False;
			btnEditDimension.Enabled := False;

			cmbCollate.Enabled := False;
			cmbCharCharSet.Enabled := False;
			cmbBlobCollate.Enabled := False;
			cmbBlobCharSet.Enabled := False;
		end;

		framDoco.LoadDoco;

		edDomainInfo.Lines.Clear;
		edDomainInfo.Lines.Add(cmbDataType.Text + ' ' + cmbBlobCharSet.Text + ' ' + cmbBlobCollate.Text);
		edDomainInfo.Lines.Add(edDefault.Text);
		
		if not FIsInterbase6 then
			edColumnName.ReadOnly := True;
		qryUtil.Close;
		qryUtil.IB_Transaction.Commit;
		FChangeDefault := False;
		FChangeCheck := False;
		FChangeName := False;
		FChangeNotNull := False;
		FChangeDataType := False;
	finally
		Screen.Cursor := crDefault;
	end;
end;

procedure TfrmColumns.NewColumn;
begin
	try
		Screen.Cursor := crHourGlass;
		//we want to create a new column...
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbBlobCharSet.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCharSetNames(cmbCharCharSet.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbBlobCollate.Items);
		MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetCollationNames(cmbCollate.Items);
		cmbDomain.Items.Assign(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].DomainList);

		FNewObject := True;
	finally
		Screen.Cursor := crDefault;
	end;
end;

procedure TfrmColumns.SetDatabaseName(const Value: String);
begin
	FDatabaseName := Value;
	qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
	qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;
	FIsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
	FSQLDialect := qryUtil.IB_Connection.SQLDialect;
	stsEditor.Panels[3].Text := Value;
end;

function TfrmColumns.GetActiveStatusBar: TStatusBar;
begin
	Result := stsEditor;
end;

procedure TfrmColumns.DoCompile;
var
	FCompile: TfrmCompileDBObject;
	FCompileText : String;
	Intf : IMarathonForm;
	FTableName : String;

begin
	Refresh;
	if FNewTableObject then
	begin
		//validation first...
		if edColumnName.Text = '' then
		begin
			MessageDlg('The new column must have a name.', mtError, [mbOK], 0);
			pgObjectEditor.ActivePage := tsMain;
			edColumnName.SetFocus;
			Exit;
		end;
		if edTableName.Text = '' then
		begin
			MessageDlg('The new table must have a name.', mtError, [mbOK], 0);
			pgObjectEditor.ActivePage := tsMain;
			edTableName.SetFocus;
			Exit;
		end;
		case pgColumn.ActivePage.PageIndex of
			0:
			begin
				if cmbDataType.Text = '' then
				begin
					MessageDlg('The new column must have datatype assigned.', mtError, [mbOK], 0);
					pgObjectEditor.ActivePage := tsMain;
					pgColumn.ActivePage := tsRaw;
					cmbDataType.SetFocus;
					Exit;
				end;

				FCompileText := 'create table ' + edTableName.Text + '(' + edColumnName.Text + ' ' + GetDataType + GetDefault + GetNotNull + GetCheck + GetCollate + ')';
			end;
			1:
			begin
				if cmbDomain.Text = '' then
				begin
					MessageDlg('The new column must have a domain name.', mtError, [mbOK], 0);
					pgObjectEditor.ActivePage := tsMain;
					pgColumn.ActivePage := tsDomain;
					cmbDomain.SetFocus;
					Exit;
				end;

				FCompileText := 'create table ' + edTableName.Text + '(' + edColumnName.Text + ' ' + MakeQuotedIdent(cmbDomain.Text, FIsInterbase6, FSQLDialect) + ')';
			end;
			2:
			begin
				if edComputed.Text = '' then
				begin
					MessageDlg('The new column must have a computed clause.', mtError, [mbOK], 0);
					pgObjectEditor.ActivePage := tsMain;
					pgColumn.ActivePage := tsComputed;
					edComputed.SetFocus;
					Exit;
				end;

				FCompileText := 'create table ' + edTableName.Text + '(' + edColumnName.Text + ' computed by ' + edComputed.Text + ')';
			end;
		end;
		FCompile := TfrmCompileDBObject.CreateCompile(Self, Self, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctSQL, FCompileText);
		FErrors := FCompile.CompileErrors;
		FCompile.Free;

		FTableName := edTableName.Text;
		if FTableEditor.QueryInterface(IMarathonForm, Intf) = S_OK then
		begin
			if FIsInterbase6 then
			begin
				if (FSQLDialect in [1, 2]) then
				begin
					FTableName := AnsiUpperCase(FTableName);
				end
				else
				begin
					FTableName := StripQuotesFromQuotedIdentifier(FTableName);
          fTableName := AnsiUpperCase(FTableName);  // rjm added
//					if not ShouldBeQuoted(FTableName) then  // rjm removed....unnecessary???
//						FTableName := AnsiUpperCase(FTableName);
				end;
			end
			else
			begin
				FTableName := AnsiUpperCase(FTableName);
			end;
			Intf.SetObjectName(FTableName);
			Intf.SetObjectModified(False);
		end;

		if FErrors then
			Exit
		else
		begin
			FNewColumnName := edColumnName.Text;
			ModalResult := mrOK;
		end;
	end
	else
	begin
		if FNewObject then
		begin
			//validation first...
			if edColumnName.Text = '' then
			begin
				MessageDlg('The new column must have a name.', mtError, [mbOK], 0);
				pgObjectEditor.ActivePage := tsMain;
				edColumnName.SetFocus;
				Exit;
			end;
			case pgColumn.ActivePage.PageIndex of
				0:
				begin
					if cmbDataType.Text = '' then
					begin
						MessageDlg('The new column must have datatype assigned.', mtError, [mbOK], 0);
						pgObjectEditor.ActivePage := tsMain;
						pgColumn.ActivePage := tsRaw;
						cmbDataType.SetFocus;
						Exit;
					end;

					FCompileText := 'alter table ' + MakeQuotedIdent(edTableName.Text, FIsInterbase6, FSQLDialect) + ' add ' + edColumnName.Text + ' ' + GetDataType + GetDefault + GetNotNull + GetCheck + GetCollate;
				end;
				1:
				begin
					if cmbDomain.Text = '' then
					begin
						MessageDlg('The new column must have a domain name.', mtError, [mbOK], 0);
						pgObjectEditor.ActivePage := tsMain;
						pgColumn.ActivePage := tsDomain;
						cmbDomain.SetFocus;
						Exit;
					end;

					FCompileText := 'alter table ' + MakeQuotedIdent(edTableName.Text, FIsInterbase6, FSQLDialect) + ' add ' + edColumnName.Text + ' ' + MakeQuotedIdent(cmbDomain.Text, FIsInterbase6, FSQLDialect);
				end;
				2:
				begin
					if edComputed.Text = '' then
					begin
						MessageDlg('The new column must have a computed clause.', mtError, [mbOK], 0);
						pgObjectEditor.ActivePage := tsMain;
						pgColumn.ActivePage := tsComputed;
						edComputed.SetFocus;
						Exit;
					end;

					FCompileText := 'alter table ' + MakeQuotedIdent(edTableName.Text, FIsInterbase6, FSQLDialect) + ' add ' + edColumnName.Text + ' computed by ' + edComputed.Text;
				end;
			end;
			FCompile := TfrmCompileDBObject.CreateCompile(Self, Self, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctSQL, FCompileText);
			FErrors := FCompile.CompileErrors;
			FCompile.Free;

			if FErrors then
				Exit
			else
			begin
				FNewColumnName := edColumnName.Text;
				ModalResult := mrOK;
			end;
		end
		else
			if FModifyObject then
			begin
				// check that the modified column has a name
				if edColumnName.Text = '' then
				begin
					MessageDlg('The column must have a name.', mtError, [mbOK], 0);
					pgObjectEditor.ActivePage := tsMain;
					edColumnName.SetFocus;
					Exit;
				end;

				// update the not null flag
				if FChangeNotNull then
				begin
					if chkColumnNotNull.Checked then
						FCompileText := 'update RDB$RELATION_FIELDS set RDB$NULL_FLAG = 1 where RDB$RELATION_NAME = ' + QuotedStr(edTableName.Text) + ' and RDB$FIELD_NAME = ' + QuotedStr(FObjectName)
					else
						FCompileText := 'update RDB$RELATION_FIELDS set RDB$NULL_FLAG = null where RDB$RELATION_NAME = ' + QuotedStr(edTableName.Text) + ' and RDB$FIELD_NAME = ' + QuotedStr(FObjectName);

					FCompile := TfrmCompileDBObject.CreateCompile(Self, Self, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctSQL, FCompileText);
					FErrors := FCompile.CompileErrors;
					FCompile.Free;

					if FErrors then
						Exit
					else
						ModalResult := mrOK;
				end;

				// update the description
				if framColumnDoco.edDoco.Modified then
				begin
					FCompileText := 'update RDB$RELATION_FIELDS set RDB$DESCRIPTION = ' + QuotedStr(framColumnDoco.edDoco.Text) + ' where RDB$RELATION_NAME = ' + QuotedStr(edTableName.Text) + ' and RDB$FIELD_NAME = ' + QuotedStr(FObjectName);

					FCompile := TfrmCompileDBObject.CreateCompile(Self, Self, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctSQL, FCompileText);
					FErrors := FCompile.CompileErrors;
					FCompile.Free;

					if FErrors then
						Exit
					else
						ModalResult := mrOK;
				end;

				// update the new column name
				if (FChangeName) and (FObjectName <> edColumnName.Text) then
				begin
					FCompileText := 'alter table ' + MakeQuotedIdent(edTableName.Text, FIsInterbase6, FSQLDialect) + ' alter column ' + MakeQuotedIdent(FObjectName, FIsInterbase6, FSQLDialect) + ' to ' + MakeQuotedIdent(edColumnName.Text, FIsInterbase6, FSQLDialect);

					FCompile := TfrmCompileDBObject.CreateCompile(Self, Self, qryUtil.IB_Connection, qryUtil.IB_Transaction, ctSQL, FCompileText);
					FErrors := FCompile.CompileErrors;
					FCompile.Free;

					if FErrors then
						Exit
					else
						if FChangeName then
						begin
							FNewColumnName := edColumnName.Text;
							ModalResult := mrOK;
						end;
				end;

			end;
	end;
end;

procedure TfrmColumns.ClearErrors;
begin
	inherited;
end;

procedure TfrmColumns.ForceRefresh;
begin
	inherited;
	Self.Refresh;
end;

procedure TfrmColumns.OpenMessages;
begin
end;

procedure TfrmColumns.edColumnNameChange(Sender: TObject);
begin
	inherited;
	FChangeName := True;
	CheckNameLength(edColumnName.Text);
end;

function TfrmColumns.GetActiveConnectionName: String;
begin
	Result := FDatabaseName;
end;

function TfrmColumns.GetActiveObjectType: TGSSCacheType;
begin
	Result := ctDomain;
end;

function TfrmColumns.GetObjectName: String;
begin
	Result := FObjectName;
end;

procedure TfrmColumns.SetObjectModified(Value: Boolean);
begin

end;

procedure TfrmColumns.SetObjectName(Value: String);
begin

end;

procedure TfrmColumns.AddCompileError(ErrorText: String);
begin

end;

procedure TfrmColumns.SetState(const Value: TColumnEditState);
var
	Intf : IMarathonForm;

begin
	FState := Value;
	case FState of
		stNewTable:
		begin
			edTableName.Enabled := True;
			FNewTableObject := True;
			FNewObject := True;
			FModifyObject := False;

			tsColumnDomain.TabVisible := False;
			tsColumnDefault.TabVisible := False;
			tsColumnDescription.TabVisible := False;
		end;
		stNewColumn:
		begin
			if Assigned(FTableEditor) then
				if FTableEditor.QueryInterface(IMarathonForm, Intf) = S_OK then
					edTableName.Text := Intf.GetObjectName;
			edTableName.Enabled := False;
			FNewTableObject := False;
			FNewObject := True;
			FModifyObject := False;

			tsColumnDomain.TabVisible := False;
			tsColumnDefault.TabVisible := False;
			tsColumnDescription.TabVisible := False;
		end;
		stColumnProperties:
		begin
			if Assigned(FTableEditor) then
				if FTableEditor.QueryInterface(IMarathonForm, Intf) = S_OK then
					edTableName.Text := Intf.GetObjectName;
			edTableName.Enabled := False;
			FNewTableObject := False;
			FNewObject := False;
			FModifyObject := True;

			tsConstraint.TabVisible := False;
			tsDescription.TabVisible := False;

			tsRaw.TabVisible := False;
			tsDomain.TabVisible := False;
			tsComputed.TabVisible := False;
		end;
	end;
end;

procedure TfrmColumns.FormActivate(Sender: TObject);
begin
	case FState of
		stNewTable:
			ActiveControl := edTableName;
		stNewColumn:
			ActiveControl := edColumnName;
		stColumnProperties:
			ActiveControl := edColumnName;
	end;
end;

procedure TfrmColumns.btnOKClick(Sender: TObject);
begin
	DoCompile;
end;

procedure TfrmColumns.tabRawDataTypeChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
	nbRawDataType.ActivePageIndex := NewTab;
end;

procedure TfrmColumns.edTableNameChange(Sender: TObject);
begin
  CheckNameLength(edTableName.Text);
end;

function TfrmColumns.GetObjectNewStatus: Boolean;
begin
	Result := FNewObject;
end;

procedure TfrmColumns.cmbColumnDomainChange(Sender: TObject);
begin
	FChangeDataType := True;
end;

procedure TfrmColumns.chkColumnNotNullClick(Sender: TObject);
begin
	FChangeNotNull := True;
end;

procedure TfrmColumns.btnColumnEditDomainClick(Sender: TObject);
begin
	with TfrmDomains.Create(nil) do
	begin
		ConnectionName := DatabaseName;
		if pgColumn.ActivePage = tsColumnDomain then
			LoadDomain(FDomainName)
		else
			LoadDomain(cmbDomain.Text);
		Show;
	end;
end;

procedure TfrmColumns.btnColumnNewDomainClick(Sender: TObject);
begin
	with TfrmDomains.Create(nil) do
	begin
		ConnectionName := DatabaseName;
		NewDomain;
		Show;
	end;
end;

procedure TfrmColumns.cmbDomainChange(Sender: TObject);
begin
   FChangeDataType := True;
end;

end.


