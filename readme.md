
Mirrors:
========

The native mirror macro, permit to call native methods (JNI/CPP) from the haxe side easily.

The metas:
----

Each meta support 2 arguments: the package / lib name, and the method name

Both are optionals for JNI (it uses the haxe package & class name / method name by default)
Both are needed for iOS & CPP.

After the version 1.0.1 conditional compilation is no more needed, the call check itself if the Context defined the required flags (ios for iOS ...)

JNI calls:
----

It support both type of methods : static or non-static.

In case of a static method it's easy:

```haxe
@JNI
function toto(arg1:String, arg2:Int, arg3:String):Bool{}
```

In the case of a non-static method, you have to set as first argument of the method a dynamic value which is the java instance of the class (than you can by example get by calling a static java singleton method)

```haxe
@JNI
function toto(instance:Dynamic, arg2:Int , arg2:String):Bool{}
```

The JNI signature of the method is automatically created.

And the JNI method is called at the same time you call the method on the haxe side.

Like said earlier you can add additional arguments to the @JNI tag:

To call a method named differently:
```haxe
@JNI("methodJava")
function toto(instance:Dynamic, arg2:Int , arg2:String):Bool{}
```

To class a method from another class:
```haxe
@JNI("another.class.java.Class","methodJava")
function toto(instance:Dynamic, arg2:Int , arg2:String):Bool{}
```

CPP & iOS calls:
----

They both behave the same way.

The first argument is the name of library (in the case of a OpenFL native extension if the ".a" filename)

The second argument is the name of the primitive (in the case of a Open native extension, the primitive is defined into the ExternalInterface.cpp class)

```haxe
@CPP("lib-name-of-extension","primitive_name")
function toto(arg1:String, arg2:Int, arg3:String):Bool{}
```

Developed by :
----
[Johann Martinache](https://github.com/shoebox) 
[@shoe_box](https://twitter.com/shoe_box)

License
----
This work is under BSD simplified License.
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
