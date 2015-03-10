# A Makefile for simple lex and yacc examples

# Comment out the proper lines below according to the scanner and
# parser generators available in your system

LEX = lex
YACC = yacc -d
# LEX = flex 
# YACC = bison -d

# We assume that your C-compiler is called gcc

CC = gcc

# Calculator is the final object that we will generate, it is produced by
# the C compiler from the y.tab.o and from the lex.yy.o

Calculator: y.tab.o lex.yy.o
	$(CC) -o Calculator y.tab.o lex.yy.o -ly -ll -lm 

y.tab.o: y.tab.c
lex.yy.o: lex.yy.c

## This rule will use yacc to generate the files y.tab.c and y.tab.h
## from our file Calculator.y

y.tab.c y.tab.h: Calculator.y
	$(YACC) -v Calculator.y

## this is the make rule to use lex to generate the file lex.yy.c from
## our file Calculator.l

lex.yy.c: Calculator.l
	$(LEX) Calculator.l

## Make clean will delete all of the generated files so we can start
## from scratch

clean:
	-rm -f lex.yy.c lex.yy.o *.tab.*  Calculator *.output
