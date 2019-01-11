package lycan.util.ext;

import flixel.FlxSprite;
import flixel.FlxObject;

class FlxObjExt {
	public static function anchorTo(obj:FlxObject, obj2:FlxObject, ?targetX:Float = 0.5, ?targetY:Float = 0.5, anchorX:Float = 0.5, anchorY:Float = 0.5) {
		if (targetX != null) obj.x = obj2.x + obj2.width * targetX - obj.width * anchorX;
		if (targetY != null) obj.y = obj2.y + obj2.height * targetY - obj.height * anchorY;
	}
}