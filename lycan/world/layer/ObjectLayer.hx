package lycan.world.layer;

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

class ObjectLayer extends FlxGroup implements ILayer {
	public var layerType(default, null):LayerType = LayerType.OBJECT;
	public var world(default, null):World;
	public var properties(default, null):TiledPropertySet;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
	
	public function getBasic():FlxBasic {
		return this;
	}
	
	public function load(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<TiledObject->Void>):Void {
		this.properties = tiledLayer.properties;
		
		loadObjects(tiledLayer, handlers);
		processProperties(tiledLayer);
	}

	override public function add(object:FlxBasic):FlxBasic {
		return super.add(object);
	}
	
	private function loadObjects(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<TiledObject->Void>):Void {
		for (o in tiledLayer.objects) {
			handlers.dispatch(o);
		}
	}
	
	private function processProperties(tiledLayer:TiledObjectLayer):Void {

	}
}