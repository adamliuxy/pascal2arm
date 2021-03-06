%{
#include <iostream>
#include <iomanip>
#include <cstring>
#include <string>
#include <sstream>
#include <new>

#define IN_FLEX

//Because FLEX generated CPP files are in Gen/ folder, ../ is required
#include "../compiler.h"
#include "../utility.h"
#include "../asm.h"
#include "../op.h"
#include "../define.h"
#include "../token.h"
#include "all.h"	//All specialisations
#include "parser.h"

extern Flags_T Flags;		//In utility.cpp
extern YYSTYPE yylval;		//In parser.cpp (generated)
extern int yydebug;		// IN parser.cpp
extern AsmFile Program;	//In parser.y
#define CurrentToken yylval

//Lexer variables
unsigned LexerCharCount, LexerLineCount;
bool LexerSyntaxError;

//Functions
void LexerConsumeComments(const char *delimiter);
void LexerConsumeInvalid();
//int yywrap();

//Inline functions
inline void LexerAddCharCount();	//Add count to char
%}
%option yylineno
%option noyywrap
/*%option stack*/

/* Pascal is case-insensitive */
A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]

WHITESPACE [ \t\r]
NQUOTE [^']



/* Literals */
LETTER [A-Za-z]
IDENTIFIER [a-zA-Z_]([a-zA-Z0-9_])*
CHAR ({NQUOTE}|'')
STRING '{CHAR}+'
DIGIT [0-9]
DIGIT_NONZERO [1-9]
/*SIGN [+\-]*/
NIL {N}{I}{L} 
FLOAT ({DIGIT}+\.{DIGIT}+)|(\.{DIGIT}+)
SIGNED_NUMBER [+\-]?{DIGIT}+

%%

{A}{N}{D}   	{ LexerAddCharCount(); return(OP_AND); }
{A}{R}{R}{A}{Y} { LexerAddCharCount(); return(K_ARRAY); }
{B}{E}{G}{I}{N} { LexerAddCharCount(); return(K_BEGIN); }
{C}{A}{S}{E}   	{LexerAddCharCount(); return(K_CASE); }
{C}{O}{N}{S}{T} {LexerAddCharCount();  return K_CONST; }
{D}{I}{V}  	{LexerAddCharCount(); return OP_DIV; }
{D}{O}    	{LexerAddCharCount(); return K_DO; }
{D}{O}{W}{N}{T}{O}  {LexerAddCharCount(); return K_DOWNTO; }
{E}{L}{S}{E}   {LexerAddCharCount(); return K_ELSE; }
{E}{N}{D}   	{LexerAddCharCount(); return K_END; }
{F}{I}{L}{E}   {LexerAddCharCount(); return K_FILE; }
{F}{O}{R}   	{LexerAddCharCount(); return K_FOR; }
{F}{U}{N}{C}{T}{I}{O}{N} {LexerAddCharCount(); return K_FUNCTION; }
{G}{O}{T}{O}   {LexerAddCharCount(); return K_GOTO; }
{I}{F}    	{LexerAddCharCount(); return K_IF; }
{I}{N}    	{LexerAddCharCount(); return OP_IN; }
{L}{A}{B}{E}{L}   {LexerAddCharCount(); return K_LABEL; }
{M}{O}{D}   {LexerAddCharCount(); return OP_MOD; }
{NIL}  {LexerAddCharCount(); return V_NIL; }
{N}{O}{T}   {LexerAddCharCount(); return OP_NOT; }
{O}{F}    {LexerAddCharCount(); return K_OF; }
{O}{R}    {LexerAddCharCount(); return OP_OR; }
{P}{A}{C}{K}{E}{D}  {LexerAddCharCount(); return K_PACKED; }
{P}{R}{O}{C}{E}{D}{U}{R}{E} {LexerAddCharCount(); return K_PROCEDURE; }
{P}{R}{O}{G}{R}{A}{M}  {LexerAddCharCount(); return K_PROGRAM; }
{R}{E}{C}{O}{R}{D}  {LexerAddCharCount(); return K_RECORD; }
{R}{E}{P}{E}{A}{T}  {LexerAddCharCount(); return K_REPEAT; }
{S}{E}{T}   {LexerAddCharCount(); return K_SET; }
{T}{H}{E}{N}   {LexerAddCharCount(); return K_THEN; }
{T}{O}    {LexerAddCharCount(); return K_TO; }
{T}{Y}{P}{E}   {LexerAddCharCount(); return K_TYPE; }
{U}{N}{T}{I}{L}   {LexerAddCharCount(); return K_UNTIL; }
{V}{A}{R}   {LexerAddCharCount(); return K_VAR; }
{W}{H}{I}{L}{E}   {LexerAddCharCount(); return K_WHILE; }
{W}{I}{T}{H}   {LexerAddCharCount(); return K_WITH; }
{X}{O}{R}    {LexerAddCharCount(); return OP_XOR; }

{T}{R}{U}{E} { LexerAddCharCount(); return I_TRUE; }
{F}{A}{L}{S}{E} { LexerAddCharCount(); return I_FALSE; }
{M}{A}{X}{I}{N}{T} { LexerAddCharCount(); return I_MAXINT; }
{B}{O}{O}{L}{E}{A}{N} { LexerAddCharCount(); return I_BOOLEAN; }
{C}{H}{A}{R} { LexerAddCharCount(); return I_CHAR; }
{I}{N}{T}{E}{G}{E}{R} { LexerAddCharCount(); return I_INTEGER; }
{R}{E}{A}{L} { LexerAddCharCount(); return I_REAL; }
{I}{N}{P}{U}{T} { LexerAddCharCount(); return I_INPUT; }
{O}{U}{P}{U}{T} { LexerAddCharCount(); return I_OUTPUT; }
{S}{T}{R}{I}{N}{G} { LexerAddCharCount(); return I_STRING; }

{F}{O}{R}{W}{A}{R}{D}  {LexerAddCharCount(); return I_FORWARD; }

^"//PRINT SYMBOL"$ { LexerAddCharCount(); Program.PrintSymbols(); }
^"//PRINT BLOCK"$ { LexerAddCharCount(); Program.PrintBlocks(); }

'{CHAR}'	{	LexerAddCharCount();
				char chara;
				if (!strcmp(yytext, "''''"))
					chara = '\'';
				else
					chara = yytext[1];

				CurrentToken.reset(new Token_Char(chara));
				return V_CHAR; 
			}
"#"{DIGIT}+	{ 	LexerAddCharCount(); 
				//Get the integer
				std::string value(yytext);
				value = value.substr(1, std::string::npos);
				
				unsigned chara = FromString<unsigned>(value);
				
				CurrentToken.reset(new Token_Char((char) chara));
				return V_CHAR; 
			}

{STRING}	{LexerAddCharCount(); 
			
			CurrentToken.reset(new Token(yytext, V_String));
			return V_STRING; 
			}
		
{IDENTIFIER}  { //Identifier
			LexerAddCharCount(); 
			
			CurrentToken.reset(new Token(yytext,V_Identifier));
			return V_IDENTIFIER; }



{FLOAT}			|
{DIGIT}+{E}{SIGNED_NUMBER} |
{FLOAT}{E}{SIGNED_NUMBER} {
				LexerAddCharCount(); 
				
				CurrentToken.reset(new Token_Real(yytext, V_Real));
				return V_REAL;
			}


		
{DIGIT}+	{
			LexerAddCharCount(); 
			
			
			CurrentToken.reset(new Token_Int(yytext, V_Int)); 
			return V_INT;
		}
	
":="    {LexerAddCharCount(); return OP_ASSIGNMENT; }

":"    |
","    |
"."    |
"="    |
"["    |
"("    |
"<"    |
">"    |
"-"    |
"+"    |
"]"    |
")"    |
";"    |
"/"    |
"*"    |
"^"		{LexerAddCharCount(); return yytext[0]; }

".."    {LexerAddCharCount(); return(OP_DOTDOT); }
">="    {LexerAddCharCount(); return(OP_GE); }
"<="    {LexerAddCharCount(); return(OP_LE); }
"<>"    {LexerAddCharCount(); return(OP_NOTEQUAL); }
"**"    {LexerAddCharCount(); return(OP_STARSTAR); }
			
			
"{"		LexerConsumeComments("{");		/* Consume Comments - Place at bottom! */
"{*"	LexerConsumeComments("{*");
"/*"	LexerConsumeComments("/*");
"//"	LexerConsumeComments("//");

{WHITESPACE}	LexerCharCount++;

[\n]	{
		LexerLineCount++;
		LexerCharCount = 1;
	}

.	{
		LexerConsumeInvalid();
	}
	
<<EOF>> {
		
		if (LexerSyntaxError){
			HandleError("There are syntax error(s). Compilation cannot proceed.", E_SYNTAX, E_FATAL, LexerLineCount, LexerCharCount);
			return Y_FATAL_ERROR;
		}
		else{
			return Y_EOF;
		}
	}
%%

//Lexer Functions
void LexerConsumeComments(const char *delimiter){
	static char endDelimiter[3];
	LexerCharCount += strlen(delimiter);

	//Beginning of comment
	//OUTPUT << "[[COMMENT DELIM " << delimiter;
	
	//Determine end delimiter
	//A zero value indicates that both strings are equal.
	//http://www.cplusplus.com/reference/clibrary/cstring/strcmp/
	if (!strcmp(delimiter, "{"))
		strcpy(endDelimiter, "}");
	else if (!strcmp(delimiter, "{*"))
		strcpy(endDelimiter, "*}");
	else if (!strcmp(delimiter, "//"))
		strcpy(endDelimiter, "\n");
	else if (!strcmp(delimiter, "/*"))
		strcpy(endDelimiter, "*/");
	
	//OUTPUT << " END DELIM " << endDelimiter;
	
	unsigned i = 0;
	char c;
	//Time to eat charas
	while(1){
		c = yyinput();
		if (c == '\n'){
			LexerLineCount++;
			LexerCharCount = 1;
		}
		else
			LexerCharCount++;
		//Unexpected EOF
		if (c == EOF){
			HandleError("Unexpected EOF in comments", E_SYNTAX, E_FATAL, LexerLineCount, LexerCharCount);
			return;
		}
		
		if (c == endDelimiter[i])
			i++;
		else
			i=0;
		
		if (i == strlen(endDelimiter)){
			//End of comment
			//OUTPUT << " COMPLETE]]";
			//if (c == '\n')
			//	unput('\n');
			return;
		}
		
		//Reached here? Still in comment
	}
}

void LexerConsumeInvalid(){

	//Eat a whole word and then report failure
	std::stringstream msg;
	char c = yytext[0];
	int charCount = 1;
	msg << "Unexpected '" << c;

	while( (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || ( c >= 97 && c <= 122 ) ){
		c = yyinput();
		charCount++;
		LexerCharCount++;
		if((c >= 48 && c <= 57) || (c >= 65 && c <= 90) || ( c >= 97 && c <= 122 ) )
			msg << c;		
	}

	bool EOFError = false;
	if (c == EOF){
		msg << " at the end of the file";
		EOFError = true;
	}
	else if (charCount > 1)
		unput(c);

	msg << "'";

	if (Flags.ShowHints)
		msg << "\n\tNote: Are you trying to define an identifier? An identifier can only begin with alphabets and can contain only numbers and alphabets.";

	ErrorLevel_T level = EOFError == true ? E_FATAL : E_ERROR;
	
	HandleError(msg.str().c_str(), E_SYNTAX, level, LexerLineCount, LexerCharCount-charCount+1);
	
	//return Y_SYNTAX_ERROR;
}


//Inline functions
inline void LexerAddCharCount(){
	LexerCharCount += strlen(yytext);
}

/**
	Removed rules
	
"^"{LETTER}	{	LexerAddCharCount(); 
				char chara;
				
				if (yytext[1] >= 97)
					chara = yytext[1] - 96;
				else
					chara = yytext[1] - 64;
				CurrentToken.reset(new Token_Char(chara));
				return V_CHAR; 
			}
**/