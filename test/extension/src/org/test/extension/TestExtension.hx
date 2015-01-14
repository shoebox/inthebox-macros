package org.test.extension;

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("testextension")
@CPP_PRIMITIVE_PREFIX("testextension")
class TestExtension
{
	
	#if android @JNI #else @CPP #end
	public static function sampleMethod(value:Int):Float
	{
		return -1.0;
	}

	@JNI public static function testArray(value:Int):Array<Int>
	{
		return [];
	}
}
