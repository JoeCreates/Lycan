package lycan.components;

interface CenterPositionable extends Entity {
	public var center:CenterPositionableComponent;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
}

class CenterPositionableComponent extends Component<CenterPositionable> {
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	public function new(entity:CenterPositionable) {
		super(entity);
	}
	
	private function set_x(x:Float):Float {
		entity.x = x - entity.width / 2;
		return x;
	}
	
	private function set_y(y:Float):Float {
		entity.y = y - entity.height / 2;
		return y;
	}
	
	private function get_x():Float {
		return entity.x + entity.width / 2;
	}
	
	private function get_y():Float {
		return entity.y + entity.height / 2;
	}
}