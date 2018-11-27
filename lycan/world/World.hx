package lycan.world;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.ds.Map;
import lycan.world.ObjectHandler;
import lycan.world.TileLayerHandler;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import lycan.world.ObjectHandler.ObjectHandlers;

// A 2D world built from Tiled maps
class World extends FlxGroup {
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale(default, null):FlxPoint;
	public var properties(default, null):Map<String, String>;
	public var updateSpeed:Float;
	
	public var onLoadedTileSets(default, null) = new FlxTypedSignal<TiledMap->Void>();
	public var onLoadedObjectLayer(default, null) = new FlxTypedSignal<TiledObjectLayer->ObjectLayer->Void>();
	public var onLoadedTileLayer(default, null) = new FlxTypedSignal<TiledTileLayer->TileLayer->Void>();
	
	public var onLoadingProgressed(default, null) = new FlxTypedSignal<Float->Void>();
	public var onLoadingComplete(default, null) = new FlxTypedSignal<Void->Void>();
	
	public function new(?scale:FlxPoint) {
		super();

		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
		updateSpeed = 1;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
	
	public static function collideWithLevel<T, U>(tilemaps:Array<FlxTilemap>, obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		if (tilemaps == null) {
			return false;
		}
		
		for (map in tilemaps) {
			// NOTE Always collide the map with objects, not the other way around
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}

		return false;
	}
	
	public function load(tiledLevel:FlxTiledMapAsset, objectLoadingHandlers:ObjectHandlers, tileLayerLoadingHandler:TileLayerHandler):Void {
		var tiledMap = new TiledMap(tiledLevel);
		properties = tiledMap.properties.keys;
		width = tiledMap.fullWidth;
		height = tiledMap.fullHeight;
		
		// Load tilesets
		loadTileSets(tiledMap);
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT: {
					loadObjectLayer(cast tiledLayer, objectLoadingHandlers);
				}
				case TiledLayerType.TILE: {
					loadTileLayer(cast tiledLayer, tileLayerLoadingHandler);
				}
				default:
					throw("Encountered unsupported Tiled layer type");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			onLoadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		onLoadingComplete.dispatch();
	}
	
	private function loadTileSets(tiledMap:TiledMap):Void {
		onLoadedTileSets.dispatch(tiledMap);
	}
	
	private function loadObjectLayer(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):Void {
		var layer = new ObjectLayer(this);
		layer.load(tiledLayer, handlers);
		add(layer.group);
		onLoadedObjectLayer.dispatch(tiledLayer, layer);
	}
	
	private function loadTileLayer(tiledLayer:TiledTileLayer, handler:TileLayerHandler):Void {
		var layer = new TileLayer(this);
		layer.load(tiledLayer, handler);
		add(layer.tilemap);
		onLoadedTileLayer.dispatch(tiledLayer, layer);
	}
}