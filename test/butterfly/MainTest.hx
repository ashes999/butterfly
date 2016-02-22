package butterfly;

import sys.io.File;
import sys.FileSystem;
import butterfly.core.Page;
import butterfly.core.Post;
import butterfly.html.FileWriter;
import Main;

import massive.munit.Assert;
import test.helpers.Factory;
import test.helpers.ContentMaker;

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

  @Test
  public function sortPostsSortsPostsReverseChronologically()
  {
    // Create three posts, out of order (with respect to their "order" field);
    var firstPost = ContentMaker.createPost('meta-publishedOn: 2011-01-31\r\nFirst post!', '${TEST_FILES_DIR}/first.md');
    var secondPost = ContentMaker.createPost('meta-publishedOn: 2016-02-21\r\nSecond post!!', '${TEST_FILES_DIR}/second.md');
    var thirdPost = ContentMaker.createPost('meta-publishedOn: 2016-02-22\r\nThird post!!!', '${TEST_FILES_DIR}/third.md');

    var posts:Array<Post> = [secondPost, thirdPost, firstPost];
    new Main().sortPosts(posts);
    Assert.areEqual(0, posts.indexOf(thirdPost));
    Assert.areEqual(1, posts.indexOf(secondPost));
    Assert.areEqual(2, posts.indexOf(firstPost));
  }

  @Test
  public function sortPagesSortsPagesByOrderAscending()
  {
    // Create three pages, out of order (with respect to their "order" field);
    var firstPage = ContentMaker.createPage('meta-order: -3\r\nFirst post!', '${TEST_FILES_DIR}/first.md');
    // default (0)
    var secondPage = ContentMaker.createPage('Second post!!', '${TEST_FILES_DIR}/second.md');
    var thirdPage = ContentMaker.createPage('meta-order: 1\r\nThird post!!!', '${TEST_FILES_DIR}/third.md');

    var pages:Array<Page> = [thirdPage, secondPage, firstPage];
    new Main().sortPages(pages);
    Assert.areEqual(0, pages.indexOf(firstPage));
    Assert.areEqual(1, pages.indexOf(secondPage));
    Assert.areEqual(2, pages.indexOf(thirdPage));
  }
}
