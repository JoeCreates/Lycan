package lycan.components;

import lycan.components.Component;
import lycan.components.Entity;
import lycan.core.LG;

interface LateUpdatable extends Entity {
	public var lateUpdatable:LateUpdatableComponent;
	public function lateUpdate(dt:Float):Void;
	@:relaxed public var exists(get, set):Bool;
	@:relaxed public var active(get, set):Bool;
}

class LateUpdatableComponent extends Component<LateUpdatable> {
	public function new(entity:LateUpdatable) {
		super(entity);
		
		LG.lateUpdate.add(lateUpdate);
	}
	
	@:append("destroy") public function destroy() {
		LG.lateUpdate.remove(lateUpdate);
	}
	
	public function lateUpdate(dt):Void {
		if (entity.entity_exists && entity.entity_active) {
			entity.lateUpdate(dt);
		}
	}
}