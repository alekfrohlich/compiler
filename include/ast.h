#ifndef AST_H
#define AST_H

class Node {
public:    
    enum NodeType {
        INTEGER,
        FLOAT,
        STRING,
        NUL,
        LVALUE,
        PLUS,
        MINUS,
        UMINUS,
        UPLUS,
        MOD,
        DIV,
        TIMES,
    };

    union ValueType {
        
        ValueType(int    val): ival(val) {}
        ValueType(double val): fval(val) {}
        ValueType(char*  val): sval(val) {}
        
        int    ival;
        double fval;
        char*  sval;
        
    };
    Node(NodeType nType, Node * left, Node * right, ValueType value) : type(nType), l(left), r(right), val(value) {}
    Node(NodeType nType, Node * left, Node * right) : type(nType), l(left), r(right), val(0) {}
    
    Node * l, * r;
    ValueType val;
    NodeType type;
    
    static void print_tree_rec(Node* root){
        if(root->l) {
            print_tree_rec(root->l);
        }
        printf("type:%d - ", root->type);
        if (root->type == NodeType::INTEGER){
            printf("value:%d; ", root->val.ival);
        }else if(root->type == NodeType::FLOAT){
            printf("value:%lf; ", root->val.fval);
        }else if(root->type == NodeType::STRING || root->type == NodeType::LVALUE){
            printf("value:%s; ", root->val.sval);
        }
        if(root->r) {
            print_tree_rec(root->r);
        }
    }
    
    static void print_tree(Node* root){
        printf("NumExpr Tree:\n");
        print_tree_rec(root);
        printf("\n\n");
    }
    
    static std::string print_tree_rec_array(Node* root){
        std::string l_str, r_str; 
        if(root->l) {
            l_str = print_tree_rec_array(root->l);
        }
        
        if(root->r) {
            r_str = print_tree_rec_array(root->r);
        }
        std::string result = l_str+r_str;
        
        switch (root->type)
        {
        case NodeType::INTEGER:
            return result+std::to_string(root->val.ival) + " ";
        case NodeType::FLOAT:
            return result+std::to_string(root->val.fval) + " ";
        case NodeType::STRING:
                return result+std::string(root->val.sval) + " ";
        case NodeType::NUL:
            return result+std::string("null ");
        case NodeType::LVALUE:
            return result+std::string(root->val.sval) + " ";
        case NodeType::PLUS:
            return result+std::string("+ ");
        case NodeType::MINUS:
            return result+std::string("- ");
        case NodeType::UMINUS:
            return result+std::string("- ");
        case NodeType::UPLUS:
            return result+std::string("+ ");
        case NodeType::MOD:
            return result+std::string("%% ");
        case NodeType::DIV:
            return result+std::string("/ ");
        case NodeType::TIMES:
            return result+std::string("* ");
        default:
            break;
        }
        return std::string("");
    }
    
};

#endif
