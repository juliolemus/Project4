%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>
    #include "ast.hpp"
    
    #define YYDEBUG 1
    int yylex(void);
    void yyerror(const char *);
    
    extern ASTNode* astRoot;
%}

%error-verbose

/* WRITEME: Copy your token and precedence specifiers from Project 3 here */
%token T_INTEGER
%token T_PLUS
%token T_MINUS
%token T_DIVIDE
%token T_MULT
%token T_OR
%token T_AND
%token T_LESS
%token T_EQUAL
%token T_EQUALEQ
%token T_LESSEQ
%token T_NOT
%token T_ID
%token T_OPENBRACKET
%token T_CLOSEBRACKET
%token T_OPENPAREN
%token T_CLOSEPAREN
%token T_TRUE
%token T_FALSE
%token T_IF
%token T_SEMICOLON
%token T_ELSE
%token T_PRINT
%token T_FOR
%token T_NEW 
%token T_INT
%token T_BOOL
%token T_NONE
%token T_DOTOP
%token T_EOF
%token T_COMMA
%token U_MINUS
%token T_COLON
%token T_RETURN

%left T_OR
%left T_AND
%left T_LESS T_LESSEQ T_EQUALEQ
%left T_PLUS T_MINUS 
%left T_MULT T_DIVIDE 
%right T_NOT U_MINUS


/* WRITEME: Specify types for all nonterminals and necessary terminals here */
%type <expression_ptr> Exp;
%type <returnstatement_ptr> Return;
%type <methodcall_ptr> MethodCall;
%type <identifier_ptr> T_ID;
%type <assignment_ptr> Assignment;
%type <expression_list_ptr> Params Params_P; 
%type <parameter_ptr> Argument;
%type <parameter_list_ptr> Args Arg;
%type <integer_ptr> T_INTEGER T_TRUE T_FALSE;
%type <statement_ptr> Stmnt;
%type <statement_list_ptr> Block Stmnts;
%type <ifelse_ptr> IFELSE;
%type <for_ptr> FORLOOP;
%type <declaration_list_ptr> Members Declrs;
%type <declaration_ptr> Member;
%type <identifier_list_ptr> Declr;
%type <type_ptr> Type ReturnType;
%type <integertype_pt> T_INT;
%type <booleantype_ptr> T_BOOL;
%type <methodbody_ptr> Body;
%type <method_ptr> Method;
%type <method_list_ptr> Methods;
%type <class_ptr> Class;
%type <class_list_ptr> Classes;
%type <program_ptr> Start;



%%

Start : Classes {$$=new ProgramNode($1);astRoot=$$;}
      ;

Classes : Classes Class {$$=$1; $$->push_back($2);}
        | Class {$$=new std::list<ClassNode*>(); $$->push_back($1);}
        ;

Class : T_ID T_COLON T_ID T_OPENBRACKET Members Methods T_CLOSEBRACKET {$$=new ClassNode($1,$3,$5,$6);}
      | T_ID T_OPENBRACKET Members Methods T_CLOSEBRACKET {$$=new ClassNode($1,NULL,$3,$4);}
      ;

Members : Members Member {$$=$1; $$->push_back($2);}
        | {$$=new std::list<DeclarationNode*>();}
        ;

Member : Type T_ID {$$=new DeclarationNode($1,new std::list<IdentifierNode*>(1,$2));}
       ;      

Type : T_INT  {$$=new IntegerTypeNode();}
     | T_BOOL {$$=new BooleanTypeNode();} 
     | T_ID   {$$=new ObjectTypeNode($1);}
     ;

Methods : Method Methods {$$=$2,$$->push_front($1);} //fix
        | {$$=new std::list<MethodNode*>();}
        ;

Method : T_ID T_OPENPAREN Args T_CLOSEPAREN T_COLON ReturnType T_OPENBRACKET Body T_CLOSEBRACKET  {$$=new MethodNode($1,$3,$6,$8);}
       ;

Args : Arg {$$=$1;}
     | {$$=new std::list<ParameterNode*>();} 
     ;

Arg  : Arg T_COMMA Argument {$$=$1; $$->push_back($3);}
     | Argument {$$=new std::list<ParameterNode*>(); $$->push_back($1);}
     ;

Argument : Type T_ID {$$=new ParameterNode($1,$2);}
         ;
ReturnType : Type {$$=$1;}
           | T_NONE {$$=new NoneNode();}
           ;

Body : Declrs Stmnts Return {$$=new MethodBodyNode($1,$2,$3);}
     ;

Declrs : Declrs Type Declr {$$=$1; $$->push_back(new DeclarationNode($2,$3));}
       | {$$=new std::list<DeclarationNode*>();}
       ;

Declr : Declr T_COMMA T_ID {$$=$1; $$->push_back($3);}
      | T_ID {$$=new std::list<IdentifierNode*>(); $$->push_back($1);}
      ;      

Stmnts : Stmnt Stmnts {$$=$2;$$->push_front($1);}
       | {$$=new std::list<StatementNode*>();} 
       ;

Stmnt  : Assignment {$$=$1;}
       | MethodCall {$$=new CallNode($1);}
       | IFELSE     {$$=$1;}
       | FORLOOP    {$$=$1;}
       | T_PRINT Exp {$$=new PrintNode($2);}
       ;

Assignment : T_ID T_EQUAL Exp {$$=new AssignmentNode($1,$3);}
           ;

IFELSE : T_IF Exp T_OPENBRACKET Block T_CLOSEBRACKET    {$$=new IfElseNode($2,$4,NULL);}
       | T_IF Exp T_OPENBRACKET Block T_CLOSEBRACKET T_ELSE T_OPENBRACKET Block T_CLOSEBRACKET {$$=new IfElseNode($2,$4,$8);}
       ;

FORLOOP : T_FOR Assignment T_SEMICOLON Exp T_SEMICOLON Assignment T_OPENBRACKET Block T_CLOSEBRACKET  {$$=new ForNode($2,$4,$6,$8);}
        ;

Block : Block Stmnt {$$->push_back($2);}
      | Stmnt {$$=new std::list<StatementNode*>(); $$->push_back($1);}
      ;

Return : T_RETURN Exp {$$=new ReturnStatementNode($2);}
       | {$$=NULL;}
       ;

Exp : Exp T_PLUS Exp     {$$=new PlusNode($1,$3);}
    | Exp T_MINUS Exp    {$$=new MinusNode($1,$3);}
    | Exp T_MULT Exp     {$$=new TimesNode($1,$3);}
    | Exp T_DIVIDE Exp   {$$=new DivideNode($1,$3);}
    | Exp T_LESS Exp     {$$=new LessNode($1,$3);}
    | Exp T_LESSEQ Exp   {$$=new LessEqualNode($1,$3);}
    | Exp T_EQUALEQ Exp  {$$=new EqualNode($1,$3);}
    | Exp T_AND Exp      {$$=new AndNode($1,$3);}
    | Exp T_OR Exp       {$$=new OrNode($1,$3);}
    | T_NOT Exp          {$$=new NotNode($2);}
    | T_MINUS Exp %prec U_MINUS      {$$=new NegationNode($2);}
    | T_ID                           {$$=new VariableNode($1);}
    | T_ID T_DOTOP T_ID              {$$=new MemberAccessNode($1,$3);}
    | MethodCall                     {$$=$1;}
    | T_OPENPAREN Exp T_CLOSEPAREN   {$$=$2;}
    | T_INTEGER    {$$=new IntegerLiteralNode($1);} 
    | T_TRUE       {$$=new BooleanLiteralNode($1);} 
    | T_FALSE      {$$=new BooleanLiteralNode($1);}
    | T_NEW T_ID   {$$=new NewNode($2,NULL);} 
    | T_NEW T_ID T_OPENPAREN Params T_CLOSEPAREN {$$=new NewNode($2,$4);}
    ;

MethodCall : T_ID T_OPENPAREN Params T_CLOSEPAREN {$$=new MethodCallNode($1,NULL,$3);}
           | T_ID T_DOTOP T_ID T_OPENPAREN Params T_CLOSEPAREN {$$=new MethodCallNode($1,$3,$5);}
           ;

Params : Params_P {$$=$1;}
       | {$$=new std::list<ExpressionNode*>();}
       ;

Params_P : Params_P T_COMMA Exp {$$=$1; $$->push_back($3);}
         | Exp     {$$=new std::list<ExpressionNode*>(); $$->push_back($1);}                 
         ;

%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
