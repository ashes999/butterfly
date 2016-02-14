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
    var modifier = new LayoutModifier(layoutFile, { "googleAnalyticsId": gaId });

    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf(gaCode) > -1);
  }

  @Test
  public function constructorAddsAtomLinkTagToHtml() {
    var layoutFile = createLayoutFile();
    var modifier = new LayoutModifier(layoutFile, { });
    var actualHtml = modifier.getHtml();
    Assert.isTrue(actualHtml.indexOf('<link type="application/atom+xml"') > -1);
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
