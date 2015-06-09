package lycan.loading.tasks ;
import lycan.util.queue.IPrioritizable;

class PriorityTask extends Task implements IPrioritizable {
	public var position:Int = 0;
	public var priority:Float;
	
	public function new(priority:Float = 0.0) {
		super();
		this.priority = priority;
	}
}