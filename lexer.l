%option yylineno
%pointer

%{
    #include <stdlib.h>
    #include <errno.h>
    #include <limits.h>
    #include "ast.hpp"
    #include "parser.hpp"
    void yyerror(const char *);
%}

/* WRITEME: Copy any definitions and start conditions from Project 3 here */

%x COMMENT


%%

<INITIAL>"/*"     { BEGIN(COMMENT); }  
<COMMENT>[^*\n]*     ;
<COMMENT>"*"+[^*/\n]* ;
<COMMENT>"\n"     ;
<COMMENT><<EOF>>  { yyerror("dangling comment"); }
<COMMENT>"*/"     { BEGIN(INITIAL); } 

[ \t\n]           ; 
0|[1-9][0-9]*     { yylval.integer_ptr = new IntegerNode(atoi(yytext)); return T_INTEGER; } 
"+"               { return T_PLUS; }  
"-"               { return T_MINUS; }
"/"               { return T_DIVIDE; }
"*"               { return T_MULT; }
"="               { return T_EQUAL; }  
"=="              { return T_EQUALEQ; }
"<"               { return T_LESS; }
";"               { return T_SEMICOLON; }  
":"               { return T_COLON; }  
"<="              { return T_LESSEQ; } 
"("               { return T_OPENPAREN; }
")"               { return T_CLOSEPAREN; }
"{"               { return T_OPENBRACKET; }
"}"               { return T_CLOSEBRACKET; }  
","               { return T_COMMA; }       
"or"              { return T_OR; }
"and"             { return T_AND; }  
"true"            { yylval.integer_ptr = new IntegerNode(1); return T_TRUE; }
"false"           { yylval.integer_ptr = new IntegerNode(0); return T_FALSE; }
"if"              { return T_IF; }  
"else"            { return T_ELSE; }
"print"           { return T_PRINT; }
"return"          { return T_RETURN; }  
"for"             { return T_FOR; }
"new"             { return T_NEW; }
"not"             { return T_NOT; }  
"int"             { return T_INT; } 
"bool"            { return T_BOOL; }  
"none"            { return T_NONE; } 
"."               { return T_DOTOP; }  
[a-zA-Z][a-zA-Z0-9]*    { yylval.identifier_ptr=new IdentifierNode(strdup(yytext)); return T_ID; }
.                 { yyerror("invalid character"); }

%%

int yywrap(void) {
  return 1;
}
