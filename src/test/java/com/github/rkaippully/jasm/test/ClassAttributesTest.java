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

package com.github.rkaippully.jasm.test;

import static org.junit.Assert.*;
import static org.objectweb.asm.Opcodes.*;

import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;

import com.github.rkaippully.jasm.Assembler;

import org.junit.BeforeClass;
import org.junit.Test;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;

/**
 * Tests class level attributes
 */
public class ClassAttributesTest {

	private static ClassReader reader;

	@BeforeClass
	public static void assembleClassFile() throws Exception {
		Assembler assembler = new Assembler();
		assembler.assemble("src/test/resources/ClassAttributesTest.jasm");

		reader = new ClassReader(
				"com/github/rkaippully/jasm/test/gen/ClassAttributesTest");
	}

	@Test
	public void testSourceFileAndDebug() {
		reader.accept(new ClassVisitor(ASM4) {
			private String source;
			private String debug;

			@Override
			public void visitSource(String source, String debug) {
				this.source = source;
				this.debug = debug;
			}

			@Override
			public void visitEnd() {
				// We need this outside visitSource() because visitSource() may
				// not get called if source and debug are null
				assertEquals("ClassAttributesTest.jasm", source);
				assertEquals("SMAP\n*E\n", debug);
			}
		}, 0);
	}

	@Test
	public void testInnerClass() {
		class InnerClassInfo implements Comparable<InnerClassInfo> {
			public String name;
			public String outerName;
			public String innerName;
			public int access;

			@Override
			public int compareTo(InnerClassInfo that) {
				return this.name.compareTo(that.name);
			}
		}

		reader.accept(new ClassVisitor(ASM4) {
			private Set<InnerClassInfo> innerClasses = new TreeSet<>();

			@Override
			public void visitInnerClass(String name, String outerName,
					String innerName, int access) {
				InnerClassInfo innerClass = new InnerClassInfo();
				innerClass.name = name;
				innerClass.outerName = outerName;
				innerClass.innerName = innerName;
				innerClass.access = access;
				innerClasses.add(innerClass);
			}

			@Override
			public void visitEnd() {
				assertEquals(3, innerClasses.size());

				Iterator<InnerClassInfo> itr = innerClasses.iterator();

				InnerClassInfo innerClass = itr.next();
				assertEquals("com/github/rkaippully/jasm/test/gen/ClassAttributesTest$InnerClass1", innerClass.name);
				assertEquals("com/github/rkaippully/jasm/test/gen/ClassAttributesTest", innerClass.outerName);
				assertEquals("InnerClass1", innerClass.innerName);
				assertEquals(ACC_PROTECTED | ACC_STATIC, innerClass.access);

				innerClass = itr.next();
				assertEquals("com/github/rkaippully/jasm/test/gen/ClassAttributesTest$InnerClass2", innerClass.name);
				assertNull(innerClass.outerName);
				assertEquals("InnerClass2", innerClass.innerName);
				assertEquals(ACC_FINAL, innerClass.access);

				innerClass = itr.next();
				assertEquals("com/github/rkaippully/jasm/test/gen/ClassAttributesTest$InnerClass3", innerClass.name);
				assertNull(innerClass.outerName);
				assertNull(innerClass.innerName);
				assertEquals(ACC_FINAL, innerClass.access);
			}
		}, 0);
	}

	@Test
	public void testEnclosingMethod() {
		reader.accept(new ClassVisitor(ASM4) {
			private String outerClass;
			private String methodName;
			private String methodDesc;

			@Override
			public void visitOuterClass(String outerClass, String methodName, String methodDesc) {
				this.outerClass = outerClass;
				this.methodName = methodName;
				this.methodDesc = methodDesc;
			}

			@Override
			public void visitEnd() {
				assertEquals("com/github/rkaippully/jasm/test/gen/ClassAttributesTestOuter", outerClass);
				assertEquals("enclosingMethod", methodName);
				assertEquals("V", methodDesc);
			}
		}, 0);
	}
}
