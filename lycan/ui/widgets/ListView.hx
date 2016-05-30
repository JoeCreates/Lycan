package lycan.ui.widgets;

import lycan.ui.widgets.buttons.PushButton;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

class ListView extends Widget {
    public var signal_currentItemChanged = new Signal2<Widget, Widget>();
    public var signal_itemActivated = new Signal1<Widget>();
    public var signal_itemPressed = new Signal1<Widget>();
    public var signal_itemHovered = new Signal1<Widget>();
    
    public function new(?parent:UIObject, ?name:String) {
        super(parent, name);
    }
}