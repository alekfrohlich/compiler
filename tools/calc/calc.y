%{
#include <stdio.h>
int yyerror(const char* s);
int yylex(void);
%}

%token NUM
%token ADD SUB MUL DIV
%token EOL

%%

calclist:
| calclist exp EOL  { printf("= %d\n", $2); }
;

exp: factor
 | exp ADD factor            { $$ = $1 + $3; }
 | exp SUB factor            { $$ = $1 - $3; }
 ;

factor: term
 | factor MUL term           { $$ = $1 * $3; }
 | factor DIV term           { $$ = $1 / $3; }
 ;

term: NUM { $$ = $1; };

%%

int main(int argc, char **argv)
{
    yyparse();
}

int yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}