package lycan.components;

import flixel.FlxCamera;
import flixel.FlxG;

interface CameraAttachable extends Entity {
	public var cameraAttachable:CameraAttachableComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
}

class CameraAttachableComponent extends Component<CameraAttachable> {
	public var x:Float;
	public var y:Float;

    public var camera(default, set):FlxCamera;

	public function new(entity:CameraAttachable) {
		super(entity);
		x = 0;
		y = 0;
		
		FlxG.signals.postUpdate.add(updatePosition);
	}
    
    public function update(dt:Float):Void {
		updatePosition();
	}
	
	@:append("destroy")
	public function destroy():Void {
		FlxG.signals.postUpdate.remove(updatePosition);
	}
	
	public function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
	
	public function centerOnCamera():Void {
		if (camera == null) return;
		centerXOnCamera();
		centerYOnCamera();
	}
	
	public function centerXOnCamera():Void {
		if (camera == null) return;
		x = (camera.width - entity.entity_width) / 2;
	}
	
	public function centerYOnCamera():Void {
		if (camera == null) return;
		y = (camera.height - entity.entity_height) / 2;
	}

	public function updatePosition():Void {
		if (camera == null) return;
		entity.entity_x = camera.scroll.x + x;
		entity.entity_y = camera.scroll.y + y;
	}
	
	public function set_camera(camera:FlxCamera):FlxCamera {
		if (camera == this.camera) return camera;
		this.camera = camera;
		updatePosition();
		return camera;
	}
	
}