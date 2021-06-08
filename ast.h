

class Node {
public:    
    enum NodeType {
        INTEGER,
        FLOAT,
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