#ifndef INSTR_H
#define INSTR_H

#include <iostream>

#include "address.h"

using namespace std;

struct Constant : public Address {

    Constant(int v)    : ival(v) {type = 0;}
    Constant(double v) : fval(v) {type = 1;}
    Constant(string v) : sval(v) {type = 2;}
    Constant()                   {type = 3;} //null
    int ival;
    double fval;
    string sval;
    int type;
    
    virtual ostream& print(ostream& os) {
        if(type==0){
            return os << ival;    
        }else if(type==1){
            return os << fval;
        }else if(type==2){
            return os << sval;
        }else if(type==3){
            return os << "null";
        }
        return os << ival;
    }
};

struct Temp : public Address {

    Temp() {
        num = _num;
        _num++;
    }
    virtual ostream& print(ostream& os) {
        return os << "t" << num;
    }

    int num;
private:
    static int _num;
};

// struct ArrayRef : public Address {

//     ArrayRef(string r) : ref(r) {}
//     virtual ostream& print(ostream& os) {
//         return os << ref;
//     }
//     string ref;
// };

struct Label {
    int  num;
    int  line;
    Label(int l) : num(_num), line(l) { _num++; }
    static int get_num() { return _num; }
    friend ostream& operator<<(ostream& os, Label& l) { return os << "L00" << l.num; } // Only handles first 10 labels correctly
private:
    static int _num;
};

enum IType : unsigned {
    PLUS = 0,
    MINUS,
    TIMES,
    DIV,
    MOD,
    ASSIGN,
    UPLUS,
    UMINUS,
    IFFALSE,
    GOTO,
    LT,
    GT,
    LTE,
    GTE,
    EQ,
    NEQ,
    RET,
};
static const char* instr_name[] = {"add", "sub", "mul", "div", "mod", "mov", "uplus", "uminus", "ifF", "goto", "lt", "gt", "lte", "gte", "eq", "neq", "ret"};

struct Instruction {

    Instruction(IType t, Address *a1, Address *a2, Address *r) : type(t), arg1(a1), arg2(a2), result(r) {}

    IType type;
    Address* arg1;
    Address* arg2;
    Address* result;

    friend ostream& operator<<(ostream& os, const Instruction& i) {
        switch(i.type) {
            default:
            case PLUS:
            case MINUS:
            case TIMES:
            case DIV:
            case MOD:
            case LT:
            case GT:
            case LTE:
            case GTE:
            case EQ:
            case NEQ:
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.arg2 << ", " << *i.result;
            case ASSIGN:
            case UPLUS:
            case UMINUS:
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.result;
            case IFFALSE:
                return os << "ifF " << *i.arg1 << " goto L" << *i.result;
            case GOTO:
                return os << "goto L" << *i.result;
            case RET:
                return os << "ret";
        }
    }
};

void gen(IType t, Address *a1, Address *a2, Address *r);
void gen(IType t, Address *a1, Address *r);
void gen(IType t, Address *a1, int label_num);
void gen(IType t, int label_num);
void gen(IType t);
void emit_code();
int  make_label();
void attach_label(int shift=0);
void attach_label_at(int);
int  get_next_line();

#endif
