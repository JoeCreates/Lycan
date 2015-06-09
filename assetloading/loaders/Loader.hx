package lycan.assetloading.loaders ;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import lycan.assetloading.tasks.ILoadingSignalDispatcher;
import lycan.assetloading.tasks.IRunnable;
import lycan.util.queue.IPrioritizable;
import lycan.util.queue.PriorityQueue;
import lycan.assetloading.tasks.IDescribable;

class Loader<T:(IPrioritizable, IRunnable, ILoadingSignalDispatcher, IDescribable)> {
	private var queue:PriorityQueue<T> = new PriorityQueue<T>();
	public var total_tasks(get, null):Int = 0;
	
	public var signal_started:Signal0 = new Signal0();
	public var signal_task_started:Signal1<String> = new Signal1<String>();
	public var signal_task_progressed:Signal2<String, Float> = new Signal2<String, Float>();
	public var signal_task_completed:Signal1<String> = new Signal1<String>();
	public var signal_task_failed:Signal2<String, String> = new Signal2<String, String>();
	public var signal_completed:Signal0 = new Signal0();
	
	private var processing:Bool = false;
	
	public function addTasks(tasks:Array<T>):Void {
		Sure.sure(!processing);
		
		for (task in tasks) {
			task.signal_started.addOnce(onTaskStarted);
			task.signal_progressed.add(onTaskProgressed);
			task.signal_completed.addOnce(onTaskCompleted);
			task.signal_failed.addOnce(onTaskFailed);
			queue.push(task);
		}
		
		total_tasks = queue.size;
	}
	
	public function start():Void {
		Sure.sure(!processing);
		
		processing = true;
		signal_started.dispatch();
	}
	
	private function onTaskStarted(what:T):Void {
		signal_task_started.dispatch(what.getDescription());
	}
	
	private function onTaskProgressed(what:T, progress:Float):Void {
		signal_task_progressed.dispatch(what.getDescription(), progress);
	}
	
	private function onTaskCompleted(what:T):Void {
		signal_task_completed.dispatch(what.getDescription());
	}
	
	private function onTaskFailed(what:T, error:String):Void {
		signal_task_failed.dispatch(what.getDescription(), error);
	}
	
	private function finish():Void {
		Sure.sure(processing);
		
		processing = false;
		signal_completed.dispatch();
	}
	
	private function get_total_tasks():Int {
		return total_tasks;
	}
	
	public function new() {}
}