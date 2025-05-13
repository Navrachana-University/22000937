%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Forward declarations for yylex and yyerror
int yylex(void);
void yyerror(const char *s);

int temp_var_count = 0;
int label_count = 0;

int new_temp_var() {
    return temp_var_count++;
}

char* new_label() {
    char* label = (char*)malloc(20);
    snprintf(label, 20, "L%d", label_count++);
    return label;
}

void print_3ac(char *op, char *arg1, char *arg2, char *result) {
    if (result) {
        if (arg2)
            printf("%s = %s %s %s\n", result, arg1, op, arg2);
        else
            printf("%s = %s\n", result, arg1);
    } else {
        if (arg2)
            printf("%s %s %s\n", op, arg1, arg2);
        else
            printf("%s %s\n", op, arg1);
    }
}

void print_label(char *label) {
    printf("%s:\n", label);
}
%}

%union {
    char* str;    // For strings (identifiers, literals, temporaries)
    char* code;   // For TAC code
}

%token WASSUP RIP SPILL DROP FR NAH GRIND SLIDEIN TEA DEAD
%token INT FLOAT STRING
%token IDENTIFIER NUMBER STRING_LITERAL
%token PLUS MINUS MULTIPLY EQUALS SEMICOLON OPAREN CPAREN LT GT COLON NEWLINE COMMA

%left PLUS MINUS
%left MULTIPLY
%nonassoc LT GT
%nonassoc FR
%nonassoc NAH

%type <str> IDENTIFIER STRING_LITERAL NUMBER expression param_list param arg_list
%type <code> statements statement

%%

program:
    WASSUP NEWLINE statements RIP NEWLINE
    ;

statements:
    /* empty */ { $$ = strdup(""); }  // Empty TAC
    | statements statement {
        char* tac = (char*)malloc(strlen($1) + ($2 ? strlen($2) : 0) + 2);
        sprintf(tac, "%s%s", $1, $2 ? $2 : "");
        free($1);
        if ($2) free($2);
        $$ = tac;
    }
    ;

statement:
    DROP IDENTIFIER EQUALS expression SEMICOLON NEWLINE {
        // Generate TAC for the drop statement
        char* tac = (char*)malloc(128);
        snprintf(tac, 128, "%s = %s\n", $2, $4);
    
        // Ensure that the 3AC is printed
        print_3ac("=", $4, NULL, $2);
    
        // Free allocated memory
        free($2);  // Identifier (the left-hand side)
        free($4);  // Expression (the right-hand side)
    
        $$ = tac;  // Assign TAC string to $$ (for later use if needed)
    }
    | SPILL expression SEMICOLON NEWLINE {
        char* tac = (char*)malloc(128);
        snprintf(tac, 128, "spill %s\n", $2);
        print_3ac("spill", $2, NULL, NULL);
        free($2);
        $$ = tac;
    }
    | GRIND IDENTIFIER LT NUMBER COLON NEWLINE statements DEAD NEWLINE {
        char* loop_start = new_label();
        char* loop_end = new_label();
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());

        char* tac = (char*)malloc(256 + strlen($7));
        snprintf(tac, 256 + strlen($7),
                 "%s:\n%s = %s < %s\nif_false %s goto %s\n%s\ngoto %s\n%s:\n",
                 loop_start, temp_var, $2, $4, temp_var, loop_end, $7, loop_start, loop_end);

        print_label(loop_start);
        printf("%s = %s < %s\n", temp_var, $2, $4);
        printf("if_false %s goto %s\n", temp_var, loop_end);
        if ($7) printf("%s", $7);
        printf("goto %s\n", loop_start);
        print_label(loop_end);

        free(loop_start);
        free(loop_end);
        free(temp_var);
        free($2);
        free($4);
        free($7);
        $$ = tac;
    }
    | GRIND IDENTIFIER GT NUMBER COLON NEWLINE statements DEAD NEWLINE {
        char* loop_start = new_label();
        char* loop_end = new_label();
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());

        char* tac = (char*)malloc(256 + strlen($7));
        snprintf(tac, 256 + strlen($7),
                 "%s:\n%s = %s > %s\nif_false %s goto %s\n%s\ngoto %s\n%s:\n",
                 loop_start, temp_var, $2, $4, temp_var, loop_end, $7, loop_start, loop_end);

        print_label(loop_start);
        printf("%s = %s > %s\n", temp_var, $2, $4);
        printf("if_false %s goto %s\n", temp_var, loop_end);
        if ($7) printf("%s", $7);
        printf("goto %s\n", loop_start);
        print_label(loop_end);

        free(loop_start);
        free(loop_end);
        free(temp_var);
        free($2);
        free($4);
        free($7);
        $$ = tac;
    }
    | SLIDEIN IDENTIFIER OPAREN arg_list CPAREN SEMICOLON NEWLINE {
        // Generate TAC for the function call
        char* tac = (char*)malloc(128);
        
        if ($4) {
            // If there are arguments, generate code like "call function_name, arg1, arg2"
            snprintf(tac, 128, "call %s, %s\n", $2, $4);
            printf("call %s, %s\n", $2, $4);
            free($4);  // Free the argument list memory
        } else {
            // If no arguments, generate code like "call function_name"
            snprintf(tac, 128, "call %s\n", $2);
            printf("call %s\n", $2);
        }
        
        free($2);  // Free the function name (IDENTIFIER)
        $$ = tac;
    }
    | FR expression COLON NEWLINE statements NAH COLON NEWLINE statements DEAD NEWLINE {
        char* false_label = new_label();
        char* end_label = new_label();

        char* tac = (char*)malloc(256 + strlen($5) + strlen($9));
        snprintf(tac, 256 + strlen($5) + strlen($9),
                 "if_false %s goto %s\n%s\ngoto %s\n%s:\n%s%s:\n",
                 $2, false_label, $5, end_label, false_label, $9, end_label);

        printf("if_false %s goto %s\n", $2, false_label);
        if ($5) printf("%s", $5);
        printf("goto %s\n", end_label);
        print_label(false_label);
        if ($9) printf("%s", $9);
        print_label(end_label);

        free(false_label);
        free(end_label);
        free($2);
        free($5);
        free($9);
        $$ = tac;
    }
    | TEA IDENTIFIER OPAREN param_list CPAREN COLON NEWLINE statements DEAD NEWLINE {
        char* tac = (char*)malloc(128 + strlen($8));
        snprintf(tac, 128 + strlen($8), "%s:\n%sreturn\n", $2, $8);
        print_label($2);
        if ($8) printf("%s", $8);
        printf("return\n");
        free($2);
        if ($4) free($4);
        free($8);
        $$ = tac;
    }
    | IDENTIFIER EQUALS expression SEMICOLON NEWLINE {
        char* tac = (char*)malloc(128);
        snprintf(tac, 128, "%s = %s\n", $1, $3);
        print_3ac("=", $3, NULL, $1);
        free($1);
        free($3);
        $$ = tac;
    }
    ;

param_list:
    /* empty */ { $$ = NULL; }
    | param { $$ = $1; }
    | param_list COMMA param {
        char* new_list = (char*)malloc(strlen($1) + strlen($3) + 2);
        sprintf(new_list, "%s,%s", $1, $3);
        free($1);
        free($3);
        $$ = new_list;
    }
    ;

param:
    IDENTIFIER {
        print_3ac("param", $1, NULL, NULL);
        $$ = strdup($1);
    }
    ;

arg_list:
    /* empty */ { $$ = NULL; }
    | expression { $$ = $1; }
    | arg_list COMMA expression {
        char* new_list = (char*)malloc(strlen($1) + strlen($3) + 2);
        sprintf(new_list, "%s,%s", $1, $3);
        free($1);
        free($3);
        $$ = new_list;
    }
    ;

expression:
    IDENTIFIER { $$ = strdup($1); }
    | NUMBER { $$ = strdup($1); }
    | STRING_LITERAL { $$ = strdup($1); }
    | expression PLUS expression {
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());
        print_3ac("+", $1, $3, temp_var);
        free($1);
        free($3);
        $$ = temp_var;
    }
    | expression MINUS expression {
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());
        print_3ac("-", $1, $3, temp_var);
        free($1);
        free($3);
        $$ = temp_var;
    }
    | expression LT expression {
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());
        print_3ac("<", $1, $3, temp_var);
        free($1);
        free($3);
        $$ = temp_var;
    }
    | expression MULTIPLY expression {
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());
        print_3ac("*", $1, $3, temp_var);
        free($1);
        free($3);
        $$ = temp_var;
    }
    | expression GT expression {
        char* temp_var = (char*)malloc(20);
        snprintf(temp_var, 20, "t%d", new_temp_var());
        print_3ac(">", $1, $3, temp_var);
        free($1);
        free($3);
        $$ = temp_var;
    }
    ;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    extern char *yytext;
    extern int yylineno;
    printf("Syntax Error: %s (near token '%s' at line %d)\n", s, yytext, yylineno);
}