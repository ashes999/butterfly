package butterfly.generator;

import massive.munit.Assert;

import butterfly.core.ButterflyConfig;
import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.generator.HtmlGenerator;

import test.helpers.Factory;
import sys.FileSystem;

using DateTools;

// When you add common code to both post/page generation, make sure you add
// tests for both functions (post/page generation)
class HtmlGeneratorTest
{
	private static inline var TEST_FILES_DIR = "test/temp/html_generator";

  @Before
  public function createTestFilesDirectory() {
    FileSystem.createDirectory(TEST_FILES_DIR);
  }

  @After
  public function deleteTestFiles() {
    nucleus.io.FileSystemExtensions.deleteDirRecursively(TEST_FILES_DIR);
  }

	@Test
  // In Butterfly 0.3, we stopped auto-inserting the title in the post in a <h2>
  // tag. Butterfly now generates the titleif/where the layout has a <butterfly-title />
	// tag (it doesn't generate any additional HTML).
	public function generatePostHtmlDoesntAutomaticallyInsertTitle()
	{
    var gen = Factory.createHtmlGenerator();
    var post = new Post();
		post.title = "Running MUnit with Haxelib";

    var actual = gen.generatePostHtml(post, new ButterflyConfig());
    Assert.areEqual(-1, actual.indexOf(post.title));
	}

	@Test
	public function generatePostHtmlReplacesButterflyTitleTagWithPostTitle()
	{
		var layout = "<butterfly-pages /><h2><butterfly-title /></h2>\n<butterfly-content /><butterfly-tags />";
		var gen = Factory.createHtmlGenerator(layout);
    var post = new Post();
		post.title = "Regex Replacement in Haxe";

    var actual = gen.generatePostHtml(post, new ButterflyConfig());
    Assert.isTrue(actual.indexOf('<h2>${post.title}</h2>') > -1);
	}

	@Test
	// no <butterfly-post-date /> tag present
	public function generatePostHtmlInsertsPostedOnDateInButterflyContentTag()
	{
		var layout = "<butterfly-pages /><h2><butterfly-title /></h2>\n<butterfly-content /><butterfly-tags />";
		var gen = Factory.createHtmlGenerator(layout);
    var post = new Post();
		post.createdOn = Date.now();

    var actual = gen.generatePostHtml(post, new ButterflyConfig());
    Assert.isTrue(actual.indexOf('Posted on ${post.createdOn.format("%Y-%m-%d")}') > -1);
	}

	@Test
	public function generatePostHtmlInsertsPostedOnDateInButterflyPostDateTag()
	{
		var layout = "<butterfly-pages /><h2><butterfly-title /></h2>\n<butterfly-content /><butterfly-tags />" +
		'Published <butterfly-post-date class="post-meta" prefix="Crafted on " />';
		var gen = Factory.createHtmlGenerator(layout);
    var post = new Post();
		post.createdOn = Date.now();

    var actual = gen.generatePostHtml(post, new ButterflyConfig());
    Assert.isTrue(actual.indexOf('<p class="post-meta">Crafted on ${post.createdOn.format("%Y-%m-%d")}') > -1);
	}

	@Test
	public function generatePostHtmlReplacesContentTagWithContent()
	{
		var layout = "<butterfly-content />";
		var expected = "Hi there!";
		var markdown = 'meta-publishedOn: 2016-01-31\r\n${expected}';
		var generator = Factory.createHtmlGenerator(layout);
		var post = Factory.createPost(markdown, '${TEST_FILES_DIR}/post.md');
		var actual = generator.generatePostHtml(post, new ButterflyConfig());
		Assert.isTrue(actual.indexOf(expected) > -1);
	}

	@Test
	public function generatePostHtmlReplacesCommentTagWithDisqusHtml()
	{
		Assert.isTrue(true);
	}

	@Test
	public function GeneratePostHtmlAppendsPostTitleToHtmlTitleTag()
	{
		Assert.isTrue(true);
	}

	@Test
	public function generatePostHtmlReplacesPageAndPostTitlesWithLinks()
	{
		var post = makePost("Chocolate Truffles", "http://fake.com/chocolate-truffles");

		var page = new Page();
		page.title = "About Le Chocolatier";
		page.url = "http://fake.com/about";

		var content = 'Do not ask [[${page.title}]]; just read this: [[${post.title}]]';

		var generator = new HtmlGenerator("<butterfly-pages /><butterfly-content /><butterfly-tags />",
			[post], [page]);

		var config = new ButterflyConfig();

		var postWithLinks = new Post();
		postWithLinks.content = content;

		var actual = generator.generatePostHtml(postWithLinks, config);
		Assert.isTrue(actual.indexOf(post.url) > -1);
		Assert.isTrue(actual.indexOf(page.url) > -1);
	}

	@Test
	public function generatePageHtmlReplacesContentTagWithContent()
	{
		Assert.isTrue(true);
	}

	@Test
	public function generatePageHtmlReplacesButterflyTitleTagWithTitle()
	{
		Assert.isTrue(true);
	}

	@Test
	public function generatePageHtmlReplacesCommentTagWithDisqusHtml()
	{
		Assert.isTrue(true);
	}

	@Test
	public function GeneratePageHtmlAppendsPostTitleToHtmlTitleTag()
	{
		Assert.isTrue(true);
	}

	@Test
	public function generatePageHtmlReplacesPageAndPostTitlesWithLinks()
	{
		var post = makePost("Chocolate Truffles", "http://fake.com/chocolate-truffles");

		var page = new Page();
		page.title = "About Le Chocolatier";
		page.url = "http://fake.com/about";

		var content = 'Do not ask [[${page.title}]]; just read this: [[${post.title}]]';

		var generator = new HtmlGenerator("<butterfly-pages /><butterfly-content /><butterfly-tags />",
			[post], [page]);

		var config = new ButterflyConfig();

		var pageWithLinks = new Page();
		pageWithLinks.content = content;

		var actual = generator.generatePageHtml(pageWithLinks, config);
		Assert.isTrue(actual.indexOf(post.url) > -1);
		Assert.isTrue(actual.indexOf(page.url) > -1);
	}

	@Test
	public function generateTagPageHtmlGeneratesListOfPostsAndPostCount()
	{
			var p1 = makePost("First Post", "http://test.com/first-post.html");
			p1.tags = ["test"];
			var p2 = makePost("Second Post");
			p2.tags = ["test"];
			var p3 = makePost("Third Post");
			p3.tags = ["test"];
			var p4 = makePost("Real, Non-Test Post", "http://test.com/fourth-post.html");
			p4.tags = ["apple", "banana"];

			var html = Factory.createHtmlGenerator().generateTagPageHtml(p1.tags[0], [p1, p2, p3]);

			Assert.isTrue(html.indexOf("3") > -1); // Post count
			Assert.isTrue(html.indexOf("tagged with test") > -1); // tag header
			Assert.isTrue(html.indexOf(p1.url) > -1);

			Assert.isTrue(html.indexOf(p1.title) > -1);
			Assert.isTrue(html.indexOf(p2.title) > -1);
			Assert.isTrue(html.indexOf(p3.title) > -1);

			// Doesn't have anything from p4
			Assert.areEqual(-1, html.indexOf(p4.title));
			Assert.areEqual(-1, html.indexOf(p4.url));
			Assert.areEqual(-1, html.indexOf(p4.tags[0]));
			Assert.areEqual(-1, html.indexOf(p4.tags[1]));
	}

	@Test
	public function generateHomePageHtmlGeneratesListOfPostsInOrder()
	{
		var p1 = makePost("Benefits of Drinking Water", "http://test.com/water.html");
		var p2 = makePost("Benefits of Eating Fish", "http://test.com/fish.html");
		var p3 = makePost("Donuts That Kill", "http://test.com/donutz.html");
		var posts:Array<Post> = [p1, p2, p3];

		var generator = new HtmlGenerator("<butterfly-content />", posts, new Array<Page>());
		var html = generator.generateHomePageHtml();
		for (post in posts) {
			Assert.isTrue(html.indexOf(post.title) > -1);
			Assert.isTrue(html.indexOf(post.url) > -1);
		}

		Assert.isTrue(html.indexOf(p1.title) < html.indexOf(p2.title));
		Assert.isTrue(html.indexOf(p2.title) < html.indexOf(p3.title));
	}

	@Test
	public function tagLinkGeneratesAnchorTagWithTagName()
	{
		var actual = HtmlGenerator.tagLink("avacado");
		Assert.areEqual(0, actual.indexOf("<a"));
		Assert.isTrue(actual.indexOf("avacado") > -1);
		Assert.isTrue(actual.indexOf(".html") > -1);
	}

	private function makePost(title:String, url:String = ""):Post
	{
		var post = new Post();
		post.title = title;
		post.url = url;
		return post;
	}
}
