package lycan.world.layer;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.group.FlxGroup;
import lycan.world.World;
import lycan.world.layer.ILayer.LayerType;
import lycan.world.layer.TileLayer;

class ObjectLayer extends FlxGroup implements ILayer {
	public var layerType(default, null):LayerType = LayerType.OBJECT;
	public var world(default, null):World;
	public var properties(default, null):TiledPropertySet;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
	
	public function getBasic():FlxBasic {
		return this;
	}
	
	public function load(tiledLayer:TiledObjectLayer, objectLoaders:ObjectLoaderRules):ObjectLayer {
		
		this.properties = tiledLayer.properties;
		
		loadObjects(tiledLayer, objectLoaders);
		processProperties(tiledLayer);
		
		return this;
	}
	
	private function loadObjects(tiledLayer:TiledObjectLayer, objectLoaders:ObjectLoaderRules):ObjectLayer {
		for (o in tiledLayer.objects) {
			if (objectLoaders.getHandler(o) == null) {
				FlxG.log.warn("Error loading world. Object with this type has no loading handler: " + o.type);
				continue;
			}
			
			// Call the loader functions
			
			// TODO simplify and renamed "loader" terms to "handler"
			// TODO we could essentially just add the handlers to a signal then!!!
			// TODO conditions can be added in many ways, but a function that returns a conditionless handler wrapped in a conditonal handler
			for (loader in objectLoaders.handlers) {
				if (!loader.precondition(o)) continue;
				
				// TODO no need for retruns, make the handler responsible
				var object:FlxBasic = loader.loader(o, this);
				
				if (object != null) {
					// TODO the named objects stuff should be done by overriding add
					// Insert the object into the named objects map
					if (o.name != null && o.name != "") {
						if (world.namedObjects.exists(o.name)) {
							throw("Error loading world. Object names must be unique: " + o.name);
						}
						world.namedObjects.set(o.name, object);
					}
					
					// TODO Remove this, when the handlers deal with it
					// Add the basic to the layer if it exists
					add(object);
				}
			}
		}
		
		for (m in this) {
			if (Std.is(m, FlxObject)) {
				var o:FlxObject = cast m;
				// TODO badness. uses setPosition because this is required for FlxNapeSprite
				o.setPosition(o.x * world.scale.x, o.y * world.scale.y);
				//if (o.components.has("nape")) {
					//var nape:NapeComponent = cast o.components.get("nape");
					//nape.setPosition(o.x, o.y);
				//}
				
			}
		}
		
		return this;
	}
	
	private function processProperties(tiledLayer:TiledObjectLayer):ObjectLayer {
		
		return this;
	}
}