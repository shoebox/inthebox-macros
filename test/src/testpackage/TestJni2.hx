package testpackage;

@:build(ShortCuts.mirrors())
@JNI_DEFAULT_PACKAGE("org.shoebox.testpackage")
class TestJni2
{
	@JNI 
	public static function method1(toto:String):Void{}

	@JNI("org.shoebox.testpackagealt") 
	public static function methodAlt(toto:String):Void{}
}
