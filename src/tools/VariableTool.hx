package tools;

import haxe.macro.Context;
import haxe.macro.Expr;

class VariableTool
{
	public static function create(reference:Function, name:String,
		position:Position):Field
	{
		var types = [for (arg in reference.args) arg.type];
		var fieldType : FieldType = FVar(TFunction(types, reference.ret));
			
		return
		{
			name : name,
			doc	: null,
			meta : [],
			access : [APublic,AStatic],
			kind : fieldType,
			pos	: position
		};
	}
}
