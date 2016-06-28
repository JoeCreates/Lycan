package lycan.ai;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

class IntentQueue<T> {
	private var queue:Array<T> = new Array<T>();
	public var signal_activeIntentChanged(default, null) = new Signal2<T, T>(); // Dispatched when the intent at the head of the queue changes
	public var signal_queueReplaced(default, null) = new Signal2<Array<T>, Array<T>>(); // Dispatched when the queue is replaced
	public var signal_intentPushed(default, null) = new Signal1<T>(); // Dispatched when an intent is pushed
	public var signal_intentPopped(default, null) = new Signal1<T>(); // Dispatched when an intent is popped
	
	// TODO implement notion of disabling manual intent changes
	// If busy, queue the intent, otherwise do it straight away
	//if (!canChangeIntent) {
	//  return nextIntent = intent;
	//}
	
	public inline function new() {
		#if debug
		signal_intentPushed.add(function(t:T):Void {
			trace("Pushed intent: " + Std.string(t));
		});
		signal_intentPopped.add(function(t:T):Void {
			trace("Popped intent: " + Std.string(t));
		});
		signal_queueReplaced.add(function(t:Array<T>, next:Array<T>):Void {
			trace("Replaced queue. Active intent was: " + Std.string(t) + ", new queue is: " + Std.string(next));
		});
		signal_activeIntentChanged.add(function(last:T, next:T):Void {
			trace("Active intent changed. Last was: " + Std.string(last) + ", next is: " + Std.string(next));
		});
		#end
	}
	
	// Add intent to the end of the queue
	public inline function push(intent:T):Void {
		var front = front();
		queue.push(intent);
		signal_intentPushed.dispatch(intent);
		if(front == null) {
			signal_activeIntentChanged.dispatch(front, intent);
		}
	}
	
	public inline function pop():Null<T> {
		if (isEmpty()) {
			return null;
		}
		var last = queue.shift();
		signal_activeIntentChanged.dispatch(last, front());
		signal_intentPopped.dispatch(last);
		return last;
	}
	
	// Cancel all intents
	public inline function clear():Void {
		var copy = copy();
		var front = front();
		queue = [];
		signal_activeIntentChanged.dispatch(front, null);
		signal_queueReplaced.dispatch(copy, queue);
	}
	
	// Cancel all intents and replace with the new intent
	public inline function replaceQueueWithIntent(intent:T):Void {
		var copy = copy();
		var front = front();
		queue = [];
		queue.push(intent);
		signal_activeIntentChanged.dispatch(front, intent);
		signal_queueReplaced.dispatch(copy, [intent]);
	}
	
	// Cancel all intents and replace with the new list of intents
	public inline function replaceQueue(intents:Array<T>):Void {
		var copy = copy();
		var front = front();
		queue = intents;
		signal_activeIntentChanged.dispatch(front, queue.length == 0 ? null : queue[0]);
		signal_queueReplaced.dispatch(copy, intents);
	}
	
	public inline function isEmpty():Bool {
		return queue.length == 0;
	}
	
	/*
	public inline function contains(intent:T):Bool {
		for (item in queue) {
			if (intent.equals(item)) {
				return true;
			}
		}
		return false;
	}
	*/
	
	/*
	public inline function hasOrderedIntents(intents:Array<T>):Bool {
		return false; // TODO
	}
	
	public inline function cancelOrderedIntents(intents:Array<T>):Void {
		// TODO
	}
	
	public inline function cancelIntents(intents:Array<T>):Void {
		queue.re
	}
	*/
	
	public inline function front():Null<T> {
		return queue.length == 0 ? null : queue[0];
	}
	
	public inline function copy():Array<T> {
		return queue.copy();
	}
}