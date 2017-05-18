package lycan.components.entities;

import flixel.effects.particles.FlxEmitter;
import lycan.components.CameraAttachable;

class CameraEmitter extends FlxEmitter implements CameraAttachable {
	public function new(?x:Float, ?y:Float, ?size:Int) {super(x, y, size);}

	override public function update(dt:Float):Void {
		super.update(dt);
	}
}