#include <cstdio>
#include <ctime>
#include <cstdlib>
#include <iostream>
#include "ast.h"

using namespace std;

int lstringCount=0;//,varCount=0;

string temps[] = {"$t0","$t1","$t2","$t3","$t4","$t5","$t6","$t7","$t8","$t9"};
map<string, int> tempRegs;
map<string, int> vars;
map<string, string> lstrings;

void releaseTemp(string tmp)
{
    if(tempRegs[tmp]!=0)
    {
        tempRegs[tmp]=0;
    }
}

string nextTemp()
{
    for (int i = 0; i < 10; ++i)
        if (tempRegs.find(temps[i]) == tempRegs.end() || tempRegs[temps[i]] == 0)
        {
            tempRegs[temps[i]] = 1;
            return temps[i];
        }
    return "";
}

string nextLstringFor(string str)
{
    if(lstrings.find(str) == lstrings.end())
    {
        lstrings[str] = "lstring" + to_string(lstringCount++);
    }
    return lstrings[str];
}

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


/* Generating Code */

#define gen(name) void name##Expr::genCode(codeData &data){}
#define genS(name) void name##Statement::genCode(string &code){}
#define genAdditiveCode(name,func) void name##Expr::genCode(codeData &data) \
{   \
    codeData re, le;    \
    expr1->genCode(le); \
    expr2->genCode(re); \
    data.code = le.code + "\n" + re.code + "\n";    \
    releaseTemp(le.place);  \
    releaseTemp(re.place);  \
    data.place = nextTemp();    \
    data.code += #func " " + data.place + ", " + le.place + ", " + re.place;   \
}
#define genDivCode(name,reg) void name##Expr::genCode(codeData &data) \
{  \
    codeData re, le;  \
    expr1->genCode(le); \
    expr2->genCode(re); \
    data.code = le.code + "\n" + re.code + "\n";  \
    releaseTemp(le.place);  \
    releaseTemp(re.place);  \
    data.place = nextTemp();    \
    data.code += "move $a0, " + le.place + "\n";    \
    data.code += "move $a1, " + re.place + "\n";    \
    data.code += "addi $sp, -8\n";  \
    data.code += "move $a2, $sp\n"; \
    data.code += "addi $a3, $sp, 4\n";  \
    data.code += "jal divide\n" ;   \
    data.code += "lw " + data.place + ", ($" #reg ")\n";  \
    data.code += "addi $sp, $sp, 8";    \
}   
#define genRelCode(name,func) void name##Expr::genCode(codeData &data)  \
{   \
    codeData le, re;    \
    expr1->genCode(le); \
    expr2->genCode(re); \
    data.code = le.code + "\n" + re.code + "\n";    \
    releaseTemp(le.place);  \
    releaseTemp(re.place);  \
    data.place = nextTemp();    \
    data.code += #func " " + data.place + ", " + le.place + ", " + re.place;   \
}

void NumExpr::genCode(codeData &data)
{
    data.place = nextTemp();
    data.code = "li " + data.place + ", " + to_string(value);
}

void StringExpr::genCode(codeData &data)
{
    data.place = nextTemp();
    data.code = "la " + data.place + ", "+nextLstringFor(str);
}

void IdExpr::genCode(codeData &data)
{
    data.place = nextTemp();
    data.code = "lw " + data.place + ", " + id;
}

genAdditiveCode(Add,add);
genAdditiveCode(Sub,sub);

void MultExpr::genCode(codeData &data)
{  
    codeData re, le;  
    expr1->genCode(le);
    expr2->genCode(re);
    data.code = le.code + "\n" + re.code + "\n";  
    releaseTemp(le.place);
    releaseTemp(re.place); 
    data.place = nextTemp();

    data.code += "move $a0, " + le.place + "\n";
    data.code += "move $a1, " + re.place + "\n";
    data.code += "jal mult\n" ; 
    data.code += "move " + data.place + ", $v0";
}

genDivCode(Div,a2);
genDivCode(Mod,a3);

void ExponentExpr::genCode(codeData &data)
{
    codeData re, le;  
    expr1->genCode(le);
    expr2->genCode(re);
    data.code = le.code + "\n" + re.code + "\n";  
    releaseTemp(le.place);
    releaseTemp(re.place); 
    data.place = nextTemp();

    data.code += "move $a0, " + le.place + "\n";
    data.code += "move $a1, " + re.place + "\n";
    data.code += "jal exponent\n"; 
    data.code += "move " + data.place + ", $v0";
}

genRelCode(LT,slt);
genRelCode(GT,sgt);
genRelCode(LTE,sle);
genRelCode(GTE,sge);
genRelCode(NE,sne);
genRelCode(EQ,seq);

// gen(Input);
void InputExpr::genCode(codeData &data)
{
    data.place = "$v0";
    data.code = "la $a0, "+nextLstringFor(prompt)+"\n";
    data.code += "jal puts\n";
    data.code += ".get_key_loop:\n\tjal keypad_getkey\n\tbeqz $v0, .get_key_loop";
    data.code += "\n\nli $a0, '\\n' \njal put_char";
}

// gen(Call);
void CallExpr::genCode(codeData &data)
{
    switch (fnId) {
        case FN_TIMECLOCK: {
            data.place = "$v0";
            data.code = "lw $v0, MS_COUNTER_REG_ADDR\n";
            //data.code += "jal rand_seed";
            return;
        }
        case FN_RANDINT: {
            codeData la, ra;
            arg0->genCode(la);
            arg1->genCode(ra);
            data.code = la.code + "\n" + ra.code + "\n";
            releaseTemp(la.place);
            releaseTemp(ra.place);
            data.place = nextTemp();

            data.code += "sub " + data.place + ", " + ra.place + ", "+la.place+"\n";
            data.code += "addi " + data.place + ", 1\n";
            data.code += "move $a0, "+data.place+"\n";
            data.code += "jal rand\n";

            data.code += "move $a0, $v0\n";  
            data.code += "move $a1, " + data.place + "\n";   
            data.code += "addi $sp, -8\n"; 
            data.code += "move $a2, $sp\n";
            data.code += "addi $a3, $sp, 4\n"; 
            data.code += "jal divide\n" ;  
            data.code += "lw " + data.place + ", ($a3)\n"; 
            data.code += "addi $sp, $sp, 8\n";

            data.code += "add $v0, "+data.place+", "+la.place;
            releaseTemp(data.place);
            data.place = "$v0";
        }
    }
}

// Statements
void PrintStatement::genCode(string &code)
{
    list<Expr *>::iterator it = lexpr.begin();
    code = "# PrintStatement\n";

    while (it != lexpr.end()) {
        Expr *expr = *it;

        codeData cd;
        expr->genCode(cd);
        code += "\n"+cd.code;
        releaseTemp(cd.place);
        code += "\nmove $a0, " + cd.place;
        
        if (expr->isA(STRING_EXPR))
            code += "\njal puts";
        else
            code += "\njal put_udecimal";
        it++;
    }
    code += "\n\nli $a0, '\\n' \njal put_char";

    // printf("code:\n%s\n", code.c_str());
}

// genS(Call);
void CallStatement::genCode(string &code)
{
    code = "# CallStatement\n";
    switch (fnId) {
        case FN_RANDSEED: {
            codeData cd;
            arg0->genCode(cd);
            code += cd.code + "\n";
            code += "move $a0, "+cd.place+"\n";
            code += "jal rand_seed";
            releaseTemp(cd.place);
        }
        default: {
            
        }
    }
}

// genS(Assign);
void AssignStatement::genCode(string &code)
{
    vars[id] = 0;
    // int result = expr->evaluate();
    codeData cd;
    expr->genCode(cd);

    code = "# AssignStatement\n";
    code += cd.code+"\n";
    releaseTemp(cd.place);
    code += "sw " + cd.place + ", " + id;
}

// genS(Block);
void BlockStatement::genCode(string &code)
{
    list<Statement *>::iterator it = stList.begin();
    code = "";
    while (it != stList.end()) {
        Statement *st = *it;

        string c;
        st->genCode(c);
        code += "\n"+c+"\n";
        // st->execute();
        it++;
    }
}

genS(If);
genS(While);
genS(For);
genS(Pass);