# MicroGreen — DSL de Estufa/Aquecimento (alvo: MicrowaveVM)

Uma linguagem simples para operadores **não-programadores** controlarem uma estufa (ou aquecedor) usando frases diretas em português.  
O compilador (implementado com **Flex/Bison + C**) cuida de *ifs*, laços e variáveis internas e gera o assembly **`.mwasm`** da **MicrowaveVM**.

Exemplo de comandos:

```text
potencia 80
aquecer ate 60
manter acima de 55 por 120s
alarme se temperatura maior 70
mostrar temperatura
parar
```

---

## Visão geral

- **Foco no usuário**: frases em português; **uma instrução por linha**; sem símbolos estranhos.
- **Estruturas básicas embutidas**: o compilador implementa internamente **condicionais** e **loops** sobre registradores e pilha da VM.
- **Alvo da compilação**: [MicrowaveVM] — VM de micro-ondas com:
  - registradores: `TIME`, `POWER`;
  - sensores somente leitura: `TEMP`, `WEIGHT`;
  - instruções: `SET`, `INC`, `DECJZ`, `GOTO`, `PRINT`, `PUSH`, `POP`, `HALT`.

A linguagem não expõe variáveis nem `if/while`. Elas existem “por baixo” (ex.: manter temperatura acima de um alvo por T segundos).  
O operador escreve **o quê** quer; o compilador cuida do **como** no assembly da VM.

---

## Referência de comandos

### Controle de potência e tempo

- `potencia N`  
  Define a potência (0..100).  
  **Gera** algo como:
  ```asm
  ; potencia N
  SET POWER N
  ```

- `esperar Ts`  
  Pausa por `T` segundos.  
  **Gera** um laço em torno de `TIME`:
  ```asm
  ; esperar T segundos
  SET TIME T
  L_wait_X:
    DECJZ TIME L_end_X
    GOTO L_wait_X
  L_end_X:
  ```

### Aquecimento

> **Obs.:** A semântica alvo é em termos de **temperatura**, mas a implementação atual é um **modelo simplificado** em cima de `TIME` (a VM não simula física real).

- `aquecer ate X`  
  Intenção: manter aquecendo **até** a temperatura atingir **pelo menos X**.  
  Implementação atual: espera `X` unidades de tempo (modelo simplificado).

- `manter acima de X por Ts`  
  Intenção: garantir que `temperatura >= X` por `T` segundos, reforçando potência se cair.  
  Implementação atual: espera `T` segundos em loop, usando `TIME` (sem checagem real de `TEMP`).

### Alarmes, exibição e sinalização

- `alarme se temperatura REL K`  
  Intenção: disparar um bipe se a condição de temperatura for verdadeira no instante atual.  
  Onde `REL ∈ {maior, menor, igual}`:
  ```text
  alarme se temperatura maior 70
  alarme se temperatura menor 10
  alarme se temperatura igual 42
  ```
  Implementação atual: modelo simplificado — sempre dispara um `PRINT` (beep lógico), sem checar `TEMP`.

- `mostrar temperatura`  
  Exibe uma aproximação da temperatura.  
  Implementação atual: imprime `TIME` (proxy da temperatura, já que a VM não permite `PUSH TEMP`).

- `mostrar potencia`  
  Exibe o valor atual de `POWER` sem destruir `TIME`:
  ```asm
  ; mostrar potencia
  PUSH TIME
  PUSH POWER
  POP TIME
  PRINT
  POP TIME
  ```

- `bipe`  
  Sinal sonoro lógico (usa `PRINT`) sem perder o valor de `TIME`:
  ```asm
  ; bipe
  PUSH TIME
  PRINT
  POP TIME
  ```

### Encerramento

- `parar` | `halt`  
  Finaliza o programa:
  ```asm
  HALT
  ```

---

## Gramática (EBNF)

```ebnf
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
CAR         = "A" | "B" | ... | "Z"
           | "a" | "b" | ... | "z" ;
DIGITO      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```

---

## Exemplos de programas MicroGreen

### 1) Aquecer rápido e parar

```text
potencia 80
aquecer ate 60
parar
```

### 2) Manter janela de temperatura

```text
potencia 70
manter acima de 55 por 20s
parar
```

### 3) Alarme de pico + exibição

```text
potencia 40
alarme se temperatura maior 70
mostrar temperatura
esperar 10s
parar
```

---

## Requisitos

- Linux (ou WSL)
- `flex`, `bison`, `gcc`, `make`
- Python 3 (para rodar a MicrowaveVM)

Instalação (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install -y flex bison gcc make python3
```

---

## Como compilar o compilador MicroGreen

No diretório do projeto:

```bash
make clean && make
```

Isso gera o binário `./microgreen` e os artefatos do Bison/Flex em `src/`.

---

## Compilação e execução na MicrowaveVM

Assumindo a estrutura:

```text
LogComp_APS/
  microgreen/     # este projeto
  MicrowaveVM/    # repositório da VM
```

### 1. Gerar `.mwasm` a partir de programas MicroGreen

No diretório `microgreen`:

```bash
./microgreen examples/01-aquecer.mgreen -o 01-aquecer.mwasm
./microgreen examples/02-manter.mgreen  -o 02-manter.mwasm
./microgreen examples/03-alarme.mgreen  -o 03-alarme.mwasm
```

### 2. Executar na VM (MicrowaveVM)

No diretório `MicrowaveVM`:

```bash
cd ../MicrowaveVM

python3 main.py ../microgreen/01-aquecer.mwasm
python3 main.py ../microgreen/02-manter.mwasm
python3 main.py ../microgreen/03-alarme.mwasm
```

Saída típica (para `03-alarme`):

```text
Loaded program from: ../microgreen/03-alarme.mwasm
TIME: 0
TIME: 0
BEEEEEEP!
Final state: {'TIME': 0, 'POWER': 40}
Final readonly state: {'TEMP': 72, 'WEIGHT': 100}
Final stack: []
```

---

## Testes negativos (erros esperados)

Alguns exemplos de erro de léxico/sintaxe:

```bash
# 1) Sintaxe inválida (faltou o 's' em duração)
printf "esperar 10
" > examples/erro_sintaxe.mgreen
./microgreen examples/erro_sintaxe.mgreen ; echo $?

# 2) Léxico inválido (unidade desconhecida)
printf "esperar 10m
" > examples/erro_lexico.mgreen
./microgreen examples/erro_lexico.mgreen ; echo $?

# 3) Léxico inválido (palavra-chave com typo)
printf "mostar temperatura
" > examples/erro_lexico2.mgreen
./microgreen examples/erro_lexico2.mgreen ; echo $?
```

Saída típica: mensagens de erro e **exit code `2`**.

---

## Estrutura do repositório

```text
microgreen/
  Makefile
  src/
    microgreen.l       # lexer (Flex)
    microgreen.y       # parser + geração de código (Bison)
    main.c             # driver: lê .mgreen, chama parser e gera .mwasm
  examples/
    01-aquecer.mgreen
    02-manter.mgreen
    03-alarme.mgreen
    erro_sintaxe.mgreen
    erro_lexico.mgreen
    erro_lexico2.mgreen
  grammar/
    MicroGreen.ebnf    # EBNF da linguagem
  README.md
```

Alvos principais do `Makefile`:

```bash
make         # compila
make clean   # limpa artefatos gerados
```

---
