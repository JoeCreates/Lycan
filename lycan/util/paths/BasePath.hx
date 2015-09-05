package lycan.util.paths;

import flixel.FlxCamera;
import flixel.util.FlxColor;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

// TODO path base class
// Moves a point along a path
class BasePath {
	public var signal_started(default, null) = new Signal1<BasePath>();
	public var signal_activeToggled(default, null) = new Signal2<BasePath, Bool>();
	public var signal_cancelled(default, null) = new Signal1<BasePath>();
	public var signal_completed(default, null) = new Signal1<BasePath>();
	
	#if debug
	public var debugColor:FlxColor;
	#end
	
	public function new() {
		#if debug
		debugColor = 0x0000FF;
		#end
	}
	
	#if debug
	public function draw(camera:FlxCamera):Void {
		
	}
	#end
}