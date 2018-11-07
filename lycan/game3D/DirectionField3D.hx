package lycan.game3D;

abstract DirectionField3D(Int) from Int from UInt to Int to UInt {
	public static inline var FRONT:DirectionField3D = 1;
	public static inline var BACK:DirectionField3D = 2;
	public static inline var FORWARD:DirectionField3D = 1;
	public static inline var BACKWARD:DirectionField3D = 2;
	public static inline var LEFT:DirectionField3D = 4;
	public static inline var RIGHT:DirectionField3D = 8;
	public static inline var UP:DirectionField3D = 16;
	public static inline var DOWN:DirectionField3D = 32;
	public static inline var TOP:DirectionField3D = 16;
	public static inline var BOTTOM:DirectionField3D = 32;
	public static inline var ANY:DirectionField3D = FRONT | BACK | BOTTOM | TOP | LEFT | RIGHT;
	public static inline var NONE:DirectionField3D = 0;
	
	public var front(get, set):Bool;
	public var back(get, set):Bool;
	public var left(get, set):Bool;
	public var right(get, set):Bool;
	public var up(get, set):Bool;
	public var down(get, set):Bool;
	
	public function new(i:Int = 0) {
		this = i;
	}
	
	public inline function setFlag(value:Bool, mask:DirectionField3D):Bool {
		if (value) this |= mask;
		else this &= ~mask;
		return value;
	}
	
	public inline function getFlag(mask:DirectionField3D):Bool {
		return this & mask == mask;
	}
	
	private inline function set_front(v:Bool):Bool return setFlag(v, FRONT);
	private inline function set_back(v:Bool):Bool return setFlag(v, BACK);
	private inline function set_left(v:Bool):Bool return setFlag(v, LEFT);
	private inline function set_right(v:Bool):Bool return setFlag(v, RIGHT);
	private inline function set_up(v:Bool):Bool return setFlag(v, UP);
	private inline function set_down(v:Bool):Bool return setFlag(v, DOWN);
	
	private inline function get_front():Bool return getFlag(FRONT);
	private inline function get_back():Bool return getFlag(BACK);
	private inline function get_left():Bool return getFlag(LEFT);
	private inline function get_right():Bool return getFlag(RIGHT);
	private inline function get_up():Bool return getFlag(UP);
	private inline function get_down():Bool return getFlag(DOWN);
}