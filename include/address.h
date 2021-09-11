#ifndef ADDR_H
#define ADDR_H

#include <iostream>

using namespace std;

struct Address {
    virtual ostream& print(ostream & os) { return os << "addr"; }
    friend  ostream& operator<<(ostream& os, Address& a) {
        return a.print(os);
    }
};

#endif
