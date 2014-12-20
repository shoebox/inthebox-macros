import massive.munit.TestSuite;

import CppCallTest;
import CppTest;
import JniCallTest;
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

		add(CppCallTest);
		add(CppTest);
		add(JniCallTest);
		add(JniTest);
	}
}
