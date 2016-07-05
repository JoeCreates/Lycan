package lycan.ai;

// Models external effects of an AI's action
class Effect {
	public var id(default, null):Int;

	public inline function new(id:Int, ?effect:Void -> Void) {
		this.id = id;

		if (effect != null) {
			this.effect = effect;
		}
	}

	public dynamic function effect():Void {

	}
}