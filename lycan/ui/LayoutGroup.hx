package lycan.ui;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

typedef LayoutGroup = TypedLayoutGroup<FlxSprite>;

class TypedLayoutGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T> {
	public var containerWidth:Float;
	public var containerHeight:Float;
	public var layout:Layout;
	
	public function new(width:Float, height:Float, layout:Layout) {
		super();
		this.containerWidth = width;
		this.containerHeight = height;
		this.layout = layout;
	}
	
	override public function add(sprite:T):T {
		var out = super.add(sprite);
		applyLayout();
		return out;
	}
	
	override public function remove(sprite:T, splice:Bool = false):T {
		var out = super.remove(sprite, splice);
		applyLayout();
		return out;
	}
	
	public function applyLayout(?layout:Layout):Void {
		if (layout == null) layout = this.layout;
		if (layout == null) return;
		
		layout.apply(cast this, containerWidth, containerHeight);
	}
}