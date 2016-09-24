package lycan.util;

import haxe.ds.StringMap;

interface Named {
	public var name:String;
}

@:autoBuild(lycan.util.NamedCollectionBuilder.build())
class NamedCollection<T:Named> {
	public var list:Array<T>;
	public var map:StringMap<T>;
	
	public function new() {
		list = new Array<T>();
		map = new StringMap<T>();
	}
	
	public function add(t:T):Void {
		map.set(t.name.toLowerCase(), t);
		list.push(t);
	}
}
