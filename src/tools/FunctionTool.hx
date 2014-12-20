package tools;

import haxe.macro.Expr;

class FunctionTool
{
	static inline function getArgsNames(func:Function):Array<Expr>
	{
		var result:Array<Expr> = [for (a in func.args) macro $i{a.name}];
		return result;
	}

	static inline function isStaticField(field:Field):Bool
	{
		var result = Lambda.has(field.access, AStatic);
		return result;
	}

	static function createReturnExpr(func:Function, name:String, 
		args:Array<Expr>):Expr
	{
		var expr:Expr = macro "";
		var params = func.ret.getParameters();
		if (params[0].name == "Void")
		{
			expr = macro $i{name}($a{args});
		}
		else
		{
			expr = macro return $i{name}($a{args});
		}
		
		return expr;
	}	
}
