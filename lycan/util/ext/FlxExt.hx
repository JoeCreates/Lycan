package lycan.util.ext;

import flixel.FlxSprite;
import flixel.FlxObject;

class FlxObjExt {
	public static function anchorTo(obj:FlxObject, obj2:FlxObject, ?targetX:Float = 0.5, ?targetY:Float = 0.5, anchorX:Float = 0.5, anchorY:Float = 0.5) {
		if (targetX != null) obj.x = obj2.x + obj2.width * targetX - obj.width * anchorX;
		if (targetY != null) obj.y = obj2.y + obj2.height * targetY - obj.height * anchorY;
	}
	
	public static function centerX(o:FlxObject, ?val:Float):Float {
		if (val != null) o.x = val - o.width / 2;
		return o.x + o.width / 2;
	}
	
	public static function centerY(o:FlxObject, ?val:Float):Float {
		if (val != null) o.y = val - o.height / 2;
		return o.y + o.height / 2;
	}
	
	public static function scaleTo(spr:FlxSprite, scale:Float, updateHitbox:Bool = true) {
		spr.scale.set(scale, scale);
		if (updateHitbox) spr.updateHitbox();
	}
}