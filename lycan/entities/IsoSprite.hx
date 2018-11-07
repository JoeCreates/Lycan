package lycan.entities;

import flixel.FlxObject;
import flixel.util.FlxColor;
import lycan.game3D.IsoBox;
import lycan.game3D.IsoGraphicUtil;
import lycan.game3D.IsoProjection;
import lycan.game3D.IsoTile;
import lycan.game3D.components.IsoEntity;
import lycan.game3D.components.Position3D;
import lycan.game3D.components.Physics3D;

class IsoSprite extends FlxObject implements IsoEntity implements Physics3D implements Position3D {
	private static var isoBox:IsoBox = new IsoBox();
	public function new(width:Float = 1, height:Float = 1, depth:Float = 1, ?graphicColor:FlxColor, ?isoProjection:IsoProjection) {
		super();
		
		var phys:Physics3DComponent = this.phys;
		var iso:IsoComponent = this.iso;
		
		phys.hitBox.set(0, 0, 0, width, height, depth);
		
		var widthRemaining:Float = width;
		for (x in 0...Math.ceil(width)) {
			var heightRemaining:Float = height;
			for (y in 0...Math.ceil(height)) {
				var depthRemaining:Float = depth;
				for (z in 0...Math.ceil(depth)) {
					// Add a tile
					var tile:IsoTile = iso.addTile(x, y, z);
					// Make a graphic for the tile is a color was specified
					if (graphicColor != null) {
						if (isoProjection == null) isoProjection = IsoProjection.iso;
						var w:Float = Math.min(1, widthRemaining);
						var h:Float =  Math.min(1, heightRemaining);
						var d:Float = Math.min(1, depthRemaining);
						isoBox.makeBox(w, h, d);
						IsoGraphicUtil.makeBox(tile, isoProjection, isoBox, graphicColor);
						tile.pos3D.subtract((1 - w) / 2, (1 - h) / 2, (1 - d) / 2);
					}
					depthRemaining--;
				}
				heightRemaining--;
			}
			widthRemaining--;
		}
	}
	
}