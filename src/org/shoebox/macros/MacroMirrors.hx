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
class MacroMirrors{

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		private function new() {

		}

	// -------o public

		#if macro

		/**
		*
		*
		* @public
		* @return	void
		*/
		static public function build( ) : Array<Field>{
			
			//Fields
				var aFields : Array<Field> = Context.getBuildFields( );
				var oClass : Null<Ref<ClassType>> = Context.getLocalClass( );

			//OpenFL only
				if(!Context.defined("openfl"))
					return aFields;

			//
				var sClass_name : String = oClass.get( ).name;

			//
				var aMetas : Array<MetadataEntry>;
				var bCPP	: Bool;
				var bJNI	: Bool;
				for( field in aFields.copy( ) ){

					//
						aMetas = [ for( m in field.meta ) if( m.name == "CPP" || m.name == "JNI" || m.name == "IOS" ) m ];

					//
						if( aMetas.length == 0 )
							continue;

					//
						for(m in aMetas)
						{
							if(m.name == "CPP" && Context.defined("cpp"))
							{
								aFields.push( _cpp(
									field ,
									( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : sClass_name,
									( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
								) );
							}
							else if( m.name == "JNI" && Context.defined("android"))
							{
								aFields.push( _jni(
									field ,
									( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : oClass.get( ).module,
									( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
								) );
							}
							else if( m.name == "IOS" && Context.defined("ios"))
							{
								aFields.push( _cpp(
									field ,
									( m.params.length > 0 ) ? _getString( m.params[ 0 ] ) : oClass.get( ).module,
									( m.params.length > 1 ) ? _getString( m.params[ 1 ] ) : field.name
								) );
							}

						}


				}

			return aFields;
		}

	// -------o protected

		/**
		* Making the JNI mirror
		*
		* @private
		* @param 	oField 		: the targetted field 	( Field )
		* @param 	sPackage 	: the package name 		( String )
		* @param 	sPackage 	: the function name 	( String )
		* @return	the new instance field ( Field )
		*/
		static private function _jni( oField : Field , sPackage : String , ?sName : String ) : Field{
			
			sPackage = sPackage.split(".").join("/");
			
			//The function
				var f : Function = _getFunc( oField );
				if(f.ret == null)
					f.ret = TPath({ name : "Void", pack : [], params : [] });
				
				var bStatic = Lambda.has( oField.access , AStatic );

			//Arguments
				var iArgs : Int = f.args.length;
				var aNames : Array<Expr> = [ for( a in f.args ) macro $i{ a.name } ];

			//JNI Arguments translation
				var ct : Null<ComplexType>;
				var tp : Null<Type>;
				var sJNI : String = "(";
				var i = 0;
				for( arg in f.args ){

					//For non static member the first argument is not include in the JNI definition
					if( i++ == 0 && !bStatic )
						continue;

					ct = arg.type;
					tp = ComplexTypeTools.toType( ct );
					sJNI += _translateType( tp );
				}
				sJNI += ")";

			//For non static we convert the first argument type to dynamic
				if( !bStatic ){
					f.args[ 0 ].type = TPath({ name : "Dynamic" , pack : [], params : [], sub : null });
				}

			//Return Type
				if(f.ret==null)
					sJNI += "V";
				else
					sJNI += _translateType( ComplexTypeTools.toType( f.ret ) );

			//Verbose
				#if verbose_mirrors
				trace( '[MIRROR] - JNI $sPackage::$sName $sJNI' );
				#end

			//Variable
				var sVar_name : String = "mirror_jni_"+sName;
				var fVar = _createVariable( sVar_name , f );

			//Return response
				if( f.ret.getParameters( )[0].name != "Void")
					f.ret = TPath({ name : "Dynamic" , pack : [], params : [], sub : null }); //Switching the return type to dynamic

				var eRet = null;
				if( f.ret.getParameters( )[ 0 ].name == "Void" ){
					eRet = macro $i{sVar_name}( $a{aNames} );
				}else{
					eRet = macro{
						var args : Array<Dynamic> = $a{ aNames };
						#if verbose_mirrors
						trace( "call with args ::: "+args);
						#end
						return $i{sVar_name}( $a{aNames} );
					};
				}

			//Result

				f.expr = macro{

					//Already loaded ?
						if( $i{ sVar_name } == null ){
							#if verbose_mirrors
								trace("Lib not loaded, loading it");
								trace( $v{ sPackage }+"::"+$v{ sName }+' :: signature '+$v{ sJNI } );
							#end

							//
								if( $v{ bStatic } )
									$i{ sVar_name } = openfl.utils.JNI.createStaticMethod(
										$v{sPackage},
										$v{sName},
										$v{sJNI}
									);
								else
									$i{ sVar_name } = openfl.utils.JNI.createMemberMethod(
										$v{sPackage},
										$v{sName},
										$v{sJNI}
									);


						}

					//Making the call
						$eRet;
				}


			return fVar;
		}

		/**
		* JNI translation of the type
		*
		* @private
		* @param 	tp : The type to be translated 	( Null<Type> )
		* @return	JNI translation of the Type 	( String )
		*/
		static private function _translateType( tp : Null<Type> ) : String{

			var c : ClassType;
			return switch( tp ){

				case TAbstract( cf , a ):
					_jniAbstract_type( cf.get( ) );

				case TDynamic( t ):
					"Lorg/haxe/lime/HaxeObject;";

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

		/**
		*
		*
		* @private
		* @return	void
		*/
		static private function _jniAbstract_type( cf : AbstractType ) : String{

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

		/**
		* Making the CPP mirror
		*
		* @private
		* @param 	oField 		: the targetted field 	( Field )
		* @param 	sPackage 	: the package name 		( String )
		* @param 	sPackage 	: the function name 	( String )
		* @return	the new instance field ( Field )
		*/
		static private function _cpp( oField : Field , sPackage : String , ?sName : String ) : Field{

			//The function
				var f : Function = _getFunc( oField );

			//Arguments
				var iArgs : Int = f.args.length;
				var aNames : Array<Expr> = [ for( a in f.args ) macro $i{ a.name } ];

			//Verbose
				#if verbose_mirrors
				trace( '[MIRROR] - CPP $sPackage::'+oField.name+'($iArgs)' );
				#end

			//Variable
				var sVar_name : String = "mirror_cpp_"+sName;
				var fVar = _createVariable( sVar_name , f );

			//Return response

				var eRet = macro "";
				if( f.ret.getParameters( )[ 0 ].name == "Void" )
					eRet = macro $i{sVar_name}( $a{aNames} );
				else
					eRet = macro return $i{sVar_name}( $a{aNames} );

			//Result
				f.expr = macro{

					//Already loaded ?
						if( $i{ sVar_name } == null ){
							#if verbose_mirrors
								trace("Lib not loaded, loading it");
								trace( $v{ sPackage }+"::"+$v{ sName }+'($iArgs)' );
							#end

							//
								$i{ sVar_name } = cpp.Lib.load( $v{ sPackage } , $v{ sName } , $v{ iArgs });

						}

					$eRet;
				}


			return fVar;
		}

		/**
		* Create the variable who will contains the instance of mirrored method
		*
		* @private
		* @return	void
		*/
		static private function _createVariable( sName : String , f : Function ) : Field{


			//Variable type
				var aTypes : Array<Null<ComplexType>> = [ for( a in f.args ) a.type ];

			//
				var k : FieldType = FVar(TFunction(aTypes , f.ret));
						/*
				return {
							name : sName ,
							doc : null,
							meta : [],
							access : [APublic,AStatic],
							kind : FVar(TPath({ pack : [], name : "Dynamic", params : [], sub : null }),null),
							pos : Context.currentPos()
						};
			*/
			//
				return {
					name	: sName ,
					doc		: null,
					meta	: [],
					access	: [APrivate,AStatic],
					kind	: k ,
					pos		: haxe.macro.Context.currentPos()
				};
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		static private function _getString(  e : Expr ) : String{

			if( e == null )
				return null;

			return switch( e.expr.getParameters( )[ 0 ] ){

				case CString( s ):
					s;

				default:
					null;

			}

		}

		/**
		* Get the field function
		*
		* @private
		* @return	void
		*/
		static private function _getFunc( f : Field ) : Function{
			return switch( f.kind ){

				case FFun( f ):
					f;

				default:
					Context.error("Only function are supported",f.pos);

			}
		}

		#end

	// -------o misc

}
