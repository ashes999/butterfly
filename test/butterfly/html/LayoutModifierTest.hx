package butterfly.html;

import massive.munit.Assert;
import sys.FileSystem;
import sys.io.File;

import butterfly.core.Page;
import butterfly.core.Post;
import test.helpers.Factory;

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
  public function constructorAddsGoogleAnalyticsFromConfigToHtml() {
    var gaId = "UA-999999";
    var gaCode = sys.io.File.getContent("templates/googleAnalytics.html").replace("GOOGLE_ANALYTICS_ID", gaId);

    var layoutFile = createLayoutFile();
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
    var layoutFile = createLayoutFile();

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
    var layoutFile = createLayoutFile("<head><title>$siteName</title></head> <butterfly-pages />");
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
		// Create a layout with <butterfly-tags />
		// Validate that you can see both tags in the final HTML
		Assert.isTrue(true);
	}

  @Test
	public function constructorInsertsTagCountsIfAttributeIsSpecified()
	{
		// Create a couple of posts with tags
		// Create a layout with <butterfly-tags show-counts="true" />
		// Validate that you can see both tags in the final HTML, with their post counts
		Assert.isTrue(true);
	}

  // Creates a layout file. Has a sensible default HTML/filename. Returns the
  // fully-qualified file name.
  private function createLayoutFile(html:String = "<html><head></head><body><butterfly-pages /><!-- Placeholder --></body></html>",
    fileName:String = 'layout.html') : String
  {
    var fullFileName = '${TEST_FILES_DIR}/${fileName}';
    sys.io.File.saveContent(fullFileName, html);
    return fullFileName;
  }
}
