%{
// Definitions
#include <stdlib.h>
#include <stdbool.h>
#include "xpp.tab.h"
#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yylloc.last_column;
%}
%option yylineno

white               [ \t]+
digit               [0-9]
 /* TODO: improve ident pattern */
ident               [a-zA-Z]+
int_constant        {digit}+
float_constant      {int_constant}(\.{int_constant})?
string_constant     \"[^\"\\]*\"

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
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRAC;  }
"}"                 { return RBRAC;  }
";"                 { return SEMIC;  }

    /* Operators */
"<"                 { return CMP;   }
">"                 { return CMP;   }
"<="                { return CMP;   }
">="                { return CMP;   }
"=="                { return CMP;   }
"!="                { return CMP;   }
"+"                 { return OP;    }
"-"                 { return OP;    }
"*"                 { return OP;    }
"/"                 { return OP;    }
"%"                 { return OP;    }

    /* Named rules */
{ident}               { yylval.strval = yytext; return IDENT; }
{string_constant}     { yylval.strval = yytext; return STRING_C; }
{int_constant}        { yylval.val    = atoi(yytext); return INT_C; }
{float_constant}      { yylval.fval   = atof(yytext); return FLOAT_C; }

    /* Ignore everything else */
.                   {}

%%

int yywrap() {
    return true;
}
