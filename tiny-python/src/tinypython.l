%option noyywrap
%option yylineno
%option nodefault

%{
#include <cstdlib>
#include <cstring>
#include <list>
#include "ast.h"
#include "tokens.h"

using namespace std;

list<int> tabs;
bool expectDedent = false;

%}

DIGIT [0-9]
LETTER [a-zA-Z]

%x eol

%%

"=" { return '='; }
"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }
"**" { return OP_EXP; }
"<" { return OP_LT; }
">" { return OP_GT; }
"<=" { return OP_LTE; }
">=" { return OP_GTE; }
"!=" { return OP_NE; }
"==" { return OP_EQ; }
"("  { return '('; }
")"  { return ')'; }
":"  { return ':'; }
","  { return ','; }
"if" { return KW_IF; }
"else" { return KW_ELSE; }
"while" { return KW_WHILE; }
"for" { return KW_FOR; }
"in" { return KW_IN; }
"range" { return KW_RANGE; }
"print" { return KW_PRINT; }
"input" { return KW_INPUT; }
"pass"  { return KW_PASS; }
"random.seed" { return KW_RANDSEED; }
"random.randint" { return KW_RANDINT; }
"time.clock" { return KW_TIMECLOCK; }
"'"[^']*"'" { yytext[yyleng-1] = '\0'; yylval.id_t = strdup(&yytext[1]); return STRING_LITERAL; }
"\""[^"]*"\"" { yytext[yyleng-1] = '\0'; yylval.id_t = strdup(&yytext[1]); return STRING_LITERAL; }
[ \t] { /* Nada */ }
"\n"  { expectDedent = true; BEGIN(eol); }
{DIGIT}+ { yylval.num_t = atoi(yytext); return TK_NUM; }
{LETTER}({DIGIT}|{LETTER}|_)* { yylval.id_t = strdup(yytext); return TK_ID; }
"#"[^\n]* { /* Nothing */ }
.   { printf("Line %d: Invalid symbol '%c'\n", yylineno, yytext[0]); }

<eol>"\n" { /* Nothing */ }
<eol>"#"[^\n]* { /* Nothing */ }
<eol>^" "+ {
	 	int curr_indent = tabs.back();

		if (yyleng > curr_indent) {
			tabs.push_back(yyleng);
			BEGIN(INITIAL);
			return TK_INDENT;
		} else if (yyleng < curr_indent) {
			tabs.pop_back();
			unput('\n');
			return TK_DEDENT;
		} else {
			expectDedent = false;
		}
	 }
<eol>. {
		unput(yytext[0]);
		int curr_indent = tabs.back();

		BEGIN(INITIAL);

		if (expectDedent && curr_indent > 0) {
			tabs.pop_back();
			unput('\n');
			return TK_DEDENT;
		} else {
			return TK_EOL;
		}
	}
<eol><<EOF>> {
				int curr_indent = tabs.back();

				BEGIN(INITIAL);

				if (expectDedent && curr_indent > 0) {
					tabs.pop_back();
					return TK_DEDENT;
				} else {
					return TK_EOL;
				}
			}

%%

void lexer_init() {
	tabs.push_back(0);
}
