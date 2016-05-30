package lycan.ui;

import lycan.ui.events.UIEvent;

enum FindChildOptions {
    FindDirectChildrenOnly;
}

class UIObject {
    private static var idTick:Int = 0;
    
    public var parent(default, set):UIObject;
    public var name(get, null):String;
    public var id(get, null):Int;
    public var sendChildEvents:Bool;
    public var receiveChildEvents:Bool;
    public var enabled(default, set):Bool = true;
    
    public var isWidgetType(get, never):Bool;
    
    public var children(default, null):List<UIObject>;
    
    private var eventFilters:List<UIObject>;
    
    public function new(?parent:UIObject = null, ?name:String = null) {
        this.name = name;
        id = idTick++;
        sendChildEvents = true;
        receiveChildEvents = true;
        
        children = new List<UIObject>();
        eventFilters = new List<UIObject>();
        
        this.parent = parent;
    }
    
    public function installEventFilter(filter:UIObject):Void {
        Sure.sure(filter != null);
        
        eventFilters.add(filter);
    }
    
    public function removeEventFilter(filter:UIObject):Void {
        Sure.sure(filter != null);
        Sure.sure(eventFilters != null);
        
        eventFilters.remove(filter);
    }
    
    // Filters events if this object has been installed as an event filter on a watched object
    // Return true if you want to filter the event out i.e. stop it being handled further, else false
    public function eventFilter(object:UIObject, e:UIEvent):Bool {
        Sure.sure(object != null);
        Sure.sure(e != null);
        
        return false;
    }
    
    public function event(e:UIEvent):Bool {
        Sure.sure(e != null);
        
        for (filter in eventFilters) {
            if (filter.event(e)) {
                return true;
            }
        }
        
        switch(e.type) {
            case EventType.ChildAdded, EventType.ChildRemoved:
                childEvent(cast e);
            default:
                // if(type >= MAX_USER) { // TODO custom events added to e above a max range
                // customEvent(e);
                // }
                // break;
                
                return false;
        }
        
        return true;
    }
    
    // Handle user-defined events
    //private function customEvent(e:CustomEvent) {
    //  
    //}
    
    // This can be reimplemented to handle a child being added or removed to the object
    private function childEvent(e:ChildEvent) {
        Sure.sure(e != null);
    }
    
    public function addChild(child:UIObject) {
        Sure.sure(child != null);
        child.parent = this;
    }
    
    public function removeChild(child:UIObject) {
        Sure.sure(child != null);
        
        var removed = children.remove(child);
        Sure.sure(removed == true);
        child.parent = null;
    }
    
    public function findChildren(name:String, ?findOption:FindChildOptions):List<UIObject> {
        Sure.sure(name != null);
        
        if(findOption == null) {
            findOption = FindDirectChildrenOnly;
        }
    
        return switch(findOption) {
            case FindDirectChildrenOnly:
                return findChildrenHelper(name, new List<UIObject>());
        }
    }
    
    private function findChildrenHelper(name:String, list:List<UIObject>):List<UIObject> {
        Sure.sure(name != null);
        
        for (child in children) {
            if (name == child.name) {
                list.push(child);
            }
        }
        return list;
    }
    
    private function get_id():Int {
        return id;
    }
    
    private function get_name():String {
        if (name == null) {
            return Std.string(id);
        }
        
        return name;
    }
    
    private function get_isWidgetType():Bool {
        return false;
    }
    
    private function set_parent(parent:UIObject):UIObject {     
        if (this.parent != null) {
            this.parent.children.remove(this);
            this.parent.event(new ChildEvent(EventType.ChildRemoved, this));
        }
        
        if(parent != null) {
            parent.children.add(this);
            parent.event(new ChildEvent(EventType.ChildAdded, this));
        }
        
        return this.parent = parent;
    }
    
    private function set_enabled(enabled:Bool):Bool {
        return this.enabled = enabled;
    }
}