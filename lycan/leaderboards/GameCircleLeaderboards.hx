package lycan.leaderboards;

#if gamecircleleaderboards

import extension.gamecircle.gc.ConnectionHandler;
import extension.gamecircle.gc.GamesClient;
import extension.gamecircle.GameCircle;

class GameCircleLeaderboards {
	public static var get(default, never):GameCircleLeaderboards = new GameCircleLeaderboards();
	
	private var leaderboards:GameCircle;
	private var connectionHandler:GameCircleConnectionHandler;
	
	private function new() {
	}
	
	public function init():Void {		
		connectionHandler = new GameCircleConnectionHandler();
		leaderboards = new GameCircle(connectionHandler);
	}
	
	public function openLeaderboard(id:String):Void {
		leaderboards.games.showLeaderboard(id);
	}
	
	public function openAchievements():Void {
		leaderboards.games.showAchievements();
	}
	
	public function isSignedIn():Bool {
		return leaderboards.games.isSignedIn();
	}
	
	public function signIn():Void {
		leaderboards.games.showSignInPage();
	}
	
	public function submitScore(id:String, score:Int):Void {
		leaderboards.games.submitScore(id, score, "");
	}
	
	public function updateAchievementProgress(id:String, percent:Float):Void {
		leaderboards.games.updateAchievement(id, percent, "");
	}
}

class GameCircleConnectionHandler extends ConnectionHandler {
	override public function onWarning(msg:String, where:String) {
	}

	override public function onError(what:String, code:Int, where:String) {
	}

	override public function onException(msg:String, where:String) {
	}

	override public function onConnectionEstablished(what:String) {
	}

	override public function onSignedOut(what:String) {
	}
}

#end