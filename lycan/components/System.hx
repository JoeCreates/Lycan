package lycan.components;

// This is just a list wrapper currently
class System<T:(IUpdateable)> {
    private var components:List<T>;
    
    public inline function new() {
        components = new List<T>();
    }
    
    public inline function add(component:T):Void {
        components.add(component);
    }
    
    public inline function remove(component:T):Void {
        components.remove(component);
    }
    
    public inline function update(dt:Float):Void {
        for (component in components) {
            component.update(dt);
        }
    }
}