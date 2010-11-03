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
// $Id: DDLExtractor.pas,v 1.4 2006/10/19 03:59:40 rjmills Exp $

unit DDLExtractor;

interface

uses
  Windows, Forms, Controls, SysUtils, Classes, IBDatabase, IBCustomDataSet,
  IBQuery, IBSQL, IBHeader, DB, Globals, DOM, xmlread, xmlwrite,
  MarathonProjectCacheTypes, StrUtils;

type
  TDDLObjectType = (
    ddlDomain,
    ddlTable,
    ddlView,
    ddlTableData,
    ddlGenerator,
    ddlException,
    ddlUDF,
    ddlStoredProc,
    ddlTrigger
    );

  TDDLSubType = (
    ddlstNone,
    ddlstPrimaryKey,
    ddlstForeignKey,
    ddlstIndex,
    ddlstGenerator,
    ddlstGeneratorVal,
    ddlstProc,
    ddlstHeader,
    ddlstDoco,
    ddlstGrants
    );

  TDDLObjectAtom = class(TObject)
  private
    FObjectName: String;
    FObjectType: TGSSCacheType;
  public
    property ObjectName : String read FObjectName write FObjectName;
    property ObjectType : TGSSCacheType read FObjectType write FObjectType;
  end;

  TOnDataEvent = procedure(Sender : TObject; Line : String; NoWrap : Boolean; var Stop : Boolean) of object;
  TOnStatusEvent = procedure(Sender : TObject; Line : String) of object;

  TDDLExtractor = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FOnData: TOnDataEvent;
    FDecimals: Integer;
    FDecSeparator: String;
    FIsIB6: Boolean;
    FSQLDIalect: Integer;
    FOnStatus: TOnStatusEvent;
    FIncludeDoc: Boolean;
    function ExtractGenerator(ObjectName : String) : String;
    function ExtractGeneratorValue(ObjectName : String) : String;
    function ExtractDomain(ObjectName : String) : String;
    function ExtractTable(ObjectName : String) : String;
    function ExtractTablePK(ObjectName : String) : String;
    function ExtractTableFK(ObjectName : String) : String;
    function ExtractTableIDX(ObjectName : String) : String;
    function ExtractTableData(ObjectName : String) : String;
    function ExtractView(ObjectName : String) : String;
    function ExtractException(ObjectName : String) : String;
    function ExtractUDF(ObjectName : String) : String;
    function ExtractStoredProcedure(ObjectName : String) : String;
    function ExtractStoredProcedureHeader(ObjectName : String) : String;
    function ExtractStoredProcedureDoco(ObjectName : String) : String;
    function ExtractTrigger(ObjectName : String) : String;
    function ExtractTriggerDoco(ObjectName : String) : String;
    function ExtractRelationGrants(ObjectName : String) : String;
    function ExtractProcedureGrants(ObjectName : String) : String;
    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    function ConvertBinary(Stream : TStream) : String;
    procedure HexToBinary(Stream: TStream; OutStream : TStream);
    function GetDBCharSetName(CharSetID: Integer): String;
    function GetDBCollationName(CollationID, CharSetID: Integer): String;
  public
    property Database : TIBDatabase read FDatabase write SetDatabase;
    property Transaction : TIBTransaction read FTransaction write SetTransaction;
    property OnData : TOnDataEvent read FOnData write FOnData;
    property OnStatus : TOnStatusEvent read FOnStatus write FOnStatus;
    function Extract(ObjectType : TDDLObjectType; ObjectSubType : TDDLSubType; ObjectName : String) : String;
    property ExDecimalPlaces : Integer read FDecimals write FDecimals;
    property ExDecimalSeparator : String read FDecSeparator write FDecSeparator;
    property IncludeDoc : Boolean read FIncludeDoc write FIncludeDoc;
    property SQLDialect : Integer read FSQLDIalect write FSQLDialect;
    property IsInterbase6 : Boolean read FIsIB6 write FIsIB6;
  end;

implementation

{ TDDLExtractor }



function TDDLExtractor.GetDBCharSetName(CharSetID: Integer): String;
var
  Q : TIBDataSet;
  CharSet : String;

begin
  Q := TIBDataSet.Create(nil);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    Q.SelectSQL.Add('select rdb$character_set_name from rdb$character_sets where rdb$character_set_id = ' + IntToStr(CharSetID));
    Q.Open;
    if not (Q.EOF and Q.BOF) then
      CharSet := Trim(Q.FieldByName('rdb$character_set_name').AsString)
    else
      CharSet := '';
    Q.Close;

    if (CharSet <> '') and (AnsiUpperCase(CharSet) <> 'NONE') then
    begin
      Result := CharSet;
    end
    else
      Result := '';
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.GetDBCollationName(CollationID : Integer; CharSetID: Integer): String;
var
  Q : TIBDataSet;
  CharSet : String;

begin
  Q := TIBDataSet.Create(nil);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    Q.SelectSQL.Add('select rdb$collation_name from rdb$collations where rdb$character_set_id = ' + IntToStr(CharSetID) + ' and rdb$collation_id = ' + IntToStr(CollationID));
    Q.Open;
    if not (Q.EOF and Q.BOF) then
      CharSet := Trim(Q.FieldByName('rdb$collation_name').AsString)
    else
      CharSet := '';
    Q.Close;

    if (CharSet <> '') and (AnsiUpperCase(CharSet) <> 'NONE') then
    begin
      Result := CharSet;
    end
    else
      Result := '';
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ConvertBinary(Stream : TStream) : String;
const
  BytesPerLine = 32;

var
  MultiLine: Boolean;
  I: Integer;
  Count: Longint;
  Buffer: array[0..BytesPerLine - 1] of Char;
  Text: array[0..BytesPerLine * 2 - 1] of Char;

begin
  Result := '{';
  Count := Stream.Size;
  MultiLine := Count >= BytesPerLine;
  while Count > 0 do
  begin
    if MultiLine then
      Result := Result + #13#10;
    if Count >= 32 then
      I := 32
    else
      I := Count;
    Stream.Read(Buffer, I);
    BinToHex(Buffer, Text, I);
    Result := Result + String(Text);
    Dec(Count, I);
  end;
  Result := Result + '}';
end;


procedure TDDLExtractor.HexToBinary(Stream: TStream; OutStream : TStream);
var
  Count: Integer;
  Buffer: array[0..255] of Char;
  FSourcePtr : PChar;
  Source : String;
  Temp : String;
  Loop : Integer;

begin
  FSourcePtr := StrAlloc(Stream.Size);
  try
    Stream.ReadBuffer(FSourcePtr^, Stream.Size);
    Source := String(FSourcePtr);
  finally
    StrDispose(FSourcePtr);
  end;

  if Length(Source) > 0 then
  begin
    Loop := 1;
    Temp := '';
    while True do
    begin
      if Source[Loop] = #13 then
      begin
        FSourcePtr := StrAlloc(Length(Temp));
        try
          Count := HexToBin(FSourcePtr, Buffer, SizeOf(Buffer));
          OutStream.Write(Buffer, Count);
        finally
          StrDispose(FSourcePtr);
        end;
        Inc(Loop, 2); //cope with the line feed...
        if Loop > Length(Source) then
          Break;
        Temp := '';
      end
      else
      begin
        Temp := Temp + Source[Loop];
        Inc(Loop);
        if Loop > Length(Source) then
        begin
          FSourcePtr := StrAlloc(Length(Temp));
          try
            Count := HexToBin(FSourcePtr, Buffer, SizeOf(Buffer));
            OutStream.Write(Buffer, Count);
          finally
            StrDispose(FSourcePtr);
          end;
          Break;
        end;
      end;
    end;
  end;
end;


function TDDLExtractor.Extract(ObjectType: TDDLObjectType; ObjectSubType : TDDLSubType;
  ObjectName: String): String;
begin
  Screen.Cursor := crHourglass;
  try
    Result := '';
    case ObjectType of
      ddlDomain :
        begin
          Result := ExtractDomain(ObjectName);
        end;
      ddlTable :
        begin
          case ObjectSubType of
            ddlstNone : Result := ExtractTable(ObjectName);
            ddlstPrimaryKey : Result := ExtractTablePK(ObjectName);
            ddlstForeignKey : Result := ExtractTableFK(ObjectName);
            ddlstIndex : Result := ExtractTableIDX(ObjectName);
            ddlstGrants : Result := ExtractRelationGrants(ObjectName);
          end;
        end;
      ddlTableData :
        begin
          Result := ExtractTableData(ObjectName);
        end;
      ddlView :
        begin
          case ObjectSubType of
            ddlstGrants : Result := ExtractRelationGrants(ObjectName);
          else
            Result := ExtractView(ObjectName);
          end;
        end;
      ddlGenerator :
        begin
          case ObjectSubType of
            ddlstGenerator, ddlstNone:
              Result := ExtractGenerator(ObjectName);
            ddlstGeneratorVal:
              Result := ExtractGeneratorValue(ObjectName);
          end;
        end;
      ddlException:
        begin
          Result := ExtractException(ObjectName);
        end;
      ddlUDF:
        begin
          Result := ExtractUDF(ObjectName);
        end;
      ddlStoredProc:
        begin
          case ObjectSubType of
            ddlstNone, ddlstProc:
              Result := ExtractStoredProcedure(ObjectName);

            ddlstHeader :
              Result := ExtractStoredProcedureHeader(ObjectName);

            ddlstGrants :
              Result := ExtractProcedureGrants(ObjectName);

            ddlstDoco :
              Result := ExtractStoredProcedureDoco(ObjectName);
          end;
        end;
      ddlTrigger:
        begin
          case ObjectSubType of
            ddlstNone :
              Result := ExtractTrigger(ObjectName);
            ddlstDoco :
              Result := ExtractTriggerDoco(ObjectName);
          end;
        end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;    
end;


function TDDLExtractor.ExtractDomain(ObjectName: String): String;
var
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Line : String;
  CharSet : String;
  Collation : String;
  Dimensions : Integer;
  Idx : Integer;
  ArrayStuff : String;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  Q1 := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    Q.Close;
    Q.SelectSQL.Clear;
    Q.SelectSQL.Add('select * from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(ObjectName, ''''));
    Q.Open;
    if Not Q.EOF and Q.BOF then
    begin
      Line := 'create domain ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$field_name').AsString), FISIb6, FSQLDialect) + ' as ';
      if FIsIB6 and (FSQLDIalect = 3) then
      begin
        Line := Line + (ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                         Q.FieldByName('rdb$field_length').AsInteger,
                                         Q.FieldByName('rdb$field_scale').AsInteger,
                                         Q.FieldByName('rdb$field_sub_type').AsInteger,
                                         Q.FieldByName('rdb$field_precision').AsInteger,
                                         True));
      end
      else
      begin
        Line := Line + (ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                         Q.FieldByName('rdb$field_length').AsInteger,
                                         Q.FieldByName('rdb$field_scale').AsInteger,
                                         -1,
                                         -1,
                                         False));
      end;
      if Q.FieldByName('rdb$field_type').AsInteger = blr_blob then
      begin
        Line := Line + ' sub_type ' + Trim(Q.FieldByName('rdb$field_sub_type').AsString) +
                       ' segment size ' + Trim(Q.FieldByName('rdb$segment_length').AsString);
      end;

      if Q.FieldByName('rdb$dimensions').AsInteger > 0 then
      begin
        ArrayStuff := '[';
        Dimensions := Q.FieldByName('rdb$dimensions').AsInteger;
        for Idx := 0 to Dimensions do
        begin
          Q1.Close;
          Q1.SelectSQL.Clear;
          Q1.SelectSQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
                        'rdb$dimension = ' + IntToStr(Idx)  + 'and rdb$field_name = ' + AnsiQuotedStr(ObjectName,''''));
          Q1.Open;
          if not (Q1.EOF and Q1.BOF) then
          begin
            ArrayStuff := ArrayStuff + Trim(Q1.FieldByName('rdb$lower_bound').AsString) + ':' + Trim(Q1.FieldByName('rdb$upper_bound').AsString) + ', ';
          end;
        end;
        ArrayStuff := Trim(ArrayStuff);
        if ArrayStuff[Length(ArrayStuff)] = ',' then
          ArrayStuff := Copy(ArrayStuff, 1, Length(ArrayStuff) - 1);
        ArrayStuff := ArrayStuff + ']';

        Line := Line + ' ' + ArrayStuff;
      end;

      CharSet := GetDBCharSetName(Q.FieldByName('rdb$character_set_id').AsInteger);
      if CharSet <> '' then
      begin
        Line := Line + ' character set ' + CharSet;
      end;

      if Trim(Q.FieldByName('rdb$default_source').AsString) <> '' then
        Line := Line + ' ' + Trim(Q.FieldByName('rdb$default_source').AsString);

      if Trim(Q.FieldByName('rdb$validation_source').AsString) <> '' then
        Line := Line + ' ' + Trim(Q.FieldByName('rdb$validation_source').AsString);

      if Not Q.FieldByName('rdb$null_flag').IsNull then
        Line := Line + ' not null';

      Collation := GetDBCollationName(Q.FieldByName('rdb$collation_id').AsInteger, Q.FieldByName('rdb$character_set_id').AsInteger);
      if Collation <> '' then
      begin
        Line := Line + ' collate ' + Collation;
      end;

      Line := Line + ';' + #13#10;

      if FIncludeDoc Then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$fields set rdb$description = ?desc where rdb$field_name = ' + AnsiQuotedStr(ObjectName,''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;
      Result := Line;
    end;
  finally
    Q.Free;
    Q1.Free;
  end;
end;

function TDDLExtractor.ExtractException(ObjectName: String): String;
var
  Q : TIBDataSet;
  Line : String;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select * from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q.Open;
    if Not Q.EOF and Q.BOF then
    begin
      Line := 'create exception ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$exception_name').AsString), FIsIB6, FSQLDialect) + ' ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$message').AsString), '''') + ';';
      Result := Line + #13#10;

      if FIncludeDoc Then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$exceptions set rdb$description = ?desc where rdb$exception_name = ' + AnsiQuotedStr(ObjectName, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;  
      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractGenerator(ObjectName : String): String;
begin
  Result := 'create generator ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ';';
end;

function TDDLExtractor.ExtractGeneratorValue(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Line : String;

begin
  Result := '';
  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;

    Q1.SelectSQL.Text := 'select gen_id(' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ', 0) as current_val from rdb$database';
    Q1.Open;
    Line := 'set generator ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' to ' + Trim(Q1.FieldByName('current_val').AsString) + ';';
    Result := Line;
    Q1.Close;
  finally
    Q1.Free;
  end;
end;

function ConvertPriv(Priv : String) : String;
begin
  Result := Priv;

  if Priv = 'A' then
    Result := 'ALL';

  if Priv = 'S' then
    Result := 'SELECT';

  if Priv = 'I' then
    Result := 'INSERT';

  if Priv = 'U' then
    Result := 'UPDATE';

  if Priv = 'D' then
    Result := 'DELETE';

  if Priv = 'X' then
    Result := 'EXECUTE';

  if Priv = 'R' then
    Result := 'REFERENCES';

end;

function TDDLExtractor.ExtractProcedureGrants(ObjectName: String): String;
var
  Q : TIBDataSet;
  Tmp : String;
  UserList : TStringList;
  Idx : Integer;
  User, Priv : String;
  Grant : String;

begin
  Result := '';
  Grant := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    UserList := TStringList.Create;
    try
      Q.SelectSQL.Add('select rdb$user, rdb$privilege, rdb$grant_option from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
      Q.Open;
      While not Q.EOF do
      begin
        Tmp := Trim(Q.FieldByName('rdb$user').AsString) + ':' + Trim(Q.FieldByName('rdb$privilege').AsString);
        if Q.FieldByName('rdb$grant_option').AsInteger = 1 then
          Tmp := Tmp + ':with grant option'
        else
          Tmp := Tmp + ':';

        if UserList.IndexOf(Tmp) = -1 then
          UserList.Add(Tmp);
        Q.Next;
      end;
      Q.Close;

      for Idx := 0 to UserList.Count - 1 do
      begin
        User := ParseSection(UserList[Idx], 1, ':');
        Priv := ParseSection(UserList[Idx], 2, ':');
        Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv))  + ' on ' + ifthen(Priv='X','procedure ','') + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;
      end;
    finally
      UserList.Free;
    end;
  finally
    Q.Free;
  end;

  Result := Grant;
end;

function TDDLExtractor.ExtractRelationGrants(ObjectName: String): String;
var
  Q : TIBDataSet;
  Tmp : String;
  UserList : TStringList;
  Idx : Integer;
  User, Priv : String;
  Grant : String;
  ColList : String;

begin
  Result := '';
  Grant := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    UserList := TStringList.Create;
    try
      Q.SelectSQL.Add('select rdb$user, rdb$privilege, rdb$grant_option from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
      Q.Open;
      While not Q.EOF do
      begin
        Tmp := Trim(Q.FieldByName('rdb$user').AsString) + ':' + Trim(Q.FieldByName('rdb$privilege').AsString);
        if Q.FieldByName('rdb$grant_option').AsInteger = 1 then
          Tmp := Tmp + ':with grant option'
        else
          Tmp := Tmp + ':';

        if UserList.IndexOf(Tmp) = -1 then
          UserList.Add(Tmp);
        Q.Next;
      end;
      Q.Close;

      for Idx := 0 to UserList.Count - 1 do
      begin
        User := ParseSection(UserList[Idx], 1, ':');
        Priv := ParseSection(UserList[Idx], 2, ':');
        if (Priv = 'U') or (Priv = 'R') then
        begin
          ColList := '';
          Q.SelectSQL.Clear;
          Q.SelectSQL.Add('select rdb$field_name from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' and rdb$privilege = ''' + Priv + ''' and rdb$user = ''' + User + ''';');
          Q.Open;
          While not Q.EOF do
          begin
            ColList := ColList + MakeQuotedIdent(Trim(Q.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect) + ', ';
            Q.Next;
          end;
          Q.Close;

          ColList := Trim(ColList);
          if Length(ColList) > 0 then
            if ColList[Length(ColList)] = ',' then
              ColList := Copy(ColList, 1, Length(ColList) - 1);


          if ColList = '' then
            Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv)) + ' on ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10
          else
            Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv)) + '(' + ColList + ') on ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;

        end
        else
        begin
          Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv))  + ' on ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;
        end;
      end;
    finally
      UserList.Free;
    end;
  finally
    Q.Free;
  end;

  Result := Grant;
end;

function TDDLExtractor.ExtractStoredProcedureDoco(
  ObjectName: String): String;
var
  Line : String;
  Q : TIBDataSet;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q.Open;
    If Not (Q.EOF and Q.BOF) then
    begin
      if FIncludeDoc then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$procedures set rdb$description = ?desc where rdb$procedure_name = ' + AnsiQuotedStr(Q.FieldByName('rdb$procedure_name').AsString, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;  
      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractStoredProcedureHeader(ObjectName: String): String;
var
  Line : String;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  First : Boolean;
  Tmp : String;
  Alter : String;
  CharSet : String;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q.Open;
    If Not (Q.EOF and Q.BOF) then
    begin
      Alter := 'create';

      Line := Alter + ' procedure ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$procedure_name').AsString), FIsIB6, FSQLDialect) + ' ';
      Q1 := TIBDataSet.Create(Self);
      try
        Q1.Database := Q.Database;
        Q1.Transaction := FTransaction;

        if FIsIB6 and (FSQLDIalect = 3) then
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end;
        Q1.Open;
        If Not (Q1.EOF and Q1.BOF) Then
        begin
          Line := Line + '(';
          First := True;
          while not Q1.EOF do
          begin
            if First then
              Line := Line + ''
            else
              Line := Line + ', ';
            First := False;
            if FIsIB6 and (FSQLDialect = 3) then
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              -1,
                                              -1,
                                              False);
            end;

            CharSet := GetDBCharSetName(Q1.FieldByName('rdb$character_set_id').AsInteger);
            if CharSet <> '' then
            begin
              Line := Line + ' character set ' + CharSet;
            end;
            Q1.Next;
          end;
          Line := Line + ')';
        end;

        Q1.Close;
        Q1.SelectSQL.Clear;
        if FIsIB6 and (FSQLDialect = 3) then
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end;
        Q1.Open;
        If Not (Q1.EOF and Q1.BOF) Then
        begin
          Line := Line + #13#10;
          Line := Line + 'returns (';
          First := True;
          while not Q1.EOF do
          begin
            if First then
              Line := Line + ''
            else
              Line := Line + ', ';
            First := False;
            if FIsIB6 and (FSQLDialect = 3) then
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              -1,
                                              -1,
                                              False);
            end;

            CharSet := GetDBCharSetName(Q1.FieldByName('rdb$character_set_id').AsInteger);
            if CharSet <> '' then
            begin
              Line := Line + ' character set ' + CharSet;
            end;
            Q1.Next;
          end;
          Line := Line + ')';
        end;
        Q1.Close;
      finally
        Q1.Free;
      end;

      //wrap to the ~80th col
      Line := WrapText(Line, #13#10, [' ', #9], 79);

      Line := Line + #13#10;
      Line := Line + 'as' + #13#10;
      Tmp := 'begin  exit;  end';
      Line := Line + Tmp;
      Line := Line + #13#10;

      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractStoredProcedure(ObjectName: String): String;
var
  Line : String;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  First : Boolean;
  Tmp : String;
  Alter : String;
  CharSet : String;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q.Open;
    If Not (Q.EOF and Q.BOF) then
    begin
      Alter := 'alter';

      Line := Alter + ' procedure ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$procedure_name').AsString), FIsIB6, FSQLDialect) + ' ';
      Q1 := TIBDataSet.Create(Self);
      try
        Q1.Database := Q.Database;
        Q1.Transaction := FTransaction;

        if FIsIB6 and (FSQLDialect = 3) then
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end;
        Q1.Open;
        If Not (Q1.EOF and Q1.BOF) Then
        begin
          Line := Line + '(';
          First := True;
          while not Q1.EOF do
          begin
            if First then
              Line := Line + ''
            else
              Line := Line + ', ';
            First := False;
            if FIsIB6 and (FSQLDialect = 3) then
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              -1,
                                              -1,
                                              False);
            end;

            CharSet := GetDBCharSetName(Q1.FieldByName('rdb$character_set_id').AsInteger);
            if CharSet <> '' then
            begin
              Line := Line + ' character set ' + CharSet;
            end;
            Q1.Next;
          end;
          Line := Line + ')';
        end;

        Q1.Close;
        Q1.SelectSQL.Clear;
        if FIsIB6 and (FSQLDialect = 3) then
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + ' order by rdb$parameter_number asc;');
        end;
        Q1.Open;
        If Not (Q1.EOF and Q1.BOF) Then
        begin
          Line := Line + #13#10;
          Line := Line + 'returns (';
          First := True;
          while not Q1.EOF do
          begin
            if First then
              Line := Line + ''
            else
              Line := Line + ', ';
            First := False;
            if FIsIB6 and (FSQLDialect = 3) then
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              -1,
                                              -1,
                                              False);
            end;

            CharSet := GetDBCharSetName(Q1.FieldByName('rdb$character_set_id').AsInteger);
            if CharSet <> '' then
            begin
              Line := Line + ' character set ' + CharSet;
            end;
            Q1.Next;
          end;
          Line := Line + ')';
        end;
        Q1.Close;
      finally
        Q1.Free;
      end;

      //wrap to the ~80th col
      Line := WrapText(Line, #13#10, [' ', #9], 79);

      Line := Line + #13#10;
      Line := Line + 'as' + #13#10;
      Tmp := AdjustLineBreaks(Trim(Q.FieldByName('rdb$procedure_source').AsString));
      Line := Line + Tmp;
      Line := Line + #13#10;

      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;


function TDDLExtractor.ExtractTable(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Q2 : TIBDataSet;
  First : Boolean;
  Line : String;
  Output : TStringList;
  CharSet : String;
  Collation : String;
  Dimensions : Integer;
  Idx : Integer;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;

begin
  Result := '';
  OutPut := TStringList.Create;
  try
    Q1 := TIBDataSet.Create(Self);
    Q2 := TIBDataSet.Create(Self);
    try
      Q1.Database := FDatabase;
      Q1.Transaction := FTransaction;
      Q2.Database := FDatabase;
      Q2.Transaction := FTransaction;

      if FIsIB6 and (FSQLDialect = 3) then
      begin
        Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
                   'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
                   'b.rdb$character_set_id, b.rdb$collation_id as fcollate, a.rdb$collation_id as tcollate, ' +
                   'b.rdb$computed_source, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, ' +
                   'b.rdb$field_sub_type, b.rdb$segment_length, ' +
                   'b.rdb$field_type, b.rdb$dimensions from rdb$relation_fields a, rdb$fields b where ' +
                   'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
                    AnsiQuotedStr(ObjectName, '''') + ' order by a.rdb$field_position asc;');
      end
      else
      begin
        Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
                   'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
                   'b.rdb$character_set_id, b.rdb$collation_id as fcollate, a.rdb$collation_id as tcollate, ' +
                   'b.rdb$computed_source, b.rdb$field_length, b.rdb$field_scale, ' +
                   'b.rdb$field_sub_type, b.rdb$segment_length, ' +
                   'b.rdb$field_type, b.rdb$dimensions from rdb$relation_fields a, rdb$fields b where ' +
                   'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
                    AnsiQuotedStr(ObjectName, '''') + ' order by a.rdb$field_position asc;');

      end;
      Q1.Open;
      First := True;
      Line := 'create table ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + '(' + #13#10;
      While Not Q1.EOF do
      begin
        if First then
          Line := Line + '     '
        else
          Line := Line + ',' + #13#10 + '     ';
        First := False;
        Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$field_name').AsString), FIsIb6, FSQLDialect) + ' ';
        if Trim(Q1.FieldByName('rdb$computed_source').AsString) <> '' then
        begin
          Line := Line + 'computed by ' + Trim(Q1.FieldByName('rdb$computed_source').AsString);
        end
        else
        begin
          if AnsiUpperCase(Copy(Trim(Q1.FieldByName('rdb$field_source').AsString), 1, 4)) = 'RDB$' then
          begin
            if FIsIB6 and (FSQLDialect = 3) then
            begin
              Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              Q1.FieldByName('rdb$field_length').AsInteger,
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              -1,
                                              -1,
                                              False);
            end;

            if Q1.FieldByName('rdb$dimensions').AsInteger > 0 then
            begin
              Line := Line + '[';
              Dimensions := Q1.FieldByName('rdb$dimensions').AsInteger;
              for Idx := 0 to Dimensions do
              begin
                Q2.Close;
                Q2.SelectSQL.Clear;
                Q2.SelectSQL.Add('select rdb$lower_bound, rdb$upper_bound from rdb$field_dimensions where ' +
                           'rdb$dimension = ' + IntToStr(Idx)  + 'and rdb$field_name = ' + AnsiQuotedStr(Trim(Q1.FieldByName('rdb$field_source').AsString), ''''));
                Q2.Open;
                if not (Q2.EOF and Q2.BOF) then
                begin
                  Line := Line + Trim(Q2.FieldByName('rdb$lower_bound').AsString) + ':' + Trim(Q2.FieldByName('rdb$upper_bound').AsString) + ', ';
                end;
              end;
              Line := Trim(Line);
              if Line[Length(Line)] = ',' then
                Line := Copy(Line, 1, Length(Line) - 1);
              Line := Line + ']';
            end;

            if Q1.FieldByName('rdb$field_type').AsInteger = blr_blob then
            begin
              Line := Line + ' sub_type ' + Trim(Q1.FieldByName('rdb$field_sub_type').AsString) +
                             ' segment size ' + Trim(Q1.FieldByName('rdb$segment_length').AsString);
            end;

            CharSet := GetDBCharSetName(Q1.FieldByName('rdb$character_set_id').AsInteger);
            if CharSet <> '' then
            begin
              Line := Line + ' character set ' + CharSet;
            end;

            if Trim(Q1.FieldByName('rdb$default_source').AsString) <> '' then
              Line := Line + ' ' + Trim(Q1.FieldByName('rdb$default_source').AsString);

            if Not (Q1.FieldByName('tnull_flag').IsNull and Q1.FieldByName('fnull_flag').IsNull) then
              Line := Line + ' not null';

            Collation := GetDBCollationName(Q1.FieldByName('tcollate').AsInteger, Q1.FieldByName('rdb$character_set_id').AsInteger);
            if Collation <> '' then
            begin
              Line := Line + ' collate ' + Collation;
            end;

          end
          else
          begin
            Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$field_source').AsString), FIsIB6, FSQLDialect);

            if Trim(Q1.FieldByName('rdb$default_source').AsString) <> '' then
              Line := Line + ' ' + Trim(Q1.FieldByName('rdb$default_source').AsString);

            if Not (Q1.FieldByName('tnull_flag').IsNull) then
              Line := Line + ' not null';

            Collation := GetDBCollationName(Q1.FieldByName('tcollate').AsInteger, Q1.FieldByName('rdb$character_set_id').AsInteger);
            if Collation <> '' then
            begin
              Line := Line + ' collate ' + Collation;
            end;
          end;
        end;
        Q1.Next;
      end;
    finally
      Q1.Free;
      Q2.Free;
    end;

    Line := Line + ');';
    OutPut.Text := Line;

    //check constraints
    Q1 := TIBDataSet.Create(Self);
    try
      Q1.Database := FDatabase;
      Q1.Transaction := FTransaction;
      Q1.SelectSQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type = ''CHECK'') ' +
                 'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
      Q1.Open;
      if Not (Q1.EOF and Q1.BOF) then
      begin
        while Not Q1.EOF do
        begin
          OutPut.Add('');
          Q2 := TIBDataSet.Create(Self);
          try
            Q2.Database := FDatabase;
            Q2.Transaction := FTransaction;
            Q2.SelectSQL.Add('select a.rdb$trigger_source from rdb$triggers a, rdb$check_constraints b where a.rdb$trigger_name = b.rdb$trigger_name and b.rdb$constraint_name = ' + AnsiQuotedStr(Trim(Q1.FieldByName('rdb$constraint_name').AsString), '''') + ';');
            Q2.Open;
            Line := 'alter table ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' add constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) + ' ' + AdjustLineBreaks(Trim(Q2.FieldByName('rdb$trigger_source').AsString)) + ';';
            Q2.Close;
            OutPut.Add(Line);
          finally
            Q2.Free;
          end;
          Q1.Next;
        end;
      end;

      Q1.Close;
      Q1.SelectSQL.Text := 'select rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';';
      Q1.Open;
      OutPut.Add('');
      OutPut.Add('');

      if FIncludeDoc then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$relations set rdb$description = ?desc where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q1.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q1.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Output.Add(List[Idx]);
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;  
      Result := OutPut.Text;
    finally
      Q1.Free;
    end;
  finally
    Output.Free;
  end;
end;

function TDDLExtractor.ExtractTableData(ObjectName: String): String;
var
  Q1 : TIBSQL;
  HasBlobs : Boolean;
  Idy : Integer;
  First : Boolean;
  InsertList : String;
  FieldList : String;
  Line : String;
  CompFields : TStringList;
  OldDecimalSeparator : Char;
  ParamList : String;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;
  Stop : Boolean;
  RowCount : Integer;


begin
  Q1 := TIBSQL.Create(Self);
  CompFields := TStringList.Create;
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;

    //get calc column names....

    Q1.SQL.Text := 'select a.rdb$field_name from rdb$relation_fields a, rdb$fields b ' +
                   'where a.rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') +
                   ' and a.rdb$field_source = b.rdb$field_name and ' +
                   'b.rdb$computed_source is not null';
    Q1.ExecQuery;
    while not Q1.EOF do
    begin
      CompFields.Add(MakeQuotedIdent(Trim(Q1.FieldByName('rdb$field_name').AsString), IsInterbase6, SQLDialect));
      Q1.Next;
    end;
    Q1.Close;

    Q1.SQL.Text := 'select * from ' + MakeQuotedIdent(ObjectName, IsInterbase6, SQLDialect);
    Q1.ExecQuery;

    HasBlobs := False;
    for Idy := 0 to Q1.Current.Count - 1 do
    begin
      if (Q1.Fields[Idy].SQLType = SQL_BLOB) then
      begin
        HasBlobs := True;
        Break;
      end;
    end;

    if Not HasBlobs then
    begin
      First := True;
      InsertList := '';
      for Idy := 0 to Q1.Current.Count - 1 do
      begin
        if CompFields.IndexOf(Q1.Fields[Idy].Name) > -1 then
          Continue;

        if First then
          InsertList := InsertList + ''
        else
          InsertList := InsertList + ', ';
        First := False;
        InsertList := InsertList + MakeQuotedIdent(Q1.Fields[Idy].Name, IsInterbase6, SQLDialect);
      end;

      InsertList := 'insert into ' + MakeQuotedIdent(ObjectName, IsInterbase6, SQLDialect) + '(' + InsertList + ') values (';

      RowCount := 0;
      While Not Q1.EOF do
      begin
        RowCount := RowCount + 1;
        if Assigned(FOnStatus) then
          FOnStatus(Self, 'Writing Row (' + IntToStr(RowCount) + ')...');
        First := True;
        FieldList := '';
        for Idy := 0 to Q1.Current.Count - 1 do
        begin
          if CompFields.IndexOf(Q1.Fields[Idy].Name) > -1 then
            Continue;

          if First then
            FieldList := FieldList + ''
          else
            FieldList := FieldList + ', ';
          First := False;
          if Q1.Fields[Idy].IsNull then
          begin
            FieldList := FieldList + 'NULL';
          end
          else
          begin
            case Q1.Fields[Idy].SQLType of
              SQL_VARYING,
              SQL_TEXT :
                FieldList := FieldList + AnsiQuotedStr(Trim(Q1.Fields[Idy].AsString), '''');

              SQL_DOUBLE,
              SQL_FLOAT,
              SQL_D_FLOAT:
                begin
                  OldDecimalSeparator := DecimalSeparator;
                  try
                    DecimalSeparator := FDecSeparator[1];
                    FieldList := FieldList + Trim(Format('%15.' + IntToStr(FDecimals) + 'f', [Q1.Fields[Idy].AsFloat]));
                  finally
                    DecimalSeparator := OldDecimalSeparator;
                  end;
                end;

              SQL_INT64,  
              SQL_LONG,
              SQL_SHORT :
                  FieldList := FieldList + Trim(Q1.Fields[Idy].AsString);


              SQL_DATE :
                FieldList := FieldList + '''' + NoLangFormatDateTime('dd-mmm-yyyy hh:mm:ss', Q1.Fields[Idy].AsDateTime) + '.00''';
              SQL_TYPE_DATE :
                FieldList := FieldList + '''' + NoLangFormatDateTime('dd-mmm-yyyy', Q1.Fields[Idy].AsDateTime) + '''';
              SQL_TYPE_TIME :
                FieldList := FieldList + '''' + NoLangFormatDateTime('hh:mm:ss', Q1.Fields[Idy].AsDateTime) + '''';
            end;
          end;
        end;
        Line := InsertList + FieldList + ');';
        if Assigned(OnData) then
          OnData(Self, Line, True, Stop);
        if Stop then
          Exit;
        Q1.Next;
      end;
    end
    else
    begin
      First := True;
      InsertList := '';
      ParamList := '';
      for Idy := 0 to Q1.Current.Count - 1 do
      begin
        if CompFields.IndexOf(Q1.Fields[Idy].Name) > -1 then
          Continue;

        if First then
        begin
          InsertList := InsertList + '';
          ParamList := ParamList + '';
        end
        else
        begin
          InsertList := InsertList + ', ';
          ParamList := ParamList + ', ';
        end;
        First := False;
        InsertList := InsertList + MakeQuotedIdent(Q1.Fields[Idy].Name, IsInterbase6, SQLDialect);
        ParamList := ParamList + '?' + IntToStr(Idy + 1);
      end;

      InsertList := 'insert into ' + MakeQuotedIdent(ObjectName, IsInterbase6, SQLDialect) + '(' + InsertList + ') values (' + ParamList + ')';

      RowCount := 0;
      While Not Q1.EOF do
      begin
        RowCount := RowCount + 1;
        if Assigned(FOnStatus) then
          FOnStatus(Self, 'Writing Row (' + IntToStr(RowCount) + ')...');

        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', InsertList);

          for Idy := 0 to Q1.Current.Count - 1 do
          begin
            oData := Doc.CreateElement('data-value');
            oXML.AppendChild(oData);
            case Q1.Fields[Idy].SQLType of
              SQL_VARYING,
              SQL_TEXT :
                begin
                  TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
                  TDOMElement(oData).SetAttribute('datatype', 'char');
                  if Q1.Fields[Idy].IsNull then
                    TDOMElement(oData).SetAttribute('value', 'NULL')
                  else
                    TDOMElement(oData).SetAttribute('value', EscapeQuotes(Trim(Q1.Fields[Idy].AsString)));
                end;

              SQL_DOUBLE,
              SQL_FLOAT,
              SQL_D_FLOAT:
                begin
                  TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
                  TDOMElement(oData).SetAttribute('datatype', 'float');
                  if Q1.Fields[Idy].IsNull then
                    TDOMElement(oData).SetAttribute('value', 'NULL')
                  else
                  begin
                    OldDecimalSeparator := DecimalSeparator;
                    try
                      DecimalSeparator := FDecSeparator[1];
                      TDOMElement(oData).SetAttribute('value', Trim(Format('%15.' + IntToStr(FDecimals) + 'f', [Q1.Fields[Idy].AsFloat])));
                    finally
                      DecimalSeparator := OldDecimalSeparator;
                    end;
                  end;
                end;

              SQL_LONG,
              SQL_SHORT :
                begin
                  TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
                  TDOMElement(oData).SetAttribute('datatype', 'int');
                  if Q1.Fields[Idy].IsNull then
                    TDOMElement(oData).SetAttribute('value', 'NULL')
                  else
                    TDOMElement(oData).SetAttribute('value', EscapeQuotes(Trim(Q1.Fields[Idy].AsString)));
                end;

              SQL_DATE :
                begin
                  TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
                  TDOMElement(oData).SetAttribute('datatype', 'datetime');
                  if Q1.Fields[Idy].IsNull then
                    TDOMElement(oData).SetAttribute('value', 'NULL')
                  else
                    TDOMElement(oData).SetAttribute('value', NoLangFormatDateTime('dd-mmm-yyyy hh:mm:ss', Q1.Fields[Idy].AsDateTime) + '.00');
                end;

              SQL_BLOB :
                begin
                  TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
                  TDOMElement(oData).SetAttribute('datatype', 'blob');
                  if Q1.Fields[Idy].IsNull then
                    TDOMElement(oData).SetAttribute('value', 'NULL')
                  else
                  begin
                    List := TStringList.Create;
                    Stream := TMemoryStream.Create;
                    try
                      Q1.Fields[Idy].SaveToStream(Stream);
                      Stream.Position := 0;
                      if Assigned(FOnStatus) then
                        FOnStatus(Self, 'Writing Row (' + IntToStr(RowCount) + ')' + #13#10 + 'Converting blob data...');

                      List.Text := ConvertBinary(Stream);
                      for Idx := 0 to List.Count - 1 do
                      begin
                        oDataLine := Doc.CreateElement('data-line');
                        oData.AppendChild(oDataLine);
                        TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
                      end;
                    finally
                      Stream.Free;
                      List.Free;
                    end;
                  end;
                end;
            else
              TDOMElement(oData).SetAttribute('position', IntToSTr(Idy + 1));
              TDOMElement(oData).SetAttribute('datatype', 'unknown');
              if Q1.Fields[Idy].IsNull then
                TDOMElement(oData).SetAttribute('value', 'NULL')
              else
                TDOMElement(oData).SetAttribute('value', EscapeQuotes(Trim(Q1.Fields[Idy].AsString)));
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              if Assigned(OnData) then
                OnData(Self, List[Idx], True, Stop);
              if Stop then
                Exit;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
          Q1.Next;
        finally
          Doc.Free;
        end;
      end;
    end;
    Q1.Close;
  finally
    Q1.Free;
    CompFields.Free;
  end;
end;


function TDDLExtractor.ExtractTableFK(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Q2 : TIBDataSet;
  First : Boolean;
  Line : String;
  Line1 : String;

begin
  Result := '';
  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    Q1.SelectSQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type = ''FOREIGN KEY'') ' +
               'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    Line := '';
    While Not Q1.EOF do
    begin
      Q2 := TIBDataSet.Create(Self);
      try
        Q2.Database := FDatabase;
        Q2.Transaction := FTransaction;

        //get the local key..
        Q2.SelectSQL.Add('select * from rdb$index_segments where rdb$index_name = ' +
                    AnsiQuotedStr(Trim(Q1.FieldByName('rdb$index_name').AsString), '''') + ' order by rdb$field_position asc;');
        Q2.Open;
        First := True;
        Line1 := '';
        While Not Q2.EOF do
        begin
          if First then
            Line1 := Line1 + ''
          else
            Line1 := Line1 + ', ';
          First := False;
          Line1 := Line1 + MakeQuotedIdent(Trim(Q2.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect);
          Q2.Next;
        end;

        Line := Line + 'alter table ' + MakeQuotedIdent(ObjectName, FIsIB6, FSQLDialect) + ' add constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) + ' foreign key (' + Line1 + ') references ';

        //get the fk relation and field...
        Q2.Close;
        Q2.SelectSQL.Clear;
        Q2.SelectSQL.Add('select rdb$relation_name from rdb$indices where rdb$index_name in ' +
                   '(select rdb$foreign_key from rdb$indices where rdb$index_name  = ' +
                   AnsiQuotedStr(Trim(Q1.FieldByName('rdb$index_name').AsString), '''') + ');');
        Q2.Open;
        Line := Line + MakeQuotedIdent(Trim(Q2.FieldByName('rdb$relation_name').AsString), FIsIb6, FSQLDIalect) + '(';

        Q2.Close;
        Q2.SelectSQL.Clear;
        Q2.SelectSQL.Add('select * from rdb$index_segments where rdb$index_name in ' +
                   '(select rdb$index_name from rdb$indices where rdb$index_name in ' +
                   '(select rdb$foreign_key from rdb$indices where rdb$index_name  = ' +
                    AnsiQuotedStr(Trim(Q1.FieldByName('rdb$index_name').AsString), '''') + ')) order by rdb$field_position asc;');
        Q2.Open;
        First := True;
        Line1 := '';
        While Not Q2.EOF do
        begin
          if First then
            Line1 := Line1 + ''
          else
            Line1 := Line1 + ', ';
          First := False;
          Line1 := Line1 + MakeQuotedIDent(Trim(Q2.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect);
          Q2.Next;
        end;

        Line := Line + Line1 + ')';

        Q2.Close;
        Q2.SelectSQL.Clear;
        Q2.SelectSQL.Add('select rdb$update_rule, rdb$delete_rule from rdb$ref_constraints where rdb$constraint_name = ' +
                    AnsiQuotedStr(Trim(Q1.FieldByName('rdb$constraint_name').AsString), '''') + ';');
        Q2.Open;
        While Not Q2.EOF do
        begin
          if (Trim(Q2.FieldByName('rdb$update_rule').AsString) <> '') and (Trim(Q2.FieldByName('rdb$update_rule').AsString) <> 'RESTRICT') then
            Line := Line + ' on update ' + Trim(Q2.FieldByName('rdb$update_rule').AsString);
          if (Trim(Q2.FieldByName('rdb$delete_rule').AsString) <> '') and (Trim(Q2.FieldByName('rdb$delete_rule').AsString) <> 'RESTRICT') then
            Line := Line + ' on delete ' + Trim(Q2.FieldByName('rdb$delete_rule').AsString);
          Q2.Next;
        end;
        Q2.Close;

        Line := Line + ';' + #13#10;
      finally
        Q2.Free;
      end;
      Q1.Next;
    end;
    Result := Line;
  finally
    Q1.Free;
  end;
end;

function TDDLExtractor.ExtractTableIDX(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Q2 : TIBDataSet;
  First : Boolean;
  Line : String;
  Line1 : String;

begin
  Result := '';
  Line1 := '';
  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    Q1.SelectSQL.Add('select * from rdb$indices where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, ''''));
    Q1.SelectSQL.Add('and not (rdb$index_name in (select rdb$index_name from rdb$relation_constraints where');
    Q1.SelectSQL.Add('rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' and ');
    Q1.SelectSQL.Add('((rdb$constraint_type = ''PRIMARY KEY'') or (rdb$constraint_type = ''FOREIGN KEY''))))');
    Q1.Open;
    While Not Q1.EOF do
    begin
      Q2 := TIBDataSet.Create(Self);
      try
        Q2.Database := FDatabase;
        Q2.Transaction := FTransaction;
        Q2.SelectSQL.Add('select * from rdb$index_segments where rdb$index_name = ' +
                   AnsiQuotedStr(Trim(Q1.FieldByName('rdb$index_name').AsString), '''') + ' order by rdb$field_position asc;');
        Q2.Open;
        First := True;
        Line := '';
        While Not Q2.EOF do
        begin
          if First then
            Line := Line + ''
          else
            Line := Line + ', ';
          First := False;
          Line := Line + MakeQuotedIdent(Trim(Q2.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect);
          Q2.Next;
        end;

        Line1 := Line1 + 'create ';
        if Q1.FieldByName('rdb$unique_flag').AsInteger = 1 then
          Line1 := Line1 + 'unique ';

        if Q1.FieldByName('rdb$index_type').AsInteger = 1 then
          Line1 := Line1 + 'descending ';

        Line1 := Line1 + 'index ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$index_name').AsString), FIsIB6, FSQLDialect) + ' on ' + MakeQuotedIdent(ObjectName, FIsIb6, FSQLDialect);
        Line1 := Line1 + '(' + Line + ');' + #13#10;

      finally
        Q2.Free;
      end;
      Q1.Next;
    end;
    Result := Line1;
  finally
    Q1.Free;
  end;
end;

function TDDLExtractor.ExtractTablePK(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Q2 : TIBDataSet;
  First : Boolean;
  Line : String;

begin
  Result := '';
  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    Q1.SelectSQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type = ''PRIMARY KEY'') ' +
               'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.BOF) then
    begin
      Q2 := TIBDataSet.Create(Self);
      try
        Q2.Database := FDatabase;
        Q2.Transaction := FTransaction;
        Q2.SelectSQL.Add('select * from rdb$index_segments where rdb$index_name = ' +
                    AnsiQuotedStr(Trim(Q1.FieldByName('rdb$index_name').AsString), '''') + ' order by rdb$field_position asc;');
        Q2.Open;
        First := True;
        Line := '';
        While Not Q2.EOF do
        begin
          if First then
            Line := Line + ''
          else
            Line := Line + ', ';
          First := False;
          Line := Line + MakeQuotedIdent(Trim(Q2.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect);
          Q2.Next;
        end;
        Line := 'alter table ' + MakeQuotedIdent(ObjectName, FIsIb6, FSQLDialect) + ' add constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) +  ' primary key (' + Line + ');';
        Result := Line;
      finally
        Q2.Free;
      end;
    end;
  finally
    Q1.Free;
  end;
end;

function TDDLExtractor.ExtractTriggerDoco(ObjectName: String): String;
var
  Q : TIBDataSet;
  Line : String;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select * from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, ''''));
    Q.Open;
    If Not (Q.EOF and Q.BOF) Then
    begin
      if FIncludeDoc then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$triggers set rdb$description = ?desc where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;  
      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;


function TDDLExtractor.ExtractTrigger(ObjectName: String): String;
var
  Q : TIBDataSet;
  Tmp : String;
  Line : String;
  X : Integer;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select * from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, ''''));
    Q.Open;
    If Not (Q.EOF and Q.BOF) Then
    begin

      Tmp := 'create trigger ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$trigger_name').AsString), FIsIB6, FSQLDialect);
      Tmp := Tmp + ' for ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$relation_name').AsString), FIsIB6, FSQLDialect) + ' ';
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      case Q.FieldByName('rdb$trigger_inactive').AsInteger of
        0 : Tmp := Tmp + 'active ';
        1 : Tmp := Tmp + 'inactive ';
      end;
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      case Q.FieldByName('rdb$trigger_type').AsInteger of
        1 : Tmp := Tmp + 'before insert ';
        2 : Tmp := Tmp + 'after insert ';
        3 : Tmp := Tmp + 'before update ';
        4 : Tmp := Tmp + 'after update ';
        5 : Tmp := Tmp + 'before delete ';
        6 : Tmp := Tmp + 'after delete ';
      end;
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      Tmp := Tmp + 'position ' + Trim(Q.FieldByName('rdb$trigger_sequence').AsString);

      Line := AdjustLineBreaks(Trim(Q.FieldByName('rdb$trigger_source').AsString));
      x := Pos(' ' + #10, Line);
      While x > 0 do
      begin
        Delete(Line, x, 2);
        x := Pos(' ' + #10, Line);
      end;

      Line := Tmp + #13#10 + Line + #13#10;
      Result := Line;
    end;
  finally
    Q.Free;
  end;

end;

function TDDLExtractor.ExtractUDF(ObjectName: String): String;
var
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Line : String;
  First : Boolean;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;
  
begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select * from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(ObjectName, ''''));
    Q.Open;
    if Not Q.EOF and Q.BOF then
    begin
      Line := 'declare external function ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$function_name').AsString), FIsIB6, FSQLDIalect) + ' ';
      Q1 := TIBDataSet.Create(Self);
      try
        Q1.Database := Q.Database;
        Q1.Transaction := FTransaction;
        Q1.SelectSQL.Clear;
        Q1.SelectSQL.Add('select * from rdb$function_arguments where rdb$function_name = ' +
                    AnsiQuotedStr(Trim(Q.FieldByName('rdb$function_name').AsString), '''') +
                    ' and rdb$argument_position <> ' + Trim(Q.FieldByName('rdb$return_argument').AsString) +';');
        Q1.Open;
        First := True;
        While not Q1.EOF do
        begin
          if First then
            Line := Line + '     ' + #13#10
          else
            Line := Line + ', ' + #13#10 + '     ';
          First := False;
          if FIsIB6 and (FSQLDialect = 3) then
          begin
            Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                            Q1.FieldByName('rdb$field_length').AsInteger,
                                            Q1.FieldByName('rdb$field_scale').AsInteger,
                                            Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                            Q1.FieldByName('rdb$field_precision').AsInteger,
                                            True);
          end
          else
          begin
            Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                            Q1.FieldByName('rdb$field_length').AsInteger,
                                            Q1.FieldByName('rdb$field_scale').AsInteger,
                                            -1,
                                            -1,
                                            False);
          end;
          if Q1.FIeldByName('rdb$mechanism').AsInteger = 0 then
            Line := Line + ' by value';
          Q1.Next;
        end;
        Q1.Close;
        Line := Line +  #13#10 + 'returns ';
        Q1.SelectSQL.Clear;
        Q1.SelectSQL.Add('select * from rdb$function_arguments where rdb$function_name = ' +
                    AnsiQuotedSTr(Trim(Q.FieldByName('rdb$function_name').AsString), '''') +
                    ' and rdb$argument_position = ' + Trim(Q.FieldByName('rdb$return_argument').AsString) +';');
        Q1.Open;
        if FIsIB6 and (FSQLDialect = 3) then
        begin
          Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                          Q1.FieldByName('rdb$field_length').AsInteger,
                                          Q1.FieldByName('rdb$field_scale').AsInteger,
                                          Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                          Q1.FieldByName('rdb$field_precision').AsInteger,
                                          True);
        end
        else
        begin
          Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                          Q1.FieldByName('rdb$field_length').AsInteger,
                                          Q1.FieldByName('rdb$field_scale').AsInteger,
                                          -1,
                                          -1,
                                          False);
        end;
        if Q1.FIeldByName('rdb$mechanism').AsInteger = 0 then
          Line := Line + ' by value';
        Line := Line +  #13#10 + 'entry_point ''' + Trim(Q.FieldByName('rdb$entrypoint').AsString) + '''';
        Line := Line +  #13#10 + 'module_name ''' + Trim(Q.FieldByName('rdb$module_name').AsString) + '''';
      finally
        Q1.Free;
      end;
      Line := Line + ';' + #13#10;
      if FIncludeDoc then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$functions set rdb$description = ?desc where rdb$function_name = ' + AnsiQuotedStr(ObjectName, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;  
      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractView(ObjectName: String): String;
var
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Tmp : String;
  First : Boolean;
  Line : String;
  Doc : TXmlDocument;
  oXML : TDOMNode;
  oStatement : TDOMNode;
  oData : TDOMNode;
  oDataLine : TDOMNode;
  Stream : TMemoryStream;
  List : TStringList;
  Idx : Integer;

begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select * from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q.Open;
    if Not Q.EOF and Q.BOF then
    begin
      Tmp := Trim(Q.FieldByName('rdb$view_source').AsString);
      Q1 := TIBDataSet.Create(Self);
      try
        Q1.Database := Q.Database;
        Q1.Transaction := FTransaction;
        Q1.SelectSQL.Clear;
        if FIsIB6 and (FSQLDialect = 3) then
        begin
          Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, b.rdb$computed_source, b.rdb$field_length, ' +
                    'b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$field_type from rdb$relation_fields a, rdb$fields b where a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$relation_name').AsString), '''') + ' ' +
                    ' order by a.rdb$field_position asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, b.rdb$computed_source, b.rdb$field_length, ' +
                    'b.rdb$field_scale, b.rdb$field_type from rdb$relation_fields a, rdb$fields b where a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$relation_name').AsString), '''') + ' ' +
                    ' order by a.rdb$field_position asc;');
        end;
        Q1.Open;
        First := True;
        Line := 'create view ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$relation_name').AsString), FIsIB6, FSQLDialect) + '(' + #13#10;
        While not Q1.EOF do
        begin
        if First then
          Line := Line + '     '
        else
          Line := Line + ',' + #13#10 + '     ';
          First := False;
          Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$field_name').AsString), FIsIB6, FSQLDialect);
          Q1.Next;
        end;
        Q1.Close;
      finally
        Q1.Free;
      end;
      Line := Line + ') as ' + Trim(Tmp) + ';' + #13#10;

      if FIncludeDoc then
      begin
        //add description here...
        Doc := TXmlDocument.Create;
        try
          oXML := Doc.CreateElement('data-record');
          Doc.AppendChild(oXML);

          oStatement := Doc.CreateElement('statement');
          oXML.AppendChild(oStatement);

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$relations set rdb$description = ?desc where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, ''''));

          oData := Doc.CreateElement('data-value');
          oXML.AppendChild(oData);
          TDOMElement(oData).SetAttribute('position', '1');
          TDOMElement(oData).SetAttribute('datatype', 'blob');
          if Q.FieldByName('rdb$description').IsNull then
            TDOMElement(oData).SetAttribute('value', 'NULL')
          else
          begin
            List := TStringList.Create;
            Stream := TMemoryStream.Create;
            try
              TBlobField(Q.FieldByName('rdb$description')).SaveToStream(Stream);
              Stream.Position := 0;
              List.LoadFromStream(Stream);
              for Idx := 0 to List.Count - 1 do
              begin
                oDataLine := Doc.CreateElement('data-line');
                oData.AppendChild(oDataLine);
                TDOMElement(oDataLine).SetAttribute('data', List[Idx]);
              end;
            finally
              Stream.Free;
              List.Free;
            end;
          end;
          Stream := TMemoryStream.Create;
          List := TStringList.Create;
          try
            WriteXMLFile(Doc, TSTream(Stream));
            Stream.Position := 0;
            List.LoadFromStream(Stream);
            List.Insert(0, '/*[');
            List.Add(']*/');
            for Idx := 0 to List.Count - 1 do
            begin
              Line := Line + List[Idx] + #13#10;
            end;
          finally
            Stream.Free;
            List.Free;
          end;
        finally
          Doc.Free;
        end;
      end;
      Result := Line;
    end;
  finally
    Q.Free;
  end;
end;

procedure TDDLExtractor.SetDatabase(const Value: TIBDatabase);
begin
  FDatabase := Value;
end;

procedure TDDLExtractor.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

end.

{
$Log: DDLExtractor.pas,v $
Revision 1.4  2006/10/19 03:59:40  rjmills
Numerous bug fixes and current work in progress

Revision 1.3  2002/04/25 07:16:24  tmuetze
New CVS powered comment block

}
