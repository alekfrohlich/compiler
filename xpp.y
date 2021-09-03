%{
#include <stdio.h>
#include <string>
#include <map>

#include "ast.h"
#include "env.h"

void yyerror(const char* s);
bool break_inside_for();
bool check_put(std::string id, int type);
// void create_token_map();
// void list_tokens();

unsigned yylex(void);

//std::map<unsigned, std::string> token_map;

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
%token CMP
%token <sval> IDENT STRING_C
%token <ival>  INT_C
%token <fval> FLOAT_C
//%nterm <nodeval> factor unaryexpr term numexpression

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
        |  atribstat ';'
        |  printstat ';'
        |  readstat ';'
        |  RETURN ';'
        |  ifstat
        |  forstat
        |  '{' { Env::open_scope(); } statelist '}' { Env::close_scope(); }
        |  BREAK ';' { if(!break_inside_for()) YYABORT;}
        |  ';'
;

vardecl: type IDENT { if(!check_put(std::string($2), $1)) YYABORT; } arraylistdecl;
atribstat: lvalue '=' expression
         | lvalue '=' allocexpression
         | lvalue '=' funccall
;

funccall: IDENT '(' paramlistcall ')';
paramlistcall: IDENT ',' paramlistcall
            |  IDENT
            |  %empty
;

printstat: PRINT expression;
readstat:  READ  lvalue;

ifstat:   IF '(' expression ')' { Env::open_scope(); } '{' statelist '}' { Env::close_scope(); } elsestat;
elsestat: ELSE { Env::open_scope(); } '{' statelist '}' { Env::close_scope(); }
        | %empty;

forstat: FOR '(' atribstat ';' expression ';' atribstat ')' { Env::open_scope(1); } statement { Env::close_scope(); };

allocexpression: NEW type '[' numexpression ']' arraylistexp;

expression: numexpression
    | numexpression CMP numexpression
;

numexpression: numexpression '+' term
    | numexpression '-' term
    | term
;

term: term '*' unaryexpr
    | term '/' unaryexpr
    | term '%' unaryexpr
    | unaryexpr
;

unaryexpr: '+' factor
    | '-' factor
    | factor
;

factor:   INT_C
        | FLOAT_C
        | STRING_C
        | NUL
        | lvalue
        | '(' numexpression ')'
;

lvalue: IDENT arraylistexp;

arraylistdecl: arraylistdecl'[' INT_C ']'        | %empty;
arraylistexp:  arraylistexp'[' numexpression ']' | %empty;


%%
/* TODO: factor string_c, null, lvalue
        | STRING_C                   { $$ = new Node(Node::FLOAT, nullptr, nullptr, $1); }
        | NUL                        { $$ = new Node(Node::FLOAT, nullptr, nullptr, $1); }
        | lvalue                     { $$ = new Node(Node::FLOAT, nullptr, nullptr, $1); }

*/


int main(int argc, char **argv)
{
#if YYDEBUG
    yydebug = 1;
#endif
    Env::open_first_scope();
    yyparse();
    Env::close_scope();
    // create_token_map();
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


//
/*
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

factor:   INT_C                      { $$ = new Node(Node::INTEGER, nullptr, nullptr, $1); }
        | FLOAT_C                    { $$ = new Node(Node::FLOAT, nullptr, nullptr, $1); }
        | lvalue                     { $$ = new Node(Node::INTEGER, nullptr, nullptr, Node::ValueType(0)); }
        | '(' numexpression ')'      { $$ = $2; }
;

*/

// void list_tokens() {
//     for (unsigned tok = yylex(); tok != YYEOF; tok = yylex()) {
//         if(token_map.find(tok) == token_map.end()){
//             yyerror("Lexical error");
//             return;
//         }
//         printf("{type = _%s_ ", token_map[tok].c_str());
//         switch(tok) {
//             case IDENT:
//             case STRING_C:
//                 printf(", str=%s", yylval.sval);
//                 break;
//             case INT_C:
//                 printf(", int=%d", yylval.ival);
//                 break;
//             case FLOAT_C:
//                 printf(", float=%f", yylval.fval);
//                 break;
//             default:
//                 break;
//         }
//         printf("}\n");
//     }
//     printf("\n=======================\nLexical analysis -> OK\n=======================\n");
// }

// void create_token_map()
// {
//     int c = DEF;
//     token_map[DEF]      = std::string("DEF");
//     token_map[INT]      = std::string("INT");
//     token_map[FLOAT]    = std::string("FLOAT");
//     token_map[STRING]   = std::string("STRING");
//     token_map[BREAK]    = std::string("BREAK");
//     token_map[PRINT]    = std::string("PRINT");
//     token_map[READ]     = std::string("READ");
//     token_map[RETURN]   = std::string("RETURN");
//     token_map[IF]       = std::string("IF");
//     token_map[ELSE]     = std::string("ELSE");
//     token_map[FOR]      = std::string("FOR");
//     token_map[NEW]      = std::string("NEW");
//     token_map[NUL]      = std::string("NUL");
//     token_map[CMP]      = std::string("CMP");
//     token_map[IDENT]    = std::string("IDENT");
//     token_map[STRING_C] = std::string("STRING_C");
//     token_map[INT_C]    = std::string("INT_C");
//     token_map[FLOAT_C]  = std::string("FLOAT_C");

//     token_map['('] = std::string("(");
//     token_map[')'] = std::string(")");
//     token_map['{'] = std::string("{");
//     token_map['}'] = std::string("}");
//     token_map['['] = std::string("[");
//     token_map[']'] = std::string("]");
//     token_map['('] = std::string("(");
//     token_map[';'] = std::string(";");
//     token_map[','] = std::string(",");
//     token_map['='] = std::string("=");
//     token_map['+'] = std::string("+");
//     token_map['-'] = std::string("-");
//     token_map['*'] = std::string("*");
//     token_map['/'] = std::string("/");
//     token_map['%'] = std::string("%");

// }
