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
// $Id: CreateDatabase.pas,v 1.2 2002/04/25 07:15:55 tmuetze Exp $

unit CreateDatabase;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, ComCtrls, StdCtrls, Buttons,
	IB_Header,
	IB_Components,
	IB_Session,
	IB_Process,
	IB_Script;

type
  TfrmCreateDatabase = class(TForm)
    nbCreateDatabase: TNotebook;
    Label1: TLabel;
    edDBName: TEdit;
    Label2: TLabel;
    edUser: TEdit;
    Label3: TLabel;
    edPassword: TEdit;
    Label4: TLabel;
    cmbPageSize: TComboBox;
    Label5: TLabel;
    cmbCharSet: TComboBox;
    chkMultifile: TCheckBox;
    pnlFiles: TPanel;
    Label7: TLabel;
    edLengthPages: TEdit;
    lblSize: TLabel;
    Label6: TLabel;
    btnAdd: TButton;
    btnRemove: TButton;
    btnEdit: TButton;
    lvSecondaryFiles: TListView;
    btnBack: TButton;
    btnFinish: TButton;
    btnClose: TButton;
    chkRunScript: TCheckBox;
    edScriptName: TEdit;
    Label9: TLabel;
    SpeedButton1: TSpeedButton;
    edResults: TMemo;
    Label10: TLabel;
		Label12: TLabel;
    dbCreateDatabase: TIB_Connection;
		tranCreateConnection: TIB_Transaction;
    qryConnection: TIB_DSQL;
    dlgOpen: TOpenDialog;
    Bevel1: TBevel;
    Panel2: TPanel;
    Bevel2: TBevel;
    Label8: TLabel;
    Label13: TLabel;
    ibScript: TIB_Script;
    cmbDialect: TComboBox;
    Label14: TLabel;
		pnlMarathon: TPanel;
    chkFurtherAction: TCheckBox;
    rbCreateProject: TRadioButton;
    rbCreateConnection: TRadioButton;
    lblFurtherAction: TLabel;
    edProjectName: TEdit;
    lblFurtherActionOne: TLabel;
    edConnectionName: TEdit;
    Image1: TImage;
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure cmbPageSizeChange(Sender: TObject);
    procedure edLengthPagesChange(Sender: TObject);
    procedure btnFinishClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure chkMultifileClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ibScriptError(Sender: TObject; const ERRCODE: Integer;
      ErrorMessage, ErrorCodes: TStringList; const SQLCODE: Integer;
      SQLMessage, SQL: TStringList; var RaiseException: Boolean);
    procedure chkFurtherActionClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure rbCreateConnectionClick(Sender: TObject);
	private
		FSTate: Integer;
		FCallingApp: Integer;
		procedure CalcSizeLabel;
		{ Private declarations }
	public
		{ Public declarations }
		property State : Integer read FSTate write FSTate;
		property CallingApp : Integer read FCallingApp write FCallingApp;
	end;

implementation

{$R *.DFM}

uses
	DBAddSecondaryFile,
	GSSCreateDatabaseConsts;

function IntSizeStr(Size : integer) : string;
var
	F : Extended;
begin
	if (Size = 0) then
		Result := '0KB'
	else
		if (Size > 1024 * 1024 * 1024) then
		begin
			F := Int(Size / (1024 * 1024 * 1024) * 100) / 100;
			Result := FloatToStrF(F, ffFixed, 8, 2) + 'GB'
		end
		else
			if (Size > 1024 * 1024) then
        Result := IntToStr((Size - 1) div (1024 * 1024) + 1) + 'MB'
      else
        Result := IntToStr((Size - 1) div 1024 + 1) + 'KB';
end;

function ExtSizeStr(Size : extended) : string;
begin
  if (Size = 0) then
    Result := '0KB'
  else
    if (Size > 1024 * 1024 * 1024) then
      Result := FloatToStrF((Size / (1024 * 1024 * 1024)), ffFixed, 8, 2) + 'GB'
    else
      if (Size > 1024 * 1024) then
        Result := FloatToStrF((Size / (1024 * 1024)), ffFixed, 8, 2) + 'MB'
      else
        Result := FloatToStrF((Size / 1024), ffFixed, 8, 2) + 'KB';
end;

function GetDefScriptDir : String;
begin

end;

procedure TfrmCreateDatabase.btnHelpClick(Sender: TObject);
begin
//  Application.HelpCommand(HELP_CONTEXT, IDH_Create_Database);
end;

procedure TfrmCreateDatabase.FormCreate(Sender: TObject);
begin
	//HelpContext := IDH_Create_Database;
	nbCreateDatabase.ActivePage := 'ONE';
	cmbDialect.ItemIndex := 0;
end;

procedure TfrmCreateDatabase.btnAddClick(Sender: TObject);
var
  F : TfrmDBSecondaryFile;
  L : Integer;
  Temp : String;

begin
  F := TfrmDBSecondaryFile.Create(Self);
  try
    if F.ShowModal = mrOK then
    begin
      with lvSecondaryFiles.Items.Add do
      begin
        Caption := F.edFileName.Text;
        SubItems.Add(F.edPages.Text);
        L := StrToInt(F.edPages.Text);
        Temp := IntSizeStr(L * StrToInt(cmbPageSize.Text));
        if Length(Temp) > 0 then
        begin
          if Temp[1] = '-' then
            SubItems.Add('>2Gb')
					else
						SubItems.Add(Temp)
        end;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmCreateDatabase.btnRemoveClick(Sender: TObject);
begin
  if lvSecondaryFiles.Selected <> nil then
  begin
    if MessageDlg('Are you sure you wish to delete the secondary file "' +
                  lvSecondaryFiles.Selected.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      lvSecondaryFiles.Selected.Delete;
    end;
  end;
end;

procedure TfrmCreateDatabase.btnEditClick(Sender: TObject);
var
  F : TfrmDBSecondaryFile;
  L : Integer;
  Temp : String;

begin
  if lvSecondaryFiles.Selected <> nil then
  begin
    F := TfrmDBSecondaryFile.Create(Self);
    try
      F.edFileName.Text := lvSecondaryFiles.Selected.Caption;
      F.edPages.Text := lvSecondaryFiles.Selected.SubItems[0];
      if F.ShowModal = mrOK then
      begin
        with lvSecondaryFiles.Selected do
        begin
					SubItems.Clear;
					Caption := F.edFileName.Text;
          SubItems.Add(F.edPages.Text);

          L := StrToInt(F.edPages.Text);
          Temp := IntSizeStr(L * StrToInt(cmbPageSize.Text));
          if Length(Temp) > 0 then
          begin
            if Temp[1] = '-' then
              SubItems.Add('>2Gb')
            else
              SubItems.Add(Temp)
          end;
        end;
      end;
    finally
      F.Free;
    end;
  end;
end;

procedure TfrmCreateDatabase.cmbPageSizeChange(Sender: TObject);
begin
  CalcSizeLabel;
end;

procedure TfrmCreateDatabase.CalcSizeLabel;
var
  L : Integer;
  Temp : String;

begin
  if chkMultifile.Checked then
  begin
    if edLengthPages.Text <> '' then
    begin
      try
        L := StrToInt(edLengthPages.Text);
        Temp := IntSizeStr(L * StrToInt(cmbPageSize.Text));
				if Length(Temp) > 0 then
				begin
          if Temp[1] = '-' then
            lblSize.Caption := '>2Gb'
          else
            lblSize.Caption := Temp;
        end;
      except
        //do nothing...
      end;
    end;
  end;
end;

procedure TfrmCreateDatabase.edLengthPagesChange(Sender: TObject);
begin
  CalcSizeLabel;
end;

procedure TfrmCreateDatabase.btnFinishClick(Sender: TObject);
var
  dbHandle: isc_db_handle;
  trHandle: isc_tr_handle;
  CreateString: string;
  SaveCW: word;
  Idx : Integer;


  function GetLine(Stat : String; EndLine : Integer) : Integer;
  var
    Ndx : Integer;
    Temp : String;

  begin
    Result := 0;
    Temp := AdjustLineBreaks(Stat);
    Ndx := Pos(#13#10, Temp);
    while Ndx > 0 do
    begin
			Result := Result + 1;
			Delete(Temp, 1, Ndx + 1);
      Ndx := Pos(#13#10, Temp);
    end;
    Result := EndLine - Result;
  end;

begin
  case nbCreateDatabase.PageIndex of
    0 :
      begin
        if edDBName.Text = '' then
        begin
          MessageDlg('Database must have a name.', mtError, [mbOK], 0);
          edDBName.SetFocus;
          Exit;
        end;

        if edUser.Text = '' then
        begin
          MessageDlg('A user name is required for database creation.', mtError, [mbOK], 0);
          edUser.SetFocus;
          Exit;
        end;

        if edPassword.Text = '' then
        begin
          MessageDlg('A password is required for database creation.', mtError, [mbOK], 0);
          edPassword.SetFocus;
          Exit;
        end;

        nbCreateDatabase.ActivePage := 'TWO';
        btnBack.Enabled := True;
      end;

    1 :
      begin
        if chkMultifile.Checked then
				begin
					if edLengthPages.Text <> '' then
          begin
            try
              StrToInt(edLengthPages.Text);
            except
              On E : Exception do
              begin
                MessageDlg('Number of pages must be a positive integer value.', mtError, [mbOK], 0);
                edLengthPages.SetFocus;
                Exit;
              end;
            end;
          end
          else
          begin
            MessageDlg('A number of pages is required for multi-file database creation.', mtError, [mbOK], 0);
            edLengthPages.SetFocus;
            Exit;
          end;

          if lvSecondaryFiles.Items.Count = 0 then
          begin
            MessageDlg('At least one secondary file is required for multi-file database creation.', mtError, [mbOK], 0);
            Exit;
          end;
        end;
        if FCallingApp = APP_MARATHON then
        begin
          pnlMarathon.Visible := True;
          if FState = APP_MARATHON_NO_OPEN_PROJECT then
          begin
            rbCreateConnection.Enabled := False;
            rbCreateConnection.Checked := False;
          end;
        end
        else
          pnlMarathon.Visible := False;
        nbCreateDatabase.ActivePage := 'THREE';
				btnBack.Enabled := True;
			end;

    2 :
      begin
        if chkRunScript.Checked then
        begin
          if not FileExists(edScriptName.Text) then
          begin
            MessageDlg('The script file "' + edScriptName.Text + '" does not exist.', mtError, [mbOK], 0);
            edScriptName.SetFocus;
            Exit;
          end;
        end;

        if chkFurtherAction.Checked and rbCreateProject.Checked then
        begin
          if edProjectName.Text = '' then
          begin
            MessageDlg('The Further Action option requires a name for the new project.', mtError, [mbOK], 0);
            edProjectName.SetFocus;
            Exit;
          end;
        end;

        if chkFurtherAction.Checked then
        begin
          if edConnectionName.Text = '' then
          begin
            MessageDlg('The Further Action option requires a name for the new connection.', mtError, [mbOK], 0);
            edConnectionName.SetFocus;
            Exit;
          end;
        end;

        nbCreateDatabase.ActivePage := 'FOUR';
        btnBack.Enabled := True;
        btnFinish.Caption := '&Create';
      end;

		3 :
      begin
        try
          edResults.Lines.Clear;
          CreateString := Format( 'create database ''%s''', [ edDBName.Text ] );
          CreateString := CreateString + Format( ' user ''%s''', [ edUser.Text ] );
          CreateString := CreateString + Format( ' password ''%s''', [ edPassword.Text ] );
          if cmbPageSize.Text <> '' then
            CreateString := CreateString + Format( ' page_size = %s', [ cmbPageSize.Text ] );


					if chkMultifile.Checked then
					begin
						CreateString := CreateString + ' length = ' + edLengthPages.Text;

						if cmbCharSet.Text <> '' then
						begin
							CreateString := CreateString + Format( ' default character set %s', [ cmbCharSet.Text ] );
						end;


						for Idx := 0 to lvSecondaryFiles.Items.Count - 1 do
						begin
							CreateString := CreateString + ' file ''' + lvSecondaryFiles.Items.Item[Idx].Caption + ''' length ' +
															lvSecondaryFiles.Items.Item[Idx].SubItems[0];
						end;
					end
					else
						if cmbCharSet.Text <> '' then
						begin
							CreateString := CreateString + Format( ' default character set %s', [ cmbCharSet.Text ] );
						end;

					dbHandle := nil;
					trHandle := nil;
					asm
						fstcw [SaveCW]
					end;
					with dbCreateDatabase.IB_Session do
					begin
						errcode := isc_dsql_execute_immediate( @Status,
																								 @dbHandle,
																								 @trHandle,
																								 null_terminated,
																								 PChar(CreateString),
																								 StrToInt(cmbDialect.Text),
																								 nil );
						asm
							fldcw [SaveCW]
						end;
						if errcode = 0 then
						begin
							asm
								fstcw [SaveCW]
							end;
							//set the dialect here....
							{ TODO -oPatrick -cTODO : Add in code to set the dialect.... }
							errCode := isc_detach_database( @Status, @dbHandle );
							asm
								fldcw [SaveCW]
              end;
            end;
            if errcode <> 0 then
              HandleException( Self );

            edResults.Lines.Add('Database "' + edDBName.Text + '" created successfully.');

            if chkRunScript.Checked then
            begin
              try
                edResults.Lines.Add('');
                edResults.Lines.Add('Running Script...');

                dbCreateDatabase.DatabaseName := edDBName.Text;
                dbCreateDatabase.Username := edUser.Text;
								dbCreateDatabase.Password := edPassword.Text;
                dbCreateDatabase.Connected := True;

                ibScript.SQL.LoadFromFile(edScriptName.Text);
                ibScript.Execute;

							except
								On E : Exception do
								begin
									edResults.Lines.Add(E.Message);
								end;
							end;
            end;
          end;
          btnBack.Enabled := False;
          btnFinish.Enabled := False;

        except
          On E : Exception do
          begin
            edResults.Lines.Add(E.Message);
          end;
        end;
      end;

  end;
end;

procedure TfrmCreateDatabase.btnBackClick(Sender: TObject);
begin
  case nbCreateDatabase.PageIndex of
    0 :
      begin
        //do nothing
      end;

    1 :
      begin
        nbCreateDatabase.ActivePage := 'ONE';
				btnBack.Enabled := False;
      end;

    2 :
      begin
				nbCreateDatabase.ActivePage := 'TWO';
        btnBack.Enabled := True;
      end;

    3 :
      begin
        nbCreateDatabase.ActivePage := 'THREE';
        btnBack.Enabled := True;
        btnFinish.Caption := 'Next &>';
      end;
  end;
end;

procedure TfrmCreateDatabase.chkMultifileClick(Sender: TObject);
begin
  if chkMultifile.Checked then
  begin
    pnlFiles.Visible := True;
    edLengthPages.SetFocus;
  end
  else
  begin
    pnlFiles.Visible := False;
  end;
end;

procedure TfrmCreateDatabase.SpeedButton1Click(Sender: TObject);
begin
  try
    dlgOpen.InitialDir := GetDefScriptDir;
  except

  end;
  if dlgOpen.Execute then
		edScriptName.Text := dlgOpen.FileName;
end;

procedure TfrmCreateDatabase.ibScriptError(Sender: TObject;
  const ERRCODE: Integer; ErrorMessage, ErrorCodes: TStringList;
	const SQLCODE: Integer; SQLMessage, SQL: TStringList;	var RaiseException: Boolean);
begin
	edResults.Lines.Add(SQLMessage.Text);
	RaiseException := False;
end;

procedure TfrmCreateDatabase.chkFurtherActionClick(Sender: TObject);
begin
	if chkFurtherAction.Checked then
	begin
		if FState = APP_MARATHON_NO_OPEN_PROJECT then
		begin
			rbCreateConnection.Enabled := False;
			rbCreateConnection.Checked := False;
		end
		else
			rbCreateConnection.Enabled := True;

		rbCreateProject.ENabled := True;
    lblFurtherAction.Enabled := not rbCreateConnection.Checked;
    lblFurtherActionOne.Enabled := True;
    edProjectName.ENabled := not rbCreateConnection.Checked;
    edConnectionName.ENabled := True;
  end
  else
  begin
    rbCreateConnection.Enabled := False;
    rbCreateProject.ENabled := False;
    lblFurtherAction.Enabled := False;
    lblFurtherActionOne.Enabled := False;
    edProjectName.ENabled := False;
    edConnectionName.ENabled := False;
  end;
end;

procedure TfrmCreateDatabase.btnCloseClick(Sender: TObject);
begin
	if (nbCreateDatabase.ActivePage = 'FOUR') and (not btnFinish.Enabled) then
    ModalResult := mrOK
  else
    ModalResult := mrCancel;
end;

procedure TfrmCreateDatabase.rbCreateConnectionClick(Sender: TObject);
begin
  if rbCreateConnection.Checked then
  begin
    lblFurtherAction.Enabled := False;
    edProjectName.Enabled := False;
  end
  else
  begin
    lblFurtherAction.Enabled := True;
    edProjectName.Enabled := True;
  end;
end;

end.

{
$Log: CreateDatabase.pas,v $
Revision 1.2  2002/04/25 07:15:55  tmuetze
New CVS powered comment block

}
