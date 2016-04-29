package butterfly.core;

import sys.io.File;
import sys.FileSystem;
import butterfly.core.Post;
import massive.munit.Assert;
using noor.io.FileSystemExtensions;

class PostTest
{
  private static inline var TEST_FILES_DIR = "test/temp/post";

  @Before
  public function createTestFilesDirectory() {
    FileSystem.createDirectory(TEST_FILES_DIR);
  }

  @After
  public function deleteTestFiles() {
    FileSystem.deleteDirectoryRecursively(TEST_FILES_DIR);
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
  
  @Test
  public function getPostTagsGetsTagsUniquely()
  {
      var p1 = new Post();
      p1.tags = ['apple', 'blueberry', 'peach'];
      var p2 = new Post();
      p2.tags = ['apple', 'cherry', 'egg'];
      
      var actual:Array<String> = Post.getPostTags([p1, p2]);
      Assert.areEqual(5, actual.length); // unique tags
      
      for (tag in p1.tags)
      {
          Assert.isTrue(actual.indexOf(tag) > -1);
      }
      
      for (tag in p2.tags)
      {
          Assert.isTrue(actual.indexOf(tag) > -1);
      }
  }
}
