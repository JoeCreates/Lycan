package lycan.world;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import lycan.FlxComponent;
import lycan.world.NapeSpace;
import nape.shape.Edge;
import openfl.Vector;

typedef Intersection = {
	x:Float,
	y:Float,
	param:Float,
	angle: Float
}

typedef Edge = {
	a:Point,
	b:Point
}

typedef Point = {
	x:Float,
	y:Float
}

class DynamicLight2D {
	
	public var intersections:Array<Intersection>;
	public var edges:Array<Edge>;
	
	public function new() {
		intersections = new Array<Intersection>();
		edges = new Array<Edge>();
	}
	
	public function getIntersection(ray:Edge, segment:Edge):Intersection {
		// Parametric form of ray
		var rx = ray.a.x;
		var ry = ray.a.y;
		var rdx = ray.b.x - ray.a.x;
		var rdy = ray.b.y - ray.a.y;
		
		// Parameteric form of segment
		var sx = segment.a.x;
		var sy = segment.a.y;
		var sdx = segment.b.x - segment.a.x;
		var sdy = segment.b.y - segment.a.y;
		
		// No intersection if lines are parallel (unit vectors are the same)
		var rMag = Math.sqrt(rdx * rdx + rdy * rdy);
		var sMag = Math.sqrt(sdx * sdx + sdy * sdy);
		if (rdx / rMag == sdx / sMag && rdy / rMag == sdy / sMag) {
			return null;
		}
		var t2 = (rdx * (sy - ry) + rdy * (rx - sx)) / (sdx * rdy - sdy * rdx);
		var t1 = (sx + sdx * t2 - rx) / rdx;
		
		// Must be within parametic whatevers for RAY/seg
		if(t1 < 0) return null;
		if (t2 < 0 || t2 > 1) return null;
		
		// Return point of intersection and parameter
		// Note that angle is not correct, but is not required, yet
		return {x: rx + rdx * t1, y: ry + rdy * t1, param: t1, angle: 0};
	}
	var length:Int;
	public function calculateIntersections(x:Float, y:Float):Array<Intersection> {
		intersections.splice(0, intersections.length);
		var pointAngles:Map<Point, Float> = new Map<Point, Float>();
		
		// For each edge, for each unqiue point
		for (s in edges) {
			for (p in [s.a, s.b]) {
				if (!pointAngles.exists(p)) {
					if (Math.pow(p.x - x, 2) + Math.pow(p.y - y, 2) > 1000000) continue;
					var angle:Float = Math.atan2(p.y - y, p.x - x);
					pointAngles.set(p, angle);
					// Cast 3 rays for each unique point
					for (a in [angle, angle - 0.00001, angle + 0.00001]) {
						// Record the closest intersection
						var closestIntersection:Null<Intersection> = null;
						for (seg in edges) {
							var ray:Edge = {
								a: {x: x, y: y},
								b: {x: x + Math.cos(angle), y: y + Math.sin(angle)}
							};
							var intersection:Null<Intersection> = getIntersection(ray, seg);
							if (intersection == null) continue;
							if (closestIntersection == null || intersection.param < closestIntersection.param) {
								closestIntersection = intersection;
							}
						}
						if (closestIntersection == null) continue;
						closestIntersection.angle = a;
						intersections.push(closestIntersection);
					}
				}
			}
		}
		
		// Sort intersections
		intersections.sort(function(a, b) {
			return a.angle > b.angle ? 1 : (b.angle > a.angle ? -1 : 0);
		});
		
		return intersections;
	}
	
	public function drawLight(sprite:FlxSprite, origin:FlxPoint, ?camera:FlxCamera):Void {
		if (camera == null) camera = FlxG.camera;
		var polygon:Array<FlxPoint> = new Array<FlxPoint>();
		for (p in calculateIntersections(origin.x, origin.y)) {
			polygon.push(FlxPoint.get(p.x - camera.scroll.x, p.y - camera.scroll.y));
		}
		FlxSpriteUtil.drawPolygon(sprite, polygon);
		for (p in polygon) p.put();
	}
	
}

class LightObstructor extends FlxComponent<FlxObject> {
	public var space:DynamicLight2D;
	
	public function new(space:DynamicLight2D) {
		super();
		this.space = space;
	}
}