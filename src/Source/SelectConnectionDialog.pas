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
// $Id: SelectConnectionDialog.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit SelectConnectionDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls;

type
	TfrmSelectConnection = class(TForm)
		Label1: TLabel;
		cmbConnections: TComboBox;
		btnCancel: TButton;
		btnOK: TButton;
		procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

procedure TfrmSelectConnection.FormCreate(Sender: TObject);
var
  Idx : Integer;

begin
	cmbConnections.Items.Clear;
	cmbConnections.Items.Add('(none)');
	for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
	begin
		cmbConnections.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
	end;
end;

end.

{
$Log: SelectConnectionDialog.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
