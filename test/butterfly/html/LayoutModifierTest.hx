package butterfly.html;

import massive.munit.Assert;
import sys.FileSystem;
import sys.io.File;

import butterfly.core.Page;
import butterfly.core.Post;
import test.helpers.Factory;
import test.helpers.Assert2;

using StringTools;

class LayoutModifierTest
{
  private static inline var TEST_FILES_DIR = "test/temp";

  @Before
  public function createTestFilesDirectory() {
    FileSystem.createDirectory(TEST_FILES_DIR);
  }

  @After
  public function deleteTestFiles() {
    butterfly.io.FileSystem.deleteDirRecursively(TEST_FILES_DIR);
    FileSystem.deleteDirectory(TEST_FILES_DIR);
  }

  @Test
  public function constructorThrowsIfLayoutFileIsMissing() {
    var config = Factory.createButterflyConfig();
    
    var message = Assert2.throws(function() {
      new LayoutModifier('${TEST_FILES_DIR}/doesntexist.html', config, [], []);
    });
    
    Assert.isTrue(message.indexOf("Can't find layout file") > -1);
  }

  @Test
  public function constructorThrowsIfButterflyPagesTagIsMissing() {
    var config = Factory.createButterflyConfig();
    var layoutFile = '${TEST_FILES_DIR}/layout.html';
    var layout = Factory.createLayoutFile(layoutFile, "<butterfly-tags show-counts=\"true\" />");
    var config = Factory.createButterflyConfig();
    
    var message = Assert2.throws(function() {
      new LayoutModifier(layoutFile, config, [], []);
    });
    
    Assert.isTrue(message.indexOf("does not contain the tag to list pages") > -1 ||
      message.indexOf("<butterfly-pages") > -1);
  }

  @Test
  public function constructorDoesntThrowIfPageTagIsMissingAndCheckForButterflyPagesIsFalse() {
    var config = Factory.createButterflyConfig();
    var layoutFile = '${TEST_FILES_DIR}/layout.html';
    var layout = Factory.createLayoutFile(layoutFile, "<butterfly-tags show-counts=\"true\" />");
    var config = Factory.createButterflyConfig();
    
    new LayoutModifier(layoutFile, config, [], [], false);
  }

  @Test
  public function constructorGeneratesPageLinks() {
    var layoutFile = '${TEST_FILES_DIR}/layout.html';
    var layout = Factory.createLayoutFile(layoutFile, "<butterfly-pages /><butterfly-tags />");
    var config = Factory.createButterflyConfig();
    
    var p1:Page = new Page();
    p1.title = "First Page";
    p1.url = "first-page.html";
    
    var p2:Page = new Page();
    p2.title = "Second Page";
    p2.url = "second/page.html";
    
    var html = new LayoutModifier(layoutFile, config, [], [p1, p2]).getHtml();
    throw html;
    Assert.isTrue(html.indexOf('href="${p1.url}"') > -1);
    Assert.isTrue(html.indexOf('href="${p2.url}"') > -1);
  }

  @Test
  public function constructorAddsGoogleAnalyticsFromConfigToHtml() {
    var gaId = "UA-999999";
    var gaCode = sys.io.File.getContent("templates/googleAnalytics.html").replace("GOOGLE_ANALYTICS_ID", gaId);

    var layoutFile = Factory.createLayoutFile('${TEST_FILES_DIR}/layout.html');
    // Sanity check that default value layout doesn't have expected HTML
    Assert.isTrue(sys.io.File.getContent(layoutFile).indexOf("google-analytics.com") == -1);
    var config = Factory.createButterflyConfig();
    config.googleAnalyticsId = gaId;

    var modifier = new LayoutModifier(layoutFile, config, new Array<Post>(), new Array<Page>());

    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf(gaCode) > -1);
  }

  @Test
  public function constructorAddsAtomLinkTagToHtml() {
    var layoutFile = Factory.createLayoutFile('${TEST_FILES_DIR}/layout.html');

    var expectedSnippet = '<link type="application/atom+xml"';
    // Sanity check that default value layout doesn't have a hard-coded link tag
    Assert.isTrue(sys.io.File.getContent(layoutFile).indexOf(expectedSnippet) == -1);
    var config = Factory.createButterflyConfig();

    var modifier = new LayoutModifier(layoutFile, config, new Array<Post>(), new Array<Page>());
    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf(expectedSnippet) > -1);
  }

  @Test
  public function constructorSubstitutesVariablesFromConfigWithTheirValues() {
    var layoutFile = Factory.createLayoutFile('${TEST_FILES_DIR}/layout.html', "<head><title>$siteName</title></head> <butterfly-pages />");
    var config = Factory.createButterflyConfig();
    config.siteName = "Learn Haxe";
    var modifier = new LayoutModifier(layoutFile, config, new Array<Post>(), new Array<Page>());
    var actual = modifier.getHtml();
    Assert.isTrue(actual.indexOf("<title>Learn Haxe</title>") > -1);
  }

	@Test
	public function constructorReplacesButterflyTagsPlaceholderWithTags()
	{
		// Create a couple of posts with tags
    var p1 = Factory.createPost("meta-publishedOn: 2016-03-03\r\nPuppies are Cute", '${TEST_FILES_DIR}/puppies.html');
    p1.tags = ["cute", "dogs"];
    
    var p2 = Factory.createPost("meta-publishedOn: 2016-03-03\r\nKittens are Cute", '${TEST_FILES_DIR}/kittens.html');
    p2.tags = ["cats", "cute"];
    
		// Create a layout with <butterfly-tags />
    var layoutFile = '${TEST_FILES_DIR}/layout.html';
    var layout = Factory.createLayoutFile(layoutFile, "<butterfly-pages /><butterfly-tags />");
    var config = Factory.createButterflyConfig();
    
		// Validate that you can see both tags in the final HTML
		var actual = new LayoutModifier(layoutFile, config, [p1, p2], []).getHtml();
    // Note that these words (dogs, cats) don't appear in the posts or titles.
    Assert.isTrue(actual.indexOf("dogs") > -1);
    Assert.isTrue(actual.indexOf("cats") > -1);
	}

  @Test
	public function constructorInsertsTagCountsIfAttributeIsSpecified()
	{
		// Create a couple of posts with tags
		var p1 = Factory.createPost("meta-publishedOn: 2016-03-03\r\nPuppies are Cute", '${TEST_FILES_DIR}/puppies.html');
    p1.tags = ["cute", "dogs"];
    
    var p2 = Factory.createPost("meta-publishedOn: 2016-03-03\r\nKittens are Cute", '${TEST_FILES_DIR}/kittens.html');
    p2.tags = ["cats", "cute"];
    
    // Create a layout with <butterfly-tags show-counts="true" />
    var layoutFile = '${TEST_FILES_DIR}/layout.html';
    var layout = Factory.createLayoutFile(layoutFile, "<butterfly-pages /><butterfly-tags show-counts=\"true\" />");
    var config = Factory.createButterflyConfig();
    
		// Validate that you can see both tags in the final HTML, with their post counts
		var actual = new LayoutModifier(layoutFile, config, [p1, p2], []).getHtml();
		Assert.isTrue(actual.indexOf("dogs</a> (1)") > -1);
    Assert.isTrue(actual.indexOf("cats</a> (1)") > -1);
    Assert.isTrue(actual.indexOf("cute</a> (2)") > -1);
	}
}
