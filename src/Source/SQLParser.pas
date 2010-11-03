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
// $Id: SQLParser.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit SQLParser;

interface

uses
  Windows, Classes, SysUtils;

type
  TTokenType = (tkNone, tkKeyWord, tkIdent, tkNumber, tkString, tkComment,
                tkTerm, tkComma, tkBracket, tkOperator, tkWhiteSpace, tkOther);

  TSQLKeyWord = (
    kwNone,
    kwSet,
    kwTerm
    );

  TToken = record
    Offset : Longint;
    Len : LongInt;
    TokenType : TTokenType;
    TokenText : String;
    KeyWord : TSQLKeyWord;
  end;

  TParseState = (psNormal, psIdent, psKeyword, psNumber,
                 psString, psComment, psBracket, psOperator,
                 psTerminator, psComma, psWhiteSpace, psOther);

  TCustomSQLParser = class(TObject)
  private
    FKeyWords : TStringList;
    FInput : String;
    FTermChar : Char;
    Ch, Next: Char;
    FState : TParseState;
    FOutPut : String;
    FPrior : Boolean;
    FIndex : Integer;
    StrDelimCount : Integer;
    procedure PushChar(Ch: Char);
    procedure Mark;
    function IsKeyWord(Ident : String) : Boolean;
    function GetKeywordType(Ident : String) : TSQLKeyword; dynamic;
    procedure SetInput(Value : String);
    function GetNextToken : TToken;
  protected
    property NextToken : TToken read GetNextToken;
    property TerminatorChar : Char read FTermChar write FTermChar;
    property Input : String read FInput write SetInPut;
    property KeyWords : TStringList read FKeyWords write FKeyWords;
  public
    constructor Create; dynamic;
    destructor Destroy; override;
  end;

  TSQLParser = class(TCustomSQLParser)
  private
    function GetKeywordType(Ident : String) : TSQLKeyword; override;
  public
    property Input;
    property NextToken;
    constructor Create; override;
  end;

  TStatementInfo = record
    Offset : LongInt;
    Statement : String;
  end;

  TSQLScriptParser = class(TCustomSQLParser)
  private
    function GetNextStatement : TStatementInfo;
  public
    property Input;
    property TerminatorChar;
    property NextStatement : TStatementInfo read GetNextStatement;
  end;


implementation

const
  STRDELIM1 = '"';
  STRDELIM2 = #39;


const
  DIGIT = ['0'..'9'];
  ALPHA = ['A'..'Z', 'a'..'z'];
  IDENT = ALPHA + DIGIT + ['_'];

  _Alpha : set of char = ['A'..'Z'];
  ZERO =  '0';
  NINE =  '9';
  TAB =   #9;
  SPACE = ' ';
  CR =    #13;
  NULL =  #0;
  LF =    #10;

constructor TCustomSQLParser.Create;
begin
  inherited Create;
  FKeywords := TStringList.Create;
end;

destructor TCustomSQLParser.Destroy;
begin
  FKeyWords.Free;
  inherited Destroy;
end;

procedure TCustomSQLParser.SetInput(Value : String);
begin
  FInput := Value + ' ';
  FTermChar := ';';
  Findex := 1;
end;

procedure TCustomSQLParser.PushChar(Ch: Char);
begin
  FOutput := FOutPut + Ch;
  Inc(FIndex);
end;

procedure TCustomSQLParser.Mark;
begin
  FPrior := False;
end;

function TCustomSQLParser.IsKeyWord(Ident : String) : Boolean;
var
  Idx : Integer;

begin
  Result := False;
  for Idx := 0 to FKeyWords.Count - 1 do
  begin
    if AnsiUpperCase(Ident) = AnsiUpperCase(FKeyWords[Idx]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TCustomSQLParser.GetKeywordType(Ident : String) : TSQLKeyword;
begin
  Result := kwNone;
end;


function TCustomSQLParser.GetNextToken : TToken;
begin
  if Not (Length(FInput) > 0) then
    raise Exception.Create('No input');
  if FIndex > Length(FInput) then
  begin
    Result.Offset := 0;
    Result.Len := 0;
    Result.TokenType := tkNone;
    Result.TokenText := '';
    Result.KeyWord := kwNone;
  end;

  while FIndex <= Length(FInput) do
  begin
    Ch := FInput[FIndex];
    if FIndex < Length(FInput) then
      Next := FInput[FIndex + 1]
    else
      Next := #0;

    case FState of
      psIdent :
        begin
          if not (Ch in  ALPHA + [ZERO..NINE,'_']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenText := FOutPut;
            if IsKeyWord(FOutPut) then
            begin
              Result.TokenType := tkKeyWord;
              Result.KeyWord := GetKeyWordType(FOutPut);
            end
            else
            begin
              Result.TokenType := tkIdent;
              Result.KeyWord := kwNone;
            end;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psOperator :
        begin
          if not (Ch in ['>','<','=','+','-']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkOperator;
            Result.TokenText := FOutPut;
            Result.KeyWord := kwNone;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psBracket :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkBracket;
          Result.TokenText := FOutPut;
          Result.KeyWord := kwNone;
          FState := psNormal;
          Exit;
        end;

      psWhiteSpace :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkWhiteSpace;
          Result.TokenText := FOutPut;
          Result.KeyWord := kwNone;
          FState := psNormal;
          Exit;
        end;

      psOther :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkOther;
          Result.TokenText := FOutPut;
          Result.KeyWord := kwNone;
          FState := psNormal;
          Exit;
        end;

      psTerminator :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkTerm;
          Result.TokenText := FOutPut;
          Result.KeyWord := kwNone;
          FState := psNormal;
          Exit;
        end;

      psComma :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkComma;
          Result.TokenText := FOutPut;
          Result.KeyWord := kwNone;
          FState := psNormal;
          Exit;
        end;

      psNumber :
        begin
          if not (Ch in [ZERO..NINE,'.','E','e']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkNumber;
            Result.TokenText := FOutPut;
            Result.KeyWord := kwNone;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psString :
        begin
          case Ch of
            STRDELIM1, STRDELIM2:
              begin
                FOutPut := FOutPut + Ch;
                StrDelimCount := StrDelimCount + 1;
                if Not Odd(StrDelimCount) then
                begin
                  if Not (Next in [STRDELIM1, STRDELIM2]) then
                  begin
                    Result.Offset := FIndex - Length(FOutPut);
                    Result.Len := Length(FOutPut);
                    Result.TokenType := tkString;
                    Result.TokenText := FOutPut;
                    Result.KeyWord := kwNone;
                    FState := psNormal;
                    PushChar(Next);
                    Exit;
                  end
                  else
                  begin
                    PushChar(Next);
                    StrDelimCount := StrDelimCount + 1;
                  end;
                end
                else
                begin
                  StrDelimCount := StrDelimCount + 1;
                end;
              end;
          else
            begin
              FOutPut := FOutPut + Ch;
            end;
          end;
        end;

      psNormal :
        begin
          if Ch = FTermChar then
          begin
            FState := psTerminator;
          end
          else
          begin
            case Ch of
              SPACE, NULL, TAB, CR, LF :
                begin
                  FState := psWhiteSpace;
                end;

              '>','<','=','+','-' :
                begin
                  FState := psOperator;
                end;

              '[',']','(',')' :
                begin
                  FState := psBracket;
                end;

              ',' :
                begin
                  FState := psComma;
                end;

              ZERO..NINE :
                begin
                  FState := psNumber;
                end;

              '#','$' :
                begin
                  if Next in DIGIT then
                  begin
                    FState := psNumber;
                    Mark;
                  end;
                end;

              'A'..'Z','a'..'z', '_' :
                begin
                  begin
                    FState := psIdent;
                    Mark;
                  end;
                end;

              STRDELIM1, STRDELIM2:
                begin
                  begin
                    FState := psString;
                    StrDelimCount := 1;
                    Mark;
                  end;
                end;


              '/' :
                begin
                  if Next = '*' then
                  begin
                    FState := psComment;
                    Mark;
                  end;
                end;
            else
              FState := psOther;
            end;
          end;
          FOutPut := Ch;
        end;

      psComment :
        begin
          if Ch = '*' then
          begin
            FOutput := FOutPut + Ch;
						if Next = '/' then
            begin
              PushChar(Next);
              Result.Offset := FIndex - Length(FOutPut);
              Result.Len := Length(FOutPut);
              Result.TokenType := tkComment;
              Result.TokenText := FOutPut;
              Result.KeyWord := kwNone;
              FState := psNormal;
              Exit
            end;
          end
          else
            FOutput := FOutPut + Ch;
        end;
    end;
    Inc(FIndex);
  end;

  //catch any unfinished business we have here...
  if FIndex > Length(FInput) then
  begin
    Result.Offset := 0;
    Result.Len := 0;
    Result.TokenType := tkNone;
    Result.TokenText := '';
    Result.KeyWord := kwNone;
  end;
end;


constructor TSQLParser.Create;
begin
  inherited Create;
	FKeyWords.Add('SET');
  FKeyWords.Add('TERM');
end;

function TSQLParser.GetKeywordType(Ident : String) : TSQLKeyword;
begin
  inherited GetKeywordType(Ident);
  if AnsiUpperCase(Ident) = 'SET' then
    Result := kwSet;
  if AnsiUpperCase(Ident) = 'TERM' then
    Result := kwTerm;
end;



function TSQLScriptParser.GetNextStatement : TStatementInfo;
var
  T : TToken;
  Statement : String;
  Offs : LongInt;
  Num1 : Boolean;

begin
  Statement := '';
  Offs := 1;
  Num1 := True;
  T := GetNextToken;
  while T.TokenType <> tkNone do
  begin
    Case T.TokenType of
      tkKeyWord,
      tkIdent,
      tkNumber,
      tkString,
			tkComma,
      tkBracket,
      tkOperator,
      tkOther:
        begin
          if Num1 then
          begin
            Num1 := False;
            Offs := T.Offset - 1;
          end;
          Statement := Statement + T.TokenText;
        end;

      tkWhiteSpace :
        begin
          if Not Num1 then
            Statement := Statement + T.TokenText;
        end;

      tkTerm :
        begin
          Result.Statement := Statement;
          Result.Offset := Offs;
          Exit;
        end;
    end;
    T := GetNextToken;
  end;
end;

end.

{
$Log: SQLParser.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
