package lycan.phys;


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
import lycan.world.components.Groundable;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
#if !FLX_NO_DEBUG
import nape.util.ShapeDebug;
import flixel.addons.nape.FlxNapeSpace.GraphicNapeDebug;
#end

class Phys {
	public static var space:Space;
	
	/** Iterations for resolving velocity (default 10) */
	public static var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public static var positionIterations:Int = 10;
	/** Whether debug graphics are enabled */
	public static var drawDebug(default, set):Null<Bool> = null;
	/** Force a fixed timestep for integrator. Null means use FlxG.elapsed */
	public static var forceTimestep:Null<Float> = null;
	
	#if !FLX_NO_DEBUG
	public static var shapeDebug(default, null):ShapeDebug;
	private static var drawDebugButton:FlxSystemButton;
	public static var debugManipulator:DebugManipulator;
	public static var enableDebugManipulator(default, set):Bool = false;
	#end
	
	public static function init():Void {
		if (space != null) return;
		
		space = new Space(Vec2.weak(0, 3));
		space.gravity.y = 2000;
		
		FlxG.signals.postUpdate.add(update);
		FlxG.signals.postUpdate.add(draw);
		FlxG.signals.stateSwitched.add(onStateSwitch);
		
		#if !FLX_NO_DEBUG
		// Add a button to toggle Nape debug shapes to the debugger
		drawDebugButton = FlxG.debugger.addButton(RIGHT, new GraphicNapeDebug(0, 0), function() {
			drawDebug = !drawDebug;
		}, true, true);
		drawDebug = false;
		#end
	}
	
	public static function destroy():Void {
		
		destroyDebug();
		
		space = null;
		
		FlxG.signals.postUpdate.remove(update);
		FlxG.signals.postUpdate.remove(draw);
		FlxG.signals.stateSwitched.remove(onStateSwitch);
		
		GroundableComponent.clearGroundsSignal.removeAll();
		
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
	public static function createWalls(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0, thickness:Float = 10, ?material:Material):Body {
		if (maxX == 0) 	maxX = FlxG.width;
		if (maxY == 0)	maxY = FlxG.height;
		if (material == null) material = new Material(0, 0.2, 0.38, 0.7);
		
		var walls:Body = new Body(BodyType.STATIC);
		
		// Left, right, top, bottom
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, minY, thickness, maxY - minY)));
		walls.shapes.add(new Polygon(Polygon.rect(maxX, minY, thickness, maxY - minY)));
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, minY - thickness, maxX - minX + thickness * 2, thickness)));
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, maxY, maxX - minX + thickness * 2, thickness)));

		walls.space = space;
		walls.setShapeMaterials(material);
		
		return walls;
	}

	private static function set_drawDebug(drawDebug:Bool):Bool {
		if (drawDebug == Phys.drawDebug) return drawDebug;
		
		#if !FLX_NO_DEBUG
		if (drawDebugButton != null)
			drawDebugButton.toggled = !drawDebug;
		
		if (drawDebug) {
			if (shapeDebug == null) {
				shapeDebug = new ShapeDebug(FlxG.width, FlxG.height);
				shapeDebug.drawConstraints = true;
				shapeDebug.display.scrollRect = null;
				shapeDebug.thickness = 1;
				FlxG.addChildBelowMouse(shapeDebug.display);
			}
		}
		else if (shapeDebug != null) {
			FlxG.removeChild(shapeDebug.display);
			shapeDebug = null;
		}
		#end
		
		return Phys.drawDebug = drawDebug;
	}

	public static function update():Void {
		if (space != null && FlxG.elapsed > 0) {
			
			#if !FLX_NO_DEBUG
			if (debugManipulator != null && enableDebugManipulator) debugManipulator.update();
			#end
			
			// TODO better method or location for this?
			GroundableComponent.clearGroundsSignal.dispatch();
			
			space.step(forceTimestep == null ? FlxG.elapsed : forceTimestep, velocityIterations, positionIterations);
		}
	}
	
	private static function onStateSwitch():Void {
		if (space != null) {
			space.clear();
			space = null; // resets atributes like gravity.
		}
		
		destroyDebug();
	}
	
	private static function destroyDebug():Void {
		#if !Flx_NO_DEBUG
		drawDebug = false;
		enableDebugManipulator = false;
		debugManipulator = null;
		if (drawDebugButton != null) {
			FlxG.debugger.removeButton(drawDebugButton);
			drawDebugButton = null;
		}
		#end
	}
	
	public static function draw():Void {
		#if !FLX_NO_DEBUG
		if (shapeDebug == null || space == null) return;
		
		shapeDebug.clear();
		shapeDebug.draw(space);
		
		var zoom = FlxG.camera.zoom;
		var sprite = shapeDebug.display;
		
		sprite.scaleX = zoom;
		sprite.scaleY = zoom;
		
		sprite.x = -FlxG.camera.scroll.x * zoom;
		sprite.y = -FlxG.camera.scroll.y * zoom;
		#end
	}
	
	private static function set_enableDebugManipulator(enable:Bool):Bool {
		if (enable && debugManipulator == null) {
			debugManipulator = new DebugManipulator();
		}
		return Phys.enableDebugManipulator = enable;
	}
}
