%{
// Definitions
#include <stdlib.h>
#include "xpp.tab.h"
%}

white               [ \t]+
digit               [0-9]
 /* TODO: improve ident pattern */
ident               [a-zA-Z]+
int_constant        {digit}+
float_constant      {int_constant}(\.{int_constant})?
string_constant     \"[^\"\\]*\"

%%
    /* Keywords */
def                 { printf("found DEF\n"); return DEF; }
int                 { printf("found int\n"); }
float               { printf("found float\n"); }
string              { printf("found string\n"); }
break               { printf("found break\n"); }
print               { printf("found print\n"); }
read                { printf("found read\n"); }
return              { printf("found return\n"); }
if                  { printf("found if\n"); }
else                { printf("found else\n"); }
for                 { printf("found for\n"); }
new                 { printf("found new\n"); }
null                { printf("found null\n"); }

    /* Punctuation */
"("                 { printf("found LPAREN\n"); }
")"                 { printf("found RPAREN\n"); }
"{"                 { printf("found LBRAC\n"); }
"}"                 { printf("found RBRAC\n"); }
";"                 { printf("found ;\n"); }

    /* Operators */
"<"                 { printf("found <\n"); }
">"                 { printf("found >\n"); }
"<="                { printf("found <=\n"); }
">="                { printf("found >=\n"); }
"=="                { printf("found ==\n"); }
"!="                { printf("found !=\n"); }
"+"                 { printf("found +\n"); }
"-"                 { printf("found -\n"); }
"*"                 { printf("found *\n"); }
"/"                 { printf("found FORWSLASH\n"); }
"%"                 { printf("found MOD\n"); }

    /* Named rules */
{ident}               { printf("found IDENT\n"); }
{int_constant}        { printf("found int_constant\n"); }
{float_constant}      { printf("found float_constant\n"); }
{string_constant}     { printf("found string_constant\n"); }

    /* Ignore everything else */
.                   {}

%%