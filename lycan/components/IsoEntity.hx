package lycan.components;

import haxe.ds.Vector;
import lycan.game3D.Box;
import lycan.game3D.IsoBox;
import lycan.game3D.components.Position3D;
import lycan.game3D.components.Physics3D;

interface IsoEntity extends Entity {
	public var iso:IsoComponent;
	public var pos3D:Position3DComponent;
	public var phys:Physics3DComponent;
}

@:tink
class IsoComponent extends Component<IsoEntity> {
	
	public var graphicBox:IsoBox;
	public var graphicAABB:Box;
	@:calc public var phys:Physics3DComponent = entity.phys;
	@:calc public var pos:Position3DComponent = entity.pos3D;
	
	private var sortDepth:Int;
	private var sortEntitiesBehind:Vector<IsoComponent>;
	private var sortVisited:Bool;
	
	public function new(entity:IsoEntity) {
		super(entity);
		
		graphicBox = new IsoBox();
		graphicAABB = new Box();
	}
	
	/** Set the size and position of hitbox to be the bounds of the graphic box */
	public function updateHitBox(recalcateBounds:Bool = true):Void {
		if (recalcateBounds) graphicBox.updateBounds();
		phys.hitBox.pos.set(graphicBox.minX, graphicBox.minY, graphicBox.minZ);
		phys.hitBox.setSize(graphicBox.width, graphicBox.height, graphicBox.depth);
	}
	
	public function updateAABB(recalcateBounds:Bool = true):Void {
		if (recalcateBounds) graphicBox.updateBounds();
		graphicAABB.pos.set(graphicBox.minX, graphicBox.minY, graphicBox.minZ).addPoint(pos.point);
		graphicAABB.setSize(graphicBox.width, graphicBox.height, graphicBox.depth);
	}
}