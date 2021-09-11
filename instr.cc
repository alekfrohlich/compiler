#include "instr.h"

int Temp::_num;
int Label::_num;
list<Instruction>   Instruction::_code;
map<int, Label*>    Instruction::_label_map;

void gen(IType t, Address *a1, Address *a2, Address *r) {
    Instruction::_code.push_back(Instruction(t,a1,a2,r));
}
void gen(IType t, Address *a1, Address *r) {
    Instruction::_code.push_back(Instruction(t,a1,r));
}
void gen(IType t, Address *a1) {
    Instruction::_code.push_back(Instruction(t,a1));
}
