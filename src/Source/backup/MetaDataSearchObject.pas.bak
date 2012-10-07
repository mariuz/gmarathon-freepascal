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
// $Id: MetaDataSearchObject.pas,v 1.4 2005/04/13 16:04:30 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: MetaDataSearchObject.pas,v $
Revision 1.4  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.3  2002/04/29 11:43:41  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit MetaDataSearchObject;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, ExtCtrls, Menus,
	IB_Components,
	IBODataset,
	Globals,
	MarathonProjectCache,
	MarathonProjectCacheTypes;

type
  TMDSearchItem = record
    ItemName : String;
  end;

  TSearchEventType = (setError, setStart, setFinish, setMDStatus, setItemFound);

	TSearchEvent = procedure(Sender : TObject; Event : TSearchEventType; Status : String; Item : TResultItem) of object;

  TMDSearchObject = class(TObject)
  private
    FConnectionList : TStringList;
    FOptions : TSearchOptions;
    FSearch : String;
    DB : TIB_Connection;
    Xact : TIB_Transaction;
		Q : TIBOQuery;
		Q1 : TIBOQuery;
    L : TStringList;
    Line : String;
    SPos : Integer;
    ResultItem : TResultItem;
    StatusItem : String;
    LinePosition : Integer;
    Halted : Boolean;
    FCurrentItem : TMDSearchItem;
    FTerminated: Boolean;
    FSearching: Boolean;
    FOnSearchEvent: TSearchEvent;

    procedure SetStatus(Stat : String);
  protected

	public
		constructor Create;
		procedure Execute;
		destructor Destroy; override;
		property Terminated : Boolean read FTerminated write FTerminated;
		property SearchString : String read FSearch write FSearch;
		property Options : TSearchOptions read FOptions write FOptions;
		property Searching : Boolean read FSearching write FSearching;
		property OnSearchEvent : TSearchEvent read FOnSearchEvent write FOnSearchEvent;
		property ConnectionList : TStringList read FConnectionList write FConnectionList;
	end;

implementation

uses
	HelpMap,
	MarathonIDE;

constructor TMDSearchObject.Create;
begin
	inherited Create;
	FConnectionList := TStringList.Create;
end;

procedure TMDSearchObject.SetStatus(Stat : String);
var
	Dummy : TResultItem;
begin
	if Assigned(FOnSearchEvent) then
    FOnSearchEvent(Self, setMDStatus, Stat, Dummy);
end;

procedure TMDSearchObject.Execute;
var
  Idx : Integer;
  DBCount : Integer;
  Dummy : TResultItem;

begin
  FSearching := True;
  if Assigned(FOnSearchEvent) then
    FOnSearchEvent(Self, setStart, '', Dummy);
  try
    try
      Halted := False;
      DB := TIB_Connection.Create(nil);
      Xact := TIB_Transaction.Create(nil);
      try
        Xact.IB_Connection := DB;
        try
          for DBCount := 0 to FConnectionList.Count - 1 do
          begin
            if XAct.InTransaction then
              XAct.Commit;

            DB.Connected := False;
            DB.DatabaseName := MarathonIdeInstance.CurrentProject.Cache.ConnectionByName[FConnectionList[DBCOunt]].DBFileName;
            DB.Username := MarathonIdeInstance.CurrentProject.Cache.ConnectionByName[FConnectionList[DBCOunt]].UserName;
            DB.Password := MarathonIdeInstance.CurrentProject.Cache.ConnectionByName[FConnectionList[DBCOunt]].Password;
            try
              DB.Connected := True;
            except
							On E : Exception do
              begin
                //unable to connect to this database so we send a message back...
                if Assigned(FOnSearchEvent) then
                  FOnSearchEvent(Self, setError, E.Message, Dummy);
              end;
            end;
            Xact.StartTransaction;
						Q := TIBOQuery.Create(nil);
						Q1 := TIBOQuery.Create(nil);
						try
              Q.IB_Connection := DB;
              Q1.IB_Connection := DB;
              try
                L := TStringList.Create;
                try
                  //Domains
                  if not Halted then
                  begin
                    if soDomains in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$field_name from rdb$fields where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$field_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        L.Text := AdjustLineBreaks(FCurrentItem.ItemName);
                        for Idx := 0 to L.Count - 1 do
                        begin
                          Line := L[Idx];
                          LinePosition := 0;
                          if not (soCaseSensitive in FOptions) then
                          begin
                            SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
													end
                          else
                            SPos := Pos(FSearch, Line);
                          while SPos <> 0 do
                          begin
                            ResultItem.Line := Idx;
                            LinePosition := LinePosition + SPos;
                            ResultItem.Position := LinePosition;
                            ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                            ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                            ResultItem.ObjType := ctDomain;
                            ResultItem.LineText := Copy(L[Idx], 1, 254);
                            ResultItem.SearchString := Copy(FSearch, 1, 254);
                            if Assigned(FOnSearchEvent) then
                              FOnSearchEvent(Self, setItemFound, '', ResultItem);

                            Delete(Line, 1, SPos);

                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                          end;
                          if Terminated then
                          begin
                            Halted := True;
                            Break;
                          end;
                          if Halted then
                            Break;
                          Application.ProcessMessages;  
                        end;
												if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;
                  //Stored Procedures
                  if not Halted then
                  begin
                    if soSP in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$procedure_name, rdb$procedure_source from rdb$procedures where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$procedure_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        if soNamesOnly in FOptions then
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$procedure_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
														else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctSP;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;
                          end;
                        end
												else
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$procedure_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctSP;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
																SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                          //source
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$procedure_source').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctSP;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
															begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;
                  //Triggers
                  if not Halted then
                  begin
                    if soTrig in FOptions then
                    begin
                      Q.Close;
											Q.SQL.Clear;
                      Q.SQL.Add('select rdb$trigger_name, rdb$trigger_source from rdb$triggers where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$trigger_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        if soNamesOnly in FOptions then
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$trigger_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctTrigger;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
															begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                        end
                        else
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$trigger_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
															ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctTrigger;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                          //source
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$trigger_source').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
														begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctTrigger;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
														Application.ProcessMessages;
                          end;
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;
                  //tables
                  if not Halted then
                  begin
                    if soTables in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$relation_name from rdb$relations where (rdb$system_flag <> 1 or rdb$system_flag is null) and rdb$view_source is null;');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$relation_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        if soNamesOnly in FOptions then
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$relation_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
														begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctTable;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
														Application.ProcessMessages;
                          end;
                        end
                        else
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$relation_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctTable;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
																SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;
                          end;

                          Q1.SQL.Text := 'select rdb$field_name from rdb$relation_fields where rdb$relation_name = ''' + Q.FieldByName('rdb$relation_name').AsString + '''';
                          Q1.Open;
                          while not Q1.EOF do
                          begin
                            //source
                            L.Text := AdjustLineBreaks(Q1.FieldByName('rdb$field_name').AsString);
                            for Idx := 0 to L.Count - 1 do
                            begin
                              Line := L[Idx];
                              LinePosition := 0;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                              while SPos <> 0 do
                              begin
                                ResultItem.Line := Idx;
                                LinePosition := LinePosition + SPos;
                                ResultItem.Position := LinePosition;
                                ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                                ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                                ResultItem.ObjType := ctTable;
																ResultItem.LineText := Copy(L[Idx], 1, 254);
                                ResultItem.SearchString := Copy(FSearch, 1, 254);
                                if Assigned(FOnSearchEvent) then
                                  FOnSearchEvent(Self, setItemFound, '', ResultItem);

                                Delete(Line, 1, SPos);

                                if Terminated then
                                begin
                                  Halted := True;
                                  Break;
                                end;
                                if not (soCaseSensitive in FOptions) then
                                begin
                                  SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                                end
                                else
                                  SPos := Pos(FSearch, Line);
                              end;
                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if Halted then
                                Break;
                              Application.ProcessMessages;
                            end;
                            if Halted then
                              Break;
                            Q1.Next;
                            Application.ProcessMessages;
                          end;
                          Q1.Close;
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
												end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;

                  //views
                  if not Halted then
                  begin
                    if soViews in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$relation_name from rdb$relations where (rdb$system_flag <> 1 or rdb$system_flag is null) and rdb$view_source is not null;');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$relation_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        if soNamesOnly in FOptions then
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$relation_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
														begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctView;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                        end
                        else
                        begin
                          //name
													L.Text := AdjustLineBreaks(Q.FieldByName('rdb$relation_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctView;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
														begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;

                          Q1.SQL.Text := 'select rdb$field_name from rdb$relation_fields where rdb$relation_name = ''' + Q.FieldByName('rdb$relation_name').AsString + '''';
                          Q1.Open;
                          while not Q1.EOF do
                          begin
                            //source
                            L.Text := AdjustLineBreaks(Q1.FieldByName('rdb$field_name').AsString);
                            for Idx := 0 to L.Count - 1 do
                            begin
                              Line := L[Idx];
                              LinePosition := 0;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                              while SPos <> 0 do
                              begin
                                ResultItem.Line := Idx;
                                LinePosition := LinePosition + SPos;
                                ResultItem.Position := LinePosition;
                                ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                                ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                                ResultItem.ObjType := ctView;
                                ResultItem.LineText := Copy(L[Idx], 1, 254);
                                ResultItem.SearchString := Copy(FSearch, 1, 254);
                                if Assigned(FOnSearchEvent) then
                                  FOnSearchEvent(Self, setItemFound, '', ResultItem);

                                Delete(Line, 1, SPos);

                                if Terminated then
                                begin
                                  Halted := True;
                                  Break;
                                end;
                                if not (soCaseSensitive in FOptions) then
                                begin
                                  SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                                end
                                else
                                  SPos := Pos(FSearch, Line);
                              end;
                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if Halted then
                                Break;
                              Application.ProcessMessages;  
                            end;
                            if Halted then
                              Break;
                            Q1.Next;
                          end;
                          Q1.Close;
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
									end;

                  //generators
                  if not Halted then
                  begin
                    if soGenerators in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$generator_name from rdb$generators where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$generator_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        L.Text := AdjustLineBreaks(FCurrentItem.ItemName);
                        for Idx := 0 to L.Count - 1 do
                        begin
                          Line := L[Idx];
                          LinePosition := 0;
                          if not (soCaseSensitive in FOptions) then
                          begin
                            SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                          end
                          else
                            SPos := Pos(FSearch, Line);
                          while SPos <> 0 do
                          begin
                            ResultItem.Line := Idx;
                            LinePosition := LinePosition + SPos;
                            ResultItem.Position := LinePosition;
                            ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                            ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                            ResultItem.ObjType := ctGenerator;
                            ResultItem.LineText := Copy(L[Idx], 1, 254);
                            ResultItem.SearchString := Copy(FSearch, 1, 254);
                            if Assigned(FOnSearchEvent) then
															FOnSearchEvent(Self, setItemFound, '', ResultItem);

                            Delete(Line, 1, SPos);

                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                          end;
                          if Terminated then
                          begin
                            Halted := True;
                            Break;
                          end;
                          if Halted then
                            Break;
                          Application.ProcessMessages;  
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;
                  //exceptions
                  if not Halted then
									begin
                    if soExceptions in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$exception_name, rdb$message from rdb$exceptions where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
                      while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$exception_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        if soNamesOnly in FOptions then
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$exception_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctException;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                        end
                        else
                        begin
                          //name
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$exception_name').AsString);
                          for Idx := 0 to L.Count - 1 do
                          begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
														while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctException;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                          //source
                          L.Text := AdjustLineBreaks(Q.FieldByName('rdb$message').AsString);
                          for Idx := 0 to L.Count - 1 do
													begin
                            Line := L[Idx];
                            LinePosition := 0;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                            while SPos <> 0 do
                            begin
                              ResultItem.Line := Idx;
                              LinePosition := LinePosition + SPos;
                              ResultItem.Position := LinePosition;
                              ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                              ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                              ResultItem.ObjType := ctException;
                              ResultItem.LineText := Copy(L[Idx], 1, 254);
                              ResultItem.SearchString := Copy(FSearch, 1, 254);
                              if Assigned(FOnSearchEvent) then
                                FOnSearchEvent(Self, setItemFound, '', ResultItem);

                              Delete(Line, 1, SPos);

                              if Terminated then
                              begin
                                Halted := True;
                                Break;
                              end;
                              if not (soCaseSensitive in FOptions) then
                              begin
                                SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                              end
                              else
                                SPos := Pos(FSearch, Line);
                            end;
                            if Terminated then
                            begin
                              Halted := True;
															Break;
                            end;
                            if Halted then
                              Break;
                            Application.ProcessMessages;  
                          end;
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;
                  //UDFS
                  if not Halted then
                  begin
                    if soUDFs in FOptions then
                    begin
                      Q.Close;
                      Q.SQL.Clear;
                      Q.SQL.Add('select rdb$function_name from rdb$functions where (rdb$system_flag <> 1 or rdb$system_flag is null);');
                      Q.Open;
											while not Q.EOF do
                      begin
                        FCurrentItem.ItemName := Q.FieldByName('rdb$function_name').AsString;
                        StatusItem := 'Seaching "' + FCurrentItem.ItemName + '"...';
                        SetStatus(StatusItem);

                        L.Text := AdjustLineBreaks(FCurrentItem.ItemName);
                        for Idx := 0 to L.Count - 1 do
                        begin
                          Line := L[Idx];
                          LinePosition := 0;
													if not (soCaseSensitive in FOptions) then
                          begin
                            SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                          end
                          else
                            SPos := Pos(FSearch, Line);
                          while SPos <> 0 do
                          begin
                            ResultItem.Line := Idx;
                            LinePosition := LinePosition + SPos;
                            ResultItem.Position := LinePosition;
                            ResultItem.ObjName := Copy(FCurrentItem.ItemName, 1, 254);
                            ResultItem.ConnectionName := ParseSection(FConnectionList[DBCOunt], 1, #9);
                            ResultItem.ObjType := ctUDF;
                            ResultItem.LineText := Copy(L[Idx], 1, 254);
                            ResultItem.SearchString := Copy(FSearch, 1, 254);
                            if Assigned(FOnSearchEvent) then
                              FOnSearchEvent(Self, setItemFound, '', ResultItem);

                            Delete(Line, 1, SPos);

                            if Terminated then
                            begin
                              Halted := True;
                              Break;
                            end;
                            if not (soCaseSensitive in FOptions) then
                            begin
                              SPos := Pos(AnsiUpperCase(FSearch), AnsiUpperCase(Line));
                            end
                            else
                              SPos := Pos(FSearch, Line);
                          end;
                          if Terminated then
                          begin
                            Halted := True;
                            Break;
                          end;
                          if Halted then
														Break;
                          Application.ProcessMessages;  
                        end;
                        if Terminated then
                        begin
                          Halted := True;
                          Break;
                        end;
                        if Halted then
                          Break;
                        Q.Next;
                        Application.ProcessMessages;
                      end;
                    end;
                  end;

                  if not Halted then
                  begin
                    if soDoco in FOptions then
                    begin


                    end;
                  end;
                finally
                  L.Free;
                end;
              finally
                //nothing
              end;
            finally
              Q.Free;
              Q1.Free;
            end;
            if XAct.InTransaction then
              XAct.Commit;
          end;
        finally
          Xact.Commit;
				end;
      finally
        XAct.Free;
        DB.Free;
      end;
    except
      On E : Exception do
      begin
        if Assigned(FOnSearchEvent) then
          FOnSearchEvent(Self, setError, E.Message, Dummy);
      end;
    end;
  finally
    if Assigned(FOnSearchEvent) then
      FOnSearchEvent(Self, setFinish, '', Dummy);
    FSearching := False;  
  end;
end;

destructor TMDSearchObject.Destroy;
begin
  FConnectionList.Free;
  inherited;
end;

end.


