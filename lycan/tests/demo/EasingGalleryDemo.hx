package lycan.tests.demo;

import flixel.addons.effects.FlxTrailArea;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.states.LycanState;
import lycan.util.timeline.Timeline;
import lycan.util.timeline.Tween;
import openfl.events.MouseEvent;
import openfl.Lib;
import lycan.util.EasingEquations;

using flixel.util.FlxSpriteUtil;
using lycan.util.IntExtensions;
using lycan.util.FloatExtensions;

class TweenGraph extends FlxSpriteGroup {
	public var description:String;
	public var ease:Float->Float;
	
	public var box:FlxSprite;
	public var point:FlxSprite;
	public var trailPoint:FlxSprite;
	
	public var graphX:Float;
	public var graphY:Float;
	
	public function new(description:String, ease:Float->Float) {
		super();
		
		this.description = description;
		this.ease = ease;
		
		box = new FlxSprite().makeGraphic(Std.int(FlxG.width / EasingGalleryDemo.TWEENS_PER_ROW - EasingGalleryDemo.ITEM_SPACING * 2), Std.int(FlxG.height / 11 - EasingGalleryDemo.ITEM_SPACING * 2), FlxColor.WHITE);
		box.drawRect(box.x, box.y, box.width, box.height, FlxColor.TRANSPARENT, { thickness: 2, color: FlxColor.BLACK });
		add(box);
		
		var text = new FlxText(0, 0, 0, description, 8);
		text.color = FlxColor.GRAY;
		add(text);
		
		point = new FlxSprite();
		point.makeGraphic(6, 6, FlxColor.TRANSPARENT);
		point.drawCircle(3, 3, 3, FlxColor.RED);
		add(point);
		
		trailPoint = new FlxSprite();
		trailPoint.makeGraphic(2, 2, FlxColor.BLUE);
		add(trailPoint);
		
		text.setPositionUsingCenter(width / 2, height / 2);
		
		graphX = 0;
		graphY = 0;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		point.x = graphX + x - point.width / 2;
		point.y = graphY + y - point.height / 2;
		
		trailPoint.x = graphX + x - trailPoint.width / 2;
		trailPoint.y = graphY + y - trailPoint.height / 2;
	}
}

class EasingGalleryDemo extends BaseDemoState {
	public static inline var TWEENS_PER_ROW:Int = 4;
	public static inline var ITEM_SPACING:Int = 4;
	
	public var rateMultiplier:Float = 1;
	
	private var timeline:Timeline<TweenGraph>;
	private var graphs:Array<TweenGraph>;
	private var graphGroup:FlxSpriteGroup;
	private var trailArea:FlxTrailArea;
	private var userControlled:Bool;
	private var reversed:Bool;
	
	override public function create():Void {
		super.create();
		
		bgColor = FlxColor.GRAY;
		
		timeline = new Timeline<TweenGraph>();
		graphs = new Array<TweenGraph>();
		graphGroup = new FlxSpriteGroup();
		trailArea = new FlxTrailArea(0, 0, FlxG.width, FlxG.height, 0.95, 1);
		userControlled = false;
		reversed = false;
		
		addTween(EaseQuad.inQuad, "EaseInQuad");
		addTween(EaseQuad.outQuad, "EaseOutQuad");
		addTween(EaseQuad.inOutQuad, "EaseInOutQuad");
		addTween(EaseQuad.outInQuad, "EaseOutInQuad");
		
		addTween(EaseCubic.inCubic, "EaseInCubic");
		addTween(EaseCubic.outCubic, "EaseOutCubic");
		addTween(EaseCubic.inOutCubic, "EaseInOutCubic");
		addTween(EaseCubic.outInCubic, "EaseOutInCubic");
		
		addTween(EaseQuart.inQuart, "EaseInQuart");
		addTween(EaseQuart.outQuart, "EaseOutQuart");
		addTween(EaseQuart.inOutQuart, "EaseInOutQuart");
		addTween(EaseQuart.outInQuart, "EaseOutInQuart");
		
		addTween(EaseQuint.inQuint, "EaseInQuint");
		addTween(EaseQuint.outQuint, "EaseOutQuint");
		addTween(EaseQuint.inOutQuint, "EaseInOutQuint");
		addTween(EaseQuint.outInQuint, "EaseOutInQuint");
		
		addTween(EaseSine.inSine, "EaseInSine");
		addTween(EaseSine.outSine, "EaseOutSine");
		addTween(EaseSine.inOutSine, "EaseInOutSine");
		addTween(EaseSine.inOutSine, "EaseOutInSine");
		
		addTween(EaseExpo.inExpo, "EaseInExpo");
		addTween(EaseExpo.outExpo, "EaseOutExpo");
		addTween(EaseExpo.inOutExpo, "EaseInOutExpo");
		addTween(EaseExpo.outInExpo, "EaseOutInExpo");
		
		addTween(EaseCirc.inCirc, "EaseInCirc");
		addTween(EaseCirc.outCirc, "EaseOutCirc");
		addTween(EaseCirc.inOutCirc, "EaseInOutCirc");
		addTween(EaseCirc.outInCirc, "EaseOutInCirc");
		
		addTween(EaseAtan.makeInAtan(), "EaseInAtan");
		addTween(EaseAtan.makeOutAtan(), "EaseOutAtan");
		addTween(EaseAtan.makeInOutAtan(), "EaseInOutAtan");
		addTween(EaseLinear.none, "EaseLinear");
		
		addTween(EaseBack.makeInBack(), "EaseInBack");
		addTween(EaseBack.makeOutBack(), "EaseOutBack");
		addTween(EaseBack.makeInOutBack(), "EaseInOutBack");
		addTween(EaseBack.makeOutInBack(), "EaseOutInBack");
		
		addTween(EaseBounce.makeInBounce(), "EaseInBounce");
		addTween(EaseBounce.makeOutBounce(), "EaseOutBounce");
		addTween(EaseBounce.makeInOutBounce(), "EaseInOutBounce");
		addTween(EaseBounce.makeOutInBounce(), "EaseOutInBounce");
		
		addTween(EaseElastic.makeInElastic(2, 1), "EaseInElastic(2, 1)");
		addTween(EaseElastic.makeOutElastic(1, 4), "EaseOutElastic(1, 4)");
		addTween(EaseElastic.makeInOutElastic(2, 1), "EaseInOutElastic(2, 1)");
		addTween(EaseElastic.makeOutInElastic(1, 4), "EaseOutInElastic(1, 4)");
		
		addTween(EaseCubicHermite.makeHermite(0.2, 0.6, 0.2), "EaseCubicHermite(0.2, 0.6, 0.2)");
		addTween(EaseCubicHermite.makeHermite(0.4, 0.2, 0.4), "EaseCubicHermite(0.4, 0.2, 0.4)");
		addTween(EaseCubicHermite.makeHermite(0.5, 0.3, 0.2), "EaseCubicHermite(0.5, 0.3, 0.2)");
		addTween(EaseCubicHermite.makeHermite(0.2, 0.3, 0.5), "EaseCubicHermite(0.2, 0.3, 0.5)");
		
		var i:Int = 0;
		var x:Float = 0;
		var y:Float = 0;
		for (graph in graphs) {
			timeline.add(new Tween(graph, 0, 1, [ { name:"graphX", start:0, end:graph.width } ], EaseLinear.none));
			timeline.add(new Tween(graph, 0, 1, [ { name:"graphY", start:graph.height, end:0 } ], graph.ease));
			
			i++;
			graph.x = x;
			x += graph.width + ITEM_SPACING;
			graph.y = y;
			if (i % EasingGalleryDemo.TWEENS_PER_ROW == 0) {
				x = 0;
				y += graph.height + ITEM_SPACING;
			}
			graphGroup.add(graph);
			trailArea.add(graph.trailPoint);
		}
		
		graphGroup.screenCenter();
		add(graphGroup);
		add(trailArea);
		
		for (graph in graphs) {
			add(graph.point);
		}
		
		Lib.current.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):Void {
			reversed = !reversed;
		});
		
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, function(e:MouseEvent):Void {
			userControlled = !userControlled;
		});
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent):Void {
			if (e.delta > 0) {
				rateMultiplier += 0.1;
			} else if (e.delta < 0) {
				rateMultiplier -= 0.1;
			}
		});
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (!userControlled) {
			if (timeline.currentTime >= 1) {
				timeline.reset();
				timeline.currentTime = 0;
			} else if (timeline.currentTime <= 0) {
				timeline.reset();
				timeline.currentTime = 1;
			}
			timeline.step(reversed ? -dt * rateMultiplier : dt * rateMultiplier);
		} else {
			timeline.stepTo((FlxG.mouse.x.clamp(1, FlxG.width) / FlxG.width).clamp(0, 1));
		}
		
		lateUpdate(dt);
	}
	
	private inline function addTween(ease:Float->Float, description:String):Void {
		var graph = new TweenGraph(description, ease);
		graphs.push(graph);
	}
}