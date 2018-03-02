package lycan.util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.components.Entity3D;
import lycan.util.Point3D;

using flixel.util.FlxSpriteUtil;

@:tink
class IsoTile extends FlxSprite implements Entity3D {
	public var tl:Point3D;
	public var tr:Point3D;
	public var bl:Point3D;
	public var br:Point3D;
	public var lbl:Point3D;
	public var lbr:Point3D;
	public var ltr:Point3D;
	//TODO we need the other point
	
	public var projection:IsoProjection;
	
	@:calc var top:FlxPoint = projection.toCart(tl);
	@:calc var left:FlxPoint = projection.toCart(bl);
	@:calc var bottom:FlxPoint = projection.toCart(br);
	@:calc var right:FlxPoint = projection.toCart(tr);
	@:calc var lowerLeft:FlxPoint = projection.toCart(lbl);
	@:calc var lowerBottom:FlxPoint = projection.toCart(lbr);
	@:calc var lowerRight:FlxPoint = projection.toCart(ltr);
	
	public function new(iso:IsoProjection, width:Float = 1, height:Float = 1, depth:Float = 1) {
		super();
		
		this.projection = iso;
		
		tl = Point3D.get(0, 0, 0);
		tr = Point3D.get(width, 0, 0);
		bl = Point3D.get(0, height, 0);
		br = Point3D.get(width, height, 0);
		lbl = Point3D.get(0, height, depth);
		lbr = Point3D.get(width, height, depth);
		ltr = Point3D.get(width, 0, depth);
	}
	
	public function generateGraphic(color:FlxColor = FlxColor.WHITE):FlxSprite {
		// Make color tones
		var midColor:FlxColor = color.getDarkened(0.3);
		var darkColor:FlxColor = color.getDarkened(0.7);
		darkColor.hue = FlxMath.wrap(Std.int(darkColor.hue) - 20, 0, 360);
		darkColor.saturation *= 0.8;
		midColor.hue = FlxMath.wrap(Std.int(midColor.hue) - 10, 0, 360);
		midColor.saturation *= 0.9;
		
		var top = this.top;
		var left = this.left;
		var right = this.right;
		var bottom = this.bottom;
		var lowerBottom = this.lowerBottom;
		var lowerRight = this.lowerRight;
		var lowerLeft = this.lowerLeft;
		
		var maxY:Float = Math.NEGATIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var minX:Float = Math.POSITIVE_INFINITY;
		
		for (p in [top, left, right, bottom, lowerBottom, lowerRight, lowerLeft]) {
			if (p.y < minY) minY = p.y;
			if (p.y > maxY) maxY = p.y;
			if (p.x < minX) minX = p.x;
			if (p.x > maxX) maxX = p.x;
		}
		
		// Normalise to make sure nothing gets cut out of frame
		if (minY != 0) {
			for (p in [top, left, right, bottom, lowerBottom, lowerRight, lowerLeft]) {
				p.y -= minY;
			}
		}
		if (minX != 0) {
			for (p in [top, left, right, bottom, lowerBottom, lowerRight, lowerLeft]) {
				p.x -= minX;
			}
		}
		
		makeGraphic(Std.int(maxX - minX), Std.int(maxY - minY), FlxColor.TRANSPARENT, true);
		
		//TODO split into triangles
		drawPolygon([top, left, bottom, right], color);
		drawPolygon([left, bottom, lowerBottom, lowerLeft], darkColor);
		drawPolygon([right, lowerRight, lowerBottom, bottom], midColor);
		
		for (p in [top, left, right, bottom, lowerBottom, lowerRight, lowerLeft]) p.put();
		
		return this;
	}
}