package lycan.world.layer;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.group.FlxGroup;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledPropertySet;
import lycan.world.WorldLayer;

class ObjectLayer extends FlxGroup implements WorldLayer { 
	public var properties(default, null):TiledPropertySet;
	
	public function new(world:TiledWorld, tiledLayer:TiledObjectLayer) {
		super();
		worldLayer.init(tiledLayer, world);
	}
	
	public function loadObjects(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):Void {		
		var objMap = new Map<TiledObject, FlxBasic>();
		
		for (o in tiledLayer.objects) {
			handlers.dispatch(o, this, objMap);
		}
	}
}