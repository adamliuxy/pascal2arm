/*******************************************************************************
 * 
 * Utility functions for Flex and Bison
 * 
 * When used in Bison/Flex provides the definition of Macros and utility functions 
 * 
 * Otherwise, it give the prototype to use the lexer and parser
 * 
 ******************************************************************************/

#ifndef FunctionsH
#define FunctionsH

// FLEX and Bison Specific
#if defined IN_BISON || defined IN_FLEX
#include "token.h"	//Declares YYTYPE and includes "parser.h"
#endif

//Bison specific
#ifdef IN_BISON
#include "lexer.h"
#endif

#define YY_DECL int yylex(void)

/*
 * Function Prototypes for Flex and Bison
 */
int yyparse();	//Bison
YY_DECL; 	//Flex

//Initialise Lexer
void LexerInit();

//Bison and Flex specific
#if defined IN_BISON || defined IN_FLEX
/*
	Bison Functions
*/

void yyerror(const char *msg);

/*
 * 
 * 	Flex Functions - defined in lexer.l
 * 
 */


void LexerConsumeComments(const char *delimiter);
void LexerConsumeInvalid();

//Inline functions
inline void LexerAddCharCount();

#endif
#endif