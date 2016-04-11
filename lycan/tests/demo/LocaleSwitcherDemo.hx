package lycan.tests.demo;

import lycan.tests.demo.BaseDemoState;

class LocaleSwitcherDemo extends BaseDemoState {
	override public function create():Void {
		super.create();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}