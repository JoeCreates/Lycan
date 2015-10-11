package lycan.tests.demo;

import lycan.states.LycanRootState;

class LycanTestRootState extends LycanRootState {
	override public function create():Void {
		super.create();
		
		// TODO add scroll panel test with list of buttons to open test states
		// TODO use a macro to generate the list
		
		openSubState(new EasingGalleryDemo());
	}
}