unit FrameDescription;

{$MODE Delphi}

interface

uses {$IFDEF FPC} 
  LCLIntf, LCLType, LMessages, {$ELSE} 
  Windows, Messages, {$ENDIF} 
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Globals, MarathonProjectCacheTypes, Db, ComCtrls, Clipbrd, SynEdit, SynEditTypes, SyntaxMemoWithStuff2, SQLDB, IBConnection, MarathonInternalInterfaces, LazUTF8, FileUtil;

type
	TframeDesc = class(TFrame)
		edDoco: TSyntaxMemoWithStuff2;
    qryDoco: TSQLQuery;
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
		function CanUndo : Boolean;
		function CanSelectAll : Boolean;
		function CanCaptureSnippet : Boolean;
	end;

implementation

uses MarathonIDE;

{$R *.lfm}

{ TframeDesc }

procedure TframeDesc.Init(Form: IMarathonBaseForm);
begin
	FForm := Form;
end;

function TframeDesc.GetDoco: String;
begin
	Result := edDoco.Text;
end;

procedure TframeDesc.SetActive;
begin
	try
		SetupNonSyntaxEditor(edDoco);
	except
		// bite my crunker
	end;
	LoadDoco;
end;

procedure TframeDesc.LoadDoco;
begin
	try
		// qryDoco.BeginBusy(False);
		Screen.Cursor := crHourGlass;
		qryDoco.Database := TIBConnection(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection);
		qryDoco.Transaction := TSQLTransaction(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction);
		qryDoco.Close;
		qryDoco.SQL.Clear;
		case FForm.GetActiveObjectType of
			MarathonProjectCacheTypes.ctDomain:
				qryDoco.SQL.Add('select rdb$field_name, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctSP:
				qryDoco.SQL.Add('select rdb$procedure_name, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctTrigger:
				qryDoco.SQL.Add('select rdb$trigger_name, rdb$description from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctException:
				qryDoco.SQL.Add('select rdb$exception_name, rdb$description from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctTable:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctView:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctUDF:
				qryDoco.SQL.Add('select rdb$function_name, rdb$description from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
		end;
		qryDoco.Open;
		SetDoco(qryDoco.FieldByName('rdb$description').AsString);
		qryDoco.Close;
		if qryDoco.Transaction.Active then
			TSQLTransaction(qryDoco.Transaction).Commit;
		// qryDoco.// // // // RequestLive := False;
		edDoco.Modified := False;
		FDocoModified := False;
	finally
		// qryDoco.EndBusy;
		Screen.Cursor := crDefault;
	end;
end;

procedure TframeDesc.SaveDoco;
begin
	try
		// qryDoco.BeginBusy(False);
		Screen.Cursor := crHourGlass;
		qryDoco.Database := TIBConnection(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection);
		qryDoco.Transaction := TSQLTransaction(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction);
		qryDoco.Close;
		// qryDoco.// // // // RequestLive := True;
		qryDoco.SQL.Clear;
		case FForm.GetActiveObjectType of
			MarathonProjectCacheTypes.ctDomain:
				qryDoco.SQL.Add('select rdb$field_name, rdb$description from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctSP:
				qryDoco.SQL.Add('select rdb$procedure_name, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctTrigger:
				qryDoco.SQL.Add('select rdb$trigger_name, rdb$description from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctException:
				qryDoco.SQL.Add('select rdb$exception_name, rdb$description from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctTable:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctView:
				qryDoco.SQL.Add('select rdb$relation_name, rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
			MarathonProjectCacheTypes.ctUDF:
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
		if qryDoco.Transaction.Active then
			TSQLTransaction(qryDoco.Transaction).Commit;
		// qryDoco.// // // // RequestLive := False;
		edDoco.Modified := False;
		FDocoModified := False;
	finally
		// qryDoco.EndBusy;
		Screen.Cursor := crDefault;
	end;
end;

procedure TframeDesc.SetDoco(const Value: String);
begin
	edDoco.Text := Value;
end;

procedure TframeDesc.edDocoChange(Sender: TObject);
begin
	FDocoModified := True;
end;

procedure TframeDesc.edDocoDragOver(Sender, Source: TObject; X, Y: Integer;
	State: TDragState; var Accept: Boolean);
begin
	Accept := False;
	if Source is TMarathonTreeNode then
	begin
		if not edDoco.Focused then
			edDoco.SetFocus;

		edDoco.CaretXY := edDoco.PixelsToRowColumn(Point(X, Y));
		Accept := True;
	end;
end;

procedure TframeDesc.edDocoDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
	if Source is TMarathonTreeNode then
	begin
		edDoco.SelText := TMarathonTreeNode(Source).Text;
	end;
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
  // edDoco.ExecuteFind;
end;

procedure TframeDesc.WSFindNext;
begin
  // edDoco.ExecuteFindNext;
end;

procedure TframeDesc.WSReplace;
begin
  // edDoco.ExecuteReplace;
end;

procedure TframeDesc.PasteFromClipboard;
begin
	edDoco.PasteFromClipboard;
end;

procedure TframeDesc.Redo;
begin
	edDoco.Redo;
end;

procedure TframeDesc.Undo;
begin
	edDoco.Undo;
end;

procedure TframeDesc.SelectAll;
begin
	edDoco.SelectAll;
end;

procedure TframeDesc.CaptureSnippet;
begin
	MarathonIDEInstance.CaptureSnippet(edDoco.SelText);
end;

procedure TframeDesc.DoPrint;
begin
	//
end;

procedure TframeDesc.DoPrintPreview;
begin
	//
end;

function TframeDesc.CanPrint: Boolean;
begin
	Result := edDoco.Lines.Count > 0;
end;

function TframeDesc.CanCopy: Boolean;
begin
	Result := edDoco.SelLength > 0;
end;

function TframeDesc.CanCut: Boolean;
begin
	Result := (not edDoco.ReadOnly) and (edDoco.SelLength > 0);
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
	Result := not edDoco.ReadOnly;
end;

function TframeDesc.CanRedo: Boolean;
begin
	Result := edDoco.CanRedo;
end;

function TframeDesc.CanUndo: Boolean;
begin
	Result := edDoco.CanUndo;
end;

function TframeDesc.CanSelectAll: Boolean;
begin
	Result := edDoco.Lines.Count > 0;
end;

function TframeDesc.CanCaptureSnippet: Boolean;
begin
	Result := Length(edDoco.SelText) > 1;
end;

end.