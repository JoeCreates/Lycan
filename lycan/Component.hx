package lycan;
import flixel.FlxObject;

//TODO actually make entity
class Component {

	public var entity:FlxObject;
	
	public function new(?entity:FlxObject) {
		this.entity = entity;
	}
	
}