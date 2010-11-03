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
// $Id: IBDebuggerVM.pas,v 1.6 2005/06/29 22:29:51 hippoman Exp $

unit IBDebuggerVM;

interface

{$I compilerdefines.inc}

uses
	Classes, SysUtils, Windows, ParseCollection, Controls, Forms, Dialogs,
	{$IFDEF D6_OR_HIGHER}
	Variants,
	{$ENDIF}
	rmMemoryDataSet,
	rmTreeNonView,
	IB_Components,
	IBODataset,
	MarathonProjectCacheTypes,
	YaccLib;

type
  TSymbolType = (stLocal, stInput, stOutput);

  TInterpreterState = (intRunning, intCompleted, intException, intPaused, intCallStackInc);

  TSymbol = class(TCollectionItem)
  public
    SymType : Integer;
    SymSize : Integer;
    SymCharSet : String;
    SymScale : Integer;
    SymPrecision : Integer;
    Name : String;
    Value : Variant;
    SymbolType : TSymbolType;
    procedure Assign(Source : TPersistent); override;
  end;

  TSymbolTable = class(TCollection)
  private
    function GetItem(Index: Integer): TSymbol;
    procedure SetItem(Index: Integer; Value: TSymbol);
  protected
  public
    function IsSymbol(SymbolName : Variant) : Boolean;
    function GetSymValue(SymbolName : Variant) : Variant;
    function GetSymType(SymbolName : Variant) : Integer;
    function UpdateSym(SymbolName : Variant; Value : Variant) : Boolean;
		function Add: TSymbol;
    property Items[Index: Integer]: TSymbol read GetItem write SetItem; default;
    constructor Create;
  end;

  TIBDebuggerVM = class;

  TProcModule = class(TObject)
	private
    FBreak : Boolean;
    FSymbolTable : TSymbolTable;
    FSQLParser : TCustomParser;
    FStatement : TStatement;
    FBreakList : TStringList;
    FStepDownStack : TList;
		FAllowBreakList : TStringList;
    FCurrentLine : Integer;
    FStatementPointer : TStatement;
    FDebuggerVM: TIBDebuggerVM;
    FProcName: String;
    FState: TInterpreterState;
    FIsInterbase6: Boolean;
    FSQLDialect: Integer;
    FJunkList : TList;
    FHaveOutput: Boolean;
    FErrorMessage: String;
    function ProcessBreakpoint(Line : Integer) : Boolean;
    function GetNextStatement(S : TStatement; var BPSet : Boolean) : Boolean;
  public
    ExecutionResults : TrmMemoryDataSet;
    procedure Execute(Step : Boolean);
    procedure Reset;
    procedure Clear;
    procedure BreakExecution;
    function Compile(ProcName : String; ProcSource : String) : Boolean;
    function Dump : String;
    function Errors : String;
    function Output : String;
    constructor Create;
    destructor Destroy; override;
    function GetSymbolTable : TSymbolTable;
    property Parser : TCustomParser read FSQLParser write FSQLParser;
    property RootStatement : TStatement read FSTatement write FStatement;
		property CurrentStatement : TStatement read FSTatementPointer write FStatementPointer;
    property BreakList : TStringList read FBreakList write FBreakList;
    property AllowBreakList : TStringList read FAllowBreakList write FAllowBreakList;
    property DebuggerVM : TIBDebuggerVM read FDebuggerVM write FDebuggerVM;
		property ProcName : String read FProcName write FProcName;
    property CurrentLine : Integer read FCurrentLine;
    property State : TInterpreterState read FState write FState;
    property IsInterbase6 : Boolean read FIsInterbase6 write FIsInterbase6;
    property SQLDialect : Integer read FSQLDialect write FSQLDialect;
    property HaveOutPut : Boolean read FHaveOutput write FHaveOutput;
    property ErrorMessage : String read FErrorMessage write FErrorMessage;
	end;

  TCallStackItem = class(TObject)
  private
    FModuleName: String;
    FSymbolTable: TSymbolTable;
    FPushedStatement: TStatement;
  public
    constructor Create;
    destructor Destroy; override;
    property ModuleName : String read FModuleName write FModuleName;
    property SymbolTable : TSymbolTable Read FSymbolTable write FSymbolTable;
    property PushedStatement : TStatement read FPushedStatement write FPushedStatement;
  end;

  TBreakPoint = class(TObject)
  private
    FLine: Integer;
    FObjectName: String;
    FConnectionName: String;
    FBreak: Boolean;
    FLog: Boolean;
    FPassCount: Integer;
    FLogMessage: String;
    FCondition: String;
    FInternalPassCount: Integer;
  public
    property ConnectionName : String read FConnectionName write FConnectionName;
		property ObjectName : String read FObjectName write FObjectName;
    property Line : Integer read FLine write FLine;
    property Condition : String read FCondition write FCondition;
    property PassCount : Integer read FPassCount write FPassCount;
		property InternalPassCount : Integer read FInternalPassCount write FInternalPassCount;
    property Break : Boolean read FBreak write FBreak;
    property Log : Boolean read FLog write FLog;
    property LogMessage : String read FLogMessage write FLogMessage;
  end;

  TIBDebuggerVM = class(TObject)
	private
    FBreakPoints : TList;
    FCallStack : TList;
    FModules : TList;
    FExecuting: Boolean;
    FEnabled: Boolean;
    FDatabase : TIB_Connection;
    FDatabaseName: String;
    FWatchList : TList;
    function GetModuleByIndex(Index: Integer): TProcModule;
    function GetModuleCount: Integer;
    function GetModuleByName(Name: String): TProcModule;
    function GetBreakPointByIndex(Index: Integer): TBreakPoint;
    function GetBreakPointCount: Integer;
    function GetState: TInterpreterState;
  public
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
    procedure Execute(Step : Boolean);
    procedure Reset;
    procedure BreakExecution;
    procedure ShowExecutionPoint;
    procedure UpdateDebugWindows;
    procedure UpdateCallStack;
    procedure UpdateLocals;
    procedure UpdateWatches;
    function Compile(ProcName : String; ProcSource : String) : Boolean;
		function CompileSubProc(ProcName : String) : Boolean;
    function Dump : String;
    function Errors : String;
    function Output : String;
		function GetTopSymbolTable : TSymbolTable;
    procedure AddBreakPoint(DatabaseName : String; ObjectName : String; Line : Integer);
    procedure AddWatch(Expression : String; Enabled : Boolean);
    procedure AddWatchAtCursor(SymbolName : String);
    procedure AddWatchDialog;
    procedure ToggleBreakPoint(DatabaseName : String; ObjectName : String; Line : Integer);
    procedure EvalModify;
		function EvalExpression(Expression : String) : Variant;
    property BreakPointCount : Integer read GetBreakPointCount;
    property BreakPoints[Index : Integer] : TBreakPoint read GetBreakPointByIndex;
    property ModuleCount : Integer read GetModuleCount;
    property Modules[Index : Integer] : TProcModule read GetModuleByIndex;
    property ModuleByName[Name : String] : TProcModule read GetModuleByName;
    property CallStack : TList read FCallStack write FCallStack;
    property WatchList : TList read FWatchList write FWatchList;
    property Executing : Boolean read FExecuting;
    property Enabled : Boolean read FEnabled write FEnabled;
    property Database : TIB_COnnection read FDatabase write FDatabase;
    property DatabaseName : String read FDatabaseName write FDatabaseName;
    property State : TInterpreterState read GetState;
  end;

  TWatch = class(TObject)
  private
    FExpression: String;
    FDebuggerVM: TIBDebuggerVM;
    FEnabled: Boolean;
    function GetValue: String;
  public
    property DebuggerVM : TIBDebuggerVM read FDebuggerVM write FDebuggerVM;
    property Expression : String read FExpression write FExpression;
    property Value : String read GetValue;
    property Enabled : Boolean read FEnabled write FEnabled;
  end;


implementation

uses
	Globals,
	MarathonIDE,
	MarathonInternalInterfaces,
  DebugAddBreakPoint,
  DebugEvalModify,
  DebugCallStack,
  DebugLocalVariables,
	DebugBreakPoints,
  DebugWatches,
  AddWatch,
  SQLYacc;

constructor TProcModule.Create;
begin
  inherited Create;
  FSymbolTable := TSymbolTable.Create;
  ExecutionResults := TrmMemoryDataSet.Create(nil);
  FStepDownStack := TList.Create;
  FBreakList := TStringList.Create;
  FAllowBreakList := TStringList.Create;
  FSQLParser := TSQLParser.Create(nil);
  FJunkList := TList.Create;
  with FSQLParser as TSQLParser do
  begin
    ParserType := ptDebugger;
    Module := Self;
  end;
end;

destructor TProcModule.Destroy;
var
  Idx : INteger;

begin
  if Assigned(FSQLParser) then
    FSQLParser.Free;
  if Assigned(FSymbolTable) then
    FSymbolTable.Free;
  if Assigned(FBreakList) then
		FBreakList.Free;
  if Assigned(FAllowBreakList) then
    FAllowBreakList.Free;
  if Assigned(FStepDownStack) then
    FStepDownStack.Free;
  for Idx := 0 to FJunkList.Count - 1 do
    TObject(FJunkList[Idx]).Free;
	FJunkList.Free;
  if Assigned(ExecutionResults) then
    ExecutionResults.Free;
  inherited Destroy;
end;

function TProcModule.Errors : String;
begin
  Result := TSQLParser(FSQLParser).Lexer.yyerrorfile.Text;
end;

function TProcModule.Output : String;
begin
  Result := TSQLParser(FSQLParser).Lexer.yyoutput.Text;
end;


function TProcModule.Dump : String;
var
  Idx : Integer;
  SymValue : String;
  SymType : String;

begin
  //header...
  Result := 'Stored Procedure Debugger Internal Dump ' + FormatDateTime('dd/mm/yy hh:mm:ss', now) + #13#10;
  Result := Result + '=========================================================' + #13#10;
  Result := Result + #13#10;
  //dump symbol table...
  Result := Result + '**Symbol Table' + #13#10;
  Result := Result + '---------------------------------------------------------' + #13#10;
  Result := Result + 'Symbol Name                   Value' + #13#10;
	Result := Result + '---------------------------------------------------------' + #13#10;
  for Idx := 0 to FSymbolTable.Count - 1 do
  begin
    case FSymbolTable.Items[Idx].SymbolType of
      stInput : SymType := 'Input';
      stOutput : SymType := 'Output';
      stLocal : SymType := 'Local';
		end;
    case FSymbolTable.Items[Idx].SymType of
      ty_blr_blob :
        begin

        end;
      ty_blr_text, ty_blr_varying :
        begin
          if VarIsNull(FSymbolTable.Items[Idx].Value) then
            SymValue := 'NULL'
          else
            SymValue := String(FSymbolTable.Items[Idx].Value);
        end;
      ty_blr_float, ty_blr_double :
        begin
          if VarIsNull(FSymbolTable.Items[Idx].Value) then
            SymValue := 'NULL'
          else
            SymValue := FloatToStr(Double(FSymbolTable.Items[Idx].Value));
        end;
      ty_blr_short, ty_blr_long :
        begin
          if VarIsNull(FSymbolTable.Items[Idx].Value) then
            SymValue := 'NULL'
          else
            SymValue := IntToStr(Integer(FSymbolTable.Items[Idx].Value));
        end;
      ty_blr_date :
        begin
          if VarIsNull(FSymbolTable.Items[Idx].Value) then
            SymValue := 'NULL'
          else
						SymValue := DateTimeToStr(TDateTime(FSymbolTable.Items[Idx].Value));
        end;
    end;
    Result := Result + Format('%-20s %-20s %-10s', [FSymbolTable.Items[Idx].Name, SymValue, SymType]) + #13#10;
  end;
  Result := Result + #13#10;
  Result := Result + '**Execution Tree' + #13#10;
	Result := Result + '---------------------------------------------------------' + #13#10;
  Result := Result + 'Procedure-->'#13#10;

  Result := Result + FStatement.Dump(0);
end;

function TProcModule.ProcessBreakpoint(Line : Integer) : Boolean;
var
  Idx : Integer;
  Tmp : Boolean;
  B : TBreakPoint;
  Ex : TSQLParser;
  Value : Variant;

begin
  Tmp := False;
  for Idx := 0 to FBreakList.Count - 1 do
  begin
    if StrToInt(FBreakList[Idx]) = Line then
    begin
      B := TBreakPoint(FBreakList.Objects[Idx]);
      if B.PassCount <> 0 then
      begin
        if B.InternalPassCount = B.PassCount then
        begin
          if B.Condition <> '' then
          begin
            Ex := TSQLParser.Create(nil);
            Ex.ParserType := ptExpr;
            Value := Ex.EvalExpression(B.Condition, nil);
          end
          else
						B.InternalPassCount := B.InternalPassCount + 1;
        end
        else
        begin
          if B.Condition <> '' then
          begin
            //
					end
          else
            B.InternalPassCount := B.InternalPassCount + 1;
        end;
      end
      else
      begin
        if B.Condition <> '' then
        begin
          if B.Log then
          begin

          end;
        end
        else
        begin
          if B.Break then
            Tmp := True;
          if B.Log then
          begin

          end;
        end;
      end;
      Break;
    end;
  end;
  Result := Tmp or FBreak;
  FBreak := False;
end;

function TProcModule.GetNextStatement(S : TStatement; var BPSet : Boolean) : Boolean;
var
//  DoBreak : Boolean;
  Tmp : Integer;

begin
  BPSet := False;
//  DoBreak := BPSet;
	Result := True;

  if (S is TProcStatement) then
  begin
    FStepDownStack.Insert(0, S);
    if S.Statements.Count > 0 then
    begin
      FStatementPointer := S.Statements.Items[0];
      FCurrentLine := FStatementPointer.Line;
      if ProcessBreakPoint(FCurrentLine) then
        BPSet := True;
      Result := True;
      Exit;
    end
    else
    begin
      Result := False;
      Exit;
    end;
  end;

	while True do
	begin
		if FStepDownStack.Count > 0 then
		begin
			Tmp := TStatement(FStepDownStack.Items[0]).Statements.IndexOf(S);
			Tmp := Tmp + 1;
			if Tmp <= TStatement(FStepDownStack.Items[0]).Statements.Count - 1 then
			begin
				FStatementPointer := TStatement(FStepDownStack.Items[0]).Statements.Items[Tmp];
				FCurrentLine := FStatementPointer.Line;
				if ProcessBreakPoint(FCurrentLine) then
          BPSet := True;
        Result := True;
        Break;
      end
      else
      begin
        //pop off the stack....
				FStepDownStack.Delete(0);

        //get the top item
        if FStepDownStack.Count > 0 then
        begin
          S := TStatement(FStepDownStack.Items[0]);
          if (S is TProcStatement) then
          begin
            if (S is TProcStatement) then
             S := TProcStatement(S).LastStatement;

            if (S is TForSelectStatement) or (S is TWhileStatement) then
            begin
              FStatementPointer := S;
              if GetNextStatement(S, BPSet) then
              begin
                Result := True;
                Break;
              end  
              else
							begin
                Result := False;
                Break;
              end;
            end;
          end
          else
          begin
            Result := False;
            Break
          end;
				end
        else
        begin
          Result := False;
          Break
        end;
      end;
    end
		else
    begin
      Result := False;
      Break
    end;
  end;
end;

procedure TProcModule.BreakExecution;
begin
  FBreak := True;
end;

procedure TProcModule.Execute(Step : Boolean);
var
  Cond : Boolean;
  DoBreak : Boolean;
  Dummy : TProcStatement;

begin
  FState := intRunning;
  DoBreak := False;
  if FStatementPointer = nil then
  begin
    //clear the execution results
    if ExecutionResults.Active then
      ExecutionResults.Close;
    FStatementPointer := FStatement;
  end;

  if Step then
  begin
    try
      if FStatementPointer is TProcStatement then
      begin
        if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
        else
          FState := intCompleted;
				Exit;
      end;

      if FStatementPointer is TAssignmentStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
        except
          on E : Exception do
          begin
            if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
						raise;
          end;
        end;

        if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
				else
          FState := intCompleted;

        Exit;
      end;

      if FStatementPointer is TDMLStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
        except
          on E : Exception do
          begin
            if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
          end;
        end;

				if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
        else
          FState := intCompleted;

        Exit;
      end;

      if FStatementPointer is TSingletonSelectStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
				except
          on E : Exception do
          begin
            if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
					end;
        end;

        if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
        else
          FState := intCompleted;

        Exit;
      end;

      if FStatementPointer is TExecProcStatement then
      begin
        TCallStackItem(DebuggerVM.CallStack[0]).PushedStatement := FStatementPointer;
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          TExecProcStatement(FStatementPointer).Step := True;
          FStatementPointer.Execute;
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intCallStackInc;
					Exit;
        except
          on E : Exception do
          begin
            if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
          end;
        end;
      end;

      if FStatementPointer is TExceptionStatement then
      begin
				TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
        except
          on E : Exception do
          begin
						if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
          end;
        end;

        if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
        else
          FState := intCompleted;

        Exit;
      end;

      if FStatementPointer is TExceptionHandlerStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        Cond := TExceptionHandlerStatement(FStatementPointer).Condition.Execute;
        if Cond then
        begin
					FStatementPointer := TExceptionHandlerStatement(FStatementPointer).ConditionTrue;
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
            FState := intCompleted;

          Exit;
        end
        else
        begin
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
						FState := intCompleted;
          Exit;
        end;
      end;

			if FStatementPointer is TSuspendStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
        except
          on E : Exception do
          begin
            if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
          end;
        end;

        if GetNextStatement(FStatementPointer, DoBreak) then
          FState := intPaused
        else
          FState := intCompleted;

        Exit;
      end;

      if FStatementPointer is TIfStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        //execute
        Cond := TIfStatement(FStatementPointer).Condition.Execute;
        if Cond then
        begin
          if TIfStatement(FStatementPointer).ConditionTrue is TProcStatement then
          begin
            FStatementPointer := TIfStatement(FStatementPointer).ConditionTrue;
          end
          else
					begin
            Dummy := TProcStatement.Create;
            Dummy.Statements.Add(TIfStatement(FStatementPointer).ConditionTrue);
            FJunkList.Add(Dummy);
            FStatementPointer := Dummy;
					end;
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
            FState := intCompleted;

          Exit;
        end
        else
        begin
          if TIfStatement(FSTatementPointer).OptElse <> nil then
          begin
            if TIfStatement(FStatementPointer).OptElse is TProcStatement then
            begin
              FStatementPointer := TIfStatement(FStatementPointer).OptElse;
            end
            else
            begin
              Dummy := TProcStatement.Create;
              Dummy.Statements.Add(TIfStatement(FStatementPointer).OptElse);
              FJunkList.Add(Dummy);
							FStatementPointer := Dummy;
            end;
            if GetNextStatement(FStatementPointer, DoBreak) then
              FState := intPaused
            else
              FState := intCompleted;

            Exit;
          end
          else
          begin
            if GetNextStatement(FStatementPointer, DoBreak) then
              FState := intPaused
						else
              FState := intCompleted;
            Exit;
          end;
        end;
			end;

      if FStatementPointer is TForSelectStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        Cond := TForSelectStatement(FStatementPointer).Next;
        if Cond then
        begin
          FStatementPointer := TForSelectStatement(FStatementPointer).ConditionTrue;
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
            FState := intCompleted;

          Exit;
        end
        else
        begin
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
						FState := intCompleted;
          Exit;
        end;
      end;

      if FStatementPointer is TExitStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        try
          FStatementPointer.Execute;
        except
          on E : Exception do
          begin
						if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
              FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            raise;
          end;
        end;
        FState := intCompleted;
				Exit;
      end;

      if FStatementPointer is TWhileStatement then
      begin
        TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
        TWhileStatement(FStatementPointer).Condition.Reset;
        Cond := TWhileStatement(FStatementPointer).Condition.Execute;
        if Cond then
        begin
          FStatementPointer := TWhileStatement(FStatementPointer).ConditionTrue;
          if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
            FState := intCompleted;

          Exit;
        end
        else
        begin
					if GetNextStatement(FStatementPointer, DoBreak) then
            FState := intPaused
          else
            FState := intCompleted;
          Exit;
        end;
      end;
    except
      on E : Exception do
      begin
        //return false
        FErrorMessage := E.Message;
        FState := intException;
				Exit;
      end;
    end;
  end
  else
  begin
		DoBreak := False;
    while True do
    begin
      Application.ProcessMessages;
      try
        if FStatementPointer is TProcStatement then
        begin
          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
            if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
          end
          else
          begin
            FState := intCompleted;
						Break;
          end;
        end;

        if FStatementPointer is TAssignmentStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
          except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
								FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
          end;

          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
						if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
          end
          else
          begin
            FState := intCompleted;
            Break;
          end;
        end;

        if FStatementPointer is TDMLStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
					except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
          end;

          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
            if DoBreak then
            begin
              FState := intPaused;
							Break;
            end
            else
              Continue;
          end
          else
					begin
            FState := intCompleted;
            Break;
          end;
        end;

        if FStatementPointer is TSingletonSelectStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
          except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
          end;

          if GetNextStatement(FStatementPointer, DoBreak) then
					begin
            if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
          end
          else
          begin
            FState := intCompleted;
            Break;
					end;
        end;

        if FStatementPointer is TExecProcStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
					try
            TExecProcStatement(FStatementPointer).Step := False;
            FStatementPointer.Execute;
          except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
          end;

          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
            if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
					end
          else
          begin
            FState := intCompleted;
            Break;
          end;
        end;

        if FStatementPointer is TExceptionStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
					except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
					end;

          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
            if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
          end
          else
          begin
            FState := intCompleted;
            Break;
          end;
        end;

        if FStatementPointer is TExceptionHandlerStatement then
				begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          Cond := TExceptionHandlerStatement(FStatementPointer).Condition.Execute;
          if Cond then
          begin
            FStatementPointer := TExceptionHandlerStatement(FStatementPointer).ConditionTrue;
            if GetNextStatement(FStatementPointer, DoBreak) then
            begin
              if DoBreak then
              begin
                FState := intPaused;
                Break;
              end
							else
                Continue;
            end
            else
            begin
              FState := intCompleted;
							Break;
						end;
					end
					else
					begin
						if GetNextStatement(FStatementPointer, DoBreak) then
						begin
							if DoBreak then
							begin
								FState := intPaused;
								Break;
							end
							else
								Continue;
						end
						else
						begin
							FState := intCompleted;
							Break;
						end;
					end;
				end;

				if FStatementPointer is TSuspendStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
          except
            on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
						end;
          end;

          if GetNextStatement(FStatementPointer, DoBreak) then
          begin
            if DoBreak then
            begin
              FState := intPaused;
              Break;
            end
            else
              Continue;
          end
          else
          begin
            FState := intCompleted;
            Break;
          end;
        end;

        if FStatementPointer is TIfStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          //execute
          Cond := TIfStatement(FStatementPointer).Condition.Execute;
          if Cond then
					begin
						if TIfStatement(FStatementPointer).ConditionTrue is TProcStatement then
            begin
							FStatementPointer := TIfStatement(FStatementPointer).ConditionTrue;
            end
            else
            begin
              Dummy := TProcStatement.Create;
              Dummy.Statements.Add(TIfStatement(FStatementPointer).ConditionTrue);
              FJunkList.Add(Dummy);
              FStatementPointer := Dummy;
            end;
            if GetNextStatement(FStatementPointer, DoBreak) then
						begin
              if DoBreak then
              begin
                FState := intPaused;
                Break;
              end
              else
                Continue;
            end
            else
            begin
              FState := intCompleted;
              Break;
            end;
          end
          else
          begin
            if TIfStatement(FSTatementPointer).OptElse <> nil then
            begin
              if TIfStatement(FStatementPointer).ConditionTrue is TProcStatement then
              begin
                FStatementPointer := TIfStatement(FStatementPointer).OptElse;
              end
              else
              begin
                Dummy := TProcStatement.Create;
								Dummy.Statements.Add(TIfStatement(FStatementPointer).OptElse);
								FJunkList.Add(Dummy);
                FStatementPointer := Dummy;
							end;
              if GetNextStatement(FStatementPointer, DoBreak) then
              begin
                if DoBreak then
                begin
                  FState := intPaused;
                  Break;
                end
                else
                  Continue;
							end
              else
              begin
                FState := intCompleted;
                Break;
              end;
            end
            else
            begin
              if GetNextStatement(FStatementPointer, DoBreak) then
              begin
                if DoBreak then
                begin
                  FState := intPaused;
                  Break;
                end
                else
                  Continue;
              end
              else
              begin
                FState := intCompleted;
                Break;
              end;
            end;
          end;
				end;

				if FStatementPointer is TForSelectStatement then
				begin
					TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
					Cond := TForSelectStatement(FStatementPointer).Next;
					if Cond then
					begin
						FStatementPointer := TForSelectStatement(FStatementPointer).ConditionTrue;
						if GetNextStatement(FStatementPointer, DoBreak) then
						begin
							if DoBreak then
							begin
                FState := intPaused;
                Break;
              end
              else
                Continue;
            end
            else
            begin
              FState := intCompleted;
              Break;
            end;
          end
          else
          begin
            if GetNextStatement(FStatementPointer, DoBreak) then
            begin
              if DoBreak then
              begin
                FState := intPaused;
                Break;
              end
              else
                Continue;
            end
            else
            begin
							FState := intCompleted;
              Break;
						end;
          end;
        end;

        if FStatementPointer is TExitStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          try
            FStatementPointer.Execute;
          except
						on E : Exception do
            begin
              if TStatement(FStepDownStack.Items[0]).ExceptionBlock <> nil then
                FStatementPointer := TStatement(FStepDownStack.Items[0]).ExceptionBlock;
            end;
          end;
          FState := intCompleted;
          Break;
        end;

        if FStatementPointer is TWhileStatement then
        begin
          TProcStatement(FStepDownStack.Items[0]).LastStatement := FStatementPointer;
          TWhileStatement(FStatementPointer).Condition.Reset;
          Cond := TWhileStatement(FStatementPointer).Condition.Execute;
          if Cond then
          begin
            FStatementPointer := TWhileStatement(FStatementPointer).ConditionTrue;
            if GetNextStatement(FStatementPointer, DoBreak) then
            begin
              if DoBreak then
              begin
                FState := intPaused;
                Break;
              end
              else
                Continue;
						end
            else
						begin
              FState := intCompleted;
              Break;
            end;
          end
          else
          begin
            if GetNextStatement(FStatementPointer, DoBreak) then
            begin
              if DoBreak then
							begin
                FState := intPaused;
                Break;
              end
              else
                Continue;
            end
            else
            begin
              FState := intCompleted;
              Break;
            end;
          end;
        end;
      except
        on E : Exception do
        begin
          //clear the execution stack...
          FStepDownStack.Clear;
          //return false
          FState := intException;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TProcModule.Clear;
var
  Idx : Integer;
begin
  //free all objects
  FSQLParser.Free;
  FSQLParser := nil;
  FSymbolTable.Free;
  FSymbolTable := nil;
  FAllowBreakList.Free;
  FAllowBreakList := nil;
	FBreakList.Free;
  FBreakList := nil;
  FStepDownStack.Free;
  FStepDownStack := nil;
  ExecutionResults.Free;
  ExecutionResults := nil;
  FStatement := nil;
  for Idx := 0 to FJunkList.Count - 1 do
    TObject(FJunkList[Idx]).Free;
  FJunkList.Free;
  FSTatementPointer := nil;

  FSymbolTable := TSymbolTable.Create;
  FAllowBreakList := TStringList.Create;
  FBreakList := TStringList.Create;
  FStepDownStack := TList.Create;
  ExecutionResults := TrmMemoryDataSet.Create(nil);
  FSQLParser := TSQLParser.Create(nil);
  TSQLParser(FSQLParser).Module := Self;
  FJunkList := TList.Create;
end;

procedure TProcModule.Reset;
var
  Idx : Integer;

begin
	//Clear the Execution Stack
	FStepDownStack.Clear;
	//Reset the Execution Tree Objects
  FStatement.Reset;
  //Reset the Symbol Table
  with FSymbolTable do
  begin
    for Idx := 0 to Count - 1 do
    begin
      Items[Idx].Value := Null;
    end;
  end;
	for Idx := 0 to FJunkList.Count - 1 do
    TObject(FJunkList[Idx]).Free;
  FJunkList.Clear;  
  //clear out the breakpoints...
  FBreakList.Clear;
  FStatementPointer := nil;
end;

function TProcModule.Compile(ProcName : String; ProcSource : String) : Boolean;
var
  PResult : Integer;

begin
  //do the parse and compile the proc...
  TSQLParser(FSQLParser).lexer.yyinput.Text := ProcSource;
  PResult := FSQLParser.yyparse;
  if PResult = 0 then
  begin
    try
      Reset;
			FStatement.Compile;
			FProcName := ProcName;
			Result := True;
		except
			on E : Exception do
			begin
				MessageDlg(E.Message, mtError, [mbOK], 0);
				Result := False;
			end;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

constructor TSymbolTable.Create;
begin
	inherited Create(TSymbol);
end;

function TSymbolTable.GetItem(Index: Integer): TSymbol;
begin
  Result := TSymbol(inherited GetItem(Index));
end;

procedure TSymbolTable.SetItem(Index: Integer; Value: TSymbol);
begin
  inherited SetItem(Index, Value);
end;

function TSymbolTable.Add: TSymbol;
begin
  Result := TSymbol(inherited Add);
end;

function TSymbolTable.UpdateSym(SymbolName : Variant; Value : Variant) : Boolean;
var
	Idx : Integer;

begin
  Result := False;
  for Idx := 0 to Count - 1 do
  begin
    if (AnsiUpperCase(SymbolName) = AnsiUpperCase(Items[Idx].Name)) then
		begin
			Items[Idx].Value := Value;
      Result := True;
      Break;
    end;
  end;
end;

function TSymbolTable.IsSymbol(SymbolName : Variant) : Boolean;
var
  Idx : Integer;

begin
  Result := False;
  for Idx := 0 to Count - 1 do
  begin
    if (AnsiUpperCase(SymbolName) = AnsiUpperCase(Items[Idx].Name)) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TSymbolTable.GetSymValue(SymbolName : Variant) : Variant;
var
  Idx : Integer;

begin
  Result := NULL;
  for Idx := 0 to Count - 1 do
  begin
		if (AnsiUpperCase(SymbolName) = AnsiUpperCase(Items[Idx].Name)) then
    begin
      Result := Items[Idx].Value;
      Break;
    end;
  end;
end;

function TSymbolTable.GetSymType(SymbolName : Variant) : Integer;
var
  Idx : Integer;

begin
  Result := 0;
  for Idx := 0 to Count - 1 do
  begin
    if (AnsiUpperCase(SymbolName) = AnsiUpperCase(Items[Idx].Name)) then
    begin
      Result := Items[Idx].SymType;
      Break;
    end;
  end;
end;

{ TIBDebuggerVM }

procedure TIBDebuggerVM.AddBreakPoint(DatabaseName : String; ObjectName : String; Line: Integer);
var
  B : TBreakPoint;
  F : IMarathonStoredProcEditor;
  P : TProcModule;
  Idx : Integer;
  FAdd : TfrmDebugAddBreakPoint;

begin
  FAdd := TfrmDebugAddBreakPoint.Create(nil);
  try
    for Idx := 0 to MarathonIDEInstance.CurrentProject.Cache.ConnectionCount - 1 do
    begin
			FAdd.cmbConnection.Items.Add(MarathonIDEInstance.CurrentProject.Cache.Connections[Idx].Caption);
    end;
    FAdd.cmbConnection.ItemIndex := FAdd.cmbConnection.Items.IndexOf(DatabaseName);
    FAdd.edProcName.Text := ObjectName;
    FAdd.edLine.Text := IntToStr(Line);
    FAdd.edPassCount.Text := '0';

		if FAdd.ShowModal = mrOK then
    begin
      // add the breakpoint to the master breakpoint list...
      B := TBreakPoint.Create;
      B.ConnectionName := FAdd.cmbConnection.Text;
      B.ObjectName := FAdd.edProcName.Text;
      B.Line := StrToInt(FAdd.edLine.Text);
      B.Condition := FAdd.edCondition.Text;
      B.PassCount := StrToInt(FAdd.edPassCount.Text);
      B.Break := FAdd.chkBreak.Checked;
      B.Log := FAdd.chkLog.Checked;
      B.LogMessage := FAdd.edLogMessage.Text;
      FBreakPoints.Add(B);

      // update the editor if it is visible...
      F := MarathonIDEInstance.DebugOpenProcedure(ObjectName, DatabaseName, False, False);
      if Assigned(F) then
      begin
        try
          F.DebugSetBreakPointLine(True, Line);
        except
					on E : Exception do
					begin
            //nothing - ignore the breakpoint...
          end;
        end;
      end;

      //if we are executing then add into the proc module list...
      if FExecuting then
      begin
        if Self.DatabaseName = DatabaseName then
				begin
          P := ModuleByName[ObjectName];
          if Assigned(P) then
          begin
            P.BreakList.AddObject(IntToStr(B.Line), B);
          end;
        end;
			end;
    end;
  finally
    FAdd.Free;
  end;
end;

procedure TIBDebuggerVM.ToggleBreakPoint(DatabaseName, ObjectName: String; Line: Integer);
var
  B : TBreakPoint;
  F : IMarathonStoredProcEditor;
  Found : Boolean;
  Idx : Integer;
  P : TProcModule;

begin
  Found := False;
  for Idx := 0 to FBreakPoints.Count - 1 do
  begin
    B := TBreakPoint(FBreakPoints[Idx]);
    if (B.ConnectionName = DatabaseName) and
       (B.ObjectName = ObjectName) and
       (B.Line = Line) then
    begin
      Found := True;
      F := MarathonIDEInstance.DebugOpenProcedure(ObjectName, DatabaseName, False, False);
      if Assigned(F) then
      begin
        F.DebugSetBreakPointLine(False, B.Line);
      end;
      TObject(FBreakPoints[Idx]).Free;
      FBreakPoints.Delete(Idx);
			//if we are executing then remove from the proc module list...
      if FExecuting then
      begin
        if Self.DatabaseName = DatabaseName then
        begin
          P := ModuleByName[ObjectName];
          if Assigned(P) then
					begin
            P.BreakList.Delete(P.BreakList.IndexOf(IntToStr(Line)));
          end;
        end;
      end;
      Break;
    end;
  end;

  if not Found then
  begin
    // add the breakpoint to the master breakpoint list...
    B := TBreakPoint.Create;
    B.ConnectionName := FDatabaseName;
    B.ConnectionName := DatabaseName;
    B.ObjectName := ObjectName;
    B.Line := Line;
    B.PassCount := 0;
    B.Break := True;
    B.Log := False;
    B.LogMessage := '';
    FBreakPoints.Add(B);

    // update the editor if it is visible...
    F := MarathonIDEInstance.DebugOpenProcedure(ObjectName, DatabaseName, False, False);
    if Assigned(F) then
    begin
      F.DebugSetBreakPointLine(True, Line);
    end;

    //if we are executing then add into the proc module list...
    if FExecuting then
		begin
      if Self.DatabaseName = DatabaseName then
      begin
        P := ModuleByName[ObjectName];
        if Assigned(P) then
        begin
          P.BreakList.AddObject(IntToStr(B.Line), B);
				end;
      end;
    end;
  end;
end;

procedure TIBDebuggerVM.BreakExecution;
begin

end;

procedure TIBDebuggerVM.Clear;
var
  Idx : Integer;

begin
  for Idx := 0 to FModules.Count - 1 do
  begin
    TProcModule(FModules[Idx]).Free;
  end;
  FModules.Clear;
end;

function TIBDebuggerVM.Compile(ProcName : String; ProcSource: String) : Boolean;
var
  M : TProcModule;

begin
  Clear;
  M := TProcModule.Create;
  M.DebuggerVM := Self;
  M.IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].IsIB6;
	M.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].SQLDialect;
  FModules.Add(M);
  Result := M.Compile(ProcName, ProcSource);
end;

function TIBDebuggerVM.CompileSubProc(ProcName: String): Boolean;
var
	Q : TIBOQuery;
  tmp : String;
  tmp1: String;
  P : TStringList;
  CharSet : String;
  M : TProcModule;
  FIsInterbase6 : Boolean;
  FSQLDialect : Integer;


begin
  FIsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].IsIB6;
  FSQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].SQLDialect;
  Q := TIBOQuery.Create(nil);
  try
    Q.IB_Connection := FDatabase;
    Q.Close;
    Q.SQL.Clear;
    if ShouldBeQuoted(ProcName) then
      tmp := 'create procedure ' + MakeQuotedIdent(ProcName, FIsInterbase6, FSQLDialect) + ' '
    else
      tmp := 'create procedure ' + ProcName + ' ';
    if FIsinterbase6 then
    begin
      if ShouldBeQuoted(ProcName) then
        Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                  'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(ProcName, '''') + ' order by rdb$parameter_number asc;')
      else
        Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                  'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ' order by rdb$parameter_number asc;');
    end
    else
		begin
      Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 0 and a.rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ' order by rdb$parameter_number asc;');
    end;
    Q.Open;
    If Not (Q.EOF and Q.BOF) Then
    begin
      tmp := tmp + '(';
      if FIsInterbase6 then
      begin
        tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_length').AsInteger,
                                                                                           Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                           Q.FieldByName('rdb$field_sub_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_precision').AsInteger,
                                                                                           True,
                                                                                           Database.SQLDialect);
      end
      else
      begin
        tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_length').AsInteger,
                                                                                           Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                           -1,
                                                                                           -1,
                                                                                           False,
                                                                                           Database.SQLDialect);
      end;
      CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(Q.FieldByName('rdb$character_set_id').AsInteger);
      if CharSet <> '' then
      begin
        Tmp := Tmp + ' character set ' + CharSet;
      end;
      Q.Next;
      while not Q.EOF do
      begin
        tmp := tmp + ', ';
        if FIsInterbase6 then
        begin
					tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_length').AsInteger,
                                                                                             Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                             Q.FieldByName('rdb$field_sub_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_precision').AsInteger,
                                                                                             True,
                                                                                             Database.SQLDialect);
        end
        else
        begin
          tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_length').AsInteger,
                                                                                             Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                             -1,
                                                                                             -1,
                                                                                             False,
                                                                                             Database.SQLDialect);
        end;
        CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(Q.FieldByName('rdb$character_set_id').AsInteger);
        if CharSet <> '' then
        begin
          Tmp := Tmp + ' character set ' + CharSet;
        end;
        Q.Next;
      end;
      tmp := tmp + ')';
    end;
    Q.Close;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;
    Q.SQL.Clear;
    if FIsInterbase6 then
    begin
      if ShouldBeQuoted(ProcName) then
        Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                  'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(ProcName, '''') + ' order by rdb$parameter_number asc;')
      else
        Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$field_sub_type, b.rdb$field_precision, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                  'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ' order by rdb$parameter_number asc;');
		end
    else
    begin
      Q.SQL.Add('select a.rdb$parameter_name, b.rdb$field_type, b.rdb$field_length, b.rdb$field_scale, b.rdb$character_set_id from rdb$procedure_parameters a, rdb$fields b where ' +
                            'a.rdb$field_source = b.rdb$field_name and a.rdb$parameter_type = 1 and a.rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ' order by rdb$parameter_number asc;');
    end;
    Q.Open;
    If Not (Q.EOF and Q.BOF) Then
    begin
      tmp := tmp + #13#10;
      tmp := tmp + 'returns (';
      if FIsInterbase6 then
      begin
        tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_length').AsInteger,
                                                                                           Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                           Q.FieldByName('rdb$field_sub_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_precision').AsInteger,
                                                                                           True,
                                                                                           Database.SQLDialect);
      end
      else
      begin
        tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                           Q.FieldByName('rdb$field_length').AsInteger,
                                                                                           Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                           -1,
                                                                                           -1,
                                                                                           False,
                                                                                           Database.SQLDialect);
      end;

      CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(Q.FieldByName('rdb$character_set_id').AsInteger);
      if CharSet <> '' then
      begin
        Tmp := Tmp + ' character set ' + CharSet;
      end;
      Q.Next;
      while not Q.EOF do
			begin
        tmp := tmp + ', ';
        if FIsInterbase6 then
        begin
          tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_length').AsInteger,
                                                                                             Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                             Q.FieldByName('rdb$field_sub_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_precision').AsInteger,
                                                                                             True,
                                                                                             Database.SQLDialect);
        end
        else
        begin
          tmp := tmp + Q.FieldByName('rdb$parameter_name').AsString + ' ' + ConvertFieldType(Q.FieldByName('rdb$field_type').AsInteger,
                                                                                             Q.FieldByName('rdb$field_length').AsInteger,
                                                                                             Q.FieldByName('rdb$field_scale').AsInteger,
                                                                                             -1,
                                                                                             -1,
                                                                                             False,
                                                                                             Database.SQLDialect);
        end;
        CharSet := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName].GetDBCharSetName(Q.FieldByName('rdb$character_set_id').AsInteger);
        if CharSet <> '' then
        begin
          Tmp := Tmp + ' character set ' + CharSet;
        end;
        Q.Next;
      end;
      tmp := tmp + ')';
    end;

    Q.Close;
    if Q.IB_Transaction.Started then
      Q.IB_Transaction.Commit;

    Tmp := WrapText(Tmp, #10#13, [' ', #9], 80);

    P := TStringList.Create;
		try
      Q.SQL.Clear;
      if FIsInterbase6 then
      begin
        if ShouldBeQuoted(ProcName) then
          Q.SQL.Add('select rdb$procedure_source from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ProcName, '''') + ';')
        else
          Q.SQL.Add('select rdb$procedure_source from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ';');
      end
      else
      begin
        Q.SQL.Add('select rdb$procedure_source from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ProcName), '''') + ';');
      end;
      Q.Open;
      If Not (Q.EOF and Q.BOF) Then
      begin
        tmp := tmp + #13#10;
        tmp := tmp + 'as' + #13#10;
        Tmp1 := Trim(AdjustLineBreaks(Q.FieldByName('rdb$procedure_source').AsString));
        P.Text := Tmp1;
      end;
      Q.Close;
      if Q.IB_Transaction.Started then
        Q.IB_Transaction.Commit;
      Q.SQL.Clear;
      Tmp := tmp + P.Text;

      M := TProcModule.Create;
      M.DebuggerVM := Self;
      M.IsInterbase6 := FIsInterbase6;
      M.SQLDialect := FSQLDialect;
      FModules.Add(M);
      Result := M.Compile(ProcName, Tmp);
    finally
      P.Free;
    end;
  finally
    Q.Free;
  end;
end;

constructor TIBDebuggerVM.Create;
begin
  FModules := TList.Create;
  FCallStack := TList.Create;
  FBreakPoints := TList.Create;
  FWatchList := TList.Create;
end;

destructor TIBDebuggerVM.Destroy;
var
  Idx : Integer;

begin
  Clear;
  for Idx := 0 to FBreakPoints.Count - 1 do
  begin
    TObject(FBreakPoints[Idx]).Free;
  end;
  FBreakPoints.Clear;
  for Idx := 0 to FWatchList.Count - 1 do
  begin
    TObject(FWatchList[Idx]).Free;
  end;
  FWatchList.Clear;
  FCallStack.Free;
  FModules.Free;
  FBreakPoints.Free;
  inherited;
end;

function TIBDebuggerVM.Dump: String;
var
  Idx : Integer;

begin
  Result := '';
  for Idx := 0 to FModules.Count - 1 do
	begin
    Result := Result + TProcModule(FModules[Idx]).Dump;
  end;
end;

function TIBDebuggerVM.Errors: String;
var
  Idx : Integer;

begin
  Result := '========================================================================';
  for Idx := 0 to FModules.Count - 1 do
  begin
    Result := Result + #13#10 + TProcModule(FModules[Idx]).Errors + #13#10 +
      '========================================================================';
  end;
end;

procedure TIBDebuggerVM.Execute(Step: Boolean);
var
  CS : TCallStackItem;
  Module : TProcModule;
  F : IMarathonStoredProcEditor;
  Idx : Integer;
  Idy : Integer;
  B : TBreakPoint;
  P : TProcModule;
  Statement : TStatement;
  S : TSymbolTable;
  S1 : TSymbolTable;
  L : TList;
  Sym : TSymbol;


begin
  if not FExecuting then
  begin
    //update the breakpoints...
    for Idx := 0 to FBreakPoints.Count - 1 do
		begin
      B := TBreakPoint(FBreakPoints[Idx]);

      for Idy := 0 to FModules.Count - 1 do
      begin
        P := TProcModule(FModules[Idy]);

        if (B.ConnectionName = Self.DatabaseName) and
           (B.ObjectName = P.ProcName) then
        begin
          P.BreakList.AddObject(IntToStr(B.Line), B);
        end;
      end;
    end;

    //put the symbol table from module[0] on the call stack
    CS := TCallStackItem.Create;
    CS.FModuleName := TProcModule(FModules[0]).ProcName;
    CS.FSymbolTable.Assign(TProcModule(FModules[0]).FSymbolTable);
    FCallStack.Insert(0, CS);
    FExecuting := True;
  end;

  CS := TCallStackItem(FCallStack[0]);
  Module := ModuleByName[CS.ModuleName];

  Module.Execute(Step);
  case Module.State of
    intPaused :
      begin
        //update the execution line in the editor...
        F := MarathonIDEInstance.DebugOpenProcedure(Module.ProcName, FDatabaseName, True, True);
        if Assigned(F) then
        begin
          F.DebugRefreshDots;
          F.DebugSetExecutionPoint(Module.CurrentLine);
        end;
        UpdateDebugWindows;
      end;
		intCompleted :
      begin
        if FCallStack.Count > 1 then
        begin
          //get the values back into the calling proc...
          S := GetTopSymbolTable;
          L := TList.Create;
          try
            for Idx := 0 to S.Count - 1 do
            begin
              if TSymbol(S.Items[Idx]).SymbolType = stOutput then
                L.Add(S.Items[Idx]);
            end;
            if Assigned(TCallStackItem(FCallStack[1]).PushedStatement) and (TCallStackItem(FCallStack[1]).PushedStatement is TExecProcStatement) then
            begin
              S1 := TCallStackItem(FCallStack[1]).SymbolTable;
              for Idx := 0 to TExecProcStatement(TCallStackItem(FCallStack[1]).PushedStatement).ProcOutputs.Statements.Count - 1 do
              begin
                Sym := TSymbol(L[Idx]);
                Statement := TStatement(TExecProcStatement(TCallStackItem(FCallStack[1]).PushedStatement).ProcOutputs.Statements[Idx]);
                S1.UpdateSym(Statement.Value, S.GetSymValue(Sym.Name));
              end;
            end;
          finally
            L.Free;
          end;

          //update the window of the called proc and remove the item from the stack
          F := MarathonIDEInstance.DebugOpenProcedure(TCallStackItem(FCallStack[0]).ModuleName, FDatabaseName, True, False);
          if Assigned(F) then
          begin
            F.DebugSetExecutionPoint(-1);
          end;
          TCallStackItem(FCallStack[0]).Free;
          FCallStack.Delete(0);

          //set the current line in the calling proc...
          F := MarathonIDEInstance.DebugOpenProcedure(TCallStackItem(FCallStack[0]).ModuleName, FDatabaseName, True, True);
          if Assigned(F) then
					begin
            F.DebugSetExecutionPoint(Modules[0].CurrentLine);
          end;
          UpdateDebugWindows;
        end
        else
        begin
          Reset;
          FExecuting := False;
          F := MarathonIDEInstance.DebugOpenProcedure(Module.ProcName, FDatabaseName, True, True);
          if Assigned(F) then
          begin
            F.DebugSetExecutionPoint(-1);
          end;
          UpdateDebugWindows;
        end;
      end;
    intException :
      begin
        if TStatement(Module.FStepDownStack.Items[0]).ExceptionBlock = nil then
        begin
          Reset;
          FExecuting := False;
        end;
        F := MarathonIDEInstance.DebugOpenProcedure(Module.ProcName, FDatabaseName, True, True);
        if Assigned(F) then
        begin
          F.DebugSetExecutionPoint(-1);
          F.DebugSetExceptionLine(Module.CurrentLine, Module.ErrorMessage);
        end;
        UpdateDebugWindows;
      end;
    intCallStackInc :
      begin
        //remove the pointer in the calling proc
        if FCallStack.Count > 1 then
        begin
          F := MarathonIDEInstance.DebugOpenProcedure(TCallStackItem(FCallStack[1]).ModuleName, FDatabaseName, True, False);
          if Assigned(F) then
					begin
            F.DebugSetExecutionPoint(-2);
          end;
          UpdateDebugWindows;
        end;
      end;
  end;
end;

function TIBDebuggerVM.GetBreakPointByIndex(Index: Integer): TBreakPoint;
begin
  Result := TBreakPoint(FBreakPoints[Index]);
end;

function TIBDebuggerVM.GetBreakPointCount: Integer;
begin
  Result := FBreakPoints.Count;
end;

function TIBDebuggerVM.GetModuleByIndex(Index: Integer): TProcModule;
begin
  Result := TProcModule(FModules[Index]);
end;

function TIBDebuggerVM.GetModuleByName(Name: String): TProcModule;
var
  Idx : Integer;

begin
  Result := nil;
  for Idx := 0 to FModules.COunt - 1 do
  begin
    if AnsiUpperCase(TProcModule(FModules[Idx]).ProcName) = AnsiUpperCase(Name) then
    begin
      Result := TProcModule(FModules[Idx]);
      Break;
    end;
  end;
end;

function TIBDebuggerVM.GetModuleCount: Integer;
begin
  Result := FModules.Count;
end;

function TIBDebuggerVM.GetTopSymbolTable: TSymbolTable;
begin
  Result := TCallStackItem(FCallStack[0]).SymbolTable;
end;

function TIBDebuggerVM.Output: String;
var
  Idx : Integer;

begin
  Result := '========================================================================';
  for Idx := 0 to FModules.Count - 1 do
  begin
    Result := Result + #13#10 + TProcModule(FModules[Idx]).Output + #13#10 +
      '========================================================================';
  end;
end;

procedure TIBDebuggerVM.Reset;
var
  Idx : Integer;

begin
  for Idx := 0 to FCallStack.Count - 1 do
  begin
    TObject(FCallStack[Idx]).Free;
  end;
  FCallStack.Clear;
  for Idx := 0 to FModules.Count - 1 do
  begin
    TProcModule(FModules[Idx]).Reset;
  end;
end;

function TIBDebuggerVM.GetState: TInterpreterState;
var
  CS : TCallStackItem;
  Module : TProcModule;

begin
  CS := TCallStackItem(FCallStack[0]);
  Module := ModuleByName[CS.ModuleName];
  Result := Module.State;
end;

procedure TIBDebuggerVM.EvalModify;
var
  EM : TfrmGetSetVariable;

begin
  EM := TfrmGetSetVariable.Create(nil);
  try
    EM.DebuggerVM := Self;
    EM.ShowModal;
  finally
    EM.Free;
  end;
end;

function TIBDebuggerVM.EvalExpression(Expression: String): Variant;
var
  Ex : TSQLParser;
begin
  if Executing then
  begin
    Ex := TSQLParser.Create(nil);
    try
      Ex.ParserType := ptExpr;
      Result := Ex.EvalExpression(Expression, GetTopSymbolTable);
    finally
      Ex.Free;
    end;
	end
  else
    Result := 'Process not accessable';
end;

procedure TIBDebuggerVM.UpdateDebugWindows;
begin
  UpdateCallStack;
  UpdateLocals;
  UpdateWatches;
end;

procedure TIBDebuggerVM.UpdateCallStack;
var
  Idx : Integer;
  F : TfrmDebugCallStack;
begin
  for Idx := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[Idx] is TfrmDebugCallStack then
    begin
      F := TfrmDebugCallStack(Screen.Forms[Idx]);
      F.UpdateInfo;
      Break;
    end;
  end;
end;

procedure TIBDebuggerVM.UpdateLocals;
var
  Idx : Integer;
  F : TfrmDebugLocals;
begin
  for Idx := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[Idx] is TfrmDebugLocals then
    begin
      F := TfrmDebugLocals(Screen.Forms[Idx]);
      F.UpdateInfo;
			Break;
    end;
  end;
end;

procedure TIBDebuggerVM.AddWatch(Expression: String; Enabled : Boolean);
var
  W : TWatch;

begin
	W := TWatch.Create;
  FWatchList.Add(W);
  W.FDebuggerVM := Self;
  W.Expression := Expression;
  W.Enabled := Enabled;
end;

procedure TIBDebuggerVM.AddWatchAtCursor(SymbolName: String);
var
  Idx : Integer;
  F : TfrmWatches;
  Found : Boolean;
begin
  AddWatch(SymbolName, True);
  Found := False;
  for Idx := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[Idx] is TfrmWatches then
    begin
      F := TfrmWatches(Screen.Forms[Idx]);
      F.BringToFront;
      F.UpdateInfo;
      Found := True;
      Break;
    end;
  end;
  if Not Found then
  begin
    F := TfrmWatches.Create(nil);
		F.Show;
  end;
end;

procedure TIBDebuggerVM.UpdateWatches;
var
  Idx : Integer;
  F : TfrmWatches;
begin
  for Idx := 0 to Screen.FormCount - 1 do
	begin
    if Screen.Forms[Idx] is TfrmWatches then
    begin
      F := TfrmWatches(Screen.Forms[Idx]);
      F.UpdateInfo;
      Break;
    end;
  end;
end;

procedure TIBDebuggerVM.AddWatchDialog;
var
  FA : TfrmAddWatch;
  Idx : Integer;
  F : TfrmWatches;
  Found : Boolean;

begin
  FA := TfrmAddWatch.Create(nil);
  try
    if FA.ShowModal = mrOK then
    begin
      AddWatch(FA.cmbVariable.Text, FA.chkEnabled.Checked);
      Found := False;
      for Idx := 0 to Screen.FormCount - 1 do
      begin
        if Screen.Forms[Idx] is TfrmWatches then
        begin
          F := TfrmWatches(Screen.Forms[Idx]);
					F.BringToFront;
          F.UpdateInfo;
          Found := True;
          Break;
        end;
      end;
      if Not Found then
      begin
        F := TfrmWatches.Create(nil);
        F.Show;
			end;
    end;
  finally
    FA.Free;
  end;
end;

procedure TIBDebuggerVM.ShowExecutionPoint;
var
  CS : TCallStackItem;
  Module : TProcModule;
  F : IMarathonStoredProcEditor;
  
begin
  CS := TCallStackItem(FCallStack[0]);
  Module := ModuleByName[CS.ModuleName];
  F := MarathonIDEInstance.DebugOpenProcedure(Module.ProcName, FDatabaseName, True, True);
  if Assigned(F) then
  begin
    F.DebugRefreshDots;
    F.DebugSetExecutionPoint(Module.CurrentLine);
  end;
end;

{ TSymbol }

procedure TSymbol.Assign(Source: TPersistent);
begin
  if not (SOurce is TSymbol) then
		raise Exception.Create('Cannot assign.');

  SymType := TSymbol(Source).SymType;
  SymSize := TSymbol(Source).SymSize;
  SymCharSet := TSymbol(Source).SymCharSet;
  SymScale := TSymbol(Source).SymScale;
  SymPrecision := TSymbol(Source).SymPrecision;
  Name := TSymbol(Source).Name;
  Value := TSymbol(Source).Value;
  SymbolType := TSymbol(Source).SymbolType;
end;

{ TCallStackItem }

constructor TCallStackItem.Create;
begin
  FSymbolTable := TSymbolTable.Create;
end;

destructor TCallStackItem.Destroy;
begin
  FSymbolTable.Free;
  inherited;
end;

function TProcModule.GetSymbolTable: TSymbolTable;
begin
  Result := FSymbolTable;
end;

{ TWatch }

function TWatch.GetValue: String;
var
  V : Variant;

begin
  if FEnabled then
  begin
		V := FDebuggerVM.EvalExpression(FExpression);
    if VarIsNull(V) then
      Result := 'NULL'
    else
      Result := V;
  end
  else
    Result := '[disabled]';    
end;

end.

{
$Log: IBDebuggerVM.pas,v $
Revision 1.6  2005/06/29 22:29:51  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.5  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.3  2002/04/29 14:52:40  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
