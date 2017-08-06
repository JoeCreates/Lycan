package lycan.effects;

import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;
import lycan.util.ImageLoader;
import lycan.components.entities.CameraEmitter;
import lycan.util.MathUtil;
import lycan.util.ParallaxUtil;


// TODO parallax + test
// TODO multilayers
class RainEmitter extends CameraEmitter {
    public var sfx:FlxSound;
	/**
	 * The rectangle within which particles stay alive.
	 */
	public var lifeZone:FlxRect;
	public var depthScaleBounds:FlxBounds<Float>;
	public var depthSpeedBounds:FlxBounds<Float>;
	public var depthAlphaBounds:FlxBounds<Float>;
	public var depthScrollFactorBounds:FlxBounds<Float>;
	/**
	 * The distribution of depth of rain particles
	 * Takes a number from 0-1 and returns an transformed value from 0-1
	 * to use when interpolating between the depth bounds
	 */
	public var depthDistribution:Float->Float;
	
	public function new(?camera:FlxCamera, maxParticles:Int = 100, ?graphic:FlxGraphicAsset) {
		super(0, 0, maxParticles);
		launchMode = FlxEmitterMode.SQUARE;
		frequency = 0.01;
		
		lifeZone = FlxRect.get();
		lifespan.set(0);
		
		depthDistribution = function(t:Float) {return Math.pow(t - 1, 2) ;};
		depthScaleBounds = new FlxBounds<Float>(1, 1);
		depthSpeedBounds = new FlxBounds<Float>(1, 1);
		depthAlphaBounds = new FlxBounds<Float>(1, 1);
		depthScrollFactorBounds = new FlxBounds<Float>(1, 1);
		
		var ce = cameraAttachable;
		ce.camera = camera != null ? camera : FlxG.camera;
		
		for (i in 0...maxParticles) {
			var rainParticle:FlxParticle = new FlxParticle();
			if (graphic != null) {
				rainParticle.loadGraphic(graphic);
			}
			add(rainParticle);
		}
	}
	
	public function setDepthFactors(min:Float, max:Float):Void {
		depthScaleBounds.set(min, max);
		depthSpeedBounds.set(min, max);
		depthAlphaBounds.set(min, max);
		depthScrollFactorBounds.set(min, max);
	}
	
	public function startRain():Void {
		start(false, frequency);
		if (sfx != null && (!sfx.playing || sfx.volume < 1)) {
			sfx.play(true); // Note force-restarted as a possible fix for Android audio related crash after resuming
			sfx.fadeIn(1, sfx.volume, 0.6);
		}
	}
	
	override public function emitParticle():FlxParticle {
		var p:FlxParticle = super.emitParticle();
		p.angle = 180 - FlxAngle.TO_DEG * Math.asin(p.velocity.x / p.velocity.y);
		
		// Value to use for interpolating between bounds
		var depth:Float = depthDistribution(FlxG.random.float(0, 1));
		var v:Float = MathUtil.lerpBounds(depthScrollFactorBounds, depth);
		p.scrollFactor.set(v, v);
		p.alpha *= MathUtil.lerpBounds(depthAlphaBounds, depth);
		v = MathUtil.lerpBounds(depthScaleBounds, depth);
		p.scale.set(p.scale.x * v, p.scale.y * v);
		v = MathUtil.lerpBounds(depthSpeedBounds, depth);
		p.velocity.set(p.velocity.x * v, p.velocity.y * v);
		
		ParallaxUtil.adjustPositionForCamera(p, camera);
		return p;
	}
	
	public function stop():Void {
		this.emitting = false;
		sfx.fadeOut(0.5);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		for (particle in members) {
			var wx:Float = ParallaxUtil.getWorldX(particle, camera);
			var wy:Float = ParallaxUtil.getWorldY(particle, camera);
			
			// If particle has moved below life bounds, kill it
			if (wy > y + lifeZone.y + lifeZone.height) {
				particle.kill();
			}
			
			// If particle gone right of bounds, move it to the left
			if (wx > x + lifeZone.right) {
				ParallaxUtil.setPositionAtScroll(particle, x + lifeZone.x - particle.width, wy, camera.scroll.x, camera.scroll.y);
			}
			// If particle gone left of bounds, move it to the right
			if (wx < x + lifeZone.x) {
				ParallaxUtil.setPositionAtScroll(particle, x + lifeZone.right, wy, camera.scroll.x, camera.scroll.y);
			}
		}
	}
}

class RainGraphicGenerator {
	static var filter(get, null):BlurFilter;
	static var point:Point = new Point();
	static var rect:Rectangle = new Rectangle();
	
	public static function makeParticle(length:Float,
		thickness:Float = 4, color:FlxColor = FlxColor.WHITE, ?blurX:Float, ?blurY:Float):FlxGraphic
	{
		var fullLength:Float = length;
		var fullWidth:Float = thickness;
		var isBlurred:Bool = blurX != null || blurY != null;
		
		if (blurX == null) blurX = 0;
		if (blurY == null) blurY = 0;
		
		if (isBlurred) {
			fullLength = length + blurY * 2;
			fullWidth = thickness + blurX * 2;
		}
		
		var b:FlxGraphic = FlxG.bitmap.create(Std.int(fullWidth), Std.int(fullLength), 0);
		rect.setTo(blurX, blurY, thickness, length);
		b.bitmap.fillRect(rect, color);
		if (isBlurred) {
			filter.blurX = blurX;
			filter.blurY = blurY;
			filter.quality = 1;
			b.bitmap.applyFilter(b.bitmap, b.bitmap.rect, point, filter);
		}
		return b;
	}
	
	private static function get_filter():BlurFilter {
		if (filter == null) filter = new BlurFilter(0, 40, 1);
		return filter;
	}
}