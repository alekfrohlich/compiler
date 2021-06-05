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
%token CMP OP
%token IDENT INT_C FLOAT_C STRING_C

%%

program: statement {  }
        | funclist {  }
        | %empty
;

funclist: funcdef funclist | funcdef;
funcdef: DEF IDENT '(' paramlist ')' '{' statelist '}';
paramlist: type IDENT ',' paramlist | type IDENT | %empty;  
type: INT | FLOAT | STRING;

statelist: statement statelist | statement;
statement: vardecl ';'
        | atribstat ';'
        | RETURN ';'
        | BREAK ';'
        | '{' statelist '}'
        | ifstat
        | forstat
;

vardecl: type IDENT;
atribstat: lvalue '=' expression;

lvalue: IDENT;
expression: numexpression
    | numexpression CMP numexpression
;
numexpression: term termlist;

termlist: pm term termlist | %empty;
pm: '+' | '-';

term: uexp uexplist;
uexplist: tdm uexp uexplist | %empty;
tdm: '*' | '/' | '%';
uexp: pm factor | factor; // tem que escrever teste pra isso tudo; sequer compila?
factor: INT_C | FLOAT_C | STRING_C | NUL | lvalue | '(' numexpression ')';

ifstat: 'I';
forstat: FOR '(' atribstat ';' expression ';' atribstat ')' statement;

%%
 /* TODO: remove 1-statement programs */
 /* TODO: vardecl and lvalue [][][][] */
 /* TODO: atribstat */
  /* TODO: print read */
  /* TODO: statement ; */
 /* TODO: if() {} */

// atribstat: lvalue '=' expression | lvalue '=' allocexpression | lvalue '=' funccall;

// funclist: funclist funcdef | funcdef;
// vardecl    SEMIC |
//             atribstat  SEMIC |
//             printstat  SEMIC |
//             readstat   SEMIC |
//             RETURN     SEMIC |
//             ifstat     SEMIC |
//             forstat    SEMIC |
//             LBRAC statelist RBRAC |
//             BREAK SEMIC |
//             SEMIC;
// vardecl: INT IDENT INT_C;
// atribstat: lvalue EQUAL expression | lvalue EQUAL funccall;
// funccall: IDENT LPAREN RPAREN;
// paramlistcall: ;
// printstat: PRINT expression;
// readstat: READ lvalue;
// ifstat: IF LPAREN expression RPAREN statement;
// forstat: FOR LPAREN atribstat SEMIC expression SEMIC atribstat RPAREN statement;
// statelist: statement statelist | statement;
// expression: ;
// lvalue: ;

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
#if YYDEBUG
    yydebug = 1;
#endif

    //!TODO: read file from argv
    yyparse();
    // list_tokens();
}

int yyerror(const char *s)
{
    fprintf(stderr, "Error %d:%d: %s\n", yylloc.first_line, yylloc.first_column, s);
}