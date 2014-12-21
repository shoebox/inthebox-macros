package testpackage;

@:build(ShortCuts.mirrors())
@JNI_DEFAULT_PACKAGE("org.test.extension")
class NonStaticMirror
{
	public function new(){}

	@JNI public static function getJniInstance():NonStaticMirror{return null;};

	@JNI public function method1(instance:NonStaticMirror, value1:Bool, 
		value2:String):Bool{return false;}
}
