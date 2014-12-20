package mirror;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using mirror.CppFieldTool;
using mirror.JniFieldTool;
using tools.ExprTool;
using tools.FieldTool;
using tools.MetadataTools;

class Mirror
{
	static inline var CppMeta = "CPP";
	static inline var TagCppDefaultLib = "CPP_DEFAULT_LIBRARY";
	static inline var TagCppPrimitivePrefix = "CPP_PRIMITIVE_PREFIX";

	function new(){}

	public static function build():Array<Field>
	{
		var fields = Context.getBuildFields();

		var isCpp = #if munit true #else Context.defined("cpp") #end;
		var isAndroid = #if munit true #else Context.defined("android") #end;
		var isOpenFl = Context.defined("openfl") || Context.defined("nme");
		if (#if munit true #else isOpenFl #end)
		{
			var localClass = Context.getLocalClass().get();
			var result:Field;
			for (field in fields.copy())
			{
				if (isCpp && field.isCpp())
				{
					result = Cpp.build(field, localClass);
				}
				else if (isAndroid && field.isJni())
				{
					result = Jni.build(field, localClass);
				}
				
				if (result != null)
				{
					fields.push(result);
				}
			}
		}

		return fields;
	}
}
