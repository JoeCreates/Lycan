package lycan.components;

interface CenterPositionable extends Entity {
	public var center:CenterPositionableComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
	public var val:Int;
}

class CenterPositionableComponent extends Component<CenterPositionable> {
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	public function new(entity:CenterPositionable) {
		super(entity);
	}
	
	// TODO potential flaw here... what if something has happened to the parameter? e.g. modified before call
	@:prepend("update") public function preupdate(dt:Float):Void {
		trace("Pre Updated with dt = " + dt + " " + entity.val);
		entity.val = 22;
	}
	@:append("update") public function postupdate(dt:Float):Void {
		trace("Post Updated with dt = " + dt + " " + entity.val);
		entity.val = 100;
	}
	
	private function set_x(x:Float):Float {
		entity.entity_x = x - entity.entity_width / 2;
		return x;
	}
	
	private function set_y(y:Float):Float {
		entity.entity_y = y - entity.entity_height / 2;
		return y;
	}
	
	private function get_x():Float {
		return entity.entity_x + entity.entity_width / 2;
	}
	
	private function get_y():Float {
		return entity.entity_y + entity.entity_height / 2;
	}
}