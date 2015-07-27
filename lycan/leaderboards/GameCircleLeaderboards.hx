package lycan.leaderboards;

#if gamecircleleaderboards

import extension.gamecircle.gc.GameCircleListener;
import extension.gamecircle.gc.GamesClient;
import extension.gamecircle.GameCircle;
import extension.gamecircle.gc.PopUpLocation;

class GameCircleLeaderboards {
	public static var get(default, never):GameCircleLeaderboards = new GameCircleLeaderboards();
	
	private var leaderboards:GameCircle;
	
	private function new() {
		leaderboards = new GameCircle();
	}
	
	public function setListener(listener:GameCircleListener):Void {
		leaderboards.setListener(listener);
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
	
	public function setPopUpLocation(location:PopUpLocation):Void {
		leaderboards.games.setPopUpLocation(location);
	}
}

#end