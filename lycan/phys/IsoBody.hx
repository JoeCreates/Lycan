package lycan.phys;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lycan.components.CenterPositionable;
import lycan.util.ImageLoader;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.AngleJoint;
import nape.constraint.Constraint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.space.Space;
import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.display.BitmapData;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageQuality;

class IsoBody {
	public static function run(iso:IsoFunctionDef, bounds:AABB, granularity:Vec2=null, quality:Int=2, simplification:Float=1.5) {
		var body = new Body();
		if (granularity==null) granularity = Vec2.weak(8, 8);
		var polys = MarchingSquares.run(iso, bounds, granularity, quality);
		for (p in polys) {
			var qolys = p.simplify(simplification).convexDecomposition(true);
			for (q in qolys) {
				body.shapes.add(new Polygon(q));
				// Recycle GeomPoly and its vertices
				q.dispose();
			}
			// Recycle list nodes
			qolys.clear();
			// Recycle GeomPoly and its vertices
			p.dispose();
		}
		// Recycle list nodes
		polys.clear();
		// Align body with its centre of mass.
		// Keeping track of our required graphic offset.
		var pivot = body.localCOM.mul(-1);
		body.translateShapes(pivot);
		body.userData.graphicOffset = pivot;
		return body;
	}
}