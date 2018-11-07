package lycan.util;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.ds.Vector;
import lycan.entities.LSprite;
import lycan.states.LycanState;

/**
 * A stack of FlxBasics which automatically makes the top item exclusively active
 * Useful for UI element focus, such as sub menus
**/
class ActiveStack {
	public var stack:Array<FlxBasic>;
	
	public function new() {
		stack = [];
	}
	
	public function set(basic:FlxBasic):Void {
		stack[stack.length - 1] = basic;
	}
	
	public function push(basic:FlxBasic):Void {
		if (stack.length > 0) {
			stack[stack.length - 1].active = false;
		}
		stack.push(basic);
		basic.active = true;
	}
	
	public function pop():FlxBasic {
		if (stack.length > 0) {
			var basic:FlxBasic = stack.pop();
			basic.active = false;
			if (stack.length > 0) {
				stack[stack.length - 1].active = true;
			}
			return basic;
		}
		return null;
	}
}