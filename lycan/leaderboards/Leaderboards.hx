package lycan.leaderboards;

#if googleplayleaderboards
import lycan.leaderboards.Leaderboards;
#end

#if gamecircleleaderboards
import lycan.leaderboards.GameCircleLeaderboards;
#end

#if gamecenterleaderboards
import lycan.leaderboards.GameCenterLeaderboards;
#end

#if kongregateleaderboards
import lycan.leaderboards.KongregateFacade;
#end

#if gamejoltleaderboards
import lycan.leaderboards.GameJoltFacade;
#end

class Leaderboards {
	public static var get(default, never):Leaderboards = new Leaderboards();
	
	private function new() {
	}
	
	public static function init():Void {
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.init();
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.init();
		#end
		
		#if gamecircleleaderboards
		GameCircleLeaderboards.get.init();
		#end
		
		#if kongregateleaderboards
		KongregateFacade.init(onKongregateLoaded);
		#end
		
		#if gamejoltleaderboards
		if (gameId == 0 || privateKey == null) {
			throw "Set the GameJolt gameId and privateKey before initializing leaderboards";
		}
		GameJoltFacade.init(gameId, privateKey, autoAuth, userName, onGameJoltLoaded);
		#end
	}
	
	public static function openLeaderboard(id:Dynamic):Void {
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.openLeaderboard(id);
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.openLeaderboard(id);
		#end
		
		#if gamecircleleaderboards
		GameCircleLeaderboards.get.openLeaderboard(id);
		#end
		
		#if kongregateleaderboards
		#end
		
		#if gamejoltleaderboards
		#end
	}
	
	public static function openAchievements():Void {
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.openAchievements();
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.openAchievements();
		#end
		
		#if gamecircleleaderboards
		GameCircleLeaderboards.get.openAchievements();
		#end
		
		#if kongregateleaderboards
		#end
		
		#if gamejoltleaderboards
		#end
	}
	
	public static function signIn():Void {
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.signIn();
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.signIn();
		#end
		
		#if gamecircleleaderboards
		GameCircleLeaderboards.get.signIn();
		#end
		
		#if kongregateleaderboards
		#end
		
		#if gamejoltleaderboards
		#end
	}
	
	public static function submitScore(score:Int, ?leaderboardId:Dynamic):Void {		
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.submitScore(leaderboardId, score);
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.submitScore(leaderboardId, score);
		#end
		
		#if gamecircleleaderboards
		GameCircleLeaderboards.get.submitScore(leaderboardId, score);
		#end
		
		#if kongregateleaderboards
		KongregateFacade.submitScore(score, "normal");
		#end
		
		#if gamejoltleaderboards
		GameJoltFacade.addScore(Std.string(score), score);
		#end
	}
	
	#if kongregateleaderboards
	private static function onKongregateLoaded():Void {
		KongregateFacade.connect();
	}
	#end
	
	#if gamejoltleaderboards
	
	public var gameId:Int = 0;
	public var privateKey:String = null;
	public var autoAuth:Bool = false;
	public var userName:String = null;
	public var userToken:String = null;
	
	private static function onGameJoltLoaded():Void {
		GameJoltFacade.authUser(null, null, onGameJoltAuthorized);
	}
	
	private static function onGameJoltAuthorized():Void {
		GameJoltFacade.openSession(onGameJoltSessionOpened);
	}
	
	private static function onGameJoltSessionOpened():Void {
		new FlxTimer(30, function(t:FlxTimer):Void {
			GameJoltFacade.pingSession(true, onGameJoltPingedSession);
		}, 0);
	}
	
	private static function onGameJoltPingedSession():Void {
		#if debug
		trace("Pinged GameJolt session");
		#end
	}
	#end
}