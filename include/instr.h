#ifndef INSTR_H
#define INSTR_H

// This file implements code related to 3-address instructions.
//
//   An instruction is a quadruple (Type, Arg1, Arg2, Res), where Type is one of
// the enumerated types (see IType) and Arg1, Arg2, and Res are all addresses. The
// theory behind addresses can be found in any standard book (e.g., Aho's Dragon Book)
// so we will assume it to be known. `Address` is a base class which is derived by `Constant`,
// `Temp`, and `Symbol`. See each class for more info. Instructions are generated during
// parsing (Syntax Directed Translation) and are stored in a global list named `_code`. Instead
// of using syntax attributes to hold instructions, we've opted to emit them incrementally.
// The contents of `_code` - that is, all the instructions corresponding to a xpp program - are
// printed when the parser performs it's final reduction. Yes, the underlying parser is LALR(1);
// typical Bison+Flex stuff. Labels generated by branching instructions are discussed inside the
// `Label` class. Finally, functions are also labeled in the final output so as to improve readability.

#include <iostream>
#include <iomanip>

#include "address.h"

using namespace std;

struct Constant : public Address {
    //   Constants may hold: an integer, a float, a string, or NULL. They may be used anywhere
    // an arithmetical expression is used. Note that this includes declarations, such as the following
    //
    // string s;
    // s = null;
    //
    // Furthermore, Constants are used to implement label numbers in `ifFalse` and `goto`, and are
    // used to store the number of parameters to a `call` instruction.

    Constant(int v)    : ival(v) {type = 0;}
    Constant(double v) : fval(v) {type = 1;}
    Constant(string v) : sval(v) {type = 2;}
    Constant()                   {type = 3;} // null
    int     ival;
    double  fval;
    string  sval;
    int     type;

    virtual ostream& print(ostream& os) {
        if (type == 0) {
            return os << ival;
        } else if (type == 1) {
            return os << fval;
        } else if (type == 2) {
            return os << sval;
        } else if (type == 3) {
            return os << "null";
        }
        return os << ival;
    }
};

struct Temp : public Address {

    //   Temporaries are used to store temporary results of arithmetical expressions.
    // They are needed to convert arbitrary expressions into 3-address form; e.g.,
    //
    // int x;
    // x = 2+3*5;
    //
    // will be translated as:
    //
    // mul 3, 5, t0
    // add 2, t0, t1
    // mov t1, x
    //
    // Observe that temporaries' names follow the convention tn where n is incremented
    // whenever a temporary is created (see `Temp::_num`).

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

struct Label {
    //   Labels are used to mark positions in code. For example, consider the translation of
    //
    //     0) if (1) { x = 2; }
    //     1) y = 3;
    //
    //     0) ifFalse 1 goto L0
    //     1) mov 2, x
    // L0: 2) mov 3, y
    //
    // Its purpose is similar to that of labels in other low level languanges such as C.
    // Labels are stored in `_label_map`, which maps lines of the generated code to labels.
    // The last label would be stored as the key value pair (2, Label).
    // In our implementation, labels are usually created before they are attached to a particular
    // line of code. The reasoning for this varies. Consider the last example. There may be arbitrarily
    // many instructions between the `ifFalse` of line 0 and the instruction `mov 3, y`. Thus, we also use
    // a stack (`_label_stack`) for storing unnattached labels. We use a stack since there may be many unnatached
    // labels at a given time (there may be an if statement inside an if statement inside ...)

    int  num;
    int  line;
    Label(int l) : num(_num), line(l) { _num++; }
    static int get_num() { return _num; } //<< setw(3) << setfill('0')
    friend ostream& operator<<(ostream& os, Label& l) { return os << string("L") + to_string(l.num); }
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
    CALL,
    PARAM,
    UPLUS,
    UMINUS,
    IFFALSE,
    GOTO,
    BREAK_,
    LT,
    GT,
    LTE,
    GTE,
    EQ,
    NEQ,
    RET,
    PRINT_,
    READ_,
    NOP,
    ALLOC,
};
static const char* instr_name[] = {"add", "sub", "mul", "div", "mod", "mov", "call", "param", "uplus", "uminus", "ifF", "goto", "break", "lt", "gt", "lte", "gte", "eq", "neq", "ret", "print", "read", "nop", "new"};

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
            if(i.arg1==nullptr || i.arg2==nullptr || i.result==nullptr) return os << "var not declared!!!";
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.arg2 << ", " << *i.result;
            case ASSIGN:
            case CALL:
            case UPLUS:
            case UMINUS:
                if(i.arg1==nullptr || i.result==nullptr) return os << "var not declared!!!";
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.result;
            case IFFALSE:
                if(i.arg1==nullptr || i.result==nullptr) return os << "var not declared!!!";
                return os << "ifF " << *i.arg1 << " goto L" << *i.result;
            case GOTO:
                if(i.result==nullptr) return os << "var not declared!!!";
                return os << "goto L" << *i.result;
            case ALLOC:
            case PARAM:
            case PRINT_:
            case READ_:
                if(i.arg1==nullptr) return os << "var not declared!!!";
                return os << instr_name[i.type] << " " << *i.arg1;
            case RET:
            case NOP:
            case BREAK_:
                return os << instr_name[i.type];
        }
    }
};

// `gen` is overloaded multiple times to make xpp.y more readable.
void gen(IType t, Address *a1, Address *a2, Address *r);
void gen(IType t, Address *a1, Address *r);
void gen(IType t, Address *a1, int num);
void gen(IType t, Address *a1);
void gen(IType t, int num);
void gen(IType t);
void emit_code();
// Label stuff
int  make_label();
void attach_label(int shift=0);
void attach_label_at(int);
void attach_function(string f_id);
int  get_next_line();

#endif
