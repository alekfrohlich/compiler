#ifndef INSTR_H
#define INSTR_H

#include <list>
#include <iostream>

struct Address {
    virtual std::ostream& print(std::ostream & os) { return os << "addr"; }
    friend std::ostream& operator<<(std::ostream& os, Address& a) {
        return a.print(os);
    }
};

struct Constant : public Address {

    Constant(int v) : val(v) {}
    int val;
    virtual std::ostream& print(std::ostream& os) {
        return os << val;
    }
};

struct Temp : public Address {

    Temp() {
        num = _num;
        _num++;
    }
    virtual std::ostream& print(std::ostream& os) {
        return os << "t" << num;
    }

    int num;
private:
    static int _num;
};

struct Symbol : public Address {
    virtual std::ostream& print(std::ostream& os) {
        return os << "x";
    }
};

enum IType : unsigned {
    PLUS = 0,
    TIMES,
    ASSIGN,
};
static const char* instr_name[] = {"add", "mul", "mov"};
static const int ops[] = {2, 2, 1};

struct Instruction {

    Instruction(IType t, Address *a1, Address *a2, Address *r) : type(t), arg1(a1), arg2(a2), result(r) {}

    IType type;
    Address* arg1;
    Address* arg2;
    Address* result;

    friend std::ostream& operator<<(std::ostream& os, const Instruction& i) {
        if (ops[i.type] == 2)
            return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.arg2 << ", " << *i.result;
        else
            return os << instr_name[i.type] << " " << *i.arg1 << ", " << *i.result;
    }

    static void gen(IType t, Address *a1, Address *a2, Address *r) {
        // std::cout << t << std::endl;
        _code.push_back(Instruction(t,a1,a2,r));
    }

    static void emit() {
        std:: cout << "Emitting ..." << std::endl;

        int size = _code.size();
        for (int i = 0; i < size; i++) {
            std:: cout << i << ") " << _code.front() << std::endl;
            _code.pop_front();
        }
        // int i = 0;
        // for (std::list<Instruction>::iterator it = _code.begin(); it != _code.end(); ++it, i++) {
        //     std::cout << i << ") " << *it << std::endl;
        // }
    }


private:
    static std::list<Instruction> _code;
};

#endif
