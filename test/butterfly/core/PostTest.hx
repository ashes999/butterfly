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
  public function generateIndexPageUsesLayout()
  {
    var fileName = "filestat-ctime-in-unix";
    var markdown = "meta-tags: Haxe, unix
meta-title: FileStat.ctime in Unix

The rest of this content is just *placeholder* data. The content has to start at
the beginning of the line to match the meta-data regex.
    ";
    var actual:String = Content.getTitle(fileName, markdown);
    Assert.areEqual("FileStat.ctime in Unix", actual);
  }

  @Test
  public function parseParsesAllMetaDataProperly()
  {
    var id:String = "1356d551e2281e1b76b8e386b849d9794daba478";
    var title:String = "Animated GIFs in HaxeFlixel";
    var date:String = "2015-01-14";
    var tag:String = "HaxeFlixel";

    var markdown = 'meta-id: ${id}
meta-title: ${title}
meta-tags: ${tag}
meta-publishedOn: ${date}

Why would you want to display animated GIFs in a HaxeFlixel game? ...';

    var fullFileName = '${TEST_FILES_DIR}/title-from-filename.md';
    File.saveContent(fullFileName, markdown);
    var post:Post = Post.parse(fullFileName, false);

    Assert.areEqual(title, post.title);
    Assert.areEqual(1, post.tags.length);
    Assert.areEqual(tag, post.tags[0]);
    Assert.areEqual(Date.fromString(date).getTime(), post.createdOn.getTime());
    Assert.areEqual(id, post.id);
  }
}
