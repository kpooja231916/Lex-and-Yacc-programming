%{
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
FILE *f[4];
int cnt=0;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
#define YYSTYPE int
%}
%pure-parser
%lex-param { void * scanner}
%parse-param {void *scanner}
%start list
%token NUMBER
%left '+' '-'
%left '*' '/' '%'
%left UMINUS
%union {int i;}
%%


list:
	|
	list stat '\n'
 	|
	list error '\n'{ yyerrok; }
	;

stat:	expr { printf( "%d\n" ,$1); }
	;

expr:	'(' expr ')'{ $$=$2; }
	|
	expr '*' expr { $$ =$1 * $3; }
	|
	expr '/' expr { $$ =$1 / $3; }
	|
	expr '+' expr { $$ =$1 + $3; }
	|
	expr '-' expr { $$ =$1 - $3; }
	|
	'-' expr %prec UMINUS { $$ = -$2; }
	
	     |
	     NUMBER
	;
%%

void* scanfunc(void *i)
{ 
    void* scanner;
    yylex_init(&scanner);
    pthread_mutex_lock(&lock);
    printf("starting thread %d...\n",cnt);
    yyset_in(f[cnt],scanner);
    cnt++;
    pthread_mutex_unlock(&lock);
    yyparse(scanner);
}

main (int argc, char* argv[])
{
	if(argc!=2)
	{
		 printf(" incorrect parameter! \n");
		 return -1;
	}
	if(!fopen(argv[1],"r"))
	{  printf(" file cannot be open!\n");
	     return -1;
	}

pthread_t threads[4];
int i,j;
char * s=malloc(100);
size_t n=100;
	for(i=0;i<4;i++)
	{
	   f[i]=fopen(argv[1],"r");
	   for(j=0;j<i*25;j++)
	   getline(&s, &n, f[i]);
	}

for(i=0;i<4;i++)
pthread_create(&threads[i],NULL,scanfunc,(void  *)&i);

for(i=0; i<4;i++)
pthread_join(threads[i],NULL);

}

yyerror()
{ 
	printf("error!\n");
}

yywrap()
{
	return(1);
}




