package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import flixel.util.FlxSignal;
import lycan.world.World;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;

typedef ObjectHandler = TiledObject->ObjectLayer->Map<TiledObject, FlxBasic>->Void;
typedef ObjectHandlers = FlxTypedSignal<ObjectHandler>;

typedef ObjectLayerHandler = TiledObjectLayer->ObjectLayer->Void;
typedef ObjectLayerHandlers = FlxTypedSignal<ObjectLayerHandler>;

typedef TileLayerHandler = TiledTileLayer->TileLayer->FlxTilemap;//TODO screded... not symmetrical
typedef TileLayerHandlers = FlxTypedSignal<TileLayerHandler>;//TODO this is all screwed

typedef WorldHandler = TiledMap->World->Void;
typedef WorldHandlers = FlxTypedSignal<WorldHandler>;

// TODO may not be necessary anymore
typedef TileSetHandler = TiledMap->Void;