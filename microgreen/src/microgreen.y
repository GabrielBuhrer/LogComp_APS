%define parse.error verbose

%{
  #include <stdio.h>
  #include <stdbool.h>

  int yylex(void);
  void yyerror(const char *s);
  extern int yylineno;

  // arquivo de saída para o código .mwasm (definido em main.c)
  extern FILE *mg_out;
  // contador para gerar labels únicos: L_wait_0, L_aquecer_1, etc.
  static int mg_next_label = 0;
%}

%union {
  int ival;
}

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
      {
        fprintf(mg_out, "; potencia %d\n", $2);
        fprintf(mg_out, "SET POWER %d\n", $2);
      }
  | T_ESPERAR T_DUR
      {
        int id = mg_next_label++;
        fprintf(mg_out, "; esperar %d segundos\n", $2);
        fprintf(mg_out, "SET TIME %d\n", $2);
        fprintf(mg_out, "L_wait_%d:\n", id);
        fprintf(mg_out, "DECJZ TIME L_end_%d\n", id);
        fprintf(mg_out, "GOTO L_wait_%d\n", id);
        fprintf(mg_out, "L_end_%d:\n", id);
      }
  | T_AQUECER T_ATE T_INT
      {
        int id = mg_next_label++;
        fprintf(mg_out, "; aquecer ate %d (modelo simplificado)\n", $3);
        fprintf(mg_out, "SET TIME %d\n", $3);
        fprintf(mg_out, "L_aquecer_%d:\n", id);
        fprintf(mg_out, "DECJZ TIME L_aquecer_fim_%d\n", id);
        fprintf(mg_out, "GOTO L_aquecer_%d\n", id);
        fprintf(mg_out, "L_aquecer_fim_%d:\n", id);
      }
  | T_MANTER T_ACIMA T_DE T_INT T_POR T_DUR
      {
        int id = mg_next_label++;
        fprintf(mg_out, "; manter acima de %d por %d segundos (modelo simplificado)\n", $4, $6);
        fprintf(mg_out, "SET TIME %d\n", $6);
        fprintf(mg_out, "L_manter_%d:\n", id);
        fprintf(mg_out, "DECJZ TIME L_manter_fim_%d\n", id);
        fprintf(mg_out, "GOTO L_manter_%d\n", id);
        fprintf(mg_out, "L_manter_fim_%d:\n", id);
      }
  | T_ALARME T_SE T_TEMPERATURA rel T_INT
      {
        fprintf(mg_out, "; alarme se temperatura ... %d (modelo simplificado; sempre dispara)\n", $5);
        fprintf(mg_out, "PUSH TIME\n");
        fprintf(mg_out, "PRINT\n");
        fprintf(mg_out, "POP TIME\n");
      }
  | T_MOSTRAR T_TEMPERATURA
      {
        // a VM não permite PUSH TEMP; usamos TIME como proxy
        fprintf(mg_out, "; mostrar temperatura (aprox: imprime TIME)\n");
        fprintf(mg_out, "PRINT\n");
      }
  | T_MOSTRAR T_POTENCIA
      {
        fprintf(mg_out, "; mostrar potencia\n");
        fprintf(mg_out, "PUSH TIME\n");
        fprintf(mg_out, "PUSH POWER\n");
        fprintf(mg_out, "POP TIME\n");
        fprintf(mg_out, "PRINT\n");
        fprintf(mg_out, "POP TIME\n");
      }
  | T_BIPE
      {
        fprintf(mg_out, "; bipe\n");
        fprintf(mg_out, "PUSH TIME\n");
        fprintf(mg_out, "PRINT\n");
        fprintf(mg_out, "POP TIME\n");
      }
  | T_PARAR
      {
        fprintf(mg_out, "; parar\n");
        fprintf(mg_out, "HALT\n");
      }
  | T_HALT
      {
        fprintf(mg_out, "; halt\n");
        fprintf(mg_out, "HALT\n");
      }
  | error
      {
        fprintf(stderr, "Erro de sintaxe na linha %d.\n", yylineno);
        yyerrok;
      }
  ;

rel
  : T_MAIOR
  | T_MENOR
  | T_IGUAL
  ;
%%
void yyerror(const char* s) {
  fprintf(stderr, "Erro: %s (linha %d)\n", s, yylineno);
}
