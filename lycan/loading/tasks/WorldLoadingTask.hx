package lycan.loading.tasks;

import lycan.world.World;
import flixel.math.FlxPoint;
import lycan.world.World.TileLayerLoader;

class WorldLoadingTask extends PriorityTask {
	private var world:World;
	private var assetPath:String;
	private var loaderDefinitions:Map<String, WorldObjectLoader>;
	private var tileLoaderDefinitions:Map<String, TileLayerLoader>;
	
	public var data(get, null):World;
	public function get_data():World {
		return world;
	}
	
	public function new(assetPath:String, loaderDefinitions:Map<String, WorldObjectLoader>, tileLoaderDefinitions:Map<String, TileLayerLoader>, priority:Float = 3, ?scale:FlxPoint) {
		super(priority);
		this.assetPath = assetPath;
		this.loaderDefinitions = loaderDefinitions;
		this.tileLoaderDefinitions = tileLoaderDefinitions;
		world = new World(scale);
		
		world.signal_loadingProgress.add(onLoadingProgressed);
	}
	
	override public function run():Void {
		signal_started.dispatch(this);
		
		world.load(assetPath, loaderDefinitions, tileLoaderDefinitions);
		
		signal_progressed.dispatch(this, 100);
		signal_completed.dispatch(this);
	}
	
	private inline function onLoadingProgressed(progress:Float):Void {
		signal_progressed.dispatch(this, progress);
	}
	
	override public function getDescription():String {
		return "Loading world...";
	}
}