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
import lycan.world.components.PhysicsEntity;

class SignalTile extends LSprite implements SignalCarrier implements PhysicsEntity {
	public function new() {
		super();
		
	}
}