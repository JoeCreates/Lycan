package lycan.components;

import lycan.components.Entity;
import lycan.components.Component;

interface GridPositionable extends Entity {
	public var gridPos:GridPositionComponent;
}

@:tink
class GridPositionComponent extends Component<GridPositionable> {
	public var x(default, set):Int = 0;
	public var y(default, set):Int = 0;
	public var realX(default, set):Float = 0;
	public var realY(default, set):Float = 0;
	
	public function new(entity:GridPositionable) {
		super(entity);
	}
	
	public function set(x:Float, y:Float) {
		realX = x;
		realY = y;
	}
	
	private function set_x(x:Int):Int {
		realX = x;
		this.x = x;
		return x;
	}
	
	private function set_y(y:Int):Int {
		realY = y;
		this.y = y;
		return y;
	}
	
	private function set_realX(x:Float):Float {
		realX = x;
		this.x = x > this.x ? Math.floor(x) : Math.ceil(x);
		return x;
	}
	
	private function set_realY(y:Float):Float {
		realY = y;
		this.y = y > this.y ? Math.floor(y) : Math.ceil(y);
		return y;
	}
}