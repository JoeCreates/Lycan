package lycan.ai;

// Interface that environments the AI is placed in implement, so the AI can query for actions available to them
interface SmartEnvironment {
	public function queryForActions(need:Need):Array<Action>;
}