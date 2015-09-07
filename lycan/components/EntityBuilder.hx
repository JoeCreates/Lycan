package lycan.components;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import tink.macro.ClassBuilder;
import tink.macro.Exprs;
import tink.macro.Types;

import lycan.components.Component;

class EntityBuilder {
	
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		// We do something different if the local type is an interface
		switch(Context.getLocalType()) {
			case TInst(rt, _):
				if (rt.get().isInterface) return buildComponentInterface();
			case _:
				return fields;
		}
		
		//TODO possibly not needed
		for (field in fields) {
			if (field.name == "components") {
				return fields;
			}
		}
		
		// Add components field
		fields.push({
			name: "components",
			doc: null,
			meta: [],
			access: [APublic],
			kind: FVar(macro :Array<lycan.components.Component<Dynamic>>,
				macro new Array<lycan.components.Component<Dynamic>>() ),
			pos: Context.currentPos()
		});
		
		var addedDraw:Bool = false;
		var addedUpdate:Bool = false;
		var addedLateUpdate:Bool = false;
		
		// Add component drawing
		for (field in fields) {
			switch (field.kind) {
				case FFun(func):
					if (field.name == "draw") {
						appendDraw(func);
						addedDraw = true;
					}
					if (field.name == "update") {
						appendUpdate(func);
						addedUpdate = true;
					}
					if (field.name == "lateUpdate") {
						appendLateUpdate(func);
						addedLateUpdate = true;
					}
				case _:
			}
		}
		
		if (!addedDraw) {
			var f:Bool = hasInheritedFunction(TypeTools.getClass(Context.getLocalType()), "draw");
			// If we find the function in a superclass, override it
			if (f) {
				appendDraw(overrideFunction("draw", { args: [], ret: null, expr: macro { super.draw(); }}, fields ));
			}
			// Otherwise, create it
			else {
			appendDraw(addFunction("draw", {args: [], ret: null, expr: macro {}}, fields));
			}
		}
		
		if (!addedUpdate) {
			var f:Bool = hasInheritedFunction(TypeTools.getClass(Context.getLocalType()), "update");
			// If we find the function in a superclass, override it
			if (f) {
				appendUpdate(overrideFunction("update", {
					args: [{ name: "dt", type: TPath( { pack: [], name: "Float" } )}],
					ret: null,
					expr: macro super.update(dt)
				}, fields));
			}
			// Otherwise, create it
			else {
				appendUpdate(addFunction("update", {
					args: [{ name: "dt", type: TPath( { pack: [], name: "Float" } )}],
					ret: null,
					expr: macro {}
				}, fields));
			}
		}
		
		if (!addedLateUpdate) {
			var f:Bool = hasInheritedFunction(TypeTools.getClass(Context.getLocalType()), "lateUpdate");
			// If we find the function in a superclass, override it
			if (f) {
				appendLateUpdate(addFunction("lateUpdate", {
					args: [{ name: "dt", type: TPath( { pack: [], name: "Float" } )}],
					ret: null,
					expr: macro super.lateUpdate(dt)
				}, fields));
			}
			// Otherwise, create it
			else {
				appendLateUpdate(addFunction("lateUpdate", {
					args: [{ name: "dt", type: TPath( { pack: [], name: "Float" } )}],
					ret: null,
					expr: macro {}
				}, fields));
			}
		}
		
		// Add getters and setters for entity_ properties
		// for each field that isn't the component field
		for (dummyField in getDummyPropertyFields()) {
			// Check if the entity_ property already exists
			var found:Bool = false;
			for (field in fields) {
				if (field.name == "entity_" + dummyField.name) {
					found = true;
					break;
				}
			}
			// If not, create it
			if (!found) {
				fields.push({
					name: dummyField.name,
					doc: null,
					meta: [],
					access: [APublic],
					kind: FProp(
						"get", "set",
						Types.toComplex(dummyField.type),
						null ),
					pos: Context.currentPos()
				});
				// And create getter/setter
				fields.push({
					name: "get_" + dummyField.name,
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({
						args: [],
						ret: Types.toComplex(dummyField.type),
						expr: macro return $i { dummyField.name.substring(7, dummyField.name.length)}
					}),
					pos: Context.currentPos()
				});
				fields.push({
					name: "set_" + dummyField.name,
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({
						args: [ {
							name: "value",
							type: Types.toComplex(dummyField.type)
						}],
						ret: Types.toComplex(dummyField.type),
						expr: macro {
							return $i { dummyField.name.substring(7, dummyField.name.length)} = value;
						}
					}),
					pos: Context.currentPos()
				});
			}			
		}
		
		// Append component instantiation to constructor
		var componentFields:Map<String, ClassField> = getComponentFields();
		var appendComponentInstantiation:Expr->TypePath->Expr = function(e:Expr, c:TypePath) {
			var found:Bool = false;
			for (field in fields) {
				if (field.name == c.name) {
					found = true;
					break;
				}
			}
			// If we do not have a field for the component, create one
			if (!found) {
				fields.push({
					name: componentFields.get(c.name).name,
					doc: null,
					meta: [],
					access: [APublic],
					kind: FVar(TPath(c), null),
					pos: Context.currentPos()
				});
			}
			return macro {
				$ { e };
				$i{componentFields.get(c.name).name} = new $c(this);
				components.push($i{componentFields.get(c.name).name});
			}
		}
		for (field in fields) {
			switch (field.kind) {
				case FFun(func) if (field.name == "new"):
					for (componentInterface in getComponentInterfaces()) {
						func.expr = appendComponentInstantiation(func.expr,
							{pack: componentInterface.pack, name: componentInterface.name + "Component"});
					}
				case _:
			}
		}
		
		return fields;
	}
	
	public static function getDummyPropertyFields():Array<ClassField> {
		var fields:Array<ClassField> = new Array<ClassField>();
		var fieldNameMap:Map<String, ClassField> = new Map<String, ClassField>();
		for (componentInterface in getComponentInterfaces()) {
			for (field in getDummyPropertyFieldsFromInterface(componentInterface)) {
				// If field not yet in array, add it
				if (!fieldNameMap.exists(field.name)) {
					fields.push(field);
					fieldNameMap.set(field.name, field);
				}
			}
		}
		return fields;
	}
	
	public static function getDummyPropertyFieldsFromInterface(componentInterface:ClassType):Array<ClassField> {
		var fields:Array<ClassField> = new Array<ClassField>();
		for (field in componentInterface.fields.get()) {
			switch(field.type) {
				case TInst(t, _):
					if (t.get().name != componentInterface.name + "Component") {
						fields.push(field);
					}
				case _:
					fields.push(field);
			}
		}
		return fields;
	}
	
	/** Create map of component field type names to their corresponding ClassFields */
	public static function getComponentFields() {
		var componentFields:Map<String, ClassField> = new Map<String, ClassField>();
		for (i in getComponentInterfaces()) {
			var componentField:ClassField = getComponentField(i);
			if (componentField != null) {
				switch (componentField.type) {
					case TInst(t, _):
						componentFields.set(t.get().name, getComponentField(i));
					case _:
				}
			} else {
				throw("Component interface is missing a field for the component");
			}
		}
		return componentFields;
	}
	
	public static function getComponentField(componentInterface:ClassType):ClassField {
		for (field in componentInterface.fields.get()) {
			switch(field.type) {
				case TInst(t, _):
					if (t.get().name == componentInterface.name + "Component") {
						return field;
					}
				case _:
			}
		}
		return null;
	}
	
	/** Recursively check if given ClassType implements interface of given name */
	public static function hasInterface(type:ClassType, interfaceName:String):Bool {
		for (i in type.interfaces) {
			// Check if this ClassType is the required interface
			if (i.t.get().name == interfaceName) {
				return true;
			}
			// If not, check its own interfaces TODO not even necessary?
			if (hasInterface(i.t.get(), interfaceName)) {
				return true;
			}
		}
		return false;
	}
	
	public static function getComponentInterfaces():Array<ClassType> {
		var out:Array<ClassType> = new Array <ClassType>();
		switch(Context.getLocalType()) {
			case TInst(r, _):
				for (i in r.get().interfaces) {
					if (hasInterface(i.t.get(), "Entity")) {
						out.push(i.t.get());
					}
				}
			case _:
		}
		return out;
	}
	
	public static function overrideFunction(name:String, func:Function, fields: Array<Field>):Function {
		fields.push({
			name: name,
			doc: null,
			meta: [],
			access: [AOverride, APublic],
			kind: FFun(func),
			pos: Context.currentPos()
		});
		return func;
	}
	
	public static function addFunction(name:String, func:Function, fields: Array<Field>):Function {
		fields.push({
			name: name,
			doc: null,
			meta: [],
			access: [APublic],
			kind: FFun(func),
			pos: Context.currentPos()
		});
		return func;
	}
	
	/** Attempt to get a function from a given class, excluding inherited functions */
	public static function hasFunction(classType:ClassType, name:String):Bool {
		for (field in classType.fields.get()) {
			switch (field.kind) {
				case FMethod(_) if (field.name == name):
					return true;
				case _:
			}
		}
		return false;
	}
	
	/** Attempt to get a function from a given class, including inherited functions */
	public static function hasInheritedFunction(superClass:ClassType, name:String):Bool {
		if (hasFunction(superClass, name)) return true;
		
		// If no superclass, return false
		if (superClass.superClass == null) return false;
		// Otherwise recursively check superclasses
		return hasInheritedFunction(superClass.superClass.t.get(), name);
	}
	
	public static function appendDraw(func:Function):Void {
		func.expr = macro {
			${func.expr};
			for (component in components) {
				if (component.requiresDraw) {
					component.draw();
				}
			}
		}
	}
	
	public static function appendUpdate(func:Function):Void {
		func.expr = macro {
			${func.expr};
			for (component in components) {
				if (component.requiresUpdate) {
					component.update($i{func.args[0].name});
				}
			}
		}
	}
	
	public static function appendLateUpdate(func:Function):Void {
		func.expr = macro {
			${func.expr};
			for (component in components) {
				if (component.requiresLateUpdate) {
					component.lateUpdate($i{func.args[0].name});
				}
			}
		}
	}
	
	public static function buildComponentInterface():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		// For each field, check it is not the field for the component, then change its name
		for (field in fields) {
			switch (field.kind) {
				case FProp(_, _, t, _):
					switch (t) {
						case TPath(p):
							// If this field is for the component, skip it
							switch (Context.getLocalType()) {
								case TInst(r, _):
									var c:ClassType = r.get();
									if (p.pack == c.pack && p.name == c.name + "Component") {
										continue;
									}
								case _:
							}
							// Otherwise, rename it
							field.name = "entity_" + field.name;
						case _:
					}
				case _:
			}
		}
		
		return fields;
		
	}
}

