package butterfly.html;

import massive.munit.Assert;
import butterfly.html.TagFinder;

class TagFinderTest
{
	@Test
	public function findTagReturnsTagIfTagIsPresent():Void
	{
		var expected = "<img src='cool.png' />";
		var actual = TagFinder.findTag("img", '<div>${expected}</div>');
		Assert.isNotNull(actual);
		Assert.areEqual(expected, actual.html);
	}

	@Test
	public function findTagReturnsNullIfTagIsNotPresent():Void
	{
		var actual = TagFinder.findTag("phone", "<div><p>Hi!</p><p>Hello!</p></div>");
		Assert.isNull(actual);
	}
}
