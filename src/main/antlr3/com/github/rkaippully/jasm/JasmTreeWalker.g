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

tree grammar JasmTreeWalker;

options {
    language     = Java;
    ASTLabelType = CommonTree;
    tokenVocab   = JasmLexer;
}

@header {
package com.github.rkaippully.jasm;

import static org.objectweb.asm.Opcodes.*;

import java.io.File;
import java.io.IOException;
import java.io.FileOutputStream;
import java.lang.reflect.Method;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;
import org.objectweb.asm.MethodVisitor;
}

@members {
private ClassWriter cw;
}

/**
 * AssemblyUnit is the grammar entry point.
 */
assemblyUnit
	:
	{
		this.cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);
	}
		clazzName=jasmHeader
		field*
		method*
		EOF
	{
        cw.visitEnd();

        try {
            File classFile = new File("target/classes/" + clazzName + ".class");
            classFile.getParentFile().mkdirs();
            FileOutputStream fos = new FileOutputStream(classFile);
            fos.write(cw.toByteArray());
            fos.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
	}
	;

/**
 * A header defines top level directives and class definition
 */
jasmHeader returns [String className]
	:	CLASS_VERSION_DIRECTIVE majv=INT_LITERAL minv=INT_LITERAL
	{
		int minorVersion = Integer.parseInt($minv.text);
		int majorVersion = Integer.parseInt($majv.text);
		int version = minorVersion << 16 | majorVersion;
	}
		clazzSpec=classSpec
		superClassName=superSpec
		implClassNames=implementsSpec?
		attrs=classAttributes?
	{
		int access = $clazzSpec.access;
		if ($attrs.deprecated)
			access |= ACC_DEPRECATED;
		cw.visit(version, access, $clazzSpec.className, $attrs.signature, superClassName, implClassNames);
		$className = $clazzSpec.className;
	}
	;

/**
 * The class definition
 */
classSpec returns [String className, int access]
	:	CLASS_DIRECTIVE
	{
		$access = 0;
	}
	(a=classAccessSpec
		{
			$access |= a;
		}
	)*
	name=className
	{
		$className = name;
	}
	;

/**
 * The super class definition
 */
superSpec returns [String className]
	:	SUPER_DIRECTIVE name=className
	{
		$className = name;
	}
	;

/**
 * The list of interfaces implemented
 */
implementsSpec returns [String[\] names]
	:	IMPLEMENTS_DIRECTIVE
	{
		List<String> nameList = new ArrayList();
	}
	(name=className
	{
		nameList.add(name);
	}
	)*
	{
		names = new String[nameList.size()];
		nameList.toArray(names);
	}
	;

/**
 * Class access and property modifiers
 */
classAccessSpec returns [int spec]
	:	PUBLIC       { $spec = ACC_PUBLIC;     }
	|	FINAL        { $spec = ACC_FINAL;      }
	|	SUPER        { $spec = ACC_SUPER;      }
	|	INTERFACE    { $spec = ACC_INTERFACE;  }
	|	ABSTRACT     { $spec = ACC_ABSTRACT;   }
	|	SYNTHETIC    { $spec = ACC_SYNTHETIC;  }
	|	ANNOTATION   { $spec = ACC_ANNOTATION; }
	|	ENUM         { $spec = ACC_ENUM;       }
	;

/**
 * Fully qualified name of a class
 */
className returns [String name]
	:	str=STRING_LITERAL
	{
		$name = $str.text;
	}
	;

/**
 * Simple name of a class
 */
simpleClassName returns [String name]
	:	str=STRING_LITERAL
	{
		$name = $str.text;
	}
	;

/**
 * Definition of a field
 */
field
	:	FIELD_DIRECTIVE
		{
			int access = 0;
		}
		(a=fieldAccessSpec
			{
				access |= a;
			}
		)*
		name=fieldName desc=fieldDescriptor
		{
			cw.visitField(access, name, desc, null, null);
		}
	;

/**
 * Field access and property modifiers
 */
fieldAccessSpec returns [int spec]
	:	PUBLIC     { $spec = ACC_PUBLIC;     }
	|	PRIVATE    { $spec = ACC_PRIVATE;    }
	|	PROTECTED  { $spec = ACC_PROTECTED;  }
	|	STATIC     { $spec = ACC_STATIC;     }
	|	FINAL      { $spec = ACC_FINAL;      }
	|	VOLATILE   { $spec = ACC_VOLATILE;   }
	|	TRANSIENT  { $spec = ACC_TRANSIENT;  }
	|	SYNTHETIC  { $spec = ACC_SYNTHETIC;  }
	|	ENUM       { $spec = ACC_ENUM;       }
	;

/**
 * Name of a field
 */
fieldName returns [String name]
	:	str=STRING_LITERAL
	{
		$name = $str.text;
	}
	;

/**
 * Field descriptor
 */
fieldDescriptor returns [String desc]
	:	str=STRING_LITERAL
	{
		$desc = $str.text;
	}
	;

method
	:	METHOD_DIRECTIVE
	;

/**
 * Name of a method
 */
methodName returns [String name]
	:	str=STRING_LITERAL
	{
		$name = $str.text;
	}
	;

/**
 * Method descriptor
 */
methodDescriptor returns [String desc]
	:	str=STRING_LITERAL
	{
		$desc = $str.text;
	}
	;

/**
 * Attributes that can appear in the attributes table of a ClassFile structure.
 * Returns the value of signature attribute if found, else null
 */
classAttributes returns [String signature, boolean deprecated]
	:	ATTRIBUTES_DIRECTIVE
		(attrs=classAttribute
			{
				if ($attrs.signature != null)
					$signature = $attrs.signature;
				else if ($attrs.deprecated)
					$deprecated = $attrs.deprecated;
			}
		)*
		END_ATTRIBUTES_DIRECTIVE
	;

classAttribute returns [String signature, boolean deprecated]
	:	SOURCE_FILE_DIRECTIVE sourceFileName=STRING_LITERAL
			{   cw.visitSource($sourceFileName.text, null);   }	
	|	DEBUG_DIRECTIVE debug=STRING_LITERAL
			{   cw.visitSource(null, $debug.text);   }	
	|	INNER_CLASS_DIRECTIVE
			{
				int access = 0;
			}
		 (a=innerClassAccessSpec
		 	{
		 		access |= a;
			}
		 )*
		 name=className
			{
				cw.visitInnerClass(name, null, null, access);
			}
	|	INNER_CLASS_DIRECTIVE
			{
				int access = 0;
			}
		 (a=innerClassAccessSpec
		 	{
		 		access |= a;
		 	}
		 )*
		 innerName=simpleClassName EQUALS name=className (OF outerName=className)?
			{
				cw.visitInnerClass(name, outerName, innerName, access);
			}
	|	ENCLOSING_METHOD_DIRECTIVE outerClass=className outerMethod=methodName desc=methodDescriptor
			{
				cw.visitOuterClass(outerClass, outerMethod, desc);
			}
	|	SYNTHETIC_DIRECTIVE
			{
				cw.visitAttribute(new Attribute("Synthetic"){
					@Override
					protected ByteVector write(final ClassWriter cw, final byte[] code,
							final int len, final int maxStack, final int maxLocals) {
        				ByteVector v = new ByteVector();
        				v.putUTF8(this.type);
        				return v;
    				}
				});
			}
	|	SIGNATURE_DIRECTIVE s=STRING_LITERAL
			{
				$signature = $s.text;
			}
	|	DEPRECATED_DIRECTIVE
			{
				$deprecated = true;
			}
	;

/**
 * Access and property modifiers for inner classes
 */
innerClassAccessSpec returns [int spec]
	:	PUBLIC     { $spec = ACC_PUBLIC;     }
	|	PRIVATE    { $spec = ACC_PRIVATE;    }
	|	PROTECTED  { $spec = ACC_PROTECTED;  }
	|	STATIC     { $spec = ACC_STATIC;     }
	|	FINAL      { $spec = ACC_FINAL;      }
	|	INTERFACE  { $spec = ACC_INTERFACE;  }
	|	ABSTRACT   { $spec = ACC_ABSTRACT;   }
	|	SYNTHETIC  { $spec = ACC_SYNTHETIC;  }
	|	ANNOTATION { $spec = ACC_ANNOTATION; }
	|	ENUM       { $spec = ACC_ENUM;       }
	;