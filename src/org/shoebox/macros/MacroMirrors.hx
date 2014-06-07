/*
Copyright (c) 2013, shoe[box]
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package org.shoebox.macros;

#if macro
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.macro.*;

using haxe.macro.Tools;
#end

/**
 * ...
 * @author shoe[box]
 */
class MacroMirrors
{
	#if macro

	public static inline var CPP_META:String = "CPP";
	public static inline var IOS_META:String = "IOS";
	public static inline var JNI_META:String = "JNI";

	public static inline var TAG_CPP_DEFAULT_LIB:String = "CPP_DEFAULT_LIBRARY";
	public static inline var TAG_CPP_PRIM_PREFIX:String = "CPP_PRIMITIVE_PREFIX";

	static var VOID = TPath({name:"Void", pack:[], params:[] });
	static var DYNAMIC = TPath({name:"Dynamic", pack:[], params:[], sub:null});

	public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields( );
		
		if (!Context.defined("openfl"))
			return fields;

		var localClass:ClassType = Context.getLocalClass( ).get();
		var config = parseConfig(localClass);

		var result:Field;
		for (field in fields.copy())
		{
			result = parseField(field, localClass, config);
			if (result != null)
			{
				fields.push(result);
				result = null;
			}
		}

		return fields;
	}

	static function parseConfig(localClass:ClassType):ContextConfig
	{
		var config:ContextConfig = {};
		var metas:Metadata = localClass.meta.get();
		if (MetaDataTools.has(metas, TAG_CPP_DEFAULT_LIB))
			config.cppDefaultLibrary = getString(MetaDataTools.get(metas, 
				TAG_CPP_DEFAULT_LIB).params[0]);

		if (MetaDataTools.has(metas, TAG_CPP_PRIM_PREFIX))
			config.cppPrimitivePrefix = getString(MetaDataTools.get(metas, 
				TAG_CPP_PRIM_PREFIX).params[0]);

		return config;
	}

	static function getLibraryName(field:Field, meta:MetadataEntry, metaLength:Int, 
		config:ContextConfig):String
	{
		var result:String;

		if (metaLength == 0 && config.cppDefaultLibrary == null)
			Context.error('The primitive name is not defined for field' +  
				'${field.name} and no CPP_DEFAULT_LIBRARY setup', field.pos);

		if (config.cppDefaultLibrary != null && metaLength == 0)
			result = config.cppDefaultLibrary;
		else
			result = getString(meta.params[0]);

		return result;
	}

	static function getPrimitiveName(field:Field, meta:MetadataEntry, metaLength:Int, 
		config:ContextConfig):String
	{
		if (metaLength == 2)
			return getString(meta.params[1]);

		return (config.cppPrimitivePrefix != null ? 
			config.cppPrimitivePrefix + "_"  : "")  + field.name;
	}

	static function parseField(field:Field, localClass:ClassType, 
		config:ContextConfig):Field
	{
		var result:Field;
		var meta:MetadataEntry;
		var metaLength:Int;
		var libraryName:String;
		var primiveName:String;

		if (MetaDataTools.has(field.meta, CPP_META) && Context.defined("cpp"))
		{
			meta = MetaDataTools.get(field.meta, CPP_META);
			metaLength = meta.params.length;

			libraryName = getLibraryName(field, meta, metaLength, config);
			primiveName = getPrimitiveName(field, meta, metaLength, config);
			
			result = cpp(field, libraryName, primiveName, "CPP");	
		}
		else if (MetaDataTools.has(field.meta, JNI_META) && Context.defined("android"))
		{
			meta = MetaDataTools.get(field.meta, JNI_META);
			metaLength = meta.params.length;
			
			result = jni(field,
				(metaLength > 0) ? getString(meta.params[0]) : localClass.module,
				(metaLength > 1) ? getString(meta.params[1]) : field.name
			);	
		}
		else if (MetaDataTools.has(field.meta, IOS_META) && Context.defined("ios"))
		{
			meta = MetaDataTools.get(field.meta, IOS_META);
			metaLength = meta.params.length;

			libraryName = getLibraryName(field, meta, metaLength, config);
			primiveName = getPrimitiveName(field, meta, metaLength, config);
			result = cpp(field, libraryName, primiveName, "IOS");	
		}

		return result;
	}

	static function jni(field:Field, packageName:String, 
		?variableName:String ):Field
	{
		packageName = packageName.split(".").join("/");
		
		var result:Function = FieldTool.getFunction(field);
		if (result.ret == null)
			result.ret = VOID;
		
		var argumentNames:Array<Expr> = getArgsNames(result);
		var signature = JniTools.getSignature(field);

		if (!isStaticField(field))
			result.args[0].type = DYNAMIC;

		#if verbose_mirrors
		Sys.println('[JNI] $packageName \t $variableName $signature');
		#end

		var mirrorName:String = getMirrorName(variableName, "jni");
		var resultVariable = createVariable(mirrorName, result, field.pos);
		var returnType:String = result.ret.getParameters( )[0].name;
		var returnExpr = null;
		var isStaticMethod = isStaticField(field);

		if (returnType != "Void")
		{
			//Switching the return type to dynamic
			result.ret = DYNAMIC; 

			returnExpr = macro
			{
				#if verbose_mirrors
				var args:Array<Dynamic> = $a{argumentNames};
				trace( "call with args ::: " + args);
				#end
				return $i{mirrorName}($a{argumentNames});
			};
		}
		else
			returnExpr = macro $i{mirrorName}($a{argumentNames});

		result.expr = macro
		{
			if ($i{mirrorName} == null)
			{
				#if verbose_mirrors
				trace("Lib not loaded, loading it");
				trace($v{packageName} + " :: " + $v{mirrorName} 
					+ ' :: signature '+$v{signature});
				#end

				if ($v{isStaticMethod})
					$i{mirrorName} = openfl.utils.JNI.createStaticMethod(
						$v{packageName}, $v{variableName}, $v{signature});
				else
					$i{mirrorName} = openfl.utils.JNI.createMemberMethod(
						$v{packageName}, $v{variableName}, $v{signature});
			}
			
			$returnExpr;
		}

		return resultVariable;
	}

	static function getMirrorName(name:String, target:String = "cpp"):String
	{
		return 'mirror_' + target + '_' + name;
	}

	static function cpp(field:Field, packageName:String, ?name:String, 
		?type:String ) : Field
	{
		var func:Function = FieldTool.getFunction(field);

		var argsCount:Int = func.args.length;
		var argumentNames:Array<Expr> = getArgsNames(func);
		
		var mirrorName:String = getMirrorName(name, "cpp");
		var fieldVariable = createVariable(mirrorName, func, field.pos);
		var returnExpr = macro "";

		#if verbose_mirrors
		Sys.println('[$type] $packageName \t $name ($argsCount)');
		#end

		if (func.ret.getParameters( )[ 0 ].name == "Void")
			returnExpr = macro $i{mirrorName}($a{argumentNames});
		else
			returnExpr = macro return $i{mirrorName}($a{argumentNames});

		func.expr = macro
		{
			if ($i{mirrorName} == null)
			{
				#if verbose_mirrors
				trace("Lib not loaded, loading it");
				trace($v{packageName}+"::"+$v{name}+'($argsCount)');
				#end

				$i{mirrorName} = cpp.Lib.load($v{packageName}, $v{name}, 
					$v{argsCount});
			}
			$returnExpr;
		}

		return fieldVariable;
	}

	static function createVariable(variableName:String, refFunction:Function, 
		positon:Position):Field
	{
		var types = [for (arg in refFunction.args) arg.type];
		var fieldType : FieldType = FVar(TFunction(types, refFunction.ret));
			
		return
		{
			name	: variableName,
			doc		: null,
			meta	: [],
			access	: [APublic,AStatic],
			kind	: fieldType,
			pos		: positon
		};
	}

	static function getString(e:Expr):String
	{
		if (e == null)
			return null;

		return switch ( e.expr.getParameters( )[ 0 ] )
		{
			case CString(s):
				s;

			default:
				null;
		}
	}

	static inline function getArgsNames(func:Function):Array<Expr>
	{
		var result:Array<Expr> = [for (a in func.args) macro $i{ a.name }];
		return result;
	}

	static inline function isStaticField(field:Field):Bool
	{
		var result = Lambda.has(field.access, AStatic);
		return result;
	}
}

class JniTools
{
	public static function getSignature(field:Field):String
	{
		var func:Function = FieldTool.getFunction(field);
		var signature = "(";
		for(arg in func.args)
			signature += translateArg(arg, field.pos);
		
		var returnType:Null<Type> = func.ret.toType();

		signature += ")" + translateType(returnType, field.pos);

		return signature;
	}

	public static function translateArg(arg:FunctionArg, pos:Position):String
	{
		var argType:Null<Type> = arg.type.toType();
		return translateType(argType, pos);
	}

	public static function translateType(argType:Null<Type>, pos:Position):String
	{
		return switch (argType)
		{
			case TAbstract(cf, a ):
				translateAbstractType(cf.get(), pos);

			case TDynamic(t):
				if (Context.defined("openfl"))
					"Lorg/haxe/lime/HaxeObject;";
				else
					"Lorg/haxe/nme/HaxeObject;";

			default:
				translateArgType(argType, pos);
		}	
	}

	public static function translateArgType(type:Null<Type>, pos:Position):String
	{
		return switch (type)
		{
			case TInst(t, params):
				translateSubArgType(type, params, pos);

			default:
				Context.fatalError(
					"Unsupported Type ::: " + type.getParameters()[0], pos);
		}
	}

	public static function translateSubArgType(type:Null<Type>, params:Array<Type>, 
		pos:Position):String
	{
		var result:String;
		switch (type.getParameters()[0].get().name)
		{
			case "String":
				result = "Ljava/lang/String;";

			case "Array":
				result = "[" + translateType(params[0], pos);

			default:
				var classType:ClassType = type.getParameters()[0].get();
				result = "L"+classType.pack.join("/") 
					+ (classType.pack.length == 0 ? "" : "/" ) 
					+ classType.name+";";
		}

		return result;
	}

	public static function translateAbstractType(a:AbstractType, pos:Position):String
	{
		var result:String = null;
		result = switch (a.name)
		{
			case "Float":
				"F";

			case "Bool":
				"Z";

			case "Int":
				"I";

			case "Void":
				"V";

			default:
				Context.fatalError("Unsupported abstract type ::: "+a.name, pos);
		}

		return result;
	}
}

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
}

class MetaDataTools
{

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

	#end
}

typedef ContextConfig=
{
	@:optional var cppPrimitivePrefix:String;
	@:optional var cppDefaultLibrary:String;
}
