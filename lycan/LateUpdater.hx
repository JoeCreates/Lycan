package lycan;

interface LateUpdater extends LateUpdatable {
	public var lateUpdates:List<Float->Void>;	
	
	public function updateLater(updateFunction:Float->Void):Void;
}