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

package noop.model;

import interpreter.Context;
import types.{NoopInteger,NoopObject};

import scala.collection.mutable.Map;

/**
 * @author alexeagle@google.com (Alex Eagle)
 */
class IntLiteralExpression(val value: Int) extends Expression {

  def evaluate(c: Context): Option[NoopInteger] = {
    val noopIntegerClassDef = c.classLoader.findClass("Int");
    return Some(new NoopInteger(noopIntegerClassDef, Map.empty[String, NoopObject], value));
  }
}
