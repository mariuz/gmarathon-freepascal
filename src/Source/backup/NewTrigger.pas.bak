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
// $Id: NewTrigger.pas,v 1.3 2005/04/13 16:04:30 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: NewTrigger.pas,v $
Revision 1.3  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit NewTrigger;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls;

type
  TfrmNewTrigger = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label1: TLabel;
    edTriggerName: TEdit;
    Label2: TLabel;
    cmbTables: TComboBox;
    cmbTrigPos: TComboBox;
    Label4: TLabel;
    edPosition: TEdit;
    UpDown1: TUpDown;
    cmbActive: TComboBox;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure edTriggerNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE;

{$R *.DFM}

procedure TfrmNewTrigger.FormCreate(Sender: TObject);
begin
	HelpContext := IDH_New_Trigger_Dialog;
end;

procedure TfrmNewTrigger.btnOKClick(Sender: TObject);
begin
  if edTriggerName.Text = '' then
  begin
    MessageDlg('Trigger must have a name.', mtError, [mbOK], 0);
    Exit;
  end;

  if cmbTables.Text = '' then
  begin
    MessageDlg('Trigger must be attached to a table.', mtError, [mbOK], 0);
    Exit;
  end;

  if cmbTrigPos.Text = '' then
  begin
    MessageDlg('Trigger must be assigned a position.', mtError, [mbOK], 0);
    Exit;
  end;

  ModalResult := mrOK;
end;

procedure TfrmNewTrigger.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_New_Trigger_Dialog);
end;

procedure TfrmNewTrigger.edTriggerNameChange(Sender: TObject);
begin
  CheckNameLength(edTriggerName.Text);
end;

end.


