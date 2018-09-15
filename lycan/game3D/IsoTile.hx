package lycan.game3D;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;

/**
 * The smallest depth sortable graphic in isometric space.
 * Large graphical elements should be split into multiple tiles so that they can be sorted for rendering.
 **/

 @:tink
class IsoTile extends FlxSprite implements Position3D {
	
	public var parent:Position3D;
	/** Point within tile to which 2D graphic is anchored */
	public var anchor3D(default, null):Point3D;
	public var anchor2D(default, null):FlxPoint;
	
	/** Helper point to avoid memory allocations */
	private static var point:FlxPoint = FlxPoint.get();
	private static var point3D:Point3D = Point3D.get();
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0, ?parent:Position3D) {
		super();
		this.parent = parent;
		pos3D.set(x, y, z);
		anchor2D = FlxPoint.get(0.5, 0.5);
		anchor3D = Point3D.get(0.5, 0.5, 0.5);
	}
	
	public function drawIso(?iso:IsoProjection):Void {
		// Determine 3D world anchor point
		point3D.copyFrom(anchor3D);
		point3D.addPoint(pos3D.point);
		
		if (iso == null) iso = IsoProjection.iso;
		if (parent != null) point3D.addPoint(parent.pos3D.point);
		
		iso.toCart(point, point3D);
		
		setPosition(point.x - anchor2D.x * frameWidth, point.y - anchor2D.y * frameHeight);
		
		draw();
	}
	
	public function anchor(x:Float = 0.5, y:Float = 0.5, z:Float = 0.5, cartX:Float = 0.5 , cartY:Float = 0.5):IsoTile {
		anchor3D.set(x, y, z);
		anchor2D.set(cartX, cartY);
		return this;
	}
	
}