#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>

static value testextension_sampleMethod(value val)
{
	return alloc_float(val_int(val) * 12.12);
}
DEFINE_PRIM (testextension_sampleMethod, 1);

static value prefix_test1(value testString, value testBool)
{
	return alloc_float(1.23);
}
DEFINE_PRIM (prefix_test1, 2);

extern "C" void testextension_main()
{
	val_int(0); // Fix Neko init	
}
DEFINE_ENTRY_POINT(testextension_main);

extern "C" int testextension_register_prims()
{
	return 0;
}
