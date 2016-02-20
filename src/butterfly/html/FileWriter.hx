package butterfly.html;

import butterfly.core.Content;

class FileWriter {
  private var outputDir:String = "";

  public function new(outputDir:String) {
    this.outputDir = outputDir;
  }

  public function writeContent(content:Content, html:String) : Void
  {
    this.write('${content.url}.html', html);
  }

  public function write(fileName:String, html:String) : Void
  {
    var finalFileName = '${outputDir}/${fileName}';
    if (sys.FileSystem.exists(finalFileName)) {
      sys.FileSystem.deleteFile(finalFileName);
    }

    sys.io.File.saveContent(finalFileName, html);
  }
}
