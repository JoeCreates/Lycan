package world;

import config.Config;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxBasic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import states.PlayState;
import world.WorldLayer.WorldLayerType;
import flixel.util.FlxColor;
/**
 * A 2D world using Tiled maps, Nape Physics, and hxDynaLight lighting
 * 
 * Consists of TileLayers and FlxGroups of game objects.
 */
class World extends FlxGroup {
	
	private static inline var TILESET_PATH = "assets/images/";
	
	
	/** TiledMap data */
	public var tiledMap:TiledMap;
	
	public var namedObjects:Map<String, FlxBasic>;
	public var namedLayers:Map<String, WorldLayer>;
	public var collidableLayers:Array<TileLayer>;
	public var updateSpeed:Float;
	
	public var scale:FlxPoint;
	
	public function new(?scale:FlxPoint) {
		super();
		this.scale = (scale == null) ? new FlxPoint(1, 1) : scale;
		
		namedObjects = new Map<String, FlxBasic>();
		namedLayers = new Map<String, WorldLayer>();
		collidableLayers = new Array<TileLayer>();
		
		updateSpeed = 1;
	}
	
	public function load(tiledLevel:Dynamic, worldLoader:WorldLoader):Void {
		tiledMap = new TiledMap(tiledLevel);
		
		// Camera scroll bounds
		FlxG.camera.setScrollBoundsRect(0, 0, tiledMap.fullWidth * scale.x, tiledMap.fullHeight * scale.x, true);
		FlxG.camera.maxScrollY += FlxG.height / 2;
		
		// Load tileset graphics
		var tilesetBitmaps:Array<BitmapData> = new Array<BitmapData>();
		for (tileset in tiledMap.tilesetArray) {
			var imagePath = new Path(tileset.imageSource);
			var processedPath = TILESET_PATH + imagePath.file + "." + imagePath.ext;
			tilesetBitmaps.push(FlxAssets.getBitmapData(processedPath));
		}
		
		// Combine tilesets into single tileset
		var tileSize:FlxPoint = FlxPoint.get(tiledMap.tileWidth, tiledMap.tileHeight);
		var combinedTileset:FlxTileFrames = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize);
		tileSize.put();
		
		// Load layers
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT:					
					// Object Layer
					var group:ObjectLayer = new ObjectLayer(this);
					worldLoader.load(group, cast tiledLayer);
					namedLayers.set(tiledLayer.name, group);
					for (m in group) {
						if (Std.is(m, FlxObject)) {
							var o:FlxObject = cast m;
							o.x *= scale.x;
							o.y *= scale.y;
						}
					}
					add(group);
				case TiledLayerType.TILE:
					var tileLayer:TileLayer = loadTileLayer(cast tiledLayer, combinedTileset);
					namedLayers.set(tiledLayer.name, tileLayer);
					add(tileLayer);
			}
		}
	}
	
	public function loadTileLayer(tiledLayer:TiledTileLayer, combinedTileset:FlxTilemapGraphicAsset):TileLayer {
		var tilemap:TileLayer = new TileLayer(this);
		var mapWidth:Int = Std.int(tiledMap.fullWidth * scale.x);
		var mapHeight:Int = Std.int(tiledMap.fullHeight * scale.y);
		
		tilemap.loadMapFromArray(tiledLayer.tileArray, tiledMap.width,  tiledMap.height, combinedTileset,
								 Std.int(tiledMap.tileWidth),  Std.int(tiledMap.tileHeight), FlxTilemapAutoTiling.OFF, 1, 1, 1);
		tilemap.scale.copyFrom(scale);
		
		// Collidable layers
		if (tiledLayer.properties.contains("collision")) {
			tilemap.solid = true;
			collidableLayers.push(tilemap);
			if (tiledLayer.properties.get("collision") == "oneway") {
				tilemap.allowCollisions = FlxObject.UP;
			}
		}
		if (tiledLayer.properties.contains("hide")) {
			tilemap.visible = false;
		}
		
		return tilemap;
	}
	
	public function getObject(name:String):FlxBasic {
		return namedObjects.get(name);
	}
	
	public function getLayer(name:String):WorldLayer {
		return namedLayers.get(name);
	}
	
	public function collideWithLevel<T, U>(obj:FlxBasic, ?notifyCallback:T->U->Void,
		?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableLayers != null) {
			for (map in collidableLayers) {
				// IMPORTANT: Always collide the map with objects, not the other way around. 
				if(FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
					return true;
				}
			}
		}
		return false;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
}

