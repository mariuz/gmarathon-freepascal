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
// $Id: FrameMetadata.pas,v 1.4 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: FrameMetadata.pas,v $
Revision 1.4  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.3  2002/04/29 11:43:41  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit FrameMetadata;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Globals, Db, ComCtrls, ComObj, Clipbrd,
	IBODataset, 
	SynEdit,
	SyntaxMemoWithStuff2,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes,
	gssscript_TLB;

type
	TframDisplayDDL = class(TFrame)
		edDDL: TSyntaxMemoWithStuff2;
    qryUtil: TIBOQuery;
		procedure edDDLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
	private
		FForm : IMarathonBaseForm;
		{ Private declarations }
	public
		{ Public declarations }
		procedure SetActive;
		procedure Init(Form : IMarathonBaseForm);
		procedure GetDDL;
		procedure CopyToClipboard;
		procedure WSFind;
		procedure WSFindNext;
		procedure SelectAll;
		procedure DoPrint;
		procedure DoPrintPreview;
		procedure CaptureSnippet;
		function CanCopy : Boolean;
		function CanFind : Boolean;
		function CanFindNext : Boolean;
		function CanSelectAll : Boolean;
		function CanCaptureSnippet : Boolean;
		function CanPrint : Boolean;
	end;

implementation

uses
	MarathonIDE;

const
	ddlDomain         = 0;
	ddlTable          = 1;
	ddlView           = 2;
	ddlTableData      = 3;
	ddlGenerator      = 4;
	ddlException      = 5;
	ddlUDF            = 6;
	ddlStoredProc     = 7;
	ddlTrigger        = 8;

	ddlstNone         = 0;
	ddlstPrimaryKey   = 1;
	ddlstForeignKey   = 2;
	ddlstIndex        = 3;
	ddlstGenerator    = 4;
	ddlstGeneratorVal = 5;
	ddlstProc         = 6;
	ddlstGrants       = 7;

{$R *.DFM}

procedure TframDisplayDDL.Init(Form : IMarathonBaseForm);
begin
	FForm := Form;
	SetupSyntaxEditor(edDDL);
end;

procedure TframDisplayDDL.CopyToClipboard;
begin
	edDDL.CopyToClipboard;
end;

procedure TframDisplayDDL.WSFind;
begin
  edDDL.WSFind;
end;

procedure TframDisplayDDL.WSFindNext;
begin
  edDDL.WSFindNext;
end;

procedure TframDisplayDDL.SelectAll;
begin
  edDDL.SelectAll;
end;

function TframDisplayDDL.CanCopy: Boolean;
begin
  Result := Length(edDDL.SelText) > 0;
end;

function TframDisplayDDL.CanFind: Boolean;
begin
  Result := edDDL.Lines.Count > 0;
end;

function TframDisplayDDL.CanFindNext: Boolean;
begin
  Result := edDDL.Lines.Count > 0;
end;

function TframDisplayDDL.CanSelectAll: Boolean;
begin
  Result := edDDL.Lines.Count > 0;
end;

procedure TframDisplayDDL.SetActive;
begin
  edDDL.SetFocus;
end;

procedure TframDisplayDDL.GetDDL;
var
  Extractor : IGSSDDLExtractor;
  TriggerList : TStringList;
  Idx : Integer;

begin
  case FForm.GetActiveObjectType of
    ctDomain:
      begin
				Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
        Extractor.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;
        Extractor.DatabaseHandle := Integer(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection.dbHandle);
        Extractor.IB6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
        edDDL.Text := Extractor.Extract(ddlDomain, ddlstNone, FForm.GetObjectName);
			end;
    ctTable:
      begin
        Screen.Cursor := crHourGlass;
        try
          Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
          Extractor.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;
          Extractor.DatabaseHandle := Integer(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection.dbHandle);
          Extractor.IB6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
          edDDL.Text := Extractor.Extract(ddlTable, ddlstNone, FForm.GetObjectName);
          edDDL.Lines.Add('');
          edDDL.Lines.Add('');
					edDDL.Lines.Add('/* Primary Key */');
          edDDL.Lines.Add('');
          edDDL.Text := edDDL.Text + Extractor.Extract(ddlTable, ddlstPrimaryKey, FForm.GetObjectName);
          edDDL.Lines.Add('');
          edDDL.Lines.Add('');
          edDDL.Lines.Add('/* Foreign Key */');
          edDDL.Lines.Add('');
          edDDL.Text := edDDL.Text + Extractor.Extract(ddlTable, ddlstForeignKey, FForm.GetObjectName);
          edDDL.Lines.Add('');
          edDDL.Lines.Add('');
          edDDL.Lines.Add('/* Indexes */');
          edDDL.Lines.Add('');
          edDDL.Text := edDDL.Text + Extractor.Extract(ddlTable, ddlstIndex, FForm.GetObjectName);

					TriggerList := TStringList.Create;
          try
            try
              qryUtil.BeginBusy(False);
              qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
              qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;
              qryUtil.SQL.Clear;
              qryUtil.SQL.Add('select rdb$trigger_name, rdb$trigger_type from rdb$triggers where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ' and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints);');
              qryUtil.Open;
              While not qryUtil.EOF do
              begin
                TriggerList.Add(qryUtil.FieldByName('rdb$trigger_name').AsString);
                qryUtil.Next;
							end;
              qryUtil.Close;
              qryUtil.IB_Transaction.Commit;
            finally
              qryUtil.EndBusy;
            end;

            if TriggerList.Count > 0 then
            begin
              edDDL.Lines.Add('');
              edDDL.Lines.Add('');
              edDDL.Lines.Add('/* Triggers */');
							edDDL.Lines.Add('');
              for Idx := 0 to TriggerList.Count - 1 do
              begin
                edDDL.Text := edDDL.Text + Extractor.Extract(ddlTrigger, ddlstNone, TriggerList[Idx]);
                edDDL.Lines.Add('');
                edDDL.Lines.Add('');
                edDDL.Lines.Add('');
              end;
            end;
          finally
            TriggerList.Free;
          end;
          edDDL.Lines.Add('');
          edDDL.Lines.Add('');
					edDDL.Lines.Add('/* Grants */');
          edDDL.Lines.Add('');
          edDDL.Text := edDDL.Text + Extractor.Extract(ddlTable, ddlstGrants, FForm.GetObjectName);
        finally
          Screen.Cursor := crDefault;
        end;    
      end;
    ctGenerator:
      begin
        Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
        Extractor.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;
        Extractor.DatabaseHandle := Integer(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection.dbHandle);
        Extractor.IB6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
				edDDL.Text := Extractor.Extract(ddlGenerator, ddlstNone, FForm.GetObjectName);
      end;
    ctException:
      begin
        Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
        Extractor.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;
        Extractor.DatabaseHandle := Integer(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection.dbHandle);
        Extractor.IB6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
        edDDL.Text := Extractor.Extract(ddlException, ddlstNone, FForm.GetObjectName);
      end;
    ctUDF:
      begin
				Extractor := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
        Extractor.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;
        Extractor.DatabaseHandle := Integer(MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection.dbHandle);
        Extractor.IB6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
        edDDL.Text := Extractor.Extract(ddlUDF, ddlstNone, FForm.GetObjectName);
      end;

  end;
end;

function TframDisplayDDL.CanCaptureSnippet: Boolean;
begin
  Result := Length(edDDL.SelText) > 1;
end;

procedure TframDisplayDDL.CaptureSnippet;
begin

end;

function TframDisplayDDL.CanPrint: Boolean;
begin
  Result := (not FForm.GetObjectNewStatus) and (edDDL.Lines.Count > 0);
end;

procedure TframDisplayDDL.DoPrint;
begin
	MarathonIDEInstance.PrintObjectDDL(False, FForm.GetObjectName, FForm.GetObjectName, FForm.GetActiveObjectType);
end;

procedure TframDisplayDDL.DoPrintPreview;
begin
  MarathonIDEInstance.PrintObjectDDL(True, FForm.GetObjectName, FForm.GetObjectName, FForm.GetActiveObjectType);
end;

procedure TframDisplayDDL.edDDLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl]) and ((Key = Ord('c')) or (Key = Ord('C'))) then
	begin
		if Length(edDDL.SelText) > 0 then
		begin
			CopyToClipboard;
		end;
	end;
end;

end.


