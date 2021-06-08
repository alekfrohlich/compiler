%{
#include <stdio.h>
#include "ast.h"
void yyerror(const char* s);
int yylex(void);
%}
%locations

%union {
    char *  strval;
    int     val;
    double  fval;
    Node *  nodeval;
}

 /* Tokens */

// %define api.value.type union
%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token CMP OP
%token IDENT STRING_C
%token <val>  INT_C
%token <fval> FLOAT_C
%nterm <nodeval> factor unaryexpr term numexpression

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

numexpression: numexpression '+' term   { $$ = new Node(Node::PLUS, $1, $3, Node::ValueType(0) ); }
    | numexpression '-' term            { $$ = new Node(Node::MINUS, $1, $3, Node::ValueType(0)); }
    | term                              { $$ = $1; }
;

term: term '*' unaryexpr    { $$ = new Node(Node::TIMES, $1, $3, Node::ValueType(0)); }
    | term '/' unaryexpr    { $$ = new Node(Node::DIV, $1, $3, Node::ValueType(0)); }
    | term '%' unaryexpr    { $$ = new Node(Node::MOD, $1, $3, Node::ValueType(0)); }
    | unaryexpr             { $$ = $1; }
;

unaryexpr: '+' factor   { $$ = new Node(Node::UPLUS, $2, nullptr, Node::ValueType(0)); }
    | '-' factor        { $$ = new Node(Node::UMINUS, $2, nullptr, Node::ValueType(0)); }
    | factor            { $$ = $1; }
;

factor:   INT_C                     { $$ = new Node(Node::INTEGER, nullptr, nullptr, $1); }
        | FLOAT_C                   { $$ = new Node(Node::FLOAT, nullptr, nullptr, $1); }
        | '(' numexpression ')'     { $$ = $2; }
;

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

// void list_tokens() {
//     for (enum yytokentype tok = yylex(); tok != YYEOF; tok = yylex()) {
//         printf("{type=%u", tok);
//         switch(tok) {
//             case IDENT:
//             case STRING_C:
//                 printf(",str=%s", yylval.strval);
//                 break;
//             case INT_C:
//                 printf(",int=%d", yylval.val);
//                 break;
//             case FLOAT_C:
//                 printf(",float=%f", yylval.fval);
//                 break;
//             default:
//                 break;
//         }
//         printf("}\n");
//     }
// }

int main(int argc, char **argv)
{
#if YYDEBUG
    yydebug = 1;
#endif

    //!TODO: read file from argv
    yyparse();
    // list_tokens();
}

void yyerror(const char *s)
{
    fprintf(stderr, "Error %d:%d: %s\n", yylloc.first_line, yylloc.first_column, s);
}