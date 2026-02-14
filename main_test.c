#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
extern int yyparse(void);

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    int parse_result = yyparse();

    fclose(yyin);
    return parse_result;
}