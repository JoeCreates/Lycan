package lycan.ai;

import haxe.ds.StringMap;
import msignal.Signal.Signal1;

enum UnprioritizedBehaviourHandlingMode {
	IGNORE_UNWEIGHTED; // Ignore suggested behaviours that the brain doesn't have a priority for
}

// AI for an NPC
class Brain {
	public var signal_behaviourChanged = new Signal1<Node>(); // Attach to this to listen for changes in behaviour
	
	private var activeBehaviours = new List<Node>(); // TODO prefer a set, not a list - there's no inherent ordering to active behaviours
	private var behaviourPriorityWeights:StringMap<Float>; // Maps named behaviours to this brain's priorities
	private var unprioritizedBehaviourHandlingMode = UnprioritizedBehaviourHandlingMode.IGNORE_UNWEIGHTED;
	
	public function new(values:StringMap<Float>) {
		this.behaviourPriorityWeights = values;
	}
	
	public function offerSuggestion(root:Node, suggestedPriority:NodePriority):Bool {
		var weighting:Null<Float> = behaviourPriorityWeights.get(suggestedPriority.name);
		
		switch(unprioritizedBehaviourHandlingMode) {
			case IGNORE_UNWEIGHTED:
				weighting = 0;
			default:
				weighting = 0;
		}
		
		// TODO
		signal_behaviourChanged.dispatch();
		
		return false;
	}
	
	// TODO need to compare the trees - they're only really the same if the children, histories, queued futures are equal too
 	public function hasBehaviour(behaviour:Node):Bool {
		for (activeBehaviour in activeBehaviours) {
			if (state == activeBehaviour) {
				return true;
			}
		}
		
		return false;
	}
}