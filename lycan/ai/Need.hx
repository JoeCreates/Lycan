package lycan.ai;

using lycan.util.FloatExtensions;

// Needs are measures of the strength of the motive to react to problems
// Like Sims "commodities", they express a class of need e.g. to be in the gym, to not go hungry
class Need {
	public var id(default, null):Int;
	public var value(default, set):Float;
	public var growthRate(default, null):Float;
	public var growthModifier(default, null):Float;
	public var tag(default, null):String;
	
	public function new(id:Int, initialValue:Float, growthRate:Float = 0.01, growthModifier:Float = 1.0, tag:String = "Unnamed Motive") {
		this.id = id;
		this.value = initialValue;
		this.growthRate = growthRate;
		this.growthModifier = growthModifier;
		this.tag = tag;
	}
	
	public function update(dt:Float):Void {
		value += dt * growthRate * growthModifier;
	}
	
	private function set_value(v:Float):Float {
		return this.value = v.clamp(0, 1);
	}
}