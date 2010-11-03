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
// $Id: YaccLib.pas,v 1.3 2005/04/13 16:04:32 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: YaccLib.pas,v $
Revision 1.3  2005/04/13 16:04:32  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}


unit YaccLib;

(* Yacc Library Unit for TP Yacc Version 3.0, 6-17-91 AG *)
(* adapted to Delphi 3, 20/9/97 *)

interface

uses Classes, LexLib;

const yymaxdepth = 2048;
  (* default stack size of parser *)

type
  TYYFlag = ( yyfnone, yyfaccept, yyfabort, yyferror );

  (* default value type, may be redefined in Yacc output file *)
  TCustomParser = Class( TComponent)
    public
      yychar   : Integer; (* current lookahead character *)
      yynerrs  : Integer; (* current number of syntax errors reported by the
                             parser *)
      yydebug  : Boolean; (* set to true to enable debugging output of parser *)

      yyLexer  : TCustomLexer; (* Lexer used to lex input *)

      constructor create(anOwner:TComponent); override;
      destructor destroy; override;

      procedure yyerror ( msg : String );
        (* error message printing routine used by the parser *)

      procedure yyclearin;
        (* delete the current lookahead token *)

      procedure yyaccept;
        (* trigger accept action of the parser; yyparse accepts returning 0, as if
           it reached end of input *)

      procedure yyabort;
        (* like yyaccept, but causes parser to return with value 1, as if an
           unrecoverable syntax error had been encountered *)

      procedure yyerrlab;
        (* causes error recovery to be started, as if a syntax error had been
           encountered *)

      procedure yyerrok;
        (* when in error mode, resets the parser to its normal mode of
           operation *)

      function yyparse : integer; virtual; abstract;

      (* Flags used internally by the parser routine: *)

    protected
      yyerrflag : Integer;
      yyflag    : TYYFlag;
  end; (* TCustomParser *)

implementation

constructor TCustomParser.create(anOwner:TComponent);
begin
  inherited create( anOwner);
  yyLexer := nil;
end;

destructor TCustomParser.destroy;
begin
  // The parser is not responsible for the Lexer's death :
  yyLexer := nil;
  inherited destroy;
end;

procedure TCustomParser.yyerror ( msg : String );
begin
  yyLexer.yyerrorfile.Add(msg);
end(*yyerrmsg*);

procedure TCustomParser.yyclearin;
begin
  yychar := -1;
end(*yyclearin*);

procedure TCustomParser.yyaccept;
begin
  yyflag := yyfaccept;
end(*yyaccept*);

procedure TCustomParser.yyabort;
begin
  yyflag := yyfabort;
end(*yyabort*);

procedure TCustomParser.yyerrlab;
begin
  yyflag := yyferror;
end(*yyerrlab*);

procedure TCustomParser.yyerrok;
begin
  yyerrflag := 0;
end(*yyerrork*);

end(*YaccLib*).


