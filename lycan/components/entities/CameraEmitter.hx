package lycan.components.entities;

import flixel.effects.particles.FlxEmitter;
import lycan.components.CameraAttachable;
import flixel.effects.particles.FlxParticle;

class CameraEmitter extends FlxEmitter implements CameraAttachable {
	public function new(?x:Float, ?y:Float, ?size:Int) {super(x, y, size);}

	override public function update(dt:Float):Void {
		super.update(dt);
	}
}

class TypedCameraEmitter<T:FlxParticle> extends FlxTypedEmitter<T> implements CameraAttachable {
	public function new(?x:Float, ?y:Float, ?size:Int) {super(x, y, size);}

	override public function update(dt:Float):Void {
		super.update(dt);
	}
}