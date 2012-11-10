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

import com.github.rkaippully.jasm.Assembler;

import org.junit.BeforeClass;
import org.junit.Test;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.FieldVisitor;

/**
 * Tests fields in a class
 */
public class FieldsTest {

	private static ClassReader reader;

	@BeforeClass
	public static void assembleClassFile() throws Exception {
		Assembler assembler = new Assembler();
		assembler.assemble("src/test/resources/FieldsTestGen.jasm");

		reader = new ClassReader("com/github/rkaippully/jasm/test/gen/FieldsTestGen");
	}

	@Test
	public void testAccessFlags() {
		ClassVisitor v = new ClassVisitor(ASM4) {
			private int access;

			@Override
			public FieldVisitor visitField(int access, String name,
					String desc, String signature, Object value) {
				this.access = access;
				return null;
			}

			@Override
			public void visitEnd() {
				assertEquals(ACC_PRIVATE, this.access);
			}
		};

		reader.accept(v, 0);
	}

	@Test
	public void testFieldName() {
		ClassVisitor v = new ClassVisitor(ASM4) {
			private String name;

			@Override
			public FieldVisitor visitField(int access, String name,
					String desc, String signature, Object value) {
				this.name = name;
				return null;
			}

			@Override
			public void visitEnd() {
				assertEquals("field1", this.name);
			}
		};

		reader.accept(v, 0);
	}

	@Test
	public void testFieldDescriptor() {
		ClassVisitor v = new ClassVisitor(ASM4) {
			private String descriptor;

			@Override
			public FieldVisitor visitField(int access, String name,
					String desc, String signature, Object value) {
				this.descriptor = desc;
				return null;
			}

			@Override
			public void visitEnd() {
				assertEquals("[I", this.descriptor);
			}
		};

		reader.accept(v, 0);
	}
}
