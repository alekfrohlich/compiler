#ifndef INSTR_H
#define INSTR_H

#include <list>
#include <map>
#include <iostream>
// #include <iomanip>

using namespace std;

struct Address {
    virtual ostream& print(ostream & os) { return os << "addr"; }
    friend  ostream& operator<<(ostream& os, Address& a) {
        return a.print(os);
    }
};

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

struct Symbol : public Address {
    virtual ostream& print(ostream& os) {
        return os << "x";
    }
};

struct Label {
    int  num;
    int  line;
    Label(int l) : num(_num), line(l) { _num++; }
    static int get_num() { return _num; }
    friend ostream& operator<<(ostream& os, Label& l) { return os << "L00" << l.num; }
private:
    static int _num;
};

enum IType : unsigned {
    PLUS = 0,
    TIMES,
    ASSIGN,
    IFFALSE,
};
static const char* instr_name[] = {"add", "mul", "mov", "ifF"};
// static const int ops[] = {2, 2, 1, 1};

struct Instruction {

    // For instructions with three operands: add, sub, mul, div,
    Instruction(IType t, Address *a1, Address *a2, Address *r) : type(t), arg1(a1), arg2(a2), result(r) {}
    // For instructions with two operands or with labels: uminus, assign
    Instruction(IType t, Address *a1, Address *r) : type(t), arg1(a1), arg2(nullptr), result(r) {}
    // For instructions with labels:
    // Labels are treated as constans
    Instruction(IType t, Address *a1) {
        type = t; arg1 = a1; arg2 = nullptr;
        //!FIXME: line should be the line of the attached label and not the label number.
        Label * l = new Label(Label::get_num());
        _label_map.insert(pair<int,Label*>(Label::get_num(), l));
        result = new Constant(l->num);
    }

    IType type;
    Address* arg1;
    Address* arg2;
    Address* result;

    friend ostream& operator<<(ostream& os, const Instruction& i) {
        switch(i.type) {
            case PLUS:
            case TIMES:
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.arg2 << ", " << *i.result;
            case ASSIGN:
                return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.result;
            case IFFALSE:
                return os << "ifF " << *i.arg1 << " goto L" << *i.result;
        }
    }

    static void gen(IType t, Address *a1, Address *a2, Address *r) {
        _code.push_back(Instruction(t,a1,a2,r));
    }
    static void gen(IType t, Address *a1, Address *r) {
        _code.push_back(Instruction(t,a1,r));
    }
    static void gen(IType t, Address *a1) {
        _code.push_back(Instruction(t,a1));
    }

    static void emit() {
        cout << "Emitting ..." << endl;

        int size = _code.size();
        for (int i = 0; i < size; i++) {
            // Set width of the ostream
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

#endif
