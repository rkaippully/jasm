/*
 * Copyright 2012 Raghu Kaippully.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

parser grammar JasmParser;

options {
    language     = Java;
    output       = AST;
    ASTLabelType = CommonTree;
    tokenVocab   = JasmLexer;
}

@header {
package com.github.rkaippully.jasm;
}

/**
 * AssemblyUnit is the grammar entry point.
 */
assemblyUnit
	:	jasmHeader
		field*
		method*
		classAttributes?
		EOF
	;

/**
 * A header defines top level directives and class definition
 */
jasmHeader
	:	CLASS_VERSION_DIRECTIVE INT_LITERAL INT_LITERAL
		classSpec
		superSpec
		implementsSpec?
	;

/**
 * The class definition
 */
classSpec
	:	CLASS_DIRECTIVE classAccessSpec* className
	;

/**
 * The super class definition
 */
superSpec
	:	SUPER_DIRECTIVE className
	;

/**
 * The list of interfaces implemented
 */
implementsSpec
	:	IMPLEMENTS_DIRECTIVE className*
	;

/**
 * Class access and property modifiers
 */
classAccessSpec
	:	PUBLIC
	|	FINAL
	|	SUPER
	|	INTERFACE
	|	ABSTRACT
	|	SYNTHETIC
	|	ANNOTATION
	|	ENUM
	;

/**
 * Fully qualified name of a class
 */
className
	:	STRING_LITERAL
	;

/**
 * Simple name of a class
 */
simpleClassName
	:	STRING_LITERAL
	;

/**
 * Definition of a field
 */
field
	:	FIELD_DIRECTIVE
		fieldAccessSpec* fieldName fieldDescriptor
	;

/**
 * Field access and property modifiers
 */
fieldAccessSpec
	:	PUBLIC
	|	PRIVATE
	|	PROTECTED
	|	STATIC
	|	FINAL
	|	VOLATILE
	|	TRANSIENT
	|	SYNTHETIC
	|	ENUM
	;

/**
 * Name of a field
 */
fieldName
	:	STRING_LITERAL
	;

/**
 * Field descriptor
 */
fieldDescriptor
	:	STRING_LITERAL
	;

method
	:	METHOD_DIRECTIVE
	;

/**
 * Name of a method
 */
methodName
	:	STRING_LITERAL
	;

/**
 * Method descriptor
 */
methodDescriptor
	:	STRING_LITERAL
	;

/**
 * Attributes that can appear in the attributes table of a ClassFile structure.
 */
classAttributes
	:	ATTRIBUTES_DIRECTIVE
		classAttribute*
		END_ATTRIBUTES_DIRECTIVE
	;

classAttribute
	:	(SOURCE_FILE_DIRECTIVE STRING_LITERAL)
		|	(DEBUG_DIRECTIVE STRING_LITERAL)
		|	(INNER_CLASS_DIRECTIVE innerClassAccessSpec* className)
		|	(INNER_CLASS_DIRECTIVE innerClassAccessSpec* simpleClassName EQUALS className (OF className)?)
		|	(ENCLOSING_METHOD_DIRECTIVE className methodName methodDescriptor)
	;

/**
 * Access and property modifiers for inner classes
 */
innerClassAccessSpec
	:	PUBLIC
	|	PRIVATE
	|	PROTECTED
	|	STATIC
	|	FINAL
	|	INTERFACE
	|	ABSTRACT
	|	SYNTHETIC
	|	ANNOTATION
	|	ENUM
	;