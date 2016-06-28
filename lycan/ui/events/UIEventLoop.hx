package lycan.ui.events;

import lycan.ui.core.UIApplicationRoot;
import lycan.ui.UIObject;

class UIPostEvent {
	public var receiver:UIObject;
	public var event:UIEvent;
	
	public function new(receiver:UIObject, event:UIEvent) {
		this.receiver = receiver;
		this.event = event;
	}
}

@:access(lycan.ui.core.UIApplicationRoot)
class UIEventLoop {
	private var events = new List<UIPostEvent>();
	private var application:UIApplicationRoot;
	
	public function new(application:UIApplicationRoot) {
		this.application = application;
	}
	
	// TODO consider the fastest data structure and how else to make this faster somehow
	public function process() {
		for (event in events) {
			// TODO should notify even if item isn't enabled?
			application.notify(event.receiver, event.event);
		}
		
		clear();
	}
	
	public function add(receiver:UIObject, event:UIEvent) {
		events.add(new UIPostEvent(receiver, event));
	}
	
	public function clear() {
		events.clear();
	}
}