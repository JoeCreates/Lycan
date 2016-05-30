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
    
    public static var entityPath:TypePath = {pack: ["lycan", "components"], name: "Entity"};
    
    public static function build():Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();
        
        //TODO possibly not needed
        //for (field in fields) {
            //if (field.name == "components") {
                //return fields;
            //}
        //}
        
        // Get local type as ClassType
        var classType:ClassType;
        switch (Context.getLocalType()) {
            case TInst(r, _):
                classType = r.get();
            case _:
        }
        
        // Prevent a type from being built twice
        if (classType.meta.has("EntityBuilderBuilt")) {
            return fields;
        }
        classType.meta.add("EntityBuilderBuilt", [], Context.currentPos());
        
        // Add components field
        if (!hasFieldIncludingBuildFields("components")) {
            fields.push({
                name: "components",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FVar(macro :Array<lycan.components.Component<Dynamic>>,
                    macro new Array<lycan.components.Component<Dynamic>>() ),
                pos: Context.currentPos()
            });
        }
        
        // We do something different if the local type is an interface
        switch(Context.getLocalType()) {
            case TInst(rt, _):
                if (rt.get().isInterface) return buildComponentInterface();
            case _:
                return fields;
        }
        
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
                appendLateUpdate(overrideFunction("lateUpdate", {
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
            if (hasFieldIncludingBuildFields(dummyField.name)) {
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
                if (!hasFieldIncludingBuildFields(dummySourceFieldName)) {
                    throw("Field " + dummySourceFieldName + " required by component interface is missing in " + classType.name);
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
        
        // Append component instantiation to constructor
        var componentFields:Map<String, ClassField> = getComponentFields();
        var appendComponentInstantiation:Expr->TypePath->Expr = function(e:Expr, c:TypePath) {
            var found:Bool = false;
            if (hasFieldIncludingBuildFields(componentFields.get(c.name).name)) {
                throw("Class " + classType.name + " has field " +
                    componentFields.get(c.name).name + ", which must not be declared as it is required by " + c.name);
                found = true;
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
                        if (classType.superClass != null) {
                            // Do not re-add components that have already been added by a superclass
                            if (hasAddedComponent(classType.superClass.t.get(), getTypePath(componentInterface))) {
                                continue;
                            }
                        }
                        // Finally, add the component instantation
                        func.expr = appendComponentInstantiation(func.expr,
                            {pack: componentInterface.pack, name: componentInterface.name + "Component" } );
                    }
                case _:
            }
        }
        
        return fields;
    }
    
    /**
     * Checks if a ClassType should have added a component already
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
    
    /** Recursively check if build field or inherited field */
    public static function hasFieldIncludingBuildFields(fieldName:String):Bool {
        var classType:ClassType;
        switch (Context.getLocalType()) {
            case TInst(r, _):
                classType = r.get();
            case _:
        }
        for (field in Context.getBuildFields()) {
            // Check if this Field is the required field
            if (field.name == fieldName) {
                return true;
            }
        }
        // If not, check the super class if there is one
        if (classType.superClass != null) {
            return hasField(classType.superClass.t.get(), fieldName);
        }
        return false;
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
    
    public static function getComponentInterfaces():Array<ClassType> {
        var out:Array<ClassType> = new Array <ClassType>();
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
                            if (hasFieldIncludingBuildFields("entity_" + field.name)) {
                                continue;
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
    
    public static function typePathEq(path1:TypePath, path2:TypePath):Bool {
        return path1.pack.toString() == path2.pack.toString() && path1.name == path2.name;
    }
    
    public static function getTypePath(type:ClassType):TypePath {
        // TODO not sure what sub is or how to obtain it, but it's probably not necessary right now?
        // params, too :P
        return {pack: type.pack, name: type.name};
    }
}