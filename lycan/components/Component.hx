package lycan.components;

class Component<T> implements IUpdateable {
	public var entity:T;
	
	public var requiresUpdate:Bool = false;
	public var requiresDraw:Bool = false;
	public var requiresLateUpdate:Bool = false;
	
	public function new(entity:T) {
		this.entity = entity;
	}

	public function update(dt:Float):Void { }

	public function draw():Void { }

	public function lateUpdate(dt:Float):Void { }
}