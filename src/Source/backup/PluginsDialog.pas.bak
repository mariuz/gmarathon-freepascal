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
// $Id: PluginsDialog.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit PluginsDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmPlugins = class(TForm)
    lbPlugins: TListBox;
    btnLoad: TButton;
    btnUnload: TButton;
    btnClose: TButton;
    btnUnloadAll: TButton;
    dlgOpen: TOpenDialog;
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnUnloadAllClick(Sender: TObject);
    procedure btnUnloadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

procedure TfrmPlugins.btnLoadClick(Sender: TObject);
begin
	dlgOpen.InitialDir := ExtractFilePath(Application.ExeName) + 'Plugins';
	if dlgOpen.Execute then
		MarathonIDEInstance.LoadPluginFromFile(dlgOpen.FileName);

	MarathonIDEInstance.RefreshPluginsDialog;
end;

procedure TfrmPlugins.btnCloseClick(Sender: TObject);
begin
	MarathonIDEInstance.SavePluginStates;
	ModalResult := mrOK;
end;

procedure TfrmPlugins.btnUnloadAllClick(Sender: TObject);
begin
	MarathonIDEInstance.UnloadPlugins;
end;

procedure TfrmPlugins.btnUnloadClick(Sender: TObject);
begin
	MarathonIDEInstance.UnloadPluginByName(lbPlugins.Items[lbPlugins.ItemIndex]);
end;

end.

{
$Log: PluginsDialog.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
