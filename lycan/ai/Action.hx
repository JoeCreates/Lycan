package lycan.ai;

class Action {
	public var id(default, null):Int;
	public var duration(default, null):Float;
	public var effects(default, null):Array<Effect>;
	
	public function new(id:Int, duration:Float, effects:Array<Effect>) {
		this.id = id;
		this.duration = duration;
		this.effects = effects;
	}
}