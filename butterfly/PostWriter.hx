package butterfly;

class PostWriter {
  public function new() {

  }

  public function write(html:String, post:butterfly.Post, outputDir:String) : Void
  {
    var finalFileName = outputDir + "/" + post.url + ".html";
    if (sys.FileSystem.exists(finalFileName)) {
      sys.FileSystem.deleteFile(finalFileName);
    }

    sys.io.File.saveContent(finalFileName, html);
  }
}
