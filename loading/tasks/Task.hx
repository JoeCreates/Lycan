package lycan.loading.tasks ;

import lycan.util.queue.IPrioritizable;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

class Task implements IRunnable implements IDescribable implements ILoadingSignalDispatcher {
	public var signal_started:Signal1<Dynamic> = new Signal1<Task>();
	public var signal_progressed:Signal2<Dynamic, Float> = new Signal2<Task, Float>();
	public var signal_completed:Signal1<Dynamic> = new Signal1<Task>();
	public var signal_failed:Signal2<Dynamic, String> = new Signal2<Task, String>();
	
	public function new() {
	}
	
	public function run():Void {
		throw "Implement me";
	}
	
	public function getDescription():String {
		throw "Implement me";
	}
}