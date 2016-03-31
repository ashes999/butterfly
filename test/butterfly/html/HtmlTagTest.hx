package butterfly.html;

import massive.munit.Assert;
import butterfly.html.HtmlTag;

class HtmlTagTest
{
	@Test
	public function constructorFindsSelfEnclosedTagWithoutAttributes()
	{
		var expected = "<butterfly-pages />";
		var actual = new HtmlTag("butterfly-pages", '<html><head /><body><p>Hi!</p>${expected}</body></html>');

		// No attributes and nothing readable
		Assert.areEqual(0, actual.attributeCount);
		Assert.areEqual("", actual.attribute("size"));
		Assert.areEqual("", actual.attribute("show-tag-counts"));
	}

	@Test
	public function constructorReturnsEmptyHtmlIfTagIsNotPresent()
	{
		var actual = new HtmlTag("quest", "<table><th /><tr><td>hi</td></tr></table>");
		Assert.areEqual(0, actual.attributeCount);
	}

	@Test
	public function constructorFindsSelfEnclosedTagWithAttributesButOnlyMatchesDoubleQuotedAttributes()
	{
		var expected = '<barrel-o-monkeys no-chimps leader-name="Koko" />';
		var actual = new HtmlTag("barrel-o-monkeys", '<div><span>${expected}</div></span>'); // out of order tags
		Assert.areEqual(1, actual.attributeCount);
		Assert.areEqual("Koko", actual.attribute("leader-name"));
	}

	@Test
	public function constructorFindsSelfEnclosedTagWithAttributesButOnlyMatchesSingleQuotedAttributes()
	{
		var expected = "<awesome-spaceships can-cloak flagship-name='Enterprise' />";
		var actual = new HtmlTag("awesome-spaceships", '<div><span>${expected}</div></span>'); // out of order tags
		Assert.areEqual(1, actual.attributeCount);
		Assert.areEqual("Enterprise", actual.attribute("flagship-name"));
	}

	@Test
	public function constructorCanFindAttributesWithQuotesInThem()
	{
		// Used by LearnHaxe for Bootstrap blog template
		var expected = '<butterfly-pages link-prefix="<li>" link-suffix="</li>" link-class="blog-nav-item" />';
		var actual = new HtmlTag("butterfly-pages", expected);

		Assert.areEqual(3, actual.attributeCount);
		Assert.areEqual("<li>", actual.attribute("link-prefix"));
		Assert.areEqual("</li>", actual.attribute("link-suffix"));
		Assert.areEqual("blog-nav-item", actual.attribute("link-class"));
	}
}
