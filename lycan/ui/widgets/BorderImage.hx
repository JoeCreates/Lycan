package lycan.ui.widgets;

import lycan.ui.renderer.IRenderItem;

using lycan.util.ArrayExtensions;

enum BorderImageRepeatMode {
	REPEATED;
	ROUNDED;
	STRETCHED;
}

// A border image widget contains nine images arranged as a 9-slice
// The corner images are used as given, and the top, right, bottom, left and center are stretched or repeated to fit
class BorderImage extends Widget {
	public var repeatMode(default, set):BorderImageRepeatMode;
	
	private var topLeft(default, null):IRenderItem;
	private var topCenter(default, null):IRenderItem;
	private var topRight(default, null):IRenderItem;
	private var middleLeft(default, null):IRenderItem;
	private var middleCenter(default, null):IRenderItem;
	private var middleRight(default, null):IRenderItem;
	private var bottomLeft(default, null):IRenderItem;
	private var bottomCenter(default, null):IRenderItem;
	private var bottomRight(default, null):IRenderItem;
	
	public function new(sprites:Array<IRenderItem>, repeatMode:BorderImageRepeatMode, ?parent:UIObject, ?name:String) {
		super(parent, name);
		
		Sure.sure(sprites.length == 9);
		Sure.sure(sprites.noNulls());
		
		topLeft = sprites[0];
		topCenter = sprites[1];
		topRight = sprites[2];
		middleLeft = sprites[3];
		middleCenter = sprites[4];
		middleRight = sprites[5];
		bottomLeft = sprites[6];
		bottomCenter = sprites[7];
		bottomRight = sprites[8];
		
		graphics = sprites;
		
		this.repeatMode = repeatMode;
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		// TODO this is wrong
		/*
		topLeft.set_x(x);
		topLeft.set_y(y);
		
		topRight.set_x(x + width - topRight.get_width());
		topRight.set_y(y);
		
		bottomLeft.set_x(x);
		bottomLeft.set_y(y + height - bottomLeft.get_height());
		
		bottomRight.set_x(x + width - bottomRight.get_width());
		bottomRight.set_y(y + height - bottomRight.get_height());
		
		var availableWidth:Float = width;
		var availableHeight:Float = height;
		
		var remainingTopWidth:Float = availableWidth - topLeft.get_width() - topRight.get_width();
		var remainingMiddleWidth:Float = availableWidth - middleLeft.get_width() - middleRight.get_width();
		var remainingBottomWidth:Float = availableWidth - bottomLeft.get_width() - bottomRight.get_width();
		var remainingLeftHeight:Float = availableHeight - topLeft.get_height() - bottomLeft.get_height();
		var remainingMiddleHeight:Float = availableHeight - topCenter.get_height() - bottomCenter.get_height();
		var remainingRightHeight:Float = availableHeight - topRight.get_height() - bottomRight.get_height();
		
		middleLeft.set_x(Std.int(x));
		middleLeft.set_y(Std.int(topLeft.get_y() + topLeft.get_height()));
		middleLeft.get_scale().set(1, remainingLeftHeight / middleLeft.get_height());
		
		middleRight.set_x(Std.int(x + width - middleRight.get_width()));
		middleRight.set_y(Std.int(topLeft.get_y() + topRight.get_height()));
		middleRight.get_scale().set(1, remainingRightHeight / middleRight.get_height());
		
		topCenter.set_x(Std.int(x + topLeft.get_width()));
		topCenter.set_y(Std.int(topLeft.get_y()));
		topCenter.get_scale().set(remainingTopWidth / topCenter.get_width(), 1);
		
		bottomCenter.set_x(Std.int(x + bottomLeft.get_width()));
		bottomCenter.set_y(Std.int(y + height - bottomLeft.get_height()));
		bottomCenter.get_scale().set(remainingBottomWidth / bottomCenter.get_width(), 1);
		
		middleCenter.set_x(Std.int(x + middleLeft.get_width()));
		middleCenter.set_y(Std.int(y + topCenter.get_height()));
		middleCenter.get_scale().set(remainingMiddleWidth / middleCenter.get_width(), remainingMiddleHeight / middleCenter.get_height());
		*/
	}
	
	private function set_repeatMode(mode:BorderImageRepeatMode):BorderImageRepeatMode {
		this.repeatMode = mode;
		updateGeometry();
		return this.repeatMode;
	}
}