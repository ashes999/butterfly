package butterfly;

class FileWriter {
  private var outputDir:String = "";

  public function new(outputDir:String) {
    this.outputDir = outputDir;
  }

  public function writePost(post:butterfly.core.Post, html:String) : Void
  {
    this.write(post.url + ".html", html);
  }

  public function write(fileName:String, html:String) : Void
  {
    var finalFileName = outputDir + "/" + fileName;
    if (sys.FileSystem.exists(finalFileName)) {
      sys.FileSystem.deleteFile(finalFileName);
    }

    sys.io.File.saveContent(finalFileName, html);
  }
}
