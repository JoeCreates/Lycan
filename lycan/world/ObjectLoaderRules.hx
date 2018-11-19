package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;
import lycan.util.structure.container.ArraySet;
import flixel.addons.editors.tiled.TiledObjectLayer;

typedef ObjectLoaderPrecondition = TiledObject->Bool;
typedef ObjectLoader = TiledObject->ObjectLayer->FlxBasic;

// Represents a collection of functions for loading objects from a Tiled map and into a World
class ObjectLoaderRules {
    public var handlers:ArraySet<{ precondition: ObjectLoaderPrecondition, loader: ObjectLoader }> = [];

    public function new() {
    }

    public function addHandler(precondition:TiledObject->Bool, loader:ObjectLoader):Void {
        var added = handlers.add({ precondition: precondition, loader: loader });
        Sure.sure(added);
    }

    public function getHandler(object:TiledObject):ObjectLoader {
        for (pair in handlers) {
            if (pair.precondition(object)) {
                return pair.loader;
            }
        }
        return null;
    }
}