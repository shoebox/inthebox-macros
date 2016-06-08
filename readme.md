Mirrors:
========

Mirror macros make it easy to call native methods (Java/C++) from Haxe. To enable them, add this before your class declaration:

```haxe
@:build(ShortCuts.mirrors())
```

JNI calls:
----------

To call a static Java method, simply add `@JNI` before the Haxe function declaration:

```haxe
@JNI
public static function myStaticMethod(arg0:String, arg1:Int, arg2:String):Bool;
```

Instance methods are more complicated. In Haxe, you would call `instance.myInstanceMethod()`, but to make a JNI instance method work, you have to call `myInstanceMethod(instance)`:

```haxe
@JNI
public static function myInstanceMethod(instance:Dynamic, arg0:String, arg1:Int, arg2:String):Bool;
```

The macros are called "mirror macros" because they look for a Java function that exactly matches the Haxe function. If this is the class in Haxe...

```haxe
package com.example.mypackage;

@:build(ShortCuts.mirrors())
class MyClass {
    @JNI
    public static function myStaticMethod(arg0:String, arg1:Int, arg2:String):Bool;
}
```

The macro will look for a Java function in `com/example/mypackage/MyClass.java`, with exactly the same name, exactly the same arguments, and exactly the same return value. If you don't like this behavior, you can specify a custom package, class name, or method name.

To call a method with a different name:
```haxe
@JNI("javaMethodName")
public static function haxeMethodName(arg0:String, arg1:Int, arg2:String):Bool;
```

To call a method from another class:
```haxe
@JNI("com.example.otherpackage.OtherClass", "javaMethodName")
public static function haxeMethodName(arg0:String, arg1:Int, arg2:String):Bool;
```

To set a different class as the default:
```haxe
@:build(ShortCuts.mirrors())
@JNI_DEFAULT_PACKAGE("com.example.otherpackage")
@JNI_DEFAULT_CLASS_NAME("OtherClass")
class MyClass {
    @JNI
    public static function haxeMethodName(arg0:String, arg1:Int, arg2:String):Bool;
}
```

CPP & iOS calls:
----------------

The `@CPP` and `@IOS` tags take two arguments.

The first argument is the name of the library to load from. For instance, if you include a library using `<ndll name="my-cpp-library" />`, then the first argument should be `"my-cpp-library"`. If you don't want to type this for every single method, you can specify a default library using the `@CPP_DEFAULT_LIBRARY` tag:

```haxe
@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("my-cpp-library")
class MyClass {
    @CPP
    public static function myStaticMethod(arg0:String, arg1:Int, arg2:String):Bool;
}
```

The second argument is the name of the primitive, as defined by `DEFINE_PRIM()` in C++. For OpenFL native extensions, `DEFINE_PRIM()` is located in ExternalInterface.cpp. You may omit the second argument if the Haxe method name matches the C++ method name.

```haxe
@CPP("my-cpp-library", "cppMethodName")
public static function haxeMethodName(arg1:String, arg2:Int, arg3:String):Bool;
```

Finally, if the C++ methods all have the same prefix, you'll want to use the `@CPP_PRIMITIVE_PREFIX` tag:

```haxe
@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("my-cpp-library") @CPP_PRIMITIVE_PREFIX("prefix")
class MyClass {
    @CPP
    public static function myMethod(arg0:String, arg1:Int, arg2:String):Bool;
    @CPP
    public static function yourMethod():Void;
    @CPP
    public static function someOtherMethod(arg0:Int, arg1:Bool):Void;
}
```

This will add "`prefix_`" in front of the primitive names, resulting in `prefix_myMethod`, `prefix_yourMethod`, and `prefix_someOtherMethod`.

Developed by:
----
[Johann Martinache](https://github.com/shoebox) 
[@shoe_box](https://twitter.com/shoe_box)

License
----
This work is under BSD simplified License.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
