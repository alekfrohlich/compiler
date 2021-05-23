%{
#include <stdio.h>
int yyerror(const char* s);
int yylex(void);
%}
%locations

%union {
    char *  strval;
    int     val;
    double  fval;
}

 /* Tokens */
%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token LPAREN RPAREN LBRAC RBRAC SEMIC
%token CMP OP EQUAL
%token IDENT INT_C FLOAT_C STRING_C

%%

program: statement {  }
        | funclist {  }
;

funclist: funcdef funclist | funcdef;
funcdef: DEF IDENT LPAREN RPAREN LBRAC RBRAC;
statement:  vardecl    SEMIC |
            atribstat  SEMIC |
            printstat  SEMIC |
            readstat   SEMIC |
            RETURN     SEMIC |
            ifstat     SEMIC |
            forstat    SEMIC |
            LBRAC statelist RBRAC |
            BREAK SEMIC |
            SEMIC;

vardecl: INT IDENT INT_C;
atribstat: lvalue EQUAL expression | lvalue EQUAL funccall;
funccall: IDENT LPAREN RPAREN;
paramlistcall: ;
printstat: PRINT expression;
readstat: READ lvalue;
ifstat: IF LPAREN expression RPAREN statement;
forstat: FOR LPAREN atribstat SEMIC expression SEMIC atribstat RPAREN statement;
statelist: statement statelist | statement;
expression: ;
lvalue: ;
%%

void list_tokens() {
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
    }
}

int main(int argc, char **argv)
{
    //!TODO: read file from argv
    yyparse();
    // list_tokens();
}

int yyerror(const char *s)
{
    fprintf(stderr, "Error %d:%d: %s\n", yylloc.first_line, yylloc.first_column, s);
}