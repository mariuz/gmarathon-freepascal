%{
unit SQLYacc;

interface

uses
  SysUtils, Classes, LexLib, YaccLib, Dialogs, ParseCollection,
  Forms, MemData, IBDebuggerVM, PlanUnit;


%}


%start entry_point

%type <TStatement>
%type <TStatement> full_proc_block
%type <TStatement> simple_column_def_name
%type <TStatement> column_def_name
%type <TStatement> proc_statement
%type <TStatement> assignment
%type <TStatement> column_name
%type <TStatement> rhs
%type <TStatement> value
%type <TStatement> proc_statements
%type <TStatement> simple_column_name
%type <TStatement> proc_block
%type <TStatement> proc_statements
%type <TStatement> expression
%type <TStatement> non_array_type
%type <TStatement> search_condition
%type <TStatement> opt_else
%type <TStatement> if_then_else
%type <TStatement> while
%type <TStatement> singleton_select
%type <TStatement> for_select
%type <TStatement> exec_procedure
%type <TStatement> insert
%type <TStatement> update
%type <TStatement> delete
%type <TStatement> function
%type <TStatement> column_select
%type <TStatement> udf
%type <TStatement> variable
%type <TStatement> parameter
%type <TStatement> u_constant
%type <TStatement> array_element
%type <TStatement> null_predicate
%type <TStatement> comparison_predicate
%type <TStatement> predicate
%type <TStatement> null_value
%type <TStatement> htable_name
%type <TStatement> update_searched
%type <TStatement> delete_searched
%type <TStatement> float_type
%type <TStatement> numeric_type
%type <TStatement> character_type
%type <TStatement> pos_short_integer
%type <TStatement> national_character_type
%type <TStatement> blob_type
%type <TStatement> non_charset_simple_type
%type <TStatement> variable_list
%type <TStatement> select
%type <TStatement> value_list
%type <TStatement> charset_clause
%type <TStatement> character_set_name
%type <TStatement> precision_opt
%type <TStatement> nonneg_short_integer
%type <TStatement> prec_scale
%type <TStatement> union_expr
%type <TStatement> expression_eval
%type <TStatement> data_type_descriptor
%type <TStatement> sql_string
%type <TStatement> excp_statement
%type <TStatement> excp_statements
%type <TStatement> errors
%type <TStatement> index_list
%type <TStatement> access_type
%type <TStatement> table_or_alias_list
%type <TStatement> plan_item
%type <TStatement> plan_item_list
%type <TStatement> plan_expression
%type <TStatement> plan_type
%type <TStatement> plan_clause
%type <TStatement> plan_clause
%type <TStatement> proc_outputs
%type <TStatement> proc_inputs
%type <TStatement> var_const_list
%type <TStatement> variable
%type <TStatement> constant
%type <TStatement> po_variable_list

/* Keywords are stropped with underscores to prevent conflicts with Delphi
   Pascal keywords. */

%token <TStatement> _ACTION_
%token <TStatement> _ACTIVE_
%token <TStatement> _ADD_
%token <TStatement> _ADMIN_
%token <TStatement> _AFTER_
%token <TStatement> _ALL_
%token <TStatement> _ALTER_
%token <TStatement> _AND_
%token <TStatement> _ANY_
%token <TStatement> _AS_
%token <TStatement> _ASC_
%token <TStatement> _ASCENDING_
%token <TStatement> _AT_
%token <TStatement> _AUTO_
%token <TStatement> _AUTODDL_
%token <TStatement> _AVG_
%token <TStatement> _BASED_
%token <TStatement> _BASENAME_
%token <TStatement> _BASE_NAME_
%token <TStatement> _BEFORE_
%token <TStatement> _BEGIN_
%token <TStatement> _BETWEEN_
%token <TStatement> _BLOB_
%token <TStatement> _BLOBEDIT_
%token <TStatement> _BUFFER_
%token <TStatement> _BY_
%token <TStatement> _CACHE_
%token <TStatement> _CASCADE_
%token <TStatement> _CAST_
%token <TStatement> _CHAR_
%token <TStatement> _CHARACTER_
%token <TStatement> _CHARACTER_LENGTH_
%token <TStatement> _CHAR_LENGTH_
%token <TStatement> _CHECK_
%token <TStatement> _CHECK_POINT_LEN_
%token <TStatement> _CHECK_POINT_LENGTH_
%token <TStatement> _COLLATE_
%token <TStatement> _COLLATION_
%token <TStatement> _COLUMN_
%token <TStatement> _COMMIT_
%token <TStatement> _COMMITTED_
%token <TStatement> _COMPILETIME_
%token <TStatement> _COMPUTED_
%token <TStatement> _CLOSE_
%token <TStatement> _CONDITIONAL_
%token <TStatement> _CONNECT_
%token <TStatement> _CONSTRAINT_
%token <TStatement> _CONTAINING_
%token <TStatement> _CONTINUE_
%token <TStatement> _COUNT_
%token <TStatement> _CREATE_
%token <TStatement> _CSTRING_
%token <TStatement> _CURRENT_
%token <TStatement> _CURRENT_DATE_
%token <TStatement> _CURRENT_TIME_
%token <TStatement> _CURRENT_TIMESTAMP_
%token <TStatement> _CURSOR_
%token <TStatement> _DATABASE_
%token <TStatement> _DATE_
%token <TStatement> _DAY_
%token <TStatement> _DB_KEY_
%token <TStatement> _DEBUG_
%token <TStatement> _DEC_
%token <TStatement> _DECIMAL_
%token <TStatement> _DECLARE_
%token <TStatement> _DEFAULT_
%token <TStatement> _DELETE_
%token <TStatement> _DESC_
%token <TStatement> _DESCENDING_
%token <TStatement> _DESCRIBE_
%token <TStatement> _DISCONNECT_
%token <TStatement> _DISPLAY_
%token <TStatement> _DISTINCT_
%token <TStatement> _DO_
%token <TStatement> _DOMAIN_
%token <TStatement> _DOUBLE_
%token <TStatement> _DROP_
%token <TStatement> _ECHO_
%token <TStatement> _EDIT_
%token <TStatement> _ELSE_
%token <TStatement> _END_
%token <TStatement> _ENTRY_POINT_
%token <TStatement> _ESCAPE_
%token <TStatement> _EVENT_
%token <TStatement> _EXCEPTION_
%token <TStatement> _EXECUTE_
%token <TStatement> _EXISTS_
%token <TStatement> _EXIT_
%token <TStatement> _EXTERN_
%token <TStatement> _EXTERNAL_
%token <TStatement> _EXTRACT_
%token <TStatement> _FETCH_
%token <TStatement> _FILE_
%token <TStatement> _FILTER_
%token <TStatement> _FLOAT_
%token <TStatement> _FOR_
%token <TStatement> _FOREIGN_
%token <TStatement> _FOUND_
%token <TStatement> _FREE_IT_
%token <TStatement> _FROM_
%token <TStatement> _FULL_
%token <TStatement> _FUNCTION_
%token <TStatement> _GDSCODE_
%token <TStatement> _GENERATOR_
%token <TStatement> _GEN_ID_
%token <TStatement> _GLOBAL_
%token <TStatement> _GOTO_
%token <TStatement> _GRANT_
%token <TStatement> _GROUP_
%token <TStatement> _GROUP_COMMIT_WAIT_
%token <TStatement> _GROUP_COMMIT__
%token <TStatement> _WAIT_TIME_
%token <TStatement> _HAVING_
%token <TStatement> _HOUR_
%token <TStatement> _HELP_
%token <TStatement> _IMMEDIATE_
%token <TStatement> _IF_
%token <TStatement> _IN_
%token <TStatement> _INACTIVE_
%token <TStatement> _INDEX_
%token <TStatement> _INDICATOR_
%token <TStatement> _INIT_
%token <TStatement> _INNER_
%token <TStatement> _INPUT_
%token <TStatement> _INPUT_TYPE_
%token <TStatement> _INSERT_
%token <TStatement> _INT_
%token <TStatement> _INTEGER_
%token <TStatement> _INTO_
%token <TStatement> _IS_
%token <TStatement> _ISOLATION_
%token <TStatement> _ISQL_
%token <TStatement> _JOIN_
%token <TStatement> _KEY_
%token <TStatement> _LC_MESSAGES_
%token <TStatement> _LC_TYPE_
%token <TStatement> _LEFT_
%token <TStatement> _LENGTH_
%token <TStatement> _LEV_
%token <TStatement> _LEVEL_
%token <TStatement> _LIKE_
%token <TStatement> _LOGFILE_
%token <TStatement> _LOG_BUFFER_SIZE_
%token <TStatement> _LOG_BUF_SIZE_
%token <TStatement> _LONG_
%token <TStatement> _MANUAL_
%token <TStatement> _MAX_
%token <TStatement> _MAXIMUM_
%token <TStatement> _MAXIMUM_SEGMENT_
%token <TStatement> _MAX_SEGMENT_
%token <TStatement> _MERGE_
%token <TStatement> _MESSAGE_
%token <TStatement> _MIN_
%token <TStatement> _MINUTE_
%token <TStatement> _MINIMUM_
%token <TStatement> _MODULE_NAME_
%token <TStatement> _MONTH_
%token <TStatement> _NAMES_
%token <TStatement> _NATIONAL_
%token <TStatement> _NATURAL_
%token <TStatement> _NCHAR_
%token <TStatement> _NO_
%token <TStatement> _NOAUTO_
%token <TStatement> _NOT_
%token <TStatement> _NULL_
%token <TStatement> _NUMERIC_
%token <TStatement> _NUM_LOG_BUFS_
%token <TStatement> _NUM_LOG_BUFFERS_
%token <TStatement> _OCTET_LENGTH_
%token <TStatement> _OF_
%token <TStatement> _ON_
%token <TStatement> _ONLY_
%token <TStatement> _OPEN_
%token <TStatement> _OPTION_
%token <TStatement> _OR_
%token <TStatement> _ORDER_
%token <TStatement> _OUTER_
%token <TStatement> _OUTPUT_
%token <TStatement> _OUTPUT_TYPE_
%token <TStatement> _OVERFLOW_
%token <TStatement> _PAGE_
%token <TStatement> _PAGELENGTH_
%token <TStatement> _PAGES_
%token <TStatement> _PAGE_SIZE_
%token <TStatement> _PARAMETER_
%token <TStatement> _PASSWORD_
%token <TStatement> _PLAN_
%token <TStatement> _POSITION_
%token <TStatement> _POST_EVENT_
%token <TStatement> _PRECISION_
%token <TStatement> _PREPARE_
%token <TStatement> _PROCEDURE_
%token <TStatement> _PROTECTED_
%token <TStatement> _PRIMARY_
%token <TStatement> _PRIVILEGES_
%token <TStatement> _PUBLIC_
%token <TStatement> _QUIT_
%token <TStatement> _RAW_PARTITIONS_
%token <TStatement> _READ_
%token <TStatement> _REAL_
%token <TStatement> _RECORD_VERSION_
%token <TStatement> _REFERENCES_
%token <TStatement> _RELEASE_
%token <TStatement> _RESERV_
%token <TStatement> _RESERVING_
%token <TStatement> _RESTRICT_
%token <TStatement> _RETAIN_
%token <TStatement> _RETURN_
%token <TStatement> _RETURNING_VALUES_
%token <TStatement> _RETURNS_
%token <TStatement> _REVOKE_
%token <TStatement> _RIGHT_
%token <TStatement> _ROLE_
%token <TStatement> _ROLLBACK_
%token <TStatement> _RUNTIME_
%token <TStatement> _SCHEMA_
%token <TStatement> _SECOND_
%token <TStatement> _SEGMENT_
%token <TStatement> _SELECT_
%token <TStatement> _SET_
%token <TStatement> _SHADOW_
%token <TStatement> _SHARED_
%token <TStatement> _SHELL_
%token <TStatement> _SHOW_
%token <TStatement> _SINGULAR_
%token <TStatement> _SIZE_
%token <TStatement> _SMALLINT_
%token <TStatement> _SNAPSHOT_
%token <TStatement> _SOME_
%token <TStatement> _SORT_
%token <TStatement> _SQL_
%token <TStatement> _SQLCODE_
%token <TStatement> _SQLERROR_
%token <TStatement> _SQLWARNING_
%token <TStatement> _STABILITY_
%token <TStatement> _STARTING_
%token <TStatement> _STARTS_
%token <TStatement> _STATEMENT_
%token <TStatement> _STATIC_
%token <TStatement> _STATISTICS_
%token <TStatement> _SUB_TYPE_
%token <TStatement> _SUM_
%token <TStatement> _SUSPEND_
%token <TStatement> _TABLE_
%token <TStatement> _TERM_
%token <TStatement> _TERMINATOR_
%token <TStatement> _THEN_
%token <TStatement> _TIME_
%token <TStatement> _TIMESTAMP_
%token <TStatement> _TO_
%token <TStatement> _TRANSACTION_
%token <TStatement> _TRANSLATE_
%token <TStatement> _TRANSLATION_
%token <TStatement> _TRIGGER_
%token <TStatement> _TRIM_
%token <TStatement> _TYPE_
%token <TStatement> _UNCOMMITTED_
%token <TStatement> _UNION_
%token <TStatement> _UNIQUE_
%token <TStatement> _UPDATE_
%token <TStatement> _UPPER_
%token <TStatement> _USER_
%token <TStatement> _USING_
%token <TStatement> _VALUE_
%token <TStatement> _VALUES_
%token <TStatement> _VARCHAR_
%token <TStatement> _VARIABLE_
%token <TStatement> _VARYING_
%token <TStatement> _VIEW_
%token <TStatement> _WAIT_
%token <TStatement> _WEEKDAY_
%token <TStatement> _WHILE_
%token <TStatement> _WHEN_
%token <TStatement> _WHENEVER_
%token <TStatement> _WHERE_
%token <TStatement> _WITH_
%token <TStatement> _WORK_
%token <TStatement> _WRITE_
%token <TStatement> _YEAR_
%token <TStatement> _YEARDAY_



%right _THEN_ _ELSE_            /* resolve dangling else */
%right ID LPAREN
%left _OR_ _AND_
%left _NOT_
%left EQUAL
%left _IS_
%left GE
%left GT
%left LE
%left LT
%left NOTGT
%left NOTLT
%left NOT_EQUAL
%left MINUS PLUS CONCAT
%left STAR SLASH
%left _COLLATE_


%token <TStatement> ID
_INTEGER
_REAL
STRING_CONST
ILLEGAL
TERM
SEMICOLON
COLON
COMMA
DOT
STAR
EQUAL
GE
GT
LE
LT
NOTGT
NOTLT
NOT_EQUAL
LPAREN
RPAREN
LSQB
RSQB
MINUS
PLUS
SLASH
CONCAT
QUEST

%{

//}


type
  TParserType = (ptNone,
                 ptDebugger,
                 ptDRUI,
                 ptExpr,
                 ptPlan,
                 ptColUnknown,
                 ptCheckInputParms,
                 ptWarnings,
                 ptSyntaxCheck);

  TOperationType = (optySelect,
                    optyInsert,
                    optyDelete,
                    optyUpdate);


  TVariablesCollectionItem = class(TCollectionItem)
  private
    FLine : Integer;
    FCol : Integer;
    FVarName : String;
    FVarCharSet : String;
    FVarLen : Integer;
    FVarType : Integer;
    FVarPrecision : Integer;
    FVarScale : Integer;
  public
    property Line : Integer read FLine write FLine;
    property Col : Integer read FCol write FCol;
    property VarName : String read FVarName write FVarName;
    property VarType : Integer read FVarType write FVarType;
    property VarLen : Integer read FVarLen write FVarLen;
    property VarCharSet : String read FVarCharSet write FVarCharSet;
    property VarPrecision : Integer read FVarPrecision write FVarPrecision;
    property VarScale : Integer read FVarScale write FVarScale;
    procedure Assign(Source : TVariablesCollectionItem ); reintroduce;
    constructor Create(Collection : TCollection); override;
    destructor Destroy; override;
  end;

  TVariablesList = class(TCollection)
  private
    function GetItem(Index: Integer): TVariablesCollectionItem;
    procedure SetItem(Index: Integer; Value: TVariablesCollectionItem);
  protected
  public
    procedure Assign(Source : TVariablesList); reintroduce;
    function Add: TVariablesCollectionItem;
    property Items[Index: Integer]: TVariablesCollectionItem read GetItem write SetItem; default;
  end;


  TOperationsCollectionItem = class(TCollectionItem)
  private
    FLine : Integer;
    FTableList : TStringList;
    FOperationType : TOperationType;
  public
    property Line : Integer read FLine write FLine;
    property TableList : TStringList read FTableList write FTableList;
    property OpType : TOperationType read FOperationType write FOperationType;
    constructor Create(Collection : TCollection); override;
    destructor Destroy; override;
  end;

  TOperationsList = class(TCollection)
  private
    function GetItem(Index: Integer): TOperationsCollectionItem;
    procedure SetItem(Index: Integer; Value: TOperationsCollectionItem);
  protected
  public
    function Add: TOperationsCollectionItem;
    property Items[Index: Integer]: TOperationsCollectionItem read GetItem write SetItem; default;
  end;

  TSQLLexer = Class(TCustomLexer)
  private
    FIsInterbase6 : Boolean;
    FSQLDialect : Integer;
  public
    Terminator : String;
    Statement : String;
    // utility functions
    function Upper(str : String) : String;
    function StripQuotes(str : String) : String;
    function IsKeyword(id : string; var token : integer) : boolean;
    function IsTerminator(id : String) : Boolean;
    // Lexer main functions
    function yylex : Integer; override;
    procedure yyaction( yyruleno : integer);
    procedure SkipComment;
    procedure CommentEOF;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    property IsInterbase6 : Boolean read FIsInterbase6 write FIsInterbase6;
    property SQLDialect : Integer read FSQLDialect write FSQLDialect;
  end;


  TStatementFound = procedure(Sender : TObject; Line : Integer; Column : Integer; Statement : String) of Object;

  TSQLParser = class(TCustomParser)
  private
    FDeclaredVariables : TVariablesList;
    FCodeVariables : TVariablesList;
    TmpSelectTableList : TStringList;
    TmpTableList : TStringList;
    FOperations : TOperationsList;
    FParserType : TParserType;
    FOnStatementFound : TStatementFound;
    FExpressionRetVal : Variant;
    FExpressionSymbols : TSymbolTable;
  public
    Module : TProcModule;
    PlanObject : TPlanObject;
    FItemList : TList;
    Lexer : TSQLLexer;
    function yyparse : integer; override;
    procedure yyerror(msg : string);
    constructor create( anOwner : TComponent); override;
    destructor destroy; override;
    function EvalExpression(Expr : String; SymbolTable : TSymbolTable) : Variant;
    property ParserType : TParserType read FParserType write FParserType;
    property Operations : TOperationsList read FOperations;
    property DeclaredVariables : TVariablesList read FDeclaredVariables;
    property CodeVariables : TVariablesList read FCodeVariables;
    property OnStatementFound : TStatementFound read FOnStatementFound write FOnStatementFound;
  end;


function ConvertOpType(OpType : TOperationType) : String;


implementation


var
  Filename : String;




function ConvertOpType(OpType : TOperationType) : String;
begin
  case OpType of
    optySelect : Result := 'Select';
    optyInsert : Result := 'Insert';
    optyDelete : Result := 'Delete';
    optyUpdate : Result := 'Update';
  end;
end;

constructor TSQLParser.Create(AnOwner : TComponent);
begin
  inherited Create(AnOwner);
  Lexer := TSQLLexer.Create(nil);
  yyLexer := Lexer;
  FItemList := TList.Create;
  yyDebug := True;
  TmpTableList := TStringList.Create;
  TmpSelectTableList := TStringList.Create;
  FOperations := TOperationsList.Create(TOperationsCollectionItem);
  FDeclaredVariables := TVariablesList.Create(TVariablesCollectionItem);
  FCodeVariables := TVariablesList.Create(TVariablesCollectionItem);
  FParserType := ptNone;
  PlanObject := TPlanObject.Create;
end;

destructor TSQLParser.Destroy;
var
  Idx : Integer;

begin
  for Idx := 0 to FItemList.Count - 1 do
    TStatement(FItemList[Idx]).Free;
  FItemList.Free;
  FOperations.Free;
  TmpTableList.Free;
  TmpSelectTableList.Free;
  FDeclaredVariables.Free;
  FCodeVariables.Free;
  Lexer.Free;
  PlanObject.Free;
  inherited Destroy;
end;

function TSQLParser.EvalExpression(Expr : String; SymbolTable : TSymbolTable) : Variant;
var
  PResult : Integer;

begin
  FExpressionSymbols := SymbolTable;
  lexer.yyinput.Text := Expr;
  try
    PResult := yyparse;
    if PResult = 0 then
    begin
      Result := FExpressionRetVal;
    end
    else
      Result := 'Syntax error';
  except
    On E : Exception do
    begin
      Result := E.Message;
    end;
  end;
end;


//==============================================================================

constructor TVariablesCollectionItem.Create(Collection : TCollection);
begin
  inherited Create(Collection);
end;

destructor TVariablesCollectionItem.Destroy;
begin
  inherited Destroy;
end;

procedure TVariablesCollectionItem.Assign(Source: TVariablesCollectionItem);
begin
  FLine := Source.Line;
  FCol := Source.Col;
  FVarName := Source.VarName;
  FVarType := Source.VarType;
  FVarLen := Source.VarLen;
  FVarCharSet := Source.VarCharSet;
  FVarPrecision := Source.VarPrecision;
  FVarScale := Source.VarScale;
end;


procedure TVariablesList.Assign(Source: TVariablesList);
var
  Idx : Integer;

begin
  Clear;
  for Idx := 0 to Source.Count - 1 do
  begin
    with Add do
      Assign(Source.Items[Idx]);
  end;
end;

function TVariablesList.GetItem(Index: Integer): TVariablesCollectionItem;
begin
  Result := TVariablesCollectionItem(inherited GetItem(Index));
end;

procedure TVariablesList.SetItem(Index: Integer; Value: TVariablesCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

function TVariablesList.Add: TVariablesCollectionItem;
begin
  Result := TVariablesCollectionItem(inherited Add);
end;

//==============================================================================


constructor TOperationsCollectionItem.Create(Collection : TCollection);
begin
  inherited Create(Collection);
  FTableList := TStringList.Create;
end;

destructor TOperationsCollectionItem.Destroy;
begin
  FTableList.Free;
  inherited Destroy;
end;

function TOperationsList.GetItem(Index: Integer): TOperationsCollectionItem;
begin
  Result := TOperationsCollectionItem(inherited GetItem(Index));
end;

procedure TOperationsList.SetItem(Index: Integer; Value: TOperationsCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

function TOperationsList.Add: TOperationsCollectionItem;
begin
  Result := TOperationsCollectionItem(inherited Add);
end;




(*----------------------------------------------------------------------------*)
procedure TSQLParser.yyerror(msg : string);
begin
  yyLexer.yyerrorfile.Add(filename+ ': ' + intToStr(yyLexer.yylineno) + ': ' + msg + ' at or before `'+ yyLexer.yytext + '''.');
end;

%}


%%

entry_point         : create
                      {
                        if not (FParserType in [ptDebugger,
                                                ptDRUI,
                                                ptColUnknown,
                                                ptCheckInputParms,
                                                ptWarnings]) then
                          raise Exception.Create('not supported');
                      }
                    | expression_eval
                      {
                        if FParserType <> ptExpr then
                          raise Exception.Create('not supported');
                        FExpressionRetVal := $1.Value;
                      }
                    | plan_clause
                      {
                        if FParserType <> ptPlan then
                          raise Exception.Create('not supported')
                        else
                          PlanObject.RootStatement := $1;

                      }
                    ;

create
                    : create_keyword create_clause
                    ;
create_keyword      : _CREATE_
                    | _ALTER_
                    ;
create_clause
                    : _PROCEDURE_ procedure_clause
                    | _TRIGGER_ def_trigger_clause
                    ;

collate_clause
                    : _COLLATE_ collation_name
                    | /* empty */
                    ;
column_def_name
                    : column_name
                    ;
simple_column_def_name
                    : simple_column_name
                    ;
data_type_descriptor
                    : init_data_type data_type
init_data_type
                    : /* empty */
                    ;

procedure_clause
                    : ID input_parameters_list output_parameters _AS_ begin_string var_declaration_list full_proc_block end_trigger
                      {
                        if FParserType = ptDebugger then
                        begin
                          Module.RootStatement := $7;
                        end;
                      }
                    ;

input_parameters_list
                    : LPAREN in_proc_parameters RPAREN
                    | /* empty */
                    ;

outut_parameters_list
                    : LPAREN out_proc_parameters RPAREN
                    | /* empty */
                    ;

output_parameters
                    : _RETURNS_ outut_parameters_list
                    | /* empty */
                    ;
in_proc_parameters
                    : in_proc_parameter
                    | in_proc_parameters COMMA in_proc_parameter
                    ;
out_proc_parameters
                    : out_proc_parameter
                    | out_proc_parameters COMMA out_proc_parameter
                    ;
in_proc_parameter
                    : simple_column_def_name non_array_type
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            with Module.GetSymbolTable.Add do
                            begin
                              Name := $1.Value;
                              SymType := $2.SymType;
                              SymCharSet := $2.SymCharSet;
                              SymPrecision := $2.SymPrecision;
                              SymScale := $2.SymScale;
                              SymSize := $2.SymSize;
                              SymbolType := stInput;
                            end;
                            Module.GetSymbolTable.UpdateSym($1.Value, Null);
                          end;

                          if FParserType = ptColUnknown then
                          begin
                            with FDeclaredVariables.Add do
                            begin
                              VarName := $1.Value;
                              Line := $1.Line;
                              Col := $1.Col;
                            end;
                          end;

                          if FParserType = ptCheckInputParms then
                          begin
                            with FDeclaredVariables.Add do
                            begin
                              VarName := $1.Value;
                              VarCharSet := $2.SymCharSet;
                              VarLen := $2.SymSize;
                              VarType := $2.SymType;
                              VarPrecision := $2.SymPrecision;
                              VarScale := $2.SymScale;
                              Line := $1.Line;
                              Col := $1.Col;
                            end;
                          end;
                        end;
                      }
                    ;

out_proc_parameter
                    : simple_column_def_name non_array_type
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            with Module.GetSymbolTable.Add do
                            begin
                              Name := $1.Value;
                              SymType := $2.SymType;
                              SymCharSet := $2.SymCharSet;
                              SymPrecision := $2.SymPrecision;
                              SymScale := $2.SymScale;
                              SymSize := $2.SymSize;
                              SymbolType := stOutput;
                            end;
                            with Module.ExecutionResults.FieldRoster.Add do
                            begin
                              Name := $1.Value;
                              case $2.Symtype of
                                ty_blr_text,
                                ty_blr_text2,
                                ty_blr_varying,
                                ty_blr_varying2:
                                  begin
                                    FieldType := fdtString;
                                    Size := $2.SymSize;
                                  end;

                                ty_blr_short,
                                ty_blr_long,
                                ty_blr_int64:
                                  FieldType := fdtInteger;

                                ty_blr_float,
                                ty_blr_double,
                                ty_blr_d_float:
                                  FieldType := fdtFloat;


                                ty_blr_blob:
                                  FieldType := fdtMemo;


                                ty_blr_sql_date,
                                ty_blr_sql_time,
                                ty_blr_timestamp:
                                  FieldType := fdtDateTime;
                              end;
                            end;
                            Module.GetSymbolTable.UpdateSym($1.Value, Null);
                          end;


                          if FParserType = ptColUnknown then
                          begin
                            with FDeclaredVariables.Add do
                            begin
                              VarName := $1.Value;
                              Line := $1.Line;
                              Col := $1.Col;
                            end;
                          end;
                        end;
                      }
                    ;

var_declaration_list
                    : var_declarations
                    | /* empty */
                    ;
var_declarations
                    : var_declaration
                    | var_declarations var_declaration
                    ;
var_declaration
                    : _DECLARE_ _VARIABLE_ column_def_name non_array_type TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            with Module.GetSymbolTable.Add do
                            begin
                              Name := $3.Value;
                              SymType := $4.SymType;
                              SymCharSet := $4.SymCharSet;
                              SymPrecision := $4.SymPrecision;
                              SymScale := $4.SymScale;
                              SymSize := $4.SymSize;
                              SymbolType := stLocal;
                            end;
                            Module.GetSymbolTable.UpdateSym($1.Value, Null);
                          end;

                          if FParserType = ptColUnknown then
                          begin
                            with FDeclaredVariables.Add do
                            begin
                              VarName := $3.Value;
                              Line := $3.Line;
                              Col := $3.Col;
                            end;
                          end;
                        end;
                      }
                    ;

proc_block
                    : proc_statement
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'proc_statement';
                          end;
                        end;
                      }
                    | full_proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'full_proc_block';
                          end;
                        end;
                      }
                    ;

full_proc_block
                    : _BEGIN_ proc_statements _END_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                            $$.EndLine := $3.Line;
                            $$.Name := 'proc_statements';
                          end;
                        end;
                      }
                    | _BEGIN_ proc_statements excp_statements _END_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                            $$.ExceptionBlock := $3;
                            $$.EndLine := $4.Line;
                            $$.Name := 'proc_statements';
                          end;
                        end;
                      }
                    ;

proc_statements
                    : proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TProcStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'proc_statements';
                          end;
                        end;
                      }
                    | proc_statements proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($2);
                            $$ := $1;
                            $$.Name := 'proc_statements';
                          end;
                        end;
                      }
                    ;

proc_statement
                    : assignment TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'assignment';
                          end;
                        end;
                      }
                    | delete TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'delete';
                          end;
                        end;
                      }
                    | _EXCEPTION_ ID TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExceptionStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TExceptionStatement(Module.RootStatement).ExceptionName := $2.Value;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'exception';
                          end;
                        end;
                      }
                    | exec_procedure
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'execprocedure';
                          end;
                        end;
                      }
                    | for_select
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'forselect';
                          end;
                        end;
                      }
                    | if_then_else
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'ifthenelse';
                          end;
                        end;
                      }
                    |
                      {
                        begin
                          if FParserType in  [ptDebugger, ptWarnings] then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }
                      insert TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                            $$.Name := 'insert';
                          end;
                        end;
                      }
                    | _POST_EVENT_ value TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TPostEventStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TPostEventStatement(Module.RootStatement).EventName := $2.Value;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'postevent';
                          end;
                        end;
                      }
                    | singleton_select
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'singletonselect';
                          end;
                        end;
                      }
                    | update TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'update';
                          end;
                        end;
                      }
                    | while
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'while';
                          end;
                        end;
                      }
                    | _SUSPEND_ TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TSuspendStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'suspend';
                          end;
                        end;
                      }
                    | _EXIT_ TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExitStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'exit';
                          end;
                        end;
                      }
                    ;

exec_procedure
                    :
                      _EXECUTE_ _PROCEDURE_ ID proc_inputs proc_outputs TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $2.Line;

                            TExecProcStatement(Module.RootStatement).ProcName := $3.Value;
                            TExecProcStatement(Module.RootStatement).ProcInputs := $4;
                            TExecProcStatement(Module.RootStatement).ProcOutputs := $5;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    ;

for_select
                    :
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }
                      _FOR_ select _INTO_ variable_list cursor_def _DO_ proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TForSelectStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $2.Line;
                            TForSelectStatement(Module.RootStatement).SQLStatement := $3;
                            TForSelectStatement(Module.RootStatement).VariableList := $5;
                            TForSelectStatement(Module.RootStatement).ConditionTrue := $8;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'forselect';
                          end;
                        end;
                      }
                    ;

if_then_else
                    : _IF_ LPAREN search_condition RPAREN _THEN_ proc_block opt_else
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TIfStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.EndLine := $6.EndLine;
                            TIfStatement(Module.RootStatement).Condition := $3;
                            TIfStatement(Module.RootStatement).ConditionTrue := $6;
                            TIfStatement(Module.RootStatement).OptElse := $7;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'ifstatement';
                          end;
                        end;
                      }
                    ;
opt_else
                    :
                      /* empty */
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := nil
                          end;
                        end;
                      }
                    | _ELSE_ proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                          end;
                        end;
                      }
                    ;

singleton_select
                    :
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }
                      select _INTO_ variable_list TERM
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            //singleton select
                            Module.RootStatement := TSingletonSelectStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $2.Line;
                            TSingletonSelectStatement(Module.RootStatement).SQLStatement := $2;
                            TSingletonSelectStatement(Module.RootStatement).VariableList := $4;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'singletonselect';
                          end;
                        end;
                      }
                    ;

variable
                    : COLON ID
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := '?' + $2.Value;
                            $$ := $2;
                          end;

                          if FParserType = ptColUnknown then
                          begin
                            with FCodeVariables.Add do
                            begin
                              VarName := $2.Value;
                              Line := $2.Line;
                              Col := $2.Col;
                            end;
                          end;
                        end;
                      }
                    ;
proc_inputs
                    : var_const_list
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                          end;
                        end;
                      }

                    | LPAREN var_const_list RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                          end;
                        end;
                      }
                    | /* empty */
                    ;
proc_outputs
                    : _RETURNING_VALUES_ po_variable_list
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                          end;
                        end;
                      }
                    | _RETURNING_VALUES_ LPAREN po_variable_list RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $3;
                          end;
                        end;
                      }
                    | /* empty */
                    ;
var_const_list
                    : variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | constant
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | null_value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | var_const_list COMMA variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    | var_const_list COMMA constant
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    | var_const_list COMMA column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    | var_const_list COMMA null_value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    ;

po_variable_list
                    : variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExecProcParams.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'execproc';
                          end;
                        end;
                      }
                    | variable_list COMMA column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    | variable_list COMMA variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($3);
                          end;
                        end;
                      }
                    ;

variable_list
                    : variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            //var list 1
                            $1.SQLStatement := $1.Value;
                            $$ := $1;
                          end;
                        end;
                      }
                    | column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := $1.Value;
                            $$ := $1;
                          end;
                        end;
                      }
                    | variable_list COMMA column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            //var list 1
                            $1.SQLStatement := $1.SQLStatement + ', ' + $3.SQLStatement;
                            $$ := $1;
                          end;
                        end;
                      }
                    | variable_list COMMA variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            //var list 1
                            $1.SQLStatement := $1.SQLStatement + ', ' + $3.SQLStatement;
                            $$ := $1;
                          end;
                        end;
                      }
                    ;
while
                    : _WHILE_ LPAREN search_condition RPAREN _DO_ proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TWhileStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.EndLine := $6.EndLine;
                            TWhileStatement(Module.RootStatement).Condition := $3;
                            TWhileStatement(Module.RootStatement).ConditionTrue := $6;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'whilestatement';
                          end;
                        end;
                      }
                    ;
cursor_def
                    : _AS_ _CURSOR_ ID
                    | /* empty */
                    ;
excp_statements
                    : excp_statement
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TProcStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.Statements.Add($1);
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'excp_statements';
                          end;
                        end;
                      }
                    | excp_statements excp_statement
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.Statements.Add($2);
                            $$ := $1;
                            $$.Name := 'excp_statements';
                          end;
                        end;
                      }
                    ;


excp_statement
                    : _WHEN_ errors _DO_ proc_block
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TExceptionHandlerStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            Module.RootStatement.EndLine := $4.EndLine;
                            TExceptionHandlerStatement(Module.RootStatement).Condition := $2;
                            TExceptionHandlerStatement(Module.RootStatement).ConditionTrue := $4;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'ExceptionHandlerStatement';
                          end;
                        end;
                      }
                    ;
errors
                    : err
                    | errors COMMA err
                    ;
err
                    : _SQLCODE_ signed_short_integer
                    | _GDSCODE_ ID
                    | _EXCEPTION_ ID
                    | _ANY_
                    ;
begin_string
                    : /* empty */
                    ;
begin_trigger
                    : /* empty */
                    ;
end_trigger
                    : /* empty */
                    ;

def_trigger_clause
                    : ID _FOR_ simple_table_name trigger_active trigger_type trigger_position begin_trigger trigger_action end_trigger
                    ;
trigger_active
                    : _ACTIVE_
                    | _INACTIVE_
                    | /* empty */
                    ;
trigger_type
                    : _BEFORE_ _INSERT_
                    | _AFTER_ _INSERT_
                    | _BEFORE_ _UPDATE_
                    | _AFTER_ _UPDATE_
                    | _BEFORE_ _DELETE_
                    | _AFTER_ _DELETE_
                    ;
trigger_position
                    : _POSITION_ nonneg_short_integer
                    | /* empty */
                    ;

trigger_action
                    : _AS_ begin_trigger var_declaration_list full_proc_block
                    ;

data_type
                    : non_array_type
                    | array_type
                    ;

non_array_type
                    : simple_type
                    | blob_type
                    ;

array_type
                    : non_charset_simple_type LSQB array_spec RSQB
                    | character_type LSQB array_spec RSQB charset_clause
                    ;

array_spec
                    : array_range
                    | array_spec COMMA array_range
                    ;

array_range
                    : signed_long_integer
                    | signed_long_integer COLON signed_long_integer
                    ;

simple_type
                    : non_charset_simple_type
                    | character_type charset_clause
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $1.SymCharSet := $2.SymCharSet;
                          end;
                        end;
                      }
                    ;

non_charset_simple_type
                    : national_character_type
                    | numeric_type
                    | float_type
                    | integer_keyword
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_long;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _SMALLINT_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_short;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _DATE_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_timestamp;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _TIMESTAMP_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_timestamp;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _TIME_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_sql_time;
                            $$.SymSize := 20;
                          end;
                        end;
                      }
                    ;

integer_keyword
                    : _INTEGER_
                    | _INT_
                    ;

blob_type
                    : _BLOB_ blob_subtype blob_segsize charset_clause
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_blob;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _BLOB_ LPAREN unsigned_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_blob;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _BLOB_ LPAREN unsigned_short_integer COMMA signed_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_blob;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _BLOB_ LPAREN COMMA signed_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_blob;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    ;

blob_segsize
                    : _SEGMENT_ _SIZE_ unsigned_short_integer
                    | /* empty */
                    ;
blob_subtype
                    : _SUB_TYPE_ signed_short_integer
                    | _SUB_TYPE_ subtype_name
                    | /* empty */
                    ;
charset_clause
                    : _CHARACTER_ _SET_ character_set_name
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymCharSet := $3.Value;
                          end;
                        end;
                      }
                    | /* empty */
                    ;

national_character_type
                    : national_character_keyword LPAREN pos_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_text;
                            $$.SymSize := $3.Value;
                          end;
                        end;
                      }
                    | national_character_keyword
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_text;
                            $$.SymSize := 1;
                          end;
                        end;
                      }
                    | national_character_keyword _VARYING_ LPAREN pos_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_varying;
                            $$.SymSize := $4.Value;
                          end;
                        end;
                      }
                    ;
character_type
                    : character_keyword LPAREN pos_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := TY_blr_text;
                            $$.SymSize := $3.Value;
                          end;
                        end;
                      }
                    | character_keyword
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_text;
                            $$.SymSize := 1;
                          end;
                        end;
                      }
                    | varying_keyword LPAREN pos_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_varying;
                            $$.SymSize := $3.Value;
                          end;
                        end;
                      }
                    ;

varying_keyword
                    : _VARCHAR_
                    | _CHARACTER_ _VARYING_
                    | _CHAR_ _VARYING_
                    ;

character_keyword
                    : _CHARACTER_
                    | _CHAR_
                    ;

national_character_keyword
                    : _NCHAR_
                    | _NATIONAL_ _CHARACTER_
                    | _NATIONAL_ _CHAR_
                    ;
character_set_name
                    : ID
                    ;
collation_name
                    : ID
                    ;
subtype_name
                    : ID
                    ;

numeric_type
                    : _NUMERIC_ prec_scale
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_double;
                            $$.SymSize := 0;
                            $$.SymPrecision := $2.SymPrecision;
                            $$.SymScale := $2.SymScale;
                          end;
                        end;
                      }
                    | decimal_keyword prec_scale
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_double;
                            $$.SymSize := 0;
                            $$.SymPrecision := $2.SymPrecision;
                            $$.SymScale := $2.SymScale;
                          end;
                        end;
                      }
                    ;

ordinal
                    : pos_short_integer
                    ;
prec_scale
                    : /* empty */
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymPrecision := 15;
                          end;
                        end;
                      }
                    | LPAREN pos_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymPrecision := $2.Value;
                          end;
                        end;
                      }
                    | LPAREN pos_short_integer COMMA nonneg_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymPrecision := $2.Value;
                            $$.SymScale := $4.Value;
                          end;
                        end;
                      }
                    ;
decimal_keyword
                    : _DECIMAL_
                    | _DEC_
                    ;

float_type
                    : _FLOAT_ precision_opt
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_float;
                            $$.SymSize := 0;
                            $$.SymPrecision := $2.SymPrecision;
                          end;
                        end;
                      }
                    | _LONG_ _FLOAT_ precision_opt
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_double;
                            $$.SymSize := 0;
                            $$.SymPrecision := $3.SymPrecision;
                          end;
                        end;
                      }
                    | _REAL_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_double;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    | _DOUBLE_ _PRECISION_
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymType := ty_blr_double;
                            $$.SymSize := 0;
                          end;
                        end;
                      }
                    ;

precision_opt
                    : LPAREN nonneg_short_integer RPAREN
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymPrecision := $2.Value;
                          end;
                        end;
                      }
                    | /* empty */
                      {
                        begin
                          if FParserType in [ptDebugger, ptCheckInputParms] then
                          begin
                            $$.SymPrecision := 15;
                          end;
                        end;
                      }
                    ;
select
                    :
                      {
                        begin
                          if FParserType in [ptDebugger, ptWarnings] then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }

                      union_expr order_clause for_update_clause

                      {
                        if FParserType = ptDRUI then
                        begin
                          with FOperations.Add do
                          begin
                            OpType := optySelect;
                            TableList.Text := TmpSelectTableList.Text;
                            Line := $2.Line;
                          end;
                          TmpTableList.Clear;
                          TmpSelectTableList.Clear;
                        end;

                        if FParserType = ptDebugger then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          if AnsiUpperCase(Copy(Lexer.Statement, 1, 6)) <> 'SELECT' then
                            Lexer.Statement := 'select ' + Lexer.Statement;
                          While Lexer.Statement[Length(Lexer.Statement)] in [#13, #10] do
                          begin
                            Lexer.Statement := Copy(Lexer.Statement, Length(Lexer.Statement) - 1, 1);
                            Lexer.Statement := Trim(Lexer.Statement);
                          end;
                          Lexer.Statement := Trim(Lexer.Statement);
                          if AnsiUpperCase(Copy(Lexer.Statement, Length(Lexer.Statement) - 3, 4)) = 'INTO' then
                          begin
                            Lexer.Statement := Copy(Lexer.Statement, 1, Length(Lexer.Statement) - 4);
                            Lexer.Statement := Trim(Lexer.Statement);
                          end;
                          yyval.yyTStatement.SQLStatement := Lexer.Statement;
                        end;

                        if FParserType = ptWarnings then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          if AnsiUpperCase(Copy(Lexer.Statement, 1, 6)) <> 'SELECT' then
                            Lexer.Statement := 'select ' + Lexer.Statement;
                          While Lexer.Statement[Length(Lexer.Statement)] in [#13, #10] do
                          begin
                            Lexer.Statement := Copy(Lexer.Statement, Length(Lexer.Statement) - 1, 1);
                            Lexer.Statement := Trim(Lexer.Statement);
                          end;
                          Lexer.Statement := Trim(Lexer.Statement);
                          if AnsiUpperCase(Copy(Lexer.Statement, Length(Lexer.Statement) - 3, 4)) = 'INTO' then
                          begin
                            Lexer.Statement := Copy(Lexer.Statement, 1, Length(Lexer.Statement) - 4);
                            Lexer.Statement := Trim(Lexer.Statement);
                          end;

                          if Assigned(FOnStatementFound) then
                            FOnStatementFound(Self, $2.Line, $2.Col, Lexer.Statement);

                        end;
                      }
                    ;
union_expr
                    : select_expr
                    | union_expr _UNION_ select_expr
                    | union_expr _UNION_ _ALL_ select_expr
                    ;

order_clause
                    : _ORDER_ _BY_ order_list
                    | /* empty */
                    ;
order_list
                    : order_item
                    | order_list COMMA order_item
                    ;
order_item
                    : column_name collate_clause order_direction
                    | ordinal collate_clause order_direction
                    ;
order_direction
                    : _ASC_
                    | _ASCENDING_
                    | _DESC_
                    | _DESCENDING_
                    | /* empty */
                    ;
for_update_clause
                    : _FOR_ _UPDATE_ for_update_list
                    | /* empty */
                    ;
for_update_list
                    : _OF_ column_list
                    | /* empty */
                    ;
select_expr
                    : _SELECT_ distinct_clause select_list from_clause where_clause group_clause having_clause plan_clause
                    ;

distinct_clause
                    : _DISTINCT_
                    | all_noise
                    ;
select_list
                    : select_items
                    | STAR
                    ;
select_items
                    : select_item
                    | select_items COMMA select_item
                    ;
select_item
                    : rhs
                    | rhs ID
                    | rhs _AS_ ID
                    ;
from_clause
                    : _FROM_ from_list
                    ;
from_list
                    : table_reference
                    | from_list COMMA table_reference
                    ;
table_reference
                    : joined_table
                    | table_proc
                    ;
joined_table
                    : table_reference join_type _JOIN_ table_reference _ON_ search_condition
                    | LPAREN joined_table RPAREN
                    ;
table_proc
                    : ID proc_table_inputs ID
                      {
                        if FParserType = ptDRUI then
                          TmpSelectTableList.Add($1.Value);
                      }
                    | ID proc_table_inputs
                      {
                        if FParserType = ptDRUI then
                          TmpSelectTableList.Add($1.Value);
                      }
                    ;
proc_table_inputs
                    : LPAREN null_or_value_list RPAREN
                    | /* empty */
                    ;
null_or_value_list
                    : null_or_value
                    | null_or_value_list COMMA null_or_value
                    ;
null_or_value
                    : null_value
                    | value
                    ;
table_name
                    : simple_table_name
                    | ID ID
                      {
                        if FParserType = ptDRUI then
                          TmpTableList.Add($1.Value);
                      }
                    ;
simple_table_name
                    : ID
                      {
                        if FParserType = ptDRUI then
                          TmpTableList.Add($1.Value);
                      }
                    ;
join_type
                    : _INNER_
                    | _LEFT_
                    | _LEFT_ _OUTER_
                    | _RIGHT_
                    | _RIGHT_ _OUTER_
                    | _FULL_
                    | _FULL_ _OUTER_
                    | /* empty */
                    ;
group_clause
                    : _GROUP_ _BY_ grp_column_list
                    | /* empty */
                    ;
grp_column_list
                    : grp_column_elem
                    | grp_column_list COMMA grp_column_elem
                    ;
grp_column_elem
                    : column_name
                    | column_name _COLLATE_ collation_name
                    ;
having_clause
                    : _HAVING_ search_condition
                    | /* empty */
                    ;
where_clause
                    : _WHERE_ search_condition
                    | /* empty */
                    ;
plan_clause
                    : _PLAN_ plan_expression
                      {
                        if FParserType = ptPlan then
                          $$ := $2;
                      }
                    | /* empty */
                    ;
plan_expression
                    : plan_type LPAREN plan_item_list RPAREN
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanExpressionStatement.Create;
                          TPlanExpressionStatement(PlanObject.RootStatement).PlanType := $1;
                          TPlanExpressionStatement(PlanObject.RootStatement).PlanList := $3;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    ;
plan_type
                    : _JOIN_
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTypeStatement.Create;
                          TPlanNodeTypeStatement(PlanObject.RootStatement).PlanType := pptJoin;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | _SORT_ _MERGE_
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTypeStatement.Create;
                          TPlanNodeTypeStatement(PlanObject.RootStatement).PlanType := pptSortMerge;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | _MERGE_
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTypeStatement.Create;
                          TPlanNodeTypeStatement(PlanObject.RootStatement).PlanType := pptMerge;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | _SORT_
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTypeStatement.Create;
                          TPlanNodeTypeStatement(PlanObject.RootStatement).PlanType := pptSort;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | /* empty */
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTypeStatement.Create;
                          TPlanNodeTypeStatement(PlanObject.RootStatement).PlanType := pptNone;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    ;
plan_item_list
                    : plan_item
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeItemListStatement.Create;
                          TPlanNodeItemListStatement(PlanObject.RootStatement).ItemList.Add($1);
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }

                    | plan_item_list COMMA plan_item
                      {
                        if FParserType = ptPlan then
                        begin
                          if $1 is TPlanNodeItemListStatement then
                            TPlanNodeItemListStatement($1).ItemList.Add($3);
                          $$ := $1;
                        end;
                      }
                    ;
plan_item
                    : table_or_alias_list access_type
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeItemStatement.Create;
                          TPlanNodeItemStatement(PlanObject.RootStatement).TableList := $1;
                          TPlanNodeItemStatement(PlanObject.RootStatement).AccessType := $2;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | plan_expression
                      {
                        if FParserType = ptPlan then
                        begin
                          $$ := $1;
                        end;
                      }
                    ;
table_or_alias_list
                    : ID
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeTableListStatement.Create;
                          TPlanNodeTableListStatement(PlanObject.RootStatement).TableList.Add($1);
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | table_or_alias_list ID
                      {
                        if FParserType = ptPlan then
                        begin
                          if $1 is TPlanNodeTableListStatement then
                            TPlanNodeTableListStatement($1).TableList.Add($2);
                          $$ := $1;
                        end;
                      }
                    ;
access_type
                    : _NATURAL_
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeAccessTypeStatement.Create;
                          TPlanNodeAccessTypeStatement(PlanObject.RootStatement).AccessType := atNatural;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | _INDEX_ LPAREN index_list RPAREN
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeAccessTypeStatement.Create;
                          TPlanNodeAccessTypeStatement(PlanObject.RootStatement).AccessType := atIndex;
                          TPlanNodeAccessTypeStatement(PlanObject.RootStatement).IndexList := $3;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | _ORDER_ ID
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeAccessTypeStatement.Create;
                          TPlanNodeAccessTypeStatement(PlanObject.RootStatement).AccessType := atOrder;
                          TPlanNodeAccessTypeStatement(PlanObject.RootStatement).Argument := $2.Value;
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    ;
index_list
                    : ID
                      {
                        if FParserType = ptPlan then
                        begin
                          PlanObject.RootStatement := TPlanNodeIndexListStatement.Create;
                          TPlanNodeIndexListStatement(PlanObject.RootStatement).IndexList.Add($1);
                          FItemList.Add(PlanObject.RootStatement);
                          $$ := PlanObject.RootStatement;
                        end;
                      }
                    | index_list COMMA ID
                      {
                        if FParserType = ptPlan then
                        begin
                          if $1 is TPlanNodeIndexListStatement then
                            TPlanNodeIndexListStatement($1).IndexList.Add($3);
                          $$ := $1;
                        end;
                      }
                    ;
insert
                    :
                      _INSERT_ _INTO_ simple_table_name column_parens_opt _VALUES_ LPAREN insert_value_list RPAREN
                      {
                        if FParserType = ptDRUI then
                        begin
                          with FOperations.Add do
                          begin
                            OpType := optyInsert;
                            TableList.Text := TmpTableList.Text;
                            Line := $2.Line;
                          end;
                          TmpTableList.Clear;
                          TmpSelectTableList.Clear;
                        end;

                        if FParserType = ptDebugger then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'insert ' + Lexer.Statement;

                          Module.RootStatement := TDMLStatement.Create;
                          Module.RootStatement.Module := Module;
                          Module.RootStatement.Line := $2.Line;
                          TDMLStatement(Module.RootStatement).SQLStatement := Lexer.Statement;
                          FItemList.Add(Module.RootStatement);
                          $$ := Module.RootStatement;
                          $$.Name := 'DML Statement';
                        end;

                        if FParserType = ptWarnings then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'insert ' + Lexer.Statement;

                          if Assigned(FOnStatementFound) then
                            FOnStatementFound(Self, $2.Line, $2.Col, Lexer.Statement);
                          
                        end;


                      }
                    |
                      _INSERT_ _INTO_ simple_table_name column_parens_opt select_expr
                      {
                        if FParserType = ptDRUI then
                        begin
                          with FOperations.Add do
                          begin
                            OpType := optyInsert;
                            TableList.Text := TmpTableList.Text;
                            Line := $2.Line;
                          end;
                          TmpTableList.Clear;
                          TmpSelectTableList.Clear;
                        end;

                        if FParserType = ptDebugger then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'insert ' + Lexer.Statement;

                          Module.RootStatement := TDMLStatement.Create;
                          Module.RootStatement.Module := Module;
                          Module.RootStatement.Line := $2.Line;
                          TDMLStatement(Module.RootStatement).SQLStatement := Lexer.Statement;
                          FItemList.Add(Module.RootStatement);
                          $$ := Module.RootStatement;
                          $$.Name := 'DML Statement';
                        end;

                        if FParserType = ptWarnings then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'insert ' + Lexer.Statement;

                          if Assigned(FOnStatementFound) then
                            FOnStatementFound(Self, $2.Line, $2.Col, Lexer.Statement);
                          
                        end;
                      }
                    ;
insert_value_list
                    : rhs
                    | insert_value_list COMMA rhs
                    ;
delete
                    : delete_searched
                    ;
delete_searched
                    :
                      {
                        begin
                          if FParserType in [ptDebugger, ptWarnings] then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }
                      _DELETE_ _FROM_ table_name where_clause
                      {
                        if FParserType = ptDRUI then
                        begin
                          with FOperations.Add do
                          begin
                            OpType := optyDelete;
                            TableList.Text := TmpTableList.Text;
                            Line := $2.Line;
                          end;
                          TmpTableList.Clear;
                          TmpSelectTableList.Clear;
                        end;

                        if FParserType = ptDebugger then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'delete from ' + Lexer.Statement;

                          Module.RootStatement := TDMLStatement.Create;
                          Module.RootStatement.Module := Module;
                          Module.RootStatement.Line := $2.Line;
                          TDMLStatement(Module.RootStatement).SQLStatement := Lexer.Statement;
                          FItemList.Add(Module.RootStatement);
                          $$ := Module.RootStatement;
                          $$.Name := 'DML Statement';
                        end;

                        if FParserType = ptWarnings then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'delete ' + Lexer.Statement;

                          if Assigned(FOnStatementFound) then
                            FOnStatementFound(Self, $2.Line, $2.Col, Lexer.Statement);

                        end;
                      }
                    ;

update
                    : update_searched
                    ;
update_searched
                    :
                      {
                        begin
                          if FParserType in [ptDebugger, ptWarnings] then
                          begin
                            Lexer.Statement := '';
                          end;
                        end;
                      }
                      _UPDATE_ table_name _SET_ assignments where_clause
                      {
                        if FParserType = ptDRUI then
                        begin
                          with FOperations.Add do
                          begin
                            OpType := optyUpdate;
                            TableList.Text := TmpTableList.Text;
                            Line := $2.Line;
                          end;
                          TmpTableList.Clear;
                          TmpSelectTableList.Clear;
                        end;

                        if FParserType = ptDebugger then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'update ' + Lexer.Statement;

                          Module.RootStatement := TDMLStatement.Create;
                          Module.RootStatement.Module := Module;
                          Module.RootStatement.Line := $2.Line;
                          TDMLStatement(Module.RootStatement).SQLStatement := Lexer.Statement;
                          FItemList.Add(Module.RootStatement);
                          $$ := Module.RootStatement;
                          $$.Name := 'DML Statement';
                        end;

                        if FParserType = ptWarnings then
                        begin
                          Lexer.Statement := Trim(Lexer.Statement);
                          Lexer.Statement := 'update ' + Lexer.Statement;

                          if Assigned(FOnStatementFound) then
                            FOnStatementFound(Self, $2.Line, $2.Col, Lexer.Statement);

                        end;
                      }
                    ;

assignments
                    : assignment
                    | assignments COMMA assignment
                    ;

assignment
                    : column_name EQUAL rhs
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TAssignmentStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TAssignmentStatement(Module.RootStatement).LHS := $1.Value;
                            TAssignmentStatement(Module.RootStatement).RHS := $3;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'assignment';
                          end;

                          if FParserType = ptColUnknown then
                          begin
                            with FCodeVariables.Add do
                            begin
                              VarName := $1.Value;
                              Line := $1.Line;
                              Col := $1.Col;
                            end;
                          end;
                        end;
                      }
                    ;
rhs
                    : value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | null_value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    ;

blob_subtype
                    : signed_short_integer
                    ;
column_parens_opt
                    : column_parens
                    | /* empty */
                    ;
column_parens
                    : LPAREN column_list RPAREN
                    ;
column_list
                    : column_name
                    | column_list COMMA column_name
                    ;
column_name
                    : simple_column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := $1.SQLStatement;
                            $$ := $1;
                          end;
                        end;
                      }
                    | ID DOT ID
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := $1.Value + $2.Value + $3.Value;
                            $$ := $1;
                          end;
                        end;
                      }
                    | ID DOT STAR
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := $1.Value + $2.Value + $3.Value;
                            $$ := $1;
                          end;
                        end;
                      }
                    ;

simple_column_name
                    : ID
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $1.SQLStatement := $1.Value;
                            $$ := $1;
                          end;
                        end;
                      }
                    ;
search_condition
                    : predicate
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'ifthenelse';
                          end;
                        end;
                      }
                    | search_condition _OR_ search_condition
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opOR;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | search_condition _AND_ search_condition
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opAND;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | _NOT_ search_condition
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $2;
                            TOperatorStatement(Module.RootStatement).Operator := opNOT;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    ;

predicate
                    : comparison_predicate
                    | between_predicate
                    | like_predicate
                    | in_predicate
                    | null_predicate
                    | quantified_predicate
                    | exists_predicate
                    | containing_predicate
                    | starting_predicate
                    | unique_predicate
                    | LPAREN search_condition RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    ;

comparison_predicate
                    : value EQUAL value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opEQUAL;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value LT value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opLessThan;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value GT value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opGreaterThan;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value GE value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opGreaterEqual;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value LE value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opLessEqual;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value NOTGT value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opNotGreaterThan;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value NOTLT value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opNotLessThan;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value NOT_EQUAL value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opNotEqual;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    ;

quantified_predicate
                    : value EQUAL _ALL_ LPAREN column_select RPAREN
                    | value LT _ALL_ LPAREN column_select RPAREN
                    | value GT _ALL_ LPAREN column_select RPAREN
                    | value GE _ALL_ LPAREN column_select RPAREN
                    | value LE _ALL_ LPAREN column_select RPAREN
                    | value NOTGT _ALL_ LPAREN column_select RPAREN
                    | value NOTLT _ALL_ LPAREN column_select RPAREN
                    | value NOT_EQUAL _ALL_ LPAREN column_select RPAREN
                    | value EQUAL some LPAREN column_select RPAREN
                    | value LT some LPAREN column_select RPAREN
                    | value GT some LPAREN column_select RPAREN
                    | value GE some LPAREN column_select RPAREN
                    | value LE some LPAREN column_select RPAREN
                    | value NOTGT some LPAREN column_select RPAREN
                    | value NOTLT some LPAREN column_select RPAREN
                    | value NOT_EQUAL some LPAREN column_select RPAREN
                    ;
some
                    : _SOME_
                    | _ANY_
                    ;
between_predicate
                    : value _BETWEEN_ value _AND_ value
                    | value _NOT_ _BETWEEN_ value _AND_ value
                    ;
like_predicate
                    : value _LIKE_ value
                    | value _NOT_ _LIKE_ value
                    | value _LIKE_ value _ESCAPE_ value
                    | value _NOT_ _LIKE_ value _ESCAPE_ value
                    ;
in_predicate
                    : value _IN_ scalar_set
                    | value _NOT_ _IN_ scalar_set
                    ;
containing_predicate
                    : value _CONTAINING_ value
                    | value _NOT_ _CONTAINING_ value
                    ;
starting_predicate
                    : value _STARTING_ value
                    | value _NOT_ _STARTING_ value
                    | value _STARTING_ _WITH_ value
                    | value _NOT_ _STARTING_ _WITH_ value
                    ;
exists_predicate
                    : _EXISTS_ LPAREN select_expr RPAREN
                    ;
unique_predicate
                    : _SINGULAR_ LPAREN select_expr RPAREN
                    ;

null_predicate
                    : value _IS_ _NULL_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $1;
                            TOperatorStatement(Module.RootStatement).Operator := opIsNull;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value _IS_ _NOT_ _NULL_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $1;
                            TOperatorStatement(Module.RootStatement).Operator := opIsNotNull;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    ;

scalar_set
                    : LPAREN constant_list RPAREN
                    | LPAREN column_select RPAREN
                    ;
column_select
                    : _SELECT_ distinct_clause value from_clause where_clause group_clause having_clause plan_clause
                    ;
value
                    : column_name
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | array_element
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | function
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | u_constant
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | parameter
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | variable
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | udf
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | MINUS value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $2;
                            TOperatorStatement(Module.RootStatement).Operator := opMINUS;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | PLUS value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $2;
                            TOperatorStatement(Module.RootStatement).Operator := opPLUS;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value PLUS value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opADD;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value CONCAT value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opCONCAT;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value _COLLATE_ collation_name
                    | value MINUS value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opSUBTRACT;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value STAR value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opMULTIPLY;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | value SLASH value
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opDIVIDE;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;  
                        end;
                      }
                    | LPAREN value RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $2;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | LPAREN column_select RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | _USER_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | _DB_KEY_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    | ID DOT _DB_KEY_
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            $$ := $1;
                            $$.Name := 'identifier';
                          end;
                        end;
                      }
                    ;

array_element
                    : column_name LSQB value_list RSQB
                    ;
value_list
                    : value
                    | value_list COMMA value
                    ;
constant
                    : u_constant
                    | MINUS u_numeric_constant
                    ;
u_numeric_constant
                    : _NUMERIC_
                    | _INTEGER
                    | _FLOAT_
                    ;
u_constant
                    : u_numeric_constant
                    | sql_string
                    ;
constant_list
                    : constant
                    | parameter
                    | current_user
                    | constant_list COMMA constant
                    | constant_list COMMA parameter
                    | constant_list COMMA current_user
                    ;
parameter
                    : QUEST
                    ;

current_user
                    : _USER_
                    ;
sql_string
                    : STRING_CONST
                      {
                        $$.Value := Lexer.StripQuotes($1.Value);
                      }
                    | ID STRING_CONST
                    ;
signed_short_integer
                    : nonneg_short_integer
                    | MINUS neg_short_integer
                    ;
nonneg_short_integer
                    : _INTEGER
                    ;
neg_short_integer
                    : _INTEGER
                    ;
pos_short_integer
                    : nonneg_short_integer
                    ;
unsigned_short_integer
                    : _INTEGER
                    ;
signed_long_integer
                    : long_integer
                    | MINUS long_integer
                    ;
long_integer
                    : _INTEGER
                    ;
function
                    : _COUNT_ LPAREN STAR RPAREN
                    | _COUNT_ LPAREN all_noise value RPAREN
                    | _COUNT_ LPAREN _DISTINCT_ value RPAREN
                    | _SUM_ LPAREN all_noise value RPAREN
                    | _SUM_ LPAREN _DISTINCT_ value RPAREN
                    | _AVG_ LPAREN all_noise value RPAREN
                    | _AVG_ LPAREN _DISTINCT_ value RPAREN
                    | maximum LPAREN all_noise value RPAREN
                    | maximum LPAREN _DISTINCT_ value RPAREN
                    | minimum LPAREN all_noise value RPAREN
                    | minimum LPAREN _DISTINCT_ value RPAREN
                    | _CAST_ LPAREN rhs _AS_ data_type_descriptor RPAREN
                    | _UPPER_ LPAREN value RPAREN
                    | _GEN_ID_ LPAREN ID COMMA value RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := nil;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opGENID;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    ;
maximum
                    : _MAXIMUM_
                    | _MAX_
                    ;
minimum
                    : _MINIMUM_
                    | _MIN_
                    ;
udf
                    : ID LPAREN value_list RPAREN
                      {
                        begin
                          if FParserType = ptDebugger then
                          begin
                            Module.RootStatement := TOperatorStatement.Create;
                            Module.RootStatement.Module := Module;
                            Module.RootStatement.Line := $1.Line;
                            TOperatorStatement(Module.RootStatement).LHS := $1;
                            TOperatorStatement(Module.RootStatement).RHS := $3;
                            TOperatorStatement(Module.RootStatement).Operator := opUDF;
                            FItemList.Add(Module.RootStatement);
                            $$ := Module.RootStatement;
                            $$.Name := 'expression';
                          end;
                        end;
                      }
                    | ID LPAREN RPAREN
                    ;
all_noise
                    : _ALL_
                    | /* empty */
                    ;
null_value
                    : _NULL_
                    ;


expression_eval     : _CAST_ LPAREN expression_eval _AS_ data_type_descriptor RPAREN
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              case $5.SymType of
                                ty_blr_text :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_text2 :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_short :
                                  begin
                                    try
                                      $$.Value := Integer($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_long :
                                  begin
                                    try
                                      $$.Value := Integer($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_quad :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_int64 :
                                  begin
                                    try
                                      $$.Value := Integer($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_float :
                                  begin
                                    try
                                      $$.Value := Single($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_double :
                                  begin
                                    try
                                      $$.Value := Double($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_d_float :
                                  begin
                                    try
                                      $$.Value := Double($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_timestamp :
                                  begin
                                    try
                                      $$.Value := Double($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_varying :
                                  begin
                                    try
                                      $$.Value := String($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_varying2 :
                                  begin
                                    try
                                      $$.Value := String($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_blob :
                                  begin
                                    raise Exception.Create('Type Mismatch');
                                  end;
                                ty_blr_cstring :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_cstring2 :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_blob_id :
                                  begin
                                    $$.Value := $3.Value;
                                  end;
                                ty_blr_sql_date :
                                  begin
                                    try
                                      $$.Value := Double($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                                ty_blr_sql_time :
                                  begin
                                    try
                                      $$.Value := Double($3.Value);
                                    except
                                      raise Exception.Create('Type Mismatch');
                                    end;
                                  end;
                              else
                                $$.Value := $3.Value;
                              end;
                              $$.SymType := $5.SymType;
                            end;
                          end;
                        end;
                      }
                    | _UPPER_ LPAREN expression_eval RPAREN
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                              $$.Value := UpperCase($3.Value);
                          end;
                        end;
                      }
                    | _GEN_ID_ LPAREN ID COMMA expression_eval RPAREN
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            $$.Value := null;
                          end;
                        end;
                      }
                    | u_constant
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) then
                              $$.Value := NULL
                            else
                              $$.Value := $1.Value;
                          end;
                        end;
                      }
                    | variable
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if FExpressionSymbols.IsSymbol($1.Value) then
                            begin
                              $$.Value := FExpressionSymbols.GetSymValue($1.Value);
                              $$.SymType := FExpressionSymbols.GetSymType($1.Name)
                            end
                            else
                              raise Exception.Create('Unknown Identifier');
                          end;
                        end;
                      }
                    | ID
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if FExpressionSymbols.IsSymbol($1.Value) then
                            begin
                              $$.Value := FExpressionSymbols.GetSymValue($1.Value);
                              $$.SymType := FExpressionSymbols.GetSymType($1.Name)
                            end
                            else
                              raise Exception.Create('Unknown Identifier');
                          end;
                        end;
                      }
                    | udf
                      {
                        begin
                          if FParserType = ptExpr then
                          begin

                          end;
                        end;
                      }
                    | MINUS expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($2.Value) then
                              $$.Value := NULL
                            else
                              $$.Value := -$2.Value;
                          end;
                        end;
                      }
                    | PLUS expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($2.Value) then
                              $$.Value := NULL
                            else
                              $$.Value := +$2.Value;
                          end;
                        end;
                      }
                    | expression_eval PLUS expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value + $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval CONCAT expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value + $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval _COLLATE_ collation_name
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval MINUS expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value - $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval STAR expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value * $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval SLASH expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value / $3.Value;
                            end;
                          end;
                        end;
                      }
                    | LPAREN expression_eval RPAREN
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($2.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $2.Value;
                            end;
                          end;
                        end;
                      }
                    | _USER_
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            $$.Value := 'user';
                          end;
                        end;
                      }
                    | expression_eval EQUAL expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value = $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval LT expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value < $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval GT expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value > $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval GE expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value >= $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval LE expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := $1.Value <= $3.Value;
                            end;
                          end;
                        end;
                      }
                    | expression_eval NOTGT expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := not ($1.Value > $3.Value);
                            end;
                          end;
                        end;
                      }
                    | expression_eval NOTLT expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := not ($1.Value < $3.Value);
                            end;
                          end;
                        end;
                      }
                    | expression_eval NOT_EQUAL expression_eval
                      {
                        begin
                          if FParserType = ptExpr then
                          begin
                            if VarIsNull($1.Value) or VarIsNull($3.Value) then
                              $$.Value := NULL
                            else
                            begin
                              $$.Value := not ($1.Value <> $3.Value);
                            end;
                          end;
                        end;
                      }
                    ;

%%


//===============================================
// KeyWords and Directives Arrays, constant.
//===============================================
const
  id_len = 20;

type
  Ident = string[id_len];

const
  (* table of Delphi Pascal keywords: *)
    no_of_keywords = 279;
    keyword : array [1..no_of_keywords] of Ident = (
      'ACTION',
      'ACTIVE',
      'ADD',
      'ADMIN',
      'AFTER',
      'ALL',
      'ALTER',
      'AND',
      'ANY',
      'AS',
      'ASC',
      'ASCENDING',
      'AT',
      'AUTO',
      'AUTODDL',
      'AVG',
      'BASED',
      'BASENAME',
      'BASE_NAME',
      'BEFORE',
      'BEGIN',
      'BETWEEN',
      'BLOB',
      'BLOBEDIT',
      'BUFFER',
      'BY',
      'CACHE',
      'CASCADE',
      'CAST',
      'CHAR',
      'CHARACTER',
      'CHARACTER_LENGTH',
      'CHAR_LENGTH',
      'CHECK',
      'CHECK_POINT_LEN',
      'CHECK_POINT_LENGTH',
      'COLLATE',
      'COLLATION',
      'COLUMN',
      'COMMIT',
      'COMMITTED',
      'COMPILETIME',
      'COMPUTED',
      'CLOSE',
      'CONDITIONAL',
      'CONNECT',
      'CONSTRAINT',
      'CONTAINING',
      'CONTINUE',
      'COUNT',
      'CREATE',
      'CSTRING',
      'CURRENT',
      'CURRENT_DATE',
      'CURRENT_TIME',
      'CURRENT_TIMESTAMP',
      'CURSOR',
      'DATABASE',
      'DATE',
      'DAY',
      'DB_KEY',
      'DEBUG',
      'DEC',
      'DECIMAL',
      'DECLARE',
      'DEFAULT',
      'DELETE',
      'DESC',
      'DESCENDING',
      'DESCRIBE',
      'DISCONNECT',
      'DISPLAY',
      'DISTINCT',
      'DO',
      'DOMAIN',
      'DOUBLE',
      'DROP',
      'ECHO',
      'EDIT',
      'ELSE',
      'END',
      'ENTRY_POINT',
      'ESCAPE',
      'EVENT',
      'EXCEPTION',
      'EXECUTE',
      'EXISTS',
      'EXIT',
      'EXTERN',
      'EXTERNAL',
      'EXTRACT',
      'FETCH',
      'FILE',
      'FILTER',
      'FLOAT',
      'FOR',
      'FOREIGN',
      'FREE_IT',
      'FROM',
      'FULL',
      'FUNCTION',
      'GDSCODE',
      'GENERATOR',
      'GEN_ID',
      'GLOBAL',
      'GOTO',
      'GRANT',
      'GROUP',
      'GROUP_COMMIT_WAIT',
      'GROUP_COMMIT_',
      'WAIT_TIME',
      'HAVING',
      'HELP',
      'HOUR',
      'IF',
      'IMMEDIATE',
      'IN',
      'INACTIVE',
      'INDEX',
      'INDICATOR',
      'INIT',
      'INNER',
      'INPUT',
      'INPUT_TYPE',
      'INSERT',
      'INT',
      'INTEGER',
      'INTO',
      'IS',
      'ISOLATION',
      'ISQL',
      'JOIN',
      'KEY',
      'LC_MESSAGES',
      'LC_TYPE',
      'LEFT',
      'LENGTH',
      'LEV',
      'LEVEL',
      'LIKE',
      'LOGFILE',
      'LOG_BUFFER_SIZE',
      'LOG_BUF_SIZE',
      'LONG',
      'MANUAL',
      'MAX',
      'MAXIMUM',
      'MAXIMUM_SEGMENT',
      'MAX_SEGMENT',
      'MERGE',
      'MESSAGE',
      'MIN',
      'MINIMUM',
      'MINUTE',
      'MODULE_NAME',
      'MONTH',
      'NAMES',
      'NATIONAL',
      'NATURAL',
      'NCHAR',
      'NO',
      'NOAUTO',
      'NOT',
      'NULL',
      'NUMERIC',
      'NUM_LOG_BUFS',
      'NUM_LOG_BUFFERS',
      'OCTET_LENGTH',
      'OF',
      'ON',
      'ONLY',
      'OPEN',
      'OPTION',
      'OR',
      'ORDER',
      'OUTER',
      'OUTPUT',
      'OUTPUT_TYPE',
      'OVERFLOW',
      'PAGE',
      'PAGELENGTH',
      'PAGES',
      'PAGE_SIZE',
      'PARAMETER',
      'PASSWORD',
      'PLAN',
      'POSITION',
      'POST_EVENT',
      'PRECISION',
      'PREPARE',
      'PROCEDURE',
      'PROTECTED',
      'PRIMARY',
      'PRIVILEGES',
      'PUBLIC',
      'QUIT',
      'RAW_PARTITIONS',
      'READ',
      'REAL',
      'RECORD_VERSION',
      'REFERENCES',
      'RELEASE',
      'RESERV',
      'RESERVING',
      'RESTRICT',
      'RETAIN',
      'RETURN',
      'RETURNING_VALUES',
      'RETURNS',
      'REVOKE',
      'RIGHT',
      'ROLE',
      'ROLLBACK',
      'RUNTIME',
      'SCHEMA',
      'SECOND',
      'SEGMENT',
      'SELECT',
      'SET',
      'SHADOW',
      'SHARED',
      'SHELL',
      'SHOW',
      'SINGULAR',
      'SIZE',
      'SMALLINT',
      'SNAPSHOT',
      'SOME',
      'SORT',
      'SQL',
      'SQLCODE',
      'SQLERROR',
      'SQLWARNING',
      'STABILITY',
      'STARTING',
      'STARTS',
      'STATEMENT',
      'STATIC',
      'STATISTICS',
      'SUB_TYPE',
      'SUM',
      'SUSPEND',
      'TABLE',
      'TERM',
      'TERMINATOR',
      'THEN',
      'TIME',
      'TIMESTAMP',
      'TO',
      'TRANSACTION',
      'TRANSLATE',
      'TRANSLATION',
      'TRIGGER',
      'TRIM',
      'TYPE',
      'UNCOMMITTED',
      'UNION',
      'UNIQUE',
      'UPDATE',
      'UPPER',
      'USER',
      'USING',
      'VALUE',
      'VALUES',
      'VARCHAR',
      'VARIABLE',
      'VARYING',
      'VIEW',
      'WAIT',
      'WEEKDAY',
      'WHEN',
      'WHENEVER',
      'WHERE',
      'WHILE',
      'WITH',
      'WORK',
      'WRITE',
      'YEAR',
      'YEARDAY'
      );
    keyword_token : array [1..no_of_keywords] of integer = (
      _ACTION_,
      _ACTIVE_,
      _ADD_,
      _ADMIN_,
      _AFTER_,
      _ALL_,
      _ALTER_,
      _AND_,
      _ANY_,
      _AS_,
      _ASC_,
      _ASCENDING_,
      _AT_,
      _AUTO_,
      _AUTODDL_,
      _AVG_,
      _BASED_,
      _BASENAME_,
      _BASE_NAME_,
      _BEFORE_,
      _BEGIN_,
      _BETWEEN_,
      _BLOB_,
      _BLOBEDIT_,
      _BUFFER_,
      _BY_,
      _CACHE_,
      _CASCADE_,
      _CAST_,
      _CHAR_,
      _CHARACTER_,
      _CHARACTER_LENGTH_,
      _CHAR_LENGTH_,
      _CHECK_,
      _CHECK_POINT_LEN_,
      _CHECK_POINT_LENGTH_,
      _COLLATE_,
      _COLLATION_,
      _COLUMN_,
      _COMMIT_,
      _COMMITTED_,
      _COMPILETIME_,
      _COMPUTED_,
      _CLOSE_,
      _CONDITIONAL_,
      _CONNECT_,
      _CONSTRAINT_,
      _CONTAINING_,
      _CONTINUE_,
      _COUNT_,
      _CREATE_,
      _CSTRING_,
      _CURRENT_,
      _CURRENT_DATE_,
      _CURRENT_TIME_,
      _CURRENT_TIMESTAMP_,
      _CURSOR_,
      _DATABASE_,
      _DATE_,
      _DAY_,
      _DB_KEY_,
      _DEBUG_,
      _DEC_,
      _DECIMAL_,
      _DECLARE_,
      _DEFAULT_,
      _DELETE_,
      _DESC_,
      _DESCENDING_,
      _DESCRIBE_,
      _DISCONNECT_,
      _DISPLAY_,
      _DISTINCT_,
      _DO_,
      _DOMAIN_,
      _DOUBLE_,
      _DROP_,
      _ECHO_,
      _EDIT_,
      _ELSE_,
      _END_,
      _ENTRY_POINT_,
      _ESCAPE_,
      _EVENT_,
      _EXCEPTION_,
      _EXECUTE_,
      _EXISTS_,
      _EXIT_,
      _EXTERN_,
      _EXTERNAL_,
      _EXTRACT_,
      _FETCH_,
      _FILE_,
      _FILTER_,
      _FLOAT_,
      _FOR_,
      _FOREIGN_,
      _FREE_IT_,
      _FROM_,
      _FULL_,
      _FUNCTION_,
      _GDSCODE_,
      _GENERATOR_,
      _GEN_ID_,
      _GLOBAL_,
      _GOTO_,
      _GRANT_,
      _GROUP_,
      _GROUP_COMMIT_WAIT_,
      _GROUP_COMMIT__,
      _WAIT_TIME_,
      _HAVING_,
      _HELP_,
      _HOUR_,
      _IF_,
      _IMMEDIATE_,
      _IN_,
      _INACTIVE_,
      _INDEX_,
      _INDICATOR_,
      _INIT_,
      _INNER_,
      _INPUT_,
      _INPUT_TYPE_,
      _INSERT_,
      _INT_,
      _INTEGER_,
      _INTO_,
      _IS_,
      _ISOLATION_,
      _ISQL_,
      _JOIN_,
      _KEY_,
      _LC_MESSAGES_,
      _LC_TYPE_,
      _LEFT_,
      _LENGTH_,
      _LEV_,
      _LEVEL_,
      _LIKE_,
      _LOGFILE_,
      _LOG_BUFFER_SIZE_,
      _LOG_BUF_SIZE_,
      _LONG_,
      _MANUAL_,
      _MAX_,
      _MAXIMUM_,
      _MAXIMUM_SEGMENT_,
      _MAX_SEGMENT_,
      _MERGE_,
      _MESSAGE_,
      _MIN_,
      _MINIMUM_,
      _MINUTE_,
      _MODULE_NAME_,
      _MONTH_,
      _NAMES_,
      _NATIONAL_,
      _NATURAL_,
      _NCHAR_,
      _NO_,
      _NOAUTO_,
      _NOT_,
      _NULL_,
      _NUMERIC_,
      _NUM_LOG_BUFS_,
      _NUM_LOG_BUFFERS_,
      _OCTET_LENGTH_,
      _OF_,
      _ON_,
      _ONLY_,
      _OPEN_,
      _OPTION_,
      _OR_,
      _ORDER_,
      _OUTER_,
      _OUTPUT_,
      _OUTPUT_TYPE_,
      _OVERFLOW_,
      _PAGE_,
      _PAGELENGTH_,
      _PAGES_,
      _PAGE_SIZE_,
      _PARAMETER_,
      _PASSWORD_,
      _PLAN_,
      _POSITION_,
      _POST_EVENT_,
      _PRECISION_,
      _PREPARE_,
      _PROCEDURE_,
      _PROTECTED_,
      _PRIMARY_,
      _PRIVILEGES_,
      _PUBLIC_,
      _QUIT_,
      _RAW_PARTITIONS_,
      _READ_,
      _REAL_,
      _RECORD_VERSION_,
      _REFERENCES_,
      _RELEASE_,
      _RESERV_,
      _RESERVING_,
      _RESTRICT_,
      _RETAIN_,
      _RETURN_,
      _RETURNING_VALUES_,
      _RETURNS_,
      _REVOKE_,
      _RIGHT_,
      _ROLE_,
      _ROLLBACK_,
      _RUNTIME_,
      _SCHEMA_,
      _SECOND_,
      _SEGMENT_,
      _SELECT_,
      _SET_,
      _SHADOW_,
      _SHARED_,
      _SHELL_,
      _SHOW_,
      _SINGULAR_,
      _SIZE_,
      _SMALLINT_,
      _SNAPSHOT_,
      _SOME_,
      _SORT_,
      _SQL_,
      _SQLCODE_,
      _SQLERROR_,
      _SQLWARNING_,
      _STABILITY_,
      _STARTING_,
      _STARTS_,
      _STATEMENT_,
      _STATIC_,
      _STATISTICS_,
      _SUB_TYPE_,
      _SUM_,
      _SUSPEND_,
      _TABLE_,
      _TERM_,
      _TERMINATOR_,
      _THEN_,
      _TIME_,
      _TIMESTAMP_,
      _TO_,
      _TRANSACTION_,
      _TRANSLATE_,
      _TRANSLATION_,
      _TRIGGER_,
      _TRIM_,
      _TYPE_,
      _UNCOMMITTED_,
      _UNION_,
      _UNIQUE_,
      _UPDATE_,
      _UPPER_,
      _USER_,
      _USING_,
      _VALUE_,
      _VALUES_,
      _VARCHAR_,
      _VARIABLE_,
      _VARYING_,
      _VIEW_,
      _WAIT_,
      _WEEKDAY_,
      _WHEN_,
      _WHENEVER_,
      _WHERE_,
      _WHILE_,
      _WITH_,
      _WORK_,
      _WRITE_,
      _YEAR_,
      _YEARDAY_
      );

procedure TSQLLexer.CommentEOF;
begin
  yyErrorfile.Add('unexpected EOF inside comment at line ' + IntToStr(yylineno));
end;

function TSQLLexer.IsTerminator(id : String) : Boolean;
begin
  if AnsiUpperCase(id) = Terminator then
    Result := True
  else
    Result := False;
end;

function TSQLLexer.Upper(str : String) : String;
begin
  Result := AnsiUpperCase(Str);
end;

function TSQLLexer.IsKeyword(ID : String; var Token : Integer) : Boolean;
var
  m : Integer;

begin
  Id := Upper(Id);
  for m := 1 to no_of_keywords do
  begin
    if Id = Keyword[m] then
    begin
      Result := True;
      Token := keyword_token[m];
      Exit;
    end;
  end;
  Result := False
end;

procedure TSQLLexer.SkipComment;
var
  C : Char;

begin
  While True do
  begin
    c := get_char;
    case c of
      '/' : ;
      '*' :
        begin
          c := get_char;
          if c = '/' then
          begin
            Break;
          end
          else
          begin
            if c = #0 then
              Break
            else
              unget_char(c);
          end;
        end;
      #0 :
        begin
          Break;
        end;
    end;
  end;
end;

function TSQLLexer.StripQuotes(str : String) : String;
var
  Idx : Integer;

begin
  if Length(Str) > 0 then
  begin
    if Str[1] in ['''', '"'] then
    begin
      Str := Copy(Str, 2, Length(Str));
    end;
  end;

  if Length(Str) > 0 then
  begin
    if Str[Length(Str)] in ['''', '"'] then
    begin
      Str := Copy(Str, 1, Length(Str) - 1);
    end;
  end;
  Result := Str;
end;


constructor TSQLLexer.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Terminator := ';';
end;

destructor TSQLLexer.Destroy;
begin
  inherited Destroy;
end;

{$I SQLLex.pas}

initialization

end.
