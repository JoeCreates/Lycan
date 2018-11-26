package lycan.world.layer;

enum LayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface ILayer {
	public var type(default, null):LayerType;
	public var properties(default, null):Map<String, String>;
	public var world(default, null):World;
}