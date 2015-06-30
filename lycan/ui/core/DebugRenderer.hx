package lycan.ui.core;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.ui.core.UIApplicationRoot;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;

// HaxeFlixel debug/development rendererer for UI elements
@:access(lycan.ui.core.UIApplicationRoot)
@:access(lycan.ui.UIObject)
class DebugRenderer extends FlxSprite {
	private var root:UIApplicationRoot;
	private var text:FlxText;
	
	public function new(root:UIApplicationRoot) {
		super(0, 0);
		this.root = root;
		this.text = new FlxText();
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, false, "debug_ui_renderer");
	}
	
	override public function draw() {
		FlxSpriteUtil.fill(this, FlxColor.TRANSPARENT);
		
		var renderWidget = function(o:UIObject) {
			Sure.sure(o != null);
			
			if (o.isWidgetType) {
				var w:Widget = cast o;
				var outer = w.outerRect();
				var border = w.borderRect();
				var inner = w.innerRect();
				var center = w.innerCenter();
				
				var rectLineColor = FlxColor.RED;
				
				if (w.keyboardFocus) {
					rectLineColor.green += 127;
				}
				if (w.gamepadFocus) {
					rectLineColor.blue += 127;
				}
				if (!w.shown) {
					rectLineColor = FlxColor.CYAN;
				}
				if (!w.enabled) {
					rectLineColor = FlxColor.GRAY;
				}
				
				var outerRectLineStyle:LineStyle = { thickness: 1, color: rectLineColor };
				//var borderRectLineStyle:LineStyle = { thickness: 1, color: rectLineColor };
				var innerRectLineStyle:LineStyle = { thickness: 1, color: rectLineColor };
				
				FlxSpriteUtil.drawRect(this, outer.x, outer.y, outer.width, outer.height, FlxColor.TRANSPARENT, outerRectLineStyle);
				//FlxSpriteUtil.drawRect(this, border.x, border.y, border.width, border.height, FlxColor.TRANSPARENT, borderRectLineStyle);
				FlxSpriteUtil.drawRect(this, inner.x, inner.y, inner.width, inner.height, FlxColor.TRANSPARENT, innerRectLineStyle);
				
				var centerLineStyle:LineStyle = { thickness: 1, color: FlxColor.MAGENTA };
				FlxSpriteUtil.drawLine(this, center.x, center.y + Math.min(20, inner.width / 6), center.x, center.y - Math.min(20, inner.width / 6), centerLineStyle);
				FlxSpriteUtil.drawLine(this, center.x - Math.min(20, inner.width / 6), center.y, center.x + Math.min(20, inner.width / 6), center.y, centerLineStyle);
				
				text.text = w.name + ": (" + w.x + "," + w.y + "), (" + w.width + "," + w.height + ")";
				text.x = w.x;
				text.y = w.y;
				text.draw();
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
		
		if (root.hoveredWidget != null) {
			var border = root.hoveredWidget.borderRect();
			var lineStyle:LineStyle = { thickness: 5, color: FlxColor.LIME };
			FlxSpriteUtil.drawRect(this, border.x, border.y, border.width, border.height, FlxColor.TRANSPARENT, lineStyle);
		}
		
		super.draw();
	}
}