%{
/*
 * TODO: add int-float type checking.
 */
#define YYSTYPE float
#include <stdlib.h>
#include "fcalc.tab.h"
#include "math.h"
%}

white       [ \t]+
digit       [0-9]
integer     {digit}+
float       {integer}(\.{integer})?

%%

{white}     { }
{float}     { yylval = atof(yytext); return NUM; }

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }

"\n"        { return EOL; }

%%