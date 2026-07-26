program keyword_test;

{ Checks that the Firebird 5/6 keywords Lazarus's SynHighlighterSQL does not
  know about are actually highlighted once FirebirdKeywords.ApplyFirebirdKeywords
  has run - see that unit for why they have to be injected through TableNames.

  Needs no database. It does need the LCL linked (SynEdit's attributes are
  built on Graphics), but not a display: build it with the nogui widgetset,
    lazbuild --ws=nogui test/keyword_test.lpi
  and it runs headlessly, which is how CI runs it.

  The limit of that trick, so nobody spends an afternoon rediscovering it:
  nogui only supports LCL classes that draw nothing. TSynSQLSyn qualifies -
  it is a non-visual component. Forms do not. Under nogui even a bare
  TForm.Create(nil) raises an access violation, as does TDBGrid, so .lfm
  loading and form construction cannot be tested this way; that needs a real
  widgetset and a display (Xvfb, say). }

{$MODE Delphi}

uses
  Interfaces, SysUtils, Classes, SynHighlighterSQL, FirebirdKeywords;

var
  Highlighter: TSynSQLSyn;
  Failures: Integer = 0;

{ The token kind SynHighlighterSQL assigns to Word on a line of its own. }
function KindOf(const Word: String): Integer;
begin
  Result := -1;
  Highlighter.SetLine(Word, 0);
  while not Highlighter.GetEol do
  begin
    if Trim(Highlighter.GetToken) <> '' then
    begin
      Result := Highlighter.GetTokenKind;
      Exit;
    end;
    Highlighter.Next;
  end;
end;

function AttrOf(const Word: String): String;
begin
  Result := '';
  Highlighter.SetLine(Word, 0);
  while not Highlighter.GetEol do
  begin
    if Trim(Highlighter.GetToken) <> '' then
    begin
      Result := Highlighter.GetTokenAttribute.Name;
      Exit;
    end;
    Highlighter.Next;
  end;
end;

procedure Check(Condition: Boolean; const What: String);
begin
  if Condition then
    WriteLn('  ok   ', What)
  else
  begin
    WriteLn('  FAIL ', What);
    Inc(Failures);
  end;
end;

var
  Idx: Integer;
  IdentifierKind: Integer;
  Word: String;

begin
  Highlighter := TSynSQLSyn.Create(nil);
  try
    Highlighter.SQLDialect := sqlFirebird40;

    { Whatever kind a word nobody has ever heard of gets - that is what the
      injected keywords must NOT be. Read it rather than hard-coding the enum
      ordinal, which is SynEdit's business and could be renumbered. }
    IdentifierKind := KindOf('ZZ_NOT_A_KEYWORD_ZZ');
    WriteLn('Identifier token kind = ', IdentifierKind, ' (', AttrOf('ZZ_NOT_A_KEYWORD_ZZ'), ')');

    WriteLn('Before ApplyFirebirdKeywords:');
    for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
    begin
      Word := ExtraFirebirdKeywords[Idx];
      { If one of these ever starts arriving already-highlighted, Lazarus has
        gained an FB5/FB6 keyword set and this unit can start shrinking. }
      Check(KindOf(Word) = IdentifierKind,
        Word + ' is an unhighlighted identifier until injected');
    end;

    ApplyFirebirdKeywords(Highlighter);

    WriteLn('After ApplyFirebirdKeywords:');
    for Idx := Low(ExtraFirebirdKeywords) to High(ExtraFirebirdKeywords) do
    begin
      Word := ExtraFirebirdKeywords[Idx];
      Check(KindOf(Word) <> IdentifierKind,
        Word + ' is highlighted (' + AttrOf(Word) + ')');
    end;

    { Injection must not turn every identifier into a keyword, and must leave
      the words the dialect list already covers alone. }
    Check(KindOf('ZZ_NOT_A_KEYWORD_ZZ') = IdentifierKind,
      'an ordinary identifier is still an identifier');
    Check(AttrOf('SELECT') = 'Reserved word', 'SELECT is still a reserved word');
    Check(AttrOf('SKIP') = 'Reserved word', 'SKIP is still a reserved word');

    { The whole point of copying the styling across: these render the same as
      the reserved words they are, despite riding in on the table-name kind. }
    Check(Highlighter.TableNameAttri.Foreground = Highlighter.KeyAttri.Foreground,
      'injected keywords use the reserved-word foreground');
    Check(Highlighter.TableNameAttri.Style = Highlighter.KeyAttri.Style,
      'injected keywords use the reserved-word style');

    { Calling twice must be harmless - LoadOptions runs on every settings
      reload. }
    ApplyFirebirdKeywords(Highlighter);
    Check(KindOf('LOCKED') <> IdentifierKind, 'still highlighted after a second call');
  finally
    Highlighter.Free;
  end;

  if Failures > 0 then
  begin
    WriteLn('FAIL: ', Failures, ' keyword highlighting check(s) failed.');
    Halt(1);
  end;
  WriteLn('PASS: Firebird 5/6 keyword highlighting works.');
end.
