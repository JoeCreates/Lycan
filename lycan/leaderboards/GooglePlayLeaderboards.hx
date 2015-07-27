package lycan.leaderboards;

#if googleplayleaderboards

import extension.gpg.GooglePlayGames;
import openfl.Lib;

class GooglePlayLeaderboards {

	public static var get(default, never):GooglePlayLeaderboards = new GooglePlayLeaderboards();
	
	private function new() {
		GooglePlayGames.init(false);
	}
	
	public function openLeaderboard(id:String):Void {
		if (id.length > 0) {
			GooglePlayGames.displayScoreboard(id);
		} else {
			GooglePlayGames.displayAllScoreboards();
		}
	}
	
	public function openAchievements():Void {
		GooglePlayGames.displayAchievements();
	}
	
	public function signIn():Void {
		GooglePlayGames.login();
	}
	
	public function unlockAchievement(id:String):Void {
		GooglePlayGames.unlock(id);
	}
	
    public function updateAchievementProgress(id:String, steps:Int):Void {
		GooglePlayGames.setSteps(id, steps);
    }
	
	public function submitScore(id:String, score:Int):Void {
		GooglePlayGames.setScore(id, score);
	}
}

#end