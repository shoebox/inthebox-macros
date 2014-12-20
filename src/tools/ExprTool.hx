package tools;

import haxe.macro.Expr;

class ExprTool
{
	public static function getString(expr:Expr):String
	{
		var result:String;
		if (expr != null)
		{
			result = switch (expr.expr.getParameters()[0])
			{
				case CString(value): value;
				default: null;
			}
		}

		return result;
	}
}
