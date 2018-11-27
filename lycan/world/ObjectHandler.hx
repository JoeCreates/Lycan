package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;

@:callable
abstract ObjectHandler(TiledObject->ObjectLayer->FlxBasic) from (TiledObject->ObjectLayer->FlxBasic) {
}

@:forward
abstract ObjectHandlers(Array<ObjectHandler>) from (Array<ObjectHandler>) to (Array<ObjectHandler>) {
	public inline function new() { this = new Array<ObjectHandler>(); }
	
	public function addForAll(handler:TiledObject->ObjectLayer->Void) {
		this.push(function(o:TiledObject, l:ObjectLayer):FlxBasic{
			handler(o, l);
			return null;
		});
	}
	
	public function addForType(type:String, handler:ObjectHandler):Void {
		var f = function(type:String, o:TiledObject, l:ObjectLayer):FlxBasic {
			return o.type == type ? handler(o, l) : null;
		}
		this.push(f.bind(type));
	}
	
	public function addForTypeAndMap(type:String, handler:ObjectHandler, map:Map<String, FlxBasic>):Void {
		var f = function(type:String, o:TiledObject, l:ObjectLayer):FlxBasic {
			if (o.type == type) {
				var basic = handler(o, l);
				map.set(type, basic); // NOTE may set null basics
				return basic;
			}
			return null;
		}
		this.push(f.bind(type));
	}
}