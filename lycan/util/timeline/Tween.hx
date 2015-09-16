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
		
		for (field in fields) {
			if (field.start == null) {
				field.start = getField(target, field.name);
			}
		}
	}
	
	override public function onUpdate(time:Float):Void {
		//trace("TIME: " + time);
		//trace("LINEAR: " + progressFraction(time, startTime, endTime));
		//trace("EASE: " + ease(progressFraction(time, startTime, endTime)));
		
		for (field in fields) {
			setField(target, field.name, ease(progressFraction(time, startTime, endTime)).lerp(field.start, field.end));
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
		Sure.sure(target != null);
		Sure.sure(key != null);
		Sure.sure(value != null);
		
		if (#if flash false && #end Reflect.hasField(target, key)) {
			Reflect.setField(target, key, value);
		} else {
			// NOTE this is necessary to catch cases where a field was optimized away, and on Flash to ensure getters/setters are called
			Reflect.setProperty(target, key, value);
		}
	}
	
	private inline function getField<T> (target:T, key:String):Dynamic {
		Sure.sure(target != null);
		Sure.sure(Reflect.hasField(target, key));
		
		if (Reflect.hasField(target, key)) {
			#if flash
			return untyped target[key];
			#else
			return Reflect.getProperty(target, key);
			#end
		}
		
		return null;
	}
}

typedef FieldDetails = {
	var name:String;
	@:optional var start:Float;
	var end:Float;
}