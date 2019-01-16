package lycan.world;

import lycan.components.Component;
import lycan.components.Entity;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledPropertySet;

interface WorldLayer extends Entity {
	public var worldLayer:WorldLayerComponent;
}

class WorldLayerComponent extends Component<WorldLayer> {
	public var world:TiledWorld;
	public var properties(default, null):TiledPropertySet;
	public var type:TiledLayerType;
	
	public function new(entity:WorldLayer) {
		super(entity);
	}
	
	public function init(tiledLayer:TiledLayer, world:TiledWorld) {
		this.world = world;
		properties = tiledLayer.properties;
		type = tiledLayer.type;
	}
}