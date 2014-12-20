package tools;

import haxe.macro.Context;
import haxe.macro.Expr;

class VariableTool
{
	public static function create(refFunction:Function, name:String,
		position:Position):Field
	{
		var types = [for (arg in refFunction.args) arg.type];
		var fieldType : FieldType = FVar(TFunction(types, refFunction.ret));
			
		return
		{
			name	: name,
			doc		: null,
			meta	: [],
			access	: [APublic,AStatic],
			kind	: fieldType,
			pos		: position
		};
	}
}
