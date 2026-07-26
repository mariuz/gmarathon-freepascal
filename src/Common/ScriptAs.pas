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

unit ScriptAs;

{$MODE Delphi}

{ SQL generation behind the object tree's "Script As" submenu.

  These take a plain connection/transaction pair rather than the IDE's
  TMarathonCacheConnection so that the unit stays free of any LCL dependency -
  MarathonProjectCache pulls in Controls/ComCtrls/Dialogs, which would make
  every generator here unreachable from a console test. test/ibx_smoke_test.lpr
  runs all of them against a live server for that reason. }

interface

uses SysUtils, Classes, IBDatabase, IBQuery, DDLExtractor, MetaExtractGlobals,
  MarathonProjectCacheTypes;

type
  { What a generator needs to know about the connection it is scripting from. }
  TScriptAsContext = record
    Database: TIBDatabase;
    Transaction: TIBTransaction;
    IsIB6: Boolean;
    Dialect: Integer;
    { Engine major version, or 0 when the caller does not know. Only consulted
      for syntax the older engines reject outright. }
    EngineMajor: Integer;
  end;

function ScriptAsContext(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  AIsIB6: Boolean; ADialect: Integer; AEngineMajor: Integer = 0): TScriptAsContext;

function ScriptAsColumnNames(const Ctx: TScriptAsContext; ObjectName: String): TStringList;
function ScriptAsPrimaryKeyColumns(const Ctx: TScriptAsContext; ObjectName: String): TStringList;
function ScriptAsIsPSQLFunction(const Ctx: TScriptAsContext; ObjectName: String): Boolean;
function ScriptAsSelect(const Ctx: TScriptAsContext; ObjectName: String): String;
function ScriptAsInsert(const Ctx: TScriptAsContext; ObjectName: String): String;
function ScriptAsUpdate(const Ctx: TScriptAsContext; ObjectName: String): String;
function ScriptAsDelete(const Ctx: TScriptAsContext; ObjectName: String): String;
function ScriptAsCreate(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
function ScriptAsDrop(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
function ScriptAsMerge(const Ctx: TScriptAsContext; ObjectName: String): String;
function ScriptAsAlter(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
function ScriptAsExecute(const Ctx: TScriptAsContext; ObjectName: String): String;

{ A routine's call signature, for showing beside it rather than making the user
  open it: 'MYPROC(A INTEGER, B VARCHAR(20)) RETURNS (R INTEGER)'. Works for a
  stored procedure or a PSQL function; returns an empty string for anything
  else, including a legacy external UDF, whose arguments are typed differently
  and are not what this is for. }
function RoutineSignature(const Ctx: TScriptAsContext; ObjectName: String;
  IsFunction: Boolean): String;

implementation

function ScriptAsContext(ADatabase: TIBDatabase; ATransaction: TIBTransaction;
  AIsIB6: Boolean; ADialect: Integer; AEngineMajor: Integer): TScriptAsContext;
begin
  Result.Database := ADatabase;
  Result.Transaction := ATransaction;
  Result.IsIB6 := AIsIB6;
  Result.Dialect := ADialect;
  Result.EngineMajor := AEngineMajor;
end;

{ "Script as ..." helpers: build column-list-driven SELECT/INSERT/UPDATE/DELETE
  templates and CREATE DDL for the object tree's "Script As" submenu. }

{ The generators commit when their metadata query is done, so a caller cannot
  rely on a transaction still being open by the time the next one runs. Rather
  than make that the caller's problem, each entry point opens one if it needs
  to - which is what every other metadata query in this codebase does. }
procedure EnsureActive(const Ctx: TScriptAsContext);
begin
  if Assigned(Ctx.Transaction) and not Ctx.Transaction.Active then
    Ctx.Transaction.StartTransaction;
end;

function ScriptAsColumnNames(const Ctx: TScriptAsContext; ObjectName: String): TStringList;
var
	Q: TIBQuery;
begin
	EnsureActive(Ctx);
	Result := TStringList.Create;
	Q := TIBQuery.Create(nil);
	try
		Q.Database := Ctx.Database;
		Q.Transaction := Ctx.Transaction;
		Q.SQL.Text := 'select rdb$field_name from rdb$relation_fields where rdb$relation_name = ' +
			AnsiQuotedStr(ObjectName, '''') + ' order by rdb$field_position asc';
		Q.Open;
		while not Q.EOF do
		begin
			Result.Add(Trim(Q.FieldByName('rdb$field_name').AsString));
			Q.Next;
		end;
		Q.Close;
		if Assigned(Q.Transaction) and Q.Transaction.Active then
			Q.Transaction.Commit;
	finally
		Q.Free;
	end;
end;

{ Primary key columns of a table, in key order, or an empty list when it has no
  primary key. Used as MERGE's join condition, which is the one place a
  generated statement genuinely needs to know the key rather than leaving a
  TODO - an ON clause that never matches would silently turn every MERGE into
  an INSERT. }
function ScriptAsPrimaryKeyColumns(const Ctx: TScriptAsContext; ObjectName: String): TStringList;
var
	Q: TIBQuery;
begin
	EnsureActive(Ctx);
	Result := TStringList.Create;
	Q := TIBQuery.Create(nil);
	try
		Q.Database := Ctx.Database;
		Q.Transaction := Ctx.Transaction;
		Q.SQL.Text :=
			'select s.rdb$field_name from rdb$relation_constraints c ' +
			'join rdb$index_segments s on s.rdb$index_name = c.rdb$index_name ' +
			'where c.rdb$constraint_type = ''PRIMARY KEY'' and c.rdb$relation_name = ' +
			AnsiQuotedStr(ObjectName, '''') + ' order by s.rdb$field_position asc';
		Q.Open;
		while not Q.EOF do
		begin
			Result.Add(Trim(Q.FieldByName('rdb$field_name').AsString));
			Q.Next;
		end;
		Q.Close;
		if Assigned(Q.Transaction) and Q.Transaction.Active then
			Q.Transaction.Commit;
	finally
		Q.Free;
	end;
end;

{ True when the named RDB$FUNCTIONS entry is a Firebird 3 PSQL function rather
  than a legacy external UDF. The two share the table but have different DROP
  verbs, and RDB$LEGACY_FLAG does not exist before Firebird 3. }
function ScriptAsIsPSQLFunction(const Ctx: TScriptAsContext; ObjectName: String): Boolean;
var
	Q: TIBQuery;
begin
	EnsureActive(Ctx);
	Result := False;
	Q := TIBQuery.Create(nil);
	try
		Q.Database := Ctx.Database;
		Q.Transaction := Ctx.Transaction;
		Q.SQL.Text := 'select * from rdb$functions where rdb$function_name = ' +
			AnsiQuotedStr(ObjectName, '''');
		Q.Open;
		Result := (not Q.EOF) and Assigned(Q.FindField('rdb$legacy_flag')) and
			(not Q.FieldByName('rdb$legacy_flag').IsNull) and
			(Q.FieldByName('rdb$legacy_flag').AsInteger = 0);
		Q.Close;
		if Assigned(Q.Transaction) and Q.Transaction.Active then
			Q.Transaction.Commit;
	finally
		Q.Free;
	end;
end;

function ScriptAsSelect(const Ctx: TScriptAsContext; ObjectName: String): String;
var
	Cols: TStringList;
	Idx: Integer;
	ColList: String;
begin
	EnsureActive(Ctx);
	Cols := ScriptAsColumnNames(Ctx, ObjectName);
	try
		ColList := '';
		for Idx := 0 to Cols.Count - 1 do
		begin
			if Idx > 0 then
				ColList := ColList + ',' + #13#10 + '    ';
			ColList := ColList + MakeQuotedIdent(Cols[Idx], Ctx.IsIB6, Ctx.Dialect);
		end;
	finally
		Cols.Free;
	end;
	Result := 'select first 100' + #13#10 + '    ' + ColList + #13#10 +
		'from ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect) + ';';
end;

function ScriptAsInsert(const Ctx: TScriptAsContext; ObjectName: String): String;
var
	Cols: TStringList;
	Idx: Integer;
	ColList, ValList: String;
begin
	EnsureActive(Ctx);
	Cols := ScriptAsColumnNames(Ctx, ObjectName);
	try
		ColList := '';
		ValList := '';
		for Idx := 0 to Cols.Count - 1 do
		begin
			if Idx > 0 then
			begin
				ColList := ColList + ',' + #13#10 + '    ';
				ValList := ValList + ',' + #13#10 + '    ';
			end;
			ColList := ColList + MakeQuotedIdent(Cols[Idx], Ctx.IsIB6, Ctx.Dialect);
			ValList := ValList + ':' + Cols[Idx];
		end;
	finally
		Cols.Free;
	end;
	Result := 'insert into ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect) + ' (' + #13#10 +
		'    ' + ColList + #13#10 + ')' + #13#10 + 'values (' + #13#10 + '    ' + ValList + #13#10 + ');';
end;

function ScriptAsUpdate(const Ctx: TScriptAsContext; ObjectName: String): String;
var
	Cols: TStringList;
	Idx: Integer;
	SetList: String;
begin
	EnsureActive(Ctx);
	Cols := ScriptAsColumnNames(Ctx, ObjectName);
	try
		SetList := '';
		for Idx := 0 to Cols.Count - 1 do
		begin
			if Idx > 0 then
				SetList := SetList + ',' + #13#10 + '    ';
			SetList := SetList + MakeQuotedIdent(Cols[Idx], Ctx.IsIB6, Ctx.Dialect) + ' = :' + Cols[Idx];
		end;
	finally
		Cols.Free;
	end;
	Result := 'update ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect) + #13#10 +
		'set ' + SetList + #13#10 + 'where /* TODO: add your criteria */ 1 = 0;';
end;

function ScriptAsDelete(const Ctx: TScriptAsContext; ObjectName: String): String;
begin
	Result := 'delete from ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect) + #13#10 +
		'where /* TODO: add your criteria */ 1 = 0;';
end;

function ScriptAsCreate(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
var
	Extractor: TDDLExtractor;
	ObjType: TDDLObjectType;
begin
	EnsureActive(Ctx);
	{ Every object kind the extractor knows, not just the four the object tree
	  offers "Script as > Create" on: SchemaCompare asks for the DDL of domains,
	  generators, exceptions, triggers and functions too, and falling those
	  through to ddlTable would quietly return a table's DDL. }
	case CacheType of
		ctDomain:      ObjType := ddlDomain;
		ctView:        ObjType := ddlView;
		ctSP:          ObjType := ddlStoredProc;
		ctTrigger:     ObjType := ddlTrigger;
		ctGenerator:   ObjType := ddlGenerator;
		ctException:   ObjType := ddlException;
		ctUDF:         ObjType := ddlUDF;
		ctPackage:     ObjType := ddlPackage;
		ctPublication: ObjType := ddlPublication;
	else
		ObjType := ddlTable;
	end;

	Extractor := TDDLExtractor.Create(nil);
	try
		Extractor.Database := Ctx.Database;
		Extractor.Transaction := Ctx.Transaction;
		Extractor.SQLDialect := Ctx.Dialect;
		Extractor.IsInterbase6 := Ctx.IsIB6;
		if CacheType = ctPackage then
			{ Header and body together - recreating a package takes both, and a
			  package may legitimately have a header and no body. }
			Result := Extractor.Extract(ddlPackage, ddlstHeader, ObjectName) + #13#10 +
				Extractor.Extract(ddlPackage, ddlstProc, ObjectName)
		else if CacheType = ctSP then
			{ Also two statements, but for a different reason than a package's.
			  The extractor renders a procedure's body as "alter procedure",
			  because the bulk export it was written for creates every stub
			  first and then fills the bodies in - which is how a procedure that
			  calls another one extracts without a forward reference. On its own
			  that "alter" fails against a database where the procedure does not
			  exist yet, which is exactly what CREATE is asked for. Emitting the
			  header stub ahead of it makes the pair stand alone. }
			Result := Extractor.Extract(ddlStoredProc, ddlstHeader, ObjectName) + #13#10 +
				Extractor.Extract(ddlStoredProc, ddlstProc, ObjectName)
		else
			Result := Extractor.Extract(ObjType, ddlstNone, ObjectName);
	finally
		Extractor.Free;
	end;
end;

function ScriptAsDrop(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
var
	Ident: String;
begin
	Ident := MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect);
	case CacheType of
		ctDomain:
			Result := 'drop domain ' + Ident + ';';
		ctTable:
			Result := 'drop table ' + Ident + ';';
		ctView:
			Result := 'drop view ' + Ident + ';';
		ctSP:
			Result := 'drop procedure ' + Ident + ';';
		ctTrigger:
			Result := 'drop trigger ' + Ident + ';';
		ctGenerator:
			{ "drop generator" rather than the modern "drop sequence" synonym:
			  both work on current Firebird (verified), but only the older form
			  works everywhere back to the InterBase-era servers this codebase
			  still supports, and it matches what ExtractGenerator emits. }
			Result := 'drop generator ' + Ident + ';';
		ctException:
			Result := 'drop exception ' + Ident + ';';
		ctUDF:
			{ A legacy external UDF is declared, not created, and drops with a
			  different verb than a Firebird 3 PSQL function. }
			if ScriptAsIsPSQLFunction(Ctx, ObjectName) then
				Result := 'drop function ' + Ident + ';'
			else
				Result := 'drop external function ' + Ident + ';';
		ctPackage:
			{ One statement is enough: DROP PACKAGE takes the body with it
			  (verified), so naming the body separately only adds a statement
			  that can fail on its own. }
			Result := 'drop package ' + Ident + ';';
	else
		Result := '/* No DROP statement applies to this object. */';
	end;
end;

function ScriptAsMerge(const Ctx: TScriptAsContext; ObjectName: String): String;
var
	Cols: TStringList;
	Keys: TStringList;
	Idx: Integer;
	Target: String;
	OnList, SetList, ColList, ValList: String;
	Col: String;
begin
	EnsureActive(Ctx);
	Target := MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect);
	Cols := ScriptAsColumnNames(Ctx, ObjectName);
	Keys := ScriptAsPrimaryKeyColumns(Ctx, ObjectName);
	try
		OnList := '';
		for Idx := 0 to Keys.Count - 1 do
		begin
			if Idx > 0 then
				OnList := OnList + #13#10 + '    and ';
			Col := MakeQuotedIdent(Keys[Idx], Ctx.IsIB6, Ctx.Dialect);
			OnList := OnList + 't.' + Col + ' = s.' + Col;
		end;
		if OnList = '' then
			{ Without a key there is nothing to match on, and "1 = 0" would not
			  be inert here the way it is in the generated UPDATE/DELETE - every
			  row would fall through to WHEN NOT MATCHED and be inserted. Say so
			  rather than leaving a statement that quietly does the wrong thing. }
			OnList := '/* TODO: this table has no primary key - add your match' + #13#10 +
				'       condition. As written nothing matches, so every source' + #13#10 +
				'       row would be INSERTed. */ 1 = 0';

		SetList := '';
		ColList := '';
		ValList := '';
		for Idx := 0 to Cols.Count - 1 do
		begin
			Col := MakeQuotedIdent(Cols[Idx], Ctx.IsIB6, Ctx.Dialect);
			if ColList <> '' then
			begin
				ColList := ColList + ',' + #13#10 + '    ';
				ValList := ValList + ',' + #13#10 + '    ';
			end;
			ColList := ColList + Col;
			ValList := ValList + 's.' + Col;
			{ The key columns are what the rows were matched on, so updating
			  them would be a no-op at best. }
			if Keys.IndexOf(Cols[Idx]) >= 0 then
				Continue;
			if SetList <> '' then
				SetList := SetList + ',' + #13#10 + '    ';
			SetList := SetList + 't.' + Col + ' = s.' + Col;
		end;

		Result := 'merge into ' + Target + ' as t' + #13#10 +
			'using /* TODO: source table, or a (select ...) */ SOURCE as s' + #13#10 +
			'on (' + OnList + ')' + #13#10;
		if SetList <> '' then
			Result := Result +
				'when matched then' + #13#10 +
				'    update set' + #13#10 + '    ' + SetList + #13#10;
		Result := Result +
			'when not matched then' + #13#10 +
			'    insert (' + #13#10 + '    ' + ColList + ')' + #13#10 +
			'    values (' + #13#10 + '    ' + ValList + ');';
	finally
		Keys.Free;
		Cols.Free;
	end;
end;

function ScriptAsAlter(const Ctx: TScriptAsContext; ObjectName: String; CacheType: TGSSCacheType): String;
var
	Extractor: TDDLExtractor;
	Cols: TStringList;
	Idx: Integer;
	Ident, ColList, FirstCol: String;
begin
	EnsureActive(Ctx);
	Ident := MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect);

	if CacheType = ctTable then
	begin
		{ Firebird has no single ALTER TABLE that restates a whole table, so
		  there is nothing to reverse-engineer - the useful thing to hand over
		  is the current column list plus the forms the user is going to reach
		  for. }
		Cols := ScriptAsColumnNames(Ctx, ObjectName);
		try
			ColList := '';
			for Idx := 0 to Cols.Count - 1 do
			begin
				if Idx > 0 then
					ColList := ColList + ', ';
				ColList := ColList + Trim(Cols[Idx]);
			end;
			if Cols.Count > 0 then
				FirstCol := MakeQuotedIdent(Cols[0], Ctx.IsIB6, Ctx.Dialect)
			else
				FirstCol := '<column>';
		finally
			Cols.Free;
		end;
		Result :=
			'/* ALTER TABLE template for ' + Trim(ObjectName) + '.' + #13#10 +
			'   Firebird has no ALTER statement that restates a whole table, so' + #13#10 +
			'   this is a starting point rather than the table''s current state.' + #13#10 +
			'   Current columns: ' + ColList + ' */' + #13#10 + #13#10 +
			'-- alter table ' + Ident + ' add <column> <type>;' + #13#10 +
			'-- alter table ' + Ident + ' drop ' + FirstCol + ';' + #13#10 +
			'-- alter table ' + Ident + ' alter ' + FirstCol + ' type <type>;' + #13#10 +
			'-- alter table ' + Ident + ' alter ' + FirstCol + ' to <new name>;' + #13#10 +
			'-- alter table ' + Ident + ' alter ' + FirstCol + ' set default <value>;' + #13#10 +
			'-- alter table ' + Ident + ' alter ' + FirstCol + ' drop default;' + #13#10 +
			'-- alter table ' + Ident + ' add constraint <name> primary key (<columns>);' + #13#10 +
			'-- alter table ' + Ident + ' drop constraint <name>;' + #13#10;
		Exit;
	end;

	if (CacheType = ctUDF) and not ScriptAsIsPSQLFunction(Ctx, ObjectName) then
	begin
		{ A legacy external UDF is a declaration, not a definition - there is no
		  ALTER form, it has to be dropped and redeclared. }
		Result := '/* ' + Trim(ObjectName) + ' is an external UDF, which has no ALTER form.' + #13#10 +
			'   Drop and re-declare it instead. */' + #13#10 +
			'-- drop external function ' + Ident + ';' + #13#10;
		Exit;
	end;

	Extractor := TDDLExtractor.Create(nil);
	try
		Extractor.Database := Ctx.Database;
		Extractor.Transaction := Ctx.Transaction;
		Extractor.SQLDialect := Ctx.Dialect;
		Extractor.IsInterbase6 := Ctx.IsIB6;
		case CacheType of
			ctView:
				Result := Extractor.Extract(ddlView, ddlstAlter, ObjectName);
			ctTrigger:
				Result := Extractor.Extract(ddlTrigger, ddlstAlter, ObjectName);
			{ These three already extract in a form that can be re-run against an
			  existing object: a procedure as "alter procedure ... <body>", and a
			  PSQL function and package header as "create or alter". }
			ctSP:
				Result := Extractor.Extract(ddlStoredProc, ddlstNone, ObjectName);
			ctUDF:
				Result := Extractor.Extract(ddlUDF, ddlstNone, ObjectName);
			ctPackage:
				Result := Extractor.Extract(ddlPackage, ddlstHeader, ObjectName) + #13#10 +
					Extractor.Extract(ddlPackage, ddlstProc, ObjectName);
		else
			Result := '/* No ALTER statement applies to this object. */';
		end;
	finally
		Extractor.Free;
	end;
end;

{ Formats one parameter's declared type. Both catalogues type their arguments
  through RDB$FIELD_SOURCE - the domain - rather than carrying the type
  directly, so the domain has to be joined in. }
function SignatureParamList(const Ctx: TScriptAsContext; const SQL: String): String;
var
	Q: TIBQuery;
	TypeName: String;
begin
	Result := '';
	Q := TIBQuery.Create(nil);
	try
		Q.Database := Ctx.Database;
		Q.Transaction := Ctx.Transaction;
		Q.SQL.Text := SQL;
		Q.Open;
		while not Q.EOF do
		begin
			if Result <> '' then
				Result := Result + ', ';
			TypeName := ConvertFieldType(
				Q.FieldByName('rdb$field_type').AsInteger,
				DeclaredFieldLength(Q),
				Q.FieldByName('rdb$field_scale').AsInteger,
				Q.FieldByName('rdb$field_sub_type').AsInteger,
				Q.FieldByName('rdb$field_precision').AsInteger,
				Ctx.IsIB6);
			Result := Result + Trim(Q.FieldByName('param_name').AsString);
			if Trim(TypeName) <> '' then
				Result := Result + ' ' + Trim(TypeName);
			Q.Next;
		end;
		Q.Close;
	finally
		Q.Free;
	end;
end;

function RoutineSignature(const Ctx: TScriptAsContext; ObjectName: String;
  IsFunction: Boolean): String;
var
	Args, Returns: String;
	Name: String;
begin
	Result := '';
	EnsureActive(Ctx);
	Name := AnsiQuotedStr(ObjectName, '''');
	if IsFunction then
	begin
		Args := SignatureParamList(Ctx,
			'select a.rdb$argument_name as param_name, f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, ' +
			'f.rdb$field_scale, f.rdb$field_sub_type, f.rdb$field_precision ' +
			'from rdb$function_arguments a ' +
			'join rdb$fields f on f.rdb$field_name = a.rdb$field_source ' +
			'where a.rdb$function_name = ' + Name +
			' and a.rdb$argument_position > 0 order by a.rdb$argument_position');
		Returns := SignatureParamList(Ctx,
			'select cast(null as varchar(1)) as param_name, f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, ' +
			'f.rdb$field_scale, f.rdb$field_sub_type, f.rdb$field_precision ' +
			'from rdb$function_arguments a ' +
			'join rdb$fields f on f.rdb$field_name = a.rdb$field_source ' +
			'where a.rdb$function_name = ' + Name +
			' and a.rdb$argument_position = 0');
	end
	else
	begin
		Args := SignatureParamList(Ctx,
			'select p.rdb$parameter_name as param_name, f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, ' +
			'f.rdb$field_scale, f.rdb$field_sub_type, f.rdb$field_precision ' +
			'from rdb$procedure_parameters p ' +
			'join rdb$fields f on f.rdb$field_name = p.rdb$field_source ' +
			'where p.rdb$procedure_name = ' + Name +
			' and p.rdb$parameter_type = 0 order by p.rdb$parameter_number');
		Returns := SignatureParamList(Ctx,
			'select p.rdb$parameter_name as param_name, f.rdb$field_type, f.rdb$field_length, f.rdb$character_length, ' +
			'f.rdb$field_scale, f.rdb$field_sub_type, f.rdb$field_precision ' +
			'from rdb$procedure_parameters p ' +
			'join rdb$fields f on f.rdb$field_name = p.rdb$field_source ' +
			'where p.rdb$procedure_name = ' + Name +
			' and p.rdb$parameter_type = 1 order by p.rdb$parameter_number');
	end;

	Result := Trim(ObjectName) + '(' + Args + ')';
	if Returns <> '' then
		Result := Result + ' RETURNS (' + Trim(Returns) + ')';
end;

function ScriptAsExecute(const Ctx: TScriptAsContext; ObjectName: String): String;
var
	Q: TIBQuery;
	InParams: TStringList;
	HasOutput: Boolean;
	Idx: Integer;
	ParamList: String;
begin
	EnsureActive(Ctx);
	InParams := TStringList.Create;
	Q := TIBQuery.Create(nil);
	try
		Q.Database := Ctx.Database;
		Q.Transaction := Ctx.Transaction;

		Q.SQL.Text := 'select rdb$parameter_name from rdb$procedure_parameters where rdb$procedure_name = ' +
			AnsiQuotedStr(ObjectName, '''') + ' and rdb$parameter_type = 0 order by rdb$parameter_number asc';
		Q.Open;
		while not Q.EOF do
		begin
			InParams.Add(Trim(Q.FieldByName('rdb$parameter_name').AsString));
			Q.Next;
		end;
		Q.Close;

		Q.SQL.Text := 'select rdb$parameter_name from rdb$procedure_parameters where rdb$procedure_name = ' +
			AnsiQuotedStr(ObjectName, '''') + ' and rdb$parameter_type = 1';
		Q.Open;
		HasOutput := not Q.EOF;
		Q.Close;

		if Assigned(Q.Transaction) and Q.Transaction.Active then
			Q.Transaction.Commit;

		{ Named arguments where the engine takes them. For a routine with more
		  than a couple of parameters "P(A => :A, B => :B)" says which value
		  goes where, and survives the parameters being reordered later, which
		  a positional call does not. Gated on Firebird 6 because that is the
		  engine this was verified against - an older one rejects the syntax
		  outright, and a script that will not parse is worse than a positional
		  one that does. }
		ParamList := '';
		for Idx := 0 to InParams.Count - 1 do
		begin
			if Idx > 0 then
				ParamList := ParamList + ', ';
			if Ctx.EngineMajor >= 6 then
				ParamList := ParamList +
					MakeQuotedIdent(InParams[Idx], Ctx.IsIB6, Ctx.Dialect) + ' => ';
			ParamList := ParamList + ':' + InParams[Idx];
		end;
	finally
		Q.Free;
		InParams.Free;
	end;

	if HasOutput then
		Result := 'select *' + #13#10 + 'from ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect)
	else
		Result := 'execute procedure ' + MakeQuotedIdent(ObjectName, Ctx.IsIB6, Ctx.Dialect);
	if ParamList <> '' then
		Result := Result + '(' + ParamList + ')';
	Result := Result + ';';
end;

end.
