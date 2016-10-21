package tools;

#if macro

import haxe.macro.Expr;

class MetadataTools
{
	public static function create(name:String, pos:Position
		, params:Array<Expr>):MetadataEntry
	{
		return {name : name, params : params, pos : pos};
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
