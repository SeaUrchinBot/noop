package noop.grammar


import org.scalatest.matchers.ShouldMatchers
import org.scalatest.Spec

/**
 * @author alexeagle@google.com (Alex Eagle)
 */

class TestSpec extends Spec with ShouldMatchers {
  val parser = new Parser();

  describe("tests") {
    it("should allow a unittest block in a class") {
      val source = "class Foo() { unittest \"testing 123\" {} }";
      parser.parseFile(source).toStringTree() should equal(
          "(CLASS Foo (UNITTEST \"testing 123\"))");
    }
    it("should not allow a unittest block in a method") {
      val source = "class Foo() { Int do() { unittest \"testing 123\" {} } }";
      intercept[ParseException] (
        parser.parseFile(source)
      );
    }
    it("should not allow a test block in a class") {
      val source = "class Foo() { test \"testing 123\" {} }";
      intercept[ParseException] (
        parser.parseFile(source)
      );
    }
    it("should allow a test block in a file") {
      val source = "test \"testing 123\" {}";
      parser.parseFile(source).toStringTree() should equal("(TEST \"testing 123\")");
    }
    it("should allow a unittest block in a test block") {
      val source = "test \"testing 123\" { unittest \"it should work\" {} }";
      parser.parseFile(source).toStringTree() should equal(
          "(TEST \"testing 123\" (UNITTEST \"it should work\"))");
    }
    it("should allow a test block in a test block") {
      val source = "test \"testing 123\" { test \"it should work\" {} }";
      parser.parseFile(source).toStringTree() should equal(
          "(TEST \"testing 123\" (TEST \"it should work\"))");
    }
    it("should not allow a unittest block in a unittest block") {
      val source = "unittest \"testing 123\" { unittest \"it should work\" {} }";
      intercept[ParseException] (
        parser.parseFile(source)
      );
    }
  }
}