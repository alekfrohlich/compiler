%{
// Definitions
#include <stdlib.h>
// #include "calc.tab.h"
%}

%%
def             { printf("found DEF\n"); }
ident           { printf("found IDENT\n"); }
"("             { printf("found LPAREN\n"); }
")"             { printf("found RPAREN\n"); }
"{"             { printf("found LBRAC\n"); }
"}"             { printf("found RBRAC\n"); }
int             { printf("found int\n"); }
float           { printf("found float\n"); }
string          { printf("found string\n"); }
break           { printf("found break\n"); }
";"               { printf("found ;\n"); }
print           { printf("found print\n"); }
read            { printf("found read\n"); }
return          { printf("found return\n"); }
if              { printf("found if\n"); }
else            { printf("found else\n"); }
for             { printf("found for\n"); }
new             { printf("found new\n"); }
"<"              { printf("found <\n"); }
">"              { printf("found >\n"); }
"<="              { printf("found <=\n"); }
">="              { printf("found >=\n"); }
"=="              { printf("found ==\n"); }
"!="              { printf("found !=\n"); }
"+"               { printf("found +\n"); }
"-"               { printf("found -\n"); }
"*"               { printf("found *\n"); }
"/"               { printf("found FORWSLASH\n"); }
"%"               { printf("found MOD\n"); }
int_constant    { printf("found int_constant\n"); }
float_constant  { printf("found float_constant\n"); }
string_constant { printf("found string_constant\n"); }
null            { printf("found null\n"); }
.               {}


%%
// Refs: http://dinosaur.compilertools.net/lex/index.html
// info flex

// User definitions

int main(int argc, char **argv)
{
    yylex();
}

int yywrap() {
    return 0;
}

int yyerror(const char *s)
{
    fprintf(stderr, "erro: %s\n", s);
}