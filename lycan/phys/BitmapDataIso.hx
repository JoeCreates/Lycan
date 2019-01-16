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


class BitmapDataIso #if flash implements IsoFunction #end {
	public var bitmap:BitmapData;
	public var alphaThreshold:Float;
	public var bounds:AABB;
	public function new(bitmap:BitmapData, alphaThreshold:Float = 0x80) {
		this.bitmap = bitmap;
		this.alphaThreshold = alphaThreshold;
		bounds = new AABB(0, 0, bitmap.width, bitmap.height);
	}
	public function graphic() {
		return new Bitmap(bitmap);
	}
	public function iso(x:Float, y:Float) {
		// Take 4 nearest pixels to interpolate linearly.
		// This gives us a smooth iso-function for which
		// we can use a lower quality in MarchingSquares for
		// the root finding.
		var ix = Std.int(x); var iy = Std.int(y);
		//clamp in-case of numerical inaccuracies
		if (ix<0) ix = 0; if (iy<0) iy = 0;
		if (ix>=bitmap.width-2)  ix = bitmap.width-2;
		if (iy>=bitmap.height-2) iy = bitmap.height-2;
		// iso-function values at each pixel centre.
		var a11 = alphaThreshold - (bitmap.getPixel32(ix,iy)>>>24);
		var a12 = alphaThreshold - (bitmap.getPixel32(ix+1,iy)>>>24);
		var a21 = alphaThreshold - (bitmap.getPixel32(ix,iy+1)>>>24);
		var a22 = alphaThreshold - (bitmap.getPixel32(ix+1,iy+1)>>>24);
		// Bilinear interpolation for sample point (x,y)
		var fx = x - ix; var fy = y - iy;
		return a11*(1-fx)*(1-fy) + a12*fx*(1-fy) + a21*(1-fx)*fy + a22*fx*fy;
	}
}