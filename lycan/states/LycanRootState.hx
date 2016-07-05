package lycan.states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.io.Path;
import lycan.ui.core.DebugRenderer;
import lycan.ui.core.UIApplicationRoot;
import lycan.util.screenshot.BatchScreenGrab;
import openfl.events.KeyboardEvent;
import openfl.Lib;

class LycanRootState extends FlxState {
	public var uiRoot(default, null) = new UIApplicationRoot();
	
	#if debug
	//private var	debugUiRenderer:DebugRenderer;
	//private var stateStackText:FlxSpriteGroup;
	#end

	private function new() {
		super();
		
		#if (debug && cpp && enablesceenshots)
			// Batch screenshots
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(evt:KeyboardEvent) {
			if (evt.keyCode == 83) { // S to take screenshots
				var screenshotSizes:Array<FlxPoint> = [
				new FlxPoint(960, 640), // 3.5 inch retina
				new FlxPoint(1136, 640), // 4 inch retina
				new FlxPoint(1280, 800), // 720p/Mac/Google Play mobile/tablet screenshots
				new FlxPoint(1334, 750), // 4.7 inch retina
				new FlxPoint(1440, 900), // Mac
				new FlxPoint(1920, 1080), // 1080p
				new FlxPoint(1920, 1200), // Amazon appstore
				new FlxPoint(2048, 1536), // iPad
				new FlxPoint(2208, 1242), // 5.5 inch retina
				new FlxPoint(2560, 1440), // 1440p
				new FlxPoint(2732, 2048), // iPad Pro
				new FlxPoint(2560, 1600), // Amazon appstore
				new FlxPoint(2880, 1800), // Mac
				new FlxPoint(3840, 2160) // 4K
				];

				var grab = new BatchScreenGrab(new Path("screenshot.png"), screenshotSizes);
				grab.start();
			}
		});
		#end
	}

	override public function create():Void {
		super.create();

		#if debug	//TODO I think this stuff was making things very slow	
		//debugUiRenderer = new DebugRenderer(uiRoot);
		//stateStackText = new FlxSpriteGroup();
		//stateStackText.scrollFactor.set(0, 0);
		//
		//FlxG.signals.postDraw.add(debugPostDraw);
		#end
	}

	override public function destroy():Void {
		//#if debug TODO
		//FlxG.signals.postDraw.remove(debugPostDraw);
		//#end
		super.destroy();
	}

	public static function getInstance<T>():T {
		var self = FlxG.game._state;
		Sure.sure(self != null);
		return cast self;
	}
	
	//#if debug
	//private function updateStateVisualisation():Void {
		//stateStackText.clear();
		//
		//var y = 0;
		//var makeText = function(o:Dynamic):FlxText {
			//var str = Type.getClassName(Type.getClass(o));
			//var text = new FlxText(0, y, 0, str, 16);
			//text.color = FlxColor.WHITE;
			//text.borderSize = 1;
			//text.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 2);
			//y += 30;
			//return text;
		//}
		//
		//var child = subState;
		//stateStackText.add(makeText(this));
		//while (child != null) {
			//stateStackText.add(makeText(child));
			//child = child.subState;
		//}
	//}
	//#end
	
	// Returns the first state of type T in the state stack, throws if there isn't one of that type
	public static function getFirstStateOfType<T>(type:Class<T>):T {
		var self = LycanRootState.getInstance();
		var child = self.subState;

		while (child != null) {
			if (Std.is(child, type)) {
				return cast child;
			}

			child = cast child.subState;
		}

		throw "Failed to find a substate of type " + Type.getClassName(type) + " in current states...";
	}

	#if debug
	//private function debugPostDraw():Void {
		//debugUiRenderer.draw();
		//updateStateVisualisation();
		//stateStackText.draw();
	//}
	#end
}