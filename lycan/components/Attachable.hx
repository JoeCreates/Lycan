package lycan.components;

import lycan.LateUpdatable;
import lycan.LateUpdater;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxPoint;
import lycan.LycanState;

interface Attachable {
	public var x:Float;
	public var y:Float;
	public var attachable:AttachableComponent;
}

class AttachableComponent extends Component<Attachable> implements LateUpdatable {
	public var parent:Attachable;
	public var children:Array<Attachable>;
	public var isRoot(get, never):Bool;
	
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var originX(default, set):Float;
	public var originY(default, set):Float;
	
	// True if attached position or origin have changed since last update
	private var dirty:Bool;
	
	public function new(entity:Attachable) {
		super(entity);
	}
	
	override public function lateUpdate(dt:Float):Void {
		
		var state:FlxState = cast FlxG.state;
		// The root is responsible for recursively updating its children
		// However, children must also update if their attached position or origin
		// have changed, which is indicated by the dirty flag
		if (isRoot || dirty) {
			recursiveUpdate(dt);
		}
	}
	
	override public function update(dt:Float):Void {
		var state:LycanState = cast FlxG.state;
		state.updateLater(lateUpdate);
	}
	
	/**
	 * Attach a child to this object at the given position
	 * @param	child The child to attach
	 * @param	x The x position of the attachment
	 * @param	y The y position of the attachment
	 */
	public function attach(child:Attachable, x:Float, y:Float, ?originX:Float, ?originY:Float):Void {
		// Detach child from current parent
		if (child.parent != null) {
			child.parent.remove(child);
		}		
		
		// Attach child to this attachable
		children.push(child);
		child.parent = this;
		
		// Instatiate properties if necessary
		if (children == null) children = new Array<Attachable>();
		if (child.attachPosition == null) child.attachPosition = FlxPoint.get();
		if (child.attachOrigin == null) child.attachOrigin = FlxPoint.get();
		
		// Set child's attached position
		child.attachPosition.set(x, y);
		
		// Set child's attachment origin if given
		if (originX != null) { child.attachOrigin.x = originX; }
		if (originY != null) { child.attachOrigin.y = originY; }
	}
	
	/**
	 * Remove a child of this attachable
	 * @param	child The child to remove
	 */
	public function remove(child:Attachable):Void {
		// Return if attachable is not a valid child
		if (child.parent != this) return;
		
		children.remove(child);
		child.parent = null;
	}
	
	@:allow AttachableComponent
	private function recursiveUpdate(dt:Float:Void {		
		// Recursively update children
		for (child in children) {
			// Update child's position
			child.x = entity.x + child.attachable.x - child.attachable.origin.x;
			child.y = entity.y + child.attachable.y - child.attachable.origin.y;
			// Update child's children
			child.attachable.recursiveUpdate(dt);
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
}