package lycan.components;

class Component<T:Entity> {
	@:isVar public var entity(get, set):T;
	
	public function new(entity:T) {
		this.entity = entity;
	}
	
	private function get_entity():T {
		return entity;
	}
	
	private function set_entity(entity:T):T {
		return this.entity = entity;
	}
}