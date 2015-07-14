package lycan.ui.widgets.constraint;

/*
import lycan.constraint.DebugHelper;
import lycan.constraint.Expression;
import lycan.constraint.frontend.ConstraintParser;
import lycan.constraint.frontend.IResolver;
import lycan.constraint.frontend.JsonTypes.ConstraintDefinition;
import lycan.constraint.Solver;
import lycan.constraint.Strength;
import lycan.constraint.Variable;
import lycan.ui.widgets.Widget;

@:enum abstract UIConstraintType(String) {
	var Width = "width";
	var Height = "height";
	var Left = "left";
	var Right = "right";
	var Top = "top";
	var Bottom = "bottom";
	var InnerLeft = "innerleft";
	var InnerRight = "innerright";
	var InnerTop = "innertop";
	var InnerBottom = "innerbottom";
	var OuterLeft = "outerleft";
	var OuterRight = "outerright";
	var OuterTop = "outertop";
	var OuterBottom = "outerbottom";
}

class ConstraintManager {
	private var root:Widget;
	private var widgets:Map<Widget, Array<Variable>>;
	private var solver:Solver;
	
	public function new(root:Widget) {
		solver = new Solver();
		widgets = new Map<Widget, Array<Variable>>();
		this.root = root;
		registerRoot(root);
	}
	
	private function registerRoot(root:Widget):Void {
		Sure.sure(root != null);
		
		var width:Variable = resolveVariable(root, Width);
		var height:Variable = resolveVariable(root, Height);
		
		solver.addEditVariable(width, Strength.strong);
		solver.addEditVariable(height, Strength.strong);
	}
	
	public function register(widget:Widget):Void {
		Sure.sure(widget != null);
		Sure.sure(widget.name != null);
		
		if (widget.name == null) {
			throw "Widget must be named to be handled by constraint solver";
		}
		
		#if debug
		for (w in widgets.keys()) {
			if (widget == w) {
				throw "Duplicate widget registered on UI constraint solver";
			}
		}
		#end
		
		var parent:Dynamic = widget.parent;
		
		if (widget != root && parent == null) {
			throw "Invalid widget";
		}
		
		var width:Variable = resolveVariable(widget, Width);
		var height:Variable = resolveVariable(widget, Height);
		
		var left:Variable = resolveVariable(widget, Left);
		var right:Variable = resolveVariable(widget, Right);
		var top:Variable = resolveVariable(widget, Top);
		var bottom:Variable = resolveVariable(widget, Bottom);
		
		var innerLeft:Variable = resolveVariable(widget, InnerLeft);
		var innerRight:Variable = resolveVariable(widget, InnerRight);
		var innerTop:Variable = resolveVariable(widget, InnerTop);
		var innerBottom:Variable = resolveVariable(widget, InnerBottom);
		
		var outerLeft:Variable = resolveVariable(widget, OuterLeft);
		var outerRight:Variable = resolveVariable(widget, OuterRight);
		var outerTop:Variable = resolveVariable(widget, OuterTop);
		var outerBottom:Variable = resolveVariable(widget, OuterBottom);
		
		// TODO it's really up to the layouts/widgets and their parents to provide the constraints, we should just register the absolutely required ones here e.g. padding constraints between child and parent?
		
		// TODO constructing stuff to then be parsed like this is incredibly inefficient
		
		// TODO note that only the variable should go on the LHS or the parser will screw up and may add variables with names like "x1 + x2"
		var constraintDefinitions = new Array<ConstraintDefinition>();
		var addDef = function(inequality:String, ?strength:String):Void {
			if (strength == null) {
				strength = "required";
			}
			constraintDefinitions.push( { inequality: inequality, strength: strength } );
		}
		
		if (widget == root) {			
			//addDef(left.name + " >= " + Std.string(0));
			//addDef(right.name + " <= " + Std.string(10000));
			//addDef(top.name + " >= " + Std.string(0));
			//addDef(bottom.name + " <= " + Std.string(10000));
		} else {
			var parentWidth:Variable = resolveVariable(cast widget.parent, Width);
			var parentHeight:Variable = resolveVariable(cast widget.parent, Height);
			
			//var parentLeft:Variable = resolveVariable(cast widget.parent, Left);
			//var parentRight:Variable = resolveVariable(cast widget.parent, Right);
			//var parentTop:Variable = resolveVariable(cast widget.parent, Top);
			//var parentBottom:Variable = resolveVariable(cast widget.parent, Bottom);
			
			if (widget.widthHint != -1) {
				//addDef(width.name + " == " + Std.string(widget.widthHint), "weak"); // TODO take into account the widget margin and parent padding
			}
			addDef(width.name + " == " + parentWidth.name);
			
			if (widget.heightHint != -1) {
				//addDef(height.name + " == " + Std.string(widget.heightHint), "weak");
			}
			addDef(height.name + " == " + parentHeight.name);
			
			//addDef(left.name + " >= " + parentLeft.name);
			//addDef(right.name + " <= " + parentRight.name + "-" + width.name);
			//addDef(top.name + " >= " + parentTop.name);
			//addDef(bottom.name + " <= " + parentBottom.name + "-" + height.name);
		}
		
		addDef(width.name + " <= " + Std.string(widget.maxWidth), "strong");
		addDef(height.name + " <= " + Std.string(widget.maxHeight), "strong");
		addDef(width.name + " >= " + Std.string(widget.minWidth), "strong");
		addDef(height.name + " >= " + Std.string(widget.minHeight), "strong");
		
		//addDef(innerLeft.name + " == " + left.name + " + " + Std.string(widget.paddingLeft));
		//addDef(innerRight.name + " == " + right.name + " - " + Std.string(widget.paddingRight));
		//addDef(innerTop.name + " == " + top.name + " + " + Std.string(widget.paddingTop));
		//addDef(innerBottom.name + " == " + bottom.name + " - " + Std.string(widget.paddingBottom));
		
		//addDef(outerLeft.name + " == " + left.name + " - " + Std.string(widget.marginLeft));
		//addDef(outerRight.name + " == " + right.name + " + " + Std.string(widget.marginRight));
		//addDef(outerTop.name + " == " + top.name + " - " + Std.string(widget.marginTop));
		//addDef(outerBottom.name + " == " + bottom.name + " + " + Std.string(widget.marginBottom));
		
		// Makes the parser reuse variables, rather than creating new ones
		var resolver = new WidgetContextResolver();
		resolver.context = widgets.get(widget);
		if(widget.parent != null) {
			resolver.context = resolver.context.concat(widgets.get(cast widget.parent));
		}
		
		for (def in constraintDefinitions) {
			var constraint = ConstraintParser.parseConstraint(def.inequality, def.strength, resolver);
			solver.addConstraint(constraint);
		}
		
		update();
	}
	
	public function deregisterWidget(widget:Widget):Void {
		Sure.sure(widget != null);
		// TODO
		
		// TODO remove all variables from solver that reference the widget? or zero them out...?
	}
	
	// TODO generalize this
	public function resizeRoot(width:Int, height:Int):Void {		
		if (width <= 0 || height <= 0) {
			return;
		}
		
		var w:Variable = resolveVariable(root, Width);
		var h:Variable = resolveVariable(root, Height);
		solver.suggestValue(resolveVariable(root, Width), width);
		solver.suggestValue(resolveVariable(root, Height), height);
		trace("Suggested width: " + width + " and height: " + height);
		
		update();

		DebugHelper.dumpSolverState(solver);
	}
	
	// Updates the positions and sizes of all widgets under the control of the solver
	// This needs to be called whenever the window resizes, or when widgets get moved, reparented etc (TODO this needs optimizing heavily)
	public function update():Void {
		solver.updateVariables();
		
		for (widget in widgets.keys()) {
			//widget.x = Std.int(resolveVariable(widget, OuterLeft).value);
			//widget.y = Std.int(resolveVariable(widget, OuterTop).value);
			widget.width = Std.int(resolveVariable(widget, Width).value);
			widget.height = Std.int(resolveVariable(widget, Height).value);
			//widget.paddingLeft = Std.int(resolveVariable(widget, InnerLeft).value);
			//widget.paddingRight = Std.int(resolveVariable(widget, InnerRight).value);
			//widget.paddingTop = Std.int(resolveVariable(widget, InnerTop).value);
			//widget.paddingBottom = Std.int(resolveVariable(widget, InnerBottom).value);
			//widget.marginLeft = Std.int(resolveVariable(widget, OuterLeft).value);
			//widget.marginRight = Std.int(resolveVariable(widget, OuterRight).value);
			//widget.marginTop = Std.int(resolveVariable(widget, OuterTop).value);
			//widget.marginBottom = Std.int(resolveVariable(widget, OuterBottom).value);
		}
		
		
	}
	
	private function resolveVariable(widget:Widget, constraintType:UIConstraintType):Variable {
		Sure.sure(widget != null);
		Sure.sure(constraintType != null);
		
		var variables:Array<Variable> = widgets.get(widget);
		
		if (variables == null) {
			variables = new Array<Variable>();
		} else {
			for (v in variables) {
				if (v.name == (widget.name + constraintType)) {
					return v;
				}
			}
		}
		var v = new Variable(widget.name + constraintType);
		variables.push(v);
		widgets.set(widget, variables);
		return v;
	}
}

// TODO optimize this whole implementation - maybe use unique ids for names and make the solver use ints rather than strings. also avoid use of map stuff for lookup when the usual widget constraint names can be known in advance
// TODO the resolver isn't going to receive messages when widget properties change currently, but it should - we should attach to various signals when registering a widget so that we can update constraints when stuff like the widget's minWidth changes
private class WidgetContextResolver implements IResolver {
	public var context:Array<Variable>;
	
	public function new(?context:Array<Variable>) {
		if (this.context == null) {
			context = new Array<Variable>();
		}
		this.context = context;
	}
	
	public function resolveVariable(name:String):Variable {		
		for (v in context) {
			if (v.name == name) {
				return v;
			}
		}
		var v = new Variable(name);
		context.push(v);
		return v;
	}
	
	public function resolveConstant(expression:String):Expression {
		var constant:Float = Std.parseFloat(expression);
		if (Math.isNaN(constant)) {
			return null;
		}
		return new Expression(constant);
	}
}
*/