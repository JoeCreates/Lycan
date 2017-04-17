package lycan.components;

class Component<T:Entity> {
	public var entity:T;
	
	public function new(entity:T) {
		this.entity = entity;
	}
}