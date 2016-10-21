import org.shoebox.macros.*;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class ShortCuts
{
	function new(){}

	static public function mirrors( ):Array<Field>
	{
		return mirror.Mirror.build();
	}
}
