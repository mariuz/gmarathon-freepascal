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
// $Id: WindowList.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit WindowList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, ImgList,
	rmCornerGrip;

type
  TfrmWindowList = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lvWindows: TListView;
    ilWindows: TImageList;
    rmCornerGrip1: TrmCornerGrip;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses
	Globals,
	HelpMap,
	MarathonMain;

{$R *.DFM}

procedure TfrmWindowList.FormCreate(Sender: TObject);
var
	idx : Integer;
	It : TListItem;
	B : TBitmap;

begin
	//load the tree images from the resources...
	LoadFormPosition(Self);

	ilWindows.Clear;
	B := TBitmap.Create;
	try
    B.LoadFromResourceName(hInstance, 'WINDOW_LIST_STRIP');
    ilWindows.AddMasked(B, B.TransparentColor);
  finally
    B.Free;
  end;

  HelpContext := IDH_Window_List_Dialog;
  for idx := 0 to Screen.FormCount - 1 do
  begin
    if not (Screen.Forms[idx] is TfrmMarathonMain) then
    begin
      if not (Screen.Forms[idx] is TfrmWindowList) then
      begin
        It := lvWindows.Items.Add;
        It.Caption := Screen.Forms[idx].Caption;
      end;
    end;
  end;
end;

procedure TfrmWindowList.btnOKClick(Sender: TObject);
begin
  if lvWindows.Selected <> nil then
    ModalResult := mrOK
  else
  begin
    MessageDlg('You must select a window.', mtError, [mbOK], 0);
  end;
end;

procedure TfrmWindowList.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_Window_List_Dialog);
end;

procedure TfrmWindowList.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
	SaveFormPosition(Self);
end;

end.

{
$Log: WindowList.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
