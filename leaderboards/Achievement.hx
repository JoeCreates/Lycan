package lycan.leaderboards ;

#if (gamecenterleaderboards || googleplayleaderboards || amazonkindleleaderboards || kongregateleaderboards || gamejoltleaderboards)

#if googleplayleaderboards
import leaderboards.GooglePlayLeaderboards;
#end

#if amazonkindleleaderboards
import leaderboards.GameCircleLeaderboards;
#end

#if gamecenterleaderboards
import leaderboards.GameCenterLeaderboards;
#end

#if kongregateleaderboards
import leaderboards.KongregateFacade;
#end

#if gamejoltleaderboards
import leaderboards.GameJoltFacade;
#end

class Achievement {
	public var id:AchievementId;
	public var unlocked:Bool = false;
	private var targetValue:Float = 0;
	
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
		
		#if googleplay
		GooglePlayLeaderboards.get.unlockAchievement(id.googlePlayId);
		#end
		
		#if amazonkindle
		GameCircleLeaderboards.get.updateAchievementProgress(id.amazonId, 100);
		#end
		
		#if ios
		GameCenterLeaderboards.get.updateAchievementProgress(id.gameCenterId, 100);
		#end
		
		#if gamejolt
		GameJoltFacade.addTrophy(id.gameJoltId);
		#end
		
		#if kongregate
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
		
		#if googleplay
		GooglePlayLeaderboards.get.updateAchievementProgress(id.googlePlayId, progressPercent);
		#end
		
		#if amazonkindle
		GameCircleLeaderboards.get.updateAchievementProgress(id.amazonId, progressPercent);
		#end
		
		#if ios
		GameCenterLeaderboards.get.updateAchievementProgress(id.gameCenterId, progressPercent);
		#end
		
		#if gamejolt
		if (progressPercent >= 100) {
			GameJoltFacade.addTrophy(id.gameJoltId);
		}
		#end
		
		#if kongregate
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

#end