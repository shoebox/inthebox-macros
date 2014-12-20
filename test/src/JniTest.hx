package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import haxe.rtti.Meta;

import testpackage.TestJni1;
import testpackage.TestJni2;

class JniTest
{
	public function new()
	{
		TestJni1;
	}

	@BeforeClass public function beforeClass():Void{}
	@AfterClass public function afterClass():Void{}
	@After public function tearDown():Void{}
	@Before public function setup():Void{}

	@Test public function testAbstractSignature()
	{
		var metas = Meta.getStatics(TestJni1);
		Assert.areEqual(metas.method1.jni_signature[0], 
			"(Ljava/lang/String;ZI)Ljava/lang/String;");

		Assert.areEqual(metas.method2.jni_signature[0], "(ZIF)Z");
		Assert.areEqual(metas.method3.jni_signature[0], 
			"(Ljava/lang/String;IF)V");
	}

	@Test public function testSignatureNonAbstract()
	{
		var metas = Meta.getStatics(TestJni1);
		Assert.areEqual(metas.method4.jni_signature[0], 
			"(Ltestpackage/TestClass;ZI)I");
	}

	@Test public function testAbstractArray()
	{
		var metas = Meta.getStatics(TestJni1);
		Assert.areEqual(metas.methodArray1.jni_signature[0], 
			"([Ljava/lang/String;)I");
		Assert.areEqual(metas.methodArray2.jni_signature[0], 
			"([Ljava/lang/String;[I)[Ljava/lang/String;");
	}

	@Test public function testPackage()
	{
		var metas = Meta.getStatics(TestJni1);	
		Assert.areEqual(metas.method3.jni_package[0], "testpackage/TestJni1");
	}

	@Test public function testPackageMeta()
	{
		var metas = Meta.getStatics(TestJni1);	
		Assert.areEqual(metas.method4.jni_package[0], "package/toto/com/TestJni1");
	}

	@Test public function testDefaultPackage()
	{
		var metas = Meta.getStatics(TestJni2);	
		Assert.areEqual(metas.methodAlt.jni_package[0], 
			"org/shoebox/testpackagealt/TestJni2");	
	}
}
