package lycan.util;

import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

/**
 * Warning: Strange behavior if you add this sprite to multiple cameras
**/
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
		
		#if !flash
		var texture = FlxG.stage.context3D.createRectangleTexture(sourceCamera.width, sourceCamera.height, BGRA, true);
		pixels = BitmapData.fromTexture(texture);
		#else
		makeGraphic(sourceCamera.width, sourceCamera.height, 0, true);
		#end
		
		group = new CameraGroup();
		group.camera = sourceCamera;
		
		updateCameraPos();
	}
	
	@:access(flixel.FlxCamera)
	override public function draw():Void {
		var onScreen = false;
		for (c in cameras) {
			if (isOnScreen(c)) {
				onScreen = true;
				break;
			}
		}
		if (!onScreen) return;
		drawToSprite();
		super.draw();
	}
	
	@:access(flixel.FlxCamera)
	public function drawToSprite(?sprite:FlxSprite) {
		if (sprite == null) sprite = this;
		
		if (!FlxG.renderBlit) {
			sourceCamera.clearDrawStack();
			sourceCamera.canvas.graphics.clear();
		} else {
			sourceCamera.fill(0, false);
		}
		group.draw();
		if (!FlxG.renderBlit) {
			sourceCamera.render();
		}
		sprite.pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
		GraphicUtil.drawCamera(sprite, sourceCamera);
	}
	
	override public function update(dt:Float):Void {
		if (frameWidth != sourceCamera.width || frameHeight != sourceCamera.height) {
			makeGraphic(sourceCamera.width, sourceCamera.height, 0, true);
		}
		
		group.update(dt);
		super.update(dt);
	}
	
	function updateCameraPos():Void {
		if (scrollFactor != null) {
			getScreenPosition(_point);
			sourceCamera.setPosition(_point.x, _point.y);
		}
	}
	
	override function set_x(x:Float):Float {
		this.x = x;
		updateCameraPos();
		return x;
	}
	
	override function set_y(y:Float):Float {
		this.y = y;
		updateCameraPos();
		return y;
	}
}

class CameraGroup extends FlxGroup {
	public function new() {
		super();
	}
	
	override public function add(object:FlxBasic):FlxBasic {
		setMemberCameras(object);
		return super.add(object);
	}
	
	override public function insert(position:Int, object:FlxBasic):FlxBasic {
		setMemberCameras(object);
		return super.insert(position, object);
	}
	
	private function setMemberCameras(object:FlxBasic):Void {
		object.cameras = cameras;
		if (@:privateAccess object.flixelType == FlxType.GROUP) {
			var group:FlxGroup = cast object;
			group.forEach(function(o:FlxBasic) {o.cameras = cameras;}, true);
		}
	}
	
	override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera> {
		forEach(function(b:FlxBasic) {
			b.cameras = value;
		}, true);
		return super.set_cameras(value);
	}
}