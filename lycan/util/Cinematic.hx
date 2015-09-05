package lycan.util;

enum TraversalMode {
	BACKWARDS;
	FORWARDS;
}

// Nestable timelines

// Base class for anything that can go into a cinematic
interface CinematicItem {
	var owner(default, null):Cinematic;
	var startTime:Float;
	var started(default, null):Bool;
}


class Cinematic implements CinematicItem {
	private var currentTime:Float;
	private var items:List<CinematicEvent>;
	private var startTime:Float;
	private var started:Bool;
	
	public function new() {
		
	}
	
	public function step(dt:Float):Void {
		
	}
	
	public function stepTo(absoluteTime:Float):Void {
		
	}
	
	public function add(event:CinematicEvent):Void {
		
	}
	
	public function addAtTime(event:CinematicEvent, time:Float):Void {
		
	}
	
	public function empty():Bool {
		
	}
	
	public function numItems():Int {
		
	}
	
	public function clear():Void {
		
	}
	
	public function reset():Void {
		
	}
}