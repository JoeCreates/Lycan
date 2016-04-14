package lycan.world.layer;

import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeTilemap;
import lycan.world.layer.TileLayer;
import nape.geom.Mat23;
import nape.phys.Body;
import nape.phys.BodyType;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

class NapeTileLayer extends TypedTileLayer<FlxNapeTilemap> implements ILayer {
	
	public var body:Body;
	
	public function new(world:World) {
		super(world);
	}
	
	override public function load(tiledLayer:TiledTileLayer, tilemap:FlxNapeTilemap):NapeTileLayer {
		super.load(tiledLayer, tilemap);
		
		tilemap.body.type = BodyType.KINEMATIC;
		tilemap.body.transformShapes(Mat23.scale(world.scale.x, world.scale.y));
	
		return this;
	}
	
	override public function processProperties(tiledLayer:TiledLayer):NapeTileLayer {
		// Do default property handling for flixel physics
		super.processProperties(tiledLayer);
		
		if (tiledLayer.properties.contains("collides")) {
			tilemap.setupCollideIndex(1);
		}
		return this;
	}
	
	private function get_body():Body {
		return tilemap.body;
	}
	private function set_body(body:Body):Body {
		return tilemap.body = body;
	}
	
}