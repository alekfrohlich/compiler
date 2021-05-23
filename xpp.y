%{
#include <stdio.h>
int yyerror(const char* s);
int yylex(void);
%}

%union {
    char *  strval;
    int     val;
    double  fval;
}

 /* Tokens */
%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token LPAREN RPAREN LBRAC RBRAC SEMIC
%token CMP OP
%token IDENT INT_C FLOAT_C STRING_C

%%

program: ;

%%

int main(int argc, char **argv)
{
    //!TODO: read file from argv
    // yyparse();
    for (enum yytokentype tok = yylex(); tok != YYEOF; tok = yylex()) {
        printf("{type=%u", tok);
        switch(tok) {
            case IDENT:
            case STRING_C:
                printf(",str=%s", yylval.strval);
                break;
            case INT_C:
                printf(",int=%d", yylval.val);
                break;
            case FLOAT_C:
                printf(",float=%f", yylval.fval);
                break;
            default:
                break;
        }
        printf("}\n");
    };
}

int yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}