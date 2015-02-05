 package mirror;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.Tools;
using tools.ExprTool;
using tools.FieldTool;
using tools.MetadataTools;

 class JniFieldTool
 {
 	public static inline var TagJni = 'JNI';
 	public static inline var TagDefaultClassName = 'JNI_DEFAULT_CLASS_NAME';
 	public static inline var TagDefaultLibrary = 'JNI_DEFAULT_PACKAGE';

 	public static function isJni(field:Field):Bool
 	{
 		return field.meta.has(TagJni);
 	}

 	public static function getPackageName(field:Field):String
 	{
 		var result:String;
 		var metas = Context.getLocalClass().get().meta.get();
 		var entry:MetadataEntry = field.meta.get(TagJni);
 		var hasFileName:Bool;
 		if (metas.has(TagDefaultLibrary))
 		{
 			if (metas.get(TagDefaultLibrary).params.length == 0)
 			{
 				#if (haxe_ver >= 3.1)
				Context.fatalError("Default package is defined " 
					+ "(JNI_DEFAULT_PACKAGE) without argument", field.pos);
				#end
 			}

 			result = entry.params.length > 0 ? entry.params[0].getString() 
 				: metas.get(TagDefaultLibrary).params[0].getString();
 		}
 		else
 		{
			var params = entry.params;
			if (params.length > 1)
			{
				result = params[0].getString();
			}
			else
			{
				if (metas.has(TagDefaultClassName) 
					&& metas.get(TagDefaultClassName).params.length > 0)
				{
					hasFileName = false;
				}
				else
				{
					result = Context.getLocalModule();
					hasFileName = true;
				}
			}
 		}

 		var splitted = result.split('.');
 		if (!hasFileName)
 		{
 			if (metas.has(TagDefaultClassName))
 			{
 				if (metas.get(TagDefaultClassName).params.length == 0)
	 			{
	 				#if (haxe_ver >= 3.1)
					Context.fatalError("Default package is defined " 
						+ '($TagDefaultClassName) without argument', field.pos);
					#end
	 			}	
	 			else
	 			{
	 				splitted.push(metas.get(TagDefaultClassName).params[0].getString());
	 			}
 			}
 			else
 			{
 				splitted.push(Context.getLocalClass().get().name);
 			}
 		}

 		result = splitted.join("/");
 		
 		return result;
 	}

 	public static function getPrimitiveName(field:Field):String
 	{
 		var entry:MetadataEntry = field.meta.get(TagJni);
 		var params = entry.params;
 		var length = params.length;

 		var result:String = null;
 		if (field.name == "new")
 		{
 			result = "<init>";
 		}
 		else
 		{
 			result = switch (length)
	 		{
	 			case 0 : field.name;
	 			case 1 : entry.params[0].getString();
	 			case 2 : entry.params[1].getString();
	 			case _ : 
	 				#if (haxe_ver >= 3.1)
					Context.fatalError("Invalid number of arguments for the JNI tag", field.pos);
					#end
	 		}
 		}

 		return result;
 	}

 	public static function getSignature(field:Field):String
 	{
 		var reference = FieldTool.getFunction(field);
 		var result = '(';
 		var args = reference.args.copy();
 		if (!field.isStaticField())
 			args.shift();

 		for (arg in args)
 		{
 			result += translateArg(arg, field.pos);
 		}

 		var returnType:Null<Type> = reference.ret.toType();
 		result += ")" + translateType(returnType, field.pos);
 		return result;
 	}

 	public static function translateArg(arg:FunctionArg, pos:Position):String
	{
		var argType = arg.type.toType();
		return translateType(argType, pos);
	}

	public static function translateType(argType:Null<Type>, pos:Position):String
	{
		return switch (argType)
		{
			case TType(t, p) : translateType(t.get().type , pos);
			case TAbstract(cf, a ) : translateAbstractType(cf.get(), pos);
			case TDynamic(t) :
				if (Context.defined("openfl"))
					"Lorg/haxe/lime/HaxeObject;";
				else
					"Lorg/haxe/nme/HaxeObject;";

			default : translateArgType(argType, pos);
		}	
	}

	public static function translateAbstractType(type:AbstractType, pos:Position):String
	{
		function error()
		{
			Context.fatalError("Unsupported abstract type ::: " + type.name, pos);
			return "ERROR";
		}

		var result:String;
		switch (type.name)
		{
			case "Bool" : result = "Z";
			case "Double" : result = "D";
			case "Float" : result = "F";
			case "Int" : result = "I";
			case "Long" : result = "J";
			case "Void" : result = "V";
			default:
				#if (haxe_ver >= 3.1)
				var complexType = type.type;
				switch (complexType)
				{
					case TAbstract(t, _): 
						var concreteT = t.get();
						result = translateAbstractType(concreteT, pos);

					default:
						error();
				}
				#end
		}

		#if (haxe_ver >= 3.1)
		if (result == null)
			error();
		#end

		return result;
	}

	public static function translateArgType(type:Null<Type>, pos:Position):String
	{
		return switch (type)
		{
			case TInst(t, params):
				translateSubArgType(type, params, pos);

			default:
				#if (haxe_ver >= 3.1)
				Context.fatalError("Unsupported Type ::: " + type.getParameters()[0], pos);
				#end
		}
	}

	public static function translateSubArgType(type:Null<Type>, params:Array<Type>, 
		pos:Position):String
	{
		var result:String;
		switch (type.getParameters()[0].get().name)
		{
			case "Array": result = "[" + translateType(params[0], pos);
			case "Double" : result = "D";
			case "JavaMap" : result = "Ljava/util/Map;";
			case "Long" : result = "J";
			case "String" : result = "Ljava/lang/String;";
			default:
				var classType:ClassType = type.getParameters()[0].get();
				var parts:Array<String>;
				var metas = Context.getLocalClass().get().meta.get();
				if (Context.getLocalClass().get().module == classType.module 
					&& metas.has(TagDefaultLibrary))
				{
					var entry:MetadataEntry = metas.get(TagDefaultLibrary);
					var className = Context.getLocalClass().get().name;
					if (metas.has(TagDefaultClassName))
					{
						var entry = metas.get(TagDefaultClassName);
						className = entry.getStringParam(0);
					}
					var raw = entry.params[0].getString();
 					parts = raw.split('.');
 					result = "L" + parts.join('/') + '/' + className + ';';
				}
				else
				{
					var pack:Array<String> = null;
					if (classType.meta.has(TagDefaultLibrary))
					{
						var entry = classType.meta.get().get(TagDefaultLibrary);
						pack = entry.getStringParam(0).split(".");
					}
					else
					{
						pack = classType.pack;
					}

					var className = classType.name;
					if (classType.meta.has(TagDefaultClassName))
					{
						var entry = classType.meta.get().get(TagDefaultClassName);
						className = entry.getStringParam(0);
					}

					result = "L" + pack.join("/") 
						+ (pack.length == 0 ? "" : "/" ) 
						+ className + ";";
				}
		}

		return result;
	}
 }
