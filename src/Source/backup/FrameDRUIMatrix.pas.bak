{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************}
// $Id: FrameDRUIMatrix.pas,v 1.4 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: FrameDRUIMatrix.pas,v $
Revision 1.4  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.3  2002/05/29 09:28:04  tmuetze
Revised a bit

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit FrameDRUIMatrix;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Db, ComCtrls, StdCtrls, ExtCtrls,
	rmPathTreeView,
	rmMemoryDataSet,
	MarathonInternalInterfaces;

type
	TframeDRUI = class(TFrame)
		dtaCrud: TrmMemoryDataSet;
		dtaCrudline: TIntegerField;
		dtaCrudop: TStringField;
		dtaCrudtable: TStringField;
		dsCrud: TDataSource;
		Panel1: TPanel;
		Label1: TLabel;
		cmbGroup: TComboBox;
		tvCrud: TrmPathTreeView;
		procedure cmbGroupChange(Sender: TObject);
	private
		{ Private declarations }
		FForm: IMarathonBaseForm;
		procedure RefreshGroupings;
	public
		{ Public declarations }
		procedure SetActive;
		procedure Init(Form: IMarathonBaseForm);
		procedure CalcMatrix(Source: String);
		function CanPrint: Boolean;
		procedure DoPrint;
		procedure DoPrintPreview;
	end;

implementation

{$R *.DFM}

uses
	SQLYacc,
	MarathonIDE;

{ TframeDRUI }

procedure TframeDRUI.CalcMatrix(Source : String);
var
	M: TSQLParser;
	Idx, Idy: Integer;

begin
	dtaCrud.Active := False;
	dtaCrud.FieldRoster.Clear;
	with dtaCrud.FieldRoster.Add do
	begin
		Name := 'line';
		Size := 0;
		FieldType := fdtInteger;
	end;
	with dtaCrud.FieldRoster.Add do
	begin
		Name := 'op';
		Size := 40;
		FieldType := fdtString;
	end;
	with dtaCrud.FieldRoster.Add do
	begin
		Name := 'table';
		Size := 120;
		FieldType := fdtString;
	end;
	dtaCrud.Active := True;

	M := TSQLParser.Create(Self);
	try
		M.ParserType := ptDRUI;
		M.Lexer.IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
		M.Lexer.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;

		M.Lexer.yyinput.Text := Source;
		if M.yyparse = 0 then
		begin
			for Idx := 0 to M.Operations.Count - 1 do
			begin
				for Idy := 0 to M.Operations.Items[Idx].TableList.Count - 1 do
				begin
					dtaCrud.Append;
					dtaCrud.FieldByName('line').AsInteger := M.Operations.Items[Idx].Line;
					dtaCrud.FieldByName('op').AsString := ConvertOpType(M.Operations.Items[Idx].OpType);
					dtaCrud.FieldByName('table').AsString := M.Operations.Items[Idx].TableList[Idy];
					dtaCrud.Post;
				end;
			end;
		end;
	finally
		M.Free;
	end;
	cmbGroup.ItemIndex := 0;
	RefreshGroupings;
end;

procedure TframeDRUI.Init(Form: IMarathonBaseForm);
begin
	FForm := Form;
end;

procedure TframeDRUI.RefreshGroupings;
var
	N: TrmTreeNode;

begin
	tvCrud.Items.BeginUpdate;
	try
		tvCrud.Items.Clear;
		dtaCrud.First;
		while not dtaCrud.EOF do
		begin
			case cmbGroup.ItemIndex of
				0: // relation
					begin
						N := tvCrud.FindPathNode(#2 + dtaCrud.FieldByName('table').AsString + #2 + dtaCrud.FieldByName('op').AsString);
						if Assigned(N) then
						begin
							tvCrud.Items.AddChild(N, dtaCrud.FieldByName('line').AsString);
						end
						else
						begin
							N := tvCrud.AddPathNode(nil, #2 + dtaCrud.FieldByName('table').AsString + #2 + dtaCrud.FieldByName('op').AsString);
							tvCrud.Items.AddChild(N, dtaCrud.FieldByName('line').AsString);
						end;
					end;

				1: // operation
					begin
						N := tvCrud.FindPathNode(#2 + dtaCrud.FieldByName('op').AsString + #2 + dtaCrud.FieldByName('table').AsString);
						if Assigned(N) then
						begin
							tvCrud.Items.AddChild(N, dtaCrud.FieldByName('line').AsString);
						end
						else
						begin
							N := tvCrud.AddPathNode(nil, #2 + dtaCrud.FieldByName('op').AsString + #2 + dtaCrud.FieldByName('table').AsString);
							tvCrud.Items.AddChild(N, dtaCrud.FieldByName('line').AsString);
						end;
					end;
			end;
			dtaCrud.Next;
		end;
		N := tvCrud.Items.GetFirstNode;
		while Assigned(N) do
		begin
			N.Expand(True);
			N := N.getNextSibling;
		end;
	finally
		tvCrud.Items.EndUpdate;
	end;
end;

procedure TframeDRUI.SetActive;
begin

end;

procedure TframeDRUI.cmbGroupChange(Sender: TObject);
begin
	RefreshGroupings;
end;

function TframeDRUI.CanPrint: Boolean;
begin
	Result := (not FForm.GetObjectNewStatus);
end;

procedure TframeDRUI.DoPrint;
begin
	MarathonIDEInstance.PrintObjectDRUIMatrix(False, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

procedure TframeDRUI.DoPrintPreview;
begin
	MarathonIDEInstance.PrintObjectDRUIMatrix(True, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

end.


