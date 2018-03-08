package lycan.game3D;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxDestroyUtil;
import haxe.ds.Vector;
import lycan.game3D.Box;
import lycan.game3D.components.Physics3D;

/** Based on Octree */
class Octree extends Box {
	
	public static inline var A_LIST:Int = 0;
	public static inline var B_LIST:Int = 1;
	/** Granularity */
	public static var divisions:Int
	public var exists:Bool;

	private var _canSubdivide:Bool;

	private var _headA:LinkedList;
	private var _tailA:LinkedList;

	private var _headB:LinkedList;
	private var _tailB:LinkedList;

	/** Internal, governs and assists with the formation of the tree. */
	private static var _min:Int;
	@:prop(trees[0], trees[0] = param) var treeLowerNorthWest:Octree;
	@:prop(trees[1], trees[1] = param) var treeLowerNorthEast:Octree;
	@:prop(trees[2], trees[2] = param) var treeLowerSouthEast:Octree;
	@:prop(trees[3], trees[3] = param) var treeLowerSouthWest:Octree;
	@:prop(trees[4], trees[4] = param) var treeUpperNorthWest:Octree;
	@:prop(trees[5], trees[5] = param) var treeUpperNorthEast:Octree;
	@:prop(trees[6], trees[6] = param) var treeUpperSouthEast:Octree;
	@:prop(trees[7], trees[7] = param) var treeUpperSouthWest:Octree;
	private var trees:Vector<Octree>;
	
	private var _halfWidth:Float;
	private var _halfHeight:Float;
	private var _halfDepth:Float;
	private var _midpointX:Float;
	private var _midpointY:Float;
	private var _midpointZ:Float;

	private static var _object:Physics3DComponent;
	private static var _objectMinX:Float;
	private static var _objectMaxX:Float;
	private static var _objectMinY:Float;
	private static var _objectMaxY:Float;
	private static var _objectMinZ:Float;
	private static var _objectMaxZ:Float;
	
	private static var _list:Int;
	private static var _useBothLists:Bool;
	private static var _processingCallback:FlxObject->FlxObject->Bool;
	private static var _notifyCallback:FlxObject->FlxObject->Void;
	private static var _iterator:LinkedList;

	private static var _objectHullX:Float;
	private static var _objectHullY:Float;
	private static var _objectHullZ:Float;
	private static var _objectHullWidth:Float;
	private static var _objectHullHeight:Float;
	private static var _objectHullDepth:Float;

	private static var _checkObjectHullX:Float;
	private static var _checkObjectHullY:Float;
	private static var _checkObjectHullZ:Float;
	private static var _checkObjectHullWidth:Float;
	private static var _checkObjectHullHeight:Float;
	private static var _checkObjectHullDepth:Float;
	
	// Caching
	public static  var cachedTreeCount:Int = 0;
	private static var _cachedTreesHead:Octree;
	private var next:Octree;

	private function new(x:Float, y:Float, z:Float, width:Float, height:Float, depth:Float ?parent:Octree) {
		super();
		trees = new Vector<Octree>(8);
		reset(x, y, z, width, height, depth, parent);
	}

	public static function recycle(x:Float, y:Float, z:Float, width:Float, height:Float, depth:Float, ?parent:Octree):Octree {
		if (_cachedTreesHead != null) {
			var cachedTree:Octree = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			cachedTreeCount--;
			cachedTree.reset(x, y, width, height, parent);
			return cachedTree;
		} else
			return new Octree(x, y, width, height, parent);
	}
	
	public static function clearCache():Void {
		// null out next pointers to help out garbage collector
		while (_cachedTreesHead != null) {
			var node = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			node.next = null;
		}
		cachedTreeCount = 0;
	}

	public function reset(x:Float, y:Float, z:Float, width:Float, height:Float, depth:Float, ?parent:Octree):Void {
		exists = true;
		
		set(x, y, z, width, height, depth);
		_headA = _tailA = LinkedList.recycle();
		_headB = _tailB = LinkedList.recycle();
		
		//Copy the parent's children (if there are any)
		if (parent != null) {
			var iterator:LinkedList;
			var ot:LinkedList;
			if (parent._headA.object != null) {
				iterator = parent._headA;
				while (iterator != null) {
					if (_tailA.object != null) {
						ot = _tailA;
						_tailA = LinkedList.recycle();
						ot.next = _tailA;
					}
					_tailA.object = iterator.object;
					iterator = iterator.next;
				}
			}
			if (parent._headB.object != null) {
				iterator = parent._headB;
				while (iterator != null) {
					if (_tailB.object != null) {
						ot = _tailB;
						_tailB = LinkedList.recycle();
						ot.next = _tailB;
					}
					_tailB.object = iterator.object;
					iterator = iterator.next;
				}
			}
		} else {
			_min = Math.floor((width + height) / (2 * divisions));
		}
		_canSubdivide = (width > _min) || (height > _min);

		//Set up comparison/sort helpers
		for (i in 0...8) trees[i] = null;
		
		_halfWidth = width / 2;
		_midpointX = minX + _halfWidth;
		_halfHeight = height / 2;
		_midpointY = minY + _halfHeight;
		_halfDepth = depth / 2;
		_midpointZ = minZ + _halfDepth;
	}
	
	override public function destroy():Void {
		_headA = FlxDestroyUtil.destroy(_headA);
		_headB = FlxDestroyUtil.destroy(_headB);
		_tailA = FlxDestroyUtil.destroy(_tailA);
		_tailB = FlxDestroyUtil.destroy(_tailB);
		
		for (i in 0...8) trees[i] = FlxDestroyUtil.destroy(trees[i]);
		
		_object = null;
		_processingCallback = null;
		_notifyCallback = null;
		
		exists = false;
		
		// Deposit this tree into the linked list for reusal.
		next = _cachedTreesHead;
		_cachedTreesHead = this;
		cachedTreeCount++;
	}

	/**
	 * Load objects and/or groups into the quad tree, and register notify and processing callbacks.
	 * @param ObjectOrGroup1	Any object that is or extends FlxObject or FlxGroup.
	 * @param ObjectOrGroup2	Any object that is or extends FlxObject or FlxGroup.  If null, the first parameter will be checked against itself.
	 * @param NotifyCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):void that is called whenever two objects are found to overlap in world space, and either no ProcessCallback is specified, or the ProcessCallback returns true.
	 * @param ProcessCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):Boolean that is called whenever two objects are found to overlap in world space.  The NotifyCallback is only called if this function returns true.  See FlxObject.separate().
	 */
	public function load(ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:FlxObject->FlxObject->Void, ?ProcessCallback:FlxObject->FlxObject->Bool):Void {
		add(ObjectOrGroup1, A_LIST);
		if (ObjectOrGroup2 != null) {
			add(ObjectOrGroup2, B_LIST);
			_useBothLists = true;
		} else {
			_useBothLists = false;
		}
		_notifyCallback = NotifyCallback;
		_processingCallback = ProcessCallback;
	}

	/**
	 * Call this function to add an object to the root of the tree.
	 * This function will recursively add all group members, but
	 * not the groups themselves.
	 * @param	ObjectOrGroup	FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
	 * @param	List			A int flag indicating the list to which you want to add the objects.  Options are A_LIST and B_LIST.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function add(objectOrGroup:FlxBasic, list:Int):Void {
		_list = list;

		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		// Add a group
		if (group != null) {
			var i:Int = 0;
			var basic:FlxBasic;
			var members:Array<FlxBasic> = group.members;
			var l:Int = group.length;
			while (i < l) {
				basic = members[i++];
				if (basic != null && basic.exists) {
					add(group, list);
				}
			}
		}
		// Add an object
		else {
			_object = (cast objectOrGroup:Physics3D).phys;
			if (_object.exists && _object.allowCollisions != FlxObject.NONE) {
				_objectMinX = _object.hitBox.minX;
				_objectMaxX = _object.hitBox.maxX;
				_objectMinY = _object.hitBox.minY;
				_objectMaxY = _object.hitBox.maxY;
				_objectMinZ = _object.hitBox.minZ;
				_objectMaxZ = _object.hitBox.maxZ;
				addObject();
			}
		}
	}

	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	private function addObject():Void {
		//If this quad (not its children) lies entirely inside this object, add it here
		if (!_canSubdivide || (minX >= _objectMinX && maxX <= _objectMaxX && minY >= _objectMinY && maxY <= _objectMaxY)) {
			addToList();
			return;
		}

		//See if the selected object fits completely inside any of the quadrants
		if ((_objectMinX > minX) && (_objectMaxX < _midpointX)) {
			if ((_objectMinY > minY) && (_objectMaxY < _midpointY)) {
				if (treeLowerNorthWest == null) {
					treeLowerNorthWest = Octree.recycle(minX, minY, _halfWidth, _halfHeight, this);
				}
				treeLowerNorthWest.addObject();
				return;
			}
			if ((_objectMinY > _midpointY) && (_objectMaxY < maxY)) {
				if (treeLowerSouthWest == null) {
					treeLowerSouthWest = Octree.recycle(minX, _midpointY, _halfWidth, _halfHeight, this);
				}
				treeLowerSouthWest.addObject();
				return;
			}
		}
		if ((_objectMinX > _midpointX) && (_objectMaxX < maxX)) {
			if ((_objectMinY > minY) && (_objectMaxY < _midpointY)) {
				if (treeLowerNorthEast == null) {
					treeLowerNorthEast = Octree.recycle(_midpointX, minY, _halfWidth, _halfHeight, this);
				}
				treeLowerNorthEast.addObject();
				return;
			}
			if ((_objectMinY > _midpointY) && (_objectMaxY < maxY)) {
				if (treeLowerSouthEast == null) {
					treeLowerSouthEast = Octree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
				}
				treeLowerSouthEast.addObject();
				return;
			}
		}

		
		//If it wasn't completely contained we have to check out the partial overlaps
		if ((_objectMaxX > minX) && (_objectMinX < _midpointX) && (_objectMaxY > minY) && (_objectMinY < _midpointY)) {
			if (treeLowerNorthWest == null) {
				treeLowerNorthWest = Octree.recycle(minX, minY, _halfWidth, _halfHeight, this);
			}
			treeLowerNorthWest.addObject();
		}
		if ((_objectMaxX > _midpointX) && (_objectMinX < maxX) && (_objectMaxY > minY) && (_objectMinY < _midpointY)) {
			if (treeLowerNorthEast == null) {
				treeLowerNorthEast = Octree.recycle(_midpointX, minY, _halfWidth, _halfHeight, this);
			}
			treeLowerNorthEast.addObject();
		}
		if ((_objectMaxX > _midpointX) && (_objectMinX < maxX) && (_objectMaxY > _midpointY) && (_objectMinY < maxY)) {
			if (treeLowerSouthEast == null) {
				treeLowerSouthEast = Octree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
			}
			treeLowerSouthEast.addObject();
		}
		if ((_objectMaxX > minX) && (_objectMinX < _midpointX) && (_objectMaxY > _midpointY) && (_objectMinY < maxY)) {
			if (treeLowerSouthWest == null) {
				treeLowerSouthWest = Octree.recycle(minX, _midpointY, _halfWidth, _halfHeight, this);
			}
			treeLowerSouthWest.addObject();
		}
	}
	
	private function addToList():Void {
		var ot:LinkedList;
		if (_list == A_LIST) {
			if (_tailA.object != null) {
				ot = _tailA;
				_tailA = LinkedList.recycle();
				ot.next = _tailA;
			}
			_tailA.object = _object;
		} else
		{
			if (_tailB.object != null) {
				ot = _tailB;
				_tailB = LinkedList.recycle();
				ot.next = _tailB;
			}
			_tailB.object = _object;
		}
		if (!_canSubdivide) {
			return;
		}
		for (t in trees) {
			if (t != null) t.addToList;
		}
	}

	/**
	 * Octree's other main function.  Call this after adding objects
	 * using Octree.load() to compare the objects that you loaded.
	 * @return	Whether or not any overlaps were found.
	 */
	public function execute():Bool {
		var overlapProcessed:Bool = false;

		if (_headA.object != null) {
			var iterator = _headA;
			while (iterator != null) {
				_object = iterator.object;
				if (_useBothLists) {
					_iterator = _headB;
				} else {
					_iterator = iterator.next;
				}
				if (_object != null && _object.exists && _object.allowCollisions > 0 &&
						_iterator != null && _iterator.object != null && overlapNode()) {
					overlapProcessed = true;
				}
				iterator = iterator.next;
			}
		}

		//Advance through the tree by calling overlap on each child
		if ((treeLowerNorthWest != null) && treeLowerNorthWest.execute()) {
			overlapProcessed = true;
		}
		if ((treeLowerNorthEast != null) && treeLowerNorthEast.execute()) {
			overlapProcessed = true;
		}
		if ((treeLowerSouthEast != null) && treeLowerSouthEast.execute()) {
			overlapProcessed = true;
		}
		if ((treeLowerSouthWest != null) && treeLowerSouthWest.execute()) {
			overlapProcessed = true;
		}

		return overlapProcessed;
	}

	/**
	 * An internal function for comparing an object against the contents of a node.
	 * @return	Whether or not any overlaps were found.
	 */
	private function overlapNode():Bool {
		//Calculate bulk hull for _object
		_objectHullX = (_object.x < _object.last.x) ? _object.x : _object.last.x;
		_objectHullY = (_object.y < _object.last.y) ? _object.y : _object.last.y;
		_objectHullWidth = _object.x - _object.last.x;
		_objectHullWidth = _object.width + ((_objectHullWidth > 0) ? _objectHullWidth : -_objectHullWidth);
		_objectHullHeight = _object.y - _object.last.y;
		_objectHullHeight = _object.height + ((_objectHullHeight > 0) ? _objectHullHeight : -_objectHullHeight);

		//Walk the list and check for overlaps
		var overlapProcessed:Bool = false;
		var checkObject:FlxObject;

		while (_iterator != null) {
			checkObject = _iterator.object;
			if (_object == checkObject || !checkObject.exists || checkObject.allowCollisions <= 0) {
				_iterator = _iterator.next;
				continue;
			}

			//Calculate bulk hull for checkObject
			_checkObjectHullX = (checkObject.x < checkObject.last.x) ? checkObject.x : checkObject.last.x;
			_checkObjectHullY = (checkObject.y < checkObject.last.y) ? checkObject.y : checkObject.last.y;
			_checkObjectHullWidth = checkObject.x - checkObject.last.x;
			_checkObjectHullWidth = checkObject.width + ((_checkObjectHullWidth > 0) ? _checkObjectHullWidth : -_checkObjectHullWidth);
			_checkObjectHullHeight = checkObject.y - checkObject.last.y;
			_checkObjectHullHeight = checkObject.height + ((_checkObjectHullHeight > 0) ? _checkObjectHullHeight : -_checkObjectHullHeight);

			//Check for intersection of the two hulls
			if ((_objectHullX + _objectHullWidth > _checkObjectHullX) &&
					(_objectHullX < _checkObjectHullX + _checkObjectHullWidth) &&
					(_objectHullY + _objectHullHeight > _checkObjectHullY) &&
					(_objectHullY < _checkObjectHullY + _checkObjectHullHeight)) {
				//Execute callback functions if they exist
				if (_processingCallback == null || _processingCallback(_object, checkObject)) {
					overlapProcessed = true;
					if (_notifyCallback != null) {
						_notifyCallback(_object, checkObject);
					}
				}
			}
			if (_iterator != null) {
				_iterator = _iterator.next;
			}
		}

		return overlapProcessed;
	}
}

// Ugly linkedlist implementation copied from HaxeFlixel 
// Should probably rewrite everything to remove this
private class LinkedList implements IFlxDestroyable
{
	/**
	 * Pooling mechanism, when LinkedLists are destroyed, they get added
	 * to this collection, and when they get recycled they get removed.
	 */
	public static var  _NUM_CACHED_FLX_LIST:Int = 0;
	private static var _cachedListsHead:LinkedList;
	
	/**
	 * Recycle a cached Linked List, or creates a new one if needed.
	 */
	public static function recycle():LinkedList
	{
		if (_cachedListsHead != null)
		{
			var cachedList:LinkedList = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			_NUM_CACHED_FLX_LIST--;
			
			cachedList.exists = true;
			cachedList.next = null;
			return cachedList;
		}
		else
			return new LinkedList();
	}
	
	/**
	 * Clear cached List nodes. You might want to do this when loading new levels
	 * (probably not though, no need to clear cache unless you run into memory problems).
	 */
	public static function clearCache():Void 
	{
		// null out next pointers to help out garbage collector
		while (_cachedListsHead != null)
		{
			var node = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			node.object = null;
			node.next = null;
		}
		_NUM_CACHED_FLX_LIST = 0;
	}
	
	/**
	 * Stores a reference to a FlxObject.
	 */
	public var object:Physics3DComponent;
	/**
	 * Stores a reference to the next link in the list.
	 */
	public var next:LinkedList;
	
	public var exists:Bool = true;
	
	/**
	 * Private, use recycle instead.
	 */
	private function new() {}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		// ensure we haven't been destroyed already
		if (!exists)
			return;
		
		object = null;
		if (next != null)
		{
			next.destroy();
		}
		exists = false;
		
		// Deposit this list into the linked list for reusal.
		next = _cachedListsHead;
		_cachedListsHead = this;
		_NUM_CACHED_FLX_LIST++;
	}
}