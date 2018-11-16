package lycan.system;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.text.FlxText;

class FpsText extends FlxText {
	public var updateInterval:Float;
	public var framesSinceUpdate:Int;
	public var lastUpdateMillis:Int;
	public var fps:Float;
	
	public function new(x:Float = 0, y:Float = 0, size:Int = 16, updateInterval:Float = 0.5) {
		super(x, y, 0, "FPS:", size);
		this.updateInterval = updateInterval;
		lastUpdateMillis = FlxG.game.ticks;
		framesSinceUpdate = 0;
		
		active = true;
	}
	
	override public function update(dt:Float):Void {
		
		framesSinceUpdate++;
		
		var millisSinceUpdate:Int = FlxG.game.ticks - lastUpdateMillis;
		if (millisSinceUpdate >= updateInterval * 1000) {
			fps = (1000 * framesSinceUpdate / millisSinceUpdate);
			text = "FPS: " + Math.round(fps * 10) / 10;
			lastUpdateMillis = FlxG.game.ticks;
			framesSinceUpdate = 0;
		}
		
		super.update(dt);
	}
	
}