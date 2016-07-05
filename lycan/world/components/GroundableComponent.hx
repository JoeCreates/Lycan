package lycan.world.components;

import flixel.FlxComponent;
import flixel.FlxObject;
import flixel.FlxSprite;

class GroundableComponent extends FlxComponent {
	private var currentGrounds:Map<FlxObject, Bool>;
	private var currentGroundCount:Int;
	private var grounded:Bool; //Hacked in for ludum dare
	private var queueGrounded:Bool;
	
	public var wasGrounded:Bool = false;
	public var isGrounded(get, never):Bool;
	/** Whether to force grounded checks to return true */
	public var forceGrounded:Bool;
	
	public function new() {
		super("groundable");
		currentGrounds = new Map<FlxObject, Bool>();
		forceGrounded = false;
		queueGrounded = false;
		grounded = false;
	}
	
	public function update(dt:Float):Void {
		wasGrounded = grounded;
		grounded = queueGrounded;
		queueGrounded = false;
	}
	
	public function groundForFrame():Void {
		queueGrounded = true;
	}
	
	public function add(object:FlxObject):Void {
		if (!currentGrounds.exists(object)) {
			currentGrounds.set(object, true);
			currentGroundCount++;
		}
	}
	
	public function remove(object):Void {
		if (currentGrounds.exists(object)) {
			currentGrounds.remove(object);
			currentGroundCount--;
		}
	}
	
	private function get_isGrounded():Bool {
		return grounded;
		return forceGrounded || currentGroundCount > 0;
	}
}