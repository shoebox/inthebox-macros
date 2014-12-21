package org.test.extension;

import android.util.Log;

public class NonStaticMirror
{
	static NonStaticMirror instance = null;

	public static NonStaticMirror getJniInstance()
	{
		if (instance == null) instance = new NonStaticMirror();
		return instance;
	}

	public boolean method1(boolean value1, String value2)
	{
		Log.d("debug", "method1 = " + value2);
		return true;
	}
}
