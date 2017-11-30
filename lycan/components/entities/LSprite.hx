package lycan.components.entities;

import flixel.FlxSprite;
import lycan.components.Attachable;
import lycan.components.CenterPositionable;
import flixel.system.FlxAssets;

class LSprite extends FlxSprite implements Attachable implements CenterPositionable {
	public function new(?x:Float, ?y:Float, ?simpleGraphic:FlxGraphicAsset) super(x, y, simpleGraphic);
	override public function update(dt:Float):Void super.update(dt);
	override public function destroy():Void	super.destroy();
}