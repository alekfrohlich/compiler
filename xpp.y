%{
#include <stdio.h>
#include <string>
#include <map>
#include <vector>
#include <set>


#include "ast.h"
#include "env.h"

void yyerror(const char* s);
bool break_inside_for();
bool check_put(std::string id, int type);
bool check_expr_tree(Node * root);
void check_expr_tree_rec(Node * root);
// void create_token_map();
// void list_tokens();

unsigned yylex(void);

std::vector<Node *> exprlist;
std::set<int> exprTypes;

//std::map<unsigned, std::string> token_map;

%}
%locations

%union {
    char*           sval;
    int             ival;
    double          fval;
    struct {
        Node*    node;
        // Address* addr;
    }               expval;
    Node *          nodeval;
}

 /* Tokens */

%token DEF INT FLOAT STRING BREAK PRINT READ RETURN IF ELSE FOR NEW NUL
%token CMP
%token <sval> IDENT STRING_C
%token <ival>  INT_C
%token <fval> FLOAT_C
%nterm <expval> factor unaryexpr term numexpression
%nterm <sval> lvalue

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

allocexpression: NEW type '[' numexpression {if(!check_expr_tree($4.node)) YYABORT;} ']' arraylistexp;

expression: numexpression               {if(!check_expr_tree($1.node)) YYABORT;}
    | numexpression CMP numexpression   {if(!check_expr_tree($1.node)) YYABORT; if(!check_expr_tree($3.node)) YYABORT;}
;

numexpression: numexpression '+' term { $$.node = new Node(Node::PLUS,  $1.node, $3.node); }
    |          numexpression '-' term { $$.node = new Node(Node::MINUS, $1.node, $3.node); }
    |          term                   { $$.node = $1.node; }
;

term: term '*' unaryexpr              { $$.node = new Node(Node::TIMES, $1.node, $3.node); }
    | term '/' unaryexpr              { $$.node = new Node(Node::DIV,   $1.node, $3.node); }
    | term '%' unaryexpr              { $$.node = new Node(Node::MOD,   $1.node, $3.node); }
    | unaryexpr                       { $$.node = $1.node; }
;

unaryexpr: '+' factor                 { $$.node = new Node(Node::UPLUS,  $2.node, nullptr); }
    |      '-' factor                 { $$.node = new Node(Node::UMINUS, $2.node, nullptr); }
    |      factor                     { $$.node = $1.node; }
;

factor:   INT_C                       { $$.node = new Node(Node::INTEGER, nullptr, nullptr, $1); }
        | FLOAT_C                     { $$.node = new Node(Node::FLOAT,   nullptr, nullptr, $1); }
        | STRING_C                    { $$.node = new Node(Node::STRING,  nullptr, nullptr, $1); }
        | NUL                         { $$.node = new Node(Node::NUL,     nullptr, nullptr); }
        | lvalue                      { $$.node = new Node(Node::LVALUE,  nullptr, nullptr, $1); }
        | '(' numexpression ')'       { $$.node = $2.node; }
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
        int lvtype = Env::get_type(std::string(root->val.sval));
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



//


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
