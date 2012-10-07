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
// $Id: FrameDependencies.pas,v 1.7 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: FrameDependencies.pas,v $
Revision 1.7  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.6  2003/11/05 05:36:41  figmentsoft
Code cleanup.
Added a line to set Item.Data to nil within lvDependsOnDeletion().  Just in case any one evaluates Item.Data for a nil.

Revision 1.5  2002/05/04 11:45:24  tmuetze
Fixed a AV which occured while the internally attached TListItem.Data was freed

Revision 1.4  2002/05/04 08:23:30  tmuetze
Added the ability to show FK relations on the 'Depends On' page

Revision 1.3  2002/04/29 11:54:53  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit FrameDependencies;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, ComCtrls, Db,
	IBODataset,
	MarathonProjectCacheTypes,
	MarathonProjectCache,
	MarathonInternalInterfaces;

type
	TframeDepend = class(TFrame)
		pgDependencies: TPageControl;
		tsDependedOn: TTabSheet;
		lvDependedOn: TListView;
		pnlDependedOnHdr: TPanel;
		tsDependsOn: TTabSheet;
		lvDependsOn: TListView;
		Panel1: TPanel;
    qryUtil: TIBOQuery;
		procedure pgDependenciesChange(Sender: TObject);
		procedure lvDependsOnDeletion(Sender: TObject; Item: TListItem);
		procedure lvDependedOnDblClick(Sender: TObject);
	private
		{ Private declarations }
		FForm : IMarathonBaseForm;
	public
		{ Public declarations }
		procedure SaveColWidths;
		procedure SetActive;
		procedure LoadDependencies;
		procedure Init(Form : IMarathonBaseForm);
		function CanPrint : Boolean;
		procedure DoPrint;
		procedure DoPrintPreview;
	end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

procedure TframeDepend.Init(Form : IMarathonBaseForm);
begin
	FForm := Form;
end;

procedure TframeDepend.SaveColWidths;
begin
	MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[0].Width := lvDependedOn.Columns[0].Width;
	MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[1].Width := lvDependedOn.Columns[1].Width;
end;

procedure TframeDepend.pgDependenciesChange(Sender: TObject);
var
	L : TListItem;
	ND : TMarathonCacheBaseNode;
	TableEditor : IMarathonTableEditor;
begin
	case pgDependencies.ActivePage.PageIndex of
		0 :
			begin
				//dependencies...
				lvDependedOn.Items.BeginUpDate;
				lvDependedOn.Items.Clear;
				qryUtil.Close;
				qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
				qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;
				qryUtil.SQL.Clear;
				qryUtil.SQL.Add('select RDB$DEPENDENT_NAME, RDB$DEPENDENT_TYPE, RDB$FIELD_NAME from RDB$DEPENDENCIES where RDB$DEPENDED_ON_NAME = ' +
					AnsiQuotedStr(FForm.GetObjectName, '''') + ' order by RDB$DEPENDENT_NAME, RDB$FIELD_NAME;');
				qryUtil.Open;
				while not qryUtil.EOF do
				begin
					L := lvDependedOn.Items.Add;
					L.Caption := qryUtil.FieldByName('RDB$DEPENDENT_NAME').AsString;
					L.SubItems.Add(qryUtil.FieldByName('RDB$FIELD_NAME').AsString);
					ND := nil;
					case qryUtil.FieldByName('RDB$DEPENDENT_TYPE').AsInteger of
						0:
							begin
								ND := TMarathonCacheTable.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheTable(ND).ObjectName := L.Caption;
								TMarathonCacheTable(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						1:
							begin
								ND := TMarathonCacheView.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheView(ND).ObjectName := L.Caption;
								TMarathonCacheView(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						2:
							begin
								ND := TMarathonCacheTrigger.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheTrigger(ND).ObjectName := L.Caption;
								TMarathonCacheTrigger(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						5:
							begin
								ND := TMarathonCacheProcedure.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheProcedure(ND).ObjectName := L.Caption;
								TMarathonCacheProcedure(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						7:
							begin
								ND := TMarathonCacheException.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheException(ND).ObjectName := L.Caption;
								TMarathonCacheException(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
					end;
					if Assigned(ND) then
					begin
						L.Data := ND;
						L.ImageIndex := TMarathonCacheBaseNode(L.Data).ImageIndex;
					end;
					qryUtil.Next;
				end;
				qryUtil.Close;
				//check to see if we have a table...
				if FForm.QueryInterface(IMarathonTableEditor, TableEditor) = S_OK then
				begin
					//does this table exist in any foreign key relationships?
					qryUtil.SQL.Clear;
					qryUtil.SQL.Text := 'select A.RDB$CONSTRAINT_NAME, B.RDB$INDEX_NAME, C.RDB$RELATION_NAME, ' +
						'D.RDB$FIELD_NAME from ' +
						'((RDB$REF_CONSTRAINTS A inner join RDB$RELATION_CONSTRAINTS B on ' +
						'A.RDB$CONSTRAINT_NAME = B.RDB$CONSTRAINT_NAME) inner join ' +
						'RDB$INDICES C on B.RDB$INDEX_NAME = C.RDB$INDEX_NAME) inner join ' +
						'RDB$INDEX_SEGMENTS D on C.RDB$INDEX_NAME = D.RDB$INDEX_NAME ' +
						'where RDB$CONST_NAME_UQ in (select RDB$CONSTRAINT_NAME from ' +
						'RDB$RELATION_CONSTRAINTS where RDB$RELATION_NAME = ' + AnsiQuotedStr(FForm.GetObjectName, '''') +
						'and ((RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'') or (RDB$CONSTRAINT_TYPE = ''UNIQUE'')))';
					qryUtil.Open;
					while not qryUtil.EOF do
					begin
						L := lvDependedOn.Items.Add;
						L.Caption := qryUtil.FieldByName('RDB$RELATION_NAME').AsString;
						L.SubItems.Add(qryUtil.FieldByName('RDB$FIELD_NAME').AsString);
						ND := TMarathonCacheTable.Create;
						ND.Caption := L.Caption;
						ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
						TMarathonCacheTable(ND).ObjectName := L.Caption;
						TMarathonCacheTable(ND).ConnectionName := FForm.GetActiveConnectionName;
						L.Data := ND;
						L.ImageIndex := TMarathonCacheBaseNode(L.Data).ImageIndex;
						qryUtil.Next;
					end;
					qryUtil.Close;
				end;

				if qryUtil.IB_Transaction.Started then
					qryUtil.IB_Transaction.Commit;
				lvDependedOn.Columns[0].Width := MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[0].Width;
				lvDependedOn.Columns[1].Width := MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[1].Width;
				lvDependedOn.Items.EndUpDate;
			end;
		1 :
			begin
				//dependencies...
				lvDependsOn.Items.BeginUpDate;
				lvDependsOn.Items.Clear;
				qryUtil.Close;
				qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
				qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;
				qryUtil.SQL.Clear;
				qryUtil.SQL.Add('select RDB$DEPENDED_ON_NAME, RDB$DEPENDED_ON_TYPE, RDB$FIELD_NAME from RDB$DEPENDENCIES where RDB$DEPENDENT_NAME = ' +
					AnsiQuotedStr(FForm.GetObjectName, '''') + ';');
				qryUtil.Open;
				while not qryUtil.EOF do
				begin
					L := lvDependsOn.Items.Add;
					L.Caption := qryUtil.FieldByName('RDB$DEPENDED_ON_NAME').AsString;
					L.SubItems.Add(qryUtil.FieldByName('RDB$FIELD_NAME').AsString);
					ND := nil;
					case qryUtil.FieldByName('RDB$DEPENDED_ON_TYPE').AsInteger of
						0:
							begin
								ND := TMarathonCacheTable.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheTable(ND).ObjectName := L.Caption;
								TMarathonCacheTable(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						1:
							begin
								ND := TMarathonCacheView.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheView(ND).ObjectName := L.Caption;
								TMarathonCacheView(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						2:
							begin
								ND := TMarathonCacheTrigger.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheTrigger(ND).ObjectName := L.Caption;
								TMarathonCacheTrigger(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						5:
							begin
								ND := TMarathonCacheProcedure.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheProcedure(ND).ObjectName := L.Caption;
								TMarathonCacheProcedure(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
						7:
							begin
								ND := TMarathonCacheException.Create;
								ND.Caption := L.Caption;
								ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
								TMarathonCacheException(ND).ObjectName := L.Caption;
								TMarathonCacheException(ND).ConnectionName := FForm.GetActiveConnectionName;
							end;
					end;
					if Assigned(ND) then
					begin
						L.Data := ND;
						L.ImageIndex := TMarathonCacheBaseNode(L.Data).ImageIndex;
					end;
					qryUtil.Next;
				end;
				qryUtil.Close;

				//check to see if we have a table...
				if FForm.QueryInterface(IMarathonTableEditor, TableEditor) = S_OK then
				begin
					//does this table exist in any foreign key relationships?
					qryUtil.SQL.Clear;
					qryUtil.SQL.Add('select distinct RC.RDB$CONSTRAINT_NAME, REFC.RDB$UPDATE_RULE,'
						+ ' REFC.RDB$DELETE_RULE, RC2.RDB$RELATION_NAME as FK_TABLE,'
						+ ' ISEG.RDB$FIELD_NAME as FK_FIELD, ISEG.RDB$FIELD_NAME as ON_FIELD'
						+ ' from RDB$RELATION_CONSTRAINTS RC'
						+ ' join RDB$REF_CONSTRAINTS REFC on RC.RDB$CONSTRAINT_NAME = REFC.RDB$CONSTRAINT_NAME'
						+ ' join RDB$RELATION_CONSTRAINTS RC2 on REFC.RDB$CONST_NAME_UQ = RC2.RDB$CONSTRAINT_NAME'
						+ ' join RDB$INDEX_SEGMENTS ISEG on RC2.RDB$INDEX_NAME = ISEG.RDB$INDEX_NAME'
						+ ' join RDB$INDEX_SEGMENTS ISEG2 on RC.RDB$INDEX_NAME = ISEG2.RDB$INDEX_NAME'
						+ ' where RC.RDB$RELATION_NAME = ' + AnsiQuotedStr(FForm.GetObjectName, '''')
						+ ' and RC.RDB$CONSTRAINT_TYPE = ' + AnsiQuotedStr('FOREIGN KEY', '''') + ' order by RC.RDB$RELATION_NAME');
					qryUtil.Open;
					while not qryUtil.EOF do
					begin
						L := lvDependsOn.Items.Add;
						L.Caption := qryUtil.FieldByName('FK_TABLE').AsString;
						L.SubItems.Add(qryUtil.FieldByName('FK_FIELD').AsString);
						ND := TMarathonCacheTable.Create;
						ND.Caption := L.Caption;
						ND.RootItem := MarathonIDEInstance.CurrentProject.Cache;
						TMarathonCacheTable(ND).ObjectName := L.Caption;
						TMarathonCacheTable(ND).ConnectionName := FForm.GetActiveConnectionName;
						L.Data := ND;
						L.ImageIndex := TMarathonCacheBaseNode(L.Data).ImageIndex;
						qryUtil.Next;
					end;
					qryUtil.Close;
				end;

				lvDependsOn.Columns[0].Width := MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[0].Width;
				lvDependsOn.Columns[1].Width := MarathonIDEInstance.CurrentProject.SPEDependColumns.Items[1].Width;
				lvDependsOn.Items.EndUpDate;

				if qryUtil.IB_Transaction.Started then
					qryUtil.IB_Transaction.Commit;
			end;
	end;
end;

procedure TframeDepend.SetActive;
begin
	case pgDependencies.ActivePage.PageIndex of
		0 :
			begin
        try
          lvDependedOn.SetFocus;
          lvDependedOn.Repaint;
        except
          On E : Exception do
					begin
						// bite me...
          end;
        end;
      end;
		1 :
      begin
        try
          lvDependsOn.SetFocus;
          lvDependsOn.Repaint;
        except
          On E : Exception do
          begin
						//bite me...
          end;
				end;
      end;
  end;
end;

procedure TframeDepend.LoadDependencies;
begin
  pgDependenciesChange(pgDependencies);
end;

procedure TframeDepend.lvDependsOnDeletion(Sender: TObject;	Item: TListItem);
begin
	if Assigned(Item.Data) then
  begin
		TObject(Item.Data).Free;
    Item.Data := nil; //AC:
  end;
end;

procedure TframeDepend.lvDependedOnDblClick(Sender: TObject);
begin
	if Assigned((Sender as TListView).Selected) then
	begin
		if Assigned((Sender as TListView).Selected.Data) then
		begin
			TMarathonCacheBaseNode((Sender as TListView).Selected.Data).FireEvent(opOpen);
		end;
	end;
end;

function TframeDepend.CanPrint: Boolean;
begin
	Result := FForm.GetObjectNewStatus;
end;

procedure TframeDepend.DoPrint;
begin
	MarathonIDEInstance.PrintObjectDependencies(False, FForm.GetObjectName, FForm.GetActiveConnectionName);
end;

procedure TframeDepend.DoPrintPreview;
begin
	MarathonIDEInstance.PrintObjectDependencies(True, FForm.GetObjectName, FForm.GetActiveConnectionName);
end;

end.


