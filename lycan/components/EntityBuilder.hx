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
	
	public static var packagePath:Array<String> = ["lycan", "components"];
	public static var entityPath:TypePath = {pack: packagePath, name: "Entity"};
	public static var componentPath:TypePath = {pack: packagePath, name: "Component"};
	
	public static var componentInterfaces:Array<ClassType>;
	
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		componentInterfaces = getComponentInterfaces();
		
		// Get local type as ClassType
		var classType:ClassType = TypeTools.getClass(Context.getLocalType());
		
		trace(":: TRY " + classType.name);
		
		// Prevent a type from being built twice
		if (classType.meta.has("EntityBuilderBuilt")) {
			trace("::METAMETAMETAMETAMETAMETA ");
			return fields;
		}
		classType.meta.add("EntityBuilderBuilt", [], Context.currentPos());
		
		trace(":: Building " + classType.name);
		
		trace("A0");
		
		// Add components field
		if (!hasField("components", fields, classType)) {
			trace("A1.5" + classType.name);
			var c = macro class {
				// TODO make it possible to customise this name
				public var components:Array<lycan.components.Component<Dynamic>> = [];
			}
			trace("A1.75");
			fields.push(c.fields[0]);
		}
		
		trace("A1");
		
		// We do something different if the local type is an interface
		switch(Context.getLocalType()) {
			case TInst(rt, _):
				if (rt.get().isInterface) return buildComponentInterface();
			case _:
				return fields;
		}
		
		trace("A2");
		
		// Add getters and setters for entity_ properties
		// for each field that isn't the component field
		for (dummyField in getDummyPropertyFields()) {
			// Check if the entity_ property already exists
			var found:Bool = false;
			if (hasField(dummyField.name, fields, classType)) {
				found = true;
				continue;
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
				
				var dummySourceFieldName:String = dummyField.name.substring(7, dummyField.name.length);
				if (!hasField(dummySourceFieldName, fields, classType)) {
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
		}
		
		trace("A3");
		
		// Append component instantiation to constructor
		var componentFields:Map<String, {field:ClassField, componentInterface:ClassType}> = getComponentFields();
		var prependComponentInstantiation:Expr->TypePath->Expr = function(e:Expr, c:TypePath) {
			var field = componentFields.get(c.name).field;
			var found:Bool = false;
			if (hasField(field.name, fields, classType)) {
				throw("Class " + classType.pack + "." + classType.name + " has field " +
					field.name + ", which must not be declared as it is required by " + c.name);
				found = true;
			}
			var ct = ComplexType.TPath(c);
			// If we do not have a field for the component, create one
			if (!found) {
				var name = field.name;
				var myClass = macro class {
					public var $name:$ct;
				}
				fields.push(myClass.fields[0]);
				trace("Added field " + name);
			}
			return macro {
				$i{field.name} = new $c(this);
				components.push($i{field.name});
				${e};
			}
		}
		
		var fs = "";
		for (field in fields) {fs += field.name + ", "; }
		trace(fs);
		for (field in fields) {
			switch (field.kind) {
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
				if (field.meta.has(":prepend")) {
					//TODO apparently
				} else if (field.meta.has(":append")) {
					//TODO
				}
			}
		}
		
		return fields;
	}
	
	/**
	 * Whether this class currently has a field of the given name
	 * Checks both build fields of this type and fields of all super classes
	 */
	public static function hasField(name:String, fields:Array<Field>, classType:ClassType):Bool {
		for (f in fields) {
			if (f.name == name) return true;
		}
		return classType.superClass != null && TypeTools.findField(classType.superClass.t.get(), name) != null;
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
	 * Return all fields from interfaces that might require dummy fields
	 */
	public static function getDummyPropertyFields():Array<ClassField> {
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
	public static function getComponentFields() {
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
				throw("Component interface " + i.name + " is missing a field for the component");
			}
		}
		return componentFields;
	}
	
	public static function getComponentField(componentInterface:ClassType):ClassField {
		for (field in componentInterface.fields.get()) {
			switch (field.type) {
				case TInst(t, _):
					var fieldClass:ClassType = t.get();
					if (typePathEq(getTypePath(fieldClass.superClass.t.get()), componentPath) &&
						classTypeEq(TypeTools.getClass(fieldClass.superClass.params[0]), componentInterface)) {
						return field;
					}
					
				case _:
			}
		}
		return null;
	}
	
	// TODO possibly don;t need this anymore (could use TypeTools.findField()?)
	public static function interfaceHasField(i:ClassType, fieldName:String):Bool {
		if (!i.isInterface) {
			return false;
		}
		for (field in i.fields.get()) {
			if (field.name == fieldName) {
				return true;
			}
		}
		for (i2 in i.interfaces) {
			if (TypeTools.findField(i2.t.get(), fieldName) != null) {
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
	
	public static function buildComponentInterface():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		var classType:ClassType;
		switch (Context.getLocalType()) {
			case TInst(r, _):
				classType = r.get();
			case _:
		}
		
		// For each field, check it is not the field for the component, then change its name
		for (field in fields) {
			switch (field.kind) {
				case FProp(_, _, t, _):
					switch (t) {
						case TPath(p):
							// If this field is for the component, skip it
							if (p.pack.toString() == classType.pack.toString() && p.name == classType.name + "Component") {
								continue;
							}
							// If this field has already been substituted, or is itself a substition, skip it
							if (field.name.substr(0, 7) == "entity_") {
								continue;
							}
							if (interfaceHasField(classType, "entity_" + field.name)) {
								continue;
							}
							// Only substitute fields explicitly marked with @:relaxed metadata
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
	
	public static function classTypeEq(c1:ClassType, c2:ClassType):Bool {
		return c1.pack.toString() == c2.pack.toString() && c1.name == c2.name;
	}
	
	public static function typePathEq(path1:TypePath, path2:TypePath):Bool {
		return path1.pack.toString() == path2.pack.toString() && path1.name == path2.name;
	}
	
	public static function getTypePath(type:ClassType):TypePath {
		// TODO not sure what sub is or how to obtain it, but it's probably not necessary right now?
		// params, too :P
		return {pack: type.pack, name: type.name};
	}
}