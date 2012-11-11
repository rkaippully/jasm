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

/**
 * Tests class header level functionality
 */
public class ClassHeaderTest {

	private static ClassReader reader;

	@BeforeClass
	public static void assembleClassFile() throws Exception {
		Assembler assembler = new Assembler();
		assembler.assemble("src/test/resources/ClassHeaderTest.jasm");

		reader = new ClassReader("com/github/rkaippully/jasm/test/gen/ClassHeaderTest");
	}

	@Test
	public void testAccessFlags() {
		assertEquals(ACC_PUBLIC | ACC_SUPER, reader.getAccess());
	}

	@Test
	public void testClassName() {
		assertEquals("com/github/rkaippully/jasm/test/gen/ClassHeaderTest",
				reader.getClassName());
	}

	@Test
	public void testSuperClassName() {
		assertEquals("java/lang/Object", reader.getSuperName());
	}

	@Test
	public void testInterfaces() {
		assertArrayEquals(new String[] { "java/io/Serializable",
				"java/io/Externalizable" }, reader.getInterfaces());
	}
}
