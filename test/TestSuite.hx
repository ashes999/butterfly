import massive.munit.TestSuite;

import butterfly.generator.HtmlGeneratorTest;
import butterfly.html.LayoutModifierTest;
import butterfly.html.HtmlTagTest;
import butterfly.html.TagFinderTest;

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
		add(butterfly.html.LayoutModifierTest);
		add(butterfly.html.HtmlTagTest);
		add(butterfly.html.TagFinderTest);
	}
}
