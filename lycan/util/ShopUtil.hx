package lycan.util;

import haxe.macro.Expr;
import haxe.macro.Type;

class ShopUtil {
	/** 
	 * Example usage: `spend(player.gold -= 10, gems -= 5);`
	 * Decrements a set of any number of variables provided all would remain >= 0
	 * Returns true if they were decremented, or false otherwise
	**/
	macro public static function spend(costs:Array<Expr>) {
		var conditionExpr:Expr = macro true;
		var spendExpr:Expr = macro {};

		for (cost in costs) {
			switch (cost.expr) {
				case EBinop(OpAssignOp(OpSub), lhs, rhs):
					conditionExpr = macro $conditionExpr && ($lhs >= $rhs);
					spendExpr = macro {$spendExpr; $cost;}
				case _:
					throw("Invalid cost expression");
			}
		}

		return macro if ($conditionExpr) {
			$spendExpr;
			true;
		} else {
			false;
		}
	}
}

