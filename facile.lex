%{
#include <assert.h>

// CONDITIONALS
#define TOK_IF 258
#define TOK_THEN 259
#define TOK_ENDIF 260
#define TOK_DO 261
#define TOK_ENDWHILE 262
#define TOK_WHILE 263

// MACROS
#define TOK_BREAK 264
#define TOK_CONTINUE 265
#define TOK_END 266
#define TOK_READ 267
#define TOK_PRINT 268

// OPERATORS
#define TOK_AFFECTATION 269
#define TOK_SEMI_COLON 270
#define TOK_ADD 271
#define TOK_SUB 272
#define TOK_MUL 273
#define TOK_DIV 274

// BOOLEANS
#define TOK_TRUE 275
#define TOK_FALSE 276
#define TOK_NOT 277
#define TOK_AND 278
#define TOK_OR 279

// SYMBOLS
#define TOK_OPENING_PARENTHESIS 280
#define TOK_CLOSING_PARENTHESIS 281
#define TOK_SHARP 282

// COMPARATORS
#define TOK_INFERIOR_THAN 283
#define TOK_SUPERIOR_THAN 284
#define TOK_INFERIOR_EQUAL 285
#define TOK_SUPERIOR_EQUAL 286
#define TOK_EQUAL 287

// NON_TERMINAL
#define TOK_NUMBER 288
#define TOK_IDENTIFIER 289

%}

%%

if {
    assert(printf("'if' found\n"));
    return TOK_IF;
}

then {
    assert(printf("'then' found\n"));
    return TOK_THEN;
}

endif {
    assert(printf("'endif' found\n"));
    return TOK_ENDIF;
}

while {
    assert(printf("'while' found\n"));
    return TOK_WHILE;
}

do {
    assert(printf("'do' found\n"));
    return TOK_DO;
}

endwhile {
    assert(printf("'endwhile' found\n"));
    return TOK_ENDWHILE;
}

break {
    assert(printf("'break' found\n"));
    return TOK_BREAK;
}

continue {
    assert(printf("'continue' found\n"));
    return TOK_CONTINUE;
}

end {
    assert(printf("'end' found\n"));
    return TOK_END;
}

read {
    assert(printf("'read' found\n"));
    return TOK_READ;
}

print {
    assert(printf("'print' found\n"));
    return TOK_PRINT;
}

";" {
    assert(printf("';' found\n"));
    return TOK_SEMI_COLON;
}

":=" {
    assert(printf("':=' found\n"));
    return TOK_AFFECTATION;
}

"=" {
    assert(printf("'=' found\n"));
    return TOK_EQUAL;
}

"+" {
    assert(printf("'+' found\n"));
    return TOK_ADD;
}

"-" {
    assert(printf("'-' found\n"));
    return TOK_SUB;
}

"*" {
    assert(printf("'*' found\n"));
    return TOK_MUL;
}

"/" {
    assert(printf("'/' found\n"));
    return TOK_DIV;
}

and {
    assert(printf("'and' found\n"));
    return TOK_AND;
}

or {
    assert(printf("'or' found\n"));
    return TOK_OR;
}

not {
    assert(printf("'not' found\n"));
    return TOK_NOT;
}

true {
    assert(printf("'true' found\n"));
    return TOK_TRUE;
}

false {
    assert(printf("'false' found\n"));
    return TOK_FALSE;
}

"(" {
    assert(printf("'(' found\n"));
    return TOK_OPENING_PARENTHESIS;
}

")" {
    assert(printf("')' found\n"));
    return TOK_CLOSING_PARENTHESIS;
}

"#" {
    assert(printf("'#' found\n"));
    return TOK_SHARP;
}

"<" {
    assert(printf("'<' found\n"));
    return TOK_INFERIOR_THAN;
}

">" {
    assert(printf("'>' found\n"));
    return TOK_SUPERIOR_THAN;
}

"<=" {
    assert(printf("'<=' found\n"));
    return TOK_INFERIOR_EQUAL;
}

">=" {
    assert(printf("'>=' found\n"));
    return TOK_SUPERIOR_EQUAL;
}

^(0|[1-9][0-9]*)$ {
    assert(printf("number found\n"));
    return TOK_NUMBER;
}

[a-zA-Z][a-zA-Z0-9_]* {
    assert(printf("identifier '%s(%d)' found\n", yytext, yyleng));
    return TOK_IDENTIFIER;
}

[ \t\n] ;
. {
    return yytext[0];
}

%%
/*
* file: facile.lex
* version: 0.3.0
*/
