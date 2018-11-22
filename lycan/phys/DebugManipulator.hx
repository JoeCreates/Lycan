package lycan.phys;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import nape.constraint.PivotJoint;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import openfl.Assets;
import openfl.geom.Matrix;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;

class DebugManipulator {
	var hand:PivotJoint;
	var bodyList:BodyList;
	
	public function new() {
		hand = new PivotJoint(Phys.space.world, null, Vec2.weak(), Vec2.weak());
		hand.active = false;
		hand.stiff = false;
		hand.maxForce = 1e5;
		hand.space = Phys.space;
	}
	
	public function update():Void {
		if (FlxG.mouse.justPressed) {
			bodyList = Phys.space.bodiesUnderPoint(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y), null, bodyList);
			
			for (body in bodyList) {
				if (body.isDynamic()) {
					hand.body2 = body;
					hand.anchor2 = body.worldPointToLocal(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y), true);
					hand.active = true;
					break;
				}
			}
			
			bodyList.clear();
		}
		else if (FlxG.mouse.justReleased) {
			hand.active = false;
		}
		
		if (hand.active) {
			hand.anchor1.setxy(FlxG.mouse.x, FlxG.mouse.y);
			hand.body2.angularVel *= 0.9;
		}
	}
}