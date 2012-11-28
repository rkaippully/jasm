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

import java.util.ArrayList;
import java.util.List;

import com.github.rkaippully.jasm.Assembler;

import org.junit.BeforeClass;
import org.junit.Test;
import org.objectweb.asm.AnnotationVisitor;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;

/**
 * Tests class level attributes
 */
public class ClassAnnotationsTest {

	private static ClassReader reader;

	@BeforeClass
	public static void assembleClassFile() throws Exception {
		Assembler assembler = new Assembler();
		assembler.assemble("src/test/resources/ClassAnnotationsTest.jasm");

		reader = new ClassReader(
				"com/github/rkaippully/jasm/test/gen/ClassAnnotationsTest");
	}

	@Test
	public void testAnnotations() {

		reader.accept(new ClassVisitor(ASM4) {
			private boolean visibleVisited;
			private boolean invisibleVisited;

			class VisibleAnnotationVisitor extends AnnotationVisitor {

				public VisibleAnnotationVisitor(String desc) {
					super(ASM4);
					assertEquals("javax/annotation/Generated", desc);
				}

				@Override
				public void visit(String name, Object value) {
					assertEquals("date", name);
					assertEquals("2001-07-04T12:08:56.235-0700", value);
				}

				@Override
				public void visitEnum(String name, String desc, String value) {
					fail("visitEnum called with name=" + name + ", value="
							+ value + ", desc = " + desc);
				}

				@Override
				public AnnotationVisitor visitAnnotation(String name,
						String desc) {
					fail("visitAnnotation called with name=" + name
							+ ", desc = " + desc);
					return null;
				}

				@Override
				public AnnotationVisitor visitArray(String name) {
					assertEquals("value", name);
					return new AnnotationVisitor(ASM4) {
						private List<Object> arrayEntries = new ArrayList<>(2);

						@Override
						public void visit(String name, Object value) {
							arrayEntries.add(value);
						}

						@Override
						public void visitEnd() {
							assertEquals(2, arrayEntries.size());
							assertEquals("codegen1", arrayEntries.get(0));
							assertEquals("codegen2", arrayEntries.get(1));
						}
					};
				}

				@Override
				public void visitEnd() {
					visibleVisited = true;
				}
			}

			class InvisibleAnnotationVisitor extends AnnotationVisitor {
				public InvisibleAnnotationVisitor(String desc) {
					super(ASM4);
					assertEquals("java/lang/Deprecated", desc);
				}

				@Override
				public void visit(String name, Object value) {
					fail("visit called with name=" + name + ", value=" + value);
				}

				@Override
				public void visitEnum(String name, String desc, String value) {
					fail("visitEnum called with name=" + name + ", value="
							+ value + ", desc = " + desc);
				}

				@Override
				public AnnotationVisitor visitAnnotation(String name,
						String desc) {
					fail("visitAnnotation called with name=" + name
							+ ", desc = " + desc);
					return null;
				}

				@Override
				public AnnotationVisitor visitArray(String name) {
					fail("visitArray called with name=" + name);
					return null;
				}

				@Override
				public void visitEnd() {
					invisibleVisited = true;
				}
			}

			@Override
			public AnnotationVisitor visitAnnotation(String desc,
					boolean visible) {
				if (visible)
					return new VisibleAnnotationVisitor(desc);
				else
					return new InvisibleAnnotationVisitor(desc);
			}

			@Override
			public void visitEnd() {
				assertTrue(visibleVisited);
				assertTrue(invisibleVisited);
			}
		}, 0);
	}
}
