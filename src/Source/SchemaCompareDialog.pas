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

unit SchemaCompareDialog;

{$MODE Delphi}

{ Picks the two connections for a schema comparison.

  Only open connections are offered. A comparison reads both catalogues, so
  there is nothing useful to do with a connection that is not connected, and
  silently connecting one on the user's behalf is not this dialog's business.

  The wording is deliberate about direction: the comparison is not symmetric,
  and "source" versus "target" alone has repeatedly been read the wrong way
  round. The label says which database the script would change. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls;

type
  TfrmSchemaCompare = class(TForm)
    lblSource: TLabel;
    lblTarget: TLabel;
    lblExplain: TLabel;
    rbFromConnection: TRadioButton;
    rbFromScript: TRadioButton;
    edScript: TEdit;
    btnBrowseScript: TButton;
    dlgOpenScript: TOpenDialog;
    cmbSource: TComboBox;
    cmbTarget: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnBrowseScriptClick(Sender: TObject);
    procedure SourceKindChanged(Sender: TObject);
  public
    { The chosen connection names, valid once the dialog returns mrOK. }
    function SourceConnection: String;
    function TargetConnection: String;
    { True when the comparison is against a DDL script rather than a second
      database. ScriptFile is then what to read. }
    function ComparingWithScript: Boolean;
    function ScriptFile: String;
  end;

implementation

uses MarathonIDE;

{$R *.lfm}

procedure TfrmSchemaCompare.FormCreate(Sender: TObject);
var
  Idx: Integer;
begin
  cmbSource.Items.Clear;
  cmbTarget.Items.Clear;
  for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
    if MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Connected then
    begin
      cmbSource.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
      cmbTarget.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
    end;
  if cmbSource.Items.Count > 0 then
    cmbSource.ItemIndex := 0;
  { Defaults to a different one where there is one, so the dialog opens on a
    comparison that would actually do something. }
  if cmbTarget.Items.Count > 1 then
    cmbTarget.ItemIndex := 1
  else if cmbTarget.Items.Count > 0 then
    cmbTarget.ItemIndex := 0;
  rbFromConnection.Checked := True;
  SourceKindChanged(nil);
end;

procedure TfrmSchemaCompare.SourceKindChanged(Sender: TObject);
begin
  cmbSource.Enabled := rbFromConnection.Checked;
  edScript.Enabled := rbFromScript.Checked;
  btnBrowseScript.Enabled := rbFromScript.Checked;
end;

procedure TfrmSchemaCompare.btnBrowseScriptClick(Sender: TObject);
begin
  dlgOpenScript.Filter := 'SQL Scripts (*.sql)|*.sql|All Files (*.*)|*.*';
  dlgOpenScript.Title := 'Reference Script';
  if dlgOpenScript.Execute then
    edScript.Text := dlgOpenScript.FileName;
end;

function TfrmSchemaCompare.ComparingWithScript: Boolean;
begin
  Result := rbFromScript.Checked;
end;

function TfrmSchemaCompare.ScriptFile: String;
begin
  Result := Trim(edScript.Text);
end;

function TfrmSchemaCompare.SourceConnection: String;
begin
  if cmbSource.ItemIndex >= 0 then
    Result := cmbSource.Items[cmbSource.ItemIndex]
  else
    Result := '';
end;

function TfrmSchemaCompare.TargetConnection: String;
begin
  if cmbTarget.ItemIndex >= 0 then
    Result := cmbTarget.Items[cmbTarget.ItemIndex]
  else
    Result := '';
end;

procedure TfrmSchemaCompare.btnOKClick(Sender: TObject);
begin
  if ComparingWithScript then
  begin
    if ScriptFile = '' then
    begin
      MessageDlg('Choose the script to compare against.', mtWarning, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    end;
    if TargetConnection = '' then
    begin
      MessageDlg('Choose the database to compare.', mtWarning, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    end;
    ModalResult := mrOK;
    Exit;
  end;

  if (SourceConnection = '') or (TargetConnection = '') then
  begin
    MessageDlg('Choose a connection on both sides.', mtWarning, [mbOK], 0);
    ModalResult := mrNone;
    Exit;
  end;
  if SourceConnection = TargetConnection then
  begin
    { Allowed by nothing in the engine, but a database compared with itself
      always reports no differences, which reads as a bug rather than as the
      tautology it is. }
    MessageDlg('The two sides are the same connection, which can only report ' +
      'no differences. Choose a different database on one side.',
      mtWarning, [mbOK], 0);
    ModalResult := mrNone;
    Exit;
  end;
  ModalResult := mrOK;
end;

end.
