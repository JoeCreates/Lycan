package lycan.util.paths;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import msignal.Signal.Signal2;
import openfl.display.Graphics;

using lycan.util.structure.container.BitSet;
using lycan.core.IntExtensions;

enum TraversalMode {
    FORWARD;
    BACKWARD;
}

// TODO use this
enum AdvanceMode {
    CONTINUOUS;
    SNAP_TO_NEAREST;
}

// Moves a point along an array of 2D points in a linear fashion, traversing at most one point in the path per update
class ConstantRatePath extends BasePath {
    public var rate:Float; // Units per second
    public var active(default, set):Bool;
    //public var bearing(default, null):Float; // Angle in degrees between current and next point in the path // TODO
    public var complete(default, set):Bool;

    public var point:FlxPoint; // The point that will follow the path
    public var traversalMode(default, null):TraversalMode;

    private var path:Array<FlxPoint>; // Path data
    private var pathIndex(default, set):Int;

    public function new() {
        super();

        rate = 0;
        active = false;
        complete = false;

        point = null;
        path = null;
        pathIndex = 0; // Note must come before setting of traversalMode due to setters
        traversalMode = FORWARD;
    }

    public function init(point:FlxPoint, path:Array<FlxPoint>, rate:Float, ?mode:TraversalMode):ConstantRatePath {
        if (mode == null) {
            mode = FORWARD;
        }
        this.point = point;
        this.path = path;
        this.rate = rate;
        this.traversalMode = mode;

        reset();

        return this;
    }

    public function start():Void {
        Sure.sure(!complete);
        Sure.sure(!active);

        active = true;
        signal_started.dispatch();
    }

    public function reset():ConstantRatePath {
        switch(traversalMode) {
            case BACKWARD:
                pathIndex = path.length - 1;
            case FORWARD:
                pathIndex = 0;
        }

        complete = false;
        active = false;

        return this;
    }

    public function cancel():Void {
        if (!complete) {
            reset();
            signal_cancelled.dispatch();
        }
    }

    public function update(dt:Float):Void {
        if (point == null || path == null) {
            return;
        }

        if (!active) {
            return;
        }

        // Decide what the next target point is
        var current:FlxPoint = path[pathIndex];
        var xDistance:Float = current.x - point.x;
        var yDistance:Float = current.y - point.y;

        if (Math.sqrt(xDistance * xDistance + yDistance * yDistance) < rate * dt) {
            current = advancePath(CONTINUOUS);
        }

        if (rate == 0) {
            return;
        }

        // Move the point
        if (!current.equals(point)) {
            moveTowardsTarget(point, current, rate, dt, signal_updated);
        }
    }

    private static inline function moveTowardsTarget(point:FlxPoint, target:FlxPoint, speed:Float, dt:Float, ?signal:Signal2<Float, Float>):Void {
        var dx:Float;
        var dy:Float;

        // Calculate position deltas
        if (point.x < target.x) {
            dx = dt * speed;
        } else if (point.x > target.x) {
            dx = -dt * speed;
        } else {
            dx = 0;
        }

        if (point.y < target.y) {
            dy = dt * speed;
        } else if (point.y > target.y) {
            dy = -dt * speed;
        } else {
            dy = 0;
        }

        // Calculate actual distance from target
        var xDistance = Math.abs(point.x - target.x);
        var yDistance = Math.abs(point.y - target.y);

        // If greater than one step distance then move towards target, else stop at target
        if (xDistance > dt * speed) {
            point.x += dx;
        } else {
            point.x = target.x;
        }

        if (yDistance > dt * speed) {
            point.y += dy;
        } else {
            point.y = target.y;
        }

        if(signal != null) {
            signal.dispatch(dx, dy);
        }
    }

    private function advancePath(mode:AdvanceMode):FlxPoint {
        if (mode == SNAP_TO_NEAREST) {
            var node:FlxPoint = path[pathIndex];
            point.copyFrom(node);
        }

        switch(traversalMode) {
            case BACKWARD:
                pathIndex -= 1;
            case FORWARD:
                pathIndex += 1;
        }

        return path[pathIndex];
    }

    public function add(x:Float, y:Float):ConstantRatePath {
        path.push(FlxPoint.get(x, y));
        return this;
    }

    public function insert(x:Float, y:Float, index:Int):ConstantRatePath {
        path.insert(index, FlxPoint.get(x, y));
        return this;
    }

    private function set_complete(complete:Bool):Bool {
        if (complete) {
            active = false;
        }

        if (this.complete && !complete) {
            return this.complete = complete;
        }

        if (!this.complete && complete) {
            this.complete = true;
            signal_completed.dispatch();
        } else {
            this.complete = complete;
        }

        return this.complete;
    }

    private function set_pathIndex(index:Int):Int {
        if (traversalMode == null) {
            return this.pathIndex = index; // Early return if initializing still
        }

        var setComplete:Bool = false;

        switch(traversalMode) {
            case FORWARD:
                if (index >= path.length) {
                    setComplete = true;
                }
            case BACKWARD:
                if (index < 0) {
                    setComplete = true;
                }
            default:
        }

        this.pathIndex = index.clamp(0, path.length - 1);

        if (setComplete) {
            complete = true;
        }

        return pathIndex;
    }

    private function set_active(active:Bool):Bool {
        if (active != this.active) {
            this.active = active;
            signal_activeToggled.dispatch(active);
        }

        return this.active = active;
    }

    public function destroy():Void {
        FlxDestroyUtil.putArray(path);
        path = null;
        point = null;
        traversalMode = null;
        signal_activeToggled = null;
        signal_started = null;
        signal_cancelled = null;
        signal_updated = null;
        signal_completed = null;
    }

    #if debug
    override public function draw(camera:FlxCamera):Void {
        Sure.sure(camera != null);

        if (path == null) {
            return;
        }

        super.draw(camera);

        if (path.length == 0) {
            return;
        }

        #if FLX_RENDER_BLIT
        var g:Graphics = FlxSpriteUtil.flashGfx;
        g.clear();
        #else
        var g:Graphics = camera.debugLayer.graphics;
        #end

        var idx:Int = 0;
        var len:Int = path.length;
        while (idx < len) {
            var node:FlxPoint = path[idx];
            var x = node.x - camera.scroll.x;
            var y = node.y - camera.scroll.y;

            // Decide what color this node should be
            var nodeSize:Int = 8;
            if ((idx == 0) || (idx == len - 1)) {
                nodeSize *= 2;
            }

            var nodeColor:FlxColor = debugColor;
            if (len > 1) {
                if (idx == 0) {
                    nodeColor = FlxColor.GREEN;
                } else if (idx == len - 1) {
                    nodeColor = FlxColor.RED;
                }
            }

            // Draw a box for the node
            g.beginFill(nodeColor);
            g.lineStyle();
            g.drawRect(x - nodeSize * 0.5, y - nodeSize * 0.5, nodeSize, nodeSize);
            g.endFill();

            // Get the next node
            var nextNode:FlxPoint;
            var lineAlpha:Float = 1.0;
            if (idx < len - 1) {
                nextNode = path[idx + 1];
            } else {
                nextNode = path[idx];
            }

            // Draw a line to the next node
            g.moveTo(x, y);
            g.lineStyle(2, debugColor, lineAlpha);
            x = nextNode.x - camera.scroll.x;
            y = nextNode.y - camera.scroll.y;
            g.lineTo(x, y);

            idx++;
        }

        // Draw the point itself
        var pointSize:Int = 8;
        g.moveTo(point.x, point.y);
        g.beginFill(debugColor.getComplementHarmony());
        g.lineStyle();
        var x:Float = point.x - pointSize * 0.5 - camera.scroll.x;
        var y:Float = point.y - pointSize * 0.5 - camera.scroll.y;
        g.drawRect(x, y, pointSize, pointSize);
        g.endFill();

        #if FLX_RENDER_BLIT
        camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
        #end
    }
    #end
}