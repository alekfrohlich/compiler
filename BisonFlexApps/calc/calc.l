%{
#include <stdlib.h>
#include "instr.h"
#include "calc.tab.h"
%}

white       [ \t]+
digit       [0-9]
integer     {digit}+

%%

"if"        { return IF; }

{white}     { }
{integer}   { yylval.ival = atoi(yytext); return NUM; }

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"x"         { return 'x'; }
"="         { return '='; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }

"\n"        { return EOL; }

%%

int yywrap() {
    return true;
}
