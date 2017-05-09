package lycan.components;

import flixel.FlxG;
import flixel.system.frontEnds.SignalFrontEnd;

interface Attachable extends Entity {
	public var attachable:AttachableComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	// TODO could add optional requirements?
	@:relaxed public var flipX(get, set):Bool;
	@:relaxed public var flipY(get, set):Bool;
}

class AttachableComponent extends Component<Attachable> {
	public var parent:Attachable;
	public var children:Array<Attachable>;
	public var isRoot(get, never):Bool;
	
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var moveFactorX(default, set):Float;
	public var moveFactorY(default, set):Float;
	public var originX(default, set):Float;
	public var originY(default, set):Float;
	public var flipX(default, set):Bool;
	public var flipY(default, set):Bool;
	public var lastX:Float;
	public var lastY:Float;
	
	// TODO x and y should also be dependent on flip
	
	// True if attached position or origin have changed since last update
	private var dirty:Bool;
	
	public function new(entity:Attachable) {
		super(entity);
		
		x = 0;
		y = 0;
		moveFactorX = 1;
		moveFactorY = 1;
		originX = 0;
		originY = 0;
		flipX = false;
		flipY = false;
		
		FlxG.signals.postUpdate.add(lateUpdate);
		
		//removeSignals = function() {
			//FlxG.signals.postUpdate.remove(lateUpdate);
		//};
	}
	
	@:append("destroy")
	public function destroy():Void {
		FlxG.signals.postUpdate.remove(lateUpdate);
	}
	
	//dynamic function removeSignals() {FlxG.signals.postUpdate.remove(lateUpdate);}
	
	public function lateUpdate():Void {
		// The root is responsible for recursively updating its children
		// However, children must also update if their attached position or origin
		// have changed, which is indicated by the dirty flag
		if (isRoot || dirty) {
			recursiveUpdate(FlxG.elapsed);
		}
	}
	
	/**
	 * Attach a child to this object at the given position
	 * @param   child The child to attach
	 * @param   x The x position of the attachment
	 * @param   y The y position of the attachment
	 */
	public function attach(child:Attachable, ?x:Float, ?y:Float, ?originX:Float, ?originY:Float, ?updateAndDraw:Bool):Void {
		// Detach child from current parent
		if (child.attachable.parent != null) {
			child.attachable.parent.attachable.remove(child);
		}
		
		// Instantiate properties if necessary
		if (children == null) children = new Array<Attachable>();
		
		// Attach child to this attachable
		children.push(child);
		child.attachable.parent = entity;
		
		// Determine relative position if x/y are null
		if (x == null) {
			x = child.entity_x - entity.entity_x;
		}
		if (y == null) {
			y = child.entity_y - entity.entity_y;
		}
		
		// Set child's attached position
		child.attachable.x = x;
		child.attachable.y = y;
		
		// Set child's attachment origin if given
		if (originX != null) { child.attachable.originX = originX; }
		if (originY != null) { child.attachable.originY = originY; }
		
		child.attachable.lastX = child.entity_x;
		child.attachable.lastY = child.entity_y;
		dirty = true;
	}
	
	/**
	 * Remove a child of this attachable
	 * @param   child The child to remove
	 */
	public function remove(child:Attachable):Void {
		// Return if attachable is not a valid child
		if (child.attachable.parent.attachable != this) return;
		
		children.remove(child);
		child.attachable.parent = null;
	}
	
	@:access(AttachableComponent)
	private function recursiveUpdate(dt:Float):Void {
		if (children == null) return;
		// Recursively update children
		for (child in children) {
			// Update child's relative position based on how much flixel has moved it
			child.attachable.x += child.entity_x - child.attachable.lastX;
			child.attachable.y += child.entity_y - child.attachable.lastY;
			// Update child's position
			// TODO ive assumed parent will be using pixelPerfectPosition here. The floor therefore prevents jittering
			// when the parent and children both have real positions
			child.entity_x = Math.floor(entity.entity_x * child.attachable.moveFactorX) + child.attachable.x - child.attachable.originX;
			child.entity_y = Math.floor(entity.entity_y * child.attachable.moveFactorY) + child.attachable.y - child.attachable.originY;
			// Update child's flip
			//child.entity_flipX = !child.attachable.flipX ? entity.entity_flipX : !entity.entity_flipX;
			//child.entity_flipY = !child.attachable.flipY ? entity.entity_flipY : !entity.entity_flipY;
			// Update child's children
			child.attachable.recursiveUpdate(dt);
			// Record current flixel position
			child.attachable.lastX = child.entity_x;
			child.attachable.lastY = child.entity_y;
		}
		dirty = false;
	}
	
	private inline function get_isRoot():Bool {
		return parent == null;
	}
	
	private function set_x(x:Float):Float {
		this.x = x;
		dirty = true;
		return x;
	}
	private function set_y(y:Float):Float {
		this.y = y;
		dirty = true;
		return y;
	}
	
	private function set_moveFactorX(x:Float):Float {
		this.moveFactorX = x;
		dirty = true;
		return x;
	}
	private function set_moveFactorY(y:Float):Float {
		this.moveFactorY = y;
		dirty = true;
		return y;
	}
	
	private function set_originX(x:Float):Float {
		this.originX = x;
		dirty = true;
		return x;
	}
	private function set_originY(y:Float):Float {
		this.originY = y;
		dirty = true;
		return y;
	}
	
	private function set_flipX(flip:Bool):Bool {
		this.flipX = flip;
		dirty = true;
		return flip;
	}
	private function set_flipY(flip:Bool):Bool {
		this.flipY = flip;
		dirty = true;
		return flip;
	}
}