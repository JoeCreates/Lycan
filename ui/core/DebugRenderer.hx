package source.lycan.ui.core;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import lycan.ui.core.UIApplicationRoot;
import lycan.ui.UIObject;
import flixel.util.FlxSpriteUtil;
import lycan.ui.widgets.Widget;
import flixel.util.FlxColor;

import flixel.FlxG;

// Debug/development renderering for UI elements
class DebugRenderer extends FlxSprite {
	private var root:UIApplicationRoot;
	
	public function new(root:UIApplicationRoot) {
		super(FlxG.width / 2, FlxG.height / 2);
		
		this.root = root;
	}
	
	override public function draw() {		
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, false, "debug_ui_renderer");
		x = FlxG.width / 2;
		y = FlxG.height / 2;
		
		var renderWidget = function(o:UIObject) {
			Sure.sure(o != null);
			
			if (o.isWidgetType) {
				var w:Widget = cast o;
				var outer = w.outerRect();
				var border = w.borderRect();
				var inner = w.innerRect();
				var center = w.innerCenter();
				
				var rectLineColor = FlxColor.RED;
				
				if (w.focus) {
					rectLineColor.green += 127;
				}				
				if (!w.shown) {
					rectLineColor = FlxColor.CYAN;
				}
				if (!w.enabled) {
					rectLineColor = FlxColor.GRAY;
				}
				
				var rectLineStyle:LineStyle = { thickness: 1, color: rectLineColor };
				FlxSpriteUtil.drawRect(this, outer.x, outer.y, outer.width, outer.height, FlxColor.TRANSPARENT, rectLineStyle);
				FlxSpriteUtil.drawRect(this, border.x, border.y, border.width, border.height, FlxColor.TRANSPARENT, rectLineStyle);
				FlxSpriteUtil.drawRect(this, inner.x, inner.y, inner.width, inner.height, FlxColor.TRANSPARENT, rectLineStyle);
				
				var centerLineStyle:LineStyle = { thickness: 1, color: FlxColor.MAGENTA };
				FlxSpriteUtil.drawLine(this, center.x, center.y + inner.height / 4, center.x, center.y - inner.height / 4, centerLineStyle);
				FlxSpriteUtil.drawLine(this, center.x - inner.width / 4, center.y, center.x + inner.width / 4, center.y, centerLineStyle);
			}
		}
		
		var visitElements = function(tlw:UIObject) {
			var items = new Array<UIObject>();
			items.push(tlw);
			while (items.length != 0) {
				var w = items.pop();
				
				for (child in w.children) {
					items.push(child);
				}
				
				renderWidget(w);
			}
		}
		
		visitElements(root.topLevelWidget);
		
		super.draw();
	}
}