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
// $Id: FrameDescription.pas,v 1.6 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: FrameDescription.pas,v $
Revision 1.6  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.5  2002/04/29 14:46:11  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.4  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit FrameDescription;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Globals, MarathonProjectCacheTypes, Db, ComCtrls, Clipbrd,
	SynEdit, SynEditTypes,
	SyntaxMemoWithStuff2,
	IBODataset,
	MarathonInternalInterfaces;

type
	TframeDesc = class(TFrame)
		edDoco: TSyntaxMemoWithStuff2;
    qryDoco: TIBOQuery;
		procedure edDocoChange(Sender: TObject);
		procedure edDocoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
		procedure edDocoDragDrop(Sender, Source: TObject; X, Y: Integer);
	private
		FDocoModified: Boolean;
		FForm : IMarathonBaseForm;
		function GetDoco: String;
		procedure SetDoco(const Value: String);
		{ Private declarations }
	public
		{ Public declarations }
		procedure SetActive;
		procedure Init(Form : IMarathonBaseForm);
		property Doco : String read GetDoco write SetDoco;
		property Modified : Boolean read FDocoModified write FDocoModified;
		procedure DoPrint;
		procedure LoadDoco;
		procedure SaveDoco;
		procedure CopyToClipboard;
		procedure CutToClipboard;
		procedure WSFind;
		procedure WSFindNext;
		procedure WSReplace;
		procedure PasteFromClipboard;
		procedure Redo;
		procedure Undo;
		procedure SelectAll;
    procedure CaptureSnippet;
    procedure DoPrintPreview;
    function CanPrint : Boolean;
    function CanCopy : Boolean;
    function CanCut : Boolean;
		function CanFind : Boolean;
		function CanFindNext : Boolean;
		function CanPaste : Boolean;
		function CanRedo : Boolean;
		function CanSelectAll : Boolean;
		function CanUndo : Boolean;
		function CanReplace : Boolean;
		function CanSaveDoco : Boolean;
		function CanCaptureSnippet : Boolean;
	end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

function TframeDesc.GetDoco: String;
begin
	Result := edDoco.Text;
end;

procedure TframeDesc.Init(Form : IMarathonBaseForm);
begin
	FForm := Form;
	SetupNonSyntaxEditor(edDoco);
end;

procedure TframeDesc.LoadDoco;
begin
	try
		qryDoco.BeginBusy(False);
		Screen.Cursor := crHourGlass;
		qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
    qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;
    qryDoco.Close;
    qryDoco.SQL.Clear;
		case FForm.GetActiveObjectType of
			ctDomain:
				qryDoco.SQL.Add('select rdb$field_name, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctSP:
				qryDoco.SQL.Add('select rdb$procedure_name, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctTrigger:
				qryDoco.SQL.Add('select rdb$trigger_name, rdb$description from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctException:
				qryDoco.SQL.Add('select rdb$exception_name, rdb$description from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctTable:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctView:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctUDF:
				qryDoco.SQL.Add('select rdb$function_name, rdb$description from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
		end;
		qryDoco.Open;
		Doco := qryDoco.FieldByName('rdb$description').AsString;
    qryDoco.Close;
    if qryDoco.IB_Transaction.Started then
      qryDoco.IB_Transaction.Commit;
    qryDoco.RequestLive := False;
    edDoco.Modified := False;
    FDocoModified := False;
  finally
    qryDoco.EndBusy;
    Screen.Cursor := crDefault;
	end;
end;

procedure TframeDesc.SaveDoco;
begin
	try
		qryDoco.BeginBusy(False);
		Screen.Cursor := crHourGlass;
		qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
		qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;
		qryDoco.Close;
		qryDoco.RequestLive := True;
		qryDoco.SQL.Clear;
		case FForm.GetActiveObjectType of
			ctDomain:
				qryDoco.SQL.Add('select rdb$field_name, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctSP:
				qryDoco.SQL.Add('select rdb$procedure_name, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctTrigger:
				qryDoco.SQL.Add('select rdb$trigger_name, rdb$description from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctException:
				qryDoco.SQL.Add('select rdb$exception_name, rdb$description from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctTable:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctView:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			ctUDF:
				qryDoco.SQL.Add('select rdb$function_name, rdb$description from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
		end;
    qryDoco.Open;
		if not (qryDoco.BOF and qryDoco.EOF) then
    begin
			qryDoco.Edit;
			qryDoco.FieldByName('rdb$description').AsString := Doco;
			qryDoco.Post;
		end;
		qryDoco.Close;
		if qryDoco.IB_Transaction.Started then
			qryDoco.IB_Transaction.Commit;
		qryDoco.RequestLive := False;
		edDoco.Modified := False;
		FDocoModified := False;
	finally
		qryDoco.EndBusy;
		Screen.Cursor := crDefault;
	end;
end;

procedure TframeDesc.SetDoco(const Value: String);
begin
	edDoco.Text := Value;
end;

procedure TframeDesc.edDocoChange(Sender: TObject);
begin
	if Assigned(FForm) then
	begin
		if Assigned(FForm.GetActiveStatusBar) then
			FDocoModified := UpdateEditorStatusBar(FForm.GetActiveStatusBar, edDoco);
	end;
end;

procedure TframeDesc.edDocoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Assigned(FForm) then
  begin
    SetFocus;
    if edDoco.InsertMode then
    begin
      if Assigned(FForm.GetActiveStatusBar) then
        FForm.GetActiveStatusBar.Panels[2].Text := 'Insert'
    end
    else
    begin
      if Assigned(FForm.GetActiveStatusBar) then
        FForm.GetActiveStatusBar.Panels[2].Text := 'Overwrite'
    end;
    edDoco.CaretXY := TBufferCoord(edDoco.PixelsToRowColumn(X,Y));
    Accept := True;
  end;
end;

procedure TframeDesc.edDocoDragDrop(Sender, Source: TObject; X,	Y: Integer);
var
	Tmp : String;

begin
	if Source is TDragQueen then
		Tmp := TDragQueen(Source).DragText;

	edDoco.SelText := Tmp;
end;

procedure TframeDesc.CopyToClipboard;
begin
	edDoco.CopyToClipboard;
end;

procedure TframeDesc.CutToClipboard;
begin
	edDoco.CutToClipboard;
end;

procedure TframeDesc.WSFind;
begin
  edDoco.WSFind;
end;

procedure TframeDesc.WSFindNext;
begin
  edDoco.WSFindNext;
end;

procedure TframeDesc.PasteFromClipboard;
begin
  edDoco.PasteFromClipboard;
end;

procedure TframeDesc.Redo;
begin
  edDoco.Redo;
end;

procedure TframeDesc.SelectAll;
begin
  edDoco.SelectAll;
end;

procedure TframeDesc.Undo;
begin
  edDoco.Undo;
end;

function TframeDesc.CanCopy: Boolean;
begin
  Result := Length(edDoco.SelText) > 0;
end;

function TframeDesc.CanCut: Boolean;
begin
  Result := Length(edDoco.SelText) > 0;
end;

function TframeDesc.CanFind: Boolean;
begin
  Result := edDoco.Lines.Count > 0;
end;

function TframeDesc.CanFindNext: Boolean;
begin
  Result := edDoco.Lines.Count > 0;
end;

function TframeDesc.CanPaste: Boolean;
begin
  Result := Clipboard.HasFormat(CF_TEXT);
end;

function TframeDesc.CanRedo: Boolean;
begin
	Result := edDoco.CanRedo;
end;

function TframeDesc.CanSelectAll: Boolean;
begin
  Result := edDoco.Lines.Count > 0;
end;

function TframeDesc.CanUndo: Boolean;
begin
  Result := edDoco.CanUndo;
end;

function TframeDesc.CanSaveDoco: Boolean;
begin
  Result := FDocoModified;
end;

function TframeDesc.CanReplace: Boolean;
begin
  Result := edDoco.Lines.Count > 0;
end;

procedure TframeDesc.WSReplace;
begin
  edDoco.WSReplace;
end;

procedure TframeDesc.SetActive;
begin
  try
    edDoco.SetFocus;
  except
    On E : Exception do
    begin

    end;
  end;  
end;

function TframeDesc.CanCaptureSnippet: Boolean;
begin
  Result := Length(edDoco.SelText) > 1;
end;

procedure TframeDesc.CaptureSnippet;
begin

end;

function TframeDesc.CanPrint: Boolean;
begin
  Result := (not FForm.GetObjectNewStatus) and (edDoco.Lines.Count > 0);
end;

procedure TframeDesc.DoPrint;
begin
  MarathonIDEInstance.PrintObjectDoco(False, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

procedure TframeDesc.DoPrintPreview;
begin
  MarathonIDEInstance.PrintObjectDoco(True, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

end.


