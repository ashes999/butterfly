import massive.munit.TestSuite;

import butterfly.html.TagFinderTest;
import butterfly.html.HtmlTagTest;
import ExampleTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(butterfly.html.TagFinderTest);
		add(butterfly.html.HtmlTagTest);
		add(ExampleTest);
	}
}
