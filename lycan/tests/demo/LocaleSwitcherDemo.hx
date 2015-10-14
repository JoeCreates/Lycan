package lycan.tests.demo;

import lycan.states.LycanState;

class LocaleSwitcherDemo extends LycanState {
	override public function create():Void {
		super.create();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}