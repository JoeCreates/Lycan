package lycan.loading.tasks;

import flixel.graphics.frames.FlxAtlasFrames;

class FlxAtlasFramesLoadingTask extends PriorityTask implements IDataProducer<FlxAtlasFrames> {
	private var filename:String = null;
	private var frames:FlxAtlasFrames;
	public var data(get, null):FlxAtlasFrames;
	private function get_data():FlxAtlasFrames {
		return frames;
	}

	public function new(filename:String, priority:Float = 10) {
		super(priority);
		this.filename = filename;
	}
	
	override public function run():Void {
		signal_started.dispatch(this);
		
		frames = ImageLoader.loadAtlas(filename);
		
		if (frames == null) {
			signal_failed.dispatch(this, "Resulting atlas was null");
			return;
		}
		
		signal_progressed.dispatch(this, 100);
		signal_completed.dispatch(this);
	}
	
	override public function getDescription():String {
		return filename;
	}
}