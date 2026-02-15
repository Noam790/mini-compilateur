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

void begin_code(void);
void end_code(void);
void produce_code(GNode *node);
%}

%code requires {
    #include <glib.h>
}

%union {
    gulong number;
    gchar *string;
    GNode * node;
}

/* CONDITIONALS */
%token TOK_IF "if"
%token TOK_THEN "then"
%token TOK_ELSE "else"
%token TOK_ELSEIF "elseif"
%token TOK_ENDIF "endif"
%token TOK_DO "do"
%token TOK_ENDWHILE "endwhile"
%token TOK_WHILE "while"

/* MACROS */
%token TOK_BREAK "break"
%token TOK_CONTINUE "continue"
%token TOK_END "end"
%token TOK_READ "read"
%token TOK_PRINT "print"

/* OPERATORS */
%token TOK_AFFECTATION ":="
%token TOK_SEMI_COLON ";"
%left TOK_ADD "+"
%left TOK_SUB "-"
%left TOK_MUL "*"
%left TOK_DIV "/"

/* BOOLEANS */
%token TOK_TRUE "true"
%token TOK_FALSE "false"
%right TOK_NOT "not"
%left TOK_AND "and"
%left TOK_OR "or"

/* SYMBOLS */
%token TOK_OPENING_PARENTHESIS "("
%token TOK_CLOSING_PARENTHESIS ")"
%token TOK_SHARP "#"

/* COMPARATORS */
%token TOK_INFERIOR_THAN "<"
%token TOK_SUPERIOR_THAN ">"
%token TOK_INFERIOR_EQUAL "<="
%token TOK_SUPERIOR_EQUAL ">="
%token TOK_EQUAL "="

/* TERMINALS */
%token<number> TOK_NUMBER "number"
%token<string> TOK_IDENTIFIER "identifier"

%type<node> code
%type<node> expression
%type<node> instruction
%type<node> identifier
%type<node> print
%type<node> read
%type<node> affectation
%type<node> number
%type<node> program
%type<node> boolean
%type<node> condition
%type<node> conditions_end
%type<node> endif
%type<node> while
%type<node> code_while
%type<node> endwhile

%define parse.error verbose

%%

program:
    code {
        begin_code();
        produce_code($1);
        end_code();
        g_node_destroy($1);
    }
;

code:
    code instruction {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
        |
    {
        $$ = g_node_new("");
    }
;

instruction:
    affectation | condition | print | while | read
;

affectation:
    identifier TOK_AFFECTATION expression TOK_SEMI_COLON
    {
        $$ = g_node_new("affectation");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
;

print:
    TOK_PRINT expression TOK_SEMI_COLON
    {
        $$ = g_node_new("print");
        g_node_append($$, $2);
    }
;

read:
    TOK_READ identifier TOK_SEMI_COLON
    {
        $$ = g_node_new("read");
        g_node_append($$, $2);
    }
;



expression:
      identifier
    | number
    | boolean
    | expression TOK_ADD expression
        {
            $$ = g_node_new("add");
            g_node_append($$, $1);
            g_node_append($$, $3);
        }
    | expression TOK_MUL expression
        {
            $$ = g_node_new("mul");
            g_node_append($$, $1);
            g_node_append($$, $3);
        }
    | expression TOK_SUB expression
        {
            $$ = g_node_new("sub");
            g_node_append($$, $1);
            g_node_append($$, $3);
        }
    | expression TOK_DIV expression
        {
            $$ = g_node_new("div");
            g_node_append($$, $1);
            g_node_append($$, $3);
        }
    | TOK_OPENING_PARENTHESIS expression TOK_CLOSING_PARENTHESIS
        {
            $$ = $2;
        }
;

identifier:
    TOK_IDENTIFIER
    {
        $$ = g_node_new("identifier");
        gulong value = (gulong) g_hash_table_lookup(table, $1);

        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($1), (gpointer) value);
        }
        g_node_append_data($$, (gpointer)value);
    }
;

number:
    TOK_NUMBER
    {
        $$ = g_node_new("number");
        g_node_append_data($$, (gpointer)$1);
    }
;


boolean:
      TOK_TRUE {
          $$ = g_node_new("true");
      }
    | TOK_FALSE {
          $$ = g_node_new("false");
      }
    | expression TOK_EQUAL expression {
          $$ = g_node_new("equal");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | expression TOK_SUPERIOR_THAN expression {
          $$ = g_node_new("superior");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | expression TOK_INFERIOR_THAN expression {
          $$ = g_node_new("inferior");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | expression TOK_SUPERIOR_EQUAL expression {
          $$ = g_node_new("superior_equal");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | expression TOK_INFERIOR_EQUAL expression {
          $$ = g_node_new("inferior_equal");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | expression TOK_SHARP expression {
          $$ = g_node_new("sharp");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | TOK_NOT boolean {
          $$ = g_node_new("not");
          g_node_append($$, $2);
      }
    | boolean TOK_OR boolean {
          $$ = g_node_new("or");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | boolean TOK_AND boolean {
          $$ = g_node_new("and");
          g_node_append($$, $1);
          g_node_append($$, $3);
      }
    | TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS {
          $$ = $2;
      }
;

condition:
      TOK_IF TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS
      TOK_THEN code
      conditions_end {
          $$ = g_node_new("if");
          g_node_append($$, $3);
          g_node_append($$, $6);
          g_node_append($$, $7);
      }
;

conditions_end:
      TOK_ELSEIF TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS
      TOK_THEN code conditions_end {
          $$ = g_node_new("elseif");
          g_node_append($$, $3);
          g_node_append($$, $6);
          g_node_append($$, $7);
      }
    | TOK_ELSE code endif {
          $$ = g_node_new("else");
          g_node_append($$, $2);
          g_node_append($$, $3);
      }
    | endif {
          $$ = $1;
      }
;

endif:
      TOK_END {
          $$ = g_node_new("end");
      }
    | TOK_ENDIF {
          $$ = g_node_new("endif");
      }
;

while:
      TOK_WHILE TOK_OPENING_PARENTHESIS boolean TOK_CLOSING_PARENTHESIS
      TOK_DO code_while endwhile {
          $$ = g_node_new("while");
          g_node_append($$, $3);
          g_node_append($$, $6);
          g_node_append($$, $7);
      }
;

code_while:
    code_while TOK_CONTINUE {
          $$ = g_node_new("continue");
      }
    | code_while TOK_BREAK {
          $$ = g_node_new("break");
      }
    | code_while instruction {
          $$ = g_node_new("code_while");
          g_node_append($$, $1);
          g_node_append($$, $2);
      }
;

endwhile:
      TOK_END {
          $$ = g_node_new("end");
      }
    | TOK_ENDWHILE {
          $$ = g_node_new("endwhile");
      }
;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
    return 0;
}

void produce_code(GNode *node)
{
    if (!node || !node->data) return;

    const char *type = (const char *)node->data;

    if (g_strcmp0(type, "code") == 0) {
        GNode *c0 = g_node_nth_child(node, 0);
        GNode *c1 = g_node_nth_child(node, 1);
        if (c0) produce_code(c0);
        if (c1) produce_code(c1);
    }
    else if (g_strcmp0(type, "affectation") == 0) {
        GNode *id = g_node_nth_child(node, 0);
        GNode *expr = g_node_nth_child(node, 1);
        if (expr) produce_code(expr);
        if (id) {
            GNode *id_val = g_node_nth_child(id, 0);
            if (id_val)
                fprintf(stream, " stloc\t%ld\n", (long)GPOINTER_TO_INT(id_val->data) - 1);
        }
    }
    else if (g_strcmp0(type, "add") == 0 ||
             g_strcmp0(type, "sub") == 0 ||
             g_strcmp0(type, "mul") == 0 ||
             g_strcmp0(type, "div") == 0) {
        GNode *left = g_node_nth_child(node, 0);
        GNode *right = g_node_nth_child(node, 1);
        if (left) produce_code(left);
        if (right) produce_code(right);
        if (g_strcmp0(type, "add") == 0) fprintf(stream, " add\n");
        else if (g_strcmp0(type, "sub") == 0) fprintf(stream, " sub\n");
        else if (g_strcmp0(type, "mul") == 0) fprintf(stream, " mul\n");
        else if (g_strcmp0(type, "div") == 0) fprintf(stream, " div\n");
    }
    else if (g_strcmp0(type, "number") == 0) {
        GNode *num = g_node_nth_child(node, 0);
        if (num)
            fprintf(stream, " ldc.i4\t%ld\n", (long)GPOINTER_TO_INT(num->data));
    }
    else if (g_strcmp0(type, "identifier") == 0) {
        GNode *id_val = g_node_nth_child(node, 0);
        if (id_val)
            fprintf(stream, " ldloc\t%ld\n", (long)GPOINTER_TO_INT(id_val->data) - 1);
    }
    else if (g_strcmp0(type, "print") == 0) {
        GNode *expr = g_node_nth_child(node, 0);
        if (expr) produce_code(expr);
        fprintf(stream, " call void class [mscorlib]System.Console::WriteLine(int32)\n");
    }
    else if (g_strcmp0(type, "read") == 0) {
        GNode *id = g_node_nth_child(node, 0);
        fprintf(stream, " call string class [mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, " call int32 int32::Parse(string)\n");
        if (id) {
            GNode *id_val = g_node_nth_child(id, 0);
            if (id_val)
                fprintf(stream, " stloc\t%ld\n", (long)GPOINTER_TO_INT(id_val->data) - 1);
        }
    }
    else if (g_strcmp0(type, "if") == 0 || g_strcmp0(type, "elseif") == 0 ||
             g_strcmp0(type, "else") == 0) {
        GNode *cond = g_node_nth_child(node, 0);
        GNode *then_code = g_node_nth_child(node, 1);
        GNode *else_code = g_node_nth_child(node, 2);

        if (cond) produce_code(cond);
        if (then_code) produce_code(then_code);
        if (else_code) produce_code(else_code);
    }
    else if (g_strcmp0(type, "while") == 0) {
        GNode *cond = g_node_nth_child(node, 0);
        GNode *body = g_node_nth_child(node, 1);
        if (cond) produce_code(cond);
        if (body) produce_code(body);
    }
    else if (g_strcmp0(type, "continue") == 0 ||
             g_strcmp0(type, "break") == 0 ||
             g_strcmp0(type, "end") == 0 ||
             g_strcmp0(type, "endwhile") == 0) {
        return;
    }
    else {
        for (GNode *child = node->children; child != NULL; child = child->next) {
            produce_code(child);
        }
    }
}


void begin_code(void)
{
    fprintf(stream, ".assembly extern mscorlib {}\n");
    fprintf(stream, ".assembly %s {}\n", module_name);
    fprintf(stream, ".method static void Main() cil managed {\n");
    fprintf(stream, ".entrypoint\n");
    fprintf(stream, ".maxstack 32\n");
}

void end_code(void)
{
    fprintf(stream, " ret\n");
    fprintf(stream, "}\n");
}


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