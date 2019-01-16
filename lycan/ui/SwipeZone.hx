package lycan.ui;

import flixel.input.IFlxInput;
import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.input.FlxPointer;
import flixel.FlxObject;

@:tink class SwipeZone extends FlxObject {
	public var currentPointer:FlxPointer;
	public var input:IFlxInput;
	public var startPosition:FlxPoint;
	public var lastPosition:FlxPoint;
	public var currentPosition:FlxPoint;
	
	public var onMove:SwipeZone->Void;
	
	
	@:calc public var startDiffX:Float = currentPosition.x - startPosition.x;
	@:calc public var startDiffY:Float = currentPosition.y - startPosition.y;
	@:calc public var frameDiffX:Float = currentPosition.x - lastPosition.x;
	@:calc public var frameDiffY:Float = currentPosition.y - lastPosition.y;
	
	public function new() {
		super();
		startPosition = FlxPoint.get();
		currentPosition = FlxPoint.get();
		lastPosition = FlxPoint.get();
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		updatePointer(dt);
	}
	
	override function destroy() {
		super.destroy();
		startPosition.put();
		currentPosition.put();
	}
	
	public function updatePointer(dt:Float):Void {
		if (currentPointer != null) {
			// Check for release
			if (!input.pressed) currentPointer = null;
			
		}
		
		// If there is a currentPointer, update position
		if (currentPointer != null) {
			lastPosition.copyFrom(currentPosition);
			currentPointer.getWorldPosition(camera, currentPosition);
			if (!currentPosition.equals(lastPosition) && onMove != null) {
				onMove(this);
			}
		}
		// Otherwise, check for new pointer
		else {
			#if !FLX_NO_MOUSE
				if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) {
					setCurrentPointer(FlxG.mouse, @:privateAccess FlxG.mouse._leftButton);
				}
			#end
			
			#if !FLX_NO_TOUCH
				if (currentPointer == null) {
					for (touch in FlxG.touches.list) {
						if (touch.justPressed && touch.overlaps(this, camera)) {
							setCurrentPointer(touch, touch);
							break;
						}
					}
				}
			#end
		}
		
	}
	
	private function setCurrentPointer(pointer:FlxPointer, input:IFlxInput) {
		if (pointer == currentPointer) return;
		
		currentPointer = pointer;
		this.input = input;
		
		if (currentPointer != null) {
			pointer.getWorldPosition(camera, startPosition);
			pointer.getWorldPosition(camera, currentPosition);
			pointer.getWorldPosition(camera, lastPosition);
		}
	}
}