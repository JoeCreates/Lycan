package lycan.world.layer;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

enum LayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface ILayer {
	public var layerType(default, null):LayerType;
	public var world(default, null):World;
	public var properties(default, null):TiledPropertySet;
	public function getBasic():FlxBasic;//TODO remove this and just make layers not extend stuff
}