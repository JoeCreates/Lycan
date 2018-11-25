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

class TimelineSprite extends FlxSprite {
	var justPressedPosition:FlxPoint;
	var justReleasedPosition:FlxPoint;
	public var timeline:Timeline;
	var text:FlxText;
	var pressed:Bool = false;
	
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		justPressedPosition = FlxPoint.get();
		justReleasedPosition = FlxPoint.get();
		timeline = new Timeline();
		text = new FlxText();
		
		makeGraphic(400, 100, 0x44ffffff, true);
		updateHitbox();
	}
	
	override function draw() {
		super.draw();
		text.draw();
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		if (FlxG.mouse.justPressed) {
			FlxG.mouse.getScreenPosition(justPressedPosition);
			if (justPressedPosition.y >= y && justPressedPosition.y < y + height) {
				pressed = true;
			}
		}
		if (FlxG.mouse.justReleased && pressed) {
			pressed = false;
			FlxG.mouse.getScreenPosition(justReleasedPosition);
			var start:Float = FlxMath.bound(justPressedPosition.x - x, 0, width);
			var end:Float = FlxMath.bound(justReleasedPosition.x - x, 0, width);
			
			if (start > end) {
				var temp = start;
				start = end;
				end = temp;
			}
			
			timeline.addPeriod(start, end);
		}
		
		FlxSpriteUtil.fill(this, 0x44ffffff);
		
		var p:Period = timeline.head;
		var cy:Float = 15;
		while (p != null) {
			FlxSpriteUtil.drawLine(this, p.start, 5, p.end, 5);
			FlxSpriteUtil.drawLine(this, p.start, cy, p.end, cy);
			cy += 10;
			p = p.next;
		}
		
		text.text = Std.string(timeline.length);
		text.x = x;
		text.y = y;
		text.cameras = this.cameras;
		text.update(dt);
	}
}

class SignalSystem extends FlxBasic {
	public var edges:List<Edge>;
	public var nodes:List<Node>;
	public var supplies:List<Node>;
	
	
	public function new() {
		super();
		edges = new List<Edge>();
		nodes = new List<Node>();
		supplies = new List<Node>();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		for (e in edges) e.update(dt);
		for (n in nodes) n.update(dt);
		for (s in supplies) s.update(dt);
	}
}

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

class Node extends SignalHolder {
	/** Map of outward edges to their lengths */
	public var outEdges:List<Edge>;
	public var inEdges:List<Edge>;
	
	public function new() {
		super();
		outEdges = new List<Edge>();
		inEdges = new List<Edge>();
		signalOn = false;
	}
	
	override function updateOutputs(timeline:Timeline) {
		for (out in outEdges) {
			out.addSignalTimeline(timeline);
		}
	}
	
	public function addEdgeIn(edge:Edge):Void {
		if (edge.output != null) edge.output.inEdges.remove(edge);
		inEdges.add(edge);
		@:privateAccess edge._output = this;
	}
	
	public function addEdgeOut(edge:Edge):Void {
		if (edge.input != null) edge.input.outEdges.remove(edge);
		outEdges.add(edge);
		@:privateAccess edge._input = this;
	}
	
}

class Edge extends SignalHolder {
	private var _input:Node;
	private var _output:Node;
	public var input(get, set):Node;
	public var output(get, set):Node;
	
	public function new(input:Node, output:Node, length:Float = 1) {
		super();
		this.output = output;
		this.input = input;
		
		propagationTime = 1;
		depropagationTime = 1;
	}
	
	override function updateOutputs(timeline:Timeline) {
		if (output != null) {
			output.addSignalTimeline(timeline);
		}
	}
	
	private function get_input():Node {
		return _input;
	}
	private function set_input(node:Node):Node {
		if (node != null) node.addEdgeOut(this);
		return node;
	}
	
	private function get_output():Node {
		return _output;
	}
	private function set_output(node:Node):Node {
		if (node != null) node.addEdgeIn(this);
		return node;
	}
}

class SignalHolder {
	private var currentDt:Float;
	/** Timeline of signals recieved from inputs */
	private var inputTimeline:Timeline;
	/** Timeline of when this node is propagated */
	private var propagationTimeline:Timeline;
	public var signalOn = false;
	/** Propagation level required to be on */
	//public var length:Float;
	public var lastPropagation:Float;
	public var lastSignalOn:Bool;
	// Between 0 and 1
	public var propagation:Float;
	public var propagationTime:Float;
	public var depropagationTime:Float;
	
	public var canPropagate:Bool;
	
	public function new() {
		inputTimeline = new Timeline();
		propagationTimeline = new Timeline();
		propagation = 0;
		lastPropagation = 0;
		lastSignalOn = false;
		propagationTime = 0.1;
		depropagationTime = 0.1;
	}
	
	public function update(dt:Float) {
		
		currentDt = dt;
		inputTimeline.clear();
		propagationTimeline.clear();
		lastPropagation = propagation;
		lastSignalOn = signalOn;
		updatePropagationTimeline(inputTimeline);
		updateOutputs(propagationTimeline);
	}
	
	public function addSignal():Void {
		var t = new Timeline();
		t.addPeriod(0, currentDt);
		addSignalTimeline(t);
	}
	
	public function addSignalTimeline(timeline:Timeline):Void {
		timeline = timeline.difference(inputTimeline);
		if (timeline.isEmpty) return;
		FlxG.watch.addQuick("adding to signal timeline", "");
		inputTimeline.add(timeline);
		updatePropagationTimeline(inputTimeline);// TODO could be more efficient to check if there is a change before updating outputs
		updateOutputs(propagationTimeline);
	}
	
	public function updatePropagationTimeline(input:Timeline):Void {
		
		
		FlxG.watch.addQuick("Updating prop timeline", "");
		
		var startProp:Float = lastPropagation;
		var currentProp:Float = startProp;
		var ip:Period = inputTimeline.head;
		var t:Float = 0;
		var inputOn:Bool = false;
		var onTime:Float = lastSignalOn ? 0 : Math.POSITIVE_INFINITY;
		
		var bound:Float = currentDt;
		var nextT:Float = 0;
		var dt:Float = currentDt;
		while (ip != null) {
			t = nextT;
			bound = inputOn ? ip.end : ip.start;
			nextT = Math.max(bound, currentDt);
			dt = nextT - t;
			
			// Figure out when signalOn next changes (propagation == 1 || 0)
			if (!inputOn && currentProp < 1) {
				// when does currentProp + dt / propagationTime = 1
				onTime = t + (1 - currentProp) * propagationTime;
				if (onTime <= currentDt) signalOn = true;
				currentProp += dt / propagationTime;
			} else if (inputOn && currentProp > 0) {
				// when does currentProp - dt / depropagationTime = 0
				var offTime = t + currentProp * depropagationTime;
				if (offTime <= currentDt) signalOn = false;
				// Add to propagationTimeline
				propagationTimeline.addPeriod(onTime, Math.min(nextT, offTime));
				currentProp -= dt / depropagationTime;
			}
			
			// Bound currentProp
			currentProp = Math.max(0, Math.min(1, currentProp));
			
			inputOn = !inputOn;
			ip = ip.next;
		}
		if (t < currentDt) {
			propagationTimeline.addPeriod(onTime, currentDt);
		}
		propagation = currentProp;
	}
	
	public function updateOutputs(timeline:Timeline):Void {
		throw("Requires implementation in subclass");
	}
}