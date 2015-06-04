package world;

enum WorldLayerType {
	TILE;
	OBJECT;
	OTHER;
}

interface WorldLayer {
	
	public var layerType:WorldLayerType;
	public var world:World;
	
}