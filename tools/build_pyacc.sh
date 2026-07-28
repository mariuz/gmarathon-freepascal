#!/bin/sh
# Builds a pyacc that can actually generate this project's parser.
#
# The pyacc that ships with FPC cannot: TP Yacc's table sizes are compile-time
# constants sized for 1990s grammars, and src/Source/sqlyacc.y overflows the
# type table before generation begins ("FATAL: type table overflow"). This
# fetches TP Yacc's sources, raises the limits, and builds the tool.
#
# Writes ./pyacc into the directory it is run from. Point tools/build_parser.sh
# at it with PYACC=/path/to/pyacc.
set -e

WORK=${1:-./tply-build}
mkdir -p "$WORK"
cd "$WORK"

BASE=https://raw.githubusercontent.com/fpc/FPCSource/main/utils/tply
for f in lexbase.pas lexdfa.pas lexlist.pas lexmsgs.pas lexopt.pas lexpos.pas \
         lexrules.pas lextable.pas plex.pas pyacc.pas yaccbase.pas yaccclos.pas \
         yacclook.pas yacclr0.pas yaccmsgs.pas yaccpars.pas yaccsem.pas \
         yacctabl.pas yylex.cod yyparse.cod; do
  [ -f "$f" ] || curl -sfO "$BASE/$f"
done

python3 - <<'PY'
p = 'yacctabl.pas'
s = open(p).read()
if 'max_nts            = 4000' in s:
    print('  limits already raised'); raise SystemExit
s = s.replace("""max_nts            =  900;  (* maximum number of nonterminals              *)
max_lits           =  max_nts+256;  (* number of literals (300+256)                *)
max_rules          =  max_nts+1;  (* number of rules (300+1)                     *)
max_types          =  100;  (* number of type tags                         *)
max_prec           =   50;  (* maximum precedence level                    *)""",
"""max_nts            = 4000;  (* maximum number of nonterminals              *)
max_lits           =  max_nts+256;  (* number of literals (300+256)                *)
max_rules          =  max_nts+1;  (* number of rules (300+1)                     *)
max_types          = 2000;  (* number of type tags                         *)
max_prec           =  200;  (* maximum precedence level                    *)""", 1)
s = s.replace("max_states         = 3000;", "max_states         = 12000;")
s = s.replace("max_items          = 40000;", "max_items          = 200000;", 1)
s = s.replace("max_trans          = 40000;", "max_trans          = 200000;", 1)
s = s.replace("max_redns          =  9600;", "max_redns          = 60000;", 1)
open(p, 'w').write(s)
print('  limits raised')
PY

fpc -Mobjfpc -O2 pyacc.pas >/dev/null
fpc -Mobjfpc -O2 plex.pas >/dev/null
echo "Built $(pwd)/pyacc and $(pwd)/plex"
