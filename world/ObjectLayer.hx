package world;

import flixel.group.FlxGroup;
import nape.phys.Body;
import world.WorldLayer.WorldLayerType;

class ObjectLayer extends FlxGroup implements WorldLayer {
	
	public var layerType:WorldLayerType = WorldLayerType.OBJECT;
	public var world:World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
	
}