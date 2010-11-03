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
// $Id: MarathonMasterProperties.pas,v 1.6 2006/10/22 06:04:28 rjmills Exp $

unit MarathonMasterProperties;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Buttons, ComCtrls, ExtCtrls,
	rmBtnEdit,
	rmBaseEdit,
	MarathonProjectCache;

type
	TPropDlgType = (
		ptNewServer,
		ptModifyServer,
		ptNewConnection,
		ptModifyConnection,
		ptNewProject,
		ptModifyProject);

  TfrmMasterProperties = class(TForm)
    pgProperties: TPageControl;
    btnHelp: TButton;
    btnCancel: TButton;
		btnOK: TButton;
    tsConnection: TTabSheet;
		Label4: TLabel;
    Label6: TLabel;
    cmbCharSet: TComboBox;
    Label1: TLabel;
    edUserName: TEdit;
    Label2: TLabel;
    edPassword: TEdit;
    chkRememberPassword: TCheckBox;
    Label5: TLabel;
    edRole: TEdit;
    Label3: TLabel;
    edConnectionName: TEdit;
    Label7: TLabel;
    cmbDialect: TComboBox;
    tsProject: TTabSheet;
    Label8: TLabel;
    cmbEditorEncoding: TComboBox;
    Label9: TLabel;
    edNumItems: TEdit;
    udNumItems: TUpDown;
    chkDomains: TCheckBox;
		chkShowSystem: TCheckBox;
		Bevel1: TBevel;
		Label10: TLabel;
    edProjectName: TEdit;
    edDatabaseName: TrmBtnEdit;
    dlgOpen: TOpenDialog;
		tsServer: TTabSheet;
		Label11: TLabel;
    edServerName: TEdit;
    cmbServerHostName: TComboBox;
		lblServerHostName: TLabel;
		Label13: TLabel;
		edServerUserName: TEdit;
		Label14: TLabel;
		edServerPassword: TEdit;
		chkServerRememberPassword: TCheckBox;
		lblServerProtocol: TLabel;
		cmbServerProtocol: TComboBox;
		rbServerLocal: TRadioButton;
		rbServerRemote: TRadioButton;
		chkSaveWindowPos: TCheckBox;
		chkTriggers: TCheckBox;
		Bevel2: TBevel;
		Label12: TLabel;
		Label15: TLabel;
		Label16: TLabel;
		edSecureDatabaseUserName: TEdit;
		edSecureDatabasePassword: TEdit;
		chkSecureDatabaseRememberPassword: TCheckBox;
		edSecureDatabaseName: TrmBtnEdit;
		Bevel3: TBevel;
    Label17: TLabel;
    Label18: TLabel;
    cmbServerName: TComboBox;
		procedure btnOKClick(Sender: TObject);
		procedure edDatabaseNameChange(Sender: TObject);
		procedure edDatabaseNameBtn1Click(Sender: TObject);
		procedure rbServerLocalClick(Sender: TObject);
    procedure edSecureDatabaseNameBtn1Click(Sender: TObject);
    procedure cmbServerHostNameDropDown(Sender: TObject);
	private
		FDialogType: TPropDlgType;
		FProject: TMarathonProject;
		FNeedToDisconnect: Boolean;
		FOldConnection: String;
		FConnection: TMarathonCacheConnection;
		FServer: TMarathonCacheServer;
		procedure SetProject(const Value: TMarathonProject);
		procedure SetDialogType(const Value: TPropDlgType);
		{ Private declarations }
	public
		{ Public declarations }
		property DialogType: TPropDlgType read FDialogType write SetDialogType;
		property Project: TMarathonProject read FProject write SetProject;
		property NeedToDisconnect: Boolean read FNeedToDisconnect;
		// This constructor is used when a new server is created
		constructor CreateNewServer(const AOwner: TComponent);
		// This constructor is used when a server is modified
		constructor CreateModifyServer(const AOwner: TComponent; const Server: TMarathonCacheServer);
		// This constructor is used when a new connection is created
		constructor CreateNewConnection(const AOwner: TComponent);
		// This constructor is used when a connection is modified
		constructor CreateModifyConnection(const AOwner: TComponent; const Connection: TMarathonCacheConnection);
		// This constructor is used when a new project is created
		constructor CreateNewProject(const AOwner: TComponent);
		// This constructor is used when a new project is modified
		constructor CreateModifyProject(const AOwner: TComponent);
	end;

implementation

uses
	Globals,
	HelpMap,
	Tools,
	MarathonIDE,
	MarathonProjectCacheTypes;

{$R *.DFM}

constructor TfrmMasterProperties.CreateNewServer(const AOwner: TComponent);
begin
	inherited Create(AOwner);
	DialogType := ptNewServer;
	Caption := 'New Server';
	cmbServerProtocol.ItemIndex := 0;
end;

constructor TfrmMasterProperties.CreateModifyServer(const AOwner: TComponent; const Server: TMarathonCacheServer);
begin
	inherited Create(AOwner);
	DialogType := ptModifyServer;
	Self.FServer := Server;
	Caption := 'Modify Server [' + Server.Caption + ']';

	edServerName.Text := Server.Caption;

	if Server.Local then
		rbServerLocal.Checked := True
	else
	begin
		rbServerRemote.Checked := True;
		cmbServerProtocol.ItemIndex := Server.Protocol;
	end;

	cmbServerHostName.Text := Server.HostName;
	edServerUserName.Text := Server.UserName;
	edServerPassword.Text := Server.Password;
	chkServerRememberPassword.Checked := Server.RememberPassword;

	edSecureDatabaseName.Text := Server.SecureDatabaseName;
	edSecureDatabaseUserName.Text := Server.SecureDatabaseUserName;
	edSecureDatabasePassword.Text := Server.SecureDatabasePassword;
	chkSecureDatabaseRememberPassword.Checked := Server.SecureDatabaseRememberPassword;
end;

constructor TfrmMasterProperties.CreateNewConnection(const AOwner: TComponent);
begin
	inherited Create(AOwner);
	DialogType := ptNewConnection;
	Caption := 'New Connection';
end;

constructor TfrmMasterProperties.CreateModifyConnection(const AOwner: TComponent; const Connection: TMarathonCacheConnection);
begin
	inherited Create(AOwner);
	DialogType := ptModifyConnection;
	Self.FConnection := Connection;
	Caption := 'Modify Connection [' + Connection.Caption + ']';

	edConnectionName.Text := Connection.Caption;
	FOldConnection := Connection.Caption;
	cmbServerName.ItemIndex := cmbServerName.Items.IndexOf(Connection.ServerName);
	edDatabaseName.Text := Connection.DBFileName;
	cmbCharSet.ItemIndex := cmbCharSet.Items.IndexOf(Connection.LangDriver);
	edUserName.Text := Connection.UserName;
	edPassword.Text := Connection.Password;
	chkRememberPassword.Checked := Connection.RememberPassword;
	edRole.Text := Connection.SQLRole;
	cmbDialect.ItemIndex := Connection.SQLDialect - 1;
end;

constructor TfrmMasterProperties.CreateNewProject(const AOwner: TComponent);
begin
	inherited Create(AOwner);
	DialogType := ptNewProject;
	Caption := 'New Project';
end;

constructor TfrmMasterProperties.CreateModifyProject(const AOwner: TComponent);
begin
	inherited Create(AOwner);
	DialogType := ptModifyProject;
	Caption := 'Modify Project [' + MarathonIDEInstance.CurrentProject.FriendlyName + ']';
	Project := MarathonIDEInstance.CurrentProject;
end;

procedure TfrmMasterProperties.SetDialogType(const Value: TPropDlgType);
var
	Idx: Integer;

begin
	FDialogType := Value;
	for Idx := 0 to pgProperties.PageCount - 1 do
		pgProperties.Pages[Idx].TabVisible := False;

	case FDialogType of
		ptNewServer, ptModifyServer:
			begin
				tsServer.TabVisible := True;
				ActiveControl := edServerName;
				rbServerLocal.OnClick(rbServerLocal);
			end;

		ptNewConnection, ptModifyConnection:
			begin
				tsConnection.TabVisible := True;
				ActiveControl := edConnectionName;
				cmbCharSet.ItemIndex := 0;
				// Fill all actual registered server names
				cmbServerName.Items.Clear;
				for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ServerCount - 1 do
					cmbServerName.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Servers[Idx].Caption);
			end;

		ptNewProject, ptModifyProject:
			begin
				tsProject.TabVisible := True;
				HelpContext := IDH_Project_Properties;
				GetCharSetNames(cmbEditorEncoding.Items);
				ActiveControl := edProjectName;
			end;
	end;
end;

procedure TfrmMasterProperties.SetProject(const Value: TMarathonProject);
var
	I: Integer;
	Encoding: String;

begin
	FProject := Value;

	edProjectName.Text := FProject.FriendlyName;
	chkShowSystem.Checked := FProject.ShowSystem;
	chkDomains.Checked := FProject.ViewSystemDomains;
	chkTriggers.Checked := FProject.ViewSystemTriggers;

	udNumItems.Position := FProject.NumHistory;
	chkSaveWindowPos.Checked := FProject.SaveWindowPositions;

	Encoding := GetCharSetName(FProject.Encoding);
	if Encoding = '' then
		cmbEditorEncoding.ItemIndex := 1
	else
		for I := 0 to cmbEditorEncoding.Items.Count - 1 do
			if Encoding = cmbEditorEncoding.Items[I] then
			begin
				cmbEditorEncoding.ItemIndex := I;
				Break;
			end
			else
				cmbEditorEncoding.ItemIndex := 1;
end;

procedure TfrmMasterProperties.btnOKClick(Sender: TObject);
var
	Item: TMarathonCacheBaseNode;
	Server: TMarathonCacheServer;
	Connection: TMarathonCacheConnection;

begin
	case FDialogType of
		ptNewServer:
			begin
				if edServerName.Text = '' then
				begin
					MessageDlg('The server must have a name.', mtError, [mbOK], 0);
					edServerName.SetFocus;
					Exit;
				end;

				Server := MarathonIDEInstance.CurrentProject.Cache.ServerByName[edServerName.Text];
				if Assigned(Server) then
				begin
					MessageDlg('The name "' + edServerName.Text + '" is already in use.', mtError, [mbOK], 0);
					edServerName.SetFocus;
					Exit;
				end;

				Server := MarathonIDEInstance.CurrentProject.Cache.AddServerInternal;
				if Assigned(Server) then
				begin
					Server.Caption := edServerName.Text;
					Server.Local := rbServerLocal.Checked;
					if not Server.Local then
					begin
						Server.Protocol := cmbServerProtocol.ItemIndex;
						Server.HostName := cmbServerHostName.Text;
					end;
					Server.UserName := edServerUserName.Text;
					Server.Password := edServerPassword.Text;
					Server.RememberPassword := chkServerRememberPassword.Checked;
					Server.SecureDatabaseName := edSecureDatabaseName.Text;
					Server.SecureDatabaseUserName := edServerUserName.Text;
					Server.SecureDatabasePassword := edServerPassword.Text;
					Server.SecureDatabaseRememberPassword := chkSecureDatabaseRememberPassword.Checked;
					Item := Server.GetParentObject;
					if Assigned(Item) then
					begin
						Item.FireEvent(opRefresh);
						Item.FireEvent(opExpandNode);
					end;
					Server.FireEvent(opRefresh);
					Server.FireEvent(opExpandNode);
					Server.Connect;
				end;

				ModalResult := mrOK;
			end;

		ptModifyServer:
			begin
				if edServerName.Text = '' then
				begin
					MessageDlg('The server must have a name.', mtError, [mbOK], 0);
					edServerName.SetFocus;
					Exit;
				end;

				if Assigned(FServer) then
				begin
					FServer.Caption := edServerName.Text;
					FServer.Local := rbServerLocal.Checked;
					if not FServer.Local then
					begin
						FServer.Protocol := cmbServerProtocol.ItemIndex;
						FServer.HostName := cmbServerHostName.Text;
					end;
					FServer.UserName := edServerUserName.Text;
					FServer.Password := edServerPassword.Text;
					FServer.RememberPassword := chkServerRememberPassword.Checked;
					FServer.SecureDatabaseName := edSecureDatabaseName.Text;
					FServer.SecureDatabaseUserName := edSecureDatabaseUserName.Text;
					FServer.SecureDatabasePassword := edSecureDatabasePassword.Text;
					FServer.SecureDatabaseRememberPassword := chkSecureDatabaseRememberPassword.Checked;
					Item := FServer.GetParentObject;
					if Assigned(Item) then
					begin
						Item.FireEvent(opRefresh);
						Item.FireEvent(opExpandNode);
					end;
					FServer.FireEvent(opRefresh);
					FServer.FireEvent(opExpandNode);
				end;

				ModalResult := mrOK;
			end;

		ptNewConnection:
			begin
				if edConnectionName.Text = '' then
				begin
					MessageDlg('The connection must have a name.', mtError, [mbOK], 0);
					edConnectionName.SetFocus;
					Exit;
				end;

				Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[edConnectionName.Text];
				if Assigned(Connection) then
				begin
					MessageDlg('The name "' + edConnectionName.Text + '" is already in use.', mtError, [mbOK], 0);
					edConnectionName.SetFocus;
					Exit;
				end;

				if cmbServerName.ItemIndex = -1 then
				begin
					MessageDlg('The connection must have a Server Name assigned.', mtError, [mbOK], 0);
					cmbServerName.SetFocus;
					Exit;
				end;

				if edDatabaseName.Text = '' then
				begin
					MessageDlg('The Database Name must not be empty.', mtError, [mbOK], 0);
					edDatabaseName.SetFocus;
					Exit;
				end;

				Connection := MarathonIDEInstance.CurrentProject.Cache.AddConnectionInternal;
				if Assigned(Connection) then
				begin
					Connection.Caption := edConnectionName.Text;
					Connection.DBFileName := edDatabaseName.Text;
					Connection.ServerName := cmbServerName.Text;
					Connection.LangDriver := cmbCharSet.Text;
					Connection.UserName := edUserName.Text;
					Connection.Password := edPassword.Text;
					Connection.RememberPassword := chkRememberPassword.Checked;
					Connection.SQLRole := edRole.Text;
					Connection.SQLDialect := cmbDialect.ItemIndex + 1;
					Item := Connection.GetParentObject;
					if Assigned(Item) then
					begin
						Item.FireEvent(opRefresh);
						Item.FireEvent(opExpandNode);
					end;
					Connection.FireEvent(opRefresh);
					Connection.FireEvent(opExpandNode);
					Connection.Connect;

					ModalResult := mrOK;
				end;
			end;

		ptModifyConnection:
			begin
				if edConnectionName.Text = '' then
				begin
					MessageDlg('The connection must have a name.', mtError, [mbOK], 0);
					edConnectionName.SetFocus;
					Exit;
				end;

				if cmbServerName.ItemIndex = -1 then
				begin
					MessageDlg('The connection must have a Server Name assigned.', mtError, [mbOK], 0);
					cmbServerName.SetFocus;
					Exit;
				end;

				if edDatabaseName.Text = '' then
				begin
					MessageDlg('The Database Name must not be empty.', mtError, [mbOK], 0);
					edDatabaseName.SetFocus;
					Exit;
				end;

				if Assigned(FConnection) then
				begin
					FConnection.Caption := edConnectionName.Text;
					FConnection.DBFileName := edDatabaseName.Text;
					FConnection.ServerName := cmbServerName.Text;
					FConnection.LangDriver := cmbCharSet.Text;
					FConnection.UserName := edUserName.Text;
					FConnection.Password := edPassword.Text;
					FConnection.RememberPassword := chkRememberPassword.Checked;
					FConnection.SQLRole := edRole.Text;
					FConnection.SQLDialect := cmbDialect.ItemIndex + 1;
					FConnection.ErrorOnConnection := False;
					Item := FConnection.GetParentObject;

					if Assigned(Item) then
					begin
						Item.FireEvent(opRefresh);
						Item.FireEvent(opExpandNode);
					end;
					FConnection.FireEvent(opRefresh);
					FConnection.FireEvent(opExpandNode);

					ModalResult := mrOK;
				end;
			end;

		ptNewProject:
			begin
				if not edProjectName.ReadOnly then
					if edProjectName.Text = '' then
					begin
						MessageDlg('Project Name must have a value.', mtError, [mbOK], 0);
						Exit;
					end;

				with MarathonIDEInstance.CurrentProject do
				begin
					NewProject;
					FriendlyName := edProjectName.Text;
					ShowSystem := chkShowSystem.Checked;
					ViewSystemDomains := chkDomains.Checked;
					ViewSystemTriggers := chkTriggers.Checked;
					NumHistory := udNumItems.Position;
					Encoding := GetCharSetValue(cmbEditorEncoding.Text);
					SaveWindowPositions := chkSaveWindowPos.Checked;
				end;
				// Set the MarathonMain Caption
				if Assigned(MarathonIDEInstance.MainForm) then
					MarathonIDEInstance.MainForm.Caption := MarathonIDEInstance.MainForm.Caption
						 + ' - ' + MarathonIDEInstance.CurrentProject.FriendlyName;

				ModalResult := mrOK;
			end;

		ptModifyProject:
			begin
				if not edProjectName.ReadOnly then
					if edProjectName.Text = '' then
					begin
						MessageDlg('Project Name must have a value.', mtError, [mbOK], 0);
						Exit;
					end;

				FProject.FriendlyName := edProjectName.Text;
				FProject.ShowSystem := chkShowSystem.Checked;
				FProject.ViewSystemDomains := chkDomains.Checked;
				FProject.ViewSystemTriggers := chkTriggers.Checked;
				FProject.NumHistory := udNumItems.Position;
				FProject.Encoding := GetCharSetValue(cmbEditorEncoding.Text);
				FProject.SaveWindowPositions := chkSaveWindowPos.Checked;

				ModalResult := mrOK;
			end;
	end;
end;

procedure TfrmMasterProperties.edDatabaseNameChange(Sender: TObject);
begin
	FNeedToDisconnect := True;
end;

procedure TfrmMasterProperties.edDatabaseNameBtn1Click(Sender: TObject);
begin
	if dlgOpen.Execute then
  begin   //AC:
		edDatabaseName.Text := dlgOpen.FileName;
    if edConnectionName.Text = '' then    //AC:
      edConnectionName.Text := ExtractFileName(dlgOpen.FileName);   //AC:
  end;    //AC:
end;

procedure TfrmMasterProperties.rbServerLocalClick(Sender: TObject);
begin
	Tools.ChangeEnables([cmbServerHostName, lblServerHostName, cmbServerProtocol,
		lblServerProtocol], rbServerRemote.Checked);
end;

procedure TfrmMasterProperties.cmbServerHostNameDropDown(Sender: TObject);
var
	slstServerList: TStringList;

begin
	slstServerList := TStringList.Create;
	Tools.EnumNetResources(slstServerList);
	if (Assigned(slstServerList) = True) then
		cmbServerHostName.Items.Assign(slstServerList);
end;

procedure TfrmMasterProperties.edSecureDatabaseNameBtn1Click(Sender: TObject);
begin
	if dlgOpen.Execute then
		edSecureDatabaseName.Text := dlgOpen.FileName;
end;

end.

{
$Log: MarathonMasterProperties.pas,v $
Revision 1.6  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.5  2003/11/05 05:46:12  figmentsoft
I added a stupid little feature where when you browse for a .gdb file, it inserts the name within the new connection's name box.  Don't know if anyone else would like this, but I find it tedious to type a connection name for the database I plan to browse and open.  If any future authors don't like to save time, please trash it.

Revision 1.4  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.3  2002/04/29 06:48:50  tmuetze
Fixed bug 538259, charsets are not saved

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
