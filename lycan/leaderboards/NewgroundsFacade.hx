package lycan.leaderboards;

#if newgrounds

import com.newgrounds.API;
import com.newgrounds.APIEvent;
import com.newgrounds.components.MedalPopup;
import flash.Lib;
import flash.utils.ByteArray;
import flixel.FlxG;
import flixel.util.FlxTimer;

class NewgroundsFacade {
	public static var showPopUp(default, null):Bool = false;
	public static dynamic function onConnectedCb(success:Bool):Void {}
	public static var connectionTimeoutMs:Float = 10000;
	
	private static var connectionTimer:FlxTimer = null;
	
	public static function init(gameId:String, privateKey:String, showPopUp:Bool = false, ?onConnectedCb:Bool->Void) {
		NewgroundsFacade.showPopUp = showPopUp;
		NewgroundsFacade.onConnectedCb = onConnectedCb;
		
		if (API.connected) {
			return;
		}
		
		connectionTimer = new FlxTimer().start(connectionTimeoutMs, function(_) {
			API.disconnect();
			NewgroundsFacade.onConnectedCb(API.connected);
		});
		
		API.addEventListener(APIEvent.API_CONNECTED, onConnected);
		API.connect(Lib.current.root, gameId, privateKey);
	}
	
	public static function addMedal(id:String) {
		if (!API.connected) {
			return;
		}
		API.unlockMedal(id);
	}
	
	public static function submitScore(scoreboard:String, score:Int) {
		if (!API.connected) {
			return;
		}
		API.postScore(scoreboard, score);
	}
	
	private static function onConnected(event:APIEvent) {
		API.removeEventListener(APIEvent.API_CONNECTED, onConnected);
		
		connectionTimer.cancel();
		
		NewgroundsFacade.onConnectedCb(API.connected);
		
		if (showPopUp) {
			var popup:MedalPopup = new MedalPopup();
			popup.x = (FlxG.width * FlxG.initialZoom) / 2 - popup.width / 2;
			popup.y = 2;
			popup.alwaysOnTop = "true";
			Lib.current.stage.addChild(popup);
		}
	}
}

#end