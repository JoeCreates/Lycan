package lycan.world.entities;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lycan.components.Component;

enum MovingPlatformType {
	LOOPING,
	PINGPONG
}

// TODO generalise to multiple states
interface MovingPlatform {
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
}

class MovingPlatformComponent extends Component implements IFlxDestroyable {
	
	public var moving(default, set):Bool;
	
	public var startCallback:MovingPlatformComponent->Void;
	public var stopCallback:MovingPlatformComponent->Void;
	
	public var nodes:Array<FlxPoint>;
	public var targetIndex:Int;
	public var target(get, never):FlxPoint;
	public var directionUnit:FlxPoint;
	public var reverse:Bool;
	/** The point on the entity which is attached to the path */
	public var attachPoint:FlxPoint;
	public var attachmentX(get, set);
	public var attachmentY(get, set);
	
	public var type:MovingPlatformType;
	public var hasReachedTarget:Bool;
	
	public function new(entity:FlxObject) {
		super(entity);
		directionUnit = FlxPoint.get();
		reverse = false;
		type = MovingPlatformType.LOOPING;
	}
	
	public function update(dt:Float):Void {
		super.update(dt);
		
		if (hasReachedTarget) {
			entity.x = target
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
		
	}
	
	override public function destroy():Void {
		super.detroy();
		for (point in nodes) {
			point.put();
		}
	}
	
	public function toggle():Void {
		on = !on;
	}
	
	private function set_on(on:Bool):Bool {
		if (this.on == on) return on;
		
		this.on = on;
		if (on) {
			if (startCallback != null) startCallback(this);
		} else {
			if (endCallback != null) stopCallback(this);
		}
		
		return on;
	}
	
	private function get_currentTarget():FlxPoint {
		return nodes[currentTargetIndex];
	}
	
	private function get_attachmentX
}