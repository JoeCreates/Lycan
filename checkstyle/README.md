# The Lycan Coding Standard

This is Lycan's coding standard. All Lycan code must conform to this standard.

[Haxe Checkstyle](https://github.com/HaxeCheckstyle/haxe-checkstyle) is used to write Haxe code that adheres to the standard.

## Setup

```
haxelib install checkstyle
```

## Usage

Open and build the FlashDevelop projects in this directory to get an interactive error report with highlighting. Alternatively, run Checkstyle in console:

```
haxelib run checkstyle -s ../lycan -c ./checkstyle_config.json
```

## Tips
* Run Checkstyle as a post-build step or as a compile-on-save option. This makes adhering to the coding standard less demanding.
* Explicitly exclude code from specific checks where required. Edit the ```excludes``` property in ```checkstyle_config.json``` to do this.
* Refer to the coding standard example code in the checkstyle directory.
* Refer to the [Haxe Checkstyle](http://haxecheckstyle.github.io/docs/haxe-checkstyle/home.html) documentation.

## The Coding Standard

### Anonymous Structures
Prefer typedefs to anonymous structures. Anonymous type usage is usually less readable than named types.

### Array Access
Avoid spaces before or inside array element accesses.

### Array Instantiation
Use ```[]``` to instantiate arrays, because this is shorter and cleaner than using ```new```.

### Avoid Inline Conditionals
Only use inline conditionals (```?``` operator) for ```if/else``` checks that end in assignment. Inline conditionals are usually harder to read than ```if/else``` chains.

### Avoid Star Imports
Avoid star imports, because they clutter the namespace they are added to. Explicitly list required imports for code clarity.

### Constant Names
Static and static inline variable names must be uppercase alphanumeric, with underscores to separate words.

### Cyclomatic Complexity
The [cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity) of methods must be under 10.

### Default Case Comes Last In Switch
The default keyword must come after the last ```case``` in a ```switch``` statement. This increases code readability.

### Dynamic Type Usage
Avoid use of Dynamic, prefer generics.

### EReg Usage
EReg instances can be created by calling the constructor, or with the ```~/pattern/modifier``` shorthand. Either is fine.

### Empty Blocks
Empty blocks are not allowed. Empty blocks, such as method bodies, must at least contain an explanatory comment.

### Empty Lines
A maximum of one empty line is allowed for separating anything. Empty lines are not allowed after multiline comments.

### Empty Packages
Empty packages are not allowed. Packages must adhere to the Lycan package structure.

### File Length
Files in Lycan should be less than 1000 lines long, with one file per class.

A class that exceeds this length may be taking on too many responsibilities, and should be reviewed to decide whether it is an exception to the rule, or needs to be reworked.

### Hexadecimal Literals
Hex literals are written uppercase e.g. 0xFFFFFF.

### Hidden Fields
Local variables or function parameters may not shadow fields defined in the same class. This excludes constructor parameters and setter methods, which should use carefully "this" to disambiguate.

### Indentation
Lycan uses tabs for indentation. For consistency, other indentation styles are banned from Lycan code.

## Inner Assignment
Avoid assignments in subexpressions. These are easily missed and can be mistaken for typos.

### Left Curly Braces
Lycan uses the one true brace style. Left curly braces go on the same line as the preceeding statement.

### Line Length
There is no limit to line length. However, this is not a reason to write complex expressions in a single line.

### Listener Names
Signal variables should be prefixed with "signal_". Slot methods have no required naming convention.

### Local Variable Names
Local variables follow an alphanumeric camelCase naming convention.

### Magic Numbers
Avoid magic numbers. Prefer named constants (static inlines). The exceptions to this are Ints and Floats -1, 0, and 1.

### Member Variable Names
Member variable names follow an alphanumeric camelCase naming convention.

### Member Method Limit
Limit the number of methods on a class to 50 or under.

### Method Length Limit
Limit method length to 50 lines or less.

### Method Names
Method names follow an alphanumeric camelCase naming convention.

### Modifier Order
Member modifier order is as follows [override][public/private][dynamic][static][inline][macro].

### Multiple String Literals In File
More than two identical string constants in a file is discouraged. Prefer constants (static inlines) wherever it makes sense.

### Multiple Variable Declarations On Line
Disallowed. Each variable declaration must be in its own statement.

### Needed Braces
One true brace style matching braces are required for ```for```, ```if/else if```, ```while``` and ```do while``` statements. Single line statements are not allowed.

### Nested For Depth
For loops may not be nested more than three deep.

### Nullable Function Parameters
Mark function parameters nullable with a question mark.

### Parameter Names
Method parameter names are camelCase alphanumeric.

### Parameter Count Limit
The maximum number of parameters a function may take is 7. In cases where more are really required, create separate types to contain related parameters and pass those instead.

### Redundant Modifiers
Modifiers access should be added to functions even where they are implicit. This ensures programmer intent is explicitly stated.

### Returns
Multiple returns in a function are sometimes useful for early exits. But it often makes code harder to debug, and is an indication that code should be refactored into smaller functions.

More than 4 returns in any single function will result in a style warning.

### Right Curly Braces
Lycan uses the one true brace style. Right curly braces go on a new line after the statement body.

### Separator Whitespace
One space comes after commas and semicolons where they are used as separators.

### Separator Line Wrap
Multi-line statement separators must come on new lines.

### Simplified Boolean Expressions
Do not unnecessary compare booleans to true or false. Use them directly and with the unary not operator.

### Spacing
Add one space after the "if" keyword and another between the closing parathesis and the opening bracket.

Use one space between binary operators and operands.

### String Literal Usage
String literals may be enclosed in double quotes. Single quotes are used with string interpolation.

### TODO Comments
Incomplete code must not be added to Lycan.

Throw an exception, return an error code, or refactor code with unhandled options or code paths. If a TODO must be added, label it with a link to the GitHub issue for the problem.

### Trace Usage
Traces useful for debugging purposes should be commented out before commit.

### Type Names
Use UpperCamelCase/PascalCase for class, interface and enum names.

### Unnecessary Constructors
Do not add constructors to classes that do not need them e.g. classes containing only static fields.

### Unused Imports
Unused imports are not allowed.

### Variable Initialization
Instance variables must be initialized in class constructors.

### Whitespace Around Binary Operators
All binary operators should be used with one space of whitespace padding around them.