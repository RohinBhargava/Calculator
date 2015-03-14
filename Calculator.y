%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <string.h>
	#include <stdbool.h>
	#include "calculator.h"

	void yyerror(char *); 
	int yylex(void);
	calculator* init_function();
	void free_func(calculator *f);
	var_container* find_variable(char *x, calculator *f); 
	var_container* init_vc(char *n);
	void free_var_container(var_container** vc, int count);
%}

%token RPARENTHESIS LPARENTHESIS EOLN MULTIPLY DIVIDE ADD SUBTRACT EXPONENT COS SIN TAN SEC CSC COT E ARCSIN ARCCOS ARCTAN ARCSEC ARCCSC ARCCOT LN LOG SQRT EQUALS VARIABLE

%union {
	struct calculator *fun;
	double du;
	char *str;
}

%token<du> NUMBER

%type<du> expression exponent parenthesis number prec md


%%

	start
		: print EOLN
		| print EOLN start 
		;

	print
		: VARIABLE EQUALS expression { 
				if (yylval.fun->count % 10 == 0)
					realloc(yylval.fun->cont, (10+yylval.fun->count) * sizeof(var_container *));
				var_container *v = find_variable(yylval.fun->var, yylval.fun);
				char *name;
				double value;
				yylval.fun->equals = false;
				if (v == NULL)
				{
					name = yylval.fun->var;
					yylval.fun->cont[yylval.fun->count] = init_vc(yylval.fun->var);
					yylval.fun->cont[yylval.fun->count]->value = $3;
					++yylval.fun->count; 
				}

				else
				{
					name = v->name;
					v->value = $3;
				}	
				printf("\"%s\" set to %lf.\n", name, $3);
		}
		| expression {
			yylval.fun->dub = $1; 
			printf("%lf\n", yylval.fun->dub);
		}
		;

	expression
		: expression ADD md { $$ = $1 + $3; }
		| expression SUBTRACT md{ $$ = $1 - $3; }
		| md { $$ = $1; }
		;		

	md
		: md MULTIPLY exponent { $$ = $1 * $3; }
		| md DIVIDE exponent { $$ = $1 / $3; }
		| exponent { $$ = $1; }
		;

	exponent
		: exponent EXPONENT prec { $$ = pow($1,$3); }
		| prec { $$ = $1; }
		;

	prec
		: SIN parenthesis { $$ = sin($2); }
		| COS parenthesis { $$ = cos($2); }
		| TAN parenthesis { $$ = tan($2); }
		| SEC parenthesis { $$ = 1/(cos($2)); }
		| CSC parenthesis { $$ = 1/(sin($2)); }
		| COT parenthesis { $$ = 1/(tan($2)); }
		| ARCSIN parenthesis { $$ = asin($2); }
		| ARCCOS parenthesis { $$ = acos($2); }
		| ARCTAN parenthesis { $$ = atan($2); }
		| ARCSEC parenthesis { $$ = 1/(acos($2)); }
		| ARCCSC parenthesis { $$ = 1/(asin($2)); }
		| ARCCOT parenthesis { $$ = 1/(atan($2)); }
		| LN parenthesis { $$ = log($2); }
		| LOG parenthesis { $$ = log10($2); }
		| SQRT parenthesis { $$ = sqrt($2); }
		| SUBTRACT parenthesis { $$ = -1 * $2; }
		| parenthesis prec { $$ = $1 * $2; }
		| parenthesis { $$ = $1; }
		;

	parenthesis
		: LPARENTHESIS expression RPARENTHESIS { $$ = $2; }
		| number { $$ = $1; }
		;


	number
		: VARIABLE { 
			printf("%s\n", yylval.fun->find);
			var_container *v = find_variable(yylval.fun->find, yylval.fun);
			if (v != NULL)
				$$ = v->value;
			else 
			{
				printf("No such variable \"%s\".\n", yylval.fun->find);
				$$ = 0;
			}
		}
		| E { $$ = M_E; }
		| NUMBER { $$ = yylval.fun->dub; }
		;

%%

calculator* init_function()
{
	calculator *returner = (calculator *) calloc(1, sizeof(calculator));

	returner->equals = false;
	returner->count = 0;    
	returner->cont = (var_container **) calloc(10, sizeof(var_container*));
	returner->dub = 0;

	return returner;
}

var_container* init_vc(char *n)
{
	var_container *vc = (var_container *) calloc(1, sizeof(var_container));

	vc->name = n;
	vc->value = 0;

	return vc;
}

void free_var_container(var_container** vc, int count)
{
	int i;
	for (i = 0; i < count; i++)
		free(vc[i]);
}

void free_func(calculator *f)
{
	free_var_container(f->cont, f->count);
	free(f);
}

var_container* find_variable(char *x, calculator* f)
{
	int i;
	for (i = 0; i < f->count; i++)
		if(strcmp(f->cont[i]->name, x) == 0)
			return f->cont[i];
	return NULL;
}

int main() 
{
	printf("Welcome to this calculator! To exit at any time, type \"exit\".\n");
	yylval.fun = init_function();
	yyparse();
	free_func(yylval.fun);
}

