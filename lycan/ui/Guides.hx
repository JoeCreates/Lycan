package lycan.ui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * A sprite that draws a grid of guidelines
 */
class Guides extends FlxSprite {

	// TODO offsets, major and minor grid lines, options or when to show text
	public var verticalLineSpacing:Float = 100;
	public var horizontalLineSpacing:Float = 100;
	
	private var text:FlxText;
	
	public function new() {
		super();
		scrollFactor.set();
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true, "guidesprite");
		
		text = new FlxText(0, 0, 0, "");
		alpha = 0.4;
	}
	
	override public function draw():Void {
		
		FlxSpriteUtil.fill(this, FlxColor.TRANSPARENT);
		
		var verticalDivisions:Int = Std.int(width / verticalLineSpacing);
		var horizontalDivisions:Int = Std.int(height / horizontalLineSpacing);
		
		var initialLineX:Float = -camera.scroll.x % verticalLineSpacing;
		var gridX:Int = Math.floor(camera.scroll.x / verticalLineSpacing);
		for (dx in 0...verticalDivisions + 1) {
			var lineX:Float = initialLineX + dx * verticalLineSpacing;
			FlxSpriteUtil.drawLine(this, lineX, 0, lineX, height);
		}

		var initialLineY:Float = -camera.scroll.y % horizontalLineSpacing;
		var gridY:Int = Math.floor(camera.scroll.y / horizontalLineSpacing);
		for (dy in 0...horizontalDivisions + 1) {
			var lineY:Float = initialLineY + dy * horizontalLineSpacing;
			FlxSpriteUtil.drawLine(this, 0, lineY, width, lineY);
			text.text = Std.string((gridY + 1 + dy) * horizontalLineSpacing);
			stamp(text, 2, Std.int(lineY - text.height));
		}
		
		super.draw();
	}
	
}