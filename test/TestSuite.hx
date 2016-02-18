import massive.munit.TestSuite;

import butterfly.generator.HtmlGeneratorTest;
import butterfly.MainTest;
import butterfly.html.TagFinderTest;
import butterfly.html.HtmlTagTest;
import butterfly.html.LayoutModifierTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(butterfly.generator.HtmlGeneratorTest);
		add(butterfly.MainTest);
		add(butterfly.html.TagFinderTest);
		add(butterfly.html.HtmlTagTest);
		add(butterfly.html.LayoutModifierTest);
	}
}
