package lycan.ui.widgets;

import flixel.FlxSprite;
import lycan.ui.renderer.IRenderItem;

using lycan.util.ArrayExtensions;

enum BorderImageRepeatMode {
	REPEATED;
	ROUNDED;
	STRETCHED;
}

// A border image widget contains nine images arranged as a 9-slice
// The corner images are used as given, and the top, right, bottom, left and center are stretched or repeated to fit
// TODO make generic implementation for rendering?
class BorderImage extends Widget {
	public var horizontalRepeatMode(default, set):BorderImageRepeatMode;
	public var verticalRepeatMode(default, set):BorderImageRepeatMode;
	
	private var topLeft(default, null):FlxSprite;
	private var topCenter(default, null):FlxSprite;
	private var topRight(default, null):FlxSprite;
	private var middleLeft(default, null):FlxSprite;
	private var middleCenter(default, null):FlxSprite;
	private var middleRight(default, null):FlxSprite;
	private var bottomLeft(default, null):FlxSprite;
	private var bottomCenter(default, null):FlxSprite;
	private var bottomRight(default, null):FlxSprite;
	
	private var renderTarget(default, null):FlxSprite; // TODO
	private var needsRedraw:Bool = true;
	
	public function new(sprites:Array<IRenderItem>, renderTarget:IRenderItem, horizontalRepeatMode:BorderImageRepeatMode, verticalRepeatMode:BorderImageRepeatMode, ?parent:UIObject, ?name:String) {
		super(parent, name);
		
		Sure.sure(sprites.length == 9);
		Sure.sure(sprites.noNulls());
		
		topLeft = cast(sprites[0], FlxSprite);
		topCenter = cast(sprites[1], FlxSprite);
		topRight = cast(sprites[2], FlxSprite);
		middleLeft = cast(sprites[3], FlxSprite);
		middleCenter = cast(sprites[4], FlxSprite);
		middleRight = cast(sprites[5], FlxSprite);
		bottomLeft = cast(sprites[6], FlxSprite);
		bottomCenter = cast(sprites[7], FlxSprite);
		bottomRight = cast(sprites[8], FlxSprite);
		
		graphics = sprites;
		
		this.horizontalRepeatMode = horizontalRepeatMode;
		this.verticalRepeatMode = verticalRepeatMode;
		
		this.renderTarget = cast(renderTarget, FlxSprite);
		
		redraw();
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		if (needsRedraw) {
			redraw();
		}
	}
	
	public function redraw():Void {
		Sure.sure(needsRedraw);
		
		switch(horizontalRepeatMode) {
			case REPEATED:
			case ROUNDED:
			case STRETCHED:
		}
		
		switch(verticalRepeatMode) {
			case REPEATED:
			case ROUNDED:
			case STRETCHED:
		}
		
		needsRedraw = false;
	}
	
	private function set_horizontalRepeatMode(mode:BorderImageRepeatMode):BorderImageRepeatMode {
		this.horizontalRepeatMode = mode;
		needsRedraw = true;
		updateGeometry();
		return this.horizontalRepeatMode;
	}
	
	private function set_verticalRepeatMode(mode:BorderImageRepeatMode):BorderImageRepeatMode {
		this.verticalRepeatMode = mode;
		needsRedraw = true;
		updateGeometry();
		return this.verticalRepeatMode;
	}
	
	override private function set_width(width:Int):Int {
		super.set_width(width);
		needsRedraw = true;
		redraw();
		return width;
	}
	
	override private function set_height(height:Int):Int {
		super.set_height(height);
		needsRedraw = true;
		redraw();
		return height;
	}
}