%define parse.error verbose

%{
  #include <stdio.h>
  #include <stdbool.h>
  int yylex(void);
  void yyerror(const char *s);
  extern int yylineno;
%}

%union { int ival; }

%token T_POTENCIA T_ESPERAR T_AQUECER T_ATE T_MANTER T_ACIMA T_DE T_POR
%token T_ALARME T_SE T_TEMPERATURA T_MAIOR T_MENOR T_IGUAL
%token T_MOSTRAR T_BIPE T_PARAR T_HALT
%token T_SEMI T_NL T_ERROR
%token <ival> T_INT T_DUR

%start programa

%%
programa
  : linhas opt_ultima
  ;

linhas
  :
  | linhas linha
  ;

linha
  : comando terminador
  ;

opt_ultima
  :
  | comando
  ;

terminador
  : T_SEMI
  | T_NL
  ;

comando
  : T_POTENCIA T_INT
  | T_ESPERAR T_DUR
  | T_AQUECER T_ATE T_INT
  | T_MANTER T_ACIMA T_DE T_INT T_POR T_DUR
  | T_ALARME T_SE T_TEMPERATURA rel T_INT
  | T_MOSTRAR mostrar_what
  | T_BIPE
  | T_PARAR
  | T_HALT
  | error { fprintf(stderr, "Erro de sintaxe na linha %d.\n", yylineno); yyerrok; }
  ;

rel
  : T_MAIOR
  | T_MENOR
  | T_IGUAL
  ;

mostrar_what
  : T_TEMPERATURA
  | T_POTENCIA
  ;
%%
void yyerror(const char* s) {
  fprintf(stderr, "Erro: %s (linha %d)\n", s, yylineno);
}
