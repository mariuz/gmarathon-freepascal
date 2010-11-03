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
// $Id: SQLLex.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $


(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)






procedure TSQLLexer.yyaction ( yyruleno : Integer );

  (* local definitions: *)


var
  kw : integer;



begin
  (* actions: *)
  case yyruleno of
  1:
    		         begin
                           SkipComment;
                         end;
  2:
      
			begin
                          yyOutput.Add('LEX:IN: ' + yyText);
                          return(_INTEGER);
                          Statement := Statement + yyText;
                        end;

  3:
               
                        begin
                          yyOutput.Add('LEX:RL: ' + yyText);
                          return(_REAL);
                          Statement := Statement + yyText;
                        end;
  4:

                        begin
                          yyOutput.Add('LEX:RL: ' + yyText);
                          return(_REAL);
                          Statement := Statement + yyText;
                        end;

  5:
                          if IsKeyword(yytext, kw) then
                         begin
                           yyOutput.Add('LEX:KW: ' + yyText);
                           return(kw);
                           Statement := Statement + yyText;
                         end
                         else
                         begin
                           if IsTerminator(yyText) then
                           begin
                             yyOutput.Add('LEX:TM: '+ yyText);
                             return(TERM);
                             Statement := Statement + yyText;
                           end
                           else
                           begin
                             yyOutput.Add('LEX:ID: ' + yyText);
                             return(ID);
                             Statement := Statement + yyText;
                           end;
                         end;

  6:
                        begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          return(STRING_CONST);
													Statement := Statement + yyText;
                        end;

  7:
                        begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          if FIsInterbase6 and (FSQLDialect = 3) then
                            return(ID)
                          else
                            return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;

  8:
                        begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          if FIsInterbase6 and (FSQLDialect = 3) then
                            return(ID)
                          else
                            return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;

  9:
                        begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;
  10:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(COLON);
                          Statement := Statement + yyText;
												end;
  11:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(COMMA);
                          Statement := Statement + yyText;
                        end;
  12:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(EQUAL);
                          Statement := Statement + yyText;
                        end;
  13:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(GE);
                          Statement := Statement + yyText;
                        end;
  14:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(GT);
                          Statement := Statement + yyText;
                        end;
  15:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOTGT);
                          Statement := Statement + yyText;
                        end;
  16:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
													return(LE);
                          Statement := Statement + yyText;
                        end;
  17:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(LPAREN);
                          Statement := Statement + yyText;
                        end;
  18:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(LT);
                          Statement := Statement + yyText;
                        end;
  19:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOTLT);
                          Statement := Statement + yyText;
                        end;
  20:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(MINUS);
                          Statement := Statement + yyText;
                        end;
  21:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(CONCAT);
                          Statement := Statement + yyText;
                        end;
  22:
					begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOT_EQUAL);
                          Statement := Statement + yyText;
                        end;
  23:
    			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOT_EQUAL);
                          Statement := Statement + yyText;
                        end;
  24:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(PLUS);
                          Statement := Statement + yyText;
                        end;
  25:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(RPAREN);
                          Statement := Statement + yyText;
                        end;
  26:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(LSQB);
                          Statement := Statement + yyText;
                        end;
  27:
   			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(RSQB);
                          Statement := Statement + yyText;
												end;
  28:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(SLASH);
                          Statement := Statement + yyText;
                        end;
  29:
   			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(STAR);
                          Statement := Statement + yyText;
                        end;
  30:
                        begin
                          if IsTerminator(yyText) then
                          begin
                            yyOutput.Add('LEX:TM: '+ yyText);
                            return(TERM);
                            Statement := Statement + yyText;
                          end
                          else
                          begin
                            yyOutput.Add('LEX:SC: ' + yyText);
                            return(SEMICOLON);
                            Statement := Statement + yyText;
                          end;
                        end;
  31:
        	        begin
                          Statement := Statement + yyText;
                        end;
  32:
                        begin
                          Statement := Statement + yyText;
                        end;

  33:
                        begin
                          if IsTerminator(yyText) then
                          begin
                            yyOutput.Add('LEX:TM: '+ yyText);
                            return(TERM);
                            Statement := Statement + yyText;
                          end
                          else
                          begin
                            if yyText = '.' then
                            begin
                              yyOutput.Add('LEX:SM: ' + yyText);
                              return(DOT);
                              Statement := Statement + yyText;
                            end
                            else
                            begin
                              yyOutput.Add('LEX:ID: ' + yyText);
                              return(ID);
                              Statement := Statement + yyText;
                            end;
                          end;
                        end;
  end;
end(*yyaction*);

function TSQLLexer.yylex : Integer;

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 60;
yynmatches = 60;
yyntrans   = 77;
yynstates  = 45;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  28,
  33,
  { 3: }
  2,
  33,
  { 4: }
  33,
  { 5: }
  5,
  33,
  { 6: }
  33,
  { 7: }
  33,
  { 8: }
  10,
  33,
  { 9: }
  11,
  33,
  { 10: }
  12,
  33,
  { 11: }
  14,
  33,
  { 12: }
  33,
  { 13: }
  18,
  33,
  { 14: }
  17,
  33,
  { 15: }
  20,
  33,
  { 16: }
  33,
  { 17: }
  24,
  33,
  { 18: }
  25,
  33,
  { 19: }
  26,
  33,
  { 20: }
  27,
  33,
  { 21: }
  29,
  33,
  { 22: }
  30,
  33,
  { 23: }
  31,
  33,
  { 24: }
  32,
  { 25: }
  33,
  { 26: }
  1,
  { 27: }
  2,
  { 28: }
  3,
  { 29: }
  4,
  { 30: }
  5,
  { 31: }
  6,
  9,
  { 32: }
  { 33: }
  9,
  { 34: }
  7,
  8,
  { 35: }
  { 36: }
  8,
  { 37: }
  13,
  { 38: }
  15,
  { 39: }
  19,
  { 40: }
  23,
  { 41: }
  16,
  { 42: }
  22,
  { 43: }
  21,
  { 44: }
  31
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  28,
  33,
{ 3: }
  2,
  33,
{ 4: }
  33,
{ 5: }
  5,
  33,
{ 6: }
  33,
{ 7: }
  33,
{ 8: }
  10,
  33,
{ 9: }
  11,
  33,
{ 10: }
  12,
  33,
{ 11: }
  14,
  33,
{ 12: }
  33,
{ 13: }
  18,
  33,
{ 14: }
  17,
  33,
{ 15: }
  20,
  33,
{ 16: }
  33,
{ 17: }
  24,
  33,
{ 18: }
  25,
  33,
{ 19: }
  26,
  33,
{ 20: }
  27,
  33,
{ 21: }
  29,
  33,
{ 22: }
  30,
  33,
{ 23: }
  31,
  33,
{ 24: }
  32,
{ 25: }
  33,
{ 26: }
  1,
{ 27: }
  2,
{ 28: }
  3,
{ 29: }
  4,
{ 30: }
  5,
{ 31: }
  6,
  9,
{ 32: }
{ 33: }
  9,
{ 34: }
  7,
  8,
{ 35: }
{ 36: }
  8,
{ 37: }
  13,
{ 38: }
  15,
{ 39: }
  19,
{ 40: }
  23,
{ 41: }
  16,
{ 42: }
  22,
{ 43: }
  21,
{ 44: }
  31
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'#'..'&','?','@',
            '\','^','`','{','}'..#255 ]; s: 25),
  ( cc: [ #9,#13,' ' ]; s: 23),
  ( cc: [ #10 ]; s: 24),
  ( cc: [ '!' ]; s: 12),
  ( cc: [ '"' ]; s: 7),
  ( cc: [ '''' ]; s: 6),
  ( cc: [ '(' ]; s: 14),
  ( cc: [ ')' ]; s: 18),
  ( cc: [ '*' ]; s: 21),
  ( cc: [ '+' ]; s: 17),
  ( cc: [ ',' ]; s: 9),
  ( cc: [ '-' ]; s: 15),
  ( cc: [ '.' ]; s: 4),
  ( cc: [ '/' ]; s: 2),
  ( cc: [ '0'..'9' ]; s: 3),
  ( cc: [ ':' ]; s: 8),
  ( cc: [ ';' ]; s: 22),
  ( cc: [ '<' ]; s: 13),
  ( cc: [ '=' ]; s: 10),
  ( cc: [ '>' ]; s: 11),
  ( cc: [ 'A'..'Z','_','a'..'z' ]; s: 5),
  ( cc: [ '[' ]; s: 19),
  ( cc: [ ']' ]; s: 20),
  ( cc: [ '|' ]; s: 16),
{ 1: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'#'..'&','?','@',
            '\','^','`','{','}'..#255 ]; s: 25),
  ( cc: [ #9,#13,' ' ]; s: 23),
  ( cc: [ #10 ]; s: 24),
  ( cc: [ '!' ]; s: 12),
  ( cc: [ '"' ]; s: 7),
  ( cc: [ '''' ]; s: 6),
  ( cc: [ '(' ]; s: 14),
  ( cc: [ ')' ]; s: 18),
  ( cc: [ '*' ]; s: 21),
  ( cc: [ '+' ]; s: 17),
  ( cc: [ ',' ]; s: 9),
  ( cc: [ '-' ]; s: 15),
  ( cc: [ '.' ]; s: 4),
  ( cc: [ '/' ]; s: 2),
  ( cc: [ '0'..'9' ]; s: 3),
  ( cc: [ ':' ]; s: 8),
  ( cc: [ ';' ]; s: 22),
  ( cc: [ '<' ]; s: 13),
  ( cc: [ '=' ]; s: 10),
  ( cc: [ '>' ]; s: 11),
  ( cc: [ 'A'..'Z','_','a'..'z' ]; s: 5),
  ( cc: [ '[' ]; s: 19),
  ( cc: [ ']' ]; s: 20),
  ( cc: [ '|' ]; s: 16),
{ 2: }
  ( cc: [ '*' ]; s: 26),
{ 3: }
  ( cc: [ '.' ]; s: 28),
  ( cc: [ '0'..'9' ]; s: 27),
{ 4: }
  ( cc: [ '0'..'9' ]; s: 29),
{ 5: }
  ( cc: [ '$','0'..'9','A'..'Z','_','a'..'z' ]; s: 30),
{ 6: }
  ( cc: [ #1..#9,#11..'&','('..#255 ]; s: 32),
  ( cc: [ #10 ]; s: 33),
  ( cc: [ '''' ]; s: 31),
{ 7: }
  ( cc: [ #1..#9,#11..'!','#'..#255 ]; s: 35),
  ( cc: [ #10 ]; s: 36),
  ( cc: [ '"' ]; s: 34),
{ 8: }
{ 9: }
{ 10: }
{ 11: }
  ( cc: [ '=' ]; s: 37),
{ 12: }
  ( cc: [ '<' ]; s: 39),
  ( cc: [ '=' ]; s: 40),
  ( cc: [ '>' ]; s: 38),
{ 13: }
  ( cc: [ '=' ]; s: 41),
  ( cc: [ '>' ]; s: 42),
{ 14: }
{ 15: }
{ 16: }
  ( cc: [ '|' ]; s: 43),
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
{ 22: }
{ 23: }
  ( cc: [ #9,#13,' ' ]; s: 44),
{ 24: }
{ 25: }
{ 26: }
{ 27: }
  ( cc: [ '.' ]; s: 28),
  ( cc: [ '0'..'9' ]; s: 27),
{ 28: }
  ( cc: [ '0'..'9' ]; s: 28),
{ 29: }
  ( cc: [ '0'..'9' ]; s: 29),
{ 30: }
  ( cc: [ '$','0'..'9','A'..'Z','_','a'..'z' ]; s: 30),
{ 31: }
{ 32: }
  ( cc: [ #1..#9,#11..'&','('..#255 ]; s: 32),
  ( cc: [ #10,'''' ]; s: 33),
{ 33: }
{ 34: }
{ 35: }
  ( cc: [ #1..#9,#11..'!','#'..#255 ]; s: 35),
  ( cc: [ #10,'"' ]; s: 36),
{ 36: }
{ 37: }
{ 38: }
{ 39: }
{ 40: }
{ 41: }
{ 42: }
{ 43: }
{ 44: }
  ( cc: [ #9,#13,' ' ]; s: 44)
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 6,
{ 6: } 8,
{ 7: } 9,
{ 8: } 10,
{ 9: } 12,
{ 10: } 14,
{ 11: } 16,
{ 12: } 18,
{ 13: } 19,
{ 14: } 21,
{ 15: } 23,
{ 16: } 25,
{ 17: } 26,
{ 18: } 28,
{ 19: } 30,
{ 20: } 32,
{ 21: } 34,
{ 22: } 36,
{ 23: } 38,
{ 24: } 40,
{ 25: } 41,
{ 26: } 42,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 47,
{ 32: } 49,
{ 33: } 49,
{ 34: } 50,
{ 35: } 52,
{ 36: } 52,
{ 37: } 53,
{ 38: } 54,
{ 39: } 55,
{ 40: } 56,
{ 41: } 57,
{ 42: } 58,
{ 43: } 59,
{ 44: } 60
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 5,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 11,
{ 9: } 13,
{ 10: } 15,
{ 11: } 17,
{ 12: } 18,
{ 13: } 20,
{ 14: } 22,
{ 15: } 24,
{ 16: } 25,
{ 17: } 27,
{ 18: } 29,
{ 19: } 31,
{ 20: } 33,
{ 21: } 35,
{ 22: } 37,
{ 23: } 39,
{ 24: } 40,
{ 25: } 41,
{ 26: } 42,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 48,
{ 32: } 48,
{ 33: } 49,
{ 34: } 51,
{ 35: } 51,
{ 36: } 52,
{ 37: } 53,
{ 38: } 54,
{ 39: } 55,
{ 40: } 56,
{ 41: } 57,
{ 42: } 58,
{ 43: } 59,
{ 44: } 60
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 6,
{ 6: } 8,
{ 7: } 9,
{ 8: } 10,
{ 9: } 12,
{ 10: } 14,
{ 11: } 16,
{ 12: } 18,
{ 13: } 19,
{ 14: } 21,
{ 15: } 23,
{ 16: } 25,
{ 17: } 26,
{ 18: } 28,
{ 19: } 30,
{ 20: } 32,
{ 21: } 34,
{ 22: } 36,
{ 23: } 38,
{ 24: } 40,
{ 25: } 41,
{ 26: } 42,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 47,
{ 32: } 49,
{ 33: } 49,
{ 34: } 50,
{ 35: } 52,
{ 36: } 52,
{ 37: } 53,
{ 38: } 54,
{ 39: } 55,
{ 40: } 56,
{ 41: } 57,
{ 42: } 58,
{ 43: } 59,
{ 44: } 60
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 5,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 11,
{ 9: } 13,
{ 10: } 15,
{ 11: } 17,
{ 12: } 18,
{ 13: } 20,
{ 14: } 22,
{ 15: } 24,
{ 16: } 25,
{ 17: } 27,
{ 18: } 29,
{ 19: } 31,
{ 20: } 33,
{ 21: } 35,
{ 22: } 37,
{ 23: } 39,
{ 24: } 40,
{ 25: } 41,
{ 26: } 42,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 48,
{ 32: } 48,
{ 33: } 49,
{ 34: } 51,
{ 35: } 51,
{ 36: } 52,
{ 37: } 53,
{ 38: } 54,
{ 39: } 55,
{ 40: } 56,
{ 41: } 57,
{ 42: } 58,
{ 43: } 59,
{ 44: } 60
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 25,
{ 2: } 49,
{ 3: } 50,
{ 4: } 52,
{ 5: } 53,
{ 6: } 54,
{ 7: } 57,
{ 8: } 60,
{ 9: } 60,
{ 10: } 60,
{ 11: } 60,
{ 12: } 61,
{ 13: } 64,
{ 14: } 66,
{ 15: } 66,
{ 16: } 66,
{ 17: } 67,
{ 18: } 67,
{ 19: } 67,
{ 20: } 67,
{ 21: } 67,
{ 22: } 67,
{ 23: } 67,
{ 24: } 68,
{ 25: } 68,
{ 26: } 68,
{ 27: } 68,
{ 28: } 70,
{ 29: } 71,
{ 30: } 72,
{ 31: } 73,
{ 32: } 73,
{ 33: } 75,
{ 34: } 75,
{ 35: } 75,
{ 36: } 77,
{ 37: } 77,
{ 38: } 77,
{ 39: } 77,
{ 40: } 77,
{ 41: } 77,
{ 42: } 77,
{ 43: } 77,
{ 44: } 77
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 24,
{ 1: } 48,
{ 2: } 49,
{ 3: } 51,
{ 4: } 52,
{ 5: } 53,
{ 6: } 56,
{ 7: } 59,
{ 8: } 59,
{ 9: } 59,
{ 10: } 59,
{ 11: } 60,
{ 12: } 63,
{ 13: } 65,
{ 14: } 65,
{ 15: } 65,
{ 16: } 66,
{ 17: } 66,
{ 18: } 66,
{ 19: } 66,
{ 20: } 66,
{ 21: } 66,
{ 22: } 66,
{ 23: } 67,
{ 24: } 67,
{ 25: } 67,
{ 26: } 67,
{ 27: } 69,
{ 28: } 70,
{ 29: } 71,
{ 30: } 72,
{ 31: } 72,
{ 32: } 74,
{ 33: } 74,
{ 34: } 74,
{ 35: } 76,
{ 36: } 76,
{ 37: } 76,
{ 38: } 76,
{ 39: } 76,
{ 40: } 76,
{ 41: } 76,
{ 42: } 76,
{ 43: } 76,
{ 44: } 77
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  yylex := yyretval;

end(*yylex*);

{
$Log: SQLLex.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
