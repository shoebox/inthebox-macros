package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import haxe.rtti.Meta;

import testpackage.TestJni1;
import testpackage.TestJni2;

class JniTest
{
	var meta1:Dynamic;
	var meta2:Dynamic;

	public function new()
	{
		TestJni1;
		TestJni2;
	}

	@BeforeClass public function beforeClass():Void
	{
		meta1 = Meta.getStatics(TestJni1);
		meta2 = Meta.getStatics(TestJni2);
	}

	@AfterClass public function afterClass():Void{}
	@After public function tearDown():Void{}
	@Before public function setup():Void{}

	@Test public function testAbstractSignature1()
	{
		Assert.areEqual(meta1.method1.jni_signature[0], 
			"(Ljava/lang/String;ZI)Ljava/lang/String;");
	}

	@Test public function testPrimitive1()
	{
		Assert.areEqual(meta1.method1.jni_primitive[0], "method1");
	}

	@Test public function testAbstractSignature2()
	{
		Assert.areEqual(meta1.method2.jni_signature[0], "(ZIF)Z");
	}

	@Test public function testPrimitive2()
	{
		Assert.areEqual(meta1.method2.jni_primitive[0], "primitivename");
	}

	@Test public function testAbstractSignature3()
	{
		Assert.areEqual(meta1.method3.jni_signature[0], 
			"(Ljava/lang/String;IF)V");
	}

	@Test public function testPrimitive3()
	{
		Assert.areEqual(meta1.method2.jni_primitive[0], "primitivename");
	}

	@Test public function testAbstractSignature4()
	{
		Assert.areEqual(meta1.method4.jni_signature[0], 
			"(Ltestpackage/TestClass;ZI)I");
	}

	@Test public function testPrimitive4()
	{
		Assert.areEqual(meta1.method4.jni_primitive[0], "primitivename");
	}

	@Test public function testPackage()
	{
		Assert.areEqual("testpackage/TestJni1", meta1.method1.jni_package[0]);
		Assert.areEqual("testpackage/TestJni1", meta1.method2.jni_package[0]);
		Assert.areEqual("testpackage/TestJni1", meta1.method3.jni_package[0]);
	}

	@Test public function testPackageMeta()
	{
		Assert.areEqual(meta1.method4.jni_package[0], "package/toto/com/TestJni1");
	}

	@Test public function testDefaultPackage()
	{
		Assert.areEqual(meta2.methodAlt.jni_package[0], 
			"org/shoebox/testpackagealt/TestJni2");	
	}
}
