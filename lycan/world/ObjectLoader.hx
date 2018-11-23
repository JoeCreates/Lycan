package lycan.world;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.group.FlxGroup;
import lycan.world.World;
import lycan.world.layer.ILayer.LayerType;
import lycan.world.layer.TileLayer;
import flixel.util.FlxSignal;
import lycan.world.layer.ObjectLayer;


typedef ObjectHandler = TiledObject->ObjectLayer->Void;

class ObjectLoader {
	
	public static function addByType(signal:FlxTypedSignal<ObjectHandler>, type:String, handler:ObjectHandler):Void {
		signal.add((o, l) -> o.type == type ? handler(o, l) : null);
	}
}