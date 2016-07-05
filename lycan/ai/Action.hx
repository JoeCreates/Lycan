package lycan.ai;

class Action {
	public var id(default, null):Int;
	public var effects(default, null):Array<Effect>;

	public function new(id:Int, ?effects:Array<Effect>) {
		this.id = id;

		if (effects != null) {
			this.effects = effects;
		}
	}

	public function started(brain:Brain<Dynamic>):Void {
		// Unimplemented
	}

	public function cancelled(brain:Brain<Dynamic>):Void {
		// Unimplemented
	}

	public function interrupted(brain:Brain<Dynamic>):Void {
		// Unimplemented
	}

	public function completed(brain:Brain<Dynamic>):Void {
		// Unimplemented
	}
}