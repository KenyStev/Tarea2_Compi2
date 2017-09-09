#include <cstdio>
#include <ctime>
#include <cstdlib>
#include <iostream>
#include "ast.h"

using namespace std;

map<string, int> vars;

int expt(int p, unsigned int q)
{
    int r = 1;

    while (q != 0) {
        if (q % 2 == 1) {    // q is odd
            r *= p;
            q--;
        }
        p *= p;
        q /= 2;
    }

    return r;
}

int InputExpr::evaluate()
{
	int result;

	cout << prompt;
	fflush(stdin);
	scanf("%d", &result);

	return result;
}

int CallExpr::evaluate()
{
    switch (fnId) {
        case FN_TIMECLOCK: return clock();
        case FN_RANDINT: {
            int start = arg0->evaluate();
            int end = arg1->evaluate();
            int range = end - start + 1;
            
            return (rand() % range) + start;
        }
        default:
            return 0;
    }
}

void BlockStatement::execute()
{
    list<Statement *>::iterator it = stList.begin();

    while (it != stList.end()) {
        Statement *st = *it;

        st->execute();
        it++;
    }
}

void PrintStatement::execute()
{
  list<Expr *>::iterator it = lexpr.begin();

  while (it != lexpr.end()) {
    Expr *expr = *it;

    if (expr->isA(STRING_EXPR)) {
      printf("%s", ((StringExpr*)expr)->str.c_str());
    } else {
      int result = expr->evaluate();
      printf("%d", result);
    }

    it++;
  }
  printf("\n");
}

void AssignStatement::execute()
{
    int result = expr->evaluate();
    vars[id] = result;
}

void IfStatement::execute()
{
    int result = cond->evaluate();

    if (result) {
        trueBlock->execute();
    } else if (falseBlock != 0) {
        falseBlock->execute();
    }
}

void WhileStatement::execute()
{
  int result = cond->evaluate();

  while (result) {
    block->execute();

    result = cond->evaluate();
  }
}

void ForStatement::execute()
{
	int val = startExpr->evaluate();
  	vars[id] = val;

	val = endExpr->evaluate();
	while (vars[id] < val) {
		block->execute();
		vars[id] = vars[id] + 1;
	}
}

void CallStatement::execute()
{
    switch (fnId) {
        case FN_RANDSEED: {
            int arg = arg0->evaluate();
            srand(arg);
        }
        default: {
            
        }
    }
}