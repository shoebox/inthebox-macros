package mirror;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Tools;
using mirror.CppFieldTool;
using mirror.JniFieldTool;
using tools.ExprTool;
using tools.FieldTool;
using tools.MetadataTools;

class Mirror
{
	static inline var MirrorDisabledMeta = "DISABLED";
	static inline var CppMeta = "CPP";
	static inline var TagCppDefaultLib = "CPP_DEFAULT_LIBRARY";
	static inline var TagCppPrimitivePrefix = "CPP_PRIMITIVE_PREFIX";

	static var VOID:ComplexType = TPath({name:"Void", pack:[], params:[], sub:null});
	
	function new(){}

	public static function build():Array<Field>
	{
		var fields = Context.getBuildFields();

		var isCpp = #if munit true #else Context.defined("cpp") #end;
		var isIos = #if munit true #else Context.defined("ios") #end;
		var isAndroid = #if munit true #else Context.defined("android") #end;
		var isOpenFl = Context.defined("openfl") || Context.defined("nme");
		var isEnabled = #if (openfl || munit) true #else false #end;
			
		var fieldDisabled:Bool;
		var func:Function;
		if (isEnabled)
		{
			var localClass = Context.getLocalClass().get();
			var result:Field;
			for (field in fields.copy())
			{	
				switch (field.kind)
				{
					case FFun(f):
					default : continue;
				}

				func = field.getFunction();
				if (func.ret == null)
					func.ret = VOID;

				fieldDisabled = field.meta.has(MirrorDisabledMeta);
				if (!fieldDisabled)
				{
					if ((isCpp && field.isCpp()) || (isIos && field.isIos()))
					{
						result = Cpp.build(field, localClass);
					}
					else if (isAndroid && field.isJni())
					{
						result = Jni.build(field, localClass);
					}
				}
				
				if (result != null)
				{
					fields.push(result);
					result = null;
				}
				
				if (func.expr == null)
				{
					func.expr = switch (func.ret.toString())
					{
						case "Bool" : macro return false;
						case "Float" : macro return -1.0;
						case "Void" : macro 
						{
							//Nothing
						};
						case "Int" : macro return 0;
						default : macro return null;
					}
				}
			}
		}

		return fields;
	}
}
