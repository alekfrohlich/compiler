#ifndef AST_H
#define AST_H

class Node {
public:    
    enum NodeType {
        INTEGER,
        FLOAT,
        STRING,
        PLUS,
        MINUS,
        UMINUS,
        UPLUS,
        MOD,
        DIV,
        TIMES,
    };

    union ValueType {
        
        ValueType(int val): ival(val) {}
        ValueType(double val): fval(val) {}
        
        int ival;
        double fval;
        
    };
    Node(NodeType nType, Node * left, Node * right, ValueType value) : type(nType), l(left), r(right), val(value) {}
    
    Node * l, * r;
    ValueType val;
    NodeType type;
};

#endif
