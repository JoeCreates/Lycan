package lycan.world.layer;

import flixel.addons.editors.tiled.TiledPropertySet;

enum LayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface ILayer {
	public var type(default, null):LayerType;
	public var properties(default, null):TiledPropertySet;
	public var world(default, null):World;
}