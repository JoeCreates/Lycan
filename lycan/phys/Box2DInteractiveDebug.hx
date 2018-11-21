package lycan.phys;

import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2FilterData;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import lime.math.Rectangle;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2FilterData;

/**
 * Box2D debugging utility, lets you drag world bodies around with the mouse/manipulate with keyboard.
 */
class Box2DInteractiveDebug {
	private static var _aabb:B2AABB = new B2AABB();
	private static var _mouseJointDef:B2MouseJointDef = new B2MouseJointDef();
	
	public var mouseJoint:B2MouseJoint = null;
	public var mouseX(get, never):Float;
	public var mouseY(get, never):Float;
	public var physicsMouseX(get, never):Float;
	public var physicsMouseY(get, never):Float;
	
	public function new() {
	}
	
	public function update():Void {
		handleMouse();
		handleKeys();
	}
	
	public function getBodyAtMouse():B2Body {
		// Make a small box around the mouse position
		var mousePVec = vec2(physicsMouseX, physicsMouseY);
		_aabb.lowerBound.set(physicsMouseX - 0.001, physicsMouseY - 0.001);
		_aabb.upperBound.set(physicsMouseX + 0.001, physicsMouseY + 0.001);
		var body:B2Body = null;
		
		// Query the world for overlapping shapes
		var getBodyCallback = function(fixture:B2Fixture):Bool {
			var shape:B2Shape = fixture.getShape();
			if (shape.testPoint(fixture.getBody().getTransform(), mousePVec)) {
				body = fixture.getBody();
				return false;
			}
			return true;
		}
		Phys.world.queryAABB(getBodyCallback, _aabb);
		return body;
	}
	
	public function handleMouse():Void {
		if (mouseJoint == null) {
			if (FlxG.mouse.justPressed) {
				var bodyAtMouse = getBodyAtMouse();
				if (bodyAtMouse != null) {
					_mouseJointDef.bodyA = Phys.world.getGroundBody();
					_mouseJointDef.bodyB = bodyAtMouse;
					_mouseJointDef.target.set(physicsMouseX, physicsMouseY);
					_mouseJointDef.collideConnected = true;
					_mouseJointDef.maxForce = 300 * bodyAtMouse.getMass();
					mouseJoint = cast Phys.world.createJoint(_mouseJointDef);
					
					bodyAtMouse.setAwake(true);
				}
			}
		} else {
			if (!FlxG.mouse.pressed) {
				Phys.world.destroyJoint(mouseJoint);
				mouseJoint = null;
			} else if (FlxG.mouse.justMoved) {
				mouseJoint.setTarget(vec2(physicsMouseX, physicsMouseY));
			}
		}
	}
	
	public function handleKeys():Void {

	}
	
	private function get_mouseX():Float {
		return FlxG.mouse.x;
	}
	private function get_mouseY():Float {
		return FlxG.mouse.y;
	}
	private function get_physicsMouseX():Float {
		return mouseX / Phys.pixelsPerMeter;
	}
	private function get_physicsMouseY():Float {
		return mouseY / Phys.pixelsPerMeter;
	}
	
	/** Helpers to reduce object instantiation */
	private static var _vec2:B2Vec2 = new B2Vec2();
	private static function vec2(x:Float, y:Float):B2Vec2 {
		_vec2.set(x, y);
		return _vec2;
	}
}