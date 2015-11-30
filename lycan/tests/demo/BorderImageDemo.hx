package lycan.tests.demo;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import lycan.ui.renderer.flixel.FlxImageRenderItem;
import lycan.ui.widgets.BorderImage;
import lycan.ui.widgets.BorderImage.BorderImageRepeatMode;

class BorderImageDemo extends BaseDemoState {
	public static inline var ITEM_SPACING:Int = 4;
	
	private var topLeft:FlxSprite = new FlxSprite();
	private var topCenter:FlxSprite = new FlxSprite();
	private var topRight:FlxSprite = new FlxSprite();
	private var centerLeft:FlxSprite = new FlxSprite();
	private var center:FlxSprite = new FlxSprite();
	private var centerRight:FlxSprite = new FlxSprite();
	private var bottomLeft:FlxSprite = new FlxSprite();
	private var bottomCenter:FlxSprite = new FlxSprite();
	private var bottomRight:FlxSprite = new FlxSprite();
	private var images:Array<FlxSprite> = new Array<FlxSprite>();
	
	public function new() {
		super();
		
		topLeft.makeGraphic(20, 20, FlxColor.GREEN);
		topCenter.makeGraphic(40, 40, FlxColor.YELLOW);
		topRight.makeGraphic(20, 20, FlxColor.RED);
		centerLeft.makeGraphic(20, 20, FlxColor.ORANGE);
		center.makeGraphic(20, 20, FlxColor.PURPLE);
		centerRight.makeGraphic(20, 20, FlxColor.BLUE);
		bottomLeft.makeGraphic(20, 20, FlxColor.BROWN);
		bottomCenter.makeGraphic(20, 20, FlxColor.ORANGE);
		bottomRight.makeGraphic(20, 20, FlxColor.PINK);
		
		images = [ new FlxImageRenderItem(topLeft), new FlxImageRenderItem(topCenter), new FlxImageRenderItem(topRight), new FlxImageRenderItem(centerLeft), new FlxImageRenderItem(center), new FlxImageRenderItem(centerRight), new FlxImageRenderItem(bottomLeft), new FlxImageRenderItem(bottomCenter), new FlxImageRenderItem(bottomRight) ];
		
		var equalSizedBorderImage:BorderImage = new BorderImage(images, new FlxImageRenderItem(new FlxSprite()).addTo(this), BorderImageRepeatMode.REPEATED, BorderImageRepeatMode.REPEATED);
		
		add(equalSizedBorderImage);
	}
	
	override public function create():Void {
		super.create();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
}