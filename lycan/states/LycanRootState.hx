package lycan.states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;

class LycanRootState extends FlxState {
	private var uiCamera:FlxCamera;
	
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		
		// NOTE shared camera for UI
		uiCamera = new FlxCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	public static function getInstance<T>():T {
		var self = FlxG.game._state;
		Sure.sure(self != null);
		return cast self;
	}
	
	// Returns the first state of type T in the state stack, throws if there isn't one of that type
	public static function getFirstStateOfType<T>(type:Class<T>):T {
		var self = LycanRootState.getInstance();
		var child = self.subState;
		
		while (child != null) {
			if (Std.is(child, type)) {
				return cast child;
			}
			
			child = cast child.subState;
		}
		
		throw "Failed to find a substate of type " + Type.getClassName(type) + " in current states...";
	}
}