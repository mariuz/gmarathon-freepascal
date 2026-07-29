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
  {$IFDEF MSWINDOWS} Windows, {$ENDIF} SysUtils, Classes, IBDatabase, IBCustomDataSet,
  IBQuery, IBSQL, IBHeader, IB, DB, MetaExtractGlobals, DOM, xmlread, xmlwrite,
  MarathonProjectCacheTypes, StrUtils, SchemaNames;

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
    ddlTrigger,
    { Appended deliberately: callers pass this enum by value, so adding in the
      middle would silently renumber the existing ones. }
    ddlPackage,
    ddlPublication,
    ddlSchema
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
    ddlstGrants,
    { Appended for the same reason as the object types above. }
    ddlstAlter
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
    FSchema : String;
    FODSMajor: Integer;
    FODSMinor: Integer;
    FODSRead: Boolean;
    FSQLDIalect: Integer;
    FOnStatus: TOnStatusEvent;
    FIncludeDoc: Boolean;
    procedure ReadODS;
    { True when the attached database's on-disk structure is at least this
      ODS. Used to decide whether a system column exists before selecting it -
      naming a column that predates the database is a hard query error, not a
      NULL. }
    function ODSAtLeast(Major, Minor: Integer): Boolean;
    function IdentityOptions(const GeneratorName: String): String;
    function TableSQLSecurity(const ObjectName: String): String;
    function ExtractPSQLFunction(Q: TIBDataSet): String;
    function ExtractPackageHeader(ObjectName : String) : String;
    function ExtractPackageBody(ObjectName : String) : String;
    function ExtractPublication(ObjectName : String) : String;
    function ExtractSchema(ObjectName : String;
      ObjectSubType : TDDLSubType = ddlstNone) : String;
    function TriggerEventClause(TriggerType: Integer): String;
    function ExternalFileClause(const ObjectName : String) : String;
    function SQLSecurityClause(const SysTable, NameColumn, ObjectName: String): String;
    function SchemaClause(const Alias: String; const Column: String = 'rdb$schema_name'): String;
    { Ties a column to the domain behind it *in the schema that domain lives
      in*, which is not necessarily the object's own.

      RDB$RELATION_FIELDS records both: RDB$FIELD_SOURCE names the domain and
      RDB$FIELD_SOURCE_SCHEMA_NAME says where it is. Matching on the name alone
      finds that name in every schema, which duplicates a column once per
      schema holding one; restricting the domain to the object's schema instead
      silently drops a column whose domain lives elsewhere. Only this says what
      is meant.

      Empty before Firebird 6, which has no such column and no schemas for it
      to distinguish. }
    function FieldSourceJoin(const RelAlias, FieldAlias: String): String;
    function QualifiedIdent(const ObjectName: String): String;
    function ExtractGenerator(ObjectName : String) : String;
    function ExtractGeneratorValue(ObjectName : String) : String;
    function ExtractDomain(ObjectName : String) : String;
    function ExtractTable(ObjectName : String) : String;
    function ExtractTablePK(ObjectName : String) : String;
    function ExtractTableFK(ObjectName : String) : String;
    function ExtractTableIDX(ObjectName : String) : String;
    function ExtractTableData(ObjectName : String) : String;
    function ExtractView(ObjectName : String; AsAlter : Boolean = False) : String;
    function ExtractException(ObjectName : String) : String;
    function ExtractUDF(ObjectName : String) : String;
    function ExtractStoredProcedure(ObjectName : String) : String;
    function ExtractStoredProcedureHeader(ObjectName : String) : String;
    function ExtractStoredProcedureDoco(ObjectName : String) : String;
    function ExtractTrigger(ObjectName : String; AsAlter : Boolean = False) : String;
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
    { The schema to extract from. Empty - the default - means whatever an
      unqualified name reaches, which is what every existing caller wants and
      leaves their output exactly as it was. Set it to a schema name and the
      queries look in that schema instead, and the DDL comes out qualified, so
      an object outside the current schema can be scripted into something that
      will actually run. }
    property Schema : String read FSchema write FSchema;
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
    { The transaction belongs to the caller and is shared with everything else
      on that connection, so by the time an extract is asked for it has often
      been committed by something unrelated - the object tree's own queries
      commit, and so does saving an editor. IBX answers a query on a closed
      transaction with "Transaction is not active" rather than opening one, so
      the guard belongs here at the single entry point rather than in each of
      the thirty-odd Extract* routines below. Same rule as ScriptAs.EnsureActive
      and ProfilerQueries.EnsureActive. }
    if Assigned(FTransaction) and not FTransaction.Active then
      FTransaction.StartTransaction;

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
            ddlstAlter : Result := ExtractView(ObjectName, True);
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
            ddlstAlter :
              Result := ExtractTrigger(ObjectName, True);
            ddlstDoco :
              Result := ExtractTriggerDoco(ObjectName);
          end;
        end;
      ddlPackage:
        begin
          { Same header/body split as stored procedures: ddlstHeader gives the
            package interface, ddlstProc the body. }
          case ObjectSubType of
            ddlstNone, ddlstHeader :
              Result := ExtractPackageHeader(ObjectName);
            ddlstProc :
              Result := ExtractPackageBody(ObjectName);
          end;
        end;
      ddlSchema:
        begin
          Result := ExtractSchema(ObjectName, ObjectSubType);
        end;
      ddlPublication:
        begin
          Result := ExtractPublication(ObjectName);
        end;
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
    Q.SelectSQL.Add('select * from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q.Open;
    if Not Q.EOF and Q.BOF then
    begin
      Line := 'create domain ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$field_name').AsString), FISIb6, FSQLDialect) + ' as ';
      if FIsIB6 and (FSQLDIalect = 3) then
      begin
        Line := Line + (ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                         DeclaredFieldLength(Q),
                                         Q.FieldByName('rdb$field_scale').AsInteger,
                                         Q.FieldByName('rdb$field_sub_type').AsInteger,
                                         Q.FieldByName('rdb$field_precision').AsInteger,
                                         True));
      end
      else
      begin
        Line := Line + (ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                         DeclaredFieldLength(Q),
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
                        'rdb$dimension = ' + IntToStr(Idx)  + 'and rdb$field_name = ' + AnsiQuotedStr(ObjectName,'''') + SchemaClause(''));
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$fields set rdb$description = ?desc where rdb$field_name = ' + AnsiQuotedStr(ObjectName,'''') + SchemaClause(''));

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
    Q.SelectSQL.Add('select * from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$exceptions set rdb$description = ?desc where rdb$exception_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));

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
  Result := 'create generator ' + QualifiedIdent(ObjectName) + ';';
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

    Q1.SelectSQL.Text := 'select gen_id(' + QualifiedIdent(ObjectName) + ', 0) as current_val from rdb$database';
    Q1.Open;
    Line := 'set generator ' + QualifiedIdent(ObjectName) + ' to ' + Trim(Q1.FieldByName('current_val').AsString) + ';';
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
      Q.SelectSQL.Add('select rdb$user, rdb$privilege, rdb$grant_option from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('', 'rdb$relation_schema_name') + ';');
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
        Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv))  + ' on ' + ifthen(Priv='X','procedure ','') + QualifiedIdent(ObjectName) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;
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
      Q.SelectSQL.Add('select rdb$user, rdb$privilege, rdb$grant_option from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('', 'rdb$relation_schema_name') + ';');
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
          Q.SelectSQL.Add('select rdb$field_name from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('', 'rdb$relation_schema_name') + ' and rdb$privilege = ''' + Priv + ''' and rdb$user = ''' + User + ''';');
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
            Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv)) + ' on ' + QualifiedIdent(ObjectName) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10
          else
            Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv)) + '(' + ColList + ') on ' + QualifiedIdent(ObjectName) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;

        end
        else
        begin
          Grant := Grant + 'grant ' + AnsiLowerCase(ConvertPriv(Priv))  + ' on ' + QualifiedIdent(ObjectName) + ' to ' + AnsiLowerCase(User) + ' ' + ParseSection(UserList[Idx], 3, ':') + ';' + #13#10;
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

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
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
                                              DeclaredFieldLength(Q1),
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              DeclaredFieldLength(Q1),
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
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
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
                                              DeclaredFieldLength(Q1),
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              DeclaredFieldLength(Q1),
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

    Q.SelectSQL.Add('select rdb$procedure_name, rdb$procedure_source, rdb$description from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                    'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
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
                                              DeclaredFieldLength(Q1),
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              DeclaredFieldLength(Q1),
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
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                           'a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$procedure_name').AsString), '''') + SchemaClause('a.') + ' order by rdb$parameter_number asc;');
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
                                              DeclaredFieldLength(Q1),
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$parameter_name').AsString), FIsIB6, FSQLDialect) + ' ' +
                             ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              DeclaredFieldLength(Q1),
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

      Line := Line + SQLSecurityClause('rdb$procedures', 'rdb$procedure_name',
                                       Trim(Q.FieldByName('rdb$procedure_name').AsString));

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


procedure TDDLExtractor.ReadODS;
begin
  FODSRead := True;
  FODSMajor := 0;
  FODSMinor := 0;
  if not Assigned(FDatabase) or not FDatabase.Connected then
    Exit;
  try
    FODSMajor := FDatabase.Attachment.GetODSMajorVersion;
    FODSMinor := FDatabase.Attachment.GetODSMinorVersion;
  except
    FODSMajor := 0;
    FODSMinor := 0;
  end;
end;

function TDDLExtractor.ODSAtLeast(Major, Minor: Integer): Boolean;
begin
  if not FODSRead then
    ReadODS;
  Result := (FODSMajor > Major) or ((FODSMajor = Major) and (FODSMinor >= Minor));
end;

function TDDLExtractor.IdentityOptions(const GeneratorName: String): String;
var
  Q : TIBDataSet;
  InitVal : Int64;
  Incr : Integer;
begin
  { Only emit the clause when it differs from Firebird's defaults of
    START WITH 1 INCREMENT BY 1, to keep ordinary identity columns terse. }
  Result := '';
  if Trim(GeneratorName) = '' then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$initial_value, rdb$generator_increment from rdb$generators ' +
               'where rdb$generator_name = ' + AnsiQuotedStr(Trim(GeneratorName), ''''));
    try
      Q.Open;
      if not Q.EOF then
      begin
        InitVal := Q.FieldByName('rdb$initial_value').AsLargeInt;
        Incr := Q.FieldByName('rdb$generator_increment').AsInteger;
        if (InitVal <> 1) or (Incr <> 1) then
          Result := ' (start with ' + IntToStr(InitVal) + ' increment by ' + IntToStr(Incr) + ')';
      end;
      Q.Close;
    except
      { RDB$INITIAL_VALUE/RDB$GENERATOR_INCREMENT are themselves Firebird 3+;
        if they are missing just omit the options rather than fail the whole
        table extraction. }
      Result := '';
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.TableSQLSecurity(const ObjectName: String): String;
var
  Q : TIBDataSet;
  Fld : TField;
begin
  { Firebird 4 SQL SECURITY DEFINER|INVOKER. RDB$SQL_SECURITY is nullable:
    NULL means the table just inherits the database default, so emit nothing
    in that case rather than guessing a value. The column itself only exists
    from ODS 13 on. }
  Result := '';
  if not ODSAtLeast(13, 0) then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$sql_security from rdb$relations where rdb$relation_name = ' +
               AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    try
      Q.Open;
      if not Q.EOF then
      begin
        Fld := Q.FindField('rdb$sql_security');
        if Assigned(Fld) and not Fld.IsNull then
        begin
          if Fld.AsBoolean then
            Result := ' sql security definer'
          else
            Result := ' sql security invoker';
        end;
      end;
      Q.Close;
    except
      Result := '';
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.TriggerEventClause(TriggerType: Integer): String;
var
  IsAfter : Boolean;
  Value : Integer;
  Slot : Integer;
  Idx : Integer;
  Actions : String;
const
  ActionNames : array[1..3] of String = ('insert', 'update', 'delete');
begin
  { Database-level triggers (Firebird 2.1+) take no relation and their own
    ON <event> clause. }
  case TriggerType of
    8192 : begin Result := 'on connect'; Exit; end;
    8193 : begin Result := 'on disconnect'; Exit; end;
    8194 : begin Result := 'on transaction start'; Exit; end;
    8195 : begin Result := 'on transaction commit'; Exit; end;
    8196 : begin Result := 'on transaction rollback'; Exit; end;
  end;

  { Table triggers pack up to three actions into RDB$TRIGGER_TYPE: the value
    is odd for BEFORE and even for AFTER, and (type + 1 - after) div 2 decodes
    in base 4 as up to three action slots (1 = INSERT, 2 = UPDATE, 3 = DELETE).
    Only the six single-action codes used to be handled, so a multi-action
    trigger - "before insert or update", which is entirely ordinary - emitted
    no event clause at all and produced invalid DDL.
    Verified against a live server for all of: 1..6, 17, 18, 25, 27, 113. }
  Result := '';
  if TriggerType <= 0 then
    Exit;

  IsAfter := (TriggerType mod 2) = 0;
  if IsAfter then
    Value := (TriggerType + 1 - 1) div 2
  else
    Value := (TriggerType + 1) div 2;

  Actions := '';
  for Idx := 0 to 2 do
  begin
    Slot := (Value div (1 shl (Idx * 2))) mod 4;
    if (Slot >= 1) and (Slot <= 3) then
    begin
      if Actions <> '' then
        Actions := Actions + ' or ';
      Actions := Actions + ActionNames[Slot];
    end;
  end;

  if Actions = '' then
    Exit;

  if IsAfter then
    Result := 'after ' + Actions
  else
    Result := 'before ' + Actions;
end;

{ Restricts a catalogue query to the schema the caller can actually reach by an
  unqualified name.

  Object names are unique per schema, not per database, so filtering on the name
  alone matches every schema that happens to use it. That is not a hypothetical:
  with a T_AMBIG in both PUBLIC and APPX, the column query matched four rows and
  ExtractTable emitted one table carrying both schemas' columns and a duplicated
  ID (verified). Since the object tree only ever offers what an unqualified name
  reaches, restricting extraction the same way makes the DDL match the object the
  user picked.

  Alias is the table alias with its dot ('a.'), or empty for an unaliased query.
  Empty before Firebird 6 (ODS 14): RDB$SCHEMA_NAME does not exist there and
  naming it is a hard error rather than a null. The CURRENT_SCHEMA null guard is
  the same one the object tree needs - with an empty search path CURRENT_SCHEMA
  is null, and without the guard every query would return nothing at all rather
  than everything. }
function TDDLExtractor.SchemaClause(const Alias: String; const Column: String): String;
begin
  { SchemaNames owns the rule now - the object editors need exactly the same
    predicate, and two copies of it are two things to keep in step. }
  Result := SchemaPredicate(Alias, Column, FSchema, ODSAtLeast(14, 0));
end;

function TDDLExtractor.FieldSourceJoin(const RelAlias, FieldAlias: String): String;
begin
  Result := SchemaNames.FieldSourceJoin(RelAlias, FieldAlias, ODSAtLeast(14, 0));
end;

function TDDLExtractor.QualifiedIdent(const ObjectName: String): String;
begin
  Result := SchemaNames.QualifiedIdent(FSchema, ObjectName, FIsIB6, FSQLDialect);
end;

{ EXTERNAL FILE, for a table whose rows live in a file rather than in the
  database.

  Without this an external table extracts as an ordinary one - the DDL
  compiles, the table appears, and everything written to it goes into the
  database instead of the file it was supposed to be a view of. The same class
  of silent wrongness as reading the byte length of a UTF8 column: what comes
  back looks like a table and is the wrong table.

  RDB$EXTERNAL_FILE is null for every ordinary table, which is what makes this
  safe to ask about unconditionally - it has been in the catalogue since
  InterBase. }
function TDDLExtractor.ExternalFileClause(const ObjectName: String): String;
var
  Q: TIBDataSet;
begin
  Result := '';
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$external_file from rdb$relations where ' +
      'rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') +
      SchemaClause(''));
    try
      Q.Open;
      if (not Q.EOF) and not Q.FieldByName('rdb$external_file').IsNull and
         (Trim(Q.FieldByName('rdb$external_file').AsString) <> '') then
        { The path is the server's, and is written as the server recorded it. }
        Result := ' external file ' +
          AnsiQuotedStr(Trim(Q.FieldByName('rdb$external_file').AsString), '''');
      Q.Close;
    except
      on E: Exception do
      begin
        { An optional clause: if the catalogue cannot answer, the table is
          extracted without it rather than the whole run failing. The bulk
          engine swallows an exception here and writes no file at all, which
          is how a missing guard showed up as "the extract produced nothing"
          rather than as an error. }
        Result := '';
      end;
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.SQLSecurityClause(const SysTable, NameColumn, ObjectName: String): String;
var
  Q : TIBDataSet;
  Fld : TField;
begin
  { Firebird 4 SQL SECURITY. Nullable, where NULL means "inherit the database
    default" rather than a value, so emit nothing in that case. }
  Result := '';
  if not ODSAtLeast(13, 0) then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$sql_security from ' + SysTable + ' where ' + NameColumn +
               ' = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    try
      Q.Open;
      if not Q.EOF then
      begin
        Fld := Q.FindField('rdb$sql_security');
        if Assigned(Fld) and not Fld.IsNull then
        begin
          if Fld.AsBoolean then
            Result := ' sql security definer'
          else
            Result := ' sql security invoker';
        end;
      end;
      Q.Close;
    except
      Result := '';
    end;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractPackageHeader(ObjectName: String): String;
var
  Q : TIBDataSet;
  Src : String;
begin
  { Packages are Firebird 3 (ODS 12). }
  Result := '';
  if not ODSAtLeast(12, 0) then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$package_header_source from rdb$packages where rdb$package_name = ' +
               AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q.Open;
    if not Q.EOF then
    begin
      Src := AdjustLineBreaks(Trim(Q.FieldByName('rdb$package_header_source').AsString));
      if Src <> '' then
        Result := 'create or alter package ' + QualifiedIdent(ObjectName) +
                  SQLSecurityClause('rdb$packages', 'rdb$package_name', ObjectName) +
                  #13#10 + 'as' + #13#10 + Src + #13#10;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractPackageBody(ObjectName: String): String;
var
  Q : TIBDataSet;
  Src : String;
begin
  Result := '';
  if not ODSAtLeast(12, 0) then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$package_body_source from rdb$packages where rdb$package_name = ' +
               AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q.Open;
    if not Q.EOF then
    begin
      { A package can exist with a header and no body, so an empty body is a
        legitimate state rather than an error - emit nothing. }
      Src := AdjustLineBreaks(Trim(Q.FieldByName('rdb$package_body_source').AsString));
      if Src <> '' then
        Result := 'recreate package body ' + QualifiedIdent(ObjectName) +
                  #13#10 + 'as' + #13#10 + Src + #13#10;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractSchema(ObjectName: String;
  ObjectSubType: TDDLSubType): String;
var
  Q : TIBDataSet;
  Line, CharSet : String;
begin
  { SQL schemas are Firebird 6 (ODS 14). RDB$SCHEMAS does not exist earlier and
    naming it is a hard error, not an empty result. }
  Result := '';
  if not ODSAtLeast(14, 0) then
    Exit;
  Q := TIBDataSet.Create(Self);
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q.SelectSQL.Add('select rdb$schema_name, rdb$character_set_name, rdb$sql_security ' +
                    'from rdb$schemas where rdb$schema_name = ' +
                    AnsiQuotedStr(ObjectName, ''''));
    Q.Open;
    if Q.EOF then
    begin
      Q.Close;
      Exit;
    end;
    { Null rather than the database default when the schema was created without
      one - PUBLIC is the case in point - and writing a DEFAULT CHARACTER SET
      clause naming nothing would not compile. }
    if Q.FieldByName('rdb$character_set_name').IsNull then
      CharSet := ''
    else
      CharSet := MakeQuotedIdent(
        Trim(Q.FieldByName('rdb$character_set_name').AsString), FIsIB6, FSQLDialect);

    if ObjectSubType = ddlstAlter then
    begin
      { What ALTER SCHEMA can actually change, probed against the 6.0.0 test
        server rather than read from the notes: SET DEFAULT CHARACTER SET and
        DROP DEFAULT CHARACTER SET, and nothing else. SQL SECURITY and OWNER TO
        are both rejected outright ("Token unknown - sql", "- owner"), in any
        position, so a schema's ALTER is its character set or nothing.

        A schema with no character set restates as the DROP form: that is the
        state it is in, and it is what makes the statement runnable against a
        schema that has one. }
      Line := 'alter schema ' +
        MakeQuotedIdent(Trim(Q.FieldByName('rdb$schema_name').AsString), FIsIB6, FSQLDialect);
      if CharSet = '' then
        Line := Line + ' drop default character set'
      else
        Line := Line + ' set default character set ' + CharSet;
      Result := Line + ';' + #13#10;
      Q.Close;
      Exit;
    end;

    Line := 'create schema ' +
      MakeQuotedIdent(Trim(Q.FieldByName('rdb$schema_name').AsString), FIsIB6, FSQLDialect);
    if CharSet <> '' then
      Line := Line + ' default character set ' + CharSet;
    { Firebird 6.0.0 has the column but no syntax that writes it - CREATE
      SCHEMA rejects a SQL SECURITY clause in either position, and so does
      ALTER (both verified). So this branch cannot be reached on any server
      that exists: the column is null on every schema, including PUBLIC. Kept
      because it is what the clause would be, and because reaching it would
      mean a release that accepts it. }
    if not Q.FieldByName('rdb$sql_security').IsNull then
    begin
      if Q.FieldByName('rdb$sql_security').AsInteger <> 0 then
        Line := Line + ' sql security definer'
      else
        Line := Line + ' sql security invoker';
    end;
    Result := Line + ';' + #13#10;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function TDDLExtractor.ExtractPublication(ObjectName: String): String;
var
  Q : TIBDataSet;
  Output : TStringList;
  Members : TStringList;
  Excluded : TStringList;
  Line : String;
  Idx : Integer;
  AutoEnable : Boolean;
begin
  { Replication publications are Firebird 4 (ODS 13). }
  Result := '';
  if not ODSAtLeast(13, 0) then
    Exit;
  Output := TStringList.Create;
  Members := TStringList.Create;
  Excluded := TStringList.Create;
  try
    Q := TIBDataSet.Create(Self);
    try
      Q.Database := FDatabase;
      Q.Transaction := FTransaction;
      Q.SelectSQL.Add('select rdb$active_flag, rdb$auto_enable from rdb$publications where rdb$publication_name = ' +
                 AnsiQuotedStr(ObjectName, ''''));
      Q.Open;
      if Q.EOF then
      begin
        Q.Close;
        Exit;
      end;
      AutoEnable := Q.FieldByName('rdb$auto_enable').AsInteger <> 0;
      { Firebird 4-6 have no CREATE PUBLICATION statement: the only publication
        an engine can hold is the built-in default one, and every DDL verb for
        it is spelled ALTER DATABASE, with the publication left unnamed. The
        table exists to allow named publications later, so a row under any
        other name has no DDL that can be written for it today. }
      if AnsiUpperCase(Trim(ObjectName)) <> DefaultPublicationName then
      begin
        Q.Close;
        Result := '/* Publication ' + Trim(ObjectName) +
                  ' - this server version has no DDL syntax for named publications */' + #13#10;
        Exit;
      end;
      if Q.FieldByName('rdb$active_flag').AsInteger <> 0 then
        Output.Add('alter database enable publication;')
      else
        Output.Add('alter database disable publication;');
      Q.Close;
    finally
      Q.Free;
    end;

    Q := TIBDataSet.Create(Self);
    try
      Q.Database := FDatabase;
      Q.Transaction := FTransaction;
      Q.SelectSQL.Add('select rdb$table_name from rdb$publication_tables where rdb$publication_name = ' +
                 AnsiQuotedStr(ObjectName, '''') + ' order by rdb$table_name');
      Q.Open;
      while not Q.EOF do
      begin
        Members.Add(Trim(Q.FieldByName('rdb$table_name').AsString));
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;

    if AutoEnable then
    begin
      { "Include all" also opts every table created from now on into the
        publication, so it has to be reproduced as such rather than as the
        current member list - but a table can still have been excluded
        afterwards, which leaves the flag set. Name those explicitly. }
      Output.Add('alter database include all to publication;');
      Q := TIBDataSet.Create(Self);
      try
        Q.Database := FDatabase;
        Q.Transaction := FTransaction;
        Q.SelectSQL.Add('select rdb$relation_name from rdb$relations where ' +
                   '((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_blr is null ' +
                   'order by rdb$relation_name');
        Q.Open;
        while not Q.EOF do
        begin
          Line := Trim(Q.FieldByName('rdb$relation_name').AsString);
          if Members.IndexOf(Line) < 0 then
            Excluded.Add(MakeQuotedIdent(Line, FIsIB6, FSQLDialect));
          Q.Next;
        end;
        Q.Close;
      finally
        Q.Free;
      end;
      for Idx := 0 to Excluded.Count - 1 do
        Output.Add('alter database exclude table ' + Excluded[Idx] + ' from publication;');
    end
    else
      if Members.Count > 0 then
      begin
        Line := '';
        for Idx := 0 to Members.Count - 1 do
        begin
          if Line <> '' then
            Line := Line + ', ';
          Line := Line + MakeQuotedIdent(Members[Idx], FIsIB6, FSQLDialect);
        end;
        Output.Add('alter database include table ' + Line + ' to publication;');
      end;

    Result := Output.Text;
  finally
    Excluded.Free;
    Members.Free;
    Output.Free;
  end;
end;

function TDDLExtractor.ExtractTable(ObjectName: String): String;
var
  Q1 : TIBDataSet;
  Q2 : TIBDataSet;
  First : Boolean;
  Line : String;
  IdentityCols : String;
  IdentityClause : String;
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

      { Identity columns arrived in Firebird 3 (ODS 12). Naming these columns
        against an older database is a hard query error rather than a NULL, so
        select them only when the ODS actually has them. }
      if ODSAtLeast(12, 0) then
        IdentityCols := 'a.rdb$identity_type as identity_type, a.rdb$generator_name as identity_gen, '
      else
        IdentityCols := '';

      if FIsIB6 and (FSQLDialect = 3) then
      begin
        Q1.SelectSQL.Add('select ' + IdentityCols + 'a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
                   'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
                   'b.rdb$character_set_id, b.rdb$collation_id as fcollate, a.rdb$collation_id as tcollate, ' +
                   'b.rdb$computed_source, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, ' +
                   'b.rdb$field_sub_type, b.rdb$segment_length, ' +
                   'b.rdb$field_type, b.rdb$dimensions from rdb$relation_fields a, rdb$fields b where ' +
                   'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
                    AnsiQuotedStr(ObjectName, '''') + SchemaClause('a.') +
                    FieldSourceJoin('a.', 'b.') + ' order by a.rdb$field_position asc;');
      end
      else
      begin
        Q1.SelectSQL.Add('select ' + IdentityCols + 'a.rdb$field_name, a.rdb$null_flag as tnull_flag, ' +
                   'b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, ' +
                   'b.rdb$character_set_id, b.rdb$collation_id as fcollate, a.rdb$collation_id as tcollate, ' +
                   'b.rdb$computed_source, b.rdb$field_length, b.rdb$character_length, b.rdb$field_scale, ' +
                   'b.rdb$field_sub_type, b.rdb$segment_length, ' +
                   'b.rdb$field_type, b.rdb$dimensions from rdb$relation_fields a, rdb$fields b where ' +
                   'a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' +
                    AnsiQuotedStr(ObjectName, '''') + SchemaClause('a.') +
                    FieldSourceJoin('a.', 'b.') + ' order by a.rdb$field_position asc;');

      end;
      Q1.Open;
      First := True;
      { EXTERNAL FILE goes between the name and the column list - Firebird
        rejects it after the closing bracket, which is where it was first put
        and where the test caught it. }
      Line := 'create table ' + QualifiedIdent(ObjectName) +
        ExternalFileClause(ObjectName) + '(' + #13#10;
      While Not Q1.EOF do
      begin
        if First then
          Line := Line + '     '
        else
          Line := Line + ',' + #13#10 + '     ';
        First := False;
        { Firebird 3 identity columns. RDB$IDENTITY_TYPE is 0 for GENERATED
          ALWAYS and 1 for GENERATED BY DEFAULT; START WITH / INCREMENT BY live
          on the backing generator named by RDB$GENERATOR_NAME. Losing this on
          extraction is not cosmetic - the restored column silently stops
          auto-generating. }
        IdentityClause := '';
        if Assigned(Q1.FindField('identity_type')) and
           not Q1.FieldByName('identity_type').IsNull then
        begin
          if Q1.FieldByName('identity_type').AsInteger = 0 then
            IdentityClause := ' generated always as identity'
          else
            IdentityClause := ' generated by default as identity';
          IdentityClause := IdentityClause + IdentityOptions(Q1.FieldByName('identity_gen').AsString);
        end;

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
                                              DeclaredFieldLength(Q1),
                                              Q1.FieldByName('rdb$field_scale').AsInteger,
                                              Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                              Q1.FieldByName('rdb$field_precision').AsInteger,
                                              True);
            end
            else
            begin
              Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                              DeclaredFieldLength(Q1),
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

            Line := Line + IdentityClause;

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

            Line := Line + IdentityClause;

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

    Line := Line + ')' +
      SQLSecurityClause('rdb$relations', 'rdb$relation_name', ObjectName) + ';';
    OutPut.Text := Line;

    //check constraints
    Q1 := TIBDataSet.Create(Self);
    try
      Q1.Database := FDatabase;
      Q1.Transaction := FTransaction;
      Q1.SelectSQL.Add('select * from rdb$relation_constraints where (rdb$constraint_type = ''CHECK'') ' +
                 'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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
            { A name the server invented is left off: writing it down makes the
              script fail on any database that has already given INTEG_<n> to
              something else, which it will have. }
            Line := 'alter table ' + QualifiedIdent(ObjectName) + ' add ' + IfThen(IsGeneratedConstraintName(Trim(Q1.FieldByName('rdb$constraint_name').AsString)), '', 'constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) + ' ') + AdjustLineBreaks(Trim(Q2.FieldByName('rdb$trigger_source').AsString)) + ';';
            Q2.Close;
            OutPut.Add(Line);
          finally
            Q2.Free;
          end;
          Q1.Next;
        end;
      end;

      Q1.Close;
      Q1.SelectSQL.Text := 'select rdb$description from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';';
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$relations set rdb$description = ?desc where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));

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
                   'where a.rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('a.') +
                   ' and a.rdb$field_source = b.rdb$field_name' + FieldSourceJoin('a.', 'b.') + ' and ' +
                   'b.rdb$computed_source is not null';
    Q1.ExecQuery;
    while not Q1.EOF do
    begin
      CompFields.Add(MakeQuotedIdent(Trim(Q1.FieldByName('rdb$field_name').AsString), IsInterbase6, SQLDialect));
      Q1.Next;
    end;
    Q1.Close;

    Q1.SQL.Text := 'select * from ' + QualifiedIdent(ObjectName);
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

      InsertList := 'insert into ' + QualifiedIdent(ObjectName) + '(' + InsertList + ') values (';

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

      InsertList := 'insert into ' + QualifiedIdent(ObjectName) + '(' + InsertList + ') values (' + ParamList + ')';

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
                      TBlobField(Q1.Fields[Idy]).SaveToStream(Stream);
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
               'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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

        Line := Line + 'alter table ' + QualifiedIdent(ObjectName) + ' add ' + IfThen(IsGeneratedConstraintName(Trim(Q1.FieldByName('rdb$constraint_name').AsString)), '', 'constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) + ' ') + 'foreign key (' + Line1 + ') references ';

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
  IdxExpr : String;
  IdxCond : String;
  Fld : TField;

begin
  Result := '';
  Line1 := '';
  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    Q1.SelectSQL.Add('select * from rdb$indices where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q1.SelectSQL.Add('and not (rdb$index_name in (select rdb$index_name from rdb$relation_constraints where');
    Q1.SelectSQL.Add('rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ' and ');
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

        Line1 := Line1 + 'index ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$index_name').AsString), FIsIB6, FSQLDialect) + ' on ' + QualifiedIdent(ObjectName);

        { An expression index has no RDB$INDEX_SEGMENTS rows, so the column
          list built above is empty and emitting it produced invalid SQL
          ("on TBL()"). RDB$EXPRESSION_SOURCE already carries its own
          parentheses. FindField (not FieldByName) because RDB$CONDITION_SOURCE
          only exists from Firebird 5 on - older servers have no such column. }
        IdxExpr := '';
        Fld := Q1.FindField('rdb$expression_source');
        if Assigned(Fld) and not Fld.IsNull then
          IdxExpr := AdjustLineBreaks(Trim(Fld.AsString));

        if IdxExpr <> '' then
          Line1 := Line1 + ' computed by ' + IdxExpr
        else
          Line1 := Line1 + '(' + Line + ')';

        { Firebird 5 partial (conditional) index. RDB$CONDITION_SOURCE already
          includes the WHERE keyword. Dropping it silently turned a partial
          index into a full one - a different index, not just cosmetic. }
        IdxCond := '';
        Fld := Q1.FindField('rdb$condition_source');
        if Assigned(Fld) and not Fld.IsNull then
          IdxCond := AdjustLineBreaks(Trim(Fld.AsString));

        if IdxCond <> '' then
          Line1 := Line1 + ' ' + IdxCond;

        Line1 := Line1 + ';' + #13#10;

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
               'and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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
        Line := 'alter table ' + QualifiedIdent(ObjectName) + ' add ' + IfThen(IsGeneratedConstraintName(Trim(Q1.FieldByName('rdb$constraint_name').AsString)), '', 'constraint ' + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$constraint_name').AsString), FIsIB6, FSQLDialect) + ' ') + 'primary key (' + Line + ');';
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
    Q.SelectSQL.Add('select * from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$triggers set rdb$description = ?desc where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));

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


function TDDLExtractor.ExtractTrigger(ObjectName: String; AsAlter: Boolean): String;
var
  EventClause : String;
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
    Q.SelectSQL.Add('select * from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q.Open;
    If Not (Q.EOF and Q.BOF) Then
    begin

      if AsAlter then
        Tmp := 'alter trigger '
      else
        Tmp := 'create trigger ';
      Tmp := Tmp + MakeQuotedIdent(Trim(Q.FieldByName('rdb$trigger_name').AsString), FIsIB6, FSQLDialect);
      { A database-level trigger has no relation, and emitting "for " with an
        empty name produced a syntax error. ALTER TRIGGER takes no relation at
        all - a trigger cannot be moved between tables, so Firebird rejects the
        clause outright rather than ignoring it (verified live: "Token unknown
        - for"). }
      if AsAlter then
        Tmp := Tmp + ' '
      else if Trim(Q.FieldByName('rdb$relation_name').AsString) <> '' then
        Tmp := Tmp + ' for ' + MakeQuotedIdent(Trim(Q.FieldByName('rdb$relation_name').AsString), FIsIB6, FSQLDialect) + ' '
      else
        Tmp := Tmp + ' ';
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      case Q.FieldByName('rdb$trigger_inactive').AsInteger of
        0 : Tmp := Tmp + 'active ';
        1 : Tmp := Tmp + 'inactive ';
      end;
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      EventClause := TriggerEventClause(Q.FieldByName('rdb$trigger_type').AsInteger);
      if EventClause <> '' then
        Tmp := Tmp + EventClause + ' ';
      if Length(Tmp) > 80 then
        Tmp := Tmp + #13#10;
      Tmp := Tmp + 'position ' + Trim(Q.FieldByName('rdb$trigger_sequence').AsString);
      Tmp := Tmp + SQLSecurityClause('rdb$triggers', 'rdb$trigger_name',
                                     Trim(Q.FieldByName('rdb$trigger_name').AsString));

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

function TDDLExtractor.ExtractPSQLFunction(Q: TIBDataSet): String;
var
  Q1 : TIBDataSet;
  Line : String;
  FuncName : String;
  RetArg : Integer;
  First : Boolean;
begin
  FuncName := Trim(Q.FieldByName('rdb$function_name').AsString);
  RetArg := Q.FieldByName('rdb$return_argument').AsInteger;
  Line := 'create or alter function ' + MakeQuotedIdent(FuncName, FIsIB6, FSQLDialect);

  Q1 := TIBDataSet.Create(Self);
  try
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    { Argument types live on the linked domain, not inline. }
    Q1.SelectSQL.Add('select a.rdb$argument_name, a.rdb$argument_position, ' +
               'f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, f.rdb$field_scale, ' +
               'f.rdb$field_sub_type, f.rdb$field_precision ' +
               'from rdb$function_arguments a join rdb$fields f ' +
               'on f.rdb$field_name = a.rdb$field_source ' +
               'where a.rdb$function_name = ' + AnsiQuotedStr(FuncName, '''') +
               ' and a.rdb$argument_position <> ' + IntToStr(RetArg) +
               ' order by a.rdb$argument_position asc');
    Q1.Open;
    First := True;
    while not Q1.EOF do
    begin
      if First then
        Line := Line + ' ('
      else
        Line := Line + ', ';
      First := False;
      Line := Line + MakeQuotedIdent(Trim(Q1.FieldByName('rdb$argument_name').AsString), FIsIB6, FSQLDialect) +
              ' ' + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                     DeclaredFieldLength(Q1),
                                     Q1.FieldByName('rdb$field_scale').AsInteger,
                                     Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                     Q1.FieldByName('rdb$field_precision').AsInteger,
                                     True);
      Q1.Next;
    end;
    if not First then
      Line := Line + ')';
    Q1.Close;

    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, f.rdb$field_scale, ' +
               'f.rdb$field_sub_type, f.rdb$field_precision ' +
               'from rdb$function_arguments a join rdb$fields f ' +
               'on f.rdb$field_name = a.rdb$field_source ' +
               'where a.rdb$function_name = ' + AnsiQuotedStr(FuncName, '''') +
               ' and a.rdb$argument_position = ' + IntToStr(RetArg));
    Q1.Open;
    if not Q1.EOF then
      Line := Line + #13#10 + 'returns ' +
              ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                               DeclaredFieldLength(Q1),
                               Q1.FieldByName('rdb$field_scale').AsInteger,
                               Q1.FieldByName('rdb$field_sub_type').AsInteger,
                               Q1.FieldByName('rdb$field_precision').AsInteger,
                               True);
    Q1.Close;
  finally
    Q1.Free;
  end;

  Line := Line + SQLSecurityClause('rdb$functions', 'rdb$function_name', FuncName);
  Line := Line + #13#10 + 'as' + #13#10 +
          AdjustLineBreaks(Trim(Q.FieldByName('rdb$function_source').AsString)) + #13#10;
  Result := Line;
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
    Q.SelectSQL.Add('select * from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));
    Q.Open;

    { Firebird 3 replaced external UDFs with PSQL functions, and the two share
      RDB$FUNCTIONS but have nothing else in common: a PSQL function has a body
      in RDB$FUNCTION_SOURCE, NULL ENTRYPOINT/MODULE_NAME, and arguments typed
      through RDB$FIELD_SOURCE rather than RDB$FIELD_TYPE. Running one through
      the DECLARE EXTERNAL FUNCTION path below produced nonsense. On Firebird 4
      and later external UDFs are deprecated and off by default, so in practice
      almost everything here is now a PSQL function. }
    if (not Q.EOF) and Assigned(Q.FindField('rdb$legacy_flag')) and
       (not Q.FieldByName('rdb$legacy_flag').IsNull) and
       (Q.FieldByName('rdb$legacy_flag').AsInteger = 0) then
    begin
      Result := ExtractPSQLFunction(Q);
      Exit;
    end;

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
                                            DeclaredFieldLength(Q1),
                                            Q1.FieldByName('rdb$field_scale').AsInteger,
                                            Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                            Q1.FieldByName('rdb$field_precision').AsInteger,
                                            True);
          end
          else
          begin
            Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                            DeclaredFieldLength(Q1),
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
                                          DeclaredFieldLength(Q1),
                                          Q1.FieldByName('rdb$field_scale').AsInteger,
                                          Q1.FieldByName('rdb$field_sub_type').AsInteger,
                                          Q1.FieldByName('rdb$field_precision').AsInteger,
                                          True);
        end
        else
        begin
          Line := Line + ConvertFieldType(Q1.FieldByName('rdb$field_type').AsInteger,
                                          DeclaredFieldLength(Q1),
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$functions set rdb$description = ?desc where rdb$function_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));

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

function TDDLExtractor.ExtractView(ObjectName: String; AsAlter: Boolean): String;
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
    Q.SelectSQL.Add('select * from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause('') + ';');
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
          Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, b.rdb$computed_source, b.rdb$field_length, b.rdb$character_length, ' +
                    'b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$field_type from rdb$relation_fields a, rdb$fields b where a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$relation_name').AsString), '''') + ' ' +
                    SchemaClause('a.') + FieldSourceJoin('a.', 'b.') +
                    ' order by a.rdb$field_position asc;');
        end
        else
        begin
          Q1.SelectSQL.Add('select a.rdb$field_name, a.rdb$null_flag as tnull_flag, b.rdb$null_flag as fnull_flag, a.rdb$field_source, a.rdb$default_source, b.rdb$computed_source, b.rdb$field_length, b.rdb$character_length, ' +
                    'b.rdb$field_scale, b.rdb$field_type from rdb$relation_fields a, rdb$fields b where a.rdb$field_source = b.rdb$field_name and a.rdb$relation_name = ' + AnsiQuotedStr(Trim(Q.FieldByName('rdb$relation_name').AsString), '''') + ' ' +
                    SchemaClause('a.') + FieldSourceJoin('a.', 'b.') +
                    ' order by a.rdb$field_position asc;');
        end;
        Q1.Open;
        First := True;
        if AsAlter then
          Line := 'alter view '
        else
          Line := 'create view ';
        Line := Line + MakeQuotedIdent(Trim(Q.FieldByName('rdb$relation_name').AsString), FIsIB6, FSQLDialect) + '(' + #13#10;
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

          TDOMElement(oStatement).SetAttribute('sql', 'update rdb$relations set rdb$description = ?desc where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + SchemaClause(''));

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
