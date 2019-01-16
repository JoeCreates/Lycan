package lycan.util;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxBasic;

class CollisionUtil {
	public static function separateSides(Object1:FlxObject, Object2:FlxObject):Int {
        var separatedX:Bool = FlxObject.separateX(Object1, Object2);
        var separatedY:Bool = FlxObject.separateY(Object1, Object2);
        return
           ( separatedX ? (Object1.x < Object2.x ? FlxObject.RIGHT : FlxObject.LEFT) : 0) |
           ( separatedY ? (Object1.y < Object2.y ? FlxObject.DOWN : FlxObject.UP) : 0);
    }
    
    public static inline function collideSides(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic,
        ?NotifyCallback:Dynamic->Dynamic->Int->Void):Bool
    {
        var collisionSides:Int = 0;
        function notify(object1:FlxObject, object2:FlxObject):Void {
            if (NotifyCallback != null) NotifyCallback(object1, object2, collisionSides);
        }
        function separate(object1:FlxObject, object2:FlxObject) {
            collisionSides = separateSides(object1, object2);
            return collisionSides > 0;
        }
        return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, notify, separate);
    }
}