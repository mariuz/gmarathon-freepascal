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
// $Id: FreeIBCompsSQL.pas,v 1.2 2002/04/25 07:17:03 tmuetze Exp $

unit FreeIBCompsSQL;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Db, IBHeader, IBCustomDataSet, IBDatabase;

type
  TfrmFreeIBComponentsSQL = class(TForm)
    btnClose: TButton;
    pgSQL: TPageControl;
    tsSelectSQL: TTabSheet;
    edSelectSQL: TMemo;
    tsRefreshSQL: TTabSheet;
    edRefreshSQL: TMemo;
    tsInsertSQL: TTabSheet;
    tsDeleteSQL: TTabSheet;
    tsUpdateSQL: TTabSheet;
    edInsertSQL: TMemo;
    edDeleteSQL: TMemo;
    edUpdateSQL: TMemo;
    dbPlugin: TIBDatabase;
    tranPlugin: TIBTransaction;
    qryUtil: TIBDataSet;
    qryUtil2: TIBDataSet;
    procedure FormCreate(Sender: TObject);
  private
    FConnectionName: String;
    FTableName: String;
    FSQLDialect : Integer;
    FIB6 : Boolean;
    { Private declarations }
  public
    { Public declarations }
    procedure Init;
    property TableName : String read FTableName write FTableName;
    property ConnectionName : String read FConnectionName write FConnectionName;
  end;

implementation

uses
  UpdateSQLPlugin,
  GimbalToolsAPI;

{$R *.DFM}

function IsIdentifierQuoted(S : String) : Boolean;
var
  BeginQuote : Boolean;
  EndQuote : Boolean;

begin
  BeginQuote := False;
  EndQuote := False;

  if Length(S) > 0 then
  begin
    if S[1] in ['''', '"'] then
    begin
      BeginQuote := True;
    end;
  end;

  if Length(S) > 0 then
  begin
    if S[Length(S)] in ['''', '"'] then
    begin
      EndQuote := True;
    end;
  end;
  Result := BeginQuote and EndQuote;
end;

function ShouldBeQuoted(S : String) : Boolean;
var
	Idx : Integer;

begin
	Result := False;
	for Idx := 1 to Length(S) do
	begin
		if not (S[Idx] in ['A'..'Z', 'a'..'z', '_', '0'..'9']) then
		begin
			Result := True;
      Break;
    end;
  end;
end;

function MakeQuotedIdent(S : String; IB6 : Boolean; Dialect : Integer) : String;
begin
  if not IB6 then
  begin
    Result := S;
  end
  else
  begin
    if Dialect in [3] then
    begin
      if not IsIdentifierQuoted(S) then
      begin
        if ShouldBeQuoted(S) then
          Result := AnsiQuotedStr(S, '"')
        else
          Result := S;
      end
      else
        Result := S;
    end
    else
      Result := S;
	end;
end;

procedure TfrmFreeIBComponentsSQL.FormCreate(Sender: TObject);
begin
  pgSQL.ActivePage := tsSelectSQL;
end;

procedure TfrmFreeIBComponentsSQL.Init;
var
	Project : IGimbalIDEMarathonProject;
  Connection : IGimbalIDEConnection;

  SelectList : TStringList;
  Idx : Integer;
  IndexList : TStringList;
  Temp : String;

begin
  //establish a connection to the database...
  Project := LocalToolServices.IDEGetProject;
  if Assigned(Project) then
  begin
    Connection := Project.IDEGetConnectionByName(FCOnnectionName);
    if Assigned(Connection) then
    begin
      FSQLDialect := Connection.IDESQLDialect;
      FIB6 := Connection.IDEIsInterbaseSix;
      dbPlugin.SetHandle(TISC_DB_HANDLE(Connection.IDEGetCurrentDBHandle));
      tranPlugin.StartTransaction;
      try
        //generate SQL...
        SelectList := TStringList.Create;
        IndexList := TStringList.Create;
        try
          //get the fieldlist...

          qryUtil.SelectSQL.Add('select a.rdb$field_name from rdb$relation_fields a, ' +
                                'rdb$fields b where a.rdb$field_source = b.rdb$field_name ' +
                                'and a.rdb$relation_name = ' + AnsiQuotedStr(FTableName, '''') + ' ' +
                                ' order by a.rdb$field_position asc;');
					qryUtil.Open;
          While not qryUtil.EOF do
          begin
            SelectList.Add(MakeQuotedIdent(Trim(qryUtil.FieldByName('rdb$field_name').AsString), FIB6, FSQLDialect));
            qryUtil.Next;
          end;
          qryUtil.Close;

          //get the PK if there is one...
          qryUtil2.SelectSQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type = ''PRIMARY KEY'') and rdb$relation_name = ''' + AnsiUpperCase(TableName) + ''';');
          qryUtil2.Open;
          if Not (qryUtil2.EOF and qryUtil2.BOF) then
          begin
            qryUtil.SelectSQL.Clear;
            qryUtil.SelectSQL.Add('select * from rdb$index_segments where rdb$index_name = ''' +
                      Trim(qryUtil2.FieldByName('rdb$index_name').AsString) +
                      ''' order by rdb$field_position asc;');
            qryUtil.Open;
            While Not qryUtil.EOF do
            begin
              IndexList.Add(Trim(qryUtil.FieldByName('rdb$field_name').AsString));
              qryUtil.Next;
            end;
            qryUtil.Close;
          end;

          //SelectSQL
          edSelectSQL.Lines.Add('select');
          for Idx := 0 to SelectList.Count - 1 do
          begin
            Temp := '  ' + SelectList[Idx];
            if Idx < SelectList.Count - 1 then
              Temp := Temp + ',';
            edSelectSQL.Lines.Add(Temp);
          end;
          edSelectSQL.Lines.Add('from');
          edSelectSQL.Lines.Add('  ' + MakeQuotedIdent(TableName, FIB6, FSQLDIalect));

          //RefreshSQL
					edRefreshSQL.Lines.Add('select');
          for Idx := 0 to SelectList.Count - 1 do
          begin
            Temp := '  ' + SelectList[Idx];
            if Idx < SelectList.Count - 1 then
              Temp := Temp + ',';
            edRefreshSQL.Lines.Add(Temp);
          end;
          edRefreshSQL.Lines.Add('from');
          edRefreshSQL.Lines.Add('  ' + MakeQuotedIdent(TableName, FIB6, FSQLDIalect));
          edRefreshSQL.Lines.Add('where');
          if IndexList.Count > 0 then
          begin
            for Idx := 0 to IndexList.Count - 1 do
            begin
              edRefreshSQL.Lines.Add('  ' + IndexList[Idx] + ' = ?' + IndexList[Idx] + ' and');
            end;
            if Copy(edRefreshSQL.Text, Length(edRefreshSQL.Text) - 5, 4) = ' and' then
              edRefreshSQL.Text := Copy(edRefreshSQL.Text, 1, Length(edRefreshSQL.Text) - 6);
          end
          else
          begin
            for Idx := 0 to IndexList.Count - 1 do
            begin
              edRefreshSQL.Lines.Add('  ' + SelectList[Idx] + ' = ?' + SelectList[Idx] + ' and');
            end;
            if Copy(edRefreshSQL.Text, Length(edRefreshSQL.Text) - 5, 4) = ' and' then
              edRefreshSQL.Text := Copy(edRefreshSQL.Text, 1, Length(edRefreshSQL.Text) - 6);
          end;

          //DeleteSQL
          edDeleteSQL.Lines.Add('delete from');
          edDeleteSQL.Lines.Add('  ' + MakeQuotedIdent(TableName, FIB6, FSQLDIalect));
          edDeleteSQL.Lines.Add('where');
          if IndexList.Count > 0 then
          begin
            for Idx := 0 to IndexList.Count - 1 do
            begin
              edDeleteSQL.Lines.Add('  ' + IndexList[Idx] + ' = ?' + IndexList[Idx] + ' and');
						end;
            if Copy(edDeleteSQL.Text, Length(edDeleteSQL.Text) - 5, 4) = ' and' then
              edDeleteSQL.Text := Copy(edDeleteSQL.Text, 1, Length(edDeleteSQL.Text) - 6);
          end
          else
          begin
            for Idx := 0 to IndexList.Count - 1 do
            begin
              edDeleteSQL.Lines.Add('  ' + SelectList[Idx] + ' = ?' + SelectList[Idx] + ' and');
            end;
            if Copy(edDeleteSQL.Text, Length(edDeleteSQL.Text) - 5, 4) = ' and' then
              edDeleteSQL.Text := Copy(edDeleteSQL.Text, 1, Length(edDeleteSQL.Text) - 6);
          end;


          //UpdateSQL
          edUpdateSQL.Lines.Add('update');
          edUpdateSQL.Lines.Add('  ' + MakeQuotedIdent(TableName, FIB6, FSQLDIalect));
          edUpdateSQL.Lines.Add('set');
          for Idx := 0 to SelectList.Count - 1 do
          begin
            Temp := '  ' + SelectList[Idx] + ' = ?' + SelectList[Idx];
            if Idx < SelectList.Count - 1 then
              Temp := Temp + ',';
            edUpdateSQL.Lines.Add(Temp);
          end;
          edUpdateSQL.Lines.Add('where');
          if IndexList.Count > 0 then
          begin
            for Idx := 0 to IndexList.Count - 1 do
            begin
              edUpdateSQL.Lines.Add('  ' + IndexList[Idx] + ' = ?' + IndexList[Idx] + ' and');
            end;
            if Copy(edUpdateSQL.Text, Length(edUpdateSQL.Text) - 5, 4) = ' and' then
              edUpdateSQL.Text := Copy(edUpdateSQL.Text, 1, Length(edUpdateSQL.Text) - 6);
          end
          else
          begin
            for Idx := 0 to IndexList.Count - 1 do
						begin
              edUpdateSQL.Lines.Add('  ' + SelectList[Idx] + ' = ?' + SelectList[Idx] + ' and');
            end;
            if Copy(edUpdateSQL.Text, Length(edUpdateSQL.Text) - 5, 4) = ' and' then
              edUpdateSQL.Text := Copy(edUpdateSQL.Text, 1, Length(edUpdateSQL.Text) - 6);
          end;

          //InsertSQL
          edInsertSQL.Lines.Add('insert into');
          edInsertSQL.Lines.Add('  ' + MakeQuotedIdent(TableName, FIB6, FSQLDIalect));
          edInsertSQL.Lines.Add('(');
          for Idx := 0 to SelectList.Count - 1 do
          begin
            Temp := '  ' + SelectList[Idx];
            if Idx < SelectList.Count - 1 then
              Temp := Temp + ',';
            edInsertSQL.Lines.Add(Temp);
          end;
          edInsertSQL.Lines.Add(')');
          edInsertSQL.Lines.Add('values');
          edInsertSQL.Lines.Add('(');
          for Idx := 0 to SelectList.Count - 1 do
          begin
            Temp := '  ?' + SelectList[Idx];
            if Idx < SelectList.Count - 1 then
              Temp := Temp + ',';
            edInsertSQL.Lines.Add(Temp);
          end;
          edInsertSQL.Lines.Add(')');
        finally
          SelectList.Free;
          IndexList.Free;
        end;

        tranPlugin.Commit;
      except
        On E : Exception do
        begin
          tranPlugin.Rollback;
				end;
      end;
    end;
  end;
end;

end.

{
$Log: FreeIBCompsSQL.pas,v $
Revision 1.2  2002/04/25 07:17:03  tmuetze
New CVS powered comment block

}
