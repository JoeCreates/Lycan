package lycan.game3D;

import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;
import haxe.ds.Vector;
import lycan.game3D.IsoBox;
import lycan.game3D.IsoProjection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;

class IsoGraphicUtil {
	public static function makeBox(spr:FlxSprite, iso:IsoProjection, box:IsoBox,
		colorTop:FlxColor = FlxColor.WHITE, ?colorLeft:FlxColor, ?colorRight:FlxColor):FlxSprite
	{
		if (colorLeft == null) colorLeft = colorTop;
		if (colorRight == null) colorRight = colorTop;
		
		var tl = box.tl;
		var tr = box.tr;
		//var ltl = box.ltl;
		var ltr = box.ltr;
		var bl = box.bl;
		var br = box.br;
		var lbl = box.lbl;
		var lbr = box.lbr;
		
		var top = iso.toCart(tl);
		var left = iso.toCart(bl);
		var right = iso.toCart(tr);
		var bottom = iso.toCart(br);
		var lowerBottom = iso.toCart(lbr);
		var lowerRight = iso.toCart(ltr);
		var lowerLeft = iso.toCart(lbl);
		
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
		
		spr.makeGraphic(Std.int(maxX - minX), Std.int(maxY - minY), FlxColor.TRANSPARENT, true);
		
		//TODO split into triangles?
		//TODO better lighting + specular
		//TODO sort polys into render order?
		var topNormal:Point3D = Util3D.getNormal(tl, tr, bl);
		var lightAngle:Float = topNormal.angleBetween(iso.lightVector);
		var lcolor = colorTop.getDarkened(lightAngle / Math.PI);
		var darkColor = colorLeft.getDarkened((Util3D.getNormal(lbl, bl, lbr).angleBetween(iso.lightVector) / Math.PI));
		var midColor = colorRight.getDarkened((Util3D.getNormal(br, lbr, ltr).scale(-1).angleBetween(iso.lightVector) / Math.PI));
		FlxSpriteUtil.drawPolygon(spr, [top, left, bottom, right], lcolor, {thickness: 1, color: lcolor});
		FlxSpriteUtil.drawPolygon(spr, [left, bottom, lowerBottom, lowerLeft], darkColor, {thickness: 0, color: darkColor});
		FlxSpriteUtil.drawPolygon(spr, [right, lowerRight, lowerBottom, bottom], midColor, {thickness: 0, color: midColor});
		
		for (p in [top, left, right, bottom, lowerBottom, lowerRight, lowerLeft]) p.put();
		
		return spr;
	}
	
	//TODO
	public static function makeCone(spr:FlxSprite, ?iso:IsoProjection, radius:Float, height:Float, color:FlxColor):FlxSprite {
		
		return spr;
	}
	
	public static function makeGrass(spr:FlxSprite, ?iso:IsoProjection, box:IsoBox):FlxSprite {
		if (iso == null) iso = IsoProjection.iso;
		
		// Get area of top
		var area:Float = box.areaTop;
		
		var density:Float = 30;
		var count:Int = Std.int(density * area);
		//var colorRange:FlxBounds<Float> = new FlxBounds<Float>(
		
		var points:Array<Point3D> = [box.tl, box.tr, box.br, box.bl];
		var basePoint:Point3D = Point3D.get();
		var basePointCart:FlxPoint = FlxPoint.get();
		for (i in 0...count) {
			Util3D.getRandomPointWithin(points, null, null, basePoint);
			//TODO nicer way to figure out the offset?
			iso.toCart(basePointCart, basePoint).add(spr.offset.x, spr.offset.y);
			FlxSpriteUtil.drawLine(spr, basePointCart.x, basePointCart.y, basePointCart.x,
				basePointCart.y - FlxG.random.float(2, 4), {thickness: 1, color: FlxColor.GREEN});
		}
		
		
		return spr;
	}
	
}