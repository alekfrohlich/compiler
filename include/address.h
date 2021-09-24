#ifndef ADDR_H
#define ADDR_H

//   This file implements `Address`. It is not meant to be instantiated; see it's
// derived classes in `instr.h`. This class exists basically to make printing easier.

#include <iostream>

using namespace std;

struct Address {
    virtual ostream& print(ostream & os) { return os << "addr"; }
    friend  ostream& operator<<(ostream& os, Address& a) { return a.print(os); }
};

#endif
