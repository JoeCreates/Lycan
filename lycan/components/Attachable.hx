package components;

import components.Attachable.AttachableSystem;
import flixel.FlxObject;

interface Attachable {
	public var x:Float;
	public var y:Float;
	public var attachable:AttachableComponent;
}

class AttachableSystem {
	
	public static var instance(get, null):Void;
	
	private function new() {
		super();
	}
	
	override public function update(dt:Float):Void {
		// Updates only root nodes
		// TODO track only roots?
		for (member in members) {
			if (member.isRoot) {
				member.update(dt);
			}
		}
	}
	
	private function get_instance():AttachableSystem {
		if (instance == null) instance = new AttachableSystem();
		return instance;
	}
}

class AttachableComponent extends Component<FlxObject> {
	public static var system:
	
	public var entity:FlxObject;
	public var parent:Attachable;
	public var children:Array<Attachable>
	public var isRoot(get, never):Bool;
	
	public var position:FlxPoint;
	public var origin:FlxPoint;
	
	public function new(entity:FlxObject) {
		super(entity);
		system = AttachableSystem.instance;
	}
	
	override public function update(dt:Float):Void {
		// Update position
		if (!isRoot) {
			entity.x = parent.entity.x + position.x - origin.x;
			entity.y = parent.entity.y + position.y - origin.y;
		}
		
		// Recursively update children
		for (child in children) {
			child.update(dt);
		}
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
		
		// Init data if necessary
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
	
	private inline function get_isRoot():Bool {
		return parent == null;
	}
}