package lycan.ui.widgets;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.ui.layouts.HBoxLayout;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.widgets.buttons.CheckBox;
import lycan.ui.widgets.buttons.PushButton;
import lycan.ui.widgets.sliders.SimpleHorizontalSlider;
import lycan.util.DebugRenderItem;
import lycan.util.timeline.Timeline;

class TimelineControls extends Widget {
	private var timeline:Timeline<Dynamic>;
	private var slider:SimpleHorizontalSlider;
	private var togglePlay:CheckBox;
	private var fastForward:PushButton;
	private var rewind:PushButton;
	private var reset:PushButton;
	private var infoLabel:Label;
	private var sliderContainer:LayoutContainer;
	private var buttonsContainer:LayoutContainer;

	private var playing(default, default):Bool;
	private var speedMultiplier:Float;
	private var totalTime:Float;
	
	public function new(timeline:Timeline<Dynamic>, group:FlxSpriteGroup, ?parent:UIObject = null, ?name:String) {
		super(parent, name);
		
		layout = new VBoxLayout(10);
		
		this.timeline = timeline;
		playing = false;
		speedMultiplier = 1.0;
		totalTime = 0;
		
		slider = new SimpleHorizontalSlider(timeline.startTime, timeline.endTime, timeline.startTime, new DebugRenderItem(10, 100, FlxColor.RED).addTo(group), new DebugRenderItem(400, 20, FlxColor.BLUE).addTo(group), null, "slider"); 
		rewind = new PushButton(new DebugRenderItem(40, 40, FlxColor.PINK).addTo(group), new DebugRenderItem(40, 40, FlxColor.GREEN).addTo(group), new DebugRenderItem(40, 40, FlxColor.GRAY).addTo(group), null, "rewind");
		togglePlay = new CheckBox(new DebugRenderItem(40, 40, FlxColor.RED).addTo(group), new DebugRenderItem(40, 40, FlxColor.GREEN).addTo(group), new DebugRenderItem(40, 40, FlxColor.GRAY).addTo(group), false, null, "togglePlay");
		fastForward = new PushButton(new DebugRenderItem(40, 40, FlxColor.PINK).addTo(group), new DebugRenderItem(40, 40, FlxColor.GREEN).addTo(group), new DebugRenderItem(40, 40, FlxColor.GRAY).addTo(group), null, "fastForward");
		reset = new PushButton(new DebugRenderItem(60, 40, FlxColor.PURPLE).addTo(group), new DebugRenderItem(60, 40, FlxColor.LIME).addTo(group), new DebugRenderItem(60, 40, FlxColor.GRAY).addTo(group), null, "reset");
		infoLabel = new Label(null, "infoLabel");
		infoLabel.graphic = new FlxText();
		group.add(infoLabel.graphic);
		
		sliderContainer = new LayoutContainer(new HBoxLayout(10, HBoxLayoutDirection.LEFT_TO_RIGHT), null, "sliderContainer");
		sliderContainer.addChild(slider);
		sliderContainer.addChild(infoLabel);
		addChild(sliderContainer);
		
		// TODO fit to parent/expand to fill space
		sliderContainer.width = 500;
		sliderContainer.height = 150;
		
		buttonsContainer = new LayoutContainer(new HBoxLayout(10, HBoxLayoutDirection.LEFT_TO_RIGHT), null, "buttonsContainer");
		buttonsContainer.addChild(rewind);
		buttonsContainer.addChild(togglePlay);
		buttonsContainer.addChild(fastForward);
		buttonsContainer.addChild(reset);
		addChild(buttonsContainer);
		
		// TODO fit to parent/expand to fill space
		buttonsContainer.width = 500;
		buttonsContainer.height = 100;
		
		// TODO remove when event propagation is in
		updateGeometry();
		
		slider.signal_valueChanged.add(function(v:Float):Void {
			if (!playing) {
				timeline.stepTo(v);
				totalTime = timeline.currentTime;
			}
		});
		
		rewind.signal_clicked.add(function():Void {
			if (speedMultiplier <= -2) {
				speedMultiplier -= 0.2;
			} else {
				speedMultiplier = -2.0;
			}
		});
		
		togglePlay.signal_clicked.add(function():Void { 
			playing = !playing;
		});
		
		fastForward.signal_clicked.add(function():Void {
			if (speedMultiplier >= 2) {
				speedMultiplier += 0.2;
			} else {
				speedMultiplier = 2.0;
			}
		});
		
		reset.signal_clicked.add(timeline.reset);
	}
	
	public function update(dt:Float):Void {
		if (playing) {
			totalTime += dt * speedMultiplier;
			slider.value = timeline.currentTime;
		}
		timeline.onUpdate(totalTime);
		
		infoLabel.graphic.text = "Playing: " + playing + ", Speed multiplier: " + speedMultiplier;
	}
}