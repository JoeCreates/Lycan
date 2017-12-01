package lycan.components.entities;

import flixel.effects.particles.FlxEmitter;
import lycan.components.CameraAttachable;
import flixel.effects.particles.FlxParticle;

class CameraEmitter extends FlxEmitter implements CameraAttachable {
	public function new(?x:Float, ?y:Float, ?size:Int) {super(x, y, size);}
}

class TypedCameraEmitter<T:FlxParticle> extends FlxTypedEmitter<T> implements CameraAttachable {
	public function new(?x:Float, ?y:Float, ?size:Int) {super(x, y, size);}
}