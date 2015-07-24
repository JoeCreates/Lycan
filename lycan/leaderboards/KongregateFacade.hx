package lycan.leaderboards;

#if kongregateleaderboards

import flixel.addons.api.FlxKongregate;

class KongregateFacade {
	public static function init(onLoadedCb:Void->Void):Void {
		FlxKongregate.init(onLoadedCb);
	}
	
	public static function addEventListener(contentType:String, cb:Void->Void):Void {
		FlxKongregate.addEventListener(contentType, cb);
	}
	
	public static function connect():Void {
		FlxKongregate.connect();
	}
	
	public static function disconnect():Void {
		FlxKongregate.disconnect();
	}
	
	public static function submitStat(name:String, value:Float):Void {
		FlxKongregate.submitStats(name, value);
	}
	
	public static function submitScore(score:Float, gameMode:String):Void {
		FlxKongregate.submitScore(score, gameMode);
	}
	
	public static function showSignInPage():Void {
		FlxKongregate.showSignInBox();
	}
	
	public static function showRegistrationPage():Void {
		FlxKongregate.showRegistrationBox();
	}
	
	public static function isGuest():Bool {
		return FlxKongregate.isGuest();
	}
	
	public static function getUserName():String {
		return FlxKongregate.getUserName();
	}
	
	public static function getUserId():Float {
		return FlxKongregate.getUserId();
	}
}

#end