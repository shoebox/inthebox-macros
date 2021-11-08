package tools;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class FieldTool
{
	public static function getFunction(field:Field):Function
	{
		var result:Function;
		switch (field.kind)
		{
			case FFun(f):
				result = f;

			default:
				Context.error("Only function are supported", field.pos);
		}
		return result;
	}

	public static inline function isStaticField(field:Field):Bool
	{
		var result = Lambda.has(field.access, AStatic);
		return result;
	}
}
#end
