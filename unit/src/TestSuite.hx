import massive.munit.TestSuite;

import lycan.TimelineTest;
import lycan.util.PrefixTrieTest;
import LycanTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(lycan.TimelineTest);
		add(lycan.util.PrefixTrieTest);
		add(LycanTest);
	}
}
