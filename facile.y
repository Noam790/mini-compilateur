%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
int yyerror(const char *msg);
extern int yylineno;
%}

/* CONDITIONALS */
%token TOK_IF 258
%token TOK_THEN 259
%token TOK_ELSE 260
%token TOK_ELSEIF 261
%token TOK_ENDIF 262
%token TOK_DO 263
%token TOK_ENDWHILE 264
%token TOK_WHILE 265

/* MACROS */
%token TOK_BREAK 266
%token TOK_CONTINUE 267
%token TOK_END 268
%token TOK_READ 269
%token TOK_PRINT 270

/* OPERATORS */
%token TOK_AFFECTATION 271
%token TOK_SEMI_COLON 272
%token TOK_ADD 273
%token TOK_SUB 274
%token TOK_MUL 275
%token TOK_DIV 276

/* BOOLEANS */
%token TOK_TRUE 277
%token TOK_FALSE 278
%token TOK_NOT 279
%token TOK_AND 280
%token TOK_OR 281

/* SYMBOLS */
%token TOK_OPENING_PARENTHESIS 282
%token TOK_CLOSING_PARENTHESIS 283
%token TOK_SHARP 284

/* COMPARATORS */
%token TOK_INFERIOR_THAN 285
%token TOK_SUPERIOR_THAN 286
%token TOK_INFERIOR_EQUAL 287
%token TOK_SUPERIOR_EQUAL 288
%token TOK_EQUAL 289

/* TERMINALS */
%token TOK_NUMBER 290
%token TOK_IDENTIFIER 291


%define parse.error verbose

%%

program:
    code
;

code:
    /* */
    | code instruction
;

instruction:
    affectation | condition | print | while | read
;

affectation:
    TOK_IDENTIFIER TOK_AFFECTATION expression TOK_SEMI_COLON
;

expression:
      TOK_IDENTIFIER
    | TOK_NUMBER
    | boolean
    | expression TOK_ADD expression
    | expression TOK_MUL expression
    | expression TOK_SUB expression
    | expression TOK_DIV expression
    | TOK_OPENING_PARENTHESIS expression TOK_CLOSING_PARENTHESIS
;

boolean:
    TOK_TRUE | TOK_FALSE
    | expression TOK_EQUAL expression
    | expression TOK_SUPERIOR_THAN expression
    | expression TOK_INFERIOR_THAN expression
    | expression TOK_SUPERIOR_EQUAL expression
    | expression TOK_INFERIOR_EQUAL expression
    | expression TOK_SHARP expression
    | TOK_NOT boolean
    | boolean TOK_OR boolean
    | boolean TOK_AND boolean
    | TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS

condition:
      TOK_IF TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS
      TOK_THEN code
      conditions_end
    ;

conditions_end:
    TOK_ELSEIF TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS TOK_THEN code conditions_end
    | TOK_ELSE code endif
    | endif
;

endif:
    TOK_END | TOK_ENDIF
;


while:
    TOK_WHILE TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS TOK_DO code_while endwhile

code_while:
    /* */ | code_while TOK_CONTINUE | code_while TOK_BREAK | code_while instruction

endwhile:
    TOK_END | TOK_ENDWHILE

read:
    TOK_READ TOK_IDENTIFIER TOK_SEMI_COLON

print:
    TOK_PRINT TOK_IDENTIFIER TOK_SEMI_COLON

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
    return 0;
}

int main(void) {
    return yyparse();
}
