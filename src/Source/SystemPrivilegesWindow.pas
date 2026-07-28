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

unit SystemPrivilegesWindow;

{$MODE Delphi}

{ Which roles may do what to the server.

  Firebird 4 grants the right to run gbak, to trace another attachment, to read
  raw pages or to create a database to *roles*, as a bitmask in RDB$ROLES that
  no other window here decodes. This shows it: the roles on the left, and for
  the selected one, every privilege the server defines with a mark against the
  ones it has.

  Read-only on purpose. Granting a system privilege is an ALTER ROLE, and one
  of them - CREATE_PRIVILEGED_ROLES - lets its holder grant the rest, so this
  is a window for finding out who can already do what rather than a control
  panel for handing it out. The SQL editor is where a considered ALTER ROLE
  belongs. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Grids, DBGrids, DB, IBDatabase, IBQuery;

type
  TfrmSystemPrivileges = class(TForm)
    pnlTop: TPanel;
    lblConnection: TLabel;
    btnRefresh: TButton;
    splPrivileges: TSplitter;
    pnlRoles: TPanel;
    lblRoles: TLabel;
    grdRoles: TDBGrid;
    pnlPrivileges: TPanel;
    lblPrivileges: TLabel;
    lstPrivileges: TListView;
    stsPrivileges: TStatusBar;
    dsRoles: TDataSource;
    qryRoles: TIBQuery;
    tranPrivileges: TIBTransaction;
    procedure btnRefreshClick(Sender: TObject);
    procedure dsRolesDataChange(Sender: TObject; Field: TField);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FConnectionName: String;
    FSupported: Boolean;
    { The names the server publishes, read once per refresh: type code in the
      object, name as the text. }
    FNames: TStringList;
    procedure SetConnectionName(const Value: String);
    function PrivilegesSupported: Boolean;
    procedure LoadNames;
    procedure ShowPrivilegesFor(const AHexBits: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshData;
    property ConnectionName: String read FConnectionName write SetConnectionName;
    { Public so the harness can read what the window decided without pressing
      anything. }
    property Supported: Boolean read FSupported;
  end;

implementation

{$R *.lfm}

uses MarathonIDE, MarathonProjectCache, SystemPrivileges;

constructor TfrmSystemPrivileges.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNames := TStringList.Create;
end;

destructor TfrmSystemPrivileges.Destroy;
begin
  FNames.Free;
  inherited Destroy;
end;

procedure TfrmSystemPrivileges.SetConnectionName(const Value: String);
var
  Conn: TMarathonCacheConnection;
begin
  FConnectionName := Value;
  Caption := 'System Privileges - ' + Value;
  lblConnection.Caption := 'Connection: ' + Value;

  Conn := CacheConnectionNamed(Value);
  if not Assigned(Conn) then
  begin
    tranPrivileges.DefaultDatabase := nil;
    qryRoles.Database := nil;
    FSupported := False;
    lblConnection.Caption := 'Connection: none';
    stsPrivileges.SimpleText := 'No connection';
    Exit;
  end;

  tranPrivileges.DefaultDatabase := Conn.Connection;
  qryRoles.Database := Conn.Connection;
  qryRoles.Transaction := tranPrivileges;

  FSupported := PrivilegesSupported;
  if not FSupported then
  begin
    { Firebird 4 introduced them. On an older server the column is not there
      and the window says so rather than failing on the query. }
    stsPrivileges.SimpleText :=
      'This server has no system privileges (Firebird 4 or later required)';
    btnRefresh.Enabled := False;
    Exit;
  end;

  RefreshData;
end;

function TfrmSystemPrivileges.PrivilegesSupported: Boolean;
var
  Q: TIBQuery;
  Tr: TIBTransaction;
begin
  Result := False;
  Tr := TIBTransaction.Create(nil);
  Q := TIBQuery.Create(nil);
  try
    Tr.DefaultDatabase := qryRoles.Database;
    Q.Database := qryRoles.Database;
    Q.Transaction := Tr;
    try
      Tr.StartTransaction;
      Q.SQL.Text := SystemPrivilegesSupportedSQL;
      Q.Open;
      Result := (not Q.EOF) and (Q.Fields[0].AsInteger > 0);
      Q.Close;
      Tr.Commit;
    except
      on E: Exception do
      begin
        if Tr.Active then
          Tr.Rollback;
        Result := False;
      end;
    end;
  finally
    Q.Free;
    Tr.Free;
  end;
end;

procedure TfrmSystemPrivileges.LoadNames;
var
  Q: TIBQuery;
begin
  FNames.Clear;
  Q := TIBQuery.Create(nil);
  try
    Q.Database := qryRoles.Database;
    Q.Transaction := tranPrivileges;
    Q.SQL.Text := SystemPrivilegeNamesSQL;
    Q.Open;
    while not Q.EOF do
    begin
      { The type code is the object, the name is the text - so the list is in
        the server's order and carries the server's numbering. }
      FNames.AddObject(Trim(Q.FieldByName('PRIV_NAME').AsString),
        TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure TfrmSystemPrivileges.RefreshData;
begin
  if not FSupported then
    Exit;

  qryRoles.Close;
  if tranPrivileges.Active then
    tranPrivileges.Commit;
  tranPrivileges.StartTransaction;

  LoadNames;
  qryRoles.SQL.Text := RoleSystemPrivilegesSQL;
  qryRoles.Open;

  stsPrivileges.SimpleText := IntToStr(FNames.Count) +
    ' system privileges defined by this server';
  { The grid's own OnDataChange fills the right pane for whichever role the
    dataset lands on. }
  dsRolesDataChange(dsRoles, nil);
end;

procedure TfrmSystemPrivileges.ShowPrivilegesFor(const AHexBits: String);
var
  Idx, Granted: Integer;
  Item: TListItem;
begin
  lstPrivileges.Items.BeginUpdate;
  try
    lstPrivileges.Items.Clear;
    Granted := 0;
    for Idx := 0 to FNames.Count - 1 do
    begin
      Item := lstPrivileges.Items.Add;
      Item.Caption := FNames[Idx];
      if HasSystemPrivilege(AHexBits, PtrInt(FNames.Objects[Idx])) then
      begin
        Item.SubItems.Add('Yes');
        Inc(Granted);
      end
      else
        Item.SubItems.Add('');
    end;
    { Every privilege is listed, granted or not: "what could this role do" is
      only answerable against the whole list, and a list of the granted ones
      alone reads as though the rest do not exist. }
    if FNames.Count > 0 then
      stsPrivileges.SimpleText := IntToStr(Granted) + ' of ' +
        IntToStr(FNames.Count) + ' granted to this role';
  finally
    lstPrivileges.Items.EndUpdate;
  end;
end;

procedure TfrmSystemPrivileges.dsRolesDataChange(Sender: TObject; Field: TField);
begin
  { Only moving between roles, not a single field changing. }
  if Assigned(Field) then
    Exit;
  if not qryRoles.Active or (qryRoles.EOF and qryRoles.BOF) then
  begin
    lstPrivileges.Items.Clear;
    Exit;
  end;
  ShowPrivilegesFor(Trim(qryRoles.FieldByName('PRIV_BITS').AsString));
end;

procedure TfrmSystemPrivileges.btnRefreshClick(Sender: TObject);
begin
  RefreshData;
end;

procedure TfrmSystemPrivileges.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryRoles.Close;
  if tranPrivileges.Active then
    tranPrivileges.Commit;
  Action := caFree;
end;

end.
