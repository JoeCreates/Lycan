package lycan.loading.loaders;

import flixel.FlxG;
import haxe.Timer;
import lycan.loading.tasks.IDescribable;
import lycan.loading.tasks.ILoadingSignalDispatcher;
import lycan.loading.tasks.IRunnable;
import lycan.util.queue.IPrioritizable;
import openfl.events.Event;
import openfl.Lib;

// Loader that runs on the main thread but timeshares, so it does not block the game loop
class EventPumpLoader<T:(IPrioritizable, IRunnable, ILoadingSignalDispatcher, IDescribable)> extends Loader<T> {
    /* The time that the loader aims to spend loading assets per OpenFL frame */
    private var timeShare:Float;
    
    public function new() {
        super();
        timeShare = (1 / FlxG.drawFramerate) * 0.5; // Load for at least 50% of the frame render time
    }
    
    private function startEvent(e:Event):Void {
        var dt:Float = 0;
        while (!queue.empty() && dt < timeShare) {
            var prev = Timer.stamp();
            var task:T = queue.pop();
            task.run();
            dt += Timer.stamp() - prev;
        }
        
        if (queue.empty()) {
            finish();
        }
    }
    
    override public function start():Void {
        super.start();
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, startEvent);
    }
    
    override private function finish():Void {
        Lib.current.stage.removeEventListener(Event.ENTER_FRAME, startEvent);
        super.finish();
    }
    
    override private function onTaskCompleted(what:T):Void {
        super.onTaskCompleted(what);
    }
    
    override private function onTaskFailed(what:T, why:String):Void {
        super.onTaskFailed(what, why);
    }
}