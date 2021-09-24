#include "env.h"

stack<Env *> Env::_stack;
std::string Env::scope_vars = "";
