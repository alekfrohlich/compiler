#include "instr.h"

#include <list>
#include <map>
#include <stack>

int Temp::_num;
int Label::_num;
list<Instruction>   _code;
map<int, Label*>    _label_map;
stack<Label*>       _label_stack;

void gen(IType t, Address *a1, Address *a2, Address *r) {
    _code.push_back(Instruction(t,a1,a2,r));
}
void gen(IType t, Address *a1, Address *r) {
    _code.push_back(Instruction(t,a1,nullptr,r));
}
void gen(IType t, Address *a1, int label_num) {
    _code.push_back(Instruction(t,a1,nullptr,new Constant(label_num)));
}
void gen(IType t, int label_num) {
    _code.push_back(Instruction(t,nullptr,nullptr,new Constant(label_num)));
}
void gen(IType t) {
    _code.push_back(Instruction(t,nullptr,nullptr,nullptr));
}

void emit_code() {
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

int make_label() {
    Label * l = new Label(-1); // will be patched by attach_label
    _label_stack.push(l);
    return l->num;
}

// If the next line in the generated code is K, then attach the top most label
// to the line K+shift.
void attach_label(int shift) {
    Label * l = _label_stack.top();
    _label_stack.pop();
    l->line = _code.size() + shift;
    _label_map.insert(pair<int,Label*>(l->line, l));
}
