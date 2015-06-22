package lycan.components;

class Component<T> {
	public var entity:T;
	
	public function new(entity:T) {
		this.entity = entity;
	}

	public function update(dt:Float):Void {}
}