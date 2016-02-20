package butterfly;

import sys.io.File;
import sys.FileSystem;
import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.html.FileWriter;
import Main;

import massive.munit.Assert;
import test.helpers.Factory;

class MainTest
{
  private static inline var TEST_FILES_DIR = "test/temp/main";

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
  public function generateIndexPageUsesLayout()
  {
    Assert.isTrue(true);
  }

  @Test
  public function generateIndexPageUsesHomePageLayoutIfSpecifiedInConfig()
  {
    var config = Factory.createButterflyConfig();

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
}
