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

	public static function build():Array<Field>
	{
		
		var fields:Array<Field> = Context.getBuildFields( );
		var localClass:Null<Ref<ClassType>> = Context.getLocalClass( );

		if(!Context.defined("openfl"))
			return fields;

		var metadatas : Array<MetadataEntry>;

		for(field in fields.copy())
		{

			metadatas = [for( m in field.meta ) 
				if( m.name == "CPP" || m.name == "JNI" || m.name == "IOS" ) m ];

			if( metadatas.length == 0 )
				continue;

			for(m in metadatas)
			{
				if (m.name == "CPP" && Context.defined("cpp"))
				{
					fields.push( cpp(field,
						( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : localClass.get( ).name,
						( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
					) );
				}
				else if (m.name == "JNI" && Context.defined("android"))
				{
					fields.push(jni(field,
						( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : localClass.get( ).module,
						( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
					) );
				}
				else if (m.name == "IOS" && Context.defined("ios"))
				{
					fields.push( cpp(field,
						( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : localClass.get( ).module,
						( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
					) );
				}
			}
		}

		return fields;
	}

	static function jni(oField:Field, packageName:String, 
		?variableName:String ):Field
	{
		packageName = packageName.split(".").join("/");
		
		//The function
			var f : Function = FieldTool.getFunction(oField);
			if(f.ret == null)
				f.ret = TPath({ name : "Void", pack : [], params : [] });
			
			var isStaticMethod = Lambda.has( oField.access , AStatic );

		//Arguments
			var argsCount : Int = f.args.length;
			var argumentNames : Array<Expr> = [ for( a in f.args ) macro $i{ a.name } ];

		//JNI Arguments translation
			var ct : Null<ComplexType>;
			var tp : Null<Type>;
			var sgnature : String = "(";
			var i = 0;
			for( arg in f.args ){

				//For non static member the first argument is not include in the JNI definition
				if( i++ == 0 && !isStaticMethod )
					continue;

				sgnature += JniTools.translateType(arg.type.toType(), oField.pos);
			}
			sgnature += ")";

		//For non static we convert the first argument type to dynamic
			if( !isStaticMethod ){
				f.args[ 0 ].type = TPath({ name : "Dynamic" , pack : [], params : [], sub : null });
			}

		//Return Type
			if(f.ret==null)
				sgnature += "V";
			else
				sgnature += _translateType( ComplexTypeTools.toType( f.ret ) );

		//Verbose
			
			Sys.println('[MIRROR] - JNI $packageName::$variableName $sgnature');
			#if verbose_mirrors
			#end

		//Variable
			var sVar_name : String = "mirror_jni_"+variableName;
			var fVar = _createVariable( sVar_name , f );

		//Return response
			if( f.ret.getParameters( )[0].name != "Void")
				f.ret = TPath({ name : "Dynamic" , pack : [], params : [], sub : null }); //Switching the return type to dynamic

			var eRet = null;
			if( f.ret.getParameters( )[ 0 ].name == "Void" ){
				eRet = macro $i{sVar_name}( $a{argumentNames} );
			}else{
				eRet = macro{
					var args : Array<Dynamic> = $a{ argumentNames };
					#if verbose_mirrors
					trace( "call with args ::: "+args);
					#end
					return $i{sVar_name}( $a{argumentNames} );
				};
			}

		//Result

			f.expr = macro{

				//Already loaded ?
					if( $i{ sVar_name } == null ){
						#if verbose_mirrors
							trace("Lib not loaded, loading it");
							trace( $v{ packageName }+"::"+$v{ variableName }+' :: signature '+$v{ sgnature } );
						#end

						//
							if( $v{ isStaticMethod } )
								$i{ sVar_name } = openfl.utils.JNI.createStaticMethod(
									$v{packageName},
									$v{variableName},
									$v{sgnature}
								);
							else
								$i{ sVar_name } = openfl.utils.JNI.createMemberMethod(
									$v{packageName},
									$v{variableName},
									$v{sgnature}
								);


					}

				//Making the call
					$eRet;
			}


		return fVar;
	}

	static function _translateType( tp : Null<Type> ) : String{

		var c : ClassType;
		return switch( tp ){

			case TAbstract( cf , a ):
				_jniAbstract_type( cf.get( ) );

			case TDynamic( t ):
				"Lorg/haxe/nme/HaxeObject;";

			default:
				c = tp.getParameters( )[ 0 ].get( );
				switch( c.name ){

					case "String":
						"Ljava/lang/String;";

					case "Array":
						"["+_translateType( tp.getParameters( )[ 1 ][0] );

					default:
						"L"+c.pack.join("/")+( c.pack.length == 0 ? "" : "/" ) + c.name+";";

				}
		}
	}

	static function _jniAbstract_type( cf : AbstractType ) : String{

		return switch( cf.name ){

			case "Float":
				"F";

			case "Bool":
				"Z";

			case "Int":
				"I";

			case "Void":
				"V";

			default:
				Context.error("Unknow abstract type ::: "+cf.name , Context.currentPos( ) );

		}

		return null;
		//return cf.get( ).name;
	}

	static function cpp( oField : Field , packageName : String , ?sName : String ) : Field{

		//The function
			var f : Function = _getFunc( oField );

		//Arguments
			var argsCount : Int = f.args.length;
			var argumentNames : Array<Expr> = [ for( a in f.args ) macro $i{ a.name } ];
		
		//Verbose
			trace( '[MIRROR] - CPP $packageName::'+oField.name+'($argsCount)' );
			#if verbose_mirrors
			#end

		//Variable
			var sVar_name : String = "mirror_cpp_"+sName;
			var fVar = _createVariable( sVar_name , f );

		//Return response

			var eRet = macro "";
			if( f.ret.getParameters( )[ 0 ].name == "Void" )
				eRet = macro $i{sVar_name}( $a{argumentNames} );
			else
				eRet = macro return $i{sVar_name}( $a{argumentNames} );

		//Result
			f.expr = macro{

				//Alread#if verbose_mirrorsy loaded ?
					if( $i{ sVar_name } == null ){
							trace("Lib not loaded, loading it");
							trace( $v{ packageName }+"::"+$v{ sName }+'($argsCount)' );
						#end

						//
							$i{ sVar_name } = cpp.Lib.load( $v{ packageName } , $v{ sName } , $v{ argsCount });

					}

				$eRet;
			}


		return fVar;
	}

	static function _createVariable( sName : String , f : Function ) : Field{

		var aTypes : Array<Null<ComplexType>> = [ for( a in f.args ) a.type ];
		var k : FieldType = FVar(TFunction(aTypes , f.ret));
			
		return {
			name	: sName ,
			doc		: null,
			meta	: [],
			access	: [APublic,AStatic],
			kind	: k ,
			pos		: haxe.macro.Context.currentPos()
		};
	}

	static function _getString(  e : Expr ) : String{

		if( e == null )
			return null;

		return switch( e.expr.getParameters( )[ 0 ] ){

			case CString( s ):
				s;

			default:
				null;

		}

	}

	static function _getFunc( f : Field ) : Function{
		return switch( f.kind ){

			case FFun( f ):
				f;

			default:
				Context.error("Only function are supported",f.pos);

		}
	}

}

class JniTools
{
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
				Context.error("Only function are supported",field.pos);
		}

		return result;
	}

}
