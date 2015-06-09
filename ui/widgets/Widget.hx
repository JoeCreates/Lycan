package lycan.ui.widgets;
import flixel.math.FlxPoint;
import lime.app.Event;
import lycan.ui.events.UIEvent;
import lycan.ui.layouts.Layout;
import lycan.ui.layouts.SizePolicy;

enum FindChildOptions {
	DirectChildrenOnly;
	FindChildrenRecursively;
}
// TODO classify and paramaeterize the numerical types?
// TODO define IWidget and figure out if it's necessary
class Widget implements IWidget {
	public var parent:Widget = null;
	public var children:List<Widget>;
	public var name:String = null;
	public var uid:Int;
	public var sendChildEvents:Bool;
	public var receiveChildEvents:Bool;
	
	public var layout:Layout;
	public var enabled:Bool;
	public var modal:Bool;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var sizePolicy:SizePolicy;
	public var minWidth:Int;
	public var maxWidth:Int;
	public var minHeight:Int;
	public var maxHeight:Int;
	public var sizeIncrement:FlxPoint;
	public var focus:Bool;
	public var shown:Bool;
	public var acceptDrops:Bool;
	
	public function new() {
		uid = cast (Math.random() * (2 ^ 30), Int);
	}
	
	/*
	public function draw() {
		
	}
	
	public function close() {
		
	}
	
	public function event(e:UIEvent):Bool {
		return false;
	}
	
	//public function installEventFilter
	//public function removeEventFilter
	//public function eventFilter(widget:IWidget, e:UIEvent):Bool {
	//	return false;
	//}
		
	public function findChildren(name:String, ?findOption:FindChildOptions):List<IWidget> {
		if(findOption == null) {
			findOption = FindChildOptions.FindChildrenRecursively;
		}
	
		var list:IWidget = new List<Widget>();
		
		// TODO
		
		return list;
	}
	
	private function childEvent(e:ChildEvent) {
		
	}
	
	private function customEvent(e:UIEvent) {
		
	}
	
	private function mousePressEvent(e:MouseEvent) {
		
	}
	
	private function mouseReleaseEvent(e:MouseEvent) {
		
	}
	
	private function mouseDoubleClickEvent(e:MouseEvent) {
		
	}
	
	private function mouseMoveEvent(e:MouseEvent) {
		
	}
	
	private function wheelEvent(e:WheelEvent) {
		
	}
	
	private function keyPressEvent(e:KeyboardEvent) {
		
	}
	
	private function keyReleaseEvent(e:KeyboardEvent) {
		
	}
	
	private function focusInEvent(e:FocusEvent) {
		
	}
	
	private function focusOutEvent(e:FocusEvent) {
		
	}
	
	private function enterEvent(e:UIEvent) {
		
	}
	
	private function leaveEvent(e:UIEvent) {
		
	}
	
	private function moveEvent(e:MoveEvent) {
		
	}
	
	private function resizeEvent(e:ResizeEvent) {
		
	}
	
	private function closeEvent(e:CloseEvent) {
		
	}
	
	private function dragEnterEvent(e:DragEnterEvent) {
		
	}
	
	private function dragMoveEvent(e:DragMoveEvent) {
		
	}
	
	private function dragLeaveEvent(e:DragLeaveEvent) {
		
	}
	
	private function dropEvent(e:DropEvent) {
		
	}
	
	private function showEvent(e:ShowEvent) {
		
	}
	
	private function hideEvent(e:HideEvent) {
		
	}
	
	private function changeEvent(e:ChangeEvent) {
		
	}
	*/
}