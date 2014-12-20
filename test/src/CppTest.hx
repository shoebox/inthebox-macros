package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import haxe.rtti.Meta;

class CppTest 
{
	public function new()
	{
		Test1;
		Test2;
	}
	
	@BeforeClass public function beforeClass():Void{}
	@AfterClass public function afterClass():Void{}
	@After public function tearDown():Void{}
	@Before public function setup():Void{}
	
	#if !android
	@Test public function testLibrary()
	{
		Assert.areEqual(Meta.getStatics(Test1).test1.cpp_library[0], "testextension");
		Assert.areEqual(Meta.getStatics(Test1).test2.cpp_library[0], "toto");
	}

	@Test public function testPrimitive()
	{
		Assert.areEqual(Meta.getStatics(Test1).test1.cpp_primitive[0], "prefix_test1");
		Assert.areEqual(Meta.getStatics(Test1).test2.cpp_primitive[0], "prim");
	}

	@Test public function testDefault()
	{
		Assert.areEqual(Meta.getStatics(Test2).test1.cpp_library[0], "testextension");
		Assert.areEqual(Meta.getStatics(Test2).test1.cpp_primitive[0], "test1");
	}

	@Test public function testCall1()
	{
		#if cpp
		var result = Test1.test1("toto", false);
		Assert.areEqual(result, 1.23);
		#end
	}
	#end
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("testextension")
@CPP_PRIMITIVE_PREFIX("prefix")
class Test1
{
	@CPP public static function test1(toto:String, value:Bool):Float{return 0.0;};
	@CPP("toto", "prim") public static function test2(toto:String, 
		value:Bool):Bool{return false;};
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("testextension")
class Test2
{
	@CPP public static function test1(toto:String, value:Bool):Void{};
}
