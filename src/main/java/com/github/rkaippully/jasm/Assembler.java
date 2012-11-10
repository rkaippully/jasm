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

package com.github.rkaippully.jasm;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.antlr.runtime.ANTLRInputStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.RecognizerSharedState;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeNodeStream;

/**
 * Provides a public API to invoke the assembler.
 */
public class Assembler {

	public void assemble(String fileName) throws IOException,
			RecognitionException {
		assemble(new FileInputStream(fileName));
	}

	public void assemble(InputStream in) throws IOException,
			RecognitionException {
		JasmLexer lex = new JasmLexer(new ANTLRInputStream(in));
		CommonTokenStream tokens = new CommonTokenStream(lex);

		RecognizerSharedState state = new RecognizerSharedState();
		JasmParser parser = new JasmParser(tokens, state);

		CommonTree tree = (CommonTree) parser.assemblyUnit().getTree();
		if (state.syntaxErrors == 0) {
			JasmTreeWalker walker = new JasmTreeWalker(
					new CommonTreeNodeStream(tree));
			walker.assemblyUnit();
		} else {
			// TODO: implement error recovery/handling
			throw new IllegalArgumentException();
		}
	}
}
