package lycan.util.paths;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import openfl.display.Graphics;

using lycan.util.BitSet;

// TODO make easier ways to yoyo, loop etc
enum TraversalMode {
	FORWARD;
	BACKWARD;
}

enum AdvanceMode {
	CONTINUOUS;
	SNAP_TO_NEAREST;
}

// Moves a point along an array of 2D points in a linear fashion at a given rate, traversing at most one point per update
class ConstantRatePath extends BasePath {
	public var signal_pauseToggled = new Signal2<BasePath, Bool>();
	public var signal_cancelled = new Signal1<BasePath>();
	public var signal_complete = new Signal1<BasePath>();
	
	public var rate:Float;
	public var active(default, set):Bool;
	//public var bearing(default, null):Float; // Angle in degrees between current and next point in the path // TODO
	public var complete(default, set):Bool;
	
	public var point:FlxPoint; // The point that will follow the path
	public var offset:FlxPoint; // TODO
	public var path:Array<FlxPoint>; // Path data
	public var pathIndex(default, set):Int;
	public var traversalMode(default, set):TraversalMode;
	
	#if debug
	public var debugColor:FlxColor;
	public var debugScrollX:Float;
	public var debugScrollY:Float;
	public var drawDebug:Bool;
	#end
	
	public function new() {
		rate = 0;
		active = false;
		complete = false;
		
		point = null;
		offset = null;
		path = null;
		pathIndex = 0;
		traversalMode = FORWARD;
		
		#if debug
		debugColor = 0xFF00FF;
		debugScrollX = 1.0;
		debugScrollY = 1.0;
		drawDebug = true;
		#end
	}
	
	public function init(point:FlxPoint, path:Array<FlxPoint>, rate:Float = 100, ?mode:TraversalMode, ?offset:FlxPoint):ConstantRatePath {
		if (mode == null) {
			mode = FORWARD;
		}
		if (offset == null) {
			offset = FlxPoint.get();
		}
		this.point = point;
		this.offset = offset;
		this.path = path;
		this.rate = rate;
		this.traversalMode = mode;
		
		reset();
		
		return this;
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
			signal_cancelled.dispatch(this);
		}
	}
	
	public function update(dt:Float):Void {
		Sure.sure(point != null);
		Sure.sure(path != null);
		
		if (complete) {
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
		// TODO add different techniques for doing this
		if (!current.equals(point)) {
			moveTowardsTarget(point, current, offset, rate, dt);
		}
	}
	
	private static inline function moveTowardsTarget(point:FlxPoint, target:FlxPoint, offset:FlxPoint, speed:Float, dt:Float):Void {
		// TODO avoid jittering on x/y. Use velocity?
		
		var dx:Float;
		var dy:Float;
		
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
		
		point.add(dx, dy);
	}
	
	private function advancePath(mode:AdvanceMode):FlxPoint {
		if (mode == SNAP_TO_NEAREST) {
			var node:FlxPoint = path[pathIndex];
			point.copyFrom(node).addPoint(offset);
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
			return complete;
		}
		
		if (!this.complete && complete) {
			this.complete = true;
			signal_complete.dispatch(this);
		}
		
		return this.complete = complete;
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
		
		// TODO
		this.pathIndex = cast Math.max(0.0, cast Math.min(cast index, cast path.length - 1));
		
		if (setComplete) {
			complete = true;
		}
		
		return pathIndex;
	}
	
	private function set_active(active:Bool):Bool {
		if (active != this.active) {
			this.active = active;
			signal_pauseToggled.dispatch(this, active);
		}
		
		return this.active = active;
	}
	
	public function destroy():Void {
		FlxDestroyUtil.putArray(path);
		path = null;
		point = null;
		offset = null;
		traversalMode = null;
		signal_pauseToggled = null;
		signal_cancelled = null;
		signal_complete = null;
	}
	
	#if debug
	override public function draw(camera:FlxCamera):Void {
		Sure.sure(camera != null);
		Sure.sure(path != null);
		
		if (path.length == 0) {
			return;
		}
		
		#if FLX_RENDER_BLIT
		var g:Graphics = FlxSpriteUtil.flashGfx;
		g.clear();
		#else
		var g:Graphics = camera.debugLayer.graphics;
		#end

		var node:FlxPoint;
		var nextNode:FlxPoint;
		var idx:Int = 0;
		var len:Int = path.length;
		while (idx < len) {
			node = path[idx];
			var x = node.x - camera.scroll.x * debugScrollX;
			var y = node.y - camera.scroll.y * debugScrollY;
			
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
			g.beginFill(nodeColor, 0.5);
			g.lineStyle();
			g.drawRect(x - nodeSize * 0.5, y - nodeSize * 0.5, nodeSize, nodeSize);
			g.endFill();

			// Then find the next node in the path
			var lineAlpha:Float = 0.8;
			if (idx < len - 1) {
				nextNode = path[idx + 1];
			} else {
				nextNode = path[idx];
			}
			
			// Then draw a line to the next node
			g.moveTo(x, y);
			g.lineStyle(1, debugColor, lineAlpha);
			x = nextNode.x - camera.scroll.x * debugScrollX;
			y = nextNode.y - camera.scroll.y * debugScrollY;
			g.lineTo(x, y);
			
			idx++;
		}
		
		// Draw the point itself
		var pointSize:Int = 8;
		g.moveTo(point.x, point.y);
		g.beginFill(debugColor.getComplementHarmony(), 0.5);
		g.lineStyle();
		g.drawRect(point.x - pointSize * 0.5, point.y - pointSize * 0.5, pointSize, pointSize);
		g.endFill();
		
		#if FLX_RENDER_BLIT
		camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		#end
	}
	#end
}