#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "microgreen.tab.h"

FILE *mg_out = NULL;    // arquivo de saída (.mwasm)

extern FILE *yyin;
int yyparse(void);

int main(int argc, char** argv) {
  const char* out_path = NULL;

  if (argc < 2) {
    fprintf(stderr, "Uso: %s arquivo.mgreen [-o saida.mwasm]\n", argv[0]);
    return 1;
  }

  // lê argumentos: arquivo de entrada + opcional -o
  for (int i = 2; i < argc; ++i) {
    if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
      out_path = argv[++i];
    }
  }

  FILE* in = fopen(argv[1], "r");
  if (!in) {
    perror("erro abrindo arquivo de entrada");
    return 1;
  }
  yyin = in;

  // define saída: arquivo dado em -o ou stdout
  if (out_path) {
    mg_out = fopen(out_path, "w");
    if (!mg_out) {
      perror("erro criando arquivo de saída");
      fclose(in);
      return 1;
    }
  } else {
    mg_out = stdout;
  }

  int rc = yyparse();

  fclose(in);
  if (mg_out && mg_out != stdout) {
    fclose(mg_out);
  }
  mg_out = NULL;

  if (rc == 0) {
    printf("Sintaxe OK \n");
    return 0;
  } else {
    fprintf(stderr, "Falha na análise sintática \n");
    return 2;
  }
}
