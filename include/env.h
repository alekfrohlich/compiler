#ifndef ENV_H
#define ENV_H

#include <stack>
#include <map>
#include <iostream>

#include "address.h"

using namespace std;

enum SymType : int {
    T_INT = 0,
    T_FLOAT,
    T_STRING,
    T_FUNC,
    T_ARRAY_REF,
};

struct Symbol : Address {
    Symbol(string i, SymType t) : id(i), type(t) {}
    string id;
    SymType type;
    virtual ostream& print(ostream& os) {
        return os << id;
    }
    void print2() { cout << id; }
    
    string get_type(){
        switch (type)
        {
        case SymType::T_INT:
            return "int"; break;
        case SymType::T_FLOAT:
            return "float"; break;
        case SymType::T_STRING:
            return "string"; break;
        case SymType::T_FUNC:
            return "func"; break;
        default:
            break;
        }
        return string("");
    }

};

class Env {
public:

    static void open_first_scope(int scope_type = 0) {
        // cout << "Opening Scope:" << endl;
        _stack.push(new Env(false));
    }

    static void open_scope(int scope_type = 0) {
        // cout << "Opening Scope:" << endl;
        bool inside_for = scope_type == 1 || Env::is_inside_for();
        _stack.push(new Env(inside_for));
    }

    static void close_scope() {
        Env * e = _stack.top();
        _stack.pop();
        // int ident = _stack.size();
        // cout << "Closing Scope:" << endl;
        // while (e) {
        //     for(map<string,int>::iterator iter = e->_table.begin(); iter != e->_table.end(); ++iter)
        //     {
        //         string id = iter->first;
        //         int type = iter->second;
        //         for (int i = 0; i < ident; i++)
        //             cout << '\t';
        //         cout << '{' << id << ',' << type << '}' << endl;
        //     }

        //     // iterate
        //     ident--;
        //     e = e->_prev;
        // }
    }

    static bool check_symbol_rec(string id){
        Env * e = _stack.top();
        while (e) {
            if (e->_table.find(id) != e->_table.end()) {
                // cout << id << endl;
                return false;
            }
            e = e->_prev;
        }
        return true;
    }

    static bool check_symbol_top(string id){
        Env * e = _stack.top();
        if (e->_table.find(id) != e->_table.end()) {
            // cout << id << endl;
            return false;
        }
        return true;
    }

    static bool check_put(string id, int type) {
        if (check_symbol_top(id)) {
            _stack.top()->_table.insert({id, new Symbol(id, SymType(type))});
            
            // print symbol table 
            for(int i=0;i<_stack.size()-1;i++){
                scope_vars += "  ";
            }
            scope_vars += _stack.top()->_table[id]->get_type() + " " +  id + "\n";
            
            return true;
        }
        return false;
    }

    static int get_type(string id) {
        Env * e = _stack.top();
        while (e) {
            if (e->_table.find(id) != e->_table.end()) {
                // cout << id << endl;
                return e->_table[id]->type;
            }
            e = e->_prev;
        }
        return -1;
    }

    static Symbol* get_symbol(string id, bool array_ref) {
        if (array_ref) {
            return new Symbol(id, SymType::T_ARRAY_REF);
        } else {
            Env * e = _stack.top();
            while (e) {
                if (e->_table.find(id) != e->_table.end()) {
                    // cout << id << endl;
                    return e->_table[id];
                }
                e = e->_prev;
            }
            return nullptr;
        }
    }

    static bool is_inside_for() {
        return Env::_stack.top()->_inside_for;
    }

public:
    static string scope_vars;


private:
    bool _inside_for;

    Env(bool inside_for): _inside_for(inside_for) {
        if (_stack.size() > 0)
            _prev = _stack.top();
        else
            _prev = nullptr;
    }

    static stack<Env*> _stack;
    map<string, Symbol*> _table;
    Env * _prev;
};

#endif
