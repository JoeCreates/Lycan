package lycan.states;

import flixel.FlxState;
import flixel.math.FlxPoint;
import haxe.io.Path;
import lycan.util.BatchScreenGrab;
import openfl.Lib;
import openfl.events.KeyboardEvent;

class LycanRootState extends FlxState {
	
	public static var get:LycanRootState;
	
	private function new() {
		super();
		
		// TODO move this somewhere better
		#if (debug && cpp && enablesceenshots)
			// Batch screenshots
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(evt:KeyboardEvent) {
			if (evt.keyCode == 83) { // S to take screenshots
				var screenshotSizes:Array<FlxPoint> = [
				new FlxPoint(960, 640), // 3.5 inch retina
				new FlxPoint(1136, 640), // 4 inch retina
				new FlxPoint(1280, 800), // 720p/Mac/Google Play mobile/tablet screenshots
				new FlxPoint(1334, 750), // 4.7 inch retina
				new FlxPoint(1440, 900), // Mac
				new FlxPoint(1920, 1080), // 1080p
				new FlxPoint(1920, 1200), // Amazon appstore
				new FlxPoint(2048, 1536), // iPad
				new FlxPoint(2208, 1242), // 5.5 inch retina
				new FlxPoint(2560, 1440), // 1440p
				new FlxPoint(2732, 2048), // iPad Pro
				new FlxPoint(2560, 1600), // Amazon appstore
				new FlxPoint(2880, 1800), // Mac
				new FlxPoint(3840, 2160) // 4K
				];

				var grab = new BatchScreenGrab(new Path("screenshot.png"), screenshotSizes);
				grab.start();
			}
		});
		#end
	}

	override public function create():Void {
		super.create();
		
		// Set static reference to this root state
		LycanRootState.get = this;
	}

	override public function destroy():Void {
		super.destroy();
	}
	
	// Returns the first state of type T in the state stack, throws if there isn't one of that type
	public static function getFirstStateOfType<T>(type:Class<T>):T {
		var child = get.subState;

		while (child != null) {
			if (Std.is(child, type)) {
				return cast child;
			}

			child = cast child.subState;
		}

		throw "Failed to find a substate of type " + Type.getClassName(type) + " in current states...";
	}
}