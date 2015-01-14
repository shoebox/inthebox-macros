package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import haxe.rtti.Meta;

class IosTest 
{
	public function new()
	{
		TestIos;
	}

	@Test public function testLibrary()
	{
		Assert.areEqual(Meta.getStatics(TestIos).test1.cpp_library[0], "testextension");
		Assert.areEqual(Meta.getStatics(TestIos).test2.cpp_library[0], "toto");
	}

	@Test public function testPrimitive()
	{
		Assert.areEqual(Meta.getStatics(TestIos).test1.cpp_primitive[0], "prefix_test1");
		Assert.areEqual(Meta.getStatics(TestIos).test2.cpp_primitive[0], "prim");
	}
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("testextension")
@CPP_PRIMITIVE_PREFIX("prefix")
class TestIos
{
	@IOS public static function test1(toto:String, value:Bool):Float{return 0.0;};
	@IOS("toto", "prim") public static function test2(toto:String, 
		value:Bool):Bool{return false;};
}
