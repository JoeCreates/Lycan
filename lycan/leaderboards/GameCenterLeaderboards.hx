package lycan.leaderboards;

#if gamecenterleaderboards

import extension.gamecentermanager.GameCenterManager;
import extension.gamecentermanager.GameCenterSortOrder;

class GameCenterLeaderboards {
	public static var get(default, never):GameCenterLeaderboards = new GameCenterLeaderboards();
	
	private function new() {
		GameCenterManager.setupManager();
	}
	
	public function openLeaderboard(id:String):Void {
		GameCenterManager.presentLeaderboards();
	}
	
	public function openAchievements():Void {
		GameCenterManager.presentAchievements();
	}
	
	public function isAvailable():Bool {
		return GameCenterManager.isGameCenterAvailable();
	}
	
	public function signIn():Void {
		GameCenterManager.authenticateUser();
	}
	
	public function submitScore(id:String, score:Int, sortOrder:GameCenterSortOrder = GameCenterSortOrder.HIGH_TO_LOW):Void {
		GameCenterManager.saveAndReportScore(id, score, sortOrder);
	}

    public function updateAchievementProgress(id:String, percent:Float, showBanner:Bool = true):Void {
		GameCenterManager.saveAndReportAchievement(id, percent, showBanner);
    }
}

#end