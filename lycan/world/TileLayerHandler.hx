package lycan.world;

import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import lycan.world.layer.TileLayer;

@:callable
abstract TileLayerHandler(TiledTileLayer->TileLayer->FlxTilemap) from (TiledTileLayer->TileLayer->FlxTilemap) {
}