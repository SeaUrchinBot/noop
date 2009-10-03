/**
 * Copyright 2009 Google Inc.
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
package noop.types;

import java.io.File;

import collection.mutable.Stack;

import org.scalatest.matchers.ShouldMatchers;
import org.scalatest.Spec;

import grammar.Parser;
import interpreter.{Frame, Context, SourceFileClassLoader}
import model.Modifier;

/**
 * @author Erik Soe Sorensen (eriksoe@gmail.com)
 */
class BooleanSpec extends Spec with ShouldMatchers {

  def createFixture = {
    val stdlibSourcePath = new File(getClass().getResource("/stdlib").toURI).getAbsolutePath();
    new SourceFileClassLoader(new Parser(), List(stdlibSourcePath))
  }

  describe("a Noop Boolean") {

    it("should have a valid class definition parsed from Noop source") {
      val classLoader = createFixture;
      val classDef = classLoader.findClass("Boolean");
      classDef.name should be("Boolean");
    }

    it("should have a native implementation of the xor method") {
      val classLoader = createFixture;
      val boolClass = classLoader.findClass("Boolean");
      val aTrue = new NoopBoolean(boolClass, Map.empty[String, NoopObject], true);
      val aFalse = new NoopBoolean(boolClass, Map.empty[String, NoopObject], false);
      val method = boolClass.findMethod("xor");
      val stack = new Stack[Frame]();
      val context = new Context(stack, classLoader);

      context.addRootFrame();
      method.modifiers should contain(Modifier.native);
      val frame = new Frame(aTrue, null);

      frame.addIdentifier("other", (null, aFalse));
      stack.push(frame);

      method.execute(context, null);
      val theBool = context.stack.top.lastEvaluated(0);

      theBool should not be (null);
      theBool.asInstanceOf[NoopBoolean].value should be(true);
    }
  }
}
