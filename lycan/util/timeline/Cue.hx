package lycan.util.timeline;

class Cue extends TimelineItem {	
	public function new(target:Dynamic, startTime:Float, ?enterLeft:Int->Void, ?exitRight:Int->Void, ?enterRight:Int->Void, ?exitLeft:Int->Void, removeOnCompletion:Bool = false) {
		super(null, target, startTime, 0);
		this.removeOnCompletion = removeOnCompletion;
		
		if (enterLeft != null) {
			signal_enterLeft.add(enterLeft);
		}
		if (enterRight != null) {
			signal_enterRight.add(enterRight);
		}
		if (exitLeft != null) {
			signal_exitLeft.add(exitLeft);
		}
		if (exitRight != null) {
			signal_exitRight.add(exitRight);
		}
	}
}