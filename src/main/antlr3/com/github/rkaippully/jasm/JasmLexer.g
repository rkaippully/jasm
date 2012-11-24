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

lexer grammar JasmLexer;

@header {
package com.github.rkaippully.jasm;

import org.apache.commons.lang3.StringEscapeUtils;
}


COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n'  { skip(); }
    |   '/*' .* '*/'                   { skip(); }
    ;

WS
    :   ( ' ' | '\t' | '\r' | '\n' )  { skip(); }
    ;

EQUALS
	:	'='
	;

FORWARD_SLASH
	:	'/'
	;

INT_LITERAL
    :   DecimalIntLiteral
    |   HexIntLiteral
    |   OctalIntLiteral
    |   BinaryIntLiteral
    ;

fragment
DecimalIntLiteral
    :   '0'
    |   '1'..'9' Digit*
    ;

fragment
Digit
    :   '0'..'9'
    ;

fragment
HexIntLiteral
    :   HexPrefix HexDigit+
    ;

fragment
HexPrefix
    :   '0' ('x' | 'X')
    ;

fragment
HexDigit
    :   ('0'..'9'|'a'..'f'|'A'..'F')
    ;

fragment
OctalIntLiteral
    :   '0' OctalDigit+
    ;

fragment
OctalDigit
    :   '0'..'7'
    ;

fragment
BinaryIntLiteral
    :   '0' ('b' | 'B') ('0' | '1')+
    ;

FLOAT_LITERAL
    :   Digit+ '.' Digit* Exponent?
    |   '.' Digit+ Exponent?
    |   Digit+ Exponent    
    ;

fragment
Exponent
    :   ('e' | 'E') ('+' | '-')? Digit+
    ;

BOOL_LITERAL
    :   'true' | 'false'
    ;

CHAR_LITERAL
    :   '\'' ( EscapeSequence | ~('\'' | '\\' | '\r' | '\n') ) '\''
    ;

fragment
EscapeSequence
    :   '\\'
    (
        'b'
    |   't'
    |   'n'
    |   'f'
    |   'r'
    |   '\"'
    |   '\''
    |   '\\'
    )
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
UnicodeEscape
    :   '\\u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment
OctalEscape
    :   '\\' OctalDigit+
    ;

STRING_LITERAL
    :   '"' ( EscapeSequence | ~('"' | '\\' | '\r' | '\n') )* '"'
    {
    	String input = getText().substring(1, getText().length() - 1);
    	setText(StringEscapeUtils.unescapeJava(input));
    }
    ;

CLASS_VERSION_DIRECTIVE
	:	'.classversion'
	;

CLASS_DIRECTIVE
	:	'.class'
	;

SOURCE_FILE_DIRECTIVE
	:	'.sourcefile'
	;

SUPER_DIRECTIVE
	:	'.super'
	;

IMPLEMENTS_DIRECTIVE
	:	'.implements'
	;

FIELD_DIRECTIVE
	:	'.field'
	;

END_FIELD_DIRECTIVE
	:	'.endfield'
	;

METHOD_DIRECTIVE
	:	'.method'
	;

END_METHOD_DIRECTIVE
	:	'.endmethod'
	;

ATTRIBUTES_DIRECTIVE
	:	'.attributes'
	;

END_ATTRIBUTES_DIRECTIVE
	:	'.endattributes'
	;

DEBUG_DIRECTIVE
	:	'.debug'
	;

INNER_CLASS_DIRECTIVE
	:	'.innerclass'
	;

ENCLOSING_METHOD_DIRECTIVE
	:	'.enclosingmethod'
	;

SYNTHETIC_DIRECTIVE
	:	'.synthetic'
	;

SIGNATURE_DIRECTIVE
	:	'.signature'
	;

DEPRECATED_DIRECTIVE
	:	'.deprecated'
	;

OF
	:	'of'
	;

PUBLIC
	:	'public'
	;

PRIVATE
	:	'private'
	;

PROTECTED
	:	'protected'
	;

STATIC
	:	'static'
	;

FINAL
	:	'final'
	;

SUPER
	:	'super'
	;

INTERFACE
	:	'interface'
	;

ABSTRACT
	:	'abstract'
	;

VOLATILE
	:	'volatile'
	;

TRANSIENT
	:	'transient'
	;

SYNTHETIC
	:	'synthetic'
	;

ANNOTATION
	:	'annotation'
	;

ENUM
	:	'enum'
	;

IDENTIFIER
    :   ~('.' | ';' | '[' | '/' | ' ' | '\t' | '\r' | '\n')+
    ;