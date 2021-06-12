%{
#include <stdio.h>
#include <string>

#include "ast.h"
#include "env.h"

void yyerror(const char* s);
bool break_inside_for();
bool check_put(std::string id, int type);

int yylex(void);
%}
%locations

%union {
    char*           sval;
    int             ival;
    double          fval;
    Node *          nodeval;
}

 /* Tokens */

%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token CMP OP
%token <sval> IDENT STRING_C
%token <ival>  INT_C
%token <fval> FLOAT_C
%nterm <nodeval> factor unaryexpr term numexpression

 /* !TODO: enum? */
%nterm <ival> type
%%

program: statement {  }
        | funclist {  }
        | %empty
;

funclist: funcdef funclist | funcdef;
funcdef: DEF IDENT                      { if(!check_put(std::string($2), SymType::T_FUNC)) YYABORT; Env::open_scope();}
                  '(' paramlist ')' '{' { Env::open_scope(); }
                      statelist '}'     { Env::close_scope(); Env::close_scope(); }
;

paramlist: type IDENT { if(!check_put(std::string($2), $1)) YYABORT; } ',' paramlist
        |  type IDENT { if(!check_put(std::string($2), $1)) YYABORT; }
        |  %empty
;  
type: INT { $$ = 0; } | FLOAT { $$ = 1; } | STRING { $$ = 2; };

statelist: statement statelist | statement;
statement: vardecl ';'
        | atribstat ';'
        | RETURN ';'
        | BREAK ';' { if(!break_inside_for()) YYABORT;}
        | '{' { Env::open_scope(); } statelist '}' { Env::close_scope(); }
        | ifstat
        | forstat
;

vardecl: type IDENT { if(!check_put(std::string($2), $1)) YYABORT; };
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
forstat: FOR '(' atribstat ';' expression ';' atribstat ')' { Env::open_scope(1); } statement { Env::close_scope(); };

%%
/* TODO: remove 1-statement programs */
/* TODO: vardecl and lvalue [][][][] */
/* TODO: atribstat */
/* TODO: print read */
/* TODO: statement ; */
/* TODO: if() {} */

// Alek, leia:
/* TODO: for tem que abrir escopo */ // OK
/* TODO: funcao ta no escopo errado, tem q ter escopo global */ // OK
/* TODO: falta checar se variavel ja foi declarada */




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
    Env::open_first_scope();
    yyparse();
    Env::close_scope();
    // list_tokens();
}

void yyerror(const char *s)
{
    fprintf(stderr, "Error %d:%d: %s\n", yylloc.first_line, yylloc.first_column, s);
}

bool break_inside_for() 
{
    if (!Env::_stack.top()->is_inside_for()) {
        yyerror("Break is NOT inside for");
        return false;
    } else {
        printf("Break is inside for\n");
        return true;
    }
}

bool check_put(std::string id, int type){
    if(!Env::check_put(id, type)) {
        yyerror("Symbol already exists");
        return false;
    } else {
        return true;
    }
}