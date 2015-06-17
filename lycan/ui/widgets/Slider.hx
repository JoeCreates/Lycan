package lycan.ui.widgets ;

class Slider extends Widget {
	public var minimum:Int;
	public var maximum:Int;
	public var down:Bool;
	public var value:Int;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
}