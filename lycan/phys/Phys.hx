package lycan.phys;

import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import lime.math.Rectangle;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import box2D.dynamics.B2BodyType;

/**
 * Box2D debugging utility, lets you drag world bodies around with the mouse/manipulate with keyboard.
 */
class Box2DInteractiveDebug {
	private static var _aabb:B2AABB = new B2AABB();
	private static var _mouseJointDef:B2MouseJointDef = new B2MouseJointDef();
	
	public var mouseJoint:B2MouseJoint = null;
	public var mouseX(get, never):Float;
	public var mouseY(get, never):Float;
	public var physicsMouseX(get, never):Float;
	public var physicsMouseY(get, never):Float;
	
	public function new() {
	}
	
	public function update():Void {
		handleMouse();
		handleKeys();
	}
	
	public function getBodyAtMouse():B2Body {
		// Make a small box around the mouse position
		var mousePVec = vec2(physicsMouseX, physicsMouseY);
		_aabb.lowerBound.set(physicsMouseX - 0.001, physicsMouseY - 0.001);
		_aabb.upperBound.set(physicsMouseX + 0.001, physicsMouseY + 0.001);
		var body:B2Body = null;
		
		// Query the world for overlapping shapes
		var getBodyCallback = function(fixture:B2Fixture):Bool {
			var shape:B2Shape = fixture.getShape();
			if (shape.testPoint(fixture.getBody().getTransform(), mousePVec)) {
				body = fixture.getBody();
				return false;
			}
			return true;
		}
		Phys.world.queryAABB(getBodyCallback, _aabb);
		return body;
	}
	
	public function handleMouse():Void {
		if (mouseJoint == null) {
			if (FlxG.mouse.justPressed) {
				var bodyAtMouse = getBodyAtMouse();
				if (bodyAtMouse != null) {
					_mouseJointDef.bodyA = Phys.world.getGroundBody();
					_mouseJointDef.bodyB = bodyAtMouse;
					_mouseJointDef.target.set(physicsMouseX, physicsMouseY);
					_mouseJointDef.collideConnected = true;
					_mouseJointDef.maxForce = 300 * bodyAtMouse.getMass();
					mouseJoint = cast Phys.world.createJoint(_mouseJointDef);
					
					bodyAtMouse.setAwake(true);
				}
			}
		} else {
			if (!FlxG.mouse.pressed) {
				Phys.world.destroyJoint(mouseJoint);
				mouseJoint = null;
			} else if (FlxG.mouse.justMoved) {
				mouseJoint.setTarget(vec2(physicsMouseX, physicsMouseY));
			}
		}
	}
	
	public function handleKeys():Void {

	}
	
	private function get_mouseX():Float {
		return FlxG.mouse.x;
	}
	private function get_mouseY():Float {
		return FlxG.mouse.y;
	}
	private function get_physicsMouseX():Float {
		return mouseX / Phys.pixelsPerMeter;
	}
	private function get_physicsMouseY():Float {
		return mouseY / Phys.pixelsPerMeter;
	}
	
	/** Helpers to reduce object instantiation */
	private static var _vec2:B2Vec2 = new B2Vec2();
	private static function vec2(x:Float, y:Float):B2Vec2 {
		_vec2.set(x, y);
		return _vec2;
	}
}

class Phys {
	public static var world:B2World;
	
	/** Iterations for resolving velocity (default 10) */
	public static var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public static var positionIterations:Int = 10;
	/** Whether debug graphics are enabled */
	public static var drawDebug(default, set):Null<Bool> = null;
	/** Force a fixed timestep for integrator. Null means use FlxG.elapsed */
	public static var forceTimestep:Null<Float> = null;
	/** Scale factor for mapping pixel coordinates to Box2D coordinates */
	public static var pixelsPerMeter(default, set):Float = 30;
	/** Minimum size of shape in Box2D space (in meters), lower than this will result in warnings */
	public static var minimumSize:Float = 0.1;
	/** Optional debug mouse/keyboard-based body manipulator */
	public static var debugManipulator:Box2DInteractiveDebug = null;
	
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
		
		setupDebugDrawing();
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
		
		var width = pixelWidth / Phys.pixelsPerMeter;
		var height = pixelHeight / Phys.pixelsPerMeter;

		if (width < minimumSize || height < minimumSize) {
			printSizeWarning();
		}
		
		rect.setAsOrientedBox(width * 0.5, height * 0.5, vec2(pixelPositionX / Phys.pixelsPerMeter, pixelPositionY / Phys.pixelsPerMeter));
		return rect;
	}
	
	public static function createCircleShape(pixelRadius:Float, pixelPositionX:Float = 0, pixelPositionY:Float = 0):B2CircleShape {
		var radius = pixelRadius / Phys.pixelsPerMeter;
		var circle = new B2CircleShape(radius);
		
		if (radius * 2 < minimumSize) {
			printSizeWarning();
		}
		
		circle.setLocalPosition(vec2(pixelPositionX / Phys.pixelsPerMeter, pixelPositionY / Phys.pixelsPerMeter));
		return circle;
	}
	
	private static function printSizeWarning():Void {
		#if !FLX_NO_DEBUG
		trace("Shape is smaller than minimum recommended Box2D size");
		#end
	}
	
	private static function setupDebugDrawing():Void {
		#if !FLX_NO_DEBUG
		
		// Skip if we have already initialised debug drawing
		if (debugRenderer != null) return;
		
		// Create sprite and debug renderer
		debugRenderer = new B2DebugDraw();
		debugSprite = new Sprite();
		
		// Set up debug renderer
		debugRenderer.setSprite(debugSprite);
		debugRenderer.setDrawScale(pixelsPerMeter);//TODO
		debugRenderer.setFillAlpha(0.3);
		debugRenderer.setLineThickness(1.5);
		debugRenderer.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
	
		addDebugButton();
		
		drawDebug = false;
		
		#end
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Adds a button to toggle debug shapes to the debugger.
	 */
	private static function addDebugButton():Void {
		if (drawDebugButton != null) {
			return;
		}
		
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
	}
	#end

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
	public static function createWalls(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0, thickness:Float = 50):B2Body {
		var bd = new B2BodyDef();
		bd.type = B2BodyType.STATIC_BODY;
		bd.position.set(minX / Phys.pixelsPerMeter, minY / Phys.pixelsPerMeter);
		bd.userData = null;
		bd.bullet = false;
		var body = Phys.world.createBody(bd);
		
		inline function addRect(x:Float, y:Float, width:Float, height:Float) {
			body.createFixture2(createRectangularShape(width, height, x + width / 2, y + height / 2));
		}
		
		addRect(minX - thickness, minY - thickness, maxX - minX + thickness * 2, thickness);
		addRect(minX - thickness, maxY, maxX - minX + thickness * 2, thickness);
		addRect(minX - thickness, minY, thickness, maxY - minY);
		addRect(maxX, minY, thickness, maxY - minY);
		
		return body;
	}

	private static function set_drawDebug(drawDebug:Bool):Bool {
		if (drawDebug == Phys.drawDebug) return drawDebug;
		
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
		
		return Phys.drawDebug = drawDebug;
	}

	public static function update():Void {
		if (world != null && FlxG.elapsed > 0) {
			if (debugManipulator != null) {
				debugManipulator.update();
			}
			
			world.step(forceTimestep == null ? FlxG.elapsed : forceTimestep, velocityIterations, positionIterations);
		}
	}
	
	@:access(flixel.FlxCamera)
	public static function draw():Void {
		#if !FLX_NO_DEBUG
		if (world == null || !drawDebug) return;
		
		world.drawDebugData();
		
		var sprite = debugSprite;
		sprite.scaleX = 1;
		sprite.scaleY = 1;
		sprite.x = 0;
		sprite.y = 0;
		
		FlxG.camera.transformObject(sprite);
		#end
	}
	
	private static function set_pixelsPerMeter(pixels:Float):Float {
		Phys.pixelsPerMeter = pixels;
		#if debug
			if (debugRenderer != null) {
				debugRenderer.setDrawScale(pixels);
			}
		#end
		return pixels;
	}
}