package lycan.util;

import flash.display.PNGEncoderOptions;
import flash.geom.Matrix;
import flash.net.FileReference;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.io.Bytes;
import lycan.util.CircularGraphic.PolygonSpoke;
import lycan.util.CircularGraphic.Spoke;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.Stage;
import openfl.display.StageQuality;
import openfl.utils.ByteArray;

/*
 * Requirements
 * Size
 * color count
 * layers
 * spoke
 */
 
class CircularGraphic extends FlxSprite {
	public var layers:Array<CircularGraphicLayer>;
	var layerSprite:FlxSprite;
	
	public function new() {
		super();
		layers = new Array<CircularGraphicLayer>();
		layerSprite = new FlxSprite();
	}
	
	/** 
	 * Generate the graphic
	 */
	public function generate(color:FlxColor = FlxColor.WHITE):Void {
		var radius:Float = 0;
		
		for (l in layers) {
			radius += l.radius + l.offset;
		}
		
		makeGraphic(Std.int(radius * 2), Std.int(radius * 2), FlxColor.TRANSPARENT, true);
		
		var currentRadius:Float = 0;
		for (l in layers) {
			currentRadius += l.offset;
			
			layerSprite.makeGraphic(Std.int(radius * 2), Std.int(radius * 2), FlxColor.TRANSPARENT, true);
			
			// If spoked
			if (l.spoke != null) {
				var spacing:Float = 360 / l.spokeCount;
				var angle:Float = l.angleOffset;
				for (i in 0...l.spokeCount) {
					l.spoke.draw(layerSprite, currentRadius, angle, radius, color);
					angle += spacing;
				}
			}
			
			// Otherwise solid circle
			else {
				var lineStyle = {
					thickness: l.radius,
					color: color,
					pixelHinting: false,
					miterLimit: 0.5
				};
				var drawStyle = {
					smoothing: true
				}
				
				// If not center, use a circular line
				if (currentRadius > 0) {
					FlxSpriteUtil.drawCircle(layerSprite, -1, -1, currentRadius + l.radius / 2, FlxColor.TRANSPARENT, lineStyle, drawStyle);
				}
				// If center, use a filled circle
				else {
					FlxSpriteUtil.drawCircle(layerSprite, -1, -1, l.radius, color, null, drawStyle);
				}
			}
			pixels.draw(layerSprite.pixels, null, null, l.delete ? BlendMode.ERASE : BlendMode.NORMAL);
			if (l.delete) {
				for (x in 0...pixels.width) {
					for (y in 0...pixels.height) {
						var c = FlxColor.fromInt(pixels.getPixel32(x, y));
						c.alpha -= FlxColor.fromInt(layerSprite.pixels.getPixel32(x, y)).alpha;
						pixels.setPixel32(x, y, c);
					}
				}
			}
			
			//var g = pixels.clone();
			//FlxSpriteUtil.fill(this, 0);
			//pixels.threshold(g, pixels.rect, _flashPointZero, ">", 0x7e000000, 0xffffffff, 0xff000000, false);
			
			currentRadius += l.radius;
		}
	}
}

class CircularGraphicLayer {
	public var spoke:Spoke;
	public var spokeCount:Int;
	public var radius:Float;
	public var angleOffset:Float;
	public var offset:Float;
	public var delete:Bool;
	
	public function new(radius:Float, offset:Float = 0, spokeCount:Int = 0, ?spoke:Spoke, angleOffset:Float = 0, delete:Bool = false) {
		this.radius = radius;
		this.spokeCount = spokeCount;
		this.spoke = spoke;
		this.angleOffset = angleOffset;
		this.offset = offset;
		this.delete = delete;
	}
}

/**
 * Relative, absolute sizes
 * Circle rect poly
 */
class Spoke {
	/** Radius for which given shape is given size. If null, size is absolute. */
	public var relativeRadius:Null<Float>;
	public var rotates:Bool;
	
	private static var matrix:Matrix = new Matrix();
	
	public function new(rotates:Bool = true,?relativeRadius:Float) {
		this.rotates = rotates;
		this.relativeRadius = relativeRadius;
	}
	
	public function draw(layerSprite:FlxSprite, radius:Float, angle:Float, totalRadius:Float, ?color:FlxColor):Void {
		
	}
	
}

class CircleSpoke extends Spoke {
	public var radius:Float;
	
	public function new(radius:Float, rotates:Bool = true, ?relativeRadius:Float) {
		this.radius = radius;
		super(rotates, relativeRadius);
	}
	
	override public function draw(layerSprite:FlxSprite, currentRadius:Float, angle:Float, totalRadius:Float, ?color:FlxColor):Void {
		super.draw(layerSprite, currentRadius, angle, totalRadius);
		
		var a = FlxAngle.TO_RAD * angle;
		var r = this.radius;
		var cr = currentRadius + r;
		
		FlxSpriteUtil.drawCircle(layerSprite, totalRadius + Math.sin(a) * cr, totalRadius -Math.cos(a) * cr, r, color);
	}
}

class PolygonSpoke extends Spoke {
	public var points:Array<FlxPoint>;
	private var transformedPoints:Array<FlxPoint>;
	
	public function new(points:Array<FlxPoint>, rotates:Bool = true, ?relativeRadius:Float) {
		this.points = points;
		transformedPoints = [];
		for (p in points) {
			transformedPoints.push(FlxPoint.get());
		}
		super(rotates, relativeRadius);
	}
	
	override public function draw(layerSprite:FlxSprite, radius:Float, angle:Float, totalRadius:Float, ?color:FlxColor):Void {
		super.draw(layerSprite, radius, angle, totalRadius);
		
		var matrix = Spoke.matrix;
		matrix.identity();
		matrix.translate(0, -radius);
		matrix.rotate(angle * FlxAngle.TO_RAD);
		matrix.translate(totalRadius, totalRadius);
		var i:Int = 0;
		for (p in transformedPoints) {
			p.copyFrom(points[i]);
			p.transform(matrix);
			i++;
		}
		FlxSpriteUtil.drawPolygon(layerSprite, transformedPoints, color, null, {smoothing: true});
	}
	
	public static function makeRectSpoke(width:Float, height:Float, rotates:Bool = true, ?relativeRadius:Float):PolygonSpoke {
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		points.push(FlxPoint.get(-width / 2, 0));
		points.push(FlxPoint.get(-width / 2, -height));
		points.push(FlxPoint.get(width / 2, -height));
		points.push(FlxPoint.get(width / 2, 0));
		return new PolygonSpoke(points, rotates, relativeRadius);
	}
}