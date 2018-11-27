package lycan.world;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;

@:callable
abstract ObjectHandler(TiledObject->ObjectLayer->FlxBasic) from (TiledObject->ObjectLayer->FlxBasic) {
	
}

@:forward(iterator)
abstract ObjectHandlers(Array<ObjectHandler>) from (Array<ObjectHandler>) {
	public inline function new() { this = new Array<ObjectHandler>(); }
	
	@:op(A += B)
	public inline function addAssign(handler:ObjectHandler):ObjectHandlers {
		this.push(handler);
		return this;
	}
	
	@:op(A += B)
	public inline function addAssignNoReturnObject(handler:TiledObject->ObjectLayer->Void):ObjectHandlers {
		addAssign((o, l)->{
			handler(o, l);
			return null;
		});
		return this;
	}
	
	@:op(A += B)
	public inline function addAssignWithNullaryPrecondition(v: { precondition:Void->Bool, handler:ObjectHandler }):ObjectHandlers {
		if (v.precondition()) {
			addAssign(v.handler);
		}
		return this;
	}
	
	@:op(A += B)
	public inline function addAssignForTypeAndNameMap(v: { type:String, map:Map<String, FlxBasic>, handler:ObjectHandler }):ObjectHandlers {
		var f = (type:String, map:Map<String, FlxBasic>, o:TiledObject, l:ObjectLayer)->{
			if (o.type == type) {
				var basic = v.handler(o, l);
				map.set(type, basic); // NOTE may set null basics
				return basic;
			}
			return null;
		}
		return addAssign(f.bind(v.type, v.map));
	}
}