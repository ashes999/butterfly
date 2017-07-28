package butterfly.generator;

import massive.munit.Assert;

import butterfly.core.ButterflyConfig;
import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.generator.HtmlGenerator;
using noor.io.FileSystemExtensions;
import sys.FileSystem;
import sys.io.File;
import test.helpers.Factory;

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
    FileSystem.deleteDirectoryRecursively(TEST_FILES_DIR);
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
        var post:Post = makePost("Unicorns", "http://unicorns.com");
        post.content = "We love unicorns.";
        
        var actual = new HtmlGenerator("<butterfly-comments />", [post], [])
            .generatePostHtml(post, new ButterflyConfig());
            
        // Don't directly read the template, because it contains placeholders
        // Instead, look for the word "disqus"
        Assert.isTrue(actual.indexOf("disqus") > -1);
	}

	@Test
	public function generatePostHtmlAppendsPostTitleToHtmlTitleTag()
	{
        var postTitle:String = "Bananas";
        var siteTitle:String = "V R Bananas";
		var post:Post = makePost(postTitle, "http://wearebananas.com");
        post.content = "We really are bananas. And sell bananas.";
        
        var actual = new HtmlGenerator('<head><title>${siteTitle}</title></head><body><butterfly-content /></body>', [post], [])
            .generatePostHtml(post, new ButterflyConfig());
            
        // Don't directly read the template, because it contains placeholders
        // Instead, look for the word "disqus"
        Assert.isTrue(actual.indexOf('<title>${postTitle} | ${siteTitle}</title>') > -1);
	}

	@Test
	public function generatePostHtmlReplacesPageAndPostTitlesWithLinks()
	{
		var post = makePost("Chocolate Truffles", "http://fake.com/chocolate-truffles");

		var page = new Page();
		page.title = "About Le Chocolatier";
		page.url = "http://fake.com/about";

		var content = 'Do not ask [[${page.title}]]; just read this: [[${post.title}]]';

		var generator = new HtmlGenerator
            ("<butterfly-pages /><butterfly-content /><butterfly-tags />", [post], [page]);

		var postWithLinks = new Post();
		postWithLinks.content = content;

		var actual = generator.generatePostHtml(postWithLinks, new ButterflyConfig());
		Assert.isTrue(actual.indexOf(post.url) > -1);
		Assert.isTrue(actual.indexOf(page.url) > -1);
	}

	@Test
	public function generatePageHtmlReplacesContentTagWithContent()
	{
		var page = makePage("Blueberry Smoothies", "Blueberry smoothies are very healthy.");
        
        var generator = new HtmlGenerator
            ("<h1>Fake.com</h1><br /><butterfly-content />", [], [page]);
            
        var actual = generator.generatePageHtml(page, new ButterflyConfig());
		Assert.isTrue(actual.indexOf(page.content) > -1);
	}

	@Test
	public function generatePageHtmlReplacesButterflyTitleTagWithTitle()
	{
		var page = makePage("Raspberry Smoothies", "Raspberry smoothies are very healthy.");
        
        var generator = new HtmlGenerator
            ("<h1><butterfly-title /></h1><br /><butterfly-content />", [], [page]);
            
        var actual = generator.generatePageHtml(page, new ButterflyConfig());
		Assert.isTrue(actual.indexOf('<h1>${page.title}</h1>') > -1);
	}

	@Test
	public function generatePageHtmlReplacesCommentTagWithDisqusHtml()
	{
		var page = makePage("Strawberry Smoothies", "Strawberry smoothies are very healthy.");
        
        var generator = new HtmlGenerator
            ("<butterfly-content /><div id='comments'><butterfly-comments /></div>", [], [page]);
            
        var actual = generator.generatePageHtml(page, new ButterflyConfig());
        var divIndex = actual.indexOf("<div id='comments'>") + 19; // 19 = length of opening div tag
		Assert.isTrue(actual.indexOf("disqus") > divIndex);
	}

	@Test
	public function generatePageHtmlAppendsPageTitleToHtmlTitleTag()
	{
		var pageTitle:String = "About";
        var siteTitle:String = "Monkeys R Us";
		var page:Page = makePage(pageTitle, "We love monkeys. And bananas.");
        
        var actual = new HtmlGenerator('<head><title>${siteTitle}</title></head><body><butterfly-content /></body>', [], [page])
            .generatePageHtml(page, new ButterflyConfig());
            
        Assert.isTrue(actual.indexOf('<title>${pageTitle} | ${siteTitle}</title>') > -1);
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

	@Test
	public function generatePostHtmlGeneratesOpenGraphDescriptionWithoutQuotations()
	{
		var title:String = "Markdown File";

    	var markdown = "meta-publishedOn: 2011-12-31
			This is a multi-line 'post' (but don't " + '"quote" me on that)!
			This is the second line.
			And the last line.';

		var fullFileName = '${TEST_FILES_DIR}/simple.md';
		File.saveContent(fullFileName, markdown);
		var post:Post = new Post();
		post.parse(fullFileName);
	
		// </head> tag is required to generate OpenGraph data
		var generator = new HtmlGenerator
            ("<butterfly-pages /><head></head><butterfly-content /><butterfly-tags />", [post], []);
		
		// Use "parse" to get the description

		var actual = generator.generatePostHtml(post, new ButterflyConfig());
		var expected = "This is a multi-line post (but dont quote me on that)!";
		expected = '<meta property="og:description" content="${expected}" />';
		Assert.isTrue(actual.indexOf(expected) > -1);
	}
	
	@Test
	public function generatePostHtmlGeneratesOpenGraphImageUsingMetaImageUrl()
	{
		var title:String = "Markdown File";
		var imageUrl = "http://i.imgur.com/iCjtnYS.gif";

		// Also tests that prefixing with whitespace still properly detects metadata
    	var markdown = '
			meta-publishedOn: 2011-12-31
			meta-image: ${imageUrl}
			The rest of the content does not matter.';

		var fullFileName = '${TEST_FILES_DIR}/imageMeta.md';
		File.saveContent(fullFileName, markdown);
		var post:Post = new Post();
		post.parse(fullFileName);
		Assert.isTrue(post.image != null && post.image != "");
	
		// </head> tag is required to generate OpenGraph data
		var generator = new HtmlGenerator
            ("<butterfly-pages /><head></head><butterfly-content /><butterfly-tags />", [post], []);
		
		var actual = generator.generatePostHtml(post, new ButterflyConfig());
		var expected = '<meta property="og:image" content="${imageUrl}" />';
		Assert.isTrue(actual.indexOf(expected) > -1);
	}
	
	@Test
	public function generatePostHtmlGeneratesOpenGraphImageUsingFirstEmbeddedImage()
	{
		var title:String = "Markdown File";
		
		// Also tests that prefixing with whitespace still properly detects metadata
    	var firstImageUrl = "http://i.imgur.com/iCjtnYS.gif";
		var markdown = 'meta-publishedOn: 2017-07-28
			Week 4: ![](${firstImageUrl})
			Week 3: ![](http://i.imgur.com/JuNPgsR.gif)
			Content goes here.
			Publication date is not necessary.';

		var fullFileName = '${TEST_FILES_DIR}/embeddedImages.md';
		File.saveContent(fullFileName, markdown);
		var post:Post = new Post();
		post.parse(fullFileName);
		Assert.isTrue(post.image != null && post.image != "");
	
		// </head> tag is required to generate OpenGraph data
		var generator = new HtmlGenerator
            ("<butterfly-pages /><head></head><butterfly-content /><butterfly-tags />", [post], []);
		
		var actual = generator.generatePostHtml(post, new ButterflyConfig());
		var expected = '<meta property="og:image" content="${firstImageUrl}" />';
		Assert.isTrue(actual.indexOf(expected) > -1);
	}

	private function makePost(title:String, url:String = ""):Post
	{
		var post = new Post();
		post.title = title;
		post.url = url;
		return post;
	}
    
    private function makePage(title:String, content:String):Page
    {
        var page = new Page();
        page.title = title;
        page.content = content;
        return page;
    }
}
