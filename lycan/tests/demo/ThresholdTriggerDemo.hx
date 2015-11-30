package lycan.tests.demo;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import lycan.util.ThresholdTrigger;
import lycan.util.ThresholdTrigger.SimpleThreshold;

class DemoThreshold extends SimpleThreshold {	
	public function new(threshold:Float, ?cbs:Array<Float->Float->Void>) {
		super(threshold, cbs);
		signal_crossed.add(function(lower:Float, upper:Float):Void {
			trace("Demo Threshold triggered due to a change from value " + lower + " to " + upper + " for threshold " + threshold);
		});
	}
}

class ThresholdTriggerDemo extends BaseDemoState {
	private var triggers:ThresholdTrigger<DemoThreshold>;
	private var text:FlxText;
	
	override public function create():Void {
		super.create();
		
		triggers = new ThresholdTrigger<DemoThreshold>();
		triggers.add(new DemoThreshold(5, [print]));
		triggers.add(new DemoThreshold(10, [print]));
		triggers.add(new DemoThreshold(20, [print]));
		triggers.add(new DemoThreshold(30, [print]));
		triggers.add(new DemoThreshold(40, [print]));
		triggers.add(new DemoThreshold(50, [print]));
		triggers.add(new DemoThreshold(60, [print]));
		triggers.add(new DemoThreshold(70, [print]));
		triggers.add(new DemoThreshold(80, [print]));
		triggers.add(new DemoThreshold(90, [print]));
		triggers.add(new DemoThreshold(100, [print]));
		triggers.add(new DemoThreshold(110, [print]));
		triggers.add(new DemoThreshold(90, [print]));
		triggers.add(new DemoThreshold(80, [print]));
		triggers.add(new DemoThreshold(70, [print]));
		triggers.add(new DemoThreshold(60, [print]));
		triggers.add(new DemoThreshold(50, [print]));
		triggers.add(new DemoThreshold(40, [print]));
		triggers.add(new DemoThreshold(30, [print]));
		triggers.add(new DemoThreshold(20, [print]));
		triggers.add(new DemoThreshold(10, [print]));
		triggers.add(new DemoThreshold(5, [print]));
		triggers.add(new DemoThreshold(2, [print]));
		triggers.add(new DemoThreshold(69, [print]));
		triggers.add(new DemoThreshold(59, [print]));
		triggers.add(new DemoThreshold(49, [print]));
		triggers.add(new DemoThreshold(39, [print]));
		triggers.add(new DemoThreshold(29, [print]));
		triggers.add(new DemoThreshold(19, [print]));
		triggers.add(new DemoThreshold(9, [print]));
		triggers.add(new DemoThreshold(4, [print]));
		triggers.add(new DemoThreshold(1, [print]));
		
		text = new FlxText(0, 0, 0, "", 18);
		text.screenCenter(FlxAxes.XY);
		add(text);
		
		var button = new FlxButton(0, 0, "Increment", function():Void {
			triggers.value += 3;
		});
		button.screenCenter(FlxAxes.X);
		button.y = FlxG.height * 0.8;
		add(button);
	}
	
	private function print(previous:Float, next:Float):Void {
		text.text += ("Triggered on change from " + previous + " to " + next + "...\n");
		text.screenCenter(FlxAxes.XY);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);

		lateUpdate(dt);
	}
}