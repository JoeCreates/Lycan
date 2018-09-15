package lycan.game3D;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;
import openfl.geom.Matrix3D;
import tink.core.Ref;
import haxe.ds.Vector;

using flixel.util.FlxSpriteUtil;

@:tink
class IsoBox {
	public var tl:Point3D;
	public var tr:Point3D;
	public var bl:Point3D;
	public var br:Point3D;
	public var lbl:Point3D;
	public var lbr:Point3D;
	public var ltr:Point3D;
	public var ltl:Point3D;
	
	public var points:Array<Point3D>;
	
	@:calc public var areaTop:Float = Util3D.getQuadArea(tl, tr, br, bl);
	@:calc public var areaLeft:Float = Util3D.getQuadArea(bl, br, lbr, lbl);
	@:calc public var areaRight:Float = Util3D.getQuadArea(tr, ltr, lbr, br);
	@:calc public var areaBackLeft:Float = Util3D.getQuadArea(tl, ltl, lbl, bl);
	@:calc public var areaBackRight:Float = Util3D.getQuadArea(tl, tr, ltr, ltl);
	@:calc public var areaBottom:Float = Util3D.getQuadArea(ltl, ltr, lbr, lbl);
	
	public var minX:Float;
	public var maxX:Float;
	public var minY:Float;
	public var maxY:Float;
	public var minZ:Float;
	public var maxZ:Float;
	public var width:Float;
	public var height:Float;
	public var depth:Float;
	
	public function new(width:Float = 1, height:Float = 1, depth:Float = 1) {
		tl = Point3D.get();
		tr = Point3D.get();
		bl = Point3D.get();
		br = Point3D.get();
		lbl = Point3D.get();
		lbr = Point3D.get();
		ltr = Point3D.get();
		ltl = Point3D.get();
		makeBox(width, height, depth);
		
		points = [tl, tr, bl, br, lbl, lbr, ltl, ltr];
	}
	
	public function makeBox(width:Float = 1, height:Float = 1, depth:Float = 1):IsoBox {
		tl.set(0, 0, 0);
		tr.set(width, 0, 0);
		bl.set(0, height, 0);
		br.set(width, height, 0);
		lbl.set(0, height, depth);
		lbr.set(width, height, depth);
		ltr.set(width, 0, depth);
		ltl.set(0, 0, depth);
		return this;
	}
	
	public function transform(matrix:Matrix3D):IsoBox {
		for (p in points) p.transform(matrix);
		return this;
	}
	
	public function translate(x:Float, y:Float, z:Float):IsoBox {
		for (p in points) p.add(x, y, z);
		return this;
	}
	
	public function updateBounds():Void {
		minX = Math.POSITIVE_INFINITY;
		maxX = Math.NEGATIVE_INFINITY;
		minY = Math.POSITIVE_INFINITY;
		maxY = Math.NEGATIVE_INFINITY;
		minZ = Math.POSITIVE_INFINITY;
		maxZ = Math.NEGATIVE_INFINITY;
		
		for (p in points) {
			if (p.x < minX) minX = p.x;
			if (p.x > maxX) maxX = p.x;
			if (p.y < minY) minY = p.y;
			if (p.y > maxY) maxY = p.y;
			if (p.z < minZ) minZ = p.z;
			if (p.z > maxZ) maxZ = p.z;
		}
		
		height = maxY - minY;
		width = maxX - minX;
		depth = maxZ - minZ;
	}
	
}