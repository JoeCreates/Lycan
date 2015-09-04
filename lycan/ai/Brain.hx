package lycan.ai;

import haxe.ds.StringMap;
import msignal.Signal.Signal1;

// TODO consider how to do behaviour orchestration/smart scenes with these NPCs and their brains

enum UnprioritizedBehaviourHandlingMode {
	IGNORE_UNWEIGHTED; // Ignore suggested behaviours that the brain doesn't have a priority for
}

// A list of stacks of active behaviours
// var subjectivePriority = suggestedPriority * ethicWeighting
// override ethic could be like nodepriority with the "name"
// a suggestion can have multiple ethics
// importance of ethics has to be done so that all actions can be compared
// each state the set of ethics and weightings that came with it
// a state suggestion also includes an invariant function, this is checked every frame to determine if we should stay in the state or exit it

/*
 joe's notes
[05:04:58] Joe Williamson: running
[05:27:12] Joe Williamson: suggest run away (it affects survival ethic with importance 0.8)
[05:27:45] Joe Williamson: NPC has survival ethic weighting of 1
[05:45:10] Joe Williamson: agent (ethic map, list of stacks of states)
[05:48:02] Joe Williamson: ^ and with each state, the set of ethics and weightings that came with it
[05:57:43] Joe Williamson: make distinction between overriding and removing a state
[05:57:57] Joe Williamson: an overiiding state keeps a list of states it overrode
[05:58:04] Joe Williamson: each in turn might have states they overrode
[05:58:20] Joe Williamson: when a state ends, we attempt to return to the states it overrode
[06:09:01] Joe Williamson: a suggestion also includes an invariant function
[06:09:16] Joe Williamson: this is checked every frame to determine if we should stay in the state
[06:09:18] Joe Williamson: or exit it
*/

// AI for a game entity
class Brain {
	public var signal_behaviourChanged = new Signal1<Node>();
	public var signal_behaviourAccepted = new Signal1<Node>();
	public var signal_behaviourRejected = new Signal1<Node>();
	
	private var activeBehaviours = new List<Node>(); // TODO prefer a set, not a list - there's no inherent ordering to active behaviours
	private var behaviourPriorityWeights:StringMap<Float>; // Maps named behaviours to this brain's priorities
	
	private var unprioritizedBehaviourHandlingMode = UnprioritizedBehaviourHandlingMode.IGNORE_UNWEIGHTED;
	
	public function new(?values:StringMap<Float>) {
		if (values == null) {
			values = new StringMap<Float>();
		}
		
		this.behaviourPriorityWeights = values;
	}
	
	public function offerBehaviour(root:Node, suggestedPriority:NodePriority):Bool {
		var weighting:Null<Float> = behaviourPriorityWeights.get(suggestedPriority.name);
		
		if(weighting == null) {
			weighting = 1;
		}
		
		switch(unprioritizedBehaviourHandlingMode) {
			case IGNORE_UNWEIGHTED:
				weighting = 0;
		}
		
		var subjectivePriority:Float = suggestedPriority.priority * weighting;
		
		// TODO iterate over the active behaviours and see if they can accept the new behaviour at the suggested priority
		// TODO if one/all (??) accept the behaviour, then install it (how?)
		// TODO how does the brain work out which behaviours are compatible with each other?
		
		var accepted:Bool = true;
		
		if (accepted) {
			signal_behaviourAccepted.dispatch(root);
			signal_behaviourChanged.dispatch(root);
			
			// TODO should probably be to replace a behaviour first, rather than add
			activeBehaviours.add(root);
			
			return true;
		} else {
			signal_behaviourRejected.dispatch(root);
			return false;
		}
	}
	
	// TODO need to do a deep comparison - the behaviour may only really the same if the children, histories, queued futures are equal too
	// TODO it would make more sense if we could easily compute a value/number for checking for a behaviour somehow - like with a mask on a bitfield but taking into account the stuff above too
 	public function hasBehaviour(behaviour:Node):Bool {
		for (activeBehaviour in activeBehaviours) {
			if (behaviour.id == activeBehaviour.id) {
				return true;
			}
		}
		
		return false;
	}
}