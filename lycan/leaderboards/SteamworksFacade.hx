package lycan.leaderboards;

#if steamworksleaderboards

import steamwrap.SteamWrap;
import openfl.Lib;
import openfl.events.Event;

// TODO implement overlay opening achievements panel on native side etc. Source SDK has these but SteamWrap doesn't atm...
@:enum abstract OverlayOption(String) to String {
	var FRIENDS = "Friends";
	var COMMUNITY = "Community";
	var PLAYERS = "Players";
	var SETTINGS = "Settings";
	var OFFICIALGAMEGROUP = "OfficialGameGroup";
	var STATS = "Stats";
	var ACHIEVEMENTS = "Achievements";
}

class SteamworksFacade {
	public static function init(appId:Int):Void {
		trace("Initializing Steamworks");
		Sure.sure(!SteamWrap.active);
		SteamWrap.init(appId);
		
		if (!SteamWrap.active) {
			trace("Failed to initialize Steamworks");
			return;
		}
		
		if (!SteamWrap.isSteamRunning()) {
			trace("Steam is not running. Restarting app in Steam...");
			SteamWrap.restartAppInSteam(); // If a game is launched when Steam is not running we should relaunch it from the Steam client
		}
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, function(e:Dynamic) {
			SteamWrap.onEnterFrame();
		});
	}
	
	public static function submitScore(id:String, score:Int, detail:Int, rank:Int):Void {
		Sure.sure(SteamWrap.active);
		var scoreObject = new LeaderboardScore(id, score, detail, rank);
		
		if(SteamWrap.active) {
			SteamWrap.uploadLeaderboardScore(scoreObject);
		}
	}
	
	public static function openOverlayToUrl(url:String):Void {
		Sure.sure(SteamWrap.active);
		
		if(SteamWrap.active) {
			SteamWrap.openOverlay(url);
		}
	}
	
	public static function isSteamRunning():Bool {
		Sure.sure(SteamWrap.active);
		
		if(SteamWrap.active) {
			return SteamWrap.isSteamRunning();
		}
		
		return false;
	}
	
	// NOTE call this when the game closes
	public static function shutdown():Void {
		Sure.sure(SteamWrap.active);
		
		if(SteamWrap.active) {
			SteamWrap.shutdown();
		}
	}
}

#end