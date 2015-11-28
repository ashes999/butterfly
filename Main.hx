using StringTools;

class Main {
  static public function main() : Void {
    new Main().run();
  }

  public function new() {

  }

  public function run() : Void {
    if (Sys.args().length != 1) {
      errorAndExit("Usage: neko Main.n <source directory>");
    }

    var projectDir = Sys.args()[0];
    trace("Using " + projectDir + " as project directory");
    ensureDirExists(projectDir);

    var binDir = projectDir + "/bin";
    if (sys.FileSystem.exists(binDir)) {
      // always clean/rebuild
      deleteDirRecursively(binDir);
      sys.FileSystem.createDirectory(binDir);
    }

    var srcDir = projectDir + "/src";
    ensureDirExists(srcDir);

    // Copy *.css and favicon over
    copyFiles(srcDir, '.css', binDir);
    copyFiles(srcDir, '.ico', binDir);

    var layoutFile = srcDir + "/layout.html";
    if (!sys.FileSystem.exists(layoutFile)) {
      errorAndExit("Can't find " + layoutFile);
    }

    var postsDir = srcDir + '/posts';
    ensureDirExists(postsDir);

    var filesAndDirs = sys.FileSystem.readDirectory(postsDir);
    var posts = new Array<butterfly.Post>();

    for (entry in filesAndDirs) {
      var relativePath = postsDir + "/" + entry;
      if (!sys.FileSystem.isDirectory(relativePath)) {
        posts.push(butterfly.Post.parse(relativePath));
      }
    }

    var writer = new butterfly.PostWriter();
    var generator = new butterfly.HtmlGenerator(layoutFile);

    for (post in posts) {
      var html = generator.generateHtml(post);
      writer.write(html, post, binDir);
    }

    trace("Generated " + posts.length + " posts.");
  }

  private function errorAndExit(message:String) : Void
  {
    trace("Error: " + message);
    Sys.exit(1);
  }

  private function ensureDirExists(path:String) : Void
  {
    if (!sys.FileSystem.exists(path)) {
      errorAndExit(path + " doesn't exist");
    } else if (!sys.FileSystem.isDirectory(path)) {
      errorAndExit(path + " isn't a directory");
    }
  }
  
  // endOfName: eg. ".css"
  private function copyFiles(srcDir:String, endOfName:String, destDir:String) : Void
  {
      var entries = sys.FileSystem.readDirectory(srcDir);
      for (entry in entries) {
        if (entry.endsWith(endOfName)) {
          sys.io.File.copy(srcDir + '/' + entry, destDir + '/' + entry);
        }
      }
  }

  private function deleteDirRecursively(path:String) : Void
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
    {
      var entries = sys.FileSystem.readDirectory(path);
      for (entry in entries) {
        if (sys.FileSystem.isDirectory(path + '/' + entry)) {
          deleteDirRecursively(path + '/' + entry);
          sys.FileSystem.deleteDirectory(path + '/' + entry);
        } else {
          sys.FileSystem.deleteFile(path + '/' + entry);
        }
      }
    }
  }
}
