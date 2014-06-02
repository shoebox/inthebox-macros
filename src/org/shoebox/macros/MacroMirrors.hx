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
	public static inline var CPP_META:String = "CPP";
	public static inline var IOS_META:String = "IOS";
	public static inline var JNI_META:String = "JNI";

	public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields( );
		var localClass:ClassType = Context.getLocalClass( ).get();
		if (!Context.defined("openfl"))
			return fields;

		var result:Field;
		for (field in fields.copy())
		{
			result = parseField(field, localClass);
			if(result != null)
			{
				fields.push(result);
				result = null;
			}
		}

		return fields;
	}

	static function parseField(field:Field, localClass:ClassType):Field
	{
		var result:Field;
		var meta:MetadataEntry;
		var metaLength:Int;

		if(MetaDataTools.has(field, CPP_META) && Context.defined("cpp"))
		{
			meta = MetaDataTools.get(field, CPP_META);
			metaLength = meta.params.length;
			checkMetaArgsCount(meta, 2, 2);

			result = cpp(field,
				(metaLength > 0) ? getString(meta.params[ 0 ]) : localClass.name,
				(metaLength > 1) ? getString(meta.params[ 1 ]) : field.name
			);	
		}
		else if(MetaDataTools.has(field, JNI_META) && Context.defined("android"))
		{
			meta = MetaDataTools.get(field, JNI_META);
			metaLength = meta.params.length;
			checkMetaArgsCount(meta, 0, 2);

			result = jni(field,
				(metaLength > 0) ? getString(meta.params[ 0 ]) : localClass.module,
				(metaLength > 1) ? getString(meta.params[ 1 ]) : field.name
			);	
		}
		else if(MetaDataTools.has(field, IOS_META) && Context.defined("ios"))
		{
			meta = MetaDataTools.get(field, IOS_META);
			metaLength = meta.params.length;
			checkMetaArgsCount(meta, 2, 2);

			result = cpp(field,
				(metaLength > 0) ? getString(meta.params[ 0 ]) : localClass.module,
				(metaLength > 1) ? getString(meta.params[ 1 ]) : field.name
			);	
		}

		return result;
	}

	static function checkMetaArgsCount(meta:MetadataEntry, min:Int, max:Int):Void
	{
		var metaName = meta.name;
		var count = meta.params.length;
		if (count > max || count < min)
			Context.error('Invalid arguments count for the meta $metaName', 
				meta.pos);
	}

	static function jni(field:Field, packageName:String, 
		?variableName:String ):Field
	{
		packageName = packageName.split(".").join("/");
		
		var result:Function = FieldTool.getFunction(field);
		if (result.ret == null)
			result.ret = TPath({name:"Void", pack:[], params:[] });
		
		var argumentNames:Array<Expr> = getArgsNames(result);
		var signature = JniTools.getSignature(field);

		if (!isStaticField(field))
			result.args[ 0 ].type = TPath({name:"Dynamic", pack:[], 
				params:[], sub:null});

		#if verbose_mirrors
		Sys.println('[JNI] $packageName::$variableName $signature');
		#end

		var mirrorName:String = "mirror_jni_"+variableName;
		var resultVariable = createVariable(mirrorName, result, field.pos);
		var returnType:String = result.ret.getParameters( )[0].name;
		var returnExpr = null;
		var isStaticMethod = isStaticField(field);

		if(returnType != "Void")
		{
			//Switching the return type to dynamic
			result.ret = TPath({name:"Dynamic", pack:[], params:[], sub:null}); 

			returnExpr = macro
			{
				var args : Array<Dynamic> = $a{ argumentNames };
				#if verbose_mirrors
				trace( "call with args ::: "+args);
				#end
				return $i{mirrorName}( $a{argumentNames} );
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
				trace($v{packageName} + " :: " + $v{mirrorName} + ' :: signature '+$v{signature});
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

	static function cpp(field:Field, packageName:String, ?name:String ) : Field
	{

		var func:Function = getFunc(field);

		var argsCount:Int = func.args.length;
		var argumentNames:Array<Expr> = getArgsNames(func);
		
		#if verbose_mirrors
		Sys.println('[CPP] $packageName::'+field.name+'($argsCount)');
		#end

		var mirrorName : String = "mirror_cpp_"+name;
		var fieldVariable = createVariable(mirrorName, func, field.pos);
		var returnExpr = macro "";

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

	static function createVariable(variableName:String, refFunction:Function, positon:Position):Field
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

		if ( e == null )
			return null;

		return switch( e.expr.getParameters( )[ 0 ] )
		{

			case CString( s ):
				s;

			default:
				null;

		}
	}

	static function getFunc(f:Field):Function
	{
		return switch(f.kind)
		{

			case FFun(f):
				f;

			default:
				Context.error("Only function are supported",f.pos);
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
		return switch(argType)
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
		return switch(type)
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
		switch(type.getParameters()[0].get().name)
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
		result = switch(a.name)
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
		switch(field.kind)
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

	public static function has(field:Field, metaName:String):Bool
	{
		var result = false;

		for(meta in field.meta)
		{
			if (meta.name == metaName)
			{
				result = true;
				break;
			}
		}

		return result;
	}

	public static function get(field:Field, metaName:String):MetadataEntry
	{
		var result:MetadataEntry = null;
		for(meta in field.meta)
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
