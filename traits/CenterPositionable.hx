package traits ;
import traits.ITrait;

interface CenterPositionable extends ITrait {
	
	public var centerX(get, set):Float;
	public var centerY(get, set):Float;
	
	private function get_centerX():Float {
		return this.x + width / 2;
	}
	
	private function set_centerX(centerX:Float):Float {
		super.set_x(centerX - width / 2);
		return centerX;
	}
	
	private function get_centerY():Float {
		return this.y + height / 2;
	}
	
	private function set_centerY(centerY:Float):Float {
		super.set_y(centerY - height / 2);
		return centerY;
	}
	
}