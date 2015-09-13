package lycan.util.timeline;

import flixel.input.FlxAccelerometer;
import lycan.util.timeline.Easing;

using lycan.util.FloatExtensions;

class Tween extends TimelineItem {
	public var ease:Float->Float;
	public var fields:Array<FieldDetails>;
	
	public function new(target:Dynamic, startTime:Float, duration:Float, fields:Array<FieldDetails>, ease:Float->Float) {		
		super(null, target, startTime, duration);
		this.ease = ease;
		this.fields = fields;
	}
	
	override public function onEnterLeft(count:Int):Void {
		
	}
	
	override public function onExitLeft(count:Int):Void {
		
	}
	
	override public function onEnterRight(count:Int):Void {

	}
	
	override public function onExitRight(count:Int):Void {
		
	}
	
	override public function onUpdate(time:Float):Void {
		//trace("TIME: " + time);
		//trace("LINEAR: " + progressFraction(time, startTime, endTime));
		//trace("EASE: " + ease(progressFraction(time, startTime, endTime)));
		
		for (field in fields) {
			setField(target, field.name, ease(progressFraction(time, startTime, endTime)).lerp(field.start , field.end));
		}
	}
	
	private static inline function progressFraction(time:Float, start:Float, end:Float):Float {
		Sure.sure(start <= end);
		
		if (start == end) {
			return 0.5;
		}
		
		return ((time - start) / (end - start)).clamp(0, 1);
	}
	
	private inline function setField<T> (target:T, key:String, value:Dynamic):Void {
		if (Reflect.hasField(target, key)) {
			#if flash
			untyped target[key] = value;
			#else
			Reflect.setField(target, key, value);
			#end
		} else {
			throw "Could not find key " + key + " on target " + target;
			// Reflect.setProperty(target, key, value);
		}
	}
}

typedef FieldDetails = {
	var name:String;
	var start:Float;
	var end:Float;
}