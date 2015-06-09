package lycan.assetloading.tasks ;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

// TODO provide a reference to a sprite that the task can assign the data to when done?
class FlxSpriteLoadingTask extends PriorityTask implements IDataProducer<FlxSprite> {
	private var assetPath:String = null;
	private var sprite:FlxSprite = null;
	public var data(get, null):FlxSprite;
	public function get_data():FlxSprite {
		return sprite;
	}

	public function new(assetPath:FlxGraphicAsset, priority:Float = 5) {
		super(priority);
		this.assetPath = assetPath;
	}
	
	override public function run():Void {
		signal_started.dispatch(this);
		
		sprite = ImageLoader.get(0, 0, assetPath);
		
		if (sprite == null) {
			signal_failed.dispatch(this, "Resulting sprite was null");
			return;
		}
		
		signal_progressed.dispatch(this, 100);
		signal_completed.dispatch(this);
	}
	
	override public function getDescription():String {
		return assetPath;
	}
}