package lycan.components;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import tink.macro.Member;
import tink.macro.Types;

import lycan.components.Component;
import tink.macro.Exprs;

class ComponentBuilder {
	
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		
		// TODO Well, that didn't work.
		//// Transform all function bodies to use substitute field names when accessing entity
		//// e.g. entity.x becomes entity.entity_x
		//switch (Context.getLocalType()) {
			//case TInst(t, _):
				//trace("Begin expression substitution in " + t.get().name);
			//case _:
		//}
		//for (field in fields) {
			//trace("On field " + field.name);
			//switch(field.kind) {
				//case FFun(f):
					//trace("It's an FFun");
					//var func:Function = f;
					//func.expr = Exprs.transform(func.expr, function(expr:Expr):Expr {
						//switch (expr.expr) {
							//case EField(e, ef):
								//trace("Found an EField " + e + " " + ef);
								//switch (e.expr) {
									//case EConst(c):
										//trace("An EConst");
										//switch (c) {
											//case CIdent(i):
												//trace("of a CIdent... " + i);
												//trace("!!!!!!!!" + Exprs.typeof(e));
												//if (i == "entity") {
													//var newExpr:Expr = macro $p { ["entity", "entity_" + ef] };
													//trace("We're substituting the expression with " + newExpr);
													//return newExpr;
												//}
											//case _:
										//}
									//case _:
								//}
							//case _:
								//trace("Found an expression: " + expr.expr);
						//}
						//return expr;
					//});
				//case _:
					//trace("Skipped because is wasnt an FFun");
			//}
		//}
		
		return fields;
	}
	
}

