package components;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.FlxObject;

class Component<T> extends FlxBasic {
	
	public static var system:ComponentSystem;
	public var entity:T;
	
	public function new(entity:T) {
		this.entity = entity;
		
	}
	
	public function preUpdate(dt:Float):Void {}
	
	public function update(dt:Float):Void {}
	
	public function postUpdate(dt:Float) {}
	
}