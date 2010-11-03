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
// $Id: ParseCollection.pas,v 1.5 2005/06/29 22:29:52 hippoman Exp $

unit ParseCollection;

interface
{$I compilerdefines.inc}

uses
	Classes, SysUtils, Dialogs, ComCtrls, DB,
	{$IFDEF D6_OR_HIGHER}
	Variants,
	{$ENDIF}
	IB_Components;
	 
const
  ty_blr_text                         = 14;
  ty_blr_text2                        = 15;
  ty_blr_short                        = 7;
  ty_blr_long                         = 8;
  ty_blr_quad                         = 9;
  ty_blr_int64                        = 16;
  ty_blr_float                        = 10;
  ty_blr_double                       = 27;
  ty_blr_d_float                      = 11;
  ty_blr_timestamp                    = 35;
  ty_blr_varying                      = 37;
  ty_blr_varying2                     = 38;
  ty_blr_blob                         = 261;
  ty_blr_cstring                      = 40;
  ty_blr_cstring2                     = 41;
  ty_blr_blob_id                      = 45;
  ty_blr_sql_date                     = 12;
  ty_blr_sql_time                     = 13;
  ty_blr_date                         = ty_blr_timestamp;



type
  TStatementList = class;

  TOperator = (opOR,
               opAND,
               opNOT,
               opEQUAL,
               opLessThan,
               opGreaterThan,
               opGreaterEqual,
               opLessEqual,
               opNotGreaterThan,
               opNotLessThan,
               opNotEqual,
               opIsNull,
               opIsNotNull,
               opMINUS,
               opPLUS,
               opADD,
               opCONCAT,
               opSUBTRACT,
               opMULTIPLY,
               opDIVIDE,
               opUDF,
               opGENID
               );

  TStatement = class(TObject)
  private
    FCol: Integer;
    FSymScale: Integer;
    FEndLine: Integer;
    FSymPrecision: Integer;
    FLine: Integer;
    FSymSize: Integer;
    FSymType: Integer;
    FSymCharSet: String;
    FSQLStatement: String;
    FName: String;
    FLocalStack: TList;
    FStatements: TList;
    FModule: TObject;
    FExeceptionBlock: TStatement;
    FValue: Variant;
  public
    property SymSize : Integer read FSymSize write FSymSize;
    property SymType : Integer read FSymType write FSymType;
    property SymCharSet : String read FSymCharSet write FSymCharSet;
    property SymPrecision : Integer read FSymPrecision write FSymPrecision;
    property SymScale : Integer read FSymScale write FSymScale;
    property Value : Variant read FValue write FValue;
    property Line : Integer read FLine write FLine;
    property EndLine : Integer read FEndLine write FEndLine;
    property Col : Integer read FCol write FCol;
    property Name : String read FName write FName;
    property Statements : TList read FStatements write FStatements;
    property Module : TObject read FModule write FModule;
    property LocalStack : TList read FLocalStack write FLocalStack;
    property SQLStatement : String read FSQLStatement write FSQLStatement;
    property ExceptionBlock : TStatement read FExeceptionBlock write FExeceptionBlock;
    function Dump(Indent : Integer) : String; virtual;
    procedure Reset; virtual;
    function Execute : Variant; virtual;
    procedure Compile; virtual;
    constructor Create;
    destructor Destroy; override;
  end;

  TProcStub = class(TStatement);

  TProcStatement = class(TStatement)
  private
    FLastStatement: TStatement;
  public
    property LastStatement : TStatement read FLastStatement write FLastStatement;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;


  TExceptionHandlerStatement = class(TStatement)
  public
    Condition : TStatement;
    ConditionTrue : TStatement;
  end;

  TAssignmentStatement = class(TStatement)
  public
    LHS : String;
    RHS : TStatement;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TOperatorStatement = class(TStatement)
  public
    LHS : TStatement;
    RHS : TStatement;
    Operator : TOperator;
    function GetGenIDValue(Generator : String; Increment : String) : Integer;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TExceptionStatement = class(TStatement)
  public
    ExceptionName : String;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;


  TExecProcStatement = class(TStatement)
  public
    ProcInputs : TStatement;
    ProcOutputs : TStatement;
    ProcName : String;
    Step : Boolean;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TExecProcParams = class(TStatement)
  public

  end;

  TIfStatement = class(TStatement)
  public
    Condition : TStatement;
    ConditionTrue : TStatement;
    OptElse : TStatement;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TPostEventStatement = class(TStatement)
  public
    EventName : String;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TSingletonSelectStatement = class(TStatement)
  public
    SQLStatement : TStatement;
    VariableList : TStatement;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TForSelectStatement = class(TStatement)
  private
    Q : TIB_Cursor;
    S : TStringList;
  public
    SQLStatement : TStatement;
    VariableList : TStatement;
    ConditionTrue : TStatement;
    function Next : Boolean;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;


  TDMLStatement = class(TStatement)
  public
    SQLStatement : String;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;


  TWhileStatement = class(TStatement)
  public
    Condition : TStatement;
    ConditionTrue : TStatement;
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TSuspendStatement = class(TStatement)
  public
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;

  TExitStatement = class(TStatement)
  public
    function Dump(Indent : Integer) : String; override;
    procedure Reset; override;
    function Execute : Variant; override;
    procedure Compile; override;
  end;


  TStatementItem = class(TCollectionItem)
  public
    Statement : TStatement;
  end;

  TStatementList = class(TCollection)
  private
    function GetItem(Index: Integer): TStatementItem;
    procedure SetItem(Index: Integer; Value: TStatementItem);
  protected
  public
    function Add: TStatementItem;
    property Items[Index: Integer]: TStatementItem read GetItem write SetItem; default;
    constructor Create;
  end;


implementation

uses
  IBDebuggerVM;


function CleanSymbol(S : String) : String;
begin
  if S <> '' then
  begin
    if S[1] = '?' then
      Result := Copy(S, 2, Length(S))
    else
      Result := S;
  end
  else
    Result := S;
end;

function Spaces(Num : Integer) : String;
var
  Idx : Integer;

begin
  Result := '';
  for Idx := 1 to Num do
  begin
    Result := Result + ' ';
  end;
end;

function ParseSection (ParseLine : String; ParseNum : Integer; ParseSep : Char) : String;
var
  iPos: LongInt;
  i : Integer;
  tmp : String;

begin
  tmp := ParseLine;
  for i := 1 To ParseNum do
  begin
    iPos := Pos(ParseSep, tmp);
    If iPos > 0 Then
    begin
      if i = ParseNum Then
      begin
	Result := Copy(tmp, 1, iPos - 1);
        Exit;
      end
      else
      begin
        Delete(tmp, 1, iPos);
      end;
    end
    else
      If ParseNum > i Then
      begin
        Result := '';
        Exit;
      end
      else
      begin
        Result := tmp;
        Exit;
      end;
  end;
end; 

function GetOperatorDesc(Op : TOperator) : String;
begin
  Result := '';
  case Op of
    opOR :
      Result := 'OR';
    opAND:
      Result := 'AND';
    opNOT:
      Result := 'NOT';
    opEQUAL:
      Result := 'EQUAL';
    opLessThan:
      Result := 'LESS THAN';
    opGreaterThan:
      Result := 'GREATER THAN';
    opGreaterEqual:
      Result := 'GREATER THAN EQUAL';
    opLessEqual:
      Result := 'LESS THAN EQUAL';
    opNotGreaterThan:
      Result := 'NOT GREATER THAN';
    opNotLessThan:
      Result := 'NOT LESS THAN';
    opNotEqual:
      Result := 'NOT EQUAL';
    opIsNull:
      Result := 'IS NULL';
    opIsNotNull:
      Result := 'IS NOT NULL';
    opMINUS:
      Result := 'MINUS';
    opPLUS:
      Result := 'PLUS';
    opADD:
      Result := 'ADD';
    opCONCAT:
      Result := 'CONCAT';
    opSUBTRACT:
      Result := 'SUBTRACT';
    opMULTIPLY:
      Result := 'MULTIPLY';
    opDIVIDE:
      Result := 'DIVIDE';
    opUDF:
      Result := 'UDF CALL';
    opGENID:
      Result := 'GEN_ID';
  end;
end;

constructor TStatementList.Create;
begin
  inherited Create(TStatementItem);
end;

function TStatementList.GetItem(Index: Integer): TStatementItem;
begin
  Result := TStatementItem(inherited GetItem(Index));
end;

procedure TStatementList.SetItem(Index: Integer; Value: TStatementItem);
begin
  inherited SetItem(Index, Value);
end;

function TStatementList.Add: TStatementItem;
begin
  Result := TStatementItem(inherited Add);
end;

constructor TStatement.Create;
begin
  inherited Create;
  Statements := TList.Create;
  LocalStack := TList.Create;
end;

destructor TStatement.Destroy;
begin
  Statements.Free;
  LocalStack.Free;
  inherited Destroy;
end;

function TStatement.Dump(Indent : Integer) : String;
begin
  Result := Spaces(Indent) + 'DEF:' + Name + '[' + IntToStr(Line) + ']' + #13#10;
end;

procedure TStatement.Compile;
begin
end;

procedure TStatement.Reset; 
begin
end;

function TStatement.Execute : Variant;
begin
end;

function TProcStatement.Dump(Indent : Integer) : String;
var
  Idx : Integer;
begin
  Result := '   Proc Block' + '[' + IntToStr(Line) + ']' + #13#10;
  For Idx := 0 to Statements.Count - 1 do
  begin
    Result := Result + Spaces(Indent) + TStatement(Statements[Idx]).Dump(Indent + 3);
  end;
  if Assigned(ExceptionBlock) then
    Result := Result + ExceptionBlock.Dump(Indent);
end;

procedure TProcStatement.Compile;
var
  Idx : Integer;

begin
  if Statements.Count > 0 then
  begin
    For Idx := 0 to Statements.Count - 1 do
    begin
      TProcModule(Module).AllowBreakList.Add(IntToStr(TStatement(Statements[Idx]).Line));
      TStatement(Statements[Idx]).Compile;
    end;
  end;
end;

procedure TProcStatement.Reset;
var
  Idx : Integer;

begin
  if Statements.Count > 0 then
  begin
    For Idx := 0 to Statements.Count - 1 do
    begin
      TStatement(Statements[Idx]).Reset;
    end;
  end;
end;

function TProcStatement.Execute : Variant;
var
  Idx : Integer;

begin
  if Statements.Count > 0 then
  begin
    For Idx := 0 to Statements.Count - 1 do
    begin
      TStatement(Statements[Idx]).Execute;
    end;
  end;
end;

function TAssignmentStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Assignment Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'LHS-->' + LHS + #13#10;
  Result := Result + Spaces(Indent) + 'RHS-->' + #13#10;
  if VarType(RHS.Value) = varEmpty then
  begin
    Result := Result + Spaces(Indent) + '      ' + RHS.Dump(Indent + 3);
  end
  else
  begin
    Result := Result + Spaces(Indent) + '      ' + RHS.Value + #13#10;
  end;
end;

procedure TAssignmentStatement.Compile;
begin
  if VarType(RHS.Value) = varEmpty then
  begin
    RHS.Compile;
  end
end;

procedure TAssignmentStatement.Reset;
begin
  if VarType(RHS.Value) = varEmpty then
  begin
    RHS.Reset;
  end
end;


function TAssignmentStatement.Execute : Variant;
var
  Right : Variant;

begin
  //work out RHS first..
  if VarType(RHS.Value) = varEmpty then
  begin
    Right := RHS.Execute;
  end
  else
  begin
    //just a literal value do the assignment...
    Right := RHS.Value;
    Right := CleanSymbol(Right);
    if TProcModule(Module).DebuggerVM.GetTopSymbolTable.IsSymbol(Right) then
      Right := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(Right);
  end;

  //now do the assignment
  TProcModule(Module).DebuggerVM.GetTopSymbolTable.UpdateSym(LHS, Right);
end;

function TOperatorStatement.Dump(Indent : Integer) : String;
var
  Idx : Integer;

begin
  Result := '   Expression Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'OP-->' + GetOperatorDesc(Operator) + #13#10;
  Result := Result + Spaces(Indent) + 'LHS-->' + #13#10;
  if Not (Operator in [opPLUS, opMINUS, opNOT, opIsNull, opIsNotNull, opGENID, opUDF]) then
  begin
    if LHS.Statements.Count > 0 then
    begin
      For Idx := 0 to LHS.Statements.Count - 1 do
      begin
        Result := Result + Spaces(Indent) + '      ' + TStatement(LHS.Statements[Idx]).Dump(Indent + 3);
      end;
    end
    else
    begin
      if VarType(LHS.Value) = varEmpty then
      begin
        Result := Result + Spaces(Indent) + '      ' + LHS.Dump(Indent + 3);
      end
      else
      begin
        Result := Result + Spaces(Indent) + '      ' + LHS.Value + #13#10;
      end;
    end;
  end;
  Result := Result + Spaces(Indent) + 'RHS-->' + #13#10;
  if RHS.Statements.Count > 0 then
  begin
    For Idx := 0 to RHS.Statements.Count - 1 do
    begin
      Result := Result + Spaces(Indent) + '      ' + TStatement(RHS.Statements[Idx]).Dump(Indent + 3);
    end;
  end
  else
  begin
    if VarType(RHS.Value) = varEmpty then
    begin
      Result := Result + Spaces(Indent) + '      ' + RHS.Dump(Indent + 3);
    end
    else
    begin
      Result := Result + Spaces(Indent) + '      ' + RHS.Value + #13#10;
    end;
  end;
end;

procedure TOperatorStatement.Reset;
begin
  if Not (Operator in [opPLUS, opMINUS, opNOT, opIsNull, opIsNotNull, opGENID, opUDF]) then
  begin
    if VarType(LHS.Value) = varEmpty then
    begin
      LHS.Reset;
    end;
  end;
  if VarType(RHS.Value) = varEmpty then
  begin
    RHS.Reset;
  end
end;

procedure TOperatorStatement.Compile;
begin
  if Not (Operator in [opPLUS, opMINUS, opNOT, opIsNull, opIsNotNull, opGENID, opUDF]) then
  begin
    if VarType(LHS.Value) = varEmpty then
    begin
      LHS.Compile;
    end;
  end;
  if VarType(RHS.Value) = varEmpty then
  begin
    RHS.Compile;
  end
end;

function TOperatorStatement.GetGenIDValue(Generator : String; Increment : String) : Integer;
var
  Q : TIB_Cursor;

begin
  Q := TIB_Cursor.Create(nil);
  try
    Q.IB_Connection := TProcModule(Module).DebuggerVM.Database;
    Q.SQL.Text := 'select gen_id(' + Generator + ', ' + Increment + ') as genid from rdb$database';
    Q.Prepare;
    Q.Execute;
    Q.First;
    if Not Q.EOF then
    begin
      Result := Q.FieldByName('genid').AsInteger;
    end
    else
      Result := 0;
  finally
    Q.Free;
  end;
end;


function TOperatorStatement.Execute : Variant;
var
  Left, Right : Variant;
  RSymName, LSymName : String;

begin
  if Operator in [opPLUS, opMINUS, opNOT, opIsNull, opIsNotNull, opGENID, opUDF] then
  begin
    if VarType(RHS.Value) = varEmpty then
    begin
      Right := RHS.Execute;
    end
    else
    begin
      //is a literal or a symbol
      Right := RHS.Value;
      Right := CleanSymbol(Right);
      if TProcModule(Module).DebuggerVM.GetTopSymbolTable.IsSymbol(Right) then
      begin
        RSymName := Right;
        Right := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(Right);
      end
      else
        RSymName := '';
    end;
    case Operator of
      opPLUS  :
        begin
          if VarIsNull(Right) then
            Result := Null
          else
          begin
            if RSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(RSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := +Double(Right);
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := +LongInt(Right);
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := +Right;
          end;
        end;
      opMINUS :
        begin
          if VarIsNull(Right) then
            Result := Null
          else
          begin
            if RSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(RSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := -Double(Right);
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := -LongInt(Right);
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := -Right;
          end;
        end;
      opNOT :
        begin
          if VarIsNull(Right) then
            Result := False
          else
            Result := Boolean(Not(Right));
        end;
      opIsNull :
        begin
          Result := VarIsNull(Right);
        end;
      opIsNotNull :
        begin
          Result := Not(VarIsNull(Right));
        end;
      opGENID :
        begin
          Result := GetGenIDValue(Right, '1');
        end;
      opUDF :
        begin
          //TODO
          Result := 0; //UDF
        end;
    end;
  end
  else
  begin
    if VarType(LHS.Value) = varEmpty then
    begin
      Left := LHS.Execute;
    end
    else
    begin
      //is a literal or a symbol
      Left := LHS.Value;
      Left := CleanSymbol(Left);
      if TProcModule(Module).DebuggerVM.GetTopSymbolTable.IsSymbol(Left) then
      begin
        LSymName := Left;
        Left := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(Left);
      end
      else
        LSymName := '';
    end;

    if VarType(RHS.Value) = varEmpty then
    begin
      Right := RHS.Execute;
    end
    else
    begin
      //is a literal or a symbol
      Right := RHS.Value;
      Right := CleanSymbol(Right);
      if TProcModule(Module).DebuggerVM.GetTopSymbolTable.IsSymbol(Right) then
      begin
        RSymName := Right;
        Right := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(Right);
      end
      else
        RSymName := '';
    end;
    case Operator of
      opEQUAL:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Left = Right;
        end;
      opADD:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := Null
          else
          begin
            if LSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(LSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := Double(Left) + Right;
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := LongInt(Left) + Right;
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := Left + Right;
          end;
        end;
      opSUBTRACT:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := Null
          else
          begin
            if LSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(LSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := Double(Left) - Right;
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := LongInt(Left) - Right;
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := Left - Right;
          end;
        end;
      opMULTIPLY:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := Null
          else
          begin
            if LSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(LSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := Double(Left) * Right;
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := LongInt(Left) * Right;
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := Left * Right;
          end;
        end;
      opDIVIDE:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := Null
          else
          begin
            if LSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(LSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    //shouldn't happen
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    Result := Double(Left) / Right;
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    Result := LongInt(Left) / Right;
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := Left / Right;
          end;
        end;
      opAND:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left AND Right);
        end;
      opOR:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left OR Right);
        end;
      opGreaterEqual:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left >= Right);
        end;
      opGreaterThan:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left > Right);
        end;
      opLessEqual:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left <= Right);
        end;
      opLessThan:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left < Right);
        end;
      opNotGreaterThan:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left < Right);
        end;
      opNotLessThan:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left > Right);
        end;
      opNotEqual:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := False
          else
            Result := Boolean(Left <> Right);
        end;
      opCONCAT:
        begin
          if VarIsNull(Right) or VarIsNull(Left) then
            Result := Null
          else
          begin
            if LSymName <> '' then
            begin
              case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(LSymName) of
                ty_blr_blob :  //blob
                  begin
                    //shouldn't happen
                  end;
                ty_blr_text, ty_blr_varying :  //string
                  begin
                    Result := String(Left) + Right;
                  end;
                ty_blr_float, ty_blr_d_float, ty_blr_double : //float
                  begin
                    //shouldn't happen
                  end;
                ty_blr_short, ty_blr_long : //integer
                  begin
                    //shouldn't happen
                  end;
                ty_blr_timestamp : //date
                  begin
                    //shouldn't happen
                  end;
              end;
            end
            else
              Result := Left + Right;
          end;
        end;
    end;
  end;
end;

function TIfStatement.Dump(Indent : Integer) : String;
begin
  Result := '   If Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Condition-->' + #13#10;
  Result := Result + Spaces(Indent) + Condition.Dump(Indent + 3);
  Result := Result + Spaces(Indent) + 'Condition True-->' + #13#10;
  Result := Result + Spaces(Indent) + ConditionTrue.Dump(Indent + 3);
  if OptElse <> nil then
  begin
    Result := Result + Spaces(Indent) + 'Else-->' + #13#10;
    Result := Result + Spaces(Indent) + OptElse.Dump(Indent + 3);
  end;
end;

procedure TIfStatement.Reset;
begin
  LocalStack.Clear;
  Condition.Reset;
  ConditionTrue.Reset;
  if OptElse <> nil then
  begin
    OptElse.Reset;
  end;
end;

procedure TIfStatement.Compile;
begin
  Condition.Compile;
  ConditionTrue.Compile;
  if not (ConditionTrue is TProcStatement) then
    TProcModule(Module).AllowBreakList.Add(IntToStr(ConditionTrue.Line));
  if OptElse <> nil then
  begin
    OptElse.Compile;
    if not (OptElse is TProcStatement) then
      TProcModule(Module).AllowBreakList.Add(IntToStr(OptElse.Line));
  end;
end;

function TIfStatement.Execute : Variant;
var
  Cond : Boolean;

begin
  Cond := Condition.Execute;
  if Cond then
  begin
    ConditionTrue.Execute;
  end
  else
  begin
    if OptElse <> nil then
    begin
      OptElse.Execute;
    end;
  end;
end;

function TWhileStatement.Dump(Indent : Integer) : String;
begin
  Result := '   While Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Condition-->' + #13#10;
  Result := Result + Spaces(Indent) + Condition.Dump(Indent + 3);
  Result := Result + Spaces(Indent) + 'Condition True-->' + #13#10;
  Result := Result + Spaces(Indent) + ConditionTrue.Dump(Indent + 3);
end;

procedure TWhileStatement.Reset;
begin
  LocalStack.Clear;
  Condition.Reset;
  ConditionTrue.Reset;
end;

procedure TWhileStatement.Compile;
begin
  Condition.Compile;
  ConditionTrue.Compile;
  if not (ConditionTrue is TProcStatement) then
    TProcModule(Module).AllowBreakList.Add(IntToStr(ConditionTrue.Line));
end;

function TWhileStatement.Execute : Variant;
var
  Cond : Boolean;

begin
  Cond := Condition.Execute;
  while Cond do
  begin
    ConditionTrue.Execute;
    Cond := Condition.Execute;
  end;
end;


function TSingletonSelectStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Singleton Select Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Statement-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + SQLStatement.SQLStatement + #13#10;
  Result := Result + Spaces(Indent) + 'Var List-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + VariableList.SQLStatement + #13#10;
end;

procedure TSingletonSelectStatement.Reset;
begin
  //nothing
end;

function TSingletonSelectStatement.Execute : Variant;
var
  Q : TIB_Cursor;
  S : TStringList;
  Tmp : String;
  Idx : Integer;
  NewValue : Variant;
  VarName : Variant;
  VarValue : Variant;
  SymType : Integer;

begin
  //create our own baby symbol table...
  S := TStringList.Create;
  try
    Idx := 1;
    Tmp := Trim(ParseSection(VariableList.SQLStatement, Idx, ','));
    While Tmp <> '' do
    begin
      if (Tmp[1] = ':') or (Tmp[1] = '?') then
        Tmp := Copy(Tmp, 2, Length(Tmp));
      S.Add(Tmp);  
      Idx := Idx + 1;
      Tmp := Trim(ParseSection(VariableList.SQLStatement, Idx, ','));
    end;

    Q := TIB_Cursor.Create(nil);
    try
      Q.IB_Connection := TProcModule(Module).DebuggerVM.Database;
      Q.SQL.Text := SQLStatement.SQLStatement;
      Q.Prepare;
      for Idx := 0 to Q.ParamCount - 1 do
      begin
        VarName := Q.Params.Columns[Idx].FieldName;
        VarValue := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(VarName);
        if VarIsNull(VarValue) then
        begin
          //Q.Params.Columns[Idx].IsNullable := True;
          Q.Params.Columns[Idx].IsNull := True
        end
        else
        begin
          case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(VarName) of
            ty_blr_blob : ;
            ty_blr_text, ty_blr_varying : Q.Params.Columns[Idx].AsString := String(VarValue);
            ty_blr_float, ty_blr_d_float, ty_blr_double : Q.Params.Columns[Idx].AsDouble := Double(VarValue);
            ty_blr_short, ty_blr_long : Q.Params.Columns[Idx].AsInteger  := Integer(VarValue);
            ty_blr_timestamp : Q.Params.Columns[Idx].AsDateTime := TDateTime(VarValue);
          end;
        end;
      end;
      Q.Execute;

      Q.First;
      if Not Q.EOF then
      begin
        for Idx := 0 to Q.FieldCount - 1 do
        begin
          SymType := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(S[Idx]);
          case SymType of
            ty_blr_blob : ;
            ty_blr_text, ty_blr_varying : NewValue := Q.Fields.Columns[Idx].AsString;
            ty_blr_float, ty_blr_d_float, ty_blr_double : NewValue := Q.Fields.Columns[Idx].AsDouble;
            ty_blr_short, ty_blr_long : NewValue := Q.Fields.Columns[Idx].AsInteger;
            ty_blr_timestamp : NewValue := Q.Fields.Columns[Idx].AsDateTime;
          end;
          TProcModule(Module).DebuggerVM.GetTopSymbolTable.UpdateSym(S[Idx], NewValue);
        end;
        //check for another row....
        Q.Next;
        if Not Q.EOF then
          raise Exception.Create('Multiple rows in singleton select');
      end
      else
      begin
        for Idx := 0 to S.Count - 1 do
        begin
          NewValue := Null;
          TProcModule(Module).DebuggerVM.GetTopSymbolTable.UpdateSym(S[Idx], NewValue);
        end;
      end;
    finally
      Q.Free;
    end;
  finally
    S.Free;
  end;
end;

procedure TSingletonSelectStatement.Compile;
begin
end;


function TForSelectStatement.Dump(Indent : Integer) : String;
begin
  Result := '   For Select Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Statement-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + SQLStatement.SQLStatement + #13#10;
  Result := Result + Spaces(Indent) + 'Var List-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + VariableList.SQLStatement + #13#10;
  Result := Result + Spaces(Indent) + 'Condition True-->' + #13#10;
  Result := Result + Spaces(Indent) + ConditionTrue.Dump(Indent + 3);
end;

procedure TForSelectStatement.Reset;
begin
  LocalStack.Clear;
  ConditionTrue.Reset;
end;

function TForSelectStatement.Execute : Variant;
begin
  //nothing
end;

procedure TForSelectStatement.Compile;
begin
  ConditionTrue.Compile;
  if not (ConditionTrue is TProcStatement) then
    TProcModule(Module).AllowBreakList.Add(IntToStr(ConditionTrue.Line));
end;

function TForSelectStatement.Next : Boolean;
var
  Idx : Integer;
  Tmp : String;
  VarName : Variant;
  VarValue : Variant;
  NewValue : Variant;


begin
  if Not Assigned(Q) then
  begin
    Q := TIB_Cursor.Create(nil);
    Q.IB_Connection := TProcModule(Module).DebuggerVM.Database;
    S := TStringList.Create;

    Idx := 1;
    Tmp := Trim(ParseSection(VariableList.SQLStatement, Idx, ','));
    While Tmp <> '' do
    begin
      S.Add(Copy(Tmp, 2, Length(Tmp)));
      Idx := Idx + 1;
      Tmp := Trim(ParseSection(VariableList.SQLStatement, Idx, ','));
    end;

    Q.SQL.Text := SQLStatement.SQLStatement;
    Q.Prepare;
    for Idx := 0 to Q.ParamCount - 1 do
    begin
      VarName := Q.Params.Columns[Idx].FieldName;
      VarValue := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(VarName);
      if VarIsNull(VarValue) then
      begin
        //Q.Params.Columns[Idx].IsNullable := True;
        Q.Params.Columns[Idx].IsNull := True
      end
      else
      begin
        case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(VarName) of
          ty_blr_blob : ;
          ty_blr_text, ty_blr_varying : Q.Params.Columns[Idx].AsString := String(VarValue);
          ty_blr_float, ty_blr_d_float, ty_blr_double : Q.Params.Columns[Idx].AsDouble := Double(VarValue);
          ty_blr_short, ty_blr_long : Q.Params.Columns[Idx].AsInteger  := Integer(VarValue);
          ty_blr_timestamp : Q.Params.Columns[Idx].AsDateTime := TDateTime(VarValue);
        end;
      end;
    end;
    Q.Execute;
    Q.First;
  end
  else
    Q.Next;

  if not Q.EOF then
  begin
    for Idx := 0 to Q.FieldCount - 1 do
    begin
      case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(S[Idx]) of
        ty_blr_blob : ;
        ty_blr_text, ty_blr_varying : NewValue := Q.Fields.Columns[Idx].AsString;
        ty_blr_float, ty_blr_d_float, ty_blr_double : NewValue := Q.Fields.Columns[Idx].AsDouble;
        ty_blr_short, ty_blr_long : NewValue := Q.Fields.Columns[Idx].AsInteger;
        ty_blr_timestamp : NewValue := Q.Fields.Columns[Idx].AsDateTime;
      end;
      TProcModule(Module).DebuggerVM.GetTopSymbolTable.UpdateSym(S[Idx], NewValue);
    end;
    Result := True;
  end
  else
  begin
    Q.Free;
    Q := nil;
    S.Free;
    S := nil;
    Result := False;
  end;
end;

function TExceptionStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Exception Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Exception-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + ExceptionName + #13#10;
end;

procedure TExceptionStatement.Reset;
begin
  //nothing
end;

function TExceptionStatement.Execute : Variant;
begin
  raise Exception.Create(ExceptionName);
end;

procedure TExceptionStatement.Compile;
begin
end;

function TExecProcStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Exec Proc Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Statement-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + SQLStatement + #13#10;
end;

procedure TExecProcStatement.Reset;
begin
  //nothing
end;

function TExecProcStatement.Execute : Variant;
var
  CS : TCallStackItem;
  Idx : Integer;
  Statement : TStatement;
  S : TSymbolTable;
  L : TList;
  Sym : TSymbol;

begin
  //copy the appropriate variables across...
  S := TProcModule(Module).DebuggerVM.ModuleByName[ProcName].GetSymbolTable;
  L := TList.Create;
  try
    for Idx := 0 to S.Count - 1 do
    begin
      if TSymbol(S.Items[Idx]).SymbolType = stInput then
        L.Add(S.Items[Idx]);
    end;
    for Idx := 0 to ProcInputs.Statements.Count - 1 do
    begin
      Sym := TSymbol(L[Idx]);
      Statement := TStatement(ProcInputs.Statements[Idx]);

      S.UpdateSym(Sym.Name, Statement.Value);
    end;
  finally
    L.Free;
  end;
  //create the callstack item and ince the call stack, call execute to get the ball rolling...
  CS := TCallStackItem.Create;
  CS.ModuleName := ProcName;
  CS.SymbolTable.Assign(TProcModule(Module).DebuggerVM.ModuleByName[ProcName].GetSymbolTable);
  TProcModule(Module).DebuggerVM.CallStack.Insert(0, CS);
  TProcModule(Module).DebuggerVM.Execute(Step);
end;

procedure TExecProcStatement.Compile;
begin
  TProcModule(Module).DebuggerVM.CompileSubProc(ProcName);
end;


function TDMLStatement.Dump(Indent : Integer) : String;
begin
  Result := '   DML Statement' + '[' + IntToStr(Line) + ']' + #13#10;
  Result := Result + Spaces(Indent) + 'Statement-->' + #13#10;
  Result := Result + Spaces(Indent) + '   ' + SQLStatement + #13#10;
end;

procedure TDMLStatement.Reset;
begin
  //nothing
end;

function TDMLStatement.Execute : Variant;
var
  Q : TIB_DSQL;
  Idx : Integer;
  VarName : Variant;
  VarValue : Variant;


begin
  Q := TIB_DSQL.Create(nil);
  try
    Q.IB_Connection := TProcModule(Module).DebuggerVM.Database;
    Q.SQL.Text := SQLStatement;
    Q.Prepare;
    for Idx := 0 to Q.ParamCount - 1 do
    begin
      VarName := Q.Params.Columns[Idx].FieldName;
      VarValue := TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymValue(VarName);
      if VarIsNull(VarValue) then
        Q.Params.Columns[Idx].IsNull := True
      else
      begin
        case TProcModule(Module).DebuggerVM.GetTopSymbolTable.GetSymType(VarName) of
          ty_blr_blob : ;
          ty_blr_text, ty_blr_varying : Q.Params.Columns[Idx].AsString := String(VarValue);
          ty_blr_float, ty_blr_d_float, ty_blr_double : Q.Params.Columns[Idx].AsDouble := Double(VarValue);
          ty_blr_short, ty_blr_long : Q.Params.Columns[Idx].AsInteger := Integer(VarValue);
          ty_blr_timestamp : Q.Params.Columns[Idx].AsDateTime := TDateTime(VarValue);
        end;
      end;
    end;
    Q.Execute;
  finally
    Q.Free;
  end;
end;

procedure TDMLStatement.Compile;
begin
end;


function TPostEventStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Post Event Statement' + '[' + IntToStr(Line) + ']' + #13#10;
end;

procedure TPostEventStatement.Reset;
begin
  //nothing
end;

function TPostEventStatement.Execute : Variant;
begin
  //nothing
end;

procedure TPostEventStatement.Compile;
begin
end;

function TSuspendStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Suspend Statement' + '[' + IntToStr(Line) + ']' + #13#10;
end;

procedure TSuspendStatement.Reset;
begin
  //nothing
end;

function TSuspendStatement.Execute : Variant;
var
  Idx : Integer;

begin
  TProcModule(Module).HaveOutPut := True;
  if Not TProcModule(Module).ExecutionResults.Active then
    TProcModule(Module).ExecutionResults.Open;

  for Idx := 0 to TProcModule(Module).DebuggerVM.GetTopSymbolTable.Count - 1 do
  begin
    if TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].SymbolType = stOutput then
    begin
      if TProcModule(Module).ExecutionResults.State <> dsInsert then
        TProcModule(Module).ExecutionResults.Append;
      case TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].SymType of
        ty_blr_blob:
          begin
            TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
          end;

        ty_blr_varying,
        ty_blr_varying2,
        ty_blr_text,
        ty_blr_text2 :
          begin
            if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
            else
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
          end;

        ty_blr_float,
        ty_blr_double,
        ty_blr_d_float:
          begin
            if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
            else
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
          end;

        ty_blr_int64,
        ty_blr_short,
        ty_blr_long:
          begin
            if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
            else
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
          end;

        ty_blr_sql_time,
        ty_blr_sql_date,
        ty_blr_timestamp:
          begin
            if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
            else
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
          end;
      end;
    end;
  end;
  if TProcModule(Module).ExecutionResults.State = dsInsert then
    TProcModule(Module).ExecutionResults.Post;
end;

procedure TSuspendStatement.Compile;
begin
end;

function TExitStatement.Dump(Indent : Integer) : String;
begin
  Result := '   Exit Statement' + '[' + IntToStr(Line) + ']' + #13#10;
end;

procedure TExitStatement.Reset;
begin
  //nothing
end;

function TExitStatement.Execute : Variant;
var
  Idx : Integer;

begin
  if not TProcModule(Module).HaveOutPut then
  begin
    if Not TProcModule(Module).ExecutionResults.Active then
      TProcModule(Module).ExecutionResults.Open;

    for Idx := 0 to TProcModule(Module).DebuggerVM.GetTopSymbolTable.Count - 1 do
    begin
      if TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].SymbolType = stOutput then
      begin
        if TProcModule(Module).ExecutionResults.State <> dsInsert then
          TProcModule(Module).ExecutionResults.Append;
        case TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].SymType of
          ty_blr_blob:
            begin
              TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
            end;

          ty_blr_varying,
          ty_blr_varying2,
          ty_blr_text,
          ty_blr_text2 :
            begin
              if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
              else
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
            end;

          ty_blr_float,
          ty_blr_double,
          ty_blr_d_float:
            begin
              if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
              else
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
            end;

          ty_blr_int64,
          ty_blr_short,
          ty_blr_long:
            begin
              if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
              else
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
            end;

          ty_blr_sql_time,
          ty_blr_sql_date,
          ty_blr_timestamp:
            begin
              if VarIsNull(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value) then
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).Clear
              else
                TProcModule(Module).ExecutionResults.FieldByName(TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Name).AsString := TProcModule(Module).DebuggerVM.GetTopSymbolTable.Items[Idx].Value;
            end;
        end;
      end;
    end;
    if TProcModule(Module).ExecutionResults.State = dsInsert then
      TProcModule(Module).ExecutionResults.Post;
  end;    
end;

procedure TExitStatement.Compile;
begin
end;

end.

{
$Log: ParseCollection.pas,v $
Revision 1.5  2005/06/29 22:29:52  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.4  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
