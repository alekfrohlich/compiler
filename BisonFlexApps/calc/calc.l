%{
#include <stdlib.h>
#include "calc.tab.h"
%}

white       [ \t]+
digit       [0-9]
integer     {digit}+

%%

{white}     { }
{integer}   { yylval = atoi(yytext); return NUM; }

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }

"\n"        { return EOL; }

%%