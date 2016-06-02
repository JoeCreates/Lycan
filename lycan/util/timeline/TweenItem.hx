package lycan.util.timeline;

import haxe.macro.Expr;
import lycan.util.EasingEquations;
import haxe.macro.Context;

using lycan.util.FloatExtensions;

class TweenItem extends TimelineItem {
    public var ease:Float->Float;
    public var tweeners:Array<Float->Void>;

    public function new(target:Dynamic, startTime:Float, duration:Float, tweeners:Array<TweenItem->Float->Void>, ease:Float->Float) {
        super(null, target, startTime, duration);
        this.ease = ease;

        this.tweeners = new Array<Float->Void>();
        for (tween in tweeners) {
            this.tweeners.push(tween.bind(this));
        }
    }

    public macro static function makeTweener(field:String):Expr {
        if (field == null || field.length == 0) {
            throw "Invalid field specified";
        }
        var code = 'function(startTime:Float, endTime:Float, item:TweenItem, time:Float):Void { item.target.$field = item.ease(TweenItem.progressFraction(time, item.startTime, item.endTime)).lerp(startTime, endTime); }';
        return Context.parseInlineString(code, Context.currentPos());
    }

    override public function onUpdate(time:Float):Void {
        for (tween in tweeners) {
            tween(time);
        }
    }

    public static inline function progressFraction(time:Float, start:Float, end:Float):Float {
        Sure.sure(start <= end);

        if (start == end) {
            return 0.5;
        }

        return ((time - start) / (end - start)).clamp(0, 1);
    }
}