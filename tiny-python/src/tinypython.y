%{
#include <cstdio>
#include <string>
#include "ast.h"

using namespace std;

extern int yylineno;

int yylex();

void yyerror(const char *str)
{
    printf("Line %d: %s\n", yylineno, str);
}

#define YYERROR_VERBOSE 1

Statement *input;
%}

%union {
    char *id_t;
    int  num_t;
    Statement *statement_t;
	BlockStatement *blkstatement_t;
    Expr *expr_t;
    ExprList *exprlist_t;
}

%token<num_t> TK_NUM
%token<id_t> TK_ID
%token<id_t> STRING_LITERAL
%token KW_IF KW_ELSE KW_WHILE KW_FOR KW_IN KW_RANGE KW_PRINT KW_INPUT KW_PASS
%token KW_RANDINT KW_RANDSEED KW_TIMECLOCK
%token TK_INDENT TK_DEDENT
%token TK_EOL
%token OP_EXP OP_LT OP_GT OP_LTE OP_GTE OP_NE OP_EQ
%type<expr_t> argument expra expr term exponent factor
%type<statement_t> print_statement assign_statement if_statement while_statement for_statement pass_statement
%type<statement_t> statement opt_else statement_block
%type<statement_t> call_statement
%type<blkstatement_t> statement_list
%type<exprlist_t> arg_list

%%

input: opt_eols statement_list opt_eols { input = $2; }
;

statement_list: statement_list eols statement { $$ = $1; $$->add($3); }
              | statement { $$ = new BlockStatement; $$->add($1); }
;

eols: TK_EOL
;

opt_eols: eols
		|
;

statement: print_statement
		  | assign_statement
		  | for_statement
		  | while_statement
		  | if_statement
		  | pass_statement
		  | call_statement
;

print_statement: KW_PRINT '(' arg_list ')' { $$ = new PrintStatement(*$3); delete $3;}
;

arg_list: arg_list ',' argument {
	    $$ = $1;
	    $$->push_back($3);
	  }
	| argument {
	    $$ = new ExprList;
	    $$->push_back($1);
	  }
;

argument: expr { $$ = $1; }
	| STRING_LITERAL {
	    string str = $1;

	    free($1);
        $$ = new StringExpr(str);
        //codeData c; $$->genCode(c);
	}
;

assign_statement: TK_ID '=' expr {
				string id = $1;

				free($1);
	 			$$ = new AssignStatement(id, $3);
		}
;

if_statement: KW_IF expr ':' statement_block eols opt_else { $$ = new IfStatement($2, $4, $6); }
;

opt_else: KW_ELSE ':' statement_block { $$ = $3; }
		 |                            { $$ = NULL; }
;

while_statement: KW_WHILE expr ':' statement_block { $$ = new WhileStatement($2, $4); }
;

for_statement: KW_FOR TK_ID KW_IN KW_RANGE '(' expr ',' expr ')' ':' statement_block {
				string id = $2;

				free($2);
				$$ = new ForStatement(id, $6, $8, $11);
}
;

pass_statement: KW_PASS { $$ = new PassStatement(); }
;

call_statement: KW_RANDSEED '(' expr ')'            { $$ = new CallStatement(FN_RANDSEED, $3); }
;

statement_block: TK_INDENT statement_list TK_DEDENT  { $$ = $2; }
;

expr: expr OP_LT expra  { $$ = new LTExpr($1, $3); }
    | expr OP_GT expra  { $$ = new GTExpr($1, $3); }
    | expr OP_LTE expra { $$ = new LTEExpr($1, $3); }
    | expr OP_GTE expra { $$ = new GTEExpr($1, $3); }
    | expr OP_NE expra  { $$ = new NEExpr($1, $3); }
    | expr OP_EQ expra    { $$ = new EQExpr($1, $3); }
    | expra             { $$ = $1; }
;

expra: expra '+' term   { $$ = new AddExpr($1, $3); }
    | expra '-' term    { $$ = new SubExpr($1, $3); }
    | term              { $$ = $1; }
;

term: term '*' exponent   { $$ = new MultExpr($1, $3); }
    | term '/' exponent   { $$ = new DivExpr($1, $3); }
    | term '%' exponent   { $$ = new ModExpr($1, $3); }
    | exponent            { $$ = $1; }
;

exponent: factor OP_EXP exponent { $$ = new ExponentExpr($1, $3); }
	    | factor { $$ = $1; }
;

factor: '(' expr ')'    { $$ = $2; }
        | '-' factor    { $$ = new MultExpr(new NumExpr(-1), $2); }
		| TK_NUM           { $$ = new NumExpr($1); }
		| KW_INPUT '(' STRING_LITERAL ')' {
					string text = $3;
					free($3);

					$$ = new InputExpr(text);
					codeData c; $$->genCode(c);
				}
        | TK_ID {
            string id = $1;

            free($1);
            $$ = new IdExpr(id);
        }
        | KW_TIMECLOCK '(' ')' { $$ = new CallExpr(FN_TIMECLOCK); }
        | KW_RANDINT '(' expr ',' expr ')'  { $$ = new CallExpr(FN_RANDINT, $3, $5); }
;

%%
