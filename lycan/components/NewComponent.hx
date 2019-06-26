// import haxe.ds.StringMap;

// class Test {
//   static function main() {
    
//     trace("Haxe is great!");
    
//     var e = new Entity();
//     e.addComponent(IntComponent);
//     trace(e.getComponent(IntComponent).int);
    
//   }
// }

// class Entity {
//   public var components:ClassMap<Class<Component>, Component> = new ClassMap<Class<Component>, Component>();
  
//   public function new() {
    
//   }
  
//   public function getComponent<C:Component>(componentClass:Class<C>):Null<C> {
//     return cast components.get(cast componentClass);
//   }
  
//   public function addComponent(componentClass:Class<Component>, ?args:Array<Dynamic>) {
//     if (args == null) args = [];
//     components.set(componentClass, Type.createInstance(componentClass, args));
//   }
  
// }

// class Component {
//   public function new() {
    
//   }
// }

// class IntComponent extends Component {
//   public var int:Int;
//   public function new() {
//     super();
//     this.int = 10;
//   }
// }

// class ClassMap<K:Class<Dynamic>, V> implements Map.IMap<K, V>
// {
//     var valueMap:StringMap<V> = new StringMap<V>(); // class name to value
//     var keyMap:StringMap<K> = new StringMap<K>(); // class name to class

//     public inline function new():Void
//     {
//     }

//     public inline function get(k:K):Null<V>
//     {
//         return valueMap.get(Type.getClassName(k));
//     }

//     public inline function set(k:K, v:V):Void
//     {
//     	var name:String = Type.getClassName(k);
//     	keyMap.set(name, k);
//         valueMap.set(name, v);
//     }

//     public inline function exists(k:K):Bool
//     {
//         return valueMap.exists(Type.getClassName(k));
//     }
		
//     public function copy():ClassMap<K, V> {
// 			var copy = new ClassMap<K, V>();
//       copy.valueMap = valueMap.copy();
//       copy.keyMap = keyMap.copy();
//       return copy;
//     }
  	
//     public inline function remove(k:K):Bool
//     {
//     	var name:String = Type.getClassName(k);
//     	keyMap.remove(name);
//         return valueMap.remove(name);
//     }

//     public inline function keys():Iterator<K>
//     {
//     	return keyMap.iterator();
//     }

//     public inline function iterator():Iterator<V>
//     {
//         return valueMap.iterator();
//     }

//     public inline function toString():String
//     {
//         return valueMap.toString();
//     }
// }