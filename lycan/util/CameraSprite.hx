package lycan.util;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

class CameraSprite extends FlxSprite {
	public var sourceCamera:FlxCamera;
	public var group:CameraGroup;
	
	public function new(width:Float = 100, height:Float = 100, x:Float = 0, y:Float = 0, ?sourceCamera:FlxCamera) {
		super(x, y);
		
		if (sourceCamera == null) {
			sourceCamera = new FlxCamera(0, 0, Std.int(width), Std.int(height));
		}
		
		this.sourceCamera = sourceCamera;
		
		this.width = width;
		this.height = height;
		
		makeGraphic(sourceCamera.width, sourceCamera.height, 0, true);
		
		group = new CameraGroup();
		group.camera = sourceCamera;
	}
	
	@:access(flixel.FlxCamera)
	override public function draw():Void {
		if (FlxG.renderTile) {
			sourceCamera.clearDrawStack();
			sourceCamera.canvas.graphics.clear();
		} else {
			sourceCamera.fill(0, false);
		}
		group.draw();
		if (FlxG.renderTile) {
			sourceCamera.render();
		}
		pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
		GraphicUtil.drawCamera(this, sourceCamera);
		super.draw();
	}
	
	override public function update(dt:Float):Void {
		if (frameWidth != sourceCamera.width || frameHeight != sourceCamera.height) {
			makeGraphic(sourceCamera.width, sourceCamera.height, 0, true);
		}
		
		group.update(dt);
		super.update(dt);
	}
}

class CameraGroup extends FlxGroup {
	public function new() {
		super();
	}
	
	override public function add(object:FlxBasic):FlxBasic {
		object.cameras = cameras;
		return super.add(object);
	}
	
	override public function insert(position:Int, object:FlxBasic):FlxBasic {
		object.cameras = cameras;
		return super.insert(position, object);
	}
	
	override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
		for (m in members) {
			m.cameras = cameras;
		}
		return super.set_cameras(Value);
	}
}