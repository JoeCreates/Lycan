package lycan.util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import tink.macro.Types;

class NamedCollectionBuilder {

	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		// If get field has already been added, skip this macro
		for (field in fields) {
			if (field.name == "get") {
				return fields;
			}
		}
		
		// Get local type as ClassType
		var classType:ClassType;
		switch (Context.getLocalType()) {
			case TInst(r, _):
				classType = r.get();
			case _:
		}
		
		//trace(classType.superClass);
		
		var type:ComplexType = Types.toComplex(Context.getLocalType());
		var typePath:TypePath;
		switch (type) {
			case TPath(p):
				typePath = p;
			case _:
		}
		
		var newFieldsClass:TypeDefinition = macro class A {
			public static var instance:$type = new $typePath();
			
			public static function get(name:String) {
				return instance.map.get(name.toLowerCase());
			}
		};
		var newFields:Array<Field> = newFieldsClass.fields;
		
		fields.push(newFields[0]);
		fields.push(newFields[1]);
		
		return fields;
	}
	
}