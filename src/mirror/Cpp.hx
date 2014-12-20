package mirror;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using haxe.macro.Tools;
using mirror.CppFieldTool;
using tools.ExprTool;
using tools.FieldTool;
using tools.FunctionTool;
using tools.MetadataTools;
using tools.VariableTool;

class Cpp
{
	function new(){}

	public static function build(field:Field, localClass:ClassType):Field
	{
		var library = field.getLibraryName(localClass);
		var primitive = field.getPrimitiveName(localClass);
		var func = field.getFunction();
		var argsCount = func.args.length;

		#if munit
		var entryPrimitive = MetadataTools.create("cpp_primitive", field.pos, 
			[macro $v{primitive}]);
		field.meta.push(entryPrimitive);

		var entryLibrary = MetadataTools.create("cpp_library", field.pos, 
			[macro $v{library}]);
		field.meta.push(entryLibrary);
		#end

		#if (verbose_mirrors)
		Sys.println($v{library} + " :: " + $v{primitive} + '($argsCount)');
		#end

		var fieldName = getMirrorName(field.name);
		var args = func.getArgsNames();
		var argsCount = args.length;
		var returnExpr = func.createReturnExpr(fieldName, args);
		var result = func.create(fieldName, field.pos);
		if (Context.defined("cpp"))
		{
			func.expr = macro
			{
				if ($i{fieldName} == null)
				{
					$i{fieldName} = cpp.Lib.load($v{library}, $v{primitive}, $v{argsCount});
					#if verbose_mirrors
					Sys.println("Lib not loaded, loading it");
					Sys.println($v{library} + "::" + $v{primitive} + '($argsCount)');
					#end
				}
				$returnExpr;
			}
		}

		return result;
	}

	static inline function getMirrorName(name:String)
	{
		return 'mirror_cpp_$name';
	}
}
