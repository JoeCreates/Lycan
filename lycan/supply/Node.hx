package lycan.supply;

import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.FlxG;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;
import haxe.ds.Map;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import lycan.util.structure.tree.EditableIntervalTree;
import flixel.FlxBasic;
import flixel.util.FlxSignal;

class Period {
	public var start:Float;
	public var end:Float;
	public var next:Period;
	
	public function new(start:Float, end:Float) {
		this.start = start;
		this.end = end;
	}
}

class Timeline {
	public var head:Period;
	public var length(default, null):Int;
	public var isEmpty(get, never):Bool;
	private function get_isEmpty():Bool return head == null;
	
	public function new() {
		clear();
	}
	
	public function clear():Void {
		head = null;
		length = 0;
	}
	
	public function addPeriod(start:Float, end:Float):Void {
		if (start >= end) return;
		
		var newPeriod:Period = new Period(start, end);
		length++;		
		
		var p:Period = head;
		var lastP:Period = null;
		// Loop to the next period later than new
		while (p != null && p.start <= newPeriod.start) {
			lastP = p;
			p = p.next;
		}
		// p is now the first period greater than new
		// lastP is the first period lower
		
		// If there is a later period, new period points to it
		if (p != null) {
			newPeriod.next = p;
			consume(newPeriod, p);	
		} 
		// If there is a previous period, it points to the new one
		if (lastP != null) {
			lastP.next = newPeriod;
			consume(lastP, newPeriod);
		} else {
			head = newPeriod;
		}
	}
	
	public function getLast():Period {
		var p = head;
		while (p.next != null) {
			p = p.next;
		}
		return p;
	}
	
	public function add(tl:Timeline) {
		var p = tl.head;
		while (p != null) {
			addPeriod(p.start, p.end);
			p = p.next;
		}
	}
	
	public function difference(tl:Timeline):Timeline {
		var out:Timeline = new Timeline();
		var t:Float = 0; // Current time
		
		var inputOn:Bool = false; // Are we inside an input period?
		var deleteOn:Bool = false; // Are we inside a delete period?
		
		var startT:Float = 0; // Current time of new period
		
		var currentIn:Period = head;
		var currentDelete:Period = tl.head;
		
		var nextInBound:Float;
		var nextDeleteBound:Float;
		
		inline function beginPeriod() startT = t;
		inline function endPeriod()	out.addPeriod(startT, t);
		
		while (currentIn != null || currentDelete != null) {
			if (currentIn != null) {
				nextInBound = !inputOn ? currentIn.start : currentIn.end;
			} else {
				nextInBound = Math.POSITIVE_INFINITY;
			}
			if (currentDelete != null) {
				nextDeleteBound = !deleteOn ? currentDelete.start : currentDelete.end;
			} else {
				nextDeleteBound = Math.POSITIVE_INFINITY;
			}
			
			// If we hit a delete bound
			if (nextDeleteBound < nextInBound) {
				deleteOn = !deleteOn;
				// If we ended a delete, get the next
				if (!deleteOn && currentDelete != null) currentDelete = currentDelete.next;
				t = nextDeleteBound;
				// If input is on
				if (inputOn) {
					// If delete period just started, end current period
					if (deleteOn) {
						endPeriod();
					}
					// Otherwise, delete just ended, we can begin new period
					else {
						beginPeriod();
					}
				}
			}
			// If we hit an input bound
			else if (nextInBound <= nextDeleteBound) {
				inputOn = !inputOn;
				// If we ended an input, get the next
				if (!inputOn && currentIn != null) currentIn = currentIn.next;
				t = nextInBound;
				// If delete isn't on
				if (!deleteOn) {
					// If we just turned input on, start new period
					if (inputOn) {
						beginPeriod();
					}
					// Otherwise, we just ended a period
					else {
						endPeriod();
					}
				}
			}
		}
		
		return out;
	}
	
	function consume(consumer:Period, head:Period):Void {
		// Don't allow consumtion of an earlier period
		if (head.start < consumer.start) return;
		
		// Get latest period within end time
		var lastPeriod:Period = null;
		var current = head;
		// Traverse elements until we reach the end or one out of range
		// (i.e. go over the ones that are overlapping until one doesn't overlap)
		while (current != null && current.start <= consumer.end) {
			lastPeriod = current;
			current = current.next;
			length--;
		}
		
		consumer.next = current;
		
		if (lastPeriod != null) {
			consumer.end = Math.max(consumer.end, lastPeriod.end);
		}
	}
}

class Node<T> extends SignalHolder<T> {
	/** Map of outward edges to their lengths */
	public var outEdges:List<Edge<T>>;
	public var inEdges:List<Edge<T>>;
	
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		super();
		outEdges = new List<Edge<T>>();
		inEdges = new List<Edge<T>>();
		this.x = x;
		this.y = y;
	}
	
	override function updateOutputs(value:Null<T>, dt:Float) {
		for (out in outEdges) {
			out.applySignal(value, dt);
		}
	}
	
	public function addEdgeIn(edge:Edge<T>):Void {
		if (edge.output != null) edge.output.inEdges.remove(edge);
		inEdges.add(edge);
		@:privateAccess edge._output = this;
	}
	
	public function addEdgeOut(edge:Edge<T>):Void {
		if (edge.input != null) edge.input.outEdges.remove(edge);
		outEdges.add(edge);
		@:privateAccess edge._input = this;
	}
	
	public function removeEdgeIn(edge:Edge<T>):Void {
		if (edge.output == this) {
			@:privateAccess edge._output = null;
			inEdges.remove(edge);
		}
	}
	
	public function removeEdgeOut(edge:Edge<T>):Void {
		if (edge.input == this) {
			@:privateAccess edge._input = null;
			outEdges.remove(edge);
		}
	}
	
}

class Edge<T> extends SignalHolder<T> {
	private var _input:Node<T>;
	private var _output:Node<T>;
	public var input(get, set):Node<T>;
	public var output(get, set):Node<T>;
	
	public function new(input:Node<T>, output:Node<T>) {
		super();
		this.output = output;
		this.input = input;
	}
	
	override function updateOutputs(value:Null<T>, dt:Float) {
		if (output != null) {
			output.applySignal(value, dt);
		}
	}
	
	public function destroy() {
		input = null;
		output = null;
	}
	
	private function get_input():Node<T> {
		return _input;
	}
	private function set_input(node:Node<T>):Node<T> {
		if (input != null) input.removeEdgeOut(this);
		if (node != null) node.addEdgeOut(this);
		return node;
	}
	
	private function get_output():Node<T> {
		return _output;
	}
	private function set_output(node:Node<T>):Node<T> {
		if (output != null) output.removeEdgeIn(this);
		if (node != null) node.addEdgeIn(this);
		return node;
	}
}

class EdgeTwoWay<T> extends SignalHolder<T> {
	public var edgeA:Edge<T>;
	public var edgeB:Edge<T>;
	public var nodeA(get, set):Node<T>;
	public var nodeB(get, set):Node<T>;
	
	public function new(nodeA:Node<T>, nodeB:Node<T>) {
		super();
		edgeA = new Edge<T>(nodeA, nodeB);
		edgeB = new Edge<T>(nodeB, nodeA);
	}
	
	override function update(dt:Float) {
		super.update(dt);
		edgeA.update(dt);
		edgeB.update(dt);
	}
	
	override function applySignal(value:Null<T>, dt:Float) {
		super.applySignal(value, dt);
		edgeA.applySignal(value, dt);
		edgeB.applySignal(value, dt);
	}
	
	override private function get_signal():Null<T> {
		if (nodeA != null && nodeA.signal != null) return nodeA.signal;
		if (nodeB != null && nodeB.signal != null) return nodeB.signal;
		return null;
	}
	
	private function get_nodeA():Node<T> {
		return edgeA != null ? edgeA.input : null;
	}
	private function set_nodeA(node:Node<T>):Node<T> {
		edgeA.input = node;
		edgeB.output = node;
		return node;
	}
	private function get_nodeB():Node<T> {
		return edgeA != null ? edgeA.output : null;
	}
	private function set_nodeB(node:Node<T>):Node<T> {
		edgeB.input = node;
		edgeA.output = node;
		return node;
	}
}

@:tink
class SignalHolder<T> {
	@:isVar public var signal(get, set):Null<T>;
	public var lastSignal:Null<T>;
	public var onSignalChanged:FlxTypedSignal<Null<T>->Void>;
	
	public function new() {
		onSignalChanged = new FlxTypedSignal<Null<T>->Void>();
		signal = null;
	}
	
	public function update(dt:Float) {
		lastSignal = signal;
		signal = null;
	}
	
	public function applySignal(value:Null<T>, dt:Float) {
		if (signal == null) {
			signal = value;
			updateOutputs(value, dt);
		}
	}
	
	public function updateOutput(output:SignalHolder<T>, value:Null<T>, dt:Float) {
		output.applySignal(value, dt);
	}
	
	public function updateOutputs(value:Null<T>, dt:Float):Void {
		throw("Requires implementation in subclass");
	}
	
	private function set_signal(value:Null<T>):Null<T> {
		var old:Null<T> = signal;
		this.signal = value;
		if (old != value) onSignalChanged.dispatch(signal);
		return signal;
	}
	private function get_signal():Null<T> {
		return signal;
	}
}