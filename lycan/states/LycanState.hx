package lycan.states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxColor;
import lycan.util.MasterCamera;

// Base state for all substates in a game
class LycanState extends FlxSubState {
	#if debug
	private var updatesWithoutLateUpdates:Int = 0; // Double check lateupdate is being called // TODO remove
	#end

	public var uiGroup(default, null):FlxSpriteGroup;
	public var uiCamera(default, null):FlxCamera;
	public var worldCamera(default, null):FlxCamera;

	public var worldZoom(default, set):Float;
	public var baseZoom:Float;

	public var zoomTween(default, null):FlxTween;

	// Tweens that should be cancelled before another tween of the same ID plays
	public var exclusiveTweens:Map<String, FlxTween>;
	
	public var overlay:FlxSprite;
	public var overlayColor(default, set):FlxColor;
	
	override public function create():Void {
		super.create();
		
		exclusiveTweens = new Map<String, FlxTween>();
		
		// Cameras TODO messy removal of original camera
		worldCamera = new MasterCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), 
		                         FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
		uiCamera = new FlxCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), 
		                         FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.remove(FlxG.camera);
		FlxG.camera = worldCamera;
		FlxG.cameras.add(worldCamera);
		FlxG.cameras.add(uiCamera);
		
		FlxCamera.defaultCameras = [worldCamera];

		baseZoom = worldCamera.zoom;
		worldZoom = 1;

		uiGroup = new FlxSpriteGroup();
		uiGroup.scrollFactor.set(0, 0);
		uiGroup.cameras = [uiCamera];
		add(uiGroup);
		overlay = new FlxSprite();
		overlay.scrollFactor.set();
		overlayColor = FlxColor.BLACK;
		overlay.alpha = 0;
		uiGroup.add(overlay);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		//updatesWithoutLateUpdates++;
		//if (updatesWithoutLateUpdates > 1) {
			//throw("lateUpdate has not been called since last update");
		//}
	}
	
	public function lateUpdate(dt:Float):Void {
		//updatesWithoutLateUpdates = 0;
		
		//forEach(function(o:FlxBasic) {
			//if (Std.is(o, LateUpdatable)) {
				//var u:LateUpdatable = cast o;
				//u.lateUpdate(dt);
			//}
		//}, true);
	}
	
	public function exclusiveTween(id:String, object:Dynamic, values:Dynamic, duration:Float = 1, ?options:TweenOptions):FlxTween {
		if (exclusiveTweens.exists(id)) {
			exclusiveTweens.get(id).cancel();
		}
		var tween:FlxTween = FlxTween.tween(object, values, duration, options);
		exclusiveTweens.set(id, tween);
		return tween;
	}

	public function zoomTo(zoom:Float, duration:Float = 0.5, ?ease:Float->Float):FlxTween {
		if (ease == null) {
			ease = FlxEase.quadInOut;
		}
		if (zoomTween != null) {
			zoomTween.cancel();
		}
		zoomTween = FlxTween.tween(this, { worldZoom: zoom }, duration, { type: FlxTween.ONESHOT, ease: ease } );
		return zoomTween;
	}

	// Sets world and camera zoom
	private function set_worldZoom(worldZoom:Float):Float {
		worldCamera.zoom = baseZoom * worldZoom;
		return this.worldZoom = worldZoom;
	}
	private function set_overlayColor(color:FlxColor):FlxColor {
		overlayColor = color;
		overlay.makeGraphic(FlxG.width, FlxG.height, color, true, "lycan.states.LycanState.overlay");
		return color;
	}
	// TODO autotweening
	// TODO camera targeting
	// TODO sound fading
}