package lycan.constraint.tests;

import haxe.unit.TestCase;
import lycan.constraint.frontend.ConstraintParser;

@:access(lycan.constraint.frontend.ConstraintParser)
class TestInfixToPostfix extends TestCase {
	public function testInfixToPostfixBasic():Void {
		var infix:Array<String> = ["3", "+", "4", "*", "2", "/", "(", "1", "-", "5", ")", "^", "2", "^", "3"];
		var postfix:Array<String> = ConstraintParser.infixToPostfix(infix);
		var index = 0;
		Sure.sure(postfix[index++] == "3");
		Sure.sure(postfix[index++] == "4");
		Sure.sure(postfix[index++] == "2");
		Sure.sure(postfix[index++] == "*");
		Sure.sure(postfix[index++] == "1");
		Sure.sure(postfix[index++] == "5");
		Sure.sure(postfix[index++] == "-");
		Sure.sure(postfix[index++] == "2");
		Sure.sure(postfix[index++] == "3");
		Sure.sure(postfix[index++] == "^");
		Sure.sure(postfix[index++] == "^");
		Sure.sure(postfix[index++] == "/");
		Sure.sure(postfix[index++] == "+");
	}
}

class TestExpressionTokenizer extends TestCase {
	public function testTokenWithSpaces():Void {
		// TODO
	}
}