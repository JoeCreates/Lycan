package lycan.world.layer;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.group.FlxGroup;
import haxe.ds.StringMap;
import lycan.world.World;
import lycan.world.components.NapeComponent;
import lycan.world.layer.ILayer.LayerType;
import lycan.world.layer.TileLayer;

typedef ObjectLoader = TiledObject->ObjectLayer->FlxBasic;

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
	
	public function load(tiledLayer:TiledObjectLayer, objectLoaders:StringMap<ObjectLoader>):ObjectLayer {
		
		this.properties = tiledLayer.properties;
		
		loadObjects(tiledLayer, objectLoaders);
		processProperties(tiledLayer);
		
		return this;
	}
	
	private function loadObjects(tiledLayer:TiledObjectLayer, objectLoaders:StringMap<ObjectLoader>):ObjectLayer {
		for (o in tiledLayer.objects) {
			if (!objectLoaders.exists(o.type)) {
				FlxG.log.warn("Error loading world. Unknown object type: " + o.type);
				continue;
			}
			
			// Call the loader function for the given object
			var object:FlxBasic = objectLoaders.get(o.type)(o, this);
			
			// Insert the object into the named objects map
			if (o.name != null && o.name != "") {
				if (world.namedObjects.exists(o.name)) {
					throw("Error loading world. Object names must be unique: " + o.name);
				}
				world.namedObjects.set(o.name, object);
			}
			
			// Add the basic to the layer if it exists
			if (object != null) {
				add(object);
			}
		}
		
		for (m in this) {
			if (Std.is(m, FlxObject)) {
				var o:FlxObject = cast m;
				// TODO badness. uses setPosition because this is required for FlxNapeSprite
				o.setPosition(o.x * world.scale.x, o.y * world.scale.y);
				if (o.components.has("nape")) {
					o.components.get("nape").setPosition(o.x, o.y);
				}
				
			}
		}
		
		return this;
	}
	
	private function processProperties(tiledLayer:TiledObjectLayer):ObjectLayer {
		
		return this;
	}
}