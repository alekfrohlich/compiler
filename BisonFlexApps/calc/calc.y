%{
#include <stdio.h>
#include "instr.h"
void yyerror(const char* s);
unsigned yylex(void);
%}
%union {
    int     ival;
    Address* addrval;
}

%token <ival> NUM
%token ADD SUB MUL DIV
%token EOL

%nterm <addrval> factor term exp
%%

calclist:
| calclist 'x' '=' exp EOL      {
                                    Instruction::gen(IType::ASSIGN, $4, new Address(), new Symbol());
                                    Instruction::emit();
                                }
;

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
