#include <fstream>
#include <iostream>
#include <string>
#include <map>
#include <cstdio>
#include "ast.h"
#include "tokens.h"

extern Statement *input;
extern FILE *yyin;
extern int yylineno;
extern map<string, int> vars;
extern map<string, string> lstrings;

using namespace std;

void fillTemplate(string &code)
{
	string header = "#include \"screen.h\"\n";
	header += 		"#include \"system.h\"\n";
	header += 		".global main\n\n";
	header +=		".data\n";

	string varsData = "";
	for (map<string,int>::iterator it=vars.begin(); it!=vars.end(); ++it)
	{
		// cout << it->first << " => " << it->second << '\n';
		varsData += "\t" + it->first + ": .word " + to_string(it->second) + "\n";
	}

	string lstringsData = "\n\n";
	for (map<string,string>::iterator it=lstrings.begin(); it!=lstrings.end(); ++it)
	{
		// cout << it->first << " => " << it->second << '\n';
		lstringsData += string("\t") + it->second + ": .asciz \"" + it->first + "\"\n";
	}

	string mainStart = 	".text\n\n";
	mainStart +=		"main:\n";

    mainStart += 		"\tli $a0, BRIGHT_WHITE\n";
    mainStart +=		"\tli $a1, BLACK\n";
    mainStart +=		"\tjal set_color\n";
    mainStart +=		"\tjal clear_screen\n\n";

    string finalLine = "\tjr $ra";

    code = header + varsData + lstringsData + mainStart + code + finalLine;
}

void lexer_init();

int main(int argc, char *argv[])
{
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <input file> [output file]\n", argv[0]);
		return 1;
	}
	yyin  = fopen(argv[1], "rb");

	if (yyin == NULL) {
		fprintf(stderr, "Cannot open file %s\n", argv[1]);
		return 2;
	}
	const char* outputFile = (argc==3)?argv[2]:"outputFile.S";

	yylineno = 1;
	lexer_init();
    input = NULL;
    yyparse();

    string MIPS32_CODE;
    if (input != 0) {
    	input->genCode(MIPS32_CODE);
        // input->execute();
    }
    fillTemplate(MIPS32_CODE);
    printf("%s\n", MIPS32_CODE.c_str());

    ofstream out(outputFile);
    out << MIPS32_CODE;
    out.close();
    return 0;
}
