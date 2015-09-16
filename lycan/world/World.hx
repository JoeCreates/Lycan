package lycan.world;

import flixel.addons.editors.tiled.TiledMap.FlxTiledAsset;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import lycan.world.Layer;
import lycan.world.Layer.TileLayer;
import msignal.Signal.Signal1;

// A 2D world built from Tiled maps
// Consists of TileLayers and FlxGroups of game objects
@:allow(lycan.world.WorldLoader)
class World extends FlxGroup {
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale(default, null):FlxPoint;
	public var name:String;
	public var updateSpeed:Float;
	public var signal_loadingProgressed(default, null):Signal1<Float>;
	
	private var namedObjects(default, null):Map<String, FlxBasic>;
	private var namedLayers(default, null):Map<String, Layer>;
	private var namedTilesets(default, null):Map<String, TiledTileSet>;
	private var collidableLayers(default, null):Array<TileLayer>;
	
	public function new(?scale:FlxPoint) {
		super();
		
		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
		name = "Unnamed World";
		updateSpeed = 1;
		
		namedObjects = new Map<String, FlxBasic>();
		namedLayers = new Map<String, Layer>();
		collidableLayers = new Array<TileLayer>();
		
		signal_loadingProgressed = new Signal1<Float>();
	}
	
	public function collideWithLevel<T, U>(obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		if (collidableLayers == null) {
			return false;
		}
		
		for (map in collidableLayers) {
			// NOTE Always collide the map with objects, not the other way around
			if(FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}
		
		return false;
	}
	
	public function load(tiledLevel:FlxTiledAsset, loadingRules:WorldLoader):Void {
		WorldLoader.load(this, tiledLevel, loadingRules);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
	
	public inline function getNamedObject(name:String):FlxBasic {
		return namedObjects.get(name);
	}
	
	public inline function getNamedLayer(name:String):Layer {
		return namedLayers.get(name);
	}
	
	public inline function getNamedTileSet(name:String):TiledTileSet {
		return namedTilesets.get(name);
	}
}