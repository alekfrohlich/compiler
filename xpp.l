%{

//   This file implements the lexical analyser for the grammar CC-2021-1, you may
// find it in BNF form under `docs`.

// Definitions
#include <stdlib.h>
#include <stdbool.h>
#include <string>

#include "ast.h"
#include "instr.h"
#include "xpp.tab.h"

int yycolumn = 1;
#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno;                           \
    yylloc.first_column = yycolumn;                                            \
    yylloc.last_column = yycolumn + yyleng - 1;                                \
    yycolumn += yyleng;
#define LEX_ERROR 9999;

%}
%option yylineno

white               [ \t]+
digit               [0-9]
ident               [a-zA-Z_][a-zA-Z0-9_]*
int_constant        {digit}+
float_constant      {int_constant}(\.{int_constant})?
 /* Based on C-style strings; c.f. https://www.lysator.liu.se/c/ANSI-C-grammar-l.html */
string_constant     \"([^\"\\]|\\.)*\"

%%
    /* Keywords */
def                 { return DEF;       }
int                 { return INT;       }
float               { return FLOAT;     }
string              { return STRING;    }
break               { return BREAK;     }
print               { return PRINT;     }
read                { return READ;      }
return              { return RETURN;    }
if                  { return IF;        }
else                { return ELSE;      }
for                 { return FOR;       }
new                 { return NEW;       }
null                { return NUL;       }

    /* Punctuation */
"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{';  }
"}"                 { return '}';  }
"["                 { return '[';  }
"]"                 { return ']';  }
";"                 { return ';';  }
","                 { return ',';  }
"="                 { return '=';  }

    /* Operators */
"<"                 { yylval.ival = 0; return CMP;   }
">"                 { yylval.ival = 1; return CMP;   }
"<="                { yylval.ival = 2; return CMP;   }
">="                { yylval.ival = 3; return CMP;   }
"=="                { yylval.ival = 4; return CMP;   }
"!="                { yylval.ival = 5; return CMP;   }
"+"                 { return '+';  }
"-"                 { return '-';  }
"*"                 { return '*';  }
"/"                 { return '/';  }
"%"                 { return '%';  }

    /* Ignore comments */
"//".*              {}

    /* Named rules */
{white}               {}
{ident}               { yylval.lvalueval.sval = strdup(yytext); return IDENT; }
{string_constant}     {
                        char * dup = strdup(yytext);
                        dup++;
                        dup[strlen(dup)-1] = 0;
                        yylval.sval   = dup;
                        return STRING_C;
                      }
{int_constant}        { yylval.ival    = atoi(yytext); return INT_C; }
{float_constant}      { yylval.fval   = atof(yytext); return FLOAT_C; }

    /* Ignore everything else */
"\n"                { yycolumn = 1; }
.                   { return LEX_ERROR; }

%%

int yywrap() {
    return true;
}
