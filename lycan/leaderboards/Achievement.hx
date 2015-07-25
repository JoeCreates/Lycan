package lycan.leaderboards;

#if googleplayleaderboards
import lycan.leaderboards.GooglePlayLeaderboards;
#end

#if amazonkindleleaderboards
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

class Achievement {
	public var id(default, null):AchievementId;
	public var unlocked(default, null):Bool = false;
	public var targetValue(default, null):Float = 0;
	
	public function new(id:AchievementId, ?targetValue:Float):Void {
		this.id = id;
		unlocked = false;
		if(targetValue != null) {
			this.targetValue = targetValue;
		}
	}
	
	public function unlock():Void {
		if (unlocked) {
			return;
		}
		
		unlocked = true;
		
		#if debug
		trace("Achievement unlocked: " + id.gameCenterId);
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.unlockAchievement(id.googlePlayId);
		#end
		
		#if amazonkindleleaderboards
		GameCircleLeaderboards.get.updateAchievementProgress(id.amazonId, 100);
		#end
		
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.updateAchievementProgress(id.gameCenterId, 100);
		#end
		
		#if gamejoltleaderboards
		GameJoltFacade.addTrophy(id.gameJoltId);
		#end
		
		#if kongregateleaderboards
		if (targetValue == null) {
			KongregateFacade.submitStat(id.kongregateId, 1);
		}
		#end
	}
	
	public function updateProgress(currentValue:Float):Void {
		#if debug
		trace("Achievement updated: " + id.gameCenterId);
		#end
		
		var progressPercent:Float = Math.min(100, ((currentValue / targetValue) * 100));
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.updateAchievementProgress(id.googlePlayId, Std.int(currentValue));
		#end
		
		#if amazonkindleleaderboards
		GameCircleLeaderboards.get.updateAchievementProgress(id.amazonId, progressPercent);
		#end
		
		#if gamecenterleaderboards
		GameCenterLeaderboards.get.updateAchievementProgress(id.gameCenterId, progressPercent);
		#end
		
		#if gamejoltleaderboards
		if (progressPercent >= 100) {
			GameJoltFacade.addTrophy(id.gameJoltId);
		}
		#end
		
		#if kongregateleaderboards
		KongregateFacade.submitStat(id.kongregateId, currentValue);
		#end
	}
}

typedef AchievementId = {
	googlePlayId:String,
	gameCenterId:String,
	kongregateId:String,
	gameJoltId:Int,
	amazonId:String
};