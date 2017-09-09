#include <cstdio>
#include "ast.h"
#include "tokens.h"

extern Statement *input;
extern FILE *yyin;
extern int yylineno;

void lexer_init();

int main(int argc, char *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
		return 1;
	}
	yyin  = fopen(argv[1], "rb");

	if (yyin == NULL) {
		fprintf(stderr, "Cannot open file %s\n", argv[1]);
		return 2;
	}

	yylineno = 1;
	lexer_init();
    input = NULL;
    yyparse();

    if (input != 0) {
        input->execute();
    }
}
