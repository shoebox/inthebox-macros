package org.shoebox.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author shoe[box]
 */

class MacroErrReport{

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
		static public function report( ) : Array<Field> {
			var a = Context.getBuildFields( );
			var sModule = Context.makeExpr( Context.getLocalClass( ).get( ).module , Context.currentPos( ) );
			var eName : Expr;
			//
				for( f in a ){

					switch( f.kind ){

						case FFun( func ):

							//
								//sFunc = Context.makeExpr( f.name , Context.currentPos( ) );
								var eRet : Expr = null;
								if( func.ret != null ){

									switch( func.ret ){

										case TPath( t ):
											switch( t.name ){

												case "Void":

												case "Float":
													eRet = macro return -1;

												case "Int":
													eRet = macro return -1;

												case "Bool":
													eRet = macro return false;

												default:
													eRet = macro return null;

											}

										default:
											eRet = null;
									}
								}

							//
							var expr : Expr = func.expr;
								expr = macro {
									//trace("call ::: "+$sModule);
									try{
										$expr;
									}catch( e : flash.errors.ArgumentError ){
										#if HypSystem
											fr.hyperfiction.HypSystem.reportError(
												$sModule ,
												e.toString( ),
												haxe.CallStack.toString( haxe.CallStack.exceptionStack( ) )+"\n"+haxe.CallStack.toString( haxe.CallStack.callStack( ) )
											);
										#else
											trace("ArgumentError");
											throw( e );
										#end
									}catch( e : flash.errors.TypeError ){

										#if HypSystem
											fr.hyperfiction.HypSystem.reportError(
												$sModule ,
												e.toString( ),
												haxe.CallStack.toString( haxe.CallStack.exceptionStack( ) )+"\n"+haxe.CallStack.toString( haxe.CallStack.callStack( ) )
											);
										#else
											trace("TypeError");
											throw( e );
										#end

									}catch( e : flash.errors.Error ){

										#if HypSystem
											fr.hyperfiction.HypSystem.reportError(
												$sModule ,
												e.toString( ),
												haxe.CallStack.toString( haxe.CallStack.exceptionStack( ) )+"\n"+haxe.CallStack.toString( haxe.CallStack.callStack( ) )
											);
										#else
											trace("Error");
											throw( e );
										#end

									}catch( unknown : Dynamic ) {

										#if HypSystem
											fr.hyperfiction.HypSystem.reportError(
												$sModule ,
												"Unknown exception : "+Std.string(unknown) ,
												haxe.CallStack.toString( haxe.CallStack.exceptionStack( ) )+"\n"+haxe.CallStack.toString( haxe.CallStack.callStack( ) )
											);
										#end

										trace("Unknow error ::: "+$sModule);
										trace( unknown );
										trace( haxe.CallStack.toString( haxe.CallStack.callStack( ) ) );
										#if HypSystem
											fr.hyperfiction.HypSystem.reportError(
												$sModule ,
												"Unknown exception : "+Std.string(unknown) ,
												haxe.CallStack.toString( haxe.CallStack.exceptionStack( ) )+"\n"+haxe.CallStack.toString( haxe.CallStack.callStack( ) )
											);
										#end
									}

								};

								if( eRet != null ){
									expr = macro {
										$expr;
										$eRet;
									}
								}

							func.expr = expr;
							/*
							var e = macro {
								try{
									$(expr);
								}catch( e : flash.errors.Error ){
									trace("errror ::: "+e);
								}
							};
							*/
						default:

					}
				}

			return a;
		}
		#end


	// -------o protected



	// -------o misc

}