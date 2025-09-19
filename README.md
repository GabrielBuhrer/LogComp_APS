# LogComp_APS

## EBNF - linguagem BRASIL

PROGRAMA        = { COMANDO } ;

COMANDO         = SIMPLES, ";" | COMPOSTO ;

SIMPLES         = ATRIB | ESCREVA | VAZIO ;

COMPOSTO        = ENQUANTO | SE | BLOCO ;

VAZIO           = ε ;

ATRIB           = IDENT, "-=", EXPR_BOOL ;

ESCREVA         = "escreva", "(", EXPR_BOOL, ")" ;

LEIA            = "leia", "(", ")" ;

ENQUANTO        = "enquanto", "(", EXPR_BOOL, ")", COMANDO ;

SE              = "se", "(", EXPR_BOOL, ")", COMANDO, [ "senao", COMANDO ] ;

BLOCO           = "faca", { COMANDO }, "fim" ;


EXPR_BOOL       = TERMO_BOOL, { "||", TERMO_BOOL } ;

TERMO_BOOL      = REL,        { "&&", REL        } ;

REL             = EXPR, [ ( "=-=" | ">" | "<" ), EXPR ] ;

EXPR            = TERMO, { ( "++" | "--" ), TERMO } ;

TERMO           = FATOR, { ( "**" | "//" ), FATOR } ;

FATOR           = ( "!" | "+" | "-" ), FATOR
                | NUM
                | "(", EXPR_BOOL, ")"
                | IDENT
                | LEIA ;

IDENT           = LETRA, { LETRA | DIGITO | "_" } ;

NUM             = DIGITO, { DIGITO } ;

LETRA           = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M"
               | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
               | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m"
               | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
               
DIGITO          = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

### OBS:

(Palavras-chave: se, senao, enquanto, faca, fim, escreva, leia)
(Operadores/símbolos: "-=" "=-=" "++" "--" "**" "//" "!" "&&" "||" "<" ">" "(" ")" ";")
(Precedência (alta → baixa):
   1) unários: "!" "+" "-"
   2) multiplicação/divisão: "**" "//"
   3) soma/subtração: "++" "--"
   4) relacionais: "=-=" "<" ">"
   5) "&&"
   6) "||"
)

