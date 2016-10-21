package org.test.extension;

import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import org.haxe.extension.Extension;

public class TestExtension extends Extension
{
	public static float sampleMethod(int inputValue)
	{
		double result = inputValue * 12.12;
		return (float)result;
	}

	public static int[] testArray(int test)
	{
		int[] result = new int[3];
		result[0] = 10;
		result[1] = test;
		result[2] = 100;
		return result;
	}
}
