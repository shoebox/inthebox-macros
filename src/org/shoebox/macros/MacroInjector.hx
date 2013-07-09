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

class MacroInjector{

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		public function new() {

		}

	// -------o public

		#if macro

		/**
		*
		*
		* @public
		* @return	void
		*/
		static public function inject( ) : Array<Field> {
			var aFields : Array<Field> = Context.getBuildFields( );

			var aCopy = aFields.copy( );

			var bWrite	: Bool;
			var eName	: Expr;
			var sGet	: String;
			var sName	: String;
			var sSet	: String;
			for( field in aFields ){

				//Reset
					bWrite	= false;
					eName	= null;
					sName	= null;

				//Meta
					var aMetas : Array<MetadataEntry> = [ for( m in field.meta ) if( m.name == "inject") m ];

				//No meta data
					if( aMetas.length == 0 )
						continue;

				//Parsing des metas
					for( meta in aMetas ){
						switch( meta.name ){

							case "inject":
								for( p in meta.params ){

									switch( p.expr.getParameters( )[ 0 ]){

										case CString( s ):
											sName = s;

										case CIdent( b ):
											bWrite = b == "true";

										default:

									}

								}

						}
					}


				//
					trace(" [INJECT] - "+(bWrite?"RW":"R-")+" | Optional name : "+sName);

				//New Methods name
					sGet = "get_"+field.name;
					sSet = bWrite ? "set_"+field.name : "never";

				//Reponse
					var ct : ComplexType = field.kind.getParameters( )[ 0 ];
					var oKind : Null<Type> = ComplexTypeTools.toType( ct ).getParameters( )[0];
					var sKind : String = Std.string( oKind )+"";

				//Getter
					aCopy.push( _createField( true , sName , field.pos , sGet , ct.toString( )+"" , ct , false ) );

				//Setter
					if( bWrite )
						aCopy.push( _createField( false , sName , field.pos , sSet , ct.toString( )+"" , ct , false ) );

				//the new getter/setter
					var type : FieldType = FProp( sGet , sSet , ct );
					var getterSetter : Field =
					{
						name	: field.name ,
						doc		: null,
						meta	: [],
						access	: [APublic],
						kind	: type,
						pos		: field.pos
					};

				//On supprime la source
					aCopy.remove( field );
					aCopy.push( getterSetter );

			}

			return aCopy;
		}

	// -------o protected

		/**
		*
		*
		* @private
		* @return	void
		*/
		static private function _createField(
												bGetter			: Bool,
												sOptional_name	: String,
												pos				: Position ,
												sName			: String ,
												sKind			: String,
												ct				: ComplexType ,
												bGet			: Bool = true ,
												bStatic			: Bool = false
											) : Field{

			//trace("_createField ::: "+bGetter+" - "+sName);
			var e = Context.makeExpr( sKind , pos );
			var func : Function = { args : [ ] , expr : null , params : [] , ret : ct };

			if( bGetter ){
				//trace( "getter :: "+$i{ sKind }+" - "+sOptional_name );
				func.expr = macro {
					return org.shoebox.patterns.injector.Injector.getInstance( ).get(
						cast( $i{ sKind } , Class<Dynamic> ),
						$v{ sOptional_name }
					);
				};

			}else{
				func.args.push( { name : "arg", type : ct , opt : false, value : null } );
				func.expr = macro {
					//trace( $i{ "arg" } );
					return org.shoebox.patterns.injector.Injector.getInstance( ).set(
						$i{ "arg" },
						cast( $i{ sKind } , Class<Dynamic> ),
						$v{ sOptional_name }
					);

				};
			}
			var fRes : Field = {
									name	: sName ,
									doc		: null,
									meta	: [],
									access	: [APublic],
									kind	: FFun( func ),
									pos		: pos
								};
			if( bStatic )
				fRes.access.push( AStatic );

			return fRes;
		}

		#end

	// -------o misc

}