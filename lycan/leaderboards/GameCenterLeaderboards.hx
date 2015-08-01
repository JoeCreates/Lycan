package lycan.leaderboards;

#if gamecenterleaderboards

import extension.gamecenter.GameCenter;

class GameCenterLeaderboards {
	public static var get(default, never):GameCenterLeaderboards = new GameCenterLeaderboards();
	
	private function new() {
		GameCenter.initialize();
	}
	
	public function openLeaderboard(id:String):Void {
		GameCenter.showLeaderboard(id);
	}
	
	public function openAchievements():Void {
		GameCenter.showAchievements();
	}
	
	public function isAvailable():Bool {
		return GameCenter.available;
	}
	
	public function signIn():Void {
		GameCenter.authenticate();
	}
	
	public function submitScore(id:String, score:Int):Void {
		GameCenter.reportScore(id, score);
	}

    public function updateAchievementProgress(id:String, percent:Float, showBanner:Bool=true):Void {
		GameCenter.reportAchievement(id, percent, showBanner);
    }
}

#end