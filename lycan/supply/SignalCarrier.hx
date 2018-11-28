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
import lycan.util.structure.tree.EditableIntervalTree;
import flixel.FlxBasic;

interface SignalCarrier extends Entity {
	public var signalCarrier:SignalCarrierComponent;
}

@:tink
class SignalCarrierComponent extends Component<SignalCarrier> {
	@:forward var _basic:FlxBasic;
	public var nodes:Array<Node>;
	public var edges:Array<EdgeTwoWay>;
	
	public function new(entity:SignalCarrier) {
		super(entity);
		_basic = cast entity;
		
		FlxG.signals.preUpdate.add(earlyUpdate);
	}
	
	public function drawToSprite(sprite:FlxSprite):Void {
		for (e in edges) {
			FlxSpriteUtil.drawLine(sprite, e.nodeA.x, e.nodeA.y, e.nodeB.x, e.nodeB.y, {color: FlxColor.fromHSB(1, 1, e.signalOn ? 1 : 0.5, 1), thickness: 10});
		}
	}
	
	@:append("destroy") public function destroy():Void {
		FlxG.signals.preUpdate.remove(earlyUpdate);
	}
	
	public function earlyUpdate() {
		if (exists && alive) {
			for (node in nodes) {
				node.update(dt);
			}
		}
	}
}