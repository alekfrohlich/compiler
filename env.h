#ifndef ENV_H
#define ENV_H

#include <stack>
#include <map>
#include <iostream>

enum SymType : int {
    T_INT = 0,
    T_FLOAT,
    T_STRING,
    T_FUNC,
};

// class Symbol {
//     //!TODO: add attributes and use appropriate types
// public:
//     Symbol (int t) : _type(t) {}
//     int _type;
// };

class Env {
public:

    static void open_first_scope(int scope_type = 0) {
        std::cout << "Opening Scope:" << std::endl;
        _stack.push(new Env(false));    
    }
    
    static void open_scope(int scope_type = 0) {
        std::cout << "Opening Scope:" << std::endl;
        bool inside_for = scope_type == 1 || _stack.top()->is_inside_for();
        _stack.push(new Env(inside_for));    
    }

    static void close_scope() { 
        Env * e = _stack.top();
        _stack.pop();
        int ident = _stack.size();
        std::cout << "Closing Scope:" << std::endl;
        while (e) {
            for(std::map<std::string,int>::iterator iter = e->_table.begin(); iter != e->_table.end(); ++iter)
            {
                std::string id = iter->first;
                int type = iter->second;
                for (int i = 0; i < ident; i++)
                    std::cout << '\t';
                std::cout << '{' << id << ',' << type << '}' << std::endl;
            }

            // iterate
            ident--;
            e = e->_prev;
        }
    }
    
    static bool check_symbol(std::string id){
        Env * e = _stack.top();
        while (e) {
            if (e->_table.find(id) != e->_table.end()) {
                std::cout << id << std::endl;
                return false;
            }
            e = e->_prev;
        }
        return true;
    }
    
    static bool check_put(std::string id, int type) {
        if (check_symbol(id)) {
            _stack.top()->_table.insert({id, type});
            return true;
        }
        return false;
    }
    
    static void remove(std::string id) {}
    static void get(std::string) {}
    
    bool is_inside_for() {
        return _inside_for;
    }

public:
    static std::stack<Env*> _stack;

private:
    bool _inside_for;
    
    Env(bool inside_for): _inside_for(inside_for) {
        if (_stack.size() > 0)
            _prev = _stack.top();
        else
            _prev = nullptr;
    }
    
    // void put_in_env(std::string id, Symbol sym) {}
    // void remove_in_env(std::string id) {}
    // void get_in_env(std::string) {}
    
    std::map<std::string, int> _table;
    Env * _prev;
};

#endif
