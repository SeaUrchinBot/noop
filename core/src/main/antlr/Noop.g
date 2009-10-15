// Copyright 2009 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

grammar Noop;

options {
  backtrack = true;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  CLASS;
  INTERFACE;
  PARAMS;
  PARAM;
  METHOD;
  MOD;
  ARGS;
  VAR;
  IMPL;
  IF;
  WHILE;
  FOREACH;
  FOR;
  TEST;
  UNITTEST;
}

@header {
  package noop.grammar.antlr;
}

@lexer::header {
  package noop.grammar.antlr;
}

@members { 
  public boolean hadErrors = false;
  
  @Override
  public String getErrorMessage(RecognitionException e, String[] tokenNames) {
    hadErrors = true;
    return super.getErrorMessage(e, tokenNames);
  }
}

@lexer::members {
  public boolean hadErrors = false;
  
  @Override
  public String getErrorMessage(RecognitionException e, String[] tokenNames) {
    hadErrors = true;
    return super.getErrorMessage(e, tokenNames);
  }
}

// A line of user input in the interactive interpreter
interpretable
  :	(importDeclaration
     | classDefinition
     | statement)+
	;

file
	:	namespaceDeclaration? importDeclaration* (classDefinition | interfaceDefinition | test)
	;

namespaceDeclaration
	:	'namespace'^ namespace ';'!
	;

importDeclaration
	:	'import'^ qualifiedType ';'!
	;

ifExpression
  : 'if' '(' expression ')' block* ('else' block*)?
  -> ^(IF expression* block*)
  ;

methodDefinition
	: methodSignature block
	-> ^(METHOD methodSignature block?)
	;

namespace
	:	VariableIdentifier ('.'! VariableIdentifier)*
	;

qualifiedType
	:	 (namespace '.'!)? TypeIdentifier
	;

classDefinition
	: doc? modifiers? 'class' TypeIdentifier parameterList typeSpecifiers? classBlock
	-> ^(CLASS modifiers? TypeIdentifier parameterList? typeSpecifiers? classBlock? doc?)
	;

doc
	:	'doc'^ StringLiteral
	;

typeSpecifiers
	: 'implements' qualifiedType (',' qualifiedType)*
	-> ^(IMPL qualifiedType)*
	;

interfaceDefinition
  : 'interface' TypeIdentifier interfaceBlock
  -> ^(INTERFACE TypeIdentifier interfaceBlock?)
  ;

modifiers
	: modifier+
	-> ^(MOD modifier+)
	;

modifier
	: 'mutable' | 'delegate' | 'native'
	;

classBlock
	:	'{'!  (identifierDeclaration ';'!)* methodDefinition* unittest* '}'!
	;

interfaceBlock
  : '{'! methodDeclaration* '}'!
	;

test
	: 'test' StringLiteral '{' (statement* | test | unittest) '}'
	-> ^(TEST StringLiteral statement* test? unittest?)
	;

unittest
	: 'unittest' StringLiteral block
	-> ^(UNITTEST StringLiteral block?)
	;

methodSignature
  : doc? modifiers? TypeIdentifier VariableIdentifier parameterList
  ;

methodDeclaration
  : methodSignature ';'
  -> ^(METHOD methodSignature)
  ;


identifierDeclaration
	:	TypeIdentifier identifierDeclarator
	-> ^(VAR TypeIdentifier identifierDeclarator)
	;

identifierDeclarator
	: VariableIdentifier ('='^ expression)?
	;

block
	: '{'!  statement* '}'!
	;

statement
	:	identifierDeclaration ';'!
	| whileLoop
	| forLoop
	| 'return'^ expression ';'!
	| expression ';'!
	| ifExpression
	| shouldStatement ';'!
	;
	
shouldStatement
	:	expression 'should'^ expression
	;

forLoop
	: 'for' '(' (identifierDeclaration|VariableIdentifier) 'in' expression ')' block
	-> ^(FOREACH identifierDeclaration? VariableIdentifier? expression block?)
	| 'for' '(' identifierDeclaration ';' conditionalExpression ';' expression ')' block
	-> ^(FOR identifierDeclaration conditionalExpression expression block?)
	;

whileLoop
	: 'while' '(' expression ')' block
	-> ^(WHILE expression block?)
	;

expression
	: additiveExpression ('='^ expression)?
	;
	
additiveExpression
	:	multiplicativeExpression ( ('+' | '-')^ multiplicativeExpression )*
	;

multiplicativeExpression
	:	conditionalExpression ( ( '*' | '/' | '%' )^ conditionalExpression )*
	;	

conditionalExpression
  : (conditionalOrExpression | conditionalAndExpression)+
  ;

conditionalOrExpression
  : conditionalAndExpression ('||'^ conditionalAndExpression)*
  ;

conditionalAndExpression
  : finalConditionalExpression ('&&'^ finalConditionalExpression)*
  ;

finalConditionalExpression
  : primary (('==' | '!=' | '>' | '<' | '>=' | '<=')^ primary)*
  ;

primary
	:	'('! expression ')'!
	| (VariableIdentifier|TypeIdentifier|literal) (arguments | ('.'^ (VariableIdentifier|TypeIdentifier) arguments?)*)
	;

arguments
	:	'(' expressionList? ')'
	-> ^(ARGS expressionList?)
	;

expressionList
	:	expression (','! expression)*
	;

parameterList
	: '('! parameters? ')'!
	;

parameters
	: parameter (',' parameter)*
	-> ^(PARAMS parameter*)
	;

parameter
	: modifiers? TypeIdentifier VariableIdentifier
	-> ^(PARAM modifiers? TypeIdentifier VariableIdentifier)
	;

literal
	: INT | StringLiteral | 'true' | 'false'
	;

/* Lexer rules */

TypeIdentifier
	: 'A' .. 'Z' ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9')*
	;

VariableIdentifier
	: 'a' .. 'z' ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9')*
	;

StringLiteral
	:	'"' ~('"'|'\\'|'\n'|'\r')* '"'
	| '"""' (options {greedy=false;}:.)* '"""'
	;

WS
  :	(' '|'\r'|'\n'|'\t')+ {$channel = HIDDEN;}
  ;

COMMENT
  :   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
  ;

LINE_COMMENT
  : '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
  ;

INT
	:	'-'? '0'..'9'+
	;