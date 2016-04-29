package butterfly;

import butterfly.core.ButterflyConfig;
import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.html.FileWriter;

using DateTools;
import Main;
import massive.munit.Assert;
using noor.io.FileSystemExtensions;
import sys.io.File;
import sys.FileSystem;
import test.helpers.Assert2;
import test.helpers.Factory;

@:access(Main)
class MainTest
{
	private static inline var TEST_FILES_DIR = "test/temp/main";

	@Before
	public function createTestFilesDirectory() {
		FileSystem.createDirectory(TEST_FILES_DIR);
	}

	@After
	public function deleteTestFiles() {
		FileSystem.deleteDirectoryRecursively(TEST_FILES_DIR);
	}

	@Test
	public function generateIndexPageUsesLayout()
	{
		var config = new ButterflyConfig();
		var srcDir = '${TEST_FILES_DIR}/standardlayout';
		var binDir:String = '${srcDir}/bin';		
		FileSystem.createDirectory(srcDir);
		FileSystem.createDirectory(binDir);

		var layout = "<h1>Standard Layout</h1><butterfly-content />";
		File.saveContent('${srcDir}/layout.html', layout);
		
		var post = new Post();
		post.tags = ["test-tag"];
		post.title = "Hello, World!";

		var generator = Factory.createHtmlGenerator(layout);
		var writer = new FileWriter(binDir);

		new Main().generateIndexPage(config, srcDir, [post], new Array<Page>(), generator, writer);

		var actual = File.getContent('${binDir}/index.html');
		// Check tags, content, and variables generated properly
		Assert.isTrue(actual.indexOf('<h1>Standard Layout</h1>') > -1);
	}

	@Test
	public function generateIndexPageUsesHomePageLayoutIfSpecifiedInConfig()
	{
		var config = new ButterflyConfig();

		config.siteName = "Client-Facing Site";
		config.homePageLayout = "custom-home.html";
		// Implicit in this test: <butterfly-pages /> is not specified, and this works
		var customHtml = "<h1>Custom HTML for $siteName</h1><butterfly-content /><butterfly-tags show-counts=\"true\" />";
		var post = new Post();
		post.tags = ["test-tag"];
		post.title = "Hello, World!";
		sys.io.File.saveContent('${TEST_FILES_DIR}/${config.homePageLayout}', customHtml);

		var generator = Factory.createHtmlGenerator();
		var writer = new FileWriter(TEST_FILES_DIR);

		new Main().generateIndexPage(config, TEST_FILES_DIR, [post], new Array<Page>(), generator, writer);

		var actual = sys.io.File.getContent('${TEST_FILES_DIR}/index.html');
		// Check tags, content, and variables generated properly
		Assert.isTrue(actual.indexOf('<h1>Custom HTML for ${config.siteName}') > -1);
		Assert.isTrue(actual.indexOf(post.title) > -1);
		// The last part of the tag link (the name) and the count
		Assert.isTrue(actual.indexOf("test-tag</a> (1)") > -1);
	}

	@Test
	public function sortPostsSortsPostsReverseChronologically()
	{
		// Create three posts, out of order (with respect to their "order" field);
		var firstPost = Factory.createPost('meta-publishedOn: 2011-01-31\r\nFirst post!', '${TEST_FILES_DIR}/c-first.md');
		var secondPost = Factory.createPost('meta-publishedOn: 2016-02-21\r\nSecond post!!', '${TEST_FILES_DIR}/a-second.md');
		var thirdPost = Factory.createPost('meta-publishedOn: 2016-02-22\r\nThird post!!!', '${TEST_FILES_DIR}/b-third.md');

		var posts:Array<Post> = [secondPost, thirdPost, firstPost];
		new Main().sortPosts(posts);
		Assert.areEqual(0, posts.indexOf(thirdPost));
		Assert.areEqual(1, posts.indexOf(secondPost));
		Assert.areEqual(2, posts.indexOf(firstPost));
	}

	@Test
	public function sortPagesSortsPagesByOrderAscending()
	{
		// Create four pages, out of order (with respect to their "order" field);
		var firstPage = Factory.createPage('meta-order: -3\r\nFirst post!', '${TEST_FILES_DIR}/first.md');
		// default (0). These two should be sorted by name alphabetically
		var secondPage = Factory.createPage('Third post!!', '${TEST_FILES_DIR}/second.md');
		var thirdPage = Factory.createPage('Second post!!', '${TEST_FILES_DIR}/third.md');
		var fourthPage = Factory.createPage('meta-order: 1\r\nFourth post!!!', '${TEST_FILES_DIR}/last.md');

		var pages:Array<Page> = [thirdPage, secondPage, fourthPage, firstPage];
		new Main().sortPages(pages);
		Assert.areEqual(0, pages.indexOf(firstPage));
		Assert.areEqual(1, pages.indexOf(secondPage));
		Assert.areEqual(2, pages.indexOf(thirdPage));
		Assert.areEqual(3, pages.indexOf(fourthPage));
	}
	
	@Test
	public function getAndValidateLayoutHtmlThrowsIfLayoutHtmlDoesntHaveContentPlaceholder()
	{
		var srcDir = TEST_FILES_DIR;
		var config = new ButterflyConfig();		
		File.saveContent('${srcDir}/layout.html', "<butterfly-pages />Bad, bad layout!");
		
		var message:String = Assert2.throws(function()
		{
            new Main().getAndValidateLayoutHtml(srcDir, config, [], []);
		});
		
		Assert.isNotNull(message);
		Assert.isTrue(message.indexOf("placeholder") > -1);
	}
	
	@Test
	public function getAndValidateLayoutHtmlDoesntThrowIfLayoutHasContentPlaceholder()
	{
		var srcDir = TEST_FILES_DIR;
		var config = new ButterflyConfig();		
		File.saveContent('${srcDir}/layout.html', "<butterfly-pages /><butterfly-content />");
		new Main().getAndValidateLayoutHtml(srcDir, config, [], []);
	}
	
	@Test
	public function runGeneratesHtmlFilesForPagesPostsTagsAndAtomFeed()
	{
		// Set up two posts, a custom home page, one page, config.json,
		// a layout, a CSS file, a JS file, and an image. Then test that they all generate correctly.
		// We're just testing files exist (with rough content checks). Most of the content generation
		// is tested in the core classes (Content, Post, Page) tests.
		
		var projectDir:String = '${TEST_FILES_DIR}/project';
		var srcDir:String = '${projectDir}/src';
		
		var post1Title:String = "brave-new-world";
		var post1Markdown:String = "Enter a brave new world!";
		var post1Content:String = createPostMarkdown(post1Markdown, ["exploration", "courage"], Date.fromString("2011-01-01"));
		var post2Title:String = "shiny-boat";
		var post2Markdown:String = "Guess which country creates the shiniest boats!";
		var post2Content:String = createPostMarkdown(post2Markdown, ["exploration", "boats"], Date.fromString("2011-12-31"));

		var pageTitle:String = "about";
		var pageContent:String = "Hello, World!";
		
		var layout:String = "<html><head><title>Cool Travel Site</title></head><body><butterfly-pages /><butterfly-content /></body></html>";
		var layoutFile:String = "layout.html";
		
		var customLayout:String = "<html><body><butterfly-pages />Custom home page!<br /><butterfly-content /></body></html>";
		var customLayoutFile = "custom.html";
		
		var config:String = '{ "siteName": "dummy site", "siteUrl": "http://dummy.com", 
			"authorName": "test robot", "homePageLayout": "${customLayoutFile}" }';		
		
		FileSystem.createDirectory(projectDir);
		FileSystem.createDirectory(srcDir);
		File.saveContent('${srcDir}/config.json', config);
		File.saveContent('${srcDir}/${layoutFile}', layout);
		File.saveContent('${srcDir}/${customLayoutFile}', customLayout);
		
		FileSystem.createDirectory('${srcDir}/posts');
		File.saveContent('${srcDir}/posts/${post1Title}.md', post1Content);
		File.saveContent('${srcDir}/posts/${post2Title}.md', post2Content);
		FileSystem.createDirectory('${srcDir}/pages');
		File.saveContent('${srcDir}/pages/${pageTitle}.md', pageContent);
		
		var contentDir:String = '${srcDir}/content';
		var cssFile = "main.css";
		var css:String = "* { padding: 0px; margin: 0px; }";
		var jsFile = "custom.js";
		var js:String = "function main() { }";
		
		FileSystem.createDirectory(contentDir);
		File.saveContent('${contentDir}/${cssFile}', css);
		File.saveContent('${contentDir}/${jsFile}', js);
		File.saveContent('${contentDir}/logo.png', "Not really a logo");
		
		new Main().run([projectDir]);
		
		// Verify all HTML was created correctly
		
		var binDir:String = '${projectDir}/bin';
		
		// Home page should use our custom layout
		var indexHtml:String = getFile('${binDir}/index.html');
		Assert.isTrue(indexHtml.indexOf('Custom home page') > -1);
		// Verify ordering of posts
		var earlierPostIndex = indexHtml.indexOf(post1Title);
		Assert.isTrue(earlierPostIndex > -1);
		var laterPostIndex = indexHtml.indexOf(post2Title);
		Assert.isTrue(laterPostIndex > -1);
		Assert.isTrue(laterPostIndex > -1);
		Assert.isTrue(laterPostIndex < earlierPostIndex);
		
		// About page uses the normal layout
		var aboutPage:String = getFile('${binDir}/about.html');
		Assert.isTrue(aboutPage.indexOf('<head>') > -1);
		Assert.isTrue(aboutPage.indexOf(pageContent) > -1);
		
		// Posts have content. Everything else is tested elsewhere.
		var post1:String = getFile('${binDir}/${post1Title}.html');
		Assert.isTrue(post1.indexOf(post1Markdown) > -1);
		var post2:String = getFile('${binDir}/${post2Title}.html');
		Assert.isTrue(post2.indexOf(post2Markdown) > -1);
		
		// Tag pages generate with all posts
		var uniqueTags = ["exploration", "courage", "boats"];
		for (tag in uniqueTags)
		{
			var tagFile:String = getFile('${binDir}/tag-${tag}.html');
			// A link to either post (not sure which is in which tag)
			Assert.isTrue(tagFile.indexOf(post1Title) > -1 || tagFile.indexOf(post2Title) > -1);
		}
		
		// Atom feed
		var atomXml:String = getFile('${binDir}/atom.xml');
		// Verify ordering of posts. Earliest posts are first.
		// Atom doesn't require this, but we do this. It's easier than using
		// xpath to get the updated date.
		earlierPostIndex = atomXml.indexOf(post1Title);
		Assert.isTrue(earlierPostIndex > -1);
		laterPostIndex = atomXml.indexOf(post2Title);
		Assert.isTrue(laterPostIndex > -1);
		Assert.isTrue(laterPostIndex > -1);
		Assert.isTrue(laterPostIndex < earlierPostIndex);
		
		// Verify all content files copied over
		assertFile('${binDir}/content/${cssFile}');
		assertFile('${binDir}/content/${jsFile}');
		assertFile('${binDir}/content/logo.png');
	}
	
	private function getFile(pathAndFilename:String):String
	{
		assertFile(pathAndFilename);
		return File.getContent(pathAndFilename);
	}
	
	private function assertFile(pathAndFilename:String):Void
	{
		Assert.isTrue(FileSystem.exists(pathAndFilename));
		Assert.isFalse(FileSystem.isDirectory(pathAndFilename));
	}
	
	private function createPostMarkdown(content:String, tags:Array<String>, publishedOn:Date):String
	{
		return 'meta-publishedOn: ${publishedOn.format("%Y-%m-%d")}\nmeta-tags: ${tags.join(", ")} \n ${content}'; 
	}
}
