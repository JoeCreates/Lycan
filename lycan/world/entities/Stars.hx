package lycan.world;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lycan.util.GameUtil;

class Stars extends FlxTypedSpriteGroup<Star> {
	public var starCount:Int;
	public var starGraphic:String;
	public var minAlpha = 0.7;
	public var maxAlpha = 0.9;
	public var typeCount:Int;
	public var starSize:FlxPoint;
	public var fieldWidth:Float;
	public var fieldHeight:Float;
	
	public function new(starGraphic:String, starSize:FlxPoint, typeCount:Int, width:Float, height:Float, density:Float) {
		super();
		
		this.fieldWidth = width;
		this.fieldHeight = height;
		this.typeCount = typeCount;
		this.starGraphic = starGraphic;
		this.starSize = starSize;
		var size:Float = width * height / (starSize.x * starSize.y);
		starCount = Std.int(size * density);
		scrollFactor.set();
	}
	
	public function create():Void {
		for (i in 0...starCount) {
			var star = new Star(FlxG.random.float(-starSize.x + 1, fieldWidth - 1),
			                    FlxG.random.float(-starSize.y + 1, fieldHeight - 1), this);
			add(star);
		}
	}
	
}

class Star extends FlxSprite {
	public var tween:FlxTween;
	
	private static var point:FlxPoint = FlxPoint.get();
	
	public function new(x:Float, y:Float, stars:Stars) {
		super(x, y);
		solid = false;
		loadGraphic(stars.starGraphic, true, Std.int(stars.starSize.x), Std.int(stars.starSize.y));
		animation.add("stars", [for (i in 0...stars.typeCount) i], 0, false);
		animation.play("stars");
		var r:FlxRandom = FlxG.random;
		animation.curAnim.curFrame = r.int(0, stars.typeCount - 1);
		color = FlxColor.fromHSB(r.float(0, 360), r.float(0, 0.18), r.float(0.8, 1));
		alpha = r.float(stars.minAlpha, stars.maxAlpha);
		tween = FlxTween.tween(this, { alpha: 0.1 }, r.float(0.4, 3.5), { type: FlxTween.PINGPONG } );
		scrollFactor.set();
	}
	
	override public function update(dt):Void {
		super.update(dt);
		getScreenPosition(point, FlxG.camera);
		
		//TODO: for both axis and efficincy
		if (point.x < 0 - frameWidth) {
			GameUtil.setPositionAtScroll(this, FlxG.camera.scroll.x + FlxG.width, y, FlxG.camera.scroll.x, FlxG.camera.scroll.y);
		}
		if (point.x > FlxG.width) {
			GameUtil.setPositionAtScroll(this, FlxG.camera.scroll.x - frameWidth, y, FlxG.camera.scroll.x, FlxG.camera.scroll.y);
		}
	}
}