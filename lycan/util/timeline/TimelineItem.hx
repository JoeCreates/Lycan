package lycan.util.timeline;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

using lycan.util.BitSet;

using lycan.util.FloatExtensions;

class Boundary {
    public var parent(default, null):TimelineItem;
    public var leftToRightCount:Int = 0;
    public var rightToLeftCount:Int = 0;
    
    private var signal_crossed:Signal2<Bool, Int>;
    
    public inline function new(parent:TimelineItem) {
        this.parent = parent;
        this.signal_crossed = new Signal2<Bool, Int>();
    }
    
    public function add(f:Bool->Int->Void):Void {
        signal_crossed.add(f);
    }
    
    public function dispatch(reverse:Bool, count:Int):Void {
        signal_crossed.dispatch(reverse, count);
    }
}

// Base class for anything that can go on a timeline
class TimelineItem {
    public var parent(default, null):Timeline<Dynamic>;
    public var target(default, set):Dynamic;
    
    public var startTime(default, set):Float;
    @:isVar public var duration(get, set):Float;
    public var endTime(get, null):Float;
    
    public var exitLeftLimit(default, null):Int;
    public var exitRightLimit(default, null):Int;
    public var completed(get, null):Bool;
    public var hovered(get, null):Bool;
    
    public var removeOnCompletion(default, default):Bool;
    public var markedForRemoval(default, default):Bool;
    
    public var left:Boundary;
    public var right:Boundary;
    public var signal_removed = new Signal1<Timeline<Dynamic>>();
    
    public function new(?parent:Timeline<Dynamic>, target:Dynamic, startTime:Float, duration:Float) {
        this.parent = parent;
        this.target = target;
        this.startTime = startTime;
        this.duration = duration;
        
        left = new Boundary(this);
        right = new Boundary(this);
        
        exitLeftLimit = 1;
        exitRightLimit = 1;
        
        removeOnCompletion = true;
        markedForRemoval = false;
        
        #if debug
        signal_removed.add(function(parent:Timeline<Dynamic>) {
            trace("Removed timeline item from timeline");
        });
        #end
    }
    
    public function reset():Void {
        // TODO reset boundary counts, remove signals?
        markedForRemoval = false;
    }
    
    public dynamic function onUpdate(time:Float):Void {
        
    }
    
    public function stepTo(nextTime:Float, ?currentTime:Float):Void {
        Sure.sure(currentTime != null);
        
        if (markedForRemoval) {
            return;
        }
        
        if (completed) {
            if (removeOnCompletion) {
                markedForRemoval = true;
            }
            return;
        }
        
        onUpdate(nextTime);
    }
    
    private function set_target(target:Dynamic):Dynamic {
        return this.target = target;
    }
    
    private function get_duration():Float {
        return this.duration;
    }
    
    private function set_duration(duration:Float):Float {
        this.duration = Math.max(0, duration);
        if (parent != null) {
            parent.itemTimeChanged(this);
        }
        return duration;
    }
    
    private function set_startTime(startTime:Float):Float {
        this.startTime = startTime;
        if (parent != null) {
            parent.itemTimeChanged(this);
        }
        return startTime;
    }
    
    private function get_endTime():Float {
        return startTime + duration;
    }
    
    private function get_completed():Bool {
        return (left.rightToLeftCount >= exitLeftLimit && right.leftToRightCount >= exitRightLimit);
    }
    
    private function get_hovered():Bool {
        Sure.sure(parent != null);
        return (parent.currentTime >= startTime && parent.currentTime <= endTime);
    }
}