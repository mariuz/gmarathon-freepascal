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
// $Id: ReorderColumns.pas,v 1.4 2006/10/22 06:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: ReorderColumns.pas,v $
Revision 1.4  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.3  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit ReorderColumns;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls,
	rmCornerGrip;

type
  TfrmReorderColumns = class(TForm)
    lvColumns: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label1: TLabel;
    rmCornerGrip1: TrmCornerGrip;
		procedure lvColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure lvColumnsDragOver(Sender, Source: TObject; X, Y: Integer;	State: TDragState; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
	end;


implementation

{$R *.DFM}

uses
	Globals,
	HelpMap{,
	MarathonMain};

procedure TfrmReorderColumns.lvColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
	Item : TListItem;
	Cap : String;

begin
	Item := lvColumns.GetItemAt(X, Y);
	if Item <> nil then
	begin
    if Item <> lvColumns.Selected then
    begin
      lvColumns.Items.BeginUpdate;
      try
        Cap := lvColumns.Selected.Caption;
        with lvColumns.Items.Insert(Item.Index) do
        begin
          Caption := Cap;
          ImageIndex := 6;
        end;
        lvColumns.Selected.Delete;
      finally
        lvColumns.Items.EndUpdate;
      end;    
    end;
  end;
end;

procedure TfrmReorderColumns.lvColumnsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item : TListItem;
  ItemHeight : Integer;

begin
  if lvColumns.Items.Count > 1 then
  begin
    ItemHeight := lvColumns.Items.Item[1].Position.Y - lvColumns.Items.Item[0].Position.Y;
  end
  else
    ItemHeight := 0;

  Item := lvColumns.GetItemAt(X, Y);
  if Item <> nil then
  begin
    if Item <> lvColumns.Selected then
      Accept := True
    else
      Accept := False;
  end
  else
    Accept := False;

  if Accept and (ItemHeight > 0) then
  begin
    if (Y < 6) and (lvColumns.TopItem.Index > 0) then
    begin
      //scroll upwards..
      lvColumns.Scroll(0, -ItemHeight);
      lvColumns.Refresh;
    end
    else
    begin
      if (Y >= (lvColumns.ClientHeight - 6)) and ((lvColumns.TopItem.Index + lvColumns.ClientHeight div ItemHeight) <= lvColumns.Items.Count) then
      begin
        //scroll downwards..
        lvColumns.Scroll(0, ItemHeight);
        lvColumns.Refresh;
			end;
    end;
  end;
end;

procedure TfrmReorderColumns.FormCreate(Sender: TObject);
begin
  //load size...
  LoadFormPosition(Self);
  HelpContext := IDH_ReOrder_Columns;
end;

procedure TfrmReorderColumns.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
	//save size...
	SaveFormPosition(Self);
end;

procedure TfrmReorderColumns.btnHelpClick(Sender: TObject);
begin
	Application.HelpCommand(HELP_CONTEXT, IDH_ReOrder_Columns);
end;

end.


