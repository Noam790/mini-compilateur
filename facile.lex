%{
#include <assert.h>
#include "facile.y.h"
%}

%option yylineno

%%

if {
    assert(printf("'if' found\n"));
    return TOK_IF;
}

then {
    assert(printf("'then' found\n"));
    return TOK_THEN;
}

else {
    assert(printf("'else' found\n"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'else' found\n"));
    return TOK_ELSEIF;
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

(0|[1-9][0-9]*) {
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
