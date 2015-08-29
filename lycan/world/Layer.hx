package lycan.world;

import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

enum LayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface Layer {
	public var layerType(default, null):LayerType;
	public var world(default, null):World;
}

class ObjectLayer extends FlxGroup implements Layer {
	public var layerType(default, null):LayerType = LayerType.OBJECT;
	public var world(default, null):World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}

class TileLayer extends FlxTilemap implements Layer {
	public var layerType(default, null):LayerType = LayerType.TILE;
	public var world(default, null):World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}