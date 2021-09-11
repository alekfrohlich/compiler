#ifndef INSTR_H
#define INSTR_H

#include <list>
#include <map>
#include <iostream>

#include "address.h"

using namespace std;

struct Constant : public Address {

    Constant(int v) : val(v) {}
    int val;
    virtual ostream& print(ostream& os) {
        return os << val;
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

// struct Symbol : public Address {
//     virtual ostream& print(ostream& os) {
//         return os << "x";
//     }
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
    LT,
    GT,
    LTE,
    GTE,
    EQ,
    NEQ,
};
static const char* instr_name[] = {"add", "sub", "mul", "div", "mod", "mov", "uplus", "uminus", "ifF", "lt", "gt", "lte", "gte", "eq", "neq"};
// static const int ops[] = {2, 2, 1, 1};

struct Instruction {

    // For instructions with three operands: add, sub, mul, div, mod
    Instruction(IType t, Address *a1, Address *a2, Address *r) : type(t), arg1(a1), arg2(a2), result(r) {}
    // For instructions with two operands or with labels: uplus, uminus, mov
    Instruction(IType t, Address *a1, Address *r) : type(t), arg1(a1), arg2(nullptr), result(r) {}
    // For instructions with labels: ifF
    // Labels are treated as constans
    Instruction(IType t, Address *a1) {
        type = t; arg1 = a1; arg2 = nullptr;
        Label * l = new Label(_code.size());
        //!FIXME: labels are currently at the same address as their goto's
        _label_map.insert(pair<int,Label*>(_code.size(), l));
        result = new Constant(l->num);
    }

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
        }
    }

    friend void gen(IType t, Address *a1, Address *a2, Address *r);
    friend void gen(IType t, Address *a1, Address *r);
    friend void gen(IType t, Address *a1);

    static void emit() {
        int size = _code.size();
        cout << "Emitting " << size << " instructions ..." << endl;

        for (int i = 0; i < size; i++) {
            auto l = _label_map.find(i);
            if (l != _label_map.end()) {
                cout << *(l->second) << ": ";
            } else {
                cout << "      ";
            }
            cout << i << ") " << _code.front() << endl;
            _code.pop_front();
        }
    }


private:
    static list<Instruction> _code;
    static map<int, Label*> _label_map;
};

void gen(IType t, Address *a1, Address *a2, Address *r);
void gen(IType t, Address *a1, Address *r);
void gen(IType t, Address *a1);

#endif
