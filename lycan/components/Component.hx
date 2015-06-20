package lycan.components;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.FlxObject;

class Component<T> {
	public var entity:T;
	
	public function new(entity:T) {
		this.entity = entity;

	public function update(dt:Float):Void {}
}