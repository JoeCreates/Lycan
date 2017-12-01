package lycan.world;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2World;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Box2D {	
	public static var world:B2World;
	
	/** Iterations for resolving velocity (default 10) */
	public static var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public static var positionIterations:Int = 10;
	/** Whether debug graphics are enabled */
	public static var drawDebug(default, set):Bool = false;
	/** Force a fixed timestep for integrator. Null means use FlxG.elapsed */
	public static var forceTimestep:Null<Float> = null;
	/** Scale factor for mapping pixel coordinates to Box2D coordinates */
	public static var pixelsPerMeter:Float = 30;
	/** Whether to enable debug mouse-based item manipulation */
	public static var debugManipulation:Bool;
	
	#if !FLX_NO_DEBUG
	private static var drawDebugButton:FlxSystemButton;
	public static var debugSprite(default, null):Sprite;
	public static var debugRenderer(default, null):B2DebugDraw;
	#end
	
	/** Helper vec2 to reduce object instantiation */
	private static var _vec2:B2Vec2 = new B2Vec2();
	private static function vec2(x:Float, y:Float):B2Vec2 {
		_vec2.set(x, y);
		return _vec2;
	}
	
	public static function init():Void {
		if (world != null) return;
		
		world = new B2World(new B2Vec2(0, 3), true);
		
		FlxG.signals.postUpdate.add(update);
		FlxG.signals.postUpdate.add(draw);
		
		setupdebugRenderer();
	}
	
	public static function destroy():Void {
		world = null;
		
		#if !FLX_NO_DEBUG
		debugSprite = null;
		debugRenderer = null;
		#end
		
		FlxG.signals.postUpdate.remove(update);
		FlxG.signals.postUpdate.remove(draw);
	}
	
	public static function createRectangularShape(pixelWidth:Float, pixelHeight:Float, pixelPositionX:Float = 0, pixelPositionY:Float = 0):B2PolygonShape {
		var rect = new B2PolygonShape();
		rect.setAsOrientedBox(pixelWidth / Box2D.pixelsPerMeter * 0.5, pixelHeight / Box2D.pixelsPerMeter * 0.5, vec2(pixelPositionX / Box2D.pixelsPerMeter, pixelPositionY / Box2D.pixelsPerMeter));
		return rect;
	}
	
	public static function createCircleShape(pixelRadius:Float, pixelPositionX:Float = 0, pixelPositionY:Float = 0):B2CircleShape {
		var circle = new B2CircleShape(pixelRadius / Box2D.pixelsPerMeter);
		circle.setLocalPosition(vec2(pixelPositionX / Box2D.pixelsPerMeter, pixelPositionY / Box2D.pixelsPerMeter));
		return circle;
	}
	
	private static function setupdebugRenderer():Void {
		#if !FLX_NO_DEBUG
		
		// Skip if we have already initialised debug drawing
		if (debugRenderer != null) return;
		
		// Create sprite and debug renderer
		debugRenderer = new B2DebugDraw();
		debugSprite = new Sprite();
		
		// Set up debug renderer
		debugRenderer.setSprite(debugSprite);
		debugRenderer.setDrawScale(30.0);
		debugRenderer.setFillAlpha(0.3);
		debugRenderer.setLineThickness(1.5);
		debugRenderer.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
	
		// Add a button to toggle debug shapes to the debugger
		var icon:BitmapData = new BitmapData(11, 11, true, 0);
		var text:TextField = new TextField();
		text.text = "B2";
		text.embedFonts = true;
		text.setTextFormat(new TextFormat(FlxAssets.FONT_DEFAULT, 8, FlxColor.WHITE, false));
		var mat = new Matrix();
		mat.translate(-2, -1);
		icon.draw(text, mat);
		drawDebugButton = FlxG.debugger.addButton(RIGHT, icon, function() {
			drawDebug = !drawDebug;
		}, true, true);
		
		drawDebug = false;
		
		#end
	}

	/**
	 * Creates simple walls around the game area - useful for prototying.
	 *
	 * @param   minX        The smallest X value of your level (usually 0).
	 * @param   minY        The smallest Y value of your level (usually 0).
	 * @param   maxX        The largest X value of your level - 0 means FlxG.width (usually the level width).
	 * @param   maxY        The largest Y value of your level - 0 means FlxG.height (usually the level height).
	 * @param   thickness   How thick the walls are. 10 by default.
	 * @param   material    The Material to use for the physics body of the walls.
	 */
	public static function createWalls(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0, thickness:Float = 10):B2Body {
		return null;// TODO
	}

	private static function set_drawDebug(drawDebug:Bool):Bool {
		if (drawDebug == Box2D.drawDebug) return drawDebug;
		
		#if !FLX_NO_DEBUG
			if (drawDebug) {
				world.setDebugDraw(debugRenderer);
				FlxG.addChildBelowMouse(debugSprite);
			} else {
				world.setDebugDraw(null);
				FlxG.removeChild(debugSprite);
			}
			
			if (drawDebugButton != null) drawDebugButton.toggled = !drawDebug;
		#end
		
		return Box2D.drawDebug = drawDebug;
	}

	public static function update():Void {
		if (world != null && FlxG.elapsed > 0) {
			world.step(forceTimestep == null ? FlxG.elapsed : forceTimestep, velocityIterations, positionIterations);
		}
	}

	public static function draw():Void {
		#if !FLX_NO_DEBUG
		if (world == null || !drawDebug) return;
		
		// TODO
		var zoom = FlxG.camera.zoom;
		var sprite = debugSprite;
		sprite.scaleX = zoom;
		sprite.scaleY = zoom;
		sprite.x = -FlxG.camera.scroll.x * zoom;
		sprite.y = -FlxG.camera.scroll.y * zoom;
		
		world.drawDebugData();
		
		#end
	}
}