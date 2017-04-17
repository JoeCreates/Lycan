package lycan.leaderboards;

#if gamejoltleaderboards

import flixel.addons.api.FlxGameJolt;

// TODO replace dynamics with typesafe stuff
class GameJoltFacade {
	public static function init(gameId:Int, privateKey:String, autoAuth:Bool = false, ?userName:String, ?userToken:String, ?cb:Null<Bool->Void>):Void {
		FlxGameJolt.init(gameId, privateKey, autoAuth, userName, userToken, cb);
	}
	
	public static function openSession(?cb:Dynamic):Void {
		FlxGameJolt.openSession(cb);
	}
	
	public static function pingSession(?active:Bool = true, ?cb:Dynamic):Void {
		FlxGameJolt.pingSession(active, cb);
	}
	
	public static function closeSession(?cb:Dynamic):Void {
		FlxGameJolt.closeSession(cb);
	}
	
	public static function authUser(?userName:String, ?userToken:String, ?cb:Dynamic):Void {
		FlxGameJolt.authUser(userName, userToken, cb);
	}
	
	public static function addScore(score:String, sort:Float, ?tableId:Int, ?allowGuest:Bool = false, ?guestName:String, ?extraData:String, ?cb:Dynamic):Void {
		FlxGameJolt.addScore(score, sort, tableId, allowGuest, guestName, extraData, cb);
	}
	
	public static function addTrophy(trophyId:Int, ?cb:Dynamic):Void {
		FlxGameJolt.addTrophy(trophyId, cb);
	}
}

#end