package butterfly.core;

import sys.io.File;
import sys.FileSystem;
import butterfly.core.Post;
import massive.munit.Assert;

class PostTest
{
  private static inline var TEST_FILES_DIR = "test/temp/post";

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
  public function parseParsesTagsAndPublishDate()
  {
    var date:String = "2015-01-14";
    var tag:String = "HaxeFlixel";

    var markdown = 'meta-tags: ${tag}
meta-publishedOn: ${date}

Why would you want to display animated GIFs in a HaxeFlixel game? ...';

    var fullFileName = '${TEST_FILES_DIR}/first_post.md';
    File.saveContent(fullFileName, markdown);
    var post:Post = new Post();
    post.parse(fullFileName);

    Assert.areEqual(1, post.tags.length);
    Assert.areEqual(tag, post.tags[0]);
    Assert.areEqual(Date.fromString(date).getTime(), post.createdOn.getTime());
  }
}
