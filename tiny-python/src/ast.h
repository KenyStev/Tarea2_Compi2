#ifndef _AST_H_
#define _AST_H_

#include <string>
#include <list>
#include <map>

using namespace std;

extern map<string, int> vars;

int expt(int p, unsigned int q);

typedef struct codeData
{
    string code;
    string place;
} codeData_t ;

enum BuiltInFunct {
    FN_TIMECLOCK,
    FN_RANDSEED,
    FN_RANDINT
};

enum ExprKind {
  LT_EXPR,
  LTE_EXPR,
  GT_EXPR,
  GTE_EXPR,
  NE_EXPR,
  EQ_EXPR,
  ADD_EXPR,
  SUB_EXPR,
  MULT_EXPR,
  DIV_EXPR,
  MOD_EXPR,
  EXPT_EXPR,
  NUM_EXPR,
  ID_EXPR,
  STRING_EXPR,
  INPUT_EXPR,
  CALL_EXPR
};

class Expr;
typedef list<Expr*> ExprList;

class Expr {
public:
    virtual void genCode(codeData &) = 0;
    virtual int evaluate() = 0;
    virtual int getKind() = 0;
    bool isA(int kind) { return (getKind() == kind); }
};

class BinaryExpr: public Expr {
public:
    BinaryExpr(Expr *expr1, Expr *expr2) {
        this->expr1 = expr1;
        this->expr2 = expr2;
    }

    Expr *expr1;
    Expr *expr2;
};

class LTExpr: public BinaryExpr {
public:
    LTExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() < expr2->evaluate(); }
    int getKind() { return LT_EXPR; }
    void genCode(codeData &);
};

class GTExpr: public BinaryExpr {
public:
    GTExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() > expr2->evaluate(); }
    int getKind() { return GT_EXPR; }
    void genCode(codeData &);
};

class LTEExpr: public BinaryExpr {
public:
    LTEExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() <= expr2->evaluate(); }
    int getKind() { return LTE_EXPR; }
    void genCode(codeData &);
};

class GTEExpr: public BinaryExpr {
public:
    GTEExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() >= expr2->evaluate(); }
    int getKind() { return GTE_EXPR; }
    void genCode(codeData &);
};

class NEExpr: public BinaryExpr {
public:
    NEExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() != expr2->evaluate(); }
    int getKind() { return NE_EXPR; }
    void genCode(codeData &);
};

class EQExpr: public BinaryExpr {
public:
    EQExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() == expr2->evaluate(); }
    int getKind() { return NE_EXPR; }
    void genCode(codeData &);
};

class AddExpr: public BinaryExpr {
public:
    AddExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() + expr2->evaluate(); }
    int getKind() { return ADD_EXPR; }
    void genCode(codeData &);
};

class SubExpr: public BinaryExpr {
public:
    SubExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() - expr2->evaluate(); }
    int getKind() { return SUB_EXPR; }
    void genCode(codeData &);
};

class MultExpr: public BinaryExpr {
public:
    MultExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() * expr2->evaluate(); }
    int getKind() { return MULT_EXPR; }
    void genCode(codeData &);
};

class DivExpr: public BinaryExpr {
public:
    DivExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() / expr2->evaluate(); }
    int getKind() { return DIV_EXPR; }
    void genCode(codeData &);
};

class ModExpr: public BinaryExpr {
public:
    ModExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expr1->evaluate() % expr2->evaluate(); }
    int getKind() { return EXPT_EXPR; }
    void genCode(codeData &);
};

class ExponentExpr: public BinaryExpr {
public:
    ExponentExpr(Expr *expr1, Expr *expr2): BinaryExpr(expr1, expr2) {}

    int evaluate() { return expt(expr1->evaluate(), expr2->evaluate()); }
    int getKind() { return MOD_EXPR; }
    void genCode(codeData &);
};

class NumExpr: public Expr {
public:
    NumExpr(int value) { this->value = value; }
    int evaluate() { return value; }
    int getKind() { return NUM_EXPR; }
    void genCode(codeData &);

    int value;
};

class IdExpr: public Expr {
public:
    IdExpr(string id) { this->id = id; }
    int evaluate() { return vars[id]; }
    int getKind() { return ID_EXPR; }
    void genCode(codeData &);

    string id;
};

class StringExpr: public Expr {
public:
    StringExpr(string str) { this->str = str; }
    int evaluate() { return 0; }
    int getKind() { return STRING_EXPR; }
    void genCode(codeData &);

    string str;
};

class InputExpr: public Expr {
public:
    InputExpr(string prompt) { this->prompt = prompt; }
    int evaluate();
    int getKind() { return INPUT_EXPR; }
    void genCode(codeData &);

    string prompt;
};

class CallExpr: public Expr {
public:
    CallExpr(BuiltInFunct fnId) { 
        this->fnId = fnId; 
    }
    CallExpr(BuiltInFunct fnId, Expr *arg0, Expr *arg1) { 
        this->fnId = fnId;
        this->arg0 = arg0;
        this->arg1 = arg1;
    }
    int evaluate();
    int getKind() { return CALL_EXPR; }
    void genCode(codeData &);

    BuiltInFunct fnId;
    Expr *arg0, *arg1;
};

enum StatementKind {
    BLOCK_STATEMENT,
    PRINT_STATEMENT,
    ASSIGN_STATEMENT,
    IF_STATEMENT,
    WHILE_STATEMENT,
	FOR_STATEMENT,
	PASS_STATEMENT,
    CALL_STATEMENT
};

class Statement {
public:
    virtual void genCode(string &) = 0;
    virtual void execute() = 0;
    virtual StatementKind getKind() = 0;
};

class BlockStatement: public Statement {
public:
    BlockStatement() {}
    void execute();
    void genCode(string &);
    StatementKind getKind() { return BLOCK_STATEMENT; }
	void add(Statement *st) { stList.push_back(st); }

    list<Statement *> stList;
};


class AssignStatement: public Statement {
public:
    AssignStatement(string id, Expr *expr) {
        this->id = id;
        this->expr = expr;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return ASSIGN_STATEMENT; }

    string id;
    Expr *expr;
};

class PrintStatement: public Statement {
public:
    PrintStatement(ExprList lexpr) {
        this->lexpr = lexpr;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return PRINT_STATEMENT; }

    ExprList lexpr;
};

class IfStatement: public Statement {
public:
    IfStatement(Expr *cond, Statement *trueBlock, Statement *falseBlock) {
        this->cond = cond;
        this->trueBlock = trueBlock;
        this->falseBlock = falseBlock;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return IF_STATEMENT; }

    Expr *cond;
    Statement *trueBlock;
    Statement *falseBlock;
};

class PassStatement: public Statement {
public:
    PassStatement() {
    }
    void execute() {} ;
    void genCode(string &);
    StatementKind getKind() { return PASS_STATEMENT; }
};

class WhileStatement: public Statement {
public:
    WhileStatement(Expr *cond, Statement *block) {
        this->cond = cond;
        this->block = block;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return WHILE_STATEMENT; }

    Expr *cond;
    Statement *block;
};

class ForStatement: public Statement {
public:
    ForStatement(string id, Expr *startExpr, Expr *endExpr, Statement *block) {
        this->id = id;
        this->startExpr = startExpr;
        this->endExpr = endExpr;
        this->block = block;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return FOR_STATEMENT; }

    string id;
    Expr *startExpr;
    Expr *endExpr;
    Statement *block;
};

class CallStatement: public Statement {
public:
    CallStatement(BuiltInFunct fnId, Expr *arg0) {
        this->fnId = fnId;
        this->arg0 = arg0;
        this->arg1 = NULL;
    }
    CallStatement(BuiltInFunct fnId, Expr *arg0, Expr *arg1): CallStatement(fnId, arg0) {
        this->arg1 = arg1;
    }
    void execute();
    void genCode(string &);
    StatementKind getKind() { return CALL_STATEMENT; }

    BuiltInFunct fnId;
    Expr *arg0, *arg1;
};

#endif
