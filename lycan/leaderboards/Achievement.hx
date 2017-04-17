package lycan.leaderboards;

#if googleplayleaderboards
import lycan.leaderboards.GooglePlayLeaderboards;
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

#if newgroundsleaderboards
import lycan.leaderboards.NewgroundsFacade;
#end

#if steamworksleaderboards
import lycan.leaderboards.SteamworksFacade;
#end

class Achievement {
	public var id(default, null):AchievementId;
	public var unlocked(default, null):Bool = false;
	public var targetValue(default, null):Null<Float> = 0;
	
	public function new(id:AchievementId, ?targetValue:Null<Float>):Void {
		this.id = id;
		unlocked = false;
		if(targetValue != null) {
			this.targetValue = targetValue;
		}
	}
	
	public function reveal():Void {
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.revealAchievementImmediate(id.googlePlayId);
		#end
	}
	
	public function unlock():Void {
		if (unlocked) {
			return;
		}
		
		unlocked = true;
		
		#if debug
		trace("Achievement unlocked: " + id.gameCenterId);
		#end
		
		#if steamworksleaderboards
		SteamworksFacade.unlockAchievement(id.steamworksId);
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.unlockAchievement(id.googlePlayId);
		#end
		
		#if gamecircleleaderboards
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
		
		#if newgroundsleaderboards
		NewgroundsFacade.addMedal(id.newgroundsId);
		#end
	}
	
	public function updateProgress(currentValue:Float):Void {
		#if debug
		trace("Achievement updated: " + id.gameCenterId);
		#end
		
		var progressPercent:Float = Math.min(100, ((currentValue / targetValue) * 100));
		
		#if steamworksleaderboards
		SteamworksFacade.indicateAchievementProgress(id.steamworksId, IntExtensions.min(currentValue, targetValue), targetValue);
		#end
		
		#if googleplayleaderboards
		GooglePlayLeaderboards.get.setAchievementSteps(id.googlePlayId, Std.int(currentValue));
		#end
		
		#if gamecircleleaderboards
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
		
		#if newgroundsleaderboards
		if (progressPercent >= 100) {
			NewgroundsFacade.addMedal(id.newgroundsId);
		}
		#end
	}
}

typedef AchievementId = {
	googlePlayId:String,
	gameCenterId:String,
	kongregateId:String,
	newgroundsId:String,
	gameJoltId:Int,
	amazonId:String,
	steamworksId:String
};