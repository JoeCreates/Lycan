package lycan.ui.widgets;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

class Menu extends Widget {
	public signal_aboutToHide(default, null):Signal0;
	public signal_aboutToShow(default, null):Signal0;
	public signal_triggered(default, null):Signal1<String>;
	public signal_hovered(default, null):Signal0;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
}