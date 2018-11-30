package lycan.world.layer;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.group.FlxGroup;
import lycan.world.WorldHandlers;
import lycan.world.World;
import lycan.world.layer.ILayer.LayerType;
import flixel.addons.editors.tiled.TiledObject;

class ObjectLayer implements ILayer {
	public var type(default, null):LayerType = LayerType.OBJECT;
	public var world(default, null):World;
	public var properties(default, null):Map<String, String>;
	public var group:FlxGroup = new FlxGroup();
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function getBasic():FlxBasic {
		return group;
	}
	
	public function load(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):Void {
		this.properties = tiledLayer.properties.keys;
		
		loadObjects(tiledLayer, handlers);
	}

	public function add(object:FlxBasic):FlxBasic {
		return group.add(object);
	}
	
	private function loadObjects(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):Void {
		var objMap = new Map<TiledObject, FlxBasic>();
		for (o in tiledLayer.objects) {
			handlers.dispatch(o, this, objMap);
		}
	}
}