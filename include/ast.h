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
    
    static std::string print_tree_rec(Node* root){

        std::string result = ""; 
        switch (root->type)
        {
        case NodeType::INTEGER:
            result = std::to_string(root->val.ival) + " "; break;
        case NodeType::FLOAT:
            result = std::to_string(root->val.fval) + " "; break;
        case NodeType::STRING:
            result = std::string(root->val.sval) + " "; break;
        case NodeType::NUL:
            result = std::string("null "); break;
        case NodeType::LVALUE:
            result = std::string(root->val.sval) + " "; break;
        case NodeType::PLUS:
            result = std::string("+ "); break;
        case NodeType::MINUS:
            result = std::string("- "); break;
        case NodeType::UMINUS:
            result = std::string("- "); break;
        case NodeType::UPLUS:
            result = std::string("+ "); break;
        case NodeType::MOD:
            result = std::string("% "); break;
        case NodeType::DIV:
            result = std::string("/ "); break;
        case NodeType::TIMES:
            result = std::string("* "); break;
        default:
            break;
        }
        
        if(root->l) {
            result += print_tree_rec(root->l);
        }
        
        if(root->r) {
            result += print_tree_rec(root->r);
        }
        return result;        
    }
    
    static void print_tree(Node* root){
        printf("NumExpr Tree:\n");
        printf("%s\n", print_tree_rec(root).c_str());
        printf("\n");
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
            return result+std::string("% ");
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
