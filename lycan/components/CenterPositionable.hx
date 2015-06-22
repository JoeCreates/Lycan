package lycan.components;

import components.Component;

interface CenterPositionable {
	public var center:CenterPositionableComponent;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
}

class CenterPositionableComponent extends Component<CenterPositionable> {
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	public function new(entity:CenterPositionable) {
		super(entity);
	}
	
	private var set_x(x:Float):Float {
		entity.x = x - entity.width / 2;
		return x;
	}
	
	private var set_y(y:Float):Float {
		entity.y = y - entity.height / 2;
		return y;
	}
	
	private var get_x():Float {
		return entity.x + entity.width / 2;
	}
	
	private var get_y():Float {
		return entity.y + entity.height / 2;
	}
}