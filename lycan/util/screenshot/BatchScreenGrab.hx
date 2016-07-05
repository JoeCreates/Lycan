package lycan.util.screenshot;

#if cpp

import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.math.FlxPoint;
import haxe.io.Path;
import openfl.events.Event;
import openfl.Lib;

// Utility for taking screenshots across several screen resolutions on native platforms
class BatchScreenGrab {
	private var path:Path;
	private var baseFilename:String;
	private var resolutions:Array<FlxPoint>;
	private var currentScreenshot:Int = 0;
	private var frameCount:Int = 0;
	private var originalResolution:FlxPoint;

	public function new(path:Path, resolutions:Array<FlxPoint>) {
		this.path = path;
		this.resolutions = resolutions;
		originalResolution = new FlxPoint(Lib.current.stage.width, Lib.current.stage.height);
		baseFilename = path.file;
	}

	public function start():Void {
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, handler);
	}

	private function handler(e:Dynamic):Void {
		frameCount++;

		if (currentScreenshot >= resolutions.length) {
			trace("All screenshots taken");
			Lib.current.stage.removeEventListener(Event.ENTER_FRAME, handler);
			#if next
			Lib.application.window.resize(Std.int(originalResolution.x), Std.int(originalResolution.y));
			#else
			Lib.current.stage.resize(Std.int(originalResolution.x), Std.int(originalResolution.y));
			#end
			return;
		}

		if (frameCount % 2 == 0) {
			#if next
			Lib.application.window.resize(Std.int(resolutions[currentScreenshot].x), Std.int(resolutions[currentScreenshot].y));
			#else
			Lib.current.stage.resize(Std.int(resolutions[currentScreenshot].x), Std.int(resolutions[currentScreenshot].y));
			#end
		} else {
			saveScreenshot();
		}
	}

	private function saveScreenshot() {
		path.file = baseFilename + "_" + Std.int(resolutions[currentScreenshot].x) + "x" + Std.int(resolutions[currentScreenshot].y) + "__" + Std.int(Math.random() * 10000000);
		SaveBitmap.save(path, FlxScreenGrab.grab(null, false, true));
		currentScreenshot++;
	}
}

#end