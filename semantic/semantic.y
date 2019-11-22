%{
  #include <stdio.h>
  #include "defs.h"
  #include "symtab.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;

  int tip;  //tip elvevese
  int functype; 
  int return_flag = 0;
  int current_block = 0;
  int remove_start;

%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP


%token _WHILE
%token _DO
%token _COMMA
%token _INC
%token _VOID

%type <i> type num_exp exp literal
%type <i> function_call argument rel_exp

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : function_list
      {  
        int idx = lookup_symbol("main", FUN);
        if(idx == -1)
          err("undefined reference to 'main'");
        else 
          if(get_type(idx) != INT)
            warn("return type of 'main' is not int");
      }
  ;

function_list
  : function
  | function_list function
  ;

function
  : type _ID
      {

        functype = $1; 
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == -1)
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $2);


        

      }
    _LPAREN parameter _RPAREN body
      {
        clear_symbols(fun_idx + 1);
        var_num = 0;
        if (return_flag == 0 && functype != _VOID)
          warn("NON-VOID STATEMENT MISSING RETURN ");
      }
  ;

type
  : _TYPE
      { $$ = $1; }
  ;

parameter
  : /* empty */
      { set_atr1(fun_idx, 0); }

  | type _ID
      { if ($1 == _VOID)
          err("SEMANTICAL ERROR VARIABLE TYPE CANNOT BE VOID");

        insert_symbol($2, PAR, $1, 1, NO_ATR);
        set_atr1(fun_idx, 1);
        set_atr2(fun_idx, $1);
      }
  ;

body
  : _LBRACKET variable_list statement_list _RBRACKET
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : vars _SEMICOLON
  ;

vars
  : _TYPE _ID
      {
 	      tip = $1; 
        if (tip == _VOID) {
          err("SEMANTICAL ERROR VARIABLE TYPE CANNOT BE VOID");
        }
        if (lookup_symbol($2, VAR|PAR) == -1) 
          insert_symbol($2, VAR, tip, ++var_num, current_block);
        else

          if (get_atr2(lookup_symbol($2, VAR|PAR)) == current_block)
            err("redefinition of '%s'", $2);
          else
            insert_symbol($2, VAR, tip , ++var_num, current_block);


      }
  | vars _COMMA _ID
      {
        if (tip == _VOID) {
          err("SEMANTICAL ERROR VARIABLE TYPE CANNOT BE VOID");
        }

        if (lookup_symbol($3, VAR|PAR) == -1) 
          insert_symbol($3, VAR, tip, ++var_num, current_block);
        else

          if (get_atr2(lookup_symbol($3, VAR|PAR)) == current_block)
            err("redefinition of '%s'", $3);
          else
            insert_symbol($3, VAR, tip , ++var_num, current_block);

      }
  ;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement
  | inc_statement
  | do_while_statement
  ;

 do_while_statement
 : _DO statement _WHILE _LPAREN _ID _RELOP literal _RPAREN _SEMICOLON

 { if ( lookup_symbol($5, VAR|PAR) == -1)
     err("VARIABLE NOT DECLARED");
   if (get_type(lookup_symbol($5, VAR|PAR)) != get_type($7))
     err ("VARIABLE AND LITERAL NOT OF THE SAME TYPE");
 ;
 }
inc_statement
  : _ID _INC _SEMICOLON
  ;

compound_statement
  : _LBRACKET { remove_start = get_last_element() + 1; current_block++; } 
     variable_list statement_list _RBRACKET 
     { 
      clear_symbols(remove_start); 
      print_symtab();
      current_block--;
    }

  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == -1)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
      }
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == -1)
          err("'%s' undeclared", $1);

      }
  | function_call
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }

  | _ID _INC
      {
        if(($$ = lookup_symbol($1, (VAR|PAR))) == -1)
          err("'%s' undeclared", $1);
      }
  ;
literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == -1)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {
        if(get_atr1(fcall_idx) != $4)
          err("wrong number of args to function '%s'", 
              get_name(fcall_idx));
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
      }
  ;

argument
  : /* empty */
    { $$ = 0; }

  | num_exp
    { 
      if(get_atr2(fcall_idx) != get_type($1))
        err("incompatible type for argument in '%s'",
            get_name(fcall_idx));
      $$ = 1;
    }
  ;

if_statement
  : if_part %prec ONLY_IF
  | if_part _ELSE statement
  ;

if_part
  : _IF _LPAREN rel_exp _RPAREN statement
  ;

rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
      }
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
      {
        if (functype == _VOID) 
          err("FUNCTION OF TYPE VOID SHOULD HAVE NO Return statement");
        if(get_type(fun_idx) != get_type($2))
          err("incompatible types in return");
        return_flag = 1;
      }
  | _RETURN _SEMICOLON {
     if (functype != _VOID)
      warn("WARNING: NONVOID FUNCTIONS SHOULD RETURN ACTUAL VALUES");
      return_flag = 1;
  }
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();

  synerr = yyparse();

  clear_symtab();
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count)
    printf("\n%d error(s).\n", error_count);

  if(synerr)
    return -1;
  else
    return error_count;
}

