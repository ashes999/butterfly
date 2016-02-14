package butterfly.html;

import massive.munit.Assert;
import sys.FileSystem;
import sys.io.File;

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

    var modifier = new LayoutModifier(layoutFile, { "googleAnalyticsId": gaId });

    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf(gaCode) > -1);
  }

  @Test
  public function constructorAddsAtomLinkTagToHtml() {
    var layoutFile = createLayoutFile();

    var expectedSnippet = '<link type="application/atom+xml"';
    // Sanity check that default value layout doesn't have a hard-coded link tag
    Assert.isTrue(sys.io.File.getContent(layoutFile).indexOf(expectedSnippet) == -1);

    var modifier = new LayoutModifier(layoutFile, { });
    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf(expectedSnippet) > -1);
  }

  // Creates a layout file. Has a sensible default HTML/filename. Returns the
  // fully-qualified file name.
  private function createLayoutFile(html:String = "<html><head></head><body><!-- Placeholder --></body></html>",
    fileName:String = 'layout.html') : String
  {
    var fullFileName = '${TEST_FILES_DIR}/${fileName}';
    sys.io.File.saveContent(fullFileName, html);
    return fullFileName;
  }
}
