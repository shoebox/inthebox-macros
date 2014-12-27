
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import haxe.rtti.Meta;

class AbstractTest
{
	var meta1:Dynamic;

	public function new()
	{
		GATracker;
	}

	@BeforeClass public function beforeClass():Void
	{
		meta1 = Meta.getStatics(GATracker);
	}

	@AfterClass public function afterClass():Void{}
	@After public function tearDown():Void{}
	@Before public function setup():Void{}

	@Test public function testJni1()
	{
		Assert.areEqual(meta1.testAbstractJni1.jni_signature[0], "(IF)Z");	
		Assert.areEqual(meta1.testAbstractJni1.jni_primitive[0], "testAbstractJni1");	
	}

	@Test public function testJni2()
	{
		Assert.areEqual(meta1.testAbstractJni2.jni_signature[0], "(F)I");	
		Assert.areEqual(meta1.testAbstractJni2.jni_primitive[0], "testAbstractJni2");
	}

	@Test public function testCpp1()
	{
		Assert.areEqual(meta1.testCpp1.cpp_library[0], "toto");
		Assert.areEqual(meta1.testCpp1.cpp_primitive[0], "osef");
	}
}

@:build(ShortCuts.mirrors())
abstract GATracker(Int)
{
	inline public function new(value:Int)
	{
		this = value;
	}

	@JNI public function testAbstractJni1(value:Float):Bool;
	@JNI public static function testAbstractJni2(value:Float):Int;
	@CPP('toto', 'osef') public function testCpp1(value:String):Int;
}
