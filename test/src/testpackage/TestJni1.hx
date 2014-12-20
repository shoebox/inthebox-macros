package testpackage;

@:build(ShortCuts.mirrors())
class TestJni1
{
	@JNI public static function method1(toto:String, value1:Bool, 
		value2:Int):String{return null;}

	@JNI("primitivename") public static function method2(toto:Bool, 
		value:Int, float:Float):Bool{return false;}

	@JNI("primitivename") public static function method3(toto:String, 
		value:Int, float:Float):Void{}

	@JNI("package.toto.com", "primitivename") public static function method4(toto:TestClass, 
		value1:Bool, value2:Int):Int{return 0;}

	@JNI public static function methodArray1(array1:Array<String>):Int{return 0;}

	@JNI public static function methodArray2(array1:Array<String>, 
		array2:Array<Int>):Array<String>{return null;}
}

class TestClass
{

}
