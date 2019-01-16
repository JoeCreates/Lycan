package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import flixel.util.FlxSignal;
import lycan.world.TiledWorld;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;

typedef ObjectHandler = TiledObject->ObjectLayer->Map<TiledObject, FlxBasic>->Void;
typedef ObjectHandlers = FlxTypedSignal<ObjectHandler>;

typedef LayerLoadedHandler = TiledLayer->WorldLayer->Void;
typedef LayerLoadedHandlers = FlxTypedSignal<LayerLoadedHandler>;