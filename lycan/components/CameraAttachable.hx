package lycan.components;

import flixel.FlxCamera;

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
	public var paddingX:Float = 0;
	public var paddingY:Float = 0;

	public function new(entity:CameraAttachable) {
		super(entity);
	}
    
     @:append("update") public function update(dt:Float):Void {
		updatePosition();
		updateSize();
	}

	public function setPadding(x:Float, y:Float):Void {
		paddingX = x;
		paddingY = y;
	}

	public function centerOnCamera():Void {
		if (camera == null) return;
		updateSize();
		x = (camera.width - entity.entity_width) / 2;
		y = (camera.height - entity.entity_height) / 2;
	}

	public function updatePosition():Void {
		if (camera == null) return;
		entity.entity_x = camera.scroll.x + x;
		entity.entity_y = camera.scroll.y + y;
	}

	public function updateSize():Void {
		if (camera == null) return;
		entity.entity_width = camera.width + paddingX;
		entity.entity_height = camera.height + paddingY;
	}
	
	public function set_camera(camera:FlxCamera):FlxCamera {
		if (camera == this.camera) return camera;
		this.camera = camera;
		updatePosition();
		return camera;
	}
	
}