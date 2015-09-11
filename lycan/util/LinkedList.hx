package lycan.util;

// A conventional linked list replacement for the Haxe List class. This provides functionality for inserting elements.

// NOTE does not extend the standard List implementation because the iterator() is inlined and cannot be overriden
// TODO complete the unimplemented methods, make sure it all matches up with List
@:generic
class LinkedList<T> {
	private var head:Cell<T>;
	private var tail:Cell<T>;
	public var length(default, null):Int;
	
	public function new() {
		length = 0;
	}
	
	public function filter(f:T->Bool):Dynamic {
		throw "Filter is unimplemented for LinkedList";
	}
	
	public function join(separator:String):String {
		throw "Join is unimplemented for LinkedList";
	}
	
	public function map<V>(f:T->V):List<V> {
		throw "Map is unimplemented for LinkedList";
	}
	
	public function add(item:T):Void {
		Sure.sure(item != null);
		
		var cell = new Cell<T>(item, null);

		if (length == 0) {
			head = cell;
			tail = cell;
		} else {
			tail.next = cell;
			tail = cell;
		}
		
		length++;
	}
	
	public function first():T {
		if (head == null) {
			return null;
		} else {
			return head.element;
		}
	}
	
	public function last():T {
		if (tail == null) {
			return null;
		} else {
			return tail.element;
		}
	}
	
	public function push(item:T):Void {
		Sure.sure(item != null);
		
		var cell = new Cell(item, head);
		head = cell;
		length++;
	}
	
	public function pop():T {
		if (head == null) {
			return null;
		}
		
		var element = head.element;
		head = head.next;
		length--;
		
		return element;
	}
	
	public function remove(item:T):Bool {
		Sure.sure(item != null);
		
		var previous:Cell<T> = null;
		var current:Cell<T> = head;
		
		while (current != null) {
			if (current.element == item) {
				length--;
				if (current == head) {
					head = current.next;
					previous = current.next;
				} else {
					previous.next = previous.next.next;
				}
				
				if (current == tail) {
					tail = previous;
				}
				
				return true;
			}
			
			previous = current;
			current = current.next;
		}
		
		return false;
	}
	
	// Inserts item after the first element that satisfies the predicate
	// Returns true on success, false on failure
	public function insertAfter(item:T, pred:T->Bool):Bool {
		Sure.sure(item != null && pred != null);
		
		var current = head;
		while (current != null) {
			if (pred(current.element)) {
				var cell = new Cell<T>(item, current.next);
				current.next = cell;
				if (cell.next == null) {
					tail = cell;
				}
				return true;
			}
			current = current.next;
		}
		
		return false;
	}
	
	// Inserts item before the first element that satisfies the predicate
	// Returns true on success, false on failure
	public function insertBefore(item:T, pred:T->Bool):Bool {
		Sure.sure(item != null && pred != null);
		
		var current = head;
		var previous:Cell<T> = null;
		while (current != null) {
			if (pred(current.element)) {
				var cell = new Cell<T>(item, current);
				if (previous == null) {
					head = cell;
				} else {
					previous.next = cell;
				}
				return true;
			}
		}
		
		return false;
	}
	
	public function toString():String {
		var buf = new StringBuf();
		var first = true;
		var it:Iterator<T> = iterator();
		buf.add("{");
		
		for (cell in it) {
			if (first) {
				first = false;
			} else {
				buf.add(", ");
			}
			buf.add(cell);
		}
		
		buf.add("}");
		return buf.toString();
	}
	
	public function clear():Void {
		head = null;
		tail = null;
		length = 0;
	}
	
	public inline function isEmpty():Bool {
		return head == null;
	}
	
	public inline function iterator():Iterator<T> {
		return new LinkedListIterator<T>(head);
	}
}

@:generic
class Cell<T> {
	public var element:T;
	public var next:Cell<T>;
	
	public inline function new(element:T, next:Cell<T>) { 
		this.element = element;
		this.next = next;
	}
}

private class LinkedListIterator<T> {
	private var head:Cell<T>;
	private var tmp:T;
	
	public inline function new(head:Cell<T>) {
		this.head = head;
		tmp = null;
	}
	
	public inline function hasNext():Bool {
		return head != null;
	}
	
	public inline function next():T {
		tmp = head.element;
		head = head.next;
		return tmp;
	}
}