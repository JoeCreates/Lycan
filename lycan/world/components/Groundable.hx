package lycan.world.components;

import flixel.FlxObject;
import flixel.FlxSprite;
import lycan.components.Component;
import lycan.components.Entity;

interface Groundable extends Entity {
	public var ground:GroundableComponent;
}

class GroundableComponent extends Component<Groundable> {
	private var currentGrounds:Map<FlxObject, Bool>;
	private var currentGroundCount:Int;
	private var grounded:Bool;//Hacked in for ludum dare
	private var queueGrounded:Bool;
	
	public var wasGrounded:Bool = false;
	public var isGrounded(get, never):Bool;
	/** Whether to force grounded checks to return true */
	public var forceGrounded:Bool;
	
	public function new(entity:Groundable) {
		super(entity);
		currentGrounds = new Map<FlxObject, Bool>();
		forceGrounded = false;
		requiresUpdate = true;
		queueGrounded = false;
		grounded = false;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
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