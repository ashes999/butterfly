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

    var srcDir = Sys.args()[0];
    trace("Using " + srcDir + " as source directory ...");
    ensureDirExists(srcDir);

    var binDir = srcDir + "/bin";
    if (!sys.FileSystem.exists(binDir)) {
      sys.FileSystem.createDirectory(binDir);
      trace("Created " + binDir);
    }

    if (!sys.FileSystem.exists(srcDir + "/src/layout.html")) {
      errorAndExit("Can't find " + srcDir + "/src/layout.html");
    }

    var postsDir = srcDir + '/posts';
    ensureDirExists(postsDir);
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
