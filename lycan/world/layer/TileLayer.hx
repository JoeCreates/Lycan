package lycan.world.layer;

import flixel.util.FlxSort;
import flixel.addons.editors.tiled.TiledPropertySet;
import lycan.world.WorldHandlers;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.WorldHandlers;
import lycan.world.components.PhysicsEntity;
import nape.callbacks.CbType;
import nape.callbacks.CbTypeList;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.tile.FlxBaseTilemap;
import flixel.system.FlxAssets;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import lycan.phys.Phys;
import lycan.world.WorldLayer;
import flixel.addons.editors.tiled.TiledLayer;

@:tink
class TileLayer extends FlxTilemap implements WorldLayer {
	public var tileWidth(get, never):Float;
	public var tileHeight(get, never):Float;
	@:calc public var properties:TiledPropertySet = worldLayer.properties;
	
	public function new(world:TiledWorld, tiledLayer:TiledTileLayer) {
		super();
		worldLayer.init(tiledLayer, world);
		
		// TODO do once for map
		// Transform tile array based on non-loading tilesets
		var translations:Array<{start:Int, offset:Int}> = [];
		var startIds = tiledLayer.map.tilesetArray.map(t->t.firstGID);
		startIds.sort((a, b) -> a - b);
		
		for (tileset in tiledLayer.map.tilesetArray) {
			if (tileset.properties.contains("nontile")) {
				var tileOffset:Int = 0;
				var startIndex = startIds.indexOf(tileset.firstGID);
				if (startIndex < startIds.length - 1) {
					tileOffset = startIds[startIndex + 1] - tileset.firstGID;
				}
				translations.push({start: tileset.firstGID, offset: tileOffset});
			}
		}
		var tileArray = tiledLayer.tileArray.map(function (i):Int {
			var out = i;
			for (t in translations) {
				if (i >= t.start) out -= t.offset;
			}
			return out;
		});
		
		// Load tilemap
		loadMapFromArray(tileArray, tiledLayer.map.width, tiledLayer.map.height, world.combinedTileset,
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), null, 1, 1, 1);
		
		// Setup collisions
		if (worldLayer.properties.contains("collision")) {
			setupCollisions(tiledLayer);
		}
		useScaleHack = false;
		scale.copyFrom(world.scale);
	}
	
	private function setupCollisions(tiledLayer:TiledTileLayer):Void {
		solid = true;
		worldLayer.world.collisionLayers.push(this);
	}
	
	private function get_tileWidth():Float {
		return _tileWidth * scale.x;
	}
	
	private function get_tileHeight():Float {
		return _tileHeight * scale.y;
	}
}