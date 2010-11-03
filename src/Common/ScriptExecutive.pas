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
// $Id: ScriptExecutive.pas,v 1.4 2006/10/19 04:01:08 rjmills Exp $

unit ScriptExecutive;

interface

uses
	Classes, Windows, SysUtils, Registry, Dialogs, Forms, Messages, Controls, StdCtrls,
	IB_Components,
	IB_Session,
	IB_Header,
	DOM,
	XMLRead,
	XMLWrite;

type
  TISQLExceptionCode = (eeInitialization, eeInvDialect, eeFOpen, eeParse,
                        eeCreate, eeConnect, eeStatement,
                        eeCommit, eeRollback, eeDDL, eeDML, eeQuery, eeFree,
                        eeUnsupt);

  EISQLException = class(Exception)
  private
    FExceptionCode: TISQLExceptionCode;
    FErrorCode: Integer;
    FExceptionData: String;
  public
    constructor Create (ErrorCode: Integer;
                        ExceptionData: String;
                        ExceptionCode: TISQLExceptionCode;
                        Msg: String);
  published
    property ExceptionCode: TISQLExceptionCode read FExceptionCode;
    property ExceptionData: String read FExceptionData;
    property ErrorCode: Integer read FErrorCode;
  end;

  TISQLAction = (actInput, actOutput, actCount, actEcho, actList, actNames, actPlan,
                 actStats, actTime, actUnk, actUnSup, actDialect, actAutoDDL, actXMLExec);


  TLineUpdateEvent = procedure(Sender : TObject; LineNumber : Integer) of Object;
  TReportErrorEvent = procedure(Sender : TObject; LineNumber : Integer; ErrorText : String) of Object;

  TDataLineMarker = class(TObject)
  private
    FLineNumber: Integer;
    FXMLBlock : String;
  public
    property LineNumber : Integer read FLineNumber write FLineNumber;
    property XMLBlock : String read FXMLBlock write FXMLBlock;
  end;

  TIBSQLObj = class (TComponent)
  private
    FQuery: TStrings;
    FDatabase: TIB_Connection;
    FSQLQuery: TIB_DSQL;
    FTmpQuery: TIB_DSQL;
    FTmpTransaction : TIB_Transaction;
    FDDLQuery: TIB_DSQL;
    FDDLTransaction : TIB_Transaction;
    FProgressEvent: TNotifyEvent;
    FStatements: integer;
    FCanceled,
    FAutoDDL: boolean;
    FTransaction: TIB_Transaction;
    FOnUpdateLine: TLineUpdateEvent;
    FOnReportError: TReportErrorEvent;

    FConnDBName : String;
    FConnDBUser : String;
    FConnDBPassword : String;
    FConnDBCharSet : String;
    FConnDBRole : String;
    FTokenPos : Integer;
    FTokenBuf : String;
    FSkipCreateConnect: Boolean;

    function ParseSQL(const InputSQL: TStringList; out Data: TStringList;
      const TermChar: String): boolean;
    function ParseDBCreate (const InputSQL: String): boolean;
    function ParseDBConnect (const InputSQL: String): boolean;
    function ParseClientDialect (const InputSQL: String): Integer;
    function IsISQLCommand (const InputSQL: String; out Data: Variant): TISQLAction;
    function ParseOnOff (const InputSQL, Item: String): Boolean;
    procedure InitTokeniser(S : String);
    function GetNextToken : String;
    procedure SetAutoDDL(const Value: boolean);

  published
    property AutoDDL: boolean read FAutoDDL write SetAutoDDL;
		property Query: TStrings read FQuery write FQuery;
    property Database: TIB_Connection read FDatabase write FDatabase;
    property SQLQuery: TIB_DSQL read FSQLQuery write FSQLQuery;
    property Transaction : TIB_Transaction read FTransaction write FTransaction;
    property Statements: Integer read FStatements;
    property OnQueryProgress: TNotifyEvent read FProgressEvent write FProgressEvent;
    property OnLineUpdate : TLineUpdateEvent read FOnUpdateLine write FOnUpdateLine;
    property OnReportError : TReportErrorEvent read FOnReportError write FOnReportError;

  public
    constructor Create (AComponent: TComponent); override;
    destructor Destroy; override;
    procedure DoISQL;
    procedure Cancel;
    property SkipCreateConnect : Boolean read FSkipCreateConnect write FSkipCreateConnect;
  end;


implementation

uses
	IBHeader;

function StripQuotes(I : String) : String;
var
	Idx : Integer;

begin
	Result := '';
	for Idx := 1 to Length(I) do
	begin
		if not (I[Idx] in ['"', '''']) then
			Result := Result + I[Idx];
	end;
end;

function TIBSQLObj.ParseSQL(const InputSQL: TStringList; out Data: TStringList; const TermChar: string): boolean;
var
	lTermLen,
	lDelimPos,
  lLineLen,
  lSrc_Cnt: Integer;
  done,
  inStatement,
  inComment: boolean;
  lTmp,
  lLine,
  lTermChar: String;
  Marker : TDataLineMarker;
  StartLine : Integer;
  lComment : String;

begin
  lTermChar := TermChar;
  inComment := false;
  lSrc_Cnt := 0;
  result := true;
  done := false;
  while not done and (lSrc_Cnt < InputSQL.Count) do
  begin
    Application.ProcessMessages;
    // If the line is blank, skip it
    if Length (Trim(InputSQL.Strings[lSrc_Cnt])) = 0 then
    begin
      Inc(lSrc_Cnt);
      Continue;
    end;

    //If the current line contains only a close comment, append it to the last line
    if Trim(InputSQL.Strings[lSrc_Cnt]) = '*/' then
    begin
      Data.Strings[Data.Count-1] := Format('%s%s', [Data.Strings[Data.Count-1], InputSQL.Strings[lSrc_Cnt]]);
      Inc(lSrc_Cnt);
      Continue;
    end;

    // Next, check to see if the line is a comment or starts one. If it does, then remove it
    lDelimPos := AnsiPos('/*', Trim(InputSQL.Strings[lSrc_Cnt]));
    if  lDelimPos = 1 then
    begin
      // since this line contains a comment character, save anything to the left of the comment (if applicable)
      StartLine := lSrc_Cnt + 1;

      if AnsiPos('*/', InputSQL.Strings[lSrc_Cnt]) = 0 then
      begin
        inComment := true;
        lComment := InputSQL.Strings[lSrc_Cnt];
      end;

      // If the line above started a comment, then keep going until the comment is completed
      while inComment do
      begin
        repeat
          Application.ProcessMessages;
          Inc(lSrc_Cnt);
          lComment := lComment + #13#10 + InputSQL.Strings[lSrc_Cnt];
          if (lSrc_Cnt = InputSQL.Count) then
          begin
            result := false;
            done := true;
            continue;
          end;
        until (AnsiPos('*/', InputSQL.Strings[lSrc_Cnt]) <> 0);

        // if there is something after the comment, save it
        lDelimPos := AnsiPos('*/', InputSQL.Strings[lSrc_Cnt]);
        lLine := Format('%s %s', [lLine, Copy (InputSQL.Strings[lSrc_cnt],
          lDelimPos+2, Length(InputSQL.Strings[lSrc_Cnt]))]);
        inComment := false;

        //do we have an XML Block in here....?
        lComment := Trim(lComment);
        if AnsiPos('/*[', lComment) = 1 then
        begin
          //we have an XML Block maybe?
          if Copy(lComment, Length(lComment) - 2, 3) = ']*/' then
          begin
            //we definitely have an XML Block...
            Marker := TDataLineMarker.Create;
            Marker.LineNumber := StartLine;
            lComment := Copy(lComment, 6, Length(lComment));
            lComment := Copy(lComment, 1, Length(lComment) - 5);
            Marker.XMLBlock := lComment;
            Data.AddObject('GSS_XML_BLOCK', Marker);
          end;
        end;
      end;
      Inc (lSrc_Cnt);
      Continue;
    end;

    // Is the delimiter being changed? }
    if AnsiPos ('SET TERM', AnsiUpperCase(Trim(InputSQL.Strings[lSrc_Cnt]))) = 1 then
    begin
      lTmp := Trim(InputSQL.Strings[lSrc_Cnt]);
      Delete (lTmp, 1, Length('SET TERM'));
      lTmp := Trim(lTmp);
      lDelimPos := Pos (lTermChar, lTmp);
      Delete (lTmp, lDelimPos, Length(lTermChar));
      lTermChar := Trim(lTmp);
      lTmp := '';
      Inc (lSrc_Cnt);
      Continue;
    end;

    // If the delimiter is at the end of the line, or if a comment exists
    // after the delimiter, then this is an entire statement.  If there is
    // a comment after the delimiter, remove it
    lDelimPos := AnsiPos (lTermChar, Trim(InputSQL.Strings[lSrc_Cnt]));
    lTermLen := Length (lTermChar);
    lLineLen := Length (Trim(InputSQL.Strings[lSrc_Cnt]));

    if (lDelimPos = (lLineLen - (lTermLen - 1))) or (AnsiPos ('/*', InputSQL.Strings[lSrc_Cnt]) > lDelimPos) then
    begin
      lLine := Trim(Format('%s %s',[lLine, InputSQL.Strings[lSrc_Cnt]]));
      Delete (lLine, lDelimPos, lTermLen);

      // Make sure that the line isn't blank after removing the terminator.
      // Some case tools print too many termination characters
      if Length(Trim(lLine)) <> 0 then
      begin
        Marker := TDataLineMarker.Create;
        Marker.LineNumber := lSrc_Cnt  + 1;
        Data.AddObject(Trim(lLine), Marker);
      end;
      lLine := '';
      Inc(lSrc_Cnt);
    end
    else
    begin
      // This statement spans multiple lines, so concatenate the lines into 1
      //  adding a CR/LF between the lines to ensure that the source looks
      //  as it was added
      inStatement := true;
      StartLine := lsrc_Cnt + 1;
      lLine := Format('%s %s',[lLine, InputSQL.Strings[lSrc_Cnt]]);
      repeat
        Application.ProcessMessages;
        Inc (lSrc_Cnt);
        if (lSrc_Cnt = InputSQL.Count) then
        begin
          result := true;
          done := true;
          instatement := false;
          continue;
        end;
        // Blank line
        if Length (Trim (InputSQL.Strings[lSrc_Cnt])) = 0 then
          Continue;

        lDelimPos := AnsiPos (lTermChar, InputSQL.Strings[lSrc_Cnt]);
        lLineLen := Length (InputSQL.Strings[lSrc_Cnt]);
        if (lDelimPos = (lLineLen - (lTermLen - 1))) or
           ((lDelimPos > 0) and
            (AnsiPos ('/*', InputSQL.Strings[lSrc_Cnt]) > lDelimPos)) then
          inStatement := false;
        lLine := lLine + #13#10 + InputSQL.Strings[lSrc_Cnt];
      until not inStatement;

      // Remove the termination character
      lDelimPos := AnsiPos (lTermChar, lLine);
      Delete (lLine, lDelimPos, lTermLen);

      // Make sure that the line isn't blank after removing the terminator.
      // Some case tools print too many termination characters
      if Length(Trim(lLine)) <> 0 then
      begin
        Marker := TDataLineMarker.Create;
        Marker.LineNumber := StartLine;
        Data.AddObject(Trim(lLine), Marker);
      end;
      lLine := '';
      Inc (lSrc_Cnt);
    end;
  end;
end;


function TIBSQLObj.ParseDBCreate (const InputSQL: String): boolean;
var
  Token : String;

begin
  FConnDBName := '';
  FConnDBUser := '';
  FConnDBPassword := '';
  FConnDBCharSet := '';
  FConnDBRole := '';

  InitTokeniser(InputSQL);
  Token := GetNextToken;
  while Token <> '' do
  begin
    if (AnsiUpperCase(Token) = 'CREATE') then
    begin
      Token := GetNextToken;
      if (AnsiUpperCase(Token) = 'DATABASE') or (AnsiUpperCase(Token) = 'SCHEMA') then
      begin
        Token := GetNextToken;
        FConnDBName := StripQuotes(Token);
      end;
    end
    else
    begin
      if (AnsiUpperCase(Token) = 'USER') or (AnsiUpperCase(Token) = 'USERNAME') then
      begin
        Token := GetNextToken;
        FConnDBUser := StripQuotes(Token);
      end
      else
      begin
        if (AnsiUpperCase(Token) = 'PASS') or (AnsiUpperCase(Token) = 'PASSWORD') then
        begin
          Token := GetNextToken;
          FConnDBPassword := StripQuotes(Token);
        end;
      end;
    end;

    Token := GetNextToken;
  end;

  result := true;
end;

function TIBSQLObj.ParseDBConnect (const InputSQL: String): boolean;
var
  Token : String;

begin
  FConnDBName := '';
  FConnDBUser := '';
  FConnDBPassword := '';
  FConnDBCharSet := '';
  FConnDBRole := '';

  InitTokeniser(InputSQL);
  Token := GetNextToken;
  while Token <> '' do
  begin
    if (AnsiUpperCase(Token) = 'CONNECT') then
    begin
      Token := GetNextToken;
      FConnDBName := StripQuotes(Token);
    end
    else
    begin
      if (AnsiUpperCase(Token) = 'USER') or (AnsiUpperCase(Token) = 'USERNAME') then
      begin
        Token := GetNextToken;
        FConnDBUser := StripQuotes(Token);
      end
      else
      begin
        if (AnsiUpperCase(Token) = 'PASS') or (AnsiUpperCase(Token) = 'PASSWORD') then
        begin
          Token := GetNextToken;
          FConnDBPassword := StripQuotes(Token);
        end;
      end;
    end;
    Token := GetNextToken;    
  end;

  result := true;
end;

function TIBSQLObj.ParseClientDialect (const InputSQL: String): Integer;
var
  lLine: String;
begin
  lLine := Trim(InputSQL);
  Delete (lLine, 1, Length ('SET SQL DIALECT '));
  try
    result := StrToInt(lLine);
  except
    On E : Exception do
    begin
      raise Exception.Create(lLine + ' is not a valid valid for SET SQL DIALECT');
    end;
  end;
end;

function TIBSQLObj.ParseOnOff (const InputSQL, Item: String): Boolean;
var
  lLine: String;
begin
  lLine := Trim(AnsiUpperCase(InputSQL));
  Delete (lLine, 1, Length (Item+' '));

  if Pos ('ON', lLine) = 1 then
    result := true
  else
    if Pos ('OFF', lLine) = 1 then
      result := false
    else
      result := true;
end;

function TIBSQLObj.IsISQLCommand (const InputSQL: String; out Data: Variant): TISQLAction;
var
  lLine: String;

begin
  lLine := Trim(AnsiUpperCase(InputSQL));

  if (Pos ('BLOBDUMP', lLine) = 1) or
     (Pos ('EDIT', lLine) = 1) or
     (Pos ('EXIT', lLine) = 1) or
     (Pos ('HELP', lLine) = 1) or
     (Pos ('QUIT', lLine) = 1) or
     (Pos ('SHOW ',lLine) = 1) then
  begin
     result := actUnSup;
     exit;
  end;

  if (Pos ('IN ', lLine) = 1) or
     (Pos ('INPUT', lLine) = 1) or
     (Pos ('OUT ', lLine) = 1) or
     (Pos ('OUTPUT', lLine) = 1) then
  begin
    if (Pos ('I', lLine) = 1) then
      result := actInput
    else
      result := actOutput;

    // grab the filename to read or output to
    Data := Copy (lLine, Pos (' ', lLine), Length(lLine));
    Data := Trim(Data);
    exit;
  end;

  if Pos('SET COUNT', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET COUNT');
    result := actCount;
    exit;
  end;

  if Pos('SET ECHO', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET ECHO');
    result := actEcho;
    exit;
  end;

  if Pos('SET LIST', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET LIST');
    result := actList;
    exit;
  end;

  if Pos('SET NAMES', lLine) = 1 then
  begin
    result := actNames;

    // Grab the character set name
    Data := Copy (lLine, Length('SET NAMES '), Length(lLine));
    Data := Trim(Data);
    exit;
  end;

  if Pos('SET PLAN', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET PLAN');
    result := actPlan;
    exit;
  end;

  if Pos('SET STATS', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET STATS');
    result := actStats;
    exit;
  end;

  if Pos('SET TIME', lLine) = 1 then
  begin
    Data := ParseOnOff (lLine, 'SET TIME');
    result := actTime;
    exit;
  end;

	// Setting the Client dialect
  if Pos ('SET SQL DIALECT', lLine) = 1 then
  begin
    Data := ParseClientDialect (lLine);
    Data := Trim(Data);
    result := actDialect;
    exit;
  end;

  if (Pos ('SET AUTODDL', lLine) = 1) or
     (Pos ('SET AUTO', lLine) = 1) then
  begin
    if Pos ('DDL', lLine) <> 0 then
      Data := ParseOnOff (lLine, 'SET AUTODDL')
    else
      Data := ParseOnOff (lLine, 'SET AUTO');
    result := actAutoDDL;
    exit;
  end;

  if Pos('GSS_XML_BLOCK', lLine) = 1 then
  begin
    result := actXMLExec;
    exit;
  end;

  result := actUnk;
end;

procedure TIBSQLObj.DoISQL;
var
  ISQLObj: TIBSQLObj;
  lCnt: integer;

  Tmp : String;

  NewSource : TStringList;

  Data,
	Source: TStringList;

  ISQLValue: Variant;
  ISQLAction: TISQLAction;


  ClientDialect: Integer;
  CharSet: String;

  InputFile: TextFile;
  LineNumber : Integer;
  Idx : Integer;
	Doc : TXmlDocument;
	S : TMemoryStream;
	L : TStringList;
	oDataRecord : TDOMNode;
	oNodeOne : TDOMNode;
	oNodeTwo : TDOMNode;
	Position : Integer;
  DataType : String;
  XData : Variant;

  dbHandle: isc_db_handle;
  trHandle: isc_tr_handle;
  SaveCW: word;

begin
  Data := TStringList.Create;
  try
    try
      Source := TStringList.Create;
      try
        Source.AddStrings (FQuery);

        ClientDialect := 1;
        CharSet := '';

        FTransaction.IB_Connection := FDatabase;
				FSQLQuery.IB_COnnection := FDatabase;
        FSQLQuery.IB_Transaction := FTransaction;

        if not ParseSQL (Source, Data, ';') then
          raise EISQLException.Create (0, '', eeParse, 'Unable to parse script');

        FStatements := Data.Count - 1;
      finally
        Source.Free;
      end;

      // Go through the String list excecuting the information line by line.
      // Each statement is executed against the currently connected database
      // and server (if there is one).
      for lCnt := 0 to Data.Count-1 do
      begin
        if FCanceled then
          break;

        Application.ProcessMessages;

        LineNumber := TDataLineMarker(Data.Objects[lCnt]).LineNumber;

        if Assigned(FOnUpdateLine) then
          FOnUpdateLine(Self, LineNumber);

        if Assigned(FProgressEvent) then
          OnQueryProgress(self);

        // Is this an ISQL Command?
        IsqlAction := IsISQLCommand(Data.Strings[lCnt], IsqlValue);
        case ISQlAction of
          actInput:
            begin
              NewSource := nil;
              try
                AssignFile(InputFile, IsqlValue);
                Reset (InputFile);
                NewSource := TStringList.Create;
								while not SeekEof(InputFile) do
                begin
                  Readln(InputFile, Tmp);
                  NewSource.Append(Tmp);
                end;

              except
                on E: Exception do
                begin
                  if Assigned(FOnReportError) then
                    FOnReportError(Self, LineNumber, 'Unable to open the file "' + ISQLValue + '"');
                end;
              end;
              ISQLObj := TIBSQLObj.Create (self);
              with ISQLObj do
              begin
                AutoDDL := FAutoDDL;
                Query := NewSource;
                Database := Self.FDatabase;
                SQLQuery := Self.FSQLQuery;
                OnLineUpdate := Self.FOnUpdateLine;
                OnReportError := Self.FOnReportError;
                DoIsql;
                Free;
                NewSource.Free;
              end;
              Continue;
            end;
          actOutput:
            begin

            end;
          actCount:
            begin
              continue;
            end;

          actEcho:
            begin
							continue;
            end;

          actList:
            begin
              continue;
            end;

          actNames:
            begin
              Charset := ISQLValue;
              continue;
            end;

          actPlan:
            begin
              continue;
            end;

          actStats:
            begin
              continue;
            end;

          actTime:
            begin
              continue;
            end;

          actDialect:
            begin
              ClientDialect := ISQLValue;
              if Assigned (Database) then
              try
                Database.SQLDialect := ClientDialect;
              except
                on E: Exception do
                begin
                  if Assigned(FOnReportError) then
										FOnReportError(Self, LineNumber, 'Invalid dialect (' + IntToStr(ClientDialect) + ')');
                end;
              end;
              continue;
            end;

          actAutoDDL:
            begin
              FAutoDDL := ISQLValue;
              continue;
            end;

          actXMLExec :
            begin
              FTmpQuery.ParamCheck := True;
              FTmpQuery.ParamChar := '?';
              try
                Doc := TXmlDocument.Create;
                try
                  L := TStringList.Create;
                  try
                    L.Text := AdjustLineBreaks(TDataLineMarker(Data.Objects[lCnt]).XMLBlock);
                    S := TMemoryStream.Create;
                    L.SaveToStream(S);
                    S.Position := 0;

                    ReadXMLFile(Doc, TStream(S));

                    oDataRecord := Doc.DocumentElement;
                    if (Assigned(oDataRecord)) and (oDataRecord.NodeName = 'data-record') then
                    begin
                      oNodeOne := oDataRecord.FirstChild;
                      while oNodeOne <> nil do
                      begin
                        if oNodeOne.NodeName = 'statement' then
                        begin
                          FTmpQuery.SQL.Text := oNodeOne.Attributes.GetNamedItem('sql').NodeValue;

													if not FTmpTransaction.Started then
                            FTmpTransaction.StartTransaction;
                          FTmpQuery.Prepare;
                          Break;
                        end;
                        oNodeOne := oNodeOne.NextSibling;
                      end;

                      oNodeOne := oDataRecord.FirstChild;
                      while oNodeOne <> nil do
                      begin
                        if oNodeOne.NodeName = 'data-value' then
                        begin
                          Position := StrToInt(oNodeOne.Attributes.GetNamedItem('position').NodeValue);
                          DataType := oNodeOne.Attributes.GetNamedItem('datatype').NodeValue;
                          if Assigned(oNodeOne.Attributes.GetNamedItem('value')) then
                          begin
                            XData := oNodeOne.Attributes.GetNamedItem('value').NodeValue;
                          end
                          else
                          begin
                            XData := '';
                            oNodeTwo := oNodeOne.FirstChild;
                            while oNodeTwo <> nil do
                            begin
                              if oNodeTwo.NodeName = 'data-line' then
                              begin
                                XData := XData + oNodeTwo.Attributes.GetNamedItem('data').NodeValue + #13#10;
                              end;
                              oNodeTwo := oNodeTwo.NextSibling;
                            end;
                          end;

                          if AnsiUpperCase(XData) = 'NULL' then
                          begin
                            FTmpQuery.Params[Position - 1].IsNull := True;
                          end
                          else
                          begin
														FTmpQuery.Params[Position - 1].AsVariant := XData;
                          end;
                        end;
                        oNodeOne := oNodeOne.NextSibling;
                      end;

                      FTmpQuery.ExecSQL;
                      FTmpTransaction.Commit;
                    end;
                  finally
                    L.Free;
                  end;
                finally
                  Doc.Free;
                end;
              finally
                FTmpQuery.ParamCheck := False;
              end;
              Continue;
            end;

          actUnSup:
            Continue; //just ignore...
        end;
        // Does this line drop a database
        if (Pos ('DROP DATABASE', AnsiUpperCase(Data.Strings[lCnt])) = 1) then
        begin
          FDatabase.DropDatabase;
          continue;
        end;

        // Does this line create a database
        if (Pos ('CREATE DATABASE', AnsiUpperCase(Data.Strings[lCnt])) = 1) or (Pos ('CREATE SCHEMA', AnsiUpperCase(Data.Strings[lCnt])) = 1) then
        begin
          if FSkipCreateConnect then
          begin
            if Assigned(FOnReportError) then
              FOnReportError(Self, LineNumber, 'CREATE DATABASE statement skipped');

						FTmpQuery.IB_Connection := FDatabase;
            FTmpQuery.ParamCheck := False;
            FTmpQuery.IB_Transaction := FTmpTransaction;
            FTmpTransaction.IB_Connection := FDatabase;

            FDDLQuery.IB_Connection := FDatabase;
            FDDLQuery.ParamCheck := False;
            FDDLQuery.IB_Transaction := FDDLTransaction;
            FDDLTransaction.IB_Connection := FDatabase;

          end
          else
          begin
            if not ParseDBCreate (Data.Strings[lCnt]) then
              raise EISQLException.Create (0, '', eeParse, 'An error occured parsing CREATE statement.')
            else
            begin
              try
                try
                  if FDatabase.Connected then
                    raise Exception.Create('Database is connected.');
                except
                  on E: Exception do
                  begin
                    if FTransaction.Started then
                      raise EISQLException.Create (0, FConnDBName, eeConnect, E.Message+#13#10'Commit or Rollback the current transaction')
                    else
                      FDatabase.Close;
                  end;
                end;

                dbHandle := nil;
                trHandle := nil;
                asm
                  fstcw [SaveCW]
                end;
                with FDatabase.IB_Session do
                begin
                  errcode := isc_dsql_execute_immediate(@Status,
																											 @dbHandle,
                                                       @trHandle,
                                                       null_terminated,
                                                       PChar(Data.Strings[lCnt]),
                                                       ClientDialect,
                                                       nil );
                  asm
                    fldcw [SaveCW]
                  end;
                  if errcode = 0 then
                  begin
                    asm
                      fstcw [SaveCW]
                    end;
                    errCode := isc_detach_database( @Status, @dbHandle );
                    asm
                      fldcw [SaveCW]
                    end;
                  end;
                  if errcode <> 0 then
                    HandleException( Self );
                end;

                FDatabase.DatabaseName := FConnDBName;
                FDatabase.SQLDialect := ClientDialect;
                FDatabase.Username := FConnDBUser;
                FDatabase.Password := FConnDBPassword;

                FDatabase.LoginPrompt := false;

                FDatabase.Open;

                FTmpQuery.IB_Connection := FDatabase;
                FTmpQuery.ParamCheck := False;
                FTmpQuery.IB_Transaction := FTmpTransaction;
                FTmpTransaction.IB_Connection := FDatabase;

                FDDLQuery.IB_Connection := FDatabase;
                FDDLQuery.ParamCheck := False;
								FDDLQuery.IB_Transaction := FDDLTransaction;
                FDDLTransaction.IB_Connection := FDatabase;

              except
                on E: Exception do
                raise EISQLException.Create (0, FConnDBName, eeCreate, E.Message);
              end;
            end;
          end;
          Continue;
        end;

        // Does this line connect to a database
        if Pos('CONNECT', AnsiUpperCase(Data.Strings[lCnt])) = 1 then
        begin
          if FSkipCreateConnect then
          begin
            if Assigned(FOnReportError) then
              FOnReportError(Self, LineNumber, 'CONNECT statement skipped');

            FTmpQuery.IB_Connection := FDatabase;
            FTmpQuery.ParamCheck := False;
            FTmpQuery.IB_Transaction := FTmpTransaction;
            FTmpTransaction.IB_Connection := FDatabase;

            FDDLQuery.IB_Connection := FDatabase;
            FDDLQuery.ParamCheck := False;
            FDDLQuery.IB_Transaction := FTmpTransaction;
            FDDLTransaction.IB_Connection := FDatabase;
          end
          else
          begin
            if not ParseDBConnect (Data.Strings[lCnt]) then
              raise EISQLException.Create (0, '', eeParse, 'An error occured parsing CONNECT statement.')
            else
            begin
              try
                try
                  if FDatabase.Connected then
										raise Exception.Create('Database is connected.');
                except
                  on E: Exception do
                  begin
                    if FTransaction.Started then
                      raise EISQLException.Create (0, FConnDBName, eeConnect, E.Message+#13#10'Commit or Rollback the current transaction')
                    else
                      FDatabase.Close;
                  end;
                end;
                FDatabase.DatabaseName := FConnDBName;
                FDatabase.Username := FConnDBUser;
                FDatabase.Password := FConnDBPassword;
                FDatabase.LoginPrompt := false;
                FDatabase.SQLDialect := ClientDialect;
                FDatabase.Open;

                FTmpQuery.IB_Connection := FDatabase;
                FTmpQuery.ParamCheck := False;
                FTmpQuery.IB_Transaction := FTmpTransaction;
                FTmpTransaction.IB_Connection := FDatabase;

                FDDLQuery.IB_Connection := FDatabase;
                FDDLQuery.ParamCheck := False;
                FDDLQuery.IB_Transaction := FTmpTransaction;
                FDDLTransaction.IB_Connection := FDatabase;

              except
                on E: Exception do
                  raise EISQLException.Create (0, FConnDBName, eeConnect, E.Message);
              end;
            end;
          end;
          Continue;
        end;

        FSQLQuery.SQL.Clear;
        FSQLQuery.SQL.Add(Data.Strings[lCnt]);
        // See if the statement is valid
				try
          if FTmpTransaction.Started or FTmpTransaction.InTransaction then
            FTmpTransaction.Commit;

          FTmpTransaction.StartTransaction;

          FTmpQuery.SQL := FSQLQuery.SQL;
          FTmpQuery.Prepare;

          if FTmpTransaction.Started or FTmpTransaction.InTransaction then
            FTmpTransaction.Commit;

          case FTmpQuery.StatementType of
            stCommit:
              begin
                try
                  if FTransaction.Started or FTransaction.InTransaction then
                    FTransaction.Commit;
                  if FDDLTransaction.Started or FDDLTransaction.InTransaction then
                    FDDLTransaction.Commit;
                except
                  on E : Exception do
                  begin
                    if Assigned(FOnReportError) then
                      FOnReportError(Self, LineNumber, E.Message);
                  end;
                end;
              end;

            stRollback:
              begin
                try
                  if FTransaction.Started or FTransaction.InTransaction then
                    FTransaction.Rollback;
                  if FDDLTransaction.Started or FDDLTransaction.InTransaction then
                    FDDLTransaction.Rollback;
                except
                  on E : Exception do
                  begin
                    if Assigned(FOnReportError) then
                      FOnReportError(Self, LineNumber, E.Message);
                  end;
                end;
              end;

            stDDL, stSetGenerator:
              begin
                // Use a different IBQuery since DDL can be set to autocommit
                FDDLQuery.SQL.Clear;
                FDDLQuery.SQL := FSQLQuery.SQL;
                try
                  if not (FDDLTransaction.Started or FDDLTransaction.InTransaction) then
                    FDDLTransaction.StartTransaction;
                  FDDLQuery.Prepare;
                  FDDLQuery.ExecSQL;
                  if FAutoDDL then
                    FDDLTransaction.Commit;

                except
                  on E: Exception do
                  begin
                    if FAutoDDL then
                      FDDLTransaction.Rollback;
                    if Assigned(FOnReportError) then
                      FOnReportError(Self, LineNumber, E.Message);
                  end;
                end;
              end;

            stDelete, stInsert, stUpdate:
              begin
                try
                  if not (FTransaction.Started or FTransaction.InTransaction) then
                    FTransaction.StartTransaction;

                  FSQLQuery.Prepare;
                  FSQLQuery.ExecSQL;
                except
                  on E: Exception do
                  begin
                    if Assigned(FOnReportError) then
                      FOnReportError(Self, LineNumber, E.Message);
                  end;
                end;
              end;

            stSelect, stSelectForUpdate, stExecProcedure:
              begin
                //ignore...
              end;
          end;
        except
          on E: Exception do
          begin
            FTmpTransaction.Rollback;
            if Assigned(FOnReportError) then
              FOnReportError(Self, LineNumber, E.Message);
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        if Assigned(FOnReportError) then
          FOnReportError(Self, LineNumber, E.Message);
      end;
    end;
  finally
    for Idx := 0 to Data.Count - 1 do
    begin
      if Assigned(Data.Objects[Idx]) then
        TObject(Data.Objects[Idx]).Free;
    end;
    Data.Free;
  end;
end;

procedure TIBSQLObj.Cancel;
begin
	FCanceled := true;
end;

constructor TIBSQLObj.Create(AComponent: TComponent);
begin
  inherited;
  FAutoDDL := true;
  FTmpQuery := TIB_DSQL.Create(nil);
  FTmpTransaction := TIB_Transaction.Create(nil);
  FDDLQuery := TIB_DSQL.Create(nil);
  FDDLTransaction := TIB_Transaction.Create(nil);
end;


{ EISQLException }
constructor EISQLException.Create(ErrorCode: Integer;
  ExceptionData: String; ExceptionCode: TISQLExceptionCode; Msg: String);
begin
  inherited Create (Msg);
  FExceptionData := ExceptionData;
  FExceptionCode := ExceptionCode;
  FErrorCode:= ErrorCode;
end;

destructor TIBSQLObj.Destroy;
begin
  FTmpQuery.Free;
  FTmpTransaction.Free;
  FDDLQuery.Free;
  FDDLTransaction.Free;
  inherited;
end;

function TIBSQLObj.GetNextToken: String;
var
  c : Char;

  procedure SkipWhiteSpace;
  var
		Idy : Integer;

  begin
    for Idy := FTokenPos to Length(FTokenBuf) do
    begin
      c := FTokenBuf[Idy];
      if not (c in [#0, #13, #10, ' ', #9]) then
      begin
        FTokenPos := Idy;
        Exit;
      end;
    end;
  end;

begin
  Result := '';
  if not (FTokenPos > Length(FTokenBuf)) then
  begin
    SkipWhitespace;
    while True do
    begin
      c := FTokenBuf[FTokenPos];
      if c in [#0, #13, #10, ' ', #9] then
        Exit
      else
      begin
        Result := Result + c;
        Inc(FTokenPos);
      end;
    end;
  end;
end;

procedure TIBSQLObj.InitTokeniser(S: String);
begin
  FTokenPos := 1;
  FTokenBuf := Trim(S);
end;

procedure TIBSQLObj.SetAutoDDL(const Value: boolean);
begin
  FAutoDDL := Value;
end;

end.

{
$Log: ScriptExecutive.pas,v $
Revision 1.4  2006/10/19 04:01:08  rjmills
Numerous bug fixes and current work in progress

Revision 1.3  2002/04/25 07:14:47  tmuetze
New CVS powered comment block

}
