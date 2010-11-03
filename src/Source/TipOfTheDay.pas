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
// $Id: TipOfTheDay.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit TipOfTheDay;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
	Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, Registry;

type
  TfrmTipOfTheDay = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    lTitle: TLabel;
    iBulb: TImage;
    lTip: TLabel;
    cbShowTips: TCheckBox;
    bClose: TButton;
    bNext: TButton;
    bPrevious: TButton;
    lbTips: TListBox;
    procedure bClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    TotalTips : Integer;
    procedure GetTip (Next : Boolean);
  public
    { Public declarations }
    CurrentTip : Integer;
  end;

var
  frmTipOfTheDay: TfrmTipOfTheDay;

implementation

uses
	Globals,
	GSSRegistry;

{$R *.DFM}

procedure TfrmTipOfTheDay.GetTip (Next : Boolean);
var
	Tip, Title : String;

begin
	if Next then
		inc(CurrentTip)
	else
    dec(CurrentTip);

  if CurrentTip < 0 then
    CurrentTip := TotalTips - 1
  else
    if CurrentTip > TotalTips - 1 then
      CurrentTip := 0;

  if lbTips.Items.Count >= 1 then
    Tip := lbTips.Items[CurrentTip]
  else
    Tip := '';  

  If Tip <> '' Then
  begin
    case Tip[1] of
      '^'  : Title:='Today''s tip...';
      '?'  : Title:='Did you know...';
      '''' : Title:='Today''s quote...';
      '!'  : Title:='Today''s joke...';
      '#'  : Title:='Today''s message...';
    else
      Title:='';
    end;
    lTitle.Caption:=Title;
    lTip.Caption:= format (Copy(Tip, 2, 255), [#13, #13, #13, #13, #13]);
  end;
end;

procedure TfrmTipOfTheDay.bClick(Sender: TObject);
begin
  GetTip(Sender = bNext);
end;

procedure TfrmTipOfTheDay.FormCreate(Sender: TObject);
var
  R : TRegistry;

begin
  TotalTips := lbTips.Items.Count;

  R := TRegistry.Create;
  try
    with R do
    begin
      if OpenKey(REG_SETTINGS_BASE, True) then
      begin
        if Not ValueExists('CurrentTip') then
          WriteInteger('CurrentTip', 0);

        CurrentTip := ReadInteger('CurrentTip');
        CloseKey;
      end
      else
        CurrentTip := 0;
    end;
  finally
    R.Free;
  end;
  GetTip(True);
end;

procedure TfrmTipOfTheDay.FormClose(Sender: TObject; var Action: TCloseAction);
var
	R : TRegistry;

begin
	TotalTips := lbTips.Items.Count;

	R := TRegistry.Create;
	try
		with R do
		begin
			if OpenKey(REG_SETTINGS_BASE, True) then
			begin
				WriteBool('ShowTips', cbShowTips.Checked);
				gShowTips := cbShowTips.Checked;
				WriteInteger('CurrentTip', CurrentTip);
				CloseKey;
			end
		end;
	finally
		R.Free;
	end;
end;

end.

{
$Log: TipOfTheDay.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
