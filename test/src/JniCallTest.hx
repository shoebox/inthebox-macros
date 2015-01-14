package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

#if android
import org.test.extension.TestExtension;
#end

class JniCallTest
{
	public function new()
	{
		trace("constructor");
	}
	
	#if android
	@Test public function test1()
	{
		var result = TestExtension.sampleMethod(100);
		Assert.areEqual(result, 1212);
	}

	@Test public function testArray()
	{
		var result = TestExtension.testArray(42);
		Assert.areEqual(result.length, 3);
		Assert.areEqual(result[0], 10);
		Assert.areEqual(result[1], 42);
		Assert.areEqual(result[2], 100);
	}

	#end
}
