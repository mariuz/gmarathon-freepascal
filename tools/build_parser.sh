#!/bin/sh
# Regenerates src/Source/SQLYacc.pas from src/Source/sqlyacc.y, and
# src/Source/SQLLex.pas from src/Source/sqllex.l.
#
# The output is checked in, so an ordinary build needs neither this script nor
# a yacc - run it after changing the grammar, the way tools/build_icons.sh is
# run after changing an icon.
#
# Two things to know before running it.
#
# The stock pyacc CANNOT build this grammar: TP Yacc's table sizes are
# compile-time constants from an era of much smaller grammars, and this one
# overflows the type table before it starts. A pyacc built with larger limits
# is required - see tools/build_pyacc.sh, which fetches TP Yacc's sources and
# raises them.
#
# And both generated units need patches that neither generator can express:
# yylex is declared by the lexer rather than by the parser, and yylex/yyaction/
# yyparse are *methods* of TSQLLexer and TSQLParser (or TSQLBuildParser) rather
# than free functions, with a local of their own. They are applied below, so the
# generated files are not hand-edited afterwards and the .l/.y stay the source
# of truth.
#
# One trap when editing the grammar: inside a yacc action, a brace closes the
# action and an apostrophe opens a Pascal string that runs to the next one. A
# Pascal { } comment or an English possessive in there silently swallows the
# rest of the rule, and the error yacc reports is somewhere else entirely. Use
# (* *) and no apostrophes.
set -e

HERE=$(cd "$(dirname "$0")/.." && pwd)
SRC="$HERE/src/Source"
PYACC=${PYACC:-pyacc}
PLEX=${PLEX:-plex}

cd "$SRC"

echo "Lexer..."
"$PLEX" sqllex.l
mv sqllex.pas SQLLex.pas.new

echo "Parser..."
"$PYACC" sqlyacc.y
mv sqlyacc.pas SQLYacc.pas.new

echo "Patching the generated lexer..."
python3 - <<'PY'
p = 'SQLLex.pas.new'
s = open(p).read()

BANNER = """{******************************************************************}
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

"""

# 1. yyaction and yylex are methods of TSQLLexer. plex declares yylex up front
#    and never defines a header for it; the method definition belongs where the
#    body starts, just before the DFA table.
old = "function yylex : Integer;\n\nprocedure yyaction ( yyruleno : Integer );"
assert old in s, "lexer preamble not found - has the template changed?"
s = s.replace(old, "procedure TSQLLexer.yyaction ( yyruleno : Integer );", 1)

old = "end(*yyaction*);\n\n(* DFA table: *)"
assert old in s, "lexer DFA table not found - has the template changed?"
s = s.replace(old,
              "end(*yyaction*);\n\nfunction TSQLLexer.yylex : Integer;\n\n"
              "(* DFA table: *)", 1)

open(p, 'w').write(BANNER + s)
print("  patched")
PY

echo "Patching the generated parser..."
python3 - <<'PY'
import re
p = 'SQLYacc.pas.new'
s = open(p).read()

# 1. yylex comes from the lexer unit, not from here.
s = s.replace("function yylex : Integer; forward;",
              "// function yylex : Integer; forward;  // addition 1", 1)

# 2. yyparse is a method, and needs a local for the statement being built.
old = "function yyparse : Integer;"
new = ("{$IFDEF BUILDER}\n"
       "function TSQLBuildParser.yyparse : Integer; // addition 2\n"
       "{$ELSE}\n"
       "function TSQLParser.yyparse : Integer; // addition 2\n"
       "{$ENDIF}")
assert old in s, "yyparse declaration not found - has the template changed?"
s = s.replace(old, new, 1)

# The statement being built is a local of yyparse. Added after the last of the
# generated locals, which is yyval.
old_locals = "    yyval : YYSType;\n"
assert old_locals in s, "yyparse locals not found - has the template changed?"
s = s.replace(old_locals, old_locals + "    S : TStatement;\n", 1)

# 3. and the lexer it reads from is an object, not a unit.
old = "yychar := yylex;"
assert old in s, "yylex call not found - has the template changed?"
s = s.replace(old, "yychar := yyLexer.yylex;", 1)

# 4. Every terminal carries a TStatement of its own, holding the text and the
#    place it was read from - that is what the debugger steps through, and what
#    the actions above assign with $1. The stock template shifts whatever
#    yylval happens to hold, which here is nil, so build one on each shift.
#    Without this the parser segfaults on the first identifier it reads.
old = "  yystate := yyn; yychar := -1; yyval := yylval;"
assert old in s, "shift step not found - has the template changed?"
s = s.replace(old,
              "  yystate := yyn;\n"
              "  yychar := -1;\n"
              "\n"
              "  S := TStatement.Create;  // addition 3\n"
              "  S.Line := yyLexer.yyLineNo;\n"
              "  S.Col := yyLexer.yyColNo;\n"
              "  S.Value := yyLexer.yyText;\n"
              "  FItemList.Add(S);\n"
              "  yylval.yyTStatement := S;\n"
              "\n"
              "  yyval := yylval;", 1)

open(p, 'w').write(s)
print("  patched")
PY

mv SQLLex.pas.new SQLLex.pas
mv SQLYacc.pas.new SQLYacc.pas
echo "Done. Rebuild and run test/debugger_test to see what the parser now accepts."
