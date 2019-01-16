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
	
	/**
	 * The x distance which swipe must move before final swipe position is updated.
	 * Negative means update if y threshold has been crossed
	 */
	public var thresholdX:Float;
	/**
	 * The y distance which swipe must move before final swipe position is updated.
	 * Negative means update if x threshold has been crossed
	 */
	public var thresholdY:Float;
	public var thresholdCrossedX:Bool;
	public var thresholdCrossedY:Bool;
	
	@:calc public var startDiffX:Float = currentPosition.x - startPosition.x;
	@:calc public var startDiffY:Float = currentPosition.y - startPosition.y;
	@:calc public var frameDiffX:Float = currentPosition.x - lastPosition.x;
	@:calc public var frameDiffY:Float = currentPosition.y - lastPosition.y;
	
	public function new(moveThresholdX:Float = 0, moveThresholdY:Float = 0) {
		super();
		startPosition = FlxPoint.get();
		currentPosition = FlxPoint.get();
		lastPosition = FlxPoint.get();
		this.thresholdX = moveThresholdX;
		this.thresholdY = moveThresholdY;
		thresholdCrossedX = false;
		thresholdCrossedY = false;
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
			updateThreshold();
			if (thresholdCrossedX || thresholdCrossedY) {
				currentPointer.getWorldPosition(camera, currentPosition);
				if (!currentPosition.equals(lastPosition) && onMove != null) {
					onMove(this);
				}
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
	
	/**
	 * Set threshold crossed flags based on current position with respect to start position
	 */
	private function updateThreshold() {
		if (!thresholdCrossedX && thresholdX >= 0 && Math.abs(currentPointer.x - startPosition.x) >= thresholdX) {
			thresholdCrossedX = true;
			if (thresholdY < 0) thresholdCrossedY = true;
		}
		if (!thresholdCrossedY && thresholdY >= 0 && Math.abs(currentPointer.y - startPosition.y) >= thresholdY) {
			thresholdCrossedY = true;
			if (thresholdX < 0) thresholdCrossedX = true;
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
			thresholdCrossedX = false;
			thresholdCrossedY = false;
		}
	}
}