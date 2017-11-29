package lycan.world;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2World;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if !FLX_NO_DEBUG

#end
class Box2D {
	
	@:isVar public static var get(get, never):Box2D;
	private static function get_get():Box2D return get == null ? new Box2D() : get;
	
	public var world:B2World;
	
	/** Iterations for resolving velocity (default 10) */
	public var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public var positionIterations:Int = 10;

	/**
	 * Whether or not the nape debug graphics are enabled.
	 */
	public var drawDebug(default, set):Bool;

	#if !FLX_NO_DEBUG
		/**
		 * A useful "canvas" which can be used to draw debug information on.
		 * To get a better idea of its use, see the official Nape demo 'SpatialQueries'
		 * (http://napephys.com/samples.html#swf-SpatialQueries)
		 * where this is used to draw lines emitted from Rays.
		 * A sensible place to use this would be the state's draw() method.
		 * Note that shapeDebug is null if drawDebug is false.
		 */
		//public var shapeDebug(default, null):ShapeDebug;
		private var drawDebugButton:FlxSystemButton;
	#end

	public function new() {
		world = new B2World(new B2Vec2(0, 10), true);
		
		FlxG.signals.postUpdate.add(update);
		FlxG.signals.postUpdate.add(draw);
		FlxG.signals.stateSwitched.add(onStateSwitch);
		
		#if !FLX_NO_DEBUG
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

	private function set_drawDebug(drawDebug:Bool):Bool {
		//#if !FLX_NO_DEBUG
		//if (drawDebugButton != null)
			//drawDebugButton.toggled = !drawDebug;
//
		//if (drawDebug) {
			//if (shapeDebug == null) {
				//shapeDebug = new ShapeDebug(FlxG.width, FlxG.height);
				//shapeDebug.drawConstraints = true;
				//shapeDebug.display.scrollRect = null;
				//shapeDebug.thickness = 1;
				//FlxG.addChildBelowMouse(shapeDebug.display);
			//}
		//} else if (shapeDebug != null) {
			//FlxG.removeChild(shapeDebug.display);
			//shapeDebug = null;
		//}
		//#end
//
		return drawDebug = this.drawDebug;
	}

	private function onStateSwitch():Void {
		//if (world != null) {
			//world.clear();
			//world = null; // resets atributes like gravity.
		//}
//
		//#if !FLX_NO_DEBUG
		//drawDebug = false;
//
		//if (drawDebugButton != null) {
			//FlxG.debugger.removeButton(drawDebugButton);
			//drawDebugButton = null;
		//}
		//#end
	}

	public function update():Void {
		//if (world != null && FlxG.elapsed > 0) {
			//world.step(FlxG.elapsed, velocityIterations, positionIterations);
		//}
	}

	public function draw():Void {
		//#if !FLX_NO_DEBUG
		//if (shapeDebug == null || world == null) {
			//return;
		//}
//
		//shapeDebug.clear();
		//shapeDebug.draw(world);
//
		//var zoom = FlxG.camera.zoom;
		//var sprite = shapeDebug.display;
//
		//sprite.scaleX = zoom;
		//sprite.scaleY = zoom;
//
		//sprite.x = -FlxG.camera.scroll.x * zoom;
		//sprite.y = -FlxG.camera.scroll.y * zoom;
		//#end
	}
}