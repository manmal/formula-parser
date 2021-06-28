/* description: Parses end evaluates mathematical expressions. */
/* lexical grammar */
%lex
%%
\s+                                                          {/* skip whitespace */}
'"'("\\"["]|[^"])*'"'                                        {return 'STRING';}
"'"('\\'[']|[^'])*"'"                                        {return 'STRING';}
[A-Za-z]{1,}[A-Za-z_0-9\.]+(?=[(])                           {return 'FUNCTION';}
'#'[A-Z0-9\/]+('!'|'?')?                                     {return 'ERROR';}
[A-Za-z@]{1,}[A-Za-z_0-9\/@?]+                               {return 'REFERENCE';}
[A-Za-z\.]+(?=[(])                                           {return 'FUNCTION';}
[0-9]+                                                       {return 'NUMBER';}
'['(.*)?']'                                                  {return 'ARRAY';}
"&"                                                          {return '&';}
" "                                                          {return ' ';}
[.]                                                          {return 'DECIMAL';}
":"                                                          {return ':';}
";"                                                          {return ';';}
","                                                          {return ',';}
"*"                                                          {return '*';}
"/"                                                          {return '/';}
"-"                                                          {return '-';}
"+"                                                          {return '+';}
"^"                                                          {return '^';}
"("                                                          {return '(';}
")"                                                          {return ')';}
">"                                                          {return '>';}
"<"                                                          {return '<';}
"NOT"                                                        {return 'NOT';}
'"'                                                          {return '"';}
"'"                                                          {return "'";}
"!"                                                          {return "!";}
"="                                                          {return '=';}
"%"                                                          {return '%';}
[#]                                                          {return '#';}
<<EOF>>                                                      {return 'EOF';}
/lex

/* operator associations and precedence (low-top, high-bottom) */
%left '='
%left '<=' '>=' '<>' 'NOT' '||'
%left '>' '<'
%left '+' '-'
%left '*' '/'
%left '^'
%left '&'
%left '%'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
  : expression EOF {
      return $1;
    }
;

expression
  : number {
      $$ = yy.toNumber($1);
    }
  | STRING {
      $$ = yy.trimEdges($1);
    }
  | expression '&' expression {
      $$ = yy.evaluateByOperator('&', [$1, $3]);
    }
  | expression '=' expression {
      $$ = yy.evaluateByOperator('=', [$1, $3]);
    }
  | expression '+' expression {
      $$ = yy.evaluateByOperator('+', [$1, $3]);
    }
  | '(' expression ')' {
      $$ = $2;
    }
  | expression '<' '=' expression {
      $$ = yy.evaluateByOperator('<=', [$1, $4]);
    }
  | expression '>' '=' expression {
      $$ = yy.evaluateByOperator('>=', [$1, $4]);
    }
  | expression '<' '>' expression {
      $$ = yy.evaluateByOperator('<>', [$1, $4]);
    }
  | expression NOT expression {
      $$ = yy.evaluateByOperator('NOT', [$1, $3]);
    }
  | expression '>' expression {
      $$ = yy.evaluateByOperator('>', [$1, $3]);
    }
  | expression '<' expression {
      $$ = yy.evaluateByOperator('<', [$1, $3]);
    }
  | expression '-' expression {
      $$ = yy.evaluateByOperator('-', [$1, $3]);
    }
  | expression '*' expression {
      $$ = yy.evaluateByOperator('*', [$1, $3]);
    }
  | expression '/' expression {
      $$ = yy.evaluateByOperator('/', [$1, $3]);
    }
  | expression '^' expression {
      $$ = yy.evaluateByOperator('^', [$1, $3]);
    }
  | '-' expression {
      var n1 = yy.invertNumber($2);

      $$ = n1;

      if (isNaN($$)) {
          $$ = 0;
      }
    }
  | '+' expression {
      var n1 = yy.toNumber($2);

      $$ = n1;

      if (isNaN($$)) {
          $$ = 0;
      }
    }
  | FUNCTION '(' ')' {
      $$ = yy.callFunction($1);
    }
  | FUNCTION '(' expseq ')' {
      $$ = yy.callFunction($1, $3);
    }
  | reference
  | error
  | error error
;

reference
   : REFERENCE {
      $$ = yy.referenceValue($1);
    }
  | REFERENCE ':' REFERENCE {
      $$ = yy.rangeValue($1, $3);
    }
;

expseq
  : expression {
      $$ = [$1];
    }
  | ARRAY {
      $$ = yy.trimEdges(yytext).split(',');
    }
  | expseq ';' expression {
      $1.push($3);
      $$ = $1;
    }
  | expseq ',' expression {
      $1.push($3);
      $$ = $1;
    }
;

number
  : NUMBER {
      $$ = $1;
    }
  | NUMBER DECIMAL NUMBER {
      $$ = ($1 + '.' + $3) * 1;
    }
  | number '%' {
      $$ = $1 * 0.01;
    }
;

error
  : ERROR {
      $$ = yy.throwError($1);
    }
;

%%
