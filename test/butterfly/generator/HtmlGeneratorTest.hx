package butterfly.generator;

import massive.munit.Assert;
import butterfly.generator.HtmlGenerator;
import butterfly.core.Post;
import test.helpers.Factory;

class HtmlGeneratorTest
{
	@Test
  // In Butterfly 0.3, we stopped auto-inserting the title in the post in a <h2>
  // tag. Butterfly now generates the h2 tag only if/where the layout has a
	// <butterfly-title /> tag.
	public function generatePostHtmlDoesntGenerateH2Tag()
	{
    var gen = Factory.createHtmlGenerator();
    var post = new Post();

    var actual = gen.generatePostHtml(post, Factory.createButterflyConfig());
    Assert.areEqual(-1, actual.indexOf("<h2"));
	}
}
