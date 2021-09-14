%{
#include <stdio.h>
#include <string>
#include <map>
#include <vector>
#include <set>


#include "ast.h"
#include "env.h"
#include "instr.h"

void yyerror(const char* s);
bool break_inside_for();
bool check_put(string id, int type);
bool check_expr_tree(Node * root);
void check_expr_tree_rec(Node * root);
// void create_token_map();
// void list_tokens();

//!TODO: Generalize Constant
//!TODO: Fix labels

unsigned yylex(void);

vector<Node *> exprlist;
set<int> exprTypes;

//map<unsigned, string> token_map;

%}
%locations

%union {
    char*           sval;
    int             ival;
    double          fval;
    struct {
        Node*    node;
        Address* addr;
    }               expval;
    Node *          nodeval;
}

 /* Tokens */
%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token <ival> CMP
%token <sval> IDENT STRING_C
%token <ival> INT_C
%token <fval> FLOAT_C

/* Variables */
%nterm <expval> factor unaryexpr term numexpression expression
%nterm <sval> lvalue
%nterm <ival> type
%%

program: statement { emit_code(); }
        | funclist { emit_code(); }
        | %empty
;

funclist: funcdef funclist | funcdef;
funcdef: DEF IDENT                      { if(!check_put(string($2), SymType::T_FUNC)) YYABORT; Env::open_scope();}
                  '(' paramlist ')' '{' { Env::open_scope(); }
                      statelist '}'     { Env::close_scope(); Env::close_scope(); }
;

paramlist: type IDENT { if(!check_put(string($2), $1)) YYABORT; } ',' paramlist
        |  type IDENT { if(!check_put(string($2), $1)) YYABORT; }
        |  %empty
;
type: INT { $$ = 0; } | FLOAT { $$ = 1; } | STRING { $$ = 2; };

statelist: statement statelist | statement;
statement: vardecl ';'
        |  atribstat ';'
        |  printstat ';'
        |  readstat ';'
        |  RETURN ';' { gen(IType::RET); }
        |  ifstat
        |  forstat
        |  '{' { Env::open_scope(); } statelist '}' { Env::close_scope(); }
        |  BREAK ';' { if(!break_inside_for()) YYABORT;}
        |  ';'
;

vardecl: type IDENT { if(!check_put(string($2), $1)) YYABORT; } arraylistdecl;
atribstat: lvalue '=' expression { Symbol * s = Env::get_symbol($1); gen(IType::ASSIGN, $3.addr, s); }
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

ifstat:   IF '(' expression ')' { gen(IType::IFFALSE, $3.addr, make_label()); Env::open_scope(); } '{' statelist '}' { Env::close_scope(); } elsestat;
elsestat: ELSE   { attach_label(1); gen(IType::GOTO, make_label()); Env::open_scope(); } '{' statelist '}' { Env::close_scope(); attach_label(); }
        | %empty { attach_label(); }
;

forstat: FOR '(' atribstat ';' expression ';' atribstat ')' { Env::open_scope(1); } statement { Env::close_scope(); };

allocexpression: NEW type '[' numexpression {if(!check_expr_tree($4.node)) YYABORT;} ']' arraylistexp;

expression: numexpression               { if(!check_expr_tree($1.node)) YYABORT; $$.addr = $1.addr; }
    | numexpression CMP numexpression   {
                                            if(!check_expr_tree($1.node)) YYABORT;
                                            if(!check_expr_tree($3.node)) YYABORT;
                                            $$.addr = new Temp();
                                            switch ($2) {
                                                case 0: gen(IType::LT , $1.addr, $3.addr, $$.addr); break;
                                                case 1: gen(IType::GT , $1.addr, $3.addr, $$.addr); break;
                                                case 2: gen(IType::LTE, $1.addr, $3.addr, $$.addr); break;
                                                case 3: gen(IType::GTE, $1.addr, $3.addr, $$.addr); break;
                                                case 4: gen(IType::EQ , $1.addr, $3.addr, $$.addr); break;
                                                case 5: gen(IType::NEQ, $1.addr, $3.addr, $$.addr); break;
                                            }
                                        }
;

numexpression: numexpression '+' term { $$.node = new Node(Node::PLUS,  $1.node, $3.node); $$.addr = new Temp(); gen(IType::PLUS, $1.addr, $3.addr, $$.addr); }
    |          numexpression '-' term { $$.node = new Node(Node::MINUS, $1.node, $3.node); $$.addr = new Temp(); gen(IType::MINUS, $1.addr, $3.addr, $$.addr); }
    |          term                   { $$.node = $1.node; $$.addr = $1.addr; }
;

term: term '*' unaryexpr              { $$.node = new Node(Node::TIMES, $1.node, $3.node); $$.addr = new Temp(); gen(IType::TIMES, $1.addr, $3.addr, $$.addr); }
    | term '/' unaryexpr              { $$.node = new Node(Node::DIV,   $1.node, $3.node); $$.addr = new Temp(); gen(IType::DIV, $1.addr, $3.addr, $$.addr); }
    | term '%' unaryexpr              { $$.node = new Node(Node::MOD,   $1.node, $3.node); $$.addr = new Temp(); gen(IType::MOD, $1.addr, $3.addr, $$.addr); }
    | unaryexpr                       { $$.node = $1.node; $$.addr = $1.addr; }
;

unaryexpr: '+' factor                 { $$.node = new Node(Node::UPLUS,  $2.node, nullptr); $$.addr = new Temp(); gen(IType::UPLUS, $2.addr, $$.addr); }
    |      '-' factor                 { $$.node = new Node(Node::UMINUS, $2.node, nullptr); $$.addr = new Temp(); gen(IType::UMINUS, $2.addr, $$.addr); }
    |      factor                     { $$.node = $1.node; $$.addr = $1.addr; }
;

factor:   INT_C                       { $$.node = new Node(Node::INTEGER, nullptr, nullptr, $1); $$.addr = new Constant($1); }
        | FLOAT_C                     { $$.node = new Node(Node::FLOAT,   nullptr, nullptr, $1); }
        | STRING_C                    { $$.node = new Node(Node::STRING,  nullptr, nullptr, $1); }
        | NUL                         { $$.node = new Node(Node::NUL,     nullptr, nullptr); }
        | lvalue                      { $$.node = new Node(Node::LVALUE,  nullptr, nullptr, $1); $$.addr = Env::get_symbol($1); }
        | '(' numexpression ')'       { $$.node = $2.node; $$.addr = $2.addr; }
;

lvalue: IDENT arraylistexp;

arraylistdecl: arraylistdecl'[' INT_C ']'        | %empty;
arraylistexp:  arraylistexp'[' numexpression {if(!check_expr_tree($3.node)) YYABORT;} ']' | %empty;


%%

int main(int argc, char **argv)
{
#if YYDEBUG
    yydebug = 1;
#endif
    Env::open_first_scope();
    yyparse();
    Env::close_scope();
    // printf("===========\n");
    printf("Trees:\n");
    for(auto it=exprlist.begin();it != exprlist.end();++it){
        Node::print_tree(*it);
    }
    printf("numexpressions: OK - %lu\n", exprlist.size());
    printf("variable declaration in the same scope: OK\n");
    printf("break inside for: OK\n");

    // create_token_map();
    // list_tokens();
}

void yyerror(const char *s)
{
    fprintf(stderr, "Error %d:%d: %s\n", yylloc.first_line, yylloc.first_column, s);
}

bool break_inside_for()
{
    if (Env::is_inside_for()) {
        yyerror("Break is NOT inside for");
        return false;
    } else {
        printf("Break is inside for\n");
        return true;
    }
}

bool check_put(string id, int type){
    if(!Env::check_put(id, type)) {
        yyerror("Symbol already exists");
        return false;
    } else {
        return true;
    }
}

bool check_expr_tree(Node * root){
    exprTypes.clear();
    exprlist.push_back(root);
    check_expr_tree_rec(root);
    // printf("Check\n");
    // printf("types:");
    // for(auto it = exprTypes.begin(); it!=exprTypes.end();it++){
    //     printf("%d; ", *it);
    // }
    // printf("\n");
    if(exprTypes.size() > 1){
        yyerror("Expr tree uses different types");
        return false;
    } else{
        return true;
    }
}

void check_expr_tree_rec(Node * root){
    if(root->type == Node::NodeType::INTEGER ||
       root->type == Node::NodeType::FLOAT   ||
       root->type == Node::NodeType::STRING) {
        exprTypes.insert(root->type);
    }
    if(root->type == Node::NodeType::LVALUE){
        int lvtype = Env::get_type(string(root->val.sval));
        if(lvtype == -1){
            printf("Variable:%s was not declared!!!! We are not taking care of this!\n",
            root->val.sval);
        }else{
            exprTypes.insert(lvtype);
        }
    }
    if(root->l){
        check_expr_tree_rec(root->l);
    }
    if(root->r){
        check_expr_tree_rec(root->r);
    }
}

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
//     token_map[DEF]      = string("DEF");
//     token_map[INT]      = string("INT");
//     token_map[FLOAT]    = string("FLOAT");
//     token_map[STRING]   = string("STRING");
//     token_map[BREAK]    = string("BREAK");
//     token_map[PRINT]    = string("PRINT");
//     token_map[READ]     = string("READ");
//     token_map[RETURN]   = string("RETURN");
//     token_map[IF]       = string("IF");
//     token_map[ELSE]     = string("ELSE");
//     token_map[FOR]      = string("FOR");
//     token_map[NEW]      = string("NEW");
//     token_map[NUL]      = string("NUL");
//     token_map[CMP]      = string("CMP");
//     token_map[IDENT]    = string("IDENT");
//     token_map[STRING_C] = string("STRING_C");
//     token_map[INT_C]    = string("INT_C");
//     token_map[FLOAT_C]  = string("FLOAT_C");

//     token_map['('] = string("(");
//     token_map[')'] = string(")");
//     token_map['{'] = string("{");
//     token_map['}'] = string("}");
//     token_map['['] = string("[");
//     token_map[']'] = string("]");
//     token_map['('] = string("(");
//     token_map[';'] = string(";");
//     token_map[','] = string(",");
//     token_map['='] = string("=");
//     token_map['+'] = string("+");
//     token_map['-'] = string("-");
//     token_map['*'] = string("*");
//     token_map['/'] = string("/");
//     token_map['%'] = string("%");

// }
