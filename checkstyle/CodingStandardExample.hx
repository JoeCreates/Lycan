package;

//import haxe.*; // Avoid star imports, explicitly list required imports.
//import haxe.Constraints; // Avoid unused imports.

interface MyInterface { // PascalCase/UpperCamelCase for interface names.
    public var x:Int; // Properties are allowed in interfaces.
    public function someFunction():String;
}

typedef PreferTypedefs = { // PascalCase/UpperCamelCase for typedef names.
    x:Int, y:Float
};

/**
 * An example to exercise all of the Haxe Checkstyle rules for Lycan's coding standard.
 * Methods are mostly written with examples of what you should not do followed by what you should do.
 */
class CodingStandardExample { // PascalCase/UpperCamelCase for class names
    // Constants
    private static inline var A_CONSTANT:Int = 200; // Upper case constant name with underscores to separate words.
    private static inline var ANOTHER_CONSTANT:Int = -20;
    private static inline var A_HEX_LITERAL:Int = 0xFFFFFF;
    //private static inline var misnamed_constant:Int = 10; // Incorrectly named constant.
    
    // Modifier order is [override][public/private][dynamic][static][inline][macro].
    //static inline private var AN_INCORRECT_MODIFIER_EXAMPLE:Float = 10.0;
    //inline private static var ANOTHER_INCORRECT_MODIFIER_EXAMPLE:Int = 2;
    public static inline var A_CORRECT_MODIFIER_EXAMPLE:Int = 10;
    
    private var camelCaseMemberName:Int; // Member variables are written in camelCase.
    
    // Instance member variable initialization
    //private var nonCtorInitialization:Int = A_CONSTANT; // Initialize variables in the constructor
    private var instanceMemberInitialization:Int; // Initialized in constructor
    
    public static function main():Void {
        // This comment fills the empty main() method body.
    }

    public function new() {
        shadowedField = A_CONSTANT; // Initializes a member variable that gets shadowed in one of the methods later. Prefer initialization in c'tor.
        camelCaseMemberName = ANOTHER_CONSTANT;
        instanceMemberInitialization = A_CONSTANT;
    }

    public function anonymousStructure():Void {
        // Don't use anonymous structures.
        //var incorrect: { x:Int, y:Float } = { x: 1, y: 1.0 };
        
        // Prefer typedefs.
        var correct:PreferTypedefs = {
            x: 1, y: 1.0
        };
    }
    
    public function arrayAccess():Void {
        var a:Array<String> = [ "Foo", "Bar", "Baz", "Boz" ];
        
        // Don't use spaces before or inside array element accesses.
        //var incorrect = a[ 0];
        //var alsoIncorrect = a[0 ];
        //var alsoAlsoIncorrect = a [0];
        
        // Preferred syntax.
        var foo = a[0];
    }
    
    public function arrayInstantiation():Void {
        // Don't use this long-handed way of instantiating arrays.
        //var incorrect:Array<String> = new Array();
        
        // Prefer shorter [] instantiation.
        var correct:Array<String> = [];
    }
    
    public function avoidInlineConditionals():Bool {
        var x = A_CONSTANT;
        //return x < ANOTHER_CONSTANT ? true : false; // Avoid this.
        
        if (x < A_CONSTANT) {
            return true;
        }
        return false;
    }
    
    public function catchParameterNames():Void {
        // Avoid the misnamed catch parameter.
        //try {
        //} catch (misnamed:Int) {
        //}
        
        try {
            // Empty block
        } catch (ex:Int) { // Catch parameter should be named 'ex'.
            // Empty block.
        }
    }
    
    public function defaultComesLast(x:Int):Void {
        // Don't do this, default should be the last label in the switch.
        //switch(x) {
        //    default:
        //    case 0:
        //}

        // Preferred usage.
        switch(x) {
            case 0:
            default:
        }
    }
    
    // Don't use Dynamic, prefer generics where possible.
    //private var dynamicValue:Dynamic;
    //public function dynamicTypeUsage(param:Dynamic):Dynamic {
    //    dynamicValue = 25;
    //    var v:Dynamic = null;
    //    return v;
    //}
    
    public function eregUsage():Void {
        // Either type of EReg usage is fine.
        var reg = new EReg("test", "i");
        var shortReg = ~/test/i;
    }
    
    public function emptyBlocks():Void {
        // Empty blocks are not allowed. For example, method bodies must contain a comment or statement, like this.
    }
    
    private var shadowedField:Int;
    public function hiddenFields():Void {
        //var shadowedField:Int = A_CONSTANT; // Do not give local variables names that are similar to or shadow member variable names.
        var nonShadowingField:Int = A_CONSTANT;
    }
    
    public function innerAssignment():Void {
        // Avoid assignments in subexpressions.
        var a = A_CONSTANT;
        var b = ANOTHER_CONSTANT;
        //if (a = b > 0) { // These are highly prone to being misread, or being a typo.
            // ...
        //}
        
        a = b; // Better, moved assignment out of the condition.
        if (a > 0) {
            // ...
        }
    }
    
    public function localVariableNames():Void {
        // Local variables should have camelCase names.
        //var NotCamelCase:Float = 20.0;
        var camelCase:Int = 0;
    }
     
    public function magicNumbers():Void {
        // Avoid use of magic numbers. Prefer named constants (static inlines) to magic numbers.
        
        // Exceptions to the magic number rule.
        var notMagic:Int = -1;
        var alsoNotMagic:Int = 0;
        var alsoAlsoNotmagic:Int = 1;
        
        // These should be handled by static inline vars.
        //var alsoMagic:Int = -2;
        //var magic:Int = 2;
    }
    
   //public function MethodNameThatIsNotCamelCase():Void {
        // Note this method does not have a camelCase name.
    //}
    
    public function methodNamesAreCamelCase():Void {
        // Note that the method name is camelCase.
    }
    
    private static inline var CONSTANT_TO_AVOID_MULTIPLE_STRING_LITERALS:String = "foo";
    public function multipleStringLiteralsInFile():Void {
        // More than two identical string literals in a file is disallowed, use constants instead.
        //var foo = "foo";
        //var anotherFoo = "foo";
        //var yetAnotherFoo = "foo";
        
        var foo = CONSTANT_TO_AVOID_MULTIPLE_STRING_LITERALS;
        var anotherFoo = CONSTANT_TO_AVOID_MULTIPLE_STRING_LITERALS;
        var yetAnotherFoo = CONSTANT_TO_AVOID_MULTIPLE_STRING_LITERALS;
    }
    
    public function multipleVariableDeclarationsOnLine():Void {
        // Avoid this
        //var a, b, c:Float = 0.0;
        
        // Each variable declaration must be in its own statement.
        var a:Float = 0.0;
        var b:Float = 0.0;
        var c:Float = 0.0;
    }
    
    public function neededBraces():Void {
        var x:Float = 0.0;
        //if (x > A_CONSTANT) x = ANOTHER_CONSTANT; // Single line if/loop statements are not allowed
        
        // Braces are required for if and looping constructs
        if (x > A_CONSTANT) {
            return;
        } else if (x < ANOTHER_CONSTANT) {
            return;
        }
        
        for (i in 0...A_CONSTANT) {
            x++;
        }
        
        while (x < ANOTHER_CONSTANT) {
            x++;
        }
        
        do {
            x++;
        } while (x < ANOTHER_CONSTANT);
    }
    
    public function nestedForDepth():Void {
        //for (i in 0...A_CONSTANT) {
        //    for (j in 0...A_CONSTANT) {
        //        for (k in 0...A_CONSTANT) { 
                    // Nested for depth too deep, refactor this code
        //        }
        //    }
        //}
        
        // Consider writing the above using helper functions or functors
    }
    
    public function nullableFunctionParameters(?x:Array<Int> /*, y:Array<Float> = null */ /*, ?z:Array<Float> = null */):Void {
        // Mark nullable parameters with a question mark
    }
    
    public function parameterNames(camelCase:Int, alphaNumeric123:Int):Void {
        // Parameter names are camelCase alphanumeric.
    }
    
    //public function parameterCountLimit(a:Int, b:Int, c:Int, d:Int, e:Int, f:Int, g:Int, h:Int):Void { // Bad, excessive number of parameters
    //    //...
    //}
    public function parameterCountLimit(structure:Array<Int>):Void { // Consolidate many parameters into a single structure.
        // In practice you would probably pass a user type, using an array for brevity.
    }
    
    //function redundantModifiers():Void {
        // Bad, explicitly state the access modifier.
    //}
    private function redundantModifiers():Void { // Good, explicit access modifier.
        //...
    }
    
    public function returnCount(?param:Null<Int>):Int {
        if (param == null) {
            return 0; // Early returns are fine.
        }
        
        switch(param) {
            case A_CONSTANT:
                return 0;
            case ANOTHER_CONSTANT:
                return 0;
        }
        
        return 0;
    }
    
    public function separatorWhitespace():Void {
        // One space comes after commas and semicolons used as separators.
        // var a = [0,0]; // Bad
        var a = [0, 0]; // Good
    }
    
    public function separatorLineWrap():Void {
        // Multi-line statement separators must not come at the end of lines
        // someTextObject. // Bad
        // text();
        
        // Multi-line statement separators come on new lines
        // someTextObject
        // .text(); // Good
    }
    
    public function simplifiedBooleanExpressions():Void {
        var b:Bool = false;
        
        // Avoid over-complicated boolean expressions
        //if (b == true) {
        //    //...   
        //}
        
        if (b) { // Better
            //... 
        }
    }
    
    public function simplifyBooleanReturns():Bool {
        var b:Bool = false;
        
        // Avoid over-complicated boolean return statements
        //if (b) {
        //    return true;
        //} else {
        //    return false;
        //}
        
        return b;
    }
    
    public function spacing():Void {
        if (A_CONSTANT < ANOTHER_CONSTANT) { // One space after the "if" and before the opening bracket, one space around the operator
            // Empty body
        }
    }
    
    public function stringLiteralUsage():Void {
        // var singleQuotes = 'Incorrect'; // Not allowed, prefer double quotes or interpolation
        var doubleQuotes = "Correct"; // Allowed.
        var x:Int = A_CONSTANT;
        var interpolation = '2x is ${x * 2}'; // Also allowed.
    }
    
    public function todoComments():Void {
        // Incomplete code should not be added to Lycan.
        // Consequently, comments that mark out incomplete code are not allowed.
        // Throw an exception, return an error code, or fix the code with unhandled options or code paths.
    }
    
    public function traceUsage():Void {
        //trace("Useful debug trace"); // Traces should be commented out before being committed to Lycan.
    }
    
    public function whitespaceAroundOperators():Void {
        // Haxe operators must be used with one space of whitespace padding around them.
        
        //var x = A_CONSTANT*ANOTHER_CONSTANT;
        var y = A_CONSTANT * ANOTHER_CONSTANT; // Clearer spacing.
    }
}