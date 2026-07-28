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

    WriteLn;
    WriteLn('What Firebird accepts and this parser does not:');
    Gap('LEAVE from a labelled loop (FB1.5)',
      'returns (N integer) as begin N = 0; ' +
      'L1: while (N < 9) do begin N = N + 1; if (N = 2) then leave L1; end suspend; end');
    Gap('EXECUTE PROCEDURE with RETURNING_VALUES',
      'as declare variable V integer; begin execute procedure DBG_HELPER returning_values :V; end');
    Gap('INSERT ... RETURNING ... INTO (FB2)',
      'returns (N integer) as begin ' +
      'insert into DBG_T (ID) values (1) returning ID into :N; suspend; end');
    Gap('MERGE (FB2)',
      'as begin merge into DBG_T d using (select 1 x from rdb$database) s ' +
      'on d.ID = s.x when not matched then insert (ID) values (s.x); end');
    Gap('a window function (FB3)',
      'returns (N integer) as begin ' +
      'select count(*) over () from rdb$database into :N; suspend; end');
    Gap('DECFLOAT (FB4)',
      'returns (N decfloat) as begin N = 1.5; suspend; end');
    Gap('INT128 (FB4)',
      'returns (N int128) as begin N = 1; suspend; end');
    Gap('a sub-procedure (FB3)',
      'returns (N integer) as ' +
      'declare procedure SUB returns (X integer) as begin X = 1; end ' +
      'begin execute procedure SUB returning_values :N; suspend; end');

    WriteLn;
    { A body that is not PSQL at all must be an answer rather than a dialog:
      the compile step used to raise its own MessageDlg, which is a hang
      anywhere without a person to click it. }
    Check(not Compiles('as begin @@@ end'),
      'a body that will not parse fails rather than raising a dialog');
    Check(VM.LastCompileError <> '', 'and says what it objected to');

    WriteLn;
    WriteLn(Known, ' construct(s) understood, ', Gaps, ' gap(s) against Firebird 6.');
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
