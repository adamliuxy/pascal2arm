#include <iostream>
#include "utility.h"
#include "lexer.h"

//Flags - declared in utility.cpp
extern Flags_T Flags;

int main(int argc, char **argv){
	ParseArg(argc, argv);	//Parse command line arguments and set Flags
	
	//Check for integrity of input and output
	if (INPUT.fail()){
		std::cout << "Error reading " << Flags.InputPath << std::endl;
		return 1;
	}
	if (OUTPUT.fail()){
		std::cout << "Error writing to " << Flags.OutputPath << std::endl;
		return 1;
	}
	
	
	return 0;
}