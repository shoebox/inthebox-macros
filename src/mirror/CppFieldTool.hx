package mirror;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using tools.ExprTool;
using tools.FieldTool;
using tools.MetadataTools;

class CppFieldTool
{
	public static inline var TagCpp = "CPP";
	public static inline var TagDefaultLibrary = "CPP_DEFAULT_LIBRARY";
	public static inline var TagPrimitivePrefix = "CPP_PRIMITIVE_PREFIX";

	public static function isCpp(field:Field):Bool
	{
		return field.meta.has(TagCpp);
	}

	public static function getPrimitiveName(field:Field, 
		localClass:ClassType):String
	{
		var entry:MetadataEntry = field.meta.get(TagCpp);
		var result:String;
		if (entry.params.length > 1)
		{
			result = entry.params[1].getString();
		}
		else
		{
			var prefix = "";
			var func = field.getFunction();
			var context = Context.getLocalClass();
			var metas = localClass.meta.get();
			if ( metas.has(TagPrimitivePrefix))
			{
				entry = metas.get(TagPrimitivePrefix);
				if (entry.params.length == 0)
				{
					Context.error("Cpp primitive tag is defined without value", 
						field.pos);
				}

				prefix = entry.params[0].getString() + '_';
			}

			result = prefix + field.name;
		}

		return result;
	}

	public static function getLibraryName(field:Field, 
		localClass:ClassType):String
	{
		var entry:MetadataEntry = field.meta.get(TagCpp);
		var meta = localClass.meta.get();
		if (entry.params.length == 0 && !meta.has(TagDefaultLibrary))
		{
			Context.error("Not default library defined globary or locally", 
				field.pos);
		}

		var expr = entry.params.length > 0 ? entry.params[0] 
			: meta.get(TagDefaultLibrary).params[0];
		var result:String = expr.getString();
		
		return result;
	}
}
