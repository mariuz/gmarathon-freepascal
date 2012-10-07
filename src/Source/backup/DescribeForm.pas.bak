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
// $Id: DescribeForm.pas,v 1.2 2002/04/25 07:21:29 tmuetze Exp $

unit DescribeForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Buttons, StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmDescribe = class(TForm)
    pgRelations: TPageControl;
    tsRelations: TTabSheet;
    Splitter1: TSplitter;
    lvRelations: TListView;
    lvColumns: TListView;
    pnlSQLAssistHint: TPanel;
    Label2: TLabel;
    Label3: TLabel;
		btnCloseHint: TSpeedButton;
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	frmDescribe: TfrmDescribe;

implementation

uses
	Globals;

{$R *.DFM}

{procedure TfrmDatabaseExplorer.lvRelationsClick(Sender: TObject);
var
	Item : TListItem;


begin
	if lvRelations.Selected <> nil then
	begin
		try
			qryDataManager.BeginBusy(False);

			if AnsiUpperCase(OldSelected) <> AnsiUpperCase(lvRelations.Selected.Caption) then
			begin
				Q := TIBGSSDataSet.Create(Self);
				try
					Q.Database := frmMarathonMain.IBObjDatabase;
					Q.IB_Transaction := frmMarathonMain.IBObjTransaction;

					case lvRelations.Selected.ImageIndex of
						2, 5 : //table, view
							begin
								Q.SQL.Add('select a.rdb$field_name, a.rdb$field_position, a.rdb$field_source, b.rdb$field_length, b.rdb$field_scale, ' +
													'b.rdb$field_type from rdb$relation_fields a, rdb$fields b where ' +
                          'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ''' +
                          AnsiUpperCase(lvRelations.Selected.Caption) + ''' order by a.rdb$field_position asc;');
                Q.Open;
                lvColumns.Items.BeginUpdate;
                try
                  lvColumns.Items.Clear;
                  While Not Q.EOF do
                  begin
                    Item := lvColumns.Items.Add;
                    Item.Caption := Q.FieldByName('rdb$field_name').AsString;
                    Item.SubItems.Add(Q.FieldByName('rdb$field_position').AsString);
                    Item.SubItems.Add(AnsiUpperCase(ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger, Q.FieldByName('rdb$field_length').AsInteger,
																	Q.FieldByName('rdb$field_scale').AsInteger)));

                    Item.SubItems.Add(Q.FieldByName('rdb$field_source').AsString);
                    Item.ImageIndex := 6;
										Q.Next;
                  end;
                finally
                  lvColumns.Items.EndUpdate;
                end;
                Q.Close;
							end;

						3 : //SP
              begin
                Q.SQL.Add('select a.rdb$parameter_name, a.rdb$parameter_number, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale from rdb$procedure_parameters a, rdb$fields b where ' +
                          'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ''' + AnsiUpperCase(lvRelations.Selected.Caption) + ''' order by rdb$parameter_number asc;');
                Q.Open;
                lvColumns.Items.BeginUpdate;
                try
                  lvColumns.Items.Clear;
                  While Not Q.EOF do
                  begin
                    Item := lvColumns.Items.Add;
                    Item.Caption := Q.FieldByName('rdb$parameter_name').AsString;
                    Item.SubItems.Add(Q.FieldByName('rdb$parameter_number').AsString);
                    Item.SubItems.Add(AnsiUpperCase(ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger, Q.FieldByName('rdb$field_length').AsInteger,
                                  Q.FieldByName('rdb$field_scale').AsInteger)));

                    Item.SubItems.Add('');
                    Item.ImageIndex := 6;
                    Q.Next;
                  end;
                finally
                  lvColumns.Items.EndUpdate;
                end;
                Q.Close;
              end;
          end;

					Q.Close;
          frmMarathonMain.IBObjTransaction.Commit;
        finally
          Q.Free;
				end;
			end;
			OldSelected := lvRelations.Selected.Caption;
		finally
			qryDataManager.EndBusy;
		end;
	end;
	DoRelationsFieldSort(False);
end;}


{function CustomRelationsSortProc(Item1, Item2: TListItem; ParamSort: integer): integer; stdcall;
begin
  if frmMarathonMain.FProject.RelationsColumns.SortOrder = srtAsc then
  begin
    Result := lstrcmp(PChar(TListItem(Item1).Caption),
                      PChar(TListItem(Item2).Caption));
  end
  else
  begin
    Result := -lstrcmp(PChar(TListItem(Item1).Caption),
                       PChar(TListItem(Item2).Caption));
  end;
end;

function CustomRelationsFieldSortProc(Item1, Item2: TListItem; ParamSort: integer): integer; stdcall;
begin
  if frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn = 0 then
  begin
    if frmMarathonMain.FProject.RelationsFieldColumns.SortOrder = srtAsc then
    begin
      Result := lstrcmp(PChar(TListItem(Item1).Caption),
                        PChar(TListItem(Item2).Caption));
    end
    else
		begin
      Result := -lstrcmp(PChar(TListItem(Item1).Caption),
                         PChar(TListItem(Item2).Caption));
    end;
  end
  else
  begin
    if frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn = 1 then
    begin
      if frmMarathonMain.FProject.RelationsFieldColumns.SortOrder = srtAsc then
      begin
        Result := StrToInt(TListItem(Item1).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]) - StrToInt(TListItem(Item2).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]);
      end
      else
      begin
        Result := StrToInt(TListItem(Item2).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]) - StrToInt(TListItem(Item1).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]);
      end;
    end
    else
    begin
      if frmMarathonMain.FProject.RelationsFieldColumns.SortOrder = srtAsc then
      begin
        Result := lstrcmp(PChar(TListItem(Item1).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]),
                          PChar(TListItem(Item2).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]));
      end
      else
      begin
        Result := -lstrcmp(PChar(TListItem(Item1).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]),
                          PChar(TListItem(Item2).SubItems[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn - 1]));
      end;
    end;
  end;
end;}

{
procedure TfrmDatabaseExplorer.DoRelationsSort(ChangeDir : Boolean);
begin
  if ChangeDir then
  begin
		if frmMarathonMain.FProject.RelationsColumns.SortOrder = srtAsc then
    begin
      frmMarathonMain.FProject.RelationsColumns.SortOrder := srtDesc;
      lvRelations.Columns[0].ImageIndex := 11;
    end
    else
    begin
      frmMarathonMain.FProject.RelationsColumns.SortOrder := srtAsc;
      lvRelations.Columns[0].ImageIndex := 12;
    end;
  end;
  lvRelations.CustomSort(@CustomRelationsSortProc,0);
  if frmMarathonMain.FProject.RelationsColumns.SortOrder = srtDesc then
    lvRelations.Columns[0].ImageIndex := 11
  else
    lvRelations.Columns[0].ImageIndex := 12;
end;

procedure TfrmDatabaseExplorer.lvRelationsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  DoRelationsSort(True);
end;

procedure TfrmDatabaseExplorer.DoRelationsFieldSort(ChangeDir : Boolean);
var
  Idx : Integer;

begin
  if ChangeDir then
  begin
    if frmMarathonMain.FProject.RelationsFieldColumns.SortOrder = srtAsc then
    begin
      frmMarathonMain.FProject.RelationsFieldColumns.SortOrder := srtDesc;
      lvColumns.Columns[0].ImageIndex := 11;
    end
    else
    begin
      frmMarathonMain.FProject.RelationsFieldColumns.SortOrder := srtAsc;
			lvColumns.Columns[0].ImageIndex := 12;
    end;
  end;
  lvColumns.CustomSort(@CustomRelationsFieldSortProc,0);
  for Idx := 0 to lvColumns.Columns.Count - 1 do
    lvColumns.Columns[Idx].ImageIndex := -1;

  if frmMarathonMain.FProject.RelationsFieldColumns.SortOrder = srtDesc then
    lvColumns.Columns[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn].ImageIndex := 11
  else
    lvColumns.Columns[frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn].ImageIndex := 12;
end;

procedure TfrmDatabaseExplorer.lvColumnsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  frmMarathonMain.FProject.RelationsFieldColumns.SortedColumn := Column.Index;
  DoRelationsFieldSort(True);
end;
 }


{procedure TfrmDatabaseExplorer.btnCloseHintClick(Sender: TObject);
var
  I : TRegistry;

begin
  pnlSQLAssistHint.Visible := False;
  I := TRegistry.Create;
  try
    if I.OpenKey(REG_SETTINGS_BASE, False) then
    begin
      I.WriteBool('ShowAssistHint', False);
      gShowAssistHint := False;
      I.CloseKey;
    end;
  finally
    I.Free;
  end;
end;}

{procedure TfrmDatabaseExplorer.lvRelationsStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  if lvRelations.Selected <> nil then
  begin
    DragObject := FRelationDrag;

    if lvRelations.Selected.ImageIndex = 3 then
    begin
      FRelationDrag.DragItemType := dbntStoredProc;
    end
    else
    begin
      FRelationDrag.DragItemType := dbntTable;
    end;
    FRelationDrag.DragItem := lvRelations.Selected.Caption
  end;
end;

procedure TfrmDatabaseExplorer.lvColumnsStartDrag(Sender: TObject; var DragObject: TDragObject);
var
  Idx : Integer;

begin
  if lvRelations.Selected <> nil then
  begin
    DragObject := FColumnsDrag;

    FColumnsDrag.DragList.Clear;

    if lvRelations.Selected.ImageIndex = 3 then
    begin
      FColumnsDrag.DragItemType := dbntStoredProc;
    end
    else
    begin
      FColumnsDrag.DragItemType := dbntTable;
    end;
		FColumnsDrag.DragItem := lvRelations.Selected.Caption;


    for idx := 0 to lvColumns.Items.Count - 1 do
    begin
      if lvColumns.Items.Item[idx].Selected then
        FColumnsDrag.DragList.Add(lvColumns.Items.Item[idx].Caption);
    end;
  end;
end;}

end.

{
$Log: DescribeForm.pas,v $
Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
