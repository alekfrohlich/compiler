%{
#include <stdio.h>
#define YYSTYPE float
int yyerror(const char* s);
int yylex(void);
%}

%token NUM
%token ADD SUB MUL DIV
%token EOL

%%

calclist:
| calclist exp EOL  { printf("= %.2f\n", $2); }
;

exp: factor
 | exp ADD factor            { $$ = $1 + $3; }
 | exp SUB factor            { $$ = $1 - $3; }
 ;

factor: NUM
 | factor MUL NUM           { $$ = $1 * $3; }
 | factor DIV NUM           { $$ = $1 / $3; }
 ;

%%

int main(int argc, char **argv)
{
    yyparse();
}

int yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}