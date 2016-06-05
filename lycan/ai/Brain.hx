package lycan.ai;

import ai.NeedId;
import haxe.ds.IntMap;
import msignal.Signal;
import haxe.ds.GenericStack;
import lycan.util.structure.container.LinkedList;

using lycan.core.ArrayExtensions;

// Represents an AI
class Brain<T:SmartEnvironment> {
    public var world(default, null):T;

    private var actionQueues(default, null):GenericStack<LinkedList<Action>>; // Future actions are stored in a queue (linked list), which can be pushed down a stack for temporary interruptions

    private var needs(default, null):Array<Need>; // Reasons for doing stuff
    private var needTraits(default, null):IntMap<Float -> Float>; // Motive traits affect the way some motives change over time e.g. slobs get hungrier faster
    private var actionTraits(default, null):IntMap<Float -> Float>; // Action traits affect the way actions are calculated e.g. override or modify the effects of actions

    public var signal_actionChosen(default, null) = new Signal1<Action>(); // Fires when the brain chooses a new action based on needs
    public var signal_actionAdded(default, null) = new Signal1<Action>(); // Fires when any action is added, via AI or manually
    public var signal_actionCompleted(default, null) = new Signal1<Action>(); // Fires when an action is reported to have successfully completed
    public var signal_actionCancelled(default, null) = new Signal1<Action>(); // Fires when the current action is cancelled
    public var signal_actionsCancelled(default, null) = new Signal0(); // Fires when all actions are cancelled
    public var signal_actionsInterrupted(default, null) = new Signal2<LinkedList<Action>, LinkedList<Action>>(); // Fires when the current queue of actions is interrupted by another queue

    // TODO cache the current action
    public function onActionComplete():Void {
        //action.completed(this);
        blocked = false;
        var currentQueue = actionQueues.first();
        currentQueue.pop();
        //signal_actionCompleted.dispatch(current);
    }
    private var blocked:Bool; // Whether the actor is currently busy and can't choose new actions. NOTE may need extra override for an interrupt where you want to force the brain to choose an action and not plan anything

    public function new() {
        actionQueues = new GenericStack<LinkedList<Action>>();
        actionQueues.add(new LinkedList<Action>());
        blocked = false;
    }

    public function init(world:T, needs:Array<Need>, needTraits:IntMap<Float->Float>, actionTraits:IntMap<Float->Float>) {
        this.world = world;
        this.needs = needs;
        this.needTraits = needTraits;
        this.actionTraits = actionTraits;
    }

    // Adds an action to the current queue of future actions
    private function addAction(action:Action):Void {
        var top = actionQueues.first();
        top.push(action);
        action.started(this);
        signal_actionAdded.dispatch(action);
    }

    // Interrupts all queued actions and adds a new queue to the top of the stack action queues
    public function interrupt(actions:Array<Action>):Void {
        if(!actionQueues.isEmpty()) {
            var top = actionQueues.first(); // TODO should maybe only interrupt the most recent item (if that's the only one running, it's the only one that really needs the interrupt method calling)
            for (item in top) {
                item.interrupted(this);
            }
        }

        actionQueues.add(new LinkedList<Action>());
        for (action in actions) {
            addAction(action);
        }

        // TODO
        //signal_actionInterrupted.dispatch(
    }

    // Cancels the current action, if there is one. Drops down to the next queue if there is one
    public function cancelCurrent():Void {
        if (actionQueues.isEmpty()) {
            return;
        }

        var top = actionQueues.first();
        if (top.length != 0) {
            var current = top.pop();
            current.cancelled(this);
            signal_actionCancelled.dispatch(current);

            if (top.length == 0) {
                actionQueues.pop();
            }
        }
    }

    public function cancelAll():Void {
        while (!actionQueues.isEmpty()) {
            var actions = actionQueues.pop();
            for (action in actions) {
                action.cancelled(this); // NOTE need to actually cancel the action itself i.e. message needs to reach component doing it, not just remove it from the brain's action queue
            }
        }

        signal_actionsCancelled.dispatch();
    }

    public function increaseNeed(id:NeedId, value:Float):Void {
        for (need in needs) {
            if (need.id == id) {
                need.value += value;
                break;
            }
        }
    }

    public function update(dt:Float):Void {
        for (need in needs) {
            need.update(dt);
        }

        if (blocked) { // TODO a state suggestion also includes an invariant function, this is checked every frame to determine if we should stay in the state or exit it - could either use this, or use a signal to decide if the brain is blocked?
            return;
        }

        var need = getGreatestNeed(); // TODO the NPC should be able to override the strategy for getting the need

        if (need != null) {
            var actions = findActions(need);

            var action = actions.randomElement(); // TODO the brain should do something more sophisticated when deciding which action to perform

            addAction(action);
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
        return world.queryForActions(need);
    }
}