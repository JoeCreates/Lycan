package lycan.ui.core;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.ui.core.UIApplicationRoot;
import lycan.ui.widgets.Widget;
import flixel.math.FlxPoint;

// HaxeFlixel debug/development renderer for UI elements
@:access(lycan.ui.core.UIApplicationRoot)
@:access(lycan.ui.UIObject)
class DebugRenderer extends FlxSprite {
	private var root:UIApplicationRoot;
	private var text:FlxText;

	// For caching/avoiding temporaries
	// TODO looks like this isn't actually worth it
	private var items:Array<Widget>;
	private var widget:Widget;
	private var lineStyle:Dynamic;
	private var rectLineColor:FlxColor;
	private var outerRectLineStyle:Dynamic;
	private var borderRectLineStyle:Dynamic;
	private var innerRectLineStyle:Dynamic;
	private var centerLineStyle:Dynamic;
	private var outer:FlxRect;
	private var border:FlxRect;
	private var inner:FlxRect;
	private var center:FlxPoint;

	public function new(root:UIApplicationRoot) {
		super(0, 0);
		this.root = root;
		this.text = new FlxText();

		this.items = [];
		this.widget = null;
		this.rectLineColor = FlxColor.RED;
		this.lineStyle = { thickness: 5, color: FlxColor.LIME };
		this.outerRectLineStyle = { thickness: 1, color: rectLineColor };
		this.borderRectLineStyle = { thickness: 1, color: rectLineColor };
		this.innerRectLineStyle = { thickness: 1, color: rectLineColor };
		this.centerLineStyle = { thickness: 1, color: FlxColor.MAGENTA };
		this.outer = null;
		this.border = null;
		this.inner = null;
		this.center = null;
		
		this.scrollFactor.set(0, 0);
		text.scrollFactor.set(0, 0);
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true, "debug_ui_renderer");
	}

	override public function draw() {
		FlxSpriteUtil.fill(this, FlxColor.TRANSPARENT);

		items.splice(0, items.length);
		renderWidgets(this, root.topLevelWidget);

		if (root.hoveredWidget != null) {
			var border = root.hoveredWidget.borderRect();
			FlxSpriteUtil.drawRect(this, border.x, border.y, border.width, border.height, FlxColor.TRANSPARENT, lineStyle);
		}

		super.draw();
	}

	/**
	 * Debug-renders the widget and all of it's children to the debug sprite in a breadth-first order.
	 * @param   renderer    The debug renderer sprite that will be rendered to.
	 * @param   root  The root widget to begin rendering from.
	 * @param   items   An empty array, used internally.
	 * @param   widget  A null widget reference, used internally.
	 * @param   text    A text item for stamping debug views of widgets with text, used internally.
	 */
	private function renderWidgets(renderer:DebugRenderer, root:Widget):Void {
		Sure.sure(root != null);
		Sure.sure(items.length == 0);

		items.push(root);
		while (items.length != 0) {
			widget = items.pop();

			renderWidget(renderer, widget);

			for (child in widget.children) {
				items.push(cast child);
			}
		}
	}

	/**
	 * Renders a debug view of a widget.
	 * @param renderer
	 * @param o
	 * @param text
	 */
	private function renderWidget(renderer:DebugRenderer, widget:Widget):Void {
		Sure.sure(widget != null);

		outer = widget.outerRect();
		border = widget.borderRect();
		inner = widget.innerRect();
		center = widget.outerCenter();

		// TODO check the UIApplicationRoot if the focus widgets == the widget and use that to color the stuff
		if (!widget.shown) {
			rectLineColor = FlxColor.CYAN;
		} else if (!widget.enabled) {
			rectLineColor = FlxColor.GRAY;
		} else {
			rectLineColor = FlxColor.RED;
		}

		FlxSpriteUtil.drawRect(renderer, outer.x, outer.y, outer.width, outer.height, FlxColor.TRANSPARENT, outerRectLineStyle);
		FlxSpriteUtil.drawRect(renderer, border.x, border.y, border.width, border.height, FlxColor.TRANSPARENT, borderRectLineStyle);
		FlxSpriteUtil.drawRect(renderer, inner.x, inner.y, inner.width, inner.height, FlxColor.TRANSPARENT, innerRectLineStyle);

		FlxSpriteUtil.drawLine(renderer, center.x, center.y + Math.min(20, inner.width / 6), center.x, center.y - Math.min(20, inner.width / 6), centerLineStyle);
		FlxSpriteUtil.drawLine(renderer, center.x - Math.min(20, inner.width / 6), center.y, center.x + Math.min(20, inner.width / 6), center.y, centerLineStyle);

		//text.text = widget.name + ": (" + widget.x + "," + widget.y + "), (" + widget.width + "," + widget.height + ")";
		//text.text = "(" + widget.x + "," + widget.y + "),(" + widget.width + "," + widget.height + ");\n(" + center.x + "," + center.y + ")";
		//text.x = widget.x;
		//text.y = widget.y;
		//text.draw();
		
		outer.put();
		border.put();
		inner.put();
		center.put();
	}
}