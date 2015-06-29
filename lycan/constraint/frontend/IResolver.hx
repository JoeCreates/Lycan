package lycan.constraint.frontend;

interface IResolver {
	public function resolveVariable(name:String):Variable;
	public function resolveConstant(expression:String):Expression;
}