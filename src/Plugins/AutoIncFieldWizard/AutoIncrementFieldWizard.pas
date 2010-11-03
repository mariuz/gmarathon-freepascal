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
// $Id: AutoIncrementFieldWizard.pas,v 1.2 2002/04/25 07:17:03 tmuetze Exp $

unit AutoIncrementFieldWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, StdCtrls, ComCtrls, IBSQL, IBHeader, IBDatabase, Db, IBCustomDataSet;

type
  TfrmAutoInc = class(TForm)
    Bevel1: TBevel;
    btnPrev: TButton;
    btnNext: TButton;
    btnClose: TButton;
    Notebook1: TNotebook;
    Label1: TLabel;
    edTableName: TEdit;
    Label4: TLabel;
    cmbColumn: TComboBox;
    Label2: TLabel;
    edGeneratorName: TEdit;
    Label5: TLabel;
    edTriggerName: TEdit;
    Label6: TLabel;
    edFiringPos: TEdit;
    udFiringPos: TUpDown;
    chkUseSPWrapper: TCheckBox;
    Label7: TLabel;
    edSPName: TEdit;
    Panel1: TPanel;
    Bevel2: TBevel;
    Label8: TLabel;
    Label13: TLabel;
    Image1: TImage;
    dbAutoInc: TIBDatabase;
    tranAutoInc: TIBTransaction;
    qryAutoInc: TIBSQL;
    qryUtil: TIBDataSet;
    Label3: TLabel;
    procedure btnNextClick(Sender: TObject);
    procedure chkUseSPWrapperClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FConnectionName: String;
    FTableName: String;
		FSQLDialect : Integer;
		FIB6 : Boolean;
		{ Private declarations }
	public
		{ Public declarations }
		procedure Init;
		property TableName : String read FTableName write FTableName;
		property ConnectionName : String read FConnectionName write FConnectionName;
	end;

implementation

{$R *.DFM}

uses
	GimbalToolsAPI,
	AutoIncrementFieldWizardPlugin;

function IsIdentifierQuoted(S : String) : Boolean;
var
	BeginQuote : Boolean;
	EndQuote : Boolean;

begin
	BeginQuote := False;
	EndQuote := False;

	if Length(S) > 0 then
	begin
		if S[1] in ['''', '"'] then
		begin
			BeginQuote := True;
    end;
  end;

  if Length(S) > 0 then
  begin
    if S[Length(S)] in ['''', '"'] then
    begin
      EndQuote := True;
    end;
  end;
  Result := BeginQuote and EndQuote;
end;

function ShouldBeQuoted(S : String) : Boolean;
var
	Idx : Integer;

begin
	Result := False;
	for Idx := 1 to Length(S) do
	begin
		if not (S[Idx] in ['A'..'Z', 'a'..'z', '_', '0'..'9']) then
		begin
      Result := True;
      Break;
    end;
  end;
end;

function MakeQuotedIdent(S : String; IB6 : Boolean; Dialect : Integer) : String;
begin
  if not IB6 then
  begin
    Result := S;
  end
  else
  begin
    if Dialect in [3] then
    begin
      if not IsIdentifierQuoted(S) then
      begin
        if ShouldBeQuoted(S) then
          Result := AnsiQuotedStr(S, '"')
        else
          Result := S;
      end
      else
        Result := S;
    end
    else
      Result := S;
	end;
end;

procedure TfrmAutoInc.btnNextClick(Sender: TObject);
var
  Project : IGimbalIDEMarathonProject;

begin
  if edGeneratorName.Text = '' then
  begin
    MessageDlg('The wizard needs to know the Generator Name to be used.', mtInformation, [mbOK], 0);
    edGeneratorName.SetFocus;
    Exit;
  end;

  if edTriggerName.Text = '' then
  begin
    MessageDlg('The wizard needs to know the Trigger Name to be used.', mtInformation, [mbOK], 0);
    edTriggerName.SetFocus;
    Exit;
  end;

  if chkUseSPWrapper.Checked then
  begin
    if edSPName.Text = '' then
    begin
      MessageDlg('The wizard needs to know the Stored Procedure Name to be used.', mtInformation, [mbOK], 0);
      edSPName.SetFocus;
      Exit;
    end;
  end;

  // create the generator...
  try
    tranAutoInc.StartTransaction;
    qryAutoInc.SQL.Add('create generator ' + MakeQuotedIdent(edGeneratorName.Text, FIB6, FSQLDialect) + ';');
    qryAutoInc.ExecQuery;
    LocalToolServices.IDERecordToScript(FConnectionName, qryAutoInc.SQL.Text);

    if chkUseSPWrapper.Checked then
    begin
			qryAutoInc.SQL.Clear;
      qryAutoInc.SQL.Add('create procedure ' + MakeQuotedIdent(edSPName.Text, FIB6, FSQLDialect));
      qryAutoInc.SQL.Add('returns (new_value integer)');
      qryAutoInc.SQL.Add('as');
      qryAutoInc.SQL.Add('begin');
      qryAutoInc.SQL.Add('  new_value = gen_id(' + MakeQUotedIdent(edGeneratorName.Text, FIB6, FSQLDialect) + ', 1);');
      qryAutoInc.SQL.Add('end');
      qryAutoInc.ExecQuery;
      LocalToolServices.IDERecordToScript(FConnectionName, qryAutoInc.SQL.Text);


      qryAutoInc.SQL.Clear;
      qryAutoInc.SQL.Add('create trigger ' + MakeQuotedIdent(edTriggerName.Text, FIB6, FSQLDialect) + ' for ' + MakeQuotedIdent(edTableName.Text, FIB6, FSQLDialect));
      qryAutoInc.SQL.Add('active before insert position ' + IntToStr(udFiringPos.Position));
      qryAutoInc.SQL.Add('as');
      qryAutoInc.SQL.Add('begin');
      qryAutoInc.SQL.Add('  if (new.' + MakeQuotedIdent(cmbColumn.Text, FIB6, FSQLDialect) + ' is null) then');
      qryAutoInc.SQL.Add('    new.' + MakeQuotedIdent(cmbColumn.Text, FIB6, FSQLDialect) + ' = gen_id(' + MakeQuotedIdent(edGeneratorName.Text, FIB6, FSQLDialect) + ', 1);');
      qryAutoInc.SQL.Add('end');
      qryAutoInc.ExecQuery;
      LocalToolServices.IDERecordToScript(FConnectionName, qryAutoInc.SQL.Text);
    end
    else
    begin
      qryAutoInc.SQL.Clear;
      qryAutoInc.SQL.Add('create trigger ' + MakeQuotedIdent(edTriggerName.Text, FIB6, FSQLDialect) + ' for ' + MakeQuotedIdent(edTableName.Text, FIB6, FSQLDialect));
      qryAutoInc.SQL.Add('active before insert position ' + IntToStr(udFiringPos.Position));
      qryAutoInc.SQL.Add('as');
      qryAutoInc.SQL.Add('begin');
      qryAutoInc.SQL.Add('  if (new.' + MakeQuotedIdent(cmbColumn.Text, FIB6, FSQLDialect) + ' is null) then');
      qryAutoInc.SQL.Add('    new.' + MakeQuotedIdent(cmbColumn.Text, FIB6, FSQLDialect) + ' = gen_id(' + MakeQuotedIdent(edGeneratorName.Text, FIB6, FSQLDialect) + ', 1);');
      qryAutoInc.SQL.Add('end');
      qryAutoInc.ExecQuery;
      LocalToolServices.IDERecordToScript(FConnectionName, qryAutoInc.SQL.Text);
    end;
    tranAutoInc.Commit;

    Project := LocalToolServices.IDEGetProject;
    if Assigned(Project) then
		begin
			Project.IDEAddItemToTree(FConnectionName, edGeneratorName.Text, ttIDEGenerator);
      Project.IDEAddItemToTree(FConnectionName, edTriggerName.Text, ttIDETrigger);
      if chkUseSPWrapper.Checked then
        Project.IDEAddItemToTree(FConnectionName, edSPName.Text, ttIDESP);
    end;
    ModalResult := mrOK;
  except
    On E : Exception do
    begin
      MessageDlg(E.Message, mtError, [mbOK], 0);
      tranAutoInc.Rollback;
      Exit;
    end;
  end;
end;

procedure TfrmAutoInc.chkUseSPWrapperClick(Sender: TObject);
begin
  if chkUseSPWrapper.Checked then
  begin
    edSPName.Enabled := True;
  end
  else
  begin
    edSPName.Enabled := False;
  end;
end;

procedure TfrmAutoInc.Init;
var
  Project : IGimbalIDEMarathonProject;
  Connection : IGimbalIDEConnection;

begin
  //establish a connection to the database...
  Project := LocalToolServices.IDEGetProject;
  if Assigned(Project) then
  begin
    Connection := Project.IDEGetConnectionByName(FCOnnectionName);
		if Assigned(Connection) then
    begin
      FSQLDialect := Connection.IDESQLDialect;
      FIB6 := Connection.IDEIsInterbaseSix;
      dbAutoInc.SetHandle(TISC_DB_HANDLE(Connection.IDEGetCurrentDBHandle));

      edTableName.Text := FTableName;


      //get the columns...
      tranAutoInc.StartTransaction;
      try
        qryUtil.SelectSQL.Add('select a.rdb$field_name from rdb$relation_fields a, rdb$fields b where ' +
                              'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
                               AnsiQuotedStr(FTableName, '''') + ' ' +
                              ' order by a.rdb$field_position asc;');
        qryUtil.Open;
        while not qryUtil.EOF do
        begin
          cmbColumn.Items.Add(Trim(qryUtil.FieldByName('rdb$field_name').AsString));
          qryUtil.Next;
        end;
        qryUtil.Close;
        tranAutoInc.Commit;
        cmbColumn.ItemIndex := 0;
      except
        On E : Exception do
        begin
          tranAutoInc.Rollback;
        end;
      end;
    end;
  end;
end;

procedure TfrmAutoInc.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dbAutoInc.SetHandle(nil);
end;

end.

{
$Log: AutoIncrementFieldWizard.pas,v $
Revision 1.2  2002/04/25 07:17:03  tmuetze
New CVS powered comment block

}
