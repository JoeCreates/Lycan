package lycan.util.queue;

interface Queue<T> {
	function empty():Bool;
	function front():T;
	function back():T;
	function push(e:T):Void;
	function pop():T;
	function remove(e:T):Bool;
	function clear():Void;
	function reserve(i:Int):Void;
	function iterator():ForwardIterator<T>;
	var size(get, null):Int;
}

// Priority queue. The higher the number, the higher the priority.
@:allow(util.PriorityQueueIterator)
class PriorityQueue<T:(IPrioritizable)> implements Queue<T> {	
	private var array:Array<T>;
	public var size(get, null):Int = 0;
	
	public function new() {
		array = new Array<T>();
	}
	
	public function empty():Bool {
		return size == 0;
	}
	
	private function get_size():Int {
		return size;
	}
	
	public function front():T {
		return get(1);
	}
	
	public function back():T {
		if (size == 1) {
			return get(1);
		}
		
		var a = get(1);
		var b = null;
		
		for (i in 2...size + 1) {
			b = get(i);
			if (a.priority > b.priority) {
				a = b;
			}
		}
		
		return a;
	}
	
	public function push(e:T):Void {
		set(++size, e);
		e.position = size;
		upheap(size);
	}
	
	public function pop():T {
		var x = get(1);
		x.position = -1;
		set(1, get(size));
		downheap(1);
		size--;
		return x;
	}
	
	public function remove(e:T):Bool {
		if (empty()) {
			return false;
		}
		
		if (e.position == 1) {
			pop();
		} else {
			var p = e.position;
			set(p, get(size));
			downheap(p);
			upheap(p);
			size--;
		}
		
		return true;
	}
	
	public function clear():Void {
		for (i in 1...array.length) {
			set(i, cast null);
		}
		
		size = 0;
	}
	
	public function iterator():ForwardIterator<T> {
		return new PriorityQueueIterator<T>(this);
	}
	
	public function reserve(i:Int):Void {
		if (size == i) {
			return;
		}
		
		var tmp = array;
		
		array = alloc(i + 1);
		
		set(0, cast null);
		if (size < i) {
			for (i in 1...size + 1) {
				set(i, tmp[i]);
			}
		}
	}
	
	public function free():Void {
		for (i in 0...array.length) {
			set(i, cast null);
		}
	}
	
	private inline function get(i:Int):T {
		return array[i];
	}
	
	private inline function set(i:Int, e:T):Void {
		array[i] = e;
	}
	
	private inline function upheap(index:Int):Void {
		var parent = index >> 1;
		var tmp = get(index);
		var p = tmp.priority;
		
		while (parent > 0) {
			var parentVal = get(parent);
			if (p - parentVal.priority > 0) {
				set(index, parentVal);
				parentVal.position = index;
				index = parent;
				parent >>= 1;
			} else {
				break;
			}
		}
		
		set(index, tmp);
		tmp.position = index;
	}
	
	private inline function downheap(index:Int):Void {
		var child = index << 1;
		var childVal:T;
		
		var tmp = get(index);
		var p = tmp.priority;
		
		while (child < size) {
			if (child < size - 1) {
				if (get(child).priority - get(child + 1).priority < 0) {
					child++;
				}
			}
			
			childVal = get(child);
			
			if (p - childVal.priority < 0) {
				set(index, childVal);
				childVal.position = index;
				tmp.position = child;
				index = child;
				child <<= 1;
			} else {
				break;
			}
		}
		
		set(index, tmp);
		tmp.position = index;
	}
	
	inline private static function alloc<T>(x:Int):Array<T> {		
		var a:Array<T>;
		#if (flash || js)
		a = untyped __new__(Array, x);
		#elseif cpp
		a = new Array<T>();
		a[x - 1] = cast null;
		#else
		a = new Array<T>();
		for (i in 0...x) a[i] = null;
		#end
		return a;
	}
}

interface ForwardIterator<T> {
	function hasNext():Bool;
	function next():T;
	function remove():Void;
}

class PriorityQueueIterator<T:(IPrioritizable)> implements ForwardIterator<T> {	
	private var queue:PriorityQueue<T>;
	private var array:Array<T>;
	private var index:Int = 1;
	private var size:Int;
	
	public function new(q:PriorityQueue<T>) {
		queue = q;
		array = new Array<T>();
		array[0] = null;
	}
	
	public function free():Void {
		array = null;
	}
	
	inline public function hasNext():Bool {
		return index < size;
	}
	
	inline public function next():T {
		return array[index++];
	}
	
	inline public function remove():Void {
		queue.remove(array[index - 1]);
	}
}