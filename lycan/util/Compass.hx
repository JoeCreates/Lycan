package lycan.util;

@:enum abstract Compass(Int) to Int {
	var N = 1;
	var S = 2;
	var E = 4;
	var W = 8;
	var NE = 5;
	var NW = 9;
	var SE = 6;
	var SW = 10;

	inline function new(val:Compass) {
		this = val;
	}

	public var northward(get, set):Bool;
	public var southward(get, set):Bool;
	public var eastward(get, set):Bool;
	public var westward(get, set):Bool;
	
	public var radians(get, never):Float;
	public var degrees(get, set):Int;

	inline function get_northward():Bool return this & N > 0;
	inline function get_eastward():Bool return this & E > 0;
	inline function get_westward():Bool return this & W > 0;
	inline function get_southward():Bool return this & S > 0;

	inline function set_northward(val:Bool):Bool {
		val ? this |= N : this &= ~N;
		this = from(this);
		return val;
	}

	inline function set_eastward(val:Bool):Bool {
		val ? this |= E : this &= ~E;
		this = from(this);
		return val;
	}

	inline function set_southward(val:Bool):Bool {
		val ? this |= S : this &= ~S;
		this = from(this);
		return val;
	}

	inline function set_westward(val:Bool):Bool {
		val ? this |= W : this &= ~W;
		this = from(this);
		return val;
	}

	inline function get_radians():Float {
		var compass:Compass = this;
		return switch (compass) {
			case N: 0;
			case S: Math.PI;
			case E: Math.PI / 2;
			case W: Math.PI * 3 / 2;
			case NE: Math.PI / 4;
			case NW: Math.PI * 7 / 4;
			case SE: Math.PI * 3 / 4;
			case SW: Math.PI * 5 / 4;
		}
	}

	inline function get_degrees():Float {
		return get_radians() * 180 / Math.PI;
	}
	
	inline function set_degrees(value:Int):Int {
		var deg = value % 360;
		while (deg < 0) deg += 360;
		deg = Math.round(deg / 45) * 45;
		this = from(switch (deg) {
			case 0: N;
			case 45: NE;
			case 90: E;
			case 135: SE;
			case 180: S;
			case 225: SW;
			case 270: W;
			case 315: NW;
		});
		return value;
	}

	@:from static function from(val:Int):Compass {
		var com:Compass = switch (val) {
			case 1: N;
			case 2: S;
			case 4: E;
			case 8: W;
			case 9: NW;
			case 5: NE;
			case 10: SW;
			case 6: SE;
			case _: throw("Invalid compass direction: " + val);
		}
		return com;
	}

	@:to function toString():String {
		var out = "";
		if (northward)
			out += "N";
		if (southward)
			out += "S";
		if (eastward)
			out += "E";
		if (westward)
			out += "W";
		return out;
	}

	@:from static function fromString(value:String):Compass {
		var val = value.toLowerCase();
		val = StringTools.replace(val, "north", "n");
		val = StringTools.replace(val, "south", "s");
		val = StringTools.replace(val, "east", "e");
		val = StringTools.replace(val, "west", "w");
		val = StringTools.replace(val, " ", "");

		return switch (val) {
			case "n": N;
			case "s": S;
			case "e": E;
			case "w": W;
			case "ne": NE;
			case "nw": NW;
			case "se": SE;
			case "sw": SW;
			case _: throw("Invalid compass string: " + value);
		}
	}
}
