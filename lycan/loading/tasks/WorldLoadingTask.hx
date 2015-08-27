package lycan.loading.tasks;

import lycan.world.World;
import lycan.world.WorldLoader;
import flixel.math.FlxPoint;

class WorldLoadingTask extends PriorityTask {
	private var worldLoader:WorldLoader;
	private var world:World;
	private var assetPath:String;
	
	public var data(get, null):World;
	public function get_data():World {
		return world;
	}
	
	public function new(assetPath:String, loaderDefinitions:Map<String, WorldObjectLoader>, priority:Float = 3, ?scale:FlxPoint) {
		super(priority);
		worldLoader = new WorldLoader(loaderDefinitions);
		this.assetPath = assetPath;
		world = new World(scale);
	}
	
	override public function run():Void {
		signal_started.dispatch(this);
		
		world.load(assetPath, worldLoader);
		
		signal_progressed.dispatch(this, 100);
		signal_completed.dispatch(this);
	}
	
	override public function getDescription():String {
		return "Loading world...";
	}
}