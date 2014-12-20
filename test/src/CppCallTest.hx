package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

#if cpp
import org.test.extension.TestExtension;
#end

class CppCallTest
{
	public function new()
	{
		trace("constructor");
	}
	
	#if (mac || ios)
	@Test public function test1()
	{
		var result = TestExtension.sampleMethod(100);
		Assert.areEqual(result, 1212);
	}

	#end
}
