package lycan.entities;

import flixel.FlxObject;
import flixel.util.FlxColor;
import lycan.game3D.IsoGraphic;
import lycan.game3D.IsoProjection;
import lycan.components.IsoEntity;
import lycan.game3D.components.Position3D;
import lycan.game3D.components.Physics3D;

class IsoSprite extends FlxObject implements Position3D implements Physics3D implements IsoEntity {
	public function new(width:Float = 1, height:Float = 1, depth:Float = 1, ?graphicColor:FlxColor, ?isoProjection:IsoProjection) {
		super();
		iso.graphicBox.makeBox(width, height, depth);
		if (graphicColor != null) {
			if (isoProjection == null) isoProjection = IsoProjection.iso;
			//TODO IsoGraphic.makeBox(this, isoProjection, iso.graphicBox, graphicColor);
			iso.updateHitBox();
		}
	}
	
}