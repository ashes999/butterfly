package butterfly.core;

import butterfly.core.Post;
import butterfly.core.Content;
using massive.munit.Assert;
using noor.io.FileSystemExtensions;
import sys.io.File;
import sys.FileSystem;

class ContentTest
{
  private static inline var TEST_FILES_DIR = "test/temp/content";

  @Before
  public function createTestFilesDirectory() {
    FileSystem.createDirectory(TEST_FILES_DIR);
  }

  @After
  public function deleteTestFiles() {
    FileSystem.deleteDirectoryRecursively(TEST_FILES_DIR);
  }

  @Test
  public function parseParsesUrlTitleAndIdProperly()
  {
    var id:String = "1356d551e2281e1b76b8e386b849d9794daba478";
    var title:String = "Animated GIFs in HaxeFlixel";
    var markdown = 'meta-id: ${id}
meta-title: ${title}

Why would you want to display animated GIFs in a HaxeFlixel game? ...';

    var fullFileName = '${TEST_FILES_DIR}/title-from-filename.md';
    File.saveContent(fullFileName, markdown);
    var content:Content = new Content();
    content.parse(fullFileName);

    Assert.areEqual(title, content.title);
    Assert.areEqual(id, content.id);
  }

  @Test
  public function parseAddsIdIfNoneExists()
  {
    var title:String = "Markdown File";
    var markdown = 'Simple markdown *here* ...';

    var fullFileName = '${TEST_FILES_DIR}/simple.md';
    File.saveContent(fullFileName, markdown);
    var content:Content = new Content();
    content.parse(fullFileName);

    Assert.isNotNull(content.id);
    Assert.isTrue(content.id.length > 0);
  }
}
