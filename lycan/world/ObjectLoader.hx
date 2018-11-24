package lycan.world;

import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.layer.ObjectLayer;

typedef ObjectHandler = TiledObject->ObjectLayer->Void;

class ObjectLoader {
	public static function addByType(signal:FlxTypedSignal<ObjectHandler>, type:String, handler:ObjectHandler):Void {
		signal.add((o, l) -> o.type == type ? handler(o, l) : null);
	}
}