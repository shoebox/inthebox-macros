import haxe.rtti.Meta;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import testpackage.NonStaticMirror;

class JniNonStaticTest
{
	var meta1:Dynamic;
	
	public function new()
	{
		NonStaticMirror;
	}

	@BeforeClass public function beforeClass()
	{
		meta1 = Meta.getFields(NonStaticMirror);	
	}
	@AfterClass public function afterClass(){}	
	@Before public function setup(){}
	@After public function tearDown(){}

	#if android
	@Test public function testJavaInstance()
	{
		var instance = NonStaticMirror.getJniInstance();
		Assert.isNotNull(instance);
	}
	#end

	@Test public function testPackage()
	{
		Assert.areEqual(meta1.method1.jni_package[0], 
			"org/test/extension/NonStaticMirror");
	}

	@Test public function testSignature()
	{
		Assert.areEqual(meta1.method1.jni_signature[0], 
			'(ZLjava/lang/String;)Z');
	}

	#if android
	@Test public function testCall()
	{
		var instance = NonStaticMirror.getJniInstance();
		Assert.isNotNull(instance);

		var classInstance = new NonStaticMirror();
		var result = classInstance.method1(instance, false, "osef");
		Assert.isTrue(result);
	}
	#end
}
