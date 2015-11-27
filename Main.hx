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
    trace("Using " + projectDir + " as project directory ...");
    ensureDirExists(projectDir);

    var binDir = projectDir + "/bin";
    if (!sys.FileSystem.exists(binDir)) {
      sys.FileSystem.createDirectory(binDir);
      trace("Created " + binDir);
    }

    var srcDir = projectDir + "/src";
    ensureDirExists(srcDir);

    if (!sys.FileSystem.exists(srcDir + "/layout.html")) {
      errorAndExit("Can't find " + srcDir + "/layout.html");
    }

    var postsDir = srcDir + '/posts';
    ensureDirExists(postsDir);

    var filesAndDirs = sys.FileSystem.readDirectory(postsDir);
    var files = new Array<String>();
    for (entry in filesAndDirs) {
      if (!sys.FileSystem.isDirectory(postsDir + "/" + entry)) {
        files.push(entry);
      }
    }
  }

  private function errorAndExit(message:String) : Void {
    trace("Error: " + message);
    Sys.exit(1);
  }

  private function ensureDirExists(path:String) : Void {
    if (!sys.FileSystem.exists(path))  {
      errorAndExit(path + " doesn't exist");
    } else if (!sys.FileSystem.isDirectory(path)) {
      errorAndExit(path + " isn't a directory");
    }
  }
}
