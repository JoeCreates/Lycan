package components;

class ComponentSystem extends FlxGroup {
	
	public var preUpdateFlag:Bool;
	public var updateFlag:Bool;
	public var postUpdateFlag:Bool;
	
	public function new() {
		super();
		preUpdateFlag = true;
		updateFlag = true;
		postUpdateFlag = true;
	}
	
	public function preUpdate(dt:Float):Void {
		for (member in members) {
			if (member.isRoot) {
				member.update(dt);
			}
		}
	}
	
	override public function update(dt:Float):Void {

	}
	
	public function postUpdate(dt:Float) {
		
	}
	
}