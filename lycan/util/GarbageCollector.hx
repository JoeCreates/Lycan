package lycan.util;

#if cpp
import cpp.vm.Gc;
#elseif neko
import neko.vm.Gc;
#elseif flash
import flash.system.System;
#end

class GarbageCollector {
	private static var paused = false;
	
	public static function isPaused():Bool {
		return paused;
	}
	
	public static function pause():Void {
		Sure.sure(!paused);
		paused = true;
		
		// TODO review this, was causing GC errors before (does it completely detach the GC, making allocations illegal or something?)
		#if cpp
		//Gc.enterGCFreeZone();
		#end
	}
	
	public static function resume():Void {
		Sure.sure(paused);
		paused = false;
		
		#if cpp
		//Gc.exitGCFreeZone();
		#end
	}
	
	public static function run(?major:Bool = true):Void {
		#if cpp
		Gc.run(true);
		#elseif neko
		Gc.run(true);
		#elseif flash
		System.gc();
		#end
	}
}