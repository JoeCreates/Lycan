class Spring extends FlxBasic {
	public var restValue:Float;
	public var value:Float;
	public var diff(get, set):Float;
	public var mass:Float;
	public var springConstant:Float;
	public var velocity:Float;
	public var minPeakForce:Float;
	public var damping:Float;
	
	public var targetObject:Dynamic;
	public var targetProperty:String;
	
	public function new(springConstant:Float = 400, damping:Float = 7, minPeakForce:Float = 2, mass:Float = 1) {
		super();
		this.springConstant = springConstant;
		this.mass = mass;
		velocity = 0;
		this.damping = damping;
		this.minPeakForce = minPeakForce;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		var d = value - restValue;
		var acc:Float = - springConstant * d / mass - (damping) * velocity;
		var velPos:Bool = velocity > 0;
		velocity += acc * dt;
		
		// If we are at peak force (velocity sign just flipped)
		if (velocity > 0 && !velPos || velocity < 0 && velPos) {
			if (Math.abs(acc * mass) < minPeakForce) {
				velocity = 0;
				value = restValue;
			}
		}
		
		value += velocity * dt;
		
		if (targetObject != null) {
			Reflect.setProperty(targetObject, targetProperty, value);
		}
	}
	
	public function setTarget(object:Dynamic, property:String, ?restValue:Float):Void {
		this.targetObject = object;
		this.targetProperty = property;
		this.restValue = restValue != null ? restValue : Reflect.getProperty(object, property);
		this.value = this.restValue;
	}
	
	private function set_diff(diff:Float):Float {
		value = restValue + diff;
		return diff;
	}
	
	private function get_diff():Float {
		return value - restValue;
	}
}