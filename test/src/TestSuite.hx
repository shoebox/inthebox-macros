import massive.munit.TestSuite;

import AbstractTest;
import CppCallTest;
import CppTest;
import DefaultBodyTest;
import IosTest;
import JniCallTest;
import JniNonStaticTest;
import JniTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(AbstractTest);
		add(CppCallTest);
		add(CppTest);
		add(DefaultBodyTest);
		add(IosTest);
		add(JniCallTest);
		add(JniNonStaticTest);
		add(JniTest);
	}
}
