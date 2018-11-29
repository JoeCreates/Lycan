package lycan.supply;

import flixel.util.FlxColor;
import lycan.supply.Node.EdgeTwoWay;
import lycan.supply.Node.SignalHolder;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.FlxG;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;
import haxe.ds.Map;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxBasic;
import lycan.supply.Node;

interface SignalCarrier extends Entity {
	public var signalCarrier:SignalCarrierComponent;
}

@:tink
class SignalCarrierComponent extends Component<SignalCarrier> {
	@:forward var _basic:FlxBasic;
	public var nodes:Array<Node>;
	public var edges:Array<Edge>;
	
	public function new(entity:SignalCarrier) {
		super(entity);
		_basic = cast entity;
		nodes = [];
		edges = [];
		
		FlxG.signals.preUpdate.add(earlyUpdate);
	}
	
	public function drawToSprite(sprite:FlxSprite, forceSignalOn:Bool = false):Void {
		for (e in edges) {
			FlxSpriteUtil.drawLine(sprite, e.input.x, e.input.y, e.output.x, e.output.y, {color: FlxColor.fromHSB(1, 0, e.signalOn || forceSignalOn ? 1 : 0.5, 1), thickness: 10});
		}
	}
	
	@:append("destroy") public function destroy():Void {
		FlxG.signals.preUpdate.remove(earlyUpdate);
	}
	
	public function earlyUpdate() {
		if (exists && alive) {
			for (node in nodes) {
				node.update(FlxG.elapsed);
			}
			for (edge in edges) {
				edge.update(FlxG.elapsed);
			}
		}
	}
}