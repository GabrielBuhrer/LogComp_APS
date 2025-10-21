%option noyywrap
%option yylineno
%option noinput
%option nounput
%{
  #include "microgreen.tab.h"
  #include <stdlib.h>
  #include <stdio.h>
%}

DIGIT      [0-9]+
WS         [ \t\r]+

%%
"potencia"          { return T_POTENCIA; }
"esperar"           { return T_ESPERAR; }
"aquecer"           { return T_AQUECER; }
"ate"               { return T_ATE; }
"manter"            { return T_MANTER; }
"acima"             { return T_ACIMA; }
"de"                { return T_DE; }
"por"               { return T_POR; }
"alarme"            { return T_ALARME; }
"se"                { return T_SE; }
"temperatura"       { return T_TEMPERATURA; }
"maior"             { return T_MAIOR; }
"menor"             { return T_MENOR; }
"igual"             { return T_IGUAL; }
"mostrar"           { return T_MOSTRAR; }
"bipe"              { return T_BIPE; }
"parar"             { return T_PARAR; }
"halt"              { return T_HALT; }

{DIGIT}"s"          { yylval.ival = atoi(yytext); return T_DUR; }
{DIGIT}             { yylval.ival = atoi(yytext); return T_INT; }

";"                 { return T_SEMI; }
"\n"                { return T_NL; }
"#"[^\n]*           { }
{WS}                { }
.                   { fprintf(stderr, "Erro léxico na linha %d: '%s'\n", yylineno, yytext); return T_ERROR; }
%%
