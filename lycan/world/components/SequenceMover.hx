package lycan.world.components;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lycan.components.Component;
import lycan.components.Entity;

enum SequenceMoverType {
	LOOPING;
	PINGPONG;
}

// TODO generalise to multiple states
interface SequenceMover extends Entity {
	public var sequenceMover:SequenceMoverComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
}

class SequenceMoverComponent extends Component<SequenceMover> implements IFlxDestroyable {
	
	public var moving(default, set):Bool;
	
	public var startCallback:SequenceMoverComponent->Void;
	public var stopCallback:SequenceMoverComponent->Void;
	
	public var nodes:Array<FlxPoint>;
	public var targetIndex:Int;
	public var target(get, never):FlxPoint;
	public var directionUnit:FlxPoint;
	public var reverse:Bool;
	/** The point moving the entity which is attached to the path */
	public var anchor:FlxPoint;
	
	public var type:SequenceMoverType;
	public var hasReachedTarget:Bool;
	
	public function new(entity:SequenceMover) {
		super(entity);
		directionUnit = FlxPoint.get();
		reverse = false;
		type = SequenceMoverType.LOOPING;
		nodes = [];
	}
	
	@:append("update")
	public function update(dt:Float):Void {
		if (hasReachedTarget) {
			//entity.x = target
		}
	}
	
	/** Prepare for next path iteration when current iteration has completed */
	private function prepareIteration():Void {
		switch (type) {
			case LOOPING:
				targetIndex = reverse ? nodes.length - 1 : 0;
			case PINGPONG:
				reverse = !reverse;
			case _:
		}
	}
	
	private function get_hasReachedTarget():Bool {
		return false;//todo
	}
	
	@:append("destroy")
	public function destroy():Void {
		for (point in nodes) {
			point.put();
		}
	}
	
	public function toggle():Void {
		moving = !moving;
	}
	
	private function set_moving(moving:Bool):Bool {
		if (this.moving == moving) return moving;
		
		this.moving = moving;
		if (moving) {
			if (startCallback != null) startCallback(this);
		} else {
			if (stopCallback != null) stopCallback(this);
		}
		
		return moving;
	}
	
	private function get_target():FlxPoint {
		return nodes[targetIndex];
	}
}