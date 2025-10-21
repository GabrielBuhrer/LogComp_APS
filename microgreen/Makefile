CC=gcc
CFLAGS=-O2 -Wall -Wextra

all: microgreen

microgreen: src/microgreen.l src/microgreen.y src/main.c
	bison -d -v -o src/microgreen.tab.c src/microgreen.y
	flex -o src/lex.yy.c src/microgreen.l
	$(CC) $(CFLAGS) -o $@ src/microgreen.tab.c src/lex.yy.c src/main.c

clean:
	rm -f microgreen src/microgreen.tab.c src/microgreen.tab.h src/lex.yy.c src/microgreen.output