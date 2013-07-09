package ;

import org.shoebox.macros.MacroInjector;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

/**
 * ...
 * @author shoe[box]
 */

class ShortCuts{

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
			return MacroInjector.inject( );
		}


		#end

	// -------o protected



	// -------o misc

}