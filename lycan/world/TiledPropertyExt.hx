package lycan.world;

import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.util.helpers.FlxRange;
import flixel.util.FlxColor;

using lycan.util.ext.StringExt;

class TiledPropertyExt {
	public static function getString(props:TiledPropertySet, key:String, ?defaultValue:String):Null<String> {
		var val = props.get(key);
		return val != null ? val : defaultValue;
	}
	
	public static function getBool(props:TiledPropertySet, key:String, defaultValue:Bool = false):Bool {
		var val = props.get(key);
		return val != null ? val.toLowerCase() == "true" : defaultValue;
	}
	
	public static function getInt(props:TiledPropertySet, key:String, ?defaultValue:Int):Null<Int> {
		var val = props.get(key);
		return val != null ? Std.parseInt(val) : defaultValue;
	}
	
	public static function getFloat(props:TiledPropertySet, key:String, ?defaultValue:Float):Null<Float> {
		var val = props.get(key);
		return val != null ? Std.parseFloat(val) : defaultValue;
	}
	
	public static function getRange(props:TiledPropertySet, key:String):{min:Float, max:Float} {
		return props.get(key).parseRange();
	}
	
	public static function getColor(props:TiledPropertySet, key:String):FlxColor {
		var val = props.get(key);
		var a:Array<Int> = haxe.Json.parse(val);
		return FlxColor.fromRGB(a[0], a[1], a[2]);
	}
}