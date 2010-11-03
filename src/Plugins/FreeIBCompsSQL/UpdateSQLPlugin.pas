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
// $Id: UpdateSQLPlugin.pas,v 1.2 2002/04/25 07:17:03 tmuetze Exp $

unit UpdateSQLPlugin;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Dialogs,
  Forms,
  Controls,
  GimbalToolsAPI,
  FreeIBCompsSQL;

type
	TUpdateSQLCommandNotifier = class(TInterfacedObject, IGimbalIDECommandNotifier)
	private

	public
		procedure OnExecute; safecall;
		function OnUpdateEnabled : Boolean; safecall;
		function OnUpdateChecked : Boolean; safecall;
	end;

var
  //boilerplate...
  OldApplicationHandle : THandle;
  LocalToolServices : IGimbalIDEServices;
  ThisPluginIndex : Integer;

  // for this plugin
  UpdateSQL : IGimbalIDECommand;
  UpdateSQLNotifier : IGimbalIDECommandNotifier;

procedure GimbalPluginInit(const ToolServices : IGimbalIDEServices; var ThisPlugin : TPlugin); stdcall;
procedure GimbalPluginExecute; stdcall;

implementation

procedure AddCommands;
begin
  UpdateSQL := LocalToolServices.IDEAddCommand(ThisPluginIndex, 'UpdateSQL');
  UpdateSQL.IDECaption := '&Create SQL for FreeIB/IBExpress...';
  UpdateSQLNotifier := TUpdateSQLCommandNotifier.Create;
  UpdateSQL.IDECommandNotifier := UpdateSQLNotifier;
end;

procedure AddMenus;
var
  Menus : IGimbalIDEMenus;
  Item : IGimbalIDEMenuItem;
  ItemTwo : IGimbalIDEMenuItem;
  Tools : IGimbalIDEMenuItem;
  Idx : Integer;
  Idy : Integer;
  Found : Boolean;
  Position : Integer;

begin
  //add the item to the main menu...
  Menus := LocalToolServices.IDEGetMenu(mtMain);
  for Idx := 0 to Menus.IDEMenuCount - 1 do
	begin
    Item := Menus.IDEMenuItem(Idx);
    If AnsiLowerCase(Item.IDEName) = '&object' then
    begin
      Found := False;
      for Idy := 0 to Item.IDEMenuCount - 1 do
      begin
        ItemTwo := Item.IDEMenuItem(Idy);
        If AnsiLowerCase(ItemTwo.IDEName) = '&tools' then
        begin
          Tools := ItemTwo;
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        if Item.IDEMenuCount > 1 then
          Position := Item.IDEMenuCount
        else
          Position := 0;
        Tools := Item.IDEAddMenuItem(ThisPluginIndex, Position, 'ToolsSub1', '&Tools', True, nil);
      end;
      Tools.IDEAddMenuItem(ThisPluginIndex, 0, 'UpdateSQLMenuOne', '', False, UpdateSQL);
      Break;
    end;
  end;

  //add the item to the browser menu...
  Menus := LocalToolServices.IDEGetMenu(mtBrowser);
  Found := False;
  for Idx := 0 to Menus.IDEMenuCount - 1 do
  begin
    Item := Menus.IDEMenuItem(Idx);
    If AnsiLowerCase(Item.IDEName) = '&tools' then
    begin
      Found := True;
      Tools := Item;
      Break;
		end;
  end;

  if not Found then
  begin
    if Menus.IDEMenuCount > 1 then
      Position := Menus.IDEMenuCount - 2
    else
      Position := 0;
    Tools := Menus.IDEAddMenuItem(ThisPluginIndex, Position, 'ToolsSub2', '&Tools', True, nil);
  end;
  Tools.IDEAddMenuItem(ThisPluginIndex, 0, 'UpdateSQLMenuOne2', '', False, UpdateSQL);

  //add the item to the table popup menu...
  Menus := LocalToolServices.IDEGetMenu(mtTableEditor);
  Found := False;
  for Idx := 0 to Menus.IDEMenuCount - 1 do
  begin
    Item := Menus.IDEMenuItem(Idx);
    If AnsiLowerCase(Item.IDEName) = '&tools' then
    begin
      Found := True;
      Tools := Item;
      Break;
    end;
  end;

  if not Found then
  begin
    if Menus.IDEMenuCount > 1 then
      Position := Menus.IDEMenuCount
    else
      Position := 0;
    Tools := Menus.IDEAddMenuItem(ThisPluginIndex, Position, 'ToolsSub3', '&Tools', True, nil);
  end;
  Tools.IDEAddMenuItem(ThisPluginIndex, 0, 'UpdateSQLMenuOne3', '', False, UpdateSQL);
end;

procedure AddNotifiers;
begin
  //none for this plugin...
end;


procedure GimbalPluginInit(const ToolServices : IGimbalIDEServices; var ThisPlugin : TPlugin); stdcall;
begin
  LocalToolServices := ToolServices;
  ThisPlugin.Name := 'Generate SQL for FreeIB/IBExpress';
  ThisPluginIndex := ThisPlugin.Index;
end;

procedure GimbalPluginExecute; stdcall;
begin
  OldApplicationHandle := Application.Handle;
  Application.Handle := LocalToolServices.IDEApplicationHandle;

  AddCommands;
  AddMenus;
  AddNotifiers;
end;

{ TUpdateSQLCommandNotifier }

procedure TUpdateSQLCommandNotifier.OnExecute;
var
  W : IGimbalIDEWindow;
  Browser : IGimbalIDEBrowserWindow;
  TableEditor : IGimbalIDETableEditorWindow;
  Items : IGimbalIDESelectedItems;
  F : TfrmFreeIBComponentsSQL;

begin
  W := LocalToolServices.IDEGetActiveWindow;
  if Assigned(W) then
  begin
    if W.QueryInterface(IGimbalIDEBrowserWindow, Browser) = S_OK then
    begin
      Items := Browser.IDESelectedItems;
			if Assigned(Items) then
      begin
        if Items.IDECount = 1 then
        begin
          if Items.IDEGetItem(0).IDEItemType = ctIDETable then
          begin
            F := TfrmFreeIBComponentsSQL.Create(nil);
            try
              F.ConnectionName := Items.IDEGetItem(0).IDEConnectionName;
              F.TableName := Items.IDEGetItem(0).IDEName;
              F.Init;
              F.ShowModal;
            finally
              F.Free;
            end;
          end;
        end;
      end;
    end
    else
    begin
      if W.QueryInterface(IGimbalIDETableEditorWindow, TableEditor) = S_OK then
      begin
        if TableEditor.IDEActivePage = pgColumns then
        begin
          Items := TableEditor.IDESelectedItems;
          if Assigned(Items) then
          begin
            if Items.IDECount = 1 then
            begin
              if Items.IDEGetItem(0).IDEItemType = ctIDETable then
              begin
                F := TfrmFreeIBComponentsSQL.Create(nil);
                try
                  F.ConnectionName := Items.IDEGetItem(0).IDEConnectionName;
                  F.TableName := Items.IDEGetItem(0).IDEName;
                  F.Init;
                  F.ShowModal;
                finally
									F.Free;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TUpdateSQLCommandNotifier.OnUpdateChecked: Boolean;
begin
  Result := False;
end;

function TUpdateSQLCommandNotifier.OnUpdateEnabled : Boolean;
var
  W : IGimbalIDEWindow;
  Browser : IGimbalIDEBrowserWindow;
  TableEditor : IGimbalIDETableEditorWindow;
  Items : IGimbalIDESelectedItems;

begin
  W := LocalToolServices.IDEGetActiveWindow;
  if Assigned(W) then
  begin
    if W.QueryInterface(IGimbalIDEBrowserWindow, Browser) = S_OK then
    begin
      Items := Browser.IDESelectedItems;
      if Assigned(Items) then
      begin
        if Items.IDECount = 1 then
        begin
          if Items.IDEGetItem(0).IDEItemType = ctIDETable then
            Result := True
          else
            Result := False;
        end
				else
          Result := False;
      end
      else
        Result := False;
    end
    else
    begin
      if W.QueryInterface(IGimbalIDETableEditorWindow, TableEditor) = S_OK then
      begin
        Result := TableEditor.IDEActivePage = pgColumns;
      end
      else
        Result := False;
    end;
  end
  else
    Result := False;
end;

end.

{
$Log: UpdateSQLPlugin.pas,v $
Revision 1.2  2002/04/25 07:17:03  tmuetze
New CVS powered comment block

}
