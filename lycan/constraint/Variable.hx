package lycan.constraint;

class Variable {
	public var name:String;
	public var value:Float;
	
	public function new(name:String) {
		Sure.sure(name != null);
		
		this.name = name;
		this.value = 0;
	}
}