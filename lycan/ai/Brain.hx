package lycan.ai;

import haxe.ds.IntMap;
import msignal.Signal;

using lycan.util.ArrayExtensions;

// A list of stacks of active behaviours
// var subjectivePriority = suggestedPriority * ethicWeighting
// override ethic could be like nodepriority with the "name"
// a suggestion can have multiple ethics
// importance of ethics has to be done so that all actions can be compared
// each state the set of ethics and weightings that came with it
// a state suggestion also includes an invariant function, this is checked every frame to determine if we should stay in the state or exit it

// Represents an AI
class Brain {
	public var world(default, null):Dynamic;
	public var needs(default, null):Array<Need>; // Reasons for doing stuff
	public var needTraits(default, null):IntMap<Float->Float>; // Motive traits affect the way some motives change over time e.g. slobs get hungrier faster
	public var actionTraits(default, null):IntMap<Float->Float>; // Action traits affect the way actions are calculated e.g. override or modify effects
	
	public var signal_actionSelected:Signal1<Action> = new Signal1<Action>();
	
	public function new() {
	}
	
	public function init(world:Dynamic, needs:Array<Need>, needTraits:IntMap<Float->Float>, actionTraits:IntMap<Float->Float>) {
		this.world = world;
		this.needs = needs;
		this.needTraits = needTraits;
		this.actionTraits = actionTraits;
	}
	
	public function act(action:Action):Void {
		for (effect in action.effects) {
			effect.effect(world);
		}
	}
	
	public function update(dt:Float):Void {
		for (need in needs) {
			need.update(dt);
		}
		
		var need = getGreatestNeed();
		
		if (need != null) {
			var actions = findActions(need);
			signal_actionSelected.dispatch(actions.randomElement());
		}
	}
	
	private inline function getGreatestNeed():Need {
		var idx:Int = 0;
		var value:Float = 0;
		for (i in 0...needs.length) {
			if (needs[i].value > value) {
				value = needs[idx].value;
				idx = i;
			}
		}
		return needs[idx];
	}
	
	private inline function findActions(need:Need):Array<Action> {
		Sure.sure(world.queryContextForActions != null);
		return world.queryContextForActions(need);
	}
}