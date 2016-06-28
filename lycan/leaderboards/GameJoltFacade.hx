package lycan.leaderboards;

#if gamejoltleaderboards

import flixel.addons.api.FlxGameJolt;

// TODO replace dynamics with typesafe stuff
class GameJoltFacade {
	public static function init(gameId:Int, privateKey:String, ?autoAuth:Bool = false, userName:String = null, ?userToken:String = null, ?cb:Null<Bool->Void>):Void {
		FlxGameJolt.init(gameId, privateKey, autoAuth, userName, userToken, cb);
	}
	
	public static function openSession(?cb:Dynamic = null):Void {
		FlxGameJolt.openSession(cb);
	}
	
	public static function pingSession(?active:Bool = true, ?cb:Dynamic = null):Void {
		FlxGameJolt.pingSession(active, cb);
	}
	
	public static function closeSession(?cb:Dynamic = null):Void {
		FlxGameJolt.closeSession(cb);
	}
	
	public static function authUser(?userName:String = null, ?userToken:String = null, ?cb:Dynamic = null):Void {
		FlxGameJolt.authUser(userName, userToken, cb);
	}
	
	public static function addScore(score:String, sort:Float, ?tableId:Int = null, ?allowGuest:Bool = false, ?guestName:String = null, ?extraData:String = null, ?cb:Dynamic = null):Void {
		FlxGameJolt.addScore(score, sort, tableId, allowGuest, guestName, extraData, cb);
	}
	
	public static function addTrophy(trophyId:Int, ?cb:Dynamic = null):Void {
		FlxGameJolt.addTrophy(trophyId, cb);
	}
}

#end