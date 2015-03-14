%{
	#include <stdio.h>
	#include "y.tab.h"
	#include "calculator.h"
	#include "float.h"
	#include "math.h"
	#include <stdbool.h>
	#include <string.h>

	int yyparse();
%}

%option noyywrap

%%

"exit"					{ exit(0); }
\n 						{ return EOLN; }
"cos"					{ return COS; }
"sin"					{ return SIN; }
"tan"					{ return TAN; }
"sec"					{ return SEC; }
"csc"					{ return CSC; }
"cot"					{ return COT; }
"e"						{ return E; }
"arcsin" 				{ return ARCSIN; }
"arccos" 				{ return ARCCOS; }
"arctan"				{ return ARCTAN; }
"arcsec"				{ return ARCSEC; }
"arccsc"				{ return ARCCSC; }
"arccot"				{ return ARCCOT; }
"ln"					{ return LN; }
"log"					{ return LOG; }
"sqrt"					{ return SQRT; }
\( 						{ return LPARENTHESIS; }
\)						{ return RPARENTHESIS; }
\^						{ return EXPONENT; }
\*						{ return MULTIPLY; }
\/						{ return DIVIDE; }
\+						{ return ADD; }
\-						{ return SUBTRACT; }
\= 						{ 
							yylval.fun->equals = true;
							return EQUALS; 
						}
[a-zA-Z][0-9]*			{	 
							printf("[%s]\n", yytext);
							yylval.fun->find = strdup(yytext);
							if (!yylval.fun->equals)
								yylval.fun->var = strdup(yytext);
							return VARIABLE; 
						}
[0-9\.]+ 				{ 
							sscanf(yytext, "%lf", &yylval.fun->dub); 
							return NUMBER; 
						}
[ \t]					;
. 						{ 
							printf("Invalid input. Exiting.\n"); 
							exit(-1); 
						}

%%


