/* Defition section */
%{
   extern int yylineno;
   extern int yylex();
   extern char* yytext;
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #include<stdint.h>
  #include<ctype.h>
  FILE*file;
/*symbol table function*/
int lookup_symbol(int che);
void create_symbol();
void insert_symbol(int type1;);
void dump_symbol();
void yyerror(char *msg);
float symtab[26];
int c=-1,f1=0,j=0,i=0;
int symbol[100];
float data[100];
int err=0;
int temp;
int tempt;
float num;
int type[100];
int o;
int line=0;
int g=0;
int b=0;
%}

%union{
   int i_val;
   double f_val;
   char* string;
}

%token PRINT PRINTLN
%token IF ELSE FOR
%token VAR ID NEWLINE '=' '-' '*' '/' '%' FLOAT INT ENF '>' '<' bigger smaller equal notequal ADDAs SUBAs MULAs DIVAs REMAs ADDo SUBo

%token <i_val> I_CONST 
%token <f_val> F_CONST 
%token<string> STRING VOID 

%type<f_val>stat FLOAT term initializer
%type<i_val> INT  ID 
%left '+' '-'
%left '*' '/' '%'
%right '='

%start program

%%
	
 program
    :program stat NEWLINE {line++;}
    | 
 ;

 stat
    :decaration
    |expression_stat
    |print_func
    |newl
    |compound_stat
 ;
 
 decaration
    : VAR ID FLOAT '=' initializer {create_symbol();temp=$2;num=$5;symtab[(int)$2]=$5;c++;insert_symbol(1);fputs("ldc\t",file);fprintf(file,"%f\n",$5);fputs("fstore\t",file);fprintf(file,"%d\n",c);}
    | VAR ID INT '=' initializer {create_symbol();temp=$2;num=$5;symtab[(int)$2]=$5;c++;insert_symbol(0);fputs("ldc\t",file);fprintf(file,"%f\n",$5);fputs("istore\t",file);fprintf(file,"%d\n",c);}
    | VAR ID INT {create_symbol();temp=$2;c++;insert_symbol(0);fputs("ldc\t0\n",file);fputs("istore\t",file);fprintf(file,"%d\n",c);}
    | VAR ID FLOAT {create_symbol();temp=$2;c++;insert_symbol(1);fputs("ldc\t0\n",file);fputs("fstore\t",file);fprintf(file,"%d\n",c);}

 ;

initializer
   : I_CONST {$$=$1;}
   | F_CONST {$$=$1;}
   |term

;
expression_stat
   :ID '=' term {printf("ASSIGN\n");symtab[(intptr_t)$1]=$3;tempt=$1;if(lookup_symbol(tempt)==1)printf("<ERROR> undefined variable in line %d\n",line+1);int i;for(i=0;i<c+1;i++){if(symbol[i]==$1){if(type[i]==0)fprintf(file,"istore\t%d\n",i);if(type[i]==1)fprintf(file,"fstore\t%d\n",i);}}}
   |ID ADDAs term {symtab[(int)$1]=$3+symtab[(int)$1];printf("ADD ASSIGN\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1)fprintf(file,"iload\t%d\niadd\nistore\t%d\n",i,i);}}
   |ID SUBAs term {symtab[(int)$1]=symtab[(int)$1]-$3;printf("SUB ASSIGN\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1)fprintf(file,"iload\t%d\nisub\nistore\t%d\n",i,i);}}
   |ID MULAs term {symtab[(int)$1]=symtab[(int)$1]*$3;printf("MUL ASSIGN\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1)fprintf(file,"iload\t%d\nimul\nistore\t%d\n",i,i);}}
   |ID DIVAs term {symtab[(int)$1]=symtab[(int)$1]/$3;printf("DIV ASSIGN\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1)fprintf(file,"iload\t%d\nidiv\nistore\t%d\n",i,i);}}
   |ID REMAs term {printf("REM ASSIGN\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1)fprintf(file,"iload\t%d\nirem\nistore\t%d\n",i,i);}}
   |ID ADDo {symtab[(int)$1]=symtab[(int)$1]+1;printf("ADD ONE\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1){fprintf(file,"iload\t%d\n",i);fputs("ldc\t1\niadd\n",file);fprintf(file,"istore\t%d\n",i);}}if(g!=0&&b==1){fprintf(file,"Label_%d:\n",g-1);b=0;}}
   |ID SUBo {symtab[(int)$1]=symtab[(int)$1]-1;printf("SUB ONE\n");int i;for(i=0;i<=c;i++){if(symbol[i]==$1){fprintf(file,"iload\t%d\n",i);fputs("ldc\t1\nisub\n",file);fprintf(file,"istore\t%d\n",i);}}if(g!=0&&b==1){fprintf(file,"Label_%d:\n",g-1);b=0;}}
   |term 

;

term
  :term '+' term {$$=$1+$3; printf("ADD\n");fputs("iadd\n",file);}
  |term '-' term {$$=$1-$3; printf("SUB\n");fputs("fsub\n",file);}
  |term '*' term {$$=$1*$3; printf("MUL\n");fputs("imul\n",file);}
  |term '/' term {if($3!=0){$$=$1/$3; printf("DIV\n");}if($3==0){printf("<ERROR> 0 can't be divided! in line %d\n",line+1);}fputs("idiv\n",file);}
  |term '%' term {if(($3-(int)$3)==0&&($1-(int)$1)==0){$$=(int)$1%(int)$3; printf("REM\n");fputs("irem\n",file);}else{printf("error mod!(line %d)\n",line+1);}}
  |'-'term  {$$=-$2;}
  |'('term')' {$$=$2;}
  |term '>' term {if($1>$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"ifle Label_%d\n",g);g++;b=1;}
  |term bigger term {if($1>=$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"iflt Label_%d\n",g);g++;b=1;}
  |term '<' term {if($1<$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"ifge Label_%d\n",g);g++;b=1;}
  |term smaller term {if($1<=$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"ifgt Label_%d\n",g);g++;b=1;}
  |term equal term {if($1==$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"ifne Label_%d\n",g);g++;b=1;}
  |term notequal term {if($1!=$3){printf("true\n");}else{printf("false\n");}fputs("isub\n",file);fprintf(file,"ifeq Label_%d\n",g);g++;b=1;}
  | ID {$$=symtab[(int)$1];int i; for(i=0;i<c+1;i++){if(symbol[i]==$1){if(type[i]==0)fprintf(file,"iload\t%d\n",i);if(type[i]==1)fprintf(file,"fload\t%d\n",i);}}}
  | I_CONST{$$=$1;fprintf(file,"ldc %d\n",$1);}
  | F_CONST{$$=$1;fprintf(file,"ldc %f\n",$1);fprintf(file,"fstore\t%d\ni2f\nfload\t%d\n",c,c);c++;}
;
print_func
  :PRINT '(' term ')' {printf("print:%f\n",$3);fputs("getstatic java/lang/System/out/ Ljava/io/PrintStream;\nswap\ninvokevirtual java/io/PrintStream/print(I)V\n",file);}
  |PRINTLN '('term ')'{printf("println:%f\n",$3);fputs("getstatic java/lang/System/out/ Ljava/io/PrintStream;\nswap\ninvokevirtual java/io/PrintStream/println(I)V\n",file);}

;
compound_stat
  :IF '('term ')' '{'         {printf("IF function\n");if(g>=1){}}
  |'}'ELSE IF '('term ')' '{' {printf("Else if function\n");if(g>=1){}}
  |'}' ELSE '{'  {printf("Else function\n");if(g>=1){fputs("goto EXIT_0:\n",file);fprintf(file,"Label_%d:\n",g-1);}}
  |'}'{fputs("EXIT_0:\n",file);}

;
newl
  :

;
%%
void yyerror(char *msg)
{
   // fprintf(stderr,"%s\t%s",yytext,msg);
   // exit(1);

}

 int main()
 {
    file=fopen("test.j","w");
    fputs(".class public main\n",file);
    fputs(".super java/lang/Object\n",file);
    fputs(".method public static main([Ljava/lang/String;)V\n",file);
    fputs(".limit stack 10\n",file);
    fputs(".limit locals 10\n",file);
    yylineno=0;
    yyparse();
    printf("total lines:%d\n",line);
   // printf("%f\n",symtab[120]);
   // dump_symbol();
    fputs("return\n",file);
    fputs(".end method",file);
   fclose(file);
    return 0;
 }

void create_symbol(){if(c==0)printf("Create symbol tabel\n");};
void insert_symbol(int type1)
{
  f1=0;
//  printf("%d\n",type1);
  for(j=0;j<i;j++)
  {
     
    if(symbol[j]==temp)
     {
          if(type[i]==type1)
          {
             printf("<ERROR>Redeclaration of Variable in line %d\n",line+1);
             
          }
          else
          {
             printf("<ERROR>Multiple Decalaration of Variable in line %d\n",line+1);
            // err=1;
             
          }
        f1=1;
      }
    }
     if(f1==0)
     {
          type[i]=type1;
          symbol[i]=temp;
         // data[i]=num;
          if(temp==97) printf("Insert symbol:a\n");
          if(temp==120)printf("Insert symbol:x\n");
          if(temp==98) printf("Insert symbol:b\n");
          if(temp==99) printf("Insert symbol:c\n");
          if(temp==100) printf("Insert symbol:d\n");
          if(temp==101) printf("Insert symbol:e\n");
          if(temp==102) printf("Insert symbol:f\n");
          if(temp==103) printf("Insert symbol:g\n");
          if(temp==104) printf("Insert symbol:h\n");
          if(temp==105) printf("Insert symbol:i\n");
          if(temp==106) printf("Insert symbol:j\n");
          if(temp==107) printf("Insert symbol:k\n");
          if(temp==108) printf("Insert symbol:l\n");
          if(temp==109) printf("Insert symbol:m\n");
          if(temp==110) printf("Insert symbol:n\n");
          if(temp==111) printf("Insert symbol:o\n");
          if(temp==112) printf("Insert symbol:p\n");
          if(temp==113) printf("Insert symbol:q\n");
          if(temp==114) printf("Insert symbol:r\n");
          if(temp==115) printf("Insert symbol:s\n");
          if(temp==116) printf("Insert symbol:t\n");
          if(temp==117) printf("Insert symbol:u\n");
          if(temp==118) printf("Insert symbol:v\n");
          if(temp==119) printf("Insert symbol:w\n");
          if(temp==121) printf("Insert symbol:y\n");
          if(temp==122) printf("Insert symbol:z\n");

          i++;
     }
   // printf("%d\n",symbol[0]);
  
};
int lookup_symbol(int che)
{
   int h=0;
   for(j=0;j<i;j++)
   {
       if(che==symbol[j]) h++;
   }
  if(h==0)return 1;
  else return 0;

};
void dump_symbol()
{
    printf("the symbol table is\n");
    printf("ID\tType\tData\n");
    if(err==0)
    {
      for(j=0;j<i;j++)
      {
          if(symbol[j]==97){ printf("a\t");data[j]=symtab[97];}
          if(symbol[j]==120){printf("x\t");data[j]=symtab[120];}
          if(symbol[j]==98){ printf("b\t");data[j]=symtab[98];}
          if(symbol[j]==99){printf("c\t");data[j]=symtab[99];}
          if(symbol[j]==100){ printf("d\t");data[j]=symtab[100];}
          if(symbol[j]==101){printf("e\t");data[j]=symtab[101];}
          if(symbol[j]==102){ printf("f\t");data[j]=symtab[102];}
          if(symbol[j]==103){printf("g\t");data[j]=symtab[103];}
          if(symbol[j]==104){ printf("h\t");data[j]=symtab[104];}
          if(symbol[j]==105){printf("i\t");data[j]=symtab[105];}
          if(symbol[j]==106){ printf("j\t");data[j]=symtab[106];}
          if(symbol[j]==107){printf("k\t");data[j]=symtab[107];}
          if(symbol[j]==108){ printf("l\t");data[j]=symtab[108];}
          if(symbol[j]==109){ printf("m\t");data[j]=symtab[109];}
          if(symbol[j]==110){printf("n\t");data[j]=symtab[110];}
          if(symbol[j]==111){ printf("o\t");data[j]=symtab[111];}
          if(symbol[j]==112){printf("p\t");data[j]=symtab[112];}
          if(symbol[j]==113){ printf("q\t");data[j]=symtab[113];}
          if(symbol[j]==114){printf("r\t");data[j]=symtab[114];}
          if(symbol[j]==115){ printf("s\t");data[j]=symtab[115];}
          if(symbol[j]==116){printf("t\t");data[j]=symtab[116];}
          if(symbol[j]==117){ printf("u\t");data[j]=symtab[117];}
          if(symbol[j]==118){printf("v\t");data[j]=symtab[118];}
          if(symbol[j]==119){ printf("w\t");data[j]=symtab[119];}
          if(symbol[j]==121){printf("y\t");data[j]=symtab[121];}
          if(symbol[j]==122){ printf("z\t");data[j]=symtab[122];}


          if(type[j]==0)printf("int\t");
          if(type[j]==1)printf("float32\t");
          printf("%f\n",data[j]);
      }
    }
    
};


