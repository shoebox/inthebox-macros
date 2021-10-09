package mirror;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using mirror.JniFieldTool;
using tools.ExprTool;
using tools.FieldTool;
using tools.FunctionTool;
using tools.MetadataTools;
using tools.VariableTool;

class Jni
{
	public static var lastJNICall:String = null;
	
	static var DYNAMIC = TPath({name:"Dynamic", pack:[], params:[], sub:null});

	public function new(){}

	public static function build(field:Field, localClass:ClassType):Field
	{
		var jniPrimitive = field.getPrimitiveName();
		var jniSignature = field.getSignature();
		var jniPackage = field.getPackageName();

		#if munit
		var entrySignature = MetadataTools.create("jni_signature", field.pos, 
			[macro $v{jniSignature}]);
		field.meta.push(entrySignature);

		var entryPrimitive = MetadataTools.create("jni_primitive", field.pos, 
			[macro $v{jniPrimitive}]);
		field.meta.push(entryPrimitive);

		var entryPackage = MetadataTools.create("jni_package", field.pos, 
			[macro $v{jniPackage}]);
		field.meta.push(entryPackage);
		#end

		var func = field.getFunction();
		var fieldName = getMirrorName(field.name);
		var args = func.getArgsNames();
		var argsCount = args.length;
		var returnExpr = func.createReturnExpr(fieldName, args);
		var result = func.create(fieldName, field.pos);
		var isStaticMethod = field.isStaticField();

		#if (verbose_mirrors)
		Sys.println('[Mirror] Static : ' + isStaticMethod 
			+ ' --------------------------------------------------------');
		Sys.println('\tPackage = $jniPackage');
		Sys.println('\tPrimitive = $jniPrimitive');
		Sys.println('\tSignature = $jniSignature\n');
		#end

		if (!isStaticMethod)
			func.args[0].type = DYNAMIC;

		var returnTypeName = field.getFunction().ret.toString();
		switch (returnTypeName)
		{
			case "Void", "Int", "Bool", "String", "Float":
			case "Array<Float>", "Array<Int>", "Array<Bool>":
			default : field.getFunction().ret = DYNAMIC;
		}	
		
		if (Context.defined("android"))
		{
			func.expr = macro
			{
				if ($i{fieldName} == null)
				{
					#if verbose_mirrors
					trace("Lib not loaded, loading it");
					trace($v{jniPackage} + " :: " + $v{jniPrimitive} 
						+ ' :: signature '+$v{jniSignature});
					#end

					#if (openfl || nme)
					if ($v{isStaticMethod})
					{
						$i{fieldName} = openfl.utils.JNI.createStaticMethod(
							$v{jniPackage}, $v{jniPrimitive}, $v{jniSignature});
					}
					else
					{
						$i{fieldName} = openfl.utils.JNI.createMemberMethod(
							$v{jniPackage}, $v{jniPrimitive}, $v{jniSignature});
					}
					#end
				}
				
				mirror.Jni.lastJNICall = $v{fieldName};
				
				$returnExpr;
			}
		}
		return result;
	}

	static inline function getMirrorName(name:String)
	{
		return 'mirror_jni_$name';
	}
}
#else
class Jni {
	public static var lastJNICall:String = null;
}
#end
