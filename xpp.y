%{
#include <stdio.h>
int yyerror(const char* s);
int yylex(void);
%}

 /* Tokens */
%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL

%%

program: ;

%%

int main(int argc, char **argv)
{
    //!TODO: read file from argv
    // yyparse();
    yylex();
}

int yywrap() {
    return 0;
}

int yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}