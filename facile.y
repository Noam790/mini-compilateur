%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <glib.h>

extern int yylex(void);
int yyerror(const char *msg);
extern int yylineno;

char *module_name;
FILE *stream;
GHashTable *table;
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

#ifndef FACILE_TEST
int main(int argc, char *argv[]) {
    if (argc == 2) {
        char *file_name_input = argv[1];
        char *extension;
        char *directory_delimiter;
        char *basename;

        extension = rindex(file_name_input, '.');
        if (!extension || strcmp(extension, ".facile") != 0) {
            fprintf(stderr, "Input filename extension must be '.facile'\n");
            return EXIT_FAILURE;
        }

        directory_delimiter = rindex(file_name_input, '/');
        if (!directory_delimiter) {
            directory_delimiter = rindex(file_name_input, '\\');
        }

        if (directory_delimiter) {
            basename = strdup(directory_delimiter + 1);
        } else {
            basename = strdup(file_name_input);
        }

        module_name = strdup(basename);
        *rindex(module_name, '.') = '\0';
        strcpy(rindex(basename, '.'), ".il");

        char *onechar = module_name;
        if (!isalpha(*onechar) && *onechar != '_') {
            free(basename);
            fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
            return EXIT_FAILURE;
        }

        onechar++;
        while (*onechar) {
            if (!isalnum(*onechar) && *onechar != '_') {
                free(basename);
                fprintf(stderr, "Base input filename cannot contains special characters\n");
                return EXIT_FAILURE;
            }
            onechar++;
        }

        if (stdin = fopen(file_name_input, "r")) {
            if (stream = fopen(basename, "w")) {
                table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
                yyparse();
                g_hash_table_destroy(table);
                fclose(stream);
                fclose(stdin);
            } else {
                free(basename);
                fclose(stdin);
                fprintf(stderr, "Output filename cannot be opened\n");
                return EXIT_FAILURE;
            }
        } else {
            free(basename);
            fprintf(stderr, "Input filename cannot be opened\n");
            return EXIT_FAILURE;
        }

        free(basename);
    } else {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
#endif