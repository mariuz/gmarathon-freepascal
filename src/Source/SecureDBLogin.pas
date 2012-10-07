unit SecureDBLogin;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, FileCtrl, ExtCtrls, Registry;

type
  TfrmSecureConnect = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edUserName: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edDBName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
	end;

implementation

uses
	Globals,
	MarathonIDE{,
	MarathonMain};

{$R *.lfm}

procedure TfrmSecureConnect.FormCreate(Sender: TObject);
begin
{	if MarathonIDEInstance.CurrentProject. SecureDB <> '' then
	begin
		edDBName.Text := MarathonIDEInstance.CurrentProject.SecureDB;
		ActiveControl := edUserName;
	end
	else
	begin
		ActiveControl := edDBName;
		Exit;
	end;

	if MarathonIDEInstance.CurrentProject.SecureDBUserName <> '' then
	begin
		edUserName.Text := MarathonIDEInstance.CurrentProject.SecureDBUserName;
		ActiveControl := edPassword;
	end
	else
		ActiveControl := edUserName;

	if MarathonIDEInstance.CurrentProject.SecureDBPassword <> '' then
		edPassword.Text := MarathonIDEInstance.CurrentProject.SecureDBPassword;}
end;

procedure TfrmSecureConnect.btnOKClick(Sender: TObject);
begin
{	MarathonIDEInstance.CurrentProject.SecureDB := edDBName.Text;
	MarathonIDEInstance.CurrentProject.SecureDBUserName := edUserName.Text;
	MarathonIDEInstance.CurrentProject.SecureDBPassword := edPassword.Text;}
	ModalResult := mrOK;
end;

end.


