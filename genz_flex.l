%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "genz_bison.tab.h"  // Include the Bison header for token definitions
%}

%option yylineno

%%

\n               { return NEWLINE; }
[ \t]+           { /* Ignore all whitespace */ }
"#realtalk"[^\n]* { /* Ignore comments */ }

"wassup"         { return WASSUP; }
"rip"            { return RIP; }
"spill"          { return SPILL; }
"drop"           { return DROP; }
"fr"             { return FR; }
"nah"            { return NAH; }
"grind"          { return GRIND; }
"slideIn"        { return SLIDEIN; }
"tea"            { return TEA; }
"dead"           { return DEAD; }

"*"              { return MULTIPLY; }
"+"              { return PLUS; }
"-"              { return MINUS; }
"="              { return EQUALS; }
";"              { return SEMICOLON; }
"<"              { return LT; }
">"              { return GT; }
"("              { return OPAREN; }
")"              { return CPAREN; }
":"              { return COLON; }
","              { return COMMA; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

[0-9]+           {
                     yylval.str = strdup(yytext);
                     return NUMBER;
                 }

\"[^\"]*\"       { yylval.str = strdup(yytext); return STRING_LITERAL; }

.                { printf("Unknown character: %c\n", yytext[0]); }

%%

int yywrap() {
    return 1;
}