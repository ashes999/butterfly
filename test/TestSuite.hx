import massive.munit.TestSuite;

import butterfly.generator.AtomGeneratorTest;
import butterfly.generator.HtmlGeneratorTest;
import butterfly.MainTest;
import butterfly.io.ArgParserTest;
import butterfly.core.ContentTest;
import butterfly.core.ButterflyConfigTest;
import butterfly.core.PageTest;
import butterfly.core.PostTest;
import butterfly.html.HtmlTagTest;
import butterfly.html.TagFinderTest;
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

		add(butterfly.generator.AtomGeneratorTest);
		add(butterfly.generator.HtmlGeneratorTest);
		add(butterfly.MainTest);
		add(butterfly.io.ArgParserTest);
		add(butterfly.core.ContentTest);
		add(butterfly.core.ButterflyConfigTest);
		add(butterfly.core.PageTest);
		add(butterfly.core.PostTest);
		add(butterfly.html.HtmlTagTest);
		add(butterfly.html.TagFinderTest);
		add(butterfly.html.LayoutModifierTest);
	}
}
