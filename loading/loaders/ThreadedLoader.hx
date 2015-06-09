package lycan.loading.loaders;

import openfl.events.Event;
import openfl.Lib;
import lycan.loading.tasks.IDescribable;
import lycan.loading.tasks.ILoadingSignalDispatcher;
import lycan.loading.tasks.IRunnable;
import lycan.util.queue.IPrioritizable;

#if neko
import neko.vm.Thread;
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
import cpp.vm.Thread;
#else
// Other platforms don't have Haxe threading support, so fake it instead
typedef ThreadedLoader<T:(IPrioritizable, IRunnable, ILoadingSignalDispatcher, IDescribable)> = EventPumpLoader<T>;
#end

#if (neko || cpp)

enum TaskSignalId {
	STARTED;
	PROGRESSED;
	COMPLETED;
	FAILED;
}

typedef SignalSpec = {
	id:TaskSignalId,
	description:String,
	?progress:Float,
	?error:String
}

// Loader that uses a separate thread to perform tasks asynchronously. Must be instantiated from the main thread.
class ThreadedLoader<T:(IPrioritizable, IRunnable, ILoadingSignalDispatcher, IDescribable)> extends Loader<T> {
	private var mainThread:Thread;
	private var workerThread:Thread;
	private var signalMutex:Mutex = new Mutex(); // This locks whilst handling/adding messages/events about what signals to dispatch
	
	private var completed:Int = 0;
	private var failed:Int = 0;
	
	override public function start():Void {
		super.start();
		mainThread = Thread.current();
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, pumpMessages);
		workerThread = Thread.create(function():Void {
			var empty = queue.empty();
			while (!empty) {
				var task:T = queue.pop();
				empty = queue.empty();
				task.run();
			}
		});
	}
	
	// TODO if we connect slots to tasks' signals, then with this loader those slots will be called from the worker thread, not the main thread, which probably isn't what we want to do
	// most of the time we will want the main thread to call the tasks' slots. typical scenarios e.g. display a sprite or play some music as soon as it finishes loading
	// one way to do this might be to give each task a unique id that could be registered with a callback for the loader to detect the event e.g. loader.addCbOnTaskProgressed(task.id, function)
	// an alternative solution would be to let tasks persist in a threadsafe data structure, then only pass instructions about what to do with tasks between threads e.g. mainThread.sendMessage(taskRef, dispatchSignal)
	
	// Signals from tasks should be called from the main thread, so are converted to messages and processed on the main thread each frame
	private function pumpMessages(e:Event):Void {
		signalMutex.acquire();
		var spec:SignalSpec = Thread.readMessage(false);
		while (spec != null) {
			switch(spec.id) {
				case STARTED:
					signal_task_started.dispatch(spec.description);
					break;
				case PROGRESSED:
					signal_task_progressed.dispatch(spec.description, spec.progress);
					break;
				case COMPLETED:
					signal_task_completed.dispatch(spec.description);
					completed++;
					break;
				case FAILED:
					signal_task_failed.dispatch(spec.description, spec.error);
					failed++;
					break;
			}			
			spec = Thread.readMessage(false);
		}
		
		if (completed + failed >= total_tasks) {
			finish();
		}
		
		signalMutex.release();
	}
	
	private function sendMessage(spec:SignalSpec):Void {
		signalMutex.acquire();
		mainThread.sendMessage(spec);
		signalMutex.release();
	}
	
	override private function onTaskStarted(what:T):Void {
		sendMessage({ id: STARTED, description: what.getDescription() });
	}
	
	override private function onTaskProgressed(what:T, progress:Float):Void {
		sendMessage({ id: PROGRESSED, description: what.getDescription(), progress:progress });
	}
	
	override private function onTaskCompleted(what:T):Void {
		sendMessage({ id: COMPLETED, description: what.getDescription() });
	}
	
	override private function onTaskFailed(what:T, error:String):Void {
		sendMessage({ id: FAILED, description: what.getDescription(), error: error });
	}
	
	override private function finish():Void {
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, pumpMessages);
		super.finish();
	}
}
#end