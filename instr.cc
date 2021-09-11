#include "instr.h"

int Temp::_num;
int Label::_num;
list<Instruction>   Instruction::_code;
map<int, Label*>    Instruction::_label_map;
