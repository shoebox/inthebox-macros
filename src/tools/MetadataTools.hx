package tools;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.Tools;
using tools.ExprTool;
using tools.FieldTool;
using tools.MetadataTools;

class MetadataTools
{
	public static function create(name:String, pos:Position
		, params:Array<Expr>):MetadataEntry
	{
		return {name : name, params : params, pos : pos};
	}

	public static function getStringParam(entry:MetadataEntry, pos:Int):String
	{
		var result:String = null;
		if (pos >= entry.params.length)
		{
			#if (haxe_ver >= 3.1)
				Context.fatalError("Position error", Context.currentPos());
			#end
		}

		result = entry.params[0].getString();

		return result;
	}

	public static function has(metas:Metadata, metaName:String):Bool
	{
		var result = false;
		for(meta in metas)
		{
			if (meta.name == metaName)
			{
				result = true;
				break;
			}
		}
		return result;
	}

	public static function get(metas:Metadata, metaName:String):MetadataEntry
	{
		var result:MetadataEntry = null;
		for(meta in metas)
		{
			if (meta.name == metaName)
			{
				result = meta;
				break;
			}
		}
		return result;
	}
}

#end
