MicroGreen — DSL de Estufa/Aquecimento (alvo: MicrowaveVM)

Uma linguagem simples para operadores não-programadores controlarem uma estufa (ou aquecedor) usando frases diretas.
O compilador cuida de ifs, laços e variáveis internas e gera o assembly .mwasm da MicrowaveVM.

Exemplos de comando:

potencia 80
aquecer ate 60
manter acima de 55 por 120s
alarme se temperatura maior 70
mostrar temperatura
parar

###Visão geral

Foco no usuário: frases em português; uma instrução por linha; sem símbolos estranhos.

Estruturas básicas embutidas: o compilador implementa internamente condicionais e loops para atingir o efeito desejado.

Alvo da compilação: MicrowaveVM — dois registradores (TIME, POWER), sensores (TEMP, WEIGHT) e instruções simples
(SET, INC, DECJZ, GOTO, PRINT, PUSH, POP, HALT).

A linguagem não expõe variáveis nem if/while. Elas existem por baixo (ex.: manter temperatura acima de um alvo por T segundos).
O operador escreve o quê quer; o compilador cuida do como.

Referência de comandos
Controle de potência e tempo

potencia N
Define a potência (0..100). Mapeia para SET POWER N.

esperar Ts
Pausa por T segundos. Mapeia para laço com TIME e DECJZ.

Aquecimento

aquecer ate X
Mantém aquecendo até temperatura atingir pelo menos X.
Por baixo: while TEMP < X → espera passos de tempo (dependendo da potencia).

manter acima de X por Ts
Garante que temperatura >= X por T segundos. Se cair, reforça com a potência atual.
Por baixo: laço de T segundos com verificações de TEMP.

Alarmes, exibição e sinalização

alarme se temperatura REL K
Dispara bipe se a condição for verdadeira neste instante.
Onde REL ∈ {maior, menor, igual}. Exemplos:

alarme se temperatura maior 70
alarme se temperatura menor 10
alarme se temperatura igual 42


mostrar temperatura | mostrar potencia
Exibe o valor atual (usa PRINT sem destruir TIME).

bipe
Sinal sonoro não destrutivo (salva/restaura TIME antes de PRINT).

Encerramento

parar | halt
Finaliza o programa.

Gramática (EBNF)
PROGRAMA    = { LINHA } ;
LINHA       = [ COMANDO ], ( "\n" | ";" ) ;

COMANDO     = AQUECER | MANTER | VEL | ALARME | ESPERAR | MOSTRAR | BIPE | PARAR ;

AQUECER     = "aquecer", "ate", INT ;
MANTER      = "manter", "acima", "de", INT, "por", DUR ;
VEL         = "potencia", INT ;
ALARME      = "alarme", "se", "temperatura", REL, INT ;
REL         = "maior" | "menor" | "igual" ;
ESPERAR     = "esperar", DUR ;
MOSTRAR     = "mostrar", ( "temperatura" | "potencia" ) ;
BIPE        = "bipe" ;
PARAR       = "parar" | "halt" ;

COMENT      = "#", { CAR }, ( "\n" | EOF ) ;

INT         = DIGITO, { DIGITO } ;
DUR         = INT, "s" ;
CAR         = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
           | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
DIGITO      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;


Exemplos

1) Aquecer rápido e parar

potencia 80
aquecer ate 60
parar


2) Manter janela de temperatura

potencia 70
manter acima de 55 por 20s
parar


3) Alarme de pico + exibição

potencia 40
alarme se temperatura maior 70
mostrar temperatura
esperar 10s
parar
