%{
#include <stdio.h>
#include "instr.h"
void yyerror(const char* s);
unsigned yylex(void);
%}
%union {
    int      ival;
    Address* addrval;
    // struct {
    //     Address* addr;
    //     Label    labl;
    // } codgval;
}

%token <ival> NUM
%token ADD SUB MUL DIV IF
%token EOL

%nterm <addrval> factor term exp bexp
// %nterm <codgval> bexp
%%

statlist:
 | statlist statement EOL
;

statement: assignstat
 | ifstat
;

ifstat: IF '(' bexp ')' { Instruction::gen(IType::IFFALSE, $3); } '{' statement '}'
;

assignstat: 'x' '=' exp         {
                                    Instruction::gen(IType::ASSIGN, $3, new Symbol());
                                    Instruction::emit();
                                }
;

bexp: exp;

exp: term
 |   exp ADD term               {
                                    $$ = new Temp();
                                    Instruction::gen(IType::PLUS, $1, $3, $$);
                                }
 ;

term: factor
 |    term MUL factor           {
                                    $$ = new Temp();
                                    Instruction::gen(IType::TIMES, $1, $3, $$);
                                }
 ;

factor: NUM { $$ = new Constant($1); };

%%

int main(int argc, char **argv)
{
    yyparse();
}

void yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}
