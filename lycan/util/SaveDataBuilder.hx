package lycan.util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

class SaveDataBuilder {

	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		
		// Create functions for loading and saving basic data
		var loadExpr:Expr = macro {};
		var saveExpr:Expr = macro {};
		var resetExpr:Expr = macro {};
		for (field in fields) {
			var t:FieldType;
			switch (field.kind) {
				case FVar(_, e):
					if (e == null) e = macro null;
					if (field.access.indexOf(AStatic) >= 0) {
						for (meta in field.meta) {
							// For each static field with "save" metadata
							if (meta.name == ":save") {
								loadExpr = macro {
									${loadExpr};
									$i{field.name} = ($p{["file", "data", field.name]} == null) ? ${e} : $p{["file", "data", field.name]};
								}
								saveExpr = macro {
									${saveExpr};
									$p{["file", "data", field.name]} = $i{field.name};
								}
								resetExpr = macro {
									${resetExpr};
									$i{field.name} = ${e};
								}
							}
							if (meta.name == ":saveMap") {
								var list:Expr = meta.params[0];
								var key:Expr = meta.params[1];
								var value:Expr = meta.params[2];
								var defaultValue:Expr = meta.params[3];
								loadExpr = macro {
									${loadExpr};
									if ($p{["file", "data", field.name]} != null) {
										var us:haxe.Unserializer = new haxe.Unserializer($p{["file", "data", field.name]});
										$i{field.name} = cast us.unserialize();
										for (e in ${list}) {
											${value} = ($i{field.name}.get(${key}) == null) ? ${defaultValue} : $i{field.name}.get(${key});
										}
									} else {
										for (e in ${list}) {
											${value} = ${defaultValue};
										}
									}
								}
								saveExpr = macro {
									${saveExpr};
									for (e in ${list}) {
										$i{field.name}.set(${key}, ${value});
									}
									var s:haxe.Serializer = new haxe.Serializer();
									s.serialize($i{field.name});
									$p{["file", "data", field.name]} = s.toString();
								}
								resetExpr = macro {
									${resetExpr};
									for (e in ${list}) {
										${value} = ${defaultValue};
									}
								}
							}
						}
					}
				case _:
			}
		}
		fields.push({
			name: "loadData",
			doc: null,
			meta: [],
			access: [APublic, AStatic],
			kind: FFun({args: [
					{name: "file", type: TPath({pack: ["flixel", "util"], name: "FlxSave"})}
				], ret: null, expr: loadExpr}),
			pos: Context.currentPos()
		});
		fields.push({
			name: "saveData",
			doc: null,
			meta: [],
			access: [APublic, AStatic],
			kind: FFun({args: [
					{name: "file", type: TPath({pack: ["flixel", "util"], name: "FlxSave"})}
				], ret: null, expr: saveExpr}),
			pos: Context.currentPos()
		});
		fields.push({
			name: "resetData",
			doc: null,
			meta: [],
			access: [APublic, AStatic],
			kind: FFun({args: [], ret: null, expr: resetExpr}),
			pos: Context.currentPos()
		});
		
		return fields;
	}
	
}