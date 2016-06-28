package lycan.util.structure.tree;

// Interval tree based on solutions to pp. 348-354 of Introduction to Algorithms (3rd ed.) by Cormen et al.
// It's an augmented RB tree that keeps track of the max upper bound of intervals for all subtrees
class EditableIntervalTree {
	private var root(default, null):Node;
	private var nil:Node; // Sentinel node, used for terminal nodes instead of handling null or loads of separate empty nodes

	public function new() {
		nil = Node.makeEmpty();
		root = nil;
	}

	// Insert an interval, returns a node representing that interval
	public function insert(start:Float, end:Float):Interval {
		Sure.sure(start <= end);

		var x = root;
		var y = nil;

		while (x != nil) {
			y = x;
			if (x.start > start) {
				x = x.left;
			} else {
				x = x.right;
			}
		}

		var tmp = new Node(start, end, end, RED, nil, nil, y);
		if (tmp.parent == nil) {
			root = tmp;
		} else {
			if (start < y.start) {
				y.left = tmp;
			} else {
				y.right = tmp;
			}
		}
		x = tmp;

		while (x != root && x.max > x.parent.max) {
			x.parent.max = x.max;
			x = x.parent;
		}

		redify(tmp);

		return tmp;
	}

	// Delete a specific node
	public function delete(n:Node):Void {
		Sure.sure(n != null);

		var x = nil;
		var y = nil;

		if (n.left == nil || n.right == nil) {
			y = n;
		} else {
			y = successor(n);
		}

		if (y.left != nil) {
			x = y.left;
		} else {
			x = y.right;
		}
		x.parent = y.parent;

		if (y.parent == nil) {
			root = x;
		} else {
			if (y == y.parent.left) {
				x.parent.left = x;
			} else {
				x.parent.right = x;
			}
		}

		if (y != n) {
			n.start = y.start;
		}

		if (y.color == BLACK) {
			deleteRedify(x);
		}
	}

	// Find the first overlapping node
	// Returns null if no node is found
	public function find(n:Node):Interval {
		Sure.sure(n != null);

		var x = root;
		while (x != nil && !overlap(n, x)) {
			if (x.left != nil && x.left.max >= n.start) {
				x = x.left;
			} else {
				x = x.right;
			}
		}

		if (x == nil) {
			return null;
		}

		return x;
	}

	// Finds the intervals that intersect a point
	public inline function stab(point:Float, result:Array<Node>):Void {
		stabHelper(root, point, result);
	}

	// Finds the intervals that overlap the range
	public inline function findOverlaps(start:Float, end:Float, result:Array<Node>):Void {
		findOverlapsHelper(root, start, end, result);
	}

	// Finds the intervals that partially overlap the range
	public inline function findPartialOverlaps(start:Float, end:Float, result:Array<Node>):Void {
		findPartialOverlapsHelper(root, start, end, result);
	}

	// Finds the intervals that are contained within the range
	public inline function findContained(start:Float, end:Float, result:Array<Node>):Void {
		findContainedHelper(root, start, end, result);
	}

	private function stabHelper(n:Node, point:Float, result:Array<Node>):Void {
		if (n == nil) {
			return;
		}

		if (n.left != nil && n.left.max >= point) {
			stabHelper(n.left, point, result);
		}

		if (point <= n.end && point >= n.start) {
			result.push(n);
		}

		if (n.right != nil) {
			stabHelper(n.right, point, result);
		}
	}

	private function findOverlapsHelper(n:Node, start:Float, end:Float, result:Array<Node>):Void {
		if (n == nil) {
			return;
		}

		if (n.left != nil && n.left.max >= start) {
			findOverlapsHelper(n.left, start, end, result);
		}

		if (n.end >= start && n.start <= end) {
			result.push(n);
		}

		if (n.right != nil) {
			findOverlapsHelper(n.right, start, end, result);
		}
	}

	private function findPartialOverlapsHelper(n:Node, start:Float, end:Float, result:Array<Node>):Void {
		if (n == nil) {
			return;
		}

		if (n.left != nil && n.left.max >= start) {
			findPartialOverlapsHelper(n.left, start, end, result);
		}

		if (n.start <= start && n.end >= start || n.start <= end && n.end >= end) {
			result.push(n);
		}

		if (n.right != nil) {
			findPartialOverlapsHelper(n.right, start, end, result);
		}
	}

	private function findContainedHelper(n:Node, start:Float, end:Float, result:Array<Node>):Void {
		if (n == nil) {
			return;
		}

		if (n.left != nil && n.left.max >= start) {
			findContainedHelper(n.left, start, end, result);
		}

		if (n.start >= start && n.end <= end) {
			result.push(n);
		}

		if (n.right != nil) {
			findContainedHelper(n.right, start, end, result);
		}
	}

	private function leftRotate(n:Node):Void {
		Sure.sure(n != null);

		var y = n.right;
		y.parent = n.parent;

		if (n.parent != nil) {
			if (n == n.parent.left) {
				y.parent.left = y;
			} else {
				y.parent.right = y;
			}
		} else {
			root = y;
		}

		n.right = y.left;

		if (n.right != nil) {
			n.right.parent = n;
		}

		y.left = n;
		n.parent = y;

		n.max = Math.max(Math.max(n.left.max, n.right.max), n.end);
		y.max = Math.max(Math.max(y.left.max, y.right.max), y.end);
	}

	private function rightRotate(n:Node):Void {
		Sure.sure(n != null);

		var y = n.left;
		y.parent = n.parent;

		if (n.parent != nil) {
			if (n == n.parent.left) {
				y.parent.left = y;
			} else {
				y.parent.right = y;
			}
		} else {
			root = y;
		}

		n.left = y.right;

		if (n.left != nil) {
			n.left.parent = n;
		}

		y.right = n;
		n.parent = y;

		n.max = Math.max(Math.max(n.left.max, n.right.max), n.end);
		y.max = Math.max(Math.max(y.left.max, y.right.max), y.end);
	}

	private inline function redify(n:Node):Void {
		Sure.sure(n != null);

		while (n != nil && n.parent != nil && n.parent.parent != nil && n.parent.color == RED) {
			if (n.parent.parent.left == n.parent) {
				if (n.parent.parent.right != nil && n.parent.parent.right.color == RED) {
					n.parent.color = BLACK;
					n.parent.parent.right.color = BLACK;
					n = n.parent.parent;
					n.color = RED;
				} else {
					if (n == n.parent.right) {
						n = n.parent;
						leftRotate(n);
					}
					n.parent.color = BLACK;
					n.parent.parent.color = RED;
					rightRotate(n.parent.parent);
				}
			} else {
				if (n.parent.parent.left != nil && n.parent.parent.left.color == RED) {
					n.parent.color = BLACK;
					n.parent.parent.left.color = BLACK;
					n = n.parent.parent;
					n.color = RED;
				} else {
					if (n == n.parent.left) {
						n = n.parent;
						rightRotate(n);
					}
					n.parent.color = BLACK;
					n.parent.parent.color = RED;
					leftRotate(n.parent.parent);
				}
			}
		}
		root.color = BLACK;
	}

	private inline function deleteRedify(n:Node):Void {
		Sure.sure(n != null);

		var w = Node.makeEmpty();

		while (n != root && n.color == BLACK) {
			if (n.parent.left == n) {
				w = n.parent.right;

				if (w.color == RED) {
					w.color = BLACK;
					w.parent.color = RED;
					leftRotate(w.parent);
					w = w.parent.right;
				} else {
					if (w.left.color == BLACK && w.right.color == BLACK) {
						w.color = RED;
						n = n.parent;
					} else {
						if (w.left.color == RED && w.right.color == BLACK) {
							w.color = RED;
							w.left.color = BLACK;
							rightRotate(w);
							w = n.parent.right;
						}
						w.color = n.parent.color;
						n.parent.color = BLACK;
						w.right.color = BLACK;
						leftRotate(w.parent);
						n = root;
					}
				}
			} else {
				w = n.parent.left;
				if (w.color == RED) {
					w.parent.color = RED;
					w.color = BLACK;
					rightRotate(n.parent);
					w = n.parent.left;
				} else {
					if (w.left.color == BLACK && w.right.color == BLACK) {
						w.color = RED;
						n = n.parent;
					} else {
						if (w.right.color = RED && w.left.color == BLACK) {
							w.color = RED;
							w.right.color = BLACK;
							leftRotate(w);
							w = n.parent.left;
						}
						w.color = w.parent.color;
						w.parent.color = BLACK;
						w.left.color = BLACK;
						rightRotate(w.parent);
						n = root;
					}
				}
			}

			n.color = BLACK;
		}
	}

	private inline function successor(n:Node):Node {
		Sure.sure(n != null);

		if (n.right != nil) {
			return min(n.right);
		}
		var y = n;
		while (y != nil && y == y.parent.right) {
			y = y.parent;
		}
		if (y == nil) {
			return nil;
		} else {
			return y.parent;
		}
	}

	// Returns the smallest node in the tree
	private inline function min(n:Node):Node {
		Sure.sure(n != null);

		if (n.left != nil) {
			return min(n.left);
		} else {
			return n;
		}
	}

	private inline function overlap(a:Node, b:Node):Bool {
		Sure.sure(a != null && b != null);
		return (a.start <= b.end && b.start <= a.end);
	}

	/*
	public function levelorderWalk(n:Node):Void {
		if (n == nil) {
			return;
		}

		var q = new List<Node>();
		q.push(n);

		while (!q.isEmpty()) {
			var u = q.pop();
			trace(u.toString());

			if (u.left != nil) {
				q.push(u.left);
			}
			if (u.right != nil) {
				q.push(u.right);
			}
		}
	}

	public function preorderWalk(n:Node):Void {
		if (n == nil) {
			return;
		}

		trace(n.toString());
		preorderWalk(n.left);
		preorderWalk(n.right);
	}

	public function inorderWalk(n:Node):Void {
		if (n == nil) {
			return;
		}

		inorderWalk(n.left);
		trace(n.toString());
		inorderWalk(n.right);
	}
	*/
}

@:enum abstract Color(Bool) from Bool to Bool {
	var RED = false;
	var BLACK = true;
}

class Node implements Interval {
	public var start:Float; // Lower bound
	public var end:Float; // Upper bound
	public var max:Float; // Max upper bound of any interval stored in the subtree rooted at this node
	public var color:Color;
	public var left:Node;
	public var right:Node;
	public var parent:Node;

	public function new(start:Float, end:Float, max:Float, color:Color, left:Node, right:Node, parent:Node) {
		Sure.sure(start <= end);

		this.start = start;
		this.end = end;
		this.max = max;
		this.color = color;
		this.left = left;
		this.right = right;
		this.parent = parent;
	}

	public static function makeEmpty():Node {
		return new Node(0, 0, 0, RED, null, null, null);
	}

	public function toString():String {
		return "[" + start + "," + end + "]";
	}
}