import massive.munit.TestSuite;

import butterfly.core.PageTest;
import butterfly.core.PostTest;
import butterfly.core.ContentTest;
import butterfly.generator.HtmlGeneratorTest;
import butterfly.generator.AtomGeneratorTest;
import butterfly.html.LayoutModifierTest;
import butterfly.html.HtmlTagTest;
import butterfly.html.TagFinderTest;
import butterfly.MainTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(butterfly.core.PageTest);
		add(butterfly.core.PostTest);
		add(butterfly.core.ContentTest);
		add(butterfly.generator.HtmlGeneratorTest);
		add(butterfly.generator.AtomGeneratorTest);
		add(butterfly.html.LayoutModifierTest);
		add(butterfly.html.HtmlTagTest);
		add(butterfly.html.TagFinderTest);
		add(butterfly.MainTest);
	}
}
