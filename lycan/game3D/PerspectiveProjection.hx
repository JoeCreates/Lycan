package lycan.game3D;

import flash.geom.Matrix3D;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import lycan.game3D.components.Position3D;
import lycan.game3D.Camera3D;
import lycan.game3D.Point3D;
import openfl.geom.Vector3D;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxBasic;

class PerspectiveProjection {
	public var width:Float;
	public var height:Float;
	public var depth:Float;
	public var matrix(default, null):Matrix3D;
	public var camera(default, null):Camera3D;
	
	private var _vec3:Vector3D;
	private var _p3:Point3D;
	private var _p2:FlxPoint;
	private inline function vec3(x:Float, y:Float, z:Float) {_vec3.setTo(x, y, z); return _vec3;}
	
	public function new(?width:Float, ?height:Float, ?depth:Float) {
		if (width == null) width = FlxG.width;
		if (height == null) height = FlxG.height;
		if (depth == null) depth = FlxG.width / 2;
		this.width = width;
		this.height = height;
		this.depth = depth;
		matrix = new Matrix3D();
		
		_vec3 = new Vector3D();
		_p3 = Point3D.get();
		_p2 = FlxPoint.get();
	}
	
	public function beginProjection(camera:Camera3D) {
		this.camera = camera;
		matrix.identity();
		matrix.appendTranslation(-camera.pos.x, -camera.pos.y, -camera.pos.z);
		matrix.appendRotation(camera.angle.y, vec3(0, 1, 0));
		matrix.appendRotation(camera.angle.x, vec3(1, 0, 0));
		matrix.appendRotation(-camera.angle.z, vec3(0, 0, 1));
	}
	
	public function set(?width:Float, ?height:Float, ?depth:Float) {
		if (width == null) width = FlxG.width;
		if (height == null) height = FlxG.height;
		if (depth == null) depth = FlxG.width / 2;
		this.width = width;
		this.height = height;
		this.depth = depth;
		return this;
	}
	
	public function applyCameraTransform(input:Point3D, ?output:Point3D):Point3D {
		if (output == null) output = Point3D.get();
		output.copyFrom(input);
		return output.transform(matrix);
	}
	
	public function toCart(?p2d:FlxPoint, p3d:Point3D):FlxPoint {
		if (p2d == null) p2d = FlxPoint.get();
		
		var dz = depth / p3d.z;
		p2d.set(width / 2 + p3d.x * dz, height / 2 + p3d.y * dz);
		return p2d;
	}
	
	public function to3D(?p3d:Point3D, p2d:FlxPoint, z:Float = 0):Point3D {
		if (p3d == null) p3d = Point3D.get();
		
		var dz = depth / z;
		p3d.set((p2d.x - width / 2) /  dz, (p2d.y - height / 2) /  dz, z);
		
		return p3d;
	}
	
	public function spriteToCart(s:FlxSprite) {
		var spr:FlxSprite = cast s;
		var s3:Position3D = cast s;
		applyCameraTransform(s3.pos3D.point, _p3);
		toCart(_p2, _p3);
		spr.visible = _p3.z > 0;
		var mul:Float = FlxEase.quadIn(1 - FlxMath.bound(camera.pos.distanceTo(s3.pos3D.point)/ 1600, 0, 1));
		spr.color = FlxColor.fromRGBFloat(mul, mul, mul);
		var newWidth = spr.width * depth / _p3.z;
		var newHeight = spr.height * depth / _p3.z;
		spr.scale.set(newWidth / spr.width, newHeight / spr.height);
		spr.angle = -camera.angle.z;
		spr.setPosition(_p2.x - spr.origin.x, _p2.y - spr.origin.y);
	}
	
	public static function byDepth(cam:Camera3D, b1:FlxBasic, b2:FlxBasic):Int {
		var o1:Position3D = cast b1;
		var o2:Position3D = cast b2;
		var oo1:FlxObject = cast b1;
		var oo2:FlxObject = cast b2;
		
		inline function sqr(a:Float) return a * a;
		function d(pos:Point3D) return sqr(cam.pos.x - pos.x) + sqr(cam.pos.y - pos.y) + sqr(cam.pos.z - pos.z);
		
		var d1 = d(o1.pos3D.point) - sqr(oo1.width / 2);
		var d2 = d(o2.pos3D.point) - sqr(oo2.width / 2);
		
		return FlxSort.byValues(FlxSort.DESCENDING, d1, d2);
	}
}