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
// $Id: SyntaxHelp.pas,v 1.4 2006/10/22 06:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: SyntaxHelp.pas,v $
Revision 1.4  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.3  2005/04/13 16:04:31  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}


unit SyntaxHelp;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls, Menus, Registry;

type
	TfrmSyntaxHelp = class(TForm)
		Panel1: TPanel;
		Panel2: TPanel;
		Splitter1: TSplitter;
		memSyntaxHelp: TMemo;
		tvSyntaxHelp: TTreeView;
		PopupMenu1: TPopupMenu;
		StayOnTop1: TMenuItem;
		N1: TMenuItem;
		Close1: TMenuItem;
		procedure Close1Click(Sender: TObject);
		procedure StayOnTop1Click(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure tvSyntaxHelpChange(Sender: TObject; Node: TTreeNode);
		procedure tvSyntaxHelpGetImageIndex(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
	frmSyntaxHelp: TfrmSyntaxHelp;

implementation

uses
	Globals,
	HelpMap,
	GSSRegistry,
  MarathonIDE{,
	MarathonMain};

{$R *.DFM}

procedure TfrmSyntaxHelp.Close1Click(Sender: TObject);
begin
	Close;
end;

procedure TfrmSyntaxHelp.StayOnTop1Click(Sender: TObject);
begin
  if FormStyle = fsStayOnTop then
  begin
    StayOnTop1.Checked := False;
    FormStyle := fsNormal;
  end
  else
  begin
    StayOnTop1.Checked := True;
    FormStyle := fsStayOnTop;
  end;
end;

procedure TfrmSyntaxHelp.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  I : TRegistry;

begin
  I := TRegistry.Create;
  try
    With I Do
    begin
      if OpenKey(REG_SETTINGS_SYNHELP, True) then
      begin
        WriteInteger('Left', Left);
        WriteInteger('Width', Width);
        WriteInteger('Top', Top);
        WriteInteger('Height', Height);
        if FormStyle = fsStayOnTop then
          WriteBool('OnTop', True)
        else
          WriteBool('OnTop', False);
        WriteInteger('SplitterPos', Panel1.Height);

        CloseKey;
      end;
    end;
  finally
    I.Free;
  end;

  Action := caFree;
end;

procedure TfrmSyntaxHelp.FormCreate(Sender: TObject);
var
  I : TRegistry;
//  P : PNodeData;
  SQLRef, FuncRef, N : TTreeNode;
  S : TStringList;
  Idx : Integer;
  Tmp, NodeCaption, NodeText : String;

begin
  I := TRegistry.Create;
  try
    With I do
    begin
      if OpenKey(REG_SETTINGS_SYNHELP, True) then
      begin
        if Not ValueExists('Left') then
          WriteInteger('Left', MarathonScreen.Left + MarathonScreen.Width - Width);

        if Not ValueExists('Width') then
          WriteInteger('Width', Width);

        if Not ValueExists('Top') then
          WriteInteger('Top', MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2);

        if Not ValueExists('Height') then
          WriteInteger('Height', Height);

        if Not ValueExists('OnTop') then
          WriteBool('OnTop', True);

        if Not ValueExists('SplitterPos') then
          WriteInteger('SplitterPos', Trunc(Height div 2));

        Left := ReadInteger('Left');
        Width := ReadInteger('Width');
        Top := ReadInteger('Top');
        Height := ReadInteger('Height');
        Panel1.Height := ReadInteger('SplitterPos');

        if ReadBool('OnTop') then
        begin
          FormStyle := fsStayOnTop;
          StayOnTop1.Checked := True;
        end
        else
        begin
          FormStyle := fsNormal;
          StayOnTop1.Checked := False;
        end;

        CloseKey;
      end;
    end;
  finally
    I.Free;
  end;

  //load data...
  try
    S := TStringList.Create;
    try
      try
        S.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sqlref.dta');
      except
        On E : Exception do
        begin
          MessageDlg('Unable to open the SQL Reference data file.', mtError, [mbOK], 0);
        end;
      end;
      if S.Count > 0 then
      begin
        SQLRef := tvSyntaxHelp.Items.AddChild(nil, 'SQL Syntax');
       { New(P);
        P^.Caption := 'SQL Syntax';
        P^.NodeText := '';
        P^.ImageIndex := 1;
        SQLRef.Data := P;
}
        for Idx := 0 to S.Count - 1 do
        begin
          Tmp := S[Idx];
          if Copy(Tmp, 1, 3) = '===' then
          begin
            NodeCaption := Copy(Tmp, 4, 1024);
            NodeText := '';
          end
          else
          begin
            if Copy(Tmp, 1, 3) = '---' then
            begin
//              N := tvSyntaxHelp.Items.AddChild(SQLRef, NodeCaption); //removed to clear compiler warning. RJM
{              New(P);
              P^.Caption := NodeCaption;
              P^.NodeText := NodeText;
              P^.ImageIndex := 10;
              N.Data := P;}
            end
            else
            begin
              NodeText := NodeText + Tmp + #13#10;
            end;
          end;
        end;
      end;
    finally
      S.Free;
    end;

    S := TStringList.Create;
    try
      try
        S.LoadFromFile(ExtractFilePath(Application.ExeName) + 'fnref.dta');
      except
        On E : Exception do
        begin
          MessageDlg('Unable to open the SQL Reference data file.', mtError, [mbOK], 0);
        end;
      end;
      if S.Count > 0 then
      begin
        FuncRef := tvSyntaxHelp.Items.AddChild(nil, 'Function Syntax');
        FuncRef.ImageIndex := 10;
{        New(P);
        P^.Caption := 'Function Syntax';
        P^.NodeText := '';
				P^.ImageIndex := 1;
        FuncRef.Data := P;}
        for Idx := 0 to S.Count - 1 do
        begin
          Tmp := S[Idx];
          if Copy(Tmp, 1, 3) = '===' then
          begin
            NodeCaption := Copy(Tmp, 4, 1024);
            NodeText := '';
          end
          else
          begin
            if Copy(Tmp, 1, 3) = '---' then
            begin
//              N := tvSyntaxHelp.Items.AddChild(FuncRef, NodeCaption);  //removed to clear compiler warning. RJM
              {New(P);
              P^.Caption := NodeCaption;
              P^.NodeText := NodeText;
              P^.ImageIndex := 10;
              N.Data := P;}
            end
            else
            begin
              NodeText := NodeText + Tmp + #13#10;
            end;
          end;
        end;
      end;
    finally
      S.Free;
    end;
  except
    On E : Exception do
    begin
      MessageDlg('Unexpexcted Error: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmSyntaxHelp.tvSyntaxHelpChange(Sender: TObject; Node: TTreeNode);
begin
	if Node <> nil then
	begin
{    if Node.Data <> nil then
//      memSyntaxHelp.Text := TNodeData(Node.Data^).NodeText
		else
			memSyntaxHelp.Text := '';}
	end;
end;

procedure TfrmSyntaxHelp.tvSyntaxHelpGetImageIndex(Sender: TObject;	Node: TTreeNode);
begin
//  Node.ImageIndex := TNodeData(Node.Data^).ImageIndex;
//  Node.SelectedIndex := TNodeData(Node.Data^).ImageIndex;
end;

end.


