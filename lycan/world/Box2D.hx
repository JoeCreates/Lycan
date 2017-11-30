package lycan.world;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
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

#if !FLX_NO_DEBUG

#end
class Box2D {	
	public var world:B2World;
	
	/** Iterations for resolving velocity (default 10) */
	public var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public var positionIterations:Int = 10;
	
	/**
	 * Whether or not the nape debug graphics are enabled.
	 */
	public static var drawDebug(default, set):Bool;

	#if !FLX_NO_DEBUG
	private static var drawDebugButton:FlxSystemButton;
	public static var debugSprite(default, null):Sprite;
	public static var debugDraw(default, null):B2DebugDraw;
	#end

	public function new() {
		world = new B2World(new B2Vec2(0, 10), true);
		
		FlxG.signals.postUpdate.add(update);
		FlxG.signals.postUpdate.add(draw);
		
		#if !FLX_NO_DEBUG
		setupDebugDrawing();
		#end
	}
	
	public function destroy():Void {
		FlxG.signals.postUpdate.remove(update);
		FlxG.signals.postUpdate.remove(draw);
	}
	
	#if !FLX_NO_DEBUG
	private function setupDebugDrawing():Void {
		debugDraw = new B2DebugDraw();
		debugSprite = new Sprite();
		debugDraw.setSprite(debugSprite);
		debugDraw.setDrawScale(30.0); // TODO
		debugDraw.setFillAlpha(0.3);
		debugDraw.setLineThickness(1.0);
		debugDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
		world.setDebugDraw(debugDraw);
	
		// Add a button to toggle debug shapes to the debugger
		// TODO could do box2d icon instead of the Nape one
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
	public function createWalls(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0, thickness:Float = 10):B2Body {
		//if (maxX == 0) {
			//maxX = FlxG.width;
		//}
//
		//if (maxY == 0) {
			//maxY = FlxG.height;
		//}
//
		//if (material == null) {
			//material = new Material(0.4, 0.2, 0.38, 0.7);
		//}
//
		var walls:B2Body = world.createBody(new B2BodyDef());
//
		//// Left wall
		//walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, minY, thickness, maxY + Math.abs(minY))));
		//// Right wall
		//walls.shapes.add(new Polygon(Polygon.rect(maxX, minY, thickness, maxY + Math.abs(minY))));
		//// Upper wall
		//walls.shapes.add(new Polygon(Polygon.rect(minX, minY - thickness, maxX + Math.abs(minX), thickness)));
		//// Bottom wall
		//walls.shapes.add(new Polygon(Polygon.rect(minX, maxY, maxX + Math.abs(minX), thickness)));
//
		//walls.space = world;
		//walls.setShapeMaterials(material);
//
		return walls;
	}

	private static function set_drawDebug(drawDebug:Bool):Bool {
		#if !FLX_NO_DEBUG
		if (drawDebug == Box2D.drawDebug) {
			return Box2D.drawDebug;
		}
		
		if (drawDebug) {
			FlxG.addChildBelowMouse(debugSprite);
		} else {
			FlxG.removeChild(debugSprite);
		}
		
		if (drawDebugButton != null) drawDebugButton.toggled = !drawDebug;

		#end
		
		return Box2D.drawDebug = drawDebug;
	}

	public function update():Void {
		if (world != null && FlxG.elapsed > 0) {
			world.step(FlxG.elapsed, velocityIterations, positionIterations);
		}
	}

	public function draw():Void {
		#if !FLX_NO_DEBUG
		if (world == null || !drawDebug) {
			return;
		}
		
		world.drawDebugData();
		
		//var zoom = FlxG.camera.zoom;
		//var sprite = shapeDebug.display;
		//sprite.scaleX = zoom;
		//sprite.scaleY = zoom;
		//sprite.x = -FlxG.camera.scroll.x * zoom;
		//sprite.y = -FlxG.camera.scroll.y * zoom;
		#end
	}
}