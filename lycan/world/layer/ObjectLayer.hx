package lycan.world.layer;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.ObjectLoader.ObjectHandler;
import lycan.world.World;
import lycan.world.layer.ILayer.LayerType;

class ObjectLayer implements ILayer {
	public var type(default, null):LayerType = LayerType.OBJECT;
	public var world(default, null):World;
	public var properties(default, null):TiledPropertySet;
	public var group:FlxGroup = new FlxGroup();
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function getBasic():FlxBasic {
		return group;
	}
	
	public function load(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<ObjectHandler>):Void {
		this.properties = tiledLayer.properties;
		
		loadObjects(tiledLayer, handlers);
		processProperties(tiledLayer);
	}

	public function add(object:FlxBasic):FlxBasic {
		return group.add(object);
	}
	
	private function loadObjects(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<ObjectHandler>):Void {
		for (o in tiledLayer.objects) {
			handlers.dispatch(o, this);
		}
	}
	
	private function processProperties(tiledLayer:TiledObjectLayer):Void {

	}
}