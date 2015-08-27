package lycan.world;

import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

enum WorldLayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface Layer {
	public var layerType(default, null):WorldLayerType;
	public var world(default, null):World;
}

class ObjectLayer extends FlxGroup implements Layer {
	public var layerType(default, null):WorldLayerType = WorldLayerType.OBJECT;
	public var world(default, null):World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}

class TileLayer extends FlxTilemap implements Layer {
	public var layerType(default, null):WorldLayerType = WorldLayerType.TILE;
	public var world(default, null):World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}