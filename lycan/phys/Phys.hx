package lycan.phys;


import nape.geom.Mat23;
import openfl.display.Shape;
import flixel.math.FlxPoint;
import flash.display.BitmapData;
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
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import openfl.geom.Matrix3D;
import openfl.geom.Matrix;
import lycan.game3D.Point3D;
import lycan.game3D.PerspectiveProjection;
#if !FLX_NO_DEBUG
import nape.util.ShapeDebug;
@:bitmap("assets/images/napeDebug.png")
class GraphicNapeDebug extends BitmapData {}
#end

class Phys {
	public static var space:Space;
	
	/** Iterations for resolving velocity (default 10) */
	public static var velocityIterations:Int = 20;
	/** Iterations for resolving position (default 10) */
	public static var positionIterations:Int = 20;
	public static var steps:Int = 2;
	/** Whether debug graphics are enabled */
	public static var drawDebug(default, set):Null<Bool> = null;
	/** Force a fixed timestep for integrator. Null means use FlxG.elapsed */
	public static var forceTimestep:Null<Float> = null;
	
	public static var floorPos:Bool = false;
	
	#if !FLX_NO_DEBUG
	public static var shapeDebug(default, null):ShapeDebug;
	private static var drawDebugButton:FlxSystemButton;
	public static var debugManipulator:DebugManipulator;
	public static var enableDebugManipulator(default, set):Bool = false;
	#end
	
	public static var matrix3D:Matrix3D;
	public static var projection:PerspectiveProjection;//TODO general projections
	
	// CbTypes
	public static var tilemapShapeType:CbType = new CbType();
	public static var sensorFilter:InteractionFilter = new InteractionFilter(0, 0, 1, 1, 0, 0);
	
	private static var _matrix:Matrix = new Matrix();
	
	public static function init():Void {
		if (space != null) return;
		
		space = new Space(Vec2.weak(0, 3));
		space.gravity.y = 2500;
		
		FlxG.signals.preUpdate.add(update);
		FlxG.signals.postUpdate.add(draw);
		FlxG.signals.preStateSwitch.add(onStateSwitch);
		FlxG.signals.preGameReset.addOnce(destroy);
		
		#if !FLX_NO_DEBUG
		// Add a button to toggle Nape debug shapes to the debugger
		@:access drawDebugButton = FlxG.debugger.addButton(RIGHT, new GraphicNapeDebug(0, 0), function() {
			drawDebug = !drawDebug;
		}, true, true);
		drawDebug = false;
		#end
	}
	
	public static function destroy():Void {
		
		destroyDebug();
		
		space = null;
		
		FlxG.signals.preUpdate.remove(update);
		FlxG.signals.postUpdate.remove(draw);
		FlxG.signals.preStateSwitch.remove(onStateSwitch);
		
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
		if (material == null) material = new Material();
		
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
		var dt = forceTimestep == null ? FlxG.elapsed : forceTimestep;
		if (space != null && dt > 0) {
			
			#if !FLX_NO_DEBUG
			if (debugManipulator != null && enableDebugManipulator) {
				var x:Null<Float> = FlxG.mouse.x;
				var y:Null<Float> = FlxG.mouse.y;
				if (!FlxG.mouse.pressed) {
					x = null;
					y = null;	
				} else if (projection != null) {
					var p = FlxPoint.get(x, y);
					var p3d = Point3D.get(x, y, 0);
					projection.to3D(null, p, projection.depth);
					p.put();
					x = p3d.x;
					y = p3d.y;
					p3d.put();
					if (FlxG.mouse.justPressed) trace(x + " " + y);
				}
				debugManipulator.update(FlxG.mouse.justPressed, x, y);
			}
			#end
			
			// TODO better method or location for this?
			GroundableComponent.clearGroundsSignal.dispatch();
			
			if (steps == 1) {
				space.step(dt, velocityIterations, positionIterations);
			} else {
				var sdt = dt / steps;
				var velItr = Std.int(velocityIterations / steps);
				var posItr = Std.int(positionIterations / steps);
				for (i in 0...steps) {
					space.step(sdt, velItr, posItr);
				}
			}

		}
	}
	
	private static function onStateSwitch():Void {
		if (space != null) {
			space.clear();
			space = null; // resets attributes like gravity.
		}
		
		destroyDebug();
	}
	
	private static function destroyDebug():Void {
		#if !FLX_NO_DEBUG
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
		
		(cast shapeDebug.display:Shape).graphics.clear();
		shapeDebug.cullingEnabled = true;
		
		var zoom = FlxG.camera.zoom;
		var sprite = shapeDebug.display;
		var scale = FlxG.camera.totalScaleX;
		
		// if (matrix3D != null) {
		// 	if (sprite.transform.matrix3D == null) sprite.transform.matrix3D = new Matrix3D();
		// 	// var scaleX = sprite.scaleX;
		// 	// var scaleY = sprite.scaleY;
		// 	// var sx = sprite.x;
		// 	// var sy = sprite.y;
		// 	var mat = sprite.transform.matrix3D;
		// 	mat.identity();
		// 	// mat.appendScale(scaleX, scaleY, 1);
		// 	// mat.appendTranslation(sx, sy, 0);
		// 	mat.append(matrix3D);
		// } else {
		// 	//sprite.scaleX = FlxG.camera.totalScaleX;
		// 	//sprite.scaleY = FlxG.camera.totalScaleY;
		// 	//sprite.x = FlxG.camera.x - FlxG.camera.scroll.x * FlxG.camera.totalScaleX - FlxG.width * ((scale - 1) / 2) + 120;
		// 	//sprite.y = FlxG.camera.y - FlxG.camera.scroll.y * FlxG.camera.totalScaleY - FlxG.height * ((scale - 1) / 2);
		// }
		
		// TODO this is terribly slow, especially for scaling
		// We can cull and crop, but even these seem slow
		// Potentially making a btimap for scaling could help, but normal draw is slowish, surely can be improved
		sprite.scaleX = FlxG.camera.totalScaleX;
		sprite.scaleY = FlxG.camera.totalScaleY;
		var sd:ShapeDebug = cast shapeDebug;
		var mat23:Mat23 = cast sd.transform;
		mat23.reset();
		mat23.toMatrix(_matrix);
		// TODO this is really wrong hardcoded for tom platformer temporarily
		_matrix.translate(FlxG.camera.x -FlxG.camera.scroll.x - FlxG.width *0.4 + 85, FlxG.camera.y -FlxG.camera.scroll.y - FlxG.height * 0.4 + 48);
		mat23.setAs(_matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
		
		shapeDebug.draw(space);
		#end
	}
	
	#if !FLX_NO_DEBUG
	private static function set_enableDebugManipulator(enable:Bool):Bool {
		if (enable && debugManipulator == null) {
			debugManipulator = new DebugManipulator();
		}
		return Phys.enableDebugManipulator = enable;
	}
	#end
}
