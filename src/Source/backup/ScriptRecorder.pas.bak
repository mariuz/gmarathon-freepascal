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
// $Id: ScriptRecorder.pas,v 1.3 2005/04/13 16:04:31 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: ScriptRecorder.pas,v $
Revision 1.3  2005/04/13 16:04:31  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit ScriptRecorder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Menus, ComCtrls, Registry, ClipBrd, ExtCtrls,	Buttons, ActnList,
	SynEdit,
	SyntaxMemoWithStuff2,
	MarathonInternalInterfaces;

type
	TfrmScriptRecorder = class(TForm, IMarathonScriptRecorder)
    edScript: TSyntaxMemoWithStuff2;
    pnlBase: TPanel;
    dlgNewScript: TSaveDialog;
    dlgAppend: TOpenDialog;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure edScriptChange(Sender: TObject);
  private
    { Private declarations }
    FScriptName : String;
    FModified : Boolean;
    FHostEditor: IMarathonRecScriptHost;
    FRecording: Boolean;
    procedure UpdateStatus;
  public
    { Public declarations }
    property Recording : Boolean read FRecording write FRecording;
    procedure RecordScript(Scr : String);
    procedure Clear;
    function CanSave : Boolean;
    function CanSaveAs : Boolean;
    function CanStopScriptRecord : Boolean;
    function CanStartScriptRecord : Boolean;
    function CanNewScriptRecord : Boolean;
    function CanAppendExistingScript : Boolean;
    procedure DoSave;
    procedure DoSaveAs;
    procedure DoStopScriptRecord;
    procedure DoStartScriptRecord;
    procedure DoNewScriptRecord;
    procedure DoAppendExistingScript;
    procedure ClearFileName;
    property HostEditor : IMarathonRecScriptHost read FHostEditor write FHostEditor;
  end;

implementation

{$R *.DFM}

uses
	Globals,
	HelpMap;

procedure TfrmScriptRecorder.FormCreate(Sender: TObject);
begin
	edScript.Clear;
	SetupSyntaxEditor(edScript);
end;

procedure TfrmScriptRecorder.edScriptChange(Sender: TObject);
begin
  if Assigned(FHostEditor) then
    FModified := UpdateEditorStatusBar(TStatusBar(FHostEditor.GetStatusBar), edScript);
end;

procedure TfrmScriptRecorder.Clear;
begin
  edScript.Lines.Clear;
end;

procedure TfrmScriptRecorder.RecordScript(Scr: String);
var
  F : TextFile;

begin
  AssignFile(F, FScriptName);
  Append(F);
  WriteLn(F, '');
  WriteLn(F, '/*============================================================================*/');
  Scr := Trim(Scr);
  if Length(Scr) > 0 then
  begin
    if not (Scr[Length(Scr)] = ';') then
      Scr := Scr + ';';
  end;
  Writeln(F, Scr);
	WriteLn(F, '/*============================================================================*/');
  CloseFile(F);
  edScript.Lines.LoadFromFile(FScriptName);
  FModified := False;
end;

function TfrmScriptRecorder.CanAppendExistingScript: Boolean;
begin
  Result := not FRecording;
end;

function TfrmScriptRecorder.CanNewScriptRecord: Boolean;
begin
  Result := not FRecording;
end;

function TfrmScriptRecorder.CanStartScriptRecord: Boolean;
begin
  Result := (FScriptName <> '') and (not FRecording);
end;

function TfrmScriptRecorder.CanStopScriptRecord: Boolean;
begin
  Result := (FScriptName <> '') and  FRecording;
end;

function TfrmScriptRecorder.CanSave: Boolean;
begin
  Result := (FScriptName <> '') and  FModified;
end;

function TfrmScriptRecorder.CanSaveAs: Boolean;
begin
  Result := True;
end;

procedure TfrmScriptRecorder.DoAppendExistingScript;
begin
  if dlgAppend.Execute then
  begin
    FScriptName := dlgAppend.FileName;
    edScript.Lines.LoadFromFile(FScriptName);
    FModified := False;
  end;
  UpdateStatus;
end;

procedure TfrmScriptRecorder.DoNewScriptRecord;
var
  A : TextFile;

begin
  if dlgNewScript.Execute then
  begin
    FScriptName := dlgNewScript.FileName;
    try
      AssignFile(A, FScriptName);
      ReWrite(A);
      WriteLn(A, '/*============================================================================*/');
      WriteLn(A, '/*   Script File                                                              */');
      WriteLn(A, '/*                                                                            */');
      WriteLn(A, '/*   Date    : ' + FormatDateTime('dd-mmm-yyyy', Now) + '                                                    */');
      WriteLn(A, '/*============================================================================*/');
      Writeln(A, '');
      Writeln(A, '');
      WriteLn(A, '/*============================================================================*/');
      Writeln(A, '');
      CloseFile(A);
      edScript.Lines.LoadFromFile(FScriptName);
      FModified := False;
    except
      On E : Exception do
      begin
        MessageDlg(E.Message, mtError, [mbOK], 0);
      end;
    end;
  end;
  UpdateStatus;
end;

procedure TfrmScriptRecorder.DoSave;
begin
  edScript.Lines.SaveToFile(FScriptName);
  FModified := False;
end;

procedure TfrmScriptRecorder.DoSaveAs;
begin
  if dlgSave.Execute then
	begin
    FScriptName := dlgSave.FileName;
    edScript.Lines.SaveToFile(FScriptName);
    FModified := False;
  end;
end;

procedure TfrmScriptRecorder.DoStartScriptRecord;
begin
  FRecording := True;
  UpdateStatus;
end;

procedure TfrmScriptRecorder.DoStopScriptRecord;
begin
  FRecording := False;
  UpdateStatus;
end;

procedure TfrmScriptRecorder.UpdateStatus;
begin
  if Assigned(FHostEditor) then
  begin
    if FScriptName = '' then
      TStatusBar(FHostEditor.GetStatusBar).Panels[3].Text := '[No Script]'
    else
      TStatusBar(FHostEditor.GetStatusBar).Panels[3].Text := FScriptName;
    if FRecording then
      TStatusBar(FHostEditor.GetStatusBar).Panels[1].Text := 'Recording'
    else
      TStatusBar(FHostEditor.GetStatusBar).Panels[1].Text := 'Not Recording'
  end;
end;

procedure TfrmScriptRecorder.ClearFileName;
begin
  FScriptName := '';
end;

end.


