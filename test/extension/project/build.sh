NDLL="../ndll/iPhone/"
HXCPP="haxelib run hxcpp Build.xml"
HXCPP_IPHONEOS=$HXCPP" -Diphoneos"
DEBUG="-Ddebug -Dfulldebug"
VERSION="-Dmiphoneos-version-min=7.0"
VERBOSE="-verbose"
GCC="-DHXCPP_GCC"
ARC="-DOBJC_ARC"
M64="-DHXCPP_M64"
LIB="downloadmanager"
DELAY="0.5"
COLOR="\n\n\\033[1;32m"

cleanup()
{
	rm -rf "obj"
	rm -rf "all_objs"
}

ios_armv6()
{
	echo "$COLOR Compiling for armv6"
	sleep $DELAY
	rm -rf NDLL"lib"LIB"-debug.iphoneos.a"
	rm -rf NDLL"lib"LIB".iphoneos.a"
	$HXCPP_IPHONEOS $VERBOSE $DEBUG $ARC $GCC
	sleep $DELAY
	$HXCPP_IPHONEOS $VERBOSE $ARC $GCC
	sleep $DELAY
}

ios_armv7()
{
	echo "$COLOR Compiling for armv7"
	rm -rf NDLL"lib"LIB"-debug.iphoneos-v7.a"
	rm -rf NDLL"lib"LIB".iphoneos-v7.a"

	$HXCPP_IPHONEOS -DHXCPP_ARMV7 $VERBOSE $DEBUG $VERSION $ARC $GCC
	sleep $DELAY
	$HXCPP_IPHONEOS -DHXCPP_ARMV7 $VERBOSE $VERSION $ARC $GCC
	sleep $DELAY
}

ios_simulator()
{
	echo "$COLOR Compiling for iOS simulator"
	rm -rf NDLL"lib"LIB"-debug.iphonesim.a"
	rm -rf NDLL"lib"LIB".iphonesim.a"
	$HXCPP -Diphonesim $VERBOSE $DEBUG $ARC $VERSION $GCC
	sleep $DELAY
	$HXCPP -Diphonesim -DHXCPP_ARMV7 $VERBOSE $VERSION $ARC $GCC
	sleep $DELAY
}

mac()
{
	echo "$COLOR Compiling for OSX"
	rm -rf NDLL"lib"LIB"-debug.iphonesim.a"
	rm -rf NDLL"lib"LIB".iphonesim.a"
	$HXCPP $VERBOSE $DEBUG $VERSION
	sleep $DELAY
	$HXCPP $VERBOSE $VERSION
	sleep $DELAY
}

mac64()
{
	echo "$COLOR Compiling for OSX 64bit"
	rm -rf NDLL"lib"LIB"-debug.iphonesim.a"
	rm -rf NDLL"lib"LIB".iphonesim.a"
	$HXCPP $M64 $VERBOSE $DEBUG $VERSION
	sleep $DELAY
	$HXCPP $M64 $VERBOSE $VERSION
	sleep $DELAY
}

android()
{
	echo "$COLOR Compiling for Android"
	rm -rf NDLL"lib"LIB"-debug.iphonesim.a"
	rm -rf NDLL"lib"LIB".iphonesim.a"
	$HXCPP -Dandroid $VERBOSE $DEBUG $VERSION
	$HXCPP -Dandroid -DHXCPP_ARMV7 $VERBOSE $DEBUG $VERSION
	sleep $DELAY
	$HXCPP -Dandroid $VERBOSE $VERSION
	$HXCPP -Dandroid -DHXCPP_ARMV7 $VERBOSE $VERSION
	sleep $DELAY
}

case "$1" in
	"v6")
		cleanup
		ios_armv6
	;;
	"v7")
		cleanup
		ios_armv7
	;;
	"simulator")
		cleanup
		ios_simulator
	;;
	"mac")
		cleanup
		mac
	;;
	"mac64")
		cleanup
		mac64
	;;
	"android")
		cleanup
		android
	;;
	*)
		cleanup
		ios_armv6
		ios_armv7
		ios_simulator
		mac
		mac64
		android
	;;
esac

cleanup
