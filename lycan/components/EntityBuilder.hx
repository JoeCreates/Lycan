package lycan.components;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import tink.macro.ClassBuilder;
import tink.macro.Exprs;
import tink.macro.Types;

/**
 * TODO
 * - Remove need to override new (will need to add a new field to classes that miss one)
 * - Add append and prepend metadatas to inject method calls into entity methods
 * - Identify component field with metadata? Not sure about this one.
 * - Allow dummy fields to be named in metadata
 * 
 * Documentation
 * Using append to destroy components in entity's detroy method
 * Using append to add component to signals
 */

class EntityBuilder {
	
	public static var packagePath:Array<String> = ["lycan.components"];
	public static var entityPath:TypePath = {pack: packagePath, name: "Entity"};
	public static var componentPath:TypePath = {pack: packagePath, name: "Component"};
	
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		// Get local type as ClassType
		var classType:ClassType = TypeTools.getClass(Context.getLocalType());
		
		// Prevent a type from being built twice
		// Adds a metadata if this is first time building, or returns early if it already
		// has the metadata
		if (classType.meta.has("EntityBuilderBuilt")) {
			return fields;
		}
		classType.meta.add("EntityBuilderBuilt", [], Context.currentPos());
		
		// If we are building an interface, do buildComponentInterface instead of proceeding
		switch(Context.getLocalType()) {
			case TInst(rt, _):
				if (rt.get().isInterface)
					return buildComponentInterface(classType, fields);
				else 
					return buildComponentClass(classType, fields);
			case _:
				return fields;
		}
		
	}
		
	/** Return list of interfaces on this class that extend Entity (i.e. component interfaces) */
	public static function getComponentInterfaces():Array<ClassType> {
		var out:Array<ClassType> = new Array<ClassType>();
		switch(Context.getLocalType()) {
			case TInst(r, _):
				for (i in r.get().interfaces) {
					if (hasInterface(i.t.get(), "Entity")) {
						// If we haven't already, add the interface to output array
						if (out.indexOf(i.t.get()) < 0) {
							out.push(i.t.get());
						}
					}
				}
			case _:
		}
		return out;
	}
	
	
	/** Function to build a class which extends Entity */
	public static function buildComponentClass(classType:ClassType, fields:Array<Field>):Array<Field> {
		
		//TODO remove requirement for constructor to build
		
		// Get list of interfaces on this class which extend Entity
		var componentInterfaces:Array<ClassType> = getComponentInterfaces();
		
		// Add components field
		if (!hasField(classType, "components")) {
			var c = macro class {
				// TODO make it possible to customise this name
				public var components:Array<components.Component<Dynamic>> = [];
			}
			fields.push(c.fields[0]);
		}
		
		// Add getters and setters for entity_ properties
		// for each field that isn't the component field
		for (dummyField in getDummyPropertyFields(componentInterfaces)) {
			
			// Skip adding dummy field if class already has field with the same name
			if (hasField(classType, dummyField.name)) {
				continue;
			}
			
			// Create the dummy field
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
			
			// Check we actually have a field for the dummy field to refer to
			var dummySourceFieldName:String = dummyField.name.substring(7, dummyField.name.length);
			if (!hasField(classType, dummySourceFieldName)) {
				throw("Field " + dummySourceFieldName + " ("+ dummyField.name+") required by component interface is missing in " + classType.name);
			}
			
			// And create getter/setter
			fields.push({
				name: "get_" + dummyField.name,
				doc: null,
				meta: [],
				access: [APublic],
				kind: FFun({
					args: [],
					ret: Types.toComplex(dummyField.type),
					expr: macro return $i { dummySourceFieldName }
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
						return $i { dummySourceFieldName } = value;
					}
				}),
				pos: Context.currentPos()
			});
		}
		
		// Prepend component instantiation to constructor
		var componentFields:Map<String, {field:ClassField, componentInterface:ClassType}> = getComponentFields(componentInterfaces);
		
		var prependComponentInstantiation:Expr->TypePath->Expr = function(e:Expr, c:TypePath) {
			var field = componentFields.get(c.name).field;
			if (hasField(classType, field.name)) {
				throw("Class " + classType.pack + "." + classType.name + " has field " +
					field.name + ", which must not be declared as it is required by " + c.name);
			}
			
			// If we do not have a field for the component, create one
			fields.push({
				name: field.name,
				doc: null,
				meta: [],
				access: [APublic],
				kind: FVar(ComplexType.TPath(c), null),
				pos: Context.currentPos()
			});
			
			return macro {
				$i{field.name} = new $c(this);
				components.push($i{field.name});// TODO is the components array useful?
				${e};
			}
		}
		
		// TODO potential big issue here because superclass needs to be built before subclasses
		for (field in fields) {
			switch (field.kind) {
				// In the constructor...
				case FFun(func) if (field.name == "new"):
					// For each component field, add if it hasn't been added by a superclass
					for (componentField in componentFields) {
						if (classType.superClass != null) {
							// Do not re-add components that have already been added by a superclass
							if (hasAddedComponent(classType.superClass.t.get(), getTypePath(componentField.componentInterface))) {
								continue;
							}
						}
						// Finally, add the component instantation
						func.expr = prependComponentInstantiation(func.expr,
							{pack: componentField.componentInterface.pack, name: TypeTools.getClass(componentField.field.type).name} );
					}
				case _:
			}
		}
		
		// Handle :append and :prepend metadata
		//TODO
		// Once we've found the "component field", for each of its fields look for the :prepend and :append metadata then handle them
		// For the mofidied field, use findField to see if it already exists
		// If it does exist, check if it is in the current class in order to determine if override should be marked
		// Check the metadata for arguments(
		// For each component
		for (componentField in componentFields) {
			var componentClass:ClassType = TypeTools.getClass(componentField.field.type);
			// For each field in the component, look for the metadata
			for (field in componentClass.fields.get()) {
				var meta:MetadataEntry;
				if (field.meta.has(":prepend")) {
					meta = field.meta.extract(":prepend")[0];
				} else if (field.meta.has(":append")) {
					meta = field.meta.extract(":append")[0];
				} else {
					continue;
				}
				
				var componentFuncArgs:Array<{t:Type, opt:Bool, name:String}>;
				switch (Types.reduce(field.type)) {
					case TFun(args, _):
						componentFuncArgs = args;
					case _:
						throw("Prepend/append metadata may only be used on a function");
				}
				
				if (meta.params.length != 1) {
					throw("Prepend/append metadata must have exactly one parameter");
				}
				var targetMethodName:String = ExprTools.getValue(meta.params[0]);
				var targetFunc:Function = null;
					
				// Find the entity field that requires code injection
				for (field in fields) {
					switch (field.kind) {
						case FFun(func) if (field.name == targetMethodName):
							targetFunc = func;
						case _:
					}
				}
				
				// Error if there is no such field
				if (targetFunc == null) {
					throw(classType.name + " has no function " + targetMethodName + ", required by " + componentClass.name);
				}
				
				// Create the method call expressions
				var params:Array<Expr> = [];
				for (p in targetFunc.args) {
					params.push(macro $i{p.name});
				}
				
				var componentFuncName:String = field.name;
				var expr = {pos: Context.currentPos(), expr: ECall(macro $i{componentField.field.name}.$componentFuncName, params)};
				
				trace("append or prepend?" + meta.name);
				targetFunc.expr = switch(meta.name) {
					case ":prepend":
						macro {
							${expr};
							${targetFunc.expr};
						}
					case _:
						macro {
							${targetFunc.expr};
							${expr};
						}
				}
			}
		}
		
		return fields;
	}
	
	/** Function to build an interface which extends Entity */
	public static function buildComponentInterface(classType:ClassType, fields:Array<Field>):Array<Field> {
		
		// For each field, check it is not the field for the component, then change its name
		for (field in fields) {
			switch (field.kind) {
				case FProp(_, _, t, _):
					switch (t) {
						case TPath(p):
							// If this field is for the component, skip it
							// TODO make more flexible
							if (p.pack.toString() == classType.pack.toString() && p.name == classType.name + "Component") {
								continue;
							}
							// If this field has already been substituted, or is itself a substition, skip it
							// TODO make this customisable
							if (field.name.substr(0, 7) == "entity_") {
								continue;
							}
							if (interfaceHasField(classType, "entity_" + field.name)) {
								continue;
							}
							// Only substitute fields explicitly marked with @:relaxed metadata
							// TODO move relaxed condition to top
							if (field.meta != null) {
								for (m in field.meta) {
									if (m.name == ":relaxed") {
										field.name = "entity_" + field.name;
									}
								}
							}
						case _:
					}
				case _:
			}
		}
		
		return fields;
		
	}
	
	/**
	 * Return fields from component interfaces that require dummy fields (i.e. have :relaxed metadata in interface)
	 */
	public static function getDummyPropertyFields(componentInterfaces:Array<ClassType>):Array<ClassField> {
		var fields:Array<ClassField> = new Array<ClassField>();
		var fieldNameMap:Map<String, ClassField> = new Map<String, ClassField>();
		for (componentInterface in componentInterfaces) {
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
	
	/** Return an fields from interface that need to have dummy fields generated due to the :relaxed metadata */
	public static function getDummyPropertyFieldsFromInterface(componentInterface:ClassType):Array<ClassField> {
		var fields:Array<ClassField> = new Array<ClassField>();
		for (field in componentInterface.fields.get()) {
			// Only substitute fields explicitly marked with @:relaxed metadata
			if (field.meta != null && field.meta.has(":relaxed")) {
				fields.push(field);
			}
		}
		return fields;
	}
	
	/** Create map of component field type names to their corresponding ClassFields */
	public static function getComponentFields(componentInterfaces:Array<ClassType>) {
		var componentFields:Map<String, {field:ClassField, componentInterface:ClassType}>
			= new Map<String, {field:ClassField, componentInterface:ClassType}>();
		for (i in componentInterfaces) {
			var componentField:ClassField = getComponentField(i);
			if (componentField != null) {
				switch (componentField.type) {
					case TInst(t, _):
						componentFields.set(t.get().name, {field: getComponentField(i), componentInterface: i});
					case _:
				}
			} else {
				throw("Component interface " + i.name + " is missing field for the component");
			}
		}
		return componentFields;
	}
	
	/** Get the field of a component interface which contains the Component */
	public static function getComponentField(componentInterface:ClassType):ClassField {
		for (field in componentInterface.fields.get()) {
			switch (field.type) {
				case TInst(t, _):
					var fieldClass:ClassType = t.get();
					// Is the type of the field Component?
					if (typePathEq(getTypePath(fieldClass.superClass.t.get()), componentPath) &&
						classTypeEq(TypeTools.getClass(fieldClass.superClass.params[0]), componentInterface)) {
						return field;
					}
					
				case _:
			}
		}
		return null;
	}
	
	/** Recursively check if given ClassType has a field */
    public static function hasField(type:ClassType, fieldName:String):Bool {
        for (field in type.fields.get()) {
            // Check if this Field is the required field
            if (field.name == fieldName) {
                return true;
            }
        }
        // If not, check the super class if there is one
        if (type.superClass != null) {
            return hasField(type.superClass.t.get(), fieldName);
        }
        return false;
    }
	
	/** Recursively check if given interface has a field */
	public static function interfaceHasField(i:ClassType, fieldName:String):Bool {
		if (!i.isInterface) {
			throw("Not an interface: " + i.name);
		}
		for (field in i.fields.get()) {
			if (field.name == fieldName) {
				return true;
			}
		}
		for (i2 in i.interfaces) {
			if (interfaceHasField(i2.t.get(), fieldName)) {
				return true;
			}
		}
		return false;
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
	
	/**
	 * Check recursively if an interface extends another
	 */
	public static function interfaceExtendsInterface(type:ClassType, extendedTypePath:TypePath):Bool {
		if (!(type.isInterface)) {
			return false;
		}
		for (i in type.interfaces) {
			if (typePathEq( getTypePath(i.t.get()), extendedTypePath)) {
				return true;
			}
			if (interfaceExtendsInterface(i.t.get(), extendedTypePath)) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Checks if a ClassType has added a required component already
	 */
	public static function hasAddedComponent(type:ClassType, componentInterfacePath:TypePath):Bool {
		// Only classes can have components added, so return false if type is an interface
		if (type.isInterface) {
			return false;
		}
		
		// Check if each interface is or extends given interface
		for (i in type.interfaces) {
			if (typePathEq(getTypePath(i.t.get()), componentInterfacePath) ||
				interfaceExtendsInterface(i.t.get(), componentInterfacePath))
			{
				return true;
			}
		}
		
		// If not, check the superclass of this type if there is one
		if (type.superClass != null) {
			return hasAddedComponent(type.superClass.t.get(), componentInterfacePath);
		}
		
		return false;
	}
	
	/** Check if two ClassTypes are equivalent */
	public static function classTypeEq(c1:ClassType, c2:ClassType):Bool {
		return c1.pack.toString() == c2.pack.toString() && c1.name == c2.name;
	}
	
	/** Check if two TypePaths are equivalent */
	public static function typePathEq(path1:TypePath, path2:TypePath):Bool {
		return path1.pack.toString() == path2.pack.toString() && path1.name == path2.name;
	}
	
	public static function getTypePath(type:ClassType):TypePath {
		// TODO not sure what sub is or how to obtain it, but it's probably not necessary right now?
		// params, too :P
		return {pack: type.pack, name: type.name};
	}
}