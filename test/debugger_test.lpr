{ The PSQL debugger's parser, from the command line.

  IBDebuggerVM interprets PSQL: it parses a procedure with the yacc grammar in
  src/Source/sqlyacc.y and walks it statement by statement. Parsing needs
  neither a database nor a display - a procedure body is text - so this asks
  it what it understands without either, which is what makes it a command-line
  test rather than another window in the GUI harness.

  What it reports is a map: for each construct, whether the parser accepts a
  body using it. Constructs known to work are asserted, so a regression fails
  the run; constructs known to be missing are printed and counted, and do
  *not* fail - closing one of those gaps should turn this test greener rather
  than red.

  The grammar is the InterBase one this program was ported from. Where it
  stands against Firebird 6 is recorded in ROADMAP.md, along with why
  extending it is not a small job: pyacc cannot even regenerate the grammar as
  it stands ("type table overflow"), so a rule cannot be added without first
  rebuilding the generator.

  Run: ./test/debugger_test }
program debugger_test;

{$MODE Delphi}{$H+}

uses
  { First, before anything that might start one: a console program with no
    thread driver dies the moment a thread is created. }
  {$IFDEF UNIX}cthreads,{$ENDIF}
  { The LCL is linked because IBDebuggerVM and the parser pull it in, but no
    window is ever created, so this runs headless - no Xvfb needed. }
  Interfaces,
  SysUtils, Classes, IBDebuggerVM;

var
  Failures: Integer = 0;
  Known: Integer = 0;
  Gaps: Integer = 0;
  VM: TIBDebuggerVM;

procedure Check(Condition: Boolean; const What: String);
begin
  if Condition then
    WriteLn('  ok   ', What)
  else
  begin
    WriteLn('  FAIL ', What);
    Inc(Failures);
  end;
  Flush(Output);
end;

function Compiles(const ABody: String): Boolean;
begin
  Result := VM.Compile('DBG_PROBE', 'create procedure DBG_PROBE ' + ABody);
end;

{ A construct the parser is known to handle. A regression here fails the run. }
procedure Supported(const AWhat, ABody: String);
begin
  Inc(Known);
  Check(Compiles(ABody), AWhat);
  if Failures > 0 then
    { The parser's own complaint is the useful half of a failure. }
    if not Compiles(ABody) then
      WriteLn('       the parser said: ', VM.LastCompileError);
end;

{ A construct that parses but cannot be *compiled* without a database, because
  compiling it reads something out of the catalogue: EXECUTE PROCEDURE and a
  sub-routine call both need the called routine's source. Running the two
  questions together is what made EXECUTE PROCEDURE look like a grammar gap for
  as long as it did - the grammar had it, and the compile step crashed. }
procedure Parses(const AWhat, ABody: String);
begin
  Inc(Known);
  Check(VM.Parses('create procedure DBG_PROBE ' + ABody), AWhat);
end;

{ A construct Firebird accepts and this parser does not. Printed and counted
  rather than asserted: closing the gap must not fail the test. }
procedure Gap(const AWhat, ABody: String);
begin
  if Compiles(ABody) then
  begin
    { Better than expected - worth saying so loudly, since it means the map
      here is out of date. }
    WriteLn('  NEW  ', AWhat, ' now parses - update this list');
    Inc(Known);
  end
  else
  begin
    WriteLn('  gap  ', AWhat);
    Inc(Gaps);
  end;
end;

begin
  WriteLn('PSQL parser, without a database or a display');
  WriteLn;

  VM := TIBDebuggerVM.Create;
  try
    { No connection at all: parsing does not need one, and the VM must not
      insist on one. This is also the guard the editors and tool windows
      needed - a name the project does not hold must not take it down. }
    VM.DatabaseName := '';

    WriteLn('What the parser understands:');
    Supported('a procedure with no arguments',
      'returns (N integer) as begin N = 1; suspend; end');
    Supported('input and output arguments',
      '(A integer, B varchar(10)) returns (N integer) as begin N = A; suspend; end');
    Supported('a declared variable',
      'returns (N integer) as declare variable V integer; ' +
      'begin V = 2; N = V * 2; suspend; end');
    Supported('IF and ELSE',
      'returns (N integer) as begin if (1 = 1) then N = 1; else N = 2; suspend; end');
    Supported('WHILE',
      'returns (N integer) as begin N = 0; while (N < 3) do N = N + 1; suspend; end');
    Supported('nested BEGIN blocks',
      'returns (N integer) as begin begin N = 1; end suspend; end');
    Supported('FOR SELECT ... INTO ... DO',
      'returns (N integer) as begin ' +
      'for select 1 from rdb$database into :N do suspend; end');
    Supported('WHEN ANY DO',
      'returns (N integer) as begin begin N = 1; when any do N = 2; end suspend; end');
    Supported('EXCEPTION by name',
      'as begin exception SOME_EXCEPTION; end');
    Supported('POST_EVENT',
      'as begin post_event ''something''; end');
    Supported('an UPDATE statement',
      'as begin update RDB$DATABASE set RDB$DESCRIPTION = null; end');
    Supported('a DELETE statement',
      'as begin delete from RDB$DATABASE where 1 = 0; end');
    Supported('an INSERT statement',
      'as begin insert into DBG_T (ID) values (1); end');
    Supported('arithmetic and string concatenation',
      'returns (S varchar(20)) as begin S = ''a'' || ''b''; suspend; end');
    Supported('IS NULL and NOT',
      'returns (N integer) as begin if (not (1 is null)) then N = 1; suspend; end');
    Supported('ROW_COUNT',
      'returns (N integer) as begin ' +
      'update RDB$DATABASE set RDB$DESCRIPTION = null; N = row_count; suspend; end');
    Supported('RDB$GET_CONTEXT',
      'returns (N varchar(32)) as begin ' +
      'N = rdb$get_context(''SYSTEM'', ''ENGINE_VERSION''); suspend; end');

    Supported('CASE expression',
      'returns (N integer) as begin N = case when 1 = 1 then 10 else 20 end; suspend; end');
    Supported('a CASE with no ELSE',
      'returns (N integer) as begin N = case when 1 = 1 then 10 end; suspend; end');
    Supported('BOOLEAN variables, TRUE and FALSE (FB3)',
      'returns (N integer) as declare variable B boolean; ' +
      'begin B = true; if (B) then N = 1; suspend; end');
    Supported('a bare boolean beside a comparison',
      'returns (N integer) as declare variable B boolean; ' +
      'begin B = false; if (B and N = 1) then N = 1; suspend; end');
    Supported('EXECUTE STATEMENT (FB1.5)',
      'returns (N integer) as begin ' +
      'execute statement ''select 1 from rdb$database'' into :N; suspend; end');
    Supported('EXECUTE STATEMENT with no INTO',
      'as begin execute statement ''recreate table T (ID integer)''; end');
    Supported('INSERTING / UPDATING / DELETING (trigger context)',
      'returns (N integer) as begin if (inserting) then N = 1; suspend; end');

    Supported('LEAVE out of a loop (FB1.5)',
      'returns (N integer) as begin N = 0; ' +
      'while (N < 9) do begin N = N + 1; if (N = 2) then leave; end suspend; end');
    Supported('LEAVE from a labelled loop (FB1.5)',
      'returns (N integer) as begin N = 0; ' +
      'L1: while (N < 9) do begin N = N + 1; if (N = 2) then leave L1; end suspend; end');
    Supported('a labelled FOR SELECT',
      'returns (N integer) as begin ' +
      'L1: for select 1 from rdb$database into :N do begin leave L1; end suspend; end');
    Supported('INSERT ... RETURNING ... INTO (FB2)',
      'returns (N integer) as begin ' +
      'insert into DBG_T (ID) values (1) returning ID into :N; suspend; end');
    Supported('MERGE (FB2)',
      'as begin merge into DBG_T d using (select 1 x from rdb$database) s ' +
      'on d.ID = s.x when not matched then insert (ID) values (s.x); end');
    Supported('MERGE with a matched branch',
      'as begin merge into DBG_T d using (select 1 x from rdb$database) s ' +
      'on d.ID = s.x when matched then update set d.ID = s.x ' +
      'when not matched then insert (ID) values (s.x); end');
    Supported('a window function (FB3)',
      'returns (N integer) as begin ' +
      'select count(*) over () from rdb$database into :N; suspend; end');
    Supported('a window function with PARTITION BY and ORDER BY',
      'returns (N integer) as begin select count(*) over ' +
      '(partition by RDB$RELATION_ID order by RDB$RELATION_ID) ' +
      'from RDB$RELATIONS into :N; suspend; end');
    Supported('DECFLOAT (FB4)',
      'returns (N decfloat) as begin N = 1.5; suspend; end');
    Supported('DECFLOAT with a precision',
      'returns (N decfloat(34)) as begin N = 1.5; suspend; end');
    Supported('INT128 (FB4)',
      'returns (N int128) as begin N = 1; suspend; end');
    { The token for a decimal literal was declared and then used by no rule at
      all, so this was a syntax error wherever it appeared. }
    Supported('a decimal literal',
      'returns (N double precision) as begin N = 1.5 + 0.25; suspend; end');
    Supported('a cursor: DECLARE / OPEN / FETCH / CLOSE (FB2.5)',
      'returns (N integer) as declare C cursor for ' +
      '(select 1 as X from rdb$database); begin ' +
      'open C; fetch C into :N; close C; suspend; end');
    Supported('IN AUTONOMOUS TRANSACTION (FB2.5)',
      'as begin in autonomous transaction do begin post_event ''x''; end end');
    Supported('UPDATE OR INSERT ... MATCHING (FB2.1)',
      'as begin update or insert into DBG_T (ID) values (1) matching (ID); end');
    Supported('FOR EXECUTE STATEMENT ... INTO ... DO (FB2.5)',
      'returns (N integer) as begin ' +
      'for execute statement ''select 1 from rdb$database'' into :N do suspend; end');
    Supported('EXECUTE STATEMENT WITH AUTONOMOUS TRANSACTION (FB2.5)',
      'as begin execute statement ''select 1 from rdb$database'' ' +
      'with autonomous transaction; end');
    Supported('EXECUTE STATEMENT ON EXTERNAL (FB2.5)',
      'as begin execute statement ''select 1 from rdb$database'' ' +
      'on external ''other.fdb'' as user ''SYSDBA'' password ''x''; end');
    Supported('WHEN SQLSTATE (FB2.5)',
      'as begin post_event ''x''; when sqlstate ''22001'' do begin post_event ''y''; end end');
    Supported('EXCEPTION with a message of its own',
      'as begin exception DBG_E ''boom''; end');
    Supported('EXCEPTION ... USING (FB3)',
      'as begin exception DBG_E ''boom @1'' using (1); end');
    Supported('COALESCE, NULLIF and IIF (FB2)',
      'returns (N integer) as begin ' +
      'N = coalesce(null, nullif(1, 2), iif(1 = 1, 3, 4)); suspend; end');
    Supported('the simple form of CASE',
      'returns (N integer) as begin N = case 1 when 1 then 10 else 20 end; suspend; end');
    Supported('SUBSTRING ... FROM ... FOR',
      'returns (N varchar(8)) as begin N = substring(''abcdef'' from 1 for 4); suspend; end');
    Supported('TRIM, plain and with LEADING/TRAILING',
      'returns (N varchar(8)) as begin ' +
      'N = trim(trailing '' '' from trim(''  ab  '')); suspend; end');
    Supported('a common table expression (FB2.1)',
      'returns (N integer) as begin ' +
      'with C as (select 1 x from rdb$database) select x from C into :N; suspend; end');
    Supported('a recursive CTE',
      'returns (N integer) as begin with recursive C as ' +
      '(select 1 x from rdb$database) select x from C into :N; suspend; end');
    Supported('a variable with a default (FB2)',
      'returns (N integer) as declare variable B integer = 7; begin N = B; suspend; end');
    Supported('a variable with DEFAULT spelled out',
      'returns (N integer) as declare variable B integer default 7; begin N = B; suspend; end');
    Supported('NEXT VALUE FOR (FB2)',
      'returns (N integer) as begin N = next value for DBG_G; suspend; end');
    Supported('IS TRUE / IS NOT FALSE (FB3)',
      'returns (N integer) as declare variable B boolean; begin ' +
      'B = true; if (B is true and B is not false) then N = 1; suspend; end');
    Supported('SIMILAR TO (FB2.5)',
      'returns (N integer) as begin if (''ab'' similar to ''a%'') then N = 1; suspend; end');
    Supported('ROWS (FB1.5)',
      'returns (N integer) as begin select 1 from rdb$database rows 1 into :N; suspend; end');
    Supported('OFFSET / FETCH FIRST ... ROWS ONLY',
      'returns (N integer) as begin ' +
      'select 1 from rdb$database offset 0 rows fetch first 1 rows only into :N; suspend; end');
    Supported('ORDER BY ... NULLS LAST',
      'returns (N integer) as begin ' +
      'select 1 from rdb$database order by 1 nulls last into :N; suspend; end');
    Supported('a named window (FB4)',
      'returns (N integer) as begin select count(*) over W ' +
      'from rdb$database window W as () into :N; suspend; end');
    Supported('MERGE ... RETURNING ... INTO',
      'returns (N integer) as begin merge into DBG_T d ' +
      'using (select 1 x from rdb$database) s ' +
      'on d.ID = s.x when not matched then insert (ID) values (s.x) ' +
      'returning d.ID into :N; suspend; end');
    Supported('CURRENT_TIMESTAMP as a value',
      'returns (N timestamp) as begin N = current_timestamp; suspend; end');
    Supported('LOCALTIMESTAMP (FB4)',
      'returns (N timestamp) as begin N = localtimestamp; suspend; end');
    Supported('WITH TIME ZONE (FB4)',
      'returns (N timestamp with time zone) as begin N = current_timestamp; suspend; end');
    Supported('RETURN out of a sub-function (FB3)',
      'returns (N integer) as ' +
      'declare function F (A integer) returns integer as begin return A; end ' +
      'begin N = 1; suspend; end');
    Supported('TYPE OF COLUMN (FB2.5)',
      'returns (N integer) as declare variable V type of column DBG_T.ID; ' +
      'begin N = 1; suspend; end');
    Supported('TYPE OF a domain (FB2.5)',
      'returns (N integer) as declare variable V type of DBG_D; begin N = 1; suspend; end');
    Supported('a domain used as a type',
      'returns (N integer) as declare variable V DBG_D; begin N = 1; suspend; end');
    Supported('a window frame (FB4)',
      'returns (N integer) as begin select count(*) over ' +
      '(order by 1 rows between unbounded preceding and current row) ' +
      'from rdb$database into :N; suspend; end');
    Supported('POSITION(x IN y)',
      'returns (N integer) as begin N = position(''a'' in ''abc''); suspend; end');
    Supported('UPDATE ... RETURNING ... INTO',
      'returns (N integer) as begin update DBG_T set ID = 1 returning ID into :N; suspend; end');
    Supported('DELETE ... RETURNING ... INTO',
      'returns (N integer) as begin delete from DBG_T returning ID into :N; suspend; end');
    Supported('SELECT ... WITH LOCK (FB1.5)',
      'returns (N integer) as begin select ID from DBG_T with lock into :N; suspend; end');
    Supported('MERGE ... WHEN NOT MATCHED BY SOURCE',
      'as begin merge into DBG_T d using (select 1 x from rdb$database) s ' +
      'on d.ID = s.x when not matched by source then delete; end');
    Supported('a derived table in FROM',
      'returns (N integer) as begin ' +
      'select a.x from (select 1 x from rdb$database) a into :N; suspend; end');
    Supported('LATERAL (FB5)',
      'returns (N integer) as begin select b.y from ' +
      '(select 1 x from rdb$database) a, lateral (select a.x y from rdb$database) b ' +
      'into :N; suspend; end');
    Supported('GROUP BY an ordinal, and HAVING',
      'returns (N integer) as begin select RDB$RELATION_ID from RDB$RELATIONS ' +
      'group by 1 having count(*) > 0 into :N; suspend; end');
    Supported('a condition assigned to a boolean (FB3)',
      'returns (N integer) as declare variable B boolean; begin ' +
      'B = (1 = 1); if (B) then N = 1; suspend; end');
    Supported('a scalar subquery as a value',
      'returns (N integer) as begin N = (select 1 from rdb$database); suspend; end');
    Supported('EXISTS and IN with a subquery',
      'returns (N integer) as begin if (exists(select 1 from rdb$database) ' +
      'and 1 in (select 1 from rdb$database)) then N = 1; suspend; end');
    Supported('a nested CASE',
      'returns (N integer) as begin N = case when 1 = 1 then ' +
      'case when 2 = 2 then 1 else 2 end else 3 end; suspend; end');

    WriteLn;
    WriteLn('What parses but needs a database to compile:');
    Parses('EXECUTE PROCEDURE with RETURNING_VALUES',
      'as declare variable V integer; begin execute procedure DBG_HELPER returning_values :V; end');
    Parses('EXECUTE PROCEDURE with inputs',
      'returns (N integer) as declare variable V integer; begin V = 1; ' +
      'execute procedure DBG_HELPER :V returning_values :N; suspend; end');
    Parses('a sub-procedure (FB3)',
      'returns (N integer) as ' +
      'declare procedure SUB returns (X integer) as begin X = 1; end ' +
      'begin execute procedure SUB returning_values :N; suspend; end');
    Parses('a sub-function (FB3)',
      'returns (N integer) as ' +
      'declare function F (A integer) returns integer as begin return A; end ' +
      'begin N = 1; suspend; end');

    WriteLn;
    WriteLn('What Firebird accepts and this parser does not:');

    WriteLn;
    { A body that is not PSQL at all must be an answer rather than a dialog:
      the compile step used to raise its own MessageDlg, which is a hang
      anywhere without a person to click it. }
    Check(not Compiles('as begin @@@ end'),
      'a body that will not parse fails rather than raising a dialog');
    Check(VM.LastCompileError <> '', 'and says what it objected to');

    WriteLn;
    WriteLn(Known, ' construct(s) understood, ', Gaps,
      ' gap(s) of the ones tracked here.');
    { The gap list being empty says the constructs collected here all parse,
      not that the grammar is Firebird 6 - it is a PSQL grammar, and the DDL
      and DSQL either side of it are another matter. New gaps belong above. }
  finally
    VM.Free;
  end;

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: the PSQL parser understands what it understood before.');
end.
