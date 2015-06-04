package world;

import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTilemapBuffer;
import nape.phys.Body;
import world.WorldLayer.WorldLayerType;

class TileLayer extends FlxTilemap implements WorldLayer {
	
	public var layerType:WorldLayerType = WorldLayerType.TILE;
	
	public var world:World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}