#include "instr.h"

int Temp::_num;
int Label::_num;
std::list<Instruction>   Instruction::_code;
std::map<int, Label*>    Instruction::_label_map;
