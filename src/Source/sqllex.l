%{



%}

NQUOTE     [^']


%%

%{

var
  kw : integer;

%}


"/*"		         begin
                           SkipComment;
                         end;
[0-9]+
			begin
                          yyOutput.Add('LEX:IN: ' + yyText);
                          return(_INTEGER);
                          Statement := Statement + yyText;
                        end;

[0-9]+"."[0-9]*
                        begin
                          yyOutput.Add('LEX:RL: ' + yyText);
                          return(_REAL);
                          Statement := Statement + yyText;
                        end;
"."[0-9]+
                        begin
                          yyOutput.Add('LEX:RL: ' + yyText);
                          return(_REAL);
                          Statement := Statement + yyText;
                        end;

[a-zA-Z_]([a-zA-Z_$0-9])* if IsKeyword(yytext, kw) then
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

''                      begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;

\"\"                    begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          if FIsInterbase6 and (FSQLDialect = 3) then
                            return(ID)
                          else
                            return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;

\"[^"\n]*[\"\n]         begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          if FIsInterbase6 and (FSQLDialect = 3) then
                            return(ID)
                          else
                            return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;

'[^'\n]*['\n]           begin
                          yyOutput.Add('LEX:ST: "' + yyText + '"');
                          return(STRING_CONST);
                          Statement := Statement + yyText;
                        end;
":"			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(COLON);
                          Statement := Statement + yyText;
                        end;
","			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(COMMA);
                          Statement := Statement + yyText;
                        end;
"="			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(EQUAL);
                          Statement := Statement + yyText;
                        end;
">="			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(GE);
                          Statement := Statement + yyText;
                        end;
">"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(GT);
                          Statement := Statement + yyText;
                        end;
"!>"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOTGT);
                          Statement := Statement + yyText;
                        end;
"<="			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(LE);
                          Statement := Statement + yyText;
                        end;
"("			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(LPAREN);
                          Statement := Statement + yyText;
                        end;
"<"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(LT);
                          Statement := Statement + yyText;
                        end;
"!<"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOTLT);
                          Statement := Statement + yyText;
                        end;
"-"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(MINUS);
                          Statement := Statement + yyText;
                        end;
"||"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(CONCAT);
                          Statement := Statement + yyText;
                        end;
"<>"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOT_EQUAL);
                          Statement := Statement + yyText;
                        end;
"!="			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(NOT_EQUAL);
                          Statement := Statement + yyText;
                        end;
"+"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(PLUS);
                          Statement := Statement + yyText;
                        end;
")"			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(RPAREN);
                          Statement := Statement + yyText;
                        end;
"["			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(LSQB);
                          Statement := Statement + yyText;
                        end;
"]"			begin
                          yyOutput.Add('LEX:SM: ' + yyText);
                          return(RSQB);
                          Statement := Statement + yyText;
                        end;
"/"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(SLASH);
                          Statement := Statement + yyText;
                        end;
"*"			begin
                          yyOutput.Add('LEX:OP: ' + yyText);
                          return(STAR);
                          Statement := Statement + yyText;
                        end;
";"                     begin
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
[ \t\r]+	        begin
                          Statement := Statement + yyText;
                        end;
\n                      begin
                          Statement := Statement + yyText;
                        end;

.                       begin
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
