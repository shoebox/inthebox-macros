import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class DefaultBodyTest
{
	public function new()
	{

	}

	@BeforeClass public function beforeClass(){}
	@AfterClass public function afterClass(){}	
	@Before public function setup(){}
	@After public function tearDown(){}

	@Test public function testDisabled()
	{
		Assert.isFalse(TestDefault.test1());
		Assert.isNull(TestDefault.test2());
		Assert.areEqual(TestDefault.test3(), -1.0);
		Assert.isNull(TestDefault.test4());
	}

	@Test public function testdDefaultResponse()
	{
		Assert.areEqual(TestDefault.testCustomResponseString(), "osef");
		Assert.isTrue(TestDefault.testCustomBool());
	}
}

@:build(ShortCuts.mirrors())
class TestDefault
{
	@DISABLED @JNI @CPP public static function test1():Bool;
	@DISABLED @JNI @CPP public static function test2():String;
	@DISABLED @JNI @CPP public static function test3():Float;
	@DISABLED @JNI @CPP public static function test4():Dynamic;
	@DISABLED @JNI @CPP public static function testCustomBool():Bool
	{
		return true;
	};
	@DISABLED @JNI @CPP public static function testCustomResponseString():String
	{
		return "osef";
	};
	@DISABLED @JNI @CPP public static function testVoid1();
	@DISABLED @JNI @CPP public static function testVoid2():Void;
}
