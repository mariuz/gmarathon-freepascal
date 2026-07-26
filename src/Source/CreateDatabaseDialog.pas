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

unit CreateDatabaseDialog;

{$MODE Delphi}

{ File > Create Database.

  Replaces the original Windows COM wizard, which had a Delphi .dfm and no
  .lfm and so could not run on this port at all - the menu item did nothing,
  silently, because its whole body sat inside a WINDOWS-only conditional.

  One page rather than the original's four: with the COM component gone, what
  is left to ask for is the five things IBX can express when it builds the
  CREATE DATABASE statement, and those fit on one form. The old wizard's
  "run a script afterwards" and "create a project" steps are not reproduced -
  a script is what the SQL editor is for, and the connection is offered
  directly instead.

  The creation itself is in the LCL-free CreateDatabase unit so it can be
  tested against a real server without a GUI. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  CreateDatabase;

type
  TfrmCreateDatabase = class(TForm)
    lblServer: TLabel;
    lblFile: TLabel;
    lblUser: TLabel;
    lblPassword: TLabel;
    lblPageSize: TLabel;
    lblCharSet: TLabel;
    lblDialect: TLabel;
    edServer: TEdit;
    edFile: TEdit;
    edUser: TEdit;
    edPassword: TEdit;
    cmbPageSize: TComboBox;
    cmbCharSet: TComboBox;
    cmbDialect: TComboBox;
    chkConnect: TCheckBox;
    btnBrowse: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  public
    { What was asked for, valid once the dialog returns mrOK - and by then the
      database has been created. }
    function Options: TCreateDatabaseOptions;
    { True when the user asked for a connection to be set up afterwards. }
    function WantsConnection: Boolean;
  end;

implementation

{$R *.lfm}

procedure TfrmCreateDatabase.FormCreate(Sender: TObject);
var
  Sizes: TStringList;
begin
  Sizes := SupportedPageSizes;
  try
    cmbPageSize.Items.Assign(Sizes);
  finally
    Sizes.Free;
  end;
  cmbPageSize.ItemIndex := 0;

  { A short list of the character sets in common use rather than every one the
    server knows: the database does not exist yet, so RDB$CHARACTER_SETS cannot
    be read to find out what this server actually supports. The combo stays
    editable for that reason - anything typed is passed through and the server
    judges it. }
  cmbCharSet.Items.Clear;
  cmbCharSet.Items.Add('UTF8');
  cmbCharSet.Items.Add('NONE');
  cmbCharSet.Items.Add('ASCII');
  cmbCharSet.Items.Add('ISO8859_1');
  cmbCharSet.Items.Add('WIN1250');
  cmbCharSet.Items.Add('WIN1251');
  cmbCharSet.Items.Add('WIN1252');
  cmbCharSet.ItemIndex := 0;

  cmbDialect.Items.Clear;
  cmbDialect.Items.Add('3');
  cmbDialect.Items.Add('1');
  cmbDialect.ItemIndex := 0;

  edUser.Text := 'SYSDBA';
end;

procedure TfrmCreateDatabase.btnBrowseClick(Sender: TObject);
begin
  dlgSave.Filter := 'Firebird Databases (*.fdb)|*.fdb|All Files (*.*)|*.*';
  dlgSave.DefaultExt := 'fdb';
  { The file must not exist, so the usual overwrite prompt would be exactly
    backwards - it would invite the user to confirm something that is then
    refused. }
  dlgSave.Options := dlgSave.Options - [ofOverwritePrompt];
  dlgSave.Title := 'New Database File';
  if dlgSave.Execute then
    edFile.Text := dlgSave.FileName;
end;

function TfrmCreateDatabase.Options: TCreateDatabaseOptions;
begin
  Result.ServerName := Trim(edServer.Text);
  Result.FileName := Trim(edFile.Text);
  Result.UserName := edUser.Text;
  Result.Password := edPassword.Text;
  Result.CharacterSet := Trim(cmbCharSet.Text);
  Result.PageSize := StrToIntDef(Trim(cmbPageSize.Text), 0);
  Result.Dialect := StrToIntDef(Trim(cmbDialect.Text), 3);
end;

function TfrmCreateDatabase.WantsConnection: Boolean;
begin
  Result := chkConnect.Checked;
end;

procedure TfrmCreateDatabase.btnOKClick(Sender: TObject);
var
  ErrorMessage: String;
begin
  if Trim(edFile.Text) = '' then
  begin
    MessageDlg('Enter a file name for the new database.', mtWarning, [mbOK], 0);
    edFile.SetFocus;
    ModalResult := mrNone;
    Exit;
  end;

  { Created here rather than by the caller so that a failure leaves the dialog
    open with the values still in it - the usual reasons are a bad path or a
    wrong password, and both are fixed by editing a field and pressing OK
    again. }
  Screen.Cursor := crHourGlass;
  try
    if not CreateFirebirdDatabase(Options, ErrorMessage) then
    begin
      Screen.Cursor := crDefault;
      MessageDlg('The database could not be created.' + #13#10#13#10 +
        ErrorMessage, mtError, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
  ModalResult := mrOK;
end;

end.
