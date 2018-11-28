package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;

typedef ObjectHandler = TiledObject->ObjectLayer->FlxBasic;
typedef ObjectHandlers = Array<ObjectHandler>;