package lycan.effects;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.addons.display.shapes.FlxShapeLightning;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPool;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.util.helpers.FlxRange;
import haxe.ds.Vector;
import lycan.states.LycanState;
import flixel.group.FlxGroup;
import flash.geom.ColorTransform;
import flixel.util.FlxDestroyUtil;
import flixel.FlxBasic;
import flixel.FlxG;

// Some good settings
		// lightning = new Lightning(0.4);
		// lightning.displaceTime.set(0.7, 1.2);
		// lightning.detail = 0.25;
		// lightning.thickness = 4;
		// lightning.lightningType = LightningType.CONTINUOUS;
		// lightning.startPoint.set(FlxG.width / 2, FlxG.height / 2);
		// lightning.endPoint.set(FlxG.width / 2 + 100, FlxG.height / 2);
		// lightning.generate();

		
		// add(zone);
		// zone.add(lightning);
		
		// for (i in 0...2) {
		// 	lightning = new Lightning(0.4);
		// 	lightning.displaceTime.set(0.7, 1.2);
		// 	lightning.regenerateDistance = 30;
		// 	lightning.detail = 0.25;
		// 	lightning.thickness = 1;
		// 	lightning.lightningType = LightningType.CONTINUOUS;
		// 	lightning.startPoint.set(FlxG.width / 2, FlxG.height / 2);
		// 	lightning.endPoint.set(FlxG.width / 2 + 100, FlxG.height / 2);
		// 	lightning.generate();
		// 	zone.add(lightning);
		// }

// TODO
// detail should be with respect to distance
// Forking
@:tink class Lightning extends FlxBasic {
	public var life:Float;
	public var lifeTime:Float;
	
	/**
	 *  How detailed the lightning is in segments per pixel between the start and end points.
	 *  A value of 1 means create 1 segment per pixel (very detailed)
	 *  A value of 0.1 means create 1 point per 10 pixels (less detailed)
	 */
	public var detail:Float;
	/**
	 *  How much the lightning can arc out sideways.
	 *  A value of 0 means the lightning is completely straight.
	 *  A value of 1 means the lightning can be as wide as it is long
	 */
	public var displacementPerPixel:Float;
	public var thickness:Float;
	public var endThickness:Null<Float>;
	public var color:FlxColor;
	public var endColor:Null<FlxColor>;
	public var displaceTime:FlxRange<Float>;
	public var lightningType:LightningType;
	public var startPoint:LightningPoint;
	public var endPoint:LightningPoint;
	public var fades:Bool;
	
	/** Whether the lightning displacement evolves over time. Control with displaceTime. */
	public var evolves:Bool = true;
	/** Whether the lightning should flicker */
	public var flickers:Bool = true;
	/** Whether the lightning should flicker */
	public var regenerates:Bool = true;

	/** The distance an end point can move before the lightning regenerates. Null prevents this regeneration. */
	public var regenerateDistance:Null<Float>;
	/** Rate at which the lightning flickers off (per second) */
	public var flickerOffPerSecond:Float = 4;
	/** Rate at which the lightning flickers on (per second) */
	public var flickerOnPerSecond:Float = 8;
	/** Rate at which the lightning randomly regenerates (per second) */
	public var regeneratePerSecond:Float = 4;
	
	public var lineCount(default, null):Int;

	@:calculated var length:Float = Math.sqrt(Math.pow(this.startPoint.x - this.endPoint.x, 2) + Math.pow(this.startPoint.y - this.endPoint.y, 2));

	var rootPoint:LightningPoint;

	var startGenX:Float;
	var startGenY:Float;
	var endGenX:Float;
	var endGenY:Float;

	/** Used when drawing to keep track of which point is being drawn from */
	var drawPoint:LightningPoint;
	var drawIndex:Int;
	var lineStyle:LineStyle;
	
	public function new(displacementPerPixel:Float, ?lightningType:LightningType) {
		super();
		
		color = FlxColor.WHITE;
		lifeTime = 0.4;
		life = lifeTime;
		thickness = 3;
		this.lightningType = lightningType == null ? LightningType.FLASH : lightningType;
		fades = true;
		
		detail = 0.5;
		this.displacementPerPixel = displacementPerPixel;
		displaceTime = new FlxRange(0.1, 0.3);
		startPoint = LightningPoint.get();
		endPoint = LightningPoint.get();
		
		lineStyle = {
			thickness: thickness,
			color: FlxColor.WHITE
		}

		regenerateDistance = null;
	}

	override public function revive():Void {
		super.revive();
		life = lifeTime;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (evolves) {
			rootPoint.updateDisplacement(startPoint, endPoint, displacementPerPixel * length, displaceTime.start, displaceTime.end, dt);
		}

		if (lightningType == FLASH) {
			if (life > 0 && lifeTime > 0) {
				life -= dt / lifeTime;
			} else {
				kill();
			}
		}
		
		if (regenerates) {
			// Random regenerations
			if (regeneratePerSecond > 0) {
				if (FlxG.random.float() < regeneratePerSecond * dt) generate();
			}

			// Regenerations based on movement of end points
			if (regenerateDistance != null) {
				inline function checkThreshold(x:Float, y:Float, current:LightningPoint):Bool {
					var distance:Float = Math.sqrt(Math.pow(current.x - x, 2) + Math.pow(current.y - y, 2));
					return distance > regenerateDistance;
				}

				if (checkThreshold(startGenX, startGenY, startPoint) || checkThreshold(endGenX, endGenY, endPoint)) {
					generate();
				}
			}
		}
		
		if (flickers) {
			if (visible) {
				if (FlxG.random.float() < flickerOffPerSecond * dt) visible = false;
			} else {
				if (FlxG.random.float() < flickerOnPerSecond * dt) visible = true;
			}
		}
	}
	
	/**
	 *  Render this lightning to a FlxSprite
	 *  @param   sprite The sprite to render to
	 */
	public function drawTo(sprite:FlxSprite):Void {
		if (rootPoint == null || !visible) return;
		// Begin drawing from the start point
		drawPoint = startPoint;
		drawIndex = 0;
		lineStyle.thickness = thickness;
		lineStyle.color = color;
		FlxSpriteUtil.beginDraw(FlxColor.TRANSPARENT, lineStyle);
		// Traverse the tree leaves from left to right to draw lines
		//var commands = new Vector<Int>();
		//var coords = new Vector<Float>();
		drawLine(rootPoint);
		
		FlxSpriteUtil.endDraw(sprite);
	}
	
	public function generate():Void {
		// If we already have points, pool them
		if (rootPoint != null) {
			rootPoint.put();
		}

		var displacement:Float = displacementPerPixel * length;

		// Create a new structure and obtain a new root point
		rootPoint = split(startPoint, endPoint, displacement, 1 / detail);
		lineCount = rootPoint != null ? rootPoint.decendentCount + 2 : 0;

		// Displace the full structure
		// Using the max displaceTime forces each point to calculate a new displacement value
		if (rootPoint != null) {
			// First time generates new target points, second time moves instantly to new targets
			for (i in 0...2) {
				rootPoint.updateDisplacement(
					startPoint, endPoint,
					displacement, displaceTime.start, displaceTime.end,
					displaceTime.end);
			}
		}

		// Keep record of where the end points were when generated
		startGenX = startPoint.x;
		startGenY = startPoint.y;
		endGenX = endPoint.x;
		endGenY = endPoint.y;
	}
	
	private function split(start:LightningPoint, end:LightningPoint, displacement:Float, detailSize:Float):LightningPoint {
		// Recursively split the lightning until we have the right level of detail
		if (displacement >= detailSize) {
			var mid:LightningPoint = LightningPoint.get((start.x + end.x) / 2, (start.y + end.y) / 2);
			mid.childA = split(start, mid, displacement / 2, detailSize);
			mid.childB = split(mid, end, displacement / 2, detailSize);
			return mid;
		}
		
		return null;
	}

	private function drawLine(point:LightningPoint, leftTurns:Int = 0):Void {
		// This is a recursive left to right tree traversal
		// When we hit a leaf, we record it as the current draw point
		// When we hit the next leaf, we draw a point from the previous point to the new one
		// leftTurns tracks how many times childA is traversed on a path to a node
		// If leftTurns is 0, we are on the right of the tree

		// If there is a left child, follow that branch
		if (point.childA != null) {
			drawLine(point.childA, leftTurns + 1);
		}

		// Prepare lineStyle for drawing line
		var lerpFactor:Float = drawIndex / (lineCount - 1);
		lineStyle.color = endColor != null ? FlxColor.interpolate(color, endColor, lerpFactor) : color;
		if (fades && lightningType == LightningType.FLASH) {
			lineStyle.color.alphaFloat = lineStyle.color.alphaFloat * life;
		}
		lineStyle.thickness = endThickness != null ? flixel.math.FlxMath.lerp(thickness, endThickness, lerpFactor) : thickness;
		
		FlxSpriteUtil.setLineStyle(lineStyle);
		
		// If a drawpoint is set, draw line from it to here
		if (drawPoint != null) {
			FlxSpriteUtil.flashGfx.moveTo(drawPoint.x, drawPoint.y);
			FlxSpriteUtil.flashGfx.lineTo(point.x, point.y);
		}

		drawIndex++;
		
		// Set this point to be the next from which a line will be drawn
		drawPoint = point;
		
		if (point.childB != null) {
			drawLine(point.childB, leftTurns);
		}
		// If leftTurns is 0 and there is no right child, we are on the far right leaf
		// So we must draw the line from this node to the endPoint
		else if (leftTurns == 0) {
			drawLine(endPoint, -1);
		}
	}
}

enum LightningType {
	FLASH;
	CONTINUOUS;
}

class LightningPoint implements IFlxPooled {
	public static var pool(get, never):IFlxPool<LightningPoint>;
	private static var _pool = new FlxPool<LightningPoint>(LightningPoint);
	private static function get_pool():IFlxPool<LightningPoint> {
		return _pool;
	}
	
	public static inline function get(x:Float = 0, y:Float = 0):LightningPoint{
		var point = _pool.get();
		point.x = x;
		point.y = y;
		point._inPool = false;
		point.displacementX = 0;
		point.displacementY = 0;
		point.targetDisplacementX = 0;
		point.targetDisplacementY = 0;
		point.displacementProgress = 0;
		point.childA = null;
		point.childB = null;
		point.timeUntilDisplaced = 0;
		return point;
	}
	
	/** Time until it reaches next displacement */
	public var timeUntilDisplaced:Float;
	public var displacementProgress:Float;
	public var displacementX:Float;
	public var displacementY:Float;
	public var targetDisplacementX:Float;
	public var targetDisplacementY:Float;
	public var childA:LightningPoint;
	public var childB:LightningPoint;
	public var x:Float;
	public var y:Float;
	public var thickness:Float;

	public var decendentCount(get, never):Int;
	
	private var _inPool:Bool = false;

	public function new(x:Float, y:Float) {
		set(x, y);
	}

	public function destroy():Void {}
	
	public function set(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
	
	private function get_decendentCount():Int {
		return (childA != null ? childA.decendentCount + 1 : 0) + (childB != null ? childB.decendentCount + 1 : 0);
	}

	public function updateDisplacement(start:LightningPoint, end:LightningPoint, displacement:Float,
		minDisplaceTime:Float, maxDisplaceTime:Float, dt:Float):Void
	{
		// Update this point
		if (timeUntilDisplaced > 0) {
			displacementProgress += dt / timeUntilDisplaced;
		} else {
			displacementProgress = 1;
		}
		
		if (displacementProgress >= 1) {
			// Calculate a new displacement time
			timeUntilDisplaced = FlxG.random.float(minDisplaceTime, maxDisplaceTime);
			displacementProgress = 0;
			// Calculate a new displacement
			displacementX = targetDisplacementX;
			displacementY = targetDisplacementY;
			targetDisplacementX = FlxG.random.float(-0.5, 0.5) * displacement;
			targetDisplacementY = FlxG.random.float(-0.5, 0.5) * displacement;
		}
		
		// Update position
		var t = FlxEase.quadInOut(displacementProgress);
		x = (start.x + end.x) / 2 + t * targetDisplacementX + (1 - t) * displacementX;
		y = (start.y + end.y) / 2 + t * targetDisplacementY + (1 - t) * displacementY;
		
		// Update children
		if (childA != null) childA.updateDisplacement(start, this, displacement / 2, minDisplaceTime / 2, maxDisplaceTime / 2, dt);
		if (childB != null) childB.updateDisplacement(this, end, displacement / 2, minDisplaceTime / 2, maxDisplaceTime / 2, dt);
	}
	
	public function put():Void {
		if (!_inPool) {
			if (childA != null) childA.put();
			if (childB != null) childB.put();
			_inPool = true;
			_pool.putUnsafe(this);
		}
	}
}